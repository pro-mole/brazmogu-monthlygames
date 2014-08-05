-- Platforming engine

Engine = {}
Engine.Objects = {} -- A list of the objects contained in the world

Engine.Physics = require("platform/physics")
require("platform/collision")

require("platform/level")
require("platform/player")
Engine.Camera = require("platform/camera")

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