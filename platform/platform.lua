-- Platform Object Prototype

Platform = {}

function Platform.new(x, y, w, h)
	-- Create basic object
	data = {
		x = x,
		y = y,
		color = {0x00, 0x00, 0x00, 0xff},
		visible = true,
		solid = true,
		fixed = true
	}
	
	local P = setmetatable(Object.new(data), Platform)
	
	-- Class-specific data
	P:addBoundingBox(0, 0, w, h)
	
	return P
end

Platform.__index = __inherit(Platform, Object)