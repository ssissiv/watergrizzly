require("modules/class")
local array = require("modules/array")
local texprop = require("modules/texprop")
local mathutil = require("modules/mathutil")

------------------------------------------------------

local function generateName()
	
	return string.format("%s-%s%d",
		string.char( math.random( 0, 26 ) + string.byte('A')),
		string.char( math.random( 0, 26 ) + string.byte('A')),
		math.random( 0, 256 ) )
end

------------------------------------------------------

local gnode = class()

function gnode:init( x, y, traits )
	self.x, self.y = x, y
	self.game = nil
	self.name = generateName()
	self.links = {}
	self.units = {}
	self.traits = traits or {}
end

function gnode:destroy()
	self.prop:destroy()
	self.prop = nil
end

function gnode:getName()
	return self.name
end

function gnode:getPosition()
	return self.x, self.y
end

function gnode:getUnits()
	return self.units
end

function gnode:getLinks()
	return self.links
end

function gnode:getLinkNodes()
	local t = {}
	for _,link in pairs(self.links) do
		if link.n0 == self then
			table.insert( t, link.n1 )
		else
			table.insert( t, link.n0 )
		end
	end
	
	return t
end

function gnode:getTraits()
	return self.traits
end

function gnode:onSpawn( game )
	self.game = game

	if self.traits.isHome then
		self.prop = texprop( "planet.png", 32, game.layer )
	else
		self.prop = texprop( "node.png", 16, game.layer )
	end
    self.prop:setLoc( self.x, self.y )
end

function gnode:addLink( link )
	assert( link )
	
	table.insert( self.links, link )
end

function gnode:addUnit( unit )
	assert( unit )
	table.insert( self.units, unit )
end

function gnode:removeUnit( unit )
	assert( array.find( self.units, unit ))
	array.removeElement( self.units, unit )
end

function gnode:intersects( x, y )
	assert(self.game)

	return mathutil.dist2d( self.x, self.y, x, y ) <= 32
end

function gnode:doPhaseIn()
	log:write("PHASE IN: %s", self:getName())
	self.traits.enemyRate = (self.traits.enemyRate or 0) + 5
	
	self:scheduleUpdate()
end

function gnode:scheduleUpdate()
	if self.timer then
		return -- already updating shit
	end
	
	self.timer = MOAITimer.new()
	self.timer:setMode( MOAITimer.LOOP )
	self.timer:setSpan( 0, 10 )
	self.timer:setListener( MOAITimer.EVENT_TIMER_END_SPAN, function() self:performUpdate() end )
	self.timer:start()
	
end

function gnode:performUpdate()
	log:write("%s updated (+%d enemies)", self:getName(), self.traits.enemyRate)
	self.traits.enemies = (self.traits.enemies or 0) + self.traits.enemyRate
end


function gnode:createIntelData()
	local data =
	{
		enemies = self.traits.enemies,
	}

	return data
end

function gnode:refreshViz( intel )
	local data = intel:find( self ) or {}

	local age = nil
	local enemies = data.enemies or 0
	
	if data == self then
		-- Full intel
		age = 0
	elseif data.tick then
		-- How old is this intel?  Scale from 0 (new) to 1 (maxold, at 2 mins)
		age = (self.game:getTick() - data.tick) * MOAISim.getStep()
	else
		-- No intel
	end

	local c = 1
	if age == nil then
		c = 0.1 -- No intel
	else
		c = (1.0 - math.min(1.0, age / 120)) * 0.9 + 0.1
	end
	if enemies > 0 then
		self.prop:setColor( 1, 0, 0, c )
		local sx = math.max( 1.0, math.min( 3.0, enemies / 80 ))
		self.prop:setScl( sx )
	else
		self.prop:setColor( 1, 1, 1, c )
	end
end

return gnode
