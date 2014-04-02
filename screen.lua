-- Let's try to define a class that will let us work with game screens

Screen = {}
Screen.__index = Screen

screens = {}
current_screen = nil

Screen.new(name)
	screens[name] = setmetatable({}, Screen)
	if current_screen == nil then
		current_screen = screens[name]
	end
end

Screen:init()
	-- Called when the screen starts
end

Screen:quit()
	-- Called when we exit the screen
end

Screen:draw()
	-- Called to draw the screen
end

Screen:update(dt)
	-- Called to update the screen
end