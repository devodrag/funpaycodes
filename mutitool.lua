local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
	Name = "Multitool",
	LoadingTitle = "Multitool",
	LoadingSubtitle = "by User",
	ConfigurationSaving = {Enabled = true, FolderName = "Multitool", FileName = "Config"},
	KeySystem = false
})

local Player = game.Players.LocalPlayer
local Mouse = Player:GetMouse()
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")

local fly = false
local flySpeed = 50
local bv, bg
local ws = 16
local jp = 50
local ac = false
local acDelay = 0.01
local acConn
local antiAFK = false
local afkConn

local Tab1 = Window:CreateTab("Движение")
local Tab2 = Window:CreateTab("Утилиты")

local function startFly()
	if not Player.Character or not Player.Character:FindFirstChild("HumanoidRootPart") then return end
	local hrp = Player.Character.HumanoidRootPart
	bv = Instance.new("BodyVelocity", hrp)
	bv.Velocity = Vector3.new(0,0,0)
	bv.MaxForce = Vector3.new(9e9,9e9,9e9)
	bg = Instance.new("BodyGyro", hrp)
	bg.P = 9e4
	bg.MaxTorque = Vector3.new(9e9,9e9,9e9)
	bg.CFrame = hrp.CFrame
	spawn(function()
		while fly and Player.Character and hrp.Parent do
			if UIS:IsKeyDown(Enum.KeyCode.W) then bv.Velocity = Camera.CFrame.LookVector * flySpeed end
			if UIS:IsKeyDown(Enum.KeyCode.S) then bv.Velocity = -Camera.CFrame.LookVector * flySpeed end
			if UIS:IsKeyDown(Enum.KeyCode.A) then bv.Velocity = -Camera.CFrame.RightVector * flySpeed end
			if UIS:IsKeyDown(Enum.KeyCode.D) then bv.Velocity = Camera.CFrame.RightVector * flySpeed end
			if UIS:IsKeyDown(Enum.KeyCode.Space) then bv.Velocity = Vector3.new(0, flySpeed, 0) end
			if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then bv.Velocity = Vector3.new(0, -flySpeed, 0) end
			if not (UIS:IsKeyDown(Enum.KeyCode.W) or UIS:IsKeyDown(Enum.KeyCode.S) or UIS:IsKeyDown(Enum.KeyCode.A) or UIS:IsKeyDown(Enum.KeyCode.D) or UIS:IsKeyDown(Enum.KeyCode.Space) or UIS:IsKeyDown(Enum.KeyCode.LeftControl)) then
				bv.Velocity = Vector3.new(0,0,0)
			end
			bg.CFrame = Camera.CFrame
			RunService.Heartbeat:Wait()
		end
	end)
end

local function stopFly()
	fly = false
	if bv then bv:Destroy() bv = nil end
	if bg then bg:Destroy() bg = nil end
end

Tab1:CreateToggle({
	Name = "Fly",
	CurrentValue = false,
	Callback = function(v)
		fly = v
		if v then startFly() else stopFly() end
	end
})

Tab1:CreateSlider({
	Name = "Fly Speed",
	Range = {1, 200},
	Increment = 1,
	CurrentValue = 50,
	Callback = function(v) flySpeed = v end
})

Tab1:CreateSlider({
	Name = "WalkSpeed",
	Range = {16, 300},
	Increment = 1,
	CurrentValue = 16,
	Callback = function(v)
		ws = v
		if Player.Character and Player.Character:FindFirstChild("Humanoid") then
			Player.Character.Humanoid.WalkSpeed = v
		end
	end
})

Tab1:CreateSlider({
	Name = "JumpPower",
	Range = {50, 300},
	Increment = 1,
	CurrentValue = 50,
	Callback = function(v)
		jp = v
		if Player.Character and Player.Character:FindFirstChild("Humanoid") then
			Player.Character.Humanoid.JumpPower = v
		end
	end
})

Player.CharacterAdded:Connect(function(char)
	char:WaitForChild("Humanoid").WalkSpeed = ws
	char:WaitForChild("Humanoid").JumpPower = jp
end)

Tab2:CreateToggle({
	Name = "Autoclicker",
	CurrentValue = false,
	Callback = function(v)
		ac = v
		if v then
			acConn = RunService.Heartbeat:Connect(function()
				if ac and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) and not UIS:GetFocusedTextBox() then
					VirtualUser:ClickButton1(Mouse.Hit.p)
					task.wait(acDelay)
				end
			end)
		else
			if acConn then acConn:Disconnect() acConn = nil end
		end
	end
})

Tab2:CreateSlider({
	Name = "Click Delay (sec)",
	Range = {0.001, 0.1},
	Increment = 0.001,
	CurrentValue = 0.01,
	Callback = function(v) acDelay = v end
})

Tab2:CreateToggle({
	Name = "Anti-AFK",
	CurrentValue = false,
	Callback = function(v)
		antiAFK = v
		if v then
			afkConn = RunService.Heartbeat:Connect(function()
				if antiAFK then
					VirtualUser:CaptureController()
					VirtualUser:ClickButton2(Vector2.new())
				end
			end)
		else
			if afkConn then afkConn:Disconnect() afkConn = nil end
		end
	end
})
