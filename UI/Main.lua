local api = {
	Tabs = {},
	CategoryHeaders = {},
	Keybind = {'RightShift'},
	Loaded = false,
	Modules = {},
	Config = {},
	Build = "1",
	Status = "Developer"
}

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local TextService = game:GetService("TextService")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local lplr = Players.LocalPlayer


local Config = {}
api.Config.CanSave = true
local FilePath = 'Proton/Configs/' .. game.PlaceId .. '.json'
function api.Config:Save_Config()
	if not api.Config.CanSave then
		return
	end
	if isfile(FilePath) then
		delfile(FilePath)
	end
	writefile(FilePath, HttpService:JSONEncode(Config))
end
function api.Config:Load_Config()
	if isfile(FilePath) then
		Config = HttpService:JSONDecode(readfile(FilePath))
	end
end

local color = {}
local THEME = {
	Main = Color3.fromRGB(27,28,27),
	Main2 = Color3.fromRGB(34,34,34),
	Accent = Color3.fromRGB(100,140,255),
	Text = Color3.fromRGB(255,255,255),
	Dim = Color3.fromRGB(150,150,150),
	Font = Font.fromEnum(Enum.Font.Gotham),
	FontBold = Font.fromEnum(Enum.Font.GothamBold)
}

local SIDEBAR = {Collapsed = 82, Expanded = 232, TweenTime = 0.17, TopMargin = 40, BottomMargin = 40}

local fontsize = Instance.new('GetTextBoundsParams')
fontsize.Width = math.huge
fontsize.Font = THEME.Font

local getfontsize = function(text, size, font)
	fontsize.Text = text
	fontsize.Size = size
	if typeof(font) == 'Font' then
		fontsize.Font = font
	end
	return TextService:GetTextBoundsAsync(fontsize)
end

local function addCorner(obj, r)
	local c = Instance.new("UICorner")
	c.CornerRadius = r or UDim.new(0,10)
	c.Parent = obj
	return c
end

function color.Dark(col, num)
	local h, s, v = col:ToHSV()
	return Color3.fromHSV(h, s, math.clamp(select(3, THEME.Main:ToHSV()) > 0.5 and v + num or v - num, 0, 1))
end

function color.Light(col, num)
	local h, s, v = col:ToHSV()
	return Color3.fromHSV(h, s, math.clamp(select(3, THEME.Main:ToHSV()) > 0.5 and v - num or v + num, 0, 1))
end

local MIN_WIDTH = 550
local MIN_HEIGHT = 450
local ICON_SIZE = 20
local PADDING_MIN = 1
local PADDING_MAX = 12
local START_HEIGHT = 520

local function makeResizableWithIcon(frame, sidebar, tabsList)
	local resizing = false
	local startMouse
	local startSize
	local startPos

	local icon = Instance.new("ImageButton")
	icon.Name = "ResizerIcon"
	icon.Size = UDim2.new(0, ICON_SIZE, 0, ICON_SIZE)
	icon.Position = UDim2.new(1, -ICON_SIZE, 1, -ICON_SIZE)
	icon.AnchorPoint = Vector2.new(0, 0)
	icon.BackgroundTransparency = 1
	icon.Image = "rbxassetid://96248178095850"
	icon.ZIndex = 2
	icon.Parent = frame

	icon.MouseEnter:Connect(function()
		icon.Size = UDim2.new(0, ICON_SIZE + 4, 0, ICON_SIZE + 4)
	end)
	icon.MouseLeave:Connect(function()
		if not resizing then
			icon.Size = UDim2.new(0, ICON_SIZE, 0, ICON_SIZE)
		end
	end)

	icon.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
		resizing = true
		startMouse = UserInputService:GetMouseLocation()
		startSize = frame.AbsoluteSize
		startPos = frame.Position
	end)

	icon.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			resizing = false
			icon.Size = UDim2.new(0, ICON_SIZE, 0, ICON_SIZE)
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if not resizing then return end
		if input.UserInputType ~= Enum.UserInputType.MouseMovement then return end

		local mouse = UserInputService:GetMouseLocation()
		local dx = mouse.X - startMouse.X
		local dy = mouse.Y - startMouse.Y

		local newW = math.max(MIN_WIDTH, startSize.X + dx * 2)
		local newH = math.max(MIN_HEIGHT, startSize.Y + dy * 2)

		frame.Size = UDim2.fromOffset(newW, newH)
		frame.Position = UDim2.new(
			startPos.X.Scale, startPos.X.Offset - (newW - startSize.X)/2,
			startPos.Y.Scale, startPos.Y.Offset - (newH - startSize.Y)/2
		)

		if sidebar then
			sidebar.Position = sidebar.Position
			sidebar.Size = sidebar.Size
		end

		if tabsList then
			local t = math.clamp((newH - MIN_HEIGHT) / (START_HEIGHT - MIN_HEIGHT), 0, 1)
			local padding = PADDING_MIN + (PADDING_MAX - PADDING_MIN) * t
			tabsList.Padding = UDim.new(0, padding)
		end
	end)
end

local screenGui = Instance.new("ScreenGui")
screenGui.ResetOnSpawn = false
screenGui.Parent = lplr:WaitForChild("PlayerGui")

local mainWindow = Instance.new("Frame")
mainWindow.Name = "MainWindow"
mainWindow.Size = UDim2.new(0, 600, 0, 520)
mainWindow.Position = UDim2.new(0.5, -300, 0.5, -260)
mainWindow.AnchorPoint = Vector2.new(0, 0)
mainWindow.BackgroundColor3 = THEME.Main
mainWindow.BorderSizePixel = 0
addCorner(mainWindow, UDim.new(0, 16))
mainWindow.Parent = screenGui

local mainfixer1 = Instance.new("Frame")
mainfixer1.Name = "SidebarFixerTop"
mainfixer1.BackgroundColor3 = THEME.Main
mainfixer1.Position = UDim2.new(0,0,0,0)
mainfixer1.Size = UDim2.new(0,15,0,15)
mainfixer1.BorderSizePixel = 0
mainfixer1.Parent = mainWindow

local mainfixer2 = Instance.new("Frame")
mainfixer2.Name = "SidebarFixerBottom"
mainfixer2.BackgroundColor3 = THEME.Main
mainfixer2.Position = UDim2.new(0,0,1,-15)
mainfixer2.Size = UDim2.new(0,15,0,15)
mainfixer2.BorderSizePixel = 0
mainfixer2.Parent = mainWindow

local contentArea = Instance.new("Frame")
contentArea.Name = "ContentArea"
contentArea.Size = UDim2.new(1, 0, 1, 0)
contentArea.Position = UDim2.new(0, 0, 0, 0)
contentArea.BackgroundTransparency = 1
contentArea.Parent = mainWindow

