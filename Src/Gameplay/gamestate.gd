class_name GameState extends Node3D

signal newDay(dayName:String, scoreForComplete:float)

# Day Vars
var currentDay:int
var currentDaysPast:int

# Player Vars
var playerHealth:float ## Player Health. 0 to 1.
var playerScore:int

var currentTableItems:Array

var isHoldingItem:bool ## Checks if holding item.

var currentHeldItemType:String ## cherry, medicalpills, medicalscanner
var currentHeldItem:InteractableObject ## Current item in hand
var currentHoveredItem:InteractableObject ## Current Object your looking at.

var isInCherryPickingState:bool
var isInCherryCombineState:bool

var canInteract:bool

var playerCamera:Node3D
var playerRaycast:RayCast3D

var playerItemHolderHand:Node3D

# UI Vars
var interationText:String
var interactionTextNode:Label
var itemControllsTextNode:Label

var DebuggingText:Label

# Gameplay Vars

var interactableItemList:Array[String] = [
	'cherry',          # 0
	'medicalpills',    # 1
	'medicalscanner'   # 2
]

# - Cherry

var cherryTypes:Array[String] = ['normal', 'spoiled'] ## The cherry types that will get added to bush. 'normal', 'spoiled by default.'
var cherryTypesStory:Array[String] ## Any Story related item to add to cherry bush. 'donStory', 'killed2004'

var cherrySection:int ## The section your on.
var lastCherrySection:int ## The last section your on.

# Item Preload (Lag Spike fix)

#Old
#@onready
#var cherryOnBush:PackedScene = preload("res://Scenes/Prefabs/objects/cherryOnBush.tscn")
#@onready
#var medicalPills:PackedScene = preload("res://Scenes/Prefabs/objects/equipment/medical_pills.tscn")

@export_category("Game Objects")
@export_group("Items")
@export var cherryOnBush:PackedScene = preload("res://Scenes/Prefabs/objects/cherryOnBush.tscn")
@export var medicalPills:PackedScene = preload("res://Scenes/Prefabs/objects/equipment/medical_pills.tscn")

# - Nodes
var interationObjectsContainer:Node3D ## The node that all World interatable objects go to.

func _create_cherry_on_bush(typeOfCherry:String, positionObject:Vector3, rotationObject:Vector3, amount:int) -> void:
	
	if amount >= 5:
		amount = 5
	
	for i in amount:
		#var cherryOnBushInstance:CherryOnBush = load("res://Scenes/Prefabs/objects/cherryOnBush.tscn").instantiate()
		var cherryOnBushInstance:CherryOnBush = cherryOnBush.instantiate()
		cherryOnBushInstance.Type = typeOfCherry
		cherryOnBushInstance.position = positionObject
		cherryOnBushInstance.rotation = rotationObject
		
		interationObjectsContainer.get_node('Cherries').add_child(cherryOnBushInstance)
		
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

func _create_object_from_prefab(prefab:PackedScene, objectPosition:Vector3, objectRotation:Vector3) -> void:
	var loadedObject:Node3D = prefab.instantiate()
	if loadedObject:
		if loadedObject == null:
			print("Object could not be created. No prefab argument.")
			return
		elif loadedObject != null:
			loadedObject.rotation = objectRotation
			loadedObject.position = objectPosition
			
			print("Added Prefab: " + str(loadedObject))
			interationObjectsContainer.add_child(loadedObject)

func add_cherry_type(newType:String) -> void:
	cherryTypes.append(newType)

func add_table_item(newItem:String) -> void:
	currentTableItems.append(newItem)

func get_cherry_count() -> int:
	var currentCherries:int = interationObjectsContainer.get_child_count(true)
	return currentCherries

func get_current_table_items() -> Array:
	var placeholder:Array = ["medicalpills"]
	return placeholder

func get_current_hovered_item() -> InteractableObject:
	if playerRaycast.is_colliding():
		var theObject:Node3D = playerRaycast.get_collider()
		var theObjectsParent:InteractableObject = theObject.get_parent()
		return theObjectsParent
	return

func _update_current_controls_text() -> String:
	if isHoldingItem:
		
		if currentHeldItemType == interactableItemList[0]:
			return "Press [E] while looking at table to Drop."
		elif (
			currentHeldItemType == interactableItemList[1] 
			|| currentHeldItemType == interactableItemList[2]
		):
			return "Press [E] while looking at table to Drop.\nPress [LMB] to Use."
			
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
			
			if theObjectParent.is_in_group(interactableItemList[0]):
				return "Press [E] to Pick."
			elif theObjectParent.is_in_group("table"):
				return  "Press [E] to Use."
			elif theObjectParent.is_in_group(interactableItemList[1]):
				return "Press [E] to Grab."
			elif theObjectParent.is_in_group(interactableItemList[2]):
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
				
				await (get_tree().create_timer(2).timeout)
				
				playerHealth += 0.32
				_reset_all_hold_items()
			
			'medicalscanner':
				pass

