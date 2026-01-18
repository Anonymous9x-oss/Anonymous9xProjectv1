--[[
    Anonymous9x Project
    Modern Roblox GUI Panel
    Mobile Friendly dengan fitur lengkap
    Created by: Anonymous9x
]]

-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- Player
local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

-- UI Creation
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Anonymous9xGUI"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.ResetOnSpawn = false

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 350, 0, 400)
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -200)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true

-- Corner for smooth edges
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

-- Shadow effect
local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(40, 40, 50)
UIStroke.Thickness = 2
UIStroke.Parent = MainFrame

-- Header
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
Header.BorderSizePixel = 0

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 8)
HeaderCorner.Parent = Header

-- Title
local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(0, 200, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "Anonymous9x Project"
Title.TextColor3 = Color3.fromRGB(255, 105, 180)
Title.TextSize = 16
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left

-- Close Button
local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -40, 0.5, -15)
CloseButton.AnchorPoint = Vector2.new(1, 0.5)
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.white
CloseButton.TextSize = 14
CloseButton.Font = Enum.Font.GothamBold

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseButton

-- Minimize Button
local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Name = "MinimizeButton"
MinimizeButton.Size = UDim2.new(0, 30, 0, 30)
MinimizeButton.Position = UDim2.new(1, -75, 0.5, -15)
MinimizeButton.AnchorPoint = Vector2.new(1, 0.5)
MinimizeButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
MinimizeButton.Text = "_"
MinimizeButton.TextColor3 = Color3.white
MinimizeButton.TextSize = 14
MinimizeButton.Font = Enum.Font.GothamBold

local MinimizeCorner = Instance.new("UICorner")
MinimizeCorner.CornerRadius = UDim.new(0, 6)
MinimizeCorner.Parent = MinimizeButton

-- Content Frame (Scrollable)
local ContentFrame = Instance.new("ScrollingFrame")
ContentFrame.Name = "ContentFrame"
ContentFrame.Size = UDim2.new(1, -20, 1, -60)
ContentFrame.Position = UDim2.new(0, 10, 0, 50)
ContentFrame.BackgroundTransparency = 1
ContentFrame.ScrollBarThickness = 4
ContentFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 120)
ContentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)

-- Tab Buttons (Mobile Friendly - Horizontal)
local TabContainer = Instance.new("Frame")
TabContainer.Name = "TabContainer"
TabContainer.Size = UDim2.new(1, 0, 0, 40)
TabContainer.Position = UDim2.new(0, 0, 0, 40)
TabContainer.BackgroundTransparency = 1

local Tabs = {"Main", "Movement", "Combat", "Visual", "Misc"}

-- UIListLayout for tabs
local TabLayout = Instance.new("UIListLayout")
TabLayout.FillDirection = Enum.FillDirection.Horizontal
TabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
TabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
TabLayout.Padding = UDim.new(0, 5)
TabLayout.Parent = TabContainer

-- Footer (Mobile Mode Indicator)
local Footer = Instance.new("Frame")
Footer.Name = "Footer"
Footer.Size = UDim2.new(1, 0, 0, 25)
Footer.Position = UDim2.new(0, 0, 1, -25)
Footer.BackgroundColor3 = Color3.fromRGB(20, 20, 30)

local FooterLabel = Instance.new("TextLabel")
FooterLabel.Size = UDim2.new(1, 0, 1, 0)
FooterLabel.BackgroundTransparency = 1
FooterLabel.Text = "Mobile Friendly v1.0"
FooterLabel.TextColor3 = Color3.fromRGB(150, 150, 180)
FooterLabel.TextSize = 12
FooterLabel.Font = Enum.Font.Gotham

-- Assemble UI
FooterLabel.Parent = Footer
Footer.Parent = MainFrame
TabContainer.Parent = MainFrame
MinimizeButton.Parent = Header
CloseButton.Parent = Header
Title.Parent = Header
Header.Parent = MainFrame
ContentFrame.Parent = MainFrame
MainFrame.Parent = ScreenGui
ScreenGui.Parent = Player:WaitForChild("PlayerGui")

