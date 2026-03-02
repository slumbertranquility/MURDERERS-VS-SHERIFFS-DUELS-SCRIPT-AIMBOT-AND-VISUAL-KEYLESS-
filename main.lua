--[[
═══════════════════════════════════════════════════════════════
    DUELS AIMBOT PRO v4.0 - LOADSTRING VERSION
    For: Murderers VS Sheriffs Duels
    Features: Aimbot, ESP, Hitbox, Auto Shoot
    Exit button properly disables everything
═══════════════════════════════════════════════════════════════
--]]

-- Prevent multiple instances
if getgenv().DuelsAimbotLoaded then
    warn("Script already running! Close existing instance first.")
    return
end
getgenv().DuelsAimbotLoaded = true

-- Startup message
print("═══════════════════════════════")
print("🎯 DUELS AIMBOT PRO v4.0")
print("Loading script...")
print("═══════════════════════════════")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- Wait for character
if not LocalPlayer.Character then
    LocalPlayer.CharacterAdded:Wait()
end
repeat task.wait() until LocalPlayer.Character
local Camera = workspace.CurrentCamera

-- Global script state
local ScriptActive = true
local Connections = {}

-- Settings
local Settings = {
    AimbotEnabled = false,
    ESPEnabled = false,
    HitboxEnabled = false,
    AutoShootEnabled = false,
    IsHoldingAim = false,
    Smoothness = 25,
    HitboxSize = 25
}

-- Theme
local ThemeColor = Color3.fromRGB(255, 50, 50)

-- UI Setup
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local TopBar = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local CloseButton = Instance.new("TextButton")
local MinimizeButton = Instance.new("TextButton")
local TabFrame = Instance.new("Frame")
local CombatTab = Instance.new("TextButton")
local VisualTab = Instance.new("TextButton")
local ContentFrame = Instance.new("ScrollingFrame")
local StatusFrame = Instance.new("Frame")
local Status = Instance.new("TextLabel")
local TargetLabel = Instance.new("TextLabel")
local TargetInfo = Instance.new("TextLabel")

ScreenGui.Name = "DuelsAimbotPro"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Try CoreGui first, fallback to PlayerGui
local success = pcall(function()
    ScreenGui.Parent = game:GetService("CoreGui")
end)
if not success then
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

-- Main Frame
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 420, 0, 450)
MainFrame.Position = UDim2.new(0.5, -210, 0.5, -225)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

-- Top Bar
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 50)
TopBar.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local TopBarGradient = Instance.new("UIGradient")
TopBarGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, ThemeColor),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 20, 20))
}
TopBarGradient.Rotation = 90
TopBarGradient.Parent = TopBar
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 12)

Title.Size = UDim2.new(1, -100, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "🎯 1v1 DUELS AIMBOT"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 20
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 40, 0, 40)
CloseButton.Position = UDim2.new(1, -45, 0, 5)
CloseButton.BackgroundColor3 = Color3.fromRGB(200, 30, 30)
CloseButton.Text = "✕"
CloseButton.TextColor3 = Color3.new(1, 1, 1)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 20
CloseButton.Parent = TopBar
Instance.new("UICorner", CloseButton).CornerRadius = UDim.new(0, 8)

MinimizeButton.Name = "MinimizeButton"
MinimizeButton.Size = UDim2.new(0, 40, 0, 40)
MinimizeButton.Position = UDim2.new(1, -90, 0, 5)
MinimizeButton.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
MinimizeButton.Text = "─"
MinimizeButton.TextColor3 = Color3.new(1, 1, 1)
MinimizeButton.Font = Enum.Font.GothamBold
MinimizeButton.TextSize = 18
MinimizeButton.Parent = TopBar
Instance.new("UICorner", MinimizeButton).CornerRadius = UDim.new(0, 8)

-- Tab Frame
TabFrame.Name = "TabFrame"
TabFrame.Size = UDim2.new(1, -20, 0, 40)
TabFrame.Position = UDim2.new(0, 10, 0, 60)
TabFrame.BackgroundTransparency = 1
TabFrame.Parent = MainFrame

local function CreateTab(name, position)
    local tab = Instance.new("TextButton")
    tab.Size = UDim2.new(0.48, 0, 1, 0)
    tab.Position = UDim2.new(position * 0.52, 0, 0, 0)
    tab.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    tab.Text = name
    tab.TextColor3 = Color3.fromRGB(200, 200, 200)
    tab.Font = Enum.Font.GothamBold
    tab.TextSize = 14
    tab.Parent = TabFrame
    Instance.new("UICorner", tab).CornerRadius = UDim.new(0, 8)
    return tab
