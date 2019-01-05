local NOISE = love.filesystem.read("script/render/perlin2d.glsl")

local effects =
{
	desaturation = 
	[[
	vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords )
	{
		vec4 pixel = Texel(texture, texture_coords );
		number average = (pixel.r+pixel.b+pixel.g)/3.0;
		pixel.r = average;
		pixel.g = average;
		pixel.b = average;
  		return pixel;
	}
	]],

	nebula = NOISE ..
	[[
		uniform Image nebula;
		uniform float density = 1.0;
		uniform float falloff = 4.0;
		uniform float scale = 1.0;
		uniform vec2 offset = vec2(0, 0);
		uniform vec3 tint = vec3(1, 0, 0);

		float normalnoise(vec2 p)
		{
		    return perlin2d( p ) * 0.5 + 0.5;
		}

		float noise(vec2 p)
		{
			p += offset;
			const int steps = 5;
			float scale = pow(2.0, float(steps));
			float displace = 0.0;
			for (int i = 0; i < steps; i++) {
				displace = normalnoise(p * scale + displace);
				scale *= 0.5;
			}
			return normalnoise(p + displace);
		}

		vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords )
		{
			vec4 pixel = vec4( 0, 0, 0, 1 ); //Texel( texture, texture_coords );
			float w = max( love_ScreenSize.x, love_ScreenSize.y );
			float n = noise( screen_coords * scale / w );
			n = pow( n + density, falloff);
			vec3 rgb = max( 0, 1.0 - n) * pixel.rgb + min( 1.0, n ) * tint.rgb;
			return vec4( rgb * color.rgb, 1.0 );
			// return vec4( normalnoise( screen_coords / max( love_ScreenSize.x, love_ScreenSize.y ) ), 0, 0, 1 );
			// return vec4( screen_coords.x / love_ScreenSize.x, screen_coords.y / love_ScreenSize.y, 0, 1 );
		}
	]]
}

for k, v in pairs( effects ) do
	effects[k] = love.graphics.newShader( v )
end

strictify( effects )

return effects
