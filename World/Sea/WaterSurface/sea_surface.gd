@tool
extends GridMap

class_name SeaSurface

@onready var sea_material_resource = preload("res://World/Sea/WaterSurface/MainWater.material")

enum SurfaceDetail{
	LOW = 3,
	MEDIUM_LOW = 2,
	MEDIUM = 1,
	HIGH = 0
}

@export var time_scale = 1.0
@onready var water_mat = get("surface_material_override/0")

@export_category("Waves")
@export var waveA : Vector4 = Vector4(
	1.0, 0.5, #direction
	.5, #steepness
	10.0 #wave length
):
	set(value):
		waveA = value
		update_wave_materials()

@export var waveB : Vector4 = Vector4(
	-0.7, 0.1, #direction
	.25, #steepness
	4.0 #wave length
):
	set(value):
		waveB = value
		update_wave_materials()
		

@export var waveC : Vector4 = Vector4(
	-1.0, 0.1, #direction
	.15, #steepness
	10.0 #wave length
):
	set(value):
		waveC = value
		update_wave_materials()

var high_poly_cells : PackedVector3Array
var last_visited_tile : Vector3i = Vector3i.ZERO

var enable_lod = false
var update_tiles_r = 2

func _input(event):
	if Input.is_action_just_pressed("SeaLOD_toggle"):
		enable_lod = !enable_lod
		
		for x in range(-500, 500):
			for y in range(-500, 500):
				set_cell_item(Vector3i(x, 0, y), SurfaceDetail.HIGH if !enable_lod else SurfaceDetail.LOW)
		
		last_visited_tile = Vector3i.ZERO
		high_poly_cells.clear()
	
	update_tiles_r += Input.get_action_strength("SeaLOD_radius_up") - Input.get_action_strength("SeaLOD_radius_down")

func _init():
	update_wave_materials()
	
	if Engine.is_editor_hint():
		if !is_instance_valid(sea_material_resource):
			sea_material_resource = load("res://World/Sea/WaterSurface/MainWater.material")
		
		for x in range(-500, 500):
			for y in range(-500, 500):
				set_cell_item(Vector3i(x, 0, y), SurfaceDetail.MEDIUM)

func _ready():
	update_wave_materials()
	
	for x in range(-500, 500):
		for y in range(-500, 500):
			set_cell_item(Vector3i(x, 0, y), SurfaceDetail.LOW if enable_lod else SurfaceDetail.HIGH)


func _physics_process(_delta):
	if sea_material_resource != null and !Engine.is_editor_hint():
		sea_material_resource.set_shader_parameter("gameTime", Game.elapsed_time*time_scale)
	
	if !Engine.is_editor_hint() and is_instance_valid(Game.player) and enable_lod:
		var player_map_position = local_to_map(Game.player.global_position * Vector3(1, 0, 1))
		if player_map_position == last_visited_tile: return
		print("New visited tile!")
		var player_tile = get_cell_item(player_map_position)
		if player_tile != INVALID_CELL_ITEM:
			for last_tile_position in high_poly_cells:
				set_cell_item(last_tile_position, SurfaceDetail.LOW)
			
			high_poly_cells.clear()
			for y in range(-update_tiles_r, update_tiles_r+1):
				for x in range(-update_tiles_r, update_tiles_r+1):
					var cell_position = player_map_position + Vector3i(x, 0, y)
					set_cell_item(cell_position, SurfaceDetail.HIGH)
					high_poly_cells.append(cell_position)
			
			last_visited_tile = player_map_position
			

func get_height(point: Vector3):
	return get_point(point).y;

func get_gerstner(point: Vector3, wave: Vector4):
	var waveDir: Vector2 = Vector2(wave.x, wave.y);
	var steepness: float = wave.z;
	var waveL: float = wave.w;
	
	var k = 2.0*PI/waveL;
	var c = sqrt(9.81/k);
	var dir = waveDir.normalized();
	var f = k * (dir.dot(Vector2(point.x, point.z)) - c * (Game.elapsed_time*time_scale));
	var a = steepness / k;
	
#	return Vector3(dir.x * a * cos(f), a * sin(f), dir.y * a * cos(f));
	return Vector3(0, a * sin(f), 0);

func get_point(object_point: Vector3):
	return get_gerstner(object_point, waveA) + get_gerstner(object_point, waveB) + get_gerstner(object_point, waveC);

func update_wave_materials():
	if !is_instance_valid(sea_material_resource):
		sea_material_resource = load("res://World/Sea/WaterSurface/MainWater.material")
	
	if !is_instance_valid(sea_material_resource):
		printerr("no water material found :(")
		return
	
	sea_material_resource.set_shader_parameter("waveA", waveA)
	sea_material_resource.set_shader_parameter("waveB", waveB)
	sea_material_resource.set_shader_parameter("waveC", waveC)

func get_sea_tile(point_global_position: Vector3) -> Vector3i:
	var cell_position = local_to_map(point_global_position * Vector3(1, 0, 1))
	var cell = get_cell_item(cell_position)
	return cell_position
