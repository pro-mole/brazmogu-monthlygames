-- Randomized textures for our planets and stuff

-- Global 

-- Create a texture for a given body using predefined patterns
-- Variable number of patterns will be applied in the order they are defined(as an array where the first element is the pattern name, follolwed by whatever else is needed)
function generateTexture(size, ...)
	local tex = love.graphics.newCanvas(size*2, size*2)
	
	love.graphics.setCanvas(tex)
	
	love.graphics.push()
	
	love.graphics.setStencil(
		function()
			love.graphics.circle("fill", size, size, size, 32)
		end
	)
	
	for i, pattern in ipairs{...} do
		local mode = pattern[1]
		print(mode)

		pattern[1] = size

		if (Pattern[mode]) then
			Pattern[mode](unpack(pattern))
		end
	end
	
	love.graphics.pop()
	love.graphics.setCanvas()
	love.graphics.setStencil()
	return tex
end

-- Pattern Routines
Pattern = {}

-- Solid fill
-- Params: Color
Pattern["solid"] = function (size, color)
	love.graphics.setColor(unpack(color))
	love.graphics.rectangle("fill", 0, 0, size*2, size*2)
end

-- Gradient Fill
-- Params: Color1 -> Color2, smoothness(1 to 100)
Pattern["gradient"] = function (size, color1, color2, smooth)
	if not smooth then smooth = 10 end
	for i = 0,1,1/smooth do
		local C = {}
		for k = 1,4 do
			C[k] = color1[k]*i + color2[k]*(1-i)
		end
		love.graphics.setColor(unpack(C))
		love.graphics.circle("fill", size, size, size*(1 + (1/smooth) - i))
	end
end

-- Scatter - randomly scatter pixels on the texture
-- Params: Color, Scatter Density(0 to 1)
Pattern["scatter"] = function (size, color, density)
	local dots, area, alpha = 0, size^2, color[4]/255
	while dots/area < density do
		love.graphics.setColor(unpack(color))
		love.graphics.point(math.random()*size*2, math.random()*size*2)
		dots = dots + alpha
	end
end

-- Blotch - randomly distributed blotches on the texture
-- Params: Color, Average blotch size, Density(0 to 1)
Pattern["blotch"] = function (size, color, avgsize, density)
	local splots, area, alpha, splotsize = 0, size^2, color[4]/255, avgsize
	while splots/area < density do
		love.graphics.setColor(unpack(color))
		local sp_size = splotsize * ((math.random()+math.random()+math.random())/3 + 0.5)
		local sp_area = math.pi*sp_size^2 / 2
		love.graphics.circle("fill", math.random()*size*2, math.random()*size*2, sp_size/2, 36)
		splots = splots + sp_area * alpha
	end
end

-- Test Code
modes = {"gradient","scatter", "blotch"}

for i = 1,10 do
	math.randomseed(i * os.time())
	effects = {{"solid", {math.random(255),math.random(255),math.random(255),255}}}
	for i = 1,math.random(0,4) do
		local new_effect = modes[math.random(#modes)]
		if new_effect == "solid" then
			table.insert(effects, {new_effect, {math.random(255),math.random(255),math.random(255), math.random(255)}})
		elseif new_effect == "gradient" then
			table.insert(effects, {new_effect, {math.random(255),math.random(255),math.random(255), math.random(255)}, {math.random(255),math.random(255),math.random(255), math.random(255)}, math.random(5,50)})
		elseif new_effect == "scatter" then
			table.insert(effects, {new_effect, {math.random(255),math.random(255),math.random(255), math.random(255)}, math.random()})
		elseif new_effect == "blotch" then
			table.insert(effects, {new_effect, {math.random(255),math.random(255),math.random(255), math.random(255)}, math.random(3,6), math.random()})
		end
	end
	local index = math.random(65535)
	print(index)
	local texture = generateTexture(2^math.random(5,8), unpack(effects))
	texture:getImageData():encode(string.format("texture%05d.png", index), "png")
end

print(love.filesystem.getSaveDirectory())