local sidebar = Instance.new("Frame")
sidebar.Name = "AttachedSidebar"
sidebar.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
sidebar.BackgroundTransparency = 0.22
sidebar.ZIndex = 0
sidebar.BorderSizePixel = 0
addCorner(sidebar, UDim.new(0, 12))
sidebar.Size = UDim2.new(0, 150, 0, mainWindow.Size.Y.Offset)
sidebar.Position = UDim2.new(0, 0, 0, mainWindow.Position.Y.Offset - 5)
sidebar.Parent = screenGui

local sidebarInner = Instance.new("Frame")
sidebarInner.Size = UDim2.new(1,0,1,0)
sidebarInner.BackgroundTransparency = 1
sidebarInner.Parent = sidebar

local logoHolder = Instance.new("Frame")
logoHolder.Size = UDim2.new(1,0,0,56)
logoHolder.Position = UDim2.new(0,0,0,0)
logoHolder.BackgroundTransparency = 1
logoHolder.Parent = sidebarInner

local logo = Instance.new("ImageButton")
logo.Size = UDim2.new(0,40,0,40)
logo.Position = UDim2.new(0.5,-25,0,8)
logo.BackgroundTransparency = 1
logo.Image = "rbxassetid://116068180860204"
logo.AutoButtonColor = false
logo.Parent = logoHolder

local tabsHolder = Instance.new("Frame")
tabsHolder.Size = UDim2.new(1,-13,1,-125)
tabsHolder.Position = UDim2.new(0,0,0,56)
tabsHolder.BackgroundTransparency = 1
tabsHolder.Parent = sidebarInner

local tabsList = Instance.new("UIListLayout")
tabsList.Parent = tabsHolder
tabsList.SortOrder = Enum.SortOrder.LayoutOrder
tabsList.FillDirection = Enum.FillDirection.Vertical
tabsList.HorizontalAlignment = Enum.HorizontalAlignment.Center
tabsList.Padding = UDim.new(0,8)

makeResizableWithIcon(mainWindow, sidebar, tabsList)

local userHolder = Instance.new("Frame")
userHolder.Size = UDim2.new(1,0,0,65)
userHolder.Position = UDim2.new(0,0,1,-65)
userHolder.BackgroundTransparency = 1
userHolder.Parent = sidebarInner

local userPanel = Instance.new("Frame")
userPanel.Size = UDim2.new(1,-16,1,-12)
userPanel.Position = UDim2.new(0,8,0,6)
userPanel.BackgroundColor3 = THEME.Main2
userPanel.BorderSizePixel = 0
userPanel.BackgroundTransparency = 1
addCorner(userPanel, UDim.new(0,12))
userPanel.Parent = userHolder

local pfp = Instance.new("ImageLabel")
pfp.Size = UDim2.new(0,36,0,36)
pfp.Position = UDim2.new(0,10,0,10)
pfp.BackgroundColor3 = THEME.Main
pfp.BackgroundTransparency = 1
pfp.Image = "https://www.roblox.com/headshot-thumbnail/image?userId="..lplr.UserId.."&width=420&height=420&format=png"
addCorner(pfp, UDim.new(1,0))
pfp.Parent = userPanel

local userLabel = Instance.new("TextLabel")
userLabel.Size = UDim2.new(1,-60,0,20)
userLabel.Position = UDim2.new(0,56,0,12)
userLabel.BackgroundTransparency = 1
userLabel.FontFace = THEME.Font
userLabel.TextSize = 14
userLabel.TextColor3 = THEME.Text
userLabel.TextXAlignment = Enum.TextXAlignment.Left
userLabel.Text = lplr.Name
userLabel.Parent = userPanel
userLabel.Visible = false

local roleLabel = Instance.new("TextLabel")
roleLabel.Size = UDim2.new(1,-60,0,16)
roleLabel.Position = UDim2.new(0,56,0,34)
roleLabel.BackgroundTransparency = 1
roleLabel.FontFace = THEME.Font
roleLabel.TextSize = 12
roleLabel.TextColor3 = THEME.Dim
roleLabel.TextXAlignment = Enum.TextXAlignment.Left
roleLabel.Text = api.Status
roleLabel.Parent = userPanel
roleLabel.Visible = false

local function getMainAbsolute()
	local cam = Workspace.CurrentCamera
	local vw, vh = cam.ViewportSize.X, cam.ViewportSize.Y
	local px = mainWindow.Position.X.Scale * vw + mainWindow.Position.X.Offset
	local py = mainWindow.Position.Y.Scale * vh + mainWindow.Position.Y.Offset
	local w = mainWindow.Size.X.Offset
	local h = mainWindow.Size.Y.Offset
	return px, py, w, h
end

local SIDEBAR_UNDERLAP_OFFSET = 12 

local function updateSidebarInstant(width)
	local px, py, w, h = getMainAbsolute()
	local leftAbs = px - width + SIDEBAR_UNDERLAP_OFFSET
	sidebar.Position = UDim2.new(0, leftAbs, 0, py - 28)
	sidebar.Size = UDim2.new(0, width, 0, h)
end

local function tweenSidebar(width)
	local px, py, w, h = getMainAbsolute()
	local leftAbs = px - width + SIDEBAR_UNDERLAP_OFFSET
	local targetPos = UDim2.new(0, leftAbs, 0, py - 28)
	local targetSize = UDim2.new(0, width, 0, h)
	TweenService:Create(sidebar, TweenInfo.new(SIDEBAR.TweenTime, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
		Position = targetPos,
		Size = targetSize
	}):Play()
end

RunService.Heartbeat:Wait()
updateSidebarInstant(SIDEBAR.Collapsed)


RunService.Heartbeat:Wait()
updateSidebarInstant(SIDEBAR.Collapsed)

Workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
	updateSidebarInstant(sidebar.Size.X.Offset)
end)
mainWindow:GetPropertyChangedSignal("Position"):Connect(function()
	updateSidebarInstant(sidebar.Size.X.Offset)
end)
mainWindow:GetPropertyChangedSignal("Size"):Connect(function()
	updateSidebarInstant(sidebar.Size.X.Offset)
end)

local labelsVisible = false
local pinned = false
local selectedTab = nil

local function applyLabelAlignment()
	for _,child in ipairs(tabsHolder:GetChildren()) do
		if child:IsA("Frame") and child:FindFirstChild("Label") then
			local lbl = child.Label
			if labelsVisible then
				lbl.TextXAlignment = Enum.TextXAlignment.Left
				lbl.Position = UDim2.new(0,48,0,0)
			else
				lbl.TextXAlignment = Enum.TextXAlignment.Center
				lbl.Position = UDim2.new(0,0,0,0)
			end
		end
	end
end

local function setAllLabels(v)
	for _,child in ipairs(tabsHolder:GetChildren()) do
		if child:IsA("Frame") and child:FindFirstChild("Label") then
			child.Label.Visible = v
		end
	end
	userLabel.Visible = v
	roleLabel.Visible = v
	labelsVisible = v
	applyLabelAlignment()
end