-- Variables
local isMinimized = false
local originalSize = MainFrame.Size
local minimizedSize = UDim2.new(0, 350, 0, 40)
local isMobile = false
local dragging = false
local dragInput, dragStart, startPos

-- Check if mobile
if UserInputService.TouchEnabled then
    isMobile = true
    MainFrame.Size = UDim2.new(0, 300, 0, 350) -- Smaller for mobile
    MainFrame.Position = UDim2.new(0.5, -150, 0.5, -175)
end

-- Dragging functionality
local function updateDrag(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(
        startPos.X.Scale, 
        startPos.X.Offset + delta.X, 
        startPos.Y.Scale, 
        startPos.Y.Offset + delta.Y
    )
end

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

Header.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input == dragInput) then
        updateDrag(input)
    end
end)

-- Button Animations
local function buttonHoverEffect(button)
    local originalColor = button.BackgroundColor3
    local hoverColor = Color3.fromRGB(
        math.min(255, originalColor.R * 255 + 30),
        math.min(255, originalColor.G * 255 + 30),
        math.min(255, originalColor.B * 255 + 30)
    )
    
    button.MouseEnter:Connect(function()
        game:GetService("TweenService"):Create(
            button,
            TweenInfo.new(0.2),
            {BackgroundColor3 = hoverColor}
        ):Play()
    end)
    
    button.MouseLeave:Connect(function()
        game:GetService("TweenService"):Create(
            button,
            TweenInfo.new(0.2),
            {BackgroundColor3 = originalColor}
        ):Play()
    end)
end

-- Close Button Function
CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

buttonHoverEffect(CloseButton)
buttonHoverEffect(MinimizeButton)

-- Minimize Function
MinimizeButton.MouseButton1Click:Connect(function()
    if not isMinimized then
        -- Minimize
        game:GetService("TweenService"):Create(
            MainFrame,
            TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {Size = minimizedSize}
        ):Play()
        ContentFrame.Visible = false
        TabContainer.Visible = false
        Footer.Visible = false
        isMinimized = true
        MinimizeButton.Text = "+"
    else
        -- Restore
        game:GetService("TweenService"):Create(
            MainFrame,
            TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {Size = originalSize}
        ):Play()
        ContentFrame.Visible = true
        TabContainer.Visible = true
        Footer.Visible = true
        isMinimized = false
        MinimizeButton.Text = "_"
    end
end)

-- Create Tabs
local function createTabButton(tabName)
    local TabButton = Instance.new("TextButton")
    TabButton.Name = tabName .. "Tab"
    TabButton.Size = isMobile and UDim2.new(0, 55, 0, 30) or UDim2.new(0, 60, 0, 30)
    TabButton.BackgroundColor3 = tabName == "Main" and Color3.fromRGB(255, 105, 180) or Color3.fromRGB(40, 40, 50)
    TabButton.Text = tabName
    TabButton.TextColor3 = Color3.white
    TabButton.TextSize = isMobile and 12 or 13
    TabButton.Font = Enum.Font.GothamBold
    
    local TabCorner = Instance.new("UICorner")
    TabCorner.CornerRadius = UDim.new(0, 6)
    TabCorner.Parent = TabButton
    
    buttonHoverEffect(TabButton)
    
    return TabButton
end

-- Create Feature Button
local function createFeatureButton(text, color)
    local Button = Instance.new("TextButton")
    Button.Name = text .. "Btn"
    Button.Size = isMobile and UDim2.new(1, -10, 0, 35) or UDim2.new(1, -10, 0, 40)
    Button.BackgroundColor3 = color
    Button.Text = text
    Button.TextColor3 = Color3.white
    Button.TextSize = isMobile and 13 or 14
    Button.Font = Enum.Font.GothamBold
    
    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 6)
    ButtonCorner.Parent = Button
    
    local UIStroke = Instance.new("UIStroke")
    UIStroke.Color = Color3.fromRGB(30, 30, 40)
    UIStroke.Thickness = 1
    UIStroke.Parent = Button
    
    buttonHoverEffect(Button)
    
    return Button
