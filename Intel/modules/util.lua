--==============================================================
-- Copyright (c) 2010-2012 Zipline Games, Inc. 
-- All Rights Reserved. 
-- http://getmoai.com
--==============================================================

local binops = require("modules/binary_ops")

----------------------------------------------------------------

local function indexOf( t, val )
	assert( type(t) == "table" )

	for k,v in pairs(t) do
		if v == val then
			return k
		end
	end
	
	return nil
end

local function indexPairs( t, idx )
	assert( type(t) == "table" )

	for k,v in pairs(t) do
		if idx == 1 then
			return k,v
		else
			idx = idx - 1
		end
	end
end

local function terase( t, val )
	assert( type(t) == "table" )

	for k,v in pairs(t) do
		if v == val then
			t[k] = nil
			return
		end
	end
end

local function tcount( t )
	assert( type(t) == "table" )

	local count = 0
	for k,v in pairs(t) do
		count = count + 1
	end
	
	return count
end

local function stringize( t, maxRecurse, tlist, indent )

	if indent == nil then indent = 0 end
	maxRecurse = maxRecurse or -1

	if type(t) == "table" and maxRecurse ~= 0 then
		local s = tostring(t) .. "\n" .. string.rep(" ", indent) .. "{\n"
		indent = indent + 4
		for k,v in pairs(t) do
			if tlist == nil or indexOf(tlist, v) == nil then
				if tlist == nil then tlist = {} end
				tlist[#tlist + 1] = v
				s = s .. string.rep(" ", indent) .. tostring(k) .." = " ..stringize(v, maxRecurse - 1, tlist, indent) ..",\n"
			else
				s = s .. string.rep(" ", indent) .. tostring(k) .." = " ..tostring(v) .. ",\n"
			end
		end
		indent = indent - 4
		s = s .. string.rep(" ", indent) .. "}"
		return s
	else
		return tostring(t)
	end
end

local function tostringl( t, maxRecurse )

	maxRecurse = maxRecurse or 3

	if type(t) == "table" and maxRecurse ~= 0 then
		local s = "{ "
		local c = ""
		for k,v in pairs(t) do
			if type(v) ~= "function" then
				if type(k) == "number" then
					s = s .. c .. tostringl( v, maxRecurse - 1 )
				else
					s = s .. c .. tostring(k) .." = " ..tostringl( v, maxRecurse - 1 )
				end
				c = ", "
			end
		end
		s = s .. " }"
		return s
	else
		return tostring(t)
	end
end

-- returns a deep copy of the table parameter
local function tcopy( tt )

	local copy = {}

	for k,v in pairs( tt ) do
		if( type(v) == "table" ) then
			copy[k] = tcopy( v )
		else
			copy[k] = v
		end
	end

	return copy
end

-- concatenates fields (deep copy) of t2 to t1
local function tconcat( t1, t2 )
  for k,v in pairs( t2 ) do
	if( type(v) == "table" ) then
	  v = tcopy( v )
	end

	t1[k] = v
  end

end

-- concatenates fields (shallow copy) of t2 to t1
local function tmerge( t1, t2 )
  for k,v in pairs( t2 ) do
	if type(k) == "number" then
		table.insert( t1, v )
	else
		t1[k] = v
	end
  end

  return t1
end

-- "inherits" a table.
function inherit( tbase )

	return function( t )
		tbase.__index = tbase
		return setmetatable( t, tbase )
	end
end

-- "extends" a table.  Recursively copies all elements of tbase into an overrides table
-- Usage: t = extend( tbase ) { a = "override", c = { "override" } }

local function extend( tbase )
	local function tcopy( t1, t2 )
		assert( type(t1) == "table" and type(t2) == "table", string.format("type(t1) == %s, type(t2) == %s", type(t1), type(t2)) )
		-- Deep-merge all of t1 into t2
		for k,v in pairs( t1 ) do
			if type(v) == "table" then
				if t2[k] == nil then
					t2[k] = tcopy( v, {} )
				else
					tcopy( v, t2[k] )
				end
			else
				if t2[k] == nil then
					t2[k] = v
				else
					assert( type(t2[k]) == type(v) )
				end
			end
		end
			
		return t2
	end
	
	return function( t )
		if tbase == nil then
			return t
		else
			return tcopy( tbase, t )
		end
	end
end

-- performs a binary search on a sorted array (t), returning an index range where the value is located
-- t : a table with numeric indices where the elements follow a total orderering
-- v : the value to search.  elements are compared with the < or > operator, unless the comparator function is passed
-- fn : a comparator function that compares two values, returning < 0, 0, or > 0 respectively if the left parameter is ordered before the right

local function defaultfn( lhs, rhs )
	if lhs == rhs then
		return 0
	elseif lhs < rhs then
		return -1
	else
		return 1
	end
end

local function binarySearch( t, v, fn )
	
	if fn == nil then
		fn = defaultfn
	end

	local a, b, mid = 1, #t, 0

	while a <= b do
		-- calculate mid
		mid = math.floor((a + b)/2)

		-- compare elements
		local cmp = fn( t[mid], v )
		if cmp < 0 then -- t[mid] < v, search above mid
			a = mid + 1
		elseif cmp > 0 then -- t[mid] > v, search below mid
			b = mid - 1
		else -- equal values
			local l, r = mid, mid + 1

			while l > 1 and fn(t[l - 1], v) == 0 do
				l = l - 1
			end

			while r < #t and fn(t[r], v) == 0 do
				r = r + 1
			end

			return l,r
		end
	end

	return a,a
end

local function makeDelegate( obj, fn, ... )
	return { _obj = obj, _fn = fn, ... }
end

local function callDelegate( delegate, ...)
	if delegate._fn == nil then
		return
	end
	local t = {}
	for k,v in pairs(delegate) do
		if type(k) == "number" then
			t[k] = v
		end
	end
	local n = #t
	for k,v in pairs({...}) do
		t[k + n] = v
	end
		
	if delegate._obj then
		assert(delegate._obj[delegate._fn], tostring(delegate._obj) .. " doesn't have function " ..tostring(delegate._fn))
		delegate._obj[delegate._fn]( delegate._obj, unpack(t, 1, table.maxn(t)) )
	else
		delegate._fn( unpack(t, 1, table.maxn(t)) )
	end
end

local function ftime( secs )
	local m = math.floor(secs / 60)
	local s = secs % 60
	return string.format( "%d:%02d", m, s )
end

local function toRGBA( n )
	local r = binops.shiftr(n, 24)
	local g = binops.b_and( binops.shiftr(n, 16), 0x000000FF )
	local b = binops.b_and( binops.shiftr(n, 8), 0x000000FF )
	local a = binops.b_and( binops.shiftr(n, 0), 0x000000FF )

	-- Return as float components.
	return r / 255, g / 255, b / 255, a / 255
end


return
{
    ModuleName = "util",

	indexOf = indexOf,
	indexPairs = indexPairs,
	tcount = tcount,
	terase = terase,
	stringize = stringize,
	tostringl = tostringl,
	tcopy = tcopy,
	tconcat = tconcat,
    tmerge = tmerge,
	inherit = inherit,
	extend = extend,
	binarySearch = binarySearch,
	ftime = ftime,

	toRGBA = toRGBA,

	makeDelegate = makeDelegate,
	callDelegate = callDelegate,
}
