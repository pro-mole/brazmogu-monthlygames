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
		fixed = false,
		name = string.format("BLOCK#%05d", #Engine.Objects)
	}
	
	local B = setmetatable(Object.new(data), Block)
	
	-- Class-specific data
	B:addBoundingBox(0, 0, w, h)
	
	return B
end

Block.__index = __inherit(Block, Object)
Block.__tostring = Object.__tostring

function Block:update(dt)
	Object.update(self, dt)

	if (self.hspeed > 0 and player.x < self.x - player.bbox.w) or(self.hspeed < 0 and player.x > self.x + self.bbox.w) then
		self.hspeed = 0
	end
end