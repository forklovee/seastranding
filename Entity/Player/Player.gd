extends Entity

class_name Player

@onready var _gimbal: Node3D = get_node("Gimbal")
@onready var _camera_target: Marker3D = _gimbal.get_node("CameraTarget")

@export_category("Camera Gimbal")
@export var gimbal_x_axis_lock = Vector2(-90.0, 90.0)

@export_category("Input")
@export var process_movement_input = true
@export var process_camera_input = true
@export var process_interaction_input = true

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

var in_vehicle: Vehicle = null:
	set (value):
		process_movement_input = value == null
		in_vehicle = value
	get:
		return in_vehicle

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _input(event):
	if event is InputEventMouseMotion and process_camera_input:
		var relative = event.relative * .25
		
		_gimbal.rotation_degrees.y -= relative.x
		_gimbal.rotation_degrees.x = clamp( _gimbal.rotation_degrees.x + relative.y, gimbal_x_axis_lock.x, gimbal_x_axis_lock.y )

func _physics_process(delta):
	if not is_on_floor() and in_vehicle == null:
		velocity.y -= gravity * delta

	if process_movement_input:
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

func can_move():
	return in_vehicle == null
