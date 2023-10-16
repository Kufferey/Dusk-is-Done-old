extends Node

# BOOLS
var isHoldingCherry:bool = false
var isClicked:bool = false
var isPaused:bool = false
var isInCombo:bool = false
var isInOptionsMenu:bool = false
# INTS
var score:int = 0
var cur_Times:int = 0
var cur_multi:int = 1
var curCherryModel:int = 1
# PLAYER SAVE
var Player:Dictionary = {
	"Score": 0,
	"Cherrys": 0,
	"cherrysMulti": 1,
	"Upgrades": {
		"ScoreMulti": 0,
		"HungerMulti": 0,
		"RoughnessMulti": 0
	}
}
# SETTINGS
var Settings:Dictionary = {
	"customMouse": true,
	"fullScreen": false
}
# SAVE PATHS
var save_path_settings = "res://SAVE_DATA.json"

func _set_fullscreen_on():
	Settings["fullScreen"] = true
	return true

func _load_settings():
	var file = FileAccess.open(save_path_settings, FileAccess.READ)
	if (not file):
		return
	if (file == null):
		return
	if (file.file_exists(save_path_settings)):
		if (!file.eof_reached()):
			var cl = JSON.parse_string(file.get_line())
			if (cl):
				Settings["customMouse"] = cl["customMouse"]
				Settings["fullScreen"] = cl["fullScreen"]
			
	
func _save_settings():
	var file = FileAccess.open(save_path_settings, FileAccess.WRITE)
	var item = {
		"customMouse": Settings["customMouse"],
		"fullScreen": Settings["fullScreen"]
	}
	var items_mashed = JSON.stringify(item)
	file.store_line(items_mashed)
	
func _save_player_build():
	pass
