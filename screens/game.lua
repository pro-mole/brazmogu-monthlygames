--- Game Screen

ScreenGame = setmetatable({}, Screen)

function ScreenGame:init()
	zone:init(32)
	self.delta = 0
end

function ScreenGame:update(dt)
	self.delta = self.delta + dt

	if self.delta >= 1 then
		self.delta = self.delta - 1
		local side = love.math.random(0,3)
		local color = COLOR[love.math.random(1,#COLOR)]
		if side == 0 then     -- Left
			Pixel.new(0, love.math.random(love.window.getHeight()), color)
		elseif side == 1 then -- Top
			Pixel.new(love.math.random(love.window.getWidth()), 0, color)
		elseif side == 2 then -- Right
			Pixel.new(love.window.getWidth(), love.math.random(love.window.getHeight()), color)
		elseif side == 3 then -- Bottom
			Pixel.new(love.math.random(love.window.getWidth()), love.window.getHeight(), color)
		end
	end

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

	-- love.graphics.printf(#pixels, love.window.getWidth()/2 - 10, love.window.getHeight() - 16, 20, "center")
	-- love.graphics.printf(#COLOR, love.window.getWidth()/2 - 10, love.window.getHeight() - 32, 20, "center")
end

function ScreenGame:quit()
end

addScreen(ScreenGame, "game")