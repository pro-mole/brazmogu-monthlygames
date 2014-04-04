--- Game Screen

ScreenGame = setmetatable({}, Screen)

function ScreenGame:init()
	zone:init(32)
	self.delta = 0
end

function ScreenGame:update(dt)
	self.delta = self.delta + dt
	for i,pixel in ipairs(pixels) do
		pixel:update(dt)
	end
end

function ScreenGame:draw()
	-- love.graphics.printf("PLAY THE GAME", love.window.getWidth()/2 - 10, love.window.getHeight()/2, 20, "center")
	zone:draw()
	for i,pixel in ipairs(pixels) do
		pixel:draw()
	end
end

function ScreenGame:quit()
end

addScreen(ScreenGame, "game")