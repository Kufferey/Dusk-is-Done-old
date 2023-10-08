extends Node2D

var Options_Menu = preload("res://scenes/options_menu.tscn")

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_exit_pressed() -> void:
	get_tree().quit(0)

func _on_options_pressed() -> void:
	Data.isInOptionsMenu = true
	
	var Options_menu_instance = Options_Menu.instantiate()
	add_child(Options_menu_instance)

func _on_audio_stream_player_finished() -> void:
	$AudioStreamPlayer.play(0)

func _process(delta: float) -> void:
	if (Data.isInOptionsMenu == true):
		$Buttons.hide()
	else :
		$Buttons.show()
