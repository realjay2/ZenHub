

local ScreenGui = Instance.new("ScreenGui")
local Main = Instance.new("Frame")
local UICorner = Instance.new("UICorner")
local TextLabel = Instance.new("TextLabel")
local UICorner_2 = Instance.new("UICorner")
local TextLabel_2 = Instance.new("TextLabel")
local UICorner_3 = Instance.new("UICorner")
local TextLabel_3 = Instance.new("TextLabel")
local UICorner_4 = Instance.new("UICorner")
local Slam01 = Instance.new("TextButton")
local UICorner_5 = Instance.new("UICorner")
local Slam05 = Instance.new("TextButton")
local UICorner_6 = Instance.new("UICorner")
local Slam5 = Instance.new("TextButton")
local UICorner_7 = Instance.new("UICorner")
local Slam1 = Instance.new("TextButton")
local UICorner_8 = Instance.new("UICorner")
local Lift1 = Instance.new("TextButton")
local UICorner_9 = Instance.new("UICorner")
local Lift01 = Instance.new("TextButton")
local UICorner_10 = Instance.new("UICorner")
local Lift05 = Instance.new("TextButton")
local UICorner_11 = Instance.new("UICorner")
local Lift5 = Instance.new("TextButton")
local UICorner_12 = Instance.new("UICorner")
local Weight = Instance.new("TextButton")
local UICorner_13 = Instance.new("UICorner")
local LowRide = Instance.new("TextButton")
local UICorner_14 = Instance.new("UICorner")
local LowRideBounce = Instance.new("TextButton")
local UICorner_15 = Instance.new("UICorner")
local CloseButton = Instance.new("TextButton")
local UICorner_16 = Instance.new("UICorner")

--Properties:

ScreenGui.Parent = game.CoreGui

Main.Name = "Main"
Main.Parent = ScreenGui
Main.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Main.BorderColor3 = Color3.fromRGB(0, 0, 0)
Main.BorderSizePixel = 0
Main.Position = UDim2.new(0.247353509, 0, 0.313559324, 0)
Main.Size = UDim2.new(0, 590, 0, 329)
Main.Active = true
Main.Draggable = true

UICorner.CornerRadius = UDim.new(0, 9)
UICorner.Parent = Main

TextLabel.Parent = Main
TextLabel.BackgroundColor3 = Color3.fromRGB(29, 29, 29)
TextLabel.BorderColor3 = Color3.fromRGB(255, 255, 255)
TextLabel.BorderSizePixel = 0
TextLabel.Size = UDim2.new(0, 590, 0, 27)
TextLabel.Font = Enum.Font.Unknown
TextLabel.Text = "VEOX HUB | ERLC"
TextLabel.TextColor3 = Color3.fromRGB(48, 16, 177)
TextLabel.TextScaled = true
TextLabel.TextSize = 14.000
TextLabel.TextWrapped = true

UICorner_2.CornerRadius = UDim.new(0, 9)
UICorner_2.Parent = TextLabel

TextLabel_2.Parent = Main
TextLabel_2.BackgroundColor3 = Color3.fromRGB(29, 29, 29)
TextLabel_2.BorderColor3 = Color3.fromRGB(0, 0, 0)
TextLabel_2.BorderSizePixel = 0
TextLabel_2.Position = UDim2.new(0.0423728824, 0, 0.106382981, 0)
TextLabel_2.Size = UDim2.new(0, 245, 0, 50)
TextLabel_2.Font = Enum.Font.Arcade
TextLabel_2.Text = "SLAM"
TextLabel_2.TextColor3 = Color3.fromRGB(112, 29, 255)
TextLabel_2.TextScaled = true
TextLabel_2.TextSize = 14.000
TextLabel_2.TextWrapped = true

UICorner_3.CornerRadius = UDim.new(1, 0)
UICorner_3.Parent = TextLabel_2

TextLabel_3.Parent = Main
TextLabel_3.BackgroundColor3 = Color3.fromRGB(29, 29, 29)
TextLabel_3.BorderColor3 = Color3.fromRGB(0, 0, 0)
TextLabel_3.BorderSizePixel = 0
TextLabel_3.Position = UDim2.new(0.542372882, 0, 0.106382981, 0)
TextLabel_3.Size = UDim2.new(0, 245, 0, 50)
TextLabel_3.Font = Enum.Font.Arcade
TextLabel_3.Text = "LIFT"
TextLabel_3.TextColor3 = Color3.fromRGB(112, 29, 255)
TextLabel_3.TextScaled = true
TextLabel_3.TextSize = 14.000
TextLabel_3.TextWrapped = true

