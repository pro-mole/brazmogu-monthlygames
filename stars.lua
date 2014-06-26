-- Planet module
--- A planet is a large-sized celestial body that may or may not have an atmosphere

require("physics")

Star = {
	magnetosphere = nil, -- Magnetospheric composition (nil if there are no particles in the magnetosphere at all)
	light_level = 100, -- Intensity of light emmitted, for purposes of energy generation
	magnetosphere_size = 0 -- If there is an atmosphere, this should be the height it expands to
}

Star.__tostring = Body.__tostring

function Star:__index(index)
	if rawget(self,index) ~= nil then
		return self[index]
	elseif Star[index] ~= nil then
		return Star[index]
	else
		return Body[index]
	end
end

function Star.new(specs)
	local T = Body.new(specs)
	
	local S = setmetatable(T, Star)
	S.class = 5
	
	table.insert(Universe.stars, S)
	return S
end

function Star:delete()
	Body.delete(self)
	
	for i,S in ipairs(Universe.stars) do
		if S == self then
			table.remove(Universe.stars, i)
			break
		end
	end
end

function Star:draw()
	Body.draw(self)
	
	if self.magnetosphere then
		love.graphics.setCanvas(layers.bot)
		love.graphics.setColor(255,255,255,16)
		love.graphics.circle("fill", self.x, self.y, self.magnetosphere_size, 36)
		love.graphics.setColor(255,255,255,255)
	end
end