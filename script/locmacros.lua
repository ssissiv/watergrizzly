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
		if type(num) ~= "number" then
			num = 999
		end
		local percent = math.floor( num * 100 )
		if percent > 0 then
			return "+%"..tostring(percent)
		elseif percent < 0 then
			return "-%"..tostring(math.abs(percent))
		else
			return "%"..tostring(percent)
		end
	end,
}

