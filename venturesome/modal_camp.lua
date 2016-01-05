local constants = require "constants"
local option_def = require "option_def"

local modal_camp = { name = "Camp" }

function modal_camp.new( gstate )
	local self = util.shallowcopy( modal_camp )
	self.gstate = gstate
	return self
end

function modal_camp:update()
	self.gstate:passTime( 1 )

	while self.option ~= option_def.packup do
		coroutine.yield()
	end

	self.gstate:initTurn()
end

function modal_camp:draw()
	for i, card in ipairs( self.ui_cards ) do
		card:draw()
	end
end

function modal_camp:refreshCards()
	local card_def = require "card_def"
	self.ui_cards = self.gstate:showCards( pairs( card_def ))
end

function modal_camp:refreshOptions( options )
	table.insert( options, option_def.packup )

	for i, card in ipairs( self.ui_cards ) do
		if card:isSelected() then
			local card_def = card:getDef()
			local desc = string.format( "Acquire %s", card_def.name )
			local resources = { [ constants.RESOURCE.EXP ] = card_def.cost, [ constants.RESOURCE.BUYS ] = 1 }
			local fn = function( gstate )
				gstate.deck:addCard( card_def )
				gstate:addResource( constants.RESOURCE.BUYS, -1 )
				gstate:addResource( constants.RESOURCE.EXP, -card_def.cost )
				gstate:refreshOptions()
			end
			local opt = { desc = desc, resources = resources, fn = fn }
			table.insert( options, opt )
		end
	end
end

return modal_camp
