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

local MODE_NULL = 0
local MODE_SCOUT = 1

----------------------------------------------------------------

local stategame = {}

function stategame:setPaused( isPaused )
	self.game:pause( isPaused )
	self:updateInfoLabel()
end

function stategame:onSelectUnit( unit )
	self.selectedUnit = unit
	self:updateUnitPanel()
end

function stategame:updateInfoLabel()
	local txt = ""
	if self.game:isPaused() then
		txt = "PAUSED"
	elseif self.mode == MODE_SCOUT then
		txt = "Click to deploy scout"
	end
	
	self.screen.binder.infoLabel:setText( txt )
	
	if self.phaseTick == nil or self.game:getTick() > self.phaseTick + 120 then
		self.screen.binder.enemyLabel:setVisible( false )
	else
		self.screen.binder.enemyLabel:setVisible( true )
	end
end

function stategame:updateTooltip( wx, wy )

	local tooltipLabel = self.screen.binder.tooltipTxt
	local x, y = self.game:wndToWorld( wx, wy )
	local txt = ""
	local node = self.game:findNode( x, y )
	if node then
		txt = txt
		local info = self.game:getIntel():find( node )
		if info then
			txt = txt .. info.name .."\n"
			 
			if info.creds then
				txt = txt .. "Creds: <orange>+" ..info.creds .."</>\n"
			end

			if info.units and #info.units > 0 then
				for _,unit in pairs(info.units) do
					txt = txt .. unit ..", "
				end
				txt = txt .. "\n"
			end
			
			if info.activity >= 20 then
				txt = txt .. "<red>Activity: High</>\n"
			elseif info.activity >= 10 then
				txt = txt .. "<orange>Activity: Med</>\n"
			elseif info.activity > 0 then
				txt = txt .. "Activity: Low</>\n"
			end

			local age = (self.game:getTick() - info.tick) * MOAISim.getStep()
			if age > 1 then
				txt = txt .. "Last scouted: " ..util.ftime( age )
			end
		else
			txt = txt .. "???"
		end
	end

	local tw, th = tooltipLabel:getSize()
	local tx, ty = self.screen:wndToUI(wx + 14, wy + 14)

	tooltipLabel:setText( txt )
	tooltipLabel:setPosition( tx + tw/2, ty - th/2 )
	tooltipLabel:setVisible( true )
end

function stategame:updateUnitPanel()
	local scouts = self.game:getResource("scouts")
	local creds = self.game:getResource("creds")
		
	self.screen.binder.resourcesLabel:setText( string.format( "Credits: %d", creds ))
end


function stategame:onSimEvent( evType, evData )
	if evType == gamedefs.EV_UNIT_ARRIVED or evType == gamedefs.EV_UNIT_LEFT then
		self:updateUnitPanel()
	elseif evType == gamedefs.EV_UPDATE_RESOURCES then
		self:updateUnitPanel()
	elseif evType == gamedefs.EV_PHASEIN then
		self.phaseTick = self.game:getTick()
		self:updateInfoLabel()
	end
end

function stategame:onClickBuyScout()
	self:transition( MODE_SCOUT )
end

function stategame:onClickBuyTower()
	self.game:buyUnit( gamedefs.UNIT_TOWER )
end

function stategame:onClickBuyFighter()
	self.game:buyUnit( gamedefs.UNIT_FIGHTER )
end

function stategame:transition( mode )
	self.mode = mode
	
	self:updateInfoLabel()
end

----------------------------------------------------------------
stategame.onLoad = function ( self, game )

	self.game = game
	self.mode = MODE_NULL
	
	self.selection = nselect( game )

	self.screen = mui.createScreen( "state-game.lua" )
	mui.activateScreen( self.screen )
	
	self.screen.binder.buy0Btn:setVisible(true)
	self.screen.binder.buy0Btn.onClick = util.makeDelegate( stategame, "onClickBuyScout" )
	self.screen.binder.buy0Btn:setText( string.format( "<hotkey>S</>couts (20)" ))
	self.screen.binder.buy0Btn:setHotkey( string.byte('s') )
	self.screen.binder.buy1Btn:setVisible(true)
	self.screen.binder.buy1Btn.onClick = util.makeDelegate( stategame, "onClickBuyTower" )
	self.screen.binder.buy1Btn:setText( string.format( "<hotkey>T</>ower (500)" ))
	self.screen.binder.buy1Btn:setHotkey( string.byte('t') )
	self.screen.binder.buy2Btn:setVisible(true)
	self.screen.binder.buy2Btn.onClick = util.makeDelegate( stategame, "onClickBuyFighter" )
	self.screen.binder.buy2Btn:setText( string.format( "<hotkey>F</>ighter (500)" ))
	self.screen.binder.buy2Btn:setHotkey( string.byte('f') )

	self:setPaused( self.game:isPaused() )
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
			self:setPaused( not self.game:isPaused() )
		elseif event.key == mui_defs.K_ENTER then
			local playerUnit = self.game:findPlayer()
			if playerUnit then
				self.game:getCamera():panTo( playerUnit:getPosition() )
			end
		elseif event.key == mui_defs.K_O then
			self.game:getIntel():setOmniscient( not self.game:getIntel():isOmniscient() )
		end
		
	elseif event.eventType == mui_defs.EVENT_MouseUp then
		local x, y = self.game:wndToWorld( event.wx, event.wy )
		local node = self.game:findNode( x, y )

		if self.mode == MODE_SCOUT and not self.isPaused then
			if node then
				self.game:buyUnit( gamedefs.UNIT_SCOUT, node )
				self:transition( MODE_NULL )
			end
			return true
		elseif self.mode == MODE_NULL and not self.isPaused then
			if event.button == mui_defs.MB_Right then
				local playerUnit = self.game:findPlayer()

				if playerUnit and node then
					-- There and back
					playerUnit:issueDefaultOrder( node )
				end
				return true
			end
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
	self.game:doTick(1)
	
	local secs = self.game:getTick() * MOAISim.getStep()
	local txt = "Time: <bigred>" ..util.ftime( secs ) .."</>"
	if self.game:isGameOver() then
		txt = txt .. " <bigred>GAMEOVER</>"
	end
	
	self.screen.binder.timeLabel:setText( txt )
	
	if inputmgr:getMouseXY() then
		self:updateTooltip( inputmgr:getMouseXY() )
	end
end

return stategame
