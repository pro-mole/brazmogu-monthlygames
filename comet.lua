-- Comet module
--- A comet is a medium-sized celestial body composed of frozen liquid matter and some rock, that leaves a trail of material on its path

require("physics")

Comet = {
	minerals = nil, -- Set of metallic concentration on the satellite's composition
	mineral_depth = 1, -- Depth of metal deposits; raises as player drills
	liquids = nil, -- Liquid composition on the planet's surface
	liquid_depth = 1 -- Depth of liquid pools; raises as player pumps
}

Comet.__tostring = Body.__tostring

function Comet:__index(index)
	if rawget(self,index) ~= nil then
		return self[index]
	elseif Comet[index] ~= nil then
		return Comet[index]
	else
		return Body[index]
	end
end

function Comet.new(specs)
	local T = Body.new(specs)
	
	local C = setmetatable(T, Comet)
	C.class = 2

	if C.minerals then
		C.mineral_depth = 1
	end
	
	table.insert(Universe.comets, C)
	return C
end

function Comet:update(dt)
	if math.random() < 1/60 then
		local angle = math.random() * 2*math.pi
		local dist = math.random()
		
		Particles:add(PartSquare, layers.bot,
			self.x + math.cos(angle)*self.size*dist,
			self.y + math.sin(angle)*self.size*dist,
			math.random(self.size/8,self.size/2),
			self.v/2,
			self.d,
			math.pi/(math.random(1,6)),
			8,
			192,
			math.random()*10 + 20)
	end

	Body:update(dt)
end

function Comet:delete()
	Body.delete(self)
	
	for i,S in ipairs(Universe.comets) do
		if S == self then
			table.remove(Universe.comets, i)
			break
		end
	end
end

function Comet:draw()	
	Body.draw(self)
end