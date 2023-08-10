extends Entity

class_name Player

@onready var _gimbal: CameraGimbal = get_node("Gimbal")
@onready var _camera_target: Marker3D = _gimbal.get_node("CameraTarget")
@onready var _animations: AnimationTree = get_node("anim")

@export_category("Input Processing")
@export var process_movement_input = true
@export var process_interaction_input = true


func _physics_process(delta):
	super(delta)
	
	$mesh.visible = !_gimbal.get_current_camera_setup().hide_target_mesh
	
	rotation_degrees.y = _gimbal.rotation_degrees.y
	
	process_movement_input = in_vehicle == null
	
	

	if process_movement_input and Input != null:
		if Input.is_action_just_pressed("ui_accept") and is_on_floor():
			velocity.y = JUMP_VELOCITY

		var input_dir = Input.get_vector("left", "right", "forward", "backward")
		var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if direction:
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
	
	_animations.set("parameters/movement/blend_position", Vector2(velocity.x, velocity.z).length())

func can_move():
	return in_vehicle == null
