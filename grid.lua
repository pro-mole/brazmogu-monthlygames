-- Game Grid

font = {standard = love.graphics.newFont("assets/font/imagine_font.otf", 16)}

spritesheet = love.graphics.newImage("assets/sprite/board.png")
spritesheet:setFilter("linear","nearest")
sprite_width = 16
sprite_height = 32

Grid = {
	width = 0,
	height = 0,
	tiles = nil,

	x = 0,
	y = 0,
	tile_width = 8,
	tile_height = 8,
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
	type = "normal",
	effects = nil
}
Tile.__index = Tile

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
	T.tile_width = tsize or 16
	T.view_angle = angle or 1
	T.tile_height = T.tile_width * T.view_angle

	T.x = (love.window.getWidth() - T.width*T.tile_width) / 2
	T.y = (love.window.getHeight() - T.height*T.tile_height*T.view_angle) / 2

	T.tiles = {}
	for y = 1,T.height do
		T.tiles[y] = {}
		row = T.tiles[y]
		for x = 1,T.width do
			row[x] = setmetatable({x = x, y = y, grid = T, owner = "neutral", occupation = 0, type = "normal", effects = {}}, Tile)
		end
	end

	-- Initialize game stats
	T.stats = {}
	for i,P in ipairs(Players) do
		T.stats[P.id] = {
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

function Grid.loadFile(name)
	-- Create a game grid based on a file with the following characters as the key:
	local key = {
		B = {"neutral", "base"},
		b = {"neutral", "bunker"},
		t = {"neutral", "turret"},
		T = {"neutral", "tower"},
		f = {"neutral", "farm"},
		l = {"left", "base"},
		r = {"right", "base"},
		u = {"up", "base"},
		d = {"down", "base"}
	}
	if not love.filesystem.exists(name) then
		return nil
	else
		local landmarks = {}
		local x,y = 1,1
		local w,h = 0,0
		for line in love.filesystem.lines(name) do
			local L = line:gsub("^%s*(.-)%s*$", "%1") -- Trim
			--print (L)
			if #L > w then w = #L end
			for i = 1,#L do
				local t = L:sub(i,i)
				if t ~= "#" then
					--print(unpack({i,y,unpack(key[t])}))
					table.insert(landmarks, {i,y,unpack(key[t])})
				end
			end
			h = y
			y = y + 1
		end
		
		local G = Grid.new(w,h,32,0.5)
		for i,spec in ipairs(landmarks) do
			local t = G:getTile(spec[1], spec[2])
			t.owner = spec[3]
			if t.owner ~= "neutral" then t.occupation = 1 end
			t.type = spec[4]
		end
		return G
	end
end

-- Default victory condition function
-- Returns the name of the player who won, or nil
function Grid:victory()
	local winner = nil
	for i,P in ipairs(Players) do
		if self.stats[P.id].bases > 0 then
			if winner ~= nil then
				return nil
			else
				winner = P.id
			end
		end
	end
	
	return winner
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

function Grid:proliferate(player)
	local player = player or turn.player
	for x,y,T in self:iterator() do
		if T.owner == player and T.occupation > 0 then
			T.occupation = T.occupation + 1
			for i = 1,2*T.occupation do
				local x,y = math.random(), math.random()
				local size = math.random(4)
				local color = {unpack(Players[T.owner].color)}
				for i = 1,3 do
					color[i] = math.min(color[i] + 128, 255)
				end
				table.insert(T.effects, {
					x = x * self.tile_width,
					y = y * self.tile_height,
					size = size,
					speed = self.tile_height / math.sqrt(size),
					dir = math.rad(270),
					color = color,
					alpha = 192,
					fade = 128,
					lifetime = size/5,
				})
			end
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
		[string.format("%d;%d",x-1,y)] = self:getTile(x-1, y),
		[string.format("%d;%d",x+1,y)] = self:getTile(x+1, y),
		[string.format("%d;%d",x,y-1)] = self:getTile(x, y-1),
		[string.format("%d;%d",x,y+1)] = self:getTile(x, y+1)
	}
end

