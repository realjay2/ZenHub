local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/jensonhirst/Orion/main/source"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

-- Settings & State
local autoAimEnabled = false
local autoHitEnabled = false
local walkSpeedLoop = false
local jumpPowerLoop = false
local walkSpeed = 16
local jumpPower = 50
local offsetX, offsetY = 10, 10
local perfectAim = false
local pitchPredictionEnabled = false
local strikeZoneVisible = false
local highlightBox = nil
local strikeZoneBox = nil
local correctKey = "123"
local ballSpeedMultiplier = 2 -- Ball speed multiplier when pitching
local magBallEnabled = false

-- Root folder to browse in File Explorer
local rootFolder = workspace

-- Key Window
local KeyWindow = OrionLib:MakeWindow({
    Name = "HCBB Key System",
    HidePremium = false,
    SaveConfig = false,
    ConfigFolder = "HCBBKey"
})

local KeyTab = KeyWindow:MakeTab({
    Name = "Key Entry",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local mainWindow -- Will hold main UI window after key accepted

local function createMainUI()
    mainWindow = OrionLib:MakeWindow({
        Name = "⚾ HCBB Utility",
        HidePremium = false,
        SaveConfig = true,
        ConfigFolder = "HCBBMain"
    })

    -- Movement Tab
    local MoveTab = mainWindow:MakeTab({
        Name = "Movement",
        Icon = "rbxassetid://4483345998",
        PremiumOnly = false
    })

    MoveTab:AddSlider({
        Name = "WalkSpeed",
        Min = 16,
        Max = 29,           -- max 29 as requested
        Default = 16,
        Increment = 1,
        Callback = function(value)
            walkSpeed = value
        end
    })

    MoveTab:AddToggle({
        Name = "Loop WalkSpeed",
        Default = false,
        Callback = function(value)
            walkSpeedLoop = value
        end
    })

    MoveTab:AddSlider({
        Name = "JumpPower",
        Min = 50,
        Max = 50,           -- max 50 as requested
        Default = 50,
        Increment = 1,
        Callback = function(value)
            jumpPower = value
        end
    })

    MoveTab:AddToggle({
        Name = "Loop JumpPower",
        Default = false,
        Callback = function(value)
            jumpPowerLoop = value
        end
    })

    -- Pitch Prediction Tab
    local PredictTab = mainWindow:MakeTab({
        Name = "Pitch Prediction",
        Icon = "rbxassetid://4483345998",
        PremiumOnly = false
    })

    PredictTab:AddToggle({
        Name = "Enable Pitch Prediction",
        Default = false,
        Callback = function(value)
            pitchPredictionEnabled = value
            if value and strikeZoneVisible and not strikeZoneBox then
                strikeZoneBox = Instance.new("BoxHandleAdornment")
                strikeZoneBox.Size = Vector3.new(4, 4, 4)
                strikeZoneBox.Transparency = 0.7
                strikeZoneBox.Color3 = Color3.fromRGB(0, 255, 255)
                strikeZoneBox.AlwaysOnTop = true
                strikeZoneBox.ZIndex = 10
                local plate = Workspace:FindFirstChild("HomePlate") or Workspace:FindFirstChild("StrikeZone")
                if plate then
                    strikeZoneBox.Adornee = plate
                    strikeZoneBox.Parent = plate
                else
                    strikeZoneBox.Adornee = Workspace.Terrain
                    strikeZoneBox.Parent = Workspace.Terrain
                end
            elseif (not value or not strikeZoneVisible) and strikeZoneBox then
                strikeZoneBox:Destroy()
                strikeZoneBox = nil
            end
        end
    })

    PredictTab:AddToggle({
        Name = "Show Strike Zone",
        Default = false,
        Callback = function(value)
            strikeZoneVisible = value
            if strikeZoneVisible and pitchPredictionEnabled and not strikeZoneBox then
                strikeZoneBox = Instance.new("BoxHandleAdornment")
                strikeZoneBox.Size = Vector3.new(4, 4, 4)
                strikeZoneBox.Transparency = 0.7
                strikeZoneBox.Color3 = Color3.fromRGB(0, 255, 255)
                strikeZoneBox.AlwaysOnTop = true
                strikeZoneBox.ZIndex = 10
                local plate = Workspace:FindFirstChild("HomePlate") or Workspace:FindFirstChild("StrikeZone")
                if plate then
                    strikeZoneBox.Adornee = plate
                    strikeZoneBox.Parent = plate
                else
                    strikeZoneBox.Adornee = Workspace.Terrain
                    strikeZoneBox.Parent = Workspace.Terrain
                end
            elseif (not strikeZoneVisible or not pitchPredictionEnabled) and strikeZoneBox then
                strikeZoneBox:Destroy()
                strikeZoneBox = nil
            end
        end
    })

    PredictTab:AddToggle({
        Name = "Perfect Aim (Auto Align Bat)",
        Default = false,
        Callback = function(value)
            perfectAim = value
        end
    })

    -- Auto Aim Tab
    local AimTab = mainWindow:MakeTab({
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
        Name = "Mag Ball (Pull Ball to You)",
        Default = false,
        Callback = function(value)
            magBallEnabled = value
        end
    })

    -- File Explorer Tab
    local ExplorerTab = mainWindow:MakeTab({
        Name = "File Explorer",
        Icon = "rbxassetid://4483345998",
        PremiumOnly = false
    })

    local folderStack = {rootFolder}  -- stack to keep track of current folder path

    local FolderLabel = ExplorerTab:AddLabel({
        Name = "Current Folder: " .. rootFolder.Name
    })

    local ListFrame = ExplorerTab:AddScrollingFrame({
        Name = "Contents",
        Size = UDim2.new(1, 0, 0.8, 0),
        CanvasSize = UDim2.new(0, 0, 0, 0)
    })

    local InfoLabel = ExplorerTab:AddLabel({
        Name = "Select an item to see details."
    })

    local function clearList()
        for _, child in pairs(ListFrame:GetChildren()) do
            if child:IsA("TextButton") then
                child:Destroy()
            end
        end
    end

    local function updateList()
        clearList()
        local currentFolder = folderStack[#folderStack]
        FolderLabel:Set("Current Folder: " .. currentFolder.Name)

        local children = currentFolder:GetChildren()
        local yPos = 0

        for _, item in ipairs(children) do
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, -10, 0, 30)
            btn.Position = UDim2.new(0, 5, 0, yPos)
            btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            btn.BorderSizePixel = 0
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.TextXAlignment = Enum.TextXAlignment.Left
            btn.Font = Enum.Font.SourceSans
            btn.TextSize = 18
            btn.Text = (#item:GetChildren() > 0) and "[Folder] " .. item.Name or item.Name
            btn.Parent = ListFrame

            btn.MouseButton1Click:Connect(function()
                if #item:GetChildren() > 0 then
                    table.insert(folderStack, item)
                    updateList()
                    InfoLabel:Set("Select an item to see details.")
                else
                    local info = "Name: " .. item.Name .. "\nClass: " .. item.ClassName
                    if item:IsA("BasePart") then
                        info = info .. "\nPosition: " .. tostring(item.Position)
                        info = info .. "\nSize: " .. tostring(item.Size)
                    elseif item:IsA("Model") then
                        info = info .. "\nModel with " .. #item:GetChildren() .. " children"
                    elseif item:IsA("ValueBase") then
                        info = info .. "\nValue: " .. tostring(item.Value)
                    end
                    InfoLabel:Set(info)
                end
            end)
            yPos = yPos + 35
        end

        ListFrame.CanvasSize = UDim2.new(0, 0, 0, yPos)
    end

    local BackButton = ExplorerTab:AddButton({
        Name = "Back",
        Callback = function()
            if #folderStack > 1 then
                table.remove(folderStack)
                updateList()
                InfoLabel:Set("Select an item to see details.")
            end
        end
    })

    updateList()

    -- Other Tab for unload
    local OtherTab = mainWindow:MakeTab({
        Name = "Other",
        Icon = "rbxassetid://4483345998",
        PremiumOnly = false
    })

    OtherTab:AddButton({
        Name = "Unload Script",
        Callback = function()
            OrionLib:Destroy()
            walkSpeedLoop = false
            jumpPowerLoop = false
            autoAimEnabled = false
            autoHitEnabled = false
            pitchPredictionEnabled = false
            perfectAim = false
            magBallEnabled = false
            local char = LocalPlayer.Character
            if char and char:FindFirstChildOfClass("Humanoid") then
                local hum = char:FindFirstChildOfClass("Humanoid")
                hum.WalkSpeed = 16
                hum.JumpPower = 50
            end
            if highlightBox then
                highlightBox:Destroy()
                highlightBox = nil
            end
            if strikeZoneBox then
                strikeZoneBox:Destroy()
                strikeZoneBox = nil
            end
            -- Clean any magnet force left
            local ball = Workspace:FindFirstChild("Ball")
            if ball then
                local bf = ball:FindFirstChild("MagnetForce")
                if bf then bf:Destroy() end
            end
        end
    })

    -- Loops
    task.spawn(function()
        while true do
            local char = LocalPlayer.Character
            if char and char:FindFirstChildOfClass("Humanoid") then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if walkSpeedLoop then
                    hum.WalkSpeed = walkSpeed
                end
                if jumpPowerLoop then
                    hum.JumpPower = jumpPower
                end
            end
            task.wait(0.2)
        end
    end)

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
    end)

    task.spawn(function()
        while true do
            if autoHitEnabled then
                local ball = Workspace:FindFirstChild("Ball")
                local char = LocalPlayer.Character
                if char and ball and char:FindFirstChild("HumanoidRootPart") and (ball.Position - char.HumanoidRootPart.Position).Magnitude < 30 then
                    mouse1press()
                    task.wait(0.1)
                    mouse1release()
                end
            end
            task.wait(0.1)
        end
    end)

    RunService.RenderStepped:Connect(function()
        local char = LocalPlayer.Character
        if not char then return end

        -- Pitch Prediction highlight and Perfect Aim
        if pitchPredictionEnabled then
            local ball = Workspace:FindFirstChild("Ball")
            if ball then
                if not highlightBox then
                    highlightBox = Instance.new("BoxHandleAdornment")
                    highlightBox.Size = Vector3.new(4, 4, 4)
                    highlightBox.Transparency = 0.5
                    highlightBox.Color3 = Color3.fromRGB(255, 0, 0)
                    highlightBox.AlwaysOnTop = true
                    highlightBox.ZIndex = 10
                    highlightBox.Adornee = ball
                    highlightBox.Parent = ball
                end
                highlightBox.Adornee = ball
                if perfectAim then
                    local hrp = char:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        local dir = (ball.Position - hrp.Position).Unit
                        hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + dir)
                    end
                end
            else
                if highlightBox then
                    highlightBox:Destroy()
                    highlightBox = nil
                end
            end
        else
            if highlightBox then
                highlightBox:Destroy()
                highlightBox = nil
            end
        end
    end)

    -- Increase ball speed if YOU are pitching (adjust pitcher detection logic as needed)
    task.spawn(function()
        while true do
            local ball = Workspace:FindFirstChild("Ball")
            if ball then
                local pitcher = Workspace:FindFirstChild("Pitcher") -- Example placeholder; adjust for your game
                if pitcher and pitcher:IsA("Model") and pitcher.Name == LocalPlayer.Name then
                    local bodyVelocity = ball:FindFirstChildWhichIsA("BodyVelocity")
                    if not bodyVelocity then
                        bodyVelocity = Instance.new("BodyVelocity")
                        bodyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
                        bodyVelocity.Parent = ball
                    end
                    local vel = ball.Velocity
                    bodyVelocity.Velocity = vel * ballSpeedMultiplier
                else
                    local bodyVelocity = ball:FindFirstChildWhichIsA("BodyVelocity")
                    if bodyVelocity then
                        bodyVelocity:Destroy()
                    end
                end
            end
            task.wait(0.1)
        end
    end)

    -- Mag Ball: Pull ball to you from any distance
    task.spawn(function()
        while true do
            if magBallEnabled then
                local ball = Workspace:FindFirstChild("Ball")
                local char = LocalPlayer.Character
                if ball and char and char:FindFirstChild("HumanoidRootPart") then
                    local hrp = char.HumanoidRootPart
                    local direction = (hrp.Position - ball.Position)
                    local distance = direction.Magnitude
                    local pullStrength = math.clamp(distance * 5, 50, 1000) -- Adjust force strength as needed

                    local bodyForce = ball:FindFirstChild("MagnetForce")
                    if not bodyForce then
                        bodyForce = Instance.new("BodyForce")
                        bodyForce.Name = "MagnetForce"
                        bodyForce.Parent = ball
                    end

                    bodyForce.Force = direction.Unit * pullStrength * ball:GetMass()
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
            task.wait(0.1)
        end
    end)
end

KeyTab:AddTextbox({
    Name = "Enter Key (Hint: 123)",
    Default = "",
    TextDisappear = true,
    Callback = function(input)
        if input == correctKey then
            OrionLib:MakeNotification({
                Name = "✅ Correct Key",
                Content = "Loading UI...",
                Time = 3
            })
            createMainUI()
            KeyWindow:Destroy()
        else
            OrionLib:MakeNotification({
                Name = "❌ Wrong Key",
                Content = "Try again.",
                Time = 3
            })
        end
    end
})

OrionLib:Init()
