-- ANONYMOUS9X PROJECT v3 - MOBILE FRIENDLY
-- Created by: Anonymus9x
-- Size: 320x480 (Perfect for Mobile)

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

-- MAIN GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Anon9xGUI"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = Player:WaitForChild("PlayerGui")

-- MAIN FRAME
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 320, 0, 480) -- Mobile size
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -240)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(255, 105, 180)
UIStroke.Thickness = 2
UIStroke.Parent = MainFrame

-- HEADER (Dragable)
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 45)
Header.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
Header.BorderSizePixel = 0

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 12)
HeaderCorner.Parent = Header

-- TITLE
local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(0.6, 0, 1, 0)
Title.Position = UDim2.new(0.05, 0, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "ANONYMOUS9X"
Title.TextColor3 = Color3.fromRGB(255, 105, 180)
Title.TextSize = 16
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left

-- SUBTITLE
local SubTitle = Instance.new("TextLabel")
SubTitle.Name = "SubTitle"
SubTitle.Size = UDim2.new(0.6, 0, 0, 15)
SubTitle.Position = UDim2.new(0.05, 0, 0.6, 0)
SubTitle.BackgroundTransparency = 1
SubTitle.Text = "PROJECT v3"
SubTitle.TextColor3 = Color3.fromRGB(200, 200, 220)
SubTitle.TextSize = 10
SubTitle.Font = Enum.Font.Gotham
SubTitle.TextXAlignment = Enum.TextXAlignment.Left

-- CLOSE BUTTON
local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(0.9, 0, 0.5, -15)
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
CloseButton.Text = "✕"
CloseButton.TextColor3 = Color3.white
CloseButton.TextSize = 14
CloseButton.Font = Enum.Font.GothamBold

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(1, 0)
CloseCorner.Parent = CloseButton

-- MINIMIZE BUTTON
local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Name = "MinimizeButton"
MinimizeButton.Size = UDim2.new(0, 30, 0, 30)
MinimizeButton.Position = UDim2.new(0.8, 0, 0.5, -15)
MinimizeButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
MinimizeButton.Text = "─"
MinimizeButton.TextColor3 = Color3.white
MinimizeButton.TextSize = 14
MinimizeButton.Font = Enum.Font.GothamBold

local MinimizeCorner = Instance.new("UICorner")
MinimizeCorner.CornerRadius = UDim.new(1, 0)
MinimizeCorner.Parent = MinimizeButton

-- TABS
local TabsFrame = Instance.new("Frame")
TabsFrame.Name = "TabsFrame"
TabsFrame.Size = UDim2.new(1, -20, 0, 40)
TabsFrame.Position = UDim2.new(0, 10, 0, 50)
TabsFrame.BackgroundTransparency = 1

local Tabs = {"Main", "Visual", "Player", "World", "Fun"}
local TabButtons = {}

for i, tabName in ipairs(Tabs) do
    local TabButton = Instance.new("TextButton")
    TabButton.Name = tabName .. "Tab"
    TabButton.Size = UDim2.new(0.18, 0, 0.8, 0)
    TabButton.Position = UDim2.new(0.02 + (i-1)*0.195, 0, 0.1, 0)
    TabButton.Text = tabName
    TabButton.BackgroundColor3 = i == 1 and Color3.fromRGB(255, 105, 180) or Color3.fromRGB(50, 50, 70)
    TabButton.TextColor3 = Color3.white
    TabButton.TextSize = 11
    TabButton.Font = Enum.Font.GothamBold
    
    local TabCorner = Instance.new("UICorner")
    TabCorner.CornerRadius = UDim.new(0, 8)
    TabCorner.Parent = TabButton
    
    TabButton.Parent = TabsFrame
    TabButtons[tabName] = TabButton
end

-- CONTENT FRAME
local ContentFrame = Instance.new("ScrollingFrame")
ContentFrame.Name = "ContentFrame"
ContentFrame.Size = UDim2.new(1, -20, 1, -120)
ContentFrame.Position = UDim2.new(0, 10, 0, 100)
ContentFrame.BackgroundTransparency = 1
ContentFrame.ScrollBarThickness = 4
ContentFrame.ScrollBarImageColor3 = Color3.fromRGB(255, 105, 180)
ContentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)

