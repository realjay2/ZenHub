print("Starting HCBB Util")
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/jensonhirst/Orion/main/source.lua"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

-- Chat events for sending chat messages
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
}

local function sendTrashTalk()
    local message = trashTalkMessages[math.random(1, #trashTalkMessages)]
    SayMessageRequest:FireServer(message, "All")
end

-- Utility to get strike zone adornee part
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
    return Workspace.Terrain -- fallback invisible
end

-- Setup Orion UI window
local Window = OrionLib:MakeWindow({
    Name = "⚾ HCBB Utility",
    HidePremium = true,
    SaveConfig = true,
    ConfigFolder = "HCBBConfig"
})

-- Movement tab
local MovementTab = Window:MakeTab({
    Name = "Movement",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

MovementTab:AddSlider({
    Name = "WalkSpeed",
    Min = 16,
    Max = 30,
    Default = 16,
    Increment = 1,
    Callback = function(value)
        walkSpeed = value
    end
})

MovementTab:AddToggle({
    Name = "Enable WalkSpeed",
    Default = false,
    Callback = function(value)
        walkSpeedEnabled = value
        if not value then
            local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = 16 end
        end
    end
})

MovementTab:AddSlider({
    Name = "JumpPower",
    Min = 50,
    Max = 100,
    Default = 50,
    Increment = 1,
    Callback = function(value)
        jumpPower = value
    end
})

MovementTab:AddToggle({
    Name = "Enable JumpPower",
    Default = false,
    Callback = function(value)
        jumpPowerEnabled = value
        if not value then
            local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.JumpPower = 50 end
        end
    end
})

MovementTab:AddSlider({
    Name = "HipHeight",
    Min = 0,
    Max = 10,
    Default = 2,
    Increment = 0.1,
    Callback = function(value)
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.HipHeight = value
        end
        hipHeight = value
    end
})

-- Fly tab
local FlyTab = Window:MakeTab({
    Name = "Fly",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

FlyTab:AddToggle({
    Name = "Enable Fly",
    Default = false,
    Callback = function(value)
        flyEnabled = value
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.PlatformStand = value
        end
    end
})

FlyTab:AddSlider({
    Name = "Fly Speed",
    Min = 1,
    Max = 50,
    Default = 30,
    Increment = 1,
    Callback = function(value)
        flySpeed = value
    end
})

-- Auto Aim & Hit tab
local AimTab = Window:MakeTab({
    Name = "Auto Aim & Hit",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

AimTab:AddToggle({
    Name = "Auto Aim",
    Default = false,
    Callback = function(value)
        autoAimEnabled = value
    end
})

AimTab:AddSlider({
    Name = "Offset X",
    Min = -20,
    Max = 100,
    Default = 10,
    Increment = 1,
    Callback = function(value)
        offsetX = value
    end
})

AimTab:AddSlider({
    Name = "Offset Y",
    Min = -20,
    Max = 100,
    Default = 10,
    Increment = 1,
    Callback = function(value)
        offsetY = value
    end
})

AimTab:AddToggle({
    Name = "Auto Hit (Left Click)",
    Default = false,
    Callback = function(value)
        autoHitEnabled = value
    end
})

AimTab:AddToggle({
    Name = "Perfect Aim (Auto Align Bat)",
    Default = false,
    Callback = function(value)
        perfectAim = value
    end
})

AimTab:AddToggle({
    Name = "Mag Ball (Pull Ball to You)",
    Default = false,
    Callback = function(value)
        magBallEnabled = value
    end
})

AimTab:AddToggle({
    Name = "Show Strike Zone",
    Default = false,
    Callback = function(value)
        strikeZoneVisible = value
        if strikeZoneVisible and not strikeZoneBox then
            strikeZoneBox = Instance.new("BoxHandleAdornment")
            strikeZoneBox.Size = Vector3.new(4, 4, 4)
            strikeZoneBox.Transparency = 0.7
            strikeZoneBox.Color3 = Color3.fromRGB(0, 255, 255)
            strikeZoneBox.AlwaysOnTop = true
            strikeZoneBox.ZIndex = 10
            strikeZoneBox.Adornee = GetStrikeZoneAdornee()
            strikeZoneBox.Parent = strikeZoneBox.Adornee
        elseif not strikeZoneVisible and strikeZoneBox then
            strikeZoneBox:Destroy()
            strikeZoneBox = nil
        end
    end
})

-- Trash talk tab
local TrashTab = Window:MakeTab({
    Name = "Trash Talk",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

TrashTab:AddButton({
    Name = "Send Trash Talk",
    Callback = function()
        sendTrashTalk()
    end
})

-- Run loops and event handlers

-- Update WalkSpeed, JumpPower, HipHeight
RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    if walkSpeedEnabled then
        if hum.WalkSpeed ~= walkSpeed then
            hum.WalkSpeed = walkSpeed
        end
    else
        if hum.WalkSpeed ~= 16 then
            hum.WalkSpeed = 16
        end
    end

    if jumpPowerEnabled then
        if hum.JumpPower ~= jumpPower then
            hum.JumpPower = jumpPower
        end
    else
        if hum.JumpPower ~= 50 then
            hum.JumpPower = 50
        end
    end

    if hum.HipHeight ~= hipHeight then
        hum.HipHeight = hipHeight
    end
end)

-- Fly control
local flyUp = false
local flyDown = false

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

RunService.Heartbeat:Connect(function()
    if flyEnabled then
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum then return end

        local moveVec = Vector3.new()
        local camera = workspace.CurrentCamera

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
            moveVec = moveVec.Unit * flySpeed * RunService.Heartbeat:Wait()
            hrp.CFrame = hrp.CFrame + moveVec
        end
    end
end)

-- Auto Aim logic
RunService.RenderStepped:Connect(function()
    if autoAimEnabled then
        local ball = Workspace:FindFirstChild("Ball")
        local char = LocalPlayer.Character
        if ball and char and char:FindFirstChild("HumanoidRootPart") then
            local hrp = char.HumanoidRootPart
            local targetPos = ball.Position + Vector3.new(offsetX, offsetY, 0)
            local lookVector = (targetPos - hrp.Position).Unit
            hrp.CFrame = CFrame.new(hrp.Position, Vector3.new(hrp.Position.X + lookVector.X, hrp.Position.Y, hrp.Position.Z + lookVector.Z))
        end
    end
    -- Perfect Aim could be implemented here if desired
end)

-- Auto Hit loop (simulate left click when ball close)
task.spawn(function()
    while true do
        if autoHitEnabled then
            local ball = Workspace:FindFirstChild("Ball")
            local char = LocalPlayer.Character
            if char and ball and char:FindFirstChild("HumanoidRootPart") then
                local hrp = char.HumanoidRootPart
                local dist = (ball.Position - hrp.Position).Magnitude
                if dist < 30 then
                    -- Using Roblox built-in mouse1click simulation may not exist
                    -- Try multiple ways for compatibility
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
        end
        task.wait(0.1)
    end
end)

-- Ball tracking projection (show a marker where ball will cross strike zone)
local projectionPart = nil
local function createProjectionPart()
    if not projectionPart then
        projectionPart = Instance.new("Part")
        projectionPart.Name = "BallProjection"
        projectionPart.Size = Vector3.new(1, 1, 1)
        projectionPart.Anchored = true
        projectionPart.CanCollide = false
        projectionPart.Material = Enum.Material.Neon
        projectionPart.Color = Color3.fromRGB(0, 255, 255)
        projectionPart.Transparency = 0.5
        projectionPart.Parent = Workspace
    end
end

RunService.Heartbeat:Connect(function()
    if magBallEnabled then
        local ball = Workspace:FindFirstChild("Ball")
        local char = LocalPlayer.Character
        if ball and char and char:FindFirstChild("HumanoidRootPart") then
            local hrp = char.HumanoidRootPart
            local dir = (hrp.Position - ball.Position).Unit
            ball.Velocity = dir * 100 -- pull ball fast to player
        end
    end

    -- Update ball projection
    if projectionPart then
        local ball = Workspace:FindFirstChild("Ball")
        local strikeZone = GetStrikeZoneAdornee()
        if ball and strikeZone and strikeZone:IsA("BasePart") then
            -- Simple projection: find intersection on strike zone's plane based on ball velocity
            local ballPos = ball.Position
            local ballVel = ball.Velocity
            local planePos = strikeZone.Position
            local planeNormal = strikeZone.CFrame.LookVector

            local denom = ballVel:Dot(planeNormal)
            if math.abs(denom) > 0.01 then
                local t = (planePos - ballPos):Dot(planeNormal) / denom
                if t > 0 then
                    local projPos = ballPos + ballVel * t
                    projectionPart.Position = projPos
                    projectionPart.Transparency = 0
                else
                    projectionPart.Transparency = 1
                end
            else
                projectionPart.Transparency = 1
            end
        else
            projectionPart.Transparency = 1
        end
    end
end)

-- Create projection part on script start
createProjectionPart()

print("⚾ HCBB Utility loaded. Use the Orion UI to control features.")

-- Show Orion window
OrionLib:Init()
