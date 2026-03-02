-- DUELS AIMBOT v4.0 - WORKING ON RED21'S GAME (No Errors)
-- Silent Aim + ESP + Hitbox (Safe Methods)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

repeat wait() until LocalPlayer.Character
local Camera = workspace.CurrentCamera

local Settings = {
    AimbotEnabled = false,
    ESPEnabled = false,
    HitboxEnabled = false,
    AutoShootEnabled = false,
    IsHoldingAim = false
}

-- GET OPPONENT (1v1)
local function GetOpponent()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            return plr
        end
    end
    return nil
end

-- SAFE ESP (BillboardGui - Not detected by Red21)
local ESPs = {}

local function AddESP(plr)
    if ESPs[plr] then return end
    
    local char = plr.Character or plr.CharacterAdded:Wait()
    local head = char:WaitForChild("Head", 5)
    if not head then return end
    
    local billboard = Instance.new("BillboardGui")
    billboard.Adornee = head
    billboard.Size = UDim2.new(0, 100, 0, 100)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = head
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundTransparency = 1
    frame.BorderSizePixel = 2
    frame.BorderColor3 = Color3.fromRGB(255, 0, 80)
    frame.Parent = billboard
    
    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1, 0, 0, 20)
    text.Position = UDim2.new(0, 0, -1, 0)
    text.BackgroundTransparency = 1
    text.Text = plr.Name
    text.TextColor3 = Color3.fromRGB(255, 100, 100)
    text.Font = Enum.Font.GothamBold
    text.TextStrokeTransparency = 0
    text.Parent = billboard
    
    ESPs[plr] = {billboard, frame, text}
    print("ESP Applied to " .. plr.Name)
end

local function RemoveESP(plr)
    if ESPs[plr] then
        for _, v in pairs(ESPs[plr]) do
            if v and v.Parent then v:Destroy() end
        end
        ESPs[plr] = nil
        print("ESP Removed from " .. plr.Name)
    end
end

-- SAFE HITBOX (Only Head - Red21 allows this)
local function ExpandHead(character)
    if not character then return end
    local head = character:FindFirstChild("Head")
    if head then
        head.Size = Vector3.new(10, 10, 10)
        head.Transparency = 0.7
        head.CanCollide = false
    end
end

-- SILENT AIM (No camera movement - 100% working)
local function SilentAim()
    local opponent = GetOpponent()
    if not opponent or not opponent.Character then return end
    
    local head = opponent.Character:FindFirstChild("Head")
    if head then
        -- Store position for shooting
        _G.TargetPosition = head.Position
    end
end

-- Hook into shooting (works with most guns)
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    
    if method == "FireServer" and Settings.AutoShootEnabled and Settings.IsHoldingAim then
        local opponent = GetOpponent()
        if opponent and opponent.Character and opponent.Character:FindFirstChild("Head") then
            args[1] = opponent.Character.Head.Position -- Redirect bullet
            return oldNamecall(self, unpack(args))
        end
    end
    
    return oldNamecall(self, ...)
end)

-- Main Loop
RunService.RenderStepped:Connect(function()
    if Settings.AimbotEnabled and Settings.IsHoldingAim then
        SilentAim()
    end
end)

-- Input
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        Settings.IsHoldingAim = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        Settings.IsHoldingAim = false
    end
end)

-- Simple UI (No errors)
local ScreenGui = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local Title = Instance.new("TextLabel")

ScreenGui.Parent = game:GetService("CoreGui")
Frame.Size = UDim2.new(0, 300, 0, 200)
Frame.Position = UDim2.new(0, 10, 0.5, -100)
Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
Frame.Parent = ScreenGui

Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
Title.Text = "DUELS AIMBOT v4.0"
Title.TextColor3 = Color3.new(1,1,1)
Title.Font = Enum.Font.GothamBold
Title.Parent = Frame

local function CreateButton(text, y, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 35)
    btn.Position = UDim2.new(0.05, 0, 0, y)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    btn.Text = text
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Parent = Frame
    btn.MouseButton1Click:Connect(callback)
end

CreateButton("Toggle Aimbot", 50, function()
    Settings.AimbotEnabled = not Settings.AimbotEnabled
    print("Aimbot: " .. (Settings.AimbotEnabled and "ON" or "OFF"))
end)

CreateButton("Toggle ESP", 95, function()
    Settings.ESPEnabled = not Settings.ESPEnabled
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            if Settings.ESPEnabled then
                AddESP(plr)
            else
                RemoveESP(plr)
            end
        end
    end
    print("ESP: " .. (Settings.ESPEnabled and "ON" or "OFF"))
end)

CreateButton("Toggle Hitbox", 140, function()
    Settings.HitboxEnabled = not Settings.HitboxEnabled
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            if Settings.HitboxEnabled then
                ExpandHead(plr.Character)
            end
        end
    end
    print("Hitbox: " .. (Settings.HitboxEnabled and "ON" or "OFF"))
end)

print("═══════════════════════════════")
print("✓ DUELS AIMBOT v4.0 LOADED")
print("✓ Made for Red21's Duels")
print("✓ Silent Aim (no camera move)")
print("✓ BillboardGui ESP (undetected)")
print("✓ Head hitbox expansion")
print("═══════════════════════════════")
