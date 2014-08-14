require("inherit")
require("platform/engine")

player = nil

debug_on = false
debug_timer = 0
debug_interval = 1
function print_debug(...)
	if debug_on then
		print(os.date("[%Y-%m-%d %H:%M:%S]"), ...)
		io.stdout:flush();
	end
end

function love.load()
	player = Player.new(128, 480)
	Platform.new(80, 504, 32, 64)
	Platform.new(0, 568, 800, 32)
	Platform.new(512, 504, 128, 64)
	Platform.new(320, 480, 64, 32)
	Platform.new(384, 500, 64, 32)
	Platform.new(320, 468, 64, 64)
	
	Block.new(240, 480, 32, 32)
	
	print(player)
	print(Engine.Physics.gravity, math.cos(Engine.Physics.gravity_dir), math.sin(Engine.Physics.gravity_dir))
	for i,O in ipairs(Engine.Objects) do
		print(O, O.x, O.y, O.fixed, O.solid, O.visible)
	end
end

function love.keypressed(k, isrepeat)
	if k == "escape" then
		love.event.quit()
	end
	
	player:keypressed(k)
end

function love.update(dt)
	while dt > Engine.tick do
		love.update(Engine.tick)
		dt = dt - Engine.tick
		print("Correcting tick...")
	end
	
	if debug_on then
		debug_on = false
	end
	debug_timer = debug_timer + dt
	if debug_timer >= debug_interval then
		debug_timer = debug_timer - debug_interval
		debug_on = true
	end
	
	Engine.update(dt)
end

function love.draw()
	Engine.draw()
end