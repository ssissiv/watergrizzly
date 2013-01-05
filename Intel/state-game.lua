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
local orders = require("game/orders")
local highscore = require("modules/highscore")

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
			 
			if info.creds and info.creds > 0 then
				txt = txt .. "Creds: <orange>+" ..info.creds .."</>\n"
			end
			if info.fuel and info.fuel > 0 then
				txt = txt .. "Fuel: <orange>+" ..info.fuel .."</>\n"
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
	local fuel = self.game:getResource("fuel")
		
	self.screen.binder.resourcesLabel:setText( string.format( "Credits: <orange>%d</>, Fuel: <orange>%d</>", creds, fuel ))
end


function stategame:onSimEvent( evType, evData )
	if evType == gamedefs.EV_GAMEOVER then
		self:transition( MODE_NULL )
		highscore:setScore( self.game:getTick() )

	elseif evType == gamedefs.EV_UNIT_ARRIVED or evType == gamedefs.EV_UNIT_LEFT then
		self:updateUnitPanel()
	elseif evType == gamedefs.EV_UPDATE_RESOURCES then
		self:updateUnitPanel()
		local playerUnit = self.game:findPlayer()
		local px, py = playerUnit:getPosition()
		if self.bonusFX then
			self.bonusFX:destroy()
			self.bonusFX = nil
		end
		if self.bonusFX2 then
			self.bonusFX2:destroy()
			self.bonusFX2 = nil
		end
		if (evData[1] or 0) > 0 and (evData[2] or 0) > 0 then
			self.bonusFX = floater( self.game, string.format("+%d / +%d", evData[1], evData[2]), px, py + 40, 1, 3 )
		elseif evData[1] and evData[1] > 0 then
			self.bonusFX = floater( self.game, string.format("+%d", evData[1]), px, py + 40, 1, 3 )
		elseif evData[2] and evData[2] > 0 then
			self.bonusFX = floater( self.game, string.format("+%d", evData[2]), px, py + 40, 1, 3 )
		end
		self.bonusFX2 = indicator( self.game, "creds.png", px, py + 40, 1, 3 )

	elseif evType == gamedefs.EV_PHASEIN then
		MOAIFmodDesigner.playSound("confirm", "space/sounds/warning")
		self.phaseTick = self.game:getTick()
		self:updateInfoLabel()

	elseif evType == gamedefs.EV_INTEL_UPDATE then
		MOAIFmodDesigner.playSound("confirm", "space/sounds/scan")
	end
end

function stategame:onClickBuyScout()
	if self.game:hasResources( gamedefs.SCOUT_COST ) then
		self:transition( MODE_SCOUT )
	end
end

function stategame:onClickBuyWatchTower()
	if self.game:hasResources( gamedefs.WATCHTOWER_COST ) then
		self.game:buyUnit( gamedefs.UNIT_WATCHTOWER )
	end
end

function stategame:onClickBuyGuardTower()
	if self.game:hasResources( gamedefs.GUARDTOWER_COST ) then
		self.game:buyUnit( gamedefs.UNIT_GUARDTOWER )
	end
end

function stategame:onClickBuyFighter()
	if self.game:hasResources( gamedefs.FIGHTER_COST ) then
		self:transition( MODE_FIGHTER )
	end
end

function stategame:transition( mode )
	self.mode = mode
	self.qnodes = {}
	
	self:updateInfoLabel()
end

function stategame:quitGame()
	local stateSplash = require("state-splash")
	statemgr.deactivate(self)
	statemgr.activate( stateSplash )
end

