require("modules/class")
local util = require("modules/util")
local array = require("modules/array")
local mathutil = require("modules/mathutil")
local camhandler = require("game/camhandler")
local gnode = require("game/gnode")
local glink = require("game/glink")
local gunit = require("game/gunit")
local gintel = require("game/gintel")
local gamedefs = require("game/gamedefs")

----------------------------------------------------------------

-- Time to open an enemy gate
local PHASE_IN = 60 * 30
local PHASE_IN_DIST = 400
local START_CREDS = 100

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
		
			MOAIGfxDevice.setPenColor ( 0.5, 0.5, 0.5, 1 )
			MOAIGfxDevice.setPenWidth ( 3 )
			
			for _,link in pairs(game.links) do
				MOAIDraw.drawLine( link:getPosition() )
			end
		end )
	
	local prop = MOAIProp2D.new ()
	prop:setDeck ( scriptDeck )
	
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
	
	createLinkViz( self.layer, self )
	
	self.listeners = {}
	
	self.tick = 0
	self.nodes = {}
	self.units = {}
	self.links = {}
	self.resources = { creds = START_CREDS }
	self.intel = gintel( self )
	
	self:loadTopography( "defaultmap.lua" )
	
	if #self.nodes > 0 then
		self:spawnUnit( gunit( gamedefs.UNIT_PLAYER ), self.nodes[1] )
	end
end

function game:destroy()
	local renderTable = MOAIRenderMgr.getRenderTable() or {}
	array.removeElement( renderTable, self.layer )
	MOAIRenderMgr.setRenderTable( renderTable )

	for _,node in pairs(self.nodes) do
		node:destroy()
	end
	for _,unit in pairs(self.units) do
		unit:destroy()
	end
		
	self.nodes, self.links, self.units = nil, nil, nil
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

function game:wndToWorld( x, y )
	return self.layer:wndToWorld( x, y )
end

function game:worldToWnd( x, y )
	return self.layer:worldToWnd( x, y )
end

function game:saveTopography( filename )
	log:write( "Saving topography to '%s'", filename )
	local fl = io.open( filename, "w" )
	if fl then
		for _,node in pairs(self.nodes) do
			fl:write( string.format("node %d %d\n", node:getPosition()) )
		end
		
		for _,link in pairs(self.links) do
			local i, j = util.indexOf(self.nodes, link.n0), util.indexOf(self.nodes, link.n1)
			fl:write( string.format("link %d %d\n", i, j))
		end
		
		fl:close()
		log:write("\tSuccess!")
	end
end

function game:loadTopography( filename )
	log:write( "Loading topography from '%s'", filename )
	local fl = io.open( filename, "r" )
	if fl then
		for _,node in pairs(self.nodes) do
			node:destroy()
		end
		self.nodes, self.links = {}, {}
		
		for line in fl:lines() do
			local i,j, x,y = line:find( "^node ([-%d]+) ([-%d]+)" )
			if x and y then
				self:spawnNode( gnode( tonumber(x), tonumber(y) ))
			end
			
			local i,j, k,l = line:find( "^link ([%d]+) ([%d]+)" )
			if k and l then
				self:spawnLink( self.nodes[tonumber(k)], self.nodes[tonumber(l)] )
			end
		end
		fl:close()
		log:write("\tSuccess!")
	end
end

function game:spawnNode( node )
	if #self.nodes == 0 then
		node:getTraits().isHome = true
		self.intel:add( node, node )
	elseif math.random() < 0.2 then
		node:getTraits().creds = math.random(10, 100)
	end
	
	table.insert( self.nodes, node )
	node:onSpawn( self )
end

function game:spawnLink( node0, node1 )
	local link = glink( node0, node1 )
	table.insert( self.links, link )

	node0:addLink( link )
	node1:addLink( link )
end

function game:spawnUnit( unit, node, ... )
	
	table.insert( self.units, unit )

	unit:onSpawn( self, node, ... )
end

function game:despawnUnit( unit )
	log:write(" DESPAWN %s", unit:getName() )
	
	array.removeElement( self.units, unit )
	
	if unit:getNode() then
		unit:getNode():removeUnit( unit )
	end
	
	unit:destroy()
end

function game:findNode( x, y )
	for _,node in pairs(self.nodes) do
		if node:intersects( x, y ) then
			return node
		end
	end
end

function game:findHomeNode()
	return self:findPlayer():getNode()
end

function game:findPlayer()
	for _,unit in pairs(self.units) do
		if unit:getTraits().unittype == gamedefs.UNIT_PLAYER then
			return unit
		end
	end
end

function game:getResource( name )
	return self.resources[name]
end

function game:addResource( name, amt )
	self.resources[name] = math.max( 0, self.resources[name] + amt )
	self:dispatchEvent( gamedefs.EV_UPDATE_RESOURCES )
end

function game:addResources( resources )
	for resource,cost in pairs(resources) do
		self:addResource( resource, cost )
	end
end

function game:buyUnit( unittype, ... )
	
	if self:isGameOver() then
		return
	end
	
	local homeNode = self:findHomeNode()
	if homeNode == nil then
		return
	end
	
	local unit = gunit( unittype )
	for resource,cost in pairs(unit:getTraits().cost) do
		if self.resources[resource] and self.resources[resource] < cost then
			return
		end
	end
	for resource,cost in pairs(unit:getTraits().cost) do
		self:addResource( resource, -cost )
	end

	log:write("BUY : %s at %s", unit:getName(), homeNode:getName() )
	self:spawnUnit( unit, homeNode, ... )
end

function game:doPhaseIn()
	local homeNode = self:findHomeNode()
	local px, py = self:findPlayer():getPosition()
	
	local i, dist
	
	repeat
		i = math.random( #self.nodes )
		dist = mathutil.dist2d( px, py, self.nodes[i]:getPosition() )
	until dist > PHASE_IN_DIST
	
	log:write("PHASE IN - dist %.2f", dist)
	self.nodes[i]:doPhaseIn()
	
	self:dispatchEvent( gamedefs.EV_PHASEIN )
end

function game:getAllUnits()
	return self.units
end

function game:getIntel()
	return self.intel
end

function game:getTick()
	return self.tick
end

function game:isGameOver()
	return self.gameOver == true
end

function game:setGameOver()
	log:write("GAME OVER at tick %d!", self.tick )
	self.intel:setOmniscient( true )
	self:pause( true )
	self.gameOver = true
end

function game:pause( paused )
	if self:isGameOver() then
		return -- no changing pause status one game over hits
	end
	
	if paused ~= self.paused then
		log:write("PAUSE: " ..tostring(paused))
		self.paused = paused

		for _,node in pairs(self.nodes) do
			node:pause( paused )
		end
		for _,unit in pairs(self.units) do
			unit:pause( paused )
		end
	end
end

function game:isPaused()
	return self.paused == true
end

function game:doTick( ticks )
	if not self.paused and not self:isGameOver() then
		self.tick = self.tick + ticks
		
		if self.tick % PHASE_IN == 0 then
			self:doPhaseIn()
		end

		local px, py = self:findPlayer():getPosition()
		for _,unit in pairs(self.units) do
			local catchRadius = unit:getTraits().catchRadius
			if catchRadius and catchRadius > mathutil.dist2d( px, py, unit:getPosition() ) then
				self:setGameOver()
				break
			end
		end
	end
	
	for _,node in pairs(self.nodes) do
		node:refreshViz( self.intel )
	end
	for _,unit in pairs(self.units) do
		unit:refreshViz()
	end
end

