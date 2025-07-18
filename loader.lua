-- Load Rayfield UI
local Rayfield = loadstring(game:HttpGet("https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/source.lua"))()

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Debris = game:GetService("Debris")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HRP = Character:WaitForChild("HumanoidRootPart")

-- Window Setup
local Window = Rayfield:CreateWindow({
	Name = "HCBB Utility",
	LoadingTitle = "HCBB Script Loader",
	LoadingSubtitle = "by Kai",
	ConfigurationSaving = { Enabled = false },
	Discord = { Enabled = false },
	KeySystem = false
})

-- Global Vars
local flightSpeed = 3
local walkSpeed = 16
local hipHeight = Humanoid.HipHeight
local walkSpeedEnabled = false
local flying = false
local trashTalkMessages = {
	"You can't hit nun", "IQ of a Packet Loss", "Knowledge of a 3rd grader",
	"your ba is probably -100", "Cant blame ping on that one", "get better",
	"womp womp", "Rando Pooron", "You're swinging like a tee-ball player"
}

-- WalkSpeed Controller
RunService.RenderStepped:Connect(function()
	if walkSpeedEnabled then
		Humanoid.WalkSpeed = walkSpeed
	else
		Humanoid.WalkSpeed = 16
	end
end)

-- Fly System
local function fly()
	if flying then return end
	flying = true

	local bv = Instance.new("BodyVelocity")
	bv.Name = "FlightVelocity"
	bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
	bv.Velocity = Vector3.zero
	bv.Parent = HRP

	RunService:BindToRenderStep("FlyControl", Enum.RenderPriority.Input.Value, function()
		local cam = workspace.CurrentCamera
		local dir = Vector3.zero
		if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += cam.CFrame.LookVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= cam.CFrame.LookVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= cam.CFrame.RightVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += cam.CFrame.RightVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir += cam.CFrame.UpVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir -= cam.CFrame.UpVector end
		bv.Velocity = dir.Unit * flightSpeed
	end)
end

local function stopFly()
	flying = false
	local bv = HRP:FindFirstChild("FlightVelocity")
	if bv then bv:Destroy() end
	RunService:UnbindFromRenderStep("FlyControl")
end

-- Trash Talk
local function sayTrash()
	local chatEvent = ReplicatedStorage:WaitForChild("DefaultChatSystemChatEvents"):WaitForChild("SayMessageRequest")
	local msg = trashTalkMessages[math.random(1, #trashTalkMessages)]
	chatEvent:FireServer(msg, "All")
end

-- Ball Highlight + Prediction
local function highlightAndPredict()
	local ball = workspace:FindFirstChild("Ball")
	if not ball then return end

	if not ball:FindFirstChild("Highlight") then
		local hl = Instance.new("Highlight")
		hl.Name = "Highlight"
		hl.FillColor = Color3.fromRGB(255, 255, 0)
		hl.OutlineColor = Color3.fromRGB(255, 0, 0)
		hl.FillTransparency = 0.5
		hl.OutlineTransparency = 0
		hl.Parent = ball
	end

	local proj = Instance.new("Part")
	proj.Anchored = true
	proj.CanCollide = false
	proj.Shape = Enum.PartType.Ball
	proj.Size = Vector3.new(0.5, 0.5, 0.5)
	proj.Material = Enum.Material.Neon
	proj.Color = Color3.fromRGB(0, 255, 0)
	proj.Position = ball.Position + (ball.Velocity.Unit * 5)
	proj.Parent = workspace
	Debris:AddItem(proj, 1)
end

-- Left Click Swing
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if input.UserInputType == Enum.UserInputType.MouseButton1 and not gameProcessed then
		local bat = Character:FindFirstChild("Bat")
		if bat and bat:FindFirstChild("Swing") then
			bat.Swing:FireServer()
		end
	end
end)

-- StrikeZone
local SwingZone = ReplicatedStorage:WaitForChild("HRDGui"):FindFirstChild("SwingZone")

-- UI Tabs
local movementTab = Window:CreateTab("Movement", 4483362458)
movementTab:CreateToggle({
	Name = "Enable Fly",
	CurrentValue = false,
	Callback = function(state)
		if state then fly() else stopFly() end
	end
})

movementTab:CreateSlider({
	Name = "Flight Speed",
	Range = {1, 25},
	Increment = 1,
	CurrentValue = flightSpeed,
	Callback = function(val) flightSpeed = val end
})

movementTab:CreateToggle({
	Name = "Custom Walkspeed",
	CurrentValue = false,
	Callback = function(val) walkSpeedEnabled = val end
})

movementTab:CreateSlider({
	Name = "Walkspeed",
	Range = {16, 100},
	Increment = 1,
	CurrentValue = walkSpeed,
	Callback = function(val) walkSpeed = val end
})

movementTab:CreateSlider({
	Name = "HipHeight",
	Range = {0, 5},
	Increment = 0.1,
	CurrentValue = hipHeight,
	Callback = function(val)
		hipHeight = val
		Humanoid.HipHeight = hipHeight
	end
})

local miscTab = Window:CreateTab("Utilities", 4483361031)
miscTab:CreateButton({
	Name = "🔥 Trash Talk",
	Callback = sayTrash
})

miscTab:CreateButton({
	Name = "📍 Highlight Ball + Predict",
	Callback = highlightAndPredict
})

miscTab:CreateParagraph({
	Title = "SwingZone Module",
	Content = SwingZone and "SwingZone module found ✅" or "Not found ❌"
})
