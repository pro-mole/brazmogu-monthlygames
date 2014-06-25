-- This is our space physics and vector math module
-- Oh boy!

-- Some constants

RIGHT = 0
DOWN = math.pi/2
LEFT = math.pi
UP = 3 * math.pi/2

-- An index of Physics stuff we need globally
Physics = {
	K = 2^9, -- Universal gravitation constant
	bodies = {},
	update = function (self,dt)
		for i,B in ipairs(self.bodies) do
			print_debug("Body:", B)
			B["influence_body"] = nil
			local max_grav = 0
			for j,C in ipairs(self.bodies) do
				if B ~= C and B.class <= C.class then
					B:applyForce(gravityBodies(B,C), bodyDirection(B,C), dt)
					if gravityBodies(B,C) > max_grav then
						B["influence_body"] = C
						max_grav = gravityBodies(B,C)
					end
					print_debug(string.format("Gravity(%s -> %s):",B,C), gravityBodies(B,C), bodyDirection(B,C), math.sqrt(squareBodyDistance(B,C)))
				end
			end
			print_debug(string.format("Ifluence on %s: %s",B,B.influence_body))
		end		
		
		for i,B in ipairs(self.bodies) do
			if B.class > 0 then
				B:update(dt)
			end
		end
	end,
	keypressed = function (self, key, isrepeat)
		for i,B in ipairs(self.bodies) do
			B:keypressed(key, isrepeat)
		end
	end,
	draw = function (self)
		for i,B in ipairs(self.bodies) do
			for j,C in ipairs(self.bodies) do
				if B ~= C then
					love.graphics.setColor(255, 0, 0, 128)
					drawVector(B.x, B.y, gravityBodies(B,C), bodyDirection(B,C))
				end
			end
		end		
	end
}

-- A "body" is anything that has mass and occupies space. Thus, it moves around, exerts gravity and collisions happen
Body = {
	name = "",
	x = 0, -- Position (of center of mass)
	y = 0,
	d = 0, -- Direction (of the body itself)
	v = 0, -- Velocity(in pixels per second)
	dir = 0, -- Velocity Direction
	vrot = 0, -- Rotation Velocity(in radians per second)
	mass = 1, -- Mass in WUs (Whatever Units)
	size = 1, -- All our objects will be spherical because that's already complicated enough :|
	class = 0, -- Size class of the body; for checking gravity effect
	influence_body = nil,
	texture_params = { {"gradient", {255,255,255,255}, {128,128,128,255}} } -- Texture info; standard to solid white
}
Body.__index = Body

function Body.new(specs)
	local T = specs or {}
	
	if not T["name"] then
		T["name"] = "Body" + math.random(1000000)
	end
	
	local B = setmetatable(T, Body)
	
	table.insert(Physics.bodies, B)
	return B
end

function Body:delete()
	for i,B in ipairs(Physics.bodies) do
		if B == self then
			table.remove(Physics.bodies, i)
			return true
		end
	end

	return false
end

function Body:__tostring()
	return self.name
end

-- Return composite vectors of a single vector
function compositeVectors(mag, dir)
	return mag * math.cos(dir), mag * math.sin(dir)
end

function toVector(vx, vy)
	return math.sqrt(vx^2 + vy^2), math.atan2(vy,vx)
end

