-----------------------------------------------------
-- MOAI UI
-- Copyright (c) 2012-2012 Klei Entertainment Inc.
-- All Rights Reserved.

local array = require( "modules/array" )
local util = require( "modules/util" )
local mui_widget = require( "mui/widgets/mui_widget" )
require( "modules/class" )

--------------------------------------------------------

local DEFAULT_IMAGE = "default.png"

local function loadImages( mui, imageFiles )

	local images = {}
	if type(imageFiles) == "string" then
		local imagefile = mui.resolveFilename( imageFiles )
		if imagefile then
			images[1] = MOAIImage.new()
			images[1]:load( mui.resolveFilename( imageFiles ))
		end
	elseif type(imageFiles) == "table" then
		for i,imageState in ipairs(imageFiles) do
			local imagefile = mui.resolveFilename( imageState.file )
			if imagefile then
				local image = MOAIImage.new()
				image:load( mui.resolveFilename( imageState.file ) )
				table.insert( images, image )
			end
		end
	end

	return images
end

local function createImage( images, w, h )

	local gfxQuad = MOAIGfxQuad2D.new ()
	gfxQuad:setTexture( images[1] )
	gfxQuad:setRect (  -w / 2, h / 2, w / 2, -h / 2 )
	gfxQuad:setUVRect ( 0, 0, 1, 1 )

	local prop = MOAIProp2D.new ()
	prop:setBlendMode( MOAIProp.BLEND_NORMAL )
	if images[1] then
		prop:setDeck( gfxQuad )
	end

	return prop, gfxQuad
end

--------------------------------------------------------

local mui_image = class( mui_widget )

function mui_image:init( mui, def )

	self._mui = mui
	self._images = loadImages( mui, def.images )

	local prop
	prop, self._deck = createImage( self._images, def.w, def.h )
	
	mui_widget.init( self, prop, def )
end

function mui_image:setSize( w, h )
	self._deck:setRect( -w/2, h/2, w/2, -h/2 )
end

function mui_image:setColor( r, g, b, a )
	self._prop:setColor( r, g, b, a )
end

function mui_image:setScale( sx, sy )
	self._prop:setScl( sx, sy )
end

function mui_image:setImage( imgFilename )
	local imagefile = self._mui.resolveFilename( imgFilename )
	if not imagefile then
		imagefile = self._mui.resolveFilename( DEFAULT_IMAGE )
	end

	if imagefile then
		self._deck:setTexture( imagefile )
		self._prop:setDeck( self._deck )
	else
		self._prop:setDeck(nil)
	end
end

function mui_image:setImageIndex( idx )
	if self._images[idx] then
		self._deck:setTexture( self._images[idx] )
		self._prop:setDeck( self._deck )
	else
		self._prop:setDeck(nil)
	end
end

function mui_image:setImageAtIndex( imgFilename, idx )
	local imagefile = self._mui.resolveFilename( imgFilename )
	if not imagefile then
		imagefile = self._mui.resolveFilename( DEFAULT_IMAGE )
	end
	local image = self._images[idx]
	if image == nil then
		image = MOAIImage.new()
	end
	image:load( imagefile )
end

return mui_image

