-- GUI functions

-- Load functions
font['menutitle'] = love.graphics.newFont("assets/font/amiga4ever.ttf", 14)
font['menustandard'] = love.graphics.newFont("assets/font/amiga4ever.ttf", 10)

GUI = { menu_padding = 4,
	button_padding = 4,
	label_padding = 4}
GUI.__index = GUI

function GUI.new()
	local N = setmetatable({menu = nil, messages = {}, labels = {}, buttons = {}, keys = {}}, GUI)

	return N
end

function GUI:mousepressed(x, y, button)
end

function GUI:keypressed(key, isrepeat)
	-- Menu controls take precedence
	if self.menu then
		local M = self.menu.current
		if key == "return" or key == " " then
			-- Select option
			local I = M.items[M.pointer]
			if I.action == "goto" then
				screens:push(I.goto)
			elseif I.action == "back" then
				self.menu.current = M.parent
			elseif I.action == "quit" then
				love.event.quit()
			elseif I.action == "submenu" then
				self.menu.current = I.submenu
			end
		elseif key == "escape" then
			-- Go back/exit
			if M.parent == nil then
				love.event.quit()
			else
				self.menu.current = M.parent
			end
		elseif key == "up" then
			-- Move up on the menu options
			M.pointer = M.pointer - 1
			if M.pointer <= 0 then M.pointer = #M.items end
		elseif key == "down" then
			-- Move down on the menu options
			M.pointer = M.pointer + 1
			if M.pointer > #M.items then M.pointer = 1 end
		elseif key == "right" then
			-- Change value on multi-value options
		elseif key == "left" then
			-- Change value on multi-value options
		end
	else
		for k,f in pairs(self.keys) do
			if key == k and f then
				local callback = f[1]
				local object = f[2]
				callback(object)
			end
		end
	end
end

function GUI:update(dt)
	-- Only thing we do in GUI update is countdown the message stack items
	for i = #self.messages,1,-1 do
		local M = self.messages[i]
		M.timer = M.timer - dt
		if M.timer <= 0 then
			table.remove(self.messages, i)
		end
	end
end

-- Add a message box
-- This adds a message to a queue, and this queue will elminiate these messages one at a time
function GUI:addMessage(x, y, width, text, timer)
	local M = {x = x, y = y, w = width, text = text, timer = timer}
	M.h = font.menustandard:getHeight() + 2*GUI.label_padding

	table.insert(self.messages, M)
end

-- Add label
-- Labels are basically text on the screen; can contain formatted text
function GUI:addLabel(x, y, width, text, object, callback)
	local L = {x = x, y = y, w = width, text = text, args = args, object = object, callback = callback}
	L.h = font.menustandard:getHeight() + 2*GUI.label_padding

	table.insert(self.labels, L)
end

-- Adds a button on the screen
-- Buttons can be clicked or activated through a shortcut key
function GUI:addButton(x, y, width, height, text, object, callback, shortcut)
	local B = {x = x, y = y, w = width, h = height, callback = callback}
	B.text = text
	if shortcut then
		self.keys[shortcut] = {callback, object}
		B.text = string.format("%s\n(%s)", text, shortcut)
	end

	table.insert(self.buttons, B)
end

-- Adds a menu to the UI
-- May contain submenus and is controlled via keys
function GUI:addMenu(menu)
	local M = self:process(menu)
	self.menu = M
	self.menu.current = self.menu 
end

-- Parse menu data and define things such as height and position from it
function GUI:process(menu, parent)
	local _menu = menu
	local M = {x = love.window.getWidth()/2, y = love.window.getHeight()/2, h = 0, w = 0, title = menu.title, items = {}, parent = parent, pointer = nil}
	
	for _,item in ipairs(_menu.items) do
		local _width = font.menustandard:getWidth(item.text) + GUI.menu_padding*2
		if M.w < _width then M.w = _width end
		M.h = M.h + font.menustandard:getHeight() + GUI.menu_padding*2
		if item.action == "setting" then
			M.h = M.h + font.menustandard:getHeight() + GUI.menu_padding
		end
		
		-- Add item to the menu data, only the essential data
		if item.action == "back" or item.action == "quit" then
			table.insert(M.items, {text = item.text, action = item.action})
		elseif item.action == "goto" then
			table.insert(M.items, {text = item.text, action = item.action, goto = item.goto})
		elseif item.action == "setting" then
			table.insert(M.items, {text = item.text, action = item.action, var = item.varname, values = item.values})
		elseif item.action == "submenu" then
			table.insert(M.items, {text = item.text, action = item.action, submenu = self:process(item.submenu, M)})
		end
	end
	
	M.pointer = 1
	
	print(string.format("%s: %s;%s", M.title, M.w, M.h))
	-- Center menu on the screen
	M.x = M.x - M.w/2
	M.y = M.y - M.h/2
	
	return M
