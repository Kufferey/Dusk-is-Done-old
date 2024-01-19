extends Node3D

signal gameOver

# Cherry
var cherriesContainer:Node3D

var cherryTypes:Array[String] = ['normal', 'spoiled']
var cherryTypesStory:Array[String]

var currentHeldItem:Node3D
var currentHoveredItem:Node3D

var cherrySection:int

# Player Vars
var isHoldingItem:bool
var isHoldingCherry:bool

var isInCherryPickingState:bool
var isInCherryCombineState:bool

var playerCamera:Node3D
var playerRaycast:RayCast3D

var playerItemHolderHand:Node3D

# Gameplay Vars

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

func _create_object_from_prefab(pathToPrefab:String, objectPosition:Vector3, objectRotation:Vector3) -> void:
	var prefabFullPath:String = ("res://scenes/prefab/" + pathToPrefab)
	if prefabFullPath:
		if prefabFullPath == null:
			print("Object could not be created. No pathToPrefab argument.")
			return
		elif prefabFullPath != null:
			var objectInstance:Node3D = load(pathToPrefab).instantiate()
			objectInstance.rotation = objectRotation
			objectInstance.position = objectPosition
			
			add_child(objectInstance)

func add_cherry_type(newType:String) -> void:
	cherryTypes.append(newType)

func get_cherry_count() -> int:
	var currentCherries:int = cherriesContainer.get_child_count(true)
	return currentCherries

func get_current_hovered_item() -> Node3D:
	if playerRaycast.is_colliding():
		var theObject = playerRaycast.get_collider()
		var theObjectsParent:Node3D = theObject.get_parent()
		return theObjectsParent
	return

func set_hovered_to_held_item():
	if !isHoldingItem:
		var object:Node3D = get_current_hovered_item()
		if playerRaycast.is_colliding():
			if get_current_hovered_item():
				if object.is_in_group("cherry"):
					currentHeldItem = object
					isHoldingItem = true
	else :
		print("Could not pick item up: Already have one in hand.")

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
	#currentHeldItem = $cherries/CherryOnBush2
	isHoldingCherry = true
	await get_tree().create_timer(8.5).timeout
	isHoldingCherry = true

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("interact"):
		set_hovered_to_held_item()

func _physics_process(delta: float) -> void:
	# Player Stuff
	if isHoldingItem && currentHeldItem != null:
		if isHoldingCherry == true && currentHeldItem != null:
			currentHeldItem.rotation.y = playerItemHolderHand.global_rotation.y
			currentHeldItem.rotation.x = playerItemHolderHand.global_rotation.x
			currentHeldItem.position = lerp(Vector3(currentHeldItem.position.x, currentHeldItem.position.y, currentHeldItem.position.z), Vector3(playerItemHolderHand.global_position.x, playerItemHolderHand.global_position.y, playerItemHolderHand.global_position.z), 5 * delta)

func _process(delta: float) -> void:
	# Player Stuff
	currentHoveredItem = get_current_hovered_item()
	# Cherry Handler
	if is_section_clear():
		pass

func _on_game_over() -> void:
	pass # Replace with function body.
