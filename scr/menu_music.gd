extends Node

func _ready() -> void:
	var player := AudioStreamPlayer.new()
	player.stream = load('res://assets/sound/mus_menu.ogg')
	player.bus = &'Music'
	add_child(player)
	player.play()
