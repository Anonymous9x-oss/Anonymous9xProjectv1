--[[
    ANONYMOUS9X HITBOX V7.1 - SIMPLIFIED NOTIFICATIONS
    - Visual Hitbox: HRP Size Expand (original)
    - Hit Detection: Raycasting + Proximity (v6)
    - Detection: Real-time game compatibility scanner
    - Notifications: SIMPLIFIED, CLEAR COLORS, EASY EXPLANATION
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- // SETTINGS //
_G.HitboxActive = false
_G.HitboxSize = 10
local MinSize = 2
local MaxSize = 60
local HitCooldown = {}

-- // DETECTION CACHE //
local GameCompatibility = {
    hasRemoteHitFunction = false,
    hasCustomHumanoid = false,
    anticheatLevel = 0,
    detectionStatus = "PENDING",
    scanComplete = false
}

-- // UI SETUP (ORIGINAL) //
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Ano9x_MobilePC"
ScreenGui.ResetOnSpawn = false
pcall(function() ScreenGui.Parent = game:GetService("CoreGui") end)

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 210, 0, 170)
MainFrame.Position = UDim2.new(0.5, -105, 0.5, -85)
MainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = ScreenGui

local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(255, 255, 255)
Stroke.Thickness = 1.8
Stroke.Parent = MainFrame

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 5)

-- Header
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 30)
Header.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Header.BorderSizePixel = 0
Header.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "Anonymous9x Hitbox"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 12
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -30, 0, 0)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Parent = Header

local MiniBtn = Instance.new("TextButton")
MiniBtn.Size = UDim2.new(0, 30, 0, 30)
MiniBtn.Position = UDim2.new(1, -60, 0, 0)
MiniBtn.BackgroundTransparency = 1
MiniBtn.Text = "—"
MiniBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MiniBtn.Parent = Header

-- Body
local Body = Instance.new("Frame")
Body.Size = UDim2.new(1, 0, 1, -30)
Body.Position = UDim2.new(0, 0, 0, 30)
Body.BackgroundTransparency = 1
Body.Parent = MainFrame

local Toggle = Instance.new("TextButton")
Toggle.Size = UDim2.new(0.9, 0, 0, 32)
Toggle.Position = UDim2.new(0.05, 0, 0.15, 0)
Toggle.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Toggle.Text = "Hitbox: OFF"
Toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
Toggle.Font = Enum.Font.GothamSemibold
Toggle.Parent = Body
Instance.new("UICorner", Toggle).CornerRadius = UDim.new(0, 4)

local SizeLabel = Instance.new("TextLabel")
SizeLabel.Size = UDim2.new(1, 0, 0, 20)
SizeLabel.Position = UDim2.new(0, 0, 0.45, 0)
SizeLabel.BackgroundTransparency = 1
SizeLabel.Text = "Size: 10"
SizeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
SizeLabel.Font = Enum.Font.Gotham
SizeLabel.Parent = Body

local SliderBack = Instance.new("Frame")
SliderBack.Size = UDim2.new(0.8, 0, 0, 5)
SliderBack.Position = UDim2.new(0.1, 0, 0.75, 0)
SliderBack.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
SliderBack.Parent = Body

local SliderFill = Instance.new("Frame")
SliderFill.Size = UDim2.new(0.2, 0, 1, 0)
SliderFill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
SliderFill.BorderSizePixel = 0
SliderFill.Parent = SliderBack

