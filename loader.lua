-- Load Rayfield UI
local Rayfield = loadstring(game:HttpGet("https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/source.lua"))()

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer

-- Wait for character and humanoid
local function getCharacter()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        return LocalPlayer.Character
    else
        return LocalPlayer.CharacterAdded:Wait()
    end
end

local Character = getCharacter()
local Humanoid = Character:WaitForChild("Humanoid")
local HRP = Character:WaitForChild("HumanoidRootPart")

-- Global Variables
local flightSpeed = 3
local walkSpeed = 16
local hipHeight = Humanoid.HipHeight
local walkSpeedEnabled = false
local flying = false
local flyUp = false
local flyDown = false

local autoAimEnabled = false
local autoHitEnabled = false
local perfectAim = false
local magBallEnabled = false
local offsetX, offsetY = 10, 10

local strikeZoneVisible = false
local strikeZoneBox = nil

local trashTalkMessages = {
    "You can't hit nun",
    "Knowledge of a 3rd grader",
    "your ba is probably -100",
    "Cant blame ping on that one son",
    "get better",
    "womp womp",
    "IQ of a Packet Loss",
    "Rando Pooron",
    "You're swinging like a tee-ball player",
    "Swing and a miss!",
    "Better luck next time!",
    "Is that all you got?",
    "My grandma hits harder!",
    "Keep dreaming champ!",
    "You throw like a toddler!",
}

-- Chat stuff
local ChatEvents = ReplicatedStorage:WaitForChild("DefaultChatSystemChatEvents")
local SayMessageRequest = ChatEvents:WaitForChild("SayMessageRequest")

