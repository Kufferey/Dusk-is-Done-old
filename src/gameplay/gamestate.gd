extends Node3D

signal gameOver

# Cherry
var cherriesContainer:Node3D

var cherryTypes:Array[String] = ['normal', 'spoiled']
var cherryTypesStory:Array[String]

var currentHeldCherry:Node3D
var currentHoveredCherry:Node3D

var cherrySection:int

# Player Vars
var isHoldingItem:bool
var isHoldingCherry:bool

var isInCherryPickingState:bool
var isInCherryCombineState:bool

var playerCamera:Node3D
var playerRaycast:RayCast3D
var playerItemHolderHand:Node3D

func _create_cherry_on_bush(typeOfCherry:String, positionObject:Vector3, rotationObject:Vector3, amount:int) -> void:
	if amount >= 5:
		amount = 5
	
	for i in amount:
		var cherryOnBushInstance:Node3D = load("res://scenes/prefab/objects/cherry_on_bush.tscn").instantiate()
		cherryOnBushInstance.Type = typeOfCherry
		cherryOnBushInstance.position = positionObject
		cherryOnBushInstance.rotation = rotationObject
		
		cherriesContainer.add_child(cherryOnBushInstance)
		
	print(amount, " ", typeOfCherry, " Cherry(s) Created. ", " AT POSITION: ", positionObject, " ROTATION OF: ", rotationObject)

func _remove_all_cherries() -> void:
	var totalCount:int = get_cherry_count()
	var totalObjects:Array[Node] = cherriesContainer.get_children(true)
	
	if totalCount <= 0 || totalObjects == [] || totalObjects.is_empty():
		print("Could not remove objects. None to remove.")
		return
	elif totalCount != 0 || totalObjects != null || !totalObjects.is_empty():
		for cherries in totalObjects:
			cherries.queue_free()
			print(cherries, " Cherry Deleted.")
	
	print(totalCount, " Objects Deleted.")

func add_cherry_type(newType:String) -> void:
	cherryTypes.append(newType)

func get_cherry_count() -> int:
	var currentCherries:int = cherriesContainer.get_child_count(true)
	return currentCherries

func get_current_hovered_item():
	pass

func is_section_clear() -> bool:
	var cherryCount:int = cherriesContainer.get_child_count(true)
	if cherryCount <= 0:
		return true
	else :
		return false

func _new_cherry_section() -> void:
	cherrySection += 1
	print("New Cherry Section: ", cherrySection)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# start
	cherriesContainer = $cherries
	
	playerRaycast = $Player/cameraPos/RayCast3D
	playerCamera = $Player/cameraPos
	playerItemHolderHand = $Player/cameraPos/ItemHolder
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	_create_cherry_on_bush(cherryTypes[0], Vector3(0,0,0), Vector3(0,0,0), 1)
	await get_tree().create_timer(1.5).timeout
	_new_cherry_section()
	_create_cherry_on_bush(cherryTypes[1], Vector3(0,0,0.3), Vector3(0,0,0), 1)
	await get_tree().create_timer(1.5).timeout
	await get_tree().create_timer(8.5).timeout

func _input(event: InputEvent) -> void:
	pass

func _process(delta: float) -> void:
	# Player Stuff
	if isHoldingCherry == true:
		currentHeldCherry.rotation.y = playerItemHolderHand.global_rotation.y
		currentHeldCherry.rotation.x = playerItemHolderHand.global_rotation.x
		currentHeldCherry.position = lerp(Vector3(currentHeldCherry.position.x, currentHeldCherry.position.y, currentHeldCherry.position.z), Vector3(playerItemHolderHand.global_position.x, playerItemHolderHand.global_position.y, playerItemHolderHand.global_position.z), 5 * delta)

	# Cherry Handler
	if is_section_clear():
		pass

func _on_game_over() -> void:
	pass # Replace with function body.
