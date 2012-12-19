----------------------------------------------------------------
-- GAME JAM! 2012
----------------------------------------------------------------

WIN_HEIGHT, WIN_WIDTH = 1280, 720
local NEBULA = MOAIImage.new()


MOAISim.openWindow ( "test", WIN_HEIGHT, WIN_WIDTH )

game = {}

game.viewport = MOAIViewport.new ()
game.viewport:setSize ( WIN_HEIGHT, WIN_WIDTH )
game.viewport:setScale (WIN_HEIGHT, WIN_WIDTH )

game.layer = MOAILayer2D.new ()
game.layer:setViewport ( game.viewport )
MOAISim.pushRenderPass ( game.layer )

game.camera = MOAICamera2D.new()
game.layer:setCamera( game.camera )

----------------------------------------------------------------

local function createCurve( pts, duration, prop, attr )

	local curve = MOAIAnimCurve.new ()
	curve:reserveKeys ( #pts )
	for i,v in pairs(pts) do
		curve:setKey ( i, (i-1) * duration/#pts, v, MOAIEaseType.LINEAR )
	end

	prop:setAttrLink ( attr, curve, MOAIAnimCurve.ATTR_VALUE )

	local timer = MOAITimer.new ()
	timer:setMode( MOAITimer.LOOP )
	timer:setSpan ( 0, curve:getLength ())
	timer:setTime( math.random() * curve:getLength() )

	curve:setAttrLink ( MOAIAnimCurve.ATTR_TIME, timer, MOAITimer.ATTR_TIME )

	timer:start()
end

local function createNebula( layer, filename )

	local r = math.random( -640, 640) 
	local x0, y0 = math.random( -1280, 1280 ), math.random( -720, 720 )
	local xs, ys = { x0 + r }, {y0}
	for i = 1,16 do
		local x, y = math.cos( i * 2 * math.pi / 16 ) * r, math.sin( i * 2 * math.pi / 16 ) * r
		table.insert( xs, x + x0 )
		table.insert( ys, y + y0 )
	end
	local r0, dr = math.random() * 360, math.random( -3, 3 ) * 360
	local duration = math.random() * 600 + 1000
	local s0, s1 = math.random() * 3 + 1, math.random() * 3 + 1
	
	local gfxQuad = MOAIGfxQuad2D.new ()
	gfxQuad:setTexture ( filename )
	gfxQuad:setRect ( -256, -256, 256, 256 )
	gfxQuad:setUVRect ( 0, 0, 1, 1 )

	local prop = MOAIProp2D.new ()
	prop:setDeck ( gfxQuad )
	prop:setLoc( x0, y0 )
	prop:setRot( r0 )
	prop:setScl( s0, s1 )
	
	local c1 = createCurve( { r0, r0 + dr}, duration, prop, MOAIProp2D.ATTR_Z_ROT )
	local c2 = createCurve( xs, duration, prop, MOAIProp2D.ATTR_X_LOC )
	local c3 = createCurve( ys, duration, prop, MOAIProp2D.ATTR_Y_LOC )
	
	layer:insertProp( prop )
	
	return { prop = prop,  c1 = c1, c2 = c2, c3 = c3 }
end

local function createBG( layer )

	local gfxQuad = MOAIGfxQuad2D.new ()
	gfxQuad:setTexture ( "space.png" )
	gfxQuad:setRect ( -640, -360, 640, 360 )
	gfxQuad:setUVRect ( 0, 0, 1, 1 )

	local prop = MOAIProp2D.new ()
	prop:setDeck ( gfxQuad )
	
	layer:insertProp( prop )
end


createBG( game.layer )

game.nebula = {}
for i = 1,8 do
	game.nebula[i] = createNebula( game.layer, "nebula1.png" )
end
for i = 1,8 do
	game.nebula[i] = createNebula( game.layer, "nebula2.png" )
end
for i = 1,8 do
	game.nebula[i] = createNebula( game.layer, "nebula3.png" )
end


