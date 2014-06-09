require("physics")

Space = {
	probes = {},
	planets = {},
	satellites = {},
	meteors = {},
	comets = {},
	stations = {}
}
require("probes")

debug_echo = false
debug_interval = 1

function print_debug(...)
	if debug_echo then
		print(...)
	end
end


function love.load()
	Probe.new({name = "Tiny", x = 32, y = 300, v = 0, dir = 0, mass = 0.01, size = 8, active = true})
	Body.new({name = "Big", x = 400, y = 300, v = 0, dir = 0, mass = 16, size = 32, fixed = true})
end

function love.update(dt)
	debug_interval = debug_interval - dt
	debug_echo = debug_interval <= 0
	
	Physics:update(dt)
	
	if debug_echo then 
		io.stdout:flush()
		debug_interval = 1
		debug_echo = false
	end
end

function love.keypressed(key, isrepest)
	Physics:keypressed(key, isrepeat)
end

function love.draw()
	for i,B in ipairs(Physics.bodies) do
		B:draw()
	end
	Physics:draw()
end