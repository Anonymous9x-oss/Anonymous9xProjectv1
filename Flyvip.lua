-- ================================================
-- ANONYMOUS9X VIP FLY - CAMERA DIRECTION FLIGHT
-- ================================================

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

-- Fly System
local FLY = {
    Active = false,
    Speed = 2,
    Velocity = nil,
    Gyro = nil,
    Loop = nil,
    Noclip = nil
}

-- Input
local Keys = {W=false, A=false, S=false, D=false, E=false, Q=false}
local Joystick = {Active=false, X=0, Y=0}

-- Functions
local function StartFly()
    if FLY.Active then return end
    FLY.Active = true
    
    FLY.Velocity = Instance.new("BodyVelocity")
    FLY.Velocity.MaxForce = Vector3.new(100000, 100000, 100000)
    FLY.Velocity.Velocity = Vector3.new(0,0,0)
    FLY.Velocity.Parent = RootPart
    
    FLY.Gyro = Instance.new("BodyGyro")
    FLY.Gyro.MaxTorque = Vector3.new(100000, 100000, 100000)
    FLY.Gyro.CFrame = RootPart.CFrame
    FLY.Gyro.Parent = RootPart
    
    Humanoid.PlatformStand = true
    
    -- Noclip
    FLY.Noclip = RS.Stepped:Connect(function()
        if not FLY.Active then return end
        for _, p in pairs(Character:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
    end)
    
    -- FLIGHT LOOP BARU: Mengikuti arah kamera sepenuhnya
    FLY.Loop = RS.Heartbeat:Connect(function()
        if not FLY.Active then return end
        
        local cam = workspace.CurrentCamera
        if not cam then return end
        
        -- Get camera direction (normalized)
        local cameraCF = cam.CFrame
        local lookVector = cameraCF.LookVector
        local rightVector = cameraCF.RightVector
        local upVector = cameraCF.UpVector
        
        -- Input movement dari keyboard
        local moveForward = 0
        local moveRight = 0
        
        if Keys.W then moveForward = moveForward + 1 end
        if Keys.S then moveForward = moveForward - 1 end
        if Keys.A then moveRight = moveRight - 1 end
        if Keys.D then moveRight = moveRight + 1 end
        
        -- Input movement dari joystick (jika ada)
        if Joystick.Active then
            moveForward = moveForward - Joystick.Y  -- Y negatif = maju
            moveRight = moveRight + Joystick.X      -- X positif = kanan
        end
        
        -- Normalize movement vector jika ada input
        local moveInput = Vector3.new(moveRight, 0, moveForward)
        if moveInput.Magnitude > 0 then
            moveInput = moveInput.Unit
        end
        
        -- HITUNGAN VIP: Gerakan mengikuti arah kamera
        local movement = Vector3.new(0, 0, 0)
        
        -- Gerakan maju/mundur: mengikuti arah pandang kamera
        if moveInput.Z ~= 0 then
            movement = movement + (lookVector * moveInput.Z)
        end
        
        -- Gerakan kiri/kanan: mengikuti arah samping kamera
        if moveInput.X ~= 0 then
            movement = movement + (rightVector * moveInput.X)
        end
        
        -- **FITUR VIP: Naik/turun OTOMATIS berdasarkan sudut kamera**
        -- Tidak perlu tombol E/Q lagi! Kamera yang menentukan naik/turun
        if moveInput.Z > 0 then  -- Hanya jika maju (bukan mundur)
            -- Hitung sudut vertikal kamera (berapa derajat melihat ke atas/bawah)
            local horizontalLook = Vector3.new(lookVector.X, 0, lookVector.Z)
            local lookAngle = math.deg(math.acos(horizontalLook.Unit:Dot(lookVector.Unit)))
            
            -- Tentukan apakah melihat ke atas atau ke bawah
            if lookVector.Y > 0 then  -- Sedang melihat ke atas
                lookAngle = lookAngle  -- positif = naik
            else  -- Sedang melihat ke bawah
                lookAngle = -lookAngle  -- negatif = turun
            end
            
            -- Konversi sudut ke faktor vertikal (0-1)
            local verticalFactor = math.clamp(lookAngle / 90, -1, 1)
            
            -- Tambahkan komponen vertikal ke movement
            if math.abs(verticalFactor) > 0.1 then  -- Threshold kecil
                movement = movement + (Vector3.new(0, verticalFactor, 0) * 0.7)
            end
        end
        
        -- **TAMBAHAN: Tombol E/Q untuk fine adjustment (opsional)**
        local fineAdjust = 0
        if Keys.E then fineAdjust = fineAdjust + 0.3 end
        if Keys.Q then fineAdjust = fineAdjust - 0.3 end
        movement = movement + Vector3.new(0, fineAdjust, 0)
        
        -- Normalize final movement dan terapkan speed
        if movement.Magnitude > 0 then
            movement = movement.Unit * FLY.Speed * 100
        end
        
        -- Apply velocity
        FLY.Velocity.Velocity = movement
        
        -- Gyro tetap mengikuti arah horizontal kamera (tidak miring)
        local horizontalLookFlat = Vector3.new(lookVector.X, 0, lookVector.Z)
        if horizontalLookFlat.Magnitude > 0 then
            FLY.Gyro.CFrame = CFrame.new(RootPart.Position, RootPart.Position + horizontalLookFlat)
        end
    end)
end

local function StopFly()
    FLY.Active = false
    
    if FLY.Loop then FLY.Loop:Disconnect() end
    if FLY.Noclip then FLY.Noclip:Disconnect() end
    if FLY.Velocity then FLY.Velocity:Destroy() end
    if FLY.Gyro then FLY.Gyro:Destroy() end
    
    for _, p in pairs(Character:GetDescendants()) do
        if p:IsA("BasePart") then p.CanCollide = true end
    end
    
    Humanoid.PlatformStand = false
    
    for k in pairs(Keys) do Keys[k] = false end
    Joystick.Active = false
    Joystick.X = 0
    Joystick.Y = 0
end

local function ToggleFly()
    if FLY.Active then StopFly() else StartFly() end
end

-- Keyboard
UIS.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Keyboard then
        local key = input.KeyCode
        if key == Enum.KeyCode.W then Keys.W = true end
        if key == Enum.KeyCode.A then Keys.A = true end
        if key == Enum.KeyCode.S then Keys.S = true end
        if key == Enum.KeyCode.D then Keys.D = true end
        if key == Enum.KeyCode.E then Keys.E = true end
        if key == Enum.KeyCode.Q then Keys.Q = true end
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Keyboard then
        local key = input.KeyCode
        if key == Enum.KeyCode.W then Keys.W = false end
        if key == Enum.KeyCode.A then Keys.A = false end
        if key == Enum.KeyCode.S then Keys.S = false end
        if key == Enum.KeyCode.D then Keys.D = false end
        if key == Enum.KeyCode.E then Keys.E = false end
        if key == Enum.KeyCode.Q then Keys.Q = false end
    end
end)

