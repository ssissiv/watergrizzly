class( "Render" )

function Render.CreateNebula()
	local st = os.clock()
	local width, height = 1024, 1024
	local canvas = love.graphics.newCanvas( width, height )
	love.graphics.setCanvas( canvas )

	local tintr, tintg, tintb = math.random(), math.random(), math.random()

	Shaders.nebula:send( "density", 0.10 + 0.1 * math.random() )
	Shaders.nebula:send( "falloff", 3.0 + 2.0 * math.random() )
	Shaders.nebula:send( "scale", math.random() + 0.5 )
	Shaders.nebula:send( "offset", { math.random() * 100, math.random() * 100 } )
	Shaders.nebula:send( "tint", { tintr, tintg, tintb } )
	love.graphics.setShader( Shaders.nebula )
	love.graphics.rectangle( "fill", 0, 0, width, height )
	love.graphics.setShader()

	for i = 1, 100 do
		love.graphics.setColor( 1, 1, 1, 0.5 + 0.5 * math.random() )
		local r = math.random() * 1.5
		local x, y = math.random( width ), math.random( height )
		if r >= 1.0 then
			love.graphics.circle( "fill", x, y, r )
		else
			love.graphics.points( x, y )
		end
	end

	love.graphics.setCanvas()
	
	print( string.format( "Render.CreateNebula took %.2f ms", (os.clock() - st) * 1000 ))
	return canvas
end
