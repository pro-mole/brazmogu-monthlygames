-- Planet module
--- A planet is a large-sized celestial body that may or may not have an atmosphere

require("physics")

Planet = {
	metals = nil, -- Set of metallic concentration on the planet's composition
	metal_depth = 1, -- Depth of metal deposits; raises as player drills
	liquids = nil, -- Liquid composition on the planet's surface
	liquid_depth = 1, -- Depth of liquid pools; raises as player pumps
	atmosphere = nil, -- Atmospheric composition (nil if there's not atmosphere at all)
	atmosphere_size = 0 -- If there is an atmosphere, this should be the height it expands to
}

Planet.__tostring = Body.__tostring

function Planet:__index(index)
	if rawget(self,index) ~= nil then
		return self[index]
	elseif Planet[index] ~= nil then
		return Planet[index]
	else
		return Body[index]
	end
end

function Planet.new(specs)
	local T = Body.new(specs)
	
	local P = setmetatable(T, Planet)
	P.class = 4

	if P.metals then
		P.metal_depth = 1
	end
	
	--table.insert(Universe.planets, P)
	return P
end

function Planet:draw()	
	Body.draw(self)
	
	if self.atmosphere then
		love.graphics.setCanvas(layers.top)
		love.graphics.setColor(255,255,255,255)
		love.graphics.push()
		love.graphics.translate(self.x, self.y)
		love.graphics.rotate(self.d)
		love.graphics.draw(self.atmosphere_texture, -self.size-self.atmosphere_size, -self.size-self.atmosphere_size)
		love.graphics.pop()
	end
end