require "game/entities/entity"
require "game/entities/entity_ext"
require "game/entities/creature"
require "game/entities/fieldling"

---------------------------------------------------------------------------

local function ValidateEntity( class )
	local id = class._classname
end

local function AccumulateEntities( class, t )
	for i, subclass in ipairs( class._subclasses ) do
		if #subclass._subclasses > 0 then
			AccumulateEntities( subclass, t )
		else
			ValidateEntity( subclass )
			table.insert( t, subclass )
		end
	end
end

ALL_ENTITIES = {}
AccumulateEntities( Entity, ALL_ENTITIES )
