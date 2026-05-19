extends RefCounted
class_name Model


func from_row(row: Array, cols: PackedStringArray):
	for i in cols.size():
		set(cols[i], row[i])
