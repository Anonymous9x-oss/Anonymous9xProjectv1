local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid")
local enabled = false
local targetSpeed = 500
local appliedSpeed = 0
local speedTransition = 0.25
local accelLimit = 1500
local seat
local rootPart

-- Color Config
local PrimaryColor = Color3.fromRGB(100, 180, 250)
local SecondaryColor = Color3.fromRGB(250, 120, 140)
local GlowColor = Color3.fromRGB(80, 160, 255)
local DarkBg = Color3.fromRGB(13, 12, 18)
local CardBg = Color3.fromRGB(22, 20, 28)
local SoftGray = Color3.fromRGB(170, 170, 200)

-- Logo Asset ID
local LOGO_ID = "102712457593054"

-- Mini Notification System
local function showMiniNotification(message, type)
    local notif = Instance.new("Frame", gui)
    notif.Size = UDim2.fromOffset(220, 34)
    notif.Position = UDim2.fromScale(0.5, -0.05)
    notif.AnchorPoint = Vector2.new(0.5, 0)
    notif.BackgroundColor3 = CardBg
    notif.BackgroundTransparency = 0.1
    notif.ZIndex = 20
    
    local notifCorner = Instance.new("UICorner", notif)
    notifCorner.CornerRadius = UDim.new(0, 10)
    
    local notifStroke = Instance.new("UIStroke", notif)
    notifStroke.Thickness = 1
    if type == "error" then
        notifStroke.Color = Color3.fromRGB(255, 100, 100)
    elseif type == "warning" then
        notifStroke.Color = Color3.fromRGB(255, 180, 80)
    else
        notifStroke.Color = PrimaryColor
    end
    notifStroke.Transparency = 0.3
    
    local icon = Instance.new("TextLabel", notif)
    icon.Size = UDim2.fromOffset(22, 22)
    icon.Position = UDim2.new(0, 8, 0.5, -11)
    icon.BackgroundTransparency = 1
    icon.Text = type == "error" and "⚠" or (type == "warning" and "⚡" or "✓")
    icon.TextColor3 = notifStroke.Color
    icon.Font = Enum.Font.GothamBold
    icon.TextSize = 14
    
    local msgLabel = Instance.new("TextLabel", notif)
    msgLabel.Size = UDim2.new(1, -38, 1, 0)
    msgLabel.Position = UDim2.new(0, 34, 0, 0)
    msgLabel.BackgroundTransparency = 1
    msgLabel.Text = message
    msgLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    msgLabel.Font = Enum.Font.Gotham
    msgLabel.TextSize = 11
    msgLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    TweenService:Create(notif, TweenInfo.new(0.25, Enum.EasingStyle.Back), {
        Position = UDim2.fromScale(0.5, 0.02)
    }):Play()
    
    task.wait(2)
    
    TweenService:Create(notif, TweenInfo.new(0.2, Enum.EasingStyle.Back), {
        Position = UDim2.fromScale(0.5, -0.05)
    }):Play()
    task.wait(0.2)
    notif:Destroy()
end

local function getSeat()
    if hum.SeatPart and hum.SeatPart:IsA("VehicleSeat") then
        return hum.SeatPart
    end
end

local function getCarRoot(seat)
    local model = seat.Parent
    if model:IsA("Model") then
        return model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
    end
end

