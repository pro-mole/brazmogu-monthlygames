-- Class inheritance
-- An easy way of generating __index functions for class inheritance

function __inherit(...)
	local inherit_order = {...}
	return function(t,i)
		if rawget(t, i) ~= nil then
			return rawget(t,i)
		else
			for x,class in ipairs(inherit_order) do
				if rawget(class,i) ~= nil then
					return rawget(class,i)
				end
			end
			
			-- if not found at all, nil it is
			return nil
		end
	end
end