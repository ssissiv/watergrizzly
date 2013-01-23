----------------------------------------------------------------
-- Copyright (c) 2010-2011 Zipline Games, Inc. 
-- All Rights Reserved. 
-- http://getmoai.com
----------------------------------------------------------------

MOAIFileSystem.setWorkingDirectory( "./../../game/win32" )
package.path = [[.\\client\\?.lua;]] .. package.path

function include( filename )
	return require(filename)
end


mui = require("mui/mui")
mui_defs = require("mui/mui_defs" )
include( "input-manager")

local SHAPE_Rect = 1
local SHAPE_FillRect = 2
local SHAPE_Line = 3
local SHAPE_Circle = 4

local editor =
{
	drawShapes = {},
	
	-- The UI resolution
	resx = 480,
	resy = 320,
	zoom = 1,
	mouseX = nil,
	mouseY = nil,

	screen = nil,
}

local function resolveFilename( filename )
	
	if filename then
		local paths = { [[data/images]], [[data/fonts]], [[data/gui]] }

		for i,path in ipairs(paths) do
			local resolvedPath = path .. "/" .. filename
			if MOAIFileSystem.checkFileExists( resolvedPath ) then
				return resolvedPath
			end
		end
	end

	return nil
end

local function drawBackground()
	MOAIGfxDevice.setPenColor(0.1, 0.1, 0.1, 1 )
	local x0, y0 = editor.layer:wndToWorld( editor.screen:uiToWnd( 0, 0 ) )
	local x1, y1 = editor.layer:wndToWorld( editor.screen:uiToWnd( 1, 1 ) )
	
	MOAIDraw.fillRect( x0, y0, x1, y1 )
end

local function drawForeground()
	for i,shape in ipairs(editor.drawShapes) do
		MOAIGfxDevice.setPenColor(shape.r, shape.g, shape.b, shape.a)
		
		if shape.type == SHAPE_Rect then
			MOAIDraw.drawRect( shape.x0, shape.y0, shape.x1, shape.y1 )
		elseif shape.type == SHAPE_FillRect then
			MOAIDraw.fillRect( shape.x0, shape.y0, shape.x1, shape.y1 )
		elseif shape.type == SHAPE_Line then
			MOAIDraw.drawLine( shape.x0, shape.y0, shape.x1, shape.y1 )
		elseif shape.type == SHAPE_Circle then
			MOAIDraw.drawCircle( shape.x0, shape.y0, shape.radius, shape.steps )
		end
	end
end


local function onMouseWheel( delta )

	if delta > 0 then
		editor.camera:moveScl( 0.1, 0.1 )
	elseif delta < 0 then
		editor.camera:moveScl( -0.1, -0.1 )
	end

end

local function createLayer( viewport, camera, fn )

	local layer = MOAILayer2D.new ()
	layer:setViewport ( viewport )
	layer:setCamera( camera )
	MOAISim.pushRenderPass ( layer )
	
	local scriptDeck = MOAIScriptDeck.new ()
	scriptDeck:setRect ( -64, -64, 64, 64 )
	scriptDeck:setDrawCallback ( fn )

	local prop = MOAIProp2D.new ()
	prop:setDeck ( scriptDeck )
	layer:insertProp ( prop )

	return layer
end

local function initEditor( width, height )

	----------------------------------------------------'
	-- setup GUI first, so that our render layer is on top.
	mui.initMui( editor.resx, editor.resy, resolveFilename )
	
	----------------------------------------------------'

	local viewport = MOAIViewport.new ()
	viewport:setSize ( width, height )
	viewport:setScale( width, height )
	editor.viewport = viewport

	local camera = MOAICamera2D.new()
	camera:setScl( 1/(editor.zoom * editor.resx), 1/(editor.zoom * editor.resy))
	editor.camera = camera

	editor.bglayer = createLayer( viewport, camera, drawBackground )
	editor.layer = createLayer( viewport, camera, drawForeground )
	
	----------------------------------------------------'

	editor.screen = mui.createScreen()
	mui.activateScreen( editor.screen )
	editor.screen:getLayer():setCamera( editor.camera )
end

local function resizeEditor( width, height )

	if not editor.layer then
		-- Can get triggered before initEditor, since creating the window will trigger a resize.
		return
	end

	--print( string.format(" EDITOR IS: %d x %d", width, height ))
	local viewport = MOAIViewport.new ()
	viewport:setSize ( width, height )
	viewport:setScale( width, height )
	editor.viewport = viewport
	
	editor.layer:setViewport ( viewport )
	editor.bglayer:setViewport( viewport )
	editor.screen:getLayer():setViewport( viewport )
end

local function loadScreen( data )

	mui.deactivateScreen( editor.screen )
	
	mui.initMui( editor.resx, editor.resy, resolveFilename )

	local res, err = pcall( mui.parseUI, 0, loadstring( data )() )
	screen = mui.createScreen( 0 )

	editor.screen = screen

	mui.activateScreen( editor.screen )
	editor.screen:getLayer():setViewport( editor.viewport )
	editor.screen:getLayer():setCamera( editor.camera )
	
	MOAIRenderMgr.setRenderTable( { editor.bglayer, editor.screen:getLayer(), editor.layer } )	
	
	if err then
		assert(false, err)
	end
end

local function setCamera( x, y, z )

	editor.zoom = z
	editor.camera:setLoc( x, y )
	editor.camera:setScl( 1/(editor.zoom*editor.resx), 1/(editor.zoom*editor.resy) )
end

local function setResolution( w, h )

	editor.resx, editor.resy = w, h
	editor.camera:setScl( 1/(editor.zoom*editor.resx), 1/(editor.zoom*editor.resy) )
	editor.camera:forceUpdate()

	mui.onResize( editor.resx, editor.resy )
end

function drawRectangle( x0, y0, x1, y1, r, g, b, a )
	table.insert( editor.drawShapes,
		{ type = SHAPE_Rect, x0 = x0, y0 = y0, x1 = x1, y1 = y1, r = r, g = g, b = b, a = a })
end

function fillRectangle( x0, y0, x1, y1, r, g, b, a )
	table.insert( editor.drawShapes,
		{ type = SHAPE_FillRect, x0 = x0, y0 = y0, x1 = x1, y1 = y1, r = r, g = g, b = b, a = a })
end

function drawLine( x0, y0, x1, y1, r, g, b, a )
	table.insert( editor.drawShapes,
		{ type = SHAPE_Line, x0 = x0, y0 = y0, x1 = x1, y1 = y1, r = r, g = g, b = b, a = a })
end

function drawCircle( cx, cy, radius, r, g, b, a )
	table.insert( editor.drawShapes,
		{ type = SHAPE_Circle, x0 = cx, y0 = cy, radius = radius, r = r, g = g, b = b, a = a })
end

local function clearShapes()
	editor.drawShapes = {}
end

return
{
	initEditor = initEditor,
	resizeEditor = resizeEditor,

	loadScreen = loadScreen,

	setCamera = setCamera,
	setResolution = setResolution,

	drawRectangle = drawRectangle,
	fillRectangle = fillRectangle,
	drawLine = drawLine,
	drawCircle = drawCircle,
	clearShapes = clearShapes,
}
