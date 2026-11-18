extends Node


func _ready() -> void:
	'''Makes it so that menu music plays across all menu scenes'''
	var player := AudioStreamPlayer.new()
	player.stream = load('res://assets/sound/mus_menu.ogg')
	player.bus = &'Music'
	add_child(player)
	player.play()
