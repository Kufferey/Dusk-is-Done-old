extends Control

signal Remove_self

var isInShop:bool = false
var curSelection:int

# SHOP ICONS
@onready var twoXicon = $"Shop_home/Icons/2xupgrades"
@onready var hungericon = $Shop_home/Icons/hungerupgrades
@onready var roughnessicon = $Shop_home/Icons/roughnessupgrades

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	isInShop = false
	curSelection = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if (Input.is_action_just_pressed("pause_menu_left")):
		curSelection += 1
	elif (Input.is_action_just_pressed("pause_menu_right")):
		curSelection -= 1
	if (Input.is_action_just_pressed("exit") && isInShop == true):
		isInShop = false
	elif (Input.is_action_just_pressed("exit") && isInShop == false):
		Data.isPaused = false
		emit_signal("Remove_self")
	
	if (isInShop):
		$Logo.hide()
		$Panel.hide()
		$Resume.hide()
		$Shop.hide()
		$Exit.hide()
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		Game_Mouse.hide()
		$Shop_home.show()
		
		if (curSelection > 2):
			curSelection = 0
		elif (curSelection < 0):
			curSelection = 2
		
		match curSelection:
			0:
				twoXicon.emit_signal("move_icon_2xupgrades", Vector2(550,350), 5 * delta)
				hungericon.emit_signal("move_icon_hungerupgrades", Vector2(-550,350), 5 * delta)
				roughnessicon.emit_signal("move_icon_roughupgrades", Vector2(-550,-350), 5 * delta)
			1:
				twoXicon.emit_signal("move_icon_2xupgrades", Vector2(-550,-350), 5 * delta)
				hungericon.emit_signal("move_icon_hungerupgrades", Vector2(550,350), 5 * delta)
				roughnessicon.emit_signal("move_icon_roughupgrades", Vector2(-550,350), 5 * delta)
			2:
				twoXicon.emit_signal("move_icon_2xupgrades", Vector2(-550,350), 5 * delta)
				hungericon.emit_signal("move_icon_hungerupgrades", Vector2(-550,-350), 5 * delta)
				roughnessicon.emit_signal("move_icon_roughupgrades", Vector2(550,350), 5 * delta)
		
	else :
		$Logo.show()
		$Panel.show()
		$Resume.show()
		$Shop.show()
		$Exit.show()
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		Game_Mouse.show()
		$Shop_home.hide()


func _on_resume_pressed() -> void:
	if (!isInShop):
		Data.isPaused = false
		emit_signal("Remove_self")


func _on_shop_pressed() -> void:
	if (!isInShop):
		isInShop = !isInShop


func _on_exit_pressed() -> void:
	if (!isInShop):
		Data.isPaused = false
		emit_signal("Remove_self")
		get_tree().change_scene_to_file("res://scenes/mainmenu.tscn")
