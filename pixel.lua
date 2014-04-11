--[[ Pixel class
These are the pesky pixels we're defending our zone against
]]

Pixel = {}
Pixel.__index = Pixel

-- List of all pixels
pixels = {}
lastindex = 0

function Pixel.new(x, y, color, speed, type)
	--[[
		x,y = pixel's initial position
		color = pixel's color name
		type = common, flash or hollow
	]]
	P = setmetatable({x = x or 0, y = y or 0, color = color or {0xff, 0xff, 0xff}, speed = speed or 16, type = "common"}, Pixel)
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
	love.graphics.setColor(self.color.r, self.color.g, self.color.b, 255)
	love.graphics.rectangle("fill", self.x-4, self.y-4, 8, 8)
	-- love.graphics.print(self.vx .. ";" .. self.vy, self.x - 8, self.y + 12)
end

function Pixel:isClicked(mx, my)
	-- Check if pixel was clicked
	return math.abs(self.x - mx) <= 4 and math.abs(self.y - my) <= 4
end

function Pixel:destroy(clicked)
	-- Destroy pixel, add to score, update streak
	-- (clicked parameter denotes whether this pixel is destroyed by direct or indirect means)
	pixels[self.index] = nil
	addParticle(partSpark, self.x, self.y, 10, 5, self.color, 2)
	if clicked then
		-- Apply radius of death(if there is a streak going on :V)
		if streak.n > 0 and self.color.r == streak.r and self.color.g == streak.g and self.color.b == streak.b then
			addParticle(partFlash, self.x, self.y, 15, 16 * streak.n, self.color)
			for i,pixel in pairs(pixels) do
				if math.sqrt((pixel.x - self.x)^2 + (pixel.y - self.y)^2) < (16 * streak.n) then
					pixel:destroy(false)
				end
			end
		end
		-- Check streak
		if self.color.r == streak.r and self.color.g == streak.g and self.color.b == streak.b then
			streak.n = streak.n + 1
			multiplier = multiplier + 1
		else
			multiplier = 1
			streak.n, streak.r, streak.g, streak.b = 1, self.color.r, self.color.g, self.color.b
		end
	end

	if clicked then
		score = score + 10*multiplier
	else
		score = score + 5
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
	self.x = self.x + dt*self.vx
	self.y = self.y + dt*self.vy
end

-- Return pixel distance from the center
function Pixel:distCenter()
	return math.sqrt((love.window.getWidth()/2 - self.x)^2 + (love.window.getHeight()/2 - self.y)^2)
end