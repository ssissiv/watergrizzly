local constants = require "constants"

local options =
{
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
			fn = function( gstate )
				gstate.deck:discard( card_idx )
				gstate:useAction()
				if card_def.on_use then
					card_def.on_use( gstate )
				end
			end
		}
	end
}

return options
