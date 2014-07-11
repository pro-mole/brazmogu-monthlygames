-- Game Grid

font = {standard = love.graphics.newFont("assets/font/imagine_font.otf")}

spritesheet = love.graphics.newImage("assets/sprite/board.png")

Grid = {
	width = 0,
	height = 0,
	tiles = nil,

	x = 0,
	y = 0,
	tile_size = 8,
	view_angle = 1,
	
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
	normal = {"None"},
	tower = {"Tower"}, -- +Range
	turret = {"Turret"}, -- +Attack
	bunker = {"Bunker"}, -- +Defense
	farm = {"Farm"}, -- +Moves
	base = {"Base"}
}

function Grid.new(width, height, tsize, angle, victory_condition)
	T = {}
	T.width = width or 15
	T.height = height or 8
	T.tile_size = tsize or 16
	T.view_angle = angle or 1

	T.x = (love.window.getWidth() - T.width*T.tile_size) / 2
	T.y = (love.window.getHeight() - T.height*T.tile_size*T.view_angle) / 2

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
			farms = 0,
			bases = 0
		}
	end
	
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
		--print(p)
		for n,v in pairs(S) do
			--print(n,v)
			S[n] = 0
		end
	end
	
	for x,y,T in self:iterator() do
		local S = self.stats[T.owner]
		S.occupation = S.occupation + 1
		if T.type ~= "normal" then
			--print(T.type)
			S[T.type.."s"] = S[T.type.."s"] + 1
		end
	end
	
	if self:victory() then
		endgame = true
		turn.player = "neutral"
	end
	
	io.stdout:flush()
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
		[string.format("%d;%d",x-1,y)] = self:getTile(x-1, y),
		[string.format("%d;%d",x+1,y)] = self:getTile(x+1, y),
		[string.format("%d;%d",x,y-1)] = self:getTile(x, y-1),
		[string.format("%d;%d",x,y+1)] = self:getTile(x, y+1)
	}
end

function Grid:startTurn(player)
	self:updateStats()
	turn.player = player
	turn.pieces = self.stats[player].farms + self.stats[player].bases
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
			adj = self.focus:getAdjacents(self.stats[turn.player].towers + 1)
			for i,T in pairs(adj) do
				A = T
				if A then
					if A.owner == turn.player then
						valid = true
						break
					end
				end
			end
			
			if valid then
				local other = "neutral"
				if turn.player == "left" then
					other = "right"
				else
					other = "left"
				end

				turn.pieces = turn.pieces - 1
				self.focus:addOccupation(1)
				self:updateStats()
				
				if turn.pieces == 0 then
					self:startTurn(other)
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
		if T.owner ~= turn.player and turn.player ~= "neutral" then
			adj = T:getAdjacents(self.stats[turn.player].towers + 1)
			for i,A in pairs(adj) do
				-- A = adj[i]
				if A then
					if A.owner == turn.player then
						love.graphics.setColor(255,255,255,32)
						love.graphics.rectangle("fill", 0, 0, self.tile_size, self.tile_size)
						break
					end
				end
			end
		end
		if self.focus == T then
			love.graphics.setColor(255,255,255,32)
			love.graphics.rectangle("fill", 0, 0, self.tile_size, self.tile_size)
		end
		--love.graphics.setColor(0,0,0,128)
		--love.graphics.rectangle("line", 0, 0, self.tile_size, self.tile_size)
		love.graphics.pop()
	end

	love.graphics.pop()

	if turn.player ~= "neutral" then
		love.graphics.setColor(unpack(PlayerColors[turn.player]))
		love.graphics.printf(string.format("YOUR TURN: %d", turn.pieces), 0, -font.standard:getHeight() - 1, self.width * self.tile_size, turn.player)
	end
	
	love.graphics.push()
	love.graphics.origin()
	for i,P in ipairs({"left","right"}) do
		love.graphics.setColor(unpack(PlayerColors[P]))
		local stats = self.stats[P]
		local w = self.x - 8
		local tx, al
		if P == "left" then
			tx = 4
			al = "right"
		else
			tx = self.x + self.width * self.tile_size + 4
			al = "left"
		end
		love.graphics.printf(string.format([[PLAYER: %s
		
		OCCUPATION: %d
		TURRETS: %d
		BUNKERS: %d
		TOWERS: %d
		FARMS: %d]], P, stats.occupation, stats.turrets, stats.bunkers, stats.towers, stats.farms), tx, self.y + font.standard:getHeight(), w, al)
	end
	love.graphics.pop()

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
		love.graphics.printf(string.format("Structures: %s", TileTypes[F.type][1]), 0, 4 + 6*h, self.width * self.tile_size, "center")
	end
	
	love.graphics.origin()
	
	if endgame then
		love.graphics.setColor(0,0,0,64)
		love.graphics.rectangle("fill",0,0,love.window.getWidth(), love.window.getHeight())

		love.graphics.setColor(255,255,255,255)
		love.graphics.printf(string.format("%s Wins!", self:victory()), 0, (love.window.getHeight() - font.standard:getHeight())/2, love.window.getWidth(), "center")
	end
