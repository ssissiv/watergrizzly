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
local orders = require("game/orders")

----------------------------------------------------------------

local MODE_NULL = 0
local MODE_SCOUT = 1
local MODE_FIGHTER = 2

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
	elseif self.mode == MODE_FIGHTER then
		txt = "Click to deploy fighter"
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

function stategame:onClickBuyWatchTower()
	self.game:buyUnit( gamedefs.UNIT_WATCHTOWER )
end

function stategame:onClickBuyGuardTower()
	self.game:buyUnit( gamedefs.UNIT_GUARDTOWER )
end

function stategame:onClickBuyFighter()
	self:transition( MODE_FIGHTER )
end

function stategame:transition( mode )
	self.mode = mode
	
	self:updateInfoLabel()
end

----------------------------------------------------------------
stategame.onLoad = function ( self, game )

	self.game = game
	self.mode = MODE_NULL
	self.qnodes = {}
	
	self.selection = nselect( game )

	self.screen = mui.createScreen( "state-game.lua" )
	mui.activateScreen( self.screen )
	
	self.screen.binder.buy0Btn:setVisible(true)
	self.screen.binder.buy0Btn.onClick = util.makeDelegate( stategame, "onClickBuyScout" )
	self.screen.binder.buy0Btn:setText( string.format( "<hotkey>S</>couts (20)" ))
	self.screen.binder.buy0Btn:setHotkey( string.byte('s') )
	self.screen.binder.buy1Btn:setVisible(true)
	self.screen.binder.buy1Btn.onClick = util.makeDelegate( stategame, "onClickBuyGuardTower" )
	self.screen.binder.buy1Btn:setText( string.format( "<hotkey>G</>uard Tower (400)" ))
	self.screen.binder.buy1Btn:setHotkey( string.byte('g') )
	self.screen.binder.buy2Btn:setVisible(true)
	self.screen.binder.buy2Btn.onClick = util.makeDelegate( stategame, "onClickBuyWatchTower" )
	self.screen.binder.buy2Btn:setText( string.format( "<hotkey>W</>atch Tower (600)" ))
	self.screen.binder.buy2Btn:setHotkey( string.byte('w') )
	self.screen.binder.buy3Btn:setVisible(true)
	self.screen.binder.buy3Btn.onClick = util.makeDelegate( stategame, "onClickBuyFighter" )
	self.screen.binder.buy3Btn:setText( string.format( "<hotkey>F</>ighter (500)" ))
	self.screen.binder.buy3Btn:setHotkey( string.byte('f') )

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
				if event.shiftDown then
					table.insert( self.qnodes, orders.moveTo( self.game, nil, node ))
				else
					local scout = self.game:buyUnit( gamedefs.UNIT_SCOUT )
					while #self.qnodes > 0 do
						local order = table.remove(self.qnodes, 1)
						order.unit = scout -- HACK
						scout:issueOrder( order, true )
					end
					scout:issueOrder( orders.scoutTo( self.game, scout, node ), true )
					self:transition( MODE_NULL )
				end
			end
			return true

		elseif self.mode == MODE_FIGHTER and not self.isPaused then
			if node then
				if event.shiftDown then
					table.insert( self.qnodes, orders.moveTo( self.game, nil, node ))
				else
					local fighter = self.game:buyUnit( gamedefs.UNIT_FIGHTER )
					while #self.qnodes > 0 do
						local order = table.remove(self.qnodes, 1)
						order.unit = fighter -- HACK
						fighter:issueOrder( order, true )
					end
					fighter:issueOrder( orders.moveTo( self.game, fighter, node ))
					fighter:issueOrder( orders.hunt( self.game, fighter, 60 * 2 ), true )
					self:transition( MODE_NULL )
				end
			end
			return true
			
		elseif self.mode == MODE_NULL and not self.isPaused then
			if event.button == mui_defs.MB_Right then
				local playerUnit = self.game:findPlayer()
				if playerUnit and node then
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