end

-- Create Category Label
local function createCategoryLabel(text)
    local Label = Instance.new("TextLabel")
    Label.Name = text .. "Category"
    Label.Size = UDim2.new(1, 0, 0, 25)
    Label.BackgroundTransparency = 1
    Label.Text = "  " .. text
    Label.TextColor3 = Color3.fromRGB(255, 105, 180)
    Label.TextSize = 14
    Label.Font = Enum.Font.GothamBold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    
    return Label
end

-- Clear Content Frame
local function clearContent()
    for _, child in ipairs(ContentFrame:GetChildren()) do
        if child:IsA("GuiObject") and child.Name ~= "UIListLayout" then
            child:Destroy()
        end
    end
end

-- Main Features
local function loadMainTab()
    clearContent()
    
    local Layout = Instance.new("UIListLayout")
    Layout.Padding = UDim.new(0, 8)
    Layout.Parent = ContentFrame
    
    -- Welcome Label
    local WelcomeLabel = Instance.new("TextLabel")
    WelcomeLabel.Size = UDim2.new(1, 0, 0, 50)
    WelcomeLabel.BackgroundTransparency = 1
    WelcomeLabel.Text = "Welcome to Anonymous9x Project\nAdvanced Roblox Script Panel"
    WelcomeLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
    WelcomeLabel.TextSize = isMobile and 14 : 16
    WelcomeLabel.Font = Enum.Font.Gotham
    WelcomeLabel.TextWrapped = true
    WelcomeLabel.Parent = ContentFrame
    
    -- Creator Info
    local CreatorLabel = Instance.new("TextLabel")
    CreatorLabel.Size = UDim2.new(1, 0, 0, 30)
    CreatorLabel.BackgroundTransparency = 1
    CreatorLabel.Text = "Creator: Anonymous9x"
    CreatorLabel.TextColor3 = Color3.fromRGB(255, 105, 180)
    CreatorLabel.TextSize = 14
    CreatorLabel.Font = Enum.Font.GothamBold
    CreatorLabel.Parent = ContentFrame
    
    -- Quick Actions Category
    local QuickCat = createCategoryLabel("Quick Actions")
    QuickCat.Parent = ContentFrame
    
    -- Fly Feature
    local FlyBtn = createFeatureButton("🚀 Fly", Color3.fromRGB(65, 105, 225))
    FlyBtn.Parent = ContentFrame
    
    -- Noclip Feature
    local NoclipBtn = createFeatureButton("👻 Noclip", Color3.fromRGB(138, 43, 226))
    NoclipBtn.Parent = ContentFrame
    
    -- ESP Feature
    local ESPBtn = createFeatureButton("👁️ ESP", Color3.fromRGB(50, 205, 50))
    ESPBtn.Parent = ContentFrame
    
    ContentFrame.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 20)
end

-- Movement Features
local function loadMovementTab()
    clearContent()
    
    local Layout = Instance.new("UIListLayout")
    Layout.Padding = UDim.new(0, 8)
    Layout.Parent = ContentFrame
    
    local Cat = createCategoryLabel("Movement Features")
    Cat.Parent = ContentFrame
    
    -- Speed
    local SpeedBtn = createFeatureButton("⚡ Speed Hack", Color3.fromRGB(255, 140, 0))
    SpeedBtn.Parent = ContentFrame
    
    -- Fly (Advanced)
    local FlyBtn = createFeatureButton("🦅 Advanced Fly", Color3.fromRGB(30, 144, 255))
    FlyBtn.Parent = ContentFrame
    
    -- Jump Power
    local JumpBtn = createFeatureButton("🦘 High Jump", Color3.fromRGB(34, 139, 34))
    JumpBtn.Parent = ContentFrame
    
    -- Walk on Water
    local WaterBtn = createFeatureButton("🌊 Walk on Water", Color3.fromRGB(64, 224, 208))
    WaterBtn.Parent = ContentFrame
    
    -- No Clip
    local NoclipBtn = createFeatureButton("🚶 No Clip Walk", Color3.fromRGB(147, 112, 219))
    NoclipBtn.Parent = ContentFrame
    
    ContentFrame.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 20)