-- Return magnitude, direction for a sum of N vectors
function addVectors(...)
	local V = {...}
	assert(#V % 2 == 0, "Vector addition is missing one vector's direction")
	
	local Vx, Vy = 0, 0
	for i = 1,#V,2 do
		local tVx, tVy = compositeVectors(V[i], V[i+1])
		Vx, Vy = Vx + tVx, Vy + tVy
	end
	
	return toVector(Vx, Vy)
end

-- Squared distance between two bodies
function squareBodyDistance(B1, B2)
	if not B1 or not B2 then
		return nil
	end
	
	return (B2.x - B1.x)^2 + (B2.y - B1.y)^2
end

-- Relative direction from one body to another
function bodyDirection(B1, B2)
	if not B1 or not B2 then
		return nil
	end
	
	return math.atan2(B2.y - B1.y, B2.x - B1.x)
end

-- Returns the gravity acceleration between two bodies(for B2 on B1)
function gravityBodies(B1, B2)
	if not B1 or not B2 then
		return nil
	end

	local d = squareBodyDistance(B1,B2)

	--[[if math.sqrt(d) <= B1.size + B2.size then
		return 0
	end]]

	return (Physics.K*B1.mass*B2.mass)/d
end

-- Get circular orbit radius around a body for given horizontal velocity
function getOrbitRadius(B, v)
	return Physics.K * B.mass / v^2
end

-- Get circular orbit velocity around a body for given distance
function getOrbitVelocity(B, r)
	return math.sqrt(Physics.K * B.mass / r)
end

-- Get escape velocity from a body's gravity for given distance
function getEscapeVelocity(B, r)
	return math.sqrt(2 * Physics.K * B.mass / r)
end

-- Get gravity field value at a given distance from a body
function getGravityField(B, r)
	return Physics.K * B.mass / r^2
end

-- Apply (vectorial) force on body
function Body:applyForce(mag, dir, dt)
	-- Defaults:
	local F = mag or 0 -- no force
	local d = dir or 0 -- to the right
	local t = dt or 1 -- 1 second
	
	--[[local Fx, Fy = compositeVectors(F/self.mass, d)
	local vx, vy = compositeVectors(self.v, self.dir)
	print_debug("Force:",self, F, dir, Fx, Fy)
	
	print_debug("Old Velocity:",self, self.v, self.dir, vx, vy)
	local Vx, Vy = vx + t*Fx, vy + t*Fy
	self.v = math.sqrt((Vx)^2 + (Vy)^2)
	self.dir = math.atan2(Vy, Vx)
	print_debug("New Velocity:",self, self.v, self.dir, Vx, Vy)]]
	
	self.v, self.dir = addVectors(self.v, self.dir, F/self.mass * t, d)
end

-- Move according to current velocity
function Body:applyVelocity(v, dir, dt)
	local vx,vy = compositeVectors(v, dir)
	
	-- print_debug("Velocity:",self, v, dir, vx, vy)
	self.x, self.y = self.x + vx*dt, self.y + vy*dt
end

-- Rotate according to current rotation velocity
function Body:applyRotation(vrot, dt)	
	-- print_debug("Rotation Velocity:",self, vrot, d)
	self:spin(vrot * dt)
end

function Body:spin(angle)
	local _d = self.d + angle
	local pi = math.pi

	if _d > 2*pi then
		repeat
			_d = _d - 2*pi
		until _d <= 2*pi
	end

	if _d < 0 then
		repeat
			_d = _d + 2*pi
		until _d >= 0
	end

	self.d = _d
end

-- Basic updating for simulations
function Body:update(dt)
	--print_debug("Speed:", self, self.v, self.dir)
	self:applyVelocity(self.v, self.dir, dt)
	self:applyRotation(self.vrot, dt)

	for i,B in ipairs(Physics.bodies) do
		if math.sqrt(squareBodyDistance(self, B)) < (self.size + B.size) then
			if self.size < B.size then
				local delta = math.sqrt(squareBodyDistance(self, B)) - (self.size + B.size)
				local dirdelta = bodyDirection(self, B)
				local dx,dy = compositeVectors(delta, dirdelta)
				self.x = self.x + dx
				self.y = self.y + dy
				self.v = B.v
				self.dir = B.dir
			end
		end
	end
end

function Body:keypressed(key, isrepest)
end

-- Drawing vectors
function drawVector(x, y, mag, dir)
	love.graphics.line(x, y, x + mag*math.cos(dir), y + mag*math.sin(dir))
end

-- Generate texture for a Body
function Body:loadTexture()
	if self.texture_file then
		self["texture"] = loadTexture(self.size, self.texture_file)
	else
		self["texture"] = generateTexture(self.size, unpack(self.texture_params))
	end
	
	if self.atmosphere then
		if self.atmosphere_file then
			self["atmosphere_texture"] = loadTexture(self.size+self.atmosphere_size, self.atmosphere_file)
		else
			self["atmosphere_texture"] = generateTexture(self.size+self.atmosphere_size, unpack(self.atmosphere_params))
		end
	end
end

-- Basic drawing for basic simulations
function Body:draw()
	if self.texture then

		love.graphics.setColor(255,255,255,255)
		love.graphics.push()
		love.graphics.translate(self.x, self.y)
		love.graphics.rotate(self.d)
		love.graphics.draw(self.texture, -self.size, -self.size)
		love.graphics.pop()
		
		-- Draw speed and orientatino vectors
		--[[love.graphics.setColor(0, 255, 255, 128)
		drawVector(self.x, self.y, self.size, self.d)
		love.graphics.setColor(0, 255, 0, 128)
		drawVector(self.x, self.y, self.v, self.dir)]]
	end
end