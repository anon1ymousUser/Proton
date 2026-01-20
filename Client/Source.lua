local Players = game:GetService("Players")
local player = Players.LocalPlayer

local ROOT = "Proton-main"
local BASE_URL = "https://raw.githubusercontent.com/anon1ymousUser/Proton/"
local commit = readfile(ROOT.."/Profiles/commit.txt")

local VALID_KEYS = {
	["check"] = true
}

-- getgenv().PROTON_KEY = "your-key-here"
local key = getgenv().PROTON_KEY

if not key or not VALID_KEYS[key] then
	player:Kick("Invalid Proton key.")
	delfolder("Proton-Main")
	return
end

print("[Proton] Key accepted:", key)

writefile(ROOT.."Profiles/DO_NOT_TOUCH_CONTAINS_KEY", key)

local loadstring = loadstring or load
if type(loadstring) ~= "function" then
	error("loadstring not supported")
end

local function requireFile(path)
	if not isfile(path) then
		local url = BASE_URL .. commit .. "/" .. path:gsub(ROOT.."/", "")
		local src = game:HttpGet(url, true)
		writefile(path, src)
	end

	local fn, err = loadstring(readfile(path))
	if not fn then
		error("Failed to load "..path..":\n"..tostring(err))
	end

	return fn()
end

local Proton = {}

-- Proton.Core = requireFile(ROOT.."/Libraries/Core.lua")
-- Proton.UI = requireFile(ROOT.."/Libraries/UI.lua")
-- Proton.Features = requireFile(ROOT.."/Libraries/Features.lua")

local gameScript = ROOT.."/Games/"..game.PlaceId..".lua"
if isfile(gameScript) then
	requireFile(gameScript)
else
	requireFile(ROOT.."/Games/universal.lua")
end
