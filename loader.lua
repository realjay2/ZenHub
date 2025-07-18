-- Load Rayfield UI
local Rayfield = loadstring(game:HttpGet("https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/source.lua"))()

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Character
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HRP = Character:WaitForChild("HumanoidRootPart")

-- Chat Event
local ChatEvents = ReplicatedStorage:WaitForChild("DefaultChatSystemChatEvents")
local SayMessageRequest = ChatEvents:WaitForChild("SayMessageRequest")

-- Trash Talk Messages
local trashTalkMessages = {
    "You can't hit nun",
    "Knowledge of a 3rd grader",
    "Your BA is probably -100",
    "Can't blame ping on that one son",
    "Get better",
    "Womp womp",
    "IQ of a packet loss",
    "Rando Pooron"
}

-- States
local flying = false
local walkspeedEnabled = false
local flySpeed = 1
local wsSpeed = 16

-- UI Setup
Rayfield:CreateWindow({Name = "Phoenix Ultra ⚾", LoadingTitle = "Initializing", ConfigurationSaving = {Enabled = false}})

local MainTab = Rayfield:CreateTab({Name = "Main", Icon = "🏃"})
local GameTab = Rayfield:CreateTab({Name = "Game Tools", Icon = "🧠"})
local MiscTab = Rayfield:CreateTab({Name = "Misc", Icon = "🎯"})

-- Fly
MainTab:CreateToggle({
    Name = "Fly (CFrame)",
    CurrentValue = false,
    Callback = function(state)
        flying = state
    end,
})

-- WalkSpeed
MainTab:CreateToggle({
    Name = "WalkSpeed (CFrame)",
    CurrentValue = false,
    Callback = function(state)
        walkspeedEnabled = state
    end,
})

MainTab:CreateSlider({
    Name = "Speed",
    Range = {1, 30},
    Increment = 1,
    CurrentValue = 16,
    Callback = function(value)
        wsSpeed = value
        flySpeed = value
    end,
})

-- HipHeight
MiscTab:CreateSlider({
    Name = "Hip Height",
    Range = {0, 50},
    Increment = 1,
    CurrentValue = 2,
    Callback = function(value)
        Humanoid.HipHeight = value
    end,
})

-- Trash Talk
MiscTab:CreateButton({
    Name = "Trash Talk",
    Callback = function()
        local msg = trashTalkMessages[math.random(1, #trashTalkMessages)]
        SayMessageRequest:FireServer(msg, "All")
    end,
})

-- Ball Highlighter & Strike Zone Projection
GameTab:CreateButton({
    Name = "Highlight Ball & Project",
    Callback = function()
        local ball = workspace:FindFirstChild("Ball")
        local gui = ReplicatedStorage:FindFirstChild("HRDGui")
        if not (ball and gui) then return end

        -- Highlight
        if not ball:FindFirstChild("SelectionBox") then
            local sel = Instance.new("SelectionBox", ball)
            sel.Adornee = ball
            sel.Color3 = Color3.new(1, 1, 0)
            sel.LineThickness = 0.05
        end

        -- Predict path
        local projection = Instance.new("Part", workspace)
        projection.Anchored = true
        projection.CanCollide = false
        projection.Transparency = 0.5
        projection.Color = Color3.new(0, 1, 0)
        projection.Material = Enum.Material.Neon
        projection.Shape = Enum.PartType.Ball
        projection.Size = Vector3.new(0.5, 0.5, 0.5)

        -- Simple prediction
        local predictedPos = ball.Position + ball.Velocity * 0.5
        projection.Position = predictedPos

        -- Check if it's in strike zone
        local swingZone = gui:FindFirstChild("SwingZone")
        if swingZone then
            local zoneCF = swingZone.CFrame
            local zoneSize = swingZone.Size
            local inZone = (predictedPos.X >= (zoneCF.X - zoneSize.X/2) and predictedPos.X <= (zoneCF.X + zoneSize.X/2)) and
                           (predictedPos.Y >= (zoneCF.Y - zoneSize.Y/2) and predictedPos.Y <= (zoneCF.Y + zoneSize.Y/2)) and
                           (predictedPos.Z >= (zoneCF.Z - zoneSize.Z/2) and predictedPos.Z <= (zoneCF.Z + zoneSize.Z/2))

            if inZone then
                projection.Color = Color3.new(0, 1, 0) -- green
            else
                projection.Color = Color3.new(1, 0, 0) -- red
            end
        end
    end,
})

-- Input: Left Click to Swing Bat
Mouse.Button1Down:Connect(function()
    local tool = Character:FindFirstChildOfClass("Tool")
    if tool and tool:FindFirstChild("Swing") then
        pcall(function()
            tool.Swing:FireServer()
        end)
    end
end)

-- Fly / WS Logic
RunService.RenderStepped:Connect(function()
    if flying or walkspeedEnabled then
        local direction = Vector3.zero
        if UIS:IsKeyDown(Enum.KeyCode.W) then direction += workspace.CurrentCamera.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then direction -= workspace.CurrentCamera.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then direction -= workspace.CurrentCamera.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then direction += workspace.CurrentCamera.CFrame.RightVector end

        direction = direction.Unit
        if direction.Magnitude > 0 then
            HRP.CFrame = HRP.CFrame + (direction * (flying and flySpeed or wsSpeed) * RunService.RenderStepped:Wait())
        end
    end
end)
