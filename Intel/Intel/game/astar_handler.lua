-- 
--  tiledAStarHandler.lua
--  lua-astar
--  
--  Created by Jay Roberts on 2011-01-12.
--  Copyright 2011 GloryFish.org. All rights reserved.
-- 


require("modules/class")
local mathutil = require("modules/mathutil")

AStarHandler = class('AStarHandler')

function AStarHandler:init( game )
	self.game = game
end

function AStarHandler:getNode( cell )

	if cell then
		return Node(cell, 0, cell)
	end
end


function AStarHandler:getAdjacentNodes( cur_node, goal_cell )
	-- Given a node, return a table containing all adjacent nodes
	local result = {}	
	local cell = cur_node.location
  
	local n = nil

	for _,adjnode in pairs(cell:getLinkNodes()) do
		n = self:_handleNode( adjnode, cur_node, goal_cell )
		if n then
			table.insert(result, n)
		end
	end
		
	return result
end

function AStarHandler:locationsAreEqual(a, b)
	return a == b
end

function AStarHandler:_handleNode(to_cell, from_node, goal_cell)
	-- Fetch a Node for the given location and set its parameters
	local n = self:getNode(to_cell)
  
	if n ~= nil then
		local x0, y0 = from_node.location:getPosition()
		local x1, y1 = to_cell:getPosition()
		local xf, yf = goal_cell:getPosition()
		local emCost = mathutil.dist2d( x1, y1, xf, yf )
		local dc = mathutil.dist2d( x0, y0, x1, y1 )

		--print("handle", to_cell:getName(), x0, y0, xf, yf, emCost, dc )

		n.mCost = from_node.mCost + dc
		n.score = n.mCost + emCost
		n.parent = from_node
    
		return n
	end
  
	return nil
end