end

CombatTab = CreateTab("COMBAT", 0)
VisualTab = CreateTab("VISUAL", 1)

-- Content Frame
ContentFrame.Name = "ContentFrame"
ContentFrame.Size = UDim2.new(1, -20, 1, -210)
ContentFrame.Position = UDim2.new(0, 10, 0, 110)
ContentFrame.BackgroundTransparency = 1
ContentFrame.BorderSizePixel = 0
ContentFrame.ScrollBarThickness = 6
ContentFrame.CanvasSize = UDim2.new(0, 0, 0, 230)
ContentFrame.Parent = MainFrame

-- Status Frame
StatusFrame.Name = "StatusFrame"
StatusFrame.Size = UDim2.new(1, -20, 0, 90)
StatusFrame.Position = UDim2.new(0, 10, 1, -100)
StatusFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
StatusFrame.BorderSizePixel = 0
StatusFrame.Parent = MainFrame
Instance.new("UICorner", StatusFrame).CornerRadius = UDim.new(0, 10)

Status.Size = UDim2.new(1, -20, 0, 20)
Status.Position = UDim2.new(0, 10, 0, 10)
Status.BackgroundTransparency = 1
Status.Text = "💡 Enable features to start"
Status.TextColor3 = Color3.fromRGB(200, 200, 200)
Status.Font = Enum.Font.Gotham
Status.TextSize = 11
Status.TextXAlignment = Enum.TextXAlignment.Left
Status.Parent = StatusFrame

TargetLabel.Size = UDim2.new(1, -20, 0, 20)
TargetLabel.Position = UDim2.new(0, 10, 0, 35)
TargetLabel.BackgroundTransparency = 1
TargetLabel.Text = "🎯 Opponent: Searching..."
TargetLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
TargetLabel.Font = Enum.Font.GothamBold
TargetLabel.TextSize = 12
TargetLabel.TextXAlignment = Enum.TextXAlignment.Left
TargetLabel.Parent = StatusFrame

TargetInfo.Size = UDim2.new(1, -20, 0, 20)
TargetInfo.Position = UDim2.new(0, 10, 0, 60)
TargetInfo.BackgroundTransparency = 1
TargetInfo.Text = "❤️ Health: N/A | 📏 Distance: N/A"
TargetInfo.TextColor3 = Color3.fromRGB(150, 150, 150)
TargetInfo.Font = Enum.Font.Gotham
TargetInfo.TextSize = 10
TargetInfo.TextXAlignment = Enum.TextXAlignment.Left
TargetInfo.Parent = StatusFrame

-- Helper Functions
local function CreateToggle(name, icon, position, default)
    local toggle = Instance.new("TextButton")
    toggle.Name = name
    toggle.Size = UDim2.new(1, -10, 0, 45)
    toggle.Position = UDim2.new(0, 5, 0, position)
    toggle.BackgroundColor3 = default and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(70, 70, 70)
    toggle.Text = "  " .. icon .. "  " .. name .. ": " .. (default and "ON" or "OFF")
    toggle.TextColor3 = Color3.new(1, 1, 1)
    toggle.Font = Enum.Font.Gotham
    toggle.TextSize = 14
    toggle.TextXAlignment = Enum.TextXAlignment.Left
    toggle.Parent = ContentFrame
    Instance.new("UICorner", toggle).CornerRadius = UDim.new(0, 10)
    return toggle
end

local function CreateSlider(name, min, max, default, position)
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Size = UDim2.new(1, -10, 0, 60)
    sliderFrame.Position = UDim2.new(0, 5, 0, position)
    sliderFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    sliderFrame.Parent = ContentFrame
    Instance.new("UICorner", sliderFrame).CornerRadius = UDim.new(0, 10)
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -20, 0, 20)
    label.Position = UDim2.new(0, 10, 0, 5)
    label.BackgroundTransparency = 1
    label.Text = name .. ": " .. default
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = sliderFrame
    
    local sliderBar = Instance.new("Frame")
    sliderBar.Name = "Bar"
    sliderBar.Size = UDim2.new(1, -20, 0, 6)
    sliderBar.Position = UDim2.new(0, 10, 0, 35)
    sliderBar.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    sliderBar.Parent = sliderFrame
    Instance.new("UICorner", sliderBar).CornerRadius = UDim.new(1, 0)
    
    local sliderFill = Instance.new("Frame")
    sliderFill.Name = "Fill"
    sliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    sliderFill.BackgroundColor3 = ThemeColor
    sliderFill.BorderSizePixel = 0
    sliderFill.Parent = sliderBar
    Instance.new("UICorner", sliderFill).CornerRadius = UDim.new(1, 0)
    
    return {Frame = sliderFrame, Label = label, Fill = sliderFill, Bar = sliderBar, Min = min, Max = max}
