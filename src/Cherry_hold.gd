extends Node2D

signal look_for_cherry_model

func _on_look_for_cherry_model() -> void:
	if (Data.curCherryModel == 1):
		$Cherry1.show()
		$Cherry2.hide()
	if (Data.curCherryModel == 2):
		$Cherry1.hide()
		$Cherry2.show()
