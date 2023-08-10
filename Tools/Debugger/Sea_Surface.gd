extends Label

func _physics_process(delta):
	if Game.sea_surface == null: return
	var sea_surface: SeaSurface = Game.sea_surface
	
	var info = "Sea Surface\n"
	info += "LOD "
	info += "enabled" if sea_surface.enable_lod else "disabled"
	info += "\n"
	
	if sea_surface.enable_lod:
		info += "LOD update radius: "+str(sea_surface.update_tiles_r)
	
	text = info
