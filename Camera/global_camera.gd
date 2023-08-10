extends Camera3D

@export var follow_player = true 

var target = null

func _init():
	set_cull_mask_value(20, false);

func _physics_process(delta):
	if follow_player and Game.player != null and target != Game.player:
		target = Game.player._camera_target
	
	if target == null:
		return
	
	global_transform = global_transform.interpolate_with(target.global_transform, delta * 20.0)
