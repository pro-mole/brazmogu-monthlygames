require("physics")

debug_echo = false
debug_interval = 1

function love.load()
	Body.new({x = 32, y = 32, v = 8, dir = 0, mass = 1, size = 8})
	Body.new({x = 400, y = 300, v = 0, dir = 0, mass = 16, size = 32})
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

function love.draw()
	for i,B in ipairs(Physics.bodies) do
		B:draw()
	end
	Physics:draw()
end