-- Speed Control (FAST)
RunService.Heartbeat:Connect(function(dt)
    if not enabled or not seat or not rootPart then return end

    local currentVel = rootPart.AssemblyLinearVelocity
    local forward = rootPart.CFrame.LookVector
    local currentSpeed = forward:Dot(Vector3.new(currentVel.X, 0, currentVel.Z))

    local diff = targetSpeed - appliedSpeed
    local step = math.clamp(diff, -accelLimit * dt, accelLimit * dt)
    appliedSpeed += step * speedTransition

    local speedDiff = appliedSpeed - currentSpeed
    local velocityChange = forward * speedDiff

    local force = velocityChange * rootPart.AssemblyMass / dt
    local maxForce = rootPart.AssemblyMass * 8000
    if force.Magnitude > maxForce then
        force = force.Unit * maxForce
    end

    local impulse = force * dt
    rootPart:ApplyImpulse(impulse)

    local rightVector = rootPart.CFrame.RightVector
    local lateralVel = rightVector * rightVector:Dot(currentVel)
    local dampingFactor = 0.92
    local lateralDamping = lateralVel * (1 - dampingFactor)
    rootPart:ApplyImpulse(-lateralDamping * rootPart.AssemblyMass * dt)

    if rootPart.AssemblyAngularVelocity.Magnitude > 0.05 then
        local angularDamping = rootPart.AssemblyAngularVelocity * 0.85
        rootPart.AssemblyAngularVelocity = rootPart.AssemblyAngularVelocity - (angularDamping * dt * 20)
    end
end)

-- Modern GUI
local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.ResetOnSpawn = false
gui.Name = "FIQQZR7_Farm"

-- Main Frame
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.fromOffset(280, 380)
frame.Position = UDim2.fromScale(0.5, 0.1)
frame.AnchorPoint = Vector2.new(0.5, 0)
frame.BackgroundColor3 = DarkBg
frame.BackgroundTransparency = 0
frame.Active = true
frame.Draggable = true
frame.ClipsDescendants = true

local frameCorner = Instance.new("UICorner", frame)
frameCorner.CornerRadius = UDim.new(0, 20)

-- Outer Glow
local outerGlow = Instance.new("UIStroke", frame)
outerGlow.Thickness = 2
outerGlow.Color = GlowColor
outerGlow.Transparency = 0.4

-- Inner Glow
local innerGlow = Instance.new("UIStroke", frame)
innerGlow.Thickness = 1
innerGlow.Color = SecondaryColor
innerGlow.Transparency = 0.6

-- Pulse animation
task.spawn(function()
    while frame.Parent do
        TweenService:Create(outerGlow, TweenInfo.new(1.5), {Transparency = 0.2}):Play()
        task.wait(1)
        TweenService:Create(outerGlow, TweenInfo.new(1.5), {Transparency = 0.5}):Play()
        task.wait(1)
    end
end)

-- Title Bar
local titleBar = Instance.new("Frame", frame)
titleBar.Size = UDim2.new(1, 0, 0, 52)
titleBar.BackgroundColor3 = Color3.fromRGB(18, 16, 24)
titleBar.BorderSizePixel = 0

local titleCorner = Instance.new("UICorner", titleBar)
titleCorner.CornerRadius = UDim.new(0, 20)

-- Logo
local logoImage = Instance.new("ImageLabel", titleBar)
logoImage.Size = UDim2.fromOffset(34, 34)
logoImage.Position = UDim2.new(0, 12, 0.5, -17)
logoImage.BackgroundTransparency = 1
logoImage.Image = "rbxassetid://" .. LOGO_ID
logoImage.ZIndex = 10

-- Title Text
local titleText = Instance.new("TextLabel", titleBar)
titleText.Size = UDim2.new(1, -100, 1, 0)
titleText.Position = UDim2.new(0, 54, 0, 0)
titleText.BackgroundTransparency = 1
titleText.Text = "FIQQZR7xANONYMOUS9X SET SPEED"
titleText.TextColor3 = Color3.fromRGB(255, 255, 255)
titleText.Font = Enum.Font.GothamBold
titleText.TextSize = 16
titleText.TextXAlignment = Enum.TextXAlignment.Left
titleText.ZIndex = 10

