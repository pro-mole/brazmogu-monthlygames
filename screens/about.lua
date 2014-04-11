-- About Screen

ScreenAbout = setmetatable({}, Screen)

function ScreenAbout:init()
	self.delta = 0
end

function ScreenAbout:keypressed(key, isrepeat)
	if key == 'escape' or key == 'backspace' then
		changeScreen("menu")
	end
end

function ScreenAbout:update(dt)
	self.delta = self.delta + dt
	if self.delta >= 1 then
		local color = COLOR[love.math.random(1,#COLOR)]
		addParticle(partSpark, love.math.random(32,536), love.math.random(32,536), 15, love.math.random(3,6), color, love.math.random(1,4))
		self.delta = self.delta - 1
	end
end

function ScreenAbout:draw()
		particles:draw()
	
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.setFont(fonts.huge)
	love.graphics.printf("CREDITS", 32, 64, 536, "center");
	
	love.graphics.setFont(fonts.big)
	love.graphics.printf("DESIGN/CODING", 32, 144, 536, "center");
	love.graphics.setFont(fonts.standard)
	love.graphics.printf("Bruno Guedes", 32, 164, 536, "center");
	love.graphics.setFont(fonts.small)
	love.graphics.printf("[brazmogu.tumblr.com]", 32, 174, 536, "center");
	
	love.graphics.setFont(fonts.big)
	love.graphics.printf("ENGINE", 32, 262, 536, "center");
	love.graphics.setFont(fonts.standard)
	love.graphics.printf("LOVE 2D", 32, 282, 536, "center");
	love.graphics.setFont(fonts.small)
	love.graphics.printf("[love2d.org]", 32, 292, 536, "center");
	
	love.graphics.setFont(fonts.big)
	love.graphics.printf("SPECIAL THANKS TO", 32, 400, 536, "center");
	love.graphics.setFont(fonts.standard)
	love.graphics.printf("Ricardo", 32, 420, 536, "center");
	love.graphics.setFont(fonts.standard)
	love.graphics.printf("Steve", 32, 430, 536, "center");
	love.graphics.setFont(fonts.small)
	love.graphics.printf("and...", 32, 442, 536, "center");
	love.graphics.setFont(fonts.standard)
	love.graphics.printf("YOU", 32, 450, 536, "center");
	
	
	love.graphics.setFont(fonts.standard)
	love.graphics.printf("Press 'Esc' or 'Backscape' to go back!", 16, 584, 268, "left");
end

function ScreenAbout:quit()
	while #particles > 0 do
		table.remove(particles,1)
	end
end

addScreen(ScreenAbout, "about")