local function expand()
	if labelsVisible then return end
	tweenSidebar(SIDEBAR.Expanded)

	delay(SIDEBAR.TweenTime * 0.55, function()
		setAllLabels(true)

		for _, h in ipairs(api.CategoryHeaders) do
			local lbl = h:FindFirstChild("HeaderText")
			local line = h:FindFirstChild("HeaderLine")

			if lbl then lbl.Visible = true end
			if line then
				line.Visible = true
				line.Size = UDim2.new(0, 0, 0, 1)

				task.wait()
				local maxWidth = h.AbsoluteSize.X - (lbl.TextBounds.X + 30)

				TweenService:Create(
					line,
					TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
					{ Size = UDim2.new(0, maxWidth, 0, 1) }
				):Play()
			end
		end
	end)
end

local function collapse()
	if pinned then return end
	if not labelsVisible then return end

	setAllLabels(false)
	tweenSidebar(SIDEBAR.Collapsed)

	for _, h in ipairs(api.CategoryHeaders) do
		local lbl = h:FindFirstChild("HeaderText")
		local line = h:FindFirstChild("HeaderLine")

		if lbl then lbl.Visible = false end
		if line then
			line.Visible = false
			line.Size = UDim2.new(0, 0, 0, 1)
		end
	end
end

sidebar.MouseLeave:Connect(collapse)

local draggingMain = false
local dragStart = Vector2.zero
local mainStart = mainWindow.Position

logo.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		draggingMain = true
		dragStart = input.Position
		mainStart = mainWindow.Position
		UserInputService.MouseBehavior = Enum.MouseBehavior.Default
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if draggingMain and input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - dragStart
		mainWindow.Position = UDim2.new(
			mainStart.X.Scale,
			mainStart.X.Offset + delta.X,
			mainStart.Y.Scale,
			mainStart.Y.Offset + delta.Y
		)
		updateSidebarInstant(sidebar.Size.X.Offset)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		draggingMain = false
	end
end)


local function createCategoryHeader(text)
	local header = Instance.new("Frame")
	header.Name = text .. "Header"
	header.Size = UDim2.new(1, -20, 0, 22)
	header.BackgroundTransparency = 1
	header.Parent = tabsHolder

	local lbl = Instance.new("TextLabel")
	lbl.Name = "HeaderText"
	lbl.AnchorPoint = Vector2.new(0.5, 0.5)
	lbl.Position = UDim2.new(0.1, 0, 0.5, 0)
	lbl.Size = UDim2.new(0, 0, 1, 0)
	lbl.BackgroundTransparency = 1
	lbl.Visible = false
	lbl.Text = text
	lbl.FontFace = THEME.Font
	lbl.TextColor3 = THEME.Accent
	lbl.TextSize = 14
	lbl.Parent = header

	local line = Instance.new("Frame")
	line.Name = "HeaderLine"
	line.AnchorPoint = Vector2.new(0, 0.5)
	line.Position = UDim2.new(0.15, lbl.TextBounds.X/2 + 10, 0.5, 1)
	line.Size = UDim2.new(0, 0, 0, 1)
	line.BackgroundColor3 = THEME.Accent
	line.Visible = false
	line.BackgroundTransparency = 0.35
	line.BorderSizePixel = 0
	line.Parent = header

	local function playGrow()
		local maxWidth = header.AbsoluteSize.X - (lbl.TextBounds.X + 30)
		TweenService:Create(
			line,
			TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
			{ Size = UDim2.new(0, maxWidth, 0, 1) }
		):Play()
	end

	local function resetLine()
		line.Size = UDim2.new(0, 0, 0, 1)
	end


	if sidebar then
		sidebar.MouseEnter:Connect(function()
			task.wait(0.15)
			playGrow()
		end)

		sidebar.MouseLeave:Connect(resetLine)
	end

	table.insert(api.CategoryHeaders, header)
	return header
end


local function ensureSelector()
	local selector = sidebar:FindFirstChild("Selector")
	if selector then return selector end

	selector = Instance.new("Frame")
	selector.Name = "Selector"
	selector.Size = UDim2.new(0,4,0,30)
	selector.BackgroundColor3 = THEME.Accent
	selector.BorderSizePixel = 0
	selector.Position = UDim2.new(1,-16,0,0)
	selector.AnchorPoint = Vector2.new(0,0)
	selector.Parent = sidebar
	addCorner(selector, UDim.new(0,15))

	local selectorfixer = Instance.new("Frame")
	selectorfixer.Name = "SelectorFixer"
	selectorfixer.Size = UDim2.new(0,1,0,30)
	selectorfixer.BackgroundColor3 = THEME.Accent
	selectorfixer.BorderSizePixel = 0
	selectorfixer.Position = UDim2.new(1,-1,0,0)
	selectorfixer.AnchorPoint = Vector2.new(0,0)
	selectorfixer.Parent = selector

	return selector
end

api.Config:Load_Config()

