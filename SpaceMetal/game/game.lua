require("modules/class")
local util = require("modules/util")
local array = require("modules/array")
local mathutil = require("modules/mathutil")
local camhandler = require("game/camhandler")
local gamedefs = require("game/gamedefs")
local csship = require("game/csship")

----------------------------------------------------------------

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
    local dt0, dt1 = math.random() * 600 + 400, math.random() * 300 + 300
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
    
    local c1 = createCurve( { r0, r0 + dr}, dt0, prop, MOAIProp2D.ATTR_Z_ROT )
    local c2 = createCurve( xs, dt1, prop, MOAIProp2D.ATTR_X_LOC )
    local c3 = createCurve( ys, dt1, prop, MOAIProp2D.ATTR_Y_LOC )
    
    layer:insertProp( prop )
    
    return { prop = prop,  c1 = c1, c2 = c2, c3 = c3 }
end

local function createBG( layer )

    local gfxQuad = MOAIGfxQuad2D.new ()
    gfxQuad:setTexture ( "data/space.png" )
    gfxQuad:setRect ( -640, -360, 640, 360 )
    gfxQuad:setUVRect ( 0, 0, 1, 1 )

    local prop = MOAIProp2D.new ()
    prop:setDeck ( gfxQuad )
    
    layer:insertProp( prop )
end

local function createNebulae( layer )
	local nebulae = {}
	for i = 1,8 do
		nebulae[i] = createNebula( layer, "data/nebula1.png" )
	end
	for i = 1,8 do
		nebulae[i] = createNebula( layer, "data/nebula2.png" )
	end
	for i = 1,8 do
		nebulae[i] = createNebula( layer, "data/nebula3.png" )
	end
	return nebulae
end


local function createLinkViz( layer, game )

	local w, h = 1280, 720 -- HMM?
	local scriptDeck = MOAIScriptDeck.new ()
	scriptDeck:setRect ( -w/2, -h/2, w/2, h/2 )
	scriptDeck:setDrawCallback ( 
		function( index, xOff, yOff, xFlip, yFlip )
		
			MOAIGfxDevice.setPenColor ( 0.4, 0.4, 0.4, 0.5 )
			MOAIGfxDevice.setPenWidth ( 2 )
			
			for _,link in pairs(game.links) do
				MOAIDraw.drawLine( link:getPosition() )
			end
		end )
	
	local prop = MOAIProp2D.new ()
	prop:setDeck ( scriptDeck )
	prop:setBlendMode( MOAIProp.GL_SRC_ALPHA, MOAIProp.GL_ONE_MINUS_SRC_ALPHA )    
	
	layer:insertProp( prop )
	
	return prop
end

----------------------------------------------------------------

game = class()

function game:init( viewport )
	log:write("game:init()")
	
	self.viewport = viewport
	self.layer = MOAILayer2D.new ()
	self.layer:setViewport( viewport )

	local renderTable = MOAIRenderMgr.getRenderTable() or {}
	table.insert( renderTable, 1, self.layer )
	MOAIRenderMgr.setRenderTable( renderTable )
	
	self.camhandler = camhandler.createHandler( self.layer )

	createBG( self.layer )
	
	self.nebulae = createNebulae( self.layer )
	
	self.listeners = {}	
	self.units = {}
	
	self.tick = 0
	
	self:spawnUnit( csship() )
end

function game:destroy()
	local renderTable = MOAIRenderMgr.getRenderTable() or {}
	array.removeElement( renderTable, self.layer )
	MOAIRenderMgr.setRenderTable( renderTable )
end

function game:addListener( listener )
	table.insert( self.listeners, listener )
end

function game:dispatchEvent( evType, evData )
	for _,listener in pairs(self.listeners) do
		listener:onSimEvent( evType, evData )
	end
end

function game:getCamera()
	return self.camhandler
end

function game:getPlayer()
	return self.units[1]
end

function game:wndToWorld( x, y )
	return self.layer:wndToWorld( x, y )
end

function game:worldToWnd( x, y )
	return self.layer:worldToWnd( x, y )
end

function game:spawnUnit( unit, ... )
	
	table.insert( self.units, unit )

	unit:onSpawn( self, ... )
end

function game:despawnUnit( unit )
	log:write(" DESPAWN %s", unit:getName() )
	
	array.removeElement( self.units, unit )
	unit:destroy()
end

function game:getTick()
	return self.tick
end

function game:isGameOver()
	return self.gameOver == true
end

function game:setGameOver()
	if not self.gameOver then
		log:write("GAME OVER at tick %d!", self.tick )
		self:pause( true )
		self.gameOver = true
		self:dispatchEvent( gamedefs.EV_GAMEOVER )
	end
end

function game:pause( paused )
	if self:isGameOver() then
		return -- no changing pause status one game over hits
	end
	
	if paused ~= self.paused then
		log:write("PAUSE: " ..tostring(paused))
		self.paused = paused
	end
end

function game:isPaused()
	return self.paused == true
end

function game:doTick( ticks )
	if not self.paused and not self:isGameOver() then
		self.tick = self.tick + ticks
		
		self:getPlayer():shipUpdate( self.tick)
	end
end

