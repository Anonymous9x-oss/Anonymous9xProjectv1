-- ==================== SPEED MODE UPDATED (MAX 500) ====================
-- Smaller UI, Max Speed 500

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- ==================== UPDATED CONFIGURATION ====================
local SpeedConfig = {
    Enabled = true,
    CurrentSpeed = 50,      -- Default speed
    MinSpeed = 16,          -- Minimum (normal walk)
    MaxSpeed = 500,         -- ⬆️ DINAIIKAN KE 500 ⬆️
    DefaultSpeed = 50,      -- Reset speed
    
    -- Step increments
    SmallStep = 5,          -- Normal click
    BigStep = 50,           -- ⬆️ Shift click (dinaikkan dari 25)
    
    -- Visual feedback
    SpeedBoostColor = Color3.fromRGB(0, 200, 255),  -- Cyan
    NormalColor = Color3.fromRGB(150, 150, 150),    -- Gray
    DangerColor = Color3.fromRGB(255, 100, 100),    -- Red for high speed
}

-- ==================== SPEED SYSTEM ====================
local originalWalkSpeed = 16
local humanoid = nil
local speedConnection = nil

-- Apply speed function
local function ApplySpeed()
    if not SpeedConfig.Enabled or not humanoid then
        return
    end
    
    -- Apply speed
    humanoid.WalkSpeed = SpeedConfig.CurrentSpeed
    
    -- High speed effects (above 100)
    if SpeedConfig.CurrentSpeed > 100 then
        -- Remove old effects
        if humanoid:FindFirstChild("SpeedBoostVelocity") then
            humanoid.SpeedBoostVelocity:Destroy()
        end
        
        -- Add velocity for stability at high speeds
        local velocity = Instance.new("BodyVelocity")
        velocity.Name = "SpeedBoostVelocity"
        velocity.MaxForce = Vector3.new(10000, 0, 10000)  -- ⬆️ Increased force
        velocity.Velocity = Vector3.new(0, 0, 0)
        velocity.Parent = humanoid
    elseif humanoid:FindFirstChild("SpeedBoostVelocity") then
        humanoid.SpeedBoostVelocity:Destroy()
    end
end

-- Update humanoid reference
local function UpdateHumanoid()
    if LocalPlayer.Character then
        humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            originalWalkSpeed = humanoid.WalkSpeed
            ApplySpeed()
        end
    end
end

-- Initial setup
UpdateHumanoid()

-- Character change listener
LocalPlayer.CharacterAdded:Connect(function(character)
    task.wait(0.5)
    UpdateHumanoid()
end)

-- ==================== SMALLER UI ====================
-- Clean old UI
if PlayerGui:FindFirstChild("SpeedModeUI") then
    PlayerGui.SpeedModeUI:Destroy()
end

-- Create ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SpeedModeUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Main Container (LEBIH KECIL)
local MainContainer = Instance.new("Frame")
MainContainer.Name = "MainContainer"
MainContainer.Size = UDim2.new(0, 160, 0, 80)  -- ⬇️ DIKECILKAN (160x80)
MainContainer.Position = UDim2.new(0, 10, 0, 70)
MainContainer.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MainContainer.BackgroundTransparency = 0.2

local ContainerCorner = Instance.new("UICorner")
ContainerCorner.CornerRadius = UDim.new(0, 6)  -- ⬇️ Corner lebih kecil
ContainerCorner.Parent = MainContainer

-- Title (LEBIH KECIL)
local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, -30, 0, 18)  -- ⬇️ Lebih pendek
Title.Position = UDim2.new(0, 8, 0, 3)
Title.BackgroundTransparency = 1
Title.Text = "SPEED"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 11  -- ⬇️ Font lebih kecil
Title.TextXAlignment = Enum.TextXAlignment.Left

-- Speed Display (LEBIH KECIL)
local SpeedDisplay = Instance.new("TextLabel")
SpeedDisplay.Name = "SpeedDisplay"
SpeedDisplay.Size = UDim2.new(0, 60, 0, 22)  -- ⬇️ Lebih kecil
SpeedDisplay.Position = UDim2.new(0.5, -30, 0, 25)
SpeedDisplay.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
SpeedDisplay.Text = tostring(SpeedConfig.CurrentSpeed)
SpeedDisplay.TextColor3 = SpeedConfig.SpeedBoostColor
SpeedDisplay.Font = Enum.Font.GothamBold
SpeedDisplay.TextSize = 14  -- ⬇️ Font display lebih kecil

local DisplayCorner = Instance.new("UICorner")
DisplayCorner.CornerRadius = UDim.new(0, 4)
DisplayCorner.Parent = SpeedDisplay

-- Decrease Button (-) (LEBIH KECIL)
local DecreaseButton = Instance.new("TextButton")
DecreaseButton.Name = "DecreaseButton"
DecreaseButton.Size = UDim2.new(0, 25, 0, 22)  -- ⬇️ Lebih kecil
DecreaseButton.Position = UDim2.new(0, 10, 0, 25)
DecreaseButton.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
DecreaseButton.BorderSizePixel = 0
DecreaseButton.Text = "-"
DecreaseButton.TextColor3 = Color3.new(1, 1, 1)
DecreaseButton.Font = Enum.Font.GothamBold
DecreaseButton.TextSize = 16  -- ⬇️ Font lebih kecil

