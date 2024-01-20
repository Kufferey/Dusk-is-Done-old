extends Node3D
class_name InteractableObject

@export_category("Object Settings")
@export var canInteract:bool
@export var isHolding:bool

@onready var _modelNode:Node3D = $Model
