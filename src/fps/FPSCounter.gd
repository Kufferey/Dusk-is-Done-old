extends CanvasLayer

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$Label.text = "FPS: " + str(Engine.get_frames_per_second()) + "/" + str(Engine.max_fps) + "\nRUNTIME: " + str(Engine.get_process_frames())
