-- Load Orion UI Library safely
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()

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
local hipHeight = 0
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
local ballProjectionParts = {}

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
    "Swing and a miss!",
    "Is that all you got?",
    "Come on, step up your game!",
    "You call that a pitch?",
    "Better luck next time!",
    "Easy strike for me!",
}

-- Sends a random trash talk message in Roblox chat
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

-- Create or update strike zone box adornment
local function UpdateStrikeZoneBox()
    if strikeZoneVisible then
        if not strikeZoneBox then
            strikeZoneBox = Instance.new("BoxHandleAdornment")
            strikeZoneBox.Size = Vector3.new(4,4,4)
            strikeZoneBox.Transparency = 0.7
            strikeZoneBox.Color3 = Color3.fromRGB(0, 255, 255)
            strikeZoneBox.AlwaysOnTop = true
            strikeZoneBox.ZIndex = 10
            strikeZoneBox.Adornee = GetStrikeZoneAdornee()
            strikeZoneBox.Parent = strikeZoneBox.Adornee
        else
            -- Update adornee in case it changed
            local adornee = GetStrikeZoneAdornee()
            if strikeZoneBox.Adornee ~= adornee then
                strikeZoneBox.Adornee = adornee
                strikeZoneBox.Parent = adornee
            end
        end
    elseif strikeZoneBox then
        strikeZoneBox:Destroy()
        strikeZoneBox = nil
    end
end

-- Highlights the ball with a selection box
local function UpdateBallHighlight()
    local ball = Workspace:FindFirstChild("Ball")
    if not ball then
        if ballHighlight then
            ballHighlight:Destroy()
            ballHighlight = nil
        end
        return
    end
    if not ballHighlight then
        ballHighlight = Instance.new("SelectionBox")
        ballHighlight.Adornee = ball
        ballHighlight.LineThickness = 0.05
        ballHighlight.SurfaceColor3 = Color3.fromRGB(255, 0, 0)
        ballHighlight.SurfaceTransparency = 0.7
        ballHighlight.Parent = ball
    end
end

-- Clears ball projection parts
local function ClearBallProjection()
    for _, part in ipairs(ballProjectionParts) do
        if part and part.Parent then
            part:Destroy()
        end
    end
    ballProjectionParts = {}
end

-- Projects where the ball will go inside strike zone
local function UpdateBallProjection()
    ClearBallProjection()
    local ball = Workspace:FindFirstChild("Ball")
    if not ball then return end

    -- Simple linear projection using ball velocity (if velocity not found, do nothing)
    local velocity = ball:FindFirstChild("BodyVelocity")
    if not velocity then return end

    local currentPos = ball.Position
    local vel = velocity.Velocity
    local dt = 0.1 -- time step
    local points = {}

    -- Calculate 10 projection points ahead (1 second ahead)
    for i = 1, 10 do
        local projectedPos = currentPos + vel * dt * i
        table.insert(points, projectedPos)
    end

    -- For each point, create a small transparent part to visualize the path
    for _, pos in ipairs(points) do
        local projPart = Instance.new("Part")
        projPart.Anchored = true
        projPart.CanCollide = false
        projPart.Transparency = 0.6
        projPart.Material = Enum.Material.Neon
        projPart.Color = Color3.fromRGB(0, 255, 255)
        projPart.Size = Vector3.new(0.2,0.2,0.2)
        projPart.Position = pos
        projPart.Parent = Workspace
        table.insert(ballProjectionParts, projPart)
        -- Auto destroy after 1.2 seconds so no clutter
        delay(1.2, function()
            if projPart and projPart.Parent then
                projPart:Destroy()
            end
        end)
    end
end

-- Swing the bat by simulating left mouse click
local function SwingBat()
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

-- Setup UI window
local Window = OrionLib:MakeWindow({
    Name = "⚾ HCBB Utility",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "HCBBConfig"
})

-- Movement Tab
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
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            if value then
                hum.WalkSpeed = walkSpeed
            else
                hum.WalkSpeed = 16
            end
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
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            if value then
                hum.JumpPower = jumpPower
            else
                hum.JumpPower = 50
            end
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
        hipHeight = value
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.HipHeight = hipHeight
        end
    end
})

-- Fly Tab
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

-- Auto Aim & Hit Tab
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
        UpdateStrikeZoneBox()
    end
})

-- Trash Talk Tab
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

-- Fly movement variables
local moveVec = Vector3.new(0,0,0)

-- Input handling for fly up/down keys
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

-- Main update loop
RunService.Heartbeat:Connect(function(dt)
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

    -- Fly movement with CFrame
    if flyEnabled then
        local camera = workspace.CurrentCamera
        moveVec = Vector3.new(0,0,0)
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
            moveVec = moveVec.Unit * flySpeed * dt
            hrp.CFrame = hrp.CFrame + moveVec
        end
    end

    -- Auto Aim logic
    if autoAimEnabled then
        local ball = Workspace:FindFirstChild("Ball")
        if ball and hrp then
            local targetPos = ball.Position + Vector3.new(offsetX, offsetY, 0)
            local lookVector = (targetPos - hrp.Position)
            local newCFrame = CFrame.new(hrp.Position, hrp.Position + Vector3.new(lookVector.X, 0, lookVector.Z))
            hrp.CFrame = newCFrame
        end
    end

    -- Perfect Aim placeholder (can align bat or something)
    -- You can add custom logic here for bat alignment

    -- MagBall logic: Pull ball towards player if enabled
    if magBallEnabled then
        local ball = Workspace:FindFirstChild("Ball")
        if ball then
            local direction = (hrp.Position - ball.Position).Unit
            local bodyVel = ball:FindFirstChildOfClass("BodyVelocity")
            if not bodyVel then
                bodyVel = Instance.new("BodyVelocity")
                bodyVel.MaxForce = Vector3.new(1e5,1e5,1e5)
                bodyVel.P = 1e4
                bodyVel.Parent = ball
            end
            bodyVel.Velocity = direction * 100
        else
            -- Remove BodyVelocity if no ball found
            if ball and ball:FindFirstChildOfClass("BodyVelocity") then
                ball:FindFirstChildOfClass("BodyVelocity"):Destroy()
            end
        end
    end

    -- Update strike zone box if visible
    if strikeZoneVisible then
        UpdateStrikeZoneBox()
    end

    -- Update ball highlight and projection
    UpdateBallHighlight()
    UpdateBallProjection()
end)

-- Auto Hit loop: left click swing if ball near
task.spawn(function()
    while true do
        if autoHitEnabled then
            local ball = Workspace:FindFirstChild("Ball")
            local char = LocalPlayer.Character
            if char and ball and char:FindFirstChild("HumanoidRootPart") and (ball.Position - char.HumanoidRootPart.Position).Magnitude < 30 then
                SwingBat()
            end
        end
        task.wait(0.1)
    end
end)

-- Left click mouse input for manual swing
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        if not autoHitEnabled then -- Only manual swing if autoHit disabled
            SwingBat()
        end
    end
end)

-- Init Orion UI
OrionLib:Init()