function Grid:startTurn(player)
	player = player or Players:next()
	self:updateStats()
	self:proliferate()
	turn.player = player
	turn.pieces = self.stats[player].farms + self.stats[player].bases
	if turn.pieces <= 0 then
		self:startTurn()
	end
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
	if m == "l" and not Players[turn.player].AI then
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
			
			love.audio.setVolume(0.25)
			if valid then
				love.audio.newSource(Sounds.confirm):play()
				turn.pieces = turn.pieces - 1
				self.focus:addOccupation(1)
				self:updateStats()
				table.insert(self.focus.effects, {
					x = 0.5 * self.tile_width,
					y = 0.5 * self.tile_height,
					size = self.tile_width/4,
					speed = self.tile_height/2,
					dir = math.rad(270),
					color = Players[turn.player].color,
					alpha = 128,
					fade = 128,
					grow = self.tile_width,
					lifetime = 0.25,
				})
				
				if turn.pieces == 0 then
					self:startTurn()
				end
				input_delay = 0.25
			else
				love.audio.newSource(Sounds.denied):play()
			end
		end
	end
end

function Grid:mouseover()
	local mx, my = love.mouse.getPosition()
	mx = mx - self.x
	my = my - self.y

	if mx > 0 and mx < self.width*self.tile_width and my > 0 and my < self.height*self.tile_height then
		local fx, fy = math.ceil(mx / self.tile_width), math.ceil(my / self.tile_height)
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
		love.graphics.translate((x-1) * self.tile_width, (y-1) * self.tile_height)
		local lighting = 0.5
		if T.owner ~= turn.player and turn.player ~= "neutral" then
			adj = T:getAdjacents(self.stats[turn.player].towers + 1)
			for i,A in pairs(adj) do
				-- A = adj[i]
				if A then
					if A.owner == turn.player then
						--[[
						love.graphics.setColor(255,255,255,32)
						love.graphics.rectangle("fill", 0, 0, self.tile_width, self.tile_height)]]
						lighting = lighting + 0.25
						break
					end
				end
			end
		end
		if T.owner == turn.player then
			lighting = lighting + 0.5
		end
		if self.focus == T then
			lighting = lighting + 0.25
		end
		T:draw(lighting)
		--[[if self.focus == T then
			love.graphics.setColor(255,255,255,32)
			love.graphics.rectangle("fill", 0, 0, self.tile_width, self.tile_height)
		end]]
		--love.graphics.setColor(0,0,0,128)
		--love.graphics.rectangle("line", 0, 0, self.tile_size, self.tile_size)
		love.graphics.pop()
	end

	love.graphics.pop()

	--[[
	if turn.player ~= "neutral" then
		love.graphics.setColor(unpack(Players[turn.player].color))
		love.graphics.printf(string.format("YOUR TURN: %d", turn.pieces), 0, -font.standard:getHeight()*2, self.width * self.tile_width, turn.player)
	end
	]]
	
	love.graphics.push()
	love.graphics.origin()
	
	if #Players.active == 2 then
		love.graphics.translate(love.window.getWidth()/4, self.y - font.standard:getHeight()*12)	
	else
		love.graphics.translate(0, self.y - font.standard:getHeight()*12)	
	end
	for i,P in ipairs(Players.active) do
		local stats = self.stats[P]
		local w = love.window.getWidth()/4
		
		love.graphics.setColor(255,255,255,255)
		drawDecoratedBox(2, 0, w - 4, font.standard:getHeight()*9, 4)
		
		love.graphics.setColor(unpack(Players[P].color))
		if turn.player == P then
			love.graphics.polygon("fill", w/2 - 8, -16 - font.standard:getHeight(), w/2 - 8, -12, w/2, -4, w/2 + 8, -12, w/2 + 8, -16 - font.standard:getHeight())
			love.graphics.setColor(255,255,255,255)
			love.graphics.printf(turn.pieces, w/2 - 8, -14 - font.standard:getHeight(), 16, "center")
			love.graphics.setColor(unpack(Players[P].color))
		end
		love.graphics.printf(string.format([[%s
		
		OCCUPATION: %d
		TURRETS: %d
		BUNKERS: %d
		TOWERS: %d
		FARMS: %d]], Players[P].name, stats.occupation, stats.turrets, stats.bunkers, stats.towers, stats.farms), 8, font.standard:getHeight(), w - 16, "center")
		
		love.graphics.translate(love.window.getWidth()/4,0)
	end
	love.graphics.pop()

	love.graphics.translate(0, self.height * self.tile_height + 4)
	love.graphics.setColor(255,255,255,255)
	drawDecoratedBox(0, 0, self.width * self.tile_width, font.standard:getHeight()*10, 4)

	if self.focus then
		local F = self.focus
		local h = font.standard:getHeight()
		love.graphics.printf("Tile Info", 0, 4+h, self.width * self.tile_width, "center")

		love.graphics.printf(string.format("Occupation: %02d", F.occupation), 0, 4 + 3*h, self.width * self.tile_width, "center")
		love.graphics.printf(string.format("Owner: %s", Players[F.owner].name), 0, 4 + 5*h, self.width * self.tile_width, "center")
		love.graphics.printf(string.format("Structures: %s", TileTypes[F.type][1]), 0, 4 + 7*h, self.width * self.tile_width, "center")
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

	if self.owner == "neutral" then
		self.occupation = v
		self.owner = p
	elseif self.owner == p then
		self.occupation = self.occupation + v
	else
		local t,b = self.grid.stats[p].turrets, self.grid.stats[self.owner].bunkers
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