-- Subtitle
local subText = Instance.new("TextLabel", titleBar)
subText.Size = UDim2.new(1, -100, 0, 14)
subText.Position = UDim2.new(0, 54, 0, 32)
subText.BackgroundTransparency = 1
subText.Text = "Fiqqzr7XCode"
subText.TextColor3 = SoftGray
subText.Font = Enum.Font.Gotham
subText.TextSize = 9
subText.TextXAlignment = Enum.TextXAlignment.Left
subText.ZIndex = 10

-- Close Button
local closeBtn = Instance.new("TextButton", titleBar)
closeBtn.Size = UDim2.fromOffset(28, 28)
closeBtn.Position = UDim2.new(1, -36, 0.5, -14)
closeBtn.BackgroundColor3 = Color3.fromRGB(50, 45, 55)
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 14
closeBtn.BorderSizePixel = 0

local closeCorner = Instance.new("UICorner", closeBtn)
closeCorner.CornerRadius = UDim.new(0, 8)

-- Minimize Button
local minBtn = Instance.new("TextButton", titleBar)
minBtn.Size = UDim2.fromOffset(28, 28)
minBtn.Position = UDim2.new(1, -68, 0.5, -14)
minBtn.BackgroundColor3 = Color3.fromRGB(50, 45, 55)
minBtn.Text = "—"
minBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
minBtn.Font = Enum.Font.GothamBold
minBtn.TextSize = 14
minBtn.BorderSizePixel = 0

local minCorner = Instance.new("UICorner", minBtn)
minCorner.CornerRadius = UDim.new(0, 8)

local function addHover(btn, hoverColor)
    local original = btn.BackgroundColor3
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = hoverColor}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = original}):Play()
    end)
end

addHover(closeBtn, Color3.fromRGB(180, 60, 70))
addHover(minBtn, Color3.fromRGB(70, 60, 80))

-- Divider
local divider = Instance.new("Frame", frame)
divider.Size = UDim2.new(0.88, 0, 0, 1)
divider.Position = UDim2.new(0.06, 0, 0, 56)
divider.BackgroundColor3 = GlowColor
divider.BackgroundTransparency = 0.5
divider.BorderSizePixel = 0

-- SCROLL CONTAINER
local scrollContainer = Instance.new("ScrollingFrame", frame)
scrollContainer.Size = UDim2.new(1, 0, 1, -56)
scrollContainer.Position = UDim2.new(0, 0, 0, 56)
scrollContainer.BackgroundTransparency = 1
scrollContainer.BorderSizePixel = 0
scrollContainer.ScrollBarThickness = 3
scrollContainer.ScrollBarImageColor3 = PrimaryColor
scrollContainer.ScrollBarImageTransparency = 0.5
scrollContainer.CanvasSize = UDim2.new(0, 0, 0, 0)

-- Content Canvas
local contentCanvas = Instance.new("Frame", scrollContainer)
contentCanvas.Size = UDim2.new(1, 0, 0, 0)
contentCanvas.BackgroundTransparency = 1
contentCanvas.ZIndex = 2

-- UIListLayout
local layout = Instance.new("UIListLayout", contentCanvas)
layout.Padding = UDim.new(0, 12)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- ========== SPEED CARD ==========
local speedCard = Instance.new("Frame", contentCanvas)
speedCard.Size = UDim2.new(0.92, 0, 0, 70)
speedCard.BackgroundColor3 = CardBg
speedCard.BorderSizePixel = 0

local cardCorner = Instance.new("UICorner", speedCard)
cardCorner.CornerRadius = UDim.new(0, 16)

local cardGlow = Instance.new("UIStroke", speedCard)
cardGlow.Thickness = 1
cardGlow.Color = GlowColor
cardGlow.Transparency = 0.5

-- Speed Value
local speedValue = Instance.new("TextLabel", speedCard)
speedValue.Size = UDim2.new(0.6, 0, 1, 0)
speedValue.BackgroundTransparency = 1
speedValue.Text = "500"
speedValue.TextColor3 = PrimaryColor
speedValue.Font = Enum.Font.GothamBold
speedValue.TextSize = 38
speedValue.TextXAlignment = Enum.TextXAlignment.Center

