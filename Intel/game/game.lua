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
local PHASE_IN = 60 * 6 -- 1 minute.

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
    local dt0, dt1 = math.random() * 600 + 1000, math.random() * 500 + 500
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
	self.intel = gintel( self )
	
	self:loadTopography( "defaultmap.lua" )
end

function game:destroy()
	local renderTable = MOAIRenderMgr.getRenderTable() or {}
	array.removeElement( renderTable, self.layer )
	MOAIRenderMgr.setRenderTable( renderTable )

	for _,node in pairs(self.nodes) do
		node:destroy()
	end
		
	self.nodes, self.links = nil, nil
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

function game:spawnUnit( unit, node )
	
	table.insert( self.units, unit )

	node:addUnit( unit )
	unit:onSpawn( self, node )
end

function game:findNode( x, y )
	for _,node in pairs(self.nodes) do
		if node:intersects( x, y ) then
			return node
		end
	end
end

function game:findHomeNode()
	return self.nodes[1]
end

function game:buyUnit( unittype )
	
	if self:findHomeNode() == nil then
		return
	end
	
	local unit

	if unittype == gamedefs.UNIT_SCOUT then
		unit = gunit(
			{
				unittype = unittype,
				icon = "unit_scout.png", mapIcon = "map_scout.png"
			} )
	elseif unittype == gamedefs.UNIT_FIGHTER then
		unit = gunit(
			{
				unittype = unittype,
				icon = "unit_fighter.png", mapIcon = "map_fighter.png",
				attack = 20
			} )
	end
	
	self:spawnUnit( unit, self:findHomeNode() )
end

function game:doPhaseIn()
	local i = math.random( #self.nodes )
	if not self.nodes[i].isHome then
		self.nodes[i]:doPhaseIn()
	end
	
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

function game:doTick( ticks )
	self.tick = self.tick + ticks
	
	if self.tick % PHASE_IN == 0 then
		self:doPhaseIn()
	end
	
	for _,node in pairs(self.nodes) do
		node:refreshViz( self.intel )
	end
	for _,unit in pairs(self.units) do
		unit:refreshViz()
	end
end

