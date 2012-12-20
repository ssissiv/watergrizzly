require( "modules/class" )
local texprop = require( "modules/texprop" )

-----------------------------------------------------

local nselect = class()

function nselect:init( game )
	self.game = game

	self.selectionProp = texprop( "select.png", 32, game.layer )
	self.selectionProp:setVisible( false )
	self.selectionProp:setColor( 1, 0, 1, 0.5 )
	self.selection = nil

	self.preselectionProp = texprop( "select.png", 32, game.layer )
	self.preselectionProp:setVisible( false )
	self.preselectionProp:setColor( 1, 1, 1, 0.8 )
	self.preselection = nil
end

function nselect:preselect( node )
	if node then
		self.preselectionProp:setLoc( node:getPosition() )
		self.preselectionProp:setVisible( true )
		self.preselection = node
	else
		self.preselectionProp:setVisible( false )
		self.preselection = nil
	end
end

function nselect:select( node )
	if node then
		self.selectionProp:setLoc( node:getPosition() )
		self.selectionProp:setVisible( true )
		self.selection = node
	else
		self.selectionProp:setVisible( false )
		self.selection = nil
	end
end

function nselect:clear()
	self:select(nil)
	self:preselect(nil)
end

function nselect:get()
	return self.selection
end

return nselect
