class_name GameState extends Node3D

signal newDay(dayName:String, dayDescription:String, daySaveData:Dictionary, scoreForComplete:float)
signal hasDied(reason:String, onDay:int)

# Day Vars
var currentDay:int
var currentDaysPast:int
const CURRENTDAYSFORMNEW:int = 5

# Player Vars
const PLAYERMAXHEALTH:float = 1.0
const PLAYERMINHEALTH:float = 0.0
var playerHealth:float

var playerScore:int

var currentTableItems:Array

var isHoldingItem:bool

var currentHeldItemType:String
var currentHeldItem:InteractableObject
var currentHoveredItem:InteractableObject

var isTrayPlaced:bool

#var isInCherryPickingState:bool
#var isInCherryCombineState:bool

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
	'medicalscanner',  # 2
	'table'            # 3
]

var interactableItemListNames:Dictionary = {
	'cherry': interactableItemList[0],
	'medicalpills': interactableItemList[1],
	'medicalscanner': interactableItemList[2],
	'table': interactableItemList[3]
}

# - Cherry

var cherryTypes:Array[String] = ['normal', 'spoiled'] ## The cherry types that will get added to bush. 'normal', 'spoiled by default.'
var cherryTypesStory:Array[String] ## Any Story related item to add to cherry bush. 'donStory', 'killed2004'

var cherrySection:int ## The section your on.
var lastCherrySection:int ## The last section your on.
var currentCherrySectionsLeft:int ## Until A new day.

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

func _ready() -> void:
	# start
	interationObjectsContainer = $InteractableItems
	
	currentDay = 1 
	currentDaysPast = 0
	
	currentCherrySectionsLeft = (currentCherrySectionsLeft + CURRENTDAYSFORMNEW)
	
	playerHealth = 1
	playerRaycast = $Player/cameraPos/RayCast3D
	playerCamera = $Player/cameraPos
	playerItemHolderHand = $Player/cameraPos/ItemHolder
	
	canInteract = true
	isTrayPlaced = false
	
	interactionTextNode = $UI/interactionText
	itemControllsTextNode = $UI/itemControlls
	DebuggingText = $UI/DebugText
	
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)

func _input(event: InputEvent) -> void:
	if (
		event.is_action_pressed("interact")
		&& canInteract == true
	):
		set_hovered_to_held_item()
		
	if Input.is_action_just_pressed("use"):
		use_item()

func _physics_process(delta: float) -> void:
	# Player Stuff
	make_current_item_sway(delta)

func _process(delta: float) -> void:
	# debug
	
	DebuggingText.text = _debug_Update()
	
	# Player Stuff
	interactionTextNode.text = _update_interaction_text()
	itemControllsTextNode.text = _update_current_controls_text()
	
	#currentTableItems = get_current_table_items()
	currentHoveredItem = get_current_hovered_item()
	
	if playerHealth > PLAYERMAXHEALTH:
		playerHealth = 1
	elif playerHealth < PLAYERMINHEALTH:
		emit_signal("hasDied", "Health got too low.", currentDay)
	
	# dayName:String, dayDescription:String, daySaveData:Dictionary, scoreForComplete:float
	if currentCherrySectionsLeft == 0:
		var playerSaveData:Dictionary = {
			"days": currentDay,
			"score": playerScore,
			"sections": cherrySection,
			"health": playerHealth,
		}
		emit_signal(
			"newDay",
			("Day ") + str(currentDay),
			("You have survived " + str(currentDaysPast) + " Days."),
			playerSaveData
			)
	
	# Cherry Handler
	if is_section_clear():
		new_cherry_section()
		
		if isTrayPlaced == false:
			set_current_cherries(false)
		else :
			set_current_cherries(true)


func create_cherry_on_bush(typeOfCherry:String, positionObject:Vector3, rotationObject:Vector3, amount:int) -> void:
	
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

func remove_all_cherries() -> void:
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

func create_object_from_prefab(prefab:PackedScene, objectPosition:Vector3, objectRotation:Vector3) -> void:
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

func add_table_items() -> void:
	pass

func add_cherry_type(newType:String) -> void:
	cherryTypes.append(newType)

func add_table_item(newItem:String) -> void:
	currentTableItems.append(newItem)

