--[[ Pixel class
These are the pesky pixels we're defending our zone against
]]

Pixel = {}
Pixel.__index = Pixel

-- List of all pixels
pixels = {}

function Pixel.new(x, y, color, type)
	--[[
		x,y = pixel's initial position
		color = pixel's color name
		type = common, flash or hollow
	]]
	P = setmetatable({}, Pixel)
	table.insert(pixels, P)
	return P
end

function Pixel:draw()
	-- Draw pixel on position, obviously
end

function Pixel:isClicked(mx, my)
	-- Check if pixel was clicked
	return false
end

function Pixel:destroy(clicked)
	-- Destroy pixel, add to score, update streak
	-- (clicked parameter denotes whether this pixel is destroyed by direct or indirect means)
end

function update(dt)
	-- Update position towards the center
end