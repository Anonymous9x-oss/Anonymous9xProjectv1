-- ==================== ANONYMOUS9X ESP ULTIMATE V3.0 PROFESSIONAL ====================
-- ✅ REAL-TIME PLAYER DETECTION (NO MISS)
-- ✅ FORCE REFRESH SYSTEM
-- ✅ AUTO-RETRY MECHANISM
-- ✅ FULL MAP DETECTION (NO DISTANCE LIMIT)
-- ✅ NAME + HEALTH + DISTANCE + BOX + LINE TRACKER
-- ✅ TOGGLE BY EXECUTE (NO GUI)
-- ✅ PROFESSIONAL NOTIFICATIONS
-- ✅ UNIVERSAL COMPATIBILITY (PC & MOBILE)
-- =====================================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- ==================== TOGGLE STATE MANAGEMENT ====================
_G.Anonymous9xESP = _G.Anonymous9xESP or {}
local ESPState = _G.Anonymous9xESP

-- Jika sudah aktif, matikan
if ESPState.Active then
    ESPState.Active = false
    
    -- Destroy semua ESP objects
    if ESPState.Objects then
        for _, espData in pairs(ESPState.Objects) do
            if espData.Folder then
                pcall(function() espData.Folder:Destroy() end)
            end
            if espData.Line then
                pcall(function() espData.Line:Remove() end)
            end
        end
    end
    
    -- Disconnect semua connections
    if ESPState.Connections then
        for _, connection in pairs(ESPState.Connections) do
            pcall(function() connection:Disconnect() end)
        end
    end
    
    -- Clear data
    ESPState.Objects = {}
    ESPState.Connections = {}
    ESPState.PlayerTracking = {}
    
    -- ==================== DEACTIVATION NOTIFICATION ====================
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "🔴 Anonymous9x ESP Ultimate V3.0",
        Text = "ESP FULL DEACTIVATED\n━━━━━━━━━━━━━━━━━━\n✖ All ESP Disabled\n✖ Line Tracker Off\n✖ Real-time Detection Off\n✖ Health Monitor Off",
        Duration = 5,
        Icon = "rbxassetid://7733920644"
    })
    
    print("\n" .. string.rep("=", 50))
    print("🔴 ANONYMOUS9X ESP ULTIMATE V3.0 - DEACTIVATED")
    print(string.rep("=", 50))
    print("All ESP features have been turned off.")
    print(string.rep("=", 50) .. "\n")
    
    return
end

-- ==================== ACTIVATION ====================
ESPState.Active = true
ESPState.Objects = {}
ESPState.Connections = {}
ESPState.PlayerTracking = {}

-- ==================== CONFIGURATION ====================
local Config = {
    -- ESP Settings
    BoxEnabled = true,
    LineEnabled = true,
    NameEnabled = true,
    HealthEnabled = true,
    DistanceEnabled = true,
    
    -- Colors
    EnemyColor = Color3.fromRGB(255, 60, 60),
    FriendlyColor = Color3.fromRGB(60, 255, 60),
    DefaultColor = Color3.fromRGB(255, 255, 255),
    
    -- Styling
    BoxThickness = 2,
    LineThickness = 2,
    TextSize = 14,
    
    -- Performance & Detection
    UpdateRate = 0.03,
    MaxDistance = math.huge,
    RetryAttempts = 5,
    RetryDelay = 0.5,
    ForceRefreshInterval = 5,
}

-- ==================== ACTIVATION NOTIFICATION ====================
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "🟢 Anonymous9x ESP Ultimate V3.0",
    Text = "ESP FULL ACTIVE\n━━━━━━━━━━━━━━━━━━\n✓ Real-time Detection ON\n✓ Force Refresh System ON\n✓ Auto-Retry Mechanism ON\n✓ Full Map Coverage ON",
    Duration = 6,
    Icon = "rbxassetid://7733960981"
})

print("\n" .. string.rep("=", 50))
print("🟢 ANONYMOUS9X ESP ULTIMATE V3.0 - ACTIVATED")
print(string.rep("=", 50))
print("✓ Real-time Player Detection: ENABLED")
print("✓ Force Refresh System: ENABLED")
print("✓ Auto-Retry Mechanism: ENABLED")
print("✓ Full Map Detection: ENABLED")
print("✓ Line Tracker: ENABLED")
print("✓ Health Monitor: ENABLED")
print("✓ Distance Calculator: ENABLED")
print(string.rep("=", 50) .. "\n")

