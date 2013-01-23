----------------------------------------------------------------
-- Copyright (c) 2010-2011 Zipline Games, Inc. 
-- All Rights Reserved. 
-- http://getmoai.com
----------------------------------------------------------------

package.path = [[./uitool/?.lua;]] .. package.path

editor = require("editor")

local VIEWPORT_WIDTH
local VIEWPORT_HEIGHT

MOAIGfxDevice.setClearColor ( 0, 0, 0, 1 )

--MOAIDebugLines.showStyle( MOAIDebugLines.TEXT_BOX_LAYOUT, true )
--MOAIDebugLines.showStyle( MOAIDebugLines.TEXT_BOX, true )
--MOAIDebugLines.setStyle ( MOAIDebugLines.PROP_MODEL_BOUNDS, 1, 1, 0.0, 0.75 )

--MOAILogMgr.openFile( [[moai.log]] )
	
MOAIEnvironment.setListener( MOAIEnvironment.EVENT_VALUE_CHANGED,
	function( name, val, c )
	
		local isResize = VIEWPORT_WIDTH ~= nil and VIEWPORT_HEIGHT ~= nil
		
		if name == "horizontalResolution" then
			VIEWPORT_WIDTH = val
		elseif name == "verticalResolution" then
			VIEWPORT_HEIGHT = val
		end
		
		if isResize then
			editor.resizeEditor( VIEWPORT_WIDTH, VIEWPORT_HEIGHT )

		elseif VIEWPORT_WIDTH ~= nil and VIEWPORT_HEIGHT ~= nil then

			MOAISim.openWindow ( "test", VIEWPORT_WIDTH, VIEWPORT_HEIGHT )
			editor.initEditor( VIEWPORT_WIDTH, VIEWPORT_HEIGHT )
		end
	end )

---------------------------------------------------------------
-- HOST INTERFACE
---------------------------------------------------------------

function setCamera( x, y, z )
	-- x,y represents the eye point (centre of the camera)
	-- w,h is the width and height (and therefore extends w/2, h/2 from x,y)
	editor.setCamera( x, y, z )
end

function setResolution( w, h )
	editor.setResolution( w, h )
end

function drawRectangle( x0, y0, x1, y1, r, g, b, a )
	editor.drawRectangle( x0, y0, x1, y1, r, g, b, a )
end

function fillRectangle( x0, y0, x1, y1, r, g, b, a )
	editor.fillRectangle( x0, y0, x1, y1, r, g, b, a )
end

function drawLine( x0, y0, x1, y1, r, g, b, a )
	editor.drawLine( x0, y0, x1, y1, r, g, b, a )
end

function drawCircle( x0, y0, radius, r, g, b, a )
	editor.drawCircle( x0, y0, radius, r, g, b, a )
end

function clearShapes()
	editor.clearShapes()
end

function loadScreen( screen )
	editor.loadScreen( screen )
end

