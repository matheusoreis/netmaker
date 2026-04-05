## Classe base para todos os schemas de validação do Zodot.
##
## Fornece a lógica central de validação, suporte a valores opcionais,
## nullable, default e checks customizados via [method refine].
## Não deve ser usada diretamente — utilize as subclasses concretas.
extends RefCounted
class_name ZodotSchema


var _checks: Array[Callable] = []  ## Lista de checks customizados registrados via [method refine].
var _type_message: String          ## Mensagem de erro emitida quando a validação de tipo falha.
var _is_optional: bool = false     ## Indica se o schema aceita [code]null[/code] como valor válido.
var _is_nullable: bool = false     ## Indica se o schema aceita [code]null[/code] sem substituir por default.
var _has_default: bool = false     ## Indica se um valor default foi definido via [method default].
var _default_value: Variant = null ## Valor retornado quando a entrada é [code]null[/code] e um default foi definido.


## Inicializa o schema com o [param type_message] usado quando a validação de tipo falha.
func _init(type_message: String) -> void:
	_type_message = type_message


## Valida o [param value] e retorna um [ZodotResult] com o resultado.
## O [param path] identifica o caminho do campo sendo validado e é incluído nos erros.
## Valores [code]null[/code] são tratados conforme [method optional], [method nullable]
## e [method default]. Em seguida, o tipo é verificado via [method _validate_type]
## e os checks registrados com [method refine] são executados em ordem.
func validate(value: Variant, path: Array[String] = []) -> ZodotResult:
	# Lidar com null
	if value == null:
		if _has_default:
			return ZodotResult.ok(_default_value)
		if _is_optional or _is_nullable:
			return ZodotResult.ok(null)
		return ZodotResult.fail([ZodotError.new(path, _type_message)])

	# Validar tipo base
	if not _validate_type(value):
		return ZodotResult.fail([ZodotError.new(path, _type_message)])

	# Executar checks customizados
	var errors: Array[ZodotError] = []
	for check in _checks:
		var result = check.call(value)
		if result is String and not result.is_empty():
			errors.append(ZodotError.new(path, result))
		elif result is Dictionary:
			var msg = result.get("message", "Erro de validação")
			errors.append(ZodotError.new(path, msg, result.get("context")))

	if not errors.is_empty():
		return ZodotResult.fail(errors)

	return ZodotResult.ok(value)


## Marca o schema como opcional, fazendo com que [code]null[/code] seja aceito como valor válido.
## Retorna o próprio schema para encadeamento.
func optional() -> ZodotSchema:
	_is_optional = true
	return self


## Marca o schema como nullable, fazendo com que [code]null[/code] seja aceito sem ser substituído por default.
## Retorna o próprio schema para encadeamento.
func nullable() -> ZodotSchema:
	_is_nullable = true
	return self


## Define o [param value] retornado quando a entrada for [code]null[/code].
## Retorna o próprio schema para encadeamento.
func default(value: Variant) -> ZodotSchema:
	_default_value = value
	_has_default = true
	return self


## Adiciona um check customizado ao schema. O [param validator] recebe o valor e deve retornar
## uma [String] com a mensagem de erro, um [Dictionary] com [code]"message"[/code] e
## [code]"context"[/code] opcionais, ou qualquer outro valor para indicar sucesso.
## Retorna o próprio schema para encadeamento.
func refine(validator: Callable) -> ZodotSchema:
	_checks.append(validator)
	return self


## Verifica se o [param value] corresponde ao tipo esperado pelo schema.
## Deve ser implementado pelas subclasses.
func _validate_type(value: Variant) -> bool:
	return false
