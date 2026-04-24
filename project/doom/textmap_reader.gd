class_name DoomTextmap
extends Resource
## Handles loading a UDMF textmap into a generic [Dictionary].


## Unicodes characters that are not allowed in keywords or identifiers.
const BAD_WORD_CHARS: Array[int] = [
	ord('{'), ord('}'), # Braces
	ord('('), ord(')'), # Parentheses
	ord(';'), # Semicolon
	ord('"'), ord('\''), # Quotes
	ord('\n'), ord('\t'), ord(' '), # Whitespace
	ord('\u0000') # Null
]


## Every type of token that can be interpreted by the scanner.
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


## All keywords this format supports, mapped to their token.
const KEYWORDS: Dictionary[StringName, TokenType] = {
	&'true': TokenType.TRUE,
	&'false': TokenType.FALSE,
}


## All tokens that are considered values, for assignments.
const VALUE_TOKENS: Array[TokenType] = [
	TokenType.INT,
	TokenType.FLOAT,
	TokenType.STRING,
	TokenType.TRUE,
	TokenType.FALSE,
]


## Represents a single token that was scanned.
class Token:
	## The line number this token was found on, in the original [String].
	var line: int = 0

	## What kind of token this is.
	var type: TokenType = TokenType.ERROR

	## The text that was scanned to create this token.
	var lexeme: String = ''

	## The text converted into a literal value.
	## This is only set for certain kinds of tokens.
	var literal: Variant = null

	func _init(p_type: TokenType, p_line: int, p_lexeme: String, p_literal: Variant = null) -> void:
		type = p_type
		line = p_line
		lexeme = p_lexeme
		literal = p_literal


## A [Dictionary] representing the textmap's output.
var data: Dictionary[StringName, Variant] = {}


## Handles scanning the text for tokens.
class Scanner:
	## All of the [class Token]s that were scanned.
	var tokens: Array[Token] = []

	## The [String] that this was derived from.
	var source: String = ''

	var _start: int = 0 # Scan start position
	var _position: int = 0 # Scan current position
	var _line_count: int = 0 # Scanned lines


	## Adds a new token to our running list of tokens.
	func add_token(type: TokenType, literal: Variant = null) -> Token:
		if type == TokenType.ERROR:
			push_error("TEXTMAP scan failure, line %d: %s" % [_line_count, literal])

		var lexeme := source.substr(_start, _position - _start)
		var token: Token = Token.new(type, _line_count, lexeme, literal)
		tokens.push_back(token)
		return token


	## Returns [code]true[/code] if the scan cursor
	## passes the end of the string. Setting [param distance]
	## can check farther than the scan cursor.
	func at_end(distance: int = 0) -> bool:
		return _position + distance >= source.length()


	## Returns the next unicode character, and advances the scan cursor
	## by [param distance].
	func advance(distance: int = 0) -> int:
		var ret: int = source.unicode_at(_position)
		_position += distance + 1
		return ret


	## Returns [code]true[/code] if the next unicode matches
	## the given [param expected] unicode character.
	## Conditionally advances the cursor position if it matches.
	func matches(expected: int) -> bool:
		if at_end():
			return false

		var ret: int = source.unicode_at(_position)
		if ret != expected:
			return false

		_position += 1
		return true


	## Returns the unicode at the scan cursor, without
	## advancing it. Setting [param distance]
	## can check farther than the scan cursor.
	func peek(distance: int = 0) -> int:
		if at_end(distance):
			return ord('\u0000')

		return source.unicode_at(_position + distance)


	## Skips ALL text until reaching the next new line.
	func skip_comment() -> void:
		while (at_end() == false):
			if peek() == ord('\n'):
				break

			advance()


	## Skips ALL text until reaching the next multi-line comment closer, "*/".
	func skip_comment_multiline() -> void:
		while (at_end() == false):
			if (peek(0) == ord('*') and peek(1) == ord('/')):
				advance(1)
				break

			advance()


	## Interprets the text at the current cursor position
	## as a string.
	func scan_string() -> Token:
		while (at_end() == false):
			var next := peek()
			if (next == ord('"') and source.unicode_at(_position) != ord('\\')):
				# Don't call advance here, we need to check for EOF
				break

			if next == ord('\n'):
				_line_count += 1

			advance()

		if at_end():
			return add_token(TokenType.ERROR, 'Got unterminated string')

		# Skip closing quote
		advance()

		var str_without_quotes := source.substr(_start + 1, _position - _start - 2)
		return add_token(TokenType.STRING, str_without_quotes)


	## Interprets the text at the current cursor position
	## as a "word". This can be either an integer, a float,
	## an identifier, or a keyword. Note that strings are
	## handled by [method scan_string] instead.
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


	## Interprets the text at the current cursor position
	## as a token, and adds it to our running list.
	## Returns the token that was created. This may be type ERROR
	## if an error occurred.
	func scan_token() -> Token:
		var c: int = advance()

		match c:
			ord(' '), ord('\t'):
				return null
			ord('\n'):
				_line_count += 1
				return null
			ord('='):
				return add_token(TokenType.ASSIGN, String.chr(c))
			ord(';'):
				return add_token(TokenType.END, String.chr(c))
			ord('{'):
				return add_token(TokenType.BLOCK_START, String.chr(c))
			ord('}'):
				return add_token(TokenType.BLOCK_END, String.chr(c))
			ord('/'):
				if matches(ord('/')):
					skip_comment()
					return null
				elif matches(ord('*')):
					skip_comment_multiline()
					return null
			ord('"'):
				return scan_string()

		if c in BAD_WORD_CHARS:
			return add_token(TokenType.ERROR, 'Unexpected character "%s"' % String.chr(c))

		return scan_word()


	## Attempts to break the [String] into a list of tokens.
	## Returns the [Array] of tokens that was created. If it is
	## empty, then an error occurred while parsing.
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


