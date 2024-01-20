class_name MedicalPills extends InteractableObject

func _on_pill_animation_animation_finished(anim_name: StringName) -> void:
	if anim_name == "consume":
		print("done! eat")
