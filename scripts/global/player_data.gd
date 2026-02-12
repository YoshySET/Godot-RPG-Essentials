extends Node

const KEY_LEVEL: String = "level"
const KEY_EXPERIENCE: String = "experience"

var level: int = 1
var experience: int = 0

var save_path_json: String = "user://save_files/savegame.json"
var save_path_binary: String = "user://save_files/savegame.save"


func save_player_data_json() -> void:
	var save_data: Dictionary = {
		KEY_LEVEL: level,
		KEY_EXPERIENCE: experience
	}
	var err: Error = FileHandler.store_json_file(save_data, save_path_json, true)
	if err != OK:
		push_error("Cloud not save player data (JSON): ", error_string(err))


func load_player_data_json() -> void:
	var save_data: Dictionary = {}
	var err: Error = FileHandler.open_json_file(save_path_json, save_data)
	if err != OK:
		push_error("Could not load player data (JSON)", error_string(err))
		return
	
	err = verify_save_data_json(save_data)
	if err != OK:
		push_error("Invalid save file structure")
		return
	
	level = save_data[KEY_LEVEL]
	experience = save_data[KEY_EXPERIENCE]
		
		
func load_player_data_binary() -> void:
	var save_data: Dictionary = {}
	var err: Error = FileHandler.open_binary_file(save_path_binary, save_data)
	if err != OK:
		push_error("Could not load player data (binary)", error_string(err))
		return
	
	err = verify_save_data_binary(save_data)
	if err != OK:
		push_error("Invalid save file structure")
		return
	
	level = save_data[KEY_LEVEL]
	experience = save_data[KEY_EXPERIENCE]
		
		
func save_player_data_binary() -> void:
	var save_data: Dictionary = {
		KEY_LEVEL: level,
		KEY_EXPERIENCE: experience
	}
	var err: Error = FileHandler.store_binary_file(save_data, save_path_binary, true)
	if err != OK:
		push_error("Cloud not save player data (binary): ", error_string(err))


func verify_save_data_json(save_data: Dictionary) -> Error:
	if not save_data.has(KEY_LEVEL):
		return ERR_DOES_NOT_EXIST
	if not save_data.has(KEY_EXPERIENCE):
		return ERR_DOES_NOT_EXIST
	return OK
	
	
func verify_save_data_binary(save_data: Dictionary) -> Error:
	if not save_data.has(KEY_LEVEL):
		return ERR_DOES_NOT_EXIST
	if not save_data.has(KEY_EXPERIENCE):
		return ERR_DOES_NOT_EXIST
	return OK
