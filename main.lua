require("draw")
require("grid")
require("ai")

--Timers
input_delay = 0
AI_delay = 1

game_grid = {}

Sounds = {
	select = love.sound.newSoundData("assets/sound/Select.wav"),
	start = love.sound.newSoundData("assets/sound/Start.wav"),
	confirm = love.sound.newSoundData("assets/sound/Click OK.wav"),
	denied = love.sound.newSoundData("assets/sound/Click No.wav")
}

Players = {
	{
		id = "neutral",
		name = "None",
		color = {128,96,48,255},
		active = false, -- Active if the player is in the game
		AI = true, -- AI true for CPU player
		key = nil,
	},
	{
		id = "left",
		name = "Nature",
		color = {0,128,0,255},
		active = true,
		AI = false,
		key = "1",
	},
	{
		id = "right",
		name = "Industry",
		color = {128,128,128,255},
		active = true,
		AI = true,
		key = "2",
	},
	{
		id = "up",
		name = "Outsider",
		color = {128,0,64,255},
		active = true,
		AI = true,
		key = "3",
	},
	{
		id = "down",
		name = "Virus",
		color = {0,192,192,255},
		active = true,
		AI = true,
		key = "4",
	},
	current = "neutral",
	active = {},
	next = function(self)
		local c = 0
		for i,P in ipairs(self.active) do
			if P == self.current then
				c = i
			end
		end

		if c == #self.active or c == 0 then
			self.current = self.active[1]
		else
			self.current = self.active[c+1]
		end

		return self.current
	end
}
setmetatable(Players, {
	__index = function(t, k)
		if not rawget(t, k) then
			for i,P in ipairs(t) do
				if P.id == k then
					return P
				end
			end
			return nil
		else
			return rawget(t, k)
		end
	end
})

-- Map data stored in tables, later we load the minimap for them into the tables :P
Maps = {
	current = 1,
	next = function(self)
		if self.current == #self then
			self.current = 1
		else
			self.current = self.current + 1
		end
		return self.current
	end,
	prev = function(self)
		if self.current == 1 then
			self.current = #self
		else
			self.current = self.current - 1
		end
		return self.current
	end,
	process = function(self)
		local allmaps = love.filesystem.getDirectoryItems("maps")
		for i,file in ipairs(allmaps) do
			table.insert(self, {name = file})
		end
		for i,map in ipairs(self) do
			local grid = Grid.loadFile("maps/" .. map.name)
			local minimap = love.graphics.newCanvas(grid.width * 4, grid.height * 4)
			local players = {left = false, right = false, up = false, down = false}
			love.graphics.setCanvas(minimap)
			for x,y,T in grid:iterator() do
				if T.owner == "neutral" then
					if T.type == "normal" then
						love.graphics.setColor(unpack(Players["neutral"].color))
					else
						love.graphics.setColor(16,16,16,255)
					end
				else
					players[T.owner] = true
					love.graphics.setColor(unpack(Players[T.owner].color))
				end
				love.graphics.rectangle("fill", (x-1) * 4, (y-1) * 4, 4, 4)
			end
			love.graphics.setCanvas()
			
			map.minimap = minimap
			map.players = players
		end
	end
}

turn = {
	player = "neutral",
	pieces = 0
}

endgame = false

require("screen/main")
require("screen/index")

function love.load()
	love.graphics.setFont(font.standard)
	Maps:process()

	screens:push(screen_menu)
end

function love.update(dt)
	if input_delay > 0 then
		input_delay = input_delay - dt
	end
	
	screens:update(dt)
end

function love.keypressed(key, isrepeat)
	if input_delay > 0 then return end
	
	screens:keypressed(key, isrepeat)
	
	if key == "escape" then
		screens:push(screen_quit)
	end
end

function love.mousepressed(x, y, button)
	if input_delay > 0 then return end
	
	screens:mousepressed(x, y, button)
end

function love.draw()
	screens:draw()
end