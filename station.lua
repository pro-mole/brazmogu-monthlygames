-- Space Station module
--- Space stations are where the player will be able to recharge his batteries and exchange mined materials for fuel and/or upgrades

require("physics")

Station = {
}

Upgrade_List = { -- A state list of how the upgrades are progressing; this doesn't really affec the Probe, it's just for easier UI generation and control
	thrust = 1,
	torque = 1,
	boost = 1,
	radar = 1,
	scanner = 0, -- Generally, 0 means an equipment that is not present yet :)
	autobreak = 0,
	drill = 1,
	storage = 1,
	pump = 1,
	tank = 1,
	vacuum = 0
}

-- Stock of primitive elements, distributed among all stations
Master_Stock = setmetatable({},
{
__index = function(t,i)
	if rawget(t,i) == nil then
		return 0
	else
		return t[i]
	end
end
}
)

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
		main_probe.energy = math.min(main_probe.max_energy, main_probe.energy + dt)
	end
	
	-- Fill up the stocks
	while #main_probe.storage > 0 do
		for E,x in chemComposition(main_probe.storage[1]) do
			print(E,x)
			if not x or x == "" then
				Master_Stock[E] = Master_Stock[E] + 1
			else
				Master_Stock[E] = Master_Stock[E] + x
			end
		end
		table.remove(main_probe.storage, 1)
	end
	
	for E,x in pairs(main_probe.tank) do
		print(E,x)
		for e,n in chemComposition(E) do
			print(e,n)
			if not n or n == "" then
				Master_Stock[e] = Master_Stock[e] + x
			else
				Master_Stock[e] = Master_Stock[e] + n*x
			end
		end
		main_probe.tank[E] = nil
	end
end

function Station:draw()	
	Body.draw(self)
	
	-- Draw Station UI iff the probe is docked
	if not bodiesTouching(self, main_probe) then return end
	
	love.graphics.setCanvas(layers.UI)
	
	love.graphics.push()
	love.graphics.origin()
	
	love.graphics.setColor(0,24,0,192)
	love.graphics.rectangle("fill",0,0,love.window.getWidth(),144)
	
	love.graphics.pop()
end