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
	return function()
		if not self.pointer then
			self.pointer = 1
		else
			self.pointer = self.pointer + 1
		end

		local p = self.pointer
		if p <= #self.probes then
			return self.pointer, self.probes[p]
		else
			p = p - #self.probes
			if p <= #self.stars then
				return self.pointer, self.stars[p]
			else
				p = p - #self.stars
				if p <= #self.planets then
					return self.pointer, self.planets[p]
				else
					p = p - #self.planets
					if p <= #self.satellites then
						return self.pointer, self.satellites[p]
					else
						p = p - #self.satellites
						if p <= #self.meteors then
							return self.pointer, self.meteors[p]
						else
							p = p - #self.meteors
							if p <= #self.comets then
								return self.pointer, self.comets[p]
							else
								p = p - #self.comets
								if p <= #self.stations then
									return self.pointer, self.stations[p]
								else
									self.pointer = nil
									return nil
								end
							end
						end
					end
				end
			end
		end
	end
end

function Universe:generate(seed)
	-- Create star systems randomly
	math.randomseed(seed or os.time())
	local x,y = math.random(-65535,65535),math.random(-65535,65535)

	self:createStar(x,y)

	local P = self.planets[math.random(#self.planets)]
	Probe.new({name = "PROBE", x = P.x, y = P.y - P.size , mass = 1, size = 8})
end

function Universe:createStar(x, y)
	-- Generate star
	local mass = math.random(2^10, 2^12)
	local size = math.random(2^8, 2^11)

	local texture = {}
	if mass/size > 64 then
		texture[1] = {"gradient", {255, 255, 255, 255}, {192, 192, 192, 255}, 100}
	elseif mass/size > 32 then
		texture[1] = {"gradient", {192, 255, 255, 255}, {144, 192, 192, 255}, 100}
	elseif mass/size > 16 then
		texture[1] = {"gradient", {144, 192, 255, 255}, {128, 144, 192, 255}, 100}
	elseif mass/size > 8 then
		texture[1] = {"gradient", {255, 255, 128, 255}, {192, 192, 144, 255}, 100}
	elseif mass/size > 2 then
		texture[1] = {"gradient", {255, 192, 128, 255}, {192, 144, 96, 255}, 100}
	else
		texture[1] = {"gradient", {255, 0, 0, 255}, {144, 0, 0, 255}, 100}
	end

	texture[2] = {"scatter", {64,64,64,128}, 0.8}
	texture[3] = {"blotch", {64,64,64,128}, 3, 0.5}

	local S = Star.new({name = string.format("STR%03d", math.random(999)), x = x, y = y, mass = mass, size = size,
		texture_params = texture})

	local omax = math.sqrt(S.size * Physics.K / 0.01)
	local omin = math.max(omax/16, S.size*4)
	
	-- Add planetary sistems randomly
	for i = 1,math.random(12) do
		local angle = math.rad(math.random(360))
		local dangle = 0
		if math.random(2) == 1 then
			dangle = math.pi/2
		else
			dangle = -math.pi/2
		end
		local dist = omax + math.random() * omax-omin
		self:createPlanet(x + math.cos(angle)*dist, y + math.sin(angle)*dist, getOrbitVelocity(S, dist), angle + dangle)
	end
	
	-- Add comets
	
	-- Add meteors(roaming and belts)
	
	-- Add stellar space stations

	return S
end

function Universe:createPlanet(x, y, v, vdir, t)
	-- Generate planet
	local t = t or "rocky"
	local mass = math.random(2^6, 2^9)
	local size = math.random(2^6, 2^9)

	local texture = {}
	texture[1] = {"gradient", {math.random(64,192), math.random(64,192), math.random(64,192), 255}, {math.random(32,128), math.random(32,128), math.random(32,128), 255}, 100}
	texture[2] = {"scatter", {math.random(32), math.random(32), math.random(32), 128}, math.random(4,8)/10}
	if math.random(10) == 1 then
		texture[3] = {"blotch", {math.random(32), math.random(32), math.random(32), 128}, math.random(2,5), math.random(3,5)/10}
	end

	local crust = {}
	crust["C"] = math.random(4,8)
	crust["Si"] = math.random(10,15)
	crust["Fe"] = math.random(2,6)
	crust["Ti"] = math.random(0,3)
	crust["Ni"] = math.random(0,4)
	crust["Li"] = math.random(0,3)
	crust["U"] = math.random(0,1)
	
	local P = Planet.new({name = string.format("PL%04d", math.random(9999)), x = x, y = y, mass = mass, size = size, v = v, dir = dir,
		vrot = (math.random() - 0.5)*math.pi,
		metals = crust, metal_depth = math.random(1,5),
		texture_params = texture})
	-- Add satellites
	
	-- Add planetary space stations

	return P
end

function Universe:createSatellite(x, y)
	-- Genearte satellite
	
	-- Add space station
end

return Universe