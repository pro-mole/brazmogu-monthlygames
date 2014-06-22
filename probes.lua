-- Probe module
--- The probe is controlled by the player and has its own set of characteristics

require("physics")

Probe = {
	active = false,

	-- Engine
	fuel = 0,
	max_fuel = 100, -- Fuel capacity (liters)
	thrust = 0.1, -- Acceleration (pixels per second per second per unit of mass)
	fuel_rate = 1, -- Fuel rate for thrust (liters per second)

	-- Energy
	energy = 0,
	max_energy = 100, -- Energy capacity (percentage)

	-- Reaction Wheels
	torque = math.pi/4, -- Angular movement (radians per second)
	torque_power = 1, -- Energy usage for torque (percentage per second)
	autobreak = false, -- Autobreaking makes it so that when the player is not turning, the reaction wheels will attempt to stop rotation automatically

	-- Boosters
	booster = 0,
	max_booster = 100, -- Booster Fuel capacity (liters)
	boost_power = 1, -- Booster power setting (1 to 10)
	boost = 10, -- Booster base potency (instantaneous acceleration force)
	booster_rate = 5, -- Booster base consumption (liters per boost per power level)
	
	-- Drill
	drill_power = 1, -- Energy usage for drill (percentage per second)
	drill_rate = 1, -- Tons of material per second
	
	-- Mineral Storage
	storage = {},
	storage_capacity = 16,
	max_storage_capacity = 64,

	-- Liquid Storage
	tank = {},
	tank_capacity = 100,
	max_tank_capacity = 500,

	-- Gas Storage
	vacuum = {},
	vacuum_capacity = 10,
	max_vacuum_capacity = 80,
	
	-- Radar
	scope = 32,
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

	P.storage = {}
	P.tank = {}
	P.vacuum = {}

	P.drill_q = 0
	
	table.insert(Space.probes, P)
	return P
end

function Probe:keypressed(key, isrepeat)
	print(key)
	if key == " " then
		if self.booster > 0 then
			self:applyForce(self.boost * 2^(self.boost_power/2), self.d)
			self.booster = self.booster - self.boost_power*self.booster_rate
		end
	end
	
	if key == "z" then
		self.autobreak = not self.autobreak
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
			if math.random(10) == 1 then
				local ddir = (math.random()-0.5)*math.pi/2
				local pv, pdir = addVectors(self.v, self.d, -self.thrust, ddir)
				Particles:add(PartSquare,
					self.x - math.cos(ddir)*self.size,
					self.y - math.sin(ddir)*self.size,
					math.random(self.size/4,self.size/2),
					-pv,
					pdir,
					math.pi/(math.random(1,6)),
					64,
					128,
					math.random()*2)
			end
		end

		if love.keyboard.isDown("down") then
			self:applyForce(-self.thrust, self.d)
			self.fuel = self.fuel - self.fuel_rate * dt
			if math.random(10) == 1 then
				local ddir = (math.random()-0.5)*math.pi/2
				local pv, pdir = addVectors(self.v, self.d, self.thrust, ddir)
				Particles:add(PartSquare,
					self.x + math.cos(ddir)*self.size,
					self.y + math.sin(ddir)*self.size,
					math.random(self.size/4,self.size/2),
					pv,
					pdir,
					math.pi/(math.random(1,6)),
					64,
					192, math.random()*2)
			end
		end
	end

	if self.energy > 0 then
		if love.keyboard.isDown("x") or self.autobreak then -- Torque Break
			if self.vrot ~= 0 and not (love.keyboard.isDown("left") or love.keyboard.isDown("right"))then
				if self.vrot > 0 then
					self.vrot = self.vrot - self.torque*dt
				elseif self.vrot < 0 then
					self.vrot = self.vrot + self.torque*dt
				end
				self.energy = self.energy - self.torque_power * dt
			end
		end

		if love.keyboard.isDown("left") then
			self.vrot = self.vrot - self.torque*dt
			self.energy = self.energy - self.torque_power * dt
		end

		if love.keyboard.isDown("right") then
			self.vrot = self.vrot + self.torque*dt
			self.energy = self.energy - self.torque_power * dt
		end

		if love.keyboard.isDown("q") then -- Drill
			local B = self.influence_body
			if math.sqrt(squareBodyDistance(self,B))-self.size-B.size <= 1 then
				self.drill_q = self.drill_q + 1/B.metal_depth * dt
				self.energy = self.energy - self.drill_power * dt
				while self.drill_q >= 1 do
					if #self.storage < self.storage_capacity then
						table.insert(self.storage, selectRandomly(B.metals))
						B.metal_depth = B.metal_depth + 1
					end
					self.drill_q = self.drill_q - 1
				end
				if math.random(4) == 1 then
					local B = self.influence_body
					local ddir = (math.random()-0.5)*(self.size/B.size)*math.pi
					local pv,pdir = addVectors(B.v, B.dir, math.random(1,4), bodyDirection(B, self) + ddir)
					pdir = bodyDirection(B, self) + ddir
					Particles:add(PartDust,
						B.x + math.cos(pdir)*B.size,
						B.y + math.sin(pdir)*B.size,
						pv, pdir, 0, 64, 192, B.color or {128,128,128}, math.random()*1)
				end
			end
		end
	end

	self.energy = math.max(0, self.energy)
	self.fuel = math.max(0, self.fuel)
	self.booster = math.max(0, self.booster)

	Body.update(self, dt)
end

function Probe:draw()
	Body.draw(self)

	--[[love.graphics.push()
	love.graphics.translate(self.x , self.y - self.size - 12)

	drawMeter(0, 0, self.size*2, 4, {128, 192, 255, 128}, {128, 192, 255, 255}, self.max_energy, self.energy)
	drawMeter(0, 4, self.size*2, 4, {255, 255, 0, 255}, {255, 255, 0, 255}, self.max_fuel, self.fuel)
	drawMeter(0, 8, self.size*2, 4, {0, 128, 0, 128}, {0, 128, 0, 128}, self.max_booster, self.booster)

	love.graphics.pop()
	
	love.graphics.push()
	love.graphics.translate(self.x - self.size - 4, self.y)
	
	drawSegMeter(0, 0, self.size*2, 4, {255, 0, 0, 128}, {255, 0, 0, 255}, 10, self.boost_power, "up")
	
	love.graphics.pop()]]
end

function Probe:drawUI()
	love.graphics.push()
	love.graphics.origin()
	love.graphics.translate(0,love.window.getHeight()-144)
	
	love.graphics.setColor(0,24,0,192)
	love.graphics.rectangle("fill",0,0,love.window.getWidth(),144)
	
	drawRadar(Radar, self, 1/16)
	drawNavWheel(NavWheel, self)
	love.graphics.draw(Radar, love.window.getWidth()-132, 12)
	love.graphics.draw(NavWheel, 4, 12)

	drawSegMeter(144, 78, 128, 16, {128, 0, 0, 255}, {255, 0, 0, 255}, 10, self.boost_power, "up")

	love.graphics.setFont(font.standard)
	drawMeter(218, 134, 128, 16, {0, 64, 96, 255}, {0, 192, 255, 255}, self.max_energy, self.energy, "right")
	love.graphics.printf("ENERGY:", 156, 116, 128, "left")
	drawMeter(218, 102, 128, 16, {128, 64, 0, 255}, {255, 192, 0, 255}, self.max_fuel, self.fuel, "right")
	love.graphics.printf("FUEL:", 156, 84, 128, "left")
	drawMeter(218, 70, 128, 16, {64, 128, 0, 255}, {192, 255, 0, 255}, self.max_booster, self.booster, "right")
	love.graphics.printf("BOOSTER:", 156, 52, 128, "left")

	local B = self.influence_body
	local vB, dB = addVectors(self.v, self.dir, -B.v, B.dir)
	love.graphics.print(string.format("REF: %s", B), 156, 16)
	love.graphics.print(string.format("V: %0.2f u/s", vB), 156, 26)
	love.graphics.print(string.format("H: %0.2f u", math.sqrt(squareBodyDistance(self,B))-self.size-B.size), 156, 36)

	drawStorage(318, 24, self)
	love.graphics.print("STORAGE:", 320, 16)
	drawTank(424, 24, self)
	love.graphics.print("TANK:", 422, 16)
	
	love.graphics.pop()
end