local ContentLayout = Instance.new("UIListLayout")
ContentLayout.Padding = UDim.new(0, 8)
ContentLayout.Parent = ContentFrame

-- ASSEMBLE GUI
SubTitle.Parent = Header
Title.Parent = Header
MinimizeButton.Parent = Header
CloseButton.Parent = Header
Header.Parent = MainFrame
TabsFrame.Parent = MainFrame
ContentFrame.Parent = MainFrame
MainFrame.Parent = ScreenGui

-- DRAGGING FUNCTION
local dragging = false
local dragStart, startPos

Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

-- MINIMIZE FUNCTION
local minimized = false
local originalSize = MainFrame.Size
local minimizedSize = UDim2.new(0, 320, 0, 45)

MinimizeButton.MouseButton1Click:Connect(function()
    if not minimized then
        TweenService:Create(MainFrame, TweenInfo.new(0.3), {Size = minimizedSize}):Play()
        TabsFrame.Visible = false
        ContentFrame.Visible = false
        minimized = true
        MinimizeButton.Text = "+"
    else
        TweenService:Create(MainFrame, TweenInfo.new(0.3), {Size = originalSize}):Play()
        TabsFrame.Visible = true
        ContentFrame.Visible = true
        minimized = false
        MinimizeButton.Text = "─"
    end
end)

-- CLOSE BUTTON
CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- BUTTON HOVER EFFECT
local function setupButtonHover(button)
    local originalColor = button.BackgroundColor3
    
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(
                math.min(255, originalColor.R * 255 + 30),
                math.min(255, originalColor.G * 255 + 30),
                math.min(255, originalColor.B * 255 + 30)
            )
        }):Play()
    end)
    
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {
            BackgroundColor3 = originalColor
        }):Play()
    end)
end

setupButtonHover(CloseButton)
setupButtonHover(MinimizeButton)
for _, btn in pairs(TabButtons) do
    setupButtonHover(btn)
end

-- CREATE FEATURE BUTTON
local function createButton(text, color)
    local Button = Instance.new("TextButton")
    Button.Name = text .. "Btn"
    Button.Size = UDim2.new(1, -10, 0, 42) -- Bigger for mobile
    Button.BackgroundColor3 = color
    Button.Text = text
    Button.TextColor3 = Color3.white
    Button.TextSize = 13
    Button.Font = Enum.Font.GothamBold
    
    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 8)
    ButtonCorner.Parent = Button
    
    setupButtonHover(Button)
    
    return Button
end

-- CLEAR CONTENT
local function clearContent()
    for _, child in ipairs(ContentFrame:GetChildren()) do
        if child:IsA("GuiObject") then
            child:Destroy()
        end
    end
end

-- MAIN TAB
local function loadMainTab()
    clearContent()
    
    -- FLY
    local FlyBtn = createButton("🚀 FLY", Color3.fromRGB(65, 105, 225))
    FlyBtn.Parent = ContentFrame
    
    -- NO CLIP
    local NoclipBtn = createButton("👻 NO CLIP", Color3.fromRGB(138, 43, 226))
    NoclipBtn.Parent = ContentFrame
    
    -- SPEED
    local SpeedBtn = createButton("⚡ SPEED HACK", Color3.fromRGB(255, 140, 0))
    SpeedBtn.Parent = ContentFrame
    
    -- HIGH JUMP
    local JumpBtn = createButton("🦘 HIGH JUMP", Color3.fromRGB(34, 139, 34))
    JumpBtn.Parent = ContentFrame
    
    -- INFINITE JUMP
    local InfJumpBtn = createButton("∞ INFINITE JUMP", Color3.fromRGB(0, 191, 255))
    InfJumpBtn.Parent = ContentFrame
    
    -- ANTI-AFK
    local AntiAFKBtn = createButton("⏰ ANTI-AFK", Color3.fromRGB(100, 149, 237))
    AntiAFKBtn.Parent = ContentFrame
    
    ContentFrame.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y)
