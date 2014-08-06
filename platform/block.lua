-- Movable Block Object Prototype

Block = {}

function Block.new(x, y, w, h)
	-- Create basic object
	data = {
		x = x,
		y = y,
		color = {0x80, 0x80, 0x00, 0xff},
		visible = true,
		solid = true,
		fixed = false
	}
	
	local B = setmetatable(Object.new(data), Block)
	
	-- Class-specific data
	B:addBoundingBox(0, 0, w, h)
	
	return B
end

Block.__index = __inherit(Block, Object)

function Block:update(dt)
	Object.update(self, dt)
	
	self.hspeed = 0
end