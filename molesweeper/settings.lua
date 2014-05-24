-- Global settings and data module
font = {}
sound = {}
bgm = {}
backdrop = {}
spritesheet = {
	grid = love.graphics.newImage("assets/sprite/minefield.png")
}
sprite = {
	mole = love.graphics.newQuad(0,0,16,16,64,64),
	mine = love.graphics.newQuad(16,0,16,16,64,64),
	flag = love.graphics.newQuad(32,0,16,16,64,64),
	coppermoss = love.graphics.newQuad(0,16,16,16,64,64),
	ironcap = love.graphics.newQuad(16,16,16,16,64,64),
	goldendrop = love.graphics.newQuad(32,16,16,16,64,64)
}
challenge = {
	begins = false,
	level = 1,
	level_settings = {
		{9, 9, {5,9}, 4, "NO", "NO", "NO"} -- Level 1
	}
}
settings = {
	minefield = {
	width = 11,
	height = 11,
	start = {x = 8, y = 15},
	mines = 8,
	coppermoss = "NO",
	ironcap = "NO",
	goldendrop = "NO"
	}
}

function loadSetting(identifier)
	local pointer = settings
	for token in string.gmatch(identifier, "[a-z]+") do
		pointer = pointer[token]
		if pointer == nil then
			return nil
		end
	end

	return pointer
end

function saveSetting(identifier, val)
	local pointer = nil
	local item = nil
	for token in string.gmatch(identifier, "[a-z]+") do
		if item == nil then
			pointer = settings
		else
			pointer = pointer[item]
		end

		print(pointer)
		print(token)

		item = token
		if pointer == nil then
			return
		end
	end

	pointer[item]=val

	if pointer ~= nil then
		print(string.format("%s = %s", identifier, val))
		print(string.format("%s = %s", identifier, loadSetting(identifier)))
	end
end

function load(slot)
	settings.minefield.height = loadSetting("minefield.height")
end

function save(slot)
end