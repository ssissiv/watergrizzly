local util = {}

function generic_error( err )
    return debug.traceback( err, 2 )
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

--doesn't handle circular references
function util.deepcopy(t)
   if type(t) ~= "table" then return t end

   local t2 = {}
   for k,v in pairs(t) do
        if type(v) == "table" then
            t2[k] = util.deepcopy(v)
        else
            t2[k] = v
        end
    end
   return t2
end

function util.shallowcopy(orig, dest)
    local copy
    if type(orig) == 'table' then
        copy = dest or {}
        for k, v in pairs(orig) do
            copy[k] = v
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

local getinfo = debug.getinfo
local max = math.max
local concat = table.concat

local function filtersource(src)
    if not src then return "[?]" end
    if src:sub(1, 1) == "@" then
        src = src:sub(2)
    end
    return src
end

local function formatinfo(info)
    if not info then return "**error**" end
    local source = filtersource(info.source)
    if info.currentline then
        source = source..":"..info.currentline
    end
    return ("\t%s in (%s) %s (%s) <%d-%d>"):format(source, info.namewhat, info.name or "?", info.what, info.linedefined, info.lastlinedefined)
end

function debugstackline(start)
    local info = getinfo(start+1)
    local source = filtersource(info.source)
    if info.currentline then
        source = source..":"..info.currentline
    end
    return source
end

