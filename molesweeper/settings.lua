-- Global settings and data module
font = {}
sound = {}
bgm = {}
backdrop = {}
sprite = {}
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