UICorner_4.CornerRadius = UDim.new(1, 0)
UICorner_4.Parent = TextLabel_3

Slam01.Name = "Slam0.1"
Slam01.Parent = Main
Slam01.BackgroundColor3 = Color3.fromRGB(29, 29, 29)
Slam01.BorderColor3 = Color3.fromRGB(0, 0, 0)
Slam01.BorderSizePixel = 0
Slam01.Position = UDim2.new(0.142372876, 0, 0.288753808, 0)
Slam01.Size = UDim2.new(0, 126, 0, 32)
Slam01.Font = Enum.Font.Arcade
Slam01.Text = "0.1"
Slam01.TextColor3 = Color3.fromRGB(112, 29, 255)
Slam01.TextScaled = true
Slam01.TextSize = 14.000
Slam01.TextWrapped = true
Slam01.MouseButton1Down:Connect(function()
	local player = game.Players.LocalPlayer
	local character = player.Character or player.CharacterAdded:Wait()
	local humanoid = character:WaitForChild("Humanoid")

	-- Function to get the vehicle the player is sitting in
	local function getVehicle()
		local seatPart = humanoid.SeatPart
		if seatPart and seatPart:IsA("VehicleSeat") then
			if seatPart.Occupant == humanoid then
				return seatPart.Parent  -- Return the car model
			end
		end
		return nil
	end

	-- Function to slam the car body down while keeping the wheels in place
	local function slamCarBody(car, height)
		if not car then return end

		local body = car:FindFirstChild("Body")  -- Adjust based on your model structure
		if not body then return end

		-- Find the Vehicle_Lights part and move each part inside it
		local lights = car:FindFirstChild("Body"):FindFirstChild("Vehicle_Lights")
		if lights then
			for _, light in pairs(lights:GetChildren()) do
				if light:IsA("BasePart") then
					light.Position = light.Position - Vector3.new(0, height, 0)  -- Move the lights along with the car
				end
			end
		end

		-- Slam the car body
		for _, part in pairs(body:GetChildren()) do
			if part:IsA("BasePart") then
				part.Position = part.Position - Vector3.new(0, height, 0)
			end
		end
	end

	-- Main execution: Check if the player is in a car and slam the body
	local car = getVehicle()
	if car then
		slamCarBody(car, 0.1)  -- Slam with a height of 0.1
	else
		print("🚗 No car detected!")
	end

end)

UICorner_5.CornerRadius = UDim.new(1, 0)
UICorner_5.Parent = Slam01

Slam05.Name = "Slam0.5"
Slam05.Parent = Main
Slam05.BackgroundColor3 = Color3.fromRGB(29, 29, 29)
Slam05.BorderColor3 = Color3.fromRGB(0, 0, 0)
Slam05.BorderSizePixel = 0
Slam05.Position = UDim2.new(0.142372876, 0, 0.419452876, 0)
Slam05.Size = UDim2.new(0, 126, 0, 32)
Slam05.Font = Enum.Font.Arcade
Slam05.Text = "0.5"
Slam05.TextColor3 = Color3.fromRGB(112, 29, 255)
Slam05.TextScaled = true
Slam05.TextSize = 14.000
Slam05.TextWrapped = true
Slam05.MouseButton1Down:Connect(function()
	local player = game.Players.LocalPlayer
	local character = player.Character or player.CharacterAdded:Wait()
	local humanoid = character:WaitForChild("Humanoid")

	-- Function to get the vehicle the player is sitting in
	local function getVehicle()
		local seatPart = humanoid.SeatPart
		if seatPart and seatPart:IsA("VehicleSeat") then
			if seatPart.Occupant == humanoid then
				return seatPart.Parent  -- Return the car model
			end
		end
		return nil
	end

	-- Function to slam the car body down while keeping the wheels in place
	local function slamCarBody(car, height)
		if not car then return end

		local body = car:FindFirstChild("Body")  -- Adjust based on your model structure
		if not body then return end

		-- Find the Vehicle_Lights part and move each part inside it
		local lights = car:FindFirstChild("Body"):FindFirstChild("Vehicle_Lights")
		if lights then
			for _, light in pairs(lights:GetChildren()) do
				if light:IsA("BasePart") then
					light.Position = light.Position - Vector3.new(0, height, 0)  -- Move the lights along with the car
				end
			end
		end

		-- Slam the car body
		for _, part in pairs(body:GetChildren()) do
			if part:IsA("BasePart") then
				part.Position = part.Position - Vector3.new(0, height, 0)
			end
		end
	end

	-- Main execution: Check if the player is in a car and slam the body
	local car = getVehicle()
	if car then
		slamCarBody(car, 0.5)  -- Slam with a height of 0.1
	else
		print("🚗 No car detected!")
	end

end)

