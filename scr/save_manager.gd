extends Node

const SLOT_COUNT := 3
const SAVE_SECTION := 'save'

var selected_slot : int = 0
var pending_save : Dictionary = {}

func slot_path(slot : int) -> String:
	return 'user://save_slot_%d.cfg' % slot

func is_valid_slot(slot : int) -> bool:
	return slot >= 1 and slot <= SLOT_COUNT

func has_slot(slot : int) -> bool:
	if not is_valid_slot(slot):
		return false
	
	return FileAccess.file_exists(slot_path(slot))

func read_slot(slot : int) -> Dictionary:
	if not is_valid_slot(slot) or not has_slot(slot):
		return {}
	
	var config := ConfigFile.new()
	var error := config.load(slot_path(slot))
	
	if error != OK:
		push_warning('Could not read save slot %d.' % slot)
		return {}
	
	var save_data : Dictionary = {}
	
	for key in config.get_section_keys(SAVE_SECTION):
		save_data[key] = config.get_value(SAVE_SECTION, key)
	
	return save_data

func write_slot(slot : int, save_data : Dictionary):
	if not is_valid_slot(slot):
		push_warning('Invalid save slot: %d' % slot)
		return ERR_INVALID_PARAMETER
	
	var config := ConfigFile.new()
	
	for key in save_data:
		config.set_value(SAVE_SECTION, key, save_data[key])
	
	var error := config.save(slot_path(slot))
	
	if error != OK:
		push_warning('Could not write save slot %d.' % slot)
	
	return error
	
func delete_slot(slot : int):
	if not is_valid_slot(slot):
		push_warning('Invalid save slot: %d' % slot)
		return ERR_INVALID_PARAMETER
	
	if not has_slot(slot):
		return OK
	
	var error := DirAccess.remove_absolute(
		ProjectSettings.globalize_path(slot_path(slot))
	)
	
	if error != OK:
		push_warning('Could not delete save slot %d.' % slot)
		return error
	
	if selected_slot == slot:
		selected_slot = 0
		pending_save.clear()
	
	return OK

func save_progress(
	scene_path : String,
	player_position : Vector2,
	tools : Array,
	play_time_seconds : int,
	ending_reached : bool
):
	if not is_valid_slot(selected_slot):
		push_warning('Select a save slot before saving progress.')
		return ERR_INVALID_PARAMETER
	
	var save_data := {
		'scene_path': scene_path,
		'player_position': player_position,
		'tools': tools,
		'play_time_seconds': play_time_seconds,
		'ending_reached': ending_reached
	}
	
	return write_slot(selected_slot, save_data)
