extends Node2D

@export var Max_cherrys_allowed:int = 5

signal _cherry_pick_location_sig(_times:int)

#@export var cherry_on_bush: PackedScene
var cherry_on_bush = preload("res://assets/scenes/prefab/Cherry_onB.tscn")
	
func _cherry_pick_location(_times:int) -> void:
#	var Random_position = randi_range(1,5)
#	var Random_position2 = randi_range(1,5)
#	var Random_position3 = randi_range(1,5)
#	var Random_position4 = randi_range(1,5)
	for Times in _times:
		var point1 = $point1.position
		var point2 = $point2.position
		var point3 = $point3.position
		var point4 = $point4.position
		var point5 = $point5.position
		var point6 = $point6.position
		var point7 = $point7.position
		var point8 = $point8.position
		var point9 = $point9.position
		
		var _Random_position = randi_range(1,9)
		var _New_position = 1
		var _Spawn_point = 1
		
		print("Position on '_Random_position' now is: " , _Random_position)
		
		match _Random_position:
			1:
				_New_position = 1
			2:
				_New_position = 2
			3:
				_New_position = 3
			4:
				_New_position = 4
			5:
				_New_position = 5
			6:
				_New_position = 6
			7:
				_New_position = 7
			8:
				_New_position = 8
			9:
				_New_position = 9
		
		match _New_position:
			1:
				_Spawn_point = point1
			2:
				_Spawn_point = point2
			3:
				_Spawn_point = point3
			4:
				_Spawn_point = point4
			5:
				_Spawn_point = point5
			6:
				_Spawn_point = point6
			7:
				_Spawn_point = point7
			8:
				_Spawn_point = point8
			9:
				_Spawn_point = point9
		
		var Cherry_instance = cherry_on_bush.instantiate()
		
		print("CHERRY LOCATION ADDED.")
		Cherry_instance.position = _Spawn_point
		$Cherrys.add_child(Cherry_instance)

func _on__cherry_pick_location_sig(_times) -> void:
	if (_times > Max_cherrys_allowed):
		_times = Max_cherrys_allowed
		_cherry_pick_location(_times)
	else :
		_cherry_pick_location(_times)
