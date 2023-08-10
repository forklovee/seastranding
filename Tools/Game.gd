extends Node

class HumanTime:
	enum Season{
		Spring = 0,
		Summer = 1,
		Autumn = 2,
		Winter = 3
	}
	
	var minutes = 0
	var hours = 0
	var day = 0
	var season: Season = Season.Spring
	var year = 0
	
	func _init(_elapsed_time):
		set_time(_elapsed_time)
	
	func set_time(_elapsed_time):
		self.minutes = int(_elapsed_time)
		if self.minutes / 60 < 1.0:
			return
		
		self.hours = int(self.minutes / 60)
		self.minutes -= self.hours*60
		
		if self.hours / 24 < 1.0:
			return
		
		self.day = int(self.hours / 24)
		self.hours -= self.day*24
		
		self.year = int(self.day / 365)
		self.day -= self.year*365
		
		self.season = int(self.day / (365/4))
		self.day -= self.season*(365/4)

@onready var player_res = preload("res://Entity/Player/Player.tscn")
@onready var main_scene = get_node("/root/main") if has_node("/root/main") else null

var player: Player = null
var sea_surface: SeaSurface = null

var game_time = HumanTime.new(0)
var elapsed_time = 0.0

func start_gameplay(player_spawn_point: Marker3D) -> bool:
	if main_scene == null:
		print("Main scene not found !!!")
		return false
	var player_spawn_target = main_scene
	if player_spawn_point != null:
		player_spawn_target = player_spawn_point
	
	player = player_res.instantiate()
	if player_spawn_target.get_parent() is Vehicle:
		player.in_vehicle = player_spawn_target.get_parent()
		player.in_vehicle.entity_inside = player
	
	player_spawn_target.add_child(player)
	player.global_transform = player_spawn_target.global_transform
	player.hide()
	
	sea_surface = main_scene.get_node("sea_surface")
	
	return true
	
func _physics_process(delta):
	elapsed_time += delta
	game_time.set_time(elapsed_time)
