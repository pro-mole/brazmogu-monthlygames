-- Load screens
require("screen")
require("screens/menu")
require("screens/game")
-- Load our game element classes
require("color")
require("pixel")
require("zone")

score = 0
streak = 0
streak_color = ""
center = {}

function love.load()
	center.x = love.window.getWidth()/2
	center.y = love.window.getHeight()/2
	
	current_screen:init()
end

function love.update(dt)
	current_screen:update(dt)
end

function love.draw()
	current_screen:draw()
end

function love.quit()
	pixels = {}
end