function Tile:update(dt)
	for i = #self.effects,1,-1 do
		local fx = self.effects[i]
		fx.lifetime = fx.lifetime - dt
		if fx.lifetime > 0 then
			if fx.speed and fx.dir then
				fx.x = fx.x + math.cos(fx.dir) * fx.speed * dt
				fx.y = fx.y + math.sin(fx.dir) * fx.speed * dt
			end
			if fx.fade then
				fx.alpha = fx.alpha - fx.fade * dt
			end
			if fx.grow then
				fx.size = fx.size + fx.grow * dt
			end
		else
			table.remove(self.effects,i)
		end
	end
end

function Tile:draw(highlight)
	local w = self.grid.tile_width
	local h = self.grid.tile_height
	local k = w/sprite_width
	local C_tile = {unpack(Players[self.owner].color)}
	local C_landmark = {unpack(Players[self.owner].color)}
	local l = highlight or 1
	for i = 1,3 do
		C_tile[i] = math.min(C_tile[i] + 0.1 * self.occupation * C_tile[i], 255)
		C_tile[i] = math.min(l * C_tile[i], 255)
	end
	
	love.graphics.setColor(unpack(C_tile))
	love.graphics.rectangle("fill", 0, 0, w, h)
	love.graphics.setColor(0,0,0,128)
	love.graphics.rectangle("line", 0, 0, w, h)
	
	love.graphics.setShader(shaders.colorize)
	love.graphics.setColor(unpack(C_landmark))
	local Q = nil
	local H,W = spritesheet:getHeight(), spritesheet:getWidth()
	local spritemap_col = {
		normal = 0,
		base = 1,
		bunker = 2,
		turret = 3,
		tower = 4,
		farm = 5
	}
	local spritemap_row = {
		neutral = 0,
		left = 1,
		right = 2,
		up = 3,
		down = 4
	}
	local Q = love.graphics.newQuad(sprite_width * spritemap_col[self.type], sprite_height * spritemap_row[self.owner],sprite_width,sprite_height,W,H)

	if Q then
		love.graphics.draw(spritesheet, Q, 0, -(sprite_height - h) - sprite_height/2, 0, k, k)
	end
	love.graphics.setShader(shaders.standard)
	
	for i,fx in ipairs(self.effects) do
		local color = {unpack(fx.color)}
		color[4] = fx.alpha
		love.graphics.setColor(unpack(color))
		love.graphics.rectangle("fill", fx.x - fx.size/2, fx.y - fx.size/2, fx.size, fx.size)
	end
end