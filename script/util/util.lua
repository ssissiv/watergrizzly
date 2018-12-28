require "util/class"
require "util/Colour"
require "util/Math"
require "util/iterators"
require "util/table"
require "util/random"
require "util/saveload"
easing = require "util/easing"
Serpent = require "util/serpent"

local util = class( "Util" )

function generic_error( err )
    return debug.traceback( err, 2 )
end

function true_function()
    return true
end

function nil_function()
    return nil
end

function deepcompare(a,b)
   if type(a) ~= type(b) then return false end
   
   if type(a) == "table" then
        for k,v in pairs(a) do
            if not deepcompare(v, b[k]) then return false end 
        end

        for k,v in pairs(b) do
            if a[k] == nil then return false end
        end

        return true
   else
        return a == b
    end
end

function clamp(val, min, max)
    if min and val < min then
        val = min
    end

    if max and val > max then
        val = max
    end

    return val
end

-- a delegate is an array with t[1] as a function, and t[2...n] as additional optional parameters.
-- Furthermore, the additional parameters ... are appended to the invocation.
-- For the sake of flexibility, delegate might directly be a function.
function call_delegate( delegate, ... )
    if type(delegate) == "function" then
        return delegate( ... )
    elseif type(delegate) == "table" then
        assert( type(delegate[1]) == "function" )
        local args = { table.unpack( delegate, 2 ) }
        local n = select( "#", ... )
        for i = 1, n do
            local p = select( i, ... )
            table.insert( args, p )
        end
        return delegate[1]( table.unpack( args ))
    end
end

