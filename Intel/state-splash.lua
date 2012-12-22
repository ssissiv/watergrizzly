--==============================================================
-- Copyright (c) 2010-2012 Zipline Games, Inc. 
-- All Rights Reserved. 
-- http://getmoai.com
--==============================================================

local util = require( "modules/util" )
local mui = require("mui/mui")
local mui_defs = require("mui/mui_defs")
local highscore = require("modules/highscore")
require("game/game")

----------------------------------------------------------------

local splash = {}


----------------------------------------------------------------
splash.onInputEvent = function ( self, event )
	
	if event.type == mui_defs.EVENT_KeyUp or event.type == mui_defs.EVENT_MouseUp then
		local stateGame = require("state-game")
		statemgr.deactivate(self)

		statemgr.activate( stateGame, game(APP.viewport) )
	end
end

----------------------------------------------------------------
splash.onLoad = function ( self )
	MOAIGfxDevice.setClearColor ( 0, 0, 0, 1 )
	inputmgr.addListener( self )
		
	self.screen = mui.createScreen( "state-splash.lua" )
	mui.activateScreen( self.screen )
	
	local score = highscore:getScore()
	if score and score > 0 then
		self.screen.binder.hs0:setText("High Score: "..tostring(score))
	else
		self.screen.binder.hs0:setText("")
	end
end

----------------------------------------------------------------
splash.onUnload = function ( self )
	inputmgr.removeListener( self )
	mui.deactivateScreen( self.screen )
	self.screen = nil
end


return splash
