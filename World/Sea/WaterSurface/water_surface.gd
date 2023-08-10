@tool
extends MeshInstance3D

class_name WaterSurface

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
		

func _ready():
	update_wave_materials()
	

func _physics_process(_delta):
	if water_mat != null and !Engine.is_editor_hint():
		water_mat.set_shader_parameter("gameTime", Game.elapsed_time*time_scale)

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
	if !is_instance_valid(water_mat):
		water_mat = get("surface_material_override/0")
	
	if !is_instance_valid(water_mat):
		printerr("no water material found :(")
		return
	
	water_mat.set_shader_parameter("waveA", waveA)
	water_mat.set_shader_parameter("waveB", waveB)
	water_mat.set_shader_parameter("waveC", waveC)
	
