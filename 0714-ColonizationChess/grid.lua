-- Game Grid

font = {standard = love.graphics.newFont("assets/font/imagine_font.otf")}

Grid = {
	width = 0,
	height = 0,
	tiles = nil,

	x = 0,
	y = 0,
	tile_size = 8,
	
	-- Game statistics, for quicker assessment
	stats = {
		neutral = {},
		left = {},
		right = {}
	},

	focus = nil -- Tile in focus
}
Grid.__index = Grid

Tile = {
	x = 0,
	y = 0,
	grid = nil,
	owner = "neutral", -- the player that controls the tile
	occupation = 0,
	type = "normal"
}
Tile.__index = Tile

Players = {
	neutral = true,
	left = true,
	right = true
}

PlayerColors = {
	neutral = {64,64,64,255},
	left = {0,64,0,255},
	right = {64,0,128,255}
}

TileTypes = {
	normal = true,
	range = true,
	power = true,
	defense = true,
	base = true
}

function Grid:new(width, height, tsize, victory_condition)
	T = {}
	T.width = width or 15
	T.height = height or 8
	T.tile_size = tsize or 16

	T.x = (love.window.getWidth() - T.width*T.tile_size) / 2
	T.y = (love.window.getHeight() - T.height*T.tile_size) / 2

	T.tiles = {}
	for y = 1,T.height do
		T.tiles[y] = {}
		row = T.tiles[y]
		for x = 1,T.width do
			row[x] = setmetatable({x = x, y = y, grid = T, owner = "neutral", occupation = 0, type = "normal"}, Tile)
		end
	end

	-- Set player bases
	for by = 0,1 do
		for bx = 0,1 do
			local lT, rT = T.tiles[T.height/2 + by][1 + bx], T.tiles[T.height/2 + by][T.width - bx]
			lT.type = "base"
			rT.type = "base"
			lT:addOccupation(1,"left")
			rT:addOccupation(1,"right")
		end
	end

	-- Initialize game stats
	T.stats = {}
	for i,P in ipairs({"left", "right", "neutral"}) do
		T.stats[P] = {
			occupation = 0,
			towers = 0,
			bunkers = 0,
			turrets = 0,
			bases = 0
		}
	end
	
	-- Set Special tiles
	
	-- Set victory condition
	T.victory = victory_condition or Grid.victory

	return setmetatable(T, Grid)
end

-- Default victory condition function
-- Returns the name of the player who won, or nil
function Grid:victory()
	if self.stats.left.bases == 0 then
		return "right"
	elseif self.stats.right.bases == 0 then
		return "left"
	else
		return nil
	end
end

function Grid:updateStats()
	for p,S in pairs(self.stats) do
		for n,v in pairs(S) do
			S[n] = 0
		end
	end
	
	for x,y,T in self:iterator() do
		local S = self.stats[T.owner]
		S.occupation = S.occupation + 1
		if not T.type == "normal" then
			S[T.type + "s"] = S[T.type + "s"] + 1
		end
	end
end

function Grid:getTile(x, y)
	if x < 1 or x > self.width or y < 1 or y > self.height then
		return nil
	else
		return self.tiles[y][x]
	end
end

function Grid:getAdjacentTiles(x, y)
	return {
		self:getTile(x-1, y),
		self:getTile(x+1, y),
		self:getTile(x, y-1),
		self:getTile(x, y+1)
	}
end

function Grid:startTurn(player)
	self:updateStats()
	turn.player = player
	turn.pieces = self.stats[player].occupation
end

function Grid:iterator()
	local x,y = 0,1
	
	return function()
		if x >= self.width then
			if y >= self.height then
				return nil
			else
				x = 1
				y = y + 1
			end
		else
			x = x + 1
		end
		return x,y,self:getTile(x,y)
	end
end

function Grid:mousepressed(x, y, m)
	if m == "l" then
		if self.focus then
			local valid = false
			adj = self.focus:getAdjacents()
			for i = 1,4 do
				A = adj[i]
				if A then
					if A.owner == turn.player then
						valid = true
						break
					end
				end
			end
			
			if valid then
				turn.pieces = turn.pieces - 1
				self.focus:addOccupation(1)
				self:updateStats()
				
				if turn.pieces == 0 then
					if turn.player == "left" then
						self:startTurn("right")
					else
						self:startTurn("left")
					end
				end
			end
		end
	end
