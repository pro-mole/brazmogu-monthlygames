-- Let's try to define a class that will let us work with game screens

Screen = {}
Screen.__index = Screen

screens = {}
current_screen = nil

function Screen.new(name,screentype)
	screens[name] = setmetatable(setmetatable({}, screentype), Screen)
	if current_screen == nil then
		current_screen = screens[name]
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