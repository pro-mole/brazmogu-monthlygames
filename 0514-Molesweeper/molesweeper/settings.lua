-- Global settings and data module
font = {}
sound = {}
bgm = {}
backdrop = {}
spritesheet = {
	grid = love.graphics.newImage("assets/sprite/minefield.png")
}
sprite = {
	dirt = love.graphics.newQuad(0,0,16,16,64,64),
	underdirt = love.graphics.newQuad(16,0,16,16,64,64),
	mole = love.graphics.newQuad(0,16,16,16,64,64),
	mine = love.graphics.newQuad(16,16,16,16,64,64),
	flag = love.graphics.newQuad(32,16,16,16,64,64),
	coppermoss = love.graphics.newQuad(0,32,16,16,64,64),
	ironcap = love.graphics.newQuad(16,32,16,16,64,64),
	goldendrop = love.graphics.newQuad(32,32,16,16,64,64)
}
challenge = {
	begins = false,
	level = 1,
	level_settings = {
		{width=9, height=9, start={5,9}, mines=4, coppermoss="NO", ironcap="NO", goldendrop="NO"}, -- Level 1
		{width=11, height=11, start={6,11}, mines=8, coppermoss="NO", ironcap="NO", goldendrop="NO"} -- Level 2
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
	},
	video = {
	fullscreen = "NO"
	},
	audio = {
	music = "ON",
	sound = "OFF"
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