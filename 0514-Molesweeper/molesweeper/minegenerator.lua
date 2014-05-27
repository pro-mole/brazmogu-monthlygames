-- Random Minefield generator
-- Set up in a different module for organization purposes

-- Default tile data; used as metatable, and overwritten locally
_tile = {
	content = "empty",								-- What is inside this tile
	dirt = 10, 										-- Soil in this tile(affected by false positives)
	water = 0,
	humus = 0,
	known = false,									-- Does the player know what is in this tile?
	mark = false,									-- Did the player mark this tile?
	neighbors = 0									-- Number of neighboring suspect tiles(mines or false positives)
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
	local Mines = {}
	local x
	local y
	for m = 1,mines do
		repeat
			x = love.math.random(1, width)
			y = love.math.random(1, height)
		until validMine(F,x,y)

		addContent(F,x,y,"mine")
		addNeighbors(F,x,y)
		table.insert(Mines, {x,y})
	end

	-- Add false positives
	if settings.minefield.coppermoss == "YES" then
		moss = math.ceil(mines/4 * math.random())
		
		for m = 1,moss do
			if #Mines == 0 then
				break
			end
			local m = math.random(#Mines)
			local x,y = unpack(Mines[m])
			table.remove(Mines,m)
			
			local cluster = math.random(2,4) * 2
			local adjacents = {{-1,0},{0,-1},{1,0},{0,1}}
			local diags = {}
			if cluster == 8 then
				diags = {{-1,-1},{1,-1},{1,1},{-1,1}}
			elseif cluster == 6 then
				if math.random(2) == 1 then
					diags = {{-1,-1},{1,1}}
				else
					diags = {{1,-1},{-1,1}}
				end
			end
			
			for i,P in ipairs(diags) do table.insert(adjacents, P) end
			
			for i,T in ipairs(adjacents) do
				local _x,_y = x+T[1], y+T[2]
				if addContent(F, _x, _y, "coppermoss") then
					addNeighbors(F, _x, _y)
					alterTerrain(F, _x, _y, {water = 8})
				end
			end
		end
	end
	
	if settings.minefield.ironcap == "YES" then
		caps = math.ceil(mines/3 * math.random())
		
		for m = 1,caps do
			if #Mines == 0 then
				break
			end
			local m = math.random(#Mines)
			local x,y = unpack(Mines[m])
			table.remove(Mines,m)
			
			local dir
			local tips
			if math.random(2) == 1 then
				dir = "horz"
				tips = {x,x}
			else
				dir = "vert"
				tips = {y,y}
			end
			
			local cluster = math.random(3,5)
			
			while cluster > 0 do
				local _x, _y = x, y
				if math.random(2) == 1 then
					if dir == "horz" then
						_x = tips[1]-1
						if _x >= 1 then
							tips[1] = _x
						end
					else
						_y = tips[1]-1
						if _y >= 1 then
							tips[1] = _y
						end
					end
				else
					if dir == "horz" then
						_x = tips[2]+1
						if _x <= width then
							tips[2]= _x
						end
					else
						_y = tips[2]+1
						if _y <= height then
							tips[2]= _y
						end
					end
				end
				
				if _x >= 1 and _y >= 1 and _x <= width and _y <= height then
					if addContent(F, _x, _y, "ironcap") then
						addNeighbors(F, _x, _y)
						alterTerrain(F, _x, _y, {humus = 10})
					end
					if F[_y][_x].content ~= "mine" then cluster = cluster - 1 end
				end
			end
		end
	end

	if settings.minefield.goldendrop == "YES" then
		local flowers = math.ceil(mines/4 * math.random())

		for f = 1,flowers do
			local x,y = 0,0
			repeat
				x = math.random(1,width)
				y = math.random(1,height)
			until F[y][x].content == "empty"

			print ("Goldendrop added")

			addContent(F, x, y, "goldendrop")
			addNeighbors(F, x, y)
			alterTerrain(F, x, y, {humus = 8, water = 5})
		end
	end
	
	if not validBoard(F) then
		F = generateMinefield(width, height, mines)
	end
	
	return F
end

-- Check if the place is good for mines
-- Among other things, it cannot match false positive patterns
function validMine(field, x, y)
	return (math.abs(x - settings.minefield.start.x) + math.abs(y - settings.minefield.start.y)) > 1 and field[y][x].content == "empty"
end

-- Change terrain composition at tile [x,y] and adjacents
function alterTerrain(field, x, y, terrain)
	local height = #field
	local width = #field[1]
	
	for _x = -1,1 do
		for _y = -1,1 do
			if y + _y >= 1 and y + _y <= height and
				x + _x >= 1 and x + _x <= width then
				local d = math.abs(_x) + math.abs(_y)
				for param,val in pairs(terrain) do
					if d == 0 then
						field[y+_y][x+_x][param] = field[y+_y][x+_x][param] + terrain[param]
					elseif d == 1 then
						field[y+_y][x+_x][param] = field[y+_y][x+_x][param] + terrain[param]/4
					elseif d == 2 then
						field[y+_y][x+_x][param] = field[y+_y][x+_x][param] + terrain[param]/16
					end
				end
			end
		end
	end
end

-- Add to the neighbor count of all tiles adjacent to [x,y]
function addNeighbors(field, x, y)
	local height = #field
	local width = #field[1]
	
	for _x = -1,1 do
		for _y = -1,1 do
			if y + _y >= 1 and y + _y <= height and
				x + _x >= 1 and x + _x <= width then
				field[y+_y][x+_x].neighbors = field[y+_y][x+_x].neighbors + 1
			end
		end
	end
end

-- Change tile [x,y]'s content
function addContent(field, x, y, content)
	local height = #field
	local width = #field[1]
	
	if x >= 1 and x <= width and
		y >= 1 and y <= height then
		if field[y][x].content == "empty" then
			field[y][x].content = content
			return true
		end
	end
	
	return false
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