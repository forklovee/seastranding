extends Node

@onready var _ui = preload("res://Tools/Debugger/UI/debug_info.tscn")

func _ready():
	_ui = _ui.instantiate()
	add_child(_ui)

func _input(event):
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit(0)
	
	if Input.is_action_just_pressed("toggle_fullscreen"):
		DisplayServer.window_set_mode(
			DisplayServer.WINDOW_MODE_FULLSCREEN 
			if DisplayServer.window_get_mode() != DisplayServer.WINDOW_MODE_FULLSCREEN else 
			DisplayServer.WINDOW_MODE_WINDOWED
		)
	
	if Input.is_action_just_pressed("no_debug_draw"):
		get_viewport().debug_draw = Viewport.DEBUG_DRAW_DISABLED
	
	if Input.is_action_just_pressed("show_wireframe"):
		get_viewport().debug_draw = Viewport.DEBUG_DRAW_WIREFRAME
