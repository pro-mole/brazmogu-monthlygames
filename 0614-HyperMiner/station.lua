-- Space Station module
--- Space stations are where the player will be able to recharge his batteries and exchange mined materials for fuel and/or upgrades

require("physics")

Station = {
}

Upgrade_List = { -- A state list of how the upgrades are progressing; this doesn't really affec the Probe, it's just for easier UI generation and control
	-- {Name, Current Level, Max Level, Requirements, Hotkey}
	{"thrust","Engine Thrust",1,4,"Fe8","1"},
	{"torque","Reaction Wheel",1,4,"C4Cu2","2"},
	{"boost","Booster Potency",1,4,"Fe12","3"},
	{"radar","Radar Range",1,8,"SiRa","4"},
	{"scanner","Planet Scanner",0,1,"SiU","5"}, -- Generally, 0 means an equipment that is not present yet :)
	{"autobreak","AutoBrerak",0,1,"","6"},
	{"drill","Drill Efficiency",1,4,"Fe6","7"},
	{"storage","Storage Capacity",1,4,"Fe4","8"},
	{"pump","Pump Efficiency",1,4,"Cu4","9"},
	{"tank","Tank Capacity",1,4,"Si6","0"},
	{"vacuum","Vaccum Chamber",0,4,"Si2Ti6","`"}
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

for i,E in ipairs(elements) do
	Master_Stock[E] = 0
end

function Master_Stock:contains(molecule)
	local found = true
	for E,x in chemComposition(molecule) do
		if x == "" then x = 1 end
		if self[E] < tonumber(x) then
			found = false
		end
	end
	
	return found
end

function Master_Stock:subtract(molecule)
	for E,x in chemComposition(molecule) do
		if x == "" then x = 1 end
		self[E] = self[E] - x
	end
end

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
	S.texture_file = "assets/textures/station.png"
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

function Station:keypressed(key, isrepeat)
	-- If the probe is not docked, just go on
	if not bodiesTouching(self, main_probe) then return end

	-- Upgrades
	for i,U in ipairs(Upgrade_List) do
		local id, name, cur, tot, req, ukey = unpack(U)
		if key == ukey then
			print(unpack(U))
			if Master_Stock:contains(req) and cur < tot then
				Master_Stock:subtract(req)
				U[3] = U[3] + 1
				-- Perform upgrade on probe
				if id == "thrust" then
					main_probe.thrust = main_probe.thrust + 5
				elseif id == "torque" then
					main_probe.torque = main_probe.torque * 2
				elseif id == "drill" then
					main_probe.drill_rate = main_probe.drill_rate * 2
				elseif id == "pump" then
					main_probe.pump_rate = main_probe.pump_rate * 2
				elseif id == "storage" then
					main_probe.storage_capacity = main_probe.storage_capacity + 16
				elseif id == "tank" then
					main_probe.tank_capacity = main_probe.tank_capacity + 10
				elseif id == "boost" then
					main_probe.booster_rate = main_probe.booster_rate - 1
				elseif id == "radar" then
					main_probe.scope = main_probe.scope * 2
				elseif id == "scanner" then
					main_probe.scope = main_probe.scope * 2
				elseif id == "vacuum" then
					main_probe.vacuum_capacity = main_probe.vacuum_capacity + 20
				end
			end
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
	
	-- Refueling
	local refuel_intvl = 0
	if refuel_intvl > 0 then
		refuel_intvl = refuel_intvl - dt
	end
	if love.keyboard.isDown("f") then
		if refuel_intvl <= 0 then
			if Master_Stock:contains("CHO") and main_probe.fuel < main_probe.max_fuel then
				Master_Stock:subtract("CHO")
				main_probe.fuel = math.min(main_probe.fuel + 5, main_probe.max_fuel)
				refuel_intvl = 0.25
			end
			
			if Master_Stock:contains("NHO") and main_probe.booster < main_probe.max_booster then
				Master_Stock:subtract("NHO")
				main_probe.booster = math.min(main_probe.booster + 5, main_probe.max_booster)
				refuel_intvl = 0.25
			end
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
	
	-- Refill
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.printf("Refuel Station", 0, 4, love.window.getWidth(), "center")
	
	if Master_Stock:contains("CHO") then
		love.graphics.setColor(255, 192, 0, 255)
	else
		love.graphics.setColor(255, 192, 0, 128)
	end
	love.graphics.printf("Engine Fuel\n(CHO)", 0, 8 + font.standard:getHeight()*2, love.window.getWidth(), "center")
	if Master_Stock:contains("NH") then
		love.graphics.setColor(192, 255, 0, 255)
	else
		love.graphics.setColor(192, 255, 0, 128)
	end
	love.graphics.printf("Booster Fuel\n(NH)", 0, 8 + font.standard:getHeight()*5, love.window.getWidth(), "center")
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.printf("(Press F to Refuel)", 0, 8 + font.standard:getHeight()*8, love.window.getWidth(), "center")
	
	-- Upgrades
	love.graphics.translate(love.window.getWidth() * 2/3, 0)
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.printf("Upgrades", 0, 4, love.window.getWidth()/3, "center")
	local line_width = love.window.getWidth()/6
	for m = 0,1 do
		for n = 1,math.ceil(#Upgrade_List/2) do
			local i = m*math.ceil(#Upgrade_List/2) + n
			if i <= #Upgrade_List then
				local U = Upgrade_List[i]
				local id, name, cur, tot, req, key = unpack(U)
				
				if Master_Stock:contains(req) then
					love.graphics.setColor(255, 255, 255, 255)
				else
					love.graphics.setColor(255, 255, 255, 128)
				end
				love.graphics.printf(string.format("%s) %s (%s)", key, name, req), m*line_width, n*2.5*font.standard:getHeight(), line_width, "center")
				drawSegMeter((m+0.5)*line_width, n*2.5*font.standard:getHeight() + 1.5*font.standard:getHeight(), line_width-8, font.standard:getHeight(), {0, 32, 0, 255}, {0, 255, 0, 255}, tot, cur, "right", tot)
			end
		end
	end
	
	love.graphics.pop()
end