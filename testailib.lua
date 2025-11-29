-- Killfeed UI v2.5 | English | Full Version | 2025
-- Smooth animations | Duplicate protection | Modern design
-- Author: n0clip + improved by Grok

local cloneref = cloneref or function(obj) return obj end

local Players = cloneref(game:GetService("Players"))
local TweenService = cloneref(game:GetService("TweenService"))
local UserInputService = cloneref(game:GetService("UserInputService"))
local RunService = cloneref(game:GetService("RunService"))
local TextService = cloneref(game:GetService("TextService"))
local CoreGui = cloneref(game:GetService("CoreGui"))
local Teams = cloneref(game:GetService("Teams"))

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local Mouse = LocalPlayer:GetMouse()

-- Prevent duplicate windows
if getgenv().Killfeed and not getgenv().Killfeed.Unloaded then
    getgenv().Killfeed:Notify("Killfeed UI", "Window already exists!", 4)
    return getgenv().Killfeed
end

local Killfeed = {
    Toggled = false,
    Unloaded = false,
    Tabs = {},
    Options = {},
    Notifications = {},
    Theme = {
        Accent = Color3.fromRGB(125, 85, 255),
        Background = Color3.fromRGB(15, 15, 15),
        Surface = Color3.fromRGB(25, 25, 25),
        Outline = Color3.fromRGB(45, 45, 45),
        Text = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(170, 170, 170),
        Red = Color3.fromRGB(255, 70, 85),
    },
    TweenInfo = TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
    CornerRadius = 8,
    DPIScale = 1,
}

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KillfeedUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 999999
ScreenGui.Parent = CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.fromOffset(720, 0)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.BackgroundColor3 = Killfeed.Theme.Background
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, Killfeed.CornerRadius)
UICorner.Parent = MainFrame

local Outline = Instance.new("UIStroke")
Outline.Color = Killfeed.Theme.Outline
Outline.Thickness = 1
Outline.Parent = MainFrame

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 50)
TopBar.BackgroundTransparency = 1
TopBar.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Text = "Killfeed UI"
Title.FontFace = Font.new("GothamBold", Enum.FontWeight.Bold)
Title.TextSize = 18
Title.TextColor3 = Killfeed.Theme.Text
Title.BackgroundTransparency = 1
Title.Size = UDim2.new(1, -100, 1, 0)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Position = UDim2.fromOffset(16, 0)
Title.Parent = TopBar

local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.fromOffset(30, 30)
CloseButton.Position = UDim2.new(1, -40, 0, 10)
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 60, 70)
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.new(1,1,1)
CloseButton.FontFace = Font.new("GothamBold")
CloseButton.TextSize = 16
CloseButton.Parent = TopBar

local CloseCorner = Instance.new("UICorner", {CornerRadius = UDim.new(0,6)}, CloseButton)

local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, 0, 1, -50)
Content.Position = UDim2.fromOffset(0, 50)
Content.BackgroundTransparency = 1
Content.Parent = MainFrame

local TabContainer = Instance.new("Frame")
TabContainer.Size = UDim2.new(0, 180, 1, 0)
TabContainer.BackgroundColor3 = Killfeed.Theme.Surface
TabContainer.Parent = Content

local TabList = Instance.new("UIListLayout")
TabList.Padding = UDim.new(0, 4)
TabList.Parent = TabContainer

local PageContainer = Instance.new("Frame")
PageContainer.Size = UDim2.new(1, -180, 1, 0)
PageContainer.Position = UDim2.fromOffset(180, 0)
PageContainer.BackgroundTransparency = 1
PageContainer.Parent = Content

local function MakeDraggable(frame, handle)
    local dragging = false
    local dragInput, dragStart, startPos

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    handle.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement) then
            local delta = input.Position - dragStart
            TweenService:Create(frame, TweenInfo.new(0.15), {Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)}):Play()
        end
    end)
end

MakeDraggable(MainFrame, TopBar)

CloseButton.MouseButton1Click:Connect(function()
    Killfeed:Toggle(false)
end)

