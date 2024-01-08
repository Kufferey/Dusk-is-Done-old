extends Node2D

var Options_Menu = preload("res://scenes/mainmenu/options_menu.tscn")
var Achievements_Menu = preload("res://scenes/mainmenu/achievements_menu.tscn")

var progress = 0
var new

var Play_pressed:bool = false

func _update_player_level():
	$Level/cl.text = str("CURRENT LEVEL: ",Data.Player["Level"])
	
	var progress = 0
	
	$Level/progress.value = progress
	
	if (progress != Data.Player["Level"]):
		progress = progress + 1

func _ready() -> void:
	Data._load_settings()
	Data._load_player()
	
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	new = Data.Player["Level"]
	
	$Buttons/Continue.hide()
	$Buttons/NewGame.hide()

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")
#	Play_pressed = !Play_pressed

func _on_exit_pressed() -> void:
	get_tree().quit(0)

func _on_options_pressed() -> void:
	Data.isInOptionsMenu = true
	Play_pressed = false
	var Options_menu_instance = Options_Menu.instantiate()
	add_child(Options_menu_instance)

func _on_audio_stream_player_finished() -> void:
	$AudioStreamPlayer.play(0)

func _process(delta: float) -> void:
	$Level/cl.text = str("CURRENT LEVEL: ",Data.Player["Level"])
	$Level/percent.text = str($Level/progress.value,"%")
	progress += 0.5
	$Level/progress.value = progress
	if (progress > new):
		$Level/progress.value = new
		
	if (Play_pressed):
		$Buttons/Continue.show()
		$Buttons/NewGame.show()
	else :
		$Buttons/Continue.hide()
		$Buttons/NewGame.hide()
		
	if (Data.isInOptionsMenu == true || Data.isInAchievementsMenu == true):
		$Buttons.hide()
	else :
		$Buttons.show()

func _on_achi_pressed() -> void:
	Data.isInAchievementsMenu = true
	var Achi_instance = Achievements_Menu.instantiate()
	add_child(Achi_instance)