func _new_held_item(isHolding:bool, newHeldItem:InteractableObject, canInteract:bool, newHeldType:String) -> void:
	isHoldingItem = isHolding
	currentHeldItem = newHeldItem
	canInteract = canInteract
	currentHeldItemType = newHeldType

func _reset_all_hold_items() -> void:
	isHoldingItem = false
	currentHeldItem = null
	canInteract = true
	currentHeldItemType = ""

func set_hovered_to_held_item() -> void:
	if !isHoldingItem:
		var object:Node3D = get_current_hovered_item()
		if playerRaycast.is_colliding():
			
			if object:
				
				if (
					object.is_in_group(interactableItemList[0]) 
					&& object.canInteract == true
				):
					_new_held_item(
						true,
						object,
						false,
						interactableItemList[0]
					)
				
				elif (
					object.is_in_group(interactableItemList[1]) 
					&& object.canInteract == true
				):
					_new_held_item(
						true,
						object,
						false,
						interactableItemList[1]
					)
					
				print("\nCurrent held item: ", currentHeldItem, "\nThe type of this object: ", currentHeldItemType)
	else :
		print("Could not pick item up: Already have one in hand.")

func is_section_clear() -> bool:
	var cherryCount:int = interationObjectsContainer.get_node("Cherries").get_child_count(true)
	if (
		cherryCount <= 0
		|| cherryCount == null
	):
		return true
	else :
		return false

func _new_cherry_section() -> void:
	lastCherrySection = cherrySection
	cherrySection += 1
	print("New Cherry Section: ", cherrySection)

func _debug_Update() -> String:
	return (
		(
			"CURRENT FPS: " + str(Engine.get_frames_per_second()) + "/" + str(Engine.max_fps) +
			"\n" +
			"\n" +
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

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# start
	interationObjectsContainer = $InteractableItems
	
	playerHealth = .1
	playerRaycast = $Player/cameraPos/RayCast3D
	playerCamera = $Player/cameraPos
	playerItemHolderHand = $Player/cameraPos/ItemHolder
	
	canInteract = true
	
	interactionTextNode = $UI/interactionText
	itemControllsTextNode = $UI/itemControlls
	DebuggingText = $UI/DebugText
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	
	await get_tree().create_timer(1.5).timeout
	_create_cherry_on_bush(cherryTypes[0], Vector3(0.5,0,0), Vector3(0,0,0), 1)
	await get_tree().create_timer(1.5).timeout
	_create_cherry_on_bush(cherryTypes[0], Vector3(0.8,0.1,0), Vector3(0,0,0), 1)
	await get_tree().create_timer(1.5).timeout
	_create_cherry_on_bush(cherryTypes[0], Vector3(-0.5,0,0), Vector3(0,0,0), 1)
	await get_tree().create_timer(1.5).timeout
	_create_object_from_prefab(medicalPills, Vector3(0, 0.4, 0), Vector3(0,0,0))

func _input(event: InputEvent) -> void:
	if (
		event.is_action_pressed("interact")
		&& canInteract == true
	):
		set_hovered_to_held_item()
		
	if Input.is_action_just_pressed("use"):
		_use_item()

func _physics_process(delta: float) -> void:
	# Player Stuff
	if (
		isHoldingItem == true
		&& currentHeldItem != null
	):
		currentHeldItem.rotation.z = playerItemHolderHand.global_rotation.z
		currentHeldItem.rotation.y = playerItemHolderHand.global_rotation.y
		currentHeldItem.rotation.x = playerItemHolderHand.global_rotation.x
		currentHeldItem.position = lerp(Vector3(
			currentHeldItem.position.x, currentHeldItem.position.y, currentHeldItem.position.z),
			Vector3(playerItemHolderHand.global_position.x, playerItemHolderHand.global_position.y, playerItemHolderHand.global_position.z),
			9.5 * delta)

func _process(delta: float) -> void:
	# debug
	
	DebuggingText.text = _debug_Update()
	
	# Player Stuff
	interactionTextNode.text = _update_interaction_text()
	itemControllsTextNode.text = _update_current_controls_text()
	
	currentTableItems = get_current_table_items()
	currentHoveredItem = get_current_hovered_item()
	
	if playerHealth > 1:
		playerHealth = 1
	
	# Cherry Handler
	if is_section_clear():
		pass