end

-- VISUAL TAB (ANTI VISUAL)
local function loadVisualTab()
    clearContent()
    
    -- LASER SHOW (KELAP-KELIP)
    local LaserBtn = createButton("🌈 LASER SHOW", Color3.fromRGB(255, 0, 255))
    LaserBtn.Parent = ContentFrame
    
    -- FULLBRIGHT
    local BrightBtn = createButton("💡 FULLBRIGHT", Color3.fromRGB(255, 215, 0))
    BrightBtn.Parent = ContentFrame
    
    -- X-RAY VISION
    local XrayBtn = createButton("🔍 X-RAY VISION", Color3.fromRGB(105, 105, 105))
    XrayBtn.Parent = ContentFrame
    
    -- CHAMS
    local ChamsBtn = createButton("👤 PLAYER CHAMS", Color3.fromRGB(148, 0, 211))
    ChamsBtn.Parent = ContentFrame
    
    -- ESP
    local ESPBtn = createButton("👁️ ESP", Color3.fromRGB(50, 205, 50))
    ESPBtn.Parent = ContentFrame
    
    -- NIGHT VISION
    local NightBtn = createButton("🌙 NIGHT VISION", Color3.fromRGB(0, 0, 139))
    NightBtn.Parent = ContentFrame
    
    ContentFrame.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y)
end

-- PLAYER TAB
local function loadPlayerTab()
    clearContent()
    
    -- TP TO PLAYER
    local TPBtn = createButton("📍 TP TO PLAYER", Color3.fromRGB(0, 206, 209))
    TPBtn.Parent = ContentFrame
    
    -- BRING PLAYER
    local BringBtn = createButton("📦 BRING PLAYER", Color3.fromRGB(255, 69, 0))
    BringBtn.Parent = ContentFrame
    
    -- KILL ALL
    local KillBtn = createButton("💀 KILL ALL", Color3.fromRGB(220, 20, 60))
    KillBtn.Parent = ContentFrame
    
    -- FREEZE ALL
    local FreezeBtn = createButton("❄️ FREEZE ALL", Color3.fromRGB(135, 206, 235))
    FreezeBtn.Parent = ContentFrame
    
    -- AIMBOT
    local AimBtn = createButton("🎯 AIMBOT", Color3.fromRGB(255, 0, 0))
    AimBtn.Parent = ContentFrame
    
    -- HITBOX EXPANDER
    local HitboxBtn = createButton("📦 HITBOX EXPAND", Color3.fromRGB(255, 165, 0))
    HitboxBtn.Parent = ContentFrame
    
    ContentFrame.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y)
end

-- WORLD TAB
local function loadWorldTab()
    clearContent()
    
    -- BRING PART
    local BringPartBtn = createButton("🧱 BRING PART", Color3.fromRGB(0, 191, 255))
    BringPartBtn.Parent = ContentFrame
    
    -- DELETE PART
    local DeleteBtn = createButton("🗑️ DELETE PART", Color3.fromRGB(255, 99, 71))
    DeleteBtn.Parent = ContentFrame
    
    -- WALK ON WATER
    local WaterBtn = createButton("🌊 WALK ON WATER", Color3.fromRGB(64, 224, 208))
    WaterBtn.Parent = ContentFrame
    
    -- NO FOG
    local FogBtn = createButton("🌫️ NO FOG", Color3.fromRGB(169, 169, 169))
    FogBtn.Parent = ContentFrame
    
    -- FPS BOOST
    local FPSBtn = createButton("⚡ FPS BOOST", Color3.fromRGB(0, 250, 154))
    FPSBtn.Parent = ContentFrame
    
    ContentFrame.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y)
end