UICorner_6.CornerRadius = UDim.new(1, 0)
UICorner_6.Parent = Slam05

Slam5.Name = "Slam5"
Slam5.Parent = Main
Slam5.BackgroundColor3 = Color3.fromRGB(29, 29, 29)
Slam5.BorderColor3 = Color3.fromRGB(0, 0, 0)
Slam5.BorderSizePixel = 0
Slam5.Position = UDim2.new(0.142372876, 0, 0.668693006, 0)
Slam5.Size = UDim2.new(0, 126, 0, 32)
Slam5.Font = Enum.Font.Arcade
Slam5.Text = "5"
Slam5.TextColor3 = Color3.fromRGB(112, 29, 255)
Slam5.TextScaled = true
Slam5.TextSize = 14.000
Slam5.TextWrapped = true
Slam5.MouseButton1Down:Connect(function()
	local player = game.Players.LocalPlayer
	local character = player.Character or player.CharacterAdded:Wait()
	local humanoid = character:WaitForChild("Humanoid")

	-- Function to get the vehicle the player is sitting in
	local function getVehicle()
		local seatPart = humanoid.SeatPart
		if seatPart and seatPart:IsA("VehicleSeat") then
			if seatPart.Occupant == humanoid then
				return seatPart.Parent  -- Return the car model
			end
		end
		return nil
	end

	-- Function to slam the car body down while keeping the wheels in place
	local function slamCarBody(car, height)
		if not car then return end

		local body = car:FindFirstChild("Body")  -- Adjust based on your model structure
		if not body then return end

		-- Find the Vehicle_Lights part and move each part inside it
		local lights = car:FindFirstChild("Body"):FindFirstChild("Vehicle_Lights")
		if lights then
			for _, light in pairs(lights:GetChildren()) do
				if light:IsA("BasePart") then
					light.Position = light.Position - Vector3.new(0, height, 0)  -- Move the lights along with the car
				end
			end
		end

		-- Slam the car body
		for _, part in pairs(body:GetChildren()) do
			if part:IsA("BasePart") then
				part.Position = part.Position - Vector3.new(0, height, 0)
			end
		end
	end

	-- Main execution: Check if the player is in a car and slam the body
	local car = getVehicle()
	if car then
		slamCarBody(car, 5)  -- Slam with a height of 0.1
	else
		print("🚗 No car detected!")
	end

end)

UICorner_7.CornerRadius = UDim.new(1, 0)
UICorner_7.Parent = Slam5

Slam1.Name = "Slam1"
Slam1.Parent = Main
Slam1.BackgroundColor3 = Color3.fromRGB(29, 29, 29)
Slam1.BorderColor3 = Color3.fromRGB(0, 0, 0)
Slam1.BorderSizePixel = 0
Slam1.Position = UDim2.new(0.142372876, 0, 0.547112465, 0)
Slam1.Size = UDim2.new(0, 126, 0, 32)
Slam1.Font = Enum.Font.Arcade
Slam1.Text = "1"
Slam1.TextColor3 = Color3.fromRGB(112, 29, 255)
Slam1.TextScaled = true
Slam1.TextSize = 14.000
Slam1.TextWrapped = true
Slam1.MouseButton1Down:Connect(function()
	local player = game.Players.LocalPlayer
	local character = player.Character or player.CharacterAdded:Wait()
	local humanoid = character:WaitForChild("Humanoid")

	-- Function to get the vehicle the player is sitting in
	local function getVehicle()
		local seatPart = humanoid.SeatPart
		if seatPart and seatPart:IsA("VehicleSeat") then
			if seatPart.Occupant == humanoid then
				return seatPart.Parent  -- Return the car model
			end
		end
		return nil
	end

	-- Function to slam the car body down while keeping the wheels in place
	local function slamCarBody(car, height)
		if not car then return end

		local body = car:FindFirstChild("Body")  -- Adjust based on your model structure
		if not body then return end

		-- Find the Vehicle_Lights part and move each part inside it
		local lights = car:FindFirstChild("Body"):FindFirstChild("Vehicle_Lights")
		if lights then
			for _, light in pairs(lights:GetChildren()) do
				if light:IsA("BasePart") then
					light.Position = light.Position - Vector3.new(0, height, 0)  -- Move the lights along with the car
				end
			end
		end

		-- Slam the car body
		for _, part in pairs(body:GetChildren()) do
			if part:IsA("BasePart") then
				part.Position = part.Position - Vector3.new(0, height, 0)
			end
		end
	end

	-- Main execution: Check if the player is in a car and slam the body
	local car = getVehicle()
	if car then
		slamCarBody(car, 1)  -- Slam with a height of 0.1
	else
		print("🚗 No car detected!")
	end

end)