end

function Grid:mouseover()
	local mx, my = love.mouse.getPosition()
	mx = mx - self.x
	my = my - self.y

	if mx > 0 and mx < self.width*self.tile_size and my > 0 and my < self.height*self.tile_size then
		local fx, fy = math.ceil(mx / self.tile_size), math.ceil(my / self.tile_size)
		self.focus = self:getTile(fx, fy)
	else
		self.focus = nil
	end
	
	if endgame then self.focus = nil end
end

function Grid:draw()
	love.graphics.origin()
	love.graphics.translate(self.x, self.y)
	love.graphics.push()

	for x,y,T in self:iterator() do
		love.graphics.push()
		love.graphics.translate((x-1) * self.tile_size, (y-1) * self.tile_size)
		T:draw()
		if T.owner == "neutral" then
			adj = T:getAdjacents()
			for i = 1,4 do
				A = adj[i]
				if A then
					if A.owner == turn.player then
						love.graphics.setColor(255,255,255,64)
						love.graphics.rectangle("fill", 0, 0, self.tile_size, self.tile_size)
						break
					end
				end
			end
		end
		if self.focus == T then
			love.graphics.setColor(255,255,255,128)
			love.graphics.rectangle("fill", 0, 0, self.tile_size, self.tile_size)
		end
		love.graphics.setColor(0,0,0,128)
		love.graphics.rectangle("line", 0, 0, self.tile_size, self.tile_size)
		love.graphics.pop()
	end

	love.graphics.pop()

	love.graphics.setColor(unpack(PlayerColors[turn.player]))
	love.graphics.printf(string.format("YOUR TURN: %d", turn.pieces), 0, -font.standard:getHeight() - 1, self.width * self.tile_size, turn.player)

	love.graphics.translate(0, self.height * self.tile_size + 4)
	love.graphics.setBlendMode("replace")
	love.graphics.setColor(255,255,255,255)
	love.graphics.rectangle("line", 1, 1, self.width * self.tile_size - 2, font.standard:getHeight()*10 + 6)
	--love.graphics.rectangle("line", 4, 4, self.width * self.tile_size - 8, font.standard:getHeight()*10)
	love.graphics.rectangle("line", 1, 1, 3, 3)
	love.graphics.rectangle("line", self.width * self.tile_size - 4, 1, 3, 3)
	love.graphics.rectangle("line", 1, font.standard:getHeight()*10 + 3, 3, 3)
	love.graphics.rectangle("line", self.width * self.tile_size - 4, font.standard:getHeight()*10 + 3, 3, 3)
	love.graphics.setBlendMode("alpha")

	if self.focus then
		local F = self.focus
		local h = font.standard:getHeight()
		love.graphics.printf("Tile Info", 0, 4, self.width * self.tile_size, "center")

		love.graphics.printf(string.format("Occupation: %02d", F.occupation), 0, 4 + 2*h, self.width * self.tile_size, "center")
		love.graphics.printf(string.format("Owner: %s", F.owner), 0, 4 + 4*h, self.width * self.tile_size, "center")
		love.graphics.printf(string.format("Structures: %s", F.type), 0, 4 + 6*h, self.width * self.tile_size, "center")
	end

	love.graphics.origin()
end

-- Tile Operations

function Tile:addOccupation(value, player)
	local v = value
	local p = player or turn.player

	if self.owner ~= p then
		v = -v
	end
	
	self.occupation = self.occupation + v
	if self.occupation == 0 then
		self.owner = "neutral"
	elseif self.occupation < 0 then
		self.occupation = -self.occupation
		self.owner = p
	end
end

function Tile:getAdjacents()
	return self.grid:getAdjacentTiles(self.x, self.y)
end

function Tile:draw()
	local s = self.grid.tile_size
	love.graphics.setColor(unpack(PlayerColors[self.owner]))
	love.graphics.rectangle("fill", 0, 0, s, s)
	if self.type == "base" then
		love.graphics.setColor({0,0,0,128})
		love.graphics.circle("line", s/2, s/2, s/4)
	end
end