-- Speed Unit
local speedUnit = Instance.new("TextLabel", speedCard)
speedUnit.Size = UDim2.new(0.3, 0, 0, 18)
speedUnit.Position = UDim2.new(0.62, 0, 0.5, -9)
speedUnit.BackgroundTransparency = 1
speedUnit.Text = "km/h"
speedUnit.TextColor3 = SoftGray
speedUnit.Font = Enum.Font.Gotham
speedUnit.TextSize = 11

-- Status Dot
local statusDot = Instance.new("Frame", speedCard)
statusDot.Size = UDim2.fromOffset(10, 10)
statusDot.Position = UDim2.new(0.85, 0, 0.5, -5)
statusDot.BackgroundColor3 = Color3.fromRGB(100, 100, 100)

local dotCorner = Instance.new("UICorner", statusDot)
dotCorner.CornerRadius = UDim.new(1, 0)

local statusText = Instance.new("TextLabel", speedCard)
statusText.Size = UDim2.new(0.3, 0, 0, 14)
statusText.Position = UDim2.new(0.85, 0, 0.65, 0)
statusText.BackgroundTransparency = 1
statusText.Text = "off"
statusText.TextColor3 = SoftGray
statusText.Font = Enum.Font.Gotham
statusText.TextSize = 9

-- ========== SPEED CONTROL ==========
local controlSection = Instance.new("Frame", contentCanvas)
controlSection.Size = UDim2.new(0.92, 0, 0, 0)
controlSection.BackgroundTransparency = 1

-- Speed Label
local speedLabel = Instance.new("TextLabel", controlSection)
speedLabel.Size = UDim2.new(1, 0, 0, 24)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "set speed"
speedLabel.TextColor3 = SoftGray
speedLabel.Font = Enum.Font.GothamBold
speedLabel.TextSize = 12
speedLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Slider Background
local sliderBg = Instance.new("Frame", controlSection)
sliderBg.Size = UDim2.new(1, 0, 0, 5)
sliderBg.Position = UDim2.new(0, 0, 0, 28)
sliderBg.BackgroundColor3 = Color3.fromRGB(35, 33, 43)
sliderBg.BorderSizePixel = 0

local sliderBgCorner = Instance.new("UICorner", sliderBg)
sliderBgCorner.CornerRadius = UDim.new(1, 0)

-- Slider Fill
local sliderFill = Instance.new("Frame", sliderBg)
sliderFill.Size = UDim2.new(0.5, 0, 1, 0)
sliderFill.BackgroundColor3 = PrimaryColor
sliderFill.BorderSizePixel = 0

local sliderFillCorner = Instance.new("UICorner", sliderFill)
sliderFillCorner.CornerRadius = UDim.new(1, 0)

-- Speed Input
local speedInput = Instance.new("TextBox", controlSection)
speedInput.Size = UDim2.new(1, 0, 0, 40)
speedInput.Position = UDim2.new(0, 0, 0, 42)
speedInput.PlaceholderText = "enter speed"
speedInput.Text = "500"
speedInput.Font = Enum.Font.GothamBold
speedInput.TextSize = 16
speedInput.BackgroundColor3 = Color3.fromRGB(28, 26, 36)
speedInput.TextColor3 = PrimaryColor
speedInput.BorderSizePixel = 0

local inputCorner = Instance.new("UICorner", speedInput)
inputCorner.CornerRadius = UDim.new(0, 10)

controlSection.Size = UDim2.new(0.92, 0, 0, 90)

-- ========== UNLIMITED BADGE ==========
local badge = Instance.new("Frame", contentCanvas)
badge.Size = UDim2.new(0.92, 0, 0, 36)
badge.BackgroundColor3 = Color3.fromRGB(28, 26, 36)
badge.BorderSizePixel = 0

