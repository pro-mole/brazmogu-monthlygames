-- Random selection functions

-- Select randomly from a table defined as value -> chance
-- Sum of chances does not have to be 1 or 100
function selectRandomly(T)
	local total = 0
	for v,c in pairs(T) do
		total = total + c
	end
	
	local k = math.random() * total
	for v,c in pairs(T) do
		if k < c then
			return v
		else
			k = k - c
		end
	end
	
	-- This should never happen
	return nil
end