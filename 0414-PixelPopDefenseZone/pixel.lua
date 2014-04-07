--[[ Pixel class
These are the pesky pixels we're defending our zone against
]]

Pixel = {}
Pixel.__index = Pixel

-- List of all pixels
pixels = {}

function Pixel.new(x, y, color, speed, type)
	--[[
		x,y = pixel's initial position
		color = pixel's color name
		type = common, flash or hollow
	]]
	P = setmetatable({x = x or 0, y = y or 0, color = color or {0xff, 0xff, 0xff}, speed = speed or 16, type = "common"}, Pixel)
	local d = P.speed / math.sqrt(math.pow(love.window.getWidth()/2 - x, 2) + math.pow(love.window.getHeight()/2 - y, 2))
	P.vx = d * (love.window.getWidth()/2 - x)
	P.vy = d * (love.window.getHeight()/2 - y)
	table.insert(pixels, P)
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
	return false
end

function Pixel:destroy(clicked)
	-- Destroy pixel, add to score, update streak
	-- (clicked parameter denotes whether this pixel is destroyed by direct or indirect means)
end

function Pixel:update(dt)
	-- Update position towards the center
	self.x = self.x + dt*self.vx
	self.y = self.y + dt*self.vy
end