## Handles scanning the text for tokens.
class Parser:
	## All of the [class Token]s to parse.
	var tokens: Array[Token] = []


	## All of the parsed data
	var parsed: Dictionary[StringName, Variant] = {}


	# Current token index
	var _position: int = 0

	# Working on a block...
	var _in_block: StringName = &''

	# Current working block
	var _block: Dictionary[StringName, Variant] = {}

	# Error already thrown, don't throw any more.
	var _error := false


	## Throws a parser error.
	func throw_error(msg: String, token: Token = null) -> void:
		if _error:
			return

		if (token == null and at_end() == false):
			# Try to infer what the token is...
			token = tokens[_position]

		var full_msg: String
		if token != null:
			full_msg = 'TEXTMAP parse failure, line %d: %s' % [token.line, msg]
		else:
			full_msg = 'TEXTMAP parse failure: %s' % msg

		push_error(full_msg)
		_error = true


	## Returns [code]true[/code] if the parse cursor
	## passes the end of the file. Setting [param distance]
	## can check farther than the parse cursor.
	func at_end(distance: int = 0) -> bool:
		assert(distance >= 0)
		if _position + distance >= tokens.size():
			return true
		var ret: Token = tokens[_position + distance]
		return (ret.type == TokenType.EOF)


	## Returns the next token, and advances the parse cursor
	## by [param distance].
	func advance(distance: int = 0) -> Token:
		assert(distance >= 0)
		var ret: Token = tokens[_position]
		_position += distance + 1
		return ret


	## Returns [code]true[/code] if the next token matches
	## the given [param type]. Conditionally advances the
	## cursor position if the type matches.
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


	## Returns the token at the parse cursor, without
	## advancing it. Setting [param distance]
	## can check farther than the parse cursor.
	func peek(distance: int = 0) -> Token:
		assert(distance >= 0)
		if at_end(distance):
			return tokens.back()

		return tokens[_position + distance]


	## Attempts to process the current cursor position as
	## an assignment expression.
	## Returns [code]false[/code] if an error was thrown.
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


	## Attempts to process the current cursor position as
	## a block's expression list.
	## Returns [code]false[/code] if an error was thrown.
	func expr_list() -> bool:
		while (peek().type != TokenType.BLOCK_END):
			if assignment_expr() == false:
				throw_error('Invalid assignment expression')
				return false

		return true


	## Attempts to process the current cursor position as
	## a new block.
	## Returns [code]false[/code] if an error was thrown.
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


	## Attempts to process the current cursor position as
	## a single global space expression.
	## Returns [code]false[/code] if an error was thrown.
	func global_expr() -> bool:
		var symbol := peek(1)
		match symbol.type:
			TokenType.BLOCK_START:
				return block()
			TokenType.ASSIGN:
				return assignment_expr()

		return false


	## Attempts to process the current cursor position as
	## the global space's entire expression list.
	## Returns [code]false[/code] if an error was thrown.
	func global_expr_list() -> bool:
		while (at_end() == false):
			if global_expr() == false:
				throw_error('Invalid global expression')
				return false

		return true


	## Attempts to process a scanned token list.
	## Returns the [Dictionary] that was created. If it is
	## empty, then an error occurred while parsing.
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
