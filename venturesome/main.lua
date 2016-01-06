local strict = require "strict"
util = require "util"
local constants = require "constants"
local game = nil
local modifiers = { ctrl = false, shift = false, alt = false }
local ttsys = require "ttsys"

-----------------------------------------------------------

function DrawText( str, ... )
    local j, k, sel, attr
    local spans = {}
    repeat
        -- find colourization.
        j, k, sel, attr = str:find( "<([#!/])([^>]*)>" )
        if j then
            if sel == '/' then
                -- Close the last span
                local attr = table.remove( spans )
                local sel = table.remove( spans )
                local start_idx = table.remove( spans )
                local end_idx = j-1
                if textnode then
                    if sel == '#' then
                        while #attr < 8 do attr = attr .. "f" end
                        if tonumber( attr, 16 ) then

                            textnode:AddMarkup( start_idx, end_idx, engine.rendering.TextNode.MARKUP_COLOUR, tonumber( attr, 16 ))
                        end
                    elseif sel == '!' and attr then
                        local jj, kk, subattr, clr = attr:find( "^(.*)#(%x%x%x%x%x%x%x?%x?)$" )
                        if clr then
                            textnode:AddMarkup( start_idx, end_idx, engine.rendering.TextNode.MARKUP_LINK, subattr, tonumber( clr, 16 ))
                        else
                            textnode:AddMarkup( start_idx, end_idx, engine.rendering.TextNode.MARKUP_LINK, attr )
                        end
                    else
                        print( "Closing unknown text markup code" )
                    end
                end
            else
                table.insert( spans, j - 1 )
                table.insert( spans, sel )
                table.insert( spans, attr )
            end
            str = str:sub( 1, j - 1 ) .. str:sub( k + 1 )
        end
    until not j

    if textnode then
        textnode:SetText( str )
    end

    --assert( #spans == 0, string.format( "Badly formatted text:", rawstr ) )
    return str
end

local function drawtext( str, x, y, ... )
	local font = love.graphics.getFont()
	local spans = {} 
	while #str > 0 do
        local j, k, sel, attr = str:find( "<([#!/])([^>]*)>" )
        if not j then
        	j, k = #str + 1, #str
        end

        local substr = str:sub( 1, j - 1 )
        love.graphics.print( substr, x, y, ... )
        str = str:sub( k + 1 )
        x = x + font:getWidth( substr )

		if sel == "/" then
			local thing = table.remove( spans )
			if type(thing) == "table" then
				love.graphics.setColor( unpack( thing ))
			else
				love.graphics.setFont( thing )
				font = thing
			end

		elseif sel == "!" then
			local assets = require "assets"
			if assets.FONTS[ attr ] then
				table.insert( spans, font )
				font = assets.FONTS[ attr ]
				love.graphics.setFont( font )
			else
				print( "No such font:", attr )
			end

		elseif sel == '#' then
            while #attr < 8 do attr = attr .. "f" end
            local r = tonumber( attr:sub( 1, 2 ), 16 )
            local g = tonumber( attr:sub( 3, 4 ), 16 )
            local b = tonumber( attr:sub( 5, 6 ), 16 )
            local a = tonumber( attr:sub( 7, 8 ), 16 )
            table.insert( spans, { love.graphics.getColor() })
            love.graphics.setColor( r, g, b, a )
		end
	end
end

function love.load()
  	math.randomseed( os.time() )

  	strictify( _G )
  	local st = os.clock()
	local gstate = require "gstate"
  	game = gstate.new()
  	love.graphics.text = drawtext
  	love.graphics.textf = love.graphics.printf
	print( os.clock() - st, " secs ")
end

function love.draw()
    ttsys.inst:clear()
	game:draw()

    local mx, my = love.mouse.getX(), love.mouse.getY()
    local ttstr = ttsys.inst:findTooltip( mx, my )
    if ttstr then
        ttsys.inst:draw( ttstr, mx, my )
    end
end

function love.update(dt)
	game:update(dt)
end

function love.mousepressed(x, y, button)
	game:mousepressed(x, y, button)
end

--function love.mousemoved( x, y, dx, dy )
--end

function love.keypressed( key, isrepeat )
	modifiers.ctrl = love.keyboard.isDown( "lctrl" ) or love.keyboard.isDown( "rctrl" )
	modifiers.shift = love.keyboard.isDown( "lshift" ) or love.keyboard.isDown( "rshift" )
	modifiers.alt = love.keyboard.isDown( "lgui" ) or love.keyboard.isDown( "rgui" )

	if game:keypressed( key, isrepeat, modifiers ) then
		return
	end

	local i = tonumber(key)
	if i then
		local cmd = game:doOption( i )
		if cmd == "restart" then
			game = gstate.new()
		end
	end
end



