local util = require "util"
local constants = require "constants"
local room = require "room"
local assets = require "assets"
local world_def = require "world_def"
local card_def = require "card_def"
local uicard = require "uicard"
local deck = require "deck"
local ttsys = require "ttsys"
local modal_travel = require "modal_travel"
local modal_camp = require "modal_camp"
local modal_dead = require "modal_dead"
local modal_timeup = require "modal_timeup"

----------------------------------------------

local gstate = {}

function gstate.new()
	local self = util.deepcopy( gstate )
	self.modals = {}
	self.resources =
	{
		[ constants.RESOURCE.PRESTIGE ] = { name = "Prestige", amount = 0, img = assets.IMGS.PRESTIGE },
		[ constants.RESOURCE.TIME ] = { name = "Time", amount = 10, img = assets.IMGS.TIME },
		[ constants.RESOURCE.ACTION ] = { name = "Actions", amount = 1, img = assets.IMGS.PRESTIGE },
		[ constants.RESOURCE.BUYS ] = { name = "Buys", amount = 1, img = assets.IMGS.TIME },
		[ constants.RESOURCE.EXP ] = { name = "EXP", amount = 0, img = assets.IMGS.TIME },
	}
	self.rooms = {}
	for name, room_def in pairs( world_def.rooms ) do
		self.rooms[ name ] = room.new( room_def )
		if name == world_def.start_room then
			self.room = self.rooms[ name ]
		end
	end
	self.deck = deck.new()
	self.deck:addListener( self )
	local init_deck = table.shuffle({ card_def.exp1, card_def.exp1, card_def.exp1, card_def.exp1,
		  card_def.exp1, card_def.exp1, card_def.exp1, 
		  card_def.prestige1, card_def.prestige1, card_def.prestige1 })
	while #init_deck > 0 do
		self.deck:addCard( table.remove( init_deck ))
	end

	self.ui =
	{
		options = {},
	}
	self:initTurn()
	self:push( modal_travel.new( self ) )
	return self
end

function gstate:initTurn()
	self.deck:discardAll()

	self:setResource( constants.RESOURCE.BUYS, 1 )
	self:setResource( constants.RESOURCE.ACTION, 1 )
	self:setResource( constants.RESOURCE.EXP, 0 )

	self.deck:draw( 5 )
end

function gstate:onDrawCard( card )
	if card.on_draw then
		card.on_draw( self )
	end
end

function gstate:onAcquireCard( card )
	if card.on_acquire then
		card.on_acquire( self )
	end
end

function gstate:onTrashCard( card )
	if card.on_trash then
		card.on_trash( self )
	end
end

function gstate:push( modal )
	assert( type(modal.update) == "function" )
	local coro = coroutine.create( modal.update )
	table.insert( self.modals, { modal = modal, coro = coro } )
	self.modal = modal

	self:updateModal( modal, self )
	if self.modal.refreshCards then
		self.modal:refreshCards()
	end
	self:refreshOptions()

	if coroutine.running() then
		return coroutine.yield()
	end
end

