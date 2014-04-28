-- Menu Screen

ScreenMenu = setmetatable({}, Screen)

function ScreenMenu:init()
	self.menu = {
		{text="Start", pos={center.x-48, center.y}, size={96,24}, action="goto", goto="game"},
		{text="Options", pos={center.x-48, center.y+32}, size={96,24}, action="submenu", submenu={
			title="Options",
			{text="Sound", pos={center.x-100, center.y}, size={96,32}, action="toggle", var="sound", values={"ON","OFF"}},
			{text="Music", pos={center.x+4, center.y}, size={96,32}, action="toggle", var="music", values={"ON","OFF"}, callback=toggleMusic},
			{text="Dificulty", pos={center.x-64, center.y+40}, size={128,32}, action="toggle", var="difficulty", values={"Easy","Medium","Hard"}},
			-- {text="Colorblind Mode", pos={center.x-72, center.y+80}, size={144,32}, action="toggle", var="colorblind", values={"ON","OFF"}},
			{text="Back", pos={center.x-24, center.y+120}, size={48,24}, action="back"}
		}},
		{text="Help", pos={center.x-48, center.y+64}, size={96,24}, action="goto", goto="help"},
		{text="About", pos={center.x-48, center.y+96}, size={96,24}, action="goto", goto="about"},
		{text="Quit", pos={center.x-48, center.y+128}, size={96,24}, action="quit"}
	}
	
	self.current_menu = self.menu
	self.parent_menu = nil
	print (self.current_menu)

	music.BGM:rewind()
	music.BGM:setVolume(0.5)
	if settings.music == "ON" then
		music.BGM:play()
	end
	
	love.graphics.setFont(fonts.standard)
end

function ScreenMenu:mousepressed(x, y, button)
	if button == 'l' then
		-- Check all menu buttons :D
		for i, button in ipairs(self.current_menu) do
			if x > button.pos[1] and x < button.pos[1]+button.size[1] and y > button.pos[2] and y < button.pos[2]+button.size[2] then
				if button.action == "goto" then
					-- Go to another screen
					changeScreen(button.goto)
				elseif button.action == "submenu" then
					self.parent_menu = self.current_menu
					self.current_menu = button.submenu
				elseif button.action == "toggle" then
					-- Change game setting value
					local value = settings[button.var]
					for i,v in ipairs(button.values) do
						if v == value then
							if i < #button.values then
								settings[button.var] = button.values[i+1]
							else
								settings[button.var] = button.values[1]
							end
							break
						end
					end
					settings:save()
				elseif button.action == "back" then
					-- Go back one menu
					self.current_menu = self.parent_menu
				elseif button.action == "quit" then
					-- Quit game	
					love.event.quit()
				end
				
				if button.callback then
					button.callback()
				end
			end
		end
	end
end

function ScreenMenu:keypressed(key, isrepeat)
end

function ScreenMenu:draw()
	love.graphics.setColor(255,255,255,255)
	love.graphics.draw(bg['titlescreen'])

	-- Draw the menu header
	love.graphics.setFont(fonts.huge)
	love.graphics.printf("PIXEL POP DEFENSE ZONE", 0, center.y/2 - fonts.huge:getHeight(), love.window.getWidth(), "center")
	
	love.graphics.setFont(fonts.standard)
	self:drawMenu(self.current_menu)
	-- Draw footer stuff, I guess
	--love.graphics.setFont(fonts.standard)
	love.graphics.printf("HIGHSCORE", center.x-32, love.window.getHeight() - 128 - fonts.standard:getHeight()*2 - 2, 64, "center")
	love.graphics.printf(highscore, center.x-32, love.window.getHeight() - 128 - fonts.standard:getHeight() - 1, 64, "center")
end

function ScreenMenu:drawMenu(menu)
	if menu.title ~= nil then
		love.graphics.setFont(fonts.big)
		love.graphics.printf(menu.title, 0, center.y - fonts.big:getHeight() - 8, love.window.getWidth(),"center")
		love.graphics.setFont(fonts.standard)
	end
	
	local mx, my = love.mouse.getPosition()
	love.graphics.setColor(255,255,255,255)
	for i,button in ipairs(menu) do
		if button.action == "toggle" then -- toggle buttons need to tell me what value is set
			love.graphics.rectangle("line", button.pos[1], button.pos[2], button.size[1], button.size[2])
			love.graphics.printf(button.text, button.pos[1], button.pos[2] + 8, button.size[1],"center")
			love.graphics.printf(settings[button.var], button.pos[1], button.pos[2] + 12 + fonts.standard:getHeight(), button.size[1],"center")
		else -- all other buttons
			love.graphics.rectangle("line", button.pos[1], button.pos[2], button.size[1], button.size[2])
			love.graphics.printf(button.text, button.pos[1], button.pos[2] + (button.size[2] - fonts.standard:getHeight())/2, button.size[1],"center")
		end
	end
end

function ScreenMenu:quit()
end

function toggleMusic()
	if settings['music'] == "ON" then
		music.BGM:play()
	else
		music.BGM:stop()
	end
end

addScreen(ScreenMenu, "menu")