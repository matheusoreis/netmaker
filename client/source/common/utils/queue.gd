extends Node
class_name Queue


## Capacidade máxima da fila.
var _capacity: int
## Índice do primeiro elemento da fila.
var _head: int = 0
## Quantidade de elementos na fila.
var _count: int = 0

## Buffer que armazena os elementos.
var _buffer: Array


## Cria uma fila com a capacidade informada.
func _init(capacity: int) -> void:
	_capacity = capacity
	_buffer = []
	_buffer.resize(capacity)

## Retorna a quantidade de elementos da fila.
func size() -> int:
	return _count


## Indica se a fila está vazia.
func is_empty() -> bool:
	return _count == 0


## Indica se a fila está cheia.
func is_full() -> bool:
	return _count == _capacity


## Insere um elemento no final da fila se houver espaço.
func enqueue(value: Variant) -> bool:
	if _count == _capacity:
		return false
	var tail: int = (_head + _count) % _capacity
	_buffer[tail] = value
	_count += 1
	return true


## Remove e retorna o primeiro elemento da fila.
func dequeue() -> Variant:
	if _count == 0:
		return null
	var value: Variant = _buffer[_head]
	_buffer[_head] = null
	_head = (_head + 1) % _capacity
	_count -= 1
	return value


## Retorna o primeiro elemento sem remover da fila.
func peek() -> Variant:
	if _count == 0:
		return null
	return _buffer[_head]


## Retorna o elemento no índice informado sem remover.
func at(idx: int) -> Variant:
	if idx < 0 or idx >= _count:
		return null
	return _buffer[(_head + idx) % _capacity]


## Remove todos os elementos da fila.
func clear() -> void:
	for i: int in _count:
		_buffer[(_head + i) % _capacity] = null
	_head = 0
	_count = 0


## Retorna um array com todos os elementos da fila.
func to_array() -> Array:
	var result: Array = []
	result.resize(_count)
	for i: int in _count:
		result[i] = _buffer[(_head + i) % _capacity]
	return result
