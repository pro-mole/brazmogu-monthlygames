-- Universe Generator
-- Here, shit gets real

Universe = {
	probes = {},
	stars = {},
	planets = {},
	satellites = {},
	meteors = {},
	comets = {},
	stations = {}
}

function Universe:iterator()
	local pointer = 0
	local bodyTables = {"probes", "stars", "planets", "satellites", "meteors", "comets", "stations"}
	return function()
		pointer = pointer + 1
		if pointer <= #bodyTables then
			return pointer, bodyTables[pointer]
		else
			return nil
		end
	end
end

function Universe:generate(seed)
	-- Create star systems randomly
	math.randomseed(seed or os.time())
	local x,y = math.random(-32768,32768),math.random(-32768,32768)

	local S = self:createStar(x,y)
	
	love.event.quit()

	--[[local St = self.stars[math.random(#self.stars)]
	local v,dir = addVectors(getOrbitVelocity(St,St.size*2),0, St.v,St.dir)
	Probe.new({name = "PROBE", x = St.x, y = St.y - St.size*2, v = v, dir = dir})]]
end

function planOrbits(orbits, rangetable, quantum, massrange, sizerange, gravthreshold)
	while true do
		local intvl, range = 0,0
		
		for i = 1,#rangetable,2 do
			if range < (rangetable[i+1] - rangetable[i]) then
				intvl = i
				range = (rangetable[i+1] - rangetable[i])
			end
		end
		
		-- print(range)
		-- print(unpack(rangetable))
		
		if range < quantum then
			break
		end
		
		local mass, size, space
		repeat
			mass, size = 2^math.random(unpack(massrange)), 2^math.random(unpack(sizerange))
			space = math.sqrt(Physics.K * mass / gravthreshold)
		until space*2 <= range
		
		-- print(Pspace)
		local dist = math.randomNormal(0.5, 0.1) * (range - space*2) + rangetable[intvl]
		table.insert(rangetable, intvl+1, dist - space)
		table.insert(rangetable, intvl+2, dist + space)
		table.insert(orbits, {dist, mass, size, space})
		
		io.stdout:flush()
	end
end

-- Second idea for generation
-- Instead of trying to fit stuff, generate it procedurally making sure everything fits
-- Also, just for starters, let's 
function Universe:createStar(x, y)
	local mass = 2^math.random(10,13)
	local size = 2^math.random(8,11)
	local density = mass/size
	print(mass,size)
	
	-- Define color based on density
	local color
	if density > 8 then
		color = {255,255,255,255}
	elseif density > 4 then
		color = {0,208,255,255}
	elseif density > 2 then
		color = {0,128,255,255}
	elseif density > 1 then
		color = {255,255,0,255}
	elseif density > 0.5 then
		color = {255,192,64,255}
	else
		color = {192,0,0,255}
	end
	
	-- Define orbit range
	local orbitrange = {size*2, math.sqrt(Physics.K * mass / 2^-10)}
	local planets = {}
	local stations = {}
	local asteroids = {}
	local comets = {}
	local stations = {}
	
	-- Plan out the planetary orbits
	planOrbits(planets, orbitrange, mass*2, {7,11}, {5,8}, 2^-2)
	
	-- Plan out asteroid belts
	planOrbits(asteroids, orbitrange, mass, {2,4}, {3,4}, 2^6)
	
	-- Plan out comets and roamers
	planOrbits(comets, orbitrange, mass/2, {2,5}, {3,4}, 2^7)
	
	-- Plan out stellar space stations
	planOrbits(stations, orbitrange, 64, {3,3}, {4,4}, 2^6)
	
	print("Planets:",#planets)
	--[[for i,P in ipairs(planets) do
		print(unpack(P))
	end]]
	print("Asteroid Ranges:",#asteroids)
	--[[for i,A in ipairs(asteroids) do
		print(unpack(A))
	end]]
	print("Comets:",#comets)
	--[[for i,C in ipairs(comets) do
		print(unpack(C))
	end]]
	print("Stations:",#stations)
	--[[for i,S in ipairs(stations) do
		print(unpack(S))
	end]]
	
	--Get shit done{}!
	local colors = 
	{{}, -- Gradient 1
	{},  -- Gradient 2
	{},  -- Luminosity
	{}}  -- Spots
	for i = 1,3 do
		colors[1][i] = color[i] * math.randomNormal(1, 0.1)
		colors[2][i] = color[i] * math.randomNormal(0.5, 0.1)
		colors[3][i] = color[i] * math.randomNormal(1.5, 0.1)
		colors[4][i] = color[i] * math.randomNormal(0.1, 0.05)
	end
	colors[1][4] = 255
	colors[2][4] = 255
	colors[3][4] = 192
	colors[4][4] = 64
	S = Star.new({name=string.format("STAR%02X", math.random(0xff)),x=x, y=y, mass=mass, size=size, color = color,
	texture_params = {
		{"gradient", colors[1], colors[2], 128},
		{"noise", colors[3]},
		{"blotch", colors[4], 3, math.randomNormal(0.2, 0.05)}
	} })
	
	-- Fill all possible orbits with planets
	for i,Pdata in ipairs(planets) do
		local _angle = math.random() * 2*math.pi,
		_x = x + math.cos(angle)*Pdata[1],
		_y = y + math.sin(angle)*Pdata[1],
		_mass = Pdata[2],
		_size = Pdata[3]
		_space = Pdata[4]
		
		P = createPlanet(_x, _y, _mass, _size, _v, _dir, _space)
	end
end

function Universe:createPlanet(x, y, mass, size, v, vdir)
	local density = mass/size
	
	-- Scramble common minerals
	local base_minerals = {
		{"Fe", {192,64,64,255}},
		{"C",  {64,64,64,255}},
		{"Si", {255,208,144,255}},
		{"Cu", {64,255,64,255}},
		{"Al", {255,192,192,255}},
		{"Ag", {128,128,128,255}},
		{"Au", {144,96,32,255}},
		{"Hg", {128,64,64,255}},
		{"S",  {192,192,32,255}}
		{"P",  {192,192,32,255}}
	}
	
	local minerals = {}
	local base_color = nil
	local m = #base_minerals
	local minrock, maxrock = m, m^2
	while #minerals < #base_minerals do
		local i = math.random(1,#base_minerals)
		local rock = base_minerals[i]
		
		if not base_color then base_color = rock[2]
		minerals[rock[1]] = math.random(minrock, maxrock)
		minrock = minrock - 1
		maxrock = maxrock - m
		table.remove(base_minerals, i)
	end
	
	-- Scramble rare minerals
	rare_minerals = {"U","Ra","Pu"}
	for i,R in ipairs(rare_minerals)
		minerals[R] = math.random(0, math.log(mass)/math.log(2))
	end
	
	-- Atmosphere and Liquid composition parameters
	local elements = {
		{"O", {128,192,255,255}},
		{"N", {255,255,255,128}},
		{"S", {255,255,128,255}},
		{"Cl", {128,255,128,255}}
	}
	local b = math.random(1,#elements)
	local base_gas, atmosphere_color = unpack(elements[b])
	
	-- Scramble liquids
	local base_liquids = {
		O =  {"H2O"},
		N =  {"NH4"},
		S =  {"H2SO4"},
		Cl = {"HCl"}
	}
	
	-- Scramble atmosphere
	local base_gases = {
		H = {"H","He","CH4"},
		O =  {"O"},
		N =  {"N"},
		Cl = {"Cl"}
	}
end

function Universe:createSatellite(x, y, v, vdir)

end

return Universe