----------------------------------------------------------------
stategame.onLoad = function ( self, game )

	self.game = game
	self.mode = MODE_NULL
	self.qnodes = {}
	self.phaseTick = nil
	
	self.selection = nselect( game )

	self.screen = mui.createScreen( "state-game.lua" )
	mui.activateScreen( self.screen )
	
	self.screen.binder.buy0Btn:setVisible(true)
	self.screen.binder.buy0Btn.onClick = util.makeDelegate( stategame, "onClickBuyScout" )
	self.screen.binder.buy0Btn:setText( string.format( "<hotkey>S</>couts (%d)", gamedefs.SCOUT_COST.creds ))
	self.screen.binder.buy0Btn:setHotkey( string.byte('s') )
	self.screen.binder.buy1Btn:setVisible(true)
	self.screen.binder.buy1Btn.onClick = util.makeDelegate( stategame, "onClickBuyGuardTower" )
	self.screen.binder.buy1Btn:setText( string.format( "<hotkey>G</>uard Tower (%d)", gamedefs.GUARDTOWER_COST.creds ))
	self.screen.binder.buy1Btn:setHotkey( string.byte('g') )
	self.screen.binder.buy2Btn:setVisible(true)
	self.screen.binder.buy2Btn.onClick = util.makeDelegate( stategame, "onClickBuyWatchTower" )
	self.screen.binder.buy2Btn:setText( string.format( "<hotkey>W</>atch Tower (%d)", gamedefs.WATCHTOWER_COST.creds ))
	self.screen.binder.buy2Btn:setHotkey( string.byte('w') )
	self.screen.binder.buy3Btn:setVisible(true)
	self.screen.binder.buy3Btn.onClick = util.makeDelegate( stategame, "onClickBuyFighter" )
	self.screen.binder.buy3Btn:setText( string.format( "<hotkey>F</>ighter (%d/%d)", gamedefs.FIGHTER_COST.creds, gamedefs.FIGHTER_COST.fuel ))
	self.screen.binder.buy3Btn:setHotkey( string.byte('f') )

	self.screen.binder.enemyLabel:setVisible( false )
	self:setPaused( self.game:isPaused() )
	self:updateUnitPanel()

	self.game:addListener( self )
	inputmgr.addListener( self )
end

----------------------------------------------------------------
stategame.onUnload = function ( self )
	if self.bonusFX then
		self.bonusFX:destroy()
		self.bonusFX = nil
	end
	if self.bonusFX2 then
		self.bonusFX2:destroy()
		self.bonusFX2 = nil
	end
	
	self.game:destroy()
	self.game = nil
	
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
		if event.key == mui_defs.K_E and event.controlDown then
			statemgr.deactivate( self )
			local stateEdit = require("state-edit")
			statemgr.activate( stateEdit, self.game )
		elseif event.key == mui_defs.K_ESCAPE then
			self:quitGame()
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
		return true
		
	elseif event.eventType == mui_defs.EVENT_MouseUp then
		if self.game:isGameOver() or self.game:isPaused() then
			return true
		end
		
		local x, y = self.game:wndToWorld( event.wx, event.wy )
		local node = self.game:findNode( x, y )

		if self.mode == MODE_SCOUT and not self.isPaused then
			if node then
				if event.shiftDown then
					table.insert( self.qnodes, orders.moveTo( self.game, nil, node ))
				else
					local scout = self.game:buyUnit( gamedefs.UNIT_SCOUT )
					if scout then
						while #self.qnodes > 0 do
							local order = table.remove(self.qnodes, 1)
							order.unit = scout -- HACK
							scout:issueOrder( order, true )
						end
						scout:issueOrder( orders.scoutTo( self.game, scout, node ), true )
						MOAIFmodDesigner.playSound("confirm", "space/sounds/confirm")
					end
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
					if fighter then
						while #self.qnodes > 0 do
							local order = table.remove(self.qnodes, 1)
							order.unit = fighter -- HACK
							fighter:issueOrder( order, true )
						end
						fighter:issueOrder( orders.moveTo( self.game, fighter, node ))
						fighter:issueOrder( orders.hunt( self.game, fighter, 60 * 2 ), true )
						self:transition( MODE_NULL )
						MOAIFmodDesigner.playSound("confirm", "space/sounds/confirm")
					end
				end
			end
			return true
			
		elseif self.mode == MODE_NULL and not self.isPaused then
			if event.button == mui_defs.MB_Right then
				local playerUnit = self.game:findPlayer()
				if playerUnit and node then
					playerUnit:issueOrder( orders.moveTo( self.game, playerUnit, node, 1 ))
					MOAIFmodDesigner.playSound("confirm", "space/sounds/confirm")
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
		txt = txt .. string.format("   <bigred>GAMEOVER: %d</>", self.game:getTick() )
	end
	
	self.screen.binder.timeLabel:setText( txt )
	
	if inputmgr:getMouseXY() then
		self:updateTooltip( inputmgr:getMouseXY() )
	end
end

return stategame
