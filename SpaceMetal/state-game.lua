--==============================================================
-- Copyright (c) 2010-2012 Zipline Games, Inc. 
-- All Rights Reserved. 
-- http://getmoai.com
--==============================================================

local util = require( "modules/util" )
local mui = require("mui/mui")
local mui_defs = require("mui/mui_defs")
local nselect = require( "game/nselect" )
local indicator = require("game/indicator")
local floater = require("game/floater")
local gamedefs = require("game/gamedefs")

----------------------------------------------------------------

local MODE_NULL = 0

----------------------------------------------------------------

local stategame = {}

function stategame:setPaused( isPaused )
	self.game:pause( isPaused )
	self:updateInfoLabel()
end

function stategame:quitGame()
	local stateSplash = require("state-splash")
	statemgr.deactivate(self)
	statemgr.activate( stateSplash )
end


function stategame:updateTooltip( wx, wy )

	local tooltipLabel = self.screen.binder.tooltipTxt
	local x, y = self.game:wndToWorld( wx, wy )
	local gridx, gridy = self.game:getPlayer():worldToGrid( x, y )
	local txt
	if gridx and gridy then
		txt = string.format("<%d, %d -> %d, %d> ", x, y, gridx, gridy )
	else
		txt = string.format("<%d, %d> ", x, y )
	end
	local tw, th = tooltipLabel:getSize()
	local tx, ty = self.screen:wndToUI(wx + 14, wy + 14)

	tooltipLabel:setText( txt )
	tooltipLabel:setPosition( tx + tw/2, ty - th/2 )
	tooltipLabel:setVisible( true )
end


----------------------------------------------------------------
stategame.onLoad = function ( self, game )

	self.game = game
	self.mode = MODE_NULL

	self.screen = mui.createScreen( "state-game.lua" )
	mui.activateScreen( self.screen )
	
	self.game:addListener( self )
	inputmgr.addListener( self )
end

----------------------------------------------------------------
stategame.onUnload = function ( self )

	self.game:destroy()
	self.game = nil
	
	inputmgr.removeListener( self )

	mui.deactivateScreen( self.screen )
	self.screen = nil
end


----------------------------------------------------------------
stategame.onInputEvent = function ( self, event )

	if self.game:getCamera():onInputEvent( event ) then
		return true
	end
	
	if event.eventType == mui_defs.EVENT_KeyUp then
		if event.key == mui_defs.K_E then
			local stateEdit = require("state-edit")
			statemgr.activate( stateEdit, self.game )
		elseif event.key == mui_defs.K_P then
			self.game:getPlayer():togglePowerGrid()
		elseif event.key == mui_defs.K_ESCAPE then
			self:quitGame()
		elseif event.key == mui_defs.K_SPACE then
			self:setPaused( not self.game:isPaused() )
		elseif event.key == mui_defs.K_ENTER then
			local playerUnit = self.game:findPlayer()
			if playerUnit then
				self.game:getCamera():panTo( playerUnit:getPosition() )
			end
		end
		return true
		
	elseif event.eventType == mui_defs.EVENT_MouseMove then
		local x, y = self.game:wndToWorld( event.wx, event.wy )
		return true
	end
end


----------------------------------------------------------------
stategame.onUpdate = function ( self )
	self.game:doTick(1)
		
	if inputmgr:getMouseXY() then
		self:updateTooltip( inputmgr:getMouseXY() )
	end
end

return stategame