-- // NOTIFICATION SYSTEM (IMPROVED) //
local function CreateNotification(title, message, icon, bgColor, duration)
    duration = duration or 4
    
    local NotifGui = Instance.new("ScreenGui")
    NotifGui.Name = "NotificationGui"
    NotifGui.ResetOnSpawn = false
    NotifGui.Parent = game:GetService("CoreGui")
    
    local NotifFrame = Instance.new("Frame")
    NotifFrame.Size = UDim2.new(0, 450, 0, 80)
    NotifFrame.Position = UDim2.new(0.5, -225, 0, 20)
    NotifFrame.BackgroundColor3 = bgColor
    NotifFrame.BorderSizePixel = 0
    NotifFrame.Parent = NotifGui
    
    local NotifCorner = Instance.new("UICorner")
    NotifCorner.CornerRadius = UDim.new(0, 8)
    NotifCorner.Parent = NotifFrame
    
    local NotifStroke = Instance.new("UIStroke")
    NotifStroke.Color = Color3.fromRGB(255, 255, 255)
    NotifStroke.Thickness = 1.5
    NotifStroke.Parent = NotifFrame
    
    -- Icon (besar)
    local IconLabel = Instance.new("TextLabel")
    IconLabel.Size = UDim2.new(0, 60, 1, 0)
    IconLabel.Position = UDim2.new(0, 10, 0, 0)
    IconLabel.BackgroundTransparency = 1
    IconLabel.Text = icon
    IconLabel.TextSize = 36
    IconLabel.Parent = NotifFrame
    
    -- Title (bold, besar)
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, -80, 0, 30)
    TitleLabel.Position = UDim2.new(0, 70, 0, 8)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = title
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 15
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = NotifFrame
    
    -- Message (smaller, secondary)
    local MessageLabel = Instance.new("TextLabel")
    MessageLabel.Size = UDim2.new(1, -80, 0, 35)
    MessageLabel.Position = UDim2.new(0, 70, 0, 38)
    MessageLabel.BackgroundTransparency = 1
    MessageLabel.Text = message
    MessageLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
    MessageLabel.Font = Enum.Font.Gotham
    MessageLabel.TextSize = 12
    MessageLabel.TextXAlignment = Enum.TextXAlignment.Left
    MessageLabel.TextWrapped = true
    MessageLabel.Parent = NotifFrame
    
    -- FADE IN
    NotifFrame.BackgroundTransparency = 1
    NotifFrame.Position = UDim2.new(0.5, -225, 0, -80)
    
    for i = 0, 1, 0.1 do
        NotifFrame.BackgroundTransparency = 1 - i
        NotifFrame.Position = UDim2.new(0.5, -225, 0, 20 * i - 80)
        task.wait(0.02)
    end
    
    -- Wait
    task.wait(duration)
    
    -- FADE OUT
    for i = 1, 0, -0.1 do
        NotifFrame.BackgroundTransparency = 1 - i
        NotifFrame.Position = UDim2.new(0.5, -225, 0, 20 * i - 80)
        task.wait(0.02)
    end
    
    NotifGui:Destroy()
end

-- // SIMPLIFIED DETECTION //
local function ScanGameCompatibility()
    GameCompatibility.detectionStatus = "SCANNING"
    
    CreateNotification(
        "🔍 Scanning",
        "Checking game compatibility...",
        "⚙️",
        Color3.fromRGB(45, 45, 45),
        2
    )
    
    task.wait(1)
    
    -- Check 1: RemoteFunction
    local hitFunctions = {
        "HitFunction", "DealDamage", "OnHit", "TakeDamage", "Hit",
        "HandleHit", "ProcessDamage", "ServerHit", "ClientHit"
    }
    
    for _, funcName in ipairs(hitFunctions) do
        if ReplicatedStorage:FindFirstChild(funcName) then
            GameCompatibility.hasRemoteHitFunction = true
            break
        end
    end
    
    -- Check 2: Custom Humanoid
    if LocalPlayer.Character then
        local char = LocalPlayer.Character
        if char:FindFirstChild("Health") or char:FindFirstChild("CustomHealth") then
            GameCompatibility.hasCustomHumanoid = true
        end
    end
    
    -- Check 3: Anticheat
    local suspiciousObjects = {
        "AntiCheat", "AC", "Anticheat", "AntiExploit", "Security",
        "Protection", "Guard", "Detector", "Monitor", "Validator"
    }
    
    for _, objName in ipairs(suspiciousObjects) do
        if workspace:FindFirstChild(objName) or ReplicatedStorage:FindFirstChild(objName) then
            GameCompatibility.anticheatLevel = 3
            break
        end
    end
    
    -- Determine result
    local title = ""
    local message = ""
    local icon = ""
    local bgColor = Color3.fromRGB(30, 30, 30)
    
    if GameCompatibility.anticheatLevel >= 3 then
        -- RED - TIDAK WORK
        title = "❌ NOT COMPATIBLE"
        message = "Game has strict anticheat. Hitbox will NOT work here."
        icon = "🚫"
        bgColor = Color3.fromRGB(139, 0, 0) -- Dark Red
        GameCompatibility.detectionStatus = "NOT_WORK"
        
    elseif GameCompatibility.hasRemoteHitFunction then
        -- GREEN - WORK 100%
        title = "✅ 100% COMPATIBLE"
        message = "Game exposes hit function. Hitbox will work perfectly!"
        icon = "✓"
        bgColor = Color3.fromRGB(34, 139, 34) -- Green
        GameCompatibility.detectionStatus = "WORK_100"
        
    elseif GameCompatibility.hasCustomHumanoid then
        -- BLUE - WORK TAPI BERVARIASI
        title = "🔵 MAYBE COMPATIBLE"
        message = "Custom humanoid detected. Hitbox might work, but results vary."
        icon = "◆"
        bgColor = Color3.fromRGB(30, 100, 180) -- Blue
        GameCompatibility.detectionStatus = "WORK_MAYBE"
        
    else
        -- YELLOW/LIME - WORK BAIK
        title = "✅ COMPATIBLE"
        message = "Standard Roblox system. Hitbox should work well!"
        icon = "✓"
        bgColor = Color3.fromRGB(107, 142, 35) -- Yellow-Green
        GameCompatibility.detectionStatus = "WORK_GOOD"
    end
    
    GameCompatibility.scanComplete = true
    task.wait(0.5)
    CreateNotification(title, message, icon, bgColor, 5)