local DecreaseCorner = Instance.new("UICorner")
DecreaseCorner.CornerRadius = UDim.new(0, 4)
DecreaseCorner.Parent = DecreaseButton

-- Increase Button (+) (LEBIH KECIL)
local IncreaseButton = Instance.new("TextButton")
IncreaseButton.Name = "IncreaseButton"
IncreaseButton.Size = UDim2.new(0, 25, 0, 22)  -- ⬇️ Lebih kecil
IncreaseButton.Position = UDim2.new(1, -35, 0, 25)
IncreaseButton.BackgroundColor3 = Color3.fromRGB(80, 200, 80)
IncreaseButton.BorderSizePixel = 0
IncreaseButton.Text = "+"
IncreaseButton.TextColor3 = Color3.new(1, 1, 1)
IncreaseButton.Font = Enum.Font.GothamBold
IncreaseButton.TextSize = 16  -- ⬇️ Font lebih kecil

local IncreaseCorner = Instance.new("UICorner")
IncreaseCorner.CornerRadius = UDim.new(0, 4)
IncreaseCorner.Parent = IncreaseButton

-- Toggle Button (LEBIH KECIL)
local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "ToggleButton"
ToggleButton.Size = UDim2.new(0, 55, 0, 22)  -- ⬇️ Lebih kecil
ToggleButton.Position = UDim2.new(0, 10, 0, 52)
ToggleButton.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
ToggleButton.BorderSizePixel = 0
ToggleButton.Text = "ON"
ToggleButton.TextColor3 = SpeedConfig.SpeedBoostColor
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.TextSize = 10  -- ⬇️ Font lebih kecil

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 4)
ToggleCorner.Parent = ToggleButton

-- Close Button (X) (LEBIH KECIL)
local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 22, 0, 22)  -- ⬇️ Lebih kecil
CloseButton.Position = UDim2.new(1, -32, 0, 52)
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 59, 48)
CloseButton.BorderSizePixel = 0
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.new(1, 1, 1)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 11  -- ⬇️ Font lebih kecil

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 4)
CloseCorner.Parent = CloseButton

-- Status Label (LEBIH KECIL)
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Name = "StatusLabel"
StatusLabel.Size = UDim2.new(1, -10, 0, 12)  -- ⬇️ Lebih kecil
StatusLabel.Position = UDim2.new(0, 5, 1, -15)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Shift: +/-50"
StatusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextSize = 8  -- ⬇️ Font sangat kecil
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left

-- ==================== DRAG SYSTEM ====================
local dragging = false
local dragStart, startPos

MainContainer.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainContainer.Position
        MainContainer.BackgroundTransparency = 0.1
    end
end)

MainContainer.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        MainContainer.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

MainContainer.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
        MainContainer.BackgroundTransparency = 0.2
    end
end)

-- ==================== UI FUNCTIONS ====================
local function UpdateUI()
    -- Update speed display
    SpeedDisplay.Text = tostring(SpeedConfig.CurrentSpeed)
    
    -- Color coding based on speed
    if SpeedConfig.CurrentSpeed > 300 then
        SpeedDisplay.TextColor3 = SpeedConfig.DangerColor
        SpeedDisplay.BackgroundColor3 = Color3.fromRGB(40, 20, 20)
    elseif SpeedConfig.CurrentSpeed > 100 then
        SpeedDisplay.TextColor3 = Color3.fromRGB(255, 200, 0)  -- Yellow
        SpeedDisplay.BackgroundColor3 = Color3.fromRGB(40, 35, 20)
    else
        SpeedDisplay.TextColor3 = SpeedConfig.SpeedBoostColor
        SpeedDisplay.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    end
    
    -- Update toggle button
    if SpeedConfig.Enabled then
        ToggleButton.Text = "ON"
        ToggleButton.TextColor3 = SpeedConfig.SpeedBoostColor
        ToggleButton.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    else
        ToggleButton.Text = "OFF"
        ToggleButton.TextColor3 = SpeedConfig.NormalColor
        ToggleButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    end
    
    -- Apply speed
    ApplySpeed()
end

-- Increase speed
local function IncreaseSpeed(bigStep)
    local step = bigStep and SpeedConfig.BigStep or SpeedConfig.SmallStep
    SpeedConfig.CurrentSpeed = math.min(SpeedConfig.CurrentSpeed + step, SpeedConfig.MaxSpeed)
    UpdateUI()
    print("[SPEED] Increased to: " .. SpeedConfig.CurrentSpeed)
end

-- Decrease speed
local function DecreaseSpeed(bigStep)
    local step = bigStep and SpeedConfig.BigStep or SpeedConfig.SmallStep
    SpeedConfig.CurrentSpeed = math.max(SpeedConfig.CurrentSpeed - step, SpeedConfig.MinSpeed)
    UpdateUI()
    print("[SPEED] Decreased to: " .. SpeedConfig.CurrentSpeed)
