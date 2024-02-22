@icon("res://Assets/Images/_branding/Icon.png")
class_name GameState extends Node3D

signal newDay(dayName:String, dayDescription:String, daySaveData:Dictionary, scoreForComplete:float)
signal hasDied(reason:String, onDay:int)

# Season Vars
static var currentSeason:String

# Day Vars
static var currentDay:int
static var currentDaysPast:int
const CURRENTSECTIONSLEFT:int = 5

# Difficulty Stuff
static var currentDifficulty:String

# Player Vars
const PLAYERMAXHEALTH:float = 1.0
const PLAYERMINHEALTH:float = 0.0
static var playerHealth:float

static var playerScore:int

static var currentTableItems:Array

static var isHoldingItem:bool

static var currentHeldItemType:String
static var currentHeldItem:InteractableObject
static var currentHoveredItem:InteractableObject

static var isTrayPlaced:bool

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
	'table',           # 3
	'paper1',          # 4
	
	# Summer
	'waterbottle'      # 5
]

var interactableItemListNames:Dictionary = {
	'cherry': interactableItemList[0],
	'medicalpills': interactableItemList[1],
	'medicalscanner': interactableItemList[2],
	'table': interactableItemList[3],
	'paper1': interactableItemList[4],
	
	# Summer
	'waterbottle': interactableItemList[5]
}

# Cherry
var cherryTypes:Array[String] = ['normal', 'spoiled']
var cherryTypesStory:Array[String]

static var cherrySection:int
static var lastCherrySection:int
static var currentCherrySectionsLeft:int

# Items
@export_category("Game Objects")
@export_group("Items")
@export var cherryOnBush:PackedScene = preload("res://Scenes/Prefabs/objects/cherryOnBush.tscn")
@export var medicalPills:PackedScene = preload("res://Scenes/Prefabs/objects/equipment/medical_pills.tscn")
@export_group("Story Items")
@export var interductionPaper:PackedScene = preload("res://Scenes/Prefabs/objects/papers/interduction_paper.tscn")

# Nodes
var interationObjectsContainer:Node3D

func _ready() -> void:
	# start
	interationObjectsContainer = $InteractableItems
	
	currentDay = int(1)
	currentDaysPast = int(0)
	
	currentCherrySectionsLeft = int((currentCherrySectionsLeft + CURRENTSECTIONSLEFT))
	
	playerHealth = float(1)
	playerRaycast = $Player/cameraPos/RayCast3D
	playerCamera = $Player/cameraPos
	playerItemHolderHand = $Player/cameraPos/ItemHolder
	
	canInteract = bool(true)
	isTrayPlaced = bool(false)
	
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
		
	if event.is_action_pressed("use"):
		use_item()

func _physics_process(delta: float) -> void:
	# Player Stuff
	make_current_item_sway(float(delta))

func _process(delta: float) -> void:
	# debug
	
	DebuggingText.text = _debug_Update()
	
	# Player Stuff
	interactionTextNode.text = _update_interaction_text()
	itemControllsTextNode.text = _update_current_controls_text()
	
	#currentTableItems = get_current_table_items()
	currentHoveredItem = get_current_hovered_item()
	
	if float(playerHealth) > float(PLAYERMAXHEALTH):
		playerHealth = 1
	elif float(playerHealth) < float(PLAYERMINHEALTH):
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
	if bool(is_section_clear()):
		new_cherry_section()
		
		if isTrayPlaced == false:
			set_current_cherries(bool(false))
		else :
			set_current_cherries(bool(true))

func create_cherry_on_bush(typeOfCherry:String, positionObject:Vector3, rotationObject:Vector3, amount:int) -> void:
	
	if amount >= 5:
		amount = 5
	
	for i in amount:
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

func set_player_health(subtract:bool, amount:float) -> void:
	if subtract == null: subtract = false
	
	if subtract: playerHealth -= float(amount)
	else: playerHealth += float(amount)

func add_table_items() -> void:
	pass

func add_cherry_type(newType:String) -> void:
	cherryTypes.append(String(newType))

func add_table_item(newItem:String) -> void:
	currentTableItems.append(String(newItem))

func get_cherry_count() -> int:
	var currentCherries:int = interationObjectsContainer.get_child_count(true)
	return int(currentCherries)

func get_current_table_items() -> void: #make  -> Array: 
	pass

func get_current_hovered_item() -> InteractableObject:
	if playerRaycast.is_colliding():
		var theObject:Node3D = playerRaycast.get_collider()
		if theObject == null: return
		var theObjectsParent:InteractableObject = theObject.get_parent()
		return theObjectsParent
	return

