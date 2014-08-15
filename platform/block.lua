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
	if not checkTouch(self:getBoundingBox(), player:getBoundingBox()) then
		print_debug(self:getBoundingBox())
		print_debug(player:getBoundingBox())
		self.hspeed = 0
	else
		print_debug(self:getBoundingBox())
		print_debug(player:getBoundingBox())
	end

	Object.update(self, dt)
end