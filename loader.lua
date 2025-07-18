-- Load Rayfield UI
local Rayfield = loadstring(game:HttpGet("https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/source.lua"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

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

local ballHighlight = nil
local projectionParts = {}
local projectionLineCount = 25

local trashTalkMessages = {
    "You can't hit nun",
    "Knowledge of a 3rd grader",
    "Your BA is probably -100",
    "Can't blame ping on that one son",
    "Get better",
    "Womp womp",
    "IQ of a Packet Loss",
    "Rando Pooron",
    "Swing and miss!",
    "Too slow, bro",
    "Try harder!",
    "Practice makes perfect... or not",
    "Can't catch me!",
    "You’re just lucky",
    "Is that all you got?",
    "Back to little league with you!",
    "Strikeout incoming!",
    "Better luck next time!",
    "Bow down to the king!",
    "I'm just warming up!"
}

-- Sends a random trash talk message in local chat
local function sendTrashTalk()
    local message = trashTalkMessages[math.random(1, #trashTalkMessages)]
    SayMessageRequest:FireServer(message, "All")
end

-- Get strike zone adornee (prefer SwingZone module in ReplicatedStorage.HRDGui)
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

-- Create or update strike zone box adornment
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

-- Ball highlighting
local function UpdateBallHighlight()
    local ball = Workspace:FindFirstChild("Ball")
    if ball then
        if not ballHighlight then
            ballHighlight = Instance.new("BoxHandleAdornment")
            ballHighlight.Size = ball.Size + Vector3.new(0.3,0.3,0.3)
            ballHighlight.Transparency = 0.5
            ballHighlight.Color3 = Color3.fromRGB(255, 165, 0)
            ballHighlight.AlwaysOnTop = true
            ballHighlight.ZIndex = 15
            ballHighlight.Adornee = ball
            ballHighlight.Parent = ball
        else
            ballHighlight.Adornee = ball
            ballHighlight.Size = ball.Size + Vector3.new(0.3,0.3,0.3)
        end
    else
        if ballHighlight then
            ballHighlight:Destroy()
            ballHighlight = nil
        end
    end
end

-- Create projection parts for ball trajectory visualization
local function CreateProjectionParts()
    for _, part in pairs(projectionParts) do
        if part and part.Parent then
            part:Destroy()
        end
    end
    projectionParts = {}
    for i=1, projectionLineCount do
        local p = Instance.new("Part")
        p.Size = Vector3.new(0.2, 0.2, 0.2)
        p.Anchored = true
        p.CanCollide = false
        p.Material = Enum.Material.Neon
        p.Color = Color3.fromRGB(255, 255, 0)
        p.Transparency = 0.5
        p.Name = "ProjectionPoint"
        p.Parent = Workspace
        table.insert(projectionParts, p)
    end
end

-- Update projection parts position based on ball velocity + gravity projection
local function UpdateProjectionParts()
    local ball = Workspace:FindFirstChild("Ball")
    if not ball or #projectionParts == 0 then return end

    local pos = ball.Position
    local velocity = ball:GetAttribute("Velocity") or Vector3.new(0,0,0)
    if velocity.Magnitude == 0 then
        -- Try to approximate velocity
        if ball:FindFirstChild("BodyVelocity") then
            velocity = ball.BodyVelocity.Velocity
        end
    end

    local gravity = Workspace.Gravity
    local timeStep = 0.1
    for i = 1, #projectionParts do
        local t = timeStep * i
        local projectedPos = pos + velocity * t + Vector3.new(0, -0.5 * gravity * t * t, 0)
        projectionParts[i].Position = projectedPos
        projectionParts[i].Transparency = 0.5 + (i / #projectionParts) * 0.5
    end
end

-- Auto bat detection - find tool named "Bat" in character or backpack
local function GetBatTool()
    local char = LocalPlayer.Character
    if not char then return nil end

    local bat = nil
    -- Search character tools
    for _, tool in pairs(char:GetChildren()) do
        if tool:IsA("Tool") and tool.Name:lower():find("bat") then
            bat = tool
            break
        end
    end
    -- If not found, search backpack
    if not bat then
        local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
        if backpack then
            for _, tool in pairs(backpack:GetChildren()) do
                if tool:IsA("Tool") and tool.Name:lower():find("bat") then
                    bat = tool
                    break
                end
            end
        end
    end
    return bat
end

-- Function to swing bat (simulate left click)
local function SwingBat()
    local bat = GetBatTool()
    if not bat then return end
    -- Attempt to activate tool (simulate click)
    local activated = false
    if bat.Activated then
        bat:Activate()
        activated = true
    end

    -- As fallback, try firing RemoteEvent or Mouse1Click if available
    if not activated then
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

-- Auto Aim logic
local function AutoAim()
    if not autoAimEnabled then return end
    local ball = Workspace:FindFirstChild("Ball")
    local char = LocalPlayer.Character
    if ball and char and char:FindFirstChild("HumanoidRootPart") then
        local hrp = char.HumanoidRootPart
        local targetPos = ball.Position + Vector3.new(offsetX, offsetY, 0)
        local lookVector = (Vector3.new(targetPos.X, hrp.Position.Y, targetPos.Z) - hrp.Position).Unit
        hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + lookVector)
    end
end

-- Auto Hit logic (left click swing if ball near)
local function AutoHit()
    if not autoHitEnabled then return end
    local ball = Workspace:FindFirstChild("Ball")
    local char = LocalPlayer.Character
    if ball and char and char:FindFirstChild("HumanoidRootPart") then
        local dist = (ball.Position - char.HumanoidRootPart.Position).Magnitude
        if dist < 30 then
            SwingBat()
        end
    end
end

-- Mag Ball logic (pull ball to player)
local function MagBall()
    if not magBallEnabled then
        -- Remove MagnetForce if exists
        local ball = Workspace:FindFirstChild("Ball")
        if ball then
            local magnet = ball:FindFirstChild("MagnetForce")
            if magnet then magnet:Destroy() end
        end
        return
    end
    local ball = Workspace:FindFirstChild("Ball")
    local char = LocalPlayer.Character
    if not ball or not char or not char:FindFirstChild("HumanoidRootPart") then return end

    local hrp = char.HumanoidRootPart
    local magnet = ball:FindFirstChild("MagnetForce")
    if not magnet then
        magnet = Instance.new("BodyPosition")
        magnet.Name = "MagnetForce"
        magnet.MaxForce = Vector3.new(1e5, 1e5, 1e5)
        magnet.P = 1e4
        magnet.Parent = ball
    end
    magnet.Position = hrp.Position + Vector3.new(0, 3, 0)
end

-- Fly logic with CFrame & camera direction, including up/down keys
local function FlyMovement(delta)
    if not flyEnabled then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local camera = workspace.CurrentCamera
    local moveVec = Vector3.new(0,0,0)
    if flyUp then
        moveVec = moveVec + Vector3.new(0, 1, 0)
    end
    if flyDown then
        moveVec = moveVec + Vector3.new(0, -1, 0)
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then
        moveVec = moveVec + Vector3.new(camera.CFrame.LookVector.X, 0, camera.CFrame.LookVector.Z).Unit
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then
        moveVec = moveVec - Vector3.new(camera.CFrame.LookVector.X, 0, camera.CFrame.LookVector.Z).Unit
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then
        moveVec = moveVec - Vector3.new(camera.CFrame.RightVector.X, 0, camera.CFrame.RightVector.Z).Unit
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then
        moveVec = moveVec + Vector3.new(camera.CFrame.RightVector.X, 0, camera.CFrame.RightVector.Z).Unit
    end

    if moveVec.Magnitude > 0 then
        moveVec = moveVec.Unit * flySpeed * delta
        hrp.CFrame = hrp.CFrame + moveVec
    end
end

-- Handle user input for fly up/down keys
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Space then
        flyUp = true
    elseif input.KeyCode == Enum.KeyCode.LeftControl or input.KeyCode == Enum.KeyCode.C then
        flyDown = true
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.Space then
        flyUp = false
    elseif input.KeyCode == Enum.KeyCode.LeftControl or input.KeyCode == Enum.KeyCode.C then
        flyDown = false
    end
end)

-- UI setup
local Window = Rayfield:CreateWindow({
    Name = "⚾ HCBB Utility",
    LoadingTitle = "Loading HCBB Utility",
    LoadingSubtitle = "by Kai",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = nil,
        FileName = "HCBBConfig"
    },
    Discord = {
        Enabled = false,
        Invite = "",
        RememberJoins = true
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
    CurrentValue = false,
    Flag = "WalkSpeedToggle",
    Callback = function(value)
        walkSpeedEnabled = value
        if not value then
            local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = 16 end
        end
    end

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
    CurrentValue = false,
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

-- Initialize projection parts for ball path visualization
CreateProjectionParts()

-- Runservice update loop
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

    -- Fly movement using CFrame, camera facing including up/down
    if flyEnabled then
        FlyMovement(delta)
    end

    -- Ball Highlight Update
    UpdateBallHighlight()

    -- Projection Path Update
    if strikeZoneVisible then
        UpdateProjectionParts()
    end

    -- Auto Aim
    AutoAim()

    -- Mag Ball
    MagBall()
end)

-- Auto Hit loop (separate coroutine)
task.spawn(function()
    while true do
        AutoHit()
        task.wait(0.1)
    end
end)

-- User Input for fly up/down keys handled above

-- Mouse input for left click swing (only when AutoHit enabled)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        if autoHitEnabled then
            SwingBat()
        end
    end
end)

-- On Character Added, reset PlatformStand and set Humanoid properties properly
LocalPlayer.CharacterAdded:Connect(function(char)
    local hum = char:WaitForChild("Humanoid", 10)
    if hum then
        hum.PlatformStand = flyEnabled
        hum.WalkSpeed = walkSpeedEnabled and walkSpeed or 16
        hum.JumpPower = jumpPowerEnabled and jumpPower or 50
        hum.HipHeight = hipHeight
    end
end)

-- Initialize Humanoid properties if character exists on script start
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
