extends InteractableObject

## A class of a cherry.

@export_category("Cherry Options")
## The type of cherry. 'normal', 'spoiled', 'donStory'
@export var Type:String
## Check if good or not.
@export var isGood:bool

func _ready() -> void:
	var modelNode:Node3D = $Model
	match Type:
		'normal':
			modelNode.remove_child($Model/cherrySpoiled)
			modelNode.remove_child($Model/cherryWithDon2005)
			
			var random:int = randi_range(0,1)
			if random == 0:
				modelNode.remove_child($Model/cherry2)
			elif random != 0:
				modelNode.remove_child($Model/cherry1)
				
			isGood = true
			
		'spoiled':
			modelNode.remove_child($Model/cherry1)
			modelNode.remove_child($Model/cherry2)
			modelNode.remove_child($Model/cherryWithDon2005)
			
			isGood = false
		'donStory':
			pass
		_:
			Type = 'normal'