local badgeCorner = Instance.new("UICorner", badge)
badgeCorner.CornerRadius = UDim.new(0, 12)

local badgeGlow = Instance.new("UIStroke", badge)
badgeGlow.Thickness = 1
badgeGlow.Color = GlowColor
badgeGlow.Transparency = 0.6

local badgeText = Instance.new("TextLabel", badge)
badgeText.Size = UDim2.new(1, 0, 1, 0)
badgeText.BackgroundTransparency = 1
badgeText.Text = "∞ unlimited speed • instant response"
badgeText.TextColor3 = PrimaryColor
badgeText.Font = Enum.Font.Gotham
badgeText.TextSize = 11

-- ========== JUMP BUTTON ==========
local jumpBtn = Instance.new("TextButton", contentCanvas)
jumpBtn.Size = UDim2.new(0.92, 0, 0, 44)
jumpBtn.Text = "💨 jump boost"
jumpBtn.Font = Enum.Font.GothamBold
jumpBtn.TextSize = 14
jumpBtn.BackgroundColor3 = Color3.fromRGB(45, 55, 75)
jumpBtn.TextColor3 = Color3.new(1, 1, 1)
jumpBtn.BorderSizePixel = 0

local jumpCorner = Instance.new("UICorner", jumpBtn)
jumpCorner.CornerRadius = UDim.new(0, 12)

addHover(jumpBtn, Color3.fromRGB(65, 75, 95))

-- ========== INFO NOTE ==========
local noteContainer = Instance.new("Frame", contentCanvas)
noteContainer.Size = UDim2.new(0.92, 0, 0, 0)
noteContainer.BackgroundColor3 = Color3.fromRGB(28, 26, 36)
noteContainer.BackgroundTransparency = 0.3
noteContainer.BorderSizePixel = 0

local noteCorner = Instance.new("UICorner", noteContainer)
noteCorner.CornerRadius = UDim.new(0, 12)

local noteTitle = Instance.new("TextLabel", noteContainer)
noteTitle.Size = UDim2.new(1, -16, 0, 24)
noteTitle.Position = UDim2.new(0, 8, 0, 6)
noteTitle.BackgroundTransparency = 1
noteTitle.Text = "📋 info"
noteTitle.TextColor3 = PrimaryColor
noteTitle.Font = Enum.Font.GothamBold
noteTitle.TextSize = 11
noteTitle.TextXAlignment = Enum.TextXAlignment.Left

local noteText = Instance.new("TextLabel", noteContainer)
noteText.Size = UDim2.new(1, -16, 0, 0)
noteText.Position = UDim2.new(0, 8, 0, 32)
noteText.BackgroundTransparency = 1
noteText.Text = "• sit in vehicle to start\n•Work all game\n• Fiqqzr7xAnonymous9x build this script"
noteText.TextColor3 = SoftGray
noteText.Font = Enum.Font.Gotham
noteText.TextSize = 10
noteText.TextXAlignment = Enum.TextXAlignment.Left
noteText.TextYAlignment = Enum.TextYAlignment.Top
noteText.LineHeight = 1.2

local function updateNoteHeight()
    local lineCount = 4
    noteText.Size = UDim2.new(1, -16, 0, lineCount * 14)
    noteContainer.Size = UDim2.new(0.92, 0, 0, 32 + (lineCount * 14) + 8)
end
updateNoteHeight()

-- ========== START BUTTON ==========
local toggleBtn = Instance.new("TextButton", contentCanvas)
toggleBtn.Size = UDim2.new(0.92, 0, 0, 50)
toggleBtn.Text = "start"
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 16
toggleBtn.BackgroundColor3 = Color3.fromRGB(220, 60, 70)
toggleBtn.TextColor3 = Color3.new(1, 1, 1)
toggleBtn.BorderSizePixel = 0

local toggleCorner = Instance.new("UICorner", toggleBtn)
toggleCorner.CornerRadius = UDim.new(0, 14)

