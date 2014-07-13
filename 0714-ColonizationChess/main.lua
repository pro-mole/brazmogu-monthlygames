require("grid")

game_grid = {}

Score = {
	left = {},
	right = {}
}

turn = {
	player = "neutral",
	pieces = 0
}

endgame = false

require("screen/main")
require("screen/index")

function love.load()
	love.graphics.setFont(font.standard)

	screens:push(screen_game)
end

function love.update(dt)
	screens:update(dt)
end

function love.keypressed(key, isrepeat)
	if key == "escape" then
		love.event.quit()
	end

	screens:keypressed(key, isrepeat)
end

function love.mousepressed(x, y, button)
	screens:mousepressed(x, y, button)
end

function love.draw()
	screens:draw()
end