end

-- Combat Features
local function loadCombatTab()
    clearContent()
    
    local Layout = Instance.new("UIListLayout")
    Layout.Padding = UDim.new(0, 8)
    Layout.Parent = ContentFrame
    
    local Cat = createCategoryLabel("Combat Features")
    Cat.Parent = ContentFrame
    
    -- Kill All
    local KillBtn = createFeatureButton("💀 Kill All Players", Color3.fromRGB(220, 20, 60))
    KillBtn.Parent = ContentFrame
    
    -- AimBot
    local AimBtn = createFeatureButton("🎯 AimBot", Color3.fromRGB(255, 69, 0))
    AimBtn.Parent = ContentFrame
    
    -- Hitbox Expander
    local HitboxBtn = createFeatureButton("📦 Hitbox Expander", Color3.fromRGB(255, 165, 0))
    HitboxBtn.Parent = ContentFrame
    
    -- Infinite Ammo
    local AmmoBtn = createFeatureButton("🔫 Infinite Ammo", Color3.fromRGB(70, 130, 180))
    AmmoBtn.Parent = ContentFrame
    
    -- Laser Gun (from request)
    local LaserBtn = createFeatureButton("🔦 Laser Gun", Color3.fromRGB(255, 0, 255))
    LaserBtn.Parent = ContentFrame
    
    -- Bring Part (from request)
    local BringBtn = createFeatureButton("📦 Bring Part", Color3.fromRGB(0, 191, 255))
    BringBtn.Parent = ContentFrame
    
    ContentFrame.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 20)
end

-- Visual Features
local function loadVisualTab()
    clearContent()
    
    local Layout = Instance.new("UIListLayout")
    Layout.Padding = UDim.new(0, 8)
    Layout.Parent = ContentFrame
    
    local Cat = createCategoryLabel("Visual Features")
    Cat.Parent = ContentFrame
    
    -- Fullbright
    local BrightBtn = createFeatureButton("💡 Fullbright", Color3.fromRGB(255, 215, 0))
    BrightBtn.Parent = ContentFrame
    
    -- X-Ray
    local XrayBtn = createFeatureButton("🔍 X-Ray Vision", Color3.fromRGB(105, 105, 105))
    XrayBtn.Parent = ContentFrame
    
    -- Chams
    local ChamsBtn = createFeatureButton("🌈 Player Chams", Color3.fromRGB(148, 0, 211))
    ChamsBtn.Parent = ContentFrame
    
    -- FPS Boost
    local FPSBtn = createFeatureButton("⚡ FPS Boost", Color3.fromRGB(0, 250, 154))
    FPSBtn.Parent = ContentFrame
    
    ContentFrame.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 20)
end

-- Misc Features
local function loadMiscTab()
    clearContent()
    
    local Layout = Instance.new("UIListLayout")
    Layout.Padding = UDim.new(0, 8)
    Layout.Parent = ContentFrame
    
    local Cat = createCategoryLabel("Miscellaneous Features")
    Cat.Parent = ContentFrame
    
    -- Anti-AFK
    local AntiAFKBtn = createFeatureButton("⏰ Anti-AFK", Color3.fromRGB(100, 149, 237))
    AntiAFKBtn.Parent = ContentFrame
    
    -- Walk Fling (from request)
    local FlingBtn = createFeatureButton("🌀 Walk Fling", Color3.fromRGB(255, 20, 147))
    FlingBtn.Parent = ContentFrame
    
    -- Teleport to Player
    local TeleportBtn = createFeatureButton("📍 Teleport to Player", Color3.fromRGB(0, 206, 209))
    TeleportBtn.Parent = ContentFrame
    
    -- Server Info
    local ServerBtn = createFeatureButton("🔧 Server Info", Color3.fromRGB(169, 169, 169))
    ServerBtn.Parent = ContentFrame
    
    -- Reset Character
    local ResetBtn = createFeatureButton("🔄 Reset Character", Color3.fromRGB(178, 34, 34))
    ResetBtn.Parent = ContentFrame
    
    ContentFrame.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 20)
