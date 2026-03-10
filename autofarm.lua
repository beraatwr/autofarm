-- AutoFarm GUI | Fluent Style
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- State
local farmingActive = false
local farmThread = nil

-- Positions
local positions = {
    Vector3.new(-65.00, 87.06, 1111.16),
    Vector3.new(-62.09, 69.48, 1369.88),
    Vector3.new(-56.87, 50.03, 2141.06),
    Vector3.new(-52.26, 82.51, 2531.64),
    Vector3.new(-50.92, 67.58, 2915.75),
    Vector3.new(-52.11, 70.76, 3355.92),
    Vector3.new(-40.52, 68.17, 3670.37),
    Vector3.new(-46.34, 55.46, 4117.53),
    Vector3.new(-44.82, 69.54, 4444.41),
    Vector3.new(-51.01, 19.28, 5216.232),
    Vector3.new(-51.15, 25.33, 5990.34),
    Vector3.new(-48.15, 69.66, 6458.56),
    Vector3.new(-52.21, 82.99, 6751.03),
    Vector3.new(-51.79, 32.31, 7274.15),
    Vector3.new(-79.17, 34.59, 7526.87),
    Vector3.new(-55.33, 46.38, 8299.41),
    Vector3.new(-51.21, -310.98, 8821.36),
    Vector3.new(-55.84, -348.82, 9486.40)
}

-- Helper Functions
local function getCharacter()
    local character = player.Character or player.CharacterAdded:Wait()
    return character:WaitForChild("HumanoidRootPart")
end

local function createPlatform(position)
    local platform = Instance.new("Part")
    platform.Size = Vector3.new(6, 1, 6)
    platform.Anchored = true
    platform.CanCollide = true
    platform.Position = position - Vector3.new(0, 3, 0)
    platform.Transparency = 1
    platform.Name = "TempPlatform"
    platform.Parent = workspace
    return platform
end

-- GUI Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AutoFarmGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = playerGui

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 280, 0, 160)
MainFrame.Position = UDim2.new(0, 20, 0.5, -80)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

-- Outer glow stroke
local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(60, 60, 60)
MainStroke.Thickness = 1.2
MainStroke.Transparency = 0.4
MainStroke.Parent = MainFrame

-- Top accent bar
local AccentBar = Instance.new("Frame")
AccentBar.Size = UDim2.new(1, 0, 0, 3)
AccentBar.Position = UDim2.new(0, 0, 0, 0)
AccentBar.BackgroundColor3 = Color3.fromRGB(220, 220, 220)
AccentBar.BorderSizePixel = 0
AccentBar.ZIndex = 3
AccentBar.Parent = MainFrame

local AccentCorner = Instance.new("UICorner")
AccentCorner.CornerRadius = UDim.new(0, 12)
AccentCorner.Parent = AccentBar

-- Header
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 44)
Header.Position = UDim2.new(0, 0, 0, 3)
Header.BackgroundTransparency = 1
Header.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -50, 1, 0)
TitleLabel.Position = UDim2.new(0, 16, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "⚡  AutoFarm"
TitleLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
TitleLabel.TextSize = 15
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = Header

local SubLabel = Instance.new("TextLabel")
SubLabel.Size = UDim2.new(1, -50, 0, 14)
SubLabel.Position = UDim2.new(0, 16, 0, 26)
SubLabel.BackgroundTransparency = 1
SubLabel.Text = "Checkpoint Runner"
SubLabel.TextColor3 = Color3.fromRGB(120, 120, 120)
SubLabel.TextSize = 11
SubLabel.Font = Enum.Font.Gotham
SubLabel.TextXAlignment = Enum.TextXAlignment.Left
SubLabel.Parent = MainFrame

-- Divider
local Divider = Instance.new("Frame")
Divider.Size = UDim2.new(1, -32, 0, 1)
Divider.Position = UDim2.new(0, 16, 0, 54)
Divider.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Divider.BorderSizePixel = 0
Divider.Parent = MainFrame

-- Status Indicator
local StatusDot = Instance.new("Frame")
StatusDot.Size = UDim2.new(0, 8, 0, 8)
StatusDot.Position = UDim2.new(0, 16, 0, 74)
StatusDot.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
StatusDot.BorderSizePixel = 0
StatusDot.Parent = MainFrame

local DotCorner = Instance.new("UICorner")
DotCorner.CornerRadius = UDim.new(1, 0)
DotCorner.Parent = StatusDot

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -36, 0, 16)
StatusLabel.Position = UDim2.new(0, 30, 0, 70)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Idle"
StatusLabel.TextColor3 = Color3.fromRGB(120, 120, 120)
StatusLabel.TextSize = 12
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.Parent = MainFrame