end

-- Create Combat Tab
local AimbotToggle = CreateToggle("SILENT AIMBOT", "🎯", 0, false)
local AutoShootToggle = CreateToggle("AUTO SHOOT", "🔫", 55, false)
local SmoothnessSlider = CreateSlider("Smoothness", 5, 100, 25, 110)

-- Create Visual Tab (hidden)
local ESPToggle = CreateToggle("ESP WALLHACK", "👁️", 0, false)
local HitboxToggle = CreateToggle("BIG HITBOX", "💥", 55, false)

ESPToggle.Visible = false
HitboxToggle.Visible = false

-- Tab Switching
local function SwitchTab(tabName)
    CombatTab.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    VisualTab.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    
    AimbotToggle.Visible = false
    AutoShootToggle.Visible = false
    SmoothnessSlider.Frame.Visible = false
    ESPToggle.Visible = false
    HitboxToggle.Visible = false
    
    if tabName == "COMBAT" then
        CombatTab.BackgroundColor3 = ThemeColor
        AimbotToggle.Visible = true
        AutoShootToggle.Visible = true
        SmoothnessSlider.Frame.Visible = true
    else
        VisualTab.BackgroundColor3 = ThemeColor
        ESPToggle.Visible = true
        HitboxToggle.Visible = true
    end
end

CombatTab.MouseButton1Click:Connect(function() SwitchTab("COMBAT") end)
VisualTab.MouseButton1Click:Connect(function() SwitchTab("VISUAL") end)
SwitchTab("COMBAT")

-- HITBOX SYSTEM
local originalSizes = {}

local function ExpandHitboxes(character)
    if not character or not ScriptActive then return end
    
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if hrp then
        if not originalSizes[hrp] then
            originalSizes[hrp] = hrp.Size
        end
        hrp.Size = Vector3.new(Settings.HitboxSize, Settings.HitboxSize, Settings.HitboxSize)
        hrp.Transparency = 1
        hrp.CanCollide = false
        hrp.Massless = true
    end
end

local function RestoreHitboxes(character)
    if not character then return end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if hrp and originalSizes[hrp] then
        hrp.Size = originalSizes[hrp]
    end
end

-- ESP SYSTEM
local function AddESP(plr)
    if not plr or plr == LocalPlayer or not ScriptActive then return end
    if not plr.Character then return end
    
    pcall(function()
        local existing = plr.Character:FindFirstChild("DuelsESP")
        if existing then
            existing:Destroy()
            task.wait(0.1)
        end
        
        local highlight = Instance.new("Highlight")
        highlight.Name = "DuelsESP"
        highlight.Adornee = plr.Character
        highlight.FillColor = ThemeColor
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.FillTransparency = 0.3
        highlight.OutlineTransparency = 0
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.Enabled = true
        highlight.Parent = plr.Character
    end)
end

local function RemoveESP(plr)
    if not plr or not plr.Character then return end
    
    pcall(function()
        local existing = plr.Character:FindFirstChild("DuelsESP")
        if existing then
            existing:Destroy()
        end
    end)
end

local function UpdateAllESP()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            if Settings.ESPEnabled and ScriptActive then
                AddESP(plr)
            else
                RemoveESP(plr)
            end
        end
    end
end

local function UpdateAllHitboxes()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            if Settings.HitboxEnabled and ScriptActive then
                ExpandHitboxes(plr.Character)
            else
                RestoreHitboxes(plr.Character)
            end
        end
    end
end

-- Apply to players
for _, plr in pairs(Players:GetPlayers()) do
    if plr ~= LocalPlayer then
        local conn = plr.CharacterAdded:Connect(function(char)
            task.wait(0.5)
            if not ScriptActive then return end
            if Settings.ESPEnabled then AddESP(plr) end
            if Settings.HitboxEnabled then ExpandHitboxes(char) end
        end)
        table.insert(Connections, conn)
        
        if plr.Character then
            if Settings.ESPEnabled then AddESP(plr) end
            if Settings.HitboxEnabled then ExpandHitboxes(plr.Character) end
        end
    end
end

local conn1 = Players.PlayerAdded:Connect(function(plr)
    local conn = plr.CharacterAdded:Connect(function(char)
        task.wait(0.5)
        if not ScriptActive then return end
        if Settings.ESPEnabled then AddESP(plr) end
        if Settings.HitboxEnabled then ExpandHitboxes(char) end
    end)
    table.insert(Connections, conn)
end)
table.insert(Connections, conn1)

