class_name SaveManager extends Node

static func dusk_is_done_save( path:String , custom_save:bool , contents:String  ) -> void:
	var save_path:String = OS.get_system_dir(
		OS.SYSTEM_DIR_DOCUMENTS) + "/Dusk Is Done/" + path
	var save_path_file:String = OS.get_system_dir(
		OS.SYSTEM_DIR_DOCUMENTS) + "/Dusk Is Done/Save/"
		
	if !DirAccess.dir_exists_absolute(save_path_file) : DirAccess.make_dir_recursive_absolute(save_path_file)
	
	if !custom_save:
		contents = ""
		
		var latest_picture:String
		var name_of_save:String
		var desc_of_save:String
		
		var save_file:Dictionary = {
			"day" + str(GameState.currentDay) : {
				"save_info" : {
					"day" : GameState.currentDay,
					"day_past" : GameState.currentDaysPast,
					"difficulty" : GameState.currentDifficulty,
					"section" : GameState.cherrySection,
					"last_section" : GameState.lastCherrySection,
					"season" : GameState.currentSeason
				},
				"save_item_list" : [
					GameState.interactableItemListNames
				],
				"save_player" : {
					"held_item" : GameState.currentHeldItem,
					"held_item_type" : GameState.currentHeldItemType,
					"is_holding_item" : GameState.isHoldingItem,
					"player_health" : GameState.playerHealth
				}
			}
		}
		
		var file = FileAccess.open(save_path , FileAccess.WRITE)
		
		file.store_string(str(save_file))
		
		file.close()
