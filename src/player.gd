extends Node3D

@onready var camera: Node3D = $camera

var sens = Data.Settings["Gameplay"]["sens"]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event: InputEvent) -> void:
	if !Data.lockMouse:
		if event is InputEventMouseMotion:
			rotate_y(-deg_to_rad(event.relative.x * sens))
			camera.rotate_x(-deg_to_rad(event.relative.y * sens))
			camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-89), deg_to_rad(89))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("exit"):
		get_tree().change_scene_to_file("res://scenes/mainmenu/mainmenu.tscn")
