extends Node3D

@onready var camera:Node3D = $cameraPos

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(-deg_to_rad(event.relative.x / 2))
		camera.rotate_x(-deg_to_rad(event.relative.y  / 2))
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-85), deg_to_rad(85))
