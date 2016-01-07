local constants = require "constants"
local option_def = require "option_def"

local modal_trash = { name = "Trash" }

function modal_trash.new( gstate, count, fn )
	local self = util.shallowcopy( modal_trash )
	self.gstate = gstate
	self.count = count or 1
	self.fn = fn
	self.trashed_cards = {}
	self:refreshName()
	return self
end

function modal_trash:refreshName()
	self.name = string.format( "Trash %d", self.count )
end

function modal_trash:update()
	while self.count > 0 do
		coroutine.yield()
	end
	return self.trashed_cards
end

function modal_trash:draw()
	for i, card in ipairs( self.ui_cards ) do
		card:draw()
	end
end

function modal_trash:refreshCards()
	self.ui_cards = self.gstate:showCards( self.gstate.deck:ihand() )
end

function modal_trash:refreshOptions( options )
	table.insert( options, { desc = "Cancel", fn = function() self.count = 0 end } )

	for i, card in ipairs( self.ui_cards ) do
		if card:isSelected() and (self.fn == nil or self.fn( card:getDef() )) then
			local card_def = card:getDef()
			local desc = string.format( "Trash %s", card_def.name )
			local fn = function( self, gstate )
				table.insert( self.trashed_cards, card_def )
				gstate.deck:trash( i )
				self.count = self.count - 1
				self:refreshName()
			end
			local opt = { desc = desc, fn = fn }
			table.insert( options, opt )
		end
	end
end

return modal_trash
