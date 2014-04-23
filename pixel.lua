--[[ Pixel class
These are the pesky pixels we're defending our zone against
]]

Pixel = {size = 16}
Pixel.__index = Pixel

-- List of all pixels
pixels = {}
lastindex = 0

-- Score value depending on game difficulty
pixelval = {Easy=4, Medium=10, Hard=16}

function Pixel.new(x, y, color, speed, ptype)
	--[[
		x,y = pixel's initial position
		color = pixel's color name
		type = common, flash, hollow or rainbow
	]]
	P = setmetatable({x = x or 0, y = y or 0, color = color or {r=0xff, g=0xff, b=0xff}, speed = speed or 16, type = ptype or "common"}, Pixel)
	if P.type == "flash" then
		P.angle = 0
		if P.color.r ~= 0xff or P.color.g ~= 0xff or P.color.b ~= 0xff then
			P.color_offset = {r=0xff - P.color.r, g=0xff - P.color.g, b=0xff - P.color.b}
		else -- Pixel is white, need to flash to black
			P.color_offset = {r=-0xff, g=-0xff, b=-0xff}
		end
	end

	if P.type == "rainbow" then
		P.cID = 1
		P.color = COLOR[P.cID]
	end
	
	local d = P.speed / P:distCenter()
	P.vx = d * (love.window.getWidth()/2 - x)
	P.vy = d * (love.window.getHeight()/2 - y)
	P.index = string.format('%08x',lastindex)
	lastindex = lastindex + 1
	pixels[P.index] =  P
	print(string.format("New pixel %s at %d,%d", P.index, P.x, P.y))
	return P
end

function Pixel:draw()
	-- Draw pixel on position, obviously
	if self.type == "rainbow" then
		self.cID = (self.cID % #COLOR) + 1
		self.color = COLOR[self.cID]
	end

	if self.type == "flash" then
		local flash_factor = math.sin(math.rad(self.angle))
		--[[ love.graphics.setColor(self.color.r + self.color_offset.r * flash_factor,
			self.color.g + self.color_offset.g * flash_factor,
			self.color.b + self.color_offset.b * flash_factor, 255) ]] -- Instead of offset to white, let's change the transparency :)
		love.graphics.setColor(self.color.r, self.color.g, self.color.b, 32 + 223*flash_factor)
	else
		love.graphics.setColor(self.color.r, self.color.g, self.color.b, 255)
	end
	
	if self.type == "hollow" then
		love.graphics.rectangle("line", self.x-(Pixel.size/2), self.y-(Pixel.size/2), Pixel.size, Pixel.size)
	else
		love.graphics.rectangle("fill", self.x-(Pixel.size/2), self.y-(Pixel.size/2), Pixel.size, Pixel.size)
	end

	-- love.graphics.print(self.vx .. ";" .. self.vy, self.x - 8, self.y + 12)
end

function Pixel:isClicked(mx, my)
	-- Check if pixel was clicked
	--return math.abs(self.x - mx) <= Pixel.size/2 and math.abs(self.y - my) <= Pixel.size/2
	return (self.x-mx)^2 + (self.y-my)^2 <= 2*(self.size/2)^2 + 4
end

function Pixel:destroy(clicked)
	-- Destroy pixel, add to score, update streak
	-- (clicked parameter denotes whether this pixel is destroyed by direct or indirect means)
	pixels[self.index] = nil
	addParticle(partSpark, self.x, self.y, 10, 5, self.color, 2)
	if clicked then
		-- Apply radius of death(if there is a streak going on :V)
		if self.type ~= "rainbow" then
			if streak.n > 0 and compare_color(self.color,streak) then
				addParticle(partFlash, self.x, self.y, 15, 16 * streak.n, self.color)
				for i,pixel in pairs(pixels) do
					if math.sqrt((pixel.x - self.x)^2 + (pixel.y - self.y)^2) < (16 * streak.n) then
						pixel:destroy(false)
					end
				end
			end
			-- Check streak
			if compare_color(self.color,streak) then
				streak.n = streak.n + 1
				multiplier = multiplier + 1
			else
				multiplier = 1
				streak.n, streak.r, streak.g, streak.b = 1, self.color.r, self.color.g, self.color.b
			end
		end
		
		if settings.sound == "ON" then
			sound.dissolve:play()
		end
	end

	if clicked then
		score = score + pixelval[settings.difficulty]*multiplier
	else
		score = score + pixelval[settings.difficulty]/2
	end
	
	if clicked and self.type == "flash" then
		for i,pixel in pairs(pixels) do
			if self.color == pixel.color then
				pixel:destroy(false)
			end
		end
	end
	
	if clicked and self.type == "hollow" then
		if zone.defense < 3 then
			zone.defense = zone.defense + 1
		end
	end

	if clicked and self.type == "rainbow" then
		timestop = 3
		streak = {r=255, g=255, b=255, n=0}
	end
end

function Pixel:update(dt)
	-- Check if pixel has reached the Zone
	local d = self:distCenter()
	if d < zone.size then
		pixels[self.index] = nil
		if zone.defense <= 0 then
			gameover = true
			if highscore < score then
				highscore = score
			end
		else
			zone.defense = zone.defense - 1
		end
	end
	-- Update position towards the center
	-- Check if time is stopped before moving, of course
	if timestop <= 0 then
		self.x = self.x + dt*self.vx
		self.y = self.y + dt*self.vy
	end
	-- Update flash effect
	if self.type == "flash" then
		self.angle = (self.angle + dt*360) % 180
	end
end

-- Return pixel distance from the center
function Pixel:distCenter()
	return math.sqrt((love.window.getWidth()/2 - self.x)^2 + (love.window.getHeight()/2 - self.y)^2)
end