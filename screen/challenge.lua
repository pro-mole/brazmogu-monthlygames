-- Challenge Screen
-- This screen serves basically as a mediator to the challenge mode
ChallengeScreen = setmetatable({}, Screen)

font["brief_title"] = love.graphics.newFont("assets/font/amiga4ever.ttf", 18)
font["brief_text"] = love.graphics.newFont("assets/font/amiga4ever.ttf", 14)

function ChallengeScreen:load()
	self.UI = GUI.new()
	self.UI:addButton(4, 596, 152, 40, "Go Back", screens, screens.pop, "escape")
	-- self.UI:addLabel(164, 4, 312, "Level: %s", self, self.getLevel)

	-- Load settings for the current level
	if not challenge.begins then
		challenge.level = 1
	end

	if challenge.level < #challenge.level_settings then
		self.UI:addButton(164, 596, 312, 40, "Begin", self, self.startGame, "return")
		current_challenge = challenge.level_settings[challenge.level]
		saveSetting("minefield.width", current_challenge.width)
		saveSetting("minefield.height", current_challenge.height)
		saveSetting("minefield.start.x", current_challenge.start[1])
		saveSetting("minefield.start.y", current_challenge.start[2])
		saveSetting("minefield.mines", current_challenge.mines)
		saveSetting("minefield.coppermoss", current_challenge.coppermoss)
		saveSetting("minefield.ironcap", current_challenge.ironcap)
		saveSetting("minefield.goldendrop", current_challenge.goldendrop)
		saveSetting("minefield.maxNeighbors", current_challenge.maxNeighbors)
		saveSetting("minefield.forceNeighbors", current_challenge.forceNeighbors)
	end
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
	
	if challenge.level_settings[challenge.level].illustration then
		for i, illustration in ipairs(challenge.level_settings[challenge.level].illustration) do
			local image, x, y = unpack(illustration)
			love.graphics.setColor(255,255,255,128)
			love.graphics.draw(image, x, y)
			love.graphics.setColor(24,24,24,128)
			love.graphics.rectangle("line", x, y, image:getWidth(), image:getHeight())
		end
	end

	self.UI:draw()

	love.graphics.setColor(24,24,24,255)
	love.graphics.setFont(font.brief_title)
	if challenge.level < #challenge.level_settings then
		love.graphics.printf(string.format("MISSION #%02d BRIEFING", challenge.level), 0, 8, 640, "center")
	else
		love.graphics.printf(string.format("CONGRATULATIONS!", challenge.level), 0, 8, 640, "center")
	end
	love.graphics.setFont(font.brief_text)
	love.graphics.printf(challenge.level_settings[challenge.level].briefing, 36, 24 + font.brief_text:getHeight(), 568, "left")
	if challenge.level < #challenge.level_settings then
		love.graphics.printf(string.format("GOOD LUCK.", challenge.level), 36, 560, 568, "right")
	else
		love.graphics.printf(string.format("GOOD JOB!", challenge.level), 36, 560, 568, "right")
	end
end

function ChallengeScreen:quit()
	
end

return ChallengeScreen