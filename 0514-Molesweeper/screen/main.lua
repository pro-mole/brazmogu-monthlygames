-- Screen manager stack and basic Screen class

Screen = {}
Screen.__index = Screen

function Screen:load()
end

function Screen:update(dt)
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

function screens:pop()
	local current = self:top()
	if current then
		current:quit()
		table.remove(self)
	end
	screen = self:top()
end

function screens:keypressed(k, isrepeat)
	self:top():keypressed(k, isrepeat)
end

function screens:update(dt)
	self:top():update(dt)
end

function screens:draw()
	self:top():draw()
end