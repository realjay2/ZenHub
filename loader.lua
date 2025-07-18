print("Starting HCBB Util")
-- Load Orion UI from provided URL
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/wx-sources/OrionLibrary/main/orion-imported/OrionLibrary.lua"))()


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

local trashTalkMessages = {
    "You can't hit nun",
    "Knowledge of a 3rd grader",
    "your ba is probably -100",
    "Cant blame ping on that one son",
    "get better",
    "womp womp",
    "IQ of a Packet Loss",
    "Rando Pooron",
    "Your swing smells bad",
    "You swinging like grandma",
    "Bet you don't even lift",
    "Is that all you got?",
    "Trash talk so cold, ice age vibes"
}

-- Send trash talk in Roblox chat
local function sendTrashTalk()
    local message = trashTalkMessages[math.random(1, #trashTalkMessages)]
    SayMessageRequest:FireServer(message, "All")
end

-- Get strike zone adornee (SwingZone module or HomePlate or Terrain)
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

-- Create UI window
local Window = OrionLib:MakeWindow({
    Name = "⚾ HCBB Utility",
    HidePremium = true,
    SaveConfig = true,
    ConfigFolder = "HCBBConfig"
})

-- Movement Tab
local MovementTab = Window:MakeTab({
    Name = "Movement",
    Icon = "rbxassetid://4483345998"
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
        if hum then hum.HipHeight = hipHeight end
    end
})

-- Fly Tab
local FlyTab = Window:MakeTab({
    Name = "Fly",
    Icon = "rbxassetid://4483345998"
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
    Icon = "rbxassetid://4483345998"
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

-- Trash Talk Tab
local TrashTab = Window:MakeTab({
    Name = "Trash Talk",
    Icon = "rbxassetid://4483345998"
})

TrashTab:AddButton({
    Name = "Send Trash Talk",
    Callback = function()
        sendTrashTalk()
    end
})

-- Run loops and input handling

RunService.Heartbeat:Connect(function()
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

    -- Fly Logic
    if flyEnabled then
        local camera = workspace.CurrentCamera
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
            moveVec = moveVec.Unit * flySpeed * RunService.Heartbeat:Wait()
            hrp.CFrame = hrp.CFrame + moveVec
        end
    end
end)

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

-- Auto Aim logic
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

    -- Perfect Aim stub (you can add alignment to bat here)
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

-- Bat swing on LeftClick (connect UserInputService)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        if autoHitEnabled then
            -- Swing bat logic here
            -- (You can add bat animations or hit detection here)
            print("Swing bat (left click)")
        end
    end
end)

print("HCBB Utility loaded!")


-- Show Orion window
OrionLib:Init()
