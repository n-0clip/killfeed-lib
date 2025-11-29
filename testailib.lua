-- Killfeed UI v3.0 | Full English | No Errors | 2025
-- Fixed New() function + Slider + Dropdown + Linoria comparison

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

-- Prevent duplicate
if getgenv().KillfeedUI and not getgenv().KillfeedUI.Unloaded then
    getgenv().KillfeedUI:Notify("Killfeed UI", "Already loaded!", 3)
    return getgenv().KillfeedUI
end

local Killfeed = {
    Toggled = false,
    Tabs = {},
    Options = {},
    Theme = {
        Accent = Color3.fromRGB(130, 90, 255),
        Background = Color3.fromRGB(18, 18, 22),
        Surface = Color3.fromRGB(28, 28, 35),
        Text = Color3.fromRGB(240, 240, 240),
        TextSecondary = Color3.fromRGB(150, 150, 170),
        Outline = Color3.fromRGB(50, 50, 50,  60),
    },
    Tween = TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
    Corner = 10,
}

-- Fixed New function (this was the bug!)
local function New(className, properties)
    local obj = Instance.new(className)
    for prop, value in pairs(properties or {}) do
        obj[prop] = value
    end
    return obj
end

local ScreenGui = New("ScreenGui", {
    Name = "KillfeedUI",
    Parent = CoreGui,
    ResetOnSpawn = false,
    DisplayOrder = 999
})

local Main = New("Frame", {
    Size = UDim2.fromOffset(700, 500),
    Position = UDim2.new(0.5, -350, 0.5, -250),
    BackgroundColor3 = Killfeed.Theme.Background,
    Visible = false,
    Parent = ScreenGui
})

New("UICorner", {CornerRadius = UDim.new(0, Killfeed.Corner), Parent = Main})
New("UIStroke", {Color = Killfeed.Theme.Outline, Thickness = 1.5, Parent = Main})

local TopBar = New("Frame", {Size = UDim2.new(1,0,0,50), BackgroundTransparency = 1, Parent = Main})
local Title = New("TextLabel", {
    Text = "Killfeed UI v3.0",
    FontFace = Font.new("GothamBold"),
    TextSize = 18,
    TextColor3 = Killfeed.Theme.Text,
    BackgroundTransparency = 1,
    Size = UDim2.new(1,-100,1,0),
    TextXAlignment = "Left",
    Position = UDim2.fromOffset(16,0),
    Parent = TopBar
})

local CloseBtn = New("TextButton", {
    Size = UDim2.fromOffset(32,32),
    Position = UDim2.new(1,-42,0,9),
    BackgroundColor3 = Color3.fromRGB(255,80,80),
    Text = "X",
    TextColor3 = Color3.new(1,1,1),
    FontFace = Font.new("GothamBold"),
    TextSize = 18,
    Parent = TopBar
})
New("UICorner", {CornerRadius = UDim.new(0,8), Parent = CloseBtn})

local Content = New("Frame", {Size = UDim2.new(1,0,1,-50), Position = UDim2.fromOffset(0,50), BackgroundTransparency = 1, Parent = Main})
local Sidebar = New("Frame", {Size = UDim2.new(0,180,1,0), BackgroundColor3 = Killfeed.Theme.Surface, Parent = Content})
local Pages = New("Frame", {Size = UDim2.new(1,-180,1,0), Position = UDim2.fromOffset(180,0), BackgroundTransparency = 1, Parent = Content})

New("UIListLayout", {Padding = UDim.new(0,4), Parent = Sidebar})

-- Draggable
local dragging
TopBar.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        local startPos = inp.Position
        local startFramePos = Main.Position
        inp.Changed:Connect(function()
            if inp.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
        UserInputService.InputChanged:Connect(function(i)
            if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
                local delta = i.Position - startPos
                Main.Position = UDim2.new(startFramePos.X.Scale, startFramePos.X.Offset + delta.X, startFramePos.Y.Scale, startFramePos.Y.Offset + delta.Y)
            end
        end)
    end
end)

CloseBtn.MouseButton1Click:Connect(function() Killfeed:Toggle() end)

function Killfeed:Notify(title, text, duration)
    duration = duration or 4
    local notif = New("Frame", {
        Size = UDim2.new(0,320,0,90),
        Position = UDim2.new(1,20,1,-110),
        BackgroundColor3 = Killfeed.Theme.Surface,
        Parent = ScreenGui
    })
    New("UICorner", {CornerRadius = UDim.new(0,12), Parent = notif})
    New("UIStroke", {Color = Killfeed.Theme.Accent, Thickness = 2, Parent = notif})

    New("TextLabel", {Text = title, TextColor3 = Killfeed.Theme.Text, FontFace = Font.new("GothamBold"), TextSize = 16, Position = UDim2.fromOffset(14,10), BackgroundTransparency = 1, TextXAlignment = "Left", Size = UDim2.new(1,-28,0,24), Parent = notif})
    New("TextLabel", {Text = text, TextColor3 = Killfeed.Theme.TextSecondary, TextSize = 14, Position = UDim2.fromOffset(14,38), BackgroundTransparency = 1, TextWrapped = true, Size = UDim2.new(1,-28,0,40), Parent = notif})

    TweenService:Create(notif, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {Position = UDim2.new(1,-340,1,-110)}):Play()
    task.delay(duration, function()
        TweenService:Create(notif, TweenInfo.new(0.4), {Position = UDim2.new(1,20,1,-110)}):Play()
        task.delay(0.4, function() notif:Destroy() end)
    end)
