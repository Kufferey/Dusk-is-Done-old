extends Node2D

# PRELOADS
var mouse
var Dropped_cherry = preload("res://assets/scenes/prefab/cherry_dropped.tscn")
var Pause_menu = preload("res://scenes/pause_menu.tscn")
# INSTANT
var holding_cherry:Node2D
# MONSTER
var monster_location:Array = [
	"None",          # 0
	"hill_upper",    # 1
	"hill_lower",    # 2
	"behind_barn",   # 3
	"behind_fence",  # 4
	"past_fence",    # 5
	"past_fence_x1", # 6
	"past_fence_x2", # 7
	"past_fence_x3", # 8
	"past_fence_x4", # 9
	"past_fence_x5"  # 10
]

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
		Data.Player["Score"] += 7
		Data.Player["Cherrys"] += 1
		Data.Player["cherrysMulti"] += .50
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
				(randi_range(1,5)))

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
			Game_Mouse.get_node("Mouse/Mouse_textures/Normal").hide()
			Game_Mouse.get_node("Mouse/Mouse_textures/Grab").show()
			Game_Mouse.get_node("Mouse/Mouse_textures/Open").hide()
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
			
		match monster_location:
			0:
				pass
			1:
				pass
			2:
				pass
			3:
				pass
			4:
				pass
			5:
				pass
			6:
				pass
			7:
				pass
			8:
				pass
			9:
				pass
				
func _input(event: InputEvent) -> void:
	if (Data.isPaused == false):
		if (Input.is_action_just_pressed("get_cherry")):
			if (Data.isHoldingCherry == true):
				Data.isHoldingCherry = false
				Data.isClicked = true
				_drop_cherry()

func _on_audio_stream_player_finished() -> void:
	$AudioStreamPlayer.play(0)
