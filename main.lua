font = {}
sound = {}
bgm = {}
backdrop = {}
sprite = {}
settings = {
	minefield = {
	width = 15,
	height = 15,
	start = {x = 8, y = 15},
	mines = 8
	}
}

-- Load game classes
require("molesweeper/gui")
require("molesweeper/grid")
require("molesweeper/mole")
-- Load the screens
require("screen/main")
gamescreen = require("screen/game")

gameover = false;

function love.load()
	screens:push(gamescreen)

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