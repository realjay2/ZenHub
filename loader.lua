local Rayfield = loadstring(game:HttpGet("https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/source.lua"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local HttpService = game:GetService("HttpService")

-- State variables
local autoAimEnabled = false
local autoHitEnabled = false
local walkSpeedLoop = false
local jumpPowerLoop = false
local noclipEnabled = false
local flyEnabled = false
local flySpeed = 30
local walkSpeed = 16
local jumpPower = 65
local hipHeight = 2
local offsetX, offsetY = 10, 10
local perfectAim = false
local pitchPredictionEnabled = false
local strikeZoneVisible = false
local strikeZoneBox = nil
local magBallEnabled = false
local ballSpeedMultiplier = 2 -- speed multiplier for ball when pitching

-- Trash Talk messages
local trashTalkMessages = {
    "You can't hit nun",
    "Knowledge of a 3rd grader",
    "your ba is probably -100",
    "Cant blame ping on that one son",
    "get better",
    "womp womp",
    "IQ of a Packet Loss",
    "Rando Pooron",
}

-- Iris Exploit UI Init (optional, can be removed if unused)
local IrisLoaded = false
local Iris = nil
local PropertyAPIDump = nil
local ScriptContent = [[]]
local SelectedInstance = nil
local Properties = {}

-- Function to send a random trash talk message in chat
local function sendTrashTalk()
    local message = trashTalkMessages[math.random(1, #trashTalkMessages)]
    game:GetService("ReplicatedStorage"):WaitForChild("DefaultChatSystemChatEvents"):WaitForChild("SayMessageRequest"):FireServer(message, "All")
end

-- Main Window
local Window = Rayfield:CreateWindow({
    Name = "⚾ HCBB Utility",
    LoadingTitle = "Loading HCBB Utility...",
    LoadingSubtitle = "by Mike",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = nil,
        FileName = "HCBBMainConfig"
    },
    Discord = {
        Enabled = false,
        Invite = "",
        RememberJoins = false
    },
    KeySystem = false
})

-- Movement Tab
local MoveTab = Window:CreateTab("Movement")

MoveTab:CreateSlider({
    Name = "WalkSpeed",
    Range = {16, 29},
    Increment = 1,
    Suffix = "",
    CurrentValue = 16,
    Flag = "WalkSpeedSlider",
    Callback = function(value)
        walkSpeed = value
    end,
})

MoveTab:CreateToggle({
    Name = "Loop WalkSpeed",
    CurrentValue = false,
    Flag = "WalkSpeedLoop",
    Callback = function(value)
        walkSpeedLoop = value
    end,
})

MoveTab:CreateSlider({
    Name = "JumpPower",
    Range = {50, 65},
    Increment = 1,
    Suffix = "",
    CurrentValue = 50,
    Flag = "JumpPowerSlider",
    Callback = function(value)
        jumpPower = value
    end,
})

MoveTab:CreateToggle({
    Name = "Loop JumpPower",
    CurrentValue = false,
    Flag = "JumpPowerLoop",
    Callback = function(value)
        jumpPowerLoop = value
    end,
})

MoveTab:CreateSlider({
    Name = "HipHeight",
    Range = {0, 10},
    Increment = 0.1,
    Suffix = "",
    CurrentValue = 2,
    Flag = "HipHeightSlider",
    Callback = function(value)
        hipHeight = value
    end,
})

MoveTab:CreateToggle({
    Name = "Noclip",
    CurrentValue = false,
    Flag = "NoclipToggle",
    Callback = function(value)
        noclipEnabled = value
    end,
})

MoveTab:CreateToggle({
    Name = "Fly",
    CurrentValue = false,
    Flag = "FlyToggle",
    Callback = function(value)
        flyEnabled = value
    end,
})

MoveTab:CreateSlider({
    Name = "Fly Speed",
    Range = {1, 50},
    Increment = 1,
    Suffix = "",
    CurrentValue = 30,
    Flag = "FlySpeedSlider",
    Callback = function(value)
        flySpeed = value
    end,
})

-- Auto Aim & Hit Tab
local AimTab = Window:CreateTab("Auto Aim & Hit")

AimTab:CreateToggle({
    Name = "Auto Aim",
    CurrentValue = false,
    Flag = "AutoAimToggle",
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
    Flag = "OffsetXSlider",
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
    Flag = "OffsetYSlider",
    Callback = function(value)
        offsetY = value
    end,
})

AimTab:CreateToggle({
    Name = "Auto Hit (Left Click)",
    CurrentValue = false,
    Flag = "AutoHitToggle",
    Callback = function(value)
        autoHitEnabled = value
    end,
})

AimTab:CreateToggle({
    Name = "Mag Ball (Pull Ball to You)",
    CurrentValue = false,
    Flag = "MagBallToggle",
    Callback = function(value)
        magBallEnabled = value
    end,
})

AimTab:CreateToggle({
    Name = "Perfect Aim (Auto Align Bat)",
    CurrentValue = false,
    Flag = "PerfectAimToggle",
    Callback = function(value)
        perfectAim = value
    end,
})

-- Trash Talk Tab
local TrashTab = Window:CreateTab("Trash Talk")

TrashTab:CreateButton({
    Name = "Send Trash Talk Message",
    Callback = function()
        sendTrashTalk()
    end,
})

-- Variables for fly
local flyVelocity = nil
local flyGyro = nil
local flying = false

-- RunService Loop
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

    -- HipHeight enforcement
    if hum.HipHeight ~= hipHeight then
        hum.HipHeight = hipHeight
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

    -- Fly toggle with full pitch + yaw orientation follow camera
    if flyEnabled then
        if not flying then
            flying = true
            hum.PlatformStand = true

            if not flyVelocity then
                flyVelocity = Instance.new("BodyVelocity")
                flyVelocity.Name = "FlyVelocity"
                flyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
                flyVelocity.Velocity = Vector3.new(0,0,0)
                flyVelocity.Parent = hrp
            end

            if not flyGyro then
                flyGyro = Instance.new("BodyGyro")
                flyGyro.Name = "FlyGyro"
                flyGyro.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
                flyGyro.CFrame = hrp.CFrame
                flyGyro.Parent = hrp
            end
        end

        local camCF = workspace.CurrentCamera.CFrame
        local moveDir = Vector3.new(0,0,0)

        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            moveDir = moveDir + camCF.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            moveDir = moveDir - camCF.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            moveDir = moveDir - camCF.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            moveDir = moveDir + camCF.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            moveDir = moveDir + Vector3.new(0,1,0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            moveDir = moveDir - Vector3.new(0,1,0)
        end

        if moveDir.Magnitude > 0 then
            moveDir = moveDir.Unit * flySpeed
            flyVelocity.Velocity = moveDir
            flyGyro.CFrame = CFrame.new(hrp.Position, hrp.Position + camCF.LookVector)
        else
            flyVelocity.Velocity = Vector3.new(0,0,0)
            flyGyro.CFrame = CFrame.new(hrp.Position, hrp.Position + camCF.LookVector)
        end
    else
        if flying then
            flying = false
            hum.PlatformStand = false
            if flyVelocity then
                flyVelocity:Destroy()
                flyVelocity = nil
            end
            if flyGyro then
                flyGyro:Destroy()
                flyGyro = nil
            end
        end
    end
end)

-- Auto Aim logic stub (you can add actual aim code here)
RunService.RenderStepped:Connect(function()
    if autoAimEnabled then
        local ball = Workspace:FindFirstChild("Ball")
        local char = LocalPlayer.Character
        if ball and char and char:FindFirstChild("HumanoidRootPart") then
            local hrp = char.HumanoidRootPart
            local dir = (ball.Position + Vector3.new(offsetX, offsetY, 0) - hrp.Position).Unit
            hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + Vector3.new(dir.X, 0, dir.Z))
        end
    end

    -- Perfect Aim placeholder
    if perfectAim then
        -- Add bat alignment logic here
    end

    -- Pitch Prediction placeholder
    if pitchPredictionEnabled then
        -- Add prediction logic here
    end

    -- Mag Ball pull
    if magBallEnabled then
        local ball = Workspace:FindFirstChild("Ball")
        local char = LocalPlayer.Character
        if ball and char and char:FindFirstChild("HumanoidRootPart") then
            local hrp = char.HumanoidRootPart
            local bodyPos = ball:FindFirstChild("MagnetForce")
            if not bodyPos then
                bodyPos = Instance.new("BodyPosition")
                bodyPos.Name = "MagnetForce"
                bodyPos.MaxForce = Vector3.new(1e5, 1e5, 1e5)
                bodyPos.P = 1e4
                bodyPos.Parent = ball
            end
            bodyPos.Position = hrp.Position + Vector3.new(0, 3, 0)
        else
            local ball = Workspace:FindFirstChild("Ball")
            if ball then
                local bf = ball:FindFirstChild("MagnetForce")
                if bf then bf:Destroy() end
            end
        end
    else
        local ball = Workspace:FindFirstChild("Ball")
        if ball then
            local bf = ball:FindFirstChild("MagnetForce")
            if bf then bf:Destroy() end
        end
    end
end)

-- Auto Hit loop
task.spawn(function()
    while true do
        if autoHitEnabled then
            local ball = Workspace:FindFirstChild("Ball")
            local char = LocalPlayer.Character
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
