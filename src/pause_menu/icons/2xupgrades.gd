extends Node2D

signal move_icon_2xupgrades(_to:Vector2, _time:float)


func _on_move_icon_2_xupgrades(_to, _time) -> void:
	var _new_position = lerp(position, _to, _time)
	position = _new_position
