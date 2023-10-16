extends Node2D

var Options_Menu = preload("res://scenes/mainmenu/options_menu.tscn")

var Play_pressed:bool = false

func _ready() -> void:
	Data._load_settings()
	
	if (Data.Settings["fullScreen"] == true):
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	if (Data.Settings["fullScreen"] == false):
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	
	$Buttons/Continue.hide()
	$Buttons/NewGame.hide()

func _on_play_pressed() -> void:
	Play_pressed = !Play_pressed

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
	if (Play_pressed):
		$Buttons/Continue.show()
		$Buttons/NewGame.show()
	else :
		$Buttons/Continue.hide()
		$Buttons/NewGame.hide()
		
	if (Data.isInOptionsMenu == true):
		$Buttons.hide()
	else :
		$Buttons.show()
