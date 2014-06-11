-- Randomized textures for our planets and stuff

-- Global 

-- Create a texture for a given body using predefined patterns
-- Variable number of patterns will be applied in the order they are defined(as an array where the first element is the pattern name, follolwed by whatever else is needed)
function generateTexture(size, ...)
	local tex = love.graphics.newCanvas(size*2, size*2)
	
	love.graphics.setCanvas(tex)
	
	love.graphics.push()
	love.graphics.translate(size,size)
	
	love.graphics.setStencil(
		function()
			love.graphics.circle("fill", 0, 0, size, 32)
		end
	)
	
	for i, pattern in ipairs{...} do
		local mode = pattern[1]
		
		if mode == "solid" then
			local _, color = unpack(pattern)
			love.graphics.setColor(unpack(color))
			love.graphics.rectangle("fill", -size, -size, size*2, size*2)
		end
		
		if mode == "gradient" then
			local _, color1, color2 = unpack(pattern)
			for i = 0,1,0.1 do
				local C = {}
				for k = 1,4 do
					C[k] = color1[k]*i + color2[k]*(1-i)
				end
				love.graphics.setColor(unpack(C))
				love.graphics.circle("fill", 0, 0, size*(1.1 - i))
			end
		end
		
		if mode == "scatter" then
			local _, color, density = unpack(pattern)
			local dots, area, alpha = 0, size^2 * math.pi/2, color[4]/255
			while dots/area < density do
				local r,a = math.random()*size, math.random()*2*math.pi
				love.graphics.setColor(unpack(color))
				love.graphics.point(math.cos(a)*r, math.sin(a)*r)
				dots = dots + alpha
			end
		end
	end
	
	love.graphics.pop()
	love.graphics.setCanvas()
	love.graphics.setStencil()
	return tex
end