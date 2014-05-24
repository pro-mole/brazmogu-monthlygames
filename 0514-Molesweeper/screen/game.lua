-- Main game screen
GameScreen = setmetatable({}, Screen)

function GameScreen:load()
	self.grid = Grid.new(settings.minefield.width, settings.minefield.height, settings.minefield.mines)
	self.mole = Mole.new(settings.minefield.start.x, settings.minefield.start.y, self.grid)
	self.UI = GUI.new()

	self.UI:addButton(4, 596, 152, 40, "Exit", screens, screens.pop, "escape")
	if not challenge.begins then
		self.UI:addButton(484, 596, 152, 40, "Restart", self, self.retry, "r")
	end
	self.UI:addButton(164, 596, 312, 40, "Verify", self, self.checkSolution, "return")

	--self.UI:addButton(324, 596, 152, 40, "Exit", nil, love.event.quit, "escape")
	--self.UI:addButton(484, 596, 152, 40, "Exit", nil, love.event.quit, "escape")
	--self.UI:addLabel(164, 4, 152, "Mines: %s", self.grid, self.grid.getMines)
	--self.UI:addLabel(324, 4, 152, "Marks: %s", self.grid, self.grid.getMarks)
	
	print("Loaded Game Screen")
end

function GameScreen:keypressed(k, isrepeat)
	if not gameover then
		if k == "`" then
			self.grid.revealed = not self.grid.revealed
		end	
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
	self:drawHUD()

	if (gameover) then
		love.graphics.setColor(0,0,0,128)
		love.graphics.rectangle("fill", 0, 0, love.window.getWidth(), love.window.getHeight())
	end

	love.graphics.setColor(255,255,255,255)
	self.UI:draw()
end

function GameScreen:drawHUD()
	-- HUD
	-- Minefield stats
	love.graphics.push()
	love.graphics.translate(164, 4)

	love.graphics.setColor(0,192,0,255)
	love.graphics.rectangle("line", 0, 0, 312, 60)
	love.graphics.rectangle("line", 3, 3, 306, 54)
	love.graphics.printf("Mines Detected", 4, 11, 96, "center")
	love.graphics.printf(self.grid:getMines(), 4, 40, 96, "center")
	love.graphics.printf("Mines Marked", 104, 11, 96, "center")
	love.graphics.printf(self.grid:getMarks(), 104, 40, 96, "center")
	
	for x = -1,1 do
		for y = -1,1 do
			local t = self.grid:getTile(self.mole.x + x, self.mole.y + y)
			local square_x, square_y = 224 + (x+1)*16, 6 + (y+1)*16
			local tile_text = "?"
			love.graphics.setColor(0,128,0,255)
			love.graphics.rectangle("fill", square_x+1, square_y+1, 14, 14)
			if t ~= nil then
				if x == 0 and y == 0 then
					love.graphics.setColor(255,255,255,255)
				else
					love.graphics.setColor(0,192,0,255)
				end

				if t.known then
					love.graphics.printf(t.neighbors, square_x, square_y + 1 + (16 - font.menustandard:getHeight())/2, 16, "center")
				elseif t.mark then
					love.graphics.printf("*", square_x, square_y + 1 + (16 - font.menustandard:getHeight())/2, 16, "center")
				end
			else
				love.graphics.setColor(0,64,0,255)
				love.graphics.rectangle("fill", square_x, square_y, 16, 16)
			end
		end
	end


	love.graphics.pop()

	-- Superfluous Technobabble/Quick Ref
	love.graphics.push()
	love.graphics.translate(4, 4)

	love.graphics.setColor(0,64,192,255)
	love.graphics.rectangle("line", 0, 0, 152, 60)
	love.graphics.rectangle("line", 3, 3, 146, 54)

	love.graphics.printf("Systems Online", 7, 7, 138, "center")

	love.graphics.printf("Move", 7, 25, 69, "center")

	love.graphics.push()
	love.graphics.translate(25, 42)
	love.graphics.polygon("fill",8,0, 0,4, 8,8)
	
	love.graphics.push()
	love.graphics.translate(10, 0)
	love.graphics.polygon("fill",0,0, 4,8, 8,0)
	love.graphics.pop()
	
	love.graphics.push()
	love.graphics.translate(17, 0)
	love.graphics.polygon("fill",0,8, 4,0, 8,8)	
	love.graphics.pop()
	
	love.graphics.push()
	love.graphics.translate(27, 0)
	love.graphics.polygon("fill",0,0, 8,4, 0,8)		
	love.graphics.pop()
	
	love.graphics.pop()

	love.graphics.printf("Mark", 76, 25, 69, "center")
	love.graphics.printf("ASWD", 76, 42, 69, "center")

	love.graphics.pop()
	
	-- Soil Survey
	love.graphics.push()
	love.graphics.translate(484, 4)

	love.graphics.setColor(192,192,0,255)
	love.graphics.rectangle("line", 0, 0, 152, 60)
	love.graphics.rectangle("line", 3, 3, 146, 54)
	
	love.graphics.printf("Soil Analysis", 7, 7, 138, "center")
	
	local terrain = self.grid:getTile(self.mole.x, self.mole.y)
	local total = terrain.dirt + terrain.water + terrain.humus
	love.graphics.setColor(128,96,0,255)
	love.graphics.printf(string.format("%d%%",terrain["dirt"]/total * 100), 7, 24, 46, "center")
	love.graphics.setColor(0,96,128,255)
	love.graphics.printf(string.format("%d%%",terrain["water"]/total * 100), 53, 24, 46, "center")
	love.graphics.setColor(64,64,64,255)
	love.graphics.printf(string.format("%d%%",terrain["humus"]/total * 100), 99, 24, 46, "center")

	love.graphics.pop()

	love.graphics.setColor(255,255,255,255)
end

function GameScreen:retry()
	self:restart()
end

function GameScreen:quit()
	gameover = false
end

function GameScreen:checkSolution()
	local win = self.grid:checkSolution(self.UI)
	
	if gameover then
		if win then
			settings.level = settings.level + 1
			self.UI:addButton(484, 596, 152, 40, "Continue", screens, screens.pop, " ")
		else
			settings.level = 1
			self.UI:addButton(484, 596, 152, 40, "Restart", screens, screens.pop, " ")
		end
	end
end

return GameScreen