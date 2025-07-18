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

local ballHighlight = nil
local projectionPart = nil

-- Trash talk messages
local trashTalkMessages = {
    "You can't hit nun",
    "Knowledge of a 3rd grader",
    "your ba is probably -100",
    "Cant blame ping on that one son",
    "get better",
    "womp womp",
    "IQ of a Packet Loss",
    "Rando Pooron",
    "Swing and miss!",
    "Bet you wish you had my stats",
    "My grandma hits better than you",
    "Is that all you got?",
    "You call that a swing?",
    "Try harder, scrub",
}

local function sendTrashTalk()
    local message = trashTalkMessages[math.random(1, #trashTalkMessages)]
    SayMessageRequest:FireServer(message, "All")
end

-- Function to get strike zone adornee (tries ReplicatedStorage.HRDGui.SwingZone module or fallback)
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

-- Create the UI window
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

local WalkSpeedSlider = MovementTab:CreateSlider({
    Name = "WalkSpeed",
    Range = {16, 30},
    Increment = 1,
    Suffix = "WalkSpeed",
    CurrentValue = 16,
    Flag = "WalkSpeed",
    Callback = function(value)
        walkSpeed = value
    end
})

local WalkSpeedToggle = MovementTab:CreateToggle({
    Name = "Enable WalkSpeed",
    CurrentValue = false,
    Flag = "WalkSpeedToggle",
    Callback = function(value)
        walkSpeedEnabled = value
        if not value then
            local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.WalkSpeed = 16
            end
        end
    end
})

local JumpPowerSlider = MovementTab:CreateSlider({
    Name = "JumpPower",
    Range = {50, 100},
    Increment = 1,
    Suffix = "JumpPower",
    CurrentValue = 50,
    Flag = "JumpPower",
    Callback = function(value)
        jumpPower = value
    end
})

local JumpPowerToggle = MovementTab:CreateToggle({
    Name = "Enable JumpPower",
    CurrentValue = false,
    Flag = "JumpPowerToggle",
    Callback = function(value)
        jumpPowerEnabled = value
        if not value then
            local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.JumpPower = 50
            end
        end
    end
})

local HipHeightSlider = MovementTab:CreateSlider({
    Name = "HipHeight",
    Range = {0, 10},
    Increment = 0.1,
    Suffix = "studs",
    CurrentValue = 2,
    Flag = "HipHeight",
    Callback = function(value)
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        hipHeight = value
        if hum then
            hum.HipHeight = hipHeight
        end
    end
})

-- Fly Tab
local FlyTab = Window:CreateTab("Fly", 4483345998)

local FlyToggle = FlyTab:CreateToggle({
    Name = "Enable Fly",
    CurrentValue = false,
    Flag = "FlyToggle",
    Callback = function(value)
        flyEnabled = value
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.PlatformStand = value
        end
    end
})

local FlySpeedSlider = FlyTab:CreateSlider({
    Name = "Fly Speed",
    Range = {1, 50},
    Increment = 1,
    Suffix = "speed",
    CurrentValue = 30,
    Flag = "FlySpeed",
    Callback = function(value)
        flySpeed = value
    end
})

-- Auto Aim & Hit Tab
local AimTab = Window:CreateTab("Auto Aim & Hit", 4483345998)

local AutoAimToggle = AimTab:CreateToggle({
    Name = "Auto Aim",
    CurrentValue = false,
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
    CurrentValue = 10,
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
    CurrentValue = 10,
    Flag = "OffsetY",
    Callback = function(value)
        offsetY = value
    end
})

local AutoHitToggle = AimTab:CreateToggle({
    Name = "Auto Hit (Left Click)",
    CurrentValue = false,
    Flag = "AutoHit",
    Callback = function(value)
        autoHitEnabled = value
    end
})

local PerfectAimToggle = AimTab:CreateToggle({
    Name = "Perfect Aim (Auto Align Bat)",
    CurrentValue = false,
    Flag = "PerfectAim",
    Callback = function(value)
        perfectAim = value
    end
})

local MagBallToggle = AimTab:CreateToggle({
    Name = "Mag Ball (Pull Ball to You)",
    CurrentValue = false,
    Flag = "MagBall",
    Callback = function(value)
        magBallEnabled = value
    end
})

AimTab:CreateToggle({
    Name = "Show Strike Zone",
    CurrentValue = false,
    Flag = "ShowStrikeZone",
    Callback = function(value)
        strikeZoneVisible = value
        if strikeZoneVisible and not strikeZoneBox then
            strikeZoneBox = Instance.new("BoxHandleAdornment")
            strikeZoneBox.Size = Vector3.new(4, 4, 4)
            strikeZoneBox.Transparency = 0.7
            strikeZoneBox.Color3 = Color3.fromRGB(0, 255, 255)
            strikeZoneBox.AlwaysOnTop = true
            strikeZoneBox.ZIndex = 10
            local adornee = GetStrikeZoneAdornee()
            strikeZoneBox.Adornee = adornee
            strikeZoneBox.Parent = adornee
        elseif (not strikeZoneVisible) and strikeZoneBox then
            strikeZoneBox:Destroy()
            strikeZoneBox = nil
        end
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

-- Utility function to create or update ball highlight
local function updateBallHighlight(ball)
    if not ballHighlight then
        ballHighlight = Instance.new("SelectionBox")
        ballHighlight.Adornee = ball
        ballHighlight.LineThickness = 0.05
        ballHighlight.Color3 = Color3.new(1, 0, 0)
        ballHighlight.Parent = ball
    end
    ballHighlight.Adornee = ball
end

-- Utility function to create or update projection part (small sphere showing projected ball position)
local function updateProjectionPart(pos)
    if not projectionPart then
        projectionPart = Instance.new("Part")
        projectionPart.Shape = Enum.PartType.Ball
        projectionPart.Material = Enum.Material.Neon
        projectionPart.Color = Color3.fromRGB(0, 255, 255)
        projectionPart.Size = Vector3.new(0.3, 0.3, 0.3)
        projectionPart.Anchored = true
        projectionPart.CanCollide = false
        projectionPart.Transparency = 0.4
        projectionPart.Parent = Workspace
    end
    projectionPart.Position = pos
end

-- Function to predict ball path and project in strike zone
local function predictBallProjection(ball)
    -- Simple prediction: project ball velocity for next 0.5 seconds in 0.1s increments
    if not ball or not ball:IsA("BasePart") then return end
    if not ball.Velocity then return end

    local dt = 0.1
    local predictionTime = 0.5
    local gravity = Workspace.Gravity or 196.2

    local position = ball.Position
    local velocity = ball.Velocity

    for t = dt, predictionTime, dt do
        -- s = ut + 0.5at^2
        local predictedPos = position + velocity * t + Vector3.new(0, -0.5 * gravity * t * t, 0)
        updateProjectionPart(predictedPos)
    end
end

-- Function to swing bat (simulate left mouse click)
local function swingBat()
    if syn and syn.mouse1click then
        syn.mouse1click()
    elseif mouse1click then
        mouse1click()
    elseif mouse1press and mouse1release then
        mouse1press()
        task.wait(0.1)
        mouse1release()
    else
        -- no mouse click method, do nothing
    end
end

-- Runservice updates
RunService.Heartbeat:Connect(function(deltaTime)
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hum or not hrp then return end

    -- WalkSpeed
    if walkSpeedEnabled then
        if hum.WalkSpeed ~= walkSpeed then
            hum.WalkSpeed = walkSpeed
        end
    else
        if hum.WalkSpeed ~= 16 then
            hum.WalkSpeed = 16
        end
    end

    -- JumpPower
    if jumpPowerEnabled then
        if hum.JumpPower ~= jumpPower then
            hum.JumpPower = jumpPower
        end
    else
        if hum.JumpPower ~= 50 then
            hum.JumpPower = 50
        end
    end

    -- HipHeight
    if hum.HipHeight ~= hipHeight then
        hum.HipHeight = hipHeight
    end

    -- Fly logic
    if flyEnabled then
        local camera = workspace.CurrentCamera
        local moveVec = Vector3.new(0,0,0)
        if flyUp then
            moveVec = moveVec + Vector3.new(0, 1, 0)
        end
        if flyDown then
            moveVec = moveVec + Vector3.new(0, -1, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            moveVec = moveVec + (camera.CFrame.LookVector * Vector3.new(1,0,1).Unit)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            moveVec = moveVec - (camera.CFrame.LookVector * Vector3.new(1,0,1).Unit)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            moveVec = moveVec - (camera.CFrame.RightVector * Vector3.new(1,0,1).Unit)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            moveVec = moveVec + (camera.CFrame.RightVector * Vector3.new(1,0,1).Unit)
        end

        if moveVec.Magnitude > 0 then
            moveVec = moveVec.Unit * flySpeed
            hrp.CFrame = hrp.CFrame + moveVec * deltaTime
        end
    end

    -- Ball tracking
    local ball = Workspace:FindFirstChild("Ball")
    if ball and ball:IsA("BasePart") then
        -- Highlight ball
        updateBallHighlight(ball)

        -- Show projection of ball path
        predictBallProjection(ball)

        -- MagBall: pull ball to you
        if magBallEnabled then
            ball.Velocity = (hrp.Position - ball.Position).Unit * 150
        end

        -- Auto Aim: rotate player to face ball with offsets
        if autoAimEnabled then
            local dir = (ball.Position + Vector3.new(offsetX, offsetY, 0) - hrp.Position).Unit
            hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + Vector3.new(dir.X, 0, dir.Z))
        end

        -- Perfect Aim (auto align bat) stub - add your bat alignment here if needed

        -- Auto Hit: if ball is close and enabled, swing bat on left click
        if autoHitEnabled then
            if (ball.Position - hrp.Position).Magnitude < 30 then
                swingBat()
            end
        end
    else
        -- No ball found: cleanup highlight and projection
        if ballHighlight then
            ballHighlight:Destroy()
            ballHighlight = nil
        end
        if projectionPart then
            projectionPart:Destroy()
            projectionPart = nil
        end
    end
end)

-- Detect fly up/down keys
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

-- Handle mouse input for perfect aim or other features if needed
-- (Add your mouse detection code here if you want)

-- END OF SCRIPT
