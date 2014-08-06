-- Platforming engine

Engine = {}
Engine.Objects = {} -- A list of the objects contained in the world

Engine.Physics = require("platform/physics")
require("platform/collision")
Engine.Camera = require("platform/camera")

require("platform/level")
require("platform/player")
require("platform/platform")
require("platform/block")

Engine.tick = 1/24; -- Engine ideal tick, inverse of ideal FPS(for dealing with severe lag)

function Engine.update(dt)
	for i,obj in ipairs(Engine.Objects) do
		if not obj.fixed then
			obj:update(dt)
		end
	end
	
	for i=1,#Engine.Objects-1 do
		for j=i+1,#Engine.Objects do
			-- check collisions
		end
	end
end

function Engine.draw()
	love.graphics.setColor(Engine.Camera.background_color)
	love.graphics.rectangle("fill", 0, 0, love.window.getWidth(), love.window.getHeight())
	for i,obj in ipairs(Engine.Objects) do
		if obj.visible then
			obj:draw()
		end
	end
end