## Ponto de entrada para criação de schemas de validação do Zodot.
##
## Instancie esta classe e use seus métodos para criar schemas tipados.
## Todos os métodos exigem uma [param message] que será emitida como erro
## caso o valor não corresponda ao tipo esperado.
##
## [codeblock]
## var z = Zodot.new()
## var schema = z.string("Deve ser uma string")
## var result = schema.validate("olá")
## [/codeblock]
extends RefCounted
class_name Zodot


## Cria um schema de validação para [String].
## O [param message] é emitido quando o valor não for uma string.
func string(message: String) -> ZodotString:
	return ZodotString.new(message)


## Cria um schema de validação para [int].
## O [param message] é emitido quando o valor não for um inteiro.
func int(message: String) -> ZodotInt:
	return ZodotInt.new(message)


## Cria um schema de validação para [float].
## O [param message] é emitido quando o valor não for um float.
func float(message: String) -> ZodotFloat:
	return ZodotFloat.new(message)


## Cria um schema de validação para [bool].
## O [param message] é emitido quando o valor não for um booleano.
func bool(message: String) -> ZodotBool:
	return ZodotBool.new(message)


## Cria um schema de validação para [Array], onde cada item é validado pelo [param item_schema].
## O [param message] é emitido quando o valor não for um array.
func array(item_schema: ZodotSchema, message: String) -> ZodotArray:
	return ZodotArray.new(item_schema, message)


## Cria um schema de validação para [Dictionary] com o formato definido por [param shape].
## O [param shape] deve mapear chaves para instâncias de [ZodotSchema].
## O [param message] é emitido quando o valor não for um dicionário.
func dictionary(shape: Dictionary, message: String) -> ZodotDictionary:
	return ZodotDictionary.new(shape, message)


## Cria um schema de validação para [Vector2].
## O [param message] é emitido quando o valor não for um [Vector2].
func vector2(message: String) -> ZodotVector2:
	return ZodotVector2.new(message)


## Cria um schema de validação para [Vector3].
## O [param message] é emitido quando o valor não for um [Vector3].
func vector3(message: String) -> ZodotVector3:
	return ZodotVector3.new(message)


## Cria um schema de validação para [Vector2i].
## O [param message] é emitido quando o valor não for um [Vector2i].
func vector2i(message: String) -> ZodotVector2i:
	return ZodotVector2i.new(message)


## Cria um schema de validação para [Vector3i].
## O [param message] é emitido quando o valor não for um [Vector3i].
func vector3i(message: String) -> ZodotVector3i:
	return ZodotVector3i.new(message)


## Cria um schema de união que aceita qualquer um dos [param schemas] fornecidos.
## O [param message] é emitido quando o valor não corresponder a nenhum dos schemas.
func union(schemas: Array, message: String) -> ZodotUnion:
	return ZodotUnion.new(schemas, message)


## Cria um schema que aceita apenas valores presentes em [param values].
## O [param message] é emitido quando o valor não estiver na lista.
func enum_values(values: Array, message: String) -> ZodotEnum:
	return ZodotEnum.new(values, message)
