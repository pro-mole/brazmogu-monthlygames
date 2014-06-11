require("physics")
require("draw")

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
	Body.new({name = "Station", x = 400, y = 684, v = 8, dir = 0, mass = 16, size = 16, class = 1})
	
	--Star.new({name = "Huge", x = 400, y = 300, v = 0, dir = 0, mass = 128, size = 64})
	--Planet.new({name = "Big1", x = 400, y = 300, v = 0, dir = 0, mass = 16, size = 32})
	--Planet.new({name = "Big2", x = 656, y = 300, v = 64, dir = math.rad(270), mass = 16, size = 32, atmosphere = {"oxygen", "hydrogen", "water"}, atmosphere_size = 64})
	
	-- Planetary System Test
	Planet.new({name = "Terra", x = 400, y = 300, v = 0, dir = 0, vrot = math.pi/16, mass = 1024, size = 64, atmosphere = {"oxygen", "hydrogen", "water"}, atmosphere_size = 128})
	Body.new({name = "Luna", x = 400, y = 44, v = 32/math.sqrt(2), dir = 0, vrot = -math.pi/32, mass = 128, size = 16, class = 2})
	Body.new({name = "Selene", x = 400, y = 812, v = 16, dir = 0, vrot = -math.pi/4, mass = 64, size = 24, class = 2})
end

function love.update(dt)
	debug_interval = debug_interval - dt
	debug_echo = debug_interval <= 0
	
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
	
	-- Radar
	Radar:clear()
	love.graphics.setCanvas(Radar)
	
	love.graphics.setColor(0,64,0,128)
	love.graphics.circle("fill", 64, 64, 64, 64)
	
	local scale = 1/8
	for i,B in ipairs(Physics.bodies) do
		local r, a = math.sqrt(squareBodyDistance(Space.probes[1], B))/8, bodyDirection(Space.probes[1], B)
		love.graphics.setColor(255,255,255,192)
		love.graphics.circle("fill", 64 + math.cos(a)*r, 64 + math.sin(a)*r, B.class+1, 4)
	end
	
	love.graphics.setColor(255,255,255,192)
	love.graphics.circle("line", 64, 64, 64, 64)
	
	love.graphics.setCanvas()
	love.graphics.draw(Radar, love.window.getWidth()-128, love.window.getHeight() - 128)
end