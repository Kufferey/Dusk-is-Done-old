extends Node2D

signal _change_mouse_sig(_new:int)

var mouse_mode = 0

var mouse1
var mouse2
var mouse3

var isMouseLocked = _lockmouse(false)

func _lockmouse(lock:bool):
	if lock == true:
		self.hide()
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		return true
	else :
		self.show()
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		return false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if isMouseLocked == true:
		mouse1 = $Mouse_textures/Normal
		mouse2 = $Mouse_textures/Open
		mouse3 = $Mouse_textures/Grab
		
		if (Data.Settings["Display"]["customMouse"] == true):
			Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if isMouseLocked == true:
		if (Data.Settings["Display"]["customMouse"] == true):
			$"..".show()
			Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
			_change_mouse()
			self.position = get_global_mouse_position()
		else :
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			$"..".hide()

func _change_mouse_mode_var(_new):
	if isMouseLocked == true:
		if (Data.Settings["Display"]["customMouse"] == true):
			mouse_mode = _new

func _change_mouse():
	if isMouseLocked == true:
		if (Data.Settings["Display"]["customMouse"] == true):
			match mouse_mode:
				0:
					$Mouse_textures/Normal.show()
					$Mouse_textures/Open.hide()
					$Mouse_textures/Grab.hide()
				1:
					$Mouse_textures/Normal.hide()
					$Mouse_textures/Open.show()
					$Mouse_textures/Grab.hide()
				2:
					$Mouse_textures/Normal.hide()
					$Mouse_textures/Open.hide()
					$Mouse_textures/Grab.show()
				_:
					$Mouse_textures/Normal.show()
					$Mouse_textures/Open.hide()
					$Mouse_textures/Grab.hide()

func _on__change_mouse_sig(_new) -> void:
	if isMouseLocked == true:
		if (Data.Settings["Display"]["customMouse"] == true):
			match _new:
				0:
					$Mouse_textures/Normal.show()
					$Mouse_textures/Open.hide()
					$Mouse_textures/Grab.hide()
				1:
					$Mouse_textures/Normal.hide()
					$Mouse_textures/Open.show()
					$Mouse_textures/Grab.hide()
				2:
					$Mouse_textures/Normal.hide()
					$Mouse_textures/Open.hide()
					$Mouse_textures/Grab.show()
				_:
					$Mouse_textures/Normal.show()
					$Mouse_textures/Open.hide()
					$Mouse_textures/Grab.hide()
