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
	Probe.new({name = "Tiny", x = 400, y = 44, v = 4, dir = 0, mass = 0.01, size = 8, active = true})
	-- Space Station Test
	Body.new({name = "Station", x = 400, y = 300, v = 0, dir = 0, mass = 64, size = 16, class = 1})
	--Star.new({name = "Huge", x = 400, y = 300, v = 0, dir = 0, mass = 128, size = 64})
	--Planet.new({name = "Big1", x = 400, y = 300, v = 0, dir = 0, mass = 16, size = 32})
	--Planet.new({name = "Big2", x = 656, y = 300, v = 64, dir = math.rad(270), mass = 16, size = 32, atmosphere = {"oxygen", "hydrogen", "water"}, atmosphere_size = 64})
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
	for i,B in ipairs(Physics.bodies) do
		B:draw()
	end
	Physics:draw()
end