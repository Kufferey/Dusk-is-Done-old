extends Node2D

var items = [
	'cherry',          # 0
	'medicalpills',    # 1
	'medicalscanner',  # 2
	'table',           # 3
	
	# Summer
	'waterbottle'      # 4
]

var is_left_arrow_hovered:bool
var is_right_arrow_hovered:bool

var current_selection:String = "cherry"

# Buttons
func _on_area_2d_mouse_entered() -> void:
	is_left_arrow_hovered = true
	$Arrows/ArrowLeft/Sprite2D.frame = 1

func _on_area_2d_2_mouse_entered() -> void:
	is_right_arrow_hovered = true
	$Arrows/ArrowRight/Sprite2D.frame = 1

func _on_area_2d_mouse_exited() -> void:
	is_left_arrow_hovered = false
	$Arrows/ArrowLeft/Sprite2D.frame = 0

func _on_area_2d_2_mouse_exited() -> void:
	is_right_arrow_hovered = false
	$Arrows/ArrowRight/Sprite2D.frame = 0
