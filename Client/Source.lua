local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer

local ROOT = "Proton-main"
local BASE_URL = "https://raw.githubusercontent.com/anon1ymousUser/Proton/"
local commit = readfile(ROOT.."/Profiles/commit.txt")

local VALID_KEYS = {
    "check"
}

-- getgenv().PROTON_KEY = "your-key-here"
local key = getgenv().PROTON_KEY

if not key or not VALID_KEYS[key] then
	player:Kick("Invalid Proton key.")
	return
end

local function requireFile(path)
	if not isfile(path) then
		local url = BASE_URL .. commit .. "/" .. path:gsub(ROOT.."/", "")
		local src = game:HttpGet(url, true)
		writefile(path, src)
	end
	return loadstring(readfile(path))()
end

local Proton = {}

--Proton.Core = requireFile(ROOT.."/Libraries/Core.lua")
--Proton.UI = requireFile(ROOT.."/Libraries/UI.lua")
--Proton.Features = requireFile(ROOT.."/Libraries/Features.lua")

local gameScript = ROOT.."/Games/"..game.PlaceId..".lua"
if isfile(gameScript) then
	requireFile(gameScript)
else
	requireFile(ROOT.."/Games/universal.lua")
end

