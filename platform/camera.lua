-- Camera routines, for drawing on screen(and scrolling)

local Camera = {
	x = 0,
	y = 0,
	width = love.window.getWidth(),
	height = love.window.getHeight(),
	draw_x = 0,
	draw_y = 0,
	follow_object = nil,
	follow_padding = 0,
	background_color = {0x00, 0xc0, 0xff, 0xff}
}

function Camera:update(dt)
	if self.follow_object then -- if there is an object to follow, go on
	end
end

return Camera