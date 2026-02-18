-- ================================================
-- ANONYMOUS9X FREECAM - FINAL FIX (100% ORI UI)
-- Fitur: UI Original (Fixed), Analog Normal, Touch/Mouse Look Work
-- ================================================

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- State Freecam
local Freecam = {
    Active = false,
    Speed = 2,
    FOV = 70,
    LookSensitivity = 0.005,
    TouchSensitivity = 0.008,
    RotX = 0,
    RotY = 0,
    Connection = nil,
    OriginalCameraType = nil,
    OriginalFOV = nil,
    OriginalWalkSpeed = nil,
    OriginalJumpPower = nil,
    OriginalPlatformStand = nil,
}

-- Input state
local Keys = {W=false, A=false, S=false, D=false}
local Joystick = {Active=false, X=0, Y=0}
local toggleBtn = nil -- Kita buat variabel kosong dulu biar fungsi bisa baca

-- Fungsi Karakter
local function getCharacter() return LocalPlayer.Character end
local function getHumanoid()
    local char = getCharacter()
    return char and char:FindFirstChildOfClass("Humanoid")
end

local function freezeCharacter(freeze)
    local hum = getHumanoid()
    if hum then
        if freeze then
            Freecam.OriginalWalkSpeed = hum.WalkSpeed
            Freecam.OriginalJumpPower = hum.JumpPower
            Freecam.OriginalPlatformStand = hum.PlatformStand
            hum.WalkSpeed = 0
            hum.JumpPower = 0
            hum.PlatformStand = true
        else
            if Freecam.OriginalWalkSpeed then
                hum.WalkSpeed = Freecam.OriginalWalkSpeed
                hum.JumpPower = Freecam.OriginalJumpPower
                hum.PlatformStand = Freecam.OriginalPlatformStand
            else
                hum.WalkSpeed = 16
                hum.JumpPower = 50
                hum.PlatformStand = false
            end
        end
    end
end

-- Start Freecam
local function startFreecam()
    if Freecam.Active then return end
    Freecam.Active = true

    Freecam.OriginalCameraType = Camera.CameraType
    Freecam.OriginalFOV = Camera.FieldOfView
    
    local rx, ry, rz = Camera.CFrame:ToEulerAnglesYXZ()
    Freecam.RotX, Freecam.RotY = rx, ry

    Camera.CameraType = Enum.CameraType.Scriptable
    freezeCharacter(true)
    
    if UIS.MouseEnabled then UIS.MouseBehavior = Enum.MouseBehavior.LockCenter end

    Freecam.Connection = RS.RenderStepped:Connect(function(dt)
        local rotCF = CFrame.fromEulerAnglesYXZ(Freecam.RotX, Freecam.RotY, 0)
        local moveDir = Vector3.new()

        if Keys.W then moveDir = moveDir + Vector3.new(0,0,-1) end
        if Keys.S then moveDir = moveDir + Vector3.new(0,0,1) end
        if Keys.A then moveDir = moveDir + Vector3.new(-1,0,0) end
        if Keys.D then moveDir = moveDir + Vector3.new(1,0,0) end

        if Joystick.Active then
            -- FIX ANALOG: Gak pake minus lagi biar maju ya maju
            moveDir = moveDir + Vector3.new(Joystick.X, 0, Joystick.Y)
        end

        if moveDir.Magnitude > 0 then moveDir = moveDir.Unit end

        local speed = Freecam.Speed * 60 * dt
        local newPos = Camera.CFrame.Position + (rotCF * moveDir * speed)
        
        Camera.CFrame = CFrame.new(newPos) * rotCF
        Camera.FieldOfView = Freecam.FOV
    end)

    if toggleBtn then
        toggleBtn.Text = "ON"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
    end
end

local function stopFreecam()
    if not Freecam.Active then return end
    Freecam.Active = false
    if Freecam.Connection then Freecam.Connection:Disconnect(); Freecam.Connection = nil end
    Camera.CameraType = Freecam.OriginalCameraType or Enum.CameraType.Custom
    Camera.FieldOfView = Freecam.OriginalFOV or 70
    UIS.MouseBehavior = Enum.MouseBehavior.Default
    freezeCharacter(false)
    for k in pairs(Keys) do Keys[k] = false end
    Joystick.Active = false
    if toggleBtn then
        toggleBtn.Text = "OFF"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    end
