-- Load Rayfield UI
local Rayfield = loadstring(game:HttpGet("https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/source.lua"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

-- Chat stuff
local ChatEvents = ReplicatedStorage:WaitForChild("DefaultChatSystemChatEvents")
local SayMessageRequest = ChatEvents:WaitForChild("SayMessageRequest")

-- State variables
local walkSpeed = 16
local jumpPower = 50
local hipHeight = 2
local walkSpeedEnabled = false
local jumpPowerEnabled = false

local flyEnabled = false
local flySpeed = 30
local flyUp = false
local flyDown = false

local autoAimEnabled = false
local autoHitEnabled = false
local perfectAim = false
local magBallEnabled = false
local offsetX, offsetY = 10, 10

local strikeZoneVisible = false
local strikeZoneBox = nil
local ballHighlightBox = nil

-- Projection parts list
local projectionParts = {}

-- Trash talk messages
local trashTalkMessages = {
    "You can't hit nun",
    "Knowledge of a 3rd grader",
    "Your BA is probably -100",
    "Can't blame ping on that one son",
    "Get better",
    "Womp womp",
    "IQ of a Packet Loss",
    "Rando Pooron",
    "Swing and a miss!",
    "Better luck next time!",
    "You’re batting .000 in my heart",
    "Is that all you got?",
    "Practice makes perfect — you’re practicing?",
    "Welcome to my highlight reel!",
}

local function sendTrashTalk()
    local message = trashTalkMessages[math.random(1, #trashTalkMessages)]
    SayMessageRequest:FireServer(message, "All")
end

-- Get strike zone adornee from ReplicatedStorage or Workspace fallback
local function GetStrikeZoneAdornee()
    local hrdGui = ReplicatedStorage:FindFirstChild("HRDGui")
    if hrdGui then
        local swingZone = hrdGui:FindFirstChild("SwingZone")
        if swingZone and (swingZone:IsA("BasePart") or swingZone:IsA("Model")) then
            return swingZone
        end
    end
    local plate = Workspace:FindFirstChild("HomePlate") or Workspace:FindFirstChild("StrikeZone")
    if plate then
        return plate
    end
    return Workspace.Terrain
end

-- Updates or creates the strike zone box adornment
local function UpdateStrikeZoneBox()
    if strikeZoneVisible then
        if not strikeZoneBox then
            strikeZoneBox = Instance.new("BoxHandleAdornment")
            strikeZoneBox.Size = Vector3.new(4, 4, 4)
            strikeZoneBox.Transparency = 0.7
            strikeZoneBox.Color3 = Color3.fromRGB(0, 255, 255)
            strikeZoneBox.AlwaysOnTop = true
            strikeZoneBox.ZIndex = 10
            strikeZoneBox.Adornee = GetStrikeZoneAdornee()
            strikeZoneBox.Parent = strikeZoneBox.Adornee
        end
    else
        if strikeZoneBox then
            strikeZoneBox:Destroy()
            strikeZoneBox = nil
        end
    end
end

-- Creates box adornment to highlight the ball
local function CreateBallHighlight()
    local ball = Workspace:FindFirstChild("Ball")
    if ball and not ballHighlightBox then
        ballHighlightBox = Instance.new("BoxHandleAdornment")
        ballHighlightBox.Size = ball.Size + Vector3.new(0.5, 0.5, 0.5)
        ballHighlightBox.Transparency = 0.5
        ballHighlightBox.Color3 = Color3.fromRGB(255, 100, 100)
        ballHighlightBox.AlwaysOnTop = true
        ballHighlightBox.ZIndex = 15
        ballHighlightBox.Adornee = ball
        ballHighlightBox.Parent = ball
    end
end

local function UpdateBallHighlight()
    local ball = Workspace:FindFirstChild("Ball")
    if ball then
        if not ballHighlightBox or ballHighlightBox.Adornee ~= ball then
            if ballHighlightBox then ballHighlightBox:Destroy() end
            CreateBallHighlight()
        end
        -- Update size smoothly if needed
        ballHighlightBox.Size = ball.Size + Vector3.new(0.5, 0.5, 0.5)
    else
        if ballHighlightBox then
            ballHighlightBox:Destroy()
            ballHighlightBox = nil
        end
    end
end

-- Creates neon parts for projection path visualization
local function CreateProjectionParts()
    for i = 1, 30 do
        local part = Instance.new("Part")
        part.Anchored = true
        part.CanCollide = false
        part.Material = Enum.Material.Neon
        part.Size = Vector3.new(0.3, 0.3, 0.3)
        part.Transparency = 0.6
        part.Color = Color3.fromRGB(0, 255, 255)
        part.Name = "ProjectionPart"
        part.Parent = Workspace
        projectionParts[i] = part
    end
end

-- Updates projection parts positions based on ball velocity and gravity
local function UpdateProjectionParts()
    local ball = Workspace:FindFirstChild("Ball")
    if not ball or not ball.Velocity then
        for _, part in pairs(projectionParts) do
            part.Transparency = 1
        end
        return
    end

    local gravity = Workspace.Gravity
    local startPos = ball.Position
    local velocity = ball.Velocity

    for i = 1, #projectionParts do
        local t = i * 0.1
        -- s = ut + 0.5at^2, vertical with gravity on Y
        local pos = startPos + velocity * t + Vector3.new(0, -0.5 * gravity * t * t, 0)
        projectionParts[i].Position = pos
        projectionParts[i].Transparency = 0.6
    end
end

-- Fly movement logic with CFrame using camera look vector (including vertical)
local function FlyMovement(delta)
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local cam = workspace.CurrentCamera
    if not cam then return end

    local moveVec = Vector3.new(0,0,0)
    if flyUp then
        moveVec = moveVec + Vector3.new(0, 1, 0)
    end
    if flyDown then
        moveVec = moveVec + Vector3.new(0, -1, 0)
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then
        moveVec = moveVec + cam.CFrame.LookVector
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then
        moveVec = moveVec - cam.CFrame.LookVector
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then
        moveVec = moveVec - cam.CFrame.RightVector
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then
        moveVec = moveVec + cam.CFrame.RightVector
    end

    if moveVec.Magnitude > 0 then
        moveVec = moveVec.Unit * flySpeed * delta
        hrp.CFrame = hrp.CFrame + moveVec
    end
end

-- Auto aim logic: smoothly rotate humanoid root part to face ball + offsets
local function AutoAim()
    if not autoAimEnabled then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local ball = Workspace:FindFirstChild("Ball")
    if not hrp or not ball then return end

    local targetPos = ball.Position + Vector3.new(offsetX, offsetY, 0)
    local lookDir = (targetPos - hrp.Position)
    lookDir = Vector3.new(lookDir.X, 0, lookDir.Z).Unit
    local newCFrame = CFrame.new(hrp.Position, hrp.Position + lookDir)
    hrp.CFrame = hrp.CFrame:Lerp(newCFrame, 0.3)
end

-- Mag Ball pulls the ball to player's position
local function MagBall()
    if not magBallEnabled then return end
    local ball = Workspace:FindFirstChild("Ball")
    local char = LocalPlayer.Character
    if not ball or not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local bodyPos = ball:FindFirstChild("MagBodyPosition")
    if not bodyPos then
        bodyPos = Instance.new("BodyPosition")
        bodyPos.Name = "MagBodyPosition"
        bodyPos.MaxForce = Vector3.new(1e5, 1e5, 1e5)
        bodyPos.P = 3000
        bodyPos.D = 100
        bodyPos.Parent = ball
    end

    bodyPos.Position = hrp.Position + Vector3.new(0, 3, 0)
end

-- Remove mag ball effect if disabled
local function RemoveMagBall()
    local ball = Workspace:FindFirstChild("Ball")
    if ball then
        local bp = ball:FindFirstChild("MagBodyPosition")
        if bp then bp:Destroy() end
    end
end

-- Swing bat function (detects bat tool in backpack or character, then triggers swing)
local function SwingBat()
    local char = LocalPlayer.Character
    if not char then return end

    -- Try tool in hand
    local tool = char:FindFirstChildOfClass("Tool")
    if not tool then
        -- Try backpack
        local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
        if backpack then
            for _, t in ipairs(backpack:GetChildren()) do
                if t:IsA("Tool") and string.find(t.Name:lower(), "bat") then
                    tool = t
                    break
                end
            end
        end
    end

    if tool and tool:FindFirstChild("Swing") and tool.Swing:IsA("RemoteEvent") then
        -- Fire remote to swing (if exists)
        tool.Swing:FireServer()
    else
        -- Otherwise try to activate tool normally
        if tool and tool.Activate then
            tool:Activate()
        end
    end
end

-- Auto hit function (left click simulation or tool swing)
local function AutoHit()
    if not autoHitEnabled then return end
    local ball = Workspace:FindFirstChild("Ball")
    local char = LocalPlayer.Character
    if not ball or not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local dist = (ball.Position - hrp.Position).Magnitude
    if dist < 30 then
        -- Swing bat automatically when close
        SwingBat()
    end
end

-- Input handling for fly up/down keys and left click for swing
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Space then
        flyUp = true
    elseif input.KeyCode == Enum.KeyCode.LeftControl or input.KeyCode == Enum.KeyCode.C then
        flyDown = true
    elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
        if autoHitEnabled then
            SwingBat()
        end
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.Space then
        flyUp = false
    elseif input.KeyCode == Enum.KeyCode.LeftControl or input.KeyCode == Enum.KeyCode.C then
        flyDown = false
    end
end)

-- Setup Rayfield UI window and tabs
local Window = Rayfield:CreateWindow({
    Name = "⚾ HCBB Utility",
    LoadingTitle = "Loading HCBB Utility",
    LoadingSubtitle = "by Kai",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = nil,
        FileName = "HCBBConfig"
    }
})

-- Movement Tab
local MovementTab = Window:CreateTab("Movement", 4483345998)
MovementTab:CreateSlider({
    Name = "WalkSpeed",
    Range = {16, 30},
    Increment = 1,
    Suffix = "WalkSpeed",
    CurrentValue = walkSpeed,
    Flag = "WalkSpeed",
    Callback = function(value)
        walkSpeed = value
    end
})
MovementTab:CreateToggle({
    Name = "Enable WalkSpeed",
    CurrentValue = walkSpeedEnabled,
    Flag = "WalkSpeedToggle",
    Callback = function(value)
        walkSpeedEnabled = value
        if not value then
            local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = 16 end
        end
    end
})
MovementTab:CreateSlider({
    Name = "JumpPower",
    Range = {50, 100},
    Increment = 1,
    Suffix = "JumpPower",
    CurrentValue = jumpPower,
    Flag = "JumpPower",
    Callback = function(value)
        jumpPower = value
    end
})
MovementTab:CreateToggle({
    Name = "Enable JumpPower",
    CurrentValue = jumpPowerEnabled,
    Flag = "JumpPowerToggle",
    Callback = function(value)
        jumpPowerEnabled = value
        if not value then
            local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.JumpPower = 50 end
        end
    end
})
MovementTab:CreateSlider({
    Name = "HipHeight",
    Range = {0, 10},
    Increment = 0.1,
    Suffix = "studs",
    CurrentValue = hipHeight,
    Flag = "HipHeight",
    Callback = function(value)
        hipHeight = value
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.HipHeight = hipHeight end
    end
})

-- Fly Tab
local FlyTab = Window:CreateTab("Fly", 4483345998)
FlyTab:CreateToggle({
    Name = "Enable Fly",
    CurrentValue = flyEnabled,
    Flag = "FlyToggle",
    Callback = function(value)
        flyEnabled = value
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.PlatformStand = value
        end
        if not value then
            -- Reset fly movement state
            flyUp = false
            flyDown = false
        end
    end
})
FlyTab:CreateSlider({
    Name = "Fly Speed",
    Range = {1, 50},
    Increment = 1,
    Suffix = "speed",
    CurrentValue = flySpeed,
    Flag = "FlySpeed",
    Callback = function(value)
        flySpeed = value
    end
})

-- Auto Aim & Hit Tab
local AimTab = Window:CreateTab("Auto Aim & Hit", 4483345998)
AimTab:CreateToggle({
    Name = "Auto Aim",
    CurrentValue = autoAimEnabled,
    Flag = "AutoAim",
    Callback = function(value)
        autoAimEnabled = value
    end
})
AimTab:CreateSlider({
    Name = "Offset X",
    Range = {-20, 100},
    Increment = 1,
    Suffix = "offset",
    CurrentValue = offsetX,
    Flag = "OffsetX",
    Callback = function(value)
        offsetX = value
    end
})
AimTab:CreateSlider({
    Name = "Offset Y",
    Range = {-20, 100},
    Increment = 1,
    Suffix = "offset",
    CurrentValue = offsetY,
    Flag = "OffsetY",
    Callback = function(value)
        offsetY = value
    end
})
AimTab:CreateToggle({
    Name = "Auto Hit (Left Click)",
    CurrentValue = autoHitEnabled,
    Flag = "AutoHit",
    Callback = function(value)
        autoHitEnabled = value
    end
})
AimTab:CreateToggle({
    Name = "Perfect Aim (Auto Align Bat)",
    CurrentValue = perfectAim,
    Flag = "PerfectAim",
    Callback = function(value)
        perfectAim = value
    end
})
AimTab:CreateToggle({
    Name = "Mag Ball (Pull Ball to You)",
    CurrentValue = magBallEnabled,
    Flag = "MagBall",
    Callback = function(value)
        magBallEnabled = value
        if not value then
            RemoveMagBall()
        end
    end
})
AimTab:CreateToggle({
    Name = "Show Strike Zone",
    CurrentValue = strikeZoneVisible,
    Flag = "ShowStrikeZone",
    Callback = function(value)
        strikeZoneVisible = value
        UpdateStrikeZoneBox()
    end
})

-- Trash Talk Tab
local TrashTab = Window:CreateTab("Trash Talk", 4483345998)
TrashTab:CreateButton({
    Name = "Send Trash Talk",
    Callback = function()
        sendTrashTalk()
    end
})

-- RunService Heartbeat loop for updates
RunService.Heartbeat:Connect(function(delta)
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hum or not hrp then return end

    -- WalkSpeed
    if walkSpeedEnabled and hum.WalkSpeed ~= walkSpeed then
        hum.WalkSpeed = walkSpeed
    elseif not walkSpeedEnabled and hum.WalkSpeed ~= 16 then
        hum.WalkSpeed = 16
    end

    -- JumpPower
    if jumpPowerEnabled and hum.JumpPower ~= jumpPower then
        hum.JumpPower = jumpPower
    elseif not jumpPowerEnabled and hum.JumpPower ~= 50 then
        hum.JumpPower = 50
    end

    -- HipHeight
    if hum.HipHeight ~= hipHeight then
        hum.HipHeight = hipHeight
    end

    -- Fly logic
    if flyEnabled then
        FlyMovement(delta)
    end

    -- Update ball highlight and projection
    UpdateBallHighlight()
    if strikeZoneVisible then
        UpdateProjectionParts()
    end

    -- Auto aim
    AutoAim()

    -- Mag ball
    MagBall()
end)

-- Auto Hit loop
task.spawn(function()
    while true do
        AutoHit()
        task.wait(0.1)
    end
end)

-- Input for fly up/down and swing already set above

-- Character Added handler
LocalPlayer.CharacterAdded:Connect(function(char)
    local hum = char:WaitForChild("Humanoid", 10)
    if hum then
        hum.PlatformStand = flyEnabled
        hum.WalkSpeed = walkSpeedEnabled and walkSpeed or 16
        hum.JumpPower = jumpPowerEnabled and jumpPower or 50
        hum.HipHeight = hipHeight
    end
end)

-- Initial character setup
do
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.PlatformStand = flyEnabled
            hum.WalkSpeed = walkSpeedEnabled and walkSpeed or 16
            hum.JumpPower = jumpPowerEnabled and jumpPower or 50
            hum.HipHeight = hipHeight
        end
    end
end

-- Create initial projection parts
CreateProjectionParts()
