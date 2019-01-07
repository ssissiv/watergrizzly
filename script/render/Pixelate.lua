local SHADER =
[[
    extern float size = 2;

    vec4 effect(vec4 color, Image tex, vec2 tex_coords, vec2 screen_coords)
    {
    	tex_coords = floor( tex_coords * size ) / size;
		vec4 c = Texel( tex, tex_coords );
		return color * c;
    }
]]

return love.graphics.newShader( SHADER )
