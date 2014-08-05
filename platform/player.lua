-- Player Object Prototype

Player = {}

function Player.new(data)
	local P = setmetatable(Object.new(data), Player)
	P.speed = 80
	P.jump = 160
	P:addBoundingBox(0, 0, 16, 32)
	
	return P
end

function Player.__index(t,i)
	if rawget(t, i) == nil then
		if Player[i] == nil then
			return Object[i]
		else
			return Player[i]
		end
	else
		return rawget(t, i)
	end
end

function Player:keypressed(k)
	if k == " " then
		if not checkOffsetFree(self, 0, 1) then
			self.vspeed = -self.jump
		end
	end
end

function Player:update(dt)
	Object.update(self, dt)
	
	if love.keyboard.isDown("right") then
		self.hspeed = self.speed
	end
	
	if love.keyboard.isDown("left") then
		self.hspeed = -self.speed
	end
	
	if not(love.keyboard.isDown("right") or love.keyboard.isDown("left")) then
		self.hspeed = 0
	end
end