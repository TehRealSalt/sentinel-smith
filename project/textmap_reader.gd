class_name DoomTextmap
extends Resource

# Some RegEx for the different tokens.
# Ideally we'd use this as a full table but my head's spinning keeping
# all of the state together so I'm going for caveman parsing instead

const PATTERNS: Dictionary[StringName, String] = {
	&'string': r'"([^"\\]*(\\.[^"\\]*)*)"',
	&'float': r'[+-]?[0-9]+\.[0-9]*([eE][+-]?[0-9]+)?',
	&'int': r'[+-]?[1-9]+[0-9]*|[00-9]+|0x[0-9A-Fa-f]+',
	&'bool': r'(true|false)',
	&'identifier': r'[A-Za-z_]+[A-Za-z0-9_]*',
	#&'comment': r'\/\/.*',
	#&'comment_block_start': r'\/\*',
	#&'comment_block_end': r'\*\/',
	&'assign': r'=',
	&'end': r'\;',
	&'block_start': r'\{',
	&'block_end': r'\}',
}

const VALUES: Array[StringName] = [&'string', &'float', &'int', &'bool']


class Token:
	# Just some helper functions on top of RegExMatch
	var regex_match: RegExMatch = null
	var line: int = 0

	func get_types() -> Array[StringName]:
		if regex_match == null:
			return [&"eof"]

		var ret: Array[StringName] = []
		for t: String in regex_match.names.keys():
			ret.push_back(t)

		return ret


	func is_type(allowed_types: Array[StringName]) -> bool:
		var types: Array[StringName] = get_types()
		for type: StringName in allowed_types:
			if type in types:
				return true

		return false


	func get_value(type: StringName) -> String:
		if regex_match == null:
			return ""

		return regex_match.get_string(type)


	func _init(from_match: RegExMatch, from_line: int) -> void:
		regex_match = from_match
		line = from_line


var tokens: Array[Token]
var token_pos: int = 0


var _rules: RegEx = null
var _source: String = ""
var _position: int = 0


func _add_token() -> Token:
	if _position >= _source.length():
		return null

	var result := _rules.search(_source, _position)
	if result == null:
		return null

	var line_num := 1 + _source.count('\n', 0, result.get_start())
	var token := Token.new(result, line_num)
	tokens.push_back(token)

	_position = result.get_end()
	return token


func _advance_token(allowed_types: Array[StringName]) -> Token:
	var prev_line := 1
	if tokens[token_pos]:
		prev_line = tokens[token_pos].line

	var ret: Token = null
	if token_pos < tokens.size():
		ret = tokens[token_pos]
		token_pos += 1

	if ret == null:
		push_error("Line %d: Expected %s, got null" % [prev_line, allowed_types])
		return null

	if not ret.is_type(allowed_types):
		push_error("Line %d: Expected %s, got %s" % [ret.line, allowed_types, ret.get_types()])
		return null

	return ret


func text_to_str(input: String) -> String:
	return input.trim_prefix('"').trim_suffix('"')


func text_to_int(input: String) -> int:
	if input.is_valid_hex_number(true):
		return input.hex_to_int()

	return input.to_int()


func text_to_float(input: String) -> float:
	assert(input.is_valid_float())
	return input.to_float()


func text_to_bool(input: String) -> bool:
	assert(input == 'true' or input == 'false')
	return (input == 'true')


var _value_type_to_entry: Dictionary[StringName, Callable] = {
	&'string': text_to_str,
	&'float': text_to_float,
	&'int': text_to_int,
	&'bool': text_to_bool,
}

var _block_stack: Array[Dictionary] = []


func _get_working_block() -> Dictionary:
	assert(_block_stack.is_empty() == false)
	return _block_stack.back()


func _push_block() -> void:
	_block_stack.push_back({})


func _pop_block() -> Dictionary:
	assert(_block_stack.is_empty() == false)
	return _block_stack.pop_back()


func _try_assignment_expr(identifier: String) -> Token:
	# assignment_expr
	var value_token := _advance_token(VALUES)
	if value_token == null:
		return null

	for value_type: StringName in VALUES:
		var value := value_token.get_value(value_type)
		if value.is_empty():
			continue

		var entry_type: Callable = _value_type_to_entry[value_type]
		var block := _get_working_block()
		block[identifier] = entry_type.call(value)

		var close_token := _advance_token([&"end"])
		if close_token == null:
			return null

		return close_token

	assert(false, "Invalid assignment value type?")
	return null


func _try_expr_list(identifier_token: Token) -> Token:
	var identifier := identifier_token.get_value(&"identifier")
	assert(identifier.is_empty() == false)

	var symbol_token := _advance_token([&"assign"])
	if symbol_token == null:
		return null

	return _try_assignment_expr(identifier)


func _try_block(block_identifier: String) -> Token:
	var size := _block_stack.size()
	_push_block()

	var token: Token = null
	while true:
		token = _advance_token([&"identifier", &"block_end"])
		if token == null:
			return null

		if token.is_type([&"block_end"]):
			var created_block := _pop_block()
			var work_block := _get_working_block()
			work_block[block_identifier] = created_block

			assert(size == _block_stack.size())
			return token

		token = _try_expr_list(token)
		if token == null:
			return null

	return null


func _try_global_expr(identifier_token: Token) -> Token:
	# global_expr
	var identifier := identifier_token.get_value(&"identifier")
	assert(identifier.is_empty() == false)

	var symbol_token := _advance_token([&"block_start", &"assign"])
	if symbol_token == null:
		return null

	if symbol_token.is_type([&"assign"]):
		return _try_assignment_expr(identifier)
	elif symbol_token.is_type([&"block_start"]):
		return _try_block(identifier)
	else:
		assert(false, "Invalid expression type?")
		return null


var data: Dictionary = {}

func _init(from: String) -> void:
	data = {}

	_source = from

	var rule_parts: PackedStringArray = []
	for pattern: StringName in PATTERNS.keys():
		rule_parts.push_back(r'(?<%s>%s)' % [pattern, PATTERNS[pattern]])
	_rules = RegEx.create_from_string('|'.join(rule_parts))

	while (_add_token()):
		pass

	var file_lines := 1 + _source.count('\n')
	var eof_token := Token.new(null, file_lines)
	tokens.push_back(eof_token)

	# translation_unit
	_push_block()

	var token: Token = null
	while true:
		# global_expr_list
		token = _advance_token([&"identifier", &"eof"])
		if token == null:
			return

		if token.is_type([&"eof"]):
			break

		token = _try_global_expr(token)
		if token == null:
			return

	assert(_block_stack.size() == 1)
	data = _pop_block()
