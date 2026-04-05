extends RefCounted
class_name GridBoundedQueue

## Fila circular de capacidade fixa (ring buffer).
## Enqueue retorna false se cheia; dequeue retorna null se vazia.

var _capacity: int
var _buffer: Array
var _head: int = 0
var _count: int = 0


func _init(capacity: int) -> void:
	assert(capacity > 0, "BoundedQueue: capacidade deve ser > 0.")
	_capacity = capacity
	_buffer = []
	_buffer.resize(capacity)


## Insere um valor no final da fila.
## Retorna true se bem-sucedido, false se a fila estiver cheia.
func enqueue(value: Variant) -> bool:
	if _count == _capacity:
		return false
	var tail: int = (_head + _count) % _capacity
	_buffer[tail] = value
	_count += 1
	return true


## Remove e retorna o valor da frente da fila.
## Retorna null se a fila estiver vazia.
func dequeue() -> Variant:
	if _count == 0:
		return null
	var value: Variant = _buffer[_head]
	_buffer[_head] = null
	_head = (_head + 1) % _capacity
	_count -= 1
	return value


## Retorna o valor da frente sem removê-lo.
## Retorna null se a fila estiver vazia.
func peek() -> Variant:
	if _count == 0:
		return null
	return _buffer[_head]


## Retorna o elemento no índice lógico [idx] (0 = frente).
## Retorna null se fora dos limites.
func at(idx: int) -> Variant:
	if idx < 0 or idx >= _count:
		return null
	return _buffer[(_head + idx) % _capacity]


## Retorna a quantidade de elementos na fila.
func size() -> int:
	return _count


## Retorna true se a fila está vazia.
func is_empty() -> bool:
	return _count == 0


## Retorna true se a fila está cheia.
func is_full() -> bool:
	return _count == _capacity


## Limpa todos os elementos da fila.
func clear() -> void:
	for i: int in _count:
		_buffer[(_head + i) % _capacity] = null
	_head = 0
	_count = 0


## Retorna os elementos da fila como Array (cópia, sem modificar a fila).
func to_array() -> Array:
	var result: Array = []
	result.resize(_count)
	for i: int in _count:
		result[i] = _buffer[(_head + i) % _capacity]
	return result
