shader_type canvas_item;

uniform sampler2D sim_texture;
uniform sampler2D collision_texture;

uniform float phase = 0.2;
uniform float attenuation = 0.999;
uniform float deltaUV = 3.0;

void fragment() {
	vec2 texture_size = intBitsToFloat( textureSize(sim_texture, 0) );
	texture_size = vec2(128.0);
	
	vec2 uv = vec2(UV.x, 1.0 - UV.y);
	float du = 1.0 / texture_size.x;
	float dv = 1.0 / texture_size.y;
	vec3 duv = vec3(du, dv, 0.0) * deltaUV;
	
	vec3 c = texture(sim_texture, UV).rgb;
	float p = (2.0 * c.r - c.g + phase * (
		texture(sim_texture, UV - duv.zy).r +
		texture(sim_texture, UV + duv.zy).r +
		texture(sim_texture, UV - duv.xz).r +
		texture(sim_texture, UV + duv.xz).r - 4.0 * c.r
	)) * attenuation;
	
	vec2 collision_uv = vec2(UV.x, 1.0 - UV.y);
	float collision = texture(collision_texture, collision_uv).r;
	float prevCollision = texture(sim_texture, UV).r;
	
	if (collision > 0.0 && prevCollision == 0.0){
		p += collision * .5;
	}
	if (prevCollision > 0.0 && collision == 0.0){
		p -= prevCollision * .5;
	}
	
	COLOR = vec4(p, c.r, collision, 1.0);
}
