extends Node

# BOOLS
var isHoldingCherry:bool = false
var isClicked:bool = false
var isPaused:bool = false
var isInCombo:bool = false
var isInOptionsMenu:bool = false
var isInAchievementsMenu:bool = false
# INTS
var score:int = 0
var cur_Times:int = 0
var cur_multi:int = 1
var cur_timeScale:int = 0
var curCherryModel:int = 1
# PLAYER SAVE
var Player:Dictionary = {
	"Level": 0,
	"Score": 0,
	"Cherrys": 0,
	"cherrysMulti": 1,
	"Upgrades": {
		"ScoreMulti": 0,
		"HungerMulti": 0,
		"RoughnessMulti": 0
	},
	"Achievements": {
#		"": false,
#		"": false,
#		"": false,
#		"": false,
#		"": false
	}
}
# SETTINGS
var Settings:Dictionary = {
	"customMouse": true,
	"fullScreen": false
}
# SAVE PATHS
var save_path_settings = "res://saves/options.json"
var save_path_player = "res://saves/player_data.json"

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
						
	if (Data.Settings["fullScreen"] == true):
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	if (Data.Settings["fullScreen"] == false):
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	
func _save_settings():
	var file = FileAccess.open(save_path_settings, FileAccess.WRITE)
	var item = {
		"customMouse": Settings["customMouse"],
		"fullScreen": Settings["fullScreen"]
	}
	var items_mashed = JSON.stringify(item)
	file.store_line(items_mashed)

func _load_player():
	var file = FileAccess.open(save_path_player, FileAccess.READ)
	if (not file):
		return
	if (file == null):
		return
	if (file.file_exists(save_path_player)):
		if (!file.eof_reached()):
			var cl = JSON.parse_string(file.get_line())
			if (cl):
				Player["Level"] = cl["level"]
				Player["Score"] = cl["score"]
				Player["Cherrys"] = cl["cherrys"]
				Player["cherrysMulti"] = cl["cherrysMulti"]
				
				Player["Upgrades"]["ScoreMulti"] = cl["upgrades"]["scoreMulti"]
				Player["Upgrades"]["HingerMulti"] = cl["upgrades"]["hungerMulti"]
				Player["Upgrades"]["RoughnessMulti"] = cl["upgrades"]["roughnessMulti"]

func _save_player_build():
	var file = FileAccess.open(save_path_player, FileAccess.WRITE)
	var item = {
	"level": Player["Level"],
	"score": Player["Score"],
	"cherrys": Player["Cherrys"],
	"cherrysMulti": Player["cherrysMulti"],
	"upgrades": {
		"scoreMulti": Player["Upgrades"]["ScoreMulti"],
		"hungerMulti": Player["Upgrades"]["HungerMulti"],
		"roughnessMulti": Player["Upgrades"]["RoughnessMulti"]
		}
	}
	var itemsmerged = JSON.stringify(item)
	file.store_line(itemsmerged)
