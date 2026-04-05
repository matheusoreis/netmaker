## Representa um erro de validação produzido por um [ZodotSchema].
##
## Contém o caminho até o campo inválido, a mensagem descritiva
## e um contexto opcional com dados adicionais sobre a falha.
extends RefCounted
class_name ZodotError


## Caminho até o campo que originou o erro, representado como uma lista de chaves.
var path: Array[String]

## Mensagem descritiva do erro de validação.
var message: String

## Dados de contexto adicionais sobre o erro. Pode ser [code]null[/code].
var context: Variant


## Inicializa o erro com o [param path], o [param message] e um [param context] opcional.
func _init(path: Array[String], message: String, context: Variant = null) -> void:
	self.path = path
	self.message = message
	self.context = context


## Retorna o [member path] formatado como string separada por pontos,
## ou uma string vazia se o caminho estiver vazio.
func get_path_string() -> String:
	return ".".join(path) if not path.is_empty() else ""
