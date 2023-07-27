shader_type spatial;
//render_mode diffuse_toon, specular_toon, blend_mix;

uniform float timeScale = 1.0;

uniform sampler2D simulation_texture;

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

uniform vec4 waveA = vec4(1.0, 0.5, .5, 10); //dir.x, dir.y, steepness, wave length
uniform vec4 waveB = vec4(-0.7, 0.1, .25, 4); //dir.x, dir.y, steepness, wave length
uniform vec4 waveC = vec4(-1.0, 0.1, .15, 10); //dir.x, dir.y, steepness, wave length

vec3 simulate_water(vec2 uv){
	float r = texture(simulation_texture, uv).r;
	
	return vec3(r, 0.0, 0.0);
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
void vertex(){
	vec3 tangent = vec3(1, 0, 0);
	vec3 binormal = vec3(0, 0, 1);
	
	VERTEX += GerstnerWave(waveA, VERTEX, tangent, binormal);
	VERTEX += GerstnerWave(waveB, VERTEX, tangent, binormal);
	VERTEX += GerstnerWave(waveC, VERTEX, tangent, binormal);
	height = VERTEX.y;
	
//	
}

void fragment(){
	
	ALBEDO = simulate_water(UV);
//	ALPHA = 1.0;
//	vec2 baseUVoffset = UV*uvOffsetScale;
//	baseUVoffset += gameTime*uvOffsetTimeScale*0.01;
//	vec2 txBasedOffset = texture(uvOffsetTx, baseUVoffset*txSize).rg*.01;
//	txBasedOffset = txBasedOffset*2.0-1.0;
//	vec2 txUV = UV*txSize;
//	txUV += uvOffsetA * txBasedOffset * (.03*sin(gameTime*.8)+0.5);
//
//	ALBEDO = texture(tx, txUV*txSize).rgb;
//	ALBEDO = vec3(ALBEDO.r + ALBEDO.g + ALBEDO.b) / 3.0;
//	ALBEDO *= colorTint.rgb*colorTint.a;
//	ALBEDO *= vec3(smoothstep(6.0, height, 0.25));
	
//	NORMAL_MAP = texture(normalTx, txUV*uvNormalOffsetScale).rgb;
//	NORMAL_MAP *= vec3(NORMAL_MAP.r + NORMAL_MAP.g + NORMAL_MAP.b)*0.8;
//	METALLIC = 0.2;
//	ROUGHNESS = 0.95;
//	vec3 refNormal = normalize(mix(NORMAL, TANGENT * NORMAL_MAP.x + BINORMAL * NORMAL_MAP.y + NORMAL * NORMAL_MAP.z, DEPTH));
//	vec2 refOvs = SCREEN_UV - refNormal.xy*1.2;
//
//	float zDepth = linearize(NORMAL_MAP_DEPTH);
//	float zPos = linearize(FRAGCOORD.z);
//	float diff = zDepth-zPos;
//
//	//darkening on edges
//	vec2 disp = texture(normalTx, 5.0*sin((UV*foamSize*64.0)-gameTime/100.0)).rg;
//	disp = ((disp*2.0)-1.0)*foamFlowStr;
//	diff += disp.x;
//	vec4 mixCol = mix(foamColor, vec4(ALBEDO.r, ALBEDO.g, ALBEDO.b, 0.0), step(0.1, diff));
//	ALBEDO = mixCol.rgb;
//	ALBEDO = mix(foamColor, vec4(ALBEDO.r, ALBEDO.g, ALBEDO.b, 0.0), .5).rgb;
	
//	disp = texture(normalTx, vec2(0.01)).rg;
//	disp = ((disp*2.0)-1.0)*1.4;
//	diff -= disp.x;
//	mixCol = mix(vec4(1.0), vec4(ALBEDO.r, ALBEDO.g, ALBEDO.b, 0.0), step(.01, diff));
//	ALBEDO = mixCol.rgb;

	//depth buffer
//	float depth = texture(DEPTH_TEXTURE, SCREEN_UV).r;
//	depth = depth*2.0-1.0;
//	depth = PROJECTION_MATRIX[3][2]/(depth+PROJECTION_MATRIX[2][2]);
//	depth = depth + VERTEX.z;
//	depth *= 0.04;
//	depth = clamp(depth, 0, alphaClamp);
//
//	ALPHA = depth+depthAlphaFix;
}