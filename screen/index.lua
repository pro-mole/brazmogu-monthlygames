-- Screen Index

screen_quit = setmetatable({}, Screen)

function screen_quit:draw()
	love.graphics.printf("QUIT?", 0, love.window.getHeight()/2 - love.graphics.getFont():getHeight(), love.window.getWidth(), "center")
	love.graphics.printf("ESC=YES	SPACE=NO", 0, love.window.getHeight()/2, love.window.getWidth(), "center")
end

function screen_quit:keypressed(k, isrepeat)
	if k == "escape" then
		love.event.quit()
	elseif k == " " then
		screens:pop()
	end
end

screen_menu = setmetatable({}, Screen)

function screen_menu:load()
	-- Load properties from file
end

function screen_menu:update(dt)
end

function screen_menu:keypressed(k, isrepeat)
end

function screen_menu:draw()
	-- Menu screen
	local H = love.graphics.getFont():getHeight()
	love.graphics.printf("MAP SELECT", 0, love.window.getHeight()/4 - H, love.window.getWidth(), "center")
	-- Show map choice and a mini-map of the current selection
	
	love.graphics.printf("PLAYERS", 0, love.window.getHeight()/2 - H, love.window.getWidth(), "center")
	local col = 0
	for i,P in ipairs(Players) do
		if P.id ~= "neutral" then
			love.graphics.setColor(unpack(P.color))
			love.graphics.printf(P.name, col * love.window.getWidth()/4, love.window.getHeight()/2 + H, love.window.getWidth()/4, "center")
			col = col + 1
		end
	end
	love.graphics.setColor(255,255,255,255)
end

function screen_menu:quit()
end

screen_game = setmetatable({}, Screen)

function screen_game:load()
	game_grid = Grid.loadFile("maps/game1.map")
	
	Players.active = {}
	for i, T in ipairs(Players) do
		if T.active then
			table.insert(Players.active, T.id)
		end
	end
	
	game_grid:startTurn()
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

