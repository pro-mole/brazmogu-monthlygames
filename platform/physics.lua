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
	gravity = 1, -- Relative gravity power over object
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
		debug_color = data.color,
		name = data.name or string.format("OBJECT#%05d", #Engine.Objects)
	}, Object)
	
	table.insert(Engine.Objects, O)
	return O
end

function Object:__tostring()
	return self.name
end

function Object:draw()
	love.graphics.setColor(unpack(self.debug_color))
	love.graphics.rectangle("fill",self.x + self.bbox.x, self.y + self.bbox.y, self.bbox.w, self.bbox.h)
end

function Object:update(dt)

end

function Object:getBoundingBox(x,y)
	local x,y = x or 0, y or 0
	local bbox = self.bbox:offsetObject(self)
	return bbox:offsetXY(x,y)
end

function Object:simulate(dt)
	print_debug(self)
	dx = self.hspeed*dt
	dy = self.vspeed*dt + 0.5*Engine.Physics.gravity*self.gravity*dt^2

	dv = Engine.Physics.gravity*self.gravity*dt

	print_debug(dx,dy,dv)
	if self:checkOffsetFree(dx, dy) then
		self.x = self.x + dx
		self.y = self.y + dy
	else
		if self:checkOffsetFree(dx, 0) then
			self.x = self.x + dx
		else
			local factor = 0.5
			while factor > 1/32 do
				if self:checkOffsetFree(dx*factor,0) then
					self.x = self.x + dx*factor
				end
				factor = factor /2
			end
		end
		if self:checkOffsetFree(0, dy) then
			self.y = self.y + dy
		else
			local factor = 0.5
			while factor > 1/32 do
				if self:checkOffsetFree(0,dy*factor) then
					self.y = self.y + dy*factor
				end
				factor = factor /2
			end
		end
	end

	self.vspeed = self.vspeed + dv
end

function Object:solveCollisions(dt)
	if self.vspeed > 0 and not self:checkOffsetFree(0, 1) then
		self.vspeed = 0
	end

	if self.vspeed < 0 and not self:checkOffsetFree(0, -1) then
		self.vspeed = 0
	end
end

function Object:getCollisions(x,y,touch)
	return self:getBoundingBox(x,y):getCollisions()
end

function Object:checkOffsetFree(x, y)
	for i,other in ipairs(Engine.Objects) do
		if other ~= self and other.solid then
			if checkOverlap(self:getBoundingBox(x,y), other:getBoundingBox()) then
				return false
			end
		end
	end

	return true
end

-- Define a bounding box for the object, with position relative to the object position and absolute dimensions
function Object:addBoundingBox(x, y, w, h)
	local bbox = BoundingBox.new{x=x, y=y, h=h, w=w}
	self.bbox = bbox
end

return Physics