extends Label

func _physics_process(delta):
	if Game != null and is_instance_valid(Game.player):
		text = "Player position: "+str(Game.player.global_position)
