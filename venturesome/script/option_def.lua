local constants = require "constants"

local options =
{
	back = { desc = "Back", pop = true },

	camp = { desc = "Camp", push = "modal_camp" },

	map = { desc = "View map", push = "modal_map" },

	packup = { desc = "Pack Up" },

	game_over = { desc = "Game Over", cmd = "restart" },

	restart = { desc = "Restart", cmd = "restart" },

	actionCard = function( card_def, card_idx )
		return
		{
			desc = string.format( "%s (%s)", card_def.name, card_def.desc ),
			resources = { [ constants.RESOURCE.ACTION ] = 1 },
			fn = function( self, gstate )
				gstate.deck:discard( card_idx )
				gstate:useAction()
				if card_def.on_use then
					card_def.on_use( gstate )
				end
			end
		}
	end,

	travel = function( desc, to )
		return { desc = desc, to = to, resources = { [ constants.RESOURCE.ACTION ] = 1 }}
	end,

	convert = function( amt )
		return
		{
			desc = "Convert this city to your control",
			resources = { [ constants.RESOURCE.PRESTIGE ] = amt },
			fn = function( self, gstate )
				gstate.room.converted = true
			end
		}
	end,

	monster = function( name, str, wis, agi )
		return
		{
			name = name,
			desc = string.format( "A %s is here wandering around, wreaking havoc.", name ),
			fn = function( self, gstate )
				local modal_combat = require "modal_combat"
				gstate:push( modal_combat.new( self, gstate )	)
			end,
			tick = function( self, gstate )
				
				print( self.name, " ticked at ", self.room.name )
			end,
		}
	end
}

return options