-- Function to send trash talk in chat
local function sendTrashTalk()
    local message = trashTalkMessages[math.random(1, #trashTalkMessages)]
    SayMessageRequest:FireServer(message, "All")
end

-- Function to get StrikeZone adornee part
local function GetStrikeZoneAdornee()
    local hrdGui = ReplicatedStorage:FindFirstChild("HRDGui")
    if hrdGui then
        local swingZone = hrdGui:FindFirstChild("SwingZone")
        if swingZone and (swingZone:IsA("BasePart") or swingZone:IsA("Model")) then
            return swingZone
        end
    end
    local plate = workspace:FindFirstChild("HomePlate") or workspace:FindFirstChild("StrikeZone")
    if plate then
        return plate
    end
    return workspace.Terrain -- fallback
end

-- UI Window
local Window = Rayfield:CreateWindow({
    Name = "⚾ HCBB Utility",
    LoadingTitle = "Loading HCBB Utility",
    LoadingSubtitle = "by Kai",
    ConfigurationSaving = {
        Enabled = false
    },
    Discord = {
        Enabled = false
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
    Callback = function(value)
        walkSpeed = value
    end
})

local WalkSpeedToggle = MovementTab:CreateToggle({
    Name = "Enable WalkSpeed",
    CurrentValue = false,
    Callback = function(value)
        walkSpeedEnabled = value
        if not value then
            local hum = Character and Character:FindFirstChildOfClass("Humanoid")
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
    Callback = function(value)
        if Character and Character:FindFirstChildOfClass("Humanoid") then
            Character.Humanoid.JumpPower = value
        end
    end
})

local HipHeightSlider = MovementTab:CreateSlider({
    Name = "HipHeight",
    Range = {0, 10},
    Increment = 0.1,
    Suffix = "studs",
    CurrentValue = hipHeight,
    Callback = function(value)
        hipHeight = value
        if Character and Character:FindFirstChildOfClass("Humanoid") then
            Character.Humanoid.HipHeight = value
        end
    end
})

-- Fly Tab
local FlyTab = Window:CreateTab("Fly", 4483345998)

local FlyToggle = FlyTab:CreateToggle({
    Name = "Enable Fly",
    CurrentValue = false,
    Callback = function(value)
        flying = value
        if flying then
            Humanoid.PlatformStand = true
        else
            Humanoid.PlatformStand = false
            local bv = HRP:FindFirstChild("FlightVelocity")
            if bv then bv:Destroy() end
            RunService:UnbindFromRenderStep("FlyControl")
        end
    end
})

local FlySpeedSlider = FlyTab:CreateSlider({
    Name = "Fly Speed",
    Range = {1, 50},
    Increment = 1,
    Suffix = "speed",
    CurrentValue = flightSpeed,
    Callback = function(value)
        flightSpeed = value
    end
})

-- Fly Movement logic
local function updateFly()
    local bv = HRP:FindFirstChild("FlightVelocity")
    if not bv then
        bv = Instance.new("BodyVelocity")
        bv.Name = "FlightVelocity"
        bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
        bv.Velocity = Vector3.new(0, 0, 0)
        bv.Parent = HRP
    end

    local camera = workspace.CurrentCamera
    local moveVec = Vector3.new(0, 0, 0)

    if flyUp then moveVec = moveVec + Vector3.new(0, 1, 0) end
    if flyDown then moveVec = moveVec + Vector3.new(0, -1, 0) end

    if UserInputService:IsKeyDown(Enum.KeyCode.W) then
        moveVec = moveVec + (camera.CFrame.LookVector * Vector3.new(1, 0, 1).Unit)
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then
        moveVec = moveVec - (camera.CFrame.LookVector * Vector3.new(1, 0, 1).Unit)
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then
        moveVec = moveVec - (camera.CFrame.RightVector * Vector3.new(1, 0, 1).Unit)
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then
        moveVec = moveVec + (camera.CFrame.RightVector * Vector3.new(1, 0, 1).Unit)
    end

    if moveVec.Magnitude > 0 then
        moveVec = moveVec.Unit * flightSpeed
        bv.Velocity = moveVec
    else
        bv.Velocity = Vector3.new(0, 0, 0)
    end
end

RunService:BindToRenderStep("FlyControl", Enum.RenderPriority.Input.Value, function()
    if flying then
        updateFly()
    end
end)

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.Space then
        flyUp = true
    elseif input.KeyCode == Enum.KeyCode.LeftControl or input.KeyCode == Enum.KeyCode.C then
        flyDown = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Space then
        flyUp = false
    elseif input.KeyCode == Enum.KeyCode.LeftControl or input.KeyCode == Enum.KeyCode.C then
        flyDown = false
    end
end)

-- Auto Aim & Hit Tab
local AimTab = Window:CreateTab("Auto Aim & Hit", 4483345998)

local AutoAimToggle = AimTab:CreateToggle({
    Name = "Auto Aim",
    CurrentValue = false,
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
    Callback = function(value)
        offsetY = value
    end
})

local AutoHitToggle = AimTab:CreateToggle({
    Name = "Auto Hit (Left Click)",
    CurrentValue = false,
    Callback = function(value)
        autoHitEnabled = value
    end
})

local PerfectAimToggle = AimTab:CreateToggle({
    Name = "Perfect Aim (Auto Align Bat)",
    CurrentValue = false,
    Callback = function(value)
        perfectAim = value
    end
})

local MagBallToggle = AimTab:CreateToggle({
    Name = "Mag Ball (Pull Ball to You)",
    CurrentValue = false,
    Callback = function(value)
        magBallEnabled = value
    end
})

-- Strike Zone Toggle (to show box adornment)
AimTab:CreateToggle({
    Name = "Show Strike Zone",
    CurrentValue = false,
    Callback = function(value)
        strikeZoneVisible = value
        if strikeZoneVisible then
            if not strikeZoneBox then
                strikeZoneBox = Instance.new("BoxHandleAdornment")
                strikeZoneBox.Size = Vector3.new(4, 4, 4)
                strikeZoneBox.Transparency = 0.7
                strikeZoneBox.Color3 = Color3.fromRGB(0, 255, 255)
                strikeZoneBox.AlwaysOnTop = true
                strikeZoneBox.ZIndex = 10
                strikeZoneBox.Adornee = GetStrikeZoneAdornee()
                strikeZoneBox.Parent = workspace.CurrentCamera
            end
        else
            if strikeZoneBox then
                strikeZoneBox:Destroy()
                strikeZoneBox = nil
            end
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

-- Ball Highlight + Projection Tab
local BallTab = Window:CreateTab("Ball Tracker", 4483345998)

local highlightEnabled = false

BallTab:CreateToggle({
    Name = "Highlight Ball",
    CurrentValue = false,
    Callback = function(value)
        highlightEnabled = value
    end
})

-- Creates or updates highlight for the ball
local function updateBallHighlight(ball)
    local highlight = ball:FindFirstChildWhichIsA("Highlight")
    if not highlight then
        highlight = Instance.new("Highlight")
        highlight.FillColor = Color3.fromRGB(255, 255, 0)
        highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
        highlight.FillTransparency = 0.5
        highlight.OutlineTransparency = 0
        highlight.Parent = ball
    end
end

-- Projection parts container
local projectionParts = {}

-- Clean old projection parts
local function clearProjection()
    for _, p in pairs(projectionParts) do
        if p and p.Parent then p:Destroy() end
    end
    projectionParts = {}
end

-- Draw a line with small parts predicting ball trajectory
local function drawProjection(ball)
    clearProjection()
    local pos = ball.Position
    local vel = ball.Velocity
    local gravity = workspace.Gravity
    local dt = 0.1
    local steps = 30

    for i = 1, steps do
        local t = dt * i
        local predictedPos = pos + (vel * t) + Vector3.new(0, -0.5 * gravity * t * t, 0)
        local part = Instance.new("Part")
        part.Size = Vector3.new(0.3, 0.3, 0.3)
        part.Shape = Enum.PartType.Ball
        part.Anchored = true
        part.CanCollide = false
        part.Material = Enum.Material.Neon
        part.Color = Color3.fromRGB(0, 255, 0)
        part.Transparency = 0.6
        part.Position = predictedPos
        part.Parent = workspace
        table.insert(projectionParts, part)
        Debris:AddItem(part, 0.2)
    end
end

-- Auto Bat Detection (search for first tool with "Bat" in name)
local function detectBat()
    local backpack = LocalPlayer:WaitForChild("Backpack")
    local character = LocalPlayer.Character
    local bat = nil

    if character then
        for _, tool in pairs(character:GetChildren()) do
            if tool:IsA("Tool") and string.find(tool.Name:lower(), "bat") then
                bat = tool
                break
            end
        end
    end
    if not bat then
        for _, tool in pairs(backpack:GetChildren()) do
            if tool:IsA("Tool") and string.find(tool.Name:lower(), "bat") then
                bat = tool
                break
            end
        end
    end
    return bat
end

-- Left Click Swing (fires Swing Remote or anim if available)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local bat = detectBat()
        if bat then
            -- Try firing remote called "Swing"
            local swingRemote = bat:FindFirstChild("Swing")
            if swingRemote and swingRemote:IsA("RemoteEvent") then
                swingRemote:FireServer()
            else
                -- Or try to play swing animation if any
                local anim = bat:FindFirstChildOfClass("Animation")
                if anim then
                    local animator = Humanoid:FindFirstChildOfClass("Animator") or Humanoid:WaitForChild("Animator")
                    local track = animator:LoadAnimation(anim)
                    track:Play()
                end
            end
        end
    end
end)

-- Auto Aim logic - rotates player towards ball with offset
RunService.RenderStepped:Connect(function()
    if autoAimEnabled then
        local ball = workspace:FindFirstChild("Ball")
        local char = LocalPlayer.Character
        if ball and char and char:FindFirstChild("HumanoidRootPart") then
            local hrp = char.HumanoidRootPart
            local targetPos = ball.Position + Vector3.new(offsetX, offsetY, 0)
            local lookVector = (targetPos - hrp.Position)
            if lookVector.Magnitude > 0 then
                hrp.CFrame = CFrame.new(hrp.Position, Vector3.new(targetPos.X, hrp.Position.Y, targetPos.Z))
            end
        end
    end
    -- Perfect Aim logic (if needed) could be added here
end)

-- Auto Hit loop
task.spawn(function()
    while true do
        if autoHitEnabled then
            local ball = workspace:FindFirstChild("Ball")
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

-- Mag Ball logic: Pull ball to player
RunService.RenderStepped:Connect(function()
    if magBallEnabled then
        local ball = workspace:FindFirstChild("Ball")
        if ball then
            local dir = (HRP.Position - ball.Position).Unit
            ball.Velocity = dir * 50
        end
    end
end)

-- Ball Highlight & Projection update loop
RunService.Heartbeat:Connect(function()
    if highlightEnabled then
        local ball = workspace:FindFirstChild("Ball")
        if ball then
            updateBallHighlight(ball)
            drawProjection(ball)
        else
            clearProjection()
        end
    else
        clearProjection()
    end
end)

-- Final WalkSpeed and HipHeight enforcement loop
RunService.Heartbeat:Connect(function()
    if walkSpeedEnabled and Humanoid.WalkSpeed ~= walkSpeed then
        Humanoid.WalkSpeed = walkSpeed
    elseif not walkSpeedEnabled and Humanoid.WalkSpeed ~= 16 then
        Humanoid.WalkSpeed = 16
    end
    if Humanoid.HipHeight ~= hipHeight then
        Humanoid.HipHeight = hipHeight
    end
end)

print("[HCBB Utility] Loaded successfully.")
