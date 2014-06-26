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
	table.insert(Universe.stars, S)

	local St = self.stations[math.random(#self.stations)]
	local v,dir = addVectors(getOrbitVelocity(St,St.size*2),0, St.v,St.dir)
	Probe.new({name = "PROBE", x = St.x, y = St.y - St.size*2, v = v, dir = dir})
end

-- Second idea for generation
-- Instead of trying to fit stuff, generate it procedurally making sure everything fits
-- Also, just for starters, let's 
function Universe:createStar(x, y)
	local mass = 2^math.random(10,13)
	local size = 2^math.random(8,11)
	local density = mass/size
	
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
	orbitrange = {size*2, math.sqrt(Physics.K * mass / 2^-10)}
	
	-- Plan out the planetary orbits
	while true do
		local intvl, range = 0,0
		
		for i = 1,#orbitrange,2 do
			if range < (orbitrange[i+1] - orbitrange[i]) then
				range = (orbitrange[i+1] - orbitrange[i])
			end
		end
		
		if range < 512 then
			break
		end
		
		local Pmass, Psize, Pspace
		repeat
			Pmass, Psize = 2^math.random(6,11), 2^math.random(5,8)
			Pspace = math.sqrt(Physics.K * mass / 2^-2)
		until Pspace*2 <= range
		
		local dist = math.randomNormal(0.5, 0.1) * (range - Pspace*2) + orbitrange[intvl] + range
		table.insert(orbitrange, i+1, dist - Pspace)
		table.insert(orbitrange, i+2, dist + Pspace)
	end
end

function Universe:createPlanet(x, y, v, vdir)

end

function Universe:createSatellite(x, y, v, vdir)

end

return Universe