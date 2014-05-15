-- Random Minefield generator
-- Set up in a different module for organization purposes

-- Default tile data; used as metatable, and overwritten locally
_tile = {
	content = "empty",	-- What is inside this tile?
	known = false,		-- Does the player know what is in this tile?
	mark = false,		-- Did the player mark this tile?
	neighbors = 0		-- Number of neighboring suspect tiles(mines or false positives)
}
Tile = {__index = _tile} -- Metatable

-- Simple function, to be extended
function generateMinefield(width, height, mines)
	local F = {}
	for i = 1,height do
		table.insert(F, {})
		local row = F[i]
		for j = 1,width do
			table.insert(row, setmetatable({}, Tile))
		end
	end

	-- Add mines
	for m = 1,mines do
		repeat
			x = love.math.random(1, width)
			y = love.math.random(1, height)
		until validMine(F,x,y)

		F[y][x].content = "mine"
		-- Add neighbor count to neighbors
		for _x = -1,1 do
			for _y = -1,1 do
				if y + _y >= 1 and y + _y <= height and
					x + _x >= 1 and x + _x <= width then
					F[y+_y][x+_x].neighbors = F[y+_y][x+_x].neighbors + 1
				end
			end
		end
	end

	return F
end

-- Check if the place is good for mines
-- Among other things, it cannot match false positive patterns
function validMine(field, x, y)
	return not (x ~= settings.minefield.start.x and y~= settings.minefield.start.y) and field[y][x].content == "empty"
end