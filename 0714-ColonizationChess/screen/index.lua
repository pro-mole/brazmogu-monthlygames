-- Screen Index

screen_menu = setmetatable({}, Screen)

function screen_menu:load()
end

function screen_menu:update(dt)
end

function screen_menu:keypressed(k, isrepeat)
end

function screen_menu:draw()
end

function screen_menu:quit()
end

screen_game = setmetatable({}, Screen)

function screen_game:load()
	game_grid = Grid.new(15,8,32,0.5)
	Players.active = {"left","right"}
	game_grid:startTurn()

	-- Set Special tiles
	local special = {
		{5,2,"turret"},
		{5,7,"bunker"},
		{11,2,"bunker"},
		{11,7,"turret"},
		{8,3,"tower"},
		{8,6,"tower"},
		{1,1,"farm"},
		{15,1,"farm"},
		{1,8,"farm"},
		{15,8,"farm"}
	}
	for i,S in ipairs(special) do
		--print(unpack(S))
		local t = game_grid:getTile(S[1], S[2])
		t.type = S[3]
	end
end

function screen_game:update(dt)
	game_grid:mouseover()
end

function screen_game:keypressed(k, isrepeat)
	game_grid:mousepressed(x, y, button)
end

function screen_game:mousepressed(x, y, button)
	game_grid:mousepressed(x,y,button)
end

function screen_game:draw()
	game_grid:draw()
end

function screen_game:quit()
end

