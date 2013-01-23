----------------------------------------------------------------
-- GAME JAM! 2012
----------------------------------------------------------------

config =
{
	LOGDIR = LOGDIR,
	WIN_HEIGHT = 720,
	WIN_WIDTH = 1080,
}

APP_VERSION = "0.1.0"

----------------------------------------------------------------

dofile('strict.lua')
require("modules/input-manager")
require("modules/state-manager")
local logger = require("modules/logger")
local filesystem = require("modules/filesystem")
local mui = require("mui/mui")
local mui_defs = require("mui/mui_defs")

if config.LOGDIR then
	logger.setLogDirectory( config.LOGDIR )
end
log = logger.openLog( "spylog.txt" )
MOAILogMgr.openFile( filesystem.pathJoin( logger.getLogDirectory(), "moailog.txt" ))

MOAISim.openWindow ( "test", config.WIN_WIDTH, config.WIN_HEIGHT )
MOAIGfxDevice.setClearColor ( 0, 0, 0, 1 )

APP = {}

APP.viewport = MOAIViewport.new ()
APP.viewport:setSize( config.WIN_WIDTH, config.WIN_HEIGHT )
APP.viewport:setScale( config.WIN_WIDTH, config.WIN_HEIGHT )

--MOAIFmodDesigner.loadFEV("space.fev")
--MOAIFmodDesigner.playSound("moo", "space/music/slow")

----------------------------------------------------------------
-- Create the GUI subsystem

local function getUIPath(fileName)
	return filesystem.pathJoin("data", fileName)
end


mui.initMui( config.WIN_WIDTH, config.WIN_HEIGHT, getUIPath )

inputmgr.init()

MOAIEnvironment.setListener( MOAIEnvironment.EVENT_VALUE_CHANGED,
	function( name, val, c )
		if name == "horizontalResolution" then
			config.WIN_WIDTH = val
		elseif name == "verticalResolution" then
			config.WIN_HEIGHT = val
		end
	
		mui.onResize( config.WIN_WIDTH, config.WIN_HEIGHT )
	end )

----------------------------------------------------------------
-- Start the game!

local stateSplash = require("state-splash")
statemgr.activate( stateSplash )
statemgr.begin ()
