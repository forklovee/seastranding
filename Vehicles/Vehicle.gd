extends CharacterBody3D

class_name Vehicle

@export var dir = Vector3(0,0,0)

var entity_inside = null:
	set (value):
		if !(value is CharacterBody3D):
			entity_inside = null
			set_process_input(false)
			return
		
		entity_inside = value
		set_process_input(entity_inside != null)

func _ready():
	set_process_input(false)

func _physics_process(delta):
	if is_processing_input():
		var input_dir = Input.get_vector("left", "right", "forward", "backward")
		dir = Vector3(input_dir.x, 0, input_dir.y)

func enter(entity: Entity):
	entity_inside = entity
	entity.in_vehicle = self
