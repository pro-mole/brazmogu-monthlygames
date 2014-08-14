-- Collision routines
-- A subset of physics, but just dealing with one question: did X collide with Y?

-- Bounding Box operations
BoundingBox = {}
BoundingBox.__index = BoundingBox

function BoundingBox.new(data)
	return setmetatable({
		x = data.x or 0,
		y = data.y or 0,
		w = data.w or 1,
		h = data.h or 1
	}, BoundingBox)
end

function BoundingBox:__tostring()
	return string.format("[[%f, %f, %f, %f]]", self.x, self.y, self.x+self.w, self.y+self.h)
end

function BoundingBox:offsetXY(x, y)
	local box = BoundingBox.new(self)
	box.x = box.x + x
	box.y = box.y + y
	return box
end

function BoundingBox:offsetObject(obj)
	return self:offsetXY(obj.x, obj.y)
end

-- Check collision between two objects
function checkCollision(A, B, touch)
	if A == B then return false end
	local touch = touch or false
	
	if checkOverlap(A.bbox:offsetObject(A),B.bbox:offsetObject(B)) then
		return true
	elseif touch then
		if checkTouch(A.bbox:offsetObject(A),B.bbox:offsetObject(B)) then
			return true
		end
	end
	
	return false
end

-- Check if bounding boxes overlap
function checkOverlap(Box1, Box2)
	if Box1.x + Box1.w < Box2.x or Box1.x > Box2.x + Box2.w or Box1.y + Box1.h < Box2.y or Box1.y > Box2.y + Box2.h then
		return false
	end
		
	return true
end

-- Check if bounding boxes touch
function checkTouch(Box1, Box2)
	if Box1.x + Box1.w == Box2.x or Box1.x == Box2.x + Box2.w or Box1.y + Box1.h == Box2.y or Box1.y == Box2.y + Box2.h then
		return false
	end
		
	return true
end
