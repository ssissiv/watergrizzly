
local SHADER = 
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
]]

return love.graphics.newShader( SHADER )
