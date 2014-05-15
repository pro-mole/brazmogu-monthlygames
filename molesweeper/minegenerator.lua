-- Random Minefield generator
-- Set up in a different module for organization purposes

-- Default tile data; used as metatable, and overwritten locally
_tile = {
	content = "empty",									-- What is inside this tile
	terrain = {dirt = 0.7, water = 0.2, sand = 0.1},	-- Soil in this tile(affected by false positives)
	known = false,										-- Does the player know what is in this tile?
	mark = false,										-- Did the player mark this tile?
	neighbors = 0										-- Number of neighboring suspect tiles(mines or false positives)
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

	count = 0
	if not validBoard(F) then
		F = generateMinefield(width, height, mines)
	end
	count = count + 1
	
	print(count)
	return F
end

-- Check if the place is good for mines
-- Among other things, it cannot match false positive patterns
function validMine(field, x, y)
	return not (x == settings.minefield.start.x and y == settings.minefield.start.y) and field[y][x].content == "empty"
end

-- Check if the board is fully navigable
-- Two conditions here:
--- Every mine must have at least one empty neighbor(not counting diagonals)
--- Every empty spot on the board must be navigable to
function validBoard(field)
	local Node = {
		x = 0,
		y = 0,
		paths = {},
		visited = false
	}
	Node.__index = Node
	
	local F = {}
	
	local safeSet, mineSet = {}, {} -- Set of safe tiles and mine tiles
	local width,height = #field, #field[1]
	for j,row in ipairs(field) do
		table.insert(F,{})
		for i,cell in ipairs(row) do
			local N = setmetatable({x = i, y = j, paths = {}}, Node)
			table.insert(F[j], N)
			if j > 1 then N.paths["up"] = field[j-1][i].content ~= "mine" end
			if j < height then N.paths["down"] = field[j+1][i].content ~= "mine" end
			if i > 1 then N.paths["left"] = field[j][i-1].content ~= "mine" end
			if i < width then N.paths["right"] =field[j][i+1].content ~= "mine" end
			if cell.content == "mine" then
				table.insert(mineSet, N)
			else
				table.insert(safeSet, N)
			end
		end
	end
	
	-- Check mine accessibility
	for i,M in ipairs(mineSet) do
		if not (M.paths["up"] or M.paths["down"] or M.paths["left"] or M.paths["right"]) then
			print(M.paths["up"],M.paths["down"],M.paths["left"],M.paths["right"])
			print(M.x, M.y)
			return false
		end
	end
	
	--Check whole map accessibility
	local N = F[settings.minefield.start.y][settings.minefield.start.x]
	Node.visit = function(self)
		local delta = {up={0,-1}, left={-1,0}, down={0,1}, right={1,0}}
		self.visited = true
		for d,P in pairs(self.paths) do
			if P then
				--print(d, P)
				--print(self.x, self.y)
				--print(unpack(delta[d]))
				--print(F[self.y+delta[d][2]][self.x+delta[d][1]])
				if not F[self.y+delta[d][2]][self.x+delta[d][1]].visited then
					F[self.y+delta[d][2]][self.x+delta[d][1]]:visit()
				end
			end
		end
	end
	N:visit()
	
	for i,S in ipairs(safeSet) do
		if not S.visited then
			print(S.visited)
			print(S.x, S.y)
			return false
		end
	end
	
	return true
end