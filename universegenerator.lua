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

-- Temporary heap of bodies
-- For when we need to backtrack
backtrack = {
	probes = {},
	stars = {},
	planets = {},
	satellites = {},
	meteors = {},
	comets = {},
	stations = {},
	iterator = Universe.iterator
}

function Universe:generate(seed)
	-- Create star systems randomly
	math.randomseed(seed or os.time())
	local x,y = math.random(-1024,1024),math.random(-1024,1024)

	S = self:createStar(x,y)
	table.insert(Universe.stars, S)

	local P = self.planets[math.random(#self.planets)]
	table.insert(Universe.probes, Probe.new({name = "PROBE", x = P.x, y = P.y - P.size*2 , mass = 1, size = 8}))
end

function Universe:createStar(x, y)
	-- Generate star
	local mass = math.random(2^10, 2^12)
	local size = math.random(2^8, 2^11)
	local density = mass/size

	local texture = {}
	if density > 64 then
		texture[1] = {"gradient", {255, 255, 255, 255}, {192, 192, 192, 255}, 100}
	elseif density > 32 then
		texture[1] = {"gradient", {128, 255, 255, 255}, {64, 192, 192, 255}, 100}
	elseif density > 16 then
		texture[1] = {"gradient", {128, 192, 255, 255}, {128, 64, 192, 255}, 100}
	elseif density > 4 then
		texture[1] = {"gradient", {255, 255, 64, 255}, {192, 192, 64, 255}, 100}
	elseif density > 1 then
		texture[1] = {"gradient", {255, 192, 64, 255}, {192, 64, 48, 255}, 100}
	else
		texture[1] = {"gradient", {192, 0, 0, 255}, {64, 0, 0, 255}, 100}
	end

	texture[2] = {"scatter", {64,64,64,64}, 0.8}
	texture[3] = {"blotch", {64,64,64,64}, 3, 0.5}
	texture[3] = {"blotch", {255,255,255,32}, 3, 0.5}

	local S = Star.new({name = string.format("STR%03d", math.random(999)), x = x, y = y, mass = mass, size = size,
		texture_params = texture})

	local omax = math.sqrt(S.mass * Physics.K / 2^-7)
	local omin = math.sqrt(S.mass * Physics.K / 2^-3)
	
	-- Add planetary sistems randomly
	local validrange = {omin,omax}
	local n = math.random(math.floor(omax-omin / S.size)/2048)
	print ("Planets:",n)
	io.stdout:flush()
	for i = 1,n do
		local valid = false

		while not valid do
			local angle = math.rad(math.random(360))
			local dangle = 0
			if math.random(2) == 1 then
				dangle = math.pi/2
			else
				dangle = -math.pi/2
			end

			local intvl = 0
			for j = 1,#validrange/2 do
				if intvl == 0 or (validrange[j*2] - validrange[j*2-1] > validrange[intvl*2] - validrange[intvl*2-1]) then
					intvl = j
				end
			end
			local dist = math.random(validrange[intvl*2-1], validrange[intvl*2])
			
			local P,I = self:createPlanet(x + math.cos(angle)*dist, y + math.sin(angle)*dist, getOrbitVelocity(S, dist), angle + dangle)
			
			valid = false
			for j = 1,#validrange,2 do
				if dist - I >= validrange[j] and dist + I <= validrange[j+1] then
					valid = true
					print (P,I,math.sqrt(squareBodyDistance(P,S)),P.v)
					table.insert(validrange,j+1,dist-I)
					table.insert(validrange,j+2,dist+I)
					print(unpack(validrange))
				end
			end

			for k,T in backtrack:iterator() do
				for l,B in ipairs(backtrack[T]) do
					if valid then
						table.insert(Universe[T], B)
					else
						B:delete()
					end
				end
				backtrack[T] = {}
			end
			love.timer.sleep(1)
		end
	end
	
	-- Add comets
	
	-- Add meteors(roaming and belts)
	
	-- Add stellar space stations

	return S, omax
end

function Universe:createPlanet(x, y, v, vdir)
	-- Generate planet
	local mass = math.random(2^7, 2^9)
	local size = math.random(2^4, 2^9)
	local density = mass/size
	local atmosize = math.max((density * size) - size, 0)
	local t = ""
	
	if density > 8 then
		t = "gas giant"
	else
		t = "rocky"
	end
	
	local texture = {}
	texture[1] = {"gradient", {math.random(64,192), math.random(64,192), math.random(64,192), 255}, {math.random(32,128), math.random(32,128), math.random(32,128), 255}, 100}
	texture[2] = {"scatter", {math.random(32), math.random(32), math.random(32), 128}, math.random(4,8)/10}
	if math.random(10) == 1 and t == "rocky" then
		texture[3] = {"blotch", {math.random(32), math.random(32), math.random(32), 128}, math.random(2,5), math.random(3,5)/10}
	end

	local crust = {}
	crust["C"] = math.random(4,8)
	crust["Si"] = math.random(10,15)
	crust["Cu"] = math.random(2,6)
	crust["Fe"] = math.random(2,6)
	crust["Ti"] = math.random(0,3)
	crust["Ni"] = math.random(0,4)
	crust["Li"] = math.random(0,3)
	crust["U"] = math.random(0,1)
	crust["Ra"] = math.random(0,1)
	crust["Pu"] = math.random(0,1)
	
	local liquids = nil
	if density > 4 and density < 8 then
		liquids = {}
		liquids["H2O"] = math.random(4,12)
		liquids["HN4"] = math.random(4,12)
		liquids["Br"] = math.random(2,6)
		liquids["Hg"] = math.random(1,3)
	end
	
	local atmo = nil
	if density > 1 then
		atmo = {}
		atmo["H"] = math.random(5,20)
		atmo["N"] = math.random(3,18)
		atmo["O"] = math.random(1,4)
		atmo["He"] = math.random(1,3)
		atmo["Cl"] = math.random(2,6)
		atmo["F"] = math.random(1,4)
	end
	
	local atmo_alpha = density
	
	local P = Planet.new({name = string.format("PL%04d", math.random(9999)), x = x, y = y, mass = mass, size = size, v = v, dir = dir,
		vrot = (math.random() - 0.5)*math.pi/4,
		metals = crust, metal_depth = math.random(1,5),
		liquids = liquids,
		atmosphere = atmo, atmosphere_size = atmosize, atmosphere_params = {{"gradient", {math.random(64,192), math.random(64,192), math.random(64,192), atmo_alpha * 32}, {math.random(32,128), math.random(32,128), math.random(32,128), atmo_alpha * 16}, 32}},
		texture_params = texture})
		
	-- Add satellites
	local omax = math.sqrt(P.mass * Physics.K / 2^-3)
	local omin = math.sqrt(P.mass * Physics.K / 2^-1)
	
	local occupied = {}
	local n = math.random(0,math.floor(omax-omin / (P.size + P.atmosphere_size)/1024)
	print ("Moons:",n)
	io.stdout:flush()
	for i = 1,n do
		local angle = math.rad(math.random(360))
		local dangle = 0
		if math.random(2) == 1 then
			dangle = math.pi/2
		else
			dangle = -math.pi/2
		end
		local dist, valid
		repeat
			valid = true
			dist = omax + math.random() * omax-omin
			for i,o in ipairs(occupied) do
				if math.abs(dist - o) < 2^9 then
					valid = false
				end
			end
		until valid
		local Sv,Sdir = addVectors(P.v, P.dir, getOrbitVelocity(P, dist), angle + dangle)
		local S = self:createSatellite(x + math.cos(angle)*dist, y + math.sin(angle)*dist, Sv, Sdir)
		table.insert(occupied, dist)
	end
	
	-- Add planetary space stations
	
	print(P)
	io.stdout:flush()
	table.insert(backtrack.planets, P)
	return P, omax
end

function Universe:createSatellite(x, y, v, vdir)
	-- Generate satellite
	local mass = math.random(2^4, 2^6)
	local size = math.random(2^5, 2^7)
	local density = mass/size
	local atmosize = math.max((density * size) - size, 0)
	local t = ""
	
	local texture = {}
	texture[1] = {"gradient", {math.random(64,192), math.random(64,192), math.random(64,192), 255}, {math.random(32,128), math.random(32,128), math.random(32,128), 255}, 100}
	texture[2] = {"scatter", {math.random(32), math.random(32), math.random(32), 128}, math.random(4,8)/10}
	while math.random(10) < 5 do
		texture[#texture+1] = {"blotch", {math.random(32), math.random(32), math.random(32), 128}, math.random(2,5), math.random(3,5)/10}
	end

	local crust = {}
	crust["C"] = math.random(1,8)
	crust["Si"] = math.random(10,15)
	crust["Fe"] = math.random(2,6)
	crust["U"] = math.random(0,1)
	
	local liquids = nil
	if density > 0.5 then
		liquids = {}
		liquids["H2O"] = math.random(4,12)
		liquids["HN4"] = math.random(4,12)
		liquids["Hg"] = math.random(1,3)
	end
	
	local S = Satellite.new({name = string.format("SAT%04d", math.random(9999)), x = x, y = y, mass = mass, size = size, v = v, dir = dir,
		vrot = (math.random() - 0.5)*math.pi/4,
		metals = crust, metal_depth = math.random(1,5),
		liquids = liquids,
		texture_params = texture})
	
	-- Add space station
	local omax = math.sqrt(P.mass * Physics.K / 2^-1)
	local omin = math.sqrt(P.mass * Physics.K / 1)

	print(S)
	io.stdout:flush()
	table.insert(backtrack.satellites, S)
	return S,omax
end

return Universe