extends MeshInstance3D

class_name WaterSurface

@export var time_scale = 1.0
@onready var water_mat = get("surface_material_override/0")

# water simulation
@onready var cr: ColorRect = get_node("SimulationTexture/ColorRect")
@onready var simulation_texture: ViewportTexture = $SimulationTexture.get_texture()
@onready var collision_texture: ViewportTexture = $WaterCollision.get_texture()

var waveA = {
	"dir": Vector2(1.0, 0.5),
	"steepness": .5,
	"wave_len": 10.0
}
var waveB = {
	"dir": Vector2(-0.7, 0.1),
	"steepness": .25,
	"wave_len": 4.0
} 
var waveC = {
	"dir": Vector2(-1.0, 0.1),
	"steepness": .15,
	"wave_len": 10.0
} 

func _ready():
#	if cr != null:
#		cr.material.set_shader_parameter("sim_texture", simulation_texture)
#		cr.material.set_shader_parameter("collision_texture", collision_texture)
	return
	if water_mat != null:
#		water_mat.set_shader_parameter("simulation_texture", simulation_texture)
		#waveA
		var waveA_vec4: Vector4 = water_mat.get_shader_parameter("waveA")
		waveA.dir = Vector2(waveA_vec4.x, waveA_vec4.y)
		waveA.steepness = waveA_vec4.z
		waveA.wave_len = waveA_vec4.w

		#waveB
		var waveB_vec4: Vector4 = water_mat.get_shader_parameter("waveB")
		waveB.dir = Vector2(waveB_vec4.x, waveB_vec4.y)
		waveB.steepness = waveB_vec4.z
		waveB.wave_len = waveB_vec4.w

		#waveC
		var waveC_vec4: Vector4 = water_mat.get_shader_parameter("waveC")
		waveC.dir = Vector2(waveC_vec4.x, waveC_vec4.y)
		waveC.steepness = waveC_vec4.z
		waveC.wave_len = waveC_vec4.w

		

func _physics_process(_delta):
	if water_mat != null:
		water_mat.set_shader_parameter("gameTime", Game.elapsed_time*time_scale)

func get_height(point: Vector3):
	return get_point(point).y;

func get_gerstner(point: Vector3, wave: Dictionary):
	var waveDir: Vector2 = wave.dir;
	var steepness: float = wave.steepness;
	var waveL: float = wave.wave_len;
	
	var k = 2.0*PI/waveL;
	var c = sqrt(9.81/k);
	var dir = waveDir.normalized();
	var f = k * (dir.dot(Vector2(point.x, point.z)) - c * (Game.elapsed_time*time_scale));
	var a = steepness / k;
	
#	return Vector3(dir.x * a * cos(f), a * sin(f), dir.y * a * cos(f));
	return Vector3(0, a * sin(f), 0);

func get_point(object_point: Vector3):
	return get_gerstner(object_point, waveA) + get_gerstner(object_point, waveB) + get_gerstner(object_point, waveC);
