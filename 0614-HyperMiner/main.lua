require("physics")
require("draw")
require("texture")

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
	Probe.new({name = "Probe", x = 0, y = 1024, v = 10, dir = math.rad(270), mass = 1, size = 8, active = true})
	
	-- Test environment
	-- A planetary system with two moons around it
	-- Also some asteroids and a comet
	Star.new({name = "Sol", x = 12148, y = 1024, v = 0, dir = 0, vrot = math.pi/8, mass = 1024, size = 1024,
		texture_params = { {"gradient", {144, 128, 0, 255}, {128, 32, 0, 255}, 100}, {"scatter", {255, 0, 0, 128}, 0.8} } })
		
	Planet.new({name = "Terra", x = 1024, y = 1024, v = 2, dir = math.rad(270), vrot = math.pi/8, mass = 128, size = 256, atmosphere = {H=0.1, O=0.6, H20=0.3}, atmosphere_size = 320,
		texture_params = { {"gradient", {64, 128, 144, 255}, {12, 64, 96, 255}, 50}, {"scatter", {0, 0, 128, 128}, 0.8}, {"blotch", {0, 64, 0, 204}, 8, 0.8} } })
		
	Satellite.new({name = "Luna", x = 1024, y = 1024 + 640, v = 10, dir = math.atan2(-2,14), vrot = -math.pi/16, mass = 24, size = 16,
		texture_params = { {"gradient", {128, 32, 32, 255}, {72, 0, 0, 255}, 32}, {"scatter", {0, 0, 0, 128}, 0.5} } })
	Satellite.new({name = "Selena", x = 64, y = 1024, v = 9.5, dir = math.rad(90), vrot = math.pi/64, mass = 48, size = 32,
		texture_params = { {"gradient", {192, 128, 144, 255}, {128, 108, 128, 255}, 50}, {"blotch", {64, 64, 64, 64}, 4, 0.8}, {"blotch", {0, 0, 64, 64}, 3, 0.9} } })

	-- Load all textures
	for k,v in pairs(Space) do
		for i = 1,#v do
			v[i]:loadTexture()
		end
	end
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
	
	local _x = math.floor(Tx / 1024) * 1024
	local _y = math.floor(Ty / 1024) * 1024

	love.graphics.draw(SpaceBG, _x-1024, _y-1024)
	love.graphics.draw(SpaceBG, _x, _y-1024)
	love.graphics.draw(SpaceBG, _x+1024, _y-1024)
	love.graphics.draw(SpaceBG, _x-1024, _y)
	love.graphics.draw(SpaceBG, _x, _y)
	love.graphics.draw(SpaceBG, _x+1024, _y)
	love.graphics.draw(SpaceBG, _x-1024, _y+1024)
	love.graphics.draw(SpaceBG, _x, _y+1024)
	love.graphics.draw(SpaceBG, _x+1024, _y+1024)

	for i,B in ipairs(Physics.bodies) do
		B:draw()
	end
	Physics:draw()
	
	if #Space.probes >= 1 then
		love.graphics.pop()

		drawRadar(Radar, probe, 1/16)
		drawNavWheel(NavWheel, probe)
		love.graphics.draw(Radar, love.window.getWidth()-132, love.window.getHeight() - 132)
		love.graphics.draw(NavWheel, 4, love.window.getHeight() - 132)

		drawSegMeter(144, love.window.getHeight() - 66, 128, 16, {128, 0, 0, 255}, {255, 0, 0, 255}, 10, probe.boost_power, "up")

		love.graphics.setFont(font.standard)
		drawMeter(218, love.window.getHeight() - 10, 128, 16, {0, 64, 96, 255}, {0, 192, 255, 255}, probe.max_energy, probe.energy, "right")
		love.graphics.printf("ENERGY:", 156, love.window.getHeight() - 28, 128, "left")
		drawMeter(218, love.window.getHeight() - 42, 128, 16, {128, 64, 0, 255}, {255, 192, 0, 255}, probe.max_fuel, probe.fuel, "right")
		love.graphics.printf("FUEL:", 156, love.window.getHeight() - 60, 128, "left")
		drawMeter(218, love.window.getHeight() - 74, 128, 16, {64, 128, 0, 255}, {192, 255, 0, 255}, probe.max_booster, probe.booster, "right")
		love.graphics.printf("BOOSTER:", 156, love.window.getHeight() - 92, 128, "left")
	end
end