function api:CreateTab(tabsettings)
	tabsettings = tabsettings or {}
	local tabapi = {
		Name = tabsettings.Name,
		Icon = tabsettings.Icon
	}

	local btn = Instance.new("Frame")
	btn.Size = UDim2.new(1, -25, 0, 44)
	btn.BackgroundColor3 = THEME.Main2
	btn.BackgroundTransparency = 1
	btn.BorderSizePixel = 0
	addCorner(btn, UDim.new(0, 10))
	btn.Parent = tabsHolder

	local img = Instance.new("ImageLabel")
	img.Size = UDim2.new(0, 26, 0, 26)
	img.Position = UDim2.new(0, 9, 0.5, -13)
	img.BackgroundTransparency = 1
	img.Image = tabsettings.Icon or ""
	img.Parent = btn

	local lbl = Instance.new("TextLabel")
	lbl.Name = "Label"
	lbl.Size = UDim2.new(1, -56, 1, 0)
	lbl.Position = UDim2.new(0, 48, 0, 0)
	lbl.BackgroundTransparency = 1
	lbl.FontFace = THEME.Font
	lbl.TextSize = 15
	lbl.TextColor3 = THEME.Text
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Text = tabsettings.Name or ""
	lbl.Parent = btn
	lbl.Visible = false

	local page = Instance.new("Frame")
	page.Size = UDim2.new(1, -15, 1, -15)
	page.BackgroundColor3 = THEME.Main
	page.Position = UDim2.new(0, 15, 0, 15)
	page.BorderSizePixel = 0
	addCorner(page, UDim.new(0, 12))
	page.Visible = false
	page.Parent = contentArea
	page.Name = (tabsettings.Name or "Tab") .. "_Page"

	local columnsHolder = Instance.new("Frame")
	columnsHolder.Name = "ColumnsHolder"
	columnsHolder.BackgroundTransparency = 1
	columnsHolder.Size = UDim2.new(1, -10, 1, -10)
	columnsHolder.Position = UDim2.new(0, 5, 0, 5)
	columnsHolder.Parent = page

	local leftColumn = Instance.new("Frame")
	leftColumn.Name = "LeftColumn"
	leftColumn.BackgroundTransparency = 1
	leftColumn.Size = UDim2.new(0.5, -5, 1, 0)
	leftColumn.Position = UDim2.new(0, 0, 0, 0)
	leftColumn.Parent = columnsHolder

	local rightColumn = Instance.new("Frame")
	rightColumn.Name = "RightColumn"
	rightColumn.BackgroundTransparency = 1
	rightColumn.Size = UDim2.new(0.5, -5, 1, 0)
	rightColumn.Position = UDim2.new(0.5, 10, 0, 0)
	rightColumn.Parent = columnsHolder


	local leftLayout = Instance.new("UIListLayout")
	leftLayout.SortOrder = Enum.SortOrder.LayoutOrder
	leftLayout.Padding = UDim.new(0, 10)
	leftLayout.Parent = leftColumn

	local rightLayout = Instance.new("UIListLayout")
	rightLayout.SortOrder = Enum.SortOrder.LayoutOrder
	rightLayout.Padding = UDim.new(0, 10)
	rightLayout.Parent = rightColumn

	api.Tabs = api.Tabs or {}
	tabapi.Modules = {}

	local selector = ensureSelector()

	local function placeModuleInShortestColumn(frame)
		local leftY = leftColumn.AbsoluteSize.Y
		local rightY = rightColumn.AbsoluteSize.Y
		if leftY <= rightY then
			frame.Parent = leftColumn
		else
			frame.Parent = rightColumn
		end
	end

	local function activateTab()
		for _, c in ipairs(contentArea:GetChildren()) do
			if c:IsA("Frame") and c ~= page then
				TweenService:Create(c, TweenInfo.new(0.15), {BackgroundTransparency = 1}):Play()
				c.Visible = false
			end
		end

		page.BackgroundTransparency = 1
		page.Visible = true
		TweenService:Create(page, TweenInfo.new(0.15), {BackgroundTransparency = 0}):Play()

		for _, tab in pairs(api.Tabs) do
			if tab.Button then
				TweenService:Create(tab.Button, TweenInfo.new(0.12), {BackgroundTransparency = 1}):Play()
				if tab.DefaultIcon and tab.Image then
					tab.Image.Image = tab.DefaultIcon
				end
			end
		end

		TweenService:Create(btn, TweenInfo.new(0.12), {BackgroundTransparency = 0.4}):Play()
		if tabsettings.ActiveIcon then img.Image = tabsettings.ActiveIcon end

		selectedTab = {Button = btn, Page = page}
		local tabAbsPos = btn.AbsolutePosition.Y - sidebar.AbsolutePosition.Y
		local tabHeight = btn.AbsoluteSize.Y
		local targetY = tabAbsPos + (tabHeight - selector.Size.Y.Offset)/2
		TweenService:Create(selector, TweenInfo.new(0.12, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
			Position = UDim2.new(1, -16, 0, targetY)
		}):Play()
	end

	btn.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 then
			activateTab()
		end
	end)
	btn.MouseEnter:Connect(expand)
	sidebar.MouseEnter:Connect(expand)

	if tabsettings.Name == "Home" then
		task.defer(activateTab)
	end

	function tabapi:CreateModule(modulesettings)
		modulesettings = modulesettings or {}
		local moduleapi = {
			Name = modulesettings.Name or "Module",
			Enabled = modulesettings.Enabled,
			KeyBind = "None",
			Listening = false,
			Connections = {}
		}

		if Config[moduleapi.Name] == nil then
			Config[moduleapi.Name] = {Enabled = false, Keybind = "none", Toggles = {}, Dropdowns = {}, Sliders = {}, ColorSliders = {}}
		end

		local modulebkg = Instance.new("Frame")
		modulebkg.Name = (modulesettings.Name or "Module") .. "_Module"
		modulebkg.Size = UDim2.new(1, 0, 0, 0)
		modulebkg.BackgroundColor3 = color.Light(THEME.Main2, 0.034)
		modulebkg.BorderSizePixel = 0
		addCorner(modulebkg, UDim.new(0, 9))

		local mod = Instance.new("Frame")
		mod.Name = moduleapi.Name
		mod.Size = UDim2.new(1, -2, 0, 0)
		mod.Position = UDim2.fromOffset(1, 1)
		mod.BackgroundColor3 = THEME.Main2
		mod.BorderSizePixel = 0
		addCorner(mod, UDim.new(0, 9))
		mod.Parent = modulebkg

		local title = Instance.new("TextLabel")
		title.Name = moduleapi.Name .. "_Title"
		title.Size = UDim2.new(0.6, 0, 0, 20)
		title.Position = UDim2.fromOffset(7, 7)
		title.BackgroundTransparency = 1
		title.Text = modulesettings.Name or "Module Title"
		title.FontFace = THEME.FontBold
		title.TextColor3 = THEME.Text
		title.TextSize = 14
		title.TextXAlignment = Enum.TextXAlignment.Left
		title.TextYAlignment = Enum.TextYAlignment.Top
		title.Parent = mod

		local desc = Instance.new("TextLabel")
		desc.Name = moduleapi.Name .. "_Description"
		desc.Size = UDim2.new(1, -20, 0, 14)
		desc.Position = UDim2.new(0, 7, 0, 27)
		desc.BackgroundTransparency = 1
		desc.Text = modulesettings.Description or ""
		desc.TextColor3 = color.Dark(THEME.Text, 0.34)
		desc.FontFace = THEME.Font
		desc.TextSize = 14
		desc.TextXAlignment = Enum.TextXAlignment.Left
		desc.Parent = mod

		local togglebkg = Instance.new("Frame")
		togglebkg.Name = modulesettings.Name .. "_ModuleToggleBkg"
		togglebkg.Size = UDim2.fromOffset(44, 22)
		togglebkg.Position = UDim2.new(1, -50, 0, 5)
		togglebkg.BackgroundColor3 = color.Light(THEME.Main2, 0.076)
		togglebkg.Parent = mod
		addCorner(togglebkg, UDim.new(0, 15))

		local togglemain = Instance.new("Frame")
		togglemain.Name = 'ToggleBG'
		togglemain.Size = UDim2.fromOffset(42, 20)
		togglemain.Position = UDim2.fromOffset(1, 1)
		togglemain.BackgroundColor3 = color.Light(THEME.Main2, 0.064)
		togglemain.Parent = togglebkg
		addCorner(togglemain, UDim.new(0, 15))

		local knob = Instance.new("Frame")
		knob.Name = "Knob"
		knob.Size = UDim2.fromOffset(12,12)
		knob.Position = UDim2.fromOffset(4, 4)
		knob.BackgroundColor3 = THEME.Text
		knob.Parent = togglemain
		addCorner(knob, UDim.new(1, 0))

		local toggleButton = Instance.new("TextButton")
		toggleButton.Name = "ToggleButton"
		toggleButton.Size = togglebkg.Size
		toggleButton.Position = togglebkg.Position
		toggleButton.Text = ""
		toggleButton.BackgroundTransparency = 1
		toggleButton.Parent = mod
		toggleButton.ZIndex = 50

		modulesettings.Function = modulesettings.Function or function() end

		function moduleapi:Toggle()
			self.Enabled = not self.Enabled
			moduleapi.Enabled = self.Enabled
			local goalPos = self.Enabled and UDim2.fromOffset(45-18, 4) or UDim2.fromOffset(3, 4)
			local bgColor = self.Enabled and THEME.Accent or color.Light(THEME.Main2, 0.064)
			TweenService:Create(knob, TweenInfo.new(0.17, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
				Position = goalPos
			}):Play()
			TweenService:Create(togglemain, TweenInfo.new(0.17), {
				BackgroundColor3 = bgColor
			}):Play()
			task.spawn(modulesettings.Function, self.Enabled)
			if not self.Enabled and self.Connections then
				for _, v in self.Connections do
					v:Disconnect()
				    end
                end
				table.clear(self.Connections)
				Config[moduleapi.Name].Enabled = moduleapi.Enabled
				task.delay(0.01, function() api.Config:Save_Config() end)
		    end

		toggleButton.MouseButton1Click:Connect(function() 
            moduleapi:Toggle()
        end)

		local keyButton = Instance.new("TextButton")
		keyButton.Name = "KeyButton"
		keyButton.Size = UDim2.fromOffset(55, 20)
		keyButton.BackgroundColor3 = color.Light(THEME.Main2, 0.064)
		keyButton.Text = ""
		keyButton.AutoButtonColor = false
		keyButton.Parent = mod
		addCorner(keyButton, UDim.new(0, 6))

		local keyLabel = Instance.new("TextLabel")
		keyLabel.BackgroundTransparency = 1
		keyLabel.FontFace = THEME.FontBold
		keyLabel.TextColor3 = THEME.Text
		keyLabel.TextSize = 13
		keyLabel.Text = moduleapi.KeyBind
		keyLabel.Size = UDim2.new(1, 0, 1, 0)
		keyLabel.Parent = keyButton

		local function updateKeyButtonPosition()
			keyButton.Position = UDim2.new(1, -(togglemain.AbsoluteSize.X + keyButton.AbsoluteSize.X + 15), 0, 5)
		end

		local function resizeKeyButton()
			local text = keyLabel.Text
			local size = getfontsize(text, 13, THEME.FontBold)
			keyButton.Size = UDim2.fromOffset(size.X + 14, 20)
			updateKeyButtonPosition()
		end
		resizeKeyButton()

		keyButton.MouseButton1Click:Connect(function()
			if moduleapi.Listening then return end
			moduleapi.Listening = true
			keyLabel.Text = "Press Anything..."
			resizeKeyButton()
		end)

	UserInputService.InputBegan:Connect(function(input, gpe)
    if not moduleapi.Listening then return end
    if gpe then return end

    if input.UserInputType == Enum.UserInputType.Keyboard then
        local newKey = input.KeyCode.Name

        if moduleapi.KeyBind == newKey then
            moduleapi.KeyBind = "None"
            keyLabel.Text = "None"
        else
            moduleapi.KeyBind = newKey
            keyLabel.Text = newKey
        end

        moduleapi.Listening = false
        resizeKeyButton()

        Config[moduleapi.Name].Keybind = moduleapi.KeyBind
        task.delay(0.01, function()
            api.Config:Save_Config()
        end)
    end
end)

    UserInputService.InputBegan:Connect(function(input, gpe)
	     if gpe then return end
         if moduleapi.Listening then return end
	        if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
	    if input.KeyCode.Name == moduleapi.KeyBind and moduleapi.KeyBind ~= "None" then
		moduleapi:Toggle()
	end
end)