func get_cherry_count() -> int:
	var currentCherries:int = interationObjectsContainer.get_child_count(true)
	return currentCherries

func get_current_table_items() -> void: #make  -> Array: 
	pass

func get_current_hovered_item() -> InteractableObject:
	if playerRaycast.is_colliding():
		var theObject:Node3D = playerRaycast.get_collider()
		var theObjectsParent:InteractableObject = theObject.get_parent()
		return theObjectsParent
	return

func set_current_cherries(lock:bool) -> void:
	for cherry in interationObjectsContainer.get_node("Cherries").get_children(false):
		cherry.canInteract = lock

func _update_current_controls_text() -> String:
	if isHoldingItem:
		
		if currentHeldItemType == interactableItemList[0]: return "Press [E] while looking at table to Drop."
		
		elif (
			currentHeldItemType == interactableItemListNames["medicalpills"]
			|| currentHeldItemType == interactableItemListNames["medicalscanner"]
		):
			return "Press [E] while looking at table to Drop.\nPress [LMB] to Use."
			
	return ""

func _update_interaction_text() -> String:
	if isHoldingItem: return ""
	
	elif !isHoldingItem:
		if playerRaycast.is_colliding():
			var theObject:Node3D = playerRaycast.get_collider()
			var theObjectParent:InteractableObject = theObject.get_parent()
			
			#if theObjectParent.is_in_group(interactableItemList[0]): return "Press [E] to Pick."   #Cherry
			#elif theObjectParent.is_in_group(interactableItemList[1]): return "Press [E] to Grab." #medicalpills
			#elif theObjectParent.is_in_group(interactableItemList[2]): return "Press [E] to Grab." #mecicalscanner
			#elif theObjectParent.is_in_group(interactableItemList[3]): return "Press [E] to Use."  #table
			
			if theObjectParent.is_in_group(interactableItemListNames['cherry']): return "Press [E] to Pick."   #Cherry
			elif theObjectParent.is_in_group(interactableItemListNames['medicalpills']): return "Press [E] to Grab." #medicalpills
			elif theObjectParent.is_in_group(interactableItemListNames['medicalscanner']): return "Press [E] to Grab." #mecicalscanner
			elif theObjectParent.is_in_group(interactableItemListNames['table']): return "Press [E] to Use."  #table
			
			else : return ""
		else : return ""
	return ""

func use_item() -> void:
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
				
				await (get_tree().create_timer(1.8).timeout)
				
				playerHealth += 0.32
				reset_all_hold_items()
			
			'medicalscanner':
				pass

func new_held_item(isHolding:bool, newHeldItem:InteractableObject, canInteract:bool, newHeldType:String) -> void:
	isHoldingItem = isHolding
	currentHeldItem = newHeldItem
	canInteract = canInteract
	currentHeldItemType = newHeldType

func reset_all_hold_items() -> void:
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
					object.is_in_group(interactableItemListNames["cherry"]) 
					&& object.canInteract == true
				):
					new_held_item(
						true,
						object,
						false,
						interactableItemListNames["cherry"]
					)
				
				elif (
					object.is_in_group(interactableItemListNames["medicalpills"]) 
					&& object.canInteract == true
				):
					new_held_item(
						true,
						object,
						false,
						interactableItemListNames["medicalpills"]
					)
					
				print("\nCurrent held item: ", currentHeldItem, "\nThe type of this object: ", currentHeldItemType)
	else :
		print("Could not pick item up: Already have one in hand.")

func is_section_clear() -> bool:
	var cherryCount:int = interationObjectsContainer.get_node("Cherries").get_child_count(true)
	if (cherryCount <= 0 || cherryCount == null):return true
	else:return false

func _on_new_day(dayName: String, dayDescription: String, daySaveData: Dictionary, scoreForComplete: float) -> void:
	currentDaysPast = currentDay
	currentCherrySectionsLeft = (currentCherrySectionsLeft + 5)
	currentDay += 1
	
	playerScore += scoreForComplete

func _on_has_died(reason: String, onDay: int) -> void:
	pass # Replace with function body.

func new_cherry_section() -> void:
	lastCherrySection = cherrySection
	currentCherrySectionsLeft = currentCherrySectionsLeft - 1
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

func make_current_item_sway(delta) -> void:
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
