-- Physics engine of my own

local Physics = {
	gravity = 320,
	gravity_dir = math.rad(270),
	terminal_velocity = 320
}

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
		solid = data.solid or false,
		visible = data.visible or true,
		debug_color = data.color
	}, Object)
	
	table.insert(Engine.Objects, O)
	return O
end

function Object:draw()
	love.graphics.setColor(unpack(self.debug_color))
	for i,box in ipairs(self.bbox) do
		love.graphics.rectangle("fill",self.x + box.x, self.y + box.y, box.w, box.h)
	end
end

function Object:update(dt)
	if checkObjectFree(self) then
		local dvy = Engine.Physics.gravity * math.sin(Engine.Physics.gravity_dir) * dt
		local dvx = Engine.Physics.gravity * math.cos(Engine.Physics.gravity_dir) * dt
		
		self.vspeed = self.vspeed - dvy
		if self.vspeed > Engine.Physics.terminal_velocity then self.vspeed = Engine.Physics.terminal_velocity end
		self.hspeed = self.hspeed + dvx
		
		if checkOffsetFree(self, self.hspeed * dt, 0) then
			self.x = self.x + self.hspeed * dt
		else
			-- "Touch" on the blocking object
			self:moveUpTo(self.hspeed * dt, 0)
			self.hspeed = 0
		end
		
		if checkOffsetFree(self, 0, self.vspeed * dt) then
			self.y = self.y + self.vspeed * dt
		else
			-- "Touch" on the blocking object
			self:moveUpTo(0, self.vspeed * dt)
			self.vspeed = 0
		end
	end
end

-- Define a bounding box for the object, with position relative to the object position and absolute dimensions
function Object:addBoundingBox(x, y, w, h)
	if self.bbox == nil then
		self.bbox = {}
	end
	
	table.insert(self.bbox, BoundingBox.new{x=x, y=y, h=h, w=w} )
end

-- Move object up to an offset, ending as close as possible to any solid barrier
function Object:moveUpTo(offx, offy)
	local dir = math.atan2(offy, offx)
	local dist = offx^2 + offy^2
	local factor = 1
	while dist*factor > 1 do
		factor = factor/2
		local fx = math.cos(dir) * factor
		local fy = math.sin(dir) * factor
		if checkOffsetFree(self, fx*offx, fy*offy) then
			self.x = self.x + fx*offx
			self.y = self.y + fy*offy
		end
	end
end

return Physics