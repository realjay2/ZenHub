local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/jensonhirst/Orion/main/source"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local HttpService = game:GetService("HttpService")

-- Settings & State
local autoAimEnabled = false
local autoHitEnabled = false
local walkSpeedLoop = false
local jumpPowerLoop = false
local walkSpeed = 16
local jumpPower = 65
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

-- Iris Exploit UI Init (will initialize only when Iris tab activated)
local IrisLoaded = false
local Iris = nil
local PropertyAPIDump = nil
local ScriptContent = [[]]
local SelectedInstance = nil
local Properties = {}

-- Iris State variables
local InstanceViewer = nil
local PropertyViewer = nil
local ScriptViewer = nil

local function GetPropertiesForInstance(Instance)
    local Properties = {}
    for i,v in next, PropertyAPIDump do
        if v.Class == Instance.ClassName and v.type == "Property" then
            pcall(function()
                Properties[v.Name] = {
                    Value = Instance[v.Name],
                    Type = v.ValueType,
                }
            end)
        end
    end
    return Properties
end

local function CrawlInstances(Inst)
    for _, Instance in next, Inst:GetChildren() do
        local InstTree = Iris.Tree({Instance.Name})

        Iris.SameLine() do
            if Instance:IsA("LocalScript") or Instance:IsA("ModuleScript") then
                if Iris.SmallButton({"View Script"}).clicked then
                    ScriptContent = decompile(Instance)
                end
            end
            if Iris.SmallButton({"View Properties"}).clicked then
                SelectedInstance = Instance
                Properties = GetPropertiesForInstance(Instance)
            end
            Iris.End()
        end

        if InstTree.state.isUncollapsed.value then
            CrawlInstances(Instance)
        end
        Iris.End()
    end
end

local function InitIris()
    if IrisLoaded then return end
    IrisLoaded = true
    Iris = loadstring(game:HttpGet("https://raw.githubusercontent.com/x0581/Iris-Exploit-Bundle/main/bundle.lua"))().Init()
    PropertyAPIDump = HttpService:JSONDecode(game:HttpGet("https://anaminus.github.io/rbx/json/api/latest.json"))

    -- Initialize Iris State
    InstanceViewer = Iris.State(false)
    PropertyViewer = Iris.State(false)
    ScriptViewer = Iris.State(false)

    Iris:Connect(function()
        Iris.Window({"MikeExplorer Settings", [Iris.Args.Window.NoResize] = true}, {size = Iris.State(Vector2.new(400, 75)), position = Iris.State(Vector2.new(0, 0))}) do
            Iris.SameLine() do
                Iris.Checkbox({"Instance Viewer"}, {isChecked = InstanceViewer})
                Iris.Checkbox({"Property Viewer"}, {isChecked = PropertyViewer})
                Iris.Checkbox({"Script Viewer"}, {isChecked = ScriptViewer})
                Iris.End()
            end
            Iris.End()
        end

        if InstanceViewer.value then
            Iris.Window({"MikeExplorer Instance Viewer", [Iris.Args.Window.NoClose] = true}, {size = Iris.State(Vector2.new(400, 300)), position = Iris.State(Vector2.new(0, 75))}) do
                CrawlInstances(game)
                Iris.End()
            end
        end

        if PropertyViewer.value then
            Iris.Window({"MikeExplorer Property Viewer", [Iris.Args.Window.NoClose] = true}, {size = Iris.State(Vector2.new(400, 200)), position = Iris.State(Vector2.new(0, 375))}) do
                Iris.Text({("Viewing Properties For: %s"):format(
                    SelectedInstance and SelectedInstance:GetFullName() or "UNKNOWN INSTANCE"
                )})
                Iris.Table({3, [Iris.Args.Table.RowBg] = true}) do
                    for PropertyName, PropDetails in next, Properties do
                        Iris.Text({PropertyName})
                        Iris.NextColumn()
                        Iris.Text({PropDetails.Type})
                        Iris.NextColumn()
                        Iris.Text({tostring(PropDetails.Value)})
                        Iris.NextColumn()
                    end
                    Iris.End()
                end
            end
            Iris.End()
        end

        if ScriptViewer.value then
            Iris.Window({"MikeExplorer Script Viewer", [Iris.Args.Window.NoClose] = true}, {size = Iris.State(Vector2.new(600, 575)), position = Iris.State(Vector2.new(400, 0))}) do
                if Iris.Button({"Copy To Clipboard"}).clicked then
                    setclipboard(ScriptContent)
                end
                local Lines = ScriptContent:split("\n")
                for I, Line in next, Lines do
                    Iris.Text({Line})
                end
                Iris.End()
            end
        end
    end)
end

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
        Max = 29,
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
        Max = 65,
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

    -- Iris Explorer Tab (new!)
    local IrisTab = mainWindow:MakeTab({
        Name = "Iris Explorer",
        Icon = "rbxassetid://4483345998",
        PremiumOnly = false
    })

    local IrisToggle = IrisTab:AddToggle({
        Name = "Enable Iris UI",
        Default = false,
        Callback = function(value)
            if value then
                InitIris()
                -- Iris UI now visible as floating windows, no blocking Orion UI
            else
                if IrisLoaded and Iris then
                    Iris:Destroy()
                    Iris = nil
                    IrisLoaded = false
                end
            end
        end
    })

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
            if IrisLoaded and Iris then
                Iris:Destroy()
                Iris = nil
                IrisLoaded = false
            end
        end
    })

    -- Apply WalkSpeed and JumpPower continuously
    RunService.Heartbeat:Connect(function()
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                if walkSpeedLoop then
                    if hum.WalkSpeed ~= walkSpeed then
                        hum.WalkSpeed = walkSpeed
                    end
                else
                    if hum.WalkSpeed ~= 16 then
                        hum.WalkSpeed = 16
                    end
                end

                if jumpPowerLoop then
                    if hum.JumpPower ~= jumpPower then
                        hum.JumpPower = jumpPower
                    end
                else
                    if hum.JumpPower ~= 50 then
                        hum.JumpPower = 50
                    end
                end
            end
        end
    end)

    -- Auto Aim
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

    -- Auto Hit (Left Click)
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
