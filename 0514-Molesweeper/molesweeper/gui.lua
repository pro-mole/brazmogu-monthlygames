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
	for k,f in pairs(self.keys) do
		if key == k and f then
			local callback = f[1]
			local object = f[2]
			callback(object)
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
end

-- Parse menu data and define things such as height and position from it
function GUI:process(menu)
	_menu = menu or self.root
end

function GUI:draw()
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