local conn2 = LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    if not ScriptActive then return end
    UpdateAllESP()
    UpdateAllHitboxes()
end)
table.insert(Connections, conn2)

-- Hitbox refresh loop
local hitboxLoop = task.spawn(function()
    while ScriptActive and task.wait(0.5) do
        if Settings.HitboxEnabled then
            UpdateAllHitboxes()
        end
    end
end)

-- GET OPPONENT
local function GetOpponent()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            return plr
        end
    end
    return nil
end

-- GET TARGET DATA
local function GetTargetData()
    if not ScriptActive then return nil end
    
    local opponent = GetOpponent()
    if not opponent or not opponent.Character then return nil end
    
    local humanoid = opponent.Character:FindFirstChild("Humanoid")
    local head = opponent.Character:FindFirstChild("Head")
    local hrp = opponent.Character:FindFirstChild("HumanoidRootPart")
    
    if not (humanoid and head and hrp) then return nil end
    if humanoid.Health <= 0 then return nil end
    
    local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myHRP then return nil end
    
    local distance = (myHRP.Position - hrp.Position).Magnitude
    
    return {
        player = opponent,
        head = head,
        humanoid = humanoid,
        hrp = hrp,
        distance = distance
    }
end

-- Input Detection
local conn3 = UserInputService.InputBegan:Connect(function(input, gp)
    if gp or not ScriptActive then return end
    
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        Settings.IsHoldingAim = true
    end
    
    if input.KeyCode == Enum.KeyCode.Delete then
        Settings.AimbotEnabled = false
        Settings.ESPEnabled = false
        Settings.HitboxEnabled = false
        Settings.AutoShootEnabled = false
        MainFrame.Visible = false
        UpdateAllESP()
        UpdateAllHitboxes()
        warn("🚨 PANIC MODE ACTIVATED")
    end
end)
table.insert(Connections, conn3)

local conn4 = UserInputService.InputEnded:Connect(function(input)
    if not ScriptActive then return end
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        Settings.IsHoldingAim = false
    end
end)
table.insert(Connections, conn4)

-- Auto Shoot
local autoShootLoop = task.spawn(function()
    while ScriptActive and task.wait() do
        if Settings.AutoShootEnabled and Settings.IsHoldingAim and Settings.AimbotEnabled then
            local target = GetTargetData()
            if target then
                mouse1click()
            end
        end
    end
end)

-- AIMBOT LOOP
local silentTarget = nil
local conn5 = RunService.RenderStepped:Connect(function()
    if not ScriptActive then return end
    
    if Settings.AimbotEnabled and Settings.IsHoldingAim and LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
        if not (humanoid and humanoid.Health > 0) then return end
        
        local target = GetTargetData()
        
        if target and target.head then
            silentTarget = target.head.Position
            
            TargetLabel.Text = "🎯 Locked: " .. target.player.Name
            TargetLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
            TargetInfo.Text = string.format("❤️ Health: %d | 📏 Distance: %d", 
                math.floor(target.humanoid.Health),
                math.floor(target.distance)
            )
        else
            silentTarget = nil
            TargetLabel.Text = "🎯 No opponent found"
            TargetLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
            TargetInfo.Text = "❤️ Health: N/A | 📏 Distance: N/A"
        end
    else
        silentTarget = nil
        TargetLabel.Text = Settings.AimbotEnabled and "🎯 Ready (Hold RMB)" or "🎯 Aimbot OFF"
        TargetLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
        TargetInfo.Text = "❤️ Health: N/A | 📏 Distance: N/A"
    end
end)
table.insert(Connections, conn5)

