-- AutoFarm | Fluent Library Edition
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer

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

-- Load Fluent Library
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- Create Window
local Window = Fluent:CreateWindow({
    Title = "AutoFarm",
    SubTitle = "made by beraatwr",
    TabWidth = 160,
    Size = UDim2.fromOffset(520, 320),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

-- Tabs
local Tabs = {
    Main = Window:AddTab({ Title = "AutoFarm", Icon = "zap" }),
    Misc = Window:AddTab({ Title = "Misc", Icon = "info" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

-- Separator
Tabs.Main:AddParagraph({
    Title = "⚡ AutoFarm",
    Content = "Teleports your character through all " .. #positions .. " checkpoints automatically. Use the toggle below to start or stop farming."
})

-- Toggle
local FarmToggle = Tabs.Main:AddToggle("FarmToggle", {
    Title = "Auto Farm",
    Description = "Start or stop automatic checkpoint farming",
    Default = false
})

-- Live status label (updated via paragraph trick)
local LiveStatus = Tabs.Main:AddParagraph({
    Title = "Live Status",
    Content = "🔴 Idle"
})

local LiveCheckpoint = Tabs.Main:AddParagraph({
    Title = "Progress",
    Content = "Waiting to start..."
})

-- Farm Logic
local function runFarm()
    while farmingActive do
        local ok, err = pcall(function()
            for i, pos in ipairs(positions) do
                if not farmingActive then return end

                -- Update live progress
                if LiveCheckpoint then
                    LiveCheckpoint:SetDesc(string.format("Checkpoint %d / %d", i, #positions))
                end

                local platform = createPlatform(pos)
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
            if LiveCheckpoint then
                LiveCheckpoint:SetDesc("⚠️ Error occurred, retrying...")
            end
            task.wait(1)
        end

        if farmingActive then
            if LiveCheckpoint then
                LiveCheckpoint:SetDesc("✅ Loop complete! Waiting 14s before next loop...")
            end
            task.wait(14)
        end
    end
end

-- Toggle Handler
FarmToggle:OnChanged(function(value)
    farmingActive = value

    if value then
        -- Start
        if LiveStatus then
            LiveStatus:SetDesc("🟢 Running")
        end
        farmThread = task.spawn(runFarm)
    else
        -- Stop
        if LiveStatus then
            LiveStatus:SetDesc("🔴 Idle")
        end
        if LiveCheckpoint then
            LiveCheckpoint:SetDesc("Waiting to start...")
        end
    end
end)

-- Teleport to specific checkpoint button
Tabs.Main:AddButton({
    Title = "Skip to Last Checkpoint",
    Description = "Instantly teleport to checkpoint #" .. #positions,
    Callback = function()
        local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            local platform = createPlatform(positions[#positions])
            hrp.CFrame = CFrame.new(positions[#positions])
            task.delay(2, function()
                if platform and platform.Parent then
                    platform:Destroy()
                end
            end)
            Fluent:Notify({
                Title = "Teleported",
                Content = "Moved to final checkpoint #" .. #positions,
                Duration = 3
            })
        else
            Fluent:Notify({
                Title = "Error",
                Content = "Character not found!",
                Duration = 3
            })
        end
    end
})

-- Settings Tab
InterfaceManager:SetLibrary(Fluent)
SaveManager:SetLibrary(Fluent)

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

-- Save / Load config
SaveManager:SetFolder("AutoFarmFluent")
SaveManager:SetConfig("Default")
SaveManager:LoadAutoloadConfig()

-- Select default tab
Window:SelectTab(1)

-- Notify on load
Fluent:Notify({
    Title = "AutoFarm Loaded",
    Content = "Press Left Ctrl to toggle the UI. Use the toggle to start farming.",
    Duration = 5
})
