extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$achieve_rect/Control/Achieve_box.emit_signal("Change_box", "Rookie Collector.", "Get 10 Cherrys in \'Easy\'\nMode.")
	$achieve_rect/Control/Achieve_box2.emit_signal("Change_box", "Beneficial Increase.", "Upgrade any station.")
	$achieve_rect/Control/Achieve_box3.emit_signal("Change_box", "Crafty", "Craft a item.")
	$achieve_rect/Control/Achieve_box4.emit_signal("Change_box", "What a End", "Gas \'Volock Vill\'.")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_back_pressed() -> void:
	Data.isInAchievementsMenu = false
	queue_free()