addHover(toggleBtn, Color3.fromRGB(240, 80, 90))

-- Update Canvas
local function updateCanvas()
    local totalHeight = 0
    for _, child in pairs(contentCanvas:GetChildren()) do
        if child:IsA("Frame") or child:IsA("TextButton") then
            totalHeight = totalHeight + child.Size.Y.Offset + 8
        end
    end
    contentCanvas.Size = UDim2.new(1, 0, 0, totalHeight + 15)
    scrollContainer.CanvasSize = UDim2.new(0, 0, 0, totalHeight + 15)
end

-- Update Slider
local function updateSlider()
    local percent
    if targetSpeed <= 1000 then
        percent = (targetSpeed - 1) / 999
    elseif targetSpeed <= 10000 then
        percent = 0.5 + ((targetSpeed - 1000) / 9000) * 0.5
    else
        percent = math.min(1, 0.75 + math.log10(targetSpeed / 10000) / 10)
    end
    percent = math.clamp(percent, 0, 1)
    
    TweenService:Create(sliderFill, TweenInfo.new(0.15), {
        Size = UDim2.new(percent, 0, 1, 0)
    }):Play()
    
    if targetSpeed >= 1000000 then
        speedValue.Text = string.format("%.1fM", targetSpeed / 1000000)
    elseif targetSpeed >= 1000 then
        speedValue.Text = string.format("%.0fk", targetSpeed / 1000)
    else
        speedValue.Text = tostring(targetSpeed)
    end
    
    if enabled and rootPart then
        appliedSpeed = targetSpeed
    end
end

-- Speed Input
speedInput.FocusLost:Connect(function()
    local v = tonumber(speedInput.Text)
    if v and v >= 1 then
        targetSpeed = math.floor(v)
        updateSlider()
        if enabled then
            showMiniNotification("⚡ speed changed to " .. (targetSpeed >= 1000000 and string.format("%.1fM", targetSpeed/1000000) or (targetSpeed >= 1000 and string.format("%.0fk", targetSpeed/1000) or tostring(targetSpeed))) .. " km/h", "success")
        end
    elseif v and v < 1 then
        targetSpeed = 1
        updateSlider()
    else
        targetSpeed = 500
        updateSlider()
    end
    speedInput.Text = tostring(targetSpeed)
end)

-- Toggle Logic
toggleBtn.MouseButton1Click:Connect(function()
    enabled = not enabled
    if enabled then
        seat = getSeat()
        if seat then
            rootPart = getCarRoot(seat)
            if rootPart then
                appliedSpeed = targetSpeed
                toggleBtn.Text = "stop"
                toggleBtn.BackgroundColor3 = Color3.fromRGB(70, 150, 90)
                statusDot.BackgroundColor3 = Color3.fromRGB(100, 220, 120)
                statusText.Text = "active"
                statusText.TextColor3 = Color3.fromRGB(100, 220, 120)
                showMiniNotification("✓ active • " .. (targetSpeed >= 1000000 and string.format("%.1fM", targetSpeed/1000000) or (targetSpeed >= 1000 and string.format("%.0fk", targetSpeed/1000) or tostring(targetSpeed))) .. " km/h", "success")
            else
                enabled = false
                toggleBtn.Text = "start"
                toggleBtn.BackgroundColor3 = Color3.fromRGB(220, 60, 70)
                statusDot.BackgroundColor3 = Color3.fromRGB(200, 80, 80)
                statusText.Text = "no car"
                statusText.TextColor3 = Color3.fromRGB(200, 120, 120)
                showMiniNotification("⚠ no vehicle detected", "error")
            end
        else
            enabled = false
            toggleBtn.Text = "start"
            toggleBtn.BackgroundColor3 = Color3.fromRGB(220, 60, 70)
            statusDot.BackgroundColor3 = Color3.fromRGB(220, 160, 80)
            statusText.Text = "sit"
            statusText.TextColor3 = Color3.fromRGB(220, 180, 100)
            showMiniNotification("⚠ please sit in vehicle", "warning")
        end
    else
        toggleBtn.Text = "start"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(220, 60, 70)
        statusDot.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
        statusText.Text = "off"
        statusText.TextColor3 = SoftGray
        showMiniNotification("⏹ system stopped", "warning")
    end
end)

