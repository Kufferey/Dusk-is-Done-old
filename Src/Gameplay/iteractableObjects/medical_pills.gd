class_name MedicalPills extends InteractableObject

signal consumeMedicalPills

@onready var pill_animation: AnimationPlayer = $PillAnimation

func _on_pill_animation_animation_finished(anim_name: StringName) -> void:
	if anim_name == "consume":
		self.queue_free()

func _on_consume_medical_pills() -> void:
	pill_animation.play("consume")
