local Library = loadstring(game:HttpGet('https://raw.githubusercontent.com/Rain-Design/PPHUD/main/Library.lua'))()
local lplr = game.Players.LocalPlayer
local Window = Library:New({
    Name = "Cracs",
})

local Page = Window:Page({
    Name = "Player"
})

local Section = Page:Section({
    Name = "Movement",
    Fill = true,
    Side = "Left"
})


local walkchanger = Section:Slider({
    Name = "Speed",
    Min = 0,
    Max = 100,
    Default = 16,
    Callback = function(value)
        if lplr and lplr.Character and lplr.Character:FindFirstChild("Humanoid") then
            lplr.Character.Humanoid.WalkSpeed = value
        end
    end
})

local noclip
local phase = Section:Toggle({
    Name = "Noclip",
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
local antiafk = Section:Toggle({
    Name = "antiafk",
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
    Name = "Reset",
    callback = function(value)
        if lplr and lplr.Character then
            lplr.Character:BreakJoints()
        end
    end
})

Window:Initialize()
