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
function checkCollision(A, B)
	if A == B then return false end
	
	for i,box1 in ipairs(A.bbox) do
		for j,box2 in ipairs(B.bbox) do
			if checkOverlap(box1:offsetObject(A),box2:offsetObject(B)) then
				return true
			end
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

-- Check if object is free
function checkObjectFree(O)
	for i,other in ipairs(Engine.Objects) do
		if other ~= O and other.solid then
			if checkCollision(O, other) then
				return false
			end
		end
	end
	
	return true
end

-- Check if object O will be free at offset position
function checkOffsetFree(O, x, y)
	O.x = O.x + x
	O.y = O.y + y
	for i,other in ipairs(Engine.Objects) do
		if other ~= O and other.solid then
			if checkCollision(O, other) then
				O.x = O.x - x
				O.y = O.y - y
				return false
			end
		end
	end
	
	O.x = O.x - x
	O.y = O.y - y
	return true
end