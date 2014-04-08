-- The zone you must defend

zone = {defense = 0, size = 32}

function zone:init(size)
	self.size = size or 32
	self.defense = 0
end

function zone:draw()
	-- Draw the Zone and the layers of defense around it(if any)
	love.graphics.setColor(192,192,192,255)
	love.graphics.circle("line", center.x, center.y, self.size, 128)
	love.graphics.setColor(255,255,255,255)
	love.graphics.circle("fill", center.x, center.y, 8, 32)
	love.graphics.circle("line", center.x, center.y, 8, 32)
end

function zone:update()
	-- Check if any pixel is in, and react accordingly
end