extends Entity

class_name Npc

@export var on_ready_behaviour: PackedScene

func _ready():
	if on_ready_behaviour != null:
		var b = on_ready_behaviour.instantiate()
		add_child(b)
