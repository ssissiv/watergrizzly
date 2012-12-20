require("modules/class")
require("modules/astar")
require("game/astar_handler")
local mathutil = require("modules/mathutil")
local texprop = require("modules/texprop")
local gintel = require("game/gintel")
local gamedefs = require("game/gamedefs")

--------------------------------------------------

local UNITNAMES = { "Jim", "Nabob", "Feryl", "Hal", "Brock", "Brook", "Jorge", "Alex", "Jase" }
local UNIT_VELOCITY = 100

--------------------------------------------------

local gunit = class()

function gunit:init()
	self.name = UNITNAMES[ math.random( #UNITNAMES ) ]
	self.node = nil
	self.orders = {}
end

function gunit:getName()
	return self.name
end

function gunit:getIcon()
	return "unit_scout.png"
end

function gunit:onSpawn( game, node )
	self.game = game
	self.node = node
	self.intel = gintel( game )
	self.prop = texprop( "map_scout.png", 8, self.game.layer )
	self.prop:setLoc( node:getPosition() )
end

function gunit:issueOrder( node )

	local order = { targetNode = node }
	
	table.insert( self.orders, order )

	if #self.orders == 1 then
		-- First order issued, get going.
		self:processOrders()
	end
end

function gunit:processOrders()
	
	assert( #self.orders > 0 )

	local order = self.orders[1]

	local res = true
	if order.targetNode then
		res = self:processMoveOrder( order )
	end
	
	if res then
		table.remove( self.orders, 1 )
		-- Process next immediately
		if #self.orders > 0 then
			self:processOrders()
		end
	end
end

function gunit:processMoveOrder( order )

	if order.targetNode ~= self.node then
		local astar = AStar(AStarHandler( self.game ))
		local path = astar:findPath( self.node, order.targetNode )
		local cost = -1
		if path then	
			local nextTarget = path:getNodes()[1].location

			--log:write("--- PATHFIND %s -> %s : Cost: %.2f (%d jumps, next: %s) --------",
			--	self.node:getName(), order.targetNode:getName(), path:getTotalMoveCost(), #path:getNodes(), nextTarget:getName() )

			self:travelTo( nextTarget )
			return false
		end
	end

	-- Completed order
	return true
end

function gunit:arriveAt( targetNode )
	assert( self.node == nil )

	self.node = targetNode
	self.node:addUnit( self )
	
	self.intel:add( self.node,
		{
			enemies = self.node.enemies
		})
	
	if targetNode == self.game:findHomeNode() then
		self.game:getIntel():merge( self.intel )
	end

	self.game:dispatchEvent( gamedefs.EV_UNIT_ARRIVED )
end

function gunit:travelTo( targetNode )
	assert( self.node )
	
	local x0, y0 = self.node:getPosition()
	local x1, y1 = targetNode:getPosition()
	local dist = mathutil.dist2d( x0, y0, x1, y1 )
	
	self.easer = self.prop:seekLoc( x1, y1, dist / UNIT_VELOCITY, MOAIEaseType.LINEAR )
	self.easer:setListener ( MOAIAction.EVENT_STOP,
		function()
			self.easer = nil
			self:arriveAt( targetNode )
			self:processOrders()
		end )

	self.node:removeUnit( self )
	self.node = nil
	
	self.game:dispatchEvent( gamedefs.EV_UNIT_LEFT )
end


function gunit:refreshViz()

	local node = self.game:findHomeNode()
	local x0, y0 = node:getPosition()
	local dist = mathutil.dist2d( x0, y0, self.prop:getLoc() )
	
	local a = 1.0 - math.min(1.0, dist / 100)
	self.prop:setColor( 1, 1, 1, a )
end

return gunit