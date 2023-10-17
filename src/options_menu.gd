extends Node2D

var enabledFullScreen:bool = false
var enabledCustomMouse:bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if (Data.Settings["fullScreen"] == true):
		$Buttons/FS.set("button_pressed", true)
	elif (Data.Settings["fullScreen"] == false):
		$Buttons/FS.set("button_pressed", false)
	if (Data.Settings["customMouse"] == true):
		$Buttons/ShowCustomMouse.set("button_pressed", true)
	elif (Data.Settings["customMouse"] == false):
		$Buttons/ShowCustomMouse.set("button_pressed", false)

func _on_fs_toggled(button_pressed: bool) -> void:
	if (button_pressed == true):
		enabledFullScreen = true
	elif (button_pressed == false):
		enabledFullScreen = false

func _on_show_custom_mouse_toggled(button_pressed: bool) -> void:
	if (button_pressed == true):
		enabledCustomMouse = true
	elif (button_pressed == false):
		enabledCustomMouse = false

func _on_apply_pressed() -> void:
	if (enabledFullScreen == true):
		Data.Settings["fullScreen"] = true
	elif (enabledFullScreen == false):
		Data.Settings["fullScreen"] = false
	
	if (enabledCustomMouse == true):
		Data.Settings["customMouse"] = true
	elif (enabledCustomMouse == false):
		Data.Settings["customMouse"] = false
	
	Data._save_settings()
	Data._load_settings()
	
	Data.isInOptionsMenu = false
	queue_free()

func _on_cancel_pressed() -> void:
	Data.isInOptionsMenu = false
	queue_free()
