class_name GameState extends Node3D

# Item Var
var interationObjectsContainer:Node3D ## The node that all World interatable objects go to.

var cherryTypes:Array[String] = ['normal', 'spoiled'] ## The cherry types that will get added to bush. 'normal', 'spoiled by default.'
var cherryTypesStory:Array[String] ## Any Story related item to add to cherry bush. 'donStory', 'killed2004'

var cherrySection:int ## The section your on.

# Player Vars
var playerHealth:float ## Player Health. 0 to 1.

var isHoldingItem:bool ## Checks if holding item.

var currentHeldItemType:String ## cherry, medicalpills, medicalscanner
var currentHeldItem:InteractableObject ## Current item in hand
var currentHoveredItem:InteractableObject ## Current Object your looking at.

var isInCherryPickingState:bool
var isInCherryCombineState:bool

var playerCamera:Node3D
var playerRaycast:RayCast3D

var playerItemHolderHand:Node3D

# UI Vars
var interationText:String
var interactionTextNode:Label
var itemControllsTextNode:Label

var DebuggingText:Label

# Gameplay Vars

func _create_cherry_on_bush(typeOfCherry:String, positionObject:Vector3, rotationObject:Vector3, amount:int) -> void:
	
	if amount >= 5:
		amount = 5
	
	for i in amount:
		var cherryOnBushInstance:CherryOnBush = load("res://scenes/prefab/objects/cherryOnBush.tscn").instantiate()
		cherryOnBushInstance.Type = typeOfCherry
		cherryOnBushInstance.position = positionObject
		cherryOnBushInstance.rotation = rotationObject
		
		interationObjectsContainer.add_child(cherryOnBushInstance)
		
	print(amount, " ", typeOfCherry, " Cherry(s) Created. ", " AT POSITION: ", positionObject, " ROTATION OF: ", rotationObject)

func _remove_all_cherries() -> void:
	var totalCount:int = get_cherry_count()
	var totalObjects:Array[Node] = interationObjectsContainer.get_children(true)
	
	if (
		totalCount <= 0 
	|| totalObjects == [] 
	|| totalObjects.is_empty()
	):
		print("Could not remove objects. None to remove.")
		return
	elif (
		totalCount != 0
		|| totalObjects != null
		|| !totalObjects.is_empty()
	):
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
	var currentCherries:int = interationObjectsContainer.get_child_count(true)
	return currentCherries

func get_current_hovered_item() -> InteractableObject:
	if playerRaycast.is_colliding():
		var theObject:Node3D = playerRaycast.get_collider()
		var theObjectsParent:InteractableObject = theObject.get_parent()
		return theObjectsParent
	return

func _update_current_controls_text() -> String:
	if isHoldingItem:

		if currentHeldItemType == 'cherry':
			return "Press [Q] to Drop."
		elif (
			currentHeldItemType == 'medicalpills' 
			|| currentHeldItemType == 'medicalscanner'
		):
			return "Press [Q] to Drop.\nPress [LMB] to Use."
			
	elif !isHoldingItem:
		return ""
	return ""

func _update_interaction_text() -> String:
	if isHoldingItem:
		return ""
	elif !isHoldingItem:
		if playerRaycast.is_colliding():
			var theObject:Node3D = playerRaycast.get_collider()
			var theObjectParent:InteractableObject = theObject.get_parent()
			
			if theObjectParent.is_in_group("cherry"):
				return "Press [E] to Pick."
			elif theObjectParent.is_in_group("table"):
				return  "Press [E] to Use."
			elif theObjectParent.is_in_group("medicalpills"):
				return "Press [E] to Grab."
			elif theObjectParent.is_in_group("medicalscanner"):
				return "Press [E] to Grab."
			
			else :
				return ""
		else :
			return ""
	return ""

