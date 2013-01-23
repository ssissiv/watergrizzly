--==============================================================
-- Copyright (c) 2010-2012 Zipline Games, Inc. 
-- All Rights Reserved. 
-- http://getmoai.com
--==============================================================

local util = require( "modules/util" )
local mui = require("mui/mui")
local mui_defs = require("mui/mui_defs")

----------------------------------------------------------------

local MODE_SELECT = 1

----------------------------------------------------------------

local stateEdit = {}

function stateEdit:updateTooltip( wx, wy )

	local tooltipLabel = self.screen.binder.tooltipTxt
	local x, y = self.game:wndToWorld( wx, wy )
	local txt = string.format("<%d, %d> ", x, y )

	local tw, th = tooltipLabel:getSize()
	local tx, ty = self.screen:wndToUI(wx + 14, wy + 14)

	tooltipLabel:setText( txt )
	tooltipLabel:setPosition( tx + tw/2, ty - th/2 )
	tooltipLabel:setVisible( true )
end

	
----------------------------------------------------------------
stateEdit.onLoad = function ( self, game )
	log:write("EDIT: ON")
	assert( game )
	
	self.game = game
	self.game:getPlayer():showEditGrid()
	
	self.mode = MODE_SELECT
	
	self.screen = mui.createScreen( "state-edit.lua" )
	mui.activateScreen( self.screen )
	
	inputmgr.addListener( self, 1 )
end

----------------------------------------------------------------
stateEdit.onUnload = function ( self )

	self.game:getPlayer():hideEditGrid()
	
	mui.deactivateScreen( self.screen )
	self.screen = nil

	inputmgr.removeListener( self )

	log:write("EDIT: OFF")
end


----------------------------------------------------------------
stateEdit.onInputEvent = function ( self, event )

	if self.game:getCamera():onInputEvent( event ) then
		return true
	end
	
	if event.eventType == mui_defs.EVENT_KeyUp then
		if event.key == mui_defs.K_E then
			statemgr.deactivate( self )
		end
	elseif event.eventType == mui_defs.EVENT_MouseDown then
		local x, y = self.game:wndToWorld( event.wx, event.wy )
		local tx, ty = self.game:getPlayer():worldToGrid( x, y )
		print("TILE: ", tx, ty)
	end
			
	return true
end

----------------------------------------------------------------
stateEdit.onUpdate = function ( self )
	self.game:doTick(0)
end

return stateEdit
