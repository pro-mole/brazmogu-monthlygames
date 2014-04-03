require("screen")
--- Game Screen

ScreenGame = {}

function ScreenGame:draw()
	love.graphics.printf("PLAY THE GAME", love.window.getWidth()/2 - 10, love.windw.getHeight()/2, 20, "center")
end

Screen.new("game", ScreenGame)