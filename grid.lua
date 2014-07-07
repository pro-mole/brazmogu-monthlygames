-- Game Grid

font = {standard = love.graphics.newFont("assets/font/imagine_font.otf")}

Grid = {
	width = 0,
	height = 0,
	tiles = nil,

	x = 0,
	y = 0,
	tile_size = 8,

	focus = nil -- Tile in focus
}
Grid.__index = Grid

Tile = {
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
	defense = true
}

function Grid:new(width, height, tsize)
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
			row[x] = setmetatable({owner = "neutral", occupation = 0, type = "normal"}, Tile)
		end
	end

	-- Set player bases
	for by = 0,1 do
		for bx = 0,1 do
			local lT, rT = T.tiles[T.height/2 + by][1 + bx], T.tiles[T.height/2 + by][T.width - bx]
			lT:addOccupation(1,"left")
			rT:addOccupation(1,"right")
		end
	end

	-- Set Special tiles

	-- Start game
	current_player = "left"

	return setmetatable(T, Grid)
end

function Grid:mouseover()
	local mx, my = love.mouse.getPosition()
	mx = mx - self.x
	my = my - self.y

	if mx > 0 and mx < self.width*self.tile_size and my > 0 and my < self.height*self.tile_size then
		local fx, fy = math.ceil(mx / self.tile_size), math.ceil(my / self.tile_size)
		self.focus = self.tiles[fy][fx]
	else
		self.focus = nil
	end
end

function Grid:draw()
	love.graphics.origin()
	love.graphics.translate(self.x, self.y)
	love.graphics.push()

	for y = 1,self.height do
		for x = 1,self.width do
			local T = self.tiles[y][x]
			love.graphics.push()
			love.graphics.translate((x-1) * self.tile_size, (y-1) * self.tile_size)
			love.graphics.setColor(unpack(PlayerColors[T.owner]))
			love.graphics.rectangle("fill", 0, 0, self.tile_size, self.tile_size)
			if self.focus == T then
				love.graphics.setColor(255,255,255,128)
				love.graphics.rectangle("fill", 0, 0, self.tile_size, self.tile_size)
			end
			love.graphics.setColor(0,0,0,128)
			love.graphics.rectangle("line", 0, 0, self.tile_size, self.tile_size)
			love.graphics.pop()
		end
	end

	love.graphics.pop()

	love.graphics.setColor(unpack(PlayerColors[current_player]))
	love.graphics.printf("YOUR TURN", 0, -font.standard:getHeight() - 1, self.width * self.tile_size, current_player)

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
	local p = player or current_player

	if self.player ~= p then
		v = v - self.occupation
	end

	if v > 0 then
		self.occupation = v
		self.owner = p
	end
end