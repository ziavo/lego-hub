local owner = "ziavo"
local repository = "lego-hub"
local branch = "main"

local games = {
	[2533391464] = "snowman_simulator",
	[8158215689] = "smoothie_simulator",
	[5904328807] = "firework_simulator",
}

local function import(file)
    return loadstring(game:HttpGetAsync(("https://raw.githubusercontent.com/%s/%s/%s/%s.lua"):format(owner, repository, branch, file)))()
end
local function init()
	local file_name = games[game.PlaceId]
	if file_name then
		import("games/"..file_name)
	end
end
init()
