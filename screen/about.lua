-- About Screen
AboutScreen = setmetatable(Screen, {})

font["credits_title"] = love.graphics.newFont("assets/font/amiga4ever.ttf", 18)
font["credits_text"] = love.graphics.newFont("assets/font/amiga4ever.ttf", 14)

function AboutScreen:keypressed(k,isrepeat)
	if k == "escape" then
		screens:pop()
	end
end

function AboutScreen:draw()
	love.graphics.draw(backdrop.printer, 0, 0)
	love.graphics.setColor(24,24,24,255)

	love.graphics.setFont(font.credits_title)
	love.graphics.printf("MOLESWEEPER (V1.1)", 0, 8, 640, "center")

	love.graphics.setFont(font.credits_text)

	love.graphics.translate(0, 128)
	love.graphics.printf("= DESIGN, CODE & GRAPHICS =", 0, 0, 640, "center")
	love.graphics.printf("Bruno Guedes", 0, 16, 640, "center")

	love.graphics.translate(0, 64)
	love.graphics.printf("= ENGINE =", 0, 0, 640, "center");
	love.graphics.printf("LOVE 2D", 0, 16, 640, "center");
	love.graphics.printf("http://love2d.org", 0, 32, 640, "center");
	
	love.graphics.translate(0, 80)
	love.graphics.printf("= MUSIC =", 0, 0, 640, "center");
	love.graphics.printf("\"NOT SAFE\" by CCIVORY", 0, 16, 640, "center");

	love.graphics.origin()
	love.graphics.setColor(255,255,255,255)
	love.graphics.draw(backdrop.face, 178, 328)
end

return AboutScreen