function debugstack(start, top, bottom)
        if not bottom then bottom = 10 end
        if not top then top = 12 end
        start = (start or 1) + 1

        local count = max(2, start)
        while getinfo(count) do
            count = count + 1
        end

        count = count - start

        if top + bottom >= count then
            top = count
            bottom = nil
        end

        local s = {"stack traceback:"}
        for i = 1, top, 1 do
            s[#s + 1] = formatinfo(getinfo(start + i - 1))
        end
        if bottom then
            s[#s + 1] = "\t..."
            for i = bottom , 1, -1 do
                s[#s + 1] = formatinfo(getinfo(count - i + 1))
            end
        end

        return concat(s, "\n")
end

function table_diff(from, to)
    local diff = 
    {
        remove = {},
        merge = {},
        add = {},
    }

    for k,v in pairs(from) do
        local t = to[k]
        if t == nil then
            diff.remove[k] = true
        else
            if type(t) == "table" then
                local d = table_diff(v, t)
                if d then
                    diff.merge[k] = d
                end
            else
                if v ~= t then
                    diff.merge[k] = t
                end
            end
        end
    end

    for k,v in pairs(to) do
        local f = from[k]
        if f == nil then
            diff.add[k] = v
        end
    end

    if not next(diff.remove) then
        diff.remove = nil
    end
    if not next(diff.merge) then
        diff.merge = nil
    end
    if not next(diff.add) then
        diff.add = nil
    end

    if next(diff) then
        return diff
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

function table.transform( t, fn )
    local j, n = 1, #t
    for i = 1, #t do
        local v = fn( t[i] )
        if j < i then
            t[i] = nil
        end
        t[j] = v
        if v ~= nil then
            j = j + 1
        end
    end
end

function table.range( a, b )
    local t = {}
    for i = a, b do
        table.insert( t, i )
    end
    return t
end

function table.arrayremove(t, v)
    for k = 1, #t do
        if t[k] == v then
            table.remove(t, k)
            return true
        end
    end
    return false
end

function table.arraycontains(t, v)
    for k = 1, #t do
        if t[k] == v then
            return true
        end
    end
    return false
end

function table.arrayfind(t, v)
    for i, tv in ipairs(t) do
        if tv == v then
            return i
        end
    end
    return nil
end

function table.find(t, v)
    for k, tv in pairs(t) do
        if tv == v then
            return k
        end
    end
    return nil
end

function table.clear(t)
    for k,v in pairs(t) do
        t[k] = nil
    end
end

function table.reverse(t)
    local len = #t
    local half = math.floor(len /2)
    for k = 1, half do
        t[k], t[len - (k-1)] =  t[len - (k-1)], t[k]
    end
end

function table.count( t )
    local count = 0
    for k,v in pairs(t) do
        count = count + 1
    end
    return count
end

function table.shuffle(array, start_index, end_index)
    
    start_index = start_index or 1
    end_index = end_index or #array

    local arrayCount = end_index - start_index + 1
    
    for i = end_index, start_index+1, -1 do
        local j = math.random(start_index, i)
        array[i], array[j] = array[j], array[i]
    end
    return array
end

function table.add(dst, src)
    for k,v in pairs(src) do
        assert(dst[k] == nil, "Merging duplicate into table")
        dst[k] = v
    end
end

function table.arrayadd(dst, src)
    for i,v in ipairs(src) do
        table.insert(dst, v)
    end
end

function table.insert_unique( t, val )
    for k, v in pairs(t) do
        if v == val then
            return
        end
    end
    table.insert( t, val )
end

function table.merge( ... )
    local t = {}
    for i = 1, select( "#", ... ) do
        local t2 = select( i, ... )
        table.arrayadd( t, t2 )
    end
    return t
end

function table.inherit( tbase, t )
    local tnew = shallowcopy( tbase ) -- note: shallow inheritance.
    for k, v in pairs(t) do
        tnew[k] = v
    end
    return tnew
end

table.empty = readonly({})

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

function straightline_entity_distsq(first, second)

    local x1, y1, z1 = first:GetWorldPosition()
    local x2, y2, z2 = second:GetWorldPosition()

    return (x1-x2)*(x1-x2) + (y1-y2)*(y1-y2) + (z1-z2)*(z1-z2)
end

function entity_facing( e1, e2 )
    local x1, y1, z1 = e1:GetWorldPosition()
    local x2, y2, z2 = e2:GetWorldPosition()
    local dx, dz = x2 - x1, z2 - z1
    return math.atan( -dx, -dz )
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

function Dict(args)
    local t = {}
    for k,v in ipairs(args) do
        t[v] = v
    end
    return t
end


local gc_running = true
function StopGC()
    collectgarbage("stop")
    gc_running = false
end

function StartGC()
    collectgarbage("restart")
    gc_running = true
end

function DoFullGC()
    collectgarbage("collect")
    if not gc_running then
        collectgarbage("stop")
    end
end

function StepGC()
    return collectgarbage("step", 0)
end


--finds the first index where val would be inserted to preserve ordering in the table t
local default_cmp = function(a,b) return a < b end
function table.binsearch(t, val, cmp)
    cmp = cmp or default_cmp
    local len = #t
    local min_idx = 1
    local max_idx = len--math.floor(len/2)

    while min_idx <= max_idx do
        local idx = math.floor((min_idx + max_idx)*.5)
        
        if cmp(t[idx], val) then
            min_idx = idx + 1
        else
            max_idx = idx - 1
        end
    end
    return min_idx
end

function table.binsert(t, val, cmp)
    local idx = table.binsearch(t, val, cmp)
    table.insert(t, idx, val)
end

function table.arraypick( t )
    local num = t and #t or 0
    return num > 0 and t[math.random(num)] or nil
end

function table.tablepick( t )
    local num = table.count( t )
    local i = math.random( num )
    for k, v in pairs(t) do
        i = i - 1
        if i <= 0 then
            return k, v
        end
    end
end

function weightedpick(options)
    local total = 0
    for k,v in pairs(options) do
        total = total + v
    end
    local rand = math.random()*total
    
    local option = next(options)
    while option do
        rand = rand - options[option]
        if rand <= 0 then
            return option
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


function MakePremultColour(r,g,b,a)
    return {r*a, b*a, g*a, a}
end


function Get(tab, ...)
    local out = tab
    for _, e in ipairs({...}) do
       out = out[e]
        if not out then
            return nil
        end
    end
    return out
end

function FilterUnorderedArray(array, fn, param)
    local len = #array
    local idx = 1
    while idx <= len do
        local val = array[idx]
        if fn(val, param) then
            idx = idx + 1
        else
            array[idx] = array[len]
            array[len] = nil
            len = len - 1
        end
    end
end

-- t is just any-old table.  Return a new sorted table as an array of the form
-- { k0, v0, k1, v1, k2, v2, ... } where <kn, vn> are the elements from t sorted by key.
local _sorted_t = {}
local function sort_cmp(a, b)
    local anum, bnum = type(a) == "number", type(b) == "number"
    if anum and bnum then
        return a < b
    elseif anum then
        return true
    elseif bnum then
        return false
    else
        return tostring(a) < tostring(b)
    end
end

function CreatedSortedKeyValues( t )
    table.clear( _sorted_t )
    for k, v in pairs( t ) do
        table.binsert( _sorted_t, k, sort_cmp )
    end
    local n = #_sorted_t
    for i = n, 1, -1 do
        table.insert( _sorted_t, i + 1, t[_sorted_t[i]] )
    end
    return _sorted_t
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

function DoStringFormatting(str)
    if str then
        -- hard coded colour overrides don't really work when you don't know what the background color is
        -- str = string.gsub(str, "\"(.-)\"", [[<#555500ff>"%1"</>]])
        -- str = string.gsub(str, "<b>(.-)</b>", [[<#007755ff>%1</>]])
        str = string.gsub(str, "<b>(.-)</b>", [[%1]])
        str = string.gsub(str, "<br/>", "\n\n")
        return str
    end
end

function SetFormattedText( textnode, str )
    str = DoStringFormatting(str)
    if textnode then
        textnode:ClearMarkup()
    end
    local j, k, sel, attr
    local spans = {}
    repeat
        -- find colourization.
        j, k, sel, attr = str:find( "<([#!/])([^>]*)>" )
        if j then
            if sel == '/' then
                -- Close the last span
                local attr = table.remove( spans )
                local sel = table.remove( spans )
                local start_idx = table.remove( spans )
                local end_idx = j-1
                if textnode then
                    if sel == '#' then
                        while #attr < 8 do attr = attr .. "f" end
                        if tonumber( attr, 16 ) then
                            textnode:AddMarkup( start_idx, end_idx, engine.rendering.TextNode.MARKUP_COLOUR, tonumber( attr, 16 ))
                        end
                    elseif sel == '!' and attr then
                        local jj, kk, subattr, clr = attr:find( "^(.*)#(%x%x%x%x%x%x%x?%x?)$" )
                        if clr then
                            textnode:AddMarkup( start_idx, end_idx, engine.rendering.TextNode.MARKUP_LINK, subattr, tonumber( clr, 16 ))
                        else
                            textnode:AddMarkup( start_idx, end_idx, engine.rendering.TextNode.MARKUP_LINK, attr )
                        end
                    else
                        print( "Closing unknown text markup code" )
                    end
                end
            else
                table.insert( spans, j - 1 )
                table.insert( spans, sel )
                table.insert( spans, attr )
            end
            str = str:sub( 1, j - 1 ) .. str:sub( k + 1 )
        end
    until not j

    if textnode then
        textnode:SetText( str )
    end

    --assert( #spans == 0, string.format( "Badly formatted text:", rawstr ) )
    return str
end


function LOC( str )
    return TheGame:Str( str )
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

return util
