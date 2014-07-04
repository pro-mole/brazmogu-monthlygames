-- Randomized textures for our planets and stuff

-- Global 
simple_textures = true -- For when my video card just can't take it O_o

-- Create a wrapping for the background
function generateBackground(size, density)
	local sky = love.graphics.newCanvas(size, size)
	love.graphics.setCanvas(sky)
	love.graphics.setColor(0,0,0,255)
	love.graphics.rectangle("fill", 0, 0, size, size)

	-- Random white dots and stuff
	local stars = 0
	while stars < size/density do
		local s = math.random() + 1
		local x, y = math.random(size), math.random(size)

		local alpha = math.random(64,255)
		love.graphics.setColor(255,255,255,alpha)
		love.graphics.circle("fill", x, y, s, 128)

		stars = stars + math.pi * s^2 * (alpha/255)
	end

	love.graphics.setCanvas()

	local index = math.random(65535)
	sky:getImageData():encode(string.format("skybox%05d.png", index), "png")
	return sky
end

-- Load texture from file
-- For cases when we want to have fixed textures(probe, stations, etc)
function loadTexture(size, filename)
	local tex = love.graphics.newCanvas(size*2, size*2)
	
	love.graphics.setCanvas(tex)
	
	local tex_img = love.graphics.newImage(filename)
	
	love.graphics.setStencil(
		function()
			love.graphics.circle("fill", size, size, size, size*2)
		end
	)
	
	if tex_img:getWidth() ~= tex:getWidth() and tex_img:getHeight() ~= tex:getHeight() then
		love.graphics.scale(size*2 / math.max(tex_img:getWidth(),tex_img:getHidth()))
	end
	
	love.graphics.draw(tex_img, 0, 0)
	
	love.graphics.origin()
	love.graphics.setStencil()
	love.graphics.setCanvas()
	return tex
end

-- Create a texture for a given body using predefined patterns
-- Variable number of patterns will be applied in the order they are defined(as an array where the first element is the pattern name, follolwed by whatever else is needed)
function generateTexture(size, ...)
	local tex = love.graphics.newCanvas(size*2, size*2)
	
	love.graphics.setCanvas(tex)
	
	love.graphics.push()
	
	love.graphics.setStencil(
		function()
			love.graphics.circle("fill", size, size, size, math.max(size/2, 32))
		end
	)
	
	for i, pattern in ipairs{...} do
		local mode = pattern[1]
		pattern[1] = size

		if (Pattern[mode]) then
			if (not simple_textures) or (mode == "gradient") then
				print(mode)
				io.stdout:flush()
				Pattern[mode](unpack(pattern))
			end
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
	if not smooth or simple_textures then smooth = 10 end
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

-- Noise - randomly scatter pixels using Simplex Noise
-- Params: Color, Seed(optional)
Pattern["noise"] = function (size, color, seed)
	love.math.setRandomSeed(seed or os.time())
	for x = 1,size*2 do
		for y = 1,size*2 do
			local _c = {unpack(color)}
			_c[4] = love.math.noise(x,y) * _c[4]
			love.graphics.setColor(unpack(_c))
			love.graphics.point(x, y)
		end
	end
end

-- Test Code
--[[
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
]]