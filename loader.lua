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

local json = (loadstring or load)("return " .. game:HttpGet("https://raw.githubusercontent.com/rxi/json.lua/master/json.lua"))()
local writefile = writefile or (syn and syn.write_file)
local readfile = readfile or (syn and syn.read_file)
local isfile = isfile or (syn and syn.is_file)

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

local boxVisible = false
local boxColor = Color3.fromRGB(0, 255, 255)
local boxThickness = 4

local espEnabled = false
local ballFillColor = Color3.new(1, 0, 0)
local ballBorderColor = Color3.new(1, 1, 1)

local highlight -- Highlight instance

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

-- Strike Zone Tab
local StrikeZoneTab = Window:MakeTab({
    Name = "Strike Zone",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local box = Drawing.new("Square")
box.Size = Vector2.new(200, 200)
box.Color = boxColor
box.Thickness = boxThickness
box.Filled = false
box.Transparency = 1
box.Visible = false

StrikeZoneTab:AddToggle({
    Name = "Show Strike Zone Box",
    Default = false,
    Callback = function(value)
        boxVisible = value
        box.Visible = boxVisible
    end
})

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

BallESPTab:AddToggle({
    Name = "Enable Ball ESP",
    Default = false,
    Callback = function(value)
        espEnabled = value
        if espEnabled then
            local ball = ReplicatedStorage:FindFirstChild("Ball")
            if ball then
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
            end
        else
            if highlight then
                highlight:Destroy()
                highlight = nil
            end
        end
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

-- Config Tab for saving/loading config
local ConfigTab = Window:MakeTab({
    Name = "Config",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local configFileName = "HCBBConfig.json"

local function saveConfig()
    local configData = {
        walkSpeed = walkSpeed,
        walkSpeedEnabled = walkSpeedEnabled,
        jumpPower = jumpPower,
        jumpPowerEnabled = jumpPowerEnabled,
        hipHeight = hipHeight,

        flyEnabled = flyEnabled,
        flySpeed = flySpeed,

        autoAimEnabled = autoAimEnabled,
        autoHitEnabled = autoHitEnabled,
        perfectAim = perfectAim,
        magBallEnabled = magBallEnabled,
        offsetX = offsetX,
        offsetY = offsetY,

        boxVisible = boxVisible,
        boxColor = {boxColor.R, boxColor.G, boxColor.B},
        boxThickness = boxThickness,

        espEnabled = espEnabled,
        ballFillColor = {ballFillColor.R, ballFillColor.G, ballFillColor.B},
        ballBorderColor = {ballBorderColor.R, ballBorderColor.G, ballBorderColor.B},
    }

    local encoded = json.encode(configData)
    if writefile then
        writefile(configFileName, encoded)
        OrionLib:MakeNotification({
            Name = "Config",
            Content = "Config saved successfully!",
            Time = 5
        })
    else
        warn("writefile not supported, can't save config.")
    end
end

local function loadConfig()
    if isfile and isfile(configFileName) and readfile then
        local content = readfile(configFileName)
        if content then
            local success, decoded = pcall(function() return json.decode(content) end)
            if success and decoded then
                walkSpeed = decoded.walkSpeed or walkSpeed
                walkSpeedEnabled = decoded.walkSpeedEnabled or walkSpeedEnabled
                jumpPower = decoded.jumpPower or jumpPower
                jumpPowerEnabled = decoded.jumpPowerEnabled or jumpPowerEnabled
                hipHeight = decoded.hipHeight or hipHeight

                flyEnabled = decoded.flyEnabled or flyEnabled
                flySpeed = decoded.flySpeed or flySpeed

                autoAimEnabled = decoded.autoAimEnabled or autoAimEnabled
                autoHitEnabled = decoded.autoHitEnabled or autoHitEnabled
                perfectAim = decoded.perfectAim or perfectAim
                magBallEnabled = decoded.magBallEnabled or magBallEnabled
                offsetX = decoded.offsetX or offsetX
                offsetY = decoded.offsetY or offsetY

                boxVisible = decoded.boxVisible or boxVisible
                local bc = decoded.boxColor
                if bc and #bc == 3 then
                    boxColor = Color3.new(bc[1], bc[2], bc[3])
                end
                boxThickness = decoded.boxThickness or boxThickness

                espEnabled = decoded.espEnabled or espEnabled
                local bfc = decoded.ballFillColor
                if bfc and #bfc == 3 then
                    ballFillColor = Color3.new(bfc[1], bfc[2], bfc[3])
                end
                local bbc = decoded.ballBorderColor
                if bbc and #bbc == 3 then
                    ballBorderColor = Color3.new(bbc[1], bbc[2], bbc[3])
                end

                -- Apply loaded settings to UI & effects
                -- Movement
                MovementTab:FindFirstChild("WalkSpeed"):SetValue(walkSpeed)
                MovementTab:FindFirstChild("Enable WalkSpeed"):SetValue(walkSpeedEnabled)
                MovementTab:FindFirstChild("JumpPower"):SetValue(jumpPower)
                MovementTab:FindFirstChild("Enable JumpPower"):SetValue(jumpPowerEnabled)
                MovementTab:FindFirstChild("HipHeight"):SetValue(hipHeight)

                -- Fly
                FlyTab:FindFirstChild("Enable Fly"):SetValue(flyEnabled)
                FlyTab:FindFirstChild("Fly Speed"):SetValue(flySpeed)

                -- Aim
                AimTab:FindFirstChild("Auto Aim"):SetValue(autoAimEnabled)
                AimTab:FindFirstChild("Offset X"):SetValue(offsetX)
                AimTab:FindFirstChild("Offset Y"):SetValue(offsetY)
                AimTab:FindFirstChild("Auto Hit (Left Click)"):SetValue(autoHitEnabled)
                AimTab:FindFirstChild("Perfect Aim (Auto Align Bat)"):SetValue(perfectAim)
                AimTab:FindFirstChild("Mag Ball (Pull Ball to You)"):SetValue(magBallEnabled)

                -- Strike Zone
                StrikeZoneTab:FindFirstChild("Show Strike Zone Box"):SetValue(boxVisible)
                StrikeZoneTab:FindFirstChild("Box Color"):SetColor(boxColor)
                StrikeZoneTab:FindFirstChild("Box Thickness"):SetValue(boxThickness)

                -- Ball ESP
                BallESPTab:FindFirstChild("Enable Ball ESP"):SetValue(espEnabled)
                BallESPTab:FindFirstChild("Ball Fill Color"):SetColor(ballFillColor)
                BallESPTab:FindFirstChild("Ball Border Color"):SetColor(ballBorderColor)

                OrionLib:MakeNotification({
                    Name = "Config",
                    Content = "Config loaded successfully!",
                    Time = 5
                })
            else
                warn("Failed to decode config file.")
            end
        end
    else
        OrionLib:MakeNotification({
            Name = "Config",
            Content = "No config file found to load.",
            Time = 5
        })
    end
end

ConfigTab:AddButton({
    Name = "Save Config",
    Callback = function()
        saveConfig()
    end
})

ConfigTab:AddButton({
    Name = "Load Config",
    Callback = function()
        loadConfig()
    end
})

-- RunService updates
RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hum or not hrp then return end

    if walkSpeedEnabled and hum.WalkSpeed ~= walkSpeed then
        hum.WalkSpeed = walkSpeed
    elseif not walkSpeedEnabled and hum.WalkSpeed ~= 16 then
        hum.WalkSpeed = 16
    end

    if jumpPowerEnabled and hum.JumpPower ~= jumpPower then
        hum.JumpPower = jumpPower
    elseif not jumpPowerEnabled and hum.JumpPower ~= 50 then
        hum.JumpPower = 50
    end

    if hum.HipHeight ~= hipHeight then
        hum.HipHeight = hipHeight
    end
end)

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

-- Update strike zone box position every frame
RunService.RenderStepped:Connect(function()
    if boxVisible then
        local cam = Workspace.CurrentCamera
        if cam then
            local viewport = cam.ViewportSize
            box.Position = Vector2.new(viewport.X/2 - box.Size.X/2, viewport.Y/2 - box.Size.Y/2)
        end
    end
end)

-- Keep highlight updated if ball changes or ESP toggled
RunService.Heartbeat:Connect(function()
    if espEnabled then
        local ball = ReplicatedStorage:FindFirstChild("Ball")
        if ball then
            if highlight and highlight.Adornee ~= ball then
                highlight.Adornee = ball
                highlight.FillColor = ballFillColor
                highlight.OutlineColor = ballBorderColor
                highlight.Parent = ball
            elseif not highlight then
                highlight = Instance.new("Highlight")
                highlight.Name = "BallHighlight"
                highlight.Adornee = ball
                highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                highlight.FillColor = ballFillColor
                highlight.OutlineColor = ballBorderColor
                highlight.Parent = ball
            end
        else
            if highlight then
                highlight:Destroy()
                highlight = nil
            end
        end
    else
        if highlight then
            highlight:Destroy()
            highlight = nil
        end
    end
end)

-- Initialize Orion UI
OrionLib:Init()
