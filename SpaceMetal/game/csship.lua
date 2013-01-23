require("modules/class")
require("modules/astar")
require("game/astar_handler")
local util = require("modules/util")
local mathutil = require("modules/mathutil")
local texprop = require("modules/texprop")
local gamedefs = require("game/gamedefs")

--------------------------------------------------

local csship = class()

function csship:init( name )
	self.name = name
end

function csship:destroy()
	self.prop:destroy()
	if self.gridProp then
		self.game.layer:removeProp( self.gridProp )
		self.gridProp = nil
		self.grid = nil
	end
end

function csship:getName()
	return self.name
end

function csship:getPosition()
	return self.prop:getLoc()
end

function csship:onSpawn( game )
	self.game = game

	self.prop = texprop( "map_player.png", nil, self.game.layer )
	self.prop:setLoc( 0, 0 )
end

function csship:worldToGrid( x, y )
	print("world ", x, y)
	x, y = self.gridProp:worldToModel( x, y )
	print("model", x, y)
	return self.grid:locToCoord( x, y )
end

function csship:showEditGrid()
	if self.gridProp == nil then
		print("MAKE GRID" )
		local grid = MOAIGrid.new ()
		grid:initHexGrid ( 2, 2, 64 )
		grid:setRepeat ( true )
		for i = 1,2 do
			grid:setRow( i, 1, 1 )
		end
		
		local tileDeck = MOAITileDeck2D.new ()
		tileDeck:setTexture ( "data/hex-tiles.png" )
		tileDeck:setSize ( 4, 4, 0.25, 0.216796875 )

		local prop = MOAIProp2D.new ()
		prop:setDeck ( tileDeck )
		prop:setGrid ( grid )
		prop:forceUpdate ()
		prop:setAttrLink(MOAIProp.INHERIT_LOC, self.prop, MOAIProp.TRANSFORM_TRAIT)
		local x, y = grid:getTileLoc( 0, 0 )
		prop:setLoc( -x, -y )

		self.game.layer:insertProp ( prop )
		self.grid = grid
		self.gridProp = prop
	end
end

function csship:hideEditGrid()
	self.game.layer:removeProp( self.gridProp )
	self.gridProp = nil
end

function csship:refreshViz()
end

return csship