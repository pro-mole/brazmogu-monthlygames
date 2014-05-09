-- Main menu screen
MenuScreen = setmetatable({}, Screen)

function MenuScreen:load()
	self.UI = GUI.new()
	
	self.UI:addMenu({title = "MOLESWEEPER", items = {
		--{text = 'Start', action = 'submenu', submenu = {"Game Setup", items={}}},
		{text = 'Custom Game', action = 'submenu', submenu = {title="Game Setup", items={
			{text = 'Start Game', action = 'goto', goto = gamescreen},
			{text = 'Field Width', action = 'setting', varname = 'minefield.width', values = {9,11,13,15,17,19,21,23,25,27,29,31,33,35}},
			{text = 'Field Height', action = 'setting', varname = 'minefield.height', values = {9,11,13,15,17,19,21,23,25,27,29,31,33,35}},
			{text = 'Number of Mines', action = 'setting', varname = 'minefield.mines', values = {4,8,12,15,20,25,30,40,50}},
			{text = 'Coppermoss', action = 'setting', varname = 'minefield.coppermoss', values = {"YES","NO"}},
			{text = 'Ironcaps', action = 'setting', varname = 'minefield.ironcap', values = {"YES","NO"}},
			{text = 'Goldendrops', action = 'setting', varname = 'minefield.goldendrop', values = {"YES","NO"}},
			{text = 'Back', action = 'back'}
		}}},
		{text = 'Settings', action = 'submenu', submenu = {title="Settings", items={
			{text = 'Back', action = 'back'}
		}}},
		{text = 'Help', action = 'goto', goto = helpscreen},
		{text = 'About', action = 'goto', goto = aboutscreen},
		{text = 'Quit', action = 'quit'}
	}})
end

function MenuScreen:update(dt)
end

function MenuScreen:draw()
	love.graphics.setColor(255,255,255,255)
	self.UI:draw()
	
	love.graphics.rectangle("line", 1,love.window.getHeight() - 9, 8, 8)
end

function MenuScreen:quit()
end

function MenuScreen:keypressed(k, isrepeat)
	self.UI:keypressed(k, isrepeat)
end

return MenuScreen