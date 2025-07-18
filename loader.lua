-- HCBB Utility with Rayfield UI

local Rayfield = loadstring(game:HttpGet("https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/source.lua"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

-- State variables
local walkSpeed = 16
local jumpPower = 50
local walkSpeedLoop = false
local jumpPowerLoop = false
local noclipEnabled = false
local flyEnabled = false
local flySpeed = 30

local autoAimEnabled = false
local autoHitEnabled = false
local perfectAim = false
local magBallEnabled = false
local offsetX = 10
local offsetY = 10

local pitchPredictionEnabled = false
local strikeZoneVisible = false
local strikeZoneBox = nil

-- Fly helper vars
local flying = false

-- Pitch prediction box setup
local function createStrikeZoneBox()
    if strikeZoneBox then strikeZoneBox:Destroy() end
    strikeZoneBox = Instance.new("BoxHandleAdornment")
    strikeZoneBox.Size = Vector3.new(4,4,4)
    strikeZoneBox.Transparency = 0.7
    strikeZoneBox.Color3 = Color3.fromRGB(0,255,255)
    strikeZoneBox.AlwaysOnTop = true
    strikeZoneBox.ZIndex = 10
    local plate = Workspace:FindFirstChild("HomePlate") or Workspace:FindFirstChild("StrikeZone")
    if plate then
        strikeZoneBox.Adornee = plate
        strikeZoneBox.Parent = plate
    else
        strikeZoneBox.Adornee = Workspace.Terrain
        strikeZoneBox.Parent = Workspace.Terrain
    end
end

local function destroyStrikeZoneBox()
    if strikeZoneBox then
        strikeZoneBox:Destroy()
        strikeZoneBox = nil
    end
end

-- Create Rayfield UI window
local Window = Rayfield:CreateWindow({
    Name = "⚾ HCBB Utility (Rayfield)",
    LoadingTitle = "Loading HCBB Utility",
    LoadingSubtitle = "by YourNameHere",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "HCBB_Configs",
        FileName = "Config"
    },
    Discord = {
        Enabled = false,
    },
    KeySystem = false,
})

-- Movement Tab
local MovementTab = Window:CreateTab("Movement")

MovementTab:CreateSlider({
    Name = "WalkSpeed",
    Range = {16, 29},
    Increment = 1,
    Suffix = "",
    CurrentValue = 16,
    Flag = "walkSpeedSlider",
    Callback = function(value)
        walkSpeed = value
    end,
})

MovementTab:CreateToggle({
    Name = "Loop WalkSpeed",
    CurrentValue = false,
    Flag = "walkSpeedLoopToggle",
    Callback = function(value)
        walkSpeedLoop = value
    end,
})

MovementTab:CreateSlider({
    Name = "JumpPower",
    Range = {50, 65},
    Increment = 1,
    Suffix = "",
    CurrentValue = 50,
    Flag = "jumpPowerSlider",
    Callback = function(value)
        jumpPower = value
    end,
})

MovementTab:CreateToggle({
    Name = "Loop JumpPower",
    CurrentValue = false,
    Flag = "jumpPowerLoopToggle",
    Callback = function(value)
        jumpPowerLoop = value
    end,
})

MovementTab:CreateToggle({
    Name = "Noclip",
    CurrentValue = false,
    Flag = "noclipToggle",
    Callback = function(value)
        noclipEnabled = value
    end,
})

MovementTab:CreateToggle({
    Name = "Fly",
    CurrentValue = false,
    Flag = "flyToggle",
    Callback = function(value)
        flyEnabled = value
        flying = value
        if not flying and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            LocalPlayer.Character.Humanoid.PlatformStand = false
        end
    end,
})

MovementTab:CreateSlider({
    Name = "Fly Speed",
    Range = {1, 50},
    Increment = 1,
    Suffix = "",
    CurrentValue = 30,
    Flag = "flySpeedSlider",
    Callback = function(value)
        flySpeed = value
    end,
})

-- Auto Aim & Hit Tab
local AimTab = Window:CreateTab("Auto Aim & Hit")

AimTab:CreateToggle({
    Name = "Auto Aim",
    CurrentValue = false,
    Flag = "autoAimToggle",
    Callback = function(value)
        autoAimEnabled = value
    end,
})

AimTab:CreateSlider({
    Name = "Offset X",
    Range = {-20, 100},
    Increment = 1,
    Suffix = "",
    CurrentValue = 10,
    Flag = "offsetXSlider",
    Callback = function(value)
        offsetX = value
    end,
})

AimTab:CreateSlider({
    Name = "Offset Y",
    Range = {-20, 100},
    Increment = 1,
    Suffix = "",
    CurrentValue = 10,
    Flag = "offsetYSlider",
    Callback = function(value)
        offsetY = value
    end,
})

AimTab:CreateToggle({
    Name = "Auto Hit (Left Click)",
    CurrentValue = false,
    Flag = "autoHitToggle",
    Callback = function(value)
        autoHitEnabled = value
    end,
})

AimTab:CreateToggle({
    Name = "Perfect Aim (Auto Align Bat)",
    CurrentValue = false,
    Flag = "perfectAimToggle",
    Callback = function(value)
        perfectAim = value
    end,
})

AimTab:CreateToggle({
    Name = "Mag Ball (Pull Ball to You)",
    CurrentValue = false,
    Flag = "magBallToggle",
    Callback = function(value)
        magBallEnabled = value
    end,
})

-- Pitch Prediction Tab
local PitchTab = Window:CreateTab("Pitch Prediction")

PitchTab:CreateToggle({
    Name = "Enable Pitch Prediction",
    CurrentValue = false,
    Flag = "pitchPredictionToggle",
    Callback = function(value)
        pitchPredictionEnabled = value
        if value and strikeZoneVisible then
            createStrikeZoneBox()
        else
            destroyStrikeZoneBox()
        end
    end,
})

PitchTab:CreateToggle({
    Name = "Show Strike Zone",
    CurrentValue = false,
    Flag = "strikeZoneToggle",
    Callback = function(value)
        strikeZoneVisible = value
        if value and pitchPredictionEnabled then
            createStrikeZoneBox()
        else
            destroyStrikeZoneBox()
        end
    end,
})

-- Other Tab
local OtherTab = Window:CreateTab("Other")

OtherTab:CreateButton({
    Name = "Unload Script",
    Callback = function()
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.WalkSpeed = 16
                hum.JumpPower = 50
                hum.PlatformStand = false
            end
            for _, part in pairs(char:GetChildren()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
        noclipEnabled = false
        flyEnabled = false
        autoAimEnabled = false
        autoHitEnabled = false
        perfectAim = false
        magBallEnabled = false
        pitchPredictionEnabled = false
        strikeZoneVisible = false
        destroyStrikeZoneBox()
        local ball = Workspace:FindFirstChild("Ball")
        if ball then
            local magnet = ball:FindFirstChild("MagnetForce")
            if magnet then magnet:Destroy() end
        end
        Rayfield:Destroy()
    end,
})

-- Run loops to enforce movement and features

RunService.Heartbeat:Connect(function(delta)
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hum or not hrp then return end

    -- WalkSpeed enforcement
    if walkSpeedLoop then
        if hum.WalkSpeed ~= walkSpeed then
            hum.WalkSpeed = walkSpeed
        end
    else
        if hum.WalkSpeed ~= 16 then
            hum.WalkSpeed = 16
        end
    end

    -- JumpPower enforcement
    if jumpPowerLoop then
        if hum.JumpPower ~= jumpPower then
            hum.JumpPower = jumpPower
        end
    else
        if hum.JumpPower ~= 50 then
            hum.JumpPower = 50
        end
    end

    -- Noclip toggle
    if noclipEnabled then
        for _, part in pairs(char:GetChildren()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    else
        for _, part in pairs(char:GetChildren()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end

    -- Fly toggle
    if flyEnabled then
        if not flying then flying = true end
        hum.PlatformStand = true

        local moveDir = Vector3.new(0,0,0)
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            moveDir = moveDir + hrp.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            moveDir = moveDir - hrp.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            moveDir = moveDir - hrp.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            moveDir = moveDir + hrp.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            moveDir = moveDir + Vector3.new(0,1,0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            moveDir = moveDir - Vector3.new(0,1,0)
        end

        if moveDir.Magnitude > 0 then
            moveDir = moveDir.Unit * flySpeed * delta
            hrp.CFrame = hrp.CFrame + moveDir
        end
    else
        if flying then
            flying = false
            if hum then
                hum.PlatformStand = false
            end
        end
    end
end)

-- Auto Aim, Perfect Aim, Mag Ball logic on RenderStepped
RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    local ball = Workspace:FindFirstChild("Ball")
    if not char or not ball then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    -- Auto Aim: rotate hrp to face ball plus offset
    if autoAimEnabled then
        local targetPos = ball.Position + Vector3.new(offsetX, offsetY, 0)
        local lookVector = (targetPos - hrp.Position)
        if lookVector.Magnitude > 0 then
            local newLook = Vector3.new(lookVector.X, 0, lookVector.Z).Unit
            hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + newLook)
        end
    end

    -- Perfect Aim: align tool handle to face ball
    if perfectAim then
        local tool = char:FindFirstChildOfClass("Tool")
        if tool and tool:FindFirstChild("Handle") then
            local handle = tool.Handle
            local direction = (ball.Position - handle.Position).Unit
            handle.CFrame = CFrame.new(handle.Position, handle.Position + direction)
        end
    end

    -- Mag Ball: pull ball to player
    if magBallEnabled then
        local magnet = ball:FindFirstChild("MagnetForce")
        if not magnet then
            magnet = Instance.new("BodyPosition")
            magnet.Name = "MagnetForce"
            magnet.MaxForce = Vector3.new(1e5, 1e5, 1e5)
            magnet.P = 1e4
            magnet.Parent = ball
        end
        magnet.Position = hrp.Position + Vector3.new(0, 3, 0)
    else
        local magnet = ball:FindFirstChild("MagnetForce")
        if magnet then
            magnet:Destroy()
        end
    end
end)

-- Auto Hit loop (safe mouse clicks)
task.spawn(function()
    while true do
        if autoHitEnabled then
            local char = LocalPlayer.Character
            local ball = Workspace:FindFirstChild("Ball")
            if char and ball and char:FindFirstChild("HumanoidRootPart") and (ball.Position - char.HumanoidRootPart.Position).Magnitude < 30 then
                if syn and syn.mouse1click then
                    syn.mouse1click()
                elseif mouse1click then
                    mouse1click()
                elseif mouse1press and mouse1release then
                    mouse1press()
                    task.wait(0.1)
                    mouse1release()
                end
            end
        end
        task.wait(0.1)
    end
end)
