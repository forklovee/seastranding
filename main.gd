extends Node3D

@export var player_spawn_point: Marker3D

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	await get_tree().create_timer(0.1).timeout
	
	var start_state = Game.start_gameplay(player_spawn_point)
	
	print("Gameplay started with code: ", start_state)

