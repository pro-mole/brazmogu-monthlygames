-- Our intrepid minesweeper mole
Mole = {size = 16}
Mole.__index = Mole

function Mole.new(x, y, grid)
	local N = {x = x or 0, y = y or 0}
	N.grid = grid

	setmetatable(N, Mole)
	N:revealTile()

	return N
end

function Mole:revealTile()
	local T = self.grid:getTile(self.x, self.y)
	if not T.known then
		T.known = true
	end	
end

function Mole:keypressed(k, isrepeat)
	-- Local variables to check the tile before moving
	local _x, _y = self.x, self.y

	if k == 'up' then
		_y = self.y - 1
	elseif k == 'down' then
		_y = self.y + 1
	elseif k == 'left' then
		_x = self.x - 1
	elseif k == 'right' then
		_x = self.x + 1
	end

	-- If walking over borders, move back
	if _y < 1 or _y > self.grid.height then
		_y = self.y
	end
	if _x < 1 or _x > self.grid.width then 
		_x = self.x
	end

	local T = self.grid:getTile(_x, _y)
	if T.mark then -- if tile is marked, don't move there, dumbass
		_x, _y = self.x, self.y
	else  -- if tile is not marked, check if we blow up
		self.x, self.y = _x, _y
		if T.content == "mine" then
			gameover = true
			self.grid.revealed = true
		end
	end
	self:revealTile()

	if k == 'w' then
		self.grid:markTile(self.x, self.y-1)
	elseif k == 's' then
		self.grid:markTile(self.x, self.y+1)
	elseif k == 'a' then
		self.grid:markTile(self.x-1, self.y)
	elseif k == 'd' then
		self.grid:markTile(self.x+1, self.y)
	end	
end

function Mole:draw()
	local y = self.y-1
	local x = self.x-1

	love.graphics.draw(spritesheet.grid, sprite.mole, x*self.size, y*self.size)
	--[[
	love.graphics.setColor(72,60,50,255)
	love.graphics.polygon("fill",
		x*self.size + self.size/2, y*self.size + 2,
		(x+1)*self.size - 2, (y+1)*self.size -2,
		x*self.size + 2, (y+1)*self.size -2)
	]]
end