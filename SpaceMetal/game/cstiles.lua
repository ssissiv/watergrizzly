local util = require("modules/util")
local mathutil = require("modules/mathutil")

-------------------------------

local TILE = 0
local TILE_N = 1
local TILE_NW = 2
local TILE_SW = 3
local TILE_S = 4
local TILE_SE = 5
local TILE_NE = 6
local TILE_COUNT = 6

local function getTile( gridx, gridy, ... )
	for i,tile in ipairs({...}) do
		if tile == TILE_N then
			gridx, gridy = gridx, gridy + 2
		elseif tile == TILE_NW then
			gridx, gridy = gridx - (gridy%2), gridy + 1
		elseif tile == TILE_SW then
			gridx, gridy = gridx - (gridy%2), gridy - 1
		elseif tile == TILE_S then
			gridx, gridy = gridx, gridy - 2
		elseif tile == TILE_SE then
			gridx, gridy = gridx + ((1+gridy)%2), gridy - 1
		elseif tile == TILE_NE then
			gridx, gridy = gridx + ((1+gridy)%2), gridy + 1
		end
	end
	
	return gridx, gridy
end

local function getTiles( gridx, gridy, tiledirs )
	local tiles = {}
	for i = 1,#tiledirs do
		local x, y = getTile( gridx, gridy, tiledirs[i])
		tiles[#tiles+1], tiles[#tiles+2] = x, y
	end
	assert(#tiles%2 == 0, string.format("%d tiledirs gave only %d tiles", #tiledirs, #tiles))
	return tiles
end


return
{
	TILE = TILE,
	TILE_N = TILE_N,
	TILE_NW = TILE_NW,
	TILE_SW = TILE_SW,
	TILE_S = TILE_S,
	TILE_SE = TILE_SE,
	TILE_NE = TILE_NE,
	TILE_COUNT = TILE_COUNT,

	getTile = getTile,
	getTiles = getTiles,
}
