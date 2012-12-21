-----------------------------------------------------
-- MOAI UI
-- Copyright (c) 2012-2012 Klei Entertainment Inc.
-- All Rights Reserved.

local array = require( "modules/array" )
local mui_screen = require( "mui/mui_screen" )
local mui_defs = require( "mui/mui_defs" )
local mui_label = require( "mui/widgets/mui_label" )
local mui_editbox = require( "mui/widgets/mui_editbox" )
local mui_image = require( "mui/widgets/mui_image" )
local mui_imagebutton = require( "mui/widgets/mui_imagebutton" )
local mui_checkbox = require( "mui/widgets/mui_checkbox" )
local mui_spinner = require( "mui/widgets/mui_spinner" )
local mui_group = require( "mui/widgets/mui_group" )
local mui_listbox = require( "mui/widgets/mui_listbox" )

local MUI =
{
	-- List of active screens
	_activeScreens = {},
	-- Loaded filenames
	_files = {},
	-- Loaded skins
	_skins = {},
	-- Factory for creating widgets
	_widgetFactory = {},
	-- Text styles
	_textStyles = {},
	-- resolves resource paths
	_fileResolver = nil,
	-- table for internal interface
	_internals = {}
}

local function resolveFilename( filename )
	if MUI._fileResolver then
		return MUI._fileResolver( filename )
	end

	return filename
end

local function processWidgetDef( def )

	if def.skin then
		local skin = MUI._skins[ def.skin ]
		assert(skin, "Skin not found: " ..def.skin)
		def = inherit( skin )( def )
	end
	
	if type(def.text_style) == "string" and #def.text_style > 0 then
		assert(MUI._textStyles[ def.text_style ], "Text style not found: " ..def.text_style)
		def.text_style = MUI._textStyles[ def.text_style ]
	end
	
	def.all_styles = MUI._textStyles

	return def
end

local function handleInputEvent( event )

	local handled = false

	for i,screen in ipairs(MUI._activeScreens) do
	
		event.x, event.y = screen:wndToUI( event.wx, event.wy )
		handled = screen:handleInputEvent( event )

		if handled then
			break
		end
	end

	return handled
end

local function createWidget( def )
	def = processWidgetDef( def )
	local ctor = MUI._widgetFactory[ def.ctor ]
	assert( type(ctor) == "function",
		string.format( "No factory for widget '%s', type '%s'", 
		tostring(def.name), tostring(def.ctor)))

	local widget = ctor( def )
	assert( widget )

	return widget
end

local function createFromSkin( skinName )
	local def = processWidgetDef( { skin = skinName } )
	return createWidget( def )
end

local function createLabel( def )
	def = processWidgetDef( def )
	return mui_label( def )
end

local function createEditBox( def )
	def = processWidgetDef( def )
	return mui_editbox( def )
end

local function createImage( def )
	def = processWidgetDef( def )
	local widget = mui_image( MUI._internals, def )
	if def.color then
		widget:setColor( unpack( def.color ))
	end
	
	return widget
end

local function createButton( def )
	return mui_imagebutton( MUI._internals, processWidgetDef( def ))
end

local function createCheckbox( def )
	return mui_checkbox( MUI._internals, processWidgetDef( def ) )
end

local function createSpinner( def )
	return mui_spinner( MUI._internals, processWidgetDef( def ) )
end

local function createGroup( def )
	return mui_group( MUI._internals, processWidgetDef( def ) )
end

local function createListBox( def )
	return mui_listbox( MUI._internals, processWidgetDef( def ) )
end

local function getStyles()
	return MUI._textStyles
end

local function parseUI( key, t )

	-- reloaded by the tool.  perhaps have an explicit unload?
	--assert( MUI._files[ key ] == nil )
	MUI._files[ key ] = t

	if t.dependents then
		for i,filename in ipairs(t.dependents) do
			if MUI._files[ filename ] == nil then
				local t = dofile( resolveFilename( filename ))
				assert(t)
				parseUI( filename, t )
			end
		end
	end

	-- Load any specified text styles into the global text styles list.
	if t.text_styles then
		for k,styledef in pairs(t.text_styles) do
			local fontfile = resolveFilename(styledef.font)
			assert( styledef.font and styledef.chars and styledef.size )
			assert( MOAIFileSystem.checkFileExists( fontfile ), styledef.font .. " does not exist!")

			local font = MOAIFont.new ()
			font:loadFromTTF ( fontfile, styledef.chars, styledef.size, styledef.dpi )
			
			local style = MOAITextStyle.new()
			style:setColor( unpack(styledef.color) )
			style:setFont( font )
	--		style:setSize( styledef.size )
			style:setScale( 1 / MUI._width, 1 / MUI._height )

			MUI._textStyles[ k ] = style
		end
	end
	
	-- Load any specified into the global list of skins.
	if t.skins then
		for i,skin in ipairs(t.skins) do
			assert( skin.name )
			assert( MUI._skins[ skin.name ] == nil, "Loading duplicate skin " ..skin.name )
			MUI._skins[ skin.name ] = skin
		end
	end
