-- AI scripts

AI = { grid = game_grid }

-- Get all tiles where the current player can move to
function AI.getAllAdjacentTiles(player)
	local P = player or turn.player
	local range = 1 + AI.grid.stats[P].towers

	local A = {}
	for x,y,T in AI.grid:iterator() do
		if T.owner == P then
			local adj = T:getAdjacents(range)
			for i,t in pairs(adj) do
				if t.owner ~= P and not A[t] then
					A[t] = true
					print(string.format("added %s", i))
				end
			end
		end
	end
	return A
end

function AI.selectTileRandomly(player)
	local P = player or turn.player
	local A = AI.getAllAdjacentTiles(P)

	local priority = {
		all = {},
		top = {},
		high = {},
		mid = {},
		low = {}
	}
	for T in pairs(A) do
		table.insert(priority.all, T)

		if T.owner ~= "neutral" then
			if T.type == "normal" then
				table.insert(priority.low, T)
			elseif T.type == "base" then
				table.insert(priority.high, T)
			elseif T.owner ~= "neutral" and T.type ~= "normal" then
				table.insert(priority.mid, T)
			end
		else
			if T.type == "base" then
				table.insert(priority.top, T)
			elseif T.type ~= "normal" then
				table.insert(priority.high, T)
			end
		end
	end

	local target_table
	if #priority.top > 0 then
		target_table = priority.top
	elseif #priority.high > 0 then
		target_table = priority.high
	elseif #priority.mid > 0 then
		target_table = priority.mid
	elseif #priority.low > 0 then
		target_table = priority.low
	else
		target_table = priority.all
	end
	print(target_table)

	return target_table[math.random(1,#target_table)]
end

function AI.takeMove(player)
	local P = player or turn.player

	local target = AI.selectTileRandomly(P)
	target:addOccupation(1,P)
	turn.pieces = turn.pieces - 1
	AI.grid:updateStats()
	table.insert(target.effects, {
		x = 0.5 * AI.grid.tile_width,
		y = 0.5 * AI.grid.tile_height,
		size = AI.grid.tile_width/4,
		speed = AI.grid.tile_height/2,
		dir = math.rad(270),
		color = Players[turn.player].color,
		alpha = 128,
		fade = 128,
		grow = AI.grid.tile_width,
		lifetime = 0.25,
	})
end