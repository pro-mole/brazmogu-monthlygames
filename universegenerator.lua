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
		table.insert(orbits, {dist, mass, size})
		
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
	colors[3][4] = 128
	colors[4][4] = 96
	--[[S = Star.new({name=string.format("STAR%02X", math.random(0xff)),x=x, y=y, mass=mass, size=size,
	texture_params = {
		{"gradient", colors[1], colors[2], 128},
		{"noise", colors[3]},
		{"blotch", colors[4], 3, math.randomNormal(0.2, 0.05)}
	} })]]
end

function Universe:createPlanet(x, y, v, vdir)

end

function Universe:createSatellite(x, y, v, vdir)

end

return Universe