end


local function loadUI( filename )

	if MUI._files[ filename ] == nil then
		assert( resolveFilename( filename ))
		local t = dofile( resolveFilename( filename ))
		parseUI( filename, t )
	end
end


local function createScreen( filename )

	-- Load if it doesn't already exist.
	if type(filename) == "string" and not MUI._files[ filename ] then
		loadUI( filename )
	end

	-- Instantiate the widgets.
	if MUI._files[ filename ] then
		assert( MUI._files[ filename ].widgets, "Creating screen for " ..filename.. ", but no widgets specified.")

		local screen = mui_screen( MUI._files[ filename ].properties, filename )

		for i,def in ipairs(MUI._files[ filename ].widgets) do
			local widget = createWidget( def )
			screen:addWidget( widget )
		end

		return screen

	else
		return mui_screen()
	end
end

local function activateScreen( screen )
	assert( array.find( MUI._activeScreens, screen ) == nil )
	
	screen:onActivate( MUI._width, MUI._height )
	
	table.insert( MUI._activeScreens, 1, screen )
	table.sort( MUI._activeScreens,
		function( screen1, screen2 )
			return screen1:getPriority() > screen2:getPriority()
		end )
	
	local renderTable = MOAIRenderMgr.getRenderTable() or {}
	for i = #MUI._activeScreens,1,-1 do
		local screen = MUI._activeScreens[i]
		array.removeElement( renderTable, screen:getLayer() )
		table.insert( renderTable, screen:getLayer() )
	end
	MOAIRenderMgr.setRenderTable( renderTable )
end

local function deactivateScreen( screen )
	assert( array.find( MUI._activeScreens, screen ) ~= nil )
	
	screen:onDeactivate()

	array.removeElement( MUI._activeScreens, screen )

	local renderTable = MOAIRenderMgr.getRenderTable()
	array.removeElement( renderTable, screen:getLayer() )
	MOAIRenderMgr.setRenderTable( renderTable )
end

local function onResize( width, height )
	MUI._width, MUI._height = width, height
	
	for k,style in pairs(MUI._textStyles) do
		-- TODO: how do we handle text??
		-- This scales directly to the screen size
		style:setScale( 1 / width, 1 / height)
		
		-- This keeps the text height at a constant relative size to the screen height,
		-- adjusting the x-scale to maintain a constant aspect ratio.
		-- style:setScale( (height / width) * (1 / 320), 1 / 320)
		style:setFont( style:getFont() )
	end
	
	for i,screen in ipairs(MUI._activeScreens) do
		screen:onResize( width, height )
	end
	
end

local function initMui( width, height, fn )

	assert( #MUI._activeScreens == 0 )
	
	MUI._width, MUI._height = width, height
	
	MUI._files = {}
	MUI._skins = {}
	MUI._textStyles = {}

	-- Factory methods for instantiating widgets.  Invoked from loadUI.
	MUI._widgetFactory["button"] = createButton
	MUI._widgetFactory["label"] = createLabel
	MUI._widgetFactory["editbox"] = createEditBox
	MUI._widgetFactory["image"] = createImage
	MUI._widgetFactory["checkbox"] = createCheckbox
	MUI._widgetFactory["spinner"] = createSpinner
	MUI._widgetFactory["group"] = createGroup
	MUI._widgetFactory["listbox"] = createListBox
	
	MUI._fileResolver = fn
end

-- Setup internal interface.  This table is exposed to internal mui systems.
-- Would prefer a more straightforward way of doing this?
MUI._internals =
{
	createWidget = createWidget,
	resolveFilename = resolveFilename,
}

return
{
	handleInputEvent = handleInputEvent,
	
	createFromSkin = createFromSkin,
	createLabel = createLabel,
	createEditBox = createEditBox,
	createImage = createImage,
	createButton = createButton,
	createCheckbox = createCheckbox,
	createSpinner = createSpinner,
	createGroup = createGroup,
	createListBox = createListBox,

	loadUI = loadUI,
	parseUI = parseUI,
	getStyles = getStyles,

	createScreen = createScreen,
	activateScreen = activateScreen,
	deactivateScreen = deactivateScreen,

	onResize = onResize,
	initMui = initMui,
}
