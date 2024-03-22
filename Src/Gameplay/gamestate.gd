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

# for misc stuff
var currentPillsTooken:int
var currentPillsTookenTotal:int

# player stuff
var canInteract:bool
var canUseItem:bool

var playerCamera:Node3D
var playerRaycast:RayCast3D

var playerItemHolderHand:Node3D

# UI Vars
var interationText:String
var interactionTextNode:Label
var itemControllsTextNode:Label

var DebuggingText:Label

# Gameplay Vars
static var interactableItemList:Array[String] = [
	'cherry',          # 0
	'medicalpills',    # 1
	'medicalscanner',  # 2
	'table',           # 3
	'paper1',          # 4
	
	# Summer
	'waterbottle'      # 5
]

static var interactableItemListNames:Dictionary = {
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
	
	playerHealth = float(0.2)
	playerRaycast = $Player/cameraPos/RayCast3D
	playerCamera = $Player/cameraPos
	playerItemHolderHand = $Player/cameraPos/ItemHolder
	
	canInteract = bool(true)
	canUseItem = bool(true)
	isTrayPlaced = bool(false)
	
	interactionTextNode = $UI/interactionText
	itemControllsTextNode = $UI/itemControlls
	DebuggingText = $UI/DebugText
	
	create_cherry_on_bush('normal', Vector3(0.4,0,0), Vector3(0,0,0), 1)
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	SaveManager.dusk_is_done_save("/Save/k.json", false, "")

func _input(event: InputEvent) -> void:
	if (
		event.is_action_pressed("interact")
		&& canInteract == true
	):
		set_hovered_to_held_item()
		
	if (
		event.is_action_pressed("use")
		&& currentHeldItem != null
		&& currentHeldItemType != ""
	):
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

func create_cherry_on_bush( typeOfCherry:String , positionObject:Vector3 , rotationObject:Vector3 , amount:int ) -> void:
	
	if amount >= 5:
		amount = 5
	
	for i in amount:
		var cherryOnBushInstance:InteractableObject = cherryOnBush.instantiate()
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

func create_object_from_prefab( prefab:PackedScene , objectPosition:Vector3 , objectRotation:Vector3 ) -> void:
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

func toggle_mouse_interaction_icon( toggle:bool ) -> void:
	if toggle:
		$UI/Pickupicon.show()
		$UI/curser.hide()
	elif !toggle:
		$UI/Pickupicon.hide()
		$UI/curser.show()

func set_player_health( subtract:bool , amount:float ) -> void:
	if subtract == null: subtract = false
	
	if subtract: playerHealth -= float(amount)
	else: playerHealth += float(amount)

func add_table_items() -> void:
	pass

func add_cherry_type( newType:String ) -> void:
	cherryTypes.append(String(newType))

func add_table_item( newItem:String ) -> void:
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
		var theObjectParentNode3D:Node3D = theObject.get_parent()
		if theObjectParentNode3D is InteractableObject:
			var theObjectsParent:InteractableObject = theObject.get_parent()
			return theObjectsParent
	return

func item_can_interact( object:Node3D , item_group:String ) -> bool:
	if (
		object.is_in_group(item_group)
		&& object.canInteract == true
	):
		return true
	else :
		return false

func set_current_cherries( lock:bool ) -> void:
	for cherry in interationObjectsContainer.get_node("Cherries").get_children(false):
		cherry.canInteract = bool(lock)

#OLD
#func show_screen_text( text:String , duration:float , fade_in:bool ) -> void:
	#
	#if fade_in:
		#$UI/poptext.show()
		#var current_transparency:float = 1
		#var popup_node:Control = $UI/poptext/popTextBox
		#
		#popup_node.modulate = Color( 1, 1, 1, current_transparency )
		#
		#popup_node.text = text
		#
		#await get_tree().create_timer(duration).timeout
		#
		#while current_transparency > 0.1:
			#current_transparency -= 0.1
			#popup_node.modulate = Color( 1, 1, 1, current_transparency )
			#await (get_tree().create_timer(0.1).timeout)
		#
		#popup_node.text = ""
		#
		#$UI/poptext.hide()
		#popup_node = null
		#
	#else :
		#$UI/poptext.show()
		#$UI/poptext/popTextBox.text = text
		#await get_tree().create_timer(duration).timeout
		#$UI/poptext/popTextBox.text = ""
		#$UI/poptext.hide()

func show_screen_text( timer_to_start:float , text:String , duration:float , fall_in_direction:bool , rotation_speed:float ) -> void:
	if duration == null || duration > 1: duration = 0.01
	if text == null || text == "": text = "TEXT IS BLANK OR\nNO TEXT."
	
	if timer_to_start >= 0: await (get_tree().create_timer(timer_to_start).timeout)
	
	if fall_in_direction:
		if rotation_speed == null || rotation_speed >= 0.05:
			rotation_speed = 0.005
		elif rotation_speed == 0.00:
			var random_number:float = randf_range(-0.005 , 0.005)
			rotation_speed = random_number
	
	var current_transparency:float = 1
	var new_text_node:Label = Label.new()
	new_text_node.text = text
	new_text_node.modulate = Color( 1 , 1 , 1 , current_transparency )
	new_text_node.theme = $UI/poptext/popTextBox.theme
	new_text_node.position.x = $UI/poptext/popTextBox.position.x
	new_text_node.position.y = $UI/poptext/popTextBox.position.y
	new_text_node.pivot_offset = $UI/poptext/popTextBox.pivot_offset
	new_text_node.horizontal_alignment = $UI/poptext/popTextBox.horizontal_alignment
	new_text_node.vertical_alignment = $UI/poptext/popTextBox.vertical_alignment
	new_text_node.anchors_preset = $UI/poptext/popTextBox.anchors_preset
	new_text_node.set("layout_mode", $UI/poptext/popTextBox.layout_mode)
	new_text_node.set("anchors_preset", $UI/poptext/popTextBox.get("anchors_preset"))
	#new_text_node.set("size", $UI/poptext/popTextBox.get("size"))
	#new_text_node.set("position", $UI/poptext/popTextBox.get("position"))
	
	get_node("UI/poptext").add_child(new_text_node)
	
	while current_transparency > 0.0:
		
		new_text_node.position.y += 1.5
		
		if fall_in_direction:
			new_text_node.rotation += rotation_speed
		
		current_transparency -= 0.01
		new_text_node.modulate = Color( 1 , 1 , 1 , current_transparency )
		await (get_tree().create_timer(duration).timeout)
	
	new_text_node.queue_free()

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
	if isHoldingItem:
		toggle_mouse_interaction_icon(false)
		return ""
	
	elif !isHoldingItem:
		if playerRaycast.is_colliding():
			
			var theObject:Node3D = playerRaycast.get_collider()
			if theObject == null: return ""
			var theObjectParent:Node3D = theObject.get_parent()
			
			if theObjectParent is InteractableObject:
				var theInteractableObject:InteractableObject = theObjectParent
				
				#if theObjectParent.is_in_group(interactableItemList[0]): return "Press [E] to Pick."   #Cherry
				#elif theObjectParent.is_in_group(interactableItemList[1]): return "Press [E] to Grab." #medicalpills
				#elif theObjectParent.is_in_group(interactableItemList[2]): return "Press [E] to Grab." #mecicalscanner
				#elif theObjectParent.is_in_group(interactableItemList[3]): return "Press [E] to Use."  #table
				
				toggle_mouse_interaction_icon(true)
				
				# Normal
				if theInteractableObject.is_in_group( String(interactableItemListNames['cherry'] )): return "Press [E] to Pick."   #Cherry
				elif theInteractableObject.is_in_group( String(interactableItemListNames['medicalpills'] )): return "Press [E] to Grab." #medicalpills
				elif theInteractableObject.is_in_group( String(interactableItemListNames['medicalscanner'] )): return "Press [E] to Grab." #mecicalscanner
				elif theInteractableObject.is_in_group( String(interactableItemListNames['table'] )): return "Press [E] to Use."  #table
				elif theInteractableObject.is_in_group( String(interactableItemListNames['paper1'] )): return "Press [E] to Read."  #paper1
				
				# Summer
				elif theInteractableObject.is_in_group( String(interactableItemListNames['waterbottle'] )): return "Press [E] to Grab."  #paper1
				
				else :
					toggle_mouse_interaction_icon(false)
					return ""
					
		else :
			toggle_mouse_interaction_icon(false)
			return ""
			
	toggle_mouse_interaction_icon(false)
	return ""

func use_item() -> void:
	if (
		isHoldingItem == true
		&& currentHeldItem != null
		&& currentHeldItemType != ""
		&& canUseItem != false
	):
		canUseItem = bool(false)
		match String(currentHeldItemType):
			'cherry':
				pass
				
			'medicalpills':
				use_item_effects(
					"consumeMedicalPills",
					1.5,
					func():
						var random_health_amount:float = randf_range( 0.30 , 0.50 )
						
						show_screen_text( 0 , "+"+str(( float(snappedf(random_health_amount, 0.01)) ) )+" Health" , 2 , true , 0 )
						
						if currentPillsTooken == 3: show_screen_text( 1.5 , "Something don't feel right." , 0.05 , false , 0 )
						elif currentPillsTooken == 4: emit_signal("hasDied", "Drug overdose.", currentDay)
						
						set_player_health(bool(false), float(random_health_amount))
						
						currentPillsTooken += 1
						
						currentHeldItem.queue_free()
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

func use_item_effects( signal_name:String , time_until_done:float , effect:Callable ) -> void:
	canUseItem = bool(false)
	currentHeldItem.emit_signal(String(signal_name))
	await (get_tree().create_timer(float(time_until_done)).timeout)
	effect.call()

func new_held_item( isHolding:bool , newHeldItem:InteractableObject , canInteract:bool , canUseItem:bool , newHeldType:String ) -> void:
	isHoldingItem = isHolding
	currentHeldItem = newHeldItem
	canInteract = canInteract
	canUseItem = canUseItem
	currentHeldItemType = newHeldType

func reset_all_hold_items() -> void:
	isHoldingItem = false
	currentHeldItem = null
	canInteract = true
	canUseItem = true
	currentHeldItemType = ""

func set_hovered_to_held_item() -> void:
	if !isHoldingItem:
		if playerRaycast.is_colliding():
			var object:Node3D = get_current_hovered_item()
			
			if object:
				
				if object is InteractableObject:
				
					if item_can_interact( object , String(interactableItemListNames["cherry"]) ):
						
						new_held_item(
							true,
							object,
							false,
							true,
							String(interactableItemListNames["cherry"])
						)
					
					elif item_can_interact( object , String(interactableItemListNames["medicalpills"]) ):
						
						new_held_item(
							true,
							object,
							false,
							true,
							String(interactableItemListNames["medicalpills"])
						)
						
					elif item_can_interact( object , String(interactableItemListNames["paper1"]) ):
						
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
					elif item_can_interact( object , String(interactableItemListNames["waterbottle"]) ):
						
						new_held_item(
							true,
							object,
							false,
							true,
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
	currentCherrySectionsLeft = int(currentCherrySectionsLeft) + 5
	currentDay += 1
	
	currentPillsTooken = 0
	
	playerScore += float(scoreForComplete)

func _on_has_died(reason: String, onDay: int) -> void:
	print(reason +"\n"+"On day: "+str(onDay))

func new_cherry_section() -> void:
	lastCherrySection = int(cherrySection)
	currentCherrySectionsLeft = int(currentCherrySectionsLeft) - 1
	cherrySection += 1
	print("New Cherry Section: ", cherrySection)

func _debug_Update() -> String:
	return (
		(
			"CURRENT FPS: " + str(Engine.get_frames_per_second()) + "/" + str(Engine.max_fps) +
			"\nCURRENT MEM: " + str(OS.get_static_memory_usage()) +
			"\n" +
			"\n" +
			"ITEM HAND/HOVER STATS:" +
			"\n" +
			"\n" +
			"Can Use Item: " + str(canUseItem) +
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

func make_current_item_sway( delta:float ) -> void:
	if (
		isHoldingItem == true
		&& currentHeldItem != null
	):
		currentHeldItem.rotation.z = float(playerItemHolderHand.global_rotation.z)
		currentHeldItem.rotation.y = float(playerItemHolderHand.global_rotation.y)
		currentHeldItem.rotation.x = float(playerItemHolderHand.global_rotation.x)
		currentHeldItem.position = lerp(Vector3(
			float(currentHeldItem.position.x), float(currentHeldItem.position.y), float(currentHeldItem.position.z)),
			Vector3(float(playerItemHolderHand.global_position.x), float(playerItemHolderHand.global_position.y), float(playerItemHolderHand.global_position.z)),
			9.5 * float(delta))
