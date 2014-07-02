-- Space Station module
--- Space stations are where the player will be able to recharge his batteries and exchange mined materials for fuel and/or upgrades

require("physics")

Station = {
}

Upgrade_List = { -- A state list of how the upgrades are progressing; this doesn't really affec the Probe, it's just for easier UI generation and control
	-- {Name, Current Level, Max Level, Requirements}
	thrust = {"Engine Thrust",1,4,{}},
	torque = {"Reaction Wheel",1,4,{}},
	boost = {"Booster Potency",1,4,{}},
	radar = {"Radar Range",1,8,{}},
	scanner = {"Planet Scanner",0,1,{}}, -- Generally, 0 means an equipment that is not present yet :)
	autobreak = {"AutoBrerak",0,1,{}},
	drill = {"Drill Efficiency",1,4,{}},
	storage = {"Storage Capacity",1,4,{}},
	pump = {"Pump Efficiency",1,4,{}},
	tank = {"Tank Capacity",1,4,{}},
	vacuum = {"Vaccum Chamber",0,4,{}}
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
	S.fill_p = 0
	
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
	
	-- Fill up the stocks(with a little delay, for charm)
	if self.fill_p < 1 then
		self.fill_p = self.fill_p + 2*dt
	else
		self.fill_p = 0
		if #main_probe.storage > 0 then
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
			break
		end
	end
end

function Station:draw()	
	Body.draw(self)
	
	-- Draw Station UI iff the probe is docked
	if not bodiesTouching(self, main_probe) then return end
	
	love.graphics.setCanvas(layers.UI)
	
	love.graphics.push()
	love.graphics.origin()
	
	love.graphics.setColor(0,24,0,240)
	love.graphics.rectangle("fill",0,0,love.window.getWidth(),144)
	
	love.graphics.setColor(255,255,255,255)
	love.graphics.setFont(font.standard)
	
	-- Element Stock
	love.graphics.print("Master Stock:", 4, 4)
	local total_lines = ((144 - 8)/ font.standard:getHeight())/2 - 1
	local offset = font.standard:getWidth("X")
	local line_width = offset * 10
	local row,col = 0,0
	for i,E in ipairs(elements) do
		love.graphics.setColor(element_color[E])
		love.graphics.print(string.format("%s:", E), 4 + col*line_width, 4 + (row+1) * font.standard:getHeight()*2)
		love.graphics.print(string.format("%04d", Master_Stock[E]), 4 + col*line_width + offset*3, 4 + (row+1) * font.standard:getHeight()*2)
		row = row + 1
		if row >= total_lines then
			row = 0
			col = col + 1
		end
	end
	
	-- Upgrades
	
	love.graphics.pop()
end