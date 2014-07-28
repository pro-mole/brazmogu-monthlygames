-- Screen Index

screen_quit = setmetatable({}, Screen)

function screen_quit:draw()
	love.graphics.printf("QUIT?", 0, love.window.getHeight()/2 - love.graphics.getFont():getHeight(), love.window.getWidth(), "center")
	love.graphics.printf("ESC=YES	SPACE=NO", 0, love.window.getHeight()/2, love.window.getWidth(), "center")
end

function screen_quit:keypressed(k, isrepeat)
	if k == "escape" then
		screens:pop()
		screens:pop()
	elseif k == " " then
		screens:pop()
	end
end

screen_menu = setmetatable({}, Screen)

function screen_menu:load()
	-- Load properties from file
end

function screen_menu:update(dt)
	local map = Maps[Maps.current]
	for p,a in pairs(map.players) do
		Players[p].active = a
	end
end

function screen_menu:keypressed(k, isrepeat)
	love.audio.setVolume(0.5)
	if k == "return" then
		love.audio.newSource(Sounds.start):play()
		love.timer.sleep(1)
		screens:push(screen_game)
	elseif k == "h" then
		screens:push(screen_help)
	elseif k == "escape" then
		screens:push(screen_quit)
	end
	
	if k == "left" then
		Maps:next()
		love.audio.newSource(Sounds.select):play()
	elseif k == "right" then
		Maps:prev()
		love.audio.newSource(Sounds.select):play()
	end

	if k == "up" then
		GameModes:next()
		love.audio.newSource(Sounds.select):play()
	elseif k == "down" then
		GameModes:prev()
		love.audio.newSource(Sounds.select):play()
	end
	
	for i,P in ipairs(Players) do
		if k == P.key and P.active then
			P.AI = not P.AI
		end
	end
end

function screen_menu:draw()
	-- Menu screen
	local H = love.graphics.getFont():getHeight()
	love.graphics.printf("MAP SELECT", 0, love.window.getHeight()/4 - H, love.window.getWidth(), "center")
	love.graphics.polygon("fill",
		love.window.getWidth()/2 - 64, love.window.getHeight()/4 - H,
		love.window.getWidth()/2 - 68, love.window.getHeight()/4 - H/2,
		love.window.getWidth()/2 - 64, love.window.getHeight()/4)
	love.graphics.polygon("fill",
		love.window.getWidth()/2 + 64, love.window.getHeight()/4 - H,
		love.window.getWidth()/2 + 68, love.window.getHeight()/4 - H/2,
		love.window.getWidth()/2 + 64, love.window.getHeight()/4)
	local map = Maps[Maps.current]

	love.graphics.printf(map.name, 0, love.window.getHeight()/4 + H, love.window.getWidth(), "center")
	-- Show map choice and a mini-map of the current selection
	local minimap = map.minimap
	love.graphics.draw(minimap, love.window.getWidth()/2 - minimap:getWidth()/2, love.window.getHeight()/4 + 3*H)
	
	love.graphics.printf("GAME MODE", 0, love.window.getHeight()*3/7 - H, love.window.getWidth(), "center")
	love.graphics.polygon("fill",
		love.window.getWidth()/2, love.window.getHeight()*3/7 + H/2-2,
		love.window.getWidth()/2 - 4, love.window.getHeight()*3/7 + H-2,
		love.window.getWidth()/2 + 4, love.window.getHeight()*3/7 + H-2)
	love.graphics.polygon("fill",
		love.window.getWidth()/2, love.window.getHeight()*3/7 + 5*H/2+2,
		love.window.getWidth()/2 - 4, love.window.getHeight()*3/7 + 2*H+2,
		love.window.getWidth()/2 + 4, love.window.getHeight()*3/7 + 2*H+2)
	love.graphics.printf(GameModes[GameModes.current][1], 0, love.window.getHeight()*3/7 + H, love.window.getWidth(), "center")

	love.graphics.printf("PLAYERS", 0, love.window.getHeight()*3/5 - H, love.window.getWidth(), "center")
	local col = 0
	for i,P in ipairs(Players) do
		if P.id ~= "neutral" then
			love.graphics.setColor(255,255,255,255)
			drawDecoratedBox(col * love.window.getWidth()/4+2, love.window.getHeight()*3/5 + H/2, love.window.getWidth()/4 - 4, 9*H, 2)
			love.graphics.setColor(unpack(P.color))
			love.graphics.printf(P.name, col * love.window.getWidth()/4 + 8, love.window.getHeight()*3/5 + H, love.window.getWidth()/4 - 16, "center")
			
			love.graphics.printf("Active:", col * love.window.getWidth()/4 + 8, love.window.getHeight()*3/5 + 3*H, love.window.getWidth()/4 - 16, "left")
			love.graphics.printf(string.format("%s",P.active), col * love.window.getWidth()/4 + 8, love.window.getHeight()*3/5 + 3*H, love.window.getWidth()/4 - 16, "right")
			
			love.graphics.printf("CPU:", col * love.window.getWidth()/4 + 8, love.window.getHeight()*3/5 + 5*H, love.window.getWidth()/4 - 16, "left")
			love.graphics.printf(string.format("%s",P.AI), col * love.window.getWidth()/4 + 8, love.window.getHeight()*3/5 + 5*H, love.window.getWidth()/4 - 16, "right")
			
			love.graphics.printf(string.format("Press (%s) to toggle AI", P.key), col * love.window.getWidth()/4 + 8, love.window.getHeight()*3/5 + 7*H, love.window.getWidth()/4 - 16, "center")
			if not P.active then
				love.graphics.setColor(0,0,0,192)
				love.graphics.rectangle("fill", col * love.window.getWidth()/4+4,love.window.getHeight()*3/5 + H/2 + 2, love.window.getWidth()*3/5 - 8, 9*H - 4)
			end
			
			col = col + 1
		end
	end
	love.graphics.setColor(255,255,255,255)
	
	love.graphics.printf("START (ENTER)", 0, love.window.getHeight()*7/8, love.window.getWidth(), "center")
	love.graphics.printf("HELP (H)", 0, love.window.getHeight()*7/8 + 2*H, love.window.getWidth(), "center")
