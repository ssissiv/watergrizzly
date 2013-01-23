--==============================================================
-- Copyright (c) 2010-2012 Zipline Games, Inc. 
-- All Rights Reserved. 
-- http://getmoai.com
--==============================================================

require("modules/class")

local filename = "highscore.txt"

----------------------------------------------------------------

local highscore = class()

function highscore:init()
end


function highscore:setScore( n )
	local oldn = self:getScore()
	assert(n>0)
	if oldn < n then
		local fl = io.open( filename, "w" )
		assert(fl)
		if fl then
			fl:write(n)
			fl:close()
			log:write("Wrote high score: %d", n )
		end
	end
end

function highscore:getScore()
	local n = 0
	
	local fl = io.open( filename, "r" )
	if fl then
		n = tonumber(fl:read())
		fl:close()
	end
	return n
end

return highscore

