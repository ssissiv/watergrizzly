local function getGridID( gridx, gridy )
	return gridx * 10000 + gridy
end

local function getGrid( gridID )
	return ( gridID / 10000 ), gridID % 10000
end

local x = getGridID( 2,  -1 )
print(x, getGrid( x ))

