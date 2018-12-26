
class( "GameScreen", Screen )

function GameScreen:init()
	self:Reset()
end

function GameScreen:Reset()
	if self.game_world then
		self.game_world:ResetWorld()
	end
	self.game_world = World.new()

	self.zoom_level = 0
	self.camera = Camera.new()
	self.camera:ZoomToLevel( self.zoom_level )
	self:CenterCamera( 0, 0 )
end

function GameScreen:SaveWorld( filename )
	assert( filename )
	SerializeToFile( self.game_world, filename )
end

function GameScreen:LoadWorld( filename )
	assert( filename )
	self.game_world = DeserializeFromFile( filename )
end

function GameScreen:UpdateScreen( dt )
	self.game_world:UpdateWorld( dt )

	self:CenterCamera( self.game_world.player:GetPosition())
	self.camera:UpdateCamera( dt )
end

function GameScreen:RenderDebug()
	self.camera:RenderDebug()
	local mx, my = love.mouse.getPosition()
	local x, y = self.camera:ScreenToWorld( mx, my )
	imgui.Text( string.format( "World: %.2f, %.2f", x, y ))
	imgui.Text( tostr( self.selected_tile ))
end


function GameScreen:RenderScreen()

	local ui = imgui
    local flags = { "NoTitleBar", "AlwaysAutoResize", "NoMove", "MenuBar", "NoScrollBar", "NoBringToFrontOnFocus" }
	ui.SetNextWindowSize( love.graphics.getWidth(), 40 )
	ui.SetNextWindowPos( 0, 0 )

    ui.Begin( "BUILD_MENU", true, flags )

    if ui.BeginMenuBar() then
    	if ui.BeginMenu( "Game" ) then
    		if ui.MenuItem( "Quit" ) then
    			love.event.quit()
    		end
    		ui.EndMenu()
    	end

    	ui.EndMenuBar()
    end

    self.camera:PushCamera()
    self.game_world:RenderWorld()
    self.camera:PopCamera()

	ui.End()
end

function GameScreen:Pan( px, py )
	local screenw, screenh = love.graphics.getWidth(), love.graphics.getHeight()
	local x0, y0 = self.camera:ScreenToWorld( 0, 0 )
	local x1, y1 = self.camera:ScreenToWorld( screenw * px, screenh * py )
	local dx, dy = x1 - x0, y1 - y0
	self.camera:Pan( dx, dy )
end

function GameScreen:PanTo( x, y )
	local x1, y1 = self.camera:ScreenToWorld( 0, 0 )
	local x2, y2 = self.camera:ScreenToWorld( love.graphics.getWidth(), love.graphics.getHeight() )

	self.camera:PanTo( x - (x2 - x1 - 1)/2, y - (y2 - y1 - 1)/2 )
end

function GameScreen:CenterCamera( wx, wy )
	local x1, y1 = self.camera:ScreenToWorld( 0, 0 )
	local x2, y2 = self.camera:ScreenToWorld( love.graphics.getWidth(), love.graphics.getHeight() )

	self.camera:MoveTo( wx - (x2 - x1 - 1)/2, wy - (y2 - y1 - 1)/2 )
end

function GameScreen:MouseMoved( mx, my )
	return false
end

function GameScreen:MousePressed( mx, my, btn )
	if btn == constants.buttons.MOUSE_LEFT then
	end

	return self.game_world:MousePressed( mx, my, btn )
end

function GameScreen:MouseReleased( mx, my, btn )
	if btn == constants.buttons.MOUSE_LEFT then
	end

	return self.game_world:MouseReleased( mx, my, btn )
end

function GameScreen:KeyPressed( key )
	local pan_delta = Input.IsShift() and 0.5 or 0.1

	if key == "space" then
		self.is_panning = true
		self.pan_start_x, self.pan_start_y = self.camera:GetPosition()
		self.pan_start_mx, self.pan_start_my = love.mouse.getPosition()
	elseif key == "backspace" then
		self:PanTo( 0, 0 )
	elseif key == "left" or key == "a" then
		self:Pan( -pan_delta, 0 )
	elseif key == "right" or key == "d" then
		self:Pan( pan_delta, 0 )
	elseif key == "up" or key == "w" then
		self:Pan( 0, -pan_delta )
	elseif key == "down" or key == "s" then
		self:Pan( 0, pan_delta )
	elseif key == "=" then
		self.zoom_level = clamp( (self.zoom_level + 1), MIN_ZOOM, MAX_ZOOM )
		local mx, my = love.mouse.getPosition()
		self.camera:ZoomToLevel( self.zoom_level, mx, my )

	elseif key == "-" then
		self.zoom_level = clamp( (self.zoom_level - 1), MIN_ZOOM, MAX_ZOOM )
		local mx, my = love.mouse.getPosition()
		self.camera:ZoomToLevel( self.zoom_level, mx, my )

	elseif key == "escape" then

	end

	return self.game_world:KeyPressed( key )
end

function GameScreen:KeyReleased( key )
	if key == "space" and self.is_panning then
		self.is_panning = nil
	end

	return self.game_world:KeyReleased( key )
end

function GameScreen:WheelMoved( dx, dy )
	local mx, my = love.mouse.getPosition()
	self.zoom_level = clamp( (self.zoom_level + dy/5), MIN_ZOOM, MAX_ZOOM )
	self.camera:ZoomToLevel( self.zoom_level, mx, my )
end

return GameScreen