UICorner_8.CornerRadius = UDim.new(1, 0)
UICorner_8.Parent = Slam1

Lift1.Name = "Lift1"
Lift1.Parent = Main
Lift1.BackgroundColor3 = Color3.fromRGB(29, 29, 29)
Lift1.BorderColor3 = Color3.fromRGB(0, 0, 0)
Lift1.BorderSizePixel = 0
Lift1.Position = UDim2.new(0.642372906, 0, 0.547112465, 0)
Lift1.Size = UDim2.new(0, 126, 0, 32)
Lift1.Font = Enum.Font.Arcade
Lift1.Text = "1"
Lift1.TextColor3 = Color3.fromRGB(112, 29, 255)
Lift1.TextScaled = true
Lift1.TextSize = 14.000
Lift1.TextWrapped = true
Lift1.MouseButton1Down:Connect(function()
	local player = game.Players.LocalPlayer
	local character = player.Character or player.CharacterAdded:Wait()
	local humanoid = character:WaitForChild("Humanoid")

	-- Function to get the vehicle the player is sitting in
	local function getVehicle()
		local seatPart = humanoid.SeatPart
		if seatPart and seatPart:IsA("VehicleSeat") then
			if seatPart.Occupant == humanoid then
				return seatPart.Parent  -- Return the car model
			end
		end
		return nil
	end

	-- Function to lift only the car body while keeping the wheels in place
	local function liftCarBody(car, height)
		if not car then return end

		local body = car:FindFirstChild("Body")  -- Adjust based on your model structure
		if not body then return end

		-- Find the Vehicle_Lights part and move each part inside it
		local lights = car:FindFirstChild("Body"):FindFirstChild("Vehicle_Lights")
		if lights then
			for _, light in pairs(lights:GetChildren()) do
				if light:IsA("BasePart") then
					light.Position = light.Position + Vector3.new(0, height, 0)  -- Move the lights along with the car
				end
			end
		end

		-- Lift the car body
		for _, part in pairs(body:GetChildren()) do
			if part:IsA("BasePart") then
				part.Position = part.Position + Vector3.new(0, height, 0)
			end
		end
	end

	-- Main execution: Check if the player is in a car and lift the body
	local car = getVehicle()
	if car then
		liftCarBody(car, 1)  -- Lift with a height of 0.1
	else
		print("🚗 No car detected!")
	end

end)

UICorner_9.CornerRadius = UDim.new(1, 0)
UICorner_9.Parent = Lift1

