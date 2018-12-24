local ui = class( "UIWorld", Engine.World )

function ui:init()
	UIWorld._base.init( self )
	self.log = {}
	self.screens = {}
	self.input = { keys_pressed = {}, btns = {} }
	
	self.styles = {}
	self.styles.default = love.graphics.getFont()
	self.styles.header = love.graphics.newFont( "data/Ayuthaya.ttf", 20 )
	return self
end

function ui:Update( dt )
	for i = #self.screens, 1, -1 do
		local screen = self.screens[i]
		if screen.UpdateScreen then
			screen:UpdateScreen( dt )
		end
	end
end

function ui:RenderUI()
	love.graphics.setColor( 255, 255, 255 )

	for i, screen in ipairs( self.screens ) do
		screen:RenderScreen( self )
	end

	table.clear( self.input.keys_pressed )
end

function ui:RegisterFont( style, font, sz )
	self.styles[ style ] = love.graphics.newFont( font, sz )
end

function ui:GetFont( style )
	return self.styles[ style ] or self.styles.default
end

---------------------------------------------

function ui:MouseMoved( x, y )
	self.input.mx, self.input.my = x, y

	for i = #self.screens, 1, -1 do
		local screen = self.screens[i]
		if screen.MouseMoved == nil or screen:MouseMoved( x, y ) then
			break
		end
	end
end

function ui:MousePressed( x, y, btn )
	self.input.clickx, self.input.clicky = x, y
	self.input.btns[ btn ] = true
	self:Log( "MousePressed %d, %d, %s", x, y, btn )

	for i = #self.screens, 1, -1 do
		local screen = self.screens[i]
		if screen.MousePressed == nil or screen:MousePressed( x, y, btn ) then
			break
		end
	end
end

function ui:MouseReleased( x, y, btn )
	self.input.clickx, self.input.clicky = nil, nil
	self.input.btns[ btn ] = nil
	self:Log( "MouseReleased %d, %d, %s", x, y, btn )

	for i = #self.screens, 1, -1 do
		local screen = self.screens[i]
		if screen.MouseReleased == nil or screen:MouseReleased( x, y, btn ) then
			break
		end
	end
end

function ui:KeyPressed( key )
	self.input.keys_pressed[ key ] = true

	for i = #self.screens, 1, -1 do
		local screen = self.screens[i]
		if screen.KeyPressed == nil or screen:KeyPressed( key ) then
			break
		end
	end
end

function ui:KeyReleased( key )
	self.input.keys_pressed[ key ] = false

	for i = #self.screens, 1, -1 do
		local screen = self.screens[i]
		if screen.KeyReleased == nil or screen:KeyReleased( key ) then
			break
		end
	end
end


function ui:WheelMoved( dx, dy )
	for i = #self.screens, 1, -1 do
		local screen = self.screens[i]
		if screen.WheelMoved == nil or screen:WheelMoved( dx, dy ) then
			break
		end
	end
end
----------------------------------------------

function ui:AddScreen( screen )
	self:SpawnEntity( screen )
end

function ui:RemoveScreen( screen )
	self:DespawnEntity( screen )
end

----------------------------------------------

function ui:Log( fmt, ... )
	table.insert( self.log, string.format( fmt, ... ))
	while #self.log > 100 do
		table.remove( self.log )
	end
end

----------------------------------------------

return ui