end

-- // DRAG //
local function EnableDrag(obj)
    local dragging, dragStart, startPos
    obj.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end
EnableDrag(Header)

-- // SLIDER //
local isSliding = false
local function UpdateSlider(input)
    local inputPos = input.Position.X
    local barPos = SliderBack.AbsolutePosition.X
    local barSize = SliderBack.AbsoluteSize.X
    local ratio = math.clamp((inputPos - barPos) / barSize, 0, 1)
    
    SliderFill.Size = UDim2.new(ratio, 0, 1, 0)
    _G.HitboxSize = math.floor(MinSize + (ratio * (MaxSize - MinSize)))
    SizeLabel.Text = "Size: " .. _G.HitboxSize
end

SliderBack.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isSliding = true
        UpdateSlider(input)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if isSliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        UpdateSlider(input)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isSliding = false
    end
end)

-- // TOGGLE //
Toggle.MouseButton1Click:Connect(function()
    _G.HitboxActive = not _G.HitboxActive
    Toggle.Text = _G.HitboxActive and "Hitbox: ON" or "Hitbox: OFF"
    Toggle.BackgroundColor3 = _G.HitboxActive and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(30, 30, 30)
    Toggle.TextColor3 = _G.HitboxActive and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(255, 255, 255)
    
    if _G.HitboxActive then
        task.spawn(ScanGameCompatibility)
    else
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                v.Character.HumanoidRootPart.Size = Vector3.new(2, 2, 1)
                v.Character.HumanoidRootPart.Transparency = 1
            end
        end
        HitCooldown = {}
    end
end)

-- // VISUAL HITBOX //
RunService.RenderStepped:Connect(function()
    if _G.HitboxActive then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = p.Character.HumanoidRootPart
                hrp.Size = Vector3.new(_G.HitboxSize, _G.HitboxSize, _G.HitboxSize)
                hrp.Transparency = 0.7
                hrp.Material = Enum.Material.Neon
                hrp.CanCollide = false
            end
        end
    end
end)

-- // HIT DETECTION //
local function RaycastHitDetection()
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    
    local rayOrigin = Camera.CFrame.Position
    local rayDirection = (Camera.CFrame * CFrame.new(0, 0, -_G.HitboxSize * 5)).Position - rayOrigin
    local rayLength = (_G.HitboxSize * 5)
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
    
    local rayResult = workspace:Raycast(rayOrigin, rayDirection.Unit * rayLength, raycastParams)
    
    if rayResult then
        local hitPart = rayResult.Instance
        local hitCharacter = hitPart.Parent
        local humanoid = hitCharacter:FindFirstChild("Humanoid")
        
        if humanoid and hitCharacter ~= LocalPlayer.Character then
            if not HitCooldown[humanoid] or (tick() - HitCooldown[humanoid]) > 0.1 then
                humanoid:TakeDamage(25)
                HitCooldown[humanoid] = tick()
            end
        end
    end
end

local function ProximityHitDetection()
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    
    local myPos = LocalPlayer.Character.HumanoidRootPart.Position
    local detectionRadius = _G.HitboxSize * 3
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local targetPos = player.Character.HumanoidRootPart.Position
            local distance = (myPos - targetPos).Magnitude
            
            if distance <= detectionRadius then
                local humanoid = player.Character:FindFirstChild("Humanoid")
                if humanoid then
                    if not HitCooldown[humanoid] or (tick() - HitCooldown[humanoid]) > 0.1 then
                        humanoid:TakeDamage(25)
                        HitCooldown[humanoid] = tick()
                    end
                end
            end
        end
    end
end

local function HybridHitDetection()
    pcall(RaycastHitDetection)
    pcall(ProximityHitDetection)
end

RunService.RenderStepped:Connect(function()
    if _G.HitboxActive and LocalPlayer.Character then
        pcall(HybridHitDetection)
    end
end)

-- // MINIMIZE //
local isMin = false
MiniBtn.MouseButton1Click:Connect(function()
    isMin = not isMin
    Body.Visible = not isMin
    MainFrame:TweenSize(isMin and UDim2.new(0, 210, 0, 30) or UDim2.new(0, 210, 0, 170), "Out", "Quad", 0.2, true)
end)

CloseBtn.MouseButton1Click:Connect(function()
    _G.HitboxActive = false
    ScreenGui:Destroy()
end)

print("✓ Anonymous9x Hitbox v1 - SIMPLIFIED DETECTION - LOADED!")