Lift01.Name = "Lift0.1"
Lift01.Parent = Main
Lift01.BackgroundColor3 = Color3.fromRGB(29, 29, 29)
Lift01.BorderColor3 = Color3.fromRGB(0, 0, 0)
Lift01.BorderSizePixel = 0
Lift01.Position = UDim2.new(0.642372906, 0, 0.288753808, 0)
Lift01.Size = UDim2.new(0, 126, 0, 32)
Lift01.Font = Enum.Font.Arcade
Lift01.Text = "0.1"
Lift01.TextColor3 = Color3.fromRGB(112, 29, 255)
Lift01.TextScaled = true
Lift01.TextSize = 14.000
Lift01.TextWrapped = true
Lift01.MouseButton1Down:Connect(function()
	local player = game.Players.LocalPlayer
	local character = player.Character or player.CharacterAdded:Wait()
	local humanoid = character:WaitForChild("Humanoid")

	-- Function to get the vehicle the player is sitting in
	local function getVehicle()
		local seatPart = humanoid.SeatPart
		if seatPart and seatPart:IsA("VehicleSeat") then
			if seatPart.Occupant == humanoid then
				return seatPart.Parent  -- Return the car model
			end
		end
		return nil
	end

	-- Function to lift only the car body while keeping the wheels in place
	local function liftCarBody(car, height)
		if not car then return end

		local body = car:FindFirstChild("Body")  -- Adjust based on your model structure
		if not body then return end

		-- Find the Vehicle_Lights part and move each part inside it
		local lights = car:FindFirstChild("Body"):FindFirstChild("Vehicle_Lights")
		if lights then
			for _, light in pairs(lights:GetChildren()) do
				if light:IsA("BasePart") then
					light.Position = light.Position + Vector3.new(0, height, 0)  -- Move the lights along with the car
				end
			end
		end

		-- Lift the car body
		for _, part in pairs(body:GetChildren()) do
			if part:IsA("BasePart") then
				part.Position = part.Position + Vector3.new(0, height, 0)
			end
		end
	end

	-- Main execution: Check if the player is in a car and lift the body
	local car = getVehicle()
	if car then
		liftCarBody(car, 0.1)  -- Lift with a height of 0.1
	else
		print("🚗 No car detected!")
	end

end)

UICorner_10.CornerRadius = UDim.new(1, 0)
UICorner_10.Parent = Lift01

Lift05.Name = "Lift0.5"
Lift05.Parent = Main
Lift05.BackgroundColor3 = Color3.fromRGB(29, 29, 29)
Lift05.BorderColor3 = Color3.fromRGB(0, 0, 0)
Lift05.BorderSizePixel = 0
Lift05.Position = UDim2.new(0.642372906, 0, 0.419452876, 0)
Lift05.Size = UDim2.new(0, 126, 0, 32)
Lift05.Font = Enum.Font.Arcade
Lift05.Text = "0.5"
Lift05.TextColor3 = Color3.fromRGB(112, 29, 255)
Lift05.TextScaled = true
Lift05.TextSize = 14.000
Lift05.TextWrapped = true
Lift05.MouseButton1Down:Connect(function()
	local player = game.Players.LocalPlayer
	local character = player.Character or player.CharacterAdded:Wait()
	local humanoid = character:WaitForChild("Humanoid")

	-- Function to get the vehicle the player is sitting in
	local function getVehicle()
		local seatPart = humanoid.SeatPart
		if seatPart and seatPart:IsA("VehicleSeat") then
			if seatPart.Occupant == humanoid then
				return seatPart.Parent  -- Return the car model
			end
		end
		return nil
	end

	-- Function to lift only the car body while keeping the wheels in place
	local function liftCarBody(car, height)
		if not car then return end

		local body = car:FindFirstChild("Body")  -- Adjust based on your model structure
		if not body then return end

		-- Find the Vehicle_Lights part and move each part inside it
		local lights = car:FindFirstChild("Body"):FindFirstChild("Vehicle_Lights")
		if lights then
			for _, light in pairs(lights:GetChildren()) do
				if light:IsA("BasePart") then
					light.Position = light.Position + Vector3.new(0, height, 0)  -- Move the lights along with the car
				end
			end
		end

		-- Lift the car body
		for _, part in pairs(body:GetChildren()) do
			if part:IsA("BasePart") then
				part.Position = part.Position + Vector3.new(0, height, 0)
			end
		end
	end

	-- Main execution: Check if the player is in a car and lift the body
	local car = getVehicle()
	if car then
		liftCarBody(car, 0.5)  -- Lift with a height of 0.1
	else
		print("🚗 No car detected!")
	end

end)

UICorner_11.CornerRadius = UDim.new(1, 0)
UICorner_11.Parent = Lift05

