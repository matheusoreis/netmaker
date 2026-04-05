## Resultado de uma validação executada por um [ZodotSchema].
##
## Encapsula o sucesso ou falha da validação, o dado resultante
## e os erros encontrados. Use [method ok] e [method fail] para construir instâncias.
extends RefCounted
class_name ZodotResult


## Indica se a validação foi bem-sucedida.
var success: bool

## Dado validado e retornado em caso de sucesso. Pode ser [code]null[/code] em caso de falha.
var data: Variant

## Lista de erros encontrados durante a validação. Vazia em caso de sucesso.
var errors: Array[ZodotError]


## Inicializa o resultado com [param success], o [param data] resultante
## e os [param errors] encontrados.
func _init(success: bool, data: Variant = null, errors: Array[ZodotError] = []) -> void:
	self.success = success
	self.data = data
	self.errors = errors


## Cria um [ZodotResult] de sucesso contendo o [param data] validado.
static func ok(data: Variant) -> ZodotResult:
	return ZodotResult.new(true, data)


## Cria um [ZodotResult] de falha contendo os [param errors] encontrados.
static func fail(errors: Array[ZodotError]) -> ZodotResult:
	return ZodotResult.new(false, null, errors)


## Retorna um [Dictionary] agrupando os erros por campo.
## A chave é o caminho do campo (via [method ZodotError.get_path_string])
## ou [code]"_root"[/code] para erros sem caminho. O valor é a mensagem do erro
## ou um [Array] de mensagens caso haja múltiplos erros no mesmo campo.
func get_errors_by_field() -> Dictionary:
	var result: Dictionary = {}

	for error in errors:
		var field = error.get_path_string()
		if field.is_empty():
			field = "_root"

		if not result.has(field):
			result[field] = error.message
		else:
			if result[field] is String:
				result[field] = [result[field]]
			if result[field] is Array:
				result[field].append(error.message)

	return result


## Retorna todos os erros concatenados em uma única string.
## O [param separator] define o separador entre as mensagens (padrão: [code]"\n"[/code]).
## Erros com caminho são formatados como [code]"campo: mensagem"[/code].
func get_errors_text(separator: String = "\n") -> String:
	var messages: Array[String] = []

	for error in errors:
		var field = error.get_path_string()
		if field.is_empty():
			messages.append(error.message)
		else:
			messages.append("%s: %s" % [field, error.message])

	return separator.join(messages)


## Retorna o primeiro [ZodotError] da lista, ou [code]null[/code] se não houver erros.
func get_first_error() -> ZodotError:
	return errors[0] if not errors.is_empty() else null


## Retorna [code]true[/code] se houver algum erro cujo caminho corresponda ao [param field] fornecido.
func has_error(field: String) -> bool:
	for error in errors:
		if error.get_path_string() == field:
			return true
	return false


## Retorna o primeiro [ZodotError] cujo caminho corresponda ao [param field] fornecido,
## ou [code]null[/code] se não for encontrado.
func get_error(field: String) -> ZodotError:
	for error in errors:
		if error.get_path_string() == field:
			return error
	return null