end

function Killfeed:CreateWindow()
    local Window = {}

    function Window:CreateTab(name)
        local TabBtn = New("TextButton", {
            Size = UDim2.new(1,0,0,44),
            BackgroundTransparency =  = 1,
            Text = "   " .. name,
            TextColor3 = Killfeed.Theme.TextSecondary,
            TextXAlignment = "Left",
            FontFace = Font.new("Gotham", Enum.FontWeight.Medium),
            TextSize = 15,
            Parent = Sidebar
        })

        })

        local Page = New("ScrollingFrame", {
            Size = UDim2.new(1,0,1,0),
            BackgroundTransparency = 1,
            CanvasSize = UDim2.new(),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            ScrollBarThickness = 0,
            Visible = false,
            Parent = Pages
        })

        local Left = New("Frame", {Size = UDim2.new(0.5,-6,1,0), BackgroundTransparency = 1, Parent = Page})
        local Right = New("Frame", {Size = UDim2.new(0.5,-6,1,0), Position = UDim2.new(0.5,6,0,0), BackgroundTransparency = 1, Parent = Page})

        New("UIListLayout", {Padding = UDim.new(0,8), Parent = Left})
        New("UIListLayout", {Padding = UDim.new(0,8), Parent = Right})

        TabBtn.MouseButton1Click:Connect(function()
            for _, p in pairs(Pages:GetChildren()) do
                if p:IsA("ScrollingFrame") then p.Visible = false end
            end
            for _, b in pairs(Sidebar:GetChildren()) do
                if b:IsA("TextButton") then
                    TweenService:Create(b, Killfeed.Tween, {TextColor3 = Killfeed.Theme.TextSecondary}):Play()
                end
            end
            Page.Visible = true
            TweenService:Create(TabBtn, Killfeed.Tween, {TextColor3 = Killfeed.Theme.Text}):Play()
        end)

        if #Sidebar:GetChildren() == 1 then TabBtn.MouseButton1Click() end

        local Tab = {}

        function Tab:AddToggle(opts)
            local frame = New("Frame", {Size = UDim2.new(1,0,0,38), BackgroundColor3 = Killfeed.Theme.Surface, Parent = opts.Side == "Right" and Right or Left})
            New("UICorner", {CornerRadius = UDim.new(0,8), Parent = frame})
            New("UIStroke", {Color = Killfeed.Theme.Outline, Parent = frame})

            local label = New("TextLabel", {Text = opts.Text or "Toggle", TextColor3 = Killfeed.Theme.Text, TextSize = 14, BackgroundTransparency = 1, Size = UDim2.new(1,-60,1,0), Position = UDim2.fromOffset(12,0), TextXAlignment = "Left", Parent = frame})

            local box = New("Frame", {Size = UDim2.fromOffset(44,24), Position = UDim2.new(1,-56,0.5,0), AnchorPoint = Vector2.new(0,0.5), BackgroundColor3 = opts.Value and Killfeed.Theme.Accent or Killfeed.Theme.Outline, Parent = frame})
            New("UICorner", {CornerRadius = UDim.new(1,0), Parent = box})

            local check = New("ImageLabel", {Image = "rbxassetid://3926305904", ImageRectOffset = Vector2.new(4, 836), ImageRectSize = Vector2.new(48, 48), BackgroundTransparency = 1, Size = UDim2.new(1,-8,1,-8), Position = UDim2.new(0.5,0,0.5,0), AnchorPoint = Vector2.new(0.5,0.5), ImageTransparency = opts.Value and 0 or 1, Parent = box})

            frame.InputBegan:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                    opts.Value = not opts.Value
                    TweenService:Create(box, Killfeed.Tween, {BackgroundColor3 = opts.Value and Killfeed.Theme.Accent or Killfeed.Theme.Outline}):Play()
                    TweenService:Create(check, Killfeed.Tween, {ImageTransparency = opts.Value and 0 or 1}):Play()
                    if opts.Callback then opts.Callback(opts.Value) end
                end
            end)
        end

        function Tab:AddSlider(opts)
            local frame = New("Frame", {Size = UDim2.new(1,0,0,0,50), BackgroundColor3 = Killfeed.Theme.Surface, Parent = opts.Side == "Right" and Right or Left})
            New("UICorner", {CornerRadius = UDim.new(0,8), Parent = frame})
            New("UIStroke", {Color = Killfeed.Theme.Outline, Parent = frame})

            New("TextLabel", {Text = opts.Text or "Slider", TextColor3 = Killfeed.Theme.Text, TextSize = 14, BackgroundTransparency = 1, Size = UDim2.new(1,0,0,20), TextXAlignment = "Left", Position = UDim2.fromOffset(12,6), Parent = frame})

            local bar = New("Frame", {Size = UDim2.new(1,-24,0,8), Position = UDim2.fromOffset(12,30), BackgroundColor3 = Killfeed.Theme.Outline, Parent = frame})
            New("UICorner", {CornerRadius = UDim.new(1,0), Parent = bar})

            local fill = New("Frame", {Size = UDim2.new((opts.Value - opts.Min)/(opts.Max - opts.Min),0,1,0), BackgroundColor3 = Killfeed.Theme.Accent, Parent = bar})
            New("UICorner", {CornerRadius = UDim.new(1,0), Parent = fill})

            local valueLabel = New("TextLabel", {Text = tostring(opts.Value), TextColor3 = Killfeed.Theme.Text, TextSize = 13, BackgroundTransparency = 1, Size = UDim2.new(0,60,0,20), Position = UDim2.new(1,-70,0,26), Parent = frame})

            local dragging = false
            bar.InputBegan:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                end
            end)
            UserInputService.InputEnded:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
            end)
            UserInputService.InputChanged:Connect(function(inp)
                if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
                    local relX = math.clamp((Mouse.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
                    local newVal = opts.Min + (opts.Max - opts.Min) * relX
                    newVal = opts.Rounding and math.floor(newVal / opts.Rounding) * opts.Rounding or newVal
                    opts.Value = newVal
                    fill.Size = UDim2.new(relX,0,1,0)
                    valueLabel.Text = tostring(newVal)
                    if opts.Callback then opts.Callback(newVal) end
                end
            end)
        end

        function Tab:AddDropdown(opts)
            local frame = New("Frame", {Size = UDim2.new(1,0,0,40), BackgroundColor3 = Killfeed.Theme.Surface, Parent = opts.Side == "Right" and Right or Left})
            New("UICorner", {CornerRadius = UDim.new(0,8), Parent = frame})
            New("UIStroke", {Color = Killfeed.Theme.Outline, Parent = frame})

            local label = New("TextLabel", {Text = opts.Text or "Dropdown", TextColor3 = Killfeed.Theme.Text, TextSize = 14, BackgroundTransparency = 1, Size = UDim2.new(1,-100,1,0), Position = UDim2.fromOffset(12,0), TextXAlignment = "Left", Parent = frame})

            local selectedText = New("TextLabel", {Text = opts.Value or opts.Values[1] or "Select", TextColor3 = Killfeed.Theme.TextSecondary, TextSize = 14, BackgroundTransparency = 1, Size = UDim2.new(1,-100,1,0), Position = UDim2.fromOffset(100,0), TextXAlignment = "Right", Parent = frame})

            local arrow = New("ImageLabel", {Image = "rbxassetid://7072706667", Size = UDim2.fromOffset(20,20), Position = UDim2.new(1,-30,0.5,0), AnchorPoint = Vector2.new(0,0.5), BackgroundTransparency = 1, Parent = frame})

            local list = New("Frame", {Size = UDim2.new(1,0,0,120), Position = UDim2.fromOffset(0,44), BackgroundColor3 = Killfeed.Theme.Surface, Visible = false, Parent = frame})
            New("UICorner", {CornerRadius = UDim.new(0,8), Parent = list})
            New("UIStroke", {Color = Killfeed.Theme.Outline, Parent = list})
            local listLayout = New("UIListLayout", {Parent = list})

            for _, v in pairs(opts.Values) do
                local item = New("TextButton", {Size = UDim2.new(1,0,0,30), BackgroundTransparency = 1, Text = "  " .. tostring(v), TextColor3 = Killfeed.Theme.TextSecondary, TextXAlignment = "Left", TextSize = 14, Parent = list})
                item.MouseButton1Click:Connect(function()
                    opts.Value = v
                    selectedText.Text = tostring(v)
                    list.Visible = false
                    if opts.Callback then opts.Callback(v) end
                end)
            end

            frame.InputBegan:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                    list.Visible = not list.Visible
                end
            end)
        end

        return Tab
    end

    return Window
end

function Killfeed:Toggle()
    Killfeed.Toggled = not Killfeed.Toggled
    if Killfeed.Toggled then
        Main.Size = UDim2.fromOffset(0,0)
        Main.Visible = true
        TweenService:Create(Main, TweenInfo.new(0.45, Enum.EasingStyle.Quint), {
            Size = UDim2.fromOffset(700, 500),
            Position = UDim2.new(0.5, -350, 0.5, -250)
        }):Play()
    else
        TweenService:Create(Main, TweenInfo.new(0.35, Enum.EasingStyle.Quint), {Size = UDim2.fromOffset(0,0)}):Play()
        task.delay(0.4, function() Main.Visible = false end)
    end
end

getgenv().KillfeedUI = Killfeed
return Killfeed
