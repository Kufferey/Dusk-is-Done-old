extends Node

signal justDied

enum {
	None,          # 0
	hill_upper,    # 1
	hill_lower,    # 2
	behind_barn,   # 3
	behind_fence,  # 4
	past_fence,    # 5
	past_fence_x1, # 6
	past_fence_x2, # 7
	past_fence_x3, # 8
	past_fence_x4, # 9
	past_fence_x5  # 10
}

var current_monster_location = None

func check_monster_location():
	match current_monster_location:
		None:
			pass
		hill_upper:
			pass
		hill_lower:
			pass
		behind_barn:
			pass
		behind_fence:
			pass
		past_fence:
			pass
		past_fence_x1:
			pass
		past_fence_x2:
			pass
		past_fence_x3:
			pass
		past_fence_x4:
			pass
		past_fence_x5:
			pass

func _on_just_died() -> void:
	pass
