extends Node2D

# PRELOADS
var mouse
var Dropped_cherry = preload("res://assets/scenes/prefab/cherry_dropped.tscn")
var Pause_menu = preload("res://scenes/pause_menu.tscn")
# INSTANT
var holding_cherry:Node2D

func _ready() -> void:
	mouse = Game_Mouse
	holding_cherry = $Cherry_hold
	Data.isClicked = true
	
	$Cherry_init.emit_signal(
		"_cherry_pick_location_sig",
		2)

func _drop_cherry() -> void:
	if (Data.isPaused == false):
		var dropped_cherry_instance = Dropped_cherry.instantiate()
		dropped_cherry_instance.position = get_global_mouse_position()
		Data.cur_Times += 1
		Data.cur_multi += .99
		Data.score += 7
		add_child(dropped_cherry_instance)

static func _reload_cherry() -> void:
	if (Data.isPaused == false):
		var Cherry_count = $Cherry_init/Cherrys
		var Child = Cherry_count.get_child_count(true)
		
		if (Child < 1):
			
			for i in range(Child):
				var child = Cherry_count.get_child(0)
				Cherry_count.remove_child(child)
				child.queue_free()
				break
				
			$Cherry_init.emit_signal(
				"_cherry_pick_location_sig",
				Data.cur_Times / Data.cur_multi)

func _cherry_timer_main() -> void:
	if (Data.isPaused == false):
		var Cherry_count = $Cherry_init/Cherrys
		var Child = Cherry_count.get_child_count(false)
		
		if (Child < 1):
			await (get_tree().create_timer(0.5, false, false, false).timeout)
			_reload_cherry()

func _process(delta: float) -> void:
	if (Data.isPaused == false):
		_cherry_timer_main()
		holding_cherry.position = get_global_mouse_position()
		if (Data.isHoldingCherry == true):
			holding_cherry.show()
			if (Data.isClicked == true):
				$Cherry_init/AudioStreamPlayer2D.play(0.0)
				Data.isClicked = false
		elif (Data.isHoldingCherry == false):
			holding_cherry.hide()
			
		if (Data.isPaused == false && Input.is_action_just_pressed("exit")):
			var pause_menu_instance = Pause_menu.instantiate()
			Data.isPaused = true
			add_child(pause_menu_instance)
		
		$Cherry_hold.emit_signal(
			"look_for_cherry_model")

func _input(event: InputEvent) -> void:
	if (Data.isPaused == false):
		if (Input.is_action_just_pressed("get_cherry")):
			if (Data.isHoldingCherry == true):
				Data.isHoldingCherry = false
				Data.isClicked = true
				_drop_cherry()

func _on_audio_stream_player_finished() -> void:
	$AudioStreamPlayer.play(0)
