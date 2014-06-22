require("random")
require("physics")
require("universegenerator")
require("draw")
require("texture")
require("particle")

font = {standard = love.graphics.newFont("assets/font/imagine_font.otf", 10)}

Space = {
	probes = {},
	stars = {},
	planets = {},
	satellites = {},
	meteors = {},
	comets = {},
	stations = {}
}

Radar = love.graphics.newCanvas(128,128)
NavWheel = love.graphics.newCanvas(128,128)

SpaceBG = generateBackground(1024, 0.64)

radar_color = {
	{255,255,255,255}, -- Class 0
	{255,192,192,255}, -- Class 1
	{128,256,192,255}, -- Class 2
	{96,192,96,255}, -- Class 3
	{128,64,128,255}, -- Class 4
	{64,128,64,255}, -- Class 5
	{128,128,64,255} -- Class 6
}

require("probes")
require("satellite")
require("planets")
require("stars")

debug_echo = false
debug_interval = 5

function print_debug(...)
	if debug_echo then
		print(...)
	end
end
 
function love.load()
	Probe.new({name = "Probe", x = -8, y = 1024, v = 5, dir = math.rad(270), mass = 1, size = 8, active = true})
	
	-- Test environment
	-- A planetary system with two moons around it
	-- Also some asteroids and a comet
	Star.new({name = "Sol", x = 12148, y = 1024, v = 0, dir = 0, vrot = math.pi/8, mass = 1024, size = 1024,
		texture_params = { {"gradient", {144, 128, 0, 255}, {128, 32, 0, 255}, 100}, {"scatter", {255, 0, 0, 128}, 0.8} } })
		
	Planet.new({name = "Terra", x = 1024, y = 1024, v = 2, dir = math.rad(270), vrot = math.pi/8, mass = 512, size = 128, atmosphere = {H=0.1, O=0.6, H20=0.3}, atmosphere_size = 240,
		texture_params = { {"gradient", {64, 128, 144, 255}, {12, 64, 96, 255}, 50}, {"scatter", {0, 0, 128, 128}, 0.8}, {"blotch", {0, 64, 0, 204}, 8, 0.8} } })
		
	Satellite.new({name = "Luna", x = 1024, y = 1024 + 640, v = 20, dir = math.atan2(-2,20), vrot = -math.pi/16, mass = 24, size = 16,
		texture_params = { {"gradient", {128, 32, 32, 255}, {72, 0, 0, 255}, 32}, {"scatter", {0, 0, 0, 128}, 0.5} } })
	Satellite.new({name = "Selena", x = 64, y = 1024, v = 16.5, dir = math.rad(90), vrot = math.pi/64, mass = 48, size = 32,
		metals = {["Fe"] = 5, ["C"] = 3},
		texture_params = { {"gradient", {192, 128, 144, 255}, {128, 108, 128, 255}, 50}, {"blotch", {64, 64, 64, 64}, 4, 0.8}, {"blotch", {0, 0, 64, 64}, 3, 0.9} } })

	table.insert(Space.stations, Body.new({name = "ST001", x = 0, y = 1024, v = 18, dir = math.pi*1.5, vrot = -math.pi/48, mass = 16, size = 16, class = 1,
		texture_params = { {"gradient", {255, 255, 255, 255}, {64, 64, 64, 255}, 50} } }))

	-- Load all textures
	for k,v in pairs(Space) do
		for i = 1,#v do
			v[i]:loadTexture()
		end
	end
	-- Clear all events before actually starting the game
	love.event.clear()
end

function love.update(dt)
	debug_interval = debug_interval - dt
	debug_echo = debug_interval <= 0
	
	Physics:update(dt)
	
	if debug_echo then 
		print(#Physics.bodies)
		io.stdout:flush()
		debug_interval = 5
		debug_echo = false
	end

	Particles:update(dt)
	for i,P in ipairs(Space.probes) do
		P:update(dt)
	end
end

function love.keypressed(key, isrepest)
	if key == "escape" then
		love.event.quit()
	end
	
	if key == "f8" then
		screenshot()
	end
	
	Physics:keypressed(key, isrepeat)
end

function love.draw()
	local probe
	local Tx, Ty = 0, 0
	if #Space.probes >= 1 then
		probe = Space.probes[1]
		love.graphics.push()
		Tx, Ty = probe.x, probe.y
		love.graphics.translate(love.window.getWidth()/2 - probe.x, love.window.getHeight()/2 - probe.y)
	end
	
	local S = SpaceBG:getWidth()
	local _x = math.floor(Tx / S) * S
	local _y = math.floor(Ty / S) * S
	local _dx = Tx %S
	local _dy = Ty %S

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
		B:draw()
	end
	Particles:draw()
	-- Physics:draw()
	
	if #Space.probes >= 1 then
		love.graphics.pop()

		probe:drawUI()
	end
	
	love.graphics.print(string.format("%d;%d",_x,_y), 0, 8)
	love.graphics.print(string.format("%d;%d",Tx,Ty), 0, 0)
end