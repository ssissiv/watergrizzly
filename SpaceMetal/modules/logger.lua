--==============================================================
-- Copyright (c) 2010-2012 Zipline Games, Inc. 
-- All Rights Reserved. 
-- http://getmoai.com
--==============================================================

module ( "logger", package.seeall )

local filesystem = require("modules/filesystem")
local util = require("modules/util")

----------------------------------------------------------------
-- log functions
----------------------------------------------------------------

local _log = {}
local _logDirectory = "log"
local _minPriority = 3 -- Only logs priority 3 and up are printed to the console.

function _log:writep( priority, formatStr, ... )

	local prefix = ""

	if self.lastwrite ~= nil and os.difftime( os.time(), self.lastwrite ) > 1 then
		prefix = "\n"
	end

	self.lastwrite = os.time()

	local str = string.format( formatStr, ... )

	self.file:write( prefix .. os.date("%H:%M:%S") .. "> " .. str .. "\n" )
	if priority >= _minPriority then
		print( str )
	end
end

function _log:write( priority, formatStr, ... )
	if type(priority) == "number" then
		self:writep( priority, formatStr, ... )
	else
		self:writep( _minPriority, priority, formatStr, ... )
	end
end

function _log:close()
	self.file:close()
end

----------------------------------------------------------------
-- public functions
----------------------------------------------------------------

local function setLogDirectory( dir )
	_logDirectory = dir or ""
end

local function getLogDirectory( dir )
	return _logDirectory
end

local function setMinPriority( p )
end

local function openLog( filename )

	local workingDir = MOAIFileSystem.getWorkingDirectory ()
	local fullFileName = filesystem.pathJoin( workingDir, _logDirectory, filename )
	MOAIFileSystem.affirmPath( filesystem.pathJoin( workingDir, _logDirectory) )
	
	local log = util.tcopy( _log )

	local fl = io.open ( fullFileName, 'wt' )
	if not fl then
		print( "### Error opening log " ..fullFileName )
	else
		local log = util.tcopy( _log )
		log.file = fl

		log:write( "### SPY SOCIETY " .. APP_VERSION .. " ###" )
		log:write( "DATE: " .. os.date() )
		log.file:flush()
		return log
	end
end

return
{
	ModuleName = "logger",
	setLogDirectory = setLogDirectory,
	getLogDirectory = getLogDirectory,
	setMinPriority = setMinPriority,
	openLog = openLog,
}