-- Jump
jumpBtn.MouseButton1Click:Connect(function()
    if rootPart then
        local boostMultiplier = math.min(targetSpeed / 100, 50)
        local jumpForce = Vector3.new(0, 650 * (1 + boostMultiplier * 0.1), 0)
        local forwardBoost = rootPart.CFrame.LookVector * (400 + targetSpeed * 2)
        rootPart:ApplyImpulse((jumpForce + forwardBoost) * rootPart.AssemblyMass / 10)
        
        TweenService:Create(jumpBtn, TweenInfo.new(0.08), {BackgroundColor3 = Color3.fromRGB(85, 95, 115)}):Play()
        task.wait(0.08)
        TweenService:Create(jumpBtn, TweenInfo.new(0.08), {BackgroundColor3 = Color3.fromRGB(45, 55, 75)}):Play()
        
        showMiniNotification("💨 jump boost • " .. (targetSpeed >= 1000000 and string.format("%.1fM", targetSpeed/1000000) or (targetSpeed >= 1000 and string.format("%.0fk", targetSpeed/1000) or tostring(targetSpeed))) .. " km/h power", "success")
    else
        showMiniNotification("⚠ no vehicle to jump", "error")
    end
end)

-- Minimize
local minimized = false
minBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    scrollContainer.Visible = not minimized
    frame.Size = minimized and UDim2.fromOffset(280, 60) or UDim2.fromOffset(280, 380)
    if not minimized then
        updateCanvas()
    end
end)

-- Close (tanpa mini icon)
closeBtn.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

-- Seat Detection
hum:GetPropertyChangedSignal("SeatPart"):Connect(function()
    seat = getSeat()
    if seat then
        rootPart = getCarRoot(seat)
        if not enabled then
            statusText.Text = "ready"
            statusText.TextColor3 = Color3.fromRGB(120, 180, 220)
            statusDot.BackgroundColor3 = Color3.fromRGB(120, 180, 220)
            showMiniNotification("✓ vehicle ready", "success")
        end
    else
        rootPart = nil
        if not enabled then
            statusText.Text = "off"
            statusText.TextColor3 = SoftGray
            statusDot.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
        end
    end
end)

hum.Died:Connect(function()
    enabled = false
    toggleBtn.Text = "start"
    toggleBtn.BackgroundColor3 = Color3.fromRGB(220, 60, 70)
    statusText.Text = "died"
    statusText.TextColor3 = Color3.fromRGB(220, 100, 100)
    statusDot.BackgroundColor3 = Color3.fromRGB(220, 100, 100)
    showMiniNotification("⚠ respawn to continue", "error")
end)

player.CharacterAdded:Connect(function(newChar)
    char = newChar
    hum = newChar:WaitForChild("Humanoid")
    enabled = false
    appliedSpeed = 0
    toggleBtn.Text = "start"
    toggleBtn.BackgroundColor3 = Color3.fromRGB(220, 60, 70)
    statusText.Text = "off"
    statusText.TextColor3 = SoftGray
    statusDot.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    updateSlider()
    updateCanvas()
end)

-- Title animation
task.spawn(function()
    local h = 0
    while titleText.Parent do
        h = (h + 0.003) % 1
        titleText.TextColor3 = Color3.fromHSV(h, 0.5, 1)
        task.wait(0.1)
    end
end)

updateCanvas()
updateSlider()

print(" FIQQZR7 x Anonymous9x FARM • Clean Edition")
print(" Quick buttons removed • Mini icon removed")
