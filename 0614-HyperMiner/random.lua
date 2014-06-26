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

-- Normalize a probability array
-- Useful for getting percentages and such :D
function normalize(T, n)
	local N = n or 100
	local total = 0
	for v,c in pairs(T) do
		total = total + c
	end
	local r = n/total
	
	N = {}
	for v,c in pairs(T) do
		N[v] = c * r
	end
	
	return N
end

-- Normal Distribution with mean phi and variance sigma
-- Adding this to the math API
function math.randomNormal(phi, sigma)
	return phi + math.sqrt(-2 * math.log(math.random())) * math.cos(2 * math.pi * math.random()) * sigma
end