Lift5.Name = "Lift5"
Lift5.Parent = Main
Lift5.BackgroundColor3 = Color3.fromRGB(29, 29, 29)
Lift5.BorderColor3 = Color3.fromRGB(0, 0, 0)
Lift5.BorderSizePixel = 0
Lift5.Position = UDim2.new(0.642372906, 0, 0.668693006, 0)
Lift5.Size = UDim2.new(0, 126, 0, 32)
Lift5.Font = Enum.Font.Arcade
Lift5.Text = "5"
Lift5.TextColor3 = Color3.fromRGB(112, 29, 255)
Lift5.TextScaled = true
Lift5.TextSize = 14.000
Lift5.TextWrapped = true
Lift5.MouseButton1Down:Connect(function()
	local player = game.Players.LocalPlayer
	local character = player.Character or player.CharacterAdded:Wait()
	local humanoid = character:WaitForChild("Humanoid")

	-- Function to get the vehicle the player is sitting in
	local function getVehicle()
		local seatPart = humanoid.SeatPart
		if seatPart and seatPart:IsA("VehicleSeat") then
			if seatPart.Occupant == humanoid then
				return seatPart.Parent  -- Return the car model
			end
		end
		return nil
	end

	-- Function to lift only the car body while keeping the wheels in place
	local function liftCarBody(car, height)
		if not car then return end

		local body = car:FindFirstChild("Body")  -- Adjust based on your model structure
		if not body then return end

		-- Find the Vehicle_Lights part and move each part inside it
		local lights = car:FindFirstChild("Body"):FindFirstChild("Vehicle_Lights")
		if lights then
			for _, light in pairs(lights:GetChildren()) do
				if light:IsA("BasePart") then
					light.Position = light.Position + Vector3.new(0, height, 0)  -- Move the lights along with the car
				end
			end
		end

		-- Lift the car body
		for _, part in pairs(body:GetChildren()) do
			if part:IsA("BasePart") then
				part.Position = part.Position + Vector3.new(0, height, 0)
			end
		end
	end

	-- Main execution: Check if the player is in a car and lift the body
	local car = getVehicle()
	if car then
		liftCarBody(car, 5)  -- Lift with a height of 0.1
	else
		print("🚗 No car detected!")
	end

end)

UICorner_12.CornerRadius = UDim.new(1, 0)
UICorner_12.Parent = Lift5

Weight.Name = "Weight"
Weight.Parent = Main
Weight.BackgroundColor3 = Color3.fromRGB(29, 29, 29)
Weight.BorderColor3 = Color3.fromRGB(0, 0, 0)
Weight.BorderSizePixel = 0
Weight.Position = UDim2.new(0.393220335, 0, 0.449848026, 0)
Weight.Size = UDim2.new(0, 126, 0, 32)
Weight.Font = Enum.Font.Unknown
Weight.Text = "Slim Down Weight"
Weight.TextColor3 = Color3.fromRGB(112, 29, 255)
Weight.TextScaled = true
Weight.TextSize = 14.000
Weight.TextWrapped = true
Weight.MouseButton1Down:Connect(function()
	local player = game.Players.LocalPlayer
	local character = player.Character or player.CharacterAdded:Wait()
	local humanoid = character:WaitForChild("Humanoid")

	-- Function to get the vehicle the player is sitting in
	local function getVehicle()
		local seatPart = humanoid.SeatPart
		if seatPart and seatPart:IsA("VehicleSeat") then
			if seatPart.Occupant == humanoid then
				return seatPart.Parent  -- Return the car model
			end
		end
		return nil
	end

	-- Function to resize the #Weight object
	local function resizeVehicleWeight(car)
		if not car then return end

		local body = car:FindFirstChild("Body")  -- Find the body of the car
		if body then
			local weight = body:FindFirstChild("#Weight")  -- Check for the #Weight object
			if weight then
				if weight:IsA("BasePart") then  -- Ensure it's a BasePart
					weight.Size = Vector3.new(0.0010000000474974513, 3, 13.5)  -- Set the new size
					print("🚗 Resized #Weight to: " .. tostring(weight.Size))
				else
					print("🚗 The #Weight is not a BasePart.")
				end
			else
				print("🚗 No #Weight object found in the car!")
			end
		else
			print("🚗 No body part found in the car!")
		end
	end

	-- Main execution: Check if the player is in a car and resize the #Weight part
	local car = getVehicle()
	if car then
		resizeVehicleWeight(car)
	else
		print("🚗 No car detected!")
	end

end)

UICorner_13.CornerRadius = UDim.new(1, 0)
UICorner_13.Parent = Weight

