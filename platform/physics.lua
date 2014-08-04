-- Physics engine of my own

-- A prototype Object, as "something that exists in the world"

Object = {
	x = 0, y = 0, -- Position
	hspeed = 0, vspeed = 0, -- Speed components; less vectorial this time
	bbox = nil, -- Bounding Box
	fixed = false, -- Is object affected by physics and other objects?
	solid = false, -- Does object stop other objects upon collision?
	visible = false, -- Do we draw this object?
	debug_color = {0,0,0,255} -- Debug drawing color
}
Object.__index = Object

function Object.new(data)
	local O = setmetatable({
		x = data.x or 0,
		y = data.y or 0,
		hspeed = 0,
		vspeed = 0,
		bbox = {},
		fixed = data.fixed or false,
		solid = data.fixed or false,
		visible = data.visible or true,
		debug_color = data.color
	}, Object)
	
	return O
end

function Object:draw()
	love.graphics.setColor(unpack(self.debug_color))
	for i,box in self.bbox do
		love.graphics.rectangle(self.x + box.x, self.y + box.y, box.w, box.h)
	end
end

-- Define a bounding box for the object, with position relative to the object position and absolute dimensions
function Object:addBoundingBox(x, y, w, h)
	if self.bbox == nil then
		self.bbox = {}
	end
	
	table.insert(self.bbox, {x=x, y=y, h=h, w=w}
end