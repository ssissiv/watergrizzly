require("modules/class")
require("modules/astar")
require("game/astar_handler")
local binops = require("modules/binary_ops")
local util = require("modules/util")
local mathutil = require("modules/mathutil")
local texprop = require("modules/texprop")
local gamedefs = require("game/gamedefs")

-------------------------------

local function createEditGrid( parent )
	parent:forceUpdate()
	
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
	prop:setAttrLink(MOAIProp.INHERIT_LOC, parent, MOAIProp.TRANSFORM_TRAIT)
	local x, y = grid:getTileLoc( 0, 0 )
	prop:setLoc( -x, -y )

	return grid, prop
end

local function getGridID( gridx, gridy )
	return gridx * 10000 + gridy
end

-------------------------------

local csship = class()

function csship:init( name )
	self.name = name
	self.components = {}
	self.updaters = {}
end

function csship:destroy()
	self.prop:destroy()
	self:hidePowerGrid()

	self.game.layer:removeProp( self.gridProp )
	self.gridProp = nil
	self.grid = nil
end

function csship:getName()
	return self.name
end

function csship:getPosition()
	return self.prop:getLoc()
end

function csship:getProp()
	return self.prop
end

function csship:onSpawn( game )
	assert( self.game == nil )
	
	self.game = game

	self.prop = texprop( "map_player.png", nil, self.game.layer )
	self.prop:setLoc( 0, 0 )

	self.grid, self.gridProp = createEditGrid( self.prop.prop )
	self.game.layer:insertProp( self.gridProp )
	self.gridProp:setVisible( false )
end

function csship:setComponent( component, gridx, gridy )

	local tiles = component:onSpawn( self, gridx, gridy )
	for i = 1,#tiles,2 do
		local gridID = getGridID(tiles[i], tiles[i+1])
		self.components[ gridID ] = component
	end
end

function csship:canSetComponent( component, gridx, gridy )
	local gridID = getGridID( gridx, gridy )
	return self.components[ gridID ] == nil and component:canSet( self, gridx, gridy )
end

function csship:getComponent( gridx, gridy )
	local gridID = getGridID( gridx, gridy )
	return self.components[ gridID ]
end


function csship:addUpdater( tick, obj )
	assert( obj.shipUpdate )
	table.insert( self.updaters, { tick = tick, obj = obj } )
end

function csship:shipUpdate( tick)
	for _,update in pairs(self.updaters) do
		if tick % update.tick == 0 then
			update.obj:shipUpdate( self )
		end
	end
end

function csship:worldToGrid( x, y )
	if self.gridProp then
		x, y = self.gridProp:worldToModel( x, y )
		return self.grid:locToCoord( x, y )
	end
end

function csship:gridToWorld( gridx, gridy )
	if self.gridProp then
		local x, y = self.grid:getTileLoc( gridx, gridy )
		x, y = self.gridProp:modelToWorld( x, y )
		return x, y
	end
end

function csship:togglePowerGrid()
	if self.powerProp then
		self:hidePowerGrid()
	else
		self:showPowerGrid()
	end
end

function csship:showPowerGrid()
	if self.powerProp == nil then
		local scriptDeck = MOAIScriptDeck.new ()
		scriptDeck:setRect ( -512, -512, 512, 512 ) -- FIXME
		scriptDeck:setDrawCallback ( 
			function( index, xOff, yOff, xFlip, yFlip )
						
				for gridID, component in pairs(self.components) do
					if component.pfactor then
						local x, y = self:gridToWorld( component.gridx, component.gridy )
						MOAIGfxDevice.setPenColor ( 0.4, 0.4, 1.0, 0.5 )
						MOAIDraw.drawCircle( x, y, 32, 16 )
						MOAIDraw.fillCircle( x, y, 32 * component.pfactor, 16 )
						MOAIGfxDevice.setPenColor ( 0, 0, 0 )
						MOAIDraw.drawCircle( x, y, 32 * component.pfactor, 16 )
					end
				end
			end )
		
		local prop = MOAIProp2D.new ()
		prop:setDeck ( scriptDeck )

		self.game.layer:insertProp ( prop )
		self.powerProp = prop
	end

end

function csship:hidePowerGrid()
	self.game.layer:removeProp( self.powerProp )
	self.powerProp = nil
end

function csship:showEditGrid()
	self.gridProp:setVisible( true )
end

function csship:hideEditGrid()
	self.gridProp:setVisible( false )
end

function csship:refreshViz()
end

return csship