end

-- Initialize Tabs
local activeTab = "Main"
local tabButtons = {}

for _, tabName in ipairs(Tabs) do
    local tabButton = createTabButton(tabName)
    tabButton.Parent = TabContainer
    tabButtons[tabName] = tabButton
    
    tabButton.MouseButton1Click:Connect(function()
        -- Update all tab colors
        for name, btn in pairs(tabButtons) do
            btn.BackgroundColor3 = name == tabName and Color3.fromRGB(255, 105, 180) or Color3.fromRGB(40, 40, 50)
        end
        
        -- Load selected tab
        activeTab = tabName
        if tabName == "Main" then
            loadMainTab()
        elseif tabName == "Movement" then
            loadMovementTab()
        elseif tabName == "Combat" then
            loadCombatTab()
        elseif tabName == "Visual" then
            loadVisualTab()
        elseif tabName == "Misc" then
            loadMiscTab()
        end
    end)
end

-- Load initial tab
loadMainTab()

-- Feature Implementations (Core Functions)
local features = {
    flying = false,
    noclip = false,
    speed = false,
    esp = false
}

-- FLY FUNCTION
local function toggleFly()
    if not features.flying then
        -- Start flying
        local bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.Name = "FlyVelocity"
        bodyVelocity.Parent = Player.Character.HumanoidRootPart
        bodyVelocity.MaxForce = Vector3.new(0, 0, 0)
        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        
        local connection
        connection = RunService.Heartbeat:Connect(function()
            if features.flying then
                local root = Player.Character and Player.Character.HumanoidRootPart
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
            else
                connection:Disconnect()
                if Player.Character and Player.Character.HumanoidRootPart:FindFirstChild("FlyVelocity") then
                    Player.Character.HumanoidRootPart.FlyVelocity:Destroy()
                end
            end
        end)
        
        features.flying = true
        return "Fly: ON"
    else
        features.flying = false
        return "Fly: OFF"
    end
end