end

-- Tile Operations

function Tile:addOccupation(value, player)
	local v = value
	local p = player or turn.player

	local other
	if p == "left" then
		other = "right"
	else
		other = "left"
	end

	if self.owner == "neutral" then
		self.occupation = v
		self.owner = p
	elseif self.owner == p then
		self.occupation = self.occupation + v
	else
		local t,b = self.grid.stats[p].turrets, self.grid.stats[other].bunkers
		--print("Attacking Turrets:",t)
		--print("Defending Bunkers:",b)
		local attack = math.max(0, t - b)
		self.occupation = math.max(0, self.occupation - attack - v)
		if self.occupation == 0 then
			self.owner = "neutral"
		elseif self.occupation < 0 then
			self.occupation = -self.occupation
			self.owner = p
		end
	end
end

function Tile:getAdjacents(d)
	local distance = d or 1
	if distance <= 1 then
		return self.grid:getAdjacentTiles(self.x, self.y)
	else
		local adjacents = self:getAdjacents(distance - 1)
		new_adjacents = {}
		for i,T in pairs(adjacents) do
			_N = self.grid:getAdjacentTiles(T.x, T.y)
			for j, _T in pairs(_N) do
				if math.abs(_T.x - self.x) + math.abs(_T.y - self.y) == distance then
					new_adjacents[string.format("%d;%d",_T.x,_T.y)] = _T
				end
			end
		end
		for i,T in pairs(new_adjacents) do
			adjacents[i] = T
		end
		return adjacents
	end
end

function Tile:draw()
	local s = self.grid.tile_size
	local k = s/16
	love.graphics.setColor(unpack(PlayerColors[self.owner]))
	love.graphics.rectangle("fill", 0, 0, s, s)
	local Q = nil
	if self.type == "base" then
		Q = love.graphics.newQuad(16,0,16,32,128,128)
		--[[love.graphics.setColor({0,0,0,128})
		love.graphics.circle("line", s/2, s/2, s/4)]]
	elseif self.type == "turret" then
		Q = love.graphics.newQuad(48,0,16,32,128,128)
		--[[love.graphics.setColor({0,0,0,128})
		love.graphics.polygon("line", s/6, s*3/4, s/2, s/5, s*5/6, s*3/4)]]
	elseif self.type == "bunker" then
		Q = love.graphics.newQuad(32,0,16,32,128,128)
		--[[love.graphics.setColor({0,0,0,128})
		love.graphics.rectangle("line", s/4, s/4, s/2, s/2)]]
	elseif self.type == "tower" then
		Q = love.graphics.newQuad(64,0,16,32,128,128)
		--[[love.graphics.setColor({0,0,0,128})
		love.graphics.polygon("line", s/2, s/4, s*3/4, s/2, s/2, s*3/4, s/4, s/2)]]
	elseif self.type == "farm" then
		Q = love.graphics.newQuad(80,0,16,32,128,128)
		--[[love.graphics.setColor({0,0,0,128})
		love.graphics.line(s/2, s/8, s/2, s*7/8)
		love.graphics.line(s/4, s/6, s/4, s*7/8)
		love.graphics.line(s*3/4, s/6, s*3/4, s*7/8)]]
	end
	if Q then
		love.graphics.draw(spritesheet, Q, 0, -s/2, 0, k, k)
	end
end