-- Checkpoint Progress Label
local ProgressLabel = Instance.new("TextLabel")
ProgressLabel.Size = UDim2.new(1, -16, 0, 14)
ProgressLabel.Position = UDim2.new(0, 16, 0, 92)
ProgressLabel.BackgroundTransparency = 1
ProgressLabel.Text = "Checkpoint: —"
ProgressLabel.TextColor3 = Color3.fromRGB(90, 90, 90)
ProgressLabel.TextSize = 11
ProgressLabel.Font = Enum.Font.Gotham
ProgressLabel.TextXAlignment = Enum.TextXAlignment.Left
ProgressLabel.Parent = MainFrame

-- Toggle Button
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(1, -32, 0, 36)
ToggleBtn.Position = UDim2.new(0, 16, 0, 112)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
ToggleBtn.BorderSizePixel = 0
ToggleBtn.Text = "Start"
ToggleBtn.TextColor3 = Color3.fromRGB(210, 210, 210)
ToggleBtn.TextSize = 13
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.AutoButtonColor = false
ToggleBtn.Parent = MainFrame

local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(0, 8)
BtnCorner.Parent = ToggleBtn

local BtnStroke = Instance.new("UIStroke")
BtnStroke.Color = Color3.fromRGB(70, 70, 70)
BtnStroke.Thickness = 1
BtnStroke.Transparency = 0.5
BtnStroke.Parent = ToggleBtn

-- Tween helpers
local function tweenColor(obj, prop, color, t)
    TweenService:Create(obj, TweenInfo.new(t or 0.25), {[prop] = color}):Play()
end

local function setActive(active)
    if active then
        tweenColor(StatusDot, "BackgroundColor3", Color3.fromRGB(220, 220, 220), 0.3)
        tweenColor(StatusLabel, "TextColor3", Color3.fromRGB(210, 210, 210), 0.3)
        tweenColor(ToggleBtn, "BackgroundColor3", Color3.fromRGB(40, 40, 40), 0.3)
        tweenColor(ToggleBtn, "TextColor3", Color3.fromRGB(240, 240, 240), 0.3)
        BtnStroke.Color = Color3.fromRGB(180, 180, 180)
        StatusLabel.Text = "Running"
        ToggleBtn.Text = "Stop"
    else
        tweenColor(StatusDot, "BackgroundColor3", Color3.fromRGB(80, 80, 80), 0.3)
        tweenColor(StatusLabel, "TextColor3", Color3.fromRGB(120, 120, 120), 0.3)
        tweenColor(ToggleBtn, "BackgroundColor3", Color3.fromRGB(28, 28, 28), 0.3)
        tweenColor(ToggleBtn, "TextColor3", Color3.fromRGB(210, 210, 210), 0.3)
        BtnStroke.Color = Color3.fromRGB(70, 70, 70)
        StatusLabel.Text = "Idle"
        ToggleBtn.Text = "Start"
        ProgressLabel.Text = "Checkpoint: —"
    end
end

-- Button hover effects
ToggleBtn.MouseEnter:Connect(function()
    if not farmingActive then
        tweenColor(ToggleBtn, "BackgroundColor3", Color3.fromRGB(45, 45, 45), 0.15)
    end
end)
ToggleBtn.MouseLeave:Connect(function()
    if not farmingActive then
        tweenColor(ToggleBtn, "BackgroundColor3", Color3.fromRGB(28, 28, 28), 0.15)
    end
end)

-- Farm Logic
local function runFarm()
    while farmingActive do
        local ok, err = pcall(function()
            local hrp = getCharacter()
            for i, pos in ipairs(positions) do
                if not farmingActive then return end
                ProgressLabel.Text = string.format("Checkpoint: %d / %d", i, #positions)
                local platform = createPlatform(pos)
                -- re-get hrp each teleport in case of respawn
                local currentHrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                if currentHrp then
                    currentHrp.CFrame = CFrame.new(pos)
                end
                task.wait(1.5)
                if platform and platform.Parent then
                    platform:Destroy()
                end
            end
        end)
        if not ok then
            ProgressLabel.Text = "Retrying..."
            task.wait(1)
        end
        if farmingActive then
            ProgressLabel.Text = "Loop complete, waiting..."
            task.wait(14)
        end
    end
end

-- Toggle
ToggleBtn.MouseButton1Click:Connect(function()
    farmingActive = not farmingActive
    setActive(farmingActive)
    if farmingActive then
        farmThread = task.spawn(runFarm)
    end
end)
