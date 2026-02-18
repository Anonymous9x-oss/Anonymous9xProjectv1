-- ═════════════════════════════════════════════════════════════
-- ║         ANONYMOUS9X MAGNETPART - FINAL BOSS EDITION       ║
-- ║              CREATED BY: ANONYMOUS9X                      ║
-- ║           METHOD: ALIGN ONLY ULTRA (FINAL)                ║
-- ║              VERSION: FINAL BOSS V300.0                   ║
-- ║           STATUS: TRUE FE UNIVERSAL BRUTAL                ║
-- ═════════════════════════════════════════════════════════════

local Services = {
    Players = game:GetService("Players"),
    RunService = game:GetService("RunService"),
    CoreGui = game:GetService("CoreGui"),
    Workspace = game:GetService("Workspace"),
    TweenService = game:GetService("TweenService")
}

local Player = Services.Players.LocalPlayer

-- ═══════════════════════════════════════════════════════════
-- STATE CONFIGURATION (FINAL BOSS SPECS)
-- ═══════════════════════════════════════════════════════════

local State = {
    Active = false,
    Minimized = false,
    
    -- MAGNET SETTINGS
    Radius = 2500,              -- Jarak caplok awal
    BringHeight = 35,           -- Tinggi di atas kepala (Request lu!)
    OrbitMode = false,
    OrbitRadius = 30,
    
    -- FORCE SETTINGS (MAXIMUM BRUTALITY)
    AlignForce = 9e18,          -- Infinity Power
    AlignResponsiveness = 200,   -- Instant Snapping
    
    ManagedParts = {},          
    PartCount = 0,
    SimRadius = 1e15,
}

local UI = { Labels = {}, Buttons = {} }

-- ═══════════════════════════════════════════════════════════
-- UTILITIES
-- ═══════════════════════════════════════════════════════════

local function SafeCall(func, ...)
    local success, result = pcall(func, ...)
    return success, result
end

local function ExpandSimulation()
    SafeCall(function()
        sethiddenproperty(Player, "SimulationRadius", State.SimRadius)
        sethiddenproperty(Player, "MaxSimulationRadius", State.SimRadius)
        settings().Physics.AllowSleep = false
        settings().Physics.ThrottleAdjustTime = 0
    end)
end

local function IsValidPart(part)
    if not part:IsA("BasePart") or part.Anchored then return false end
    if Player.Character and part:IsDescendantOf(Player.Character) then return false end
    if part.Parent and part.Parent:FindFirstChildOfClass("Humanoid") then return false end
    if part.Name == "Baseplate" or part.Name == "Terrain" then return false end
    return true
end

-- ═══════════════════════════════════════════════════════════
-- ALIGN ONLY ULTRA SETUP (LOCK-ON ENGINE)
-- ═══════════════════════════════════════════════════════════

local function SetupAlignOnly(part)
    if State.ManagedParts[part] then return true end
    
    local success = SafeCall(function()
        local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        local hrpAtt = hrp:FindFirstChild("An9xTargetAtt")
        if not hrpAtt then
            hrpAtt = Instance.new("Attachment")
            hrpAtt.Name = "An9xTargetAtt"
            hrpAtt.Parent = hrp
        end
        
        local partAtt = Instance.new("Attachment")
        partAtt.Name = "An9xPartAtt"
        partAtt.Parent = part
        
        local align = Instance.new("AlignPosition")
        align.Name = "An9xAlign"
        align.Attachment0 = partAtt
        align.Attachment1 = hrpAtt
        align.MaxForce = State.AlignForce
        align.Responsiveness = State.AlignResponsiveness
        align.RigidityEnabled = true -- TITIK FINAL BOS (INSTANT SNAP)
        align.ApplyAtCenterOfMass = true
        align.Parent = part
        
        -- BRUTAL PHYSICS BYPASS
        part.CanCollide = false
        part.Velocity = Vector3.new(0, 5, 0) -- Kickstart physics
        
        State.ManagedParts[part] = {
            Attachment = partAtt,
            AlignPosition = align
        }
        State.PartCount = State.PartCount + 1
    end)
    return success
end

local function CleanupPart(part)
    local components = State.ManagedParts[part]
    if components then
        SafeCall(function()
            if components.Attachment then components.Attachment:Destroy() end
            if components.AlignPosition then components.AlignPosition:Destroy() end
        end)
        State.ManagedParts[part] = nil
        State.PartCount = math.max(0, State.PartCount - 1)
    end
end

-- ═══════════════════════════════════════════════════════════
-- UI CONSTRUCTION (BALIK KE ORI NOIR THEME)
-- ═══════════════════════════════════════════════════════════

local function BuildUI()
    if Services.CoreGui:FindFirstChild("An9xMagnetPanel") then
        Services.CoreGui.An9xMagnetPanel:Destroy()
    end
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "An9xMagnetPanel"
    ScreenGui.Parent = Services.CoreGui
    
    local Main = Instance.new("Frame")
    Main.Size = UDim2.new(0, 300, 0, 380)
    Main.Position = UDim2.new(0.5, -150, 0.4, -190)
    Main.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Main.Active = true
    Main.Draggable = true
    Main.Parent = ScreenGui
    
    local MainCorner = Instance.new("UICorner", Main)
    MainCorner.CornerRadius = UDim.new(0, 8)
    
    local MainStroke = Instance.new("UIStroke", Main)
    MainStroke.Color = Color3.fromRGB(255, 255, 255)
    MainStroke.Thickness = 2
    
    -- Header (ORI STYLE)
    local Header = Instance.new("Frame")
    Header.Size = UDim2.new(1, 0, 0, 50)
    Header.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    Header.Parent = Main
    Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 8)
    
    local Title = Instance.new("TextLabel")
    Title.Text = "ANONYMOUS9X MAGNETPART"
    Title.Size = UDim2.new(1, -100, 0, 20)
    Title.Position = UDim2.new(0, 12, 0, 8)
    Title.BackgroundTransparency = 1
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Font = Enum.Font.GothamBlack
    Title.TextSize = 12
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Header

    -- TOMBOL CLOSE & MINIMIZE (BALIK LAGI!)
    local MinBtn = Instance.new("TextButton")
    MinBtn.Text = "−"
    MinBtn.Size = UDim2.new(0, 40, 0, 40)
    MinBtn.Position = UDim2.new(1, -85, 0, 5)
    MinBtn.BackgroundTransparency = 1
    MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    MinBtn.TextSize = 24
    MinBtn.Parent = Header
    
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Text = "×"
    CloseBtn.Size = UDim2.new(0, 40, 0, 40)
    CloseBtn.Position = UDim2.new(1, -42, 0, 5)
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
    CloseBtn.TextSize = 28
    CloseBtn.Parent = Header

    local Content = Instance.new("Frame")
    Content.Size = UDim2.new(1, 0, 1, -50)
    Content.Position = UDim2.new(0, 0, 0, 50)
    Content.BackgroundTransparency = 1
    Content.Parent = Main
    UI.Content = Content

    -- Warning Box
    local Warning = Instance.new("TextLabel")
    Warning.Size = UDim2.new(0.9, 0, 0, 48)
    Warning.Position = UDim2.new(0.05, 0, 0, 8)
    Warning.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    Warning.TextColor3 = Color3.fromRGB(0, 255, 100)
    Warning.Font = Enum.Font.Code
    Warning.TextSize = 9
    Warning.Text = "[!] Most parts can cause fps drop"
    Warning.Parent = Content
    Instance.new("UIStroke", Warning).Color = Color3.fromRGB(0, 255, 100)

    -- Stats Box
    local StatsBox = Instance.new("Frame")
    StatsBox.Size = UDim2.new(0.9, 0, 0, 160)
    StatsBox.Position = UDim2.new(0.05, 0, 0, 64)
    StatsBox.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
    StatsBox.Parent = Content

    local function CreateLabel(yPos, name, text)
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -16, 0, 20)
        label.Position = UDim2.new(0, 10, 0, yPos)
        label.BackgroundTransparency = 1
        label.TextColor3 = Color3.fromRGB(220, 220, 220)
        label.Font = Enum.Font.Code
        label.TextSize = 10
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Text = text
        label.Parent = StatsBox
        UI.Labels[name] = label
    end

    CreateLabel(28, "Parts", "Magnet Parts: 0")
    CreateLabel(48, "FPS", "FPS: 60")
    CreateLabel(68, "Method", "Version: Ano9x 1.00 Beta") -- Request lu!
    CreateLabel(88, "Mode", "Mode: STACK")
    CreateLabel(108, "Height", "Height Offset: " .. State.BringHeight)
    CreateLabel(128, "Status", "Status: READY")

    local ActionBtn = Instance.new("TextButton")
    ActionBtn.Size = UDim2.new(0.9, 0, 0, 50)
    ActionBtn.Position = UDim2.new(0.05, 0, 1, -58)
    ActionBtn.Text = "ACTIVATE MAGNET"
    ActionBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ActionBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
    ActionBtn.Font = Enum.Font.GothamBlack
    ActionBtn.Parent = Content
    Instance.new("UICorner", ActionBtn).CornerRadius = UDim.new(0, 5)

    -- EVENTS
    ActionBtn.MouseButton1Click:Connect(function()
        State.Active = not State.Active
        ActionBtn.Text = State.Active and "MAGNET: ACTIVE" or "ACTIVATE MAGNET"
        ActionBtn.BackgroundColor3 = State.Active and Color3.fromRGB(200, 0, 0) or Color3.fromRGB(255, 255, 255)
        ActionBtn.TextColor3 = State.Active and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(0, 0, 0)
        if not State.Active then for p, _ in pairs(State.ManagedParts) do CleanupPart(p) end end
    end)

    MinBtn.MouseButton1Click:Connect(function()
        State.Minimized = not State.Minimized
        Content.Visible = not State.Minimized
        Services.TweenService:Create(Main, TweenInfo.new(0.3), {Size = State.Minimized and UDim2.new(0, 300, 0, 50) or UDim2.new(0, 300, 0, 380)}):Play()
        MinBtn.Text = State.Minimized and "+" or "−"
    end)

    CloseBtn.MouseButton1Click:Connect(function()
        State.Active = false
        for p, _ in pairs(State.ManagedParts) do CleanupPart(p) end
        ScreenGui:Destroy()
    end)
end

-- ═══════════════════════════════════════════════════════════
-- HEARTBEAT LOOP (THE "BOSS" ENGINE)
-- ═══════════════════════════════════════════════════════════

Services.RunService.Heartbeat:Connect(function()
    ExpandSimulation()
    if not State.Active then return end
    
    local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local hrpPos = hrp.Position
    local activeCount = 0
    
    -- SEARCH & LOCK NEW PARTS
    for _, part in pairs(Services.Workspace:GetDescendants()) do
        if IsValidPart(part) then
            local dist = (part.Position - hrpPos).Magnitude
            if dist < State.Radius then
                SetupAlignOnly(part)
            end
        end
    end
    
    -- UPDATE ALL LOCKED PARTS (NO MATTER THE DISTANCE)
    for part, _ in pairs(State.ManagedParts) do
        if part.Parent and IsValidPart(part) then
            activeCount = activeCount + 1
            local targetPos = hrpPos + Vector3.new(0, State.BringHeight, 0)
            
            -- Update Attachment Target
            local hrpAtt = hrp:FindFirstChild("An9xTargetAtt")
            if hrpAtt then 
                hrpAtt.WorldPosition = targetPos 
            end
            
            -- FORCED PHYSICS (BIAR GAK BISA LEPAS)
            part.Velocity = Vector3.new(0, 0.5, 0)
            part.RotVelocity = Vector3.new(math.random(), math.random(), math.random())
        else
            CleanupPart(part)
        end
    end
    
    if UI.Labels.Parts then UI.Labels.Parts.Text = "Magnet Parts: " .. activeCount end
    if UI.Labels.FPS then UI.Labels.FPS.Text = "FPS: " .. math.floor(1/Services.RunService.Heartbeat:Wait()) end
end)

BuildUI()
print("ANONYMOUS9X MAGNET - V1.00 Beta Loaded")
