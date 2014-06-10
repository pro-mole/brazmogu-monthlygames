-- Probe module
--- The probe is controlled by the player and has its own set of characteristics

require("physics")

Probe = {
	active = false,
	fuel = 0,
	max_fuel = 100, -- Fuel capacity (liters)
	energy = 0,
	max_energy = 100, -- Energy capacity (percentage)
	booster = 0,
	max_booster = 100, -- Booster Fuel capacity (liters)
	thrust = 0.1, -- Acceleration (pixels per second per second)
	boost_power = 1, -- Booster power setting (1 to 10)
	boost = 10, -- Booster base potency (instantaneous acceleration force)
	fuel_rate = 1, -- Fuel rate for thrust (liters per second)
	energy_rate = 1, -- Energy rate for torque (percentage per second)
	booster_rate = 5, -- Booster base consumption (liters per boost per power level)
	torque = math.pi/4 -- Angular movement (radians per second)
}

Probe.__tostring = Body.__tostring

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
	P.class = 0
	P.fuel = P.max_fuel
	P.energy = P.max_energy
	P.booster = P.max_booster
	
	table.insert(Space.probes, P)
	return P
end

function Probe:keypressed(key, isrepeat)
	print(key)
	if self.booster > 0 then
		if key == " " then
			self:applyForce(self.boost * 2^(self.boost_power/2), self.d)
			self.booster = self.booster - self.boost_power*self.booster_rate
		end
	end
	
	if key == "=" then
		if self.boost_power < 10 then
			self.boost_power = self.boost_power + 1
		end
	end
	
	if key == "-" then
		if self.boost_power > 1 then
			self.boost_power = self.boost_power - 1
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
	love.graphics.translate(self.x - self.size, self.y - self.size - 12)

	drawMeter(0, 0, self.size*2, 4, {128, 192, 255, 128}, {128, 192, 255, 255}, self.max_energy, self.energy)
	drawMeter(0, 4, self.size*2, 4, {255, 255, 0, 255}, {255, 255, 0, 255}, self.max_fuel, self.fuel)
	drawMeter(0, 8, self.size*2, 4, {0, 128, 0, 128}, {0, 128, 0, 128}, self.max_booster, self.booster)

	love.graphics.pop()
	
	love.graphics.push()
	love.graphics.translate(self.x - self.size - 4, self.y - self.size)
	
	drawMeter(0, 0, 4, self.size*2, {255, 0, 0, 128}, {255, 0, 0, 255}, 10, self.boost_power, "up")
	
	love.graphics.pop()
end