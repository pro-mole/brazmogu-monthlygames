-- Load screens
require("screen")
require("screens/menu")
require("screens/game")
require("screens/help")
require("screens/about")
-- Load our game element classes
require("color")
require("pixel")
require("zone")
require("particle")

center = {}
fonts = {}
bg = {}
sound = {}
music = {}
settings = {sound = "ON", music = "ON", difficulty = "Medium", colorblind = "OFF"}

function love.load()
	center.x = love.graphics.getWidth()/2
	center.y = love.graphics.getHeight()/2
	
	fonts['small'] = love.graphics.newFont("assets/font/PixelPop.ttf",8)
	fonts['standard'] = love.graphics.newFont("assets/font/PixelPop.ttf",10)
	fonts['big'] = love.graphics.newFont("assets/font/PixelPop.ttf",12)
	fonts['huge'] = love.graphics.newFont("assets/font/PixelPop.ttf",48)

	sound['dissolve'] = love.audio.newSource("assets/sound/dissolve.wav","static")

	music['BGM'] = love.audio.newSource("assets/sound/bgm.mp3","stream")
	
	bg['circles'] = love.graphics.newImage("assets/bg/octos.png")
	bg['titlescreen'] = love.graphics.newImage("assets/bg/title.png")

	score_load()
	settings:load()
	
	current_screen:init()
end

function love.update(dt)
	current_screen:update(dt)
end

function love.mousepressed(x, y, button, istouch)
	current_screen:mousepressed(x,y,button)
end

function love.keypressed(key, scancode, isrepeat)
	current_screen:keypressed(key,isrepeat)
end

function love.draw()
	current_screen:draw()
end

function love.quit()
	pixels = {}
end

function settings:save()
	local gamedata = ""
	for k,v in pairs(self) do
		if k ~= "save" and k ~= "load" then
			gamedata = gamedata .. string.format("%s=%s\n",k,v)
		end
	end
	if not love.filesystem.write("ppdz.settings", gamedata) then
		print("ERROR: Cannot save settings")
	end
end

function settings:load()
	if not love.filesystem.getInfo("ppdz.settings") then
		self:save()
	else
		local str, bytes = love.filesystem.read("ppdz.settings")
		-- print(string.format("%s bytes read from save file", bytes))
		if bytes == 0 then return end
		
		for k, v in string.gmatch(str, "(%w+)=(%w+)") do
			self[k] = v
		end
	end
end

function score_load()
	if not love.filesystem.getInfo("ppdz.data") then
		score_save()
	else
		local str, bytes = love.filesystem.read("ppdz.data")

		if bytes == 0 then return end

		highscore_str = ""
		for k=1,10 do
			hex = str:sub((k-1)*4 + 1, k*4)
			val = string.char((tonumber(hex, 16) / 9)+32)
			highscore_str = highscore_str .. val
		end

		highscore = tonumber(highscore_str)
	end
end

function score_save()
	-- "Encrypt" high score
	crypto = ""
	highscore_str = string.format("%010d", highscore)
	for n=1,10 do
		hex = string.format("%04x", 9*(string.byte(highscore_str, n) - 32))
		crypto = crypto .. hex
	end

	if not love.filesystem.write("ppdz.data", crypto) then
		print("ERROR: Cannot save high score")
	end
end