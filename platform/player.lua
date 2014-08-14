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
		fixed = false,
		name = "PLAYER"
	}
	
	local P = setmetatable(Object.new(data), Player)
	
	-- Class-specific data
	P.speed = 80
	P.jump = 160
	P:addBoundingBox(0, 0, 16, 32)
	
	return P
end

Player.__index = __inherit(Player, Object)
Player.__tostring = Object.__tostring

function Player:keypressed(k)
	if k == " " then
		if not self:checkOffsetFree(0, 1) then
			print "JUMP"
			self.vspeed = -self.jump
		end
	end
end

function Player:update(dt)
	print_debug(self.x, self.y)
	local others = self:getCollisions(false)

	if love.keyboard.isDown("right") then
		self.hspeed = self.speed
		print_debug("Check pushing to the right")
		for other in pairs(others) do
			print_debug(other, other.bbox:offsetObject(other))
			if not other.fixed and other.x > self.x then
				print_debug(string.format("Pushing %s", other))
				other.hspeed = self.speed/2
			end
		end
	end
	
	if love.keyboard.isDown("left") then
		self.hspeed = -self.speed
	end
	
	if not(love.keyboard.isDown("right") or love.keyboard.isDown("left")) then
		self.hspeed = 0
	end
	
	Object.update(self, dt)
end