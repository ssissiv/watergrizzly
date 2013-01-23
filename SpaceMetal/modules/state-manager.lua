--==============================================================
-- Copyright (c) 2010-2012 Zipline Games, Inc. 
-- All Rights Reserved. 
-- http://getmoai.com
--==============================================================

module ( "statemgr", package.seeall )

local util = require( "modules/util" )

----------------------------------------------------------------
----------------------------------------------------------------
-- variables
----------------------------------------------------------------
local loadedStates = {}
local stateStack = {}

----------------------------------------------------------------
-- run loop
----------------------------------------------------------------
local updateThread = MOAICoroutine.new ()

----------------------------------------------------------------
-- local functions
----------------------------------------------------------------

local function updateFunction ()
	
	while true do
		
		coroutine.yield ()
		
		local activeStack = util.tmerge( {}, stateStack)
		for k,v in pairs(activeStack) do
			if type ( v.onUpdate ) == "function" and util.indexOf(stateStack, v) ~= nil then
				v:onUpdate ()
			end
		end
		
	end
end


----------------------------------------------------------------
-- functions
----------------------------------------------------------------
function begin ()
	
	updateThread:run ( updateFunction )
end

----------------------------------------------------------------

function deactivate( state )

	local idx = util.indexOf( stateStack, state )
	assert( idx ~= nil )

	local state = stateStack[idx]

	-- do the state's onLoseFocus
	if idx == #stateStack and type ( state.onLoseFocus ) == "function" then
		state:onLoseFocus ()
	end
	
	-- do the state's onUnload
	if type ( state.onUnload ) == "function" then
		state:onUnload ()
	end

	table.remove( stateStack, idx )
		
	-- do the new current state's onFocus
	if idx > #stateStack and #stateStack > 0 and type ( stateStack[ #stateStack ].onFocus ) == "function" then
		stateStack[ #stateStack ]:onFocus ( )
	end
	
end


----------------------------------------------------------------
function activateAtIndex( state, index, ... ) 
	assert( state ~= nil )
	assert( util.indexOf( stateStack, state ) == nil )

	if stateStack[index] ~= state then
		table.insert( stateStack, index, state )
	
		-- if state is newly topmost, notify the previous topmost state
		if index == #stateStack and index > 1 and type ( stateStack[ index - 1 ].onLoseFocus ) == "function" then
			stateStack[ index - 1 ]:onLoseFocus ( )
		end
	
		-- do the new state's onLoad
		state:onLoad( ... )

		-- notify the new state of topmost status, if applicable
		if index == #stateStack and type(state.onFocus) == "function" then
			state:onFocus()
		end

	else
		assert(false, "State already active at index " ..index)
	end
		
end

function activate( state, ... ) 

	activateAtIndex( state, #stateStack + 1, ... )
end

----------------------------------------------------------------
function stop ( )
	
	while #stateStack > 0 do
		deactivate( stateStack[ #stateStack ] )
	end

	updateThread:stop ()
	os.exit()
end
