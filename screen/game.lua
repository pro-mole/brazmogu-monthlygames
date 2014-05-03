-- Main game screen
GameScreen = setmetatable({}, Screen)

function GameScreen:load()
	self.grid = Grid.new(15, 15)
	self.mole = Mole.new(8, 15, self.grid)
	print("Loaded Game Screen")
end

function GameScreen:keypressed(k, isrepeat)
	self.mole:keypressed(k, isrepeat)
end

function GameScreen:draw()
	love.graphics.push()

	love.graphics.translate(self.grid.offset.x, self.grid.offset.y)
	self.grid:draw()
	self.mole:draw()
	
	love.graphics.pop()
end

return GameScreen