function gstate:pop()
	local modal = self.modals[ #self.modals ]
	table.remove( self.modals )
	self.modal = self.modals [ #self.modals ].modal

	if self.modal.refreshCards then
		self.modal:refreshCards()
	end
	self:refreshOptions()
end

function gstate:updateModal( ... )
	local modal = self.modals[ #self.modals ]
	local ok, result = coroutine.resume( modal.coro, ... )
	if not ok then
		error( result .. "\n" .. debug.traceback( modal.coro ) )
	elseif coroutine.status( modal.coro ) ~= "suspended" then
		self:pop()
		self:updateModal( result )
	end
end

function gstate:update()
	if self:getTime() <= 0 then
		self:push( modal_timeup.new( self ) )
	else
		self:updateModal()
	end
end

function gstate:showCards( ... )
	local cards = {}
	for _, card_def in ... do
		local card = uicard.new( card_def )
		table.insert( cards, card )
	end

	table.sort( cards, function (c1, c2) return c1:getDef().name < c2:getDef().name end )

	local dx = (love.graphics.getWidth() - 40) / #cards
	for i, card in ipairs( cards ) do
		local x, y = dx * (i - 1) + 20, 380
		card:moveTo( x, y )
	end
	return cards
end

function gstate:drawResource( x, res )
	local x0 = x
	local amount = self:getResource( res )
	res = self.resources[ res ]
	local font = love.graphics.getFont()
	love.graphics.draw( res.img, x, 10 )
	local txt = string.format( "%s: %d", res.name, amount )
	love.graphics.setColor( 255, 255, 255, 255 )
	--love.graphics.text( txt, x, 10 )
	--x = x + font:getWidth( txt ) + 10
	love.graphics.textf( tostring( amount ), x, 16, res.img:getWidth(), "center" )
	x = x + res.img:getWidth() + 10
	ttsys.inst:addTooltip( x0, 10, x, 32, string.format( "%d %s", amount, res.name ))
	return x
end


function gstate:drawResourceTokens( x, res )
	local amount = self:getResource( res )
	res = self.resources[ res ]
	local txt = res.name .. ":"
	love.graphics.text( txt, x, 10 )
	x = x + font:getWidth( txt ) + 4	
	while amount > 0 do
	end
	
	local font = love.graphics.getFont()
	love.graphics.draw( res.img, x, 10 )
	local txt = string.format( "%s: %d", res.name, amount )
	love.graphics.setColor( 255, 255, 255, 255 )
	--love.graphics.text( txt, x, 10 )
	--x = x + font:getWidth( txt ) + 10
	love.graphics.textf( tostring( amount ), x, 16, res.img:getWidth(), "center" )
	x = x + res.img:getWidth() + 10
	return x
end

function gstate:drawOverlay()
	local font = love.graphics.getFont()
	local x = self:drawResource( 10, constants.RESOURCE.PRESTIGE )
	x = self:drawResource( x, constants.RESOURCE.TIME )
	x = self:drawResource( x, constants.RESOURCE.ACTION )
	x = self:drawResource( x, constants.RESOURCE.BUYS )
	x = self:drawResource( x, constants.RESOURCE.EXP )

	love.graphics.setColor( 255, 255, 255, 255 )
	local txt = string.format( "%s\nCards: %d (%d/%d/%d)", self.modal.name, self.deck:getSizes() )
	love.graphics.text( txt, love.graphics.getWidth() - font:getWidth( txt ) - 10, 10 )
end

function gstate:refreshOptions()
	table.clear( self.ui.options )
	if self.modal.refreshOptions then
		self.modal:refreshOptions( self.ui.options )
	end
end

function gstate:draw()
	love.graphics.setColor( 255, 255, 255, 255 )
	love.graphics.push()
	love.graphics.translate( 0, 64 )
	self.room:draw()
	love.graphics.pop()

	self:drawOverlay()

	-- Options
	for i, opt in ipairs( self.ui.options ) do
		local enabled, reason = self:canDoOption( opt )
		if enabled then
			love.graphics.setColor( unpack( constants.COLOURS.WHITE ))
			love.graphics.text( string.format( "%d) %s", i, opt.desc ), 10, 200 + (i-1) * 20 )
		else
			love.graphics.text( string.format( "<#777777>%d) %s <#ff0000>(%s)</>", i, opt.desc, reason or "" ), 10, 200 + (i-1) * 20 )
		end
	end

	if self.modal.draw then
		self.modal:draw()
	end
end

function gstate:addResource( res, dt )
	self.resources[ res ].amount = self.resources[ res ].amount + dt
end

function gstate:setResource( res, v )
	self.resources[ res ].amount = v
end

function gstate:getResource( res )
	return self.resources[ res ].amount
end

function gstate:passTime( dt )
	self:addResource( constants.RESOURCE.TIME, -dt )
end

function gstate:getTime()
	return self:getResource( constants.RESOURCE.TIME )
end

function gstate:useAction()
	self:addResource( constants.RESOURCE.ACTION, -1 )
end

function gstate:getActions()
	return self:getResource( constants.RESOURCE.ACTION )
end

function gstate:travelTo( to )
	self.room = room.new( world_def.rooms[ to ] )
	self:refreshOptions()
end

function gstate:canDoOption( opt )
	if opt.resources then
		for res, val in pairs(opt.resources) do
			local amount = self:getResource( res )
			if amount < val then
				return false, string.format( "Need %d %s", val, res )
			end
		end
	end
	return true
end

function gstate:doOption( i )
	local opt = self.ui.options[ i ]
	if opt and self:canDoOption( opt ) then
		print( "DO:", opt.desc )

		self.modal.option = opt

		if opt.fn then
			self:push( { option = opt, update = function( self, gstate ) opt.fn( gstate ) end } )
		end

		if opt.to then
			self:useAction()
			self:travelTo( opt.to )

		elseif opt.push then
			local modal = require( opt.push )
			self:push( modal.new( self ) )

		elseif opt.pop then
			self:pop()

		elseif opt.cmd then
			return opt.cmd
		end
	end
end

function gstate:mousepressed( mx, my, button )
	if self.modal.mousepressed then
		self.modal:mousepressed( mx, my, button )
		return
	end

	if self.modal.ui_cards then
		for i = #self.modal.ui_cards, 1, -1 do
			local card = self.modal.ui_cards[i]
			if card:isect( mx, my ) then
				card:select( not card:isSelected() )
				break
			end
		end
		self:refreshOptions()
	end
end

function gstate:keypressed( key, isrepeat, modifiers )
	if self.modal.keypressed then
		return self.modal:keypressed( key, isrepeat )
	end

	if key == "a" and modifiers.ctrl then
		self:addResource( constants.RESOURCE.ACTION, 1 )
	end
end


return gstate