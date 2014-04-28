--- Game Screen

ScreenGame = setmetatable({}, Screen)

gameover = false
timestop = 0
score = 0
highscore = 0
multiplier = 1
streak = {n=0, r=255, g=255, b=255}

function ScreenGame:init()
	-- set up local vars
	zone:init(32)
	self.delta = 0
	self.dstep = 0
	if settings.difficulty == "Easy" then
		self.step=4
		self.interval = 4
		self.timerate = 0.99
		self.mininterval = 1
		
		self.speedavg = 8
		self.speedavgrate = 0.5
		self.maxspeedavg = 32
		
		self.speedvar = 0
		self.speedvarrate = 0.01
		self.maxspeedvar = 0.5

		self.randChances = {streak=5, flash=20, hollow=20, rainbow=20}
	elseif settings.difficulty == "Medium" then
		self.step=2
		self.interval = 2
		self.timerate = 0.9
		self.mininterval = 0.5
		
		self.speedavg = 12
		self.speedavgrate = 1
		self.maxspeedavg = 48
		
		self.speedvar = 0
		self.speedvarrate = 0.01
		self.maxspeedvar = 0.5

		self.randChances = {streak=10, flash=50, hollow=50, rainbow=100}
	elseif settings.difficulty == "Hard" then
		self.step=1
		self.interval = 1
		self.timerate = 0.75
		self.mininterval = 0.25
		
		self.speedavg = 16
		self.speedavgrate = 2
		self.maxspeedavg = 64
		
		self.speedvar = 0
		self.speedvarrate = 0.1
		self.maxspeedvar = 1

		self.randChances = {streak=20, flash=100, hollow=100, rainbow=500}
	end
	
	-- set up global vars
	gameover = false
	score = 0
	multiplier = 1
	streak = {n=0, r=255, g=255, b=255}

	-- play that music
	music.BGM:setVolume(1.0)
	if settings.music == "ON" then
		music.BGM:play()
	end
end

function ScreenGame:update(dt)
	if not gameover then
		if timestop <= 0 then
			self.delta = self.delta + dt
			self.dstep = self.dstep + dt
		end
		
		if timestop > 0 then timestop = timestop - dt
		elseif timestop < 0 then timestop = 0
		end

		if self.delta >= self.interval then
			self.delta = self.delta - self.interval
			local side = love.math.random(0,3)
			local color = COLOR[love.math.random(1,#COLOR)]
			--local color = COLOR[11]
			local ptype = "common"
			
			-- Chance of continuing the streak (definitely)
			local chance = love.math.random(1,self.randChances.streak)
			if chance == 1 then
				color = {r=streak.r, g=streak.g, b=streak.b}
			end
			
			-- Chance of pixel being special
			chance = love.math.random(1,self.randChances.flash)
			if chance == 1 then
				ptype = "flash"
			else
				chance = love.math.random(1,self.randChances.hollow)
				if chance == 1 then
					ptype = "hollow"
				else
					chance = love.math.random(1,self.randChances.rainbow)
					if chance == 1 then
						ptype = "rainbow"
					end
				end
			end
			
			local speed = self.speedavg + self.speedavg*love.math.random(-self.speedvar, self.speedvar)
			if side == 0 then     -- Left
				Pixel.new(0, love.math.random(love.window.getHeight()), color, speed, ptype)
			elseif side == 1 then -- Top
				Pixel.new(love.math.random(love.window.getWidth()), 0, color, speed, ptype)
			elseif side == 2 then -- Right
				Pixel.new(love.window.getWidth(), love.math.random(love.window.getHeight()), color, speed, ptype)
			elseif side == 3 then -- Bottom
				Pixel.new(love.math.random(love.window.getWidth()), love.window.getHeight(), color, speed, ptype)
			end
		end
		
		if self.dstep >= self.step then
			self.dstep = self.dstep - self.step
			if self.interval > self.mininterval then self.interval = self.interval * self.timerate end
			if self.speedavg < self.maxspeedavg then self.speedavg = self.speedavg + self.speedavgrate end
			if self.speedvar < self.maxspeedvar then self.speedvar = self.speedvar + self.speedvarrate end
		end

		for i,pixel in pairs(pixels) do
			pixel:update(dt)
		end
	end
end

function ScreenGame:keypressed(key ,isrepeat)
	if key == "escape" and gameover then
		changeScreen("menu")
	end
end

function ScreenGame:mousepressed(x, y, button)
	if not gameover then
		print(string.format("mouse press(%s) at %d;%d",button,x,y))
		if button == 'l' then
			for i,pixel in pairs(pixels) do
				if pixel:isClicked(x,y) then
					print("Got a pixel!")
					pixel:destroy(true)
					-- Consider breaking the loop here; maybe we don't want to click more than one at a time?
				end
			end
		end
	end
end

function ScreenGame:draw()
	-- love.graphics.printf("PLAY THE GAME", love.window.getWidth()/2 - 10, love.window.getHeight()/2, 20, "center")
	love.graphics.setColor(255,255,255,255)
	love.graphics.draw(bg['circles'])

	zone:draw()
	for i,pixel in pairs(pixels) do
		pixel:draw()
	end
	particles:draw()

	love.graphics.setFont(fonts.standard)
	love.graphics.setColor(255,255,255,255)
	local stats_w = fonts.standard:getWidth("STREAK")
	local stats_h = fonts.standard:getHeight() * 5
	love.graphics.printf("SCORE", 4, love.window.getHeight() - stats_h, stats_w, "center")
	love.graphics.printf(score, 4, love.window.getHeight() - stats_h + fonts.standard:getHeight() * 2, stats_w, "center")
	love.graphics.printf("STREAK", love.window.getWidth() - 4 - stats_w, love.window.getHeight() - stats_h, stats_w, "center")
	love.graphics.setColor(streak.r,streak.g,streak.b,255)
	love.graphics.rectangle("fill", love.window.getWidth() - stats_w/2 - 9, love.window.getHeight() - stats_h + fonts.standard:getHeight() * 2, 8, 8)
	love.graphics.printf(streak.n, love.window.getWidth() - stats_w/2 + 1, love.window.getHeight() - stats_h + fonts.standard:getHeight() * 2 + 1, fonts.standard:getWidth("00"), "left")
	
	if gameover then
		love.graphics.setColor(0,0,0,128)
		love.graphics.rectangle("fill",0,0,love.window.getWidth(),love.window.getHeight())
		love.graphics.setFont(fonts.big)
		love.graphics.setColor(255,255,255,255)
		love.graphics.printf("GAME OVER", 0, love.window.getHeight()/2 - 24, love.window.getWidth(), "center")
		love.graphics.setFont(fonts.standard)
		love.graphics.printf("Press ESC to continue...", 0, love.window.getHeight()/2, love.window.getWidth(), "center")
	end
	-- love.graphics.printf(#pixels, love.window.getWidth()/2 - 10, love.window.getHeight() - 16, 20, "center")
	-- love.graphics.printf(#COLOR, love.window.getWidth()/2 - 10, love.window.getHeight() - 32, 20, "center")
end

function ScreenGame:quit()
	pixels = {}
end

addScreen(ScreenGame, "game")