func set_current_cherries(lock:bool) -> void:
	for cherry in interationObjectsContainer.get_node("Cherries").get_children(false):
		cherry.canInteract = bool(lock)

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
			if theObject == null: return ""
			var theObjectParent:InteractableObject = theObject.get_parent()
			
			#if theObjectParent.is_in_group(interactableItemList[0]): return "Press [E] to Pick."   #Cherry
			#elif theObjectParent.is_in_group(interactableItemList[1]): return "Press [E] to Grab." #medicalpills
			#elif theObjectParent.is_in_group(interactableItemList[2]): return "Press [E] to Grab." #mecicalscanner
			#elif theObjectParent.is_in_group(interactableItemList[3]): return "Press [E] to Use."  #table
			
			# Normal
			if theObjectParent.is_in_group(String(interactableItemListNames['cherry'])): return "Press [E] to Pick."   #Cherry
			elif theObjectParent.is_in_group(String(interactableItemListNames['medicalpills'])): return "Press [E] to Grab." #medicalpills
			elif theObjectParent.is_in_group(String(interactableItemListNames['medicalscanner'])): return "Press [E] to Grab." #mecicalscanner
			elif theObjectParent.is_in_group(String(interactableItemListNames['table'])): return "Press [E] to Use."  #table
			elif theObjectParent.is_in_group(String(interactableItemListNames['paper1'])): return "Press [E] to Read."  #paper1
			
			# Summer
			elif theObjectParent.is_in_group(String(interactableItemListNames['waterbottle'])): return "Press [E] to Grab."  #paper1
			
			else : return ""
		else : return ""
	return ""

func use_item() -> void:
	if (
		isHoldingItem == true
		&& currentHeldItem != null
		&& currentHeldItemType != ""
	):
		match String(currentHeldItemType):
			'cherry':
				pass
				
			'medicalpills':
				use_item_effects(
					"consumeMedicalPills",
					1.8,
					func():
						set_player_health(bool(false), float(0.32))
						reset_all_hold_items()
				)
			
			'medicalscanner':
				pass
				
			# Summer
			'waterbottle':
				use_item_effects(
					"consume_waterbottle",
					1.2,
					func():
						reset_all_hold_items()
				)

func use_item_effects(signal_name:String, time_until_done:float, effect:Callable) -> void:
	currentHeldItem.emit_signal(String(signal_name))
	await (get_tree().create_timer(float(time_until_done)).timeout)
	effect.call()

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
					object.is_in_group(String(interactableItemListNames["cherry"])) 
					&& object.canInteract == true
				):
					new_held_item(
						true,
						object,
						false,
						String(interactableItemListNames["cherry"])
					)
				
				elif (
					object.is_in_group(String(interactableItemListNames["medicalpills"])) 
					&& object.canInteract == true
				):
					new_held_item(
						true,
						object,
						false,
						String(interactableItemListNames["medicalpills"])
					)
					
				elif (
					object.is_in_group(String(interactableItemListNames["paper1"])) 
					&& object.canInteract == true
				):
					var audio:AudioStreamPlayer = AudioStreamPlayer.new()
					var sound = load("res://Assets/Audio/paper/paperSample_3.ogg")
					
					audio.stream = sound
					audio.pitch_scale = float(1.5)
					
					add_child(audio)
					audio.play(float(0.5))
					
					object.queue_free()
					await get_tree().create_timer(1.5).timeout
					sound = null
					audio.queue_free()
					
				# Summer
				elif (
					object.is_in_group(String(interactableItemListNames["waterbottle"])) 
					&& object.canInteract == true
				):
					new_held_item(
						true,
						object,
						false,
						String(interactableItemListNames['waterbottle'])
					)
					
				print("\nCurrent held item: ", currentHeldItem, "\nThe type of this object: ", currentHeldItemType)
	else :
		print("Could not pick item up: Already have one in hand.")

func is_section_clear() -> bool:
	var cherryCount:int = interationObjectsContainer.get_node("Cherries").get_child_count(true)
	if (cherryCount <= 0 || cherryCount == null): return true
	else: return false

func _on_new_day(dayName: String, dayDescription: String, daySaveData: Dictionary, scoreForComplete: float) -> void:
	currentDaysPast = int(currentDay)
	currentCherrySectionsLeft = (int(currentCherrySectionsLeft) + 5)
	currentDay += 1
	
	playerScore += float(scoreForComplete)

func _on_has_died(reason: String, onDay: int) -> void:
	pass # Replace with function body.

func new_cherry_section() -> void:
	lastCherrySection = int(cherrySection)
	currentCherrySectionsLeft = int(currentCherrySectionsLeft) - 1
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
			9.5 * float(delta))