local TREFS = {}
function tostr( t, maxRecurse, indent )
    table.clear( TREFS )

    if indent == nil then indent = 0 end
    maxRecurse = maxRecurse or 1

    if type(t) == "table" and maxRecurse ~= 0 then
        local s = tostring(t) .. "\n" .. string.rep(" ", indent) .. "{\n"
        indent = indent + 4
        for k,v in pairs(t) do
            if table.arrayfind  (TREFS, v) == nil then
                TREFS[#TREFS + 1] = v
                s = s .. string.rep(" ", indent) .. tostring(k) .." = " ..tostr(v, maxRecurse - 1, indent) ..",\n"
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

function rawstring( t )
    local mt = getmetatable( t )
    if mt then
        -- Seriously, is there any better way to bypass the tostring metamethod?
        setmetatable( t, nil )
        local s = tostring( t )
        setmetatable( t, mt )
        return s
    else
        return tostring(t)
    end
end

local pow = math.pow 
local floor = math.floor
local fmod = math.fmod
local sin = math.sin
local cos = math.cos
local atan2 = math.atan2
local abs = math.abs
local floor = math.floor

-- constrain angle delta to [-PI, PI]
function normalizeDelta(angle)
    return atan2(sin(angle), cos(angle))
end

function reduceangle(angle)
    angle = (angle > 2*PI or angle < 0) and fmod(angle, 2*PI) or angle
    if angle < 0 then 
        angle = angle + 2*PI 
    end
    return angle
end

function angledist(src, dest)
    return ((reduceangle(dest) - reduceangle(src)) + PI) % (2*PI) - PI
end

function arclength(angle, radius)
    return angle * radius
end

function arcToAngle(arclength, radius)
    return arclength / radius
end

function rotate2d( dx, dy, theta )
    return dx * math.cos(theta) - dy * math.sin(theta), dx * math.sin(theta) + dy * math.cos(theta)
end

-- Pick a random point within a circle at (x0, y0) with radius.
function randomPoint( radius, x0, y0 )
    local phi = math.random() * 2 * math.pi
    local r = math.random() * radius
    return r * math.cos( phi ) + x0, r * math.sin( phi ) + y0
end

-- true if the short direction from angle1 to angle2 is clockwise, false otherwise
function clockwise(angle1, angle2)
    return angledist(angle1, angle2) < 0
end

function truncnum(f, dec)
    local m = pow(10, dec or 2)
    return floor(f * m) / m
end

function normalizeVec3(x,y,z)
    local mag = math.sqrt(x*x+y*y+z*z)
    if mag > 0 then
        return x/mag, y/mag, z/mag
    end
    return 0,0,0
end

function normalizeVec2(x,y)
    local mag = math.sqrt(x*x+y*y)
    if mag > 0 then
        return x/mag, y/mag
    end
    return 0,0
end

function distsq(x1, y1, x2, y2)
    local dx = x2-x1
    local dy = y2-y1
    return dx*dx + dy*dy
end

function distance(x1, y1, x2, y2)
    local dx = x2-x1
    local dy = y2-y1
    return math.sqrt( dx*dx + dy*dy )
end

function dot( x1, y1, x2, y2 )
    return x1 * x2 + y1 * y2
end

function weightedpick(options)
    local total = 0
    for k,v in pairs(options) do
        total = total + v
    end
    local rand = math.random()*total
    
    local option = next(options)
    while option do
        local wt = options[option]
        rand = rand - wt
        if rand <= 0 then
            return option, wt
        end
        option = next(options, option)
    end
    assert(option, "weighted random is messed up")
end

-- Choose a random number in a gaussian distribution.
-- Based on the polar form of the Box-Muller transformation.
function math.randomGauss( mean, stddev )
	local x1, x2, w
	repeat
		x1 = 2 * math.random() - 1
		x2 = 2 * math.random() - 1
		w = x1 * x1 + x2 * x2
	until w < 1.0

	w = math.sqrt( (-2 * math.log( w ) ) / w )
	return (x1 * w)*stddev + mean
end

function printf(fmt, ...)
    print(string.format(fmt, ...))
end

function string:split( inSplitPattern, outResults )
   if not outResults then
      outResults = { }
   end
   local theStart = 1
   local theSplitStart, theSplitEnd = string.find( self, inSplitPattern, theStart )
   while theSplitStart do
      table.insert( outResults, string.sub( self, theStart, theSplitStart-1 ) )
      theStart = theSplitEnd + 1
      theSplitStart, theSplitEnd = string.find( self, inSplitPattern, theStart )
   end
   table.insert( outResults, string.sub( self, theStart ) )
   return outResults
end

local _ENUM_META =
{
    __index = function( t, k ) error( "BAD ENUM ACCESS: "..tostring(k) ) end,
    __newindex = function( t, k, v ) error( "BAD ENUM ACCESS "..tostring(k) ) end,
}

function MakeEnum(args)
    local enum = {}
    for k,v in ipairs(args) do
        assert(type(v) == "string", "Enums come from strings")
        enum[v] = v
    end
    setmetatable( enum, _ENUM_META )
    return enum
end

function AppendEnum(enum, args)
    setmetatable( enum, nil )
    for k,v in ipairs(args) do
        assert(type(v) == "string", "Enums come from strings")
        assert(enum[v] == nil, v )
        enum[v] = v
    end
    setmetatable( enum, _ENUM_META )
    return enum
end

function IsEnum( val, enum )
    assert( getmetatable( enum ) == _ENUM_META )
    return val and enum[val] == val
end

function MakeBitField(args)
    local bitfield = { NONE = 0 }
    for k,v in ipairs(args) do
        assert(type(v) == "string", "Bitfields come from strings")
        assert(bitfield[v] == nil)
        bitfield[v] = 2^(k-1)
    end
    return bitfield
end

function HexColour(val)
    return bit32.rshift(bit32.band(val, 0xFF000000), 24)/255,
        bit32.rshift(bit32.band(val, 0xFF0000), 16)/255,
        bit32.rshift(bit32.band(val, 0xFF00), 8)/255,
        bit32.rshift(bit32.band(val, 0xFF), 0)/255
end

function HexColour255(val)
    return bit32.rshift(bit32.band(val, 0xFF000000), 24),
        bit32.rshift(bit32.band(val, 0xFF0000), 16),
        bit32.rshift(bit32.band(val, 0xFF00), 8),
        bit32.rshift(bit32.band(val, 0xFF), 0)
end

function THexColour(val)
    return {HexColour(val)}
end

function LerpColour( c1, c2, t )
    return
    {
        c1[1] * (1-t) + c2[1] * t,
        c1[2] * (1-t) + c2[2] * t,
        c1[3] * (1-t) + c2[3] * t,
        c1[4] * (1-t) + c2[4] * t,
    }
end

function Lerp(x1,x2,t)
    return x1 + x2 * t - x1 * t
end

