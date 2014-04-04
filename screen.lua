-- Let's try to define a class that will let us work with game screens

Screen = {}
Screen.__index = Screen

screens = {}
current_screen = nil

function addScreen(screen,name)
	screens[name] = screen
	if current_screen == nil then
		current_screen = screen
	end
end

function changeScreen(to)
	local _from = current_screen
	local _to = screens[to]
	if _to ~= nil and _from ~= _to then
		_from:quit()
		_to:init()
		current_screen = _to
	end
end

function Screen:init()
	-- Called when the screen starts
end

function Screen:quit()
	-- Called when we exit the screen
end

function Screen:draw()
	-- Called to draw the screen
end

function Screen:update(dt)
	-- Called to update the screen
end