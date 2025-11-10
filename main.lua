local Library = loadstring(game:HttpGet('https://raw.githubusercontent.com/anon1ymousUser/Cracs-Roblox/refs/heads/main/lib.lua'))()
local lplr = game.Players.LocalPlayer
local Window = Library:Window({
	Text = "cracs",
})

local Tab = Window:Tab({
	Text = "Player"
})

local Section = Tab:Section({
	Text = "Movement",
	Side = "Left"
})


local walkchanger = Section:Slider({
	Text = "Speed",
	Minimum = 0,
	Maximum = 100,
	Default = 16,
	Postfix = "ws",
	Callback = function(value)
		if lplr and lplr.Character and lplr.Character:FindFirstChild("Humanoid") then
			lplr.Character.Humanoid.WalkSpeed = value
		end
	end
})

local noclip
local phase = Section:Check({
	Text = "Noclip",
	Default = false,
	Callback = function(value)
		if value then
			noclip = game:GetService('RunService').Stepped:Connect(function()
				if lplr and lplr.Character then
					for _, part in lplr.Character:GetDescendants() do
						if part:IsA("BasePart") and part.CanCollide then
							part.CanCollide = false
						end
					end
				end
			end)
		else
			if value == false and noclip then
				noclip:Disconnect()
			end
		end
	end
})


local antiafkconn
local antiafk = Section:Check({
	Text = "antiafk",
	Default = false,
	Callback = function(value)
		if value then
			if getconnections then
				for _,v in next, getconnections(lplr.Idled) do
					if v["Disable"] then
						v["Disable"](v)
					elseif v["Disconnect"] then
						v["Disconnect"](v)
					end
				end
			else
				antiafkconn = lplr.Idled:Connect(function()
					game:GetService("VirtualUser"):CaptureController()
					game:GetService("VirtualUser"):ClickButton2(Vector2.new())
				end)
			end
		else
			if value == false and antiafkconn then
				antiafkconn:Disconnect()
			end
		end
	end
})

local reset = Section:Button({
	Text = "Reset",
	Callback = function(value)
		if lplr and lplr.Character then
			lplr.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Dead)
			lplr.Character.Humanoid.Health = 0
		end
	end
})

Tab:Select()
