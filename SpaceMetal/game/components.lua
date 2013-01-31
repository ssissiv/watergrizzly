require("modules/class")
require("modules/astar")
require("game/astar_handler")
local util = require("modules/util")
local mathutil = require("modules/mathutil")
local texprop = require("modules/texprop")
local gamedefs = require("game/gamedefs")
local cstiles = require("game/cstiles")
local powergrid = require("game/powergrid")

--------------------------------------------------

local function validateEmptyTiles( ship, tiles )
	for i = 1,#tiles,2 do
		local gridx, gridy = tiles[i], tiles[i+1]
		if ship:getComponent( gridx, gridy ) ~= nil then
			return false
		end
	end
	
	return true
end

local function validateConnectedTiles( ship, tiles )
	for i = 1,#tiles,2 do
		local x, y = tiles[i], tiles[i+1]
		for i = 1,cstiles.TILE_COUNT do
			if ship:getComponent( cstiles.getTile( x, y, i ) ) ~= nil then
				return true
			end
		end
	end
	
	return false
end
--------------------------------------------------

local base_comp = class()

function base_comp:init()
end

function base_comp:canSet( ship, gridx, gridy )
	local tiles = cstiles.getTiles( gridx, gridy, self.tiles )
	
	if not validateEmptyTiles( ship, tiles ) then
		return false -- A tile already occupied
	end

	if ship:getComponent( 0, 0 ) ~= nil then
		if not validateConnectedTiles( ship, tiles ) then
			return false -- No connectors
		end
	else
		return gridx == 0 and gridy == 0 -- First component must be at origin
	end

	return true
end

function base_comp:onSpawn( ship, gridx, gridy )
	local x, y = ship.grid:getTileLoc( gridx, gridy, MOAIGridSpace.TILE_BOTTOM_CENTER )
	x, y = ship.gridProp:worldToModel( x, y )

	local prop = texprop( self.texfile, nil, ship.game.layer )
	prop:setParent( ship:getProp() )
	prop:setLoc( x, y )

	self.ship = ship
	self.viz = prop
	self.gridx, self.gridy = gridx, gridy
	
	return cstiles.getTiles( gridx, gridy, self.tiles )
end


--------------------------------------------------

local hull0_comp = class( base_comp )

hull0_comp.texfile = "components/hull0.png"
hull0_comp.traits = { hull = 1 }
hull0_comp.tiles = { cstiles.TILE }

function hull0_comp:init()
	base_comp.init( self )
end

--------------------------------------------------

local conduit0_comp = class( base_comp )

conduit0_comp.texfile = "components/conduit0.png"
conduit0_comp.traits = { pcap = 30, pdrain = 5, hull = 1 }
conduit0_comp.tiles = { cstiles.TILE }

function conduit0_comp:init()
	base_comp.init( self )
	
	self.ptrans = 0
end

function conduit0_comp:onSpawn( ship, gridx, gridy )
	ship:addUpdater( 20, self )
	return base_comp.onSpawn( self, ship, gridx, gridy )
end

function conduit0_comp:powerTransfer( p )
	self.ptrans = self.ptrans + p
	self.pfactor = 1 - (self.ptrans / self.traits.pcap)
end

function conduit0_comp:shipUpdate( ship )
	self.ptrans = math.max( 0, self.ptrans - self.traits.pdrain )
	self.pfactor = 1 - (self.ptrans / self.traits.pcap)
end

--------------------------------------------------

local power0_comp = class( base_comp )

power0_comp.texfile = "components/power0.png"
power0_comp.traits = { pcap = 100, pregen = 10 }
power0_comp.tiles = { cstiles.TILE, cstiles.TILE_NE, cstiles.TILE_SE, cstiles.TILE_NW, cstiles.TILE_SW }

function power0_comp:init()
	base_comp.init( self )
	
	self.psource = self.traits.pcap
end

function power0_comp:onSpawn( ship, gridx, gridy )
	ship:addUpdater( 60, self )
	return base_comp.onSpawn( self, ship, gridx, gridy )
end

function power0_comp:powerTransfer( p )
	assert( self.psource > p )
	self.psource = self.psource - p
	self.pfactor = self.psource / self.traits.pcap
end

function power0_comp:shipUpdate( ship )
	self.psource = math.min( self.traits.pcap, self.psource + self.traits.pregen )
	self.pfactor = self.psource / self.traits.pcap
end

--------------------------------------------------

local thruster0_comp = class( base_comp )

thruster0_comp.texfile = "components/thruster0.png"
thruster0_comp.traits = { psink = 15 }
thruster0_comp.tiles = { cstiles.TILE, cstiles.TILE_S }

function thruster0_comp:init()
	base_comp.init( self )
end

function thruster0_comp:onSpawn( ship, gridx, gridy )
	ship:addUpdater( 60, self )
	return base_comp.onSpawn( self, ship, gridx, gridy )
end

function thruster0_comp:shipUpdate( ship )
	local plinks = powergrid.findPower( ship, self.traits.psink, self.gridx, self.gridy )
	if plinks then
		for i = 1,#plinks,2 do
			local gridx, gridy = plinks[i], plinks[i+1]
			local component = ship:getComponent( gridx, gridy )
			component:powerTransfer( self.traits.psink )
		end
		self.pfactor = 1
	else
		print("NO THRUST!")
		self.pfactor = 0
	end
end

--------------------------------------------------

return
{
	all = { hull0_comp, conduit0_comp, power0_comp, thruster0_comp }
}
