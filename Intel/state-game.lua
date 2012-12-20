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
local gamedefs = require("game/gamedefs")

----------------------------------------------------------------

local stategame = {}

function stategame:setPaused( isPaused )
	self.isPaused = isPaused
	self.screen.binder.pauseLabel:setVisible( self.isPaused )
end

function stategame:onSelectUnit( unit )
	self.selectedUnit = unit
	self:updateUnitPanel()
end

function stategame:updateTooltip( wx, wy )

	local tooltipLabel = self.screen.binder.tooltipTxt
	local x, y = self.game:wndToWorld( wx, wy )
	local txt = ""
	local node = self.game:findNode( x, y )
	if node then
		txt = txt .. node:getName() .."\n"
		local info = self.game:getIntel():find( node )
		if info == nil or info.tick == nil then
			txt = txt .. "Status Unknown"
		elseif info == node then
			if #node:getUnits() > 0 then
				for _,unit in pairs(node:getUnits()) do
					txt = txt .. " " .. unit:getName() .. ","
				end
			end
		else
			local age = (self.game:getTick() - info.tick) * MOAISim.getStep()
			txt = txt .. "Last scouted: " ..util.ftime( age )
		end
	end

	local tw, th = tooltipLabel:getSize()
	local tx, ty = self.screen:wndToUI(wx + 14, wy + 14)

	tooltipLabel:setText( txt )
	tooltipLabel:setPosition( tx + tw/2, ty - th/2 )
	tooltipLabel:setVisible( true )
end

function stategame:updateUnitPanel()
	self:updateHomePanel()
	self:updateAwayPanel()
end

function stategame:updateHomePanel()
	local panel = self.screen:findWidget("home0")
	local i = 1
	local units = {}
	if self.game:findHomeNode() then
		units = self.game:findHomeNode():getUnits()
	end
	
	while panel do
		local unitBtn = panel:findWidget("unitBtn")
		local unitName = panel:findWidget("unitName")
		local selectImg = panel:findWidget("selectImg")

		if units[i] == nil then
			panel:setVisible(false)
		else
			panel:setVisible(true)
			unitBtn:setInactiveImage( units[i]:getIcon() )
			unitBtn:setActiveImage( units[i]:getIcon() )
			unitBtn:setHoverImage( units[i]:getIcon() )
			unitBtn.onClick = util.makeDelegate( self, "onSelectUnit", units[i] )
			unitName:setText( units[i]:getName() )
			selectImg:setVisible( self.selectedUnit == units[i] )
		end

		panel = self.screen:findWidget("home"..i)
		i = i + 1
	end
end

function stategame:updateAwayPanel()
	
	local panel = self.screen:findWidget("away0")
	local i, j = 1, 1
	local units = self.game:getAllUnits()
	local homeNode = self.game:findHomeNode()
	
	while panel do
		local unitBtn = panel:findWidget("awayUnitBtn")
		local unitName = panel:findWidget("awayUnitName")
		local selectImg = panel:findWidget("awaySelectImg")

		while j <= #units and (units[j]:getNode() == homeNode) do
			j = j + 1
		end
		
		if units[j] == nil then
			panel:setVisible(false)
		else
			panel:setVisible(true)
			unitBtn:setInactiveImage( units[j]:getIcon() )
			unitBtn:setActiveImage( units[j]:getIcon() )
			unitBtn:setHoverImage( units[j]:getIcon() )
			--unitBtn.onClick = util.makeDelegate( self, "onSelectUnit", units[i] )
			unitName:setText( units[j]:getName() )
			selectImg:setVisible( self.selectedUnit == units[j] )
			j = j + 1
		end

		panel = self.screen:findWidget("away"..i)
		i = i + 1
	end
end

function stategame:onSimEvent( evType, evData )
	if evType == gamedefs.EV_UNIT_ARRIVED or evType == gamedefs.EV_UNIT_LEFT then
		self:updateUnitPanel()
	elseif evType == gamedefs.EV_PHASEIN then
	end
end

function stategame:onClickBuyScout()
	self.game:buyUnit( gamedefs.UNIT_SCOUT )
end

function stategame:onClickBuyFighter()
	self.game:buyUnit( gamedefs.UNIT_FIGHTER )
end

function stategame:onClickBuyCaptain()
end

function stategame:onClickBuyGeneral()
end

----------------------------------------------------------------
stategame.onLoad = function ( self, game )

	self.game = game
	self.isPaused = false
	
	self.selection = nselect( game )

	self.screen = mui.createScreen( "state-game.lua" )
	mui.activateScreen( self.screen )
	self.screen.binder.fighterBtn.onClick = util.makeDelegate( stategame, "onClickBuyFighter" )
	self.screen.binder.scoutBtn.onClick = util.makeDelegate( stategame, "onClickBuyScout" )
	self.screen.binder.captainBtn.onClick = util.makeDelegate( stategame, "onClickBuyCaptain" )
	self.screen.binder.generalBtn.onClick = util.makeDelegate( stategame, "onClickBuyGeneral" )

	self:updateUnitPanel()

	self.game:addListener( self )
	inputmgr.addListener( self )
end

----------------------------------------------------------------
stategame.onUnload = function ( self )
	self.selection:clear()

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
		if event.key == mui_defs.K_ESCAPE then
			statemgr.deactivate( self )
			local stateEdit = require("state-edit")
			statemgr.activate( stateEdit, self.game )
			return true
		elseif event.key == mui_defs.K_SPACE then
			self:setPaused( not self.isPaused )		
		end
		
	elseif event.eventType == mui_defs.EVENT_MouseUp then
		if event.button == mui_defs.MB_Right then
			local x, y = self.game:wndToWorld( event.wx, event.wy )
			local node = self.game:findNode( x, y )

			if node and self.selectedUnit then
				-- There and back
				self.selectedUnit:issueDefaultOrder( node )
				local tmp = indicator( self.game, "fx_move.png", x, y )
			end
			return true
		end

	elseif event.eventType == mui_defs.EVENT_MouseMove then
		local x, y = self.game:wndToWorld( event.wx, event.wy )
		self.selection:preselect( self.game:findNode( x, y ))
		
		self:updateTooltip( event.wx, event.wy )
		return true

	end
end


----------------------------------------------------------------
stategame.onUpdate = function ( self )
	if not self.isPaused then
		self.game:doTick(1)
	end
	
	local secs = self.game:getTick() * MOAISim.getStep()
	self.screen.binder.timeLabel:setText( "Time: " ..util.ftime( secs ))
end

return stategame
