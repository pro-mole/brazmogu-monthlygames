-- Player Object Prototype

Player = {}

function Player.new(x,y)
	-- Create basic object
	data = {
		x = x,
		y = y,
		color = {0xff, 0x00, 0x00, 0xff},
		visible = true,
		solid = false,
		fixed = false
	}
	
	local P = setmetatable(Object.new(data), Player)
	
	-- Class-specific data
	P.speed = 80
	P.jump = 160
	P:addBoundingBox(0, 0, 16, 32)
	
	return P
end

Player.__index = __inherit(Player, Object)

function Player:keypressed(k)
	if k == " " then
		if not checkOffsetFree(self, 0, 1) then
			self.vspeed = -self.jump
		end
	end
end

function Player:update(dt)
	print_debug(self.x, self.y)
	
	if love.keyboard.isDown("right") then
		self.hspeed = self.speed
		local others = getOffsetCollisions(self, 1, 0)
		if #others > 0 then
			for i,other in ipairs(others) do
				if other.solid and not other.fixed then
					if checkOffsetFree(other, self.speed/2 * dt, 0) then
						other.x = other.x + self.speed*dt/2
					else
						other:moveUpTo(self.speed*dt/2, 0)
					end
					self:moveUpTo(self.speed*dt, 0)
				end
			end
		end
	end
	
	if love.keyboard.isDown("left") then
		self.hspeed = -self.speed
		local others = getOffsetCollisions(self, -1, 0)
		if #others > 0 then
			for i,other in ipairs(others) do
				if other.solid and not other.fixed then
					if checkOffsetFree(other, -self.speed/2 * dt, 0) then
						other.x = other.x - self.speed*dt/2
					else
						other:moveUpTo(-self.speed*dt/2, 0)
					end
					self:moveUpTo(-self.speed*dt, 0)
				end
			end
		end
	end
	
	if not(love.keyboard.isDown("right") or love.keyboard.isDown("left")) then
		self.hspeed = 0
	end
	
	Object.update(self, dt)
end