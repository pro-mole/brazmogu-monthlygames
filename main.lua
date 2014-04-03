-- Load screens
require("screen")
require("screens/menu")
require("screens/game")
-- Load our game element classes
require("pixel")
require("zone")

score = 0
streak = 0
streak_color = ""

function love.load()
end

function love.update(dt)
	current_screen:update(dt)
end

function love.draw()
	current_screen:draw()
end

function love.quit()
end