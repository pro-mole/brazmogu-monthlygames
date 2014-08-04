-- Collision routines
-- A subset of physics, but just dealing with one question: did X collide with Y?

-- Check collision between two objects
function checkCollision(A, B)
	for i,box1 in ipairs(A.bbox) do
		for j,box2 in ipairs(B.bbox) do
			if checkOverlap(box1, box2) then
				return true
			end
		end
	end
	
	return false
end

-- Check if bounding boxes overlap
function checkOverlap(Box1, Box2)
	return false
end