function Killfeed:CreateWindow(config)
    config = config or {}
    config.Title = config.Title or "Killfeed UI"
    config.Size = config.Size or UDim2.fromOffset(720, 540)

    Title.Text = config.Title
    MainFrame.Size = config.Size

    local Window = {}

    function Window:CreateTab(name)
        local TabButton = Instance.new("TextButton")
        TabButton.Size = UDim2.new(1, 0, 0, 40)
        TabButton.BackgroundTransparency = 1
        TabButton.Text = "  " .. name
        TabButton.TextColor3 = Killfeed.Theme.TextSecondary
        TabButton.TextXAlignment = Enum.TextXAlignment.Left
        TabButton.FontFace = Font.new("Gotham")
        TabButton.TextSize = 15
        TabButton.Parent = TabContainer

        local TabPage = Instance.new("ScrollingFrame")
        TabPage.Size = UDim2.new(1, 0, 1, 0)
        TabPage.BackgroundTransparency = 1
        TabPage.ScrollBarThickness = 4
        TabPage.Visible = false
        TabPage.AutomaticCanvasSize = Enum.AutomaticSize.Y
        TabPage.Parent = PageContainer

        local LeftColumn = Instance.new("Frame")
        LeftColumn.Size = UDim2.new(0.5, -6, 1, 0)
        LeftColumn.BackgroundTransparency = 1
        LeftColumn.Parent = TabPage

        local RightColumn = Instance.new("Frame")
        RightColumn.Size = UDim2.new(0.5, -6, 1, 0)
        RightColumn.Position = UDim2.new(0.5, 6, 0, 0)
        RightColumn.BackgroundTransparency = 1
        RightColumn.Parent = TabPage

        local LeftLayout = Instance.new("UIListLayout")
        LeftLayout.Padding = UDim.new(0, 8)
        LeftLayout.Parent = LeftColumn

        local RightLayout = Instance.new("UIListLayout")
        RightLayout.Padding = UDim.new(0, 8)
        RightLayout.Parent = RightColumn

        TabButton.MouseButton1Click:Connect(function()
            for _, page in pairs(PageContainer:GetChildren()) do
                if page:IsA("ScrollingFrame") then page.Visible = false end
            end
            for _, btn in pairs(TabContainer:GetChildren()) do
                if btn:IsA("TextButton") then
                    TweenService:Create(btn, Killfeed.TweenInfo, {TextColor3 = Killfeed.Theme.TextSecondary}):Play()
                end
            end

            TabPage.Visible = true
            TweenService:Create(TabButton, Killfeed.TweenInfo, {TextColor3 = Killfeed.Theme.Text}):Play()
        end)

        if #TabContainer:GetChildren() == 3 then -- first tab
            TabButton.MouseButton1Click()
        end

        local Tab = {}

        function Window:AddToggle(options)
            local Toggle = Instance.new("TextButton")
            Toggle.Size = UDim2.new(1, 0, 0, 36)
            Toggle.BackgroundColor3 = Killfeed.Theme.Surface
            Toggle.Text = ""
            Toggle.Parent = options.Side == "Right" and RightColumn or LeftColumn

            local Corner = Instance.new("UICorner", {CornerRadius = UDim.new(0,6)}, Toggle)
            local Stroke = Instance.new("UIStroke", {Color = Killfeed.Theme.Outline}, Toggle)

            local Label = Instance.new("TextLabel")
            Label.Text = options.Text or "Toggle"
            Label.TextColor3 = Killfeed.Theme.Text
            Label.TextSize = 14
            Label.FontFace = Font.new("Gotham")
            Label.BackgroundTransparency = 1
            Label.Size = UDim2.new(1, -50, 1, 0)
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Position = UDim2.fromOffset(12, 0)
            Label.Parent = Toggle

            local Indicator = Instance.new("Frame")
            Indicator.Size = UDim2.fromOffset(20, 20)
            Indicator.Position = UDim2.new(1, -32, 0.5, 0)
            Indicator.AnchorPoint = Vector2.new(0.5, 0.5)
            Indicator.BackgroundColor3 = options.Value and Killfeed.Theme.Accent or Killfeed.Theme.Outline
            Indicator.Parent = Toggle

            local IndCorner = Instance.new("UICorner", {CornerRadius = UDim.new(1,0)}, Indicator)

            Toggle.MouseButton1Click:Connect(function()
                options.Value = not options.Value
                TweenService:Create(Indicator, Killfeed.TweenInfo, {
                    BackgroundColor3 = options.Value and Killfeed.Theme.Accent or Killfeed.Theme.Outline
                }):Play()
                if options.Callback then options.Callback(options.Value) end
            end)

            table.insert(Killfeed.Options, {Type="Toggle", Value = options.Value})
        end

        function Window:AddButton(options)
            local Button = Instance.new("TextButton")
            Button.Size = UDim2.new(1, 0, 0, 40)
            Button.BackgroundColor3 = Killfeed.Theme.Surface
            Button.Text = options.Text or "Button"
            Button.TextColor3 = Killfeed.Theme.Text
            Button.FontFace = Font.new("GothamBold")
            Button.TextSize = 15
            Button.Parent = options.Side == "Right" and RightColumn or LeftColumn

            local Corner = Instance.new("UICorner", {CornerRadius = UDim.new(0,8)}, Button)
            local Stroke = Instance.new("UIStroke", {Color = Killfeed.Theme.Accent, Thickness = 0}, Button)

            Button.MouseEnter:Connect(function()
                TweenService:Create(Button, Killfeed.TweenInfo, {BackgroundColor3 = Killfeed.Theme.Accent}):Play()
                TweenService:Create(Stroke, Killfeed.TweenInfo, {Thickness = 2}):Play()
            end)
            Button.MouseLeave:Connect(function()
                TweenService:Create(Button, Killfeed.TweenInfo, {BackgroundColor3 = Killfeed.Theme.Surface}):Play()
                TweenService:Create(Stroke, Killfeed.TweenInfo, {Thickness = 0}):Play()
            end)

            Button.MouseButton1Click:Connect(function()
                if options.Callback then options.Callback() end
            end)
        end

        return Tab
    end

    return Window
