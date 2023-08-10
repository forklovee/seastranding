extends Camera3D


func _physics_process(delta):
	if Game.player != null:
		global_transform.origin.x = Game.player.global_transform.origin.x/8.0
		global_transform.origin.z = -Game.player.global_transform.origin.z/8.0