end

function screen_menu:quit()
end

screen_game = setmetatable({}, Screen)

function screen_game:load()
	game_grid = Grid.loadFile("maps/" .. Maps[Maps.current].name)
	game_grid.victory = GameModes[GameModes.current][2]
	AI.grid = game_grid
	
	Players.active = {}
	for i, T in ipairs(Players) do
		if T.active then
			table.insert(Players.active, T.id)
		end
	end
	
	game_grid:startTurn()
end

function screen_game:update(dt)
	if Players[turn.player].AI and turn.player ~= neutral then
		if AI_delay <= 0 then
			AI.takeMove(turn.player)
			AI_delay = 1
			if turn.pieces <= 0 then
				game_grid:startTurn()
			end
		else
			AI_delay = AI_delay - dt
		end
	end

	game_grid:mouseover()
	for x,y,T in game_grid:iterator() do
		T:update(dt)
	end
end

function screen_game:keypressed(k, isrepeat)
	if k == "escape" then
		screens:push(screen_quit)
	end
	
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

screen_help = setmetatable({}, Screen)

function screen_help:draw()
	love.graphics.printf("MANUAL", 0, 12, love.window.getWidth(), "center")
	love.graphics.printf([[Colonization Chess is a game for up to 4 players in local multiplayer mode. The objective of the game is to conquer all the bases in the field.
	
	At the start of their turn, each player has a number of moves equals to the number of bases and farms they control. For each move the player may choose a tile to:
	- Conquer an empty tile adjacent to the area the player controls;
	- Fortify one of their own tiles; or
	- Attack an enemy tile adjacent to the area the player controls.
	At the end of the turn, each tile the player controls will proliferate, adding 1 to its current occupation.
	
	Different tiles on the field add different advantages to the player that controls them:
	- Base tiles give one extra move and also are necessary to win the game;
	- Farm tiles give one extra move per turn;
	- Turret tiles will cause one more damage on enemy tiles per attack;
	- Bunker tiles will prevent one damage when the enemy attacks(the damage dealt cannot be smaller than 1);
	- Tower tiles give one extra tile of range to the player.]], 8, 36, love.window.getWidth()-16, "left")
	
	love.graphics.printf("PRESS 'ESC' TO RETURN", 8, love.window.getHeight() - love.graphics.getFont():getHeight(), love.window.getWidth() - 8, "right")
end

function screen_help:keypressed(k, isrepeat)
	if k == "escape" then
		screens:pop()	
	end
end