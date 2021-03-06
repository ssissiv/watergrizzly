local constants = require "constants"
local option_def = require "option_def"

local ADJS = { "Light", "Dark", "Forbidden", "Mystical", "Dreary", "Far", "Cold",
	"Ominous", "Mysterious", "Great", "Hidden", "Well-Traveled", "Gray", "Red", "Overgrown",
	"Dim", "Ancient", "Long", "Quiet" }

local NOUNS = { "Woods", "Forest", "Road", "Trail", "Marshlands", "Swamp", "Plains", "Fields",
	"Foothills", "Mountains", "Footpaths", "Shores", "Taiga" }

local SYB1 = { "we", "qui", "axa", "tu", "meed", "va", "ba", "del", "shar", "che", "bu", "men", "la", "pa", "pren", "se", "shi" }

local function procroom()
	return { name = string.format( "The %s %s", table.arraypick(ADJS), table.arraypick(NOUNS)),
			desc = "Description", options = {}, things = {} }
end

local function proccity( room )
	local cityname = ""
	for i = 1, math.random( 2, 4 ) do
		cityname = cityname .. table.arraypick( SYB1 )
	end
	cityname = cityname:sub(1,1):upper() .. cityname:sub( 2 )

	room.name = string.format( "The %s City of %s", table.arraypick(ADJS), cityname )
	room.desc = "A bustling city!"
	room.options = { option_def.convert( math.random(2,5) * 5) }
end

local function worldgen()
	local proc_rooms = {}

	local function islinked( i, ii )
		for j, opt in ipairs( proc_rooms[i].options ) do
			if opt.to == ii then
				return true
			end
		end
		return false
	end
	local function link( i, j )
		table.insert( proc_rooms[i].options,
			option_def.travel( string.format( "Travel to %s", proc_rooms[ j ].name ), j ))
		table.insert( proc_rooms[j].options,
			option_def.travel( string.format( "Travel to %s", proc_rooms[ i ].name ), i ))
	end

	-- Make a graph
	for i = 1, 50 do
		local x, y = math.random( 10, 500 ), math.random( 10, 500 )
		local proc_room = procroom()
		proc_room.mapx, proc_room.mapy = x, y
		proc_room.key = #proc_rooms + 1
		table.insert( proc_rooms, proc_room )
	end

	-- Pick 5 cities
	local left = util.shallowcopy( proc_rooms )	
	for i = 1, 5 do
		local room = table.remove( left, math.random( #left ))
		proccity( room )
	end
	-- Pick 20 monsters
	for i = 1, 20 do
		local room = proc_rooms[ math.random( #proc_rooms ) ]		
		table.insert( room.things, option_def.monster( "Ogre", 3, 3, 3 ))
	end		

	-- cull
	local left = util.shallowcopy(proc_rooms)
	local tree = { table.remove( left ) }
	while #left > 0 do
		local room = table.remove( left )
		local mindist, minroom = math.huge
		for i, to in ipairs( tree ) do
			local dist = distance( room.mapx, room.mapy, to.mapx, to.mapy )
			if dist < mindist then
				mindist, minroom = dist, to
			end
		end
		-- connect to minroom.
		link( room.key, minroom.key )
		table.insert( tree, room )
	end

	return proc_rooms
end

rooms = worldgen()

local function validate( rooms )
	for k, room in pairs(rooms) do
		for i, opt in ipairs( room.options ) do
			assert( type(opt) == "table" )
			assert( opt.to == nil or rooms[ opt.to ], string.format( "Bad option: %s (%s)", tostring(opt.to), k ))
		end
	end
end
validate( rooms )

return
{
	start_room = next( rooms ),
	rooms = rooms,
}

