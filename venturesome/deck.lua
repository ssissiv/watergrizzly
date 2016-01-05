local card_def = require "card_def"
local util = require "util"

local deck = {}

function deck.new()
	local self = util.shallowcopy( deck )
	self.listeners = {}
	self.all = {}
	self.dis_cards = {}
	self.hand_cards = {}
	self.draw_cards = {}
	return self
end

function deck:addListener( listener )
	table.insert( self.listeners, listener )
end

function deck:notifyListeners( fn, ... )
	for i, listener in ipairs( self.listeners ) do
		listener[ fn ]( listener, ... )
	end
end

function deck:discard( i )
	i = i or math.random( #self.hand_cards )
	local card = table.remove( self.hand_cards, i )
	table.insert( self.dis_cards, card )
	print( string.format( "Discard: %s (%d left in hand)", card.name, #self.hand_cards ))
end

function deck:trash( i )
	assert( i )
	local card = table.remove( self.hand_cards, i )
	table.arrayremove( self.all, card )
	print( string.format( "Trash: %s (%d left in hand)", card.name, #self.hand_cards ))
	self:notifyListeners( "onTrashCard", card )
end

function deck:discardAll()
	while #self.hand_cards > 0 do
		self:discard( 1 )
	end
end

function deck:addCard( card_def )
	table.insert( self.all, card_def )
	table.insert( self.hand_cards, card_def )
	print( string.format( "Pick up: %s (%d left in hand)", card_def.name, #self.hand_cards ))
	self:notifyListeners( "onAcquireCard", card_def )
end

function deck:draw( num )
	for i = 1, num do
		if #self.draw_cards == 0 then
			table.shuffle( self.dis_cards )
			self.dis_cards, self.draw_cards = self.draw_cards, self.dis_cards
		end
		local card = table.remove( self.draw_cards )
		table.insert( self.hand_cards, card )
		print( string.format( "Draw: %s (%d in hand)", card.name, #self.hand_cards ))
		self:notifyListeners( "onDrawCard", card )
	end
end

function deck:ihand()
	return ipairs( self.hand_cards )
end

function deck:getSizes()
	return #self.all, #self.hand_cards, #self.draw_cards, #self.dis_cards
end

return deck

