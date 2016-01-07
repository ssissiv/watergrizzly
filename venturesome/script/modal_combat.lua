local constants = require "constants"
local option_def = require "option_def"

local modal_combat = { name = "Combat" }

function modal_combat.new( monster, gstate )
	local self = util.shallowcopy( modal_combat )
	self.gstate = gstate
	self.monster = monster
	return self
end

function modal_combat:update()
	while true do
		coroutine.yield()
	end
end

function modal_combat:draw()
	for i, card in ipairs( self.ui_cards ) do
		card:draw()
	end
end

function modal_combat:refreshCards()
	self.ui_cards = self.gstate:showCards( self.gstate.deck:ihand() )
end

function modal_combat:refreshOptions()
	self.gstate:addLine( string.format( "You are fighting: <#ff0000>%s</>", self.monster.name ))

	self.gstate:addOption( option_def.back )
	self.gstate:addOption( option_def.attack )

	for i, card_def in self.gstate.deck:ihand() do
		if card_def.kind == constants.CARD.ACTION then
			self.gstate:addOption( option_def.actionCard( card_def, i ) )
		end
	end
end

return modal_combat