-- FUN TAB
local function loadFunTab()
    clearContent()
    
    -- WALK FLING
    local FlingBtn = createButton("🌀 WALK FLING", Color3.fromRGB(255, 20, 147))
    FlingBtn.Parent = ContentFrame
    
    -- SPIN BOT
    local SpinBtn = createButton("🔄 SPIN BOT", Color3.fromRGB(147, 112, 219))
    SpinBtn.Parent = ContentFrame
    
    -- SIZE CHANGER
    local SizeBtn = createButton("📏 SIZE CHANGER", Color3.fromRGB(218, 165, 32))
    SizeBtn.Parent = ContentFrame
    
    -- ANIMATION HACK
    local AnimBtn = createButton("💃 ANIMATION HACK", Color3.fromRGB(199, 21, 133))
    AnimBtn.Parent = ContentFrame
    
    -- GRAVITY HACK
    local GravityBtn = createButton("⬇️ GRAVITY HACK", Color3.fromRGB(70, 130, 180))
    GravityBtn.Parent = ContentFrame
    
    ContentFrame.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y)
end

-- TAB SWITCHING
for tabName, btn in pairs(TabButtons) do
    btn.MouseButton1Click:Connect(function()
        -- Reset all tab colors
        for name, tabBtn in pairs(TabButtons) do
            tabBtn.BackgroundColor3 = name == tabName and Color3.fromRGB(255, 105, 180) or Color3.fromRGB(50, 50, 70)
        end
        
        -- Load tab content
        if tabName == "Main" then
            loadMainTab()
        elseif tabName == "Visual" then
            loadVisualTab()
        elseif tabName == "Player" then
            loadPlayerTab()
        elseif tabName == "World" then
            loadWorldTab()
        elseif tabName == "Fun" then
            loadFunTab()
        end
    end)
end

-- LOAD INITIAL TAB
loadMainTab()

-- NOTIFICATION FUNCTION
local function notify(msg)
    local notif = Instance.new("TextLabel")
    notif.Size = UDim2.new(0, 280, 0, 40)
    notif.Position = UDim2.new(0.5, -140, 1, -50)
    notif.AnchorPoint = Vector2.new(0.5, 1)
    notif.BackgroundColor3 = Color3.fromRGB(255, 105, 180)
    notif.TextColor3 = Color3.white
    notif.Text = "⚠️ " .. msg
    notif.TextSize = 13
    notif.Font = Enum.Font.GothamBold
    notif.Parent = ScreenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = notif
    
    -- Animate in
    notif:TweenPosition(UDim2.new(0.5, -140, 1, -100), "Out", "Quad", 0.3)
    
    wait(2)
    
    -- Animate out
    notif:TweenPosition(UDim2.new(0.5, -140, 1, -50), "In", "Quad", 0.3, true, function()
        notif:Destroy()
    end)
end

-- MOBILE OPTIMIZATION
if UserInputService.TouchEnabled then
    notify("Mobile Mode Activated")
    -- Make buttons even bigger for touch
    for _, btn in pairs(TabButtons) do
        btn.TextSize = 10
    end
end

-- FEATURE IMPLEMENTATIONS
local features = {
    flying = false,
    noclip = false,
    esp = false,
    chams = false
}

-- LASER SHOW FUNCTION (ANTI VISUAL)
local laserActive = false
local laserConnections = {}

