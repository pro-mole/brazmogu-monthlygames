-- Main game screen
GameScreen = setmetatable({}, Screen)

function GameScreen:load()
	self.grid = Grid.new(settings.minefield.width, settings.minefield.height, settings.minefield.mines)
	self.mole = Mole.new(settings.minefield.start.x, settings.minefield.start.y, self.grid)
	self.UI = GUI.new()

	self.UI:addButton(4, 596, 152, 40, "Exit", nil, love.event.quit, "escape")
	self.UI:addButton(164, 596, 152, 40, "Restart", self, self.retry, "r")
	--self.UI:addButton(324, 596, 152, 40, "Exit", nil, love.event.quit, "escape")
	--self.UI:addButton(484, 596, 152, 40, "Exit", nil, love.event.quit, "escape")
	self.UI:addLabel(164, 4, 152, "Mines: %s", self.grid, self.grid.getMines)
	self.UI:addLabel(324, 4, 152, "Marks: %s", self.grid, self.grid.getMarks)
	self.UI:addButton(164, 36, 312, 40, "Verify", self.grid, self.grid.checkSolution, "enter")
	print("Loaded Game Screen")
end

function GameScreen:keypressed(k, isrepeat)
	if not gameover then
		self.mole:keypressed(k, isrepeat)
	end
	self.UI:keypressed(k, isrepeat)
end

function GameScreen:update(dt)
	self.UI:update(dt)
end

function GameScreen:draw()
	love.graphics.push()

	love.graphics.translate(self.grid.offset.x, self.grid.offset.y)
	self.grid:draw()
	self.mole:draw()

	love.graphics.pop()

	if (gameover) then
		love.graphics.setColor(0,0,0,128)
		love.graphics.rectangle("fill", 0, 0, love.window.getWidth(), love.window.getHeight())
	end

	love.graphics.setColor(255,255,255,255)
	self.UI:draw()
end

function GameScreen:retry()
	gameover = false
	self:restart()
end

return GameScreen