require("modules/class")
require("modules/astar")
require("game/astar_handler")
local util = require("modules/util")
local mathutil = require("modules/mathutil")
local texprop = require("modules/texprop")
local gintel = require("game/gintel")
local gamedefs = require("game/gamedefs")
local orders = require("game/orders")

--------------------------------------------------

local UNITNAMES = { "Jim", "Nabob", "Feryl", "Hal", "Brock", "Brook", "Jorge", "Alex", "Jase" }

--------------------------------------------------

local gunit = class()

function gunit:init( unittype )
	assert( type(unittype) == "number" )
		
	self.node = nil
	self.orders = {}

	if unittype == gamedefs.UNIT_PLAYER then
		self.traits =
			{
				name = "Player",
				icon = "unit_player.png", mapIcon = "map_player.png",
				truesight = true,
				velocity = 100,
				defaultFn = orders.moveTo
			}
	elseif unittype == gamedefs.UNIT_SCOUT then
		self.traits =
			{
				name = "Scout " ..UNITNAMES[ math.random( #UNITNAMES ) ],
				icon = "unit_scout.png", mapIcon = "map_scout.png",
				allied = true,
				velocity = 250,
				cost = { creds = 20 },
				defaultFn = orders.scoutTo,
			}
	elseif unittype == gamedefs.UNIT_TOWER_SCOUT then
		self.traits =
			{
				name = "Tower Scout",
				icon = "unit_scout.png", mapIcon = "map_tower_scout.png",
				allied = true,
				velocity = 250,
				spawnFn = orders.findPlayer,
			}
			
	elseif unittype == gamedefs.UNIT_FIGHTER then
		self.traits =
			{
				name = "Cptn." ..UNITNAMES[ math.random( #UNITNAMES ) ],
				ttname = "<blue>Fighter</>",
				mapIcon = "map_fighter.png",
				velocity = 100,
				allied = true,
				cost = { creds = 500 },
				attack = 10,
				health = 100,
			}
	elseif unittype == gamedefs.UNIT_GUARDTOWER then
		self.traits =
			{
				name = "Guard Tower",
				ttname = "<blue>GuardT.</>",
				mapIcon = "map_guard.png",
				velocity = 1,
				allied = true,
				cost = { creds = 400 },
				attack = 10,
				health = 200,
			}
	elseif unittype == gamedefs.UNIT_WATCHTOWER then
		self.traits =
			{
				name = "Watch Tower",
				ttname = "<blue>WatchT.</>",
				mapIcon = "map_tower.png",
				velocity = 1,
				cost = { creds = 600 },
				allied = true,
				health = 100,
				spawnFn = orders.watch,
			}

	elseif unittype == gamedefs.UNIT_MERC then
		self.traits =
			{
				name = "Merc "..UNITNAMES[ math.random( #UNITNAMES ) ],
				ttname = "<red>Merc</>",
				icon = "", mapIcon = "map_merc.png",
				catchRadius = 20,
				hunt = 60 * 8,
				velocity = 150,
				activity = 10,
				attack = 20,
				health = 40,
				spawnFn = orders.hunt
			}
	elseif unittype == gamedefs.UNIT_MERC2 then
		self.traits =
			{
				name = "MercII "..UNITNAMES[ math.random( #UNITNAMES ) ],
				ttname = "<red>MercII</>",
				icon = "", mapIcon = "map_merc2.png",
				catchRadius = 20,
				hunt = 60 * 4,
				velocity = 200,
				activity = 10,
				attack = 30,
				health = 100,
				spawnFn = orders.hunt
			}
	elseif unittype == gamedefs.UNIT_MERC3 then
		self.traits =
			{
				name = "MercIII "..UNITNAMES[ math.random( #UNITNAMES ) ],
				ttname = "<red>MercIII</>",
				icon = "", mapIcon = "map_merc3.png",
				catchRadius = 20,
				hunt = 60 * 2,
				velocity = 300,
				activity = 15,
				attack = 100,
				health = 400,
				spawnFn = orders.hunt
			}
	end
	
	self.traits.unittype = unittype
end

function gunit:destroy()
	if self.timer then
		self.timer:stop()
		self.timer = nil
	end
	
	self.prop:destroy()
	self.ghost:destroy()
end

function gunit:getName()
	return self.traits.name
end

function gunit:getTraits()
	return self.traits
end

function gunit:getPosition()
	return self.prop:getLoc()
end

function gunit:getIcon()
	return self.traits.icon
end

function gunit:getNode()
	return self.node
end

function gunit:getLastNode()
	return self.lastNode
end

function gunit:onSpawn( game, node, ... )
	self.game = game
	self.intel = gintel( game )
	self.prop = texprop( self.traits.mapIcon, nil, self.game.layer )
	self.prop:setLoc( node:getPosition() )
	self.prop:setColor( 1, 1, 1, 0 )

	self.ghost = texprop( self.traits.mapIcon, nil, self.game.layer )
	self.ghost:setVisible( false )
	
	assert( self.timer == nil )
	self.timer = MOAITimer.new()
	self.timer:setMode( MOAITimer.LOOP )
	self.timer:setSpan( 0, 5 )
	self.timer:setTime( math.random() * 4 )
	self.timer:setListener( MOAITimer.EVENT_TIMER_END_SPAN, function() self:performUpdate() end )
	self.timer:start()

	self:arriveAt( node )

	if self.traits.spawnFn then
		self:issueOrder( self.traits.spawnFn( self.game, self, ... ))
	end
end

function gunit:pause( paused )
	if self.timer then
		self.timer:pause( paused )
	end
	if self.easer then
		self.easer:pause( paused )
	end
end

function gunit:performUpdate()
	if #self.orders > 0 then
		-- First order issued, get going.
		self.orders[1]:process()
	end
end

function gunit:issueDefaultOrder( ... )

	if self.traits.defaultFn then
		self:issueOrder( self.traits.defaultFn( self.game, self, ... ))
	end
end

function gunit:issueOrder( order, queue )

	if not queue then
		while #self.orders > 1 do
			table.remove( self.orders, 2 )
		end
	end
	
	table.insert( self.orders, order )

	if #self.orders == 1 then
		-- First order issued, get going.
		self.orders[1]:process()
	end
end

function gunit:removeOrder( order )
	local idx = util.indexOf( self.orders, order )
	assert(idx)
	
	table.remove( self.orders, idx )
	if idx == 1 and #self.orders > 0 then
		-- removed current order, do next
		self.orders[1]:process()
	end
end


function gunit:arriveAt( targetNode )
	assert( self.node == nil )

	self.node = targetNode
	self.node:addUnit( self )
	
	if self.traits.truesight then
		self.game:getIntel():add( self.node, self.node )
	elseif self.traits.allied then
		self.intel:add( self.node, self.node:createIntelData() )
	end
	
	if self.traits.activity then
		self.node:getTraits().activity = (self.node:getTraits().activity or 0) + self.traits.activity
	end
	
	local playerNode = self.game:findHomeNode()
	if targetNode == playerNode and self.traits.allied then
		self.game:getIntel():merge( self.intel )
	end

	-- weird combat shit
	if self:getTraits().health then
		local target
		for _,unit in pairs(self.node:getUnits()) do
			if unit ~= self and unit:getTraits().allied ~= self:getTraits().allied and unit:getTraits().attack then
				self:damage( unit:getTraits().attack )
				if unit:getTraits().health then
					target = unit
				end
			end
		end
		if target and self:getTraits().attack then
			target:damage( self:getTraits().attack )
		end
	end
	
	if #self.orders > 0 then
		self.orders[1]:process()
	end

	self.game:dispatchEvent( gamedefs.EV_UNIT_ARRIVED )
end

function gunit:damage( dmg )
	log:write("DMG %s (%d)", self:getName(), dmg )
	self:getTraits().health = self:getTraits().health - dmg
	if self:getTraits().health <= 0 then
		self.game:despawnUnit( self )
	end
end

function gunit:departFrom()
	assert( self.node )

	if self.traits.truesight then
		self.game:getIntel():rmv( self.node )
		self.game:getIntel():add( self.node, self.node:createIntelData() )
	end

	self.node:removeUnit( self )
	self.lastNode = self.node
	self.node = nil
	
	self.game:dispatchEvent( gamedefs.EV_UNIT_LEFT )
end

function gunit:travelTo( targetNode )
	assert( self.node )
	
	local x0, y0 = self.node:getPosition()
	local x1, y1 = targetNode:getPosition()
	local dist = mathutil.dist2d( x0, y0, x1, y1 )
	
	self.easer = self.prop:seekLoc( x1, y1, dist / self.traits.velocity, MOAIEaseType.LINEAR )
	self.easer:setListener ( MOAIAction.EVENT_STOP,
		function()
			self.easer = nil
			self:arriveAt( targetNode )
		end )

	self:departFrom()
end


function gunit:refreshViz()

	if not self.game:getIntel():isOmniscient() then
		local playerUnit = self.game:findPlayer()
		local x0, y0 = playerUnit.prop:getLoc()
		local dist = mathutil.dist2d( x0, y0, self.prop:getLoc() )
		
		local a = 1.0 - math.min(1.0, dist / 200)
		self.prop:setColor( 1, 1, 1, a )
	else
		self.prop:setColor( 1, 1, 1, 1 )
	end
end

return gunit