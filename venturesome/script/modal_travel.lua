local constants = require "constants"
local option_def = require "option_def"

local modal_travel = { name = "Travel" }

function modal_travel.new( gstate )
	local self = util.shallowcopy( modal_travel )
	self.gstate = gstate
	return self
end

function modal_travel:update()
	while true do
		coroutine.yield()
	end
end

function modal_travel:draw()
	for i, card in ipairs( self.ui_cards ) do
		card:draw()
	end
end

function modal_travel:refreshCards()
	self.ui_cards = self.gstate:showCards( self.gstate.deck:ihand() )
end

function modal_travel:refreshOptions( options )
	assert( options )

	self.gstate:addLine( self.gstate.room.desc )
	for i, thing in self.gstate.room:ithings() do
		self.gstate:addLine( thing.desc )
	end

	table.insert( options, option_def.camp )
	--table.insert( options, option_def.map )
	
	for i, opt in self.gstate.room:ioptions() do
		table.insert( options, opt )
	end

	for i, card_def in self.gstate.deck:ihand() do
		if card_def.kind == constants.CARD.ACTION then
			table.insert( options, option_def.actionCard( card_def, i ) )
		end
	end
end

function modal_travel:keypressed( key, isrepeat, modifiers )
	if key == "m" and modifiers.ctrl then
		self.gstate.room:addThing( option_def.monster( "Monster", 3, 3, 3 ))
	end
	self.gstate:refreshOptions()
end

return modal_travel

