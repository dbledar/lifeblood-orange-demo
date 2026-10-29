extends Control

@onready var play_button : Button = $margin/vbox/center/menu/play
@onready var settings_button : Button = $margin/vbox/center/menu/settings
@onready var quit_button : Button = $margin/vbox/center/menu/quit

func _ready() -> void:
	play_button.pressed.connect(on_button_pressed.bind('play'))
	settings_button.pressed.connect(on_button_pressed.bind('settings'))
	quit_button.pressed.connect(on_button_pressed.bind('quit'))

func on_button_pressed(action : String) -> void:
	match action:
		'play':
			get_tree().change_scene_to_file('res://scenes/saves_screen.tscn')
		'settings':
			get_tree().change_scene_to_file('res://scenes/settings_screen.tscn')
		'quit':
			get_tree().quit()
