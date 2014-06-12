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
			local _, color1, color2, smooth = unpack(pattern)
			if not smooth then smooth = 10 end
			for i = 0,1,1/smooth do
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
			local dots, area, alpha = 0, size^2, color[4]/255
			while dots/area < density do
				love.graphics.setColor(unpack(color))
				love.graphics.point(math.random()*size*2 - size, math.random()*size*2 - size)
				dots = dots + alpha
			end
		end
	end
	
	love.graphics.pop()
	love.graphics.setCanvas()
	love.graphics.setStencil()
	return tex
end

-- Test Code
modes = {"solid","gradient","scatter"}
effects = {{"solid", {math.random(255),math.random(255),math.random(255),255}}}

for i = 1,10 do
	math.randomseed(i * os.time())
	for i = 1,math.random(0,4) do
		local new_effect = modes[math.random(#modes)]
		if new_effect == "solid" then
			table.insert(effects, {new_effect, {math.random(255),math.random(255),math.random(255), math.random(255)}})
		elseif new_effect == "gradient" then
			table.insert(effects, {new_effect, {math.random(255),math.random(255),math.random(255), math.random(255)}, {math.random(255),math.random(255),math.random(255), math.random(255)}, math.random(5,50)})
		elseif new_effect == "scatter" then
			table.insert(effects, {new_effect, {math.random(255),math.random(255),math.random(255), math.random(255)}, math.random()})
		end
	end
	texture = generateTexture(2^math.random(5,8), unpack(effects))
	texture:getImageData():encode(string.format("texture%05d.png", math.random(65535)), "png")
end