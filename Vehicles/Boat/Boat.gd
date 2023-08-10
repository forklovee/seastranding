extends Vehicle

class_name Boat

@onready var water_surface: SeaSurface = get_parent().get_node("sea_surface") if get_parent().has_node("sea_surface") else null
@onready var engine_foam_particles: GPUParticles3D = get_node("engine_foam") if has_node("engine_foam") else null

func _physics_process(delta):
	super(delta)
	var point0 = 0 if water_surface == null else water_surface.get_height(global_position - Vector3(0, 0, 0.5))
	var floating_height = 0 if water_surface == null else water_surface.get_height(global_position)
	var point2 = 0 if water_surface == null else water_surface.get_height(global_position + Vector3(0, 0, 0.5))
	$mesh.global_rotation.x = point0 - point2
	
	rotation.y = lerp_angle(rotation.y, rotation.y - dir.x, 0.7*delta)
	
	var movement_velocity = transform.basis * Vector3(0, 0, dir.z)*10.0
	velocity.x = move_toward(velocity.x, movement_velocity.x, delta*2.0)
	velocity.y = (floating_height-global_position.y) * 20.0
	velocity.z = move_toward(velocity.z, movement_velocity.z, delta*2.0) 
	
	move_and_slide()
