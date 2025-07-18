-- Load Orion Library safely
local OrionLib
do
    local success, response = pcall(function()
        return game:HttpGet("https://raw.githubusercontent.com/jensonhirst/Orion/main/source")
    end)

    if not success or not response or #response == 0 then
        warn("Failed to download Orion UI library. Check your internet and exploit settings.")
        return
    end

    local func, err = loadstring(response)
    if not func then
        warn("Failed to load Orion UI library: "..tostring(err))
        return
    end

    OrionLib = func()
end

if not OrionLib then
    warn("OrionLib is nil, aborting script.")
    return
end

-- Check Drawing API
if not Drawing then
    warn("Drawing API not supported by your exploit.")
    return
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

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

-- Orion UI Window
local Window = OrionLib:MakeWindow({
    Name = "⚾ HCBB Utility",
    HidePremium = true,
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
        if hum then hum.PlatformStand = value end
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

-- Strike Zone Tab (Drawing Box)
local StrikeZoneTab = Window:MakeTab({
    Name = "Strike Zone",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local box = Drawing.new("Square")
box.Size = Vector2.new(300, 300)
box.Color = Color3.fromRGB(0, 255, 255) -- default cyan
box.Thickness = 4
box.Filled = false
box.Transparency = 1
box.Visible = false

local boxVisible = false

StrikeZoneTab:AddToggle({
    Name = "Show Strike Zone Box",
    Default = false,
    Callback = function(value)
        boxVisible = value
        box.Visible = boxVisible
    end
})

local boxColor = box.Color
local boxThickness = box.Thickness

StrikeZoneTab:AddColorpicker({
    Name = "Box Color",
    Default = boxColor,
    Callback = function(color)
        boxColor = color
        box.Color = boxColor
    end
})

StrikeZoneTab:AddSlider({
    Name = "Box Thickness",
    Min = 1,
    Max = 10,
    Default = boxThickness,
    Increment = 1,
    Callback = function(value)
        boxThickness = value
        box.Thickness = boxThickness
    end
})

-- Ball ESP Tab
local BallESPTab = Window:MakeTab({
    Name = "Ball ESP",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local highlight -- Highlight instance for the ball ESP
local espEnabled = false

local ballFillColor = Color3.new(1, 0, 0) -- default red
local ballBorderColor = Color3.new(1, 1, 1) -- default white

local function enableBallESP(enable)
    local ball = ReplicatedStorage:FindFirstChild("Ball")
    if enable and ball then
        if not highlight then
            highlight = Instance.new("Highlight")
            highlight.Name = "BallHighlight"
            highlight.Adornee = ball
            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            highlight.FillColor = ballFillColor
            highlight.OutlineColor = ballBorderColor
            highlight.Parent = ball
        else
            highlight.Adornee = ball
            highlight.FillColor = ballFillColor
            highlight.OutlineColor = ballBorderColor
        end
    elseif highlight then
        highlight:Destroy()
        highlight = nil
    end
end

BallESPTab:AddToggle({
    Name = "Enable Ball ESP",
    Default = false,
    Callback = function(value)
        espEnabled = value
        enableBallESP(value)
    end
})

BallESPTab:AddColorpicker({
    Name = "Ball Fill Color",
    Default = ballFillColor,
    Callback = function(color)
        ballFillColor = color
        if highlight then
            highlight.FillColor = ballFillColor
        end
    end
})

BallESPTab:AddColorpicker({
    Name = "Ball Border Color",
    Default = ballBorderColor,
    Callback = function(color)
        ballBorderColor = color
        if highlight then
            highlight.OutlineColor = ballBorderColor
        end
    end
})

-- Main RunService update loop
RunService.Heartbeat:Connect(function()
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
end)

-- Fly movement with CFrame
RunService.Heartbeat:Connect(function()
    if flyEnabled then
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local camera = Workspace.CurrentCamera
        local moveVec = Vector3.new(0,0,0)

        if flyUp then moveVec = moveVec + Vector3.new(0, 1, 0) end
        if flyDown then moveVec = moveVec + Vector3.new(0, -1, 0) end
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
            hrp.CFrame = hrp.CFrame + moveVec * RunService.Heartbeat:Wait()
        end
    end
end)

-- Fly up/down keys
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
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

-- Update strike zone box position every frame to stay centered on screen
RunService.RenderStepped:Connect(function()
    if boxVisible then
        local cam = Workspace.CurrentCamera
        if cam then
            local viewport = cam.ViewportSize
            box.Position = Vector2.new(viewport.X/2 - box.Size.X/2, viewport.Y/2 - box.Size.Y/2)
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
            local dir = (targetPos - hrp.Position).Unit
            hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + Vector3.new(dir.X, 0, dir.Z))
        end
    end
end)

-- Auto Hit loop (simulate left click)
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

-- Pull ball to you if MagBall enabled
RunService.Heartbeat:Connect(function()
    if magBallEnabled then
        local ball = Workspace:FindFirstChild("Ball")
        local char = LocalPlayer.Character
        if ball and char and char:FindFirstChild("HumanoidRootPart") then
            ball.Velocity = Vector3.new(0, 0, 0)
            local direction = (char.HumanoidRootPart.Position - ball.Position).Unit
            ball.CFrame = ball.CFrame + direction * 2
        end
    end
end)

-- Keep highlight updated if ball changes
RunService.Heartbeat:Connect(function()
    if espEnabled then
        local ball = ReplicatedStorage:FindFirstChild("Ball")
        if ball then
            if highlight and highlight.Adornee ~= ball then
                highlight.Adornee = ball
                highlight.FillColor = ballFillColor
                highlight.OutlineColor = ballBorderColor
            elseif not highlight then
                enableBallESP(true)
            end
        else
            if highlight then
                highlight:Destroy()
                highlight = nil
            end
        end
    end
end)

print("Bypassed HCBB fuckass anti-cheat")
-- Initialize Orion UI
OrionLib:Init()
