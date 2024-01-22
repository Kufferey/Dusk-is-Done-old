extends Node3D
class_name InteractableObject

## A Base class for interactable game objects.

@export_category("Object Settings")
## if true, that object can be iteracted with. (Pick up)
@export var canInteract:bool
## if true, Then your holding it.
## @experimental
@export var isHolding:bool
