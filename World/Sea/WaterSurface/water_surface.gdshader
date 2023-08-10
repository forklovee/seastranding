shader_type spatial;
render_mode diffuse_lambert, blend_mix, depth_draw_always, world_vertex_coords;

uniform float timeScale = 1.0;

uniform sampler2D depth_texture : source_color, hint_depth_texture;

uniform sampler2D simulation_texture;
uniform float simulation_a = 0.0;

uniform sampler2D tx;
uniform vec4 colorTint : source_color;
uniform float tintScale = 0.5;
uniform vec2 txSize = vec2(2.0, 2.0);
uniform vec2 foamSize = vec2(2.0, 2.0);

uniform sampler2D uvOffsetTx;
uniform vec2 uvOffsetScale = vec2(0.2, 0.2);
uniform vec2 uvNormalOffsetScale = vec2(0.2, 0.2);
uniform float uvOffsetTimeScale = 0.05;
uniform float uvOffsetA = 0.2;

uniform sampler2D normalTx: hint_normal;

uniform vec4 foamColor : source_color;
uniform float foamFlowStr = 0.5;
uniform float foamFlowSpeed = 0.1;
uniform float pposScale = 1.0;

uniform float near = 0.15;
uniform float far = 300.0;

uniform float alphaClamp = 0.9;
uniform float depthAlphaFix = 0.9;

uniform float gameTime = 0.0;

uniform vec4 waveA = vec4(0.245, 0.5, .5, 22); //dir.x, dir.y, steepness, wave length
uniform vec4 waveB = vec4(-0.275, 0.1, .25, 20); //dir.x, dir.y, steepness, wave length
uniform vec4 waveC = vec4(0.17, 0.1, .15, 50); //dir.x, dir.y, steepness, wave length

uniform vec4 fragment_waveA = vec4(0.245, 0.5, .5, 22); //dir.x, dir.y, steepness, wave length
uniform vec4 fragment_waveB = vec4(-0.275, 0.1, .25, 20); //dir.x, dir.y, steepness, wave length
uniform vec4 fragment_waveC = vec4(0.17, 0.1, .15, 50); //dir.x, dir.y, steepness, wave length

vec3 simulate_water(vec2 uv, vec3 normal){
	vec3 water_sim = texture(simulation_texture, uv).rgb;
	water_sim = vec3(water_sim.r *= .5) * normal;
	
	return water_sim;
}

float linearize(float cDepth){
	cDepth = 2.0*cDepth-1.0;
	return near * far/(far+cDepth*(near-far));
}

vec3 GerstnerWave(vec4 wave, vec3 pos, out vec3 tangent, out vec3 binormal){
	vec2 waveDir = wave.xy;
	float steepness = wave.z;
	float waveL = wave.w;
	
	float k = 2.0*PI/waveL;
	float c = sqrt(9.81/k);
	vec2 dir = normalize(waveDir);
	float f = k * (dot(dir, pos.xz) - c * gameTime);
	float a = steepness / k;
	
	//tangent and binormal
	
	tangent += vec3(
		-dir.x * dir.x * (steepness * sin(f)),
		dir.x * (steepness * cos(f)),
		-dir.x * dir.y * (steepness * sin(f))
	);
	binormal += vec3(
		-dir.y * dir.y * (steepness * sin(f)),
		dir.y * (steepness * cos(f)),
		-dir.y * dir.y * (steepness * sin(f))
	);
	
//	return vec3(dir.x * a * cos(f), a * sin(f), dir.y * a * cos(f));
	return vec3(0, a * sin(f), 0);
}

varying float height;
varying float fragment_height;
void vertex(){
	vec3 tangent = vec3(0.0);
	vec3 binormal = vec3(0.0);
	
	vec3 vert = VERTEX;
	vert += GerstnerWave(fragment_waveA, vert, tangent, binormal);
	vert += GerstnerWave(fragment_waveB, vert, tangent, binormal);
	vert += GerstnerWave(fragment_waveC, vert, tangent, binormal);
	fragment_height = vert.y;
	
	tangent = vec3(0.0);
	binormal = vec3(0.0);
	VERTEX += GerstnerWave(waveA, VERTEX, tangent, binormal);
	VERTEX += GerstnerWave(waveB, VERTEX, tangent, binormal);
	VERTEX += GerstnerWave(waveC, VERTEX, tangent, binormal);
	
	height = VERTEX.y;
}

void fragment(){
	//depth buffer
	float depth = texture(depth_texture, SCREEN_UV).r;
	depth = PROJECTION_MATRIX[3][2]/(depth+PROJECTION_MATRIX[2][2]);
	depth = depth + VERTEX.z;
	float albedo_depth = clamp(exp(-depth * 5.2), 0.0, 1.0);
	float alpha_depth = exp(-depth * 2.0);
	vec3 color = vec3(1.0-albedo_depth) * colorTint.rgb;
	ALPHA = 1.0 - alpha_depth;
	vec3 depth_color = (height*.1 + 0.9)*color;
	
	vec2 baseUVoffset = UV*uvOffsetScale;
	baseUVoffset += sin(TIME*0.0001);
	vec3 txBasedOffset = texture(uvOffsetTx, baseUVoffset*txSize*5.0 + 1.5*sin(TIME*.005)).rgb;
	
	float foam_anim_offset = 0.01*sin(TIME);
	
	vec2 waves_uv = UV*txSize*.001;
	waves_uv += txBasedOffset.rg*.6;
	vec3 waves_color = texture(tx, waves_uv).rgb;
	waves_color = vec3(waves_color.r + waves_color.g + waves_color.b) / 3.0;
	waves_color = (waves_color.r > 0.8+foam_anim_offset && waves_color.r < 0.9+foam_anim_offset ||
	waves_color.r > 0.48+foam_anim_offset && waves_color.r < 0.75+foam_anim_offset ||
	waves_color.r > 0.0+foam_anim_offset && waves_color.r < 0.45+foam_anim_offset) ? vec3(1.0) : vec3(0.0);
	ROUGHNESS = 0.1*txBasedOffset.r*waves_color.r;
	waves_color *= -0.05;
	
	ALBEDO = depth_color*clamp(1.0-fragment_height, 0.5, 1.0) + waves_color;
}