local constants = require "constants"
local option_def = require "option_def"

local modal_discard = { name = "Discard" }

function modal_discard.new( gstate, count )
	local self = util.shallowcopy( modal_discard )
	self.gstate = gstate
	self.count = count or 1
	self.discarded_cards = {}
	self:refreshName()
	return self
end

function modal_discard:refreshName()
	self.name = string.format( "Discard %d", self.count )
end

function modal_discard:update()
	self.ui_cards = self.gstate:showCards( self.gstate.deck:ihand() )
	while self.count > 0 do
		coroutine.yield()
	end
	return self.discarded_cards
end

function modal_discard:draw()
	for i, card in ipairs( self.ui_cards ) do
		card:draw()
	end
end

function modal_discard:refreshCards()
	self.ui_cards = self.gstate:showCards( self.gstate.deck:ihand() )
end

function modal_discard:refreshOptions( options )
	table.insert( options, { desc = "Cancel", fn = function() self.count = 0 end } )

	for i, card in ipairs( self.ui_cards ) do
		if card:isSelected() then
			local card_def = card:getDef()
			local desc = string.format( "Discard %s", card_def.name )
			local fn = function( gstate )
				table.insert( self.discarded_cards, card_def )
				gstate.deck:discard( i )
				self.count = self.count - 1
				self:refreshName()
			end
			local opt = { desc = desc, fn = fn }
			table.insert( options, opt )
		end
	end
end

return modal_discard
