require("molesweeper/minegenerator")
-- The game's grid
Grid = {}
Grid.__index = Grid

function Grid.new(w, h, mines)
	local _w = w or 16
	local _h = h or 16
	local _m = mines or 8
	local N = {width = _w, height = _h, tile_size = 16, marks = 0, mines = _m}
	N.offset = {x = (love.window.getWidth() - _w * N.tile_size)/2, y = (love.window.getHeight() - _h * N.tile_size)/2}

	N.tiles = generateMinefield(_w, _h, _m)
	N.revealed = false

	return setmetatable(N, Grid)
end

function Grid:draw()
	love.graphics.setColor(32,32,32,255)
	love.graphics.rectangle("fill", -4, -4, self.width*self.tile_size + 8, self.height*self.tile_size + 8)

	for j = 1,self.height do
		for i = 1,self.width do
			self:drawTile(i,j)
		end
	end
end

function Grid:getTile(x, y)
	if x < 1 or x > self.width or y < 1 or y > self.height then
		return nil
	end

	return self.tiles[y][x]
end

function Grid:markTile(x, y)
	local T = self:getTile(x, y)
	if T ~= nil and not T.known then
		T.mark = not T.mark
		if T.mark then
			self.marks = self.marks + 1
		else
			self.marks = self.marks - 1
		end
	end
end

function Grid:getMines()
	return self.mines
end

function Grid:getMarks()
	return self.marks
end

function Grid:checkSolution()
	if self.mines ~= self.marks then
		return false
	end

	-- Assuming we have the same number of marks and mines, then either all marked tiles are mines or the player failed
	for i,row in ipairs(N.tiles) do
		for j,cell in ipairs(row) do
			if cell.mark and cell.content ~= "mine" then
				return false
			end
		end
	end

	-- Here we then checked that all makerd tiles are mines, and thus all mines were marked. Yay!
	return true
end

function Grid:drawTile(x, y)
	local T = self:getTile(x, y)

	local draw_x = (x-1) * self.tile_size
	local draw_y = (y-1) * self.tile_size
	
	love.graphics.setColor(64,64,64,255)
	love.graphics.rectangle("line", draw_x, draw_y, self.tile_size, self.tile_size)

	if T.known or self.revealed then
		love.graphics.setColor(192,192,192,255)
		love.graphics.rectangle("fill", draw_x+1, draw_y+1, self.tile_size-2, self.tile_size-2)
		if T.content == "mine" then
			love.graphics.setColor(128, 0, 0, 255)
			love.graphics.circle("fill", draw_x + self.tile_size/2, draw_y + self.tile_size/2, self.tile_size/4, 8)
		else
			if T.neighbors > 0 then
				love.graphics.setColor(128, 0, 0, 255)
				love.graphics.printf(T.neighbors, draw_x, draw_y + 2, self.tile_size, "center")
			end
		end
	else
		love.graphics.setColor(128,128,128,255)
		love.graphics.rectangle("fill", draw_x+1, draw_y+1, self.tile_size-2, self.tile_size-2)
		if T.mark then
			love.graphics.setColor(128, 0, 0, 255)
			love.graphics.polygon("fill",
				draw_x + 2, draw_y + 2,
				draw_x + 2, draw_y + self.tile_size - 2,
				draw_x + self.tile_size - 2, draw_y + self.tile_size/2)
		end
	end
end