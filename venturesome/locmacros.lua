----------------------------------------------------------------
-- Localization macros

return
{
	-- Percentage, 0 places of precision.
	percent = function( num )
		local percent = math.floor( num * 100 )
		if percent < 0 then
			return "-%"..tostring(math.abs(percent))
		else
			return "%"..tostring(percent)
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