-- GUI
local CoreGui = game:GetService("CoreGui")
local oldGUI = CoreGui:FindFirstChild("FlyGUI")
if oldGUI then oldGUI:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "FlyGUI"
gui.ResetOnSpawn = false
gui.Parent = CoreGui

-- Panel
local panel = Instance.new("Frame")
panel.Size = UDim2.new(0, 140, 0, 130)
panel.Position = UDim2.new(1, -150, 0, 10)
panel.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
panel.BackgroundTransparency = 0.1
panel.BorderSizePixel = 0
panel.Parent = gui

-- Title bar
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 25)
titleBar.BackgroundColor3 = Color3.fromRGB(40, 0, 0)
titleBar.Parent = panel

local title = Instance.new("TextLabel")
title.Text = "FLY A9x"
title.TextColor3 = Color3.fromRGB(255, 100, 100)
title.Size = UDim2.new(0, 60, 1, 0)
title.Position = UDim2.new(0, 5, 0, 0)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 12
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = titleBar

local closeBtn = Instance.new("TextButton")
closeBtn.Text = "×"
closeBtn.Size = UDim2.new(0, 25, 0, 25)
closeBtn.Position = UDim2.new(1, -25, 0, 0)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 16
closeBtn.Parent = titleBar

-- Content
local content = Instance.new("Frame")
content.Size = UDim2.new(1, 0, 1, -25)
content.Position = UDim2.new(0, 0, 0, 25)
content.BackgroundTransparency = 1
content.Parent = panel

-- Toggle button
local toggleBtn = Instance.new("TextButton")
toggleBtn.Text = "ON"
toggleBtn.Size = UDim2.new(1, -10, 0, 35)
toggleBtn.Position = UDim2.new(0, 5, 0, 5)
toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 12
toggleBtn.Parent = content

-- Speed controls
local speedFrame = Instance.new("Frame")
speedFrame.Size = UDim2.new(1, -10, 0, 25)
speedFrame.Position = UDim2.new(0, 5, 0, 45)
speedFrame.BackgroundTransparency = 1
speedFrame.Parent = content

local speedLabel = Instance.new("TextLabel")
speedLabel.Text = "SPD:"
speedLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
speedLabel.Size = UDim2.new(0, 30, 1, 0)
speedLabel.Position = UDim2.new(0, 0, 0, 0)
speedLabel.BackgroundTransparency = 1
speedLabel.Font = Enum.Font.Gotham
speedLabel.TextSize = 10
speedLabel.TextXAlignment = Enum.TextXAlignment.Left
speedLabel.Parent = speedFrame

local speedMinus = Instance.new("TextButton")
speedMinus.Text = "-"
speedMinus.Size = UDim2.new(0, 20, 0, 20)
speedMinus.Position = UDim2.new(0, 35, 0.5, -10)
speedMinus.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
speedMinus.TextColor3 = Color3.fromRGB(255, 255, 255)
speedMinus.Font = Enum.Font.GothamBold
speedMinus.TextSize = 12
speedMinus.Parent = speedFrame

