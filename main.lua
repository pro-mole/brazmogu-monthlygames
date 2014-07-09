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

	-- Set Special tiles
	local special = {
		{5,2,"turret"},
		{5,7,"bunker"},
		{11,2,"bunker"},
		{11,7,"turret"},
		{8,3,"tower"},
		{8,6,"tower"},
	}
	for i,S in ipairs(special) do
		local t = game_grid:getTile(S[1], S[2])
		t.type = S[3]
	end
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