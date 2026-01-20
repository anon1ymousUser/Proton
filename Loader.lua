if not game:IsLoaded() then
	game.Loaded:Wait()
end

local genv = getgenv and getgenv() or {}
if genv.ProtonLoaded then
	return
end

local isfile = isfile or function(file)
	local suc, res = pcall(function()
		return readfile(file)
	end)
	return suc and type(res) == "string" and #res > 0
end

local delfile = delfile or function(file)
	pcall(function()
		writefile(file, "")
	end)
end

local ROOT = "Proton-Main"
local BASE_URL = "https://raw.githubusercontent.com/anon1ymousUser/Proton/"
local WATERMARK = "-- Proton cache watermark (auto-removed on updates)\n"

local function ensureFolder(path)
	if not isfolder(path) then
		makefolder(path)
	end
end

local function downloadFile(path, url)
	local data = game:HttpGet(url, true)
	if path:find("%.lua") then
		data = WATERMARK .. data
	end
	writefile(path, data)
	return data
end

local function getFile(path, url)
	if not isfile(path) then
		return downloadFile(path, url)
	end
	return readfile(path)
end

local function wipeFolder(path)
	if not isfolder(path) then return end
	for _, file in listfiles(path) do
		if file:lower():find("loader") then continue end
		if isfile(file) then
			local src = readfile(file)
			if src:sub(1, #WATERMARK) == WATERMARK then
				delfile(file)
			end
		end
	end
end

for _, folder in {
	ROOT,
	ROOT.."/Client",
	ROOT.."/Games",
	ROOT.."/Assets",
	ROOT.."/Libraries",
	ROOT.."/Profiles"
} do
	ensureFolder(folder)
end

if not shared.ProtonDeveloper then
	local commit = "main"
	local suc, res = pcall(function()
		return game:HttpGet("https://github.com/anon1ymousUser/Proton", true)
	end)

	if suc then
		local idx = res:find("currentOid")
		if idx then
			local hash = res:sub(idx + 13, idx + 52)
			if #hash == 40 then
				commit = hash
			end
		end
	end

	local commitPath = ROOT.."/Profiles/commit.txt"
	if not isfile(commitPath) or readfile(commitPath) ~= commit then
		wipeFolder(ROOT)
		wipeFolder(ROOT.."/Client")
		wipeFolder(ROOT.."/Games")
		wipeFolder(ROOT.."/Libraries")
	end

	writefile(commitPath, commit)
end

local commit = isfile(ROOT.."/Profiles/commit.txt") and readfile(ROOT.."/Profiles/commit.txt") or "main"

local loaderSource = getFile(
	ROOT.."/Loader.lua",
	BASE_URL..commit.."/Loader.lua"
)

local clientSource = getFile(
	ROOT.."/Client/Source.lua",
	BASE_URL..commit.."/Client/Source.lua"
)

if not isfile(ROOT.."/Loader.lua") then
	downloadFile(ROOT.."/Loader.lua", BASE_URL..commit.."/Loader.lua")
end

if not isfile(ROOT.."/Client/Source.lua") then
	downloadFile(ROOT.."/Client/Source.lua", BASE_URL..commit.."/Client/Source.lua")
end

if queue_on_teleport then
	queue_on_teleport(loaderSource)
end

genv.ProtonLoaded = true
loadstring(clientSource)()

print("loader worked no errors")
