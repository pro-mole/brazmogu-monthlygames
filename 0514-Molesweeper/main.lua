-- Load game classes
require("molesweeper/settings")
require("molesweeper/gui")
require("molesweeper/grid")
require("molesweeper/mole")
-- Load the screens
require("screen/main")
menuscreen = require("screen/menu")
gamescreen = require("screen/game")
helpscreen = nil
aboutscreen = nil

gameover = false;

function love.load()
	load()
	screens:push(menuscreen)

	print("Loaded")
end

function love.keypressed(k, isrepeat)
	screens:keypressed(k, isrepeat)
end

function love.update(dt)
	screens:update(dt)
end

function love.draw()
	love.graphics.setColor(255,255,255,255)
	screens:draw()
end

function love.quit()
end