-- ==================== UTILITY FUNCTIONS ====================
local function GetPlayerColor(player)
    if not LocalPlayer.Team or not player.Team then
        return Config.DefaultColor
    end
    
    return player.Team == LocalPlayer.Team 
        and Config.FriendlyColor 
        or Config.EnemyColor
end

local function FormatDistance(distance)
    return string.format("%.0fm", distance)
end

local function GetHealthPercentage(humanoid)
    if not humanoid then return 0 end
    local health = math.max(0, humanoid.Health)
    local maxHealth = math.max(1, humanoid.MaxHealth)
    return math.floor((health / maxHealth) * 100)
end

-- ==================== ESP CREATION (ADVANCED) ====================
local function CreateESP(player, retryCount)
    if not ESPState.Active then return end
    if player == LocalPlayer then return end
    
    retryCount = retryCount or 0
    
    -- Check if already exists and valid
    if ESPState.Objects[player] then
        local espData = ESPState.Objects[player]
        if espData.Folder and espData.Folder.Parent then
            return -- Already exists and valid
        else
            -- Clean up invalid ESP
            pcall(function()
                if espData.Folder then espData.Folder:Destroy() end
                if espData.Line then espData.Line:Remove() end
            end)
            ESPState.Objects[player] = nil
        end
    end
    
    local character = player.Character
    if not character then
        -- Retry if character not loaded
        if retryCount < Config.RetryAttempts then
            task.delay(Config.RetryDelay, function()
                CreateESP(player, retryCount + 1)
            end)
        end
        return
    end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    
    if not rootPart or not humanoid then
        -- Retry if parts not found
        if retryCount < Config.RetryAttempts then
            task.delay(Config.RetryDelay, function()
                CreateESP(player, retryCount + 1)
            end)
        end
        return
    end
    
    -- Create ESP Container
    local espFolder = Instance.new("Folder")
    espFolder.Name = "ESP_" .. player.Name
    espFolder.Parent = Camera
    
    -- ==================== BOX ESP ====================
    local box = Instance.new("BoxHandleAdornment")
    box.Name = "ESP_Box"
    box.Size = Vector3.new(4, 6, 1)
    box.Adornee = rootPart
    box.AlwaysOnTop = true
    box.ZIndex = 10
    box.Transparency = 0.65
    box.Color3 = GetPlayerColor(player)
    box.Parent = espFolder
    
    -- ==================== LINE TRACKER ====================
    local line = Drawing.new("Line")
    line.Thickness = Config.LineThickness
    line.Color = GetPlayerColor(player)
    line.Transparency = 1
    line.Visible = true
    
    -- ==================== INFO BILLBOARD ====================
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESP_Info"
    billboard.Adornee = rootPart
    billboard.Size = UDim2.new(0, 200, 0, 100)
    billboard.StudsOffset = Vector3.new(0, 4, 0)
    billboard.AlwaysOnTop = true
    billboard.MaxDistance = Config.MaxDistance
    billboard.Parent = espFolder
    
    -- Container Frame
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 1, 0)
    container.BackgroundTransparency = 1
    container.Parent = billboard
    
    -- ==================== NAME LABEL ====================
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "NameLabel"
    nameLabel.Size = UDim2.new(1, 0, 0.25, 0)
    nameLabel.Position = UDim2.new(0, 0, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = player.Name
    nameLabel.TextColor3 = Color3.new(1, 1, 1)
    nameLabel.TextStrokeTransparency = 0
    nameLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = Config.TextSize + 2
    nameLabel.TextScaled = false
    nameLabel.Parent = container
    
    -- ==================== HEALTH LABEL ====================
    local healthLabel = Instance.new("TextLabel")
    healthLabel.Name = "HealthLabel"
    healthLabel.Size = UDim2.new(1, 0, 0.25, 0)
    healthLabel.Position = UDim2.new(0, 0, 0.25, 0)
    healthLabel.BackgroundTransparency = 1
    healthLabel.Text = "HP: 100%"
    healthLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
    healthLabel.TextStrokeTransparency = 0
    healthLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
    healthLabel.Font = Enum.Font.GothamBold
    healthLabel.TextSize = Config.TextSize
    healthLabel.Parent = container
    
    -- ==================== DISTANCE LABEL ====================
    local distanceLabel = Instance.new("TextLabel")
    distanceLabel.Name = "DistanceLabel"
    distanceLabel.Size = UDim2.new(1, 0, 0.25, 0)
    distanceLabel.Position = UDim2.new(0, 0, 0.5, 0)
    distanceLabel.BackgroundTransparency = 1
    distanceLabel.Text = "0m"
    distanceLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
    distanceLabel.TextStrokeTransparency = 0
    distanceLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
    distanceLabel.Font = Enum.Font.GothamBold
    distanceLabel.TextSize = Config.TextSize
    distanceLabel.Parent = container
    
    -- Store ESP Data
    ESPState.Objects[player] = {
        Folder = espFolder,
        Box = box,
        Line = line,
        Billboard = billboard,
        NameLabel = nameLabel,
        HealthLabel = healthLabel,
        DistanceLabel = distanceLabel,
        Player = player,
        RootPart = rootPart,
        Humanoid = humanoid,
        CreatedAt = tick()
    }
    
    -- Track player
    ESPState.PlayerTracking[player] = {
        HasESP = true,
        LastUpdate = tick(),
        Character = character
    }
    
    print("[ESP] ✅ Created for: " .. player.Name)
end

-- ==================== ESP UPDATE (ADVANCED) ====================
local function UpdateESP()
    if not ESPState.Active then return end
    
    for player, espData in pairs(ESPState.Objects) do
        -- Validate player
        if not player or not player.Parent or not player.Character then
            pcall(function()
                if espData.Folder then espData.Folder:Destroy() end
                if espData.Line then espData.Line:Remove() end
            end)
            ESPState.Objects[player] = nil
            ESPState.PlayerTracking[player] = nil
            continue
        end
        
        local character = player.Character
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        
        if not rootPart or not humanoid then 
            continue 
        end
        
        -- Update tracking
        if ESPState.PlayerTracking[player] then
            ESPState.PlayerTracking[player].LastUpdate = tick()
        end
        
        -- Update color
        local color = GetPlayerColor(player)
        
        -- Update Box
        if espData.Box and espData.Box.Parent then
            espData.Box.Color3 = color
            espData.Box.Adornee = rootPart
        end
        
        -- Update Line Tracker
        if espData.Line then
            local rootPos = rootPart.Position
            local screenPos, onScreen = Camera:WorldToViewportPoint(rootPos)
            
            if onScreen then
                local screenSize = Camera.ViewportSize
                espData.Line.From = Vector2.new(screenSize.X / 2, screenSize.Y)
                espData.Line.To = Vector2.new(screenPos.X, screenPos.Y)
                espData.Line.Color = color
                espData.Line.Visible = true
            else
                espData.Line.Visible = false
            end
        end
        
        -- Update Health
        if espData.HealthLabel and humanoid then
            local healthPercent = GetHealthPercentage(humanoid)
            espData.HealthLabel.Text = string.format("HP: %d%%", healthPercent)
            
            -- Health color gradient
            if healthPercent > 75 then
                espData.HealthLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
            elseif healthPercent > 50 then
                espData.HealthLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
            elseif healthPercent > 25 then
                espData.HealthLabel.TextColor3 = Color3.fromRGB(255, 165, 0)
            else
                espData.HealthLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
            end
        end
        
        -- Update Distance
        if espData.DistanceLabel and LocalPlayer.Character then
            local localRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if localRoot then
                local distance = (rootPart.Position - localRoot.Position).Magnitude
                espData.DistanceLabel.Text = FormatDistance(distance)
            end
        end
        
        -- Update Name Color
        if espData.NameLabel then
            espData.NameLabel.TextColor3 = color
        end
    end
end

-- ==================== FORCE REFRESH SYSTEM ====================
local function ForceRefreshAllPlayers()
    if not ESPState.Active then return end
    
    print("[ESP] 🔄 Force Refresh: Scanning all players...")
    local scanned = 0
    local created = 0
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            scanned = scanned + 1
            
            -- Check if player has valid ESP
            local hasValidESP = false
            if ESPState.Objects[player] then
                local espData = ESPState.Objects[player]
                if espData.Folder and espData.Folder.Parent then
                    hasValidESP = true
                end
            end
            
            -- Create ESP if missing or invalid
            if not hasValidESP then
                CreateESP(player)
                created = created + 1
            end
        end
    end
    
    print(string.format("[ESP] ✅ Refresh Complete: %d scanned, %d created", scanned, created))
end

-- ==================== AUTO-DETECTION SYSTEM ====================
local function SetupPlayerDetection(player)
    if player == LocalPlayer then return end
    
    -- Immediate ESP creation
    task.spawn(function()
        CreateESP(player)
    end)
    
    -- Character added detection
    local charConn = player.CharacterAdded:Connect(function(character)
        print("[ESP] 🔄 Character Added: " .. player.Name)
        
        -- Remove old ESP
        if ESPState.Objects[player] then
            pcall(function()
                if ESPState.Objects[player].Folder then 
                    ESPState.Objects[player].Folder:Destroy() 
                end
                if ESPState.Objects[player].Line then 
                    ESPState.Objects[player].Line:Remove() 
                end
            end)
            ESPState.Objects[player] = nil
        end
        
        -- Create new ESP with retry
        task.wait(0.3)
        CreateESP(player)
    end)
    
    -- Store connection
    if not ESPState.Connections[player] then
        ESPState.Connections[player] = {}
    end
    table.insert(ESPState.Connections[player], charConn)
end

-- ==================== ESP REMOVAL ====================
local function RemoveESP(player)
    local espData = ESPState.Objects[player]
    if espData then
        pcall(function()
            if espData.Folder then espData.Folder:Destroy() end
            if espData.Line then espData.Line:Remove() end
        end)
        ESPState.Objects[player] = nil
    end
    
    -- Disconnect player connections
    if ESPState.Connections[player] then
        for _, conn in pairs(ESPState.Connections[player]) do
            pcall(function() conn:Disconnect() end)
        end
        ESPState.Connections[player] = nil
    end
    
    -- Remove tracking
    ESPState.PlayerTracking[player] = nil
end

-- ==================== INITIAL SETUP ====================
-- Setup existing players
for _, player in pairs(Players:GetPlayers()) do
    SetupPlayerDetection(player)
end

-- Player added event
table.insert(ESPState.Connections, Players.PlayerAdded:Connect(function(player)
    print("[ESP] 🆕 New Player Joined: " .. player.Name)
    SetupPlayerDetection(player)
end))

-- Player removed event
table.insert(ESPState.Connections, Players.PlayerRemoving:Connect(function(player)
    print("[ESP] 👋 Player Left: " .. player.Name)
    RemoveESP(player)
end))

-- Local player respawn
table.insert(ESPState.Connections, LocalPlayer.CharacterAdded:Connect(function()
    print("[ESP] 🔄 Local Player Respawned")
    task.wait(1)
    ForceRefreshAllPlayers()
end))

-- ==================== MAIN UPDATE LOOP ====================
table.insert(ESPState.Connections, RunService.RenderStepped:Connect(function()
    UpdateESP()
end))

-- ==================== FORCE REFRESH LOOP ====================
table.insert(ESPState.Connections, RunService.Heartbeat:Connect(function()
    task.spawn(function()
        while ESPState.Active do
            task.wait(Config.ForceRefreshInterval)
            ForceRefreshAllPlayers()
        end
    end)
end))

-- ==================== HEALTH MONITORING ====================
table.insert(ESPState.Connections, RunService.Heartbeat:Connect(function()
    for player, tracking in pairs(ESPState.PlayerTracking) do
        if player and player.Parent then
            -- Check if character changed
            if player.Character ~= tracking.Character then
                print("[ESP] ⚠️ Character Change Detected: " .. player.Name)
                RemoveESP(player)
                tracking.Character = player.Character
                task.wait(0.3)
                CreateESP(player)
            end
            
            -- Check for missing ESP
            if not ESPState.Objects[player] or not ESPState.Objects[player].Folder then
                print("[ESP] ⚠️ Missing ESP Detected: " .. player.Name)
                CreateESP(player)
            end
        end
    end
end))

-- Initial force refresh
task.delay(2, function()
    ForceRefreshAllPlayers()
end)

-- ==================== SCRIPT INFO ====================
print("\n" .. string.rep("━", 60))
print("┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓")
print("┃         🔥 ANONYMOUS9X ESP ULTIMATE V3.0 🔥           ┃")
print("┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫")
print("┃  ✓ Real-time Player Detection                        ┃")
print("┃  ✓ Force Refresh System (Auto-Scan)                  ┃")
print("┃  ✓ Auto-Retry Mechanism                              ┃")
print("┃  ✓ Full Map Detection (No Distance Limit)            ┃")
print("┃  ✓ Advanced Line Tracker                             ┃")
print("┃  ✓ Real-time Health Monitor                          ┃")
print("┃  ✓ Dynamic Distance Calculator                       ┃")
print("┃  ✓ Professional Box ESP                              ┃")
print("┃  ✓ Character Change Detection                        ┃")
print("┃  ✓ Missing ESP Auto-Recovery                         ┃")
print("┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫")
print("┃  🎮 CONTROLS:                                         ┃")
print("┃     • Execute Script: Activate ESP                    ┃")
print("┃     • Execute Again: Deactivate ESP                   ┃")
print("┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫")
print("┃  📊 STATUS: ACTIVE & MONITORING                      ┃")
print("┃  🔧 Creator: Anonymous9x                              ┃")
print("┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛")
print(string.rep("━", 60) .. "\n")