LowRide.Name = "LowRide"
LowRide.Parent = Main
LowRide.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
LowRide.BorderColor3 = Color3.fromRGB(147, 23, 255)
LowRide.BorderSizePixel = 0
LowRide.Position = UDim2.new(0.0813559294, 0, 0.81155014, 0)
LowRide.Size = UDim2.new(0, 199, 0, 49)
LowRide.Font = Enum.Font.Unknown
LowRide.Text = "Low Rider Mode"
LowRide.TextColor3 = Color3.fromRGB(112, 29, 255)
LowRide.TextScaled = true
LowRide.TextSize = 14.000
LowRide.TextWrapped = true
LowRide.MouseButton1Down:Connect(function()
	local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- Function to get the vehicle the player is sitting in
local function getVehicle()
    local seatPart = humanoid.SeatPart
    if seatPart and seatPart:IsA("VehicleSeat") then
        if seatPart.Occupant == humanoid then
            return seatPart.Parent  -- Return the car model
        end
    end
    return nil
end

-- Function to simulate extreme lowrider-style lift (front lifted dramatically, back slammed)
local function extremeLowriderLift(car)
    if not car then return end

    local wheels = car:FindFirstChild("Wheels")
    if not wheels then return end

    -- Extreme suspension settings for all wheels
    local wheelSettings = {
        FL = wheels.FL,
        FR = wheels.FR,
        RL = wheels.RL,
        RR = wheels.RR
    }

    -- Apply extreme lift for the front and dramatic slam for the rear
    for wheel, parts in pairs(wheelSettings) do
        -- Manipulate suspension properties for each wheel
        local spring = parts:FindFirstChild("Spring")
        local hinge = parts:FindFirstChild("SuspensionHinge")

        if spring then
            -- Adjust Spring Force, damping, MaxLength for extreme lift and slam
            if wheel == "FL" or wheel == "FR" then
                spring.FreeLength = 10  -- Extremely high front lift
                spring.Stiffness = 500  -- Very soft stiffness for extreme front lift
                spring.Damping = 3000  -- Extremely high damping to control bouncing
                spring.MaxForce = 500000  -- Maximum force for an exaggerated front lift
                spring.MaxLength = 15  -- MaxLength set very high to allow extreme lift
            elseif wheel == "RL" or wheel == "RR" then
                spring.FreeLength = -8  -- Massive rear drop
                spring.Stiffness = 300  -- Soft stiffness for an exaggerated rear slam
                spring.Damping = 1500  -- Moderate damping for rear drop
                spring.MaxForce = 350000  -- High force for extreme rear drop
                spring.MaxLength = 10  -- MaxLength set high for more drop
            end
        end

        if hinge then
            -- Increase hinge angles for larger range of suspension motion
            if wheel == "FL" or wheel == "FR" then
                hinge.LowerAngle = -40  -- Larger angle for front suspension lift
                hinge.UpperAngle = 40
            elseif wheel == "RL" or wheel == "RR" then
                hinge.LowerAngle = -20  -- More drop for rear suspension
                hinge.UpperAngle = 20
            end
        end
    end

    -- Apply extreme lift/drop to the car's body
    local body = car:FindFirstChild("Body")  -- Adjust if your body parts are named differently
    if body then
        for _, part in pairs(body:GetChildren()) do
            if part:IsA("BasePart") then
                -- Extreme lift for front body parts
                if part.Name == "Front" then
                    part.CFrame = part.CFrame + Vector3.new(0, 20, 0)  -- Maximum front lift
                -- Extreme drop for rear body parts
                elseif part.Name == "Rear" then
                    part.CFrame = part.CFrame + Vector3.new(0, -15, 0)  -- Maximum rear drop
                end
            end
        end
    end
end

-- Function to smooth out suspension after hitting obstacles
local function smoothSuspension(car)
    local wheels = car:FindFirstChild("Wheels")
    if not wheels then return end

    for _, wheel in pairs(wheels:GetChildren()) do
        local spring = wheel:FindFirstChild("Spring")
        if spring then
            -- Smooth adjustment to restore suspension
            spring.FreeLength = math.clamp(spring.FreeLength, -5, 5)  -- Keep it within a reasonable range
            spring.Stiffness = 1000  -- Moderate stiffness for natural movement
            spring.Damping = 1500  -- Lower damping to prevent bounce
            spring.MaxForce = 200000  -- Prevent too much force being applied
            spring.MaxLength = 5  -- Keep the length at a manageable value
        end
    end
end

-- Main execution: Check if the player is in a car and apply the extreme lift/drop effect
local car = getVehicle()
if car then
    extremeLowriderLift(car)

    -- Monitor for car movement and adjust suspension if needed
    local isStuck = false
    while true do
        -- Check if the car is moving slowly or has become stuck
        local velocity = car.PrimaryPart and car.PrimaryPart.AssemblyLinearVelocity
        if velocity and velocity.Magnitude < 0.1 then
            if not isStuck then
                isStuck = true
                smoothSuspension(car)  -- Smooth the suspension out
            end
        else
            isStuck = false
        end

        wait(0.1)  -- Regular check interval to prevent performance hits
    end
else
    print("🚗 No car detected!")
end

end)