local function toggleLaserShow()
    if not laserActive then
        notify("LASER SHOW: ON")
        laserActive = true
        
        local function createLaserBeam(color, startPos, endPos)
            local beam = Instance.new("Part")
            beam.Size = Vector3.new(0.2, 0.2, (startPos - endPos).magnitude)
            beam.CFrame = CFrame.new((startPos + endPos) / 2, endPos)
            beam.Color = color
            beam.Material = Enum.Material.Neon
            beam.Transparency = 0.3
            beam.Anchored = true
            beam.CanCollide = false
            beam.Parent = workspace
            
            game:GetService("Debris"):AddItem(beam, 0.1)
            return beam
        end
        
        -- Laser colors
        local colors = {
            Color3.fromRGB(255, 0, 0),
            Color3.fromRGB(0, 255, 0),
            Color3.fromRGB(0, 0, 255),
            Color3.fromRGB(255, 255, 0),
            Color3.fromRGB(255, 0, 255)
        }
        
        -- Create laser effect loop
        table.insert(laserConnections, RunService.Heartbeat:Connect(function()
            if not laserActive then return end
            
            for i = 1, 5 do
                local startPos = Vector3.new(
                    math.random(-50, 50),
                    math.random(10, 50),
                    math.random(-50, 50)
                )
                
                local endPos = Vector3.new(
                    math.random(-100, 100),
                    math.random(0, 100),
                    math.random(-100, 100)
                )
                
                createLaserBeam(colors[math.random(1, #colors)], startPos, endPos)
            end
            
            -- Flash screen effect
            if Player.Character then
                local root = Player.Character:FindFirstChild("HumanoidRootPart")
                if root then
                    local flash = Instance.new("Part")
                    flash.Size = Vector3.new(100, 100, 100)
                    flash.Position = root.Position
                    flash.Color = colors[math.random(1, #colors)]
                    flash.Material = Enum.Material.Neon
                    flash.Transparency = 0.8
                    flash.Anchored = true
                    flash.CanCollide = false
                    flash.Parent = workspace
                    
                    game:GetService("Debris"):AddItem(flash, 0.05)
                end
            end
        end))
        
    else
        notify("LASER SHOW: OFF")
        laserActive = false
        -- Clean up connections
        for _, conn in ipairs(laserConnections) do
            conn:Disconnect()
        end
        laserConnections = {}
    end
end

-- FLY FUNCTION
local function toggleFly()
    if not features.flying then
        notify("FLY: ON (WASD + Space/Shift)")
        features.flying = true
        
        local bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.Name = "FlyVelocity"
        bodyVelocity.Parent = Player.Character.HumanoidRootPart
        bodyVelocity.MaxForce = Vector3.new(0, 0, 0)
        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        
        table.insert(laserConnections, RunService.Heartbeat:Connect(function()
            if features.flying and Player.Character then
                local root = Player.Character.HumanoidRootPart
                if root then
                    local newVelocity = Vector3.new(0, 0, 0)
                    
                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                        newVelocity = newVelocity + (root.CFrame.LookVector * 50)
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                        newVelocity = newVelocity + (root.CFrame.LookVector * -50)
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                        newVelocity = newVelocity + (root.CFrame.RightVector * -50)
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                        newVelocity = newVelocity + (root.CFrame.RightVector * 50)
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                        newVelocity = newVelocity + Vector3.new(0, 50, 0)
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                        newVelocity = newVelocity + Vector3.new(0, -50, 0)
                    end
                    
                    bodyVelocity.Velocity = newVelocity
                end
            end
        end))
    else
        notify("FLY: OFF")
        features.flying = false
        if Player.Character and Player.Character.HumanoidRootPart:FindFirstChild("FlyVelocity") then
            Player.Character.HumanoidRootPart.FlyVelocity:Destroy()
        end
    end
end

-- NO CLIP FUNCTION
local function toggleNoclip()
    features.noclip = not features.noclip
    if features.noclip then
        notify("NO CLIP: ON")
        table.insert(laserConnections, RunService.Stepped:Connect(function()
            if Player.Character then
                for _, part in pairs(Player.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end))
    else
        notify("NO CLIP: OFF")
    end
end

-- ESP FUNCTION
local function toggleESP()
    features.esp = not features.esp
    if features.esp then
        notify("ESP: ON")
        for _, otherPlayer in ipairs(Players:GetPlayers()) do
            if otherPlayer ~= Player and otherPlayer.Character then
                local highlight = Instance.new("Highlight")
                highlight.Name = "ESP_Highlight"
                highlight.FillColor = Color3.fromRGB(255, 0, 0)
                highlight.OutlineColor = Color3.fromRGB(255, 255, 0)
                highlight.FillTransparency = 0.5
                highlight.Parent = otherPlayer.Character
            end
        end
    else
        notify("ESP: OFF")
        for _, otherPlayer in ipairs(Players:GetPlayers()) do
            if otherPlayer.Character then
                local highlight = otherPlayer.Character:FindFirstChild("ESP_Highlight")
                if highlight then
                    highlight:Destroy()
                end
            end
        end
    end
end

-- FULLBRIGHT
local function toggleFullbright()
    local lighting = game:GetService("Lighting")
    lighting.Ambient = Color3.new(1, 1, 1)
    lighting.Brightness = 2
    lighting.GlobalShadows = false
    notify("FULLBRIGHT: ON")
end

-- BRING PART FUNCTION
local function bringPart()
    local target = Mouse.Target
    if target then
        local char = Player.Character
        if char and char.HumanoidRootPart then
            target.Position = char.HumanoidRootPart.Position + Vector3.new(0, 5, 0)
            notify("PART BROUGHT")
        end
    else
        notify("CLICK ON A PART FIRST")
    end
end

-- WALK FLING FUNCTION
local walkFlingActive = false
local function toggleWalkFling()
    walkFlingActive = not walkFlingActive
    if walkFlingActive then
        notify("WALK FLING: ON (Walk to fling)")
        table.insert(laserConnections, Player.Character.Humanoid:GetPropertyChangedSignal("MoveDirection"):Connect(function()
            if Player.Character.Humanoid.MoveDirection.Magnitude > 0 then
                local root = Player.Character.HumanoidRootPart
                local bv = Instance.new("BodyVelocity")
                bv.Velocity = root.CFrame.LookVector * 100 + Vector3.new(0, 50, 0)
                bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                bv.Parent = root
                game:GetService("Debris"):AddItem(bv, 0.1)
            end
        end))
    else
        notify("WALK FLING: OFF")
    end
end

-- CONNECT BUTTONS TO FUNCTIONS
local function connectButton(buttonName, func)
    -- Wait for button to exist
    local button
    repeat
        for _, child in ipairs(ContentFrame:GetChildren()) do
            if child.Name == buttonName then
                button = child
                break
            end
        end
        wait()
    until button
    
    button.MouseButton1Click:Connect(func)
end

-- Auto-connect buttons when tabs load
coroutine.wrap(function()
    while wait(0.5) do
        if ScreenGui.Parent then
            -- Main tab buttons
            if ContentFrame:FindFirstChild("🚀 FLYBtn") then
                ContentFrame["🚀 FLYBtn"].MouseButton1Click:Connect(toggleFly)
            end
            if ContentFrame:FindFirstChild("👻 NO CLIPBtn") then
                ContentFrame["👻 NO CLIPBtn"].MouseButton1Click:Connect(toggleNoclip)
                end
         -- Visual tab buttons
            if ContentFrame:FindFirstChild("🌈 LASER SHOWBtn") then
                ContentFrame["🌈 LASER SHOWBtn"].MouseButton1Click:Connect(toggleLaserShow)
            end
            if ContentFrame:FindFirstChild("👁️ ESPBtn") then
                ContentFrame["👁️ ESPBtn"].MouseButton1Click:Connect(toggleESP)
            end
            if ContentFrame:FindFirstChild("💡 FULLBRIGHTBtn") then
                ContentFrame["💡 FULLBRIGHTBtn"].MouseButton1Click:Connect(toggleFullbright)
            end
            
            -- World tab buttons
            if ContentFrame:FindFirstChild("🧱 BRING PARTBtn") then
                ContentFrame["🧱 BRING PARTBtn"].MouseButton1Click:Connect(bringPart)
            end
            
            -- Fun tab buttons
            if ContentFrame:FindFirstChild("🌀 WALK FLINGBtn") then
                ContentFrame["🌀 WALK FLINGBtn"].MouseButton1Click:Connect(toggleWalkFling)
            end
        end
    end
end)()

-- INITIAL NOTIFICATION
wait(1)
notify("ANONYMOUS9X PROJECT LOADED!")

print("[ANON9X] GUI Successfully Loaded!")
```       

