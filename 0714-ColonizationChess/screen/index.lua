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
	local map = Maps[Maps.current]
	for p,a in pairs(map.players) do
		Players[p].active = a
	end
end

function screen_menu:keypressed(k, isrepeat)
	if k == "return" then
		love.audio.newSource(Sounds.start):play()
		love.timer.sleep(1)
		screens:push(screen_game)
	end
	
	if k == "left" then
		Maps:next()
		love.audio.newSource(Sounds.select):play()
	elseif k == "right" then
		Maps:prev()
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
	local map = Maps[Maps.current]
	love.graphics.printf(map.name, 0, love.window.getHeight()/4 + H, love.window.getWidth(), "center")
	-- Show map choice and a mini-map of the current selection
	local minimap = map.minimap
	love.graphics.draw(minimap, love.window.getWidth()/2 - minimap:getWidth()/2, love.window.getHeight()/4 + 3*H)
	
	love.graphics.printf("PLAYERS", 0, love.window.getHeight()/2 - H, love.window.getWidth(), "center")
	local col = 0
	for i,P in ipairs(Players) do
		if P.id ~= "neutral" then
			love.graphics.setColor(255,255,255,255)
			drawDecoratedBox(col * love.window.getWidth()/4+2, love.window.getHeight()/2 + H/2, love.window.getWidth()/4 - 4, 9*H, 2)
			love.graphics.setColor(unpack(P.color))
			love.graphics.printf(P.name, col * love.window.getWidth()/4 + 8, love.window.getHeight()/2 + H, love.window.getWidth()/4 - 16, "center")
			
			love.graphics.printf("Active:", col * love.window.getWidth()/4 + 8, love.window.getHeight()/2 + 3*H, love.window.getWidth()/4 - 16, "left")
			love.graphics.printf(string.format("%s",P.active), col * love.window.getWidth()/4 + 8, love.window.getHeight()/2 + 3*H, love.window.getWidth()/4 - 16, "right")
			
			love.graphics.printf("CPU:", col * love.window.getWidth()/4 + 8, love.window.getHeight()/2 + 5*H, love.window.getWidth()/4 - 16, "left")
			love.graphics.printf(string.format("%s",P.AI), col * love.window.getWidth()/4 + 8, love.window.getHeight()/2 + 5*H, love.window.getWidth()/4 - 16, "right")
			
			love.graphics.printf(string.format("Press (%s) to toggle AI", P.key), col * love.window.getWidth()/4 + 8, love.window.getHeight()/2 + 7*H, love.window.getWidth()/4 - 16, "center")
			if not P.active then
				love.graphics.setColor(0,0,0,192)
				love.graphics.rectangle("fill", col * love.window.getWidth()/4+4,love.window.getHeight()/2 + H/2 + 2, love.window.getWidth()/4 - 8, 9*H - 4)
			end
			
			col = col + 1
		end
	end
	love.graphics.setColor(255,255,255,255)
	
	love.graphics.printf("START\n(ENTER)", 0, love.window.getHeight()*7/8, love.window.getWidth(), "center")
end

function screen_menu:quit()
end

screen_game = setmetatable({}, Screen)

function screen_game:load()
	game_grid = Grid.loadFile("maps/" .. Maps[Maps.current].name)
	
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
	for x,y,T in game_grid:iterator() do
		T:update(dt)
	end
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

