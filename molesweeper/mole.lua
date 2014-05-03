-- Our intrepid minesweeper mole
Mole = {size = 16}
Mole.__index = Mole

function Mole.new(x, y, grid)
	local N = {x = x or 0, y = y or 0}
	N.grid = grid

	return setmetatable(N, Mole)
end

function Mole:keypressed(k, isrepeat)
	if k == 'up' then
		self.y = self.y - 1
	elseif k == 'down' then
		self.y = self.y + 1
	elseif k == 'left' then
		self.x = self.x - 1
	elseif k == 'right' then
		self.x = self.x + 1
	end

	if self.y < 1 then self.y = 1 end
	if self.y > self.grid.height then self.y = self.grid.height end
	if self.x < 1 then self.x = 1 end
	if self.x > self.grid.width then self.x = self.grid.width end
end

function Mole:draw()
	local y = self.y-1
	local x = self.x-1

	love.graphics.setColor(72,60,50,255)
	love.graphics.polygon("fill",
		x*self.size + self.size/2, y*self.size + 2,
		(x+1)*self.size - 2, (y+1)*self.size -2,
		x*self.size + 2, (y+1)*self.size -2)
end