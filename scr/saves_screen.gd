extends Control

const TITLE_SCREEN = 'res://scenes/title_screen.tscn'
const OPENING_SCENE = 'res://scenes/opening_sequence.tscn'

@onready var back_button: Button = $margin/layout/footer/back


func _ready() -> void:
	back_button.pressed.connect(on_back_pressed)

	for slot in range(1, 4):
		var row_path := 'margin/layout/saves/slot_%d' % slot
		var select_button: Button = get_node(row_path + '/select')
		var delete_button: Button = get_node(row_path + '/delete')

		select_button.pressed.connect(on_select_pressed.bind(slot))
		delete_button.pressed.connect(on_delete_pressed.bind(slot))

	refresh_slots()


func refresh_slots() -> void:
	for slot in range(1, 4):
		var row_path := 'margin/layout/saves/slot_%d' % slot
		var select_button: Button = get_node(row_path + '/select')
		var delete_button: Button = get_node(row_path + '/delete')

		if SaveManager.has_slot(slot):
			var save_data: Dictionary = SaveManager.read_slot(slot)
			select_button.text = make_save_summary(slot, save_data)
			delete_button.disabled = false
		else:
			select_button.text = 'SAVE %d\nNEW GAME' % slot
			delete_button.disabled = true


func make_save_summary(slot: int, save_data: Dictionary) -> String:
	var tools: Array = save_data.get('tools', [])
	var tool_names := PackedStringArray()

	for tool in tools:
		tool_names.append(str(tool))

	var tools_text := 'None'
	if not tool_names.is_empty():
		tools_text = ', '.join(tool_names)

	var play_time := int(save_data.get('play_time_seconds', 0))
	var ending_reached := bool(save_data.get('ending_reached', false))
	var ending_text := 'Achieved' if ending_reached else 'Not achieved'

	return 'SAVE %d\nTools: %s\nTime: %s\nDemo ending: %s' % [
		slot,
		tools_text,
		format_play_time(play_time),
		ending_text,
	]


func format_play_time(total_seconds: int) -> String:
	var hours := int(total_seconds / 3600.0)
	var minutes := int((total_seconds % 3600) / 60.0)
	var seconds := total_seconds % 60

	return '%02d:%02d:%02d' % [hours, minutes, seconds]


func on_select_pressed(slot: int) -> void:
	SaveManager.selected_slot = slot

	if SaveManager.has_slot(slot):
		var save_data: Dictionary = SaveManager.read_slot(slot)
		SaveManager.pending_save = save_data

		var scene_path: String = save_data.get('scene_path', OPENING_SCENE)
		get_tree().change_scene_to_file(scene_path)
	else:
		SaveManager.pending_save = { }
		get_tree().change_scene_to_file(OPENING_SCENE)


func on_delete_pressed(slot: int) -> void:
	if SaveManager.has_slot(slot):
		SaveManager.delete_slot(slot)
		refresh_slots()


func on_back_pressed() -> void:
	get_tree().change_scene_to_file(TITLE_SCREEN)


func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed('ui_cancel'):
		get_viewport().set_input_as_handled()
		get_tree().change_scene_to_file(TITLE_SCREEN)
