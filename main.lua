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

function love.load()
	love.graphics.setFont(font.standard)

	game_grid = Grid.new()
	game_grid:startTurn("left")
end

function love.update(dt)
	game_grid:mouseover()
end

function love.keypressed(key, isrepeat)
	if key == "escape" then
		love.event.quit()
	end
end

function love.mousepressed(x, y, button)
	game_grid:mousepressed(x, y, button)
end

function love.draw()
	game_grid:draw()
end