-- Challenge Screen
-- This screen serves basically as a mediator to the challenge mode
ChallengeScreen = setmetatable({}, Screen)

function ChallengeScreen:load()
	self.UI = GUI.new()
	self.UI:addButton(164, 596, 312, 40, "Begin", self, self.startGame, "return")
	
	-- Load settings for the current level
	
end

function ChallengeScreen:startGame()
	challenge.begins = true
	screens:push(gamescreen)
end

return ChallengeScreen