end

-- Toggle speed
local function ToggleSpeed()
    SpeedConfig.Enabled = not SpeedConfig.Enabled
    
    if SpeedConfig.Enabled then
        ApplySpeed()
        print("[SPEED] Enabled: " .. SpeedConfig.CurrentSpeed)
    else
        if humanoid then
            humanoid.WalkSpeed = originalWalkSpeed
            if humanoid:FindFirstChild("SpeedBoostVelocity") then
                humanoid.SpeedBoostVelocity:Destroy()
            end
        end
        print("[SPEED] Disabled")
    end
    
    UpdateUI()
end

-- Reset to default
local function ResetSpeed()
    SpeedConfig.CurrentSpeed = SpeedConfig.DefaultSpeed
    UpdateUI()
    print("[SPEED] Reset to default: " .. SpeedConfig.DefaultSpeed)
end

-- Close UI
local function CloseUI()
    -- Reset speed
    if humanoid then
        humanoid.WalkSpeed = originalWalkSpeed
        if humanoid:FindFirstChild("SpeedBoostVelocity") then
            humanoid.SpeedBoostVelocity:Destroy()
        end
    end
    
    -- Stop connection
    if speedConnection then
        speedConnection:Disconnect()
    end
    
    -- Destroy UI
    ScreenGui:Destroy()
    
    print("[SPEED] UI Closed - Speed reset to normal")
end

-- ==================== BUTTON CONNECTIONS ====================
-- Increase Button
IncreaseButton.MouseButton1Click:Connect(function()
    local isShiftPressed = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or 
                          UserInputService:IsKeyDown(Enum.KeyCode.RightShift)
    IncreaseSpeed(isShiftPressed)
end)

-- Decrease Button
DecreaseButton.MouseButton1Click:Connect(function()
    local isShiftPressed = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or 
                          UserInputService:IsKeyDown(Enum.KeyCode.RightShift)
    DecreaseSpeed(isShiftPressed)
end)

-- Toggle Button
ToggleButton.MouseButton1Click:Connect(ToggleSpeed)

-- Close Button
CloseButton.MouseButton1Click:Connect(CloseUI)

-- ==================== KEYBIND CONTROLS ====================
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    -- Toggle Speed (T)
    if input.KeyCode == Enum.KeyCode.T then
        ToggleSpeed()
    
    -- Increase Speed (+/=)
    elseif input.KeyCode == Enum.KeyCode.Equals or input.KeyCode == Enum.KeyCode.Plus then
        local isShiftPressed = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or 
                              UserInputService:IsKeyDown(Enum.KeyCode.RightShift)
        IncreaseSpeed(isShiftPressed)
    
    -- Decrease Speed (-)
    elseif input.KeyCode == Enum.KeyCode.Minus then
        local isShiftPressed = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or 
                              UserInputService:IsKeyDown(Enum.KeyCode.RightShift)
        DecreaseSpeed(isShiftPressed)
    
    -- Reset Speed (R)
    elseif input.KeyCode == Enum.KeyCode.R then
        ResetSpeed()
    
    -- Max Speed (M)
    elseif input.KeyCode == Enum.KeyCode.M then
        SpeedConfig.CurrentSpeed = SpeedConfig.MaxSpeed
        UpdateUI()
        print("[SPEED] MAX SPEED: 500!")
    end
end)

-- ==================== ASSEMBLE UI ====================
Title.Parent = MainContainer
SpeedDisplay.Parent = MainContainer
DecreaseButton.Parent = MainContainer
IncreaseButton.Parent = MainContainer
ToggleButton.Parent = MainContainer
CloseButton.Parent = MainContainer
StatusLabel.Parent = MainContainer
MainContainer.Parent = ScreenGui
ScreenGui.Parent = PlayerGui

-- Initial UI update
UpdateUI()

-- ==================== AUTO UPDATE HUMANOID ====================
speedConnection = RunService.Heartbeat:Connect(function()
    if not humanoid or not humanoid.Parent then
        UpdateHumanoid()
    end
    
    -- Keep applying speed
    if SpeedConfig.Enabled and humanoid then
        ApplySpeed()
    end
end)

-- ==================== STARTUP MESSAGE ====================
print("========================================")
print("⚡ SPEED MODE UPDATED")
print("CHANGES:")
print("  ✅ Max Speed: 500 (was 200)")
print("  ✅ UI Size: Smaller (160x80)")
print("  ✅ Big Step: 50 (was 25)")
print("CONTROLS:")
print("  [+] Button: +5 speed")
print("  [-] Button: -5 speed")
print("  [ON/OFF]: Toggle speed")
print("  [X]: Close & reset")
print("KEYBINDS:")
print("  T = Toggle ON/OFF")
print("  +/= = Increase speed")
print("  - = Decrease speed")
print("  R = Reset to 50")
print("  M = MAX SPEED (500)")
print("  Shift + Click = +/-50")
print("COLOR CODING:")
print("  <100 = Cyan")
print("  100-300 = Yellow")
print("  >300 = Red (DANGER)")
print("========================================")
