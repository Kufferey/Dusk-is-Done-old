extends CanvasLayer

var UI

func _ready() -> void:
	UI = $UI_text

func _update_ui():
	UI.text = ("SCORE: " + str(Data.score) + "\nx" + str(Data.cur_Times) + " Cherrys")

func _process(delta: float) -> void:
	_update_ui()