UICorner_14.CornerRadius = UDim.new(1, 0)
UICorner_14.Parent = LowRide

LowRideBounce.Name = "LowRideBounce"
LowRideBounce.Parent = Main
LowRideBounce.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
LowRideBounce.BorderColor3 = Color3.fromRGB(147, 23, 255)
LowRideBounce.BorderSizePixel = 0
LowRideBounce.Position = UDim2.new(0.579661012, 0, 0.81155014, 0)
LowRideBounce.Size = UDim2.new(0, 199, 0, 49)
LowRideBounce.Font = Enum.Font.Unknown
LowRideBounce.Text = "Low Rider Bounce"
LowRideBounce.TextColor3 = Color3.fromRGB(112, 29, 255)
LowRideBounce.TextScaled = true
LowRideBounce.TextSize = 14.000
LowRideBounce.TextWrapped = true
LowRideBounce.MouseButton1Down:Connect(function()
	local player = game.Players.LocalPlayer
	local character = player.Character or player.CharacterAdded:Wait()
	local humanoid = character:WaitForChild("Humanoid")

	-- Function to get the vehicle the player is sitting in
	local function getVehicle()
		local seatPart = humanoid.SeatPart
		if seatPart and seatPart:IsA("VehicleSeat") then
			if seatPart.Occupant == humanoid then
				return seatPart.Parent  -- Return the car model
			end
		end
		return nil
	end

	-- Function to simulate bouncing for the front wheels (lowrider style)
	local function lowriderBounce(car)
		if not car then return end

		local wheels = car:FindFirstChild("Wheels")
		if not wheels then return end

		-- Get front wheel settings
		local frontWheels = {
			FL = wheels.FL,
			FR = wheels.FR
		}

		-- Apply bouncing to front wheels
		for wheel, parts in pairs(frontWheels) do
			local spring = parts:FindFirstChild("Spring")

			if spring then
				-- Make the front wheels bounce
				local bounceStrength = 10  -- Adjust this value for bounce intensity
				local bounceSpeed = 5  -- Adjust how fast the bounce happens
				local maxHeight = 5  -- Adjust the maximum bounce height

				-- Adjusting the spring properties to simulate bouncing
				while true do
					spring.FreeLength = 10 + math.sin(tick() * bounceSpeed) * bounceStrength  -- Create a sine wave effect for bounce
					spring.MaxLength = maxHeight  -- Set the maximum length of the bounce
					spring.Damping = 300  -- Control bounce decay

					wait(0.05)  -- Small delay to update every frame
				end
			end
		end
	end

	-- Main execution: Check if the player is in a car and apply the lowrider bounce effect
	local car = getVehicle()
	if car then
		lowriderBounce(car)
	else
		print("🚗 No car detected!")
	end
end)

UICorner_15.CornerRadius = UDim.new(1, 0)
UICorner_15.Parent = LowRideBounce

CloseButton.Name = "CloseButton"
CloseButton.Parent = Main
CloseButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
CloseButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
CloseButton.BorderSizePixel = 0
CloseButton.Position = UDim2.new(0.957627118, 0, 0, 0)
CloseButton.Size = UDim2.new(0, 25, 0, 28)
CloseButton.Font = Enum.Font.SourceSansBold
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(112, 29, 255)
CloseButton.TextScaled = true
CloseButton.TextSize = 14.000
CloseButton.TextWrapped = true
CloseButton.MouseButton1Click:Connect(function()
	Main:Destroy()
end)


UICorner_16.Parent = CloseButton
