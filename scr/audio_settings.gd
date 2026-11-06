extends Node

const SETTINGS_PATH := 'user://settings.cfg'
const BUS_NAMES: Array[StringName] = [&'Master', &'Music', &'SFX', &'Voice']


func _ready() -> void:
	load_audio_settings()


func load_audio_settings() -> void:
	var config := ConfigFile.new()

	if config.load(SETTINGS_PATH) != OK:
		return

	for bus_name in BUS_NAMES:
		var bus_index := AudioServer.get_bus_index(bus_name)
		if bus_index < 0:
			push_warning('Audio bus not found: ' + str(bus_name))
			continue

		var saved_volume := float(config.get_value('audio', str(bus_name), 1.0))
		AudioServer.set_bus_volume_linear(bus_index, clampf(saved_volume, 0.0, 1.0))


func set_bus_volume(bus_name: StringName, volume: float) -> void:
	var bus_index := AudioServer.get_bus_index(bus_name)
	if bus_index < 0:
		push_warning('Audio bus not found ' + str(bus_name))
		return

	AudioServer.set_bus_volume_linear(bus_index, clampf(volume, 0.0, 1.0))
	save_audio_settings()


func save_audio_settings() -> void:
	var config := ConfigFile.new()
	config.load(SETTINGS_PATH)
	for bus_name in BUS_NAMES:
		var bus_index := AudioServer.get_bus_index(bus_name)
		if bus_index < 0:
			continue

		config.set_value('audio', str(bus_name), AudioServer.get_bus_volume_linear(bus_index))

		var error := config.save(SETTINGS_PATH)
		if error != OK:
			push_warning('Could not save audio settings.')
