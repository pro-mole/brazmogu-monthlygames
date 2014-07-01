-- Space Station module
--- Space stations are where the player will be able to recharge his batteries and exchange mined materials for fuel and/or upgrades

require("physics")

Station = {
}

-- Circular Menu for Station operations
Station["menu"] = {
	"Dump",
	"Engine+",
	"Torque+",
	"Booster+",
	"Fuel+",
	"Booster+",
	"Drill+",
	"Pump+",
	"Storage+",
	"Tank+",
	"Vacuum+",
	"Radar+",
	"Scanner+",
	"Solar Panels"
}

Station.__tostring = Body.__tostring

function Station:__index(index)
	if rawget(self,index) ~= nil then
		return self[index]
	elseif Station[index] ~= nil then
		return Station[index]
	else
		return Body[index]
	end
end

function Station.new(specs)
	local T = Body.new(specs)
	
	local S = setmetatable(T, Station)
	S.class = 1
	S.size = 16
	S.mass = 8
	S.texture_params = {
		{"gradient",{192,192,192,255},{128,128,128,255},32}
	}
	
	table.insert(Space.stations, S)
	return S
end

function Station:delete()
	Body.delete(self)
	
	for i,S in ipairs(Universe.stations) do
		if S == self then
			table.remove(Universe.stations, i)
			break
		end
	end
end

function Station:update(dt)
	Body.update(self, dt)
	-- If the probe is not docked, just go on
	if not bodiesTouching(self, main_probe) then return end

	if main_probe.energy < main_probe.max_energy then
		main_probe.energy = math.min(main_probe.max_energy, main_probe.energy + 0.25)
	end
end

function Station:draw()	
	Body.draw(self)
end