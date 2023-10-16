extends Node2D

@export var SPEED := 150
@export var curSpeedacc := 55
var random_dir = randi_range(0,1)
var SPEED_ANGLE = 0.001

func _ready() -> void:
	var _Random_image = randi_range(1,2)
	
#	match _Random_image:
#		1:
#			$cherry_1.show()
#			$cherry_2.hide()
#		2:
#			$cherry_2.show()
#			$cherry_1.hide()
	match Data.curCherryModel:
		1:
			$cherry_1.show()
			$cherry_2.hide()
		2:
			$cherry_2.show()
			$cherry_1.hide()

func _process(delta: float) -> void:
	if (random_dir != 1):
		rotation = rotation - SPEED_ANGLE
	else :
		rotation = rotation + SPEED_ANGLE
	
	SPEED_ANGLE += 0.003
	SPEED += curSpeedacc
	position.y += SPEED * delta
	
	await (get_tree().create_timer(1, false, false, false).timeout)
	queue_free()
