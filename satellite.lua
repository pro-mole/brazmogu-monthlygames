-- Satellite module
--- A satellite is a medium-sized celestial body composed of rocky matter

require("physics")

Satellite = {
	minerals = nil, -- Set of minerallic concentration on the satellite's composition
	mineral_depth = 1, -- Depth of mineral deposits; raises as player drills
	liquids = nil, -- Liquid composition on the planet's surface
	liquid_depth = 1 -- Depth of liquid pools; raises as player pumps
}

Satellite.__tostring = Body.__tostring

function Satellite:__index(index)
	if rawget(self,index) ~= nil then
		return self[index]
	elseif Satellite[index] ~= nil then
		return Satellite[index]
	else
		return Body[index]
	end
end

function Satellite.new(specs)
	local T = Body.new(specs)
	
	local S = setmetatable(T, Satellite)
	S.class = 3

	if S.minerals then
		S.mineral_depth = 1
	end
	
	table.insert(Space.satellites, S)
	return S
end

function Satellite:delete()
	Body.delete(self)
	
	for i,S in ipairs(Universe.satellites) do
		if S == self then
			table.remove(Universe.satellites, i)
			break
		end
	end
end

function Satellite:draw()	
	Body.draw(self)
end