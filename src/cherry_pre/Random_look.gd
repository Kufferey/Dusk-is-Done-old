extends Node2D
class_name Cherry_on_bush

signal Choose_cherry_look(_look)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var Random_look = randi_range(0,1)
	_cherry_look(Random_look)
	
func _cherry_look(_look:int=0):
	match _look:
		0:
			$cherry1.show()
			$cherry2.hide()
		1:
			$cherry1.hide()
			$cherry2.show()
		_:
			$cherry1.show()
			$cherry2.hide()

func _on_button_pressed() -> void:
	if (Data.isPaused == false):
		if ($cherry1.visible):
			Data.curCherryModel = 1
		elif ($cherry2.visible):
			Data.curCherryModel = 2
		
		Data.isHoldingCherry = true
		queue_free()
