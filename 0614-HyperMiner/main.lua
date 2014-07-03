require("random")
require("physics")
require("draw")
require("texture")
require("particle")

font = {standard = love.graphics.newFont("assets/font/imagine_font.otf", 10)}

Space = require("universegenerator")
main_probe = nil

Radar = love.graphics.newCanvas(128,128)
NavWheel = love.graphics.newCanvas(128,128)

SpaceBG = generateBackground(1024, 0.64)

radar_color = {
	{255,255,255,255}, -- Class 0
	{128,128,182,255}, -- Class 1
	{64,64,64,255}, -- Class 2
	{96,192,192,255}, -- Class 3
	{0,64,128,255}, -- Class 4
	{128,128,64,255}, -- Class 5
}

require("probes")
require("asteroid")
require("comet")
require("satellite")
require("station")
require("planets")
require("stars")

debug_echo = false
debug_interval = 5

function print_debug(...)
	if debug_echo then
		print(...)
	end
end
 
loading = true
load_buffer = {}
 
function love.load()
	Universe:generate(arg[2])
	if #Space.probes >= 1 then
		main_probe = Space.probes[1]
	end

	-- Start loading textures
	loading = true
	for k,v in Space:iterator() do
		for l,B in ipairs(Space[v]) do
			table.insert(load_buffer, B)
		end
	end
	loaded = 0
	total_load = #load_buffer
end

function love.update(dt)
	if loading then return end
	
	--debug_interval = debug_interval - dt
	debug_echo = debug_interval <= 0

	Physics:update(dt)
	
	if debug_echo then 
		print(#Physics.bodies)
		io.stdout:flush()
		debug_interval = 5
		debug_echo = false
	end

	Particles:update(dt)
	for i,P in ipairs(Universe.probes) do
		P:update(dt)
	end
end

function love.keypressed(key, isrepest)
	print(key)
	io.stdout:flush()
	
	if key == "escape" then
		love.event.quit()
	end
	
	if loading then return end

	if key == "f8" then
		screenshot()
	end
	
	main_probe:keypressed(key, isrepeat)
end

function love.keyreleased(key)
	if loading then return end
	
	main_probe:keyreleased(key, isrepeat)
end

-- Drawing layers(all canvasses)
layers = {
	BG = love.graphics.newCanvas(),
	bot = love.graphics.newCanvas(),
	mid = love.graphics.newCanvas(),
	top = love.graphics.newCanvas(),
	UI = love.graphics.newCanvas(),
	over = love.graphics.newCanvas() -- Tooltips/Overlay
}

function love.draw()
	if loading then
		love.graphics.setCanvas()
		
		love.graphics.setFont(font.standard)
		love.graphics.setColor(255,255,255,255)
		love.graphics.printf("GENERATING UNIVERSE - LOADING TEXTURES", 0, love.window.getHeight()/2 - font.standard:getHeight(), love.window.getWidth(), "center")
		love.graphics.printf(string.format("%0d%%", loaded/total_load * 100), 0, love.window.getHeight()/2, love.window.getWidth(), "center")
		
		if #load_buffer > 0 then
			load_buffer[1]:loadTexture()
			table.remove(load_buffer, 1)
			loaded = loaded + 1
		else
			loading = false
		end
		
		return
	end

	local probe
	local screen_diag = math.sqrt(love.window.getWidth()^2 + love.window.getHeight()^2)
	local Tx, Ty = 0, 0
	if #Universe.probes >= 1 then
		probe = Universe.probes[1]
		love.graphics.push()
		Tx, Ty = probe.x, probe.y
		love.graphics.translate(love.window.getWidth()/2 - probe.x, love.window.getHeight()/2 - probe.y)
	end
	
	local S = SpaceBG:getWidth()
	local _x = math.floor(Tx / S) * S
	local _y = math.floor(Ty / S) * S
	local _dx = Tx %S
	local _dy = Ty %S

	love.graphics.setCanvas(layers.BG)
	love.graphics.draw(SpaceBG, _x, _y)
	
	if _dx < S/2 then
		love.graphics.draw(SpaceBG, _x-S, _y)
	elseif _dx > S/2 then
		love.graphics.draw(SpaceBG, _x+S, _y)
	end
	
	if _dy < S/2 then
		love.graphics.draw(SpaceBG, _x, _y-S)
	elseif _dy > S/2 then
		love.graphics.draw(SpaceBG, _x, _y+S)
	end
	
	if _dx < S/2 and _dy < S/2 then
		love.graphics.draw(SpaceBG, _x-S, _y-S)
	elseif _dx > S/2 and _dy < S/2 then
		love.graphics.draw(SpaceBG, _x+S, _y-S)
	elseif _dx < S/2 and _dy > S/2 then
		love.graphics.draw(SpaceBG, _x-S, _y+S)
	elseif _dx > S/2 and _dy > S/2 then
		love.graphics.draw(SpaceBG, _x+S, _y+S)
	end
	--[[love.graphics.draw(SpaceBG, _x-S, _y-S)
	love.graphics.draw(SpaceBG, _x, _y-S)
	love.graphics.draw(SpaceBG, _x+S, _y-S)
	love.graphics.draw(SpaceBG, _x-S, _y)
	love.graphics.draw(SpaceBG, _x, _y)
	love.graphics.draw(SpaceBG, _x+S, _y)
	love.graphics.draw(SpaceBG, _x-S, _y+S)
	love.graphics.draw(SpaceBG, _x, _y+S)
	love.graphics.draw(SpaceBG, _x+S, _y+S)]]

	for i,B in ipairs(Physics.bodies) do
		if (math.sqrt(squareBodyDistance(B,probe)) - B.size) <= screen_diag/2 then
			B:draw()
		end
	end
	Particles:draw()
	Physics:draw()
	
	if #Universe.probes >= 1 then
		love.graphics.pop()

		probe:drawUI()
	end
	
	love.graphics.origin()
	love.graphics.setCanvas()
	love.graphics.setColor(255,255,255,255)
	for i,L in ipairs({"BG","bot","mid","top","UI","over"}) do
		love.graphics.draw(layers[L],0,0)
		layers[L]:clear()
	end
	
	if love.keyboard.isDown("`") then
		drawMap(probe, 1/64)
	end
end