end

function Killfeed:Toggle(state)
    Killfeed.Toggled = state ~= nil and state or not Killfeed.Toggled
    MainFrame.Visible = Killfeed.Toggled

    if Killfeed.Toggled then
        MainFrame.Size = UDim2.fromOffset(0, 0)
        MainFrame.Visible = true
        TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {
            Size = config.Size or UDim2.fromOffset(720, 540),
            Position = UDim2.new(0.5, 0, 0.5, 0)
        }):Play()
    else
        TweenService:Create(MainFrame, TweenInfo.new(0.35, Enum.EasingStyle.Quint), {
            Size = UDim2.fromOffset(0, 0)
        }):Play()
        task.delay(0.4, function()
            if not Killfeed.Toggled then MainFrame.Visible = false end
        end)
    end
end

function Killfeed:Notify(title, desc, time)
    time = time or 5
    local Notif = Instance.new("Frame")
    Notif.Size = UDim2.new(0, 300, 0, 80)
    Notif.Position = UDim2.new(1, 20, 1, -100)
    Notif.BackgroundColor3 = Killfeed.Theme.Surface
    Notif.Parent = ScreenGui

    local Corner = Instance.new("UICorner", {CornerRadius = UDim.new(0,10)}, Notif)
    local Stroke = Instance.new("UIStroke", {Color = Killfeed.Theme.Accent}, Notif)

    local TitleLabel = Instance.new("TextLabel", {Text = title, TextColor3 = Killfeed.Theme.Text, FontFace = Font.new("GothamBold"), TextSize = 16, Position = UDim2.fromOffset(12, 8)}, Notif)
    local DescLabel = Instance.new("TextLabel", {Text = desc, TextColor3 = Killfeed.Theme.TextSecondary, TextSize = 14, Position = UDim2.fromOffset(12, 32), Size = UDim2.new(1, -24,0,40), TextWrapped = true}, Notif)

    TweenService:Create(Notif, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {Position = UDim2.new(1, -320, 1, -100)}):Play()

    task.delay(time, function()
        TweenService:Create(Notif, TweenInfo.new(0.4), {Position = UDim2.new(1, 20, 1, -100)}):Play()
        task.delay(0.4, function() Notif:Destroy() end)
    end)
end

getgenv().Killfeed = Killfeed
return Killfeed
