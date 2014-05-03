-- Load game classes
require("molesweeper/grid")
require("molesweeper/mole")
-- Load the screens
require("screen/main")
gamescreen = require("screen/game")

function love.load()
	screens:push(gamescreen)

	print("Loaded")
end

function love.keypressed(k, isrepeat)
	screens:keypressed(k, isrepeat)
end

function love.update(dt)
end

function love.draw()
	screens:draw()
end

function love.quit()
end