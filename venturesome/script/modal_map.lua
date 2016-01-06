local constants = require "constants"
local option_def = require "option_def"
local world_def = require "world_def"
local assets = require "assets"

local modal_map = {}

function modal_map.new( gstate )
	local self = util.shallowcopy( modal_map )
	self.gstate = gstate
	self.x, self.y = 0, 0
	self.width, self.height = 512, 512
	self.zoom = 4
	return self
end

function modal_map:update()
	while not self.done do
		coroutine.yield()
	end
end

function modal_map:draw()
	love.graphics.setScissor( 0, 0, 512, 512 )
	love.graphics.setColor( 32, 12, 0, 255 )
	love.graphics.rectangle( "fill", 0, 0, self.width, self.height )

	love.graphics.push()
	local cx, cy = self.gstate.room.mapx, self.gstate.room.mapy
	if cx and cy then
		self.x, self.y = self.width/2 - cx * self.zoom, self.height/2 - cy * self.zoom
		love.graphics.translate( self.x, self.y )
	end
	love.graphics.scale( self.zoom, self.zoom )
	
	love.graphics.setColor( 255, 255, 255, 255 )
	love.graphics.draw( assets.IMGS.MAP, 0, 0, 0, self.width / assets.IMGS.MAP:getWidth(), self.height / assets.IMGS.MAP:getHeight() )
	for name, room in pairs( self.gstate.rooms ) do
		self:drawRoom( room )
	end

	-- You are Here
	love.graphics.circle( "line", self.gstate.room.mapx, self.gstate.room.mapy, 12 )

	love.graphics.pop()
	love.graphics.setScissor()
end

function modal_map:drawRoom( room )
	if room.mapx and room.mapy then
		local x, y, size = room.mapx, room.mapy, 5
		love.graphics.setColor( 200, 100, 50, 255 )
		love.graphics.rectangle( "fill", x - size/2, y - size/2, size, size )

		for i, opt in ipairs( room.options ) do
			if opt.to then
				local to_room = self.gstate.rooms[ opt.to ]
				love.graphics.line( x, y, to_room.mapx, to_room.mapy )
			end
		end
	end
end

function modal_map:relax()
	for i, room in pairs( self.gstate.rooms ) do
		if room.mapx then
			local dx, dy, n = 0, 0, 0
			for j, room2 in pairs( self.gstate.rooms ) do
				local dist = room2.mapx and distance( room.mapx, room.mapy, room2.mapx, room2.mapy ) or 0
				if dist > 0 and dist < 50 then
					dx, dy = dx + (room2.mapx - room.mapx), dy + (room2.mapy - room.mapy)
					n = n + 1
				end
			end
			if n > 0 then
				local dist = distance( 0, 0, dx, dy )
				dx, dy = dx / n, dy / n
				dx, dy = dx / dist, dy / dist
				room.mapx, room.mapy = room.mapx - dx * 5, room.mapy - dy * 5
				print( "ADJUST", room.name, dx, dy )
			end
		end
	end
end


function modal_map:keypressed( key, isrepeat )
	if key == "=" then
		self.zoom = self.zoom * 2
	elseif key == "-" then
		self.zoom = self.zoom / 2
	elseif key == "r" then
		self:relax()
	elseif key == "escape" then
		self.done = true
	end
end

function modal_map:mousepressed( mx, my, button )
	print( mx - self.x, my - self.y )
end

return modal_map