end

function GUI:draw()
	if self.menu then
		local m = self.menu.current
		
		love.graphics.push()
		love.graphics.translate(0, m.y)
		
		love.graphics.setFont(font.menutitle)
		love.graphics.printf(m.title, 0, -(font.menutitle:getHeight() + GUI.menu_padding*2), love.window.getWidth(), "center")
		
		love.graphics.push()
		love.graphics.translate(m.x, 0)
		
		love.graphics.setFont(font.menustandard)
		local _y = 0
		for _,item in ipairs(m.items) do
			love.graphics.printf(item.text, 0, _y, m.w, "center")
			
			if m.items[m.pointer] == item then
				self:drawPointer(item.action, 0, _y, m.w, font.menustandard:getHeight())
			end
			
			_y = _y + font.menustandard:getHeight() + GUI.menu_padding*2
			
			if item.action == "setting" then
				_y = _y + font.menustandard:getHeight() + GUI.menu_padding*2
			end
		end
		love.graphics.pop()
		love.graphics.pop()
	end

	love.graphics.setFont(font.menustandard)	
	for i,B in ipairs(self.buttons) do
		love.graphics.push()
		love.graphics.translate(B.x, B.y)

		love.graphics.rectangle("line", 0, 0, B.w, B.h)
		love.graphics.rectangle("line", 3, 3, B.w-6, B.h-6)
		local lines = select(2, string.gsub(B.text, "\n", "")) + 1
		local text_y = (B.h - font.menustandard:getHeight()*lines) / 2
		love.graphics.printf(B.text, GUI.button_padding, text_y, B.w - 2*GUI.button_padding, "center")

		love.graphics.pop()
	end

	for i,L in ipairs(self.labels) do
		love.graphics.push()
		love.graphics.translate(L.x, L.y)

		love.graphics.rectangle("line", 0, 0, L.w, L.h)
		if L.callback then
			love.graphics.printf(string.format(L.text, L.callback(L.object)), GUI.label_padding, GUI.label_padding, L.w - 2*GUI.label_padding, "center")
		else
			love.graphics.printf(string.format(L.text), GUI.label_padding, GUI.label_padding, L.w - 2*GUI.label_padding, "center")
		end

		love.graphics.pop()
	end
	
	if #self.messages >= 1 then
		local M = self.messages[#self.messages]
		love.graphics.push()
		love.graphics.translate(M.x, M.y)
		
		love.graphics.printf(string.format(M.text), GUI.label_padding, GUI.label_padding, M.w - 2*GUI.label_padding, "center")

		love.graphics.pop()
	end
end

-- Draw pointer for menu
-- Depending on the action, the pointer will change, for aesthetic reasons :P
function GUI:drawPointer(action,x,y,w,h)
	-- Default pointer
	if action == "back" then
		love.graphics.polygon("fill",
				x - GUI.menu_padding, y,
				x - GUI.menu_padding, y + h,
				x - 8 - GUI.menu_padding, y + h/2)
	elseif action == "setting" then
		love.graphics.polygon("fill",
				x - GUI.menu_padding, y,
				x - GUI.menu_padding, y + h,
				x - 8 - GUI.menu_padding, y + h/2)
		love.graphics.polygon("fill",
				x + w + GUI.menu_padding, y,
				x + w + GUI.menu_padding, y + h,
				x + w + 8 + GUI.menu_padding, y + h/2)
	else
		love.graphics.polygon("fill",
				x - 8 - GUI.menu_padding, y,
				x - 8 - GUI.menu_padding, y + h,
				x - GUI.menu_padding, y + h/2)
		love.graphics.polygon("fill",
				x + w + 8 + GUI.menu_padding, y,
				x + w + 8 + GUI.menu_padding, y + h,
				x + w + GUI.menu_padding, y + h/2)
	end
end