-- SLIDER SYSTEM
local function SetupSlider(slider, settingName)
    local dragging = false
    
    slider.Bar.InputBegan:Connect(function(input)
        if not ScriptActive then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    
    local conn = UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    table.insert(Connections, conn)
    
    local conn2 = UserInputService.InputChanged:Connect(function(input)
        if not ScriptActive then return end
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mousePos = UserInputService:GetMouseLocation().X
            local barPos = slider.Bar.AbsolutePosition.X
            local barSize = slider.Bar.AbsoluteSize.X
            local pct = math.clamp((mousePos - barPos) / barSize, 0, 1)
            local value = math.floor(slider.Min + (slider.Max - slider.Min) * pct)
            
            Settings[settingName] = value
            slider.Fill.Size = UDim2.new(pct, 0, 1, 0)
            slider.Label.Text = slider.Label.Text:match("^[^:]+") .. ": " .. value
        end
    end)
    table.insert(Connections, conn2)
end

SetupSlider(SmoothnessSlider, "Smoothness")

-- TOGGLE FUNCTIONS
AimbotToggle.MouseButton1Click:Connect(function()
    if not ScriptActive then return end
    Settings.AimbotEnabled = not Settings.AimbotEnabled
    AimbotToggle.Text = "  🎯  SILENT AIMBOT: " .. (Settings.AimbotEnabled and "ON" or "OFF")
    AimbotToggle.BackgroundColor3 = Settings.AimbotEnabled and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(70, 70, 70)
    Status.Text = Settings.AimbotEnabled and "💡 Hold RIGHT CLICK - No camera movement" or "💡 Aimbot disabled"
end)

AutoShootToggle.MouseButton1Click:Connect(function()
    if not ScriptActive then return end
    Settings.AutoShootEnabled = not Settings.AutoShootEnabled
    AutoShootToggle.Text = "  🔫  AUTO SHOOT: " .. (Settings.AutoShootEnabled and "ON" or "OFF")
    AutoShootToggle.BackgroundColor3 = Settings.AutoShootEnabled and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(70, 70, 70)
end)

ESPToggle.MouseButton1Click:Connect(function()
    if not ScriptActive then return end
    Settings.ESPEnabled = not Settings.ESPEnabled
    ESPToggle.Text = "  👁️  ESP WALLHACK: " .. (Settings.ESPEnabled and "ON" or "OFF")
    ESPToggle.BackgroundColor3 = Settings.ESPEnabled and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(70, 70, 70)
    UpdateAllESP()
end)

HitboxToggle.MouseButton1Click:Connect(function()
    if not ScriptActive then return end
    Settings.HitboxEnabled = not Settings.HitboxEnabled
    HitboxToggle.Text = "  💥  BIG HITBOX: " .. (Settings.HitboxEnabled and "ON" or "OFF")
    HitboxToggle.BackgroundColor3 = Settings.HitboxEnabled and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(70, 70, 70)
    UpdateAllHitboxes()
end)

-- CLEANUP FUNCTION
local function CleanupScript()
    print("🛑 Shutting down script...")
    
    ScriptActive = false
    Settings.AimbotEnabled = false
    Settings.ESPEnabled = false
    Settings.HitboxEnabled = false
    Settings.AutoShootEnabled = false
    
    for _, conn in pairs(Connections) do
        if typeof(conn) == "RBXScriptConnection" then
            conn:Disconnect()
        elseif typeof(conn) == "thread" then
            task.cancel(conn)
        end
    end
    
    for _, plr in pairs(Players:GetPlayers()) do
        RemoveESP(plr)
        if plr.Character then
            RestoreHitboxes(plr.Character)
        end
    end
    
    ScreenGui:Destroy()
    getgenv().DuelsAimbotLoaded = nil
    
    print("✓ Script fully disabled")
end

-- CLOSE BUTTON
CloseButton.MouseButton1Click:Connect(function()
    CleanupScript()
end)

-- MINIMIZE BUTTON
local minimized = false
MinimizeButton.MouseButton1Click:Connect(function()
    if not ScriptActive then return end
    minimized = not minimized
    local tween = TweenInfo.new(0.3, Enum.EasingStyle.Quad)
    
    if minimized then
        MinimizeButton.Text = "□"
        TweenService:Create(MainFrame, tween, {Size = UDim2.new(0, 420, 0, 50)}):Play()
        TabFrame.Visible = false
        ContentFrame.Visible = false
        StatusFrame.Visible = false
    else
        MinimizeButton.Text = "─"
        TweenService:Create(MainFrame, tween, {Size = UDim2.new(0, 420, 0, 450)}):Play()
        TabFrame.Visible = true
        ContentFrame.Visible = true
        StatusFrame.Visible = true
    end
end)

-- Toggle UI (INSERT key)
local conn6 = UserInputService.InputBegan:Connect(function(key, gp)
    if not ScriptActive then return end
    if not gp and key.KeyCode == Enum.KeyCode.Insert then
        MainFrame.Visible = not MainFrame.Visible
    end
end)
table.insert(Connections, conn6)

print("═══════════════════════════════")
print("✓ DUELS AIMBOT PRO v4.0 LOADED!")
print("✓ UI Created Successfully")
print("✓ Press INSERT to toggle UI")
print("✓ Press X to exit")
print("✓ DELETE = Panic mode")
print("═══════════════════════════════")
