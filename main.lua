require("platform/engine")

player = nil

function love.load()
	player = Player.new{
		x = 128,
		y = 480,
		color = {255,0,0,255},
		fixed = false,
		solid = false,
		visible = true
	}
	
	local floor = Object.new{
		x = 0,
		y = 568,
		color = {0,0,0,255},
		fixed = true,
		solid = true,
		visible = true
	}
	floor:addBoundingBox(0, 0, 800, 32)
	floor = Object.new{
		x = 480,
		y = 536,
		color = {0,0,0,255},
		fixed = true,
		solid = true,
		visible = true
	}
	floor:addBoundingBox(0, 0, 128, 32)
	
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
	Engine.update(dt)
end

function love.draw()
	Engine.draw()
end