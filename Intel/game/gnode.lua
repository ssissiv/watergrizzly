require("modules/class")
local array = require("modules/array")
local texprop = require("modules/texprop")
local mathutil = require("modules/mathutil")
local gamedefs = require("game/gamedefs")
local gunit = require("game/gunit")

------------------------------------------------------

local ACTIVITY_FADE = 2

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
	if self.timer then
		self.timer:stop()
		self.timer = nil
	end
	
	if self.fuelProp then
		self.fuelProp:destroy()
		self.fuelProp = nil
	end
	
	if self.credsProp then
		self.credsProp:destroy()
		self.credsProp = nil
	end
	
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

	local i = math.random(25)
	if self.traits.isHome then
		self.prop = texprop( "planet.png", 32, game.layer )
	elseif MOAIFileSystem.checkFileExists( "data/node"..i..".png" ) then
		self.prop = texprop( "node"..i..".png", nil, game.layer )
		local sx = math.random() / 5 + 0.5
		self.prop:setScl(sx)
	else
		self.prop = texprop( "node.png", nil, game.layer )
	end
    self.prop:setLoc( self.x, self.y )
	
	self:scheduleUpdate()
end

function gnode:addLink( link )
	assert( link )
	
	table.insert( self.links, link )
end

function gnode:addUnit( unit )
	assert( unit and array.find( self.units, unit ) == nil )
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
	self.traits.enemyRate = (self.traits.enemyRate or 0) + 5
	
	local m = math.random( self.game:getTick() + 1 )
	local unit
	if m < 60 * 100 then
		unit = gunit( gamedefs.UNIT_MERC )
	elseif m < 60 * 200 then
		unit = gunit( gamedefs.UNIT_MERC2 )
	else
		unit = gunit( gamedefs.UNIT_MERC3 )
	end

	self.game:spawnUnit( unit, self )
	log:write("\tPhase %s", unit:getName())
end

function gnode:tallyActivity()
	local activity = self:getTraits().activity or 0
	for i,unit in pairs(self.units) do
		activity = activity + (unit:getTraits().activity or 0)
	end
	return activity
end

function gnode:scheduleUpdate()
	assert(self.timer == nil)
	
	self.timer = MOAITimer.new()
	self.timer:setMode( MOAITimer.LOOP )
	self.timer:setSpan( 0, 5 )
	self.timer:setTime( math.random() * 5 )
	self.timer:setListener( MOAITimer.EVENT_TIMER_END_SPAN, function() self:performUpdate() end )
	self.timer:start()
	
end

function gnode:performUpdate()
	if (self.traits.creds and self.traits.creds > 0) or (self.traits.fuel and self.traits.fuel > 0) then
		local playerUnit = self.game:findPlayer()
		if playerUnit:getNode() == self then
			self.game:addResource( "creds", self.traits.creds or 0 )
			self.game:addResource( "fuel", self.traits.fuel or 0 )
			self.game:dispatchEvent( gamedefs.EV_UPDATE_RESOURCES, { self.traits.creds, self.traits.fuel } )
			self.traits.creds, self.traits.fuel = 0, 0
		end
	end
	
	if math.random() < 0.05 then
		local creds = self:getTraits().creds or 0
		self:getTraits().creds = 10 + creds + math.random( 40 )
	end
	if math.random() < 0.02 then
		local fuel = self:getTraits().fuel or 0
		if fuel < 8 then
			self:getTraits().fuel = fuel + math.random( 1, 8 )
		end
	end
	
	if self.traits.activity then
		self.traits.activity = self.traits.activity - ACTIVITY_FADE
		if self.traits.activity <= 0 then
			self.traits.activity = nil
		end
	end
end


function gnode:pause( paused )
	if self.timer then
		self.timer:pause( paused )
	end
end

function gnode:createIntelData()
	local data =
	{
		name = self.name,
		activity = self:tallyActivity(),
		creds = self.traits.creds,
		fuel = self.traits.fuel,
		tick = self.game:getTick(),
	}
	
	if #self.units > 0 then
		for _,unit in pairs(self.units) do
			if unit:getTraits().ttname then
				if data.units == nil then data.units = {} end
				local name = unit:getTraits().ttname
				if unit:getTraits().health then
					name = string.format("(%d)", unit:getTraits().health)
				end
				table.insert(data.units, name)
			end
		end
	end

	return data
end

function gnode:refreshViz( intel )
	local data = intel:find( self )

	local age = nil
	
	if data == nil then
		-- No intel
	elseif data.tick == nil then
		-- Full intel
		age = 0
	else
		-- How old is this intel?  Scale from 0 (new) to 1 (maxold, at 2 mins)
		age = (self.game:getTick() - data.tick) * MOAISim.getStep()
	end

	local c = 1
	if age == nil then
		c = 0.1 -- No intel
	else
		c = (1.0 - math.min(1.0, age / 60)) * 0.9 + 0.1
	end
	if data and data.activity > 0 then
		self.prop:setColor( 1, 0, 0, c )
		local sx = math.max( 1.0, math.min( 3.0, data.activity / 30 ))
		self.prop:setScl( sx )
	else
		self.prop:setColor( 1, 1, 1, c )
	end
	
	if data and (data.creds or 0) > 0 then
		if self.credsProp == nil then
			self.credsProp = texprop( "map_creds.png", nil, self.game.layer )
		end
		local x, y = self:getPosition()
		self.credsProp:setLoc( x - 20, y + 30 )
		self.credsProp:setColor( 1, 1, 1, c )
		self.credsProp:setVisible(true)
	elseif self.credsProp then
		self.credsProp:setVisible(false)
	end
	if data and (data.fuel or 0) > 0 then
		if self.fuelProp == nil then
			self.fuelProp = texprop( "map_fuel.png", nil, self.game.layer )
		end
		local x, y = self:getPosition()
		self.fuelProp:setLoc( x + 10, y + 30 )
		self.fuelProp:setColor( 1, 1, 1, c )
		self.fuelProp:setVisible(true)
	elseif self.fuelProp then
		self.fuelProp:setVisible(false)
	end
end

return gnode
