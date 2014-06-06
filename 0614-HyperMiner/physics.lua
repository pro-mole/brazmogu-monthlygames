-- This is our space physics and vector math module
-- Oh boy!

-- Some constants

RIGHT = 0
DOWN = 90
LEFT = 180
UP = 270

-- An index of Physics stuff we need globally
Physics = {
	bodies = {},
	update = function (self,dt)
		for i,B in ipairs(self.bodies) do
			print_debug("Body:", B)
			for j,C in ipairs(self.bodies) do
				if B ~= C then
					B:applyForce(gravityBodies(B,C), bodyDirection(B,C), dt)
					print_debug("Gravity:", gravityBodies(B,C), bodyDirection(B,C))
				end
			end
		end		
		
		for i,B in ipairs(self.bodies) do
			B:update(dt)
		end
	end,
	draw = function (self)
		for i,B in ipairs(self.bodies) do
			for j,C in ipairs(self.bodies) do
				if B ~= C then
					love.graphics.setColor(255, 0, 0, 255)
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
	vrot = 0, -- Rotation Velocity(in angles per second)
	mass = 1, -- Mass in WUs (Whatever Units)
	size = 1, -- All our objects will be spherical because that's already complicated enough :|
	}
Body.__index = Body

function Body.new(specs)
	local T = specs or {}
	
	if not T["name"] then
		T["name"] = "Body" + math.random(1000000)
	end
	
	B = setmetatable(T, Body)
	
	table.insert(Physics.bodies, B)
	return B
end

function Body:__tostring()
	return self.name
end

-- Return composite vectors of a single vector
function compositeVectors(mag, dir)
	return mag * math.cos(dir), mag * math.sin(dir)
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

-- Returns the gravity acceleration between two bodies(for both bodies)
function gravityBodies(B1, B2)
	if not B1 or not B2 then
		return nil
	end
	
	local d = squareBodyDistance(B1,B2)
	local K = 2^13 -- Universal constant
	return K*B2.mass/d
end

-- Apply (vectorial) force on body
function Body:applyForce(mag, dir, dt)
	-- Defaults:
	local F = mag or 0 -- no force
	local d = dir or 0 -- to the right
	local t = dt or 1 -- 1 second
	
	local Fx, Fy = compositeVectors(F, d)
	local vx, vy = compositeVectors(self.v, self.dir)
	
	local Vx, Vy = vx + t*Fx, vy + t*Fy
	self.v = math.sqrt((Vx)^2 + (Vy)^2)
	self.dir = math.atan2(Vy, Vx)
end

-- Move according to current velocity
function Body:applyVelocity(v, dir, dt)
	local vx,vy = compositeVectors(v, dir)
	
	--print_debug(self.vx, self.vy)
	self.x, self.y = self.x + vx*dt, self.y + vy*dt
end

-- Basic updating for simulations
function Body:update(dt)
	--print_debug("Speed:", self, self.v, self.dir)
	self:applyVelocity(self.v, self.dir, dt)
end

-- Drawing vectors
function drawVector(x, y, mag, dir)
	love.graphics.line(x, y, x + mag*math.cos(dir), y + mag*math.sin(dir))
end

-- Basic drawing for basic simulations
function Body:draw()
	-- Draw the body
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.circle("line", self.x, self.y, self.size, 36)
	
	-- Draw speed and orientatino vectors
	love.graphics.setColor(0, 255, 255, 255)
	drawVector(self.x, self.y, self.size, self.d)
	love.graphics.setColor(0, 255, 0, 255)
	drawVector(self.x, self.y, self.v, self.dir)
end