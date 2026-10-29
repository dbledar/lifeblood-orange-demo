extends Control

@onready var window_type : OptionButton = $margin/vbox/window_type/window_options
@onready var master_slider : HSlider = $margin/vbox/audio_rows/master/slider
@onready var music_slider : HSlider = $margin/vbox/audio_rows/music/slider
@onready var sfx_slider : HSlider = $margin/vbox/audio_rows/sfx/slider
@onready var voice_slider : HSlider = $margin/vbox/audio_rows/voice/slider
@onready var back_button : Button = $margin/vbox/back

func _ready() -> void:
	window_type.add_item('Windowed', 0)
	window_type.add_item('Fullscreen', 1)
	window_type.add_item('Borderless Windowed', 2)
	window_type.item_selected.connect(on_window_type_selected)
	back_button.connect('pressed', on_back_button_pressed)
	
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		window_type.select(1)
	elif DisplayServer.window_get_flag(DisplayServer.WINDOW_FLAG_BORDERLESS):
		window_type.select(2)
	else:
		window_type.select(0)
	
	connect_volume_slider(master_slider, &'Master')
	connect_volume_slider(music_slider, &'Music')
	connect_volume_slider(sfx_slider, &'SFX')
	connect_volume_slider(voice_slider, &'Voice')
	

func on_window_type_selected(index : int) -> void:
	match index:
		0:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
		1:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
		2:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)

func connect_volume_slider(slider : HSlider, bus_name : StringName) -> void:
	var bus_index := AudioServer.get_bus_index(bus_name)
	if bus_index <= 0:
		push_warning('Audio bus not found: ' + bus_name)
		return
	
	slider.value = AudioServer.get_bus_volume_linear(bus_index) * 100.0
	slider.value_changed.connect(on_volume_changed.bind(bus_name))

func on_volume_changed(value : float, bus_name : StringName) -> void:
	var bus_index := AudioServer.get_bus_index(bus_name)
	if bus_index >= 0:
		AudioServer.set_bus_volume_linear(bus_index, value / 100.0)

func on_back_button_pressed() -> void:
	get_tree().change_scene_to_file('res://scenes/title_screen.tscn')
