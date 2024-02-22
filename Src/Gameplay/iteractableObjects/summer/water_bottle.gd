class_name WaterBottle extends InteractableObject

signal consume_waterbottle

@onready var consume: AnimationPlayer = $Consume

func _on_consume_waterbottle() -> void:
	consume.play("consume")

func _on_consume_animation_finished(anim_name: StringName) -> void:
	if anim_name == "consume":
		self.queue_free()
