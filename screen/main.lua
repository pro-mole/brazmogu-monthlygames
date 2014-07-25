-- Screen manager stack and basic Screen class

Screen = {}
Screen.__index = Screen

function Screen:load()
end

function Screen:update(dt)
end

function Screen:keypressed(k, isrepeat)
end

function Screen:mousepressed(x, y, button)
end

function Screen:draw()
end

function Screen:quit()
end

function Screen:restart()
	self:quit()
	self:load()
end

screens  = {}

function screens:top()
	return self[#self]
end

function screens:push(k)
	local current = self:top()
	if current then
		current.quit()
	end

	table.insert(self, k)
	screen = self:top()
	screen:load()
end

function screens:pop(reload)
	local current = self:top()
	if current then
		current:quit()
		table.remove(self)
	end
	screen = self:top()
	if not screen then
		love.event.quit()
	end
	local R = reload or false
	if R then
		screen:load()
	end
end

function screens:keypressed(k, isrepeat)
	self:top():keypressed(k, isrepeat)
end

function screens:mousepressed(x, y, button)
	self:top():mousepressed(x, y, button)
end

function screens:update(dt)
	self:top():update(dt)
end

function screens:draw()
	self:top():draw()
end