end

local function toggleFreecam()
    if Freecam.Active then stopFreecam() else startFreecam() end
end

-- Logic Nengok (Fixed Touch & Mouse)
UIS.InputChanged:Connect(function(input)
    if not Freecam.Active then return end
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        Freecam.RotY = Freecam.RotY - input.Delta.X * Freecam.LookSensitivity
        Freecam.RotX = Freecam.RotX - input.Delta.Y * Freecam.LookSensitivity
        Freecam.RotX = math.clamp(Freecam.RotX, -1.5, 1.5)
    elseif input.UserInputType == Enum.UserInputType.Touch then
        if input.Delta.Magnitude > 0.5 then
            Freecam.RotY = Freecam.RotY - input.Delta.X * Freecam.TouchSensitivity
            Freecam.RotX = Freecam.RotX - input.Delta.Y * Freecam.TouchSensitivity
            Freecam.RotX = math.clamp(Freecam.RotX, -1.5, 1.5)
        end
    end
end)

UIS.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Keyboard then
        local k = input.KeyCode
        if k == Enum.KeyCode.W then Keys.W = true end
        if k == Enum.KeyCode.A then Keys.A = true end
        if k == Enum.KeyCode.S then Keys.S = true end
        if k == Enum.KeyCode.D then Keys.D = true end
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Keyboard then
        local k = input.KeyCode
        if k == Enum.KeyCode.W then Keys.W = false end
        if k == Enum.KeyCode.A then Keys.A = false end
        if k == Enum.KeyCode.S then Keys.S = false end
        if k == Enum.KeyCode.D then Keys.D = false end
    end
end)

-- ================================================
-- GUI PANEL (FULL ORIGINAL PUNYA LU)
-- ================================================
local oldGUI = CoreGui:FindFirstChild("A9xFreecam")
if oldGUI then oldGUI:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "A9xFreecam"
gui.ResetOnSpawn = false
gui.Parent = CoreGui

local panel = Instance.new("Frame")
panel.Size = UDim2.new(0, 140, 0, 150)
panel.Position = UDim2.new(1, -150, 0, 10)
panel.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
panel.BorderSizePixel = 0
panel.Parent = gui

local stroke = Instance.new("UIStroke", panel)
stroke.Color = Color3.fromRGB(255, 255, 255)
stroke.Thickness = 1.5

local corner = Instance.new("UICorner", panel)
corner.CornerRadius = UDim.new(0, 6)

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 25)
titleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
titleBar.BorderSizePixel = 0
titleBar.Parent = panel

local titleCorner = Instance.new("UICorner", titleBar)
titleCorner.CornerRadius = UDim.new(0, 6)

local title = Instance.new("TextLabel")
title.Text = "A9x Freecam"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Size = UDim2.new(1, -45, 1, 0)
title.Position = UDim2.new(0, 5, 0, 0)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 11
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = titleBar

local minBtn = Instance.new("TextButton")
minBtn.Text = "−"
minBtn.Size = UDim2.new(0, 20, 0, 20)
minBtn.Position = UDim2.new(1, -45, 0.5, -10)
minBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
minBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minBtn.Font = Enum.Font.GothamBold
minBtn.TextSize = 14
minBtn.BorderSizePixel = 0
minBtn.Parent = titleBar
local minCorner = Instance.new("UICorner", minBtn)
minCorner.CornerRadius = UDim.new(0, 4)

local closeBtn = Instance.new("TextButton")
closeBtn.Text = "×"
closeBtn.Size = UDim2.new(0, 20, 0, 20)
closeBtn.Position = UDim2.new(1, -22, 0.5, -10)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 14
closeBtn.BorderSizePixel = 0
closeBtn.Parent = titleBar
local closeCorner = Instance.new("UICorner", closeBtn)
closeCorner.CornerRadius = UDim.new(0, 4)

local content = Instance.new("Frame")
content.Size = UDim2.new(1, -6, 1, -29)
content.Position = UDim2.new(0, 3, 0, 26)
content.BackgroundTransparency = 1
content.Parent = panel

toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(1, 0, 0, 30)
toggleBtn.Position = UDim2.new(0, 0, 0, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
toggleBtn.Text = "OFF"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 11
toggleBtn.BorderSizePixel = 0
toggleBtn.Parent = content
local toggleCorner = Instance.new("UICorner", toggleBtn)
toggleCorner.CornerRadius = UDim.new(0, 4)
local toggleStroke = Instance.new("UIStroke", toggleBtn)
toggleStroke.Color = Color3.fromRGB(255, 255, 255)
toggleStroke.Thickness = 1

toggleBtn.MouseButton1Click:Connect(toggleFreecam)

local speedFrame = Instance.new("Frame")
speedFrame.Size = UDim2.new(1, 0, 0, 30)
speedFrame.Position = UDim2.new(0, 0, 0, 35)
speedFrame.BackgroundTransparency = 1
speedFrame.Parent = content

local speedLabel = Instance.new("TextLabel")
speedLabel.Text = "SPEED"
speedLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
speedLabel.Size = UDim2.new(0, 40, 1, 0)
speedLabel.Position = UDim2.new(0, 0, 0, 0)
speedLabel.BackgroundTransparency = 1
speedLabel.Font = Enum.Font.Gotham
speedLabel.TextSize = 9
speedLabel.TextXAlignment = Enum.TextXAlignment.Left
speedLabel.Parent = speedFrame

local speedMinus = Instance.new("TextButton")
speedMinus.Text = "-"
speedMinus.Size = UDim2.new(0, 20, 0, 20)
speedMinus.Position = UDim2.new(0, 40, 0.5, -10)
speedMinus.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
speedMinus.TextColor3 = Color3.fromRGB(255, 255, 255)
speedMinus.Font = Enum.Font.GothamBold
speedMinus.TextSize = 12
speedMinus.BorderSizePixel = 0
speedMinus.Parent = speedFrame
local minusCorner = Instance.new("UICorner", speedMinus)
minusCorner.CornerRadius = UDim.new(0, 4)

local speedValue = Instance.new("TextLabel")
speedValue.Text = tostring(Freecam.Speed)
speedValue.TextColor3 = Color3.fromRGB(255, 255, 255)
speedValue.Size = UDim2.new(0, 30, 0, 20)
speedValue.Position = UDim2.new(0, 65, 0.5, -10)
speedValue.BackgroundTransparency = 1
speedValue.Font = Enum.Font.GothamBold
speedValue.TextSize = 11
speedValue.Parent = speedFrame

local speedPlus = Instance.new("TextButton")
speedPlus.Text = "+"
speedPlus.Size = UDim2.new(0, 20, 0, 20)
speedPlus.Position = UDim2.new(0, 100, 0.5, -10)
speedPlus.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
speedPlus.TextColor3 = Color3.fromRGB(255, 255, 255)
speedPlus.Font = Enum.Font.GothamBold
speedPlus.TextSize = 12
speedPlus.BorderSizePixel = 0
speedPlus.Parent = speedFrame
local plusCorner = Instance.new("UICorner", speedPlus)
plusCorner.CornerRadius = UDim.new(0, 4)

speedMinus.MouseButton1Click:Connect(function()
    Freecam.Speed = math.max(0.5, Freecam.Speed - 0.5)
    speedValue.Text = string.format("%.1f", Freecam.Speed)
end)
speedPlus.MouseButton1Click:Connect(function()
    Freecam.Speed = math.min(10, Freecam.Speed + 0.5)
    speedValue.Text = string.format("%.1f", Freecam.Speed)
end)

local fovFrame = Instance.new("Frame")
fovFrame.Size = UDim2.new(1, 0, 0, 30)
fovFrame.Position = UDim2.new(0, 0, 0, 70)
fovFrame.BackgroundTransparency = 1
fovFrame.Parent = content

local fovLabel = Instance.new("TextLabel")
fovLabel.Text = "FOV"
fovLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
fovLabel.Size = UDim2.new(0, 40, 1, 0)
fovLabel.Position = UDim2.new(0, 0, 0, 0)
fovLabel.BackgroundTransparency = 1
fovLabel.Font = Enum.Font.Gotham
fovLabel.TextSize = 9
fovLabel.TextXAlignment = Enum.TextXAlignment.Left
fovLabel.Parent = fovFrame

local fovMinus = Instance.new("TextButton")
fovMinus.Text = "-"
fovMinus.Size = UDim2.new(0, 20, 0, 20)
fovMinus.Position = UDim2.new(0, 40, 0.5, -10)
fovMinus.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
fovMinus.TextColor3 = Color3.fromRGB(255, 255, 255)
fovMinus.Font = Enum.Font.GothamBold
fovMinus.TextSize = 12
fovMinus.BorderSizePixel = 0
fovMinus.Parent = fovFrame
local fovMinusCorner = Instance.new("UICorner", fovMinus)
fovMinusCorner.CornerRadius = UDim.new(0, 4)

local fovValue = Instance.new("TextLabel")
fovValue.Text = tostring(Freecam.FOV)
fovValue.TextColor3 = Color3.fromRGB(255, 255, 255)
fovValue.Size = UDim2.new(0, 30, 0, 20)
fovValue.Position = UDim2.new(0, 65, 0.5, -10)
fovValue.BackgroundTransparency = 1
fovValue.Font = Enum.Font.GothamBold
fovValue.TextSize = 11
fovValue.Parent = fovFrame

local fovPlus = Instance.new("TextButton")
fovPlus.Text = "+"
fovPlus.Size = UDim2.new(0, 20, 0, 20)
fovPlus.Position = UDim2.new(0, 100, 0.5, -10)
fovPlus.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
fovPlus.TextColor3 = Color3.fromRGB(255, 255, 255)
fovPlus.Font = Enum.Font.GothamBold
fovPlus.TextSize = 12
fovPlus.BorderSizePixel = 0
fovPlus.Parent = fovFrame
local fovPlusCorner = Instance.new("UICorner", fovPlus)
fovPlusCorner.CornerRadius = UDim.new(0, 4)

fovMinus.MouseButton1Click:Connect(function()
    Freecam.FOV = math.max(20, Freecam.FOV - 5)
    fovValue.Text = tostring(Freecam.FOV)
    if Freecam.Active then Camera.FieldOfView = Freecam.FOV end
end)
fovPlus.MouseButton1Click:Connect(function()
    Freecam.FOV = math.min(120, Freecam.FOV + 5)
    fovValue.Text = tostring(Freecam.FOV)
    if Freecam.Active then Camera.FieldOfView = Freecam.FOV end
end)

-- Mobile Joystick
if UIS.TouchEnabled then
    local joyBg = Instance.new("Frame")
    joyBg.Size = UDim2.new(0, 120, 0, 120)
    joyBg.Position = UDim2.new(0, 30, 1, -150)
    joyBg.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    joyBg.BackgroundTransparency = 0.3
    joyBg.BorderSizePixel = 0
    joyBg.Parent = gui
    local joyCorner = Instance.new("UICorner", joyBg)
    joyCorner.CornerRadius = UDim.new(1, 0)

    local joyKnob = Instance.new("Frame")
    joyKnob.Size = UDim2.new(0, 50, 0, 50)
    joyKnob.Position = UDim2.new(0.5, -25, 0.5, -25)
    joyKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    joyKnob.BackgroundTransparency = 0.2
    joyKnob.BorderSizePixel = 0
    joyKnob.Parent = joyBg
    local knobCorner = Instance.new("UICorner", joyKnob)
    knobCorner.CornerRadius = UDim.new(1, 0)

    joyBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            Joystick.Active = true
            local conn; conn = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    Joystick.Active = false
                    Joystick.X = 0; Joystick.Y = 0
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
                    if math.abs(x) < 0.15 then x = 0 end
                    if math.abs(y) < 0.15 then y = 0 end
                    Joystick.X = x; Joystick.Y = y
                    joyKnob.Position = UDim2.new(0.5 + x * 0.4, -25, 0.5 + y * 0.4, -25)
                end
            end)
        end
    end)
end

local minimized = false
local originalSize = panel.Size
minBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        TweenService:Create(panel, TweenInfo.new(0.2), {Size = UDim2.new(0, 140, 0, 25)}):Play()
        content.Visible = false
        minBtn.Text = "+"
    else
        TweenService:Create(panel, TweenInfo.new(0.2), {Size = originalSize}):Play()
        content.Visible = true
        minBtn.Text = "−"
    end
end)

closeBtn.MouseButton1Click:Connect(function()
    stopFreecam()
    gui:Destroy()
end)

gui.Destroying:Connect(stopFreecam)
print("[A9x Freecam]")
