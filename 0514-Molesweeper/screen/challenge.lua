-- Challenge Screen
-- This screen serves basically as a mediator to the challenge mode
ChallengeScreen = setmetatable({}, Screen)

function ChallengeScreen:load()
	self.UI = GUI.new()
	self.UI:addButton(164, 596, 312, 40, "Begin", self, self.startGame, "return")
	self.UI:addButton(4, 596, 152, 40, "Go Back", screens, screens.pop, "escape")
	-- self.UI:addLabel(164, 4, 312, "Level: %s", self, self.getLevel)

	-- Load settings for the current level
	if not challenge.begins then
		challenge.level = 1
	end
	current_challenge = challenge.level_settings[challenge.level]
	saveSetting("minefield.width", current_challenge.width)
	saveSetting("minefield.height", current_challenge.height)
	saveSetting("minefield.start.x", current_challenge.start[1])
	saveSetting("minefield.start.y", current_challenge.start[2])
	saveSetting("minefield.mines", current_challenge.mines)
	saveSetting("minefield.coppermoss", current_challenge.coppermoss)
	saveSetting("minefield.ironcap", current_challenge.ironcap)
	saveSetting("minefield.goldendrop", current_challenge.goldendrop)
	print(settings.minefield.maxNeighbors, current_challenge.maxNeighbors)
	saveSetting("minefield.maxNeighbors", current_challenge.maxNeighbors)
	print(settings.minefield.maxNeighbors, current_challenge.maxNeighbors)
	saveSetting("minefield.forceNeighbors", current_challenge.forceNeighbors)
end

function ChallengeScreen:keypressed(k, isrepeat)
	if k == "escape" then
		challenge.level = 1
		saveSetting("minefield.maxNeighbors", 9)
		saveSetting("minefield.forceNeighbors", 1)
	end
	self.UI:keypressed(k, isrepeat)
end

function ChallengeScreen:startGame()
	challenge.begins = true
	screens:push(gamescreen)
end

function ChallengeScreen:getLevel()
	return challenge.level
end

function ChallengeScreen:draw()
	love.graphics.draw(backdrop.printer, 0, 0)
	self.UI:draw()
	
	love.graphics.setColor(24,24,24,255)
	love.graphics.printf(string.format("MISSION #%02d BRIEFING", challenge.level), 4, 8, 632, "center")
	love.graphics.printf(challenge.level_settings[challenge.level].briefing, 36, 24, 568, "left")
end

function ChallengeScreen:quit()
	
end

return ChallengeScreen