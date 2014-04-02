-- The zone you must defend

zone = {defense = 0, size = 32}

zone:init(size)
	self.size = size or 32
	self.defense = 0
end

zone:draw()
	-- Draw the Zone and the layers of defense around it(if any)
end

zone:update()
	-- Check if any pixel is in, and react accordingly
end