-- NOCLIP FUNCTION
local function toggleNoclip()
    features.noclip = not features.noclip
    if features.noclip then
        local connection
        connection = RunService.Stepped:Connect(function()
            if Player.Character then
                for _, part in pairs(Player.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            else
                connection:Disconnect()
            end
        end)
    end
    return features.noclip and "Noclip: ON" or "Noclip: OFF"
end

-- SPEED HACK
local function toggleSpeed()
    features.speed = not features.speed
    if Player.Character and Player.Character.Humanoid then
        if features.speed then
            Player.Character.Humanoid.WalkSpeed = 100
        else
            Player.Character.Humanoid.WalkSpeed = 16
        end
    end
    return features.speed and "Speed: 100" or "Speed: 16"
end

-- ESP FUNCTION (Simplified)
local function toggleESP()
    features.esp = not features.esp
    if features.esp then
        for _, otherPlayer in ipairs(Players:GetPlayers()) do
            if otherPlayer ~= Player and otherPlayer.Character then
                local highlight = Instance.new("Highlight")
                highlight.Name = "ESP_Highlight"
                highlight.FillColor = Color3.fromRGB(255, 0, 0)
                highlight.OutlineColor = Color3.fromRGB(255, 255, 0)
                highlight.Parent = otherPlayer.Character
            end
        end
    else
        for _, otherPlayer in ipairs(Players:GetPlayers()) do
            if otherPlayer.Character then
                local highlight = otherPlayer.Character:FindFirstChild("ESP_Highlight")
                if highlight then
                    highlight:Destroy()
                end
            end
        end
    end
    return features.esp and "ESP: ON" or "ESP: OFF"
end

-- LASER GUN FUNCTION (from request)
local function activateLaserGun()
    local tool = Instance.new("Tool")
    tool.Name = "LaserGun"
    tool.Parent = Player.Backpack
    
    local handle = Instance.new("Part")
    handle.Name = "Handle"
    handle.Size = Vector3.new(1, 1, 3)
    handle.Parent = tool
    
    tool.Activated:Connect(function()
        local ray = Ray.new(
            handle.Position,
            (Mouse.Hit.p - handle.Position).unit * 500
        )
        
        local part, position = workspace:FindPartOnRay(ray, Player.Character)
        
        if part then
            -- Create laser effect
            local laser = Instance.new("Part")
            laser.Size = Vector3.new(0.2, 0.2, (handle.Position - position).magnitude)
            laser.CFrame = CFrame.new((handle.Position + position) / 2, position)
            laser.Color = Color3.fromRGB(255, 0, 0)
            laser.Material = Enum.Material.Neon
            laser.Anchored = true
            laser.CanCollide = false
            laser.Parent = workspace
            
            game:GetService("Debris"):AddItem(laser, 0.1)
            
            -- Damage if it's a player
            local humanoid = part.Parent:FindFirstChild("Humanoid")
            if humanoid then
                humanoid:TakeDamage(25)
            end
        end
    end)
    
    return "Laser Gun equipped!"
end

-- BRING PART FUNCTION (from request)
local function bringPart()
    local targetPart = Mouse.Target
    if targetPart then
        local character = Player.Character
        if character and character.HumanoidRootPart then
            targetPart.Position = character.HumanoidRootPart.Position + Vector3.new(0, 5, 0)
            return "Part brought to you!"
        end
    end
    return "Click on a part first!"
end

-- WALK FLING FUNCTION (from request)
local function toggleWalkFling()
    if Player.Character and Player.Character.Humanoid then
        local humanoid = Player.Character.Humanoid
        local originalWalkSpeed = humanoid.WalkSpeed
        
        humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
            if humanoid.WalkSpeed > 0 then
                local root = Player.Character.HumanoidRootPart
                if root then
                    local bodyVelocity = Instance.new("BodyVelocity")
                    bodyVelocity.Velocity = root.CFrame.LookVector * 100 + Vector3.new(0, 50, 0)
                    bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                    bodyVelocity.Parent = root
                    
                    game:GetService("Debris"):AddItem(bodyVelocity, 0.1)
                end
            end
        end)
        
        return "Walk Fling: ON (Walk to fling)"
    end
    return "Walk Fling: Failed"
end

-- Connect buttons to functions (example connections)
-- You'll need to add proper connections for each button
-- Here's an example pattern:

local function connectButton(buttonName, func)
    -- This function would connect buttons when they're created
    -- Implementation depends on your specific button naming system
end

-- Notification system
local function notify(message)
    local notification = Instance.new("TextLabel")
    notification.Size = UDim2.new(0, 200, 0, 40)
    notification.Position = UDim2.new(0.5, -100, 1, -50)
    notification.AnchorPoint = Vector2.new(0.5, 1)
    notification.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    notification.TextColor3 = Color3.fromRGB(255, 105, 180)
    notification.Text = message
    notification.TextSize = 14
    notification.Font = Enum.Font.GothamBold
    notification.Parent = ScreenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = notification
    
    -- Animate
    notification:TweenPosition(
        UDim2.new(0.5, -100, 1, -100),
        Enum.EasingDirection.Out,
        Enum.EasingStyle.Quad,
        0.3
    )
    
    wait(2)
    
    notification:TweenPosition(
        UDim2.new(0.5, -100, 1, -50),
        Enum.EasingDirection.In,
        Enum.EasingStyle.Quad,
        0.3,
        true,
        function()
            notification:Destroy()
        end
    )
end

-- Mobile optimization
if isMobile then
    -- Increase button sizes for touch
    local function makeMobileFriendly(button)
        button.Size = UDim2.new(1, -20, 0, 45)
        button.TextSize = 13
    end
end

-- Initial notification
wait(1)
notify("Anonymous9x Project Loaded!")

print("Anonymous9x Project GUI successfully loaded!")

