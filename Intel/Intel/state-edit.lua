--==============================================================
-- Copyright (c) 2010-2012 Zipline Games, Inc. 
-- All Rights Reserved. 
-- http://getmoai.com
--==============================================================

local util = require( "modules/util" )
local mui = require("mui/mui")
local mui_defs = require("mui/mui_defs")
local nselect = require( "game/nselect" )
local gnode = require( "game/gnode" )

----------------------------------------------------------------

local MODE_SELECT = 1

----------------------------------------------------------------

local stateEdit = {}

function stateEdit:updateTooltip( wx, wy )

	local tooltipLabel = self.screen.binder.tooltipTxt
	local x, y = self.game:wndToWorld( wx, wy )
	local txt = string.format("<%d, %d> ", x, y )
	local node = self.game:findNode( x, y )
	if node then
		txt = txt .. node:getName()
		if #node:getUnits() > 0 then
			for _,unit in pairs(node:getUnits()) do
				txt = txt .. unit:getName() .. ", "
			end
		end
	end

	local tw, th = tooltipLabel:getSize()
	local tx, ty = self.screen:wndToUI(wx + 14, wy + 14)

	tooltipLabel:setText( txt )
	tooltipLabel:setPosition( tx + tw/2, ty - th/2 )
	tooltipLabel:setVisible( true )
end

function stateEdit:createLink( node0, node1 )
	if node0 and node1 and node0 ~= node1 then
		self.game:spawnLink( node0, node1 )
	end
end

function stateEdit:createNode( x, y )

	local node = gnode( x, y )
	self.game:spawnNode( node )
	
	return node
end
	
----------------------------------------------------------------
stateEdit.onLoad = function ( self, game )
	log:write("EDIT: ON")

	self.game = game
	self.game:getIntel():setOmniscient( true )
	
	self.mode = MODE_SELECT
	self.selection = nselect( game )
	
	self.screen = mui.createScreen( "state-edit.lua" )
	mui.activateScreen( self.screen )
	
	inputmgr.addListener( self )
end

----------------------------------------------------------------
stateEdit.onUnload = function ( self )
	self.game:getIntel():setOmniscient( false )

	self.selection:clear()
	
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

	if self.mode == MODE_SELECT then
		if event.eventType == mui_defs.EVENT_KeyUp then
			local keycode = event.key + (mui_defs.K_A - 1)

			if event.key == mui_defs.K_ESCAPE then
				statemgr.deactivate( self )
				local stateGame = require("state-game")
				statemgr.activate( stateGame, self.game )
				return true
				
			elseif event.key == mui_defs.K_ENTER then
				local x, y = self.game:wndToWorld( event.wx, event.wy )
				local node = self.game:findNode( x, y )
				self:createLink( self.selection:get(), node )
				
			elseif keycode == mui_defs.K_L and event.controlDown then
				self.selection:clear()
				self.game:loadTopography("map.lua")
			elseif keycode == mui_defs.K_S and event.controlDown then
				self.game:saveTopography("map.lua")
			end
		
		elseif event.eventType == mui_defs.EVENT_MouseDown then
			local x, y = self.game:wndToWorld( event.wx, event.wy )
			local node = self.game:findNode( x, y ) or (event.button == mui_defs.MB_Right and self:createNode( x, y ))
			self.selection:select( node )
			return true

		elseif event.eventType == mui_defs.EVENT_MouseMove then
			local x, y = self.game:wndToWorld( event.wx, event.wy )
			self.selection:preselect( self.game:findNode( x, y ))
			
			self:updateTooltip( event.wx, event.wy )
			return true
		end
	end
end

----------------------------------------------------------------
stateEdit.onUpdate = function ( self )
	self.game:doTick(0)
end

return stateEdit
