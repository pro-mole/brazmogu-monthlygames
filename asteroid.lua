-- Asteroid module
--- An asteroid is a small-sized celestial body composed of rocky matter

require("physics")

Asteroid = {
	minerals = nil, -- Set of metallic concentration on the asteroid's composition
	mineral_depth = 1, -- Depth of metal deposits; raises as player drills
}

Asteroid.__tostring = Body.__tostring

function Asteroid:__index(index)
	if rawget(self,index) ~= nil then
		return self[index]
	elseif Asteroid[index] ~= nil then
		return Asteroid[index]
	else
		return Body[index]
	end
end

function Asteroid.new(specs)
	local T = Body.new(specs)
	
	local A = setmetatable(T, Asteroid)
	A.class = 2

	if A.minerals then
		A.mineral_depth = 1
	end
	
	table.insert(Universe.meteors, A)
	return A
end

function Asteroid:delete()
	Body.delete(self)
	
	for i,A in ipairs(Universe.meteors) do
		if A == self then
			table.remove(Universe.meteors, i)
			break
		end
	end
end

function Asteroid:draw()	
	Body.draw(self)
end