-- Help Screen

ScreenHelp = setmetatable({}, Screen)

function ScreenHelp:init()
	self.splashsize = 1
	addParticle(partFlash, 150, 368, 15, 16, {r=255, g=255, b=255})
	self.delta = 0
end

function ScreenHelp:update(dt)
	self.delta = self.delta + dt
	if self.delta > 1 then
		if self.splashsize >= 4 then
			self.splashsize = 1
		else
			self.splashsize = self.splashsize + 1
		end
		addParticle(partFlash, 150, 368, 15, 16 * self.splashsize, {r=255, g=255, b=255})
		self.delta = self.delta - 1
	end
end

function ScreenHelp:keypressed(key, isrepeat)
	if key == 'escape' or key == 'backspace' then
		changeScreen("menu")
	end
end

function ScreenHelp:draw()
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.setFont(fonts.big)
	-- Draw Instructions directly on screen because why not, hm?
	love.graphics.printf("Playing Pixel Pop Defense Zone is pretty simple: just click the pixels(seen to the right, in many different colors) into oblivion before they reach the zone delimited in the center of the screen!", 32, 32, 256, "left");
	
	local _x, x, y = 0, 406, 64
	for i,k in ipairs(COLOR) do
		if _x >= 4 then	_x, x, y = 0, 406, y+24 end
		
		love.graphics.setColor(k.r, k.g, k.b, 255)
		love.graphics.rectangle("fill", x, y, 8, 8)
		_x = _x + 1
		x = x + 24
	end
	
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.printf("Try clicking pixels of a same color in a row to not only rack up more points per pixel destroyed, but also add a sweet splash effect and destroy more pixels at once!", 332, 280, 256, "right");
	love.graphics.rectangle("fill", 140, 284, 8, 8)
	love.graphics.setFont(fonts.standard)
	love.graphics.printf(self.splashsize, 150, 282, 8, "center")
	love.graphics.setFont(fonts.big)
	particles:draw()
	
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.printf("And that's about all you need to know for now! Stay strong as long as you can and best of luck!", 32, 480, 536, "center");
	
	love.graphics.setFont(fonts.standard)
	love.graphics.printf("Press 'Esc' or 'Backscape' to go back!", 16, 584, 268, "left");
end

function ScreenHelp:quit()
	while #particles > 0 do
		table.remove(particles,1)
	end
end

addScreen(ScreenHelp, "help")