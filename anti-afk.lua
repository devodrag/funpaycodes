local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local AntiAFKEnabled = false
local MenuVisible = true
local AFKInterval = 0.1
local LastAFKAction = tick()
local Player = Players.LocalPlayer
local Connection
local ScreenGui = nil

local success, errorMsg = pcall(function()
    print("Attempting to create GUI...")
    ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "AntiAFKGUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.IgnoreGuiInset = true
    local playerGui = Player:WaitForChild("PlayerGui", 10)
    if not playerGui then
        error("PlayerGui not found after 10 seconds")
    end
    ScreenGui.Parent = playerGui

    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0, 200, 0, 200)
    Frame.Position = UDim2.new(0.5, -100, 0.5, -100)
    Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Frame.BorderSizePixel = 0
    Frame.BackgroundTransparency = 0.2
    Frame.Parent = ScreenGui

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 30)
    Title.Position = UDim2.new(0, 0, 0, 10)
    Title.Text = "Anti-AFK"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.BackgroundTransparency = 1
    Title.TextScaled = true
    Title.Font = Enum.Font.SourceSansBold
    Title.Parent = Frame

    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Size = UDim2.new(0.9, 0, 0, 30)
    ToggleButton.Position = UDim2.new(0.05, 0, 0.25, 0)
    ToggleButton.Text = "Anti-AFK: OFF"
    ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    ToggleButton.TextScaled = true
    ToggleButton.Font = Enum.Font.SourceSans
    ToggleButton.Parent = Frame

    local IntervalInput = Instance.new("TextBox")
    IntervalInput.Size = UDim2.new(0.9, 0, 0, 30)
    IntervalInput.Position = UDim2.new(0.05, 0, 0.45, 0)
    IntervalInput.Text = tostring(AFKInterval)
    IntervalInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    IntervalInput.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    IntervalInput.TextScaled = true
    IntervalInput.Font = Enum.Font.SourceSans
    IntervalInput.Parent = Frame

    local UnloadButton = Instance.new("TextButton")
    UnloadButton.Size = UDim2.new(0.9, 0, 0, 30)
    UnloadButton.Position = UDim2.new(0.05, 0, 0.65, 0)
    UnloadButton.Text = "Unload"
    UnloadButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    UnloadButton.BackgroundColor3 = Color3.fromRGB(100, 50, 50)
    UnloadButton.TextScaled = true
    UnloadButton.Font = Enum.Font.SourceSans
    UnloadButton.Parent = Frame

    ToggleButton.MouseButton1Click:Connect(function()
        AntiAFKEnabled = not AntiAFKEnabled
        ToggleButton.Text = AntiAFKEnabled and "Anti-AFK: ON" or "Anti-AFK: OFF"
        ToggleButton.BackgroundColor3 = AntiAFKEnabled and Color3.fromRGB(0, 100, 0) or Color3.fromRGB(50, 50, 50)
        print("Anti-AFK Toggled: " .. tostring(AntiAFKEnabled))
    end)

    IntervalInput.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            local newInterval = tonumber(IntervalInput.Text)
            if newInterval and newInterval >= 0.1 then
                AFKInterval = newInterval
                print("Interval set to: " .. AFKInterval)
            else
                IntervalInput.Text = tostring(AFKInterval)
                print("Invalid interval, reset to: " .. AFKInterval)
            end
        end
    end)

    -- Unload Script
    UnloadButton.MouseButton1Click:Connect(function()
        AntiAFKEnabled = false
        if Connection then
            Connection:Disconnect()
        end
        if ScreenGui then
            ScreenGui:Destroy()
        end
        print("Anti-AFK Script Unloaded")
    end)

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if input.KeyCode == Enum.KeyCode.RightControl and not gameProcessed then
            MenuVisible = not MenuVisible
            Frame.Visible = MenuVisible
            print("Menu Visible: " .. tostring(MenuVisible))
        end
    end)

    print("GUI Setup Completed")
end)

if not success then
    warn("Failed to create GUI: " .. tostring(errorMsg))
    print("Falling back to console-based Anti-AFK. Press Right Alt to toggle.")
    -- Fallback console toggle
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if input.KeyCode == Enum.KeyCode.RightAlt and not gameProcessed then
            AntiAFKEnabled = not AntiAFKEnabled
            print("Anti-AFK Toggled (Console): " .. tostring(AntiAFKEnabled))
        end
    end)
else
    print("GUI Created Successfully")
end

local function PerformAFKAction()
    if AntiAFKEnabled and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
        pcall(function()
            local rootPart = Player.Character.HumanoidRootPart
            local originalCFrame = rootPart.CFrame
            rootPart.CFrame = originalCFrame * CFrame.new(0.1, 0, 0)
            wait(0.01)
            rootPart.CFrame = originalCFrame
            print("AFK Action Performed: CFrame Moved")
        end)
    else
        print("AFK Action Skipped: No character or root part")
    end
end

-- Main Loop
Connection = RunService.Heartbeat:Connect(function()
    if AntiAFKEnabled and tick() - LastAFKAction >= AFKInterval then
        PerformAFKAction()
        LastAFKAction = tick()
    end
end)

print("Anti-AFK Script Loaded! Press Right Ctrl to toggle menu (if GUI works) or Right Alt for console toggle.")