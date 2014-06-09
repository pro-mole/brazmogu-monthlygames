--- Probes module

require("physics")

Probe = {
	active = false,
	fuel = 0,
	max_fuel = 100, -- Fuel capacity (liters)
	energy = 0,
	max_energy = 100, -- Energy capacity (percentage)
	boost_power = 1, -- Booster power setting(1 to 10)
	thrust = 0.1, -- Acceleration (pixels per second per second)
	boost = 10, -- Booster base potency (instantaneous acceleration force)
	fuel_rate = 1, -- Fuel rate for thrust (liters per second)
	energy_rate = 1, -- Energy rate for torque (percentage per second)
	boost_rate = 10, -- Fuel spent for burst booster
	torque = math.pi/4 -- Angular movement (radians per second)
}

function Probe:__index(index)
	if rawget(self,index) ~= nil then
		return self[index]
	elseif Probe[index] ~= nil then
		return Probe[index]
	else
		return Body[index]
	end
end

function Probe.new(specs)
	local T = Body.new(specs)
	
	local P = setmetatable(T, Probe)
	P.fuel = P.max_fuel
	P.energy = P.max_energy
	
	table.insert(Physics.bodies, P)
	return P
end

function Probe:keypressed(key, isrepeat)
	if self.fuel > 0 then
		if key == " " then
			self:applyForce(self.thrust*320, self.d)
			self.fuel = self.fuel - self.fuel_rate * 10
		end
	end
end

function Probe:update(dt)
	if self.fuel > 0 then
		if love.keyboard.isDown("up") then
			self:applyForce(self.thrust, self.d)
			self.fuel = self.fuel - self.fuel_rate * dt
		end

		if love.keyboard.isDown("down") then
			self:applyForce(-self.thrust, self.d)
			self.fuel = self.fuel - self.fuel_rate * dt
		end
	end

	if self.energy > 0 then
		if love.keyboard.isDown("left") then
			self:spin(-self.torque * dt)
			self.energy = self.energy - self.energy_rate * dt
		end

		if love.keyboard.isDown("right") then
			self:spin(self.torque * dt)
			self.energy = self.energy - self.energy_rate * dt
		end
	end

	Body.update(self, dt)
end

function Probe:draw()
	Body.draw(self)

	love.graphics.push()
	love.graphics.translate(self.x - self.size, self.y - self.size - 8)

	love.graphics.setColor(128, 192, 255, 255)
	love.graphics.rectangle("fill", 0, 0, self.energy / self.max_energy * (self.size * 2), 4)
	love.graphics.setColor(128, 128, 0, 255)
	love.graphics.rectangle("fill", 0, 4, self.fuel / self.max_fuel * (self.size * 2), 4)

	love.graphics.pop()
end