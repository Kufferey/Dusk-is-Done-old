extends CanvasLayer

var UI

func _ready() -> void:
	UI = $UI_text

func _update_ui():
	UI.text = ("SCORE: " + str(Data.Player["Score"]) + "\nx" + str(Data.Player["Cherrys"]) + " Cherrys")

func _process(delta: float) -> void:
	_update_ui()
