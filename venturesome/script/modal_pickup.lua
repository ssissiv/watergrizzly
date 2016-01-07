local constants = require "constants"
local option_def = require "option_def"

local modal_pickup = { name = "Pickup" }

function modal_pickup.new( gstate, count, fn )
	local self = util.shallowcopy( modal_pickup )
	self.gstate = gstate
	self.count = count or 1
	self.fn = fn
	return self
end

function modal_pickup:update()
	while self.count > 0 do
		coroutine.yield()
	end
end

function modal_pickup:draw()
	for i, card in ipairs( self.ui_cards ) do
		card:draw()
	end
end

function modal_pickup:refreshCards()
	local card_def = require "card_def"
	self.ui_cards = self.gstate:showCards( pairs( card_def ))
end

function modal_pickup:refreshOptions( options )
	table.insert( options, { desc = "Cancel", fn = function() self.count = 0 end } )

	for i, card in ipairs( self.ui_cards ) do
		if card:isSelected() and (self.fn == nil or self.fn( card:getDef() )) then
			local card_def = card:getDef()
			local desc = string.format( "Acquire %s", card_def.name )
			local fn = function( self, gstate )
				gstate.deck:addCard( card_def )
				self.count = self.count - 1
				gstate:refreshOptions()
			end
			local opt = { desc = desc, fn = fn }
			table.insert( options, opt )
		end
	end
end

return modal_pickup
