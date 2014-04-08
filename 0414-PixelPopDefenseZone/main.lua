-- Load screens
require("screen")
require("screens/menu")
require("screens/game")
-- Load our game element classes
require("color")
require("pixel")
require("zone")
require("particle")

center = {}

function love.load()
	center.x = love.window.getWidth()/2
	center.y = love.window.getHeight()/2
	
	current_screen:init()
end

function love.update(dt)
	current_screen:update(dt)
end

function love.mousepressed(x, y, button)
	current_screen:mousepressed(x,y,button)
end

function love.keypressed(key, isrepeat)
	current_screen:keypressed(key,isrepeat)
end

function love.draw()
	current_screen:draw()
end

function love.quit()
	pixels = {}
end