local saved = Config[moduleapi.Name]

    if saved.Keybind and saved.Keybind ~= "none" then
	    moduleapi.KeyBind = saved.Keybind
	    keyLabel.Text = saved.Keybind
	    resizeKeyButton()
    end

    if saved.Enabled == true then
	    moduleapi.Enabled = false
	    moduleapi:Toggle()
    end

		local controlsHolder = Instance.new("Frame")
		controlsHolder.Name = modulesettings.Name .. "_Controls"
		controlsHolder.Size = UDim2.new(1, -14, 0, 0)
		controlsHolder.Position = UDim2.fromOffset(7, 47)
		controlsHolder.BackgroundTransparency = 1
		controlsHolder.Parent = mod
		controlsHolder.AutomaticSize = Enum.AutomaticSize.Y

		local controlsPadding = Instance.new("UIPadding")
		controlsPadding.PaddingTop = UDim.new(0, 6)
		controlsPadding.PaddingBottom = UDim.new(0, 6)
		controlsPadding.PaddingLeft = UDim.new(0, 6)
		controlsPadding.PaddingRight = UDim.new(0, 6)
		controlsPadding.Parent = controlsHolder

		local controlsLayout = Instance.new("UIListLayout")
		controlsLayout.SortOrder = Enum.SortOrder.LayoutOrder
		controlsLayout.Padding = UDim.new(0, 6)
		controlsLayout.Parent = controlsHolder

		mod.AutomaticSize = Enum.AutomaticSize.Y
		modulebkg.AutomaticSize = Enum.AutomaticSize.Y

		local function makeSignal()
			local listeners = {}
			return {
				Connect = function(_, fn) table.insert(listeners, fn); return {Disconnect = function() for i,v in ipairs(listeners) do if v==fn then table.remove(listeners,i); break end end end} end,
				Fire = function(_, ...) for _, fn in ipairs(listeners) do task.spawn(fn, ...) end end
			}
		end

		local function createRow(name, height)
			local row = Instance.new("Frame")
			row.Name = name and name or "Row"
			row.Size = UDim2.new(1, 0, 0, height or 28)
			row.BackgroundTransparency = 1
			row.LayoutOrder = #controlsHolder:GetChildren() + 1
			row.Parent = controlsHolder
			return row
		end

		function moduleapi:CreateSlider(slidersettings)
			local sliderapi = {
				Name = slidersettings.Name,
				Value = slidersettings.Value
			}
			
			if Config[moduleapi.Name].Sliders[sliderapi.Name] == nil then
				Config[moduleapi.Name].Sliders[sliderapi.Name] = {Value = slidersettings.Default}
			end

			local row = createRow(slidersettings.Name, 38)

			local label = Instance.new("TextLabel")
			label.Size = UDim2.new(0.45, 0, 0, 16)
			label.Position = UDim2.new(0, 0, 0, 2)
			label.BackgroundTransparency = 1
			label.FontFace = THEME.FontBold
			label.TextColor3 = THEME.Text
			label.TextSize = 13
			label.Text = slidersettings.Name
			label.TextXAlignment = Enum.TextXAlignment.Left
			label.Parent = row
			local valueBox = Instance.new("TextBox")
			valueBox.Size = UDim2.new(0.2, 0, 0, 16)
			valueBox.Position = UDim2.new(0.8, -2, 0, 2)
			valueBox.BackgroundColor3 = color.Light(THEME.Main2, 0.064)
			valueBox.FontFace = THEME.FontBold
			valueBox.BackgroundTransparency = 1
			valueBox.TextColor3 = THEME.Text
			valueBox.TextSize = 13
			valueBox.Text = tostring(slidersettings.Default)
			valueBox.ClearTextOnFocus = false
			valueBox.TextXAlignment = Enum.TextXAlignment.Right
			valueBox.Parent = row
			addCorner(valueBox, UDim.new(0, 4))
			local sliderBkg = Instance.new("Frame")
			sliderBkg.Size = UDim2.new(1, -6, 0, 8)
			sliderBkg.Position = UDim2.new(0, 3, 0, 26)
			sliderBkg.BackgroundColor3 = color.Light(THEME.Main2, 0.064)
			sliderBkg.Parent = row
			addCorner(sliderBkg, UDim.new(0, 6))
			local fill = Instance.new("Frame")
			local relInit = (slidersettings.Default - slidersettings.Min) / math.max(1, (slidersettings.Max - slidersettings.Min))
			fill.Size = UDim2.new(relInit, 0, 1, 0)
			fill.BackgroundColor3 = THEME.Accent
			fill.Parent = sliderBkg
			addCorner(fill, UDim.new(0, 6))
			local knob = Instance.new("Frame")
			knob.Size = UDim2.fromOffset(12, 12)
			knob.AnchorPoint = Vector2.new(0.5, 0.5)
			knob.Position = UDim2.new(relInit, 0, 0.5, 0)
			knob.BackgroundColor3 = THEME.Text
			knob.Parent = sliderBkg
			addCorner(knob, UDim.new(1, 0))

			local dragging = false
			local currentValue = slidersettings.Default
			local signal = makeSignal()
			
			local min = slidersettings.Min or 0
			local max = slidersettings.Max or 100
			local step = slidersettings.Step or 0
			local default = Config[moduleapi.Name].Sliders[sliderapi.Name] or slidersettings.Default
			
			local function updateValue(raw)
				if step > 0 then raw = math.floor((raw + step / 2) / step) * step end
				raw = math.clamp(raw, min, max)
				currentValue = raw

				local rel = (raw - min) / math.max(1, (max - min))
				fill.Size = UDim2.new(rel, 0, 1, 0)
				knob.Position = UDim2.new(rel, 0, 0.5, 0)

				valueBox.Text = tostring(math.floor(raw))

                Config[moduleapi.Name].Sliders[sliderapi.Name] = currentValue
				task.delay(0.01, function() api.Config:Save_Config() end)
			end

			local function setValueFromPos(x)
				local absPos = math.clamp(x - sliderBkg.AbsolutePosition.X, 0, sliderBkg.AbsoluteSize.X)
				local t = absPos / math.max(1, sliderBkg.AbsoluteSize.X)
				local raw = min + (max - min) * t
				updateValue(raw)
			end

			sliderBkg.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					dragging = true
					setValueFromPos(input.Position.X)
				end
			end)

			sliderBkg.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					dragging = false
				end
			end)

			UserInputService.InputChanged:Connect(function(input)
				if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
					setValueFromPos(input.Position.X)
				end
			end)

			valueBox.FocusLost:Connect(function()
				local num = tonumber(valueBox.Text)
				if num then
					updateValue(num)
				else
					valueBox.Text = tostring(currentValue)
				end
			end)

			task.defer(function()
				updateValue(default)
			end)

			return {
				Value = currentValue,
				Set = function(_, v)
					updateValue(v)
				end,
				Connect = function(_, fn)
					return signal:Connect(fn)
				end
			}
		end

		function moduleapi:CreateDropdown(dropdownsettings)
			local dropdownapi = {
				Name = dropdownsettings.Name,
				Option = dropdownsettings.Option,
			}
			
			if Config[moduleapi.Name].Dropdowns[dropdownsettings.Name] == nil then
				Config[moduleapi.Name].Dropdowns[dropdownsettings.Name] = {Option = dropdownsettings.Default or dropdownsettings.Options[1]}
			end
			
			local name = dropdownsettings.Name or "Dropdown"
			local options = dropdownsettings.Options or {}
			local defaultIndex = dropdownsettings.DefaultIndex or 1

			local row = createRow(name, 28)
			local label = Instance.new("TextLabel")
			label.Size = UDim2.new(0.5, 0, 0, 28)
			label.Position = UDim2.new(0, 0, 0, 0)
			label.BackgroundTransparency = 1
			label.FontFace = THEME.FontBold
			label.TextColor3 = THEME.Text
			label.TextSize = 13
			label.Text = name
			label.TextXAlignment = Enum.TextXAlignment.Left
			label.Parent = row
			local dropdownbkg = Instance.new("Frame")
			dropdownbkg.Size = UDim2.new(0.5, 0, 0, 28)
			dropdownbkg.Position = UDim2.new(0.5, 0, 0, 0)
			dropdownbkg.BackgroundColor3 = color.Light(THEME.Main2, 0.046)
			dropdownbkg.BorderSizePixel = 0
			dropdownbkg.Parent = row
			addCorner(dropdownbkg, UDim.new(0, 6))
			local dropdownBtn = Instance.new("TextButton")
			dropdownBtn.Size = UDim2.new(1, -2, 1, -2)
			dropdownBtn.Position = UDim2.fromOffset(1, 1)
			dropdownBtn.BackgroundColor3 = color.Light(THEME.Main2, 0.034)
			dropdownBtn.Text = ""
			dropdownBtn.AutoButtonColor = true
			dropdownBtn.Parent = dropdownbkg
			addCorner(dropdownBtn, UDim.new(0,6))
			local selectedLabel = Instance.new("TextLabel")
			selectedLabel.BackgroundTransparency = 1
			selectedLabel.FontFace = THEME.Font
			selectedLabel.TextColor3 = THEME.Text
			selectedLabel.TextSize = 13
			selectedLabel.Text = options[defaultIndex] or ""
			selectedLabel.Size = UDim2.new(1, -28, 1, 0)
			selectedLabel.Position = UDim2.new(0, 8, 0, 0)
			selectedLabel.TextXAlignment = Enum.TextXAlignment.Left
			selectedLabel.Parent = dropdownBtn
			local caret = Instance.new("ImageLabel")
			caret.Size = UDim2.new(0, 18, 1, 0)
			caret.Position = UDim2.new(1, -18, 0, 0)
			caret.BackgroundTransparency = 1
			caret.Image = "rbxassetid://129753620246765"
			caret.Parent = dropdownBtn
			local optsbkg = Instance.new("Frame")
			optsbkg.Size = UDim2.new(1, -50, 0, 0)
			optsbkg.Position = UDim2.new(0, 0, 0, 32)
			optsbkg.BackgroundColor3 = color.Light(THEME.Main2, 0.046)
			optsbkg.BorderSizePixel = 0
			optsbkg.ClipsDescendants = true
			optsbkg.Parent = row
			addCorner(optsbkg, UDim.new(0, 6))
			local optionsFrame = Instance.new("Frame")
			optionsFrame.Size = UDim2.new(1, -2, 1, -2)
			optionsFrame.Position = UDim2.fromOffset(1, 1)
			optionsFrame.BackgroundColor3 = color.Light(THEME.Main2, 0.034)
			optionsFrame.Parent = optsbkg
			addCorner(optionsFrame, UDim.new(0, 6))
			local optionsLayout = Instance.new("UIListLayout")
			optionsLayout.Padding = UDim.new(0, 2)
			optionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
			optionsLayout.Parent = optionsFrame

			local currentIndex = defaultIndex
			local signal = makeSignal()
			local baseModuleHeight = mod.AbsoluteSize.Y

        local saved = Config[moduleapi.Name].Dropdowns[dropdownsettings.Name]
            if saved then
                dropdownapi.Option = saved
                selectedLabel.Text = saved
            else
                dropdownapi.Option = dropdownsettings.Default or options[1]
                selectedLabel.Text = dropdownapi.Option
            end
			
			local function rebuildOptions()
				for i, opt in ipairs(options) do
					local optBtn = Instance.new("TextButton")
					optBtn.Size = UDim2.new(1, 0, 0, 26)
					optBtn.BackgroundTransparency = 0
					optBtn.BackgroundColor3 = color.Light(THEME.Main2, 0.034)
					optBtn.Text = ""
					optBtn.AutoButtonColor = true
					optBtn.Parent = optionsFrame
					optBtn.BorderSizePixel = 0
					addCorner(optBtn, UDim.new(0, 6))

					if i > 1 then
						local divider = Instance.new("Frame")
						divider.Size = UDim2.new(1, -8, 0, 1)
						divider.Position = UDim2.new(0, 4, 0, 0)
						divider.BackgroundColor3 = color.Light(THEME.Main2, 0.058)
						divider.BorderSizePixel = 0
						divider.Parent = optBtn
					end

					local t = Instance.new("TextLabel")
					t.BackgroundTransparency = 1
					t.Size = UDim2.new(1, 0, 1, 0)
					t.Position = UDim2.new(0, 8, 0, 0)
					t.FontFace = THEME.Font
					t.TextColor3 = THEME.Text
					t.TextSize = 13
					t.Text = opt
					t.TextXAlignment = Enum.TextXAlignment.Left
					t.Parent = optBtn

					optBtn.MouseEnter:Connect(function()
						TweenService:Create(optBtn, TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
							BackgroundColor3 = color.Light(THEME.Main2, 0.036)
						}):Play()
					end)
					optBtn.MouseLeave:Connect(function()
						TweenService:Create(optBtn, TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
							BackgroundColor3 = color.Light(THEME.Main2, 0.034)
						}):Play()
					end)

					dropdownBtn.MouseButton1Click:Connect(function()
						optsbkg.Visible = true
						caret.Rotation = 180
						local totalHeight = 0
						for _, c in ipairs(optionsFrame:GetChildren()) do
							if c:IsA("TextButton") then
								totalHeight = totalHeight + c.AbsoluteSize.Y + (optionsLayout.Padding.Offset or 0)
							end
						end
						totalHeight = math.clamp(totalHeight, 0, 200)

						TweenService:Create(optsbkg, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
							Size = UDim2.new(optsbkg.Size.X.Scale, optsbkg.Size.X.Offset, 0, totalHeight)
						}):Play()

						TweenService:Create(mod, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
							Size = UDim2.new(mod.Size.X.Scale, mod.Size.X.Offset, 0, baseModuleHeight + totalHeight + 5)
						}):Play()
						
						TweenService:Create(controlsHolder, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
							Size = UDim2.new(controlsHolder.Size.X.Scale, controlsHolder.Size.X.Offset, 0, baseModuleHeight + totalHeight)
						}):Play()
						
						TweenService:Create(row, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
							Size = UDim2.new(row.Size.X.Scale, row.Size.X.Offset, 0, totalHeight + 33)
						}):Play()
					end)

					optBtn.MouseButton1Click:Connect(function()
						currentIndex = i
						selectedLabel.Text = opt

						TweenService:Create(optsbkg, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
							Size = UDim2.new(optsbkg.Size.X.Scale, optsbkg.Size.X.Offset, 0, 0)
						}):Play()

						TweenService:Create(mod, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
							Size = UDim2.new(mod.Size.X.Scale, mod.Size.X.Offset, 0, baseModuleHeight)
						}):Play()

						TweenService:Create(controlsHolder, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
							Size = UDim2.new(controlsHolder.Size.X.Scale, controlsHolder.Size.X.Offset, 0, baseModuleHeight)
						}):Play()
						
						TweenService:Create(row, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
							Size = UDim2.new(row.Size.X.Scale, row.Size.X.Offset, 0, 28)
						}):Play()
						
						task.delay(0.2, function()
							optsbkg.Visible = false
							caret.Rotation = 0
						end)

                        Config[moduleapi.Name].Dropdowns[dropdownsettings.Name] = opt
						task.delay(0.01, function() api.Config:Save_Config() end)
					end)
				end
			end

			local function updateOptionsFrameHeight()
				local total = 0
				for _, c in ipairs(optionsFrame:GetChildren()) do
					if c:IsA("TextButton") then total = total + c.AbsoluteSize.Y + (optionsLayout.Padding.Offset or 0) end
				end
				local targetHeight = math.clamp(total, 0, 200)
				TweenService:Create(optionsFrame, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
					Size = UDim2.new(1,0,0,targetHeight)
				}):Play()
			end

			dropdownBtn.MouseButton1Click:Connect(function()
				optionsFrame.Visible = true
				updateOptionsFrameHeight()
			end)

			rebuildOptions()

			local api = {
				Value = options[currentIndex],
				Set = function(_, opt)
					for i,v in ipairs(options) do
						if v == opt then
							currentIndex = i
							selectedLabel.Text = opt
							break
						end
					end
				end,
				Connect = function(_, fn) return signal:Connect(fn) end,
				Options = options
			}
			return api
		end

		function moduleapi:CreateTextbox(textboxsettings)
			local textboxapi = {
				Name = textboxsettings.Name,
				Text = nil
			}

			local row = createRow(textboxsettings.Name, 28)
			local label = Instance.new("TextLabel")
			label.Size = UDim2.new(0.45, 0, 1, 0)
			label.Position = UDim2.new(0, 0, 0, 0)
			label.BackgroundTransparency = 1
			label.FontFace = THEME.FontBold
			label.TextColor3 = THEME.Text
			label.TextSize = 13
			label.Text = textboxsettings.Name
			label.TextXAlignment = Enum.TextXAlignment.Left
			label.Parent = row
			local txtbkg = Instance.new("Frame")
			txtbkg.Size = UDim2.new(0.55, 0, 1, 0)
			txtbkg.Position = UDim2.new(0.45, 0, 0, 0)
			txtbkg.BackgroundColor3 = color.Light(THEME.Main2, 0.046)
			txtbkg.BorderSizePixel = 0
			txtbkg.ClipsDescendants = true
			txtbkg.Parent = row
			addCorner(txtbkg, UDim.new(0, 6))
			local txt = Instance.new("TextBox")
			txt.Size = UDim2.new(1, -2, 1, -2)
			txt.Position = UDim2.fromOffset(1, 1)
			txt.BackgroundColor3 = color.Light(THEME.Main2, 0.034)
			txt.Text = textboxsettings.Text or ""
			txt.ClipsDescendants = true
			txt.PlaceholderText = textboxsettings.Placeholder
			txt.FontFace = THEME.Font
			txt.TextSize = 13
			txt.TextColor3 = THEME.Text
			txt.ClearTextOnFocus = false
			txt.Parent = txtbkg
			addCorner(txt, UDim.new(0, 6))

			local signal = makeSignal()
			txt.FocusLost:Connect(function(enterPressed)
			end)

			local api = {
				Text = txt.Text,
				Set = function(_, v) txt.Text = v end,
				Connect = function(_, fn) return signal:Connect(fn) end
			}
			return api
		end

		function moduleapi:CreateColorSlider(opts)
			opts = opts or {}
			local name = opts.Name or "Color"
			local default = opts.Default or Color3.fromRGB(255, 255, 255)
			local onChange = opts.Function

			local row = createRow(name, 96)
			local label = Instance.new("TextLabel")
			label.Size = UDim2.new(1, 0, 0, 18)
			label.Position = UDim2.new(0, 0, 0, 0)
			label.BackgroundTransparency = 1
			label.FontFace = THEME.FontBold
			label.TextColor3 = THEME.Text
			label.TextSize = 13
			label.Text = name
			label.TextXAlignment = Enum.TextXAlignment.Left
			label.Parent = row

			local preview = Instance.new("Frame")
			preview.Size = UDim2.new(0, 36, 0, 36)
			preview.Position = UDim2.new(1, -36, 0, 18)
			preview.BackgroundColor3 = default
			preview.Parent = row
			addCorner(preview, UDim.new(0,6))

			local sliders = {}
			local colors = {"R","G","B"}
			local values = {math.clamp(math.floor(default.R*255),0,255), math.clamp(math.floor(default.G*255),0,255), math.clamp(math.floor(default.B*255),0,255)}
			local signal = makeSignal()

			for i, c in ipairs(colors) do
				local sopts = {
					Name = c,
					Min = 0,
					Max = 255,
					Default = values[i],
					Step = 1,
					Function = function(v)
						values[i] = math.clamp(math.floor(v),0,255)
						preview.BackgroundColor3 = Color3.fromRGB(values[1], values[2], values[3])
						if onChange then pcall(onChange, preview.BackgroundColor3) end
						signal:Fire(preview.BackgroundColor3)
					end
				}
				local s = moduleapi:CreateSlider(sopts)
				local children = controlsHolder:GetChildren()
				local createdChild = children[#children]
				if createdChild and createdChild.Parent == controlsHolder then
					createdChild.Parent = row
				end
				table.insert(sliders, s)
			end

			local api = {
				GetColor = function() return Color3.fromRGB(values[1], values[2], values[3]) end,
				SetColor = function(_, color3)
					local r,g,b = math.clamp(math.floor(color3.R*255),0,255), math.clamp(math.floor(color3.G*255),0,255), math.clamp(math.floor(color3.B*255),0,255)
					values = {r,g,b}
					preview.BackgroundColor3 = Color3.fromRGB(r,g,b)
					for i, s in ipairs(sliders) do if s and s.Set then pcall(s.Set, s, values[i]) end end
					if onChange then pcall(onChange, preview.BackgroundColor3) end
					signal:Fire(preview.BackgroundColor3)
				end,
				Connect = function(_, fn) return signal:Connect(fn) end
			}
			return api
		end

		placeModuleInShortestColumn(modulebkg)

		table.insert(tabapi.Modules, moduleapi)

		return moduleapi
	end

	table.insert(api.Tabs, {Button = btn, Page = page, Image = img, DefaultIcon = tabsettings.Icon, ActiveIcon = tabsettings.ActiveIcon})

	return tabapi
end

home = api:CreateTab({
	Name="Home",
	Icon="rbxassetid://75277775223347",
	ActiveIcon="rbxassetid://75277775223347"
})

createCategoryHeader("Combat")
local combat = api:CreateTab({
	Name="Combat",
	Icon = "rbxassetid://95536289898968",
	ActiveIcon = "rbxassetid://95536289898968"
})
local legit = api:CreateTab({
	Name="Legit",
	Icon = "rbxassetid://125282530777725",
	ActiveIcon = "rbxassetid://125282530777725"
})

createCategoryHeader("Visuals")
local world = api:CreateTab({
	Name="World",
	Icon = "rbxassetid://101211606227796",
	ActiveIcon = "rbxassetid://101211606227796"
})
local player = api:CreateTab({
	Name="Player",
	Icon = "rbxassetid://92144768914590",
	ActiveIcon = "rbxassetid://92144768914590"
})

createCategoryHeader("Misc")
local settings = api:CreateTab({
	Name="Settings",
	Icon = "rbxassetid://117353800875058",
	ActiveIcon = "rbxassetid://117353800875058"
})

home:CreateModule({
	Name= "Uninject",

    Function = function(callback)
    
    end

})

Fly = home:CreateModule({
	Name = "Fly",
	Description = "idk this is js a test nothing works"
})

local slider = Fly:CreateSlider({
	Name = "Fly Speed",
	Min = 0,
	Max = 100,
	Default = 40,
	Function = function(v)
		print("Flyspeed = ", v)
	end
})

Fly:CreateDropdown({
	Name = "Mode",
	Options = {"Legit", "Rage", "Silent"},
	Default = "Legit",
	Function = function(v)
		print("Selected Mode:", v)
	end
})

Fly:CreateTextbox({
	Name = "Key",
	Placeholder = "Enter key...",
	Function = function(v)
		print("Key:", v)
	end
})

--[[Fly:CreateColorSlider({
	Name = "ESP Color",
	Default = Color3.fromRGB(255, 0, 0),
	Function = function(c)
		print("Color:", c)
	end
})]]


updateSidebarInstant(SIDEBAR.Collapsed)
setAllLabels(false)

shared.Proton = api

return api 
