----------------------------------------------------------------
-- Localization macros

return
{
    -- List things:
    -- "foo"
    -- "foo and bar"
    -- "foo, bar, and foobar"
    listing = function( t )
        local concat = t[1]
        for i = 2, #t - 1 do
            concat = concat .. ", " ..t[i]
        end
        if #t >= 3 then
            concat = concat .. ", and " .. t[#t]
        elseif #t >= 2 then
            concat = concat .. " and " .. t[#t]
        end
        return concat
    end,

    comma_listing = function( t )
        local concat = t[1]
        for i = 2, #t do
            concat = concat .. ", " ..t[i]
        end
        return concat
    end,

    number_postfix = function( n )
        if n == 0 then
            return "0th"
        elseif n == 1 then
            return "1st"
        elseif n == 2 then
            return "2nd"
        elseif n == 3 then
            return "3rd"
        else
            return string.format( "%sth", n )
        end
    end,

    concat_line = function( s )
        if s ~= nil then
            return "\n"..tostring(s)
        else
            return ""
        end
    end,

    a_an = function( str )
        local c = loc.tolower( str:sub(1,1) )
        if c == "a" or c == "e" or c == "i" or c == "o" or c == "u" then
            return "an"
        else
            return "a"
        end
    end, 

    colour = function( rgba )
        return "#"..MakeColourString( HexColour( rgba ))
    end,

    binding = function ( control )
        return string.format( "<#WHITE>[%s]</>", TheGame:GetInput():GetBoundKeyString( control ))
    end,

    -- Percentage, 0 places of precision.
    percent = function( num )
        local percent = num * 100
        if percent < 0 then
            return string.format( "-%.0f%%", -percent )
        else
            return string.format( "%.0f%%", percent )
        end
    end,

    -- Signed percent, 0 places of precision.
    spercent = function( num )
        num = num or 0
        return string.format( "%+g%%", num * 100 )
    end,
}
