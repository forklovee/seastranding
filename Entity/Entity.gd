extends CharacterBody3D

class_name Entity

@export var entity_name = "entity"

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var relative_water_level = 0.0

var in_vehicle: Vehicle = null:
	set (value):
		in_vehicle = value
	get:
		return in_vehicle

func _physics_process(delta):
	if Game.sea_surface != null:
		var sea_surface : SeaSurface = Game.sea_surface
		var water_level = sea_surface.get_height(global_position)
		
		#relative_water_level = global_position - water_level
	
	if not is_on_floor() and in_vehicle == null and relative_water_level > 0.0:
		velocity.y -= gravity * delta
	else:
		velocity.y = relative_water_level
