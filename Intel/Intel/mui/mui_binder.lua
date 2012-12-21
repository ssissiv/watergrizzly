-----------------------------------------------------
-- MOAI UI
-- Copyright (c) 2012-2012 Klei Entertainment Inc.
-- All Rights Reserved.

local array = require( "modules/array" )

local mui_binder = {}

local function _bindingWarning() end

local nullBindingMt =
{
	__index = function( t, k )
		print("WARNING: failed bind '" ..t.name.. "' accessing '" ..tostring(k).."'" )

		-- Typically only functions are accessed by widgets, so return a null function
		return _bindingWarning
	end,

	__newindex = function( t, k, v )
		print("WARNING: failed bind '" ..t.name.. "' assigning '" ..tostring(k).."'" )
	end
}

local function createNullBinding( name )
	return setmetatable( { name = name }, nullBindingMt )
end

function mui_binder.__index( t, k )
	-- Trying to bind a widget named 'k'.
	if t._bindings[k] == nil then
		local widget = t._screen:findWidget(k)
		if not widget then
			widget = createNullBinding( k )
		end
		t._bindings[k] = widget
	end

	return t._bindings[k]
end

function mui_binder.__newindex( t, k, v )
	assert(false, "This table cannot be assigned to.")
end

function mui_binder.create( screen )
	local binder = {}
	binder._screen = screen
	binder._bindings = {}
	setmetatable( binder, mui_binder )
	return binder
end

return mui_binder