func _use_item() -> void:
	if (
		isHoldingItem == true
		&& currentHeldItem != null
		&& currentHeldItemType != ""
	):
		match currentHeldItemType:
			'cherry':
				pass
			'medicalpills':
				currentHeldItem.emit_signal("consumeMedicalPills")
				await (get_tree().create_timer(1.7).timeout)
				playerHealth += 0.2
				_reset_all_hold_items()
			'medicalscanner':
				pass

func _reset_all_hold_items() -> void:
	isHoldingItem = false
	currentHeldItem = null
	currentHeldItemType = ""

func set_hovered_to_held_item() -> void:
	if !isHoldingItem:
		var object:Node3D = get_current_hovered_item()
		if playerRaycast.is_colliding():
			
			if object:
				
				if (
					object.is_in_group("cherry") 
					&& object.canInteract == true
				):
					currentHeldItem = object
					isHoldingItem = true
					currentHeldItemType = 'cherry'
				
				elif (
					object.is_in_group("medicalpills") 
					&& object.canInteract == true
				):
					currentHeldItem = object
					isHoldingItem = true
					currentHeldItemType = 'medicalpills'
					
				print("\nCurrent held item: ", currentHeldItem, "\nThe type of this object: ", currentHeldItemType)
	else :
		print("Could not pick item up: Already have one in hand.")

func is_section_clear() -> bool:
	var cherryCount:int = interationObjectsContainer.get_child_count(true)
	if (cherryCount <= 0):
		return true
	else :
		return false

func _new_cherry_section() -> void:
	cherrySection += 1
	print("New Cherry Section: ", cherrySection)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# start
	interationObjectsContainer = $InteractableItems
	
	playerHealth = 1
	playerRaycast = $Player/cameraPos/RayCast3D
	playerCamera = $Player/cameraPos
	playerItemHolderHand = $Player/cameraPos/ItemHolder
	
	interactionTextNode = $UI/interactionText
	itemControllsTextNode = $UI/itemControlls
	DebuggingText = $UI/DebugText
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	
	await get_tree().create_timer(1.5).timeout
	_create_cherry_on_bush(cherryTypes[0], Vector3(0.5,0,0), Vector3(0,0,0), 1)

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("interact"):
		set_hovered_to_held_item()
		
	if Input.is_action_just_pressed("use"):
		_use_item()

func _physics_process(delta: float) -> void:
	# Player Stuff
	if (
		isHoldingItem
		&& currentHeldItem != null
	):
		if (
			isHoldingItem == true
			&& currentHeldItem != null
		):
			currentHeldItem.rotation.y = playerItemHolderHand.global_rotation.y
			currentHeldItem.rotation.x = playerItemHolderHand.global_rotation.x
			currentHeldItem.position = lerp(Vector3(
				currentHeldItem.position.x, currentHeldItem.position.y, currentHeldItem.position.z),
				Vector3(playerItemHolderHand.global_position.x, playerItemHolderHand.global_position.y, playerItemHolderHand.global_position.z),
				5 * delta)

func _debug_Update() -> String:
	return (
		(
			"ITEM HAND/HOVER STATS:" +
			"\n" +
			"\n" +
			"Current Held Item: " + str(currentHeldItem) +
			"\n" +
			"Current Hovered Item: " + str(currentHoveredItem) +
			"\n" +
			"Current Held Item Type: " + str(currentHeldItemType) +
			"\n" +
			"\n" +
			"PLAYER STATS:" +
			"\n" +
			"\n" +
			"PlayerHealth: " + str(playerHealth)
		)
	)

func _process(delta: float) -> void:
	# debug
	
	DebuggingText.text = _debug_Update()
	
	# Player Stuff
	interactionTextNode.text = _update_interaction_text()
	itemControllsTextNode.text = _update_current_controls_text()
	
	currentHoveredItem = get_current_hovered_item()
	
	if playerHealth > 1:
		playerHealth = 1
	
	# Cherry Handler
	if is_section_clear():
		pass
