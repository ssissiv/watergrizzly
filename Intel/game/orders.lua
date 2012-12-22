require("modules/class")
require("modules/astar")
require("game/astar_handler")
local util = require("modules/util")
local mathutil = require("modules/mathutil")
local gintel = require("game/gintel")
local gamedefs = require("game/gamedefs")
local indicator = require("game/indicator")

--------------------------------------------------

local moveTo = class()

function moveTo:init( game, unit, targetNode, maxMove )
	self.game = game
	self.unit = unit
	self.targetNode = targetNode
	self.maxMove = maxMove

	self.fx = indicator( self.game, "fx_move.png", targetNode:getPosition() )
end

function moveTo:process()

	if self.unit:getNode() == nil then
		return
	end
	
	if self.unit == self.game:findPlayer() then
		if not self.game:hasResources( { fuel = 1 } ) then
			self.unit:removeOrder( self )
			return
		else
			self.game:useResources( { fuel = 1 } )
		end
	end
			
	if (self.maxMove == nil or self.maxMove > 0) and self.targetNode ~= self.unit:getNode() then
		local astar = AStar(AStarHandler( self.game ))
		local path = astar:findPath( self.unit:getNode(), self.targetNode )
		if path then	
			local nextTarget = path:getNodes()[1].location

			--log:write("--- PATHFIND %s -> %s : Cost: %.2f (%d jumps, next: %s) --------",
			--	self.node:getName(), order.targetNode:getName(), path:getTotalMoveCost(), #path:getNodes(), nextTarget:getName() )
			self.unit:travelTo( nextTarget )
			if self.maxMove then
				self.maxMove = self.maxMove - 1
			end
		end
	else
		-- Completed order
		self.unit:removeOrder( self )
	end
end

--------------------------------------------------

local scoutTo = class()

function scoutTo:init( game, unit, targetNode )
	self.game = game
	self.unit = unit
	self.targetNode = targetNode

	self.fx = indicator( self.game, "fx_move.png", targetNode:getPosition() )
end

function scoutTo:process()

	if self.unit:getNode() == nil then
		return
	end

	local playerUnit = self.game:findPlayer()
	local targetNode = self.targetNode or self.game:findHomeNode() or playerUnit:getLastNode()
	
	if targetNode and targetNode ~= self.unit:getNode() then
		local astar = AStar(AStarHandler( self.game ))
		local path = astar:findPath( self.unit:getNode(), targetNode )
		if path then	
			local nextTarget = path:getNodes()[1].location

			--log:write("--- PATHFIND %s -> %s : Cost: %.2f (%d jumps, next: %s) --------",
			--	self.node:getName(), order.targetNode:getName(), path:getTotalMoveCost(), #path:getNodes(), nextTarget:getName() )

			self.unit:travelTo( nextTarget )
		end
	elseif self.targetNode then
		self.targetNode = nil
		self:process() -- initiate scout back home
	elseif targetNode == playerUnit:getNode() then
		-- Completed order
		self.unit:removeOrder( self )
		self.game:despawnUnit( self.unit )
	end
end

--------------------------------------------------

local hunt = class()

function hunt:init( game, unit, delay )
	self.game = game
	self.unit = unit
	self.delay = delay or (60 * 8)
end

function hunt:process()

	if self.unit:getNode() == nil then
		return
	end

	if self.targetNode == self.unit:getNode() then
		-- arrived! wait some time
		self.tick = self.game:getTick() + self.delay
		self.targetNode = nil
		return
	end
		
	if self.tick and self.tick > self.game:getTick() then
		-- still waiting
		return
	end
	
	local linkNodes = self.unit:getNode():getLinkNodes()
	local lastNode = self.unit:getLastNode()
	local nextIdx = math.random( #linkNodes )
	while linkNodes[nextIdx] == lastNode do
		if math.random( #linkNodes ) == 1 then
			break
		else
			nextIdx = math.random( #linkNodes )
		end
	end
	local targetNode = linkNodes[ math.random( #linkNodes ) ]
	
	if targetNode and targetNode ~= self.unit:getNode() then
		local astar = AStar(AStarHandler( self.game ))
		local path = astar:findPath( self.unit:getNode(), targetNode )
		if path then	
			self.targetNode = path:getNodes()[1].location

			--log:write("--- PATHFIND %s -> %s : Cost: %.2f (%d jumps, next: %s) --------",
			--	self.node:getName(), order.targetNode:getName(), path:getTotalMoveCost(), #path:getNodes(), nextTarget:getName() )

			self.unit:travelTo( self.targetNode )
		end
	end
end

--------------------------------------------------

local findPlayer = class()

function findPlayer:init( game, unit )
	self.game = game
	self.unit = unit
	self.delay = unit:getTraits().delay or 0
end

function findPlayer:process()

	if self.unit:getNode() == nil then
		return
	end
	
	if self.travelling then
		-- arrived! wait some time
		self.tick = self.game:getTick() + self.delay
		self.travelling = false
		return
	end
		
	if self.tick and self.tick > self.game:getTick() then
		-- still waiting
		return
	end
	
	local playerUnit = self.game:findPlayer() 
	local targetNode = playerUnit:getNode() or playerUnit:getLastNode()
	
	if targetNode ~= self.unit:getNode() then
		local astar = AStar(AStarHandler( self.game ))
		local path = astar:findPath( self.unit:getNode(), targetNode )
		if path then	
			local nextTarget = path:getNodes()[1].location

			--log:write("--- PATHFIND %s -> %s : Cost: %.2f (%d jumps, next: %s) --------",
			--	self.node:getName(), order.targetNode:getName(), path:getTotalMoveCost(), #path:getNodes(), nextTarget:getName() )

			self.unit:travelTo( nextTarget )
			self.travelling = true
		end
	elseif targetNode == playerUnit:getNode() then
		-- Completed order
		self.unit:removeOrder( self )
		self.game:despawnUnit( self.unit )
	end
end

--------------------------------------------------

local watch = class()

function watch:init( game, unit )
	self.game = game
	self.unit = unit
	self.tick = self.game:getTick() + 60 * 5
end

function watch:process()

	if self.tick and self.tick > self.game:getTick() then
		-- still waiting
		return
	else
		-- spawn a scout
		local gunit = require("game/gunit")
		local unit = gunit( gamedefs.UNIT_TOWER_SCOUT )
		self.game:spawnUnit( unit, self.unit:getNode() )
		self.tick = self.game:getTick() + 60 * 5
	end
end
--------------------------------------------------

return
{
	moveTo = moveTo,
	scoutTo = scoutTo,
	hunt = hunt,
	watch = watch,
	findPlayer = findPlayer,
}
