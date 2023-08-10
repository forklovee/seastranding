extends Node3D

class_name CameraGimbal

class CameraSetup:
	var cameraboom_height = 0.0
	var cameraboom_length = 0.0
	var x_axis_lock = Vector2(-90.0, 90.0)
	var invert_x = false
	var invert_y = false
	
	var hide_target_mesh = false
	
	func _init(cameraboom_height: float, cameraboom_length: float, x_axis_lock: Vector2, invert_x:bool, invert_y: bool, hide_target_mesh = false):
		self.cameraboom_height = cameraboom_height
		self.cameraboom_length = cameraboom_length
		
		self.x_axis_lock = x_axis_lock
		self.invert_x = invert_x
		self.invert_y = invert_y
		
		self.hide_target_mesh = hide_target_mesh

@export var process_camera_input = true
@export_category("Camera Setup")
@export_range(0, 1, 1) var camera_setup_id = 0
@export var camera_setups = [ CameraSetup.new(0, 0, Vector2(-90.0, 90.0), false, false, true), CameraSetup.new(1.5, 4, Vector2(-20.0, 90.0), true, false) ]

func _ready():
	camera_setups = [ CameraSetup.new(0, 0, Vector2(-90.0, 90.0), false, false, true), CameraSetup.new(7.5, 5, Vector2(-80.0, 10.0), true, false) ]

func _input(event):
	if event is InputEventMouseMotion and process_camera_input and \
	camera_setups.size() != 0 and camera_setup_id < camera_setups.size():
		var camera_setup: CameraSetup = camera_setups[camera_setup_id]
		
		var relative = event.relative * .5
		
		rotation_degrees.y -= relative.x if !camera_setup.invert_y else -relative.x
		
		var relative_x = relative.y if camera_setup.invert_x else -relative.y
		rotation_degrees.x = clamp(rotation_degrees.x + relative_x, camera_setups[camera_setup_id].x_axis_lock.x, camera_setups[camera_setup_id].x_axis_lock.y )

func _physics_process(delta):
	if camera_setups.size() == 0 and camera_setup_id > camera_setups.size():
		printerr("No camera setup set!")
		return
	global_position = get_parent().global_position
	
#	$CameraTarget.position.y = camera_setups[camera_setup_id].cameraboom_height
#	$CameraTarget.position.z = camera_setups[camera_setup_id].cameraboom_length

func get_current_camera_setup() -> CameraSetup:
	return camera_setups[camera_setup_id] if camera_setups.size() != 0 and camera_setup_id < camera_setups.size() else CameraSetup.new(0.0, 0.0, Vector2.ONE, false, false)
