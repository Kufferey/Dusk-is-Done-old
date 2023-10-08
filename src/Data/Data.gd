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