local speedValue = Instance.new("TextLabel")
speedValue.Name = "SpeedValue"
speedValue.Text = tostring(FLY.Speed)
speedValue.TextColor3 = Color3.fromRGB(255, 255, 0)
speedValue.Size = UDim2.new(0, 30, 0, 20)
speedValue.Position = UDim2.new(0, 60, 0.5, -10)
speedValue.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
speedValue.Font = Enum.Font.GothamBold
speedValue.TextSize = 11
speedValue.Parent = speedFrame

local speedPlus = Instance.new("TextButton")
speedPlus.Text = "+"
speedPlus.Size = UDim2.new(0, 20, 0, 20)
speedPlus.Position = UDim2.new(0, 95, 0.5, -10)
speedPlus.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
speedPlus.TextColor3 = Color3.fromRGB(255, 255, 255)
speedPlus.Font = Enum.Font.GothamBold
speedPlus.TextSize = 12
speedPlus.Parent = speedFrame

-- Info text (cara pakai)
local infoText = Instance.new("TextLabel")
infoText.Text = "Fly with the noclip system"
infoText.TextColor3 = Color3.fromRGB(150, 150, 255)
infoText.Size = UDim2.new(1, -10, 0, 20)
infoText.Position = UDim2.new(0, 5, 0, 75)
infoText.BackgroundTransparency = 1
infoText.Font = Enum.Font.Gotham
infoText.TextSize = 9
infoText.TextXAlignment = Enum.TextXAlignment.Center
infoText.Parent = content

-- Mobile joystick (untuk gerakan maju/mundur/kiri/kanan)
if UIS.TouchEnabled then
    local joyBg = Instance.new("Frame")
    joyBg.Size = UDim2.new(0, 120, 0, 120)
    joyBg.Position = UDim2.new(0, 30, 1, -150)
    joyBg.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    joyBg.BackgroundTransparency = 0.3
    joyBg.BorderSizePixel = 0
    joyBg.Parent = gui
    
    local joyCorner = Instance.new("UICorner")
    joyCorner.CornerRadius = UDim.new(1, 0)
    joyCorner.Parent = joyBg
    
    local joyKnob = Instance.new("Frame")
    joyKnob.Size = UDim2.new(0, 50, 0, 50)
    joyKnob.Position = UDim2.new(0.5, -25, 0.5, -25)
    joyKnob.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    joyKnob.BackgroundTransparency = 0.2
    joyKnob.BorderSizePixel = 0
    joyKnob.Parent = joyBg
    
    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = joyKnob
    
    -- Touch handling
    joyBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            Joystick.Active = true
            
            local conn
            conn = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    Joystick.Active = false
                    Joystick.X = 0
                    Joystick.Y = 0
                    joyKnob.Position = UDim2.new(0.5, -25, 0.5, -25)
                    if conn then conn:Disconnect() end
                else
                    local bgPos = joyBg.AbsolutePosition
                    local bgSize = joyBg.AbsoluteSize
                    local touchPos = input.Position
                    
                    local x = ((touchPos.X - bgPos.X) / bgSize.X) * 2 - 1
                    local y = ((touchPos.Y - bgPos.Y) / bgSize.Y) * 2 - 1
                    
                    local len = math.sqrt(x*x + y*y)
                    if len > 1 then x = x/len; y = y/len end
                    
                    local dead = 0.15
                    if math.abs(x) < dead then x = 0 end
                    if math.abs(y) < dead then y = 0 end
                    
                    Joystick.X = x
                    Joystick.Y = y
                    
                    joyKnob.Position = UDim2.new(
                        0.5 + x * 0.4, -25,
                        0.5 + y * 0.4, -25
                    )
                end
            end)
        end
    end)
end

-- Update UI
local function UpdateUI()
    if FLY.Active then
        toggleBtn.Text = "ON"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    else
        toggleBtn.Text = "OFF"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    end
    speedValue.Text = string.format("%.1f", FLY.Speed)
end

-- Button events
toggleBtn.MouseButton1Click:Connect(function()
    ToggleFly()
    UpdateUI()
end)

speedMinus.MouseButton1Click:Connect(function()
    FLY.Speed = math.max(0.5, FLY.Speed - 0.5)
    UpdateUI()
end)

speedPlus.MouseButton1Click:Connect(function()
    FLY.Speed = math.min(10, FLY.Speed + 0.5)
    UpdateUI()
end)

closeBtn.MouseButton1Click:Connect(function()
    StopFly()
    gui:Destroy()
end)

-- Cleanup
gui.Destroying:Connect(function()
    StopFly()
end)

UpdateUI()

-- Character events
LocalPlayer.CharacterAdded:Connect(function(newChar)
    Character = newChar
    task.wait(0.5)
    Humanoid = Character:WaitForChild("Humanoid")
    RootPart = Character:WaitForChild("HumanoidRootPart")
    
    if FLY.Active then
        StopFly()
        task.wait(0.1)
        StartFly()
    end
end)

print("[Fly VIP] [Anonymous9x] Loaded - Camera Direction Flight System")
