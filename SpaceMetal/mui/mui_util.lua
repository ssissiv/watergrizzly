-----------------------------------------------------
-- MOAI UI
-- Copyright (c) 2012-2012 Klei Entertainment Inc.
-- All Rights Reserved.

local mui_defs = require("mui/mui_defs")

local function isMouseEvent( ev )
	return
		ev.type == mui_defs.EVENT_MouseDown or
		ev.type == mui_defs.EVENT_MouseUp or
		ev.type == mui_defs.EVENT_MouseMove
end

return
{
	isMouseEvent = isMouseEvent
}

