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

function Object:simulate(dt)
	dx = self.hspeed*dt
	dy = self.vspeed*dt + 0.5*Engine.Physics.gravity*self.gravity*dt^2

	dv = Engine.Physics.gravity*self.gravity*dt

	self.x = self.x + dx
	self.y = self.y + dy
	self.vspeed = self.vspeed + dv
end

function Object:solveCollisions(dt)
	local others = self:getCollisions()
	for other in pairs(others) do
		if other.solid then
			local boxSelf = self.bbox:offsetObject(self)
			local boxOther = other.bbox:offsetObject(other)
			local dx, dy = 0, 0
			if boxSelf.x < boxOther.x and (boxSelf.x + boxSelf.w) < (boxOther.x + boxOther.w) then
				dx = boxSelf.x+boxSelf.w - boxOther.x
			else
				dx = boxOther.x+boxOther.w - boxSelf.x
			end
			if boxSelf.y < boxOther.y then
				dy = boxSelf.y+boxSelf.h - boxOther.y
			else
				dy = boxOther.y+boxOther.h - boxSelf.y
			end

			print_debug(self)
			print_debug(boxSelf, boxOther)
			print_debug(self.hspeed, self.vspeed, dx, dy)
			if dx ~= 0 or dy ~= 0 then
				if math.abs(dx) <= math.abs(dy) then
					if self.hspeed > 0 then
						self.x = self.x - dx
					elseif self.hspeed < 0 then
						self.x = self.x + dx
					end
					self.hsspeed = 0 
				end

				if math.abs(dx) >= math.abs(dy) then
					if self.vspeed > 0 then
						self.y = self.y - dy
					elseif self.vspeed < 0 then
						self.y = self.y + dy
					end
					self.vspeed = 0
				end
			end
		end
	end
end

function Object:getCollisions(touch)
	local others = {}
	for i,other in ipairs(Engine.Objects) do
		if i ~= self then
			if checkCollision(self,other,touch) then
				if not others[other] then
					others[other] = true
				end
			end
		end
	end

	return others
end

function Object:checkOffsetFree(x, y)
	for i,other in ipairs(Engine.Objects) do
		if i ~= self and other.solid then
			if checkOverlap(self.bbox:offsetXY(self.x+x,self.y+y), other.bbox:offsetObject(other)) then
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