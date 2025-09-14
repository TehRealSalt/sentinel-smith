class_name DoomTextmap
extends Resource

# TODO: Replace these with ord in Godot 4.5
# Whitespace
const _NULL := 0x00 #ord('\0')
const _NEW_LINE := 0x0a #ord('\n')
const _TAB := 0x09 #ord('\t')
const _SPACE := 0x20 #ord(' ')

# Key symbols
const _EQUAL := 0x3d #ord('=')
const _SEMICOLON := 0x3b #ord(';')
const _OPEN := 0x28 #ord('(')
const _CLOSE := 0x29 #ord(')')
const _BRACE_OPEN := 0x7b #ord('{')
const _BRACE_CLOSE := 0x7d #ord('}')
const _QUOTE := 0x22 #ord('"')
const _QUOTE_SINGLE := 0x27 #ord('\'')

# Comments
const _SLASH := 0x2f #ord('/')
const _SLASH_BACK := 0x2f #ord('\\')
const _STAR := 0x2a #ord('*')


const BAD_WORD_CHARS: Array[int] = [
	_BRACE_OPEN,
	_BRACE_CLOSE,
	_OPEN,
	_CLOSE,
	_SEMICOLON,
	_QUOTE,
	_QUOTE_SINGLE,
	_NEW_LINE,
	_TAB,
	_SPACE,
	_NULL
]


enum TokenType
{
	ERROR,

	# Small characters
	ASSIGN,
	END,
	BLOCK_START,
	BLOCK_END,

	# values
	INT,
	FLOAT,
	STRING,

	# keywords
	TRUE,
	FALSE,

	# other
	IDENTIFIER,
	EOF,
}


const KEYWORDS: Dictionary[StringName, TokenType] = {
	&'true': TokenType.TRUE,
	&'false': TokenType.FALSE,
}


class Token:
	var line: int = 0
	var type: TokenType = TokenType.ERROR
	var lexeme: String = ''
	var literal: Variant = null

	func _init(p_type: TokenType, p_line: int, p_lexeme: String, p_literal: Variant = null) -> void:
		type = p_type
		line = p_line
		lexeme = p_lexeme
		literal = p_literal


## A [Dictionary] representing the Textmap's output.
var data: Dictionary[StringName, Variant] = {}


class Scanner:
	## All of the [class Token]s that were scanned.
	var tokens: Array[Token] = []

	## The [String] that this was derived from.
	var source: String = ''

	var _start: int = 0 # Scan start position
	var _position: int = 0 # Scan current position
	var _line_count: int = 0 # Scanned lines

	func add_token(type: TokenType, literal: Variant = null) -> Token:
		if type == TokenType.ERROR:
			push_error("TEXTMAP scan failure, line %d: %s" % [_line_count, literal])

		var lexeme := source.substr(_start, _position - _start)
		var token: Token = Token.new(type, _line_count, lexeme, literal)
		tokens.push_back(token)
		return token


	func at_end(distance: int = 0) -> bool:
		return _position + distance >= source.length()


	func advance(distance: int = 0) -> int:
		var ret: int = source.unicode_at(_position)
		_position += distance + 1
		return ret


	func matches(expected: int) -> bool:
		if at_end():
			return false

		var ret: int = source.unicode_at(_position)
		if ret != expected:
			return false

		_position += 1
		return true


	func peek(distance: int = 0) -> int:
		if at_end(distance):
			return _NULL

		return source.unicode_at(_position + distance)


	func skip_comment() -> void:
		while (at_end() == false):
			if peek() == _NEW_LINE:
				break

			advance()


	func skip_comment_multiline() -> void:
		while (at_end() == false):
			if (peek(0) == _STAR and peek(1) == _SLASH):
				advance(1)
				break

			advance()


	func scan_string() -> Token:
		while (at_end() == false):
			var next := peek()
			if (next == _QUOTE and source.unicode_at(_position) != _SLASH_BACK):
				# Don't call advance here, we need to check for EOF
				break

			if next == _NEW_LINE:
				_line_count += 1

			advance()

		if at_end():
			return add_token(TokenType.ERROR, 'Got unterminated string')

		# Skip closing quote
		advance()

		var str_without_quotes := source.substr(_start + 1, _position - _start - 2)
		return add_token(TokenType.STRING, str_without_quotes)


	func scan_word() -> Token:
		while (at_end() == false):
			var next := peek()
			if next in BAD_WORD_CHARS:
				break

			advance()

		var word := source.substr(_start, _position - _start)

		# TODO: I think this is the right priority, but I haven't confirmed
		if word.is_valid_hex_number(true):
			return add_token(TokenType.INT, word.hex_to_int())
		elif word.is_valid_int():
			return add_token(TokenType.INT, word.to_int())
		elif word.is_valid_float():
			return add_token(TokenType.FLOAT, word.to_float())
		elif word.is_valid_ascii_identifier():
			if KEYWORDS.has(word):
				return add_token(KEYWORDS[word])
			return add_token(TokenType.IDENTIFIER, word)

		return add_token(TokenType.ERROR, 'Invalid word "%s"' % word)


	func scan_token() -> Token:
		var c: int = advance()

		match c:
			_SPACE, _TAB:
				return null
			_NEW_LINE:
				_line_count += 1
				return null
			_EQUAL:
				return add_token(TokenType.ASSIGN, String.chr(c))
			_SEMICOLON:
				return add_token(TokenType.END, String.chr(c))
			_BRACE_OPEN:
				return add_token(TokenType.BLOCK_START, String.chr(c))
			_BRACE_CLOSE:
				return add_token(TokenType.BLOCK_END, String.chr(c))
			_SLASH:
				if matches(_SLASH):
					skip_comment()
					return null
				elif matches(_STAR):
					skip_comment_multiline()
					return null
			_QUOTE:
				return scan_string()

		if c in BAD_WORD_CHARS:
			return add_token(TokenType.ERROR, 'Unexpected character "%s"' % String.chr(c))

		return scan_word()


	func scan() -> Array[Token]:
		tokens.clear()
		_start = 0
		_position = 0
		_line_count = 1

		while (at_end() == false):
			_start = _position
			var token := scan_token()
			if token:
				if token.type == TokenType.ERROR:
					return []
				if token.type == TokenType.EOF:
					return tokens

		add_token(TokenType.EOF)
		return tokens


	func _init(p_source: String) -> void:
		source = p_source


class Parser:
	## All of the [class Token]s to parse.
	var tokens: Array[Token] = []

	## All of the parsed data
	var parsed: Dictionary[StringName, Variant] = {}

	var _position: int = 0 # Current token index

	var _in_block: StringName = &'' # Working on a block...
	var _block: Dictionary[StringName, Variant] = {} # Current working block

	var _error := false
	func throw_error(msg: String, token: Token = null) -> void:
		if _error:
			return

		var full_msg: String
		if (token == null and at_end() == false):
			token = tokens[_position]

		if token != null:
			full_msg = "TEXTMAP scan failure, line %d: %s" % [token.line, msg]
		else:
			full_msg = "TEXTMAP scan failure: %s" % msg

		push_error(full_msg)
		_error = true


	func at_end(distance: int = 0) -> bool:
		assert(distance >= 0)
		if _position + distance >= tokens.size():
			return true
		var ret: Token = tokens[_position + distance]
		return (ret.type == TokenType.EOF)


	func advance(distance: int = 0) -> Token:
		assert(distance >= 0)
		var ret: Token = tokens[_position]
		_position += distance + 1
		return ret


	func matches(expected_type: TokenType) -> bool:
		var token: Token
		if at_end():
			token = tokens.back()
		else:
			token = tokens[_position]

		if token.type != expected_type:
			return false

		_position += 1
		return true


	func peek(distance: int = 0) -> Token:
		assert(distance >= 0)
		if at_end(distance):
			return tokens.back()

		return tokens[_position + distance]


	const VALUE_TOKENS: Array[TokenType] = [
		TokenType.INT,
		TokenType.FLOAT,
		TokenType.STRING,
		TokenType.TRUE,
		TokenType.FALSE,
	]

	func assignment_expr() -> bool:
		var identifier := advance()
		if identifier.type != TokenType.IDENTIFIER:
			throw_error('Expected identifier, got "%s"' % identifier.lexeme, identifier)
			return false

		var symbol := advance()
		if symbol.type != TokenType.ASSIGN:
			throw_error('Expected "=", got "%s"' % symbol.lexeme, symbol)
			return false

		var value := advance()
		if not value.type in VALUE_TOKENS:
			throw_error('Invalid value "%s"; expected [int/float/string/bool]' % value.lexeme, value)
			return false

		var bookend := advance()
		if bookend.type != TokenType.END:
			throw_error('Expected ";", got "%s"' % bookend.lexeme, bookend)
			return false

		var assign_to: Dictionary[StringName, Variant]
		if _in_block.is_empty():
			assign_to = parsed
		else:
			assign_to = _block

		var name: StringName = identifier.literal
		var literal: Variant = value.literal

		if literal == null:
			# Handle keywords
			match value.type:
				TokenType.TRUE:
					literal = true
				TokenType.FALSE:
					literal = false
				_:
					throw_error('Invalid keyword "%s"' % value.lexeme, value)
					return false

		assign_to[name] = literal
		return true


	func expr_list() -> bool:
		while (peek().type != TokenType.BLOCK_END):
			if assignment_expr() == false:
				throw_error('Invalid assignment expression')
				return false

		return true


	func block() -> bool:
		if not _in_block.is_empty():
			throw_error('Tried to start block within a block')
			return false

		var identifier := advance()
		if identifier.type != TokenType.IDENTIFIER:
			throw_error('Expected identifier, got "%s"' % identifier.lexeme, identifier)
			return false

		var symbol := advance()
		if symbol.type != TokenType.BLOCK_START:
			throw_error('Expected "{", got "%s"' % symbol.lexeme, symbol)
			return false

		_in_block = identifier.lexeme

		var result := expr_list()
		if not result:
			throw_error('Invalid block expressions')
			return false

		var bookend := advance()
		if bookend.type != TokenType.BLOCK_END:
			throw_error('Expected "}", got "%s"' % bookend.lexeme, bookend)
			return false

		var arr: Array = parsed.get_or_add(_in_block, [])
		arr.push_back(_block)

		_in_block = &''
		_block = {}
		return true


	func global_expr() -> bool:
		var symbol := peek(1)
		match symbol.type:
			TokenType.BLOCK_START:
				return block()
			TokenType.ASSIGN:
				return assignment_expr()

		return false


	func global_expr_list() -> bool:
		while (at_end() == false):
			if global_expr() == false:
				throw_error('Invalid global expression')
				return false

		return true


	func translation_unit() -> Dictionary[StringName, Variant]:
		parsed = {}
		_position = 0

		if global_expr_list() == false:
			# Invalid, throw empty dictionary
			throw_error('Failure')
			return {}

		return parsed


	func _init(p_tokens: Array[Token]) -> void:
		tokens = p_tokens


func _init(from: String) -> void:
	PerfTiming.start(&'TEXTMAP.scan')
	var scanner := Scanner.new(from)
	var tokens := scanner.scan()
	PerfTiming.stop(&'TEXTMAP.scan')

	if tokens.is_empty():
		return

	PerfTiming.start(&'TEXTMAP.parse')
	var parser := Parser.new(tokens)
	data = parser.translation_unit()
	PerfTiming.stop(&'TEXTMAP.parse')
