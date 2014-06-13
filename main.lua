require("physics")
require("draw")
require("texture")

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
require("planets")
require("stars")

debug_echo = false
debug_interval = 0

function print_debug(...)
	if debug_echo then
		print(...)
	end
end
 
function love.load()
	Probe.new({name = "Tiny", x = 400, y = 800, v = 0, dir = 0, mass = 1, size = 8, active = true})
	
	-- Space Station Test
	Body.new({name = "Station", x = 400, y = 1196, v = 8, dir = 0, mass = 16, size = 16, class = 1,
		texture = { {"gradient", {255,255,255,255}, {128,128,128,255}} } })
	
	--Star.new({name = "Huge", x = 400, y = 300, v = 0, dir = 0, mass = 128, size = 64})
	--Planet.new({name = "Big1", x = 400, y = 300, v = 0, dir = 0, mass = 16, size = 32})
	--Planet.new({name = "Big2", x = 656, y = 300, v = 64, dir = math.rad(270), mass = 16, size = 32, atmosphere = {"oxygen", "hydrogen", "water"}, atmosphere_size = 64})
	
	-- Planetary System Test
	Planet.new({name = "Terra", x = 400, y = 300, v = 0, dir = 0, vrot = math.pi/16, mass = 1024, size = 64, atmosphere = {"oxygen", "hydrogen", "water"}, atmosphere_size = 128,
		texture = { {"gradient", {0, 192, 255, 255}, {0, 96, 128, 255}}, {"scatter", {192, 144, 0, 204}, 0.8}} })
	Body.new({name = "Luna", x = 400, y = 44, v = 32/math.sqrt(2), dir = 0, vrot = -math.pi/32, mass = 128, size = 16, class = 2,
		texture = { {"solid", {192, 0, 0, 255}}, {"scatter", {0, 0, 0, 192}, 0.5}} })
	Body.new({name = "Selene", x = 400, y = 1324, v = 16, dir = 0, vrot = -math.pi/4, mass = 64, size = 24, class = 2,
		texture = { {"solid", {192, 144, 255, 255}}, {"blotch", {128, 102, 48, 64}, 3, 0.7}, {"blotch", {72, 64, 16, 64}, 7, 0.5}} })
end

function love.update(dt)
	debug_interval = debug_interval - dt
	--debug_echo = debug_interval <= 0
	
	Physics:update(dt)
	
	if debug_echo then 
		print(#Physics.bodies)
		io.stdout:flush()
		debug_interval = 1
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
	if #Space.probes >= 1 then
		local probe = Space.probes[1]
		love.graphics.push()
		love.graphics.translate(love.window.getWidth()/2 - probe.x, love.window.getHeight()/2 - probe.y)
	end
	
	for i,B in ipairs(Physics.bodies) do
		B:draw()
	end
	Physics:draw()
	
	if #Space.probes >= 1 then
		love.graphics.pop()
	end
	
	drawRadar(Radar, Space.probes[1], 1/16)
	love.graphics.draw(Radar, love.window.getWidth()-128, love.window.getHeight() - 128)
end