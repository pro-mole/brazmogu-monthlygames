-- Here's me trying my hand at doing a particle system

particles = {}

-- General workings of the particle system

-- Create a new particle of given type
function addParticle(_type, x, y, duration, ...)
	table.insert(particles, _type.new(x, y, duration, unpack{...}))
end

function particles:draw()
	for i,p in ipairs(particles) do
		p:draw()
	end
	self:update()
end

function particles:update()
	for i,p in ipairs(particles) do
		if p.duration <= 0 then
			table.remove(particles,i)
		end
	end
end

--[[ Particle type: fading sparks
For when the pixels are destroyed ]]
partSpark = {}
partSpark.__index = partSpark

function partSpark.new(x, y, duration, numSparks, color, avgSize)
	local P = {x=x, y=y, duration=duration, done=false, sparks={}}
	local numSparks = numSparks or 4

	print(string.format("PARTICLE: [%d;%d - %d, %d, (%x,%x,%x), %d]", P.x, P.y, P.duration, numSparks, color.r, color.g, color.b, avgSize))
	print (numSparks)
	for i=1,numSparks,1 do
		local spark = {x=x, y=y, size=avgSize or 4, color=color or {r=0xff, g=0xff, b=0xff}, alpha=128}
		spark.x = spark.x + love.math.random(-numSparks,numSparks)
		spark.y = spark.y + love.math.random(-numSparks,numSparks)
		spark.size = spark.size + love.math.random(-numSparks,numSparks)
		spark.direction = 360/numSparks*i + love.math.random(-90/numSparks,90/numSparks)
		spark.speed = love.math.random(1,numSparks)
		table.insert(P.sparks, spark)
	end
	
	return setmetatable(P, partSpark)
end

function partSpark:draw()
	for i,s in ipairs(self.sparks) do
		love.graphics.setColor(s.color.r, s.color.g, s.color.b, s.alpha)
		love.graphics.rectangle("fill", s.x - s.size/2, s.y - s.size/2, s.size, s.size)
		
		s.x = s.x + math.cos(math.rad(s.direction))*s.speed
		s.y = s.y + math.sin(math.rad(s.direction))*s.speed
		s.alpha = s.alpha - s.alpha/self.duration
	end
	
	self.duration = self.duration - 1
end

--[[ Particle type: flash area
For the "radius of death" effect]]
partFlash = {}
partFlash.__index = partFlash

function partFlash.new(x, y, duration, size, color)
	local P = {x=x, y=y, duration=duration, color=color or {r=0xff, g=0xff, b=0xff}, size=size, alpha=96}
	return setmetatable(P, partFlash)
end

function partFlash:draw()
	love.graphics.setColor(self.color.r, self.color.g, self.color.b, self.alpha/2)
	love.graphics.circle("fill", self.x, self.y, self.size, 128)
	love.graphics.setColor(self.color.r, self.color.g, self.color.b, self.alpha)
	love.graphics.circle("line", self.x, self.y, self.size, 128)
	self.alpha = self.alpha - self.alpha/self.duration
	self.duration = self.duration - 1
end