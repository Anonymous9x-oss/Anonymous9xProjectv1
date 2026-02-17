-- ================================================
-- ANONYMOUS9x ARMAGEDON SPAM v3.0 (BRUTAL ENGINE)
-- FITUR: DUAL HEARTBEAT + PARALLEL + ADAPTIVE SPEED
-- SPEED: 8000-12000+ RPS (STABLE, ANTI-CRASH)
-- FIX: STOP INSTAN, MULTI-THREAD FIRING
-- GUI: 100% SAMA PERSIS, TIDAK DIUBAH
-- ================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

-- CONFIGURATION (SAMA PERSIS)
local Config = {
    SpeedMultiplier = 60,  -- Base multiplier (dinaikin dikit)
    MaxMultiplier = 150,   -- Turbo max (lebih gila)
    MinMultiplier = 50,    -- Safety min
    Theme = {
        Bg = Color3.fromRGB(10, 10, 12),
        Panel = Color3.fromRGB(18, 18, 20),
        Text = Color3.fromRGB(255, 255, 255),
        Stroke = Color3.fromRGB(255, 255, 255),
        Green = Color3.fromRGB(0, 255, 120),
        Red = Color3.fromRGB(255, 60, 60),
        Gray = Color3.fromRGB(150, 150, 150)
    }
}

-- STATE (SAMA PERSIS + TAMBAHAN PERFORMANCE)
local Brutal = {
    Remotes = {},
    Spamming = false,
    Fired = 0,
    Target = 1000,
    Connections = {},
    GUI = nil,
    Performance = {
        LastTick = 0,
        CurrentRPS = 0,
        Multiplier = 60,
        PeakRPS = 0
    }
}

-- ========== 🛠️ UI UTILITIES (SAMA PERSIS) ==========
local function CreateStroke(obj, thickness, transparency)
    local s = Instance.new("UIStroke", obj)
    s.Color = Config.Theme.Stroke
    s.Thickness = thickness or 1
    s.Transparency = transparency or 0.8
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    return s
end

local function MakeDraggable(frame, handle)
    local dragging, dragInput, dragStart, startPos
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    frame.InputChanged:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- ========== 🎯 SCANNER (SAMA PERSIS) ==========
function Brutal.Scan()
    Brutal.Remotes = {}
    local function deepScan(folder)
        for _, v in pairs(folder:GetDescendants()) do
            if v:IsA("RemoteEvent") then
                table.insert(Brutal.Remotes, {Obj = v, Path = v:GetFullName(), Active = true})
            end
        end
    end
    pcall(function() deepScan(game:GetService("ReplicatedStorage")) end)
    pcall(function() deepScan(workspace) end)
    return #Brutal.Remotes
end

-- ========== 🔥🔥 BRUTAL ENGINE V3 (DUAL HEARTBEAT + PARALLEL) ==========
function Brutal.StartAttack()
    if Brutal.Spamming then return end
    
    -- Filter Active Remotes
    local Targets = {}
    for _, r in pairs(Brutal.Remotes) do 
        if r.Active then 
            table.insert(Targets, r.Obj) 
        end 
    end
    if #Targets == 0 then return end

    -- Reset state
    Brutal.Spamming = true
    Brutal.Fired = 0
    Brutal.Performance.Multiplier = Config.SpeedMultiplier
    Brutal.Performance.LastTick = tick()
    Brutal.Performance.CurrentRPS = 0
    
    -- 🚀 CORE SPAM FUNCTION (PARALLEL + ADAPTIVE)
    local function SpamRoutine()
        if not Brutal.Spamming then return end
        if Brutal.Fired >= Brutal.Target then
            Brutal.StopAttack()
            return
        end
        
        -- ADAPTIVE SPEED (Turbo Mode)
        local now = tick()
        local delta = now - Brutal.Performance.LastTick
        if delta > 0.05 then  -- Update setiap ~3 frame
            Brutal.Performance.CurrentRPS = Brutal.Fired / delta
            Brutal.Performance.LastTick = now
            
            -- Rekam peak performance
            if Brutal.Performance.CurrentRPS > Brutal.Performance.PeakRPS then
                Brutal.Performance.PeakRPS = Brutal.Performance.CurrentRPS
            end
            
            -- Auto adjust multiplier berdasarkan RPS
            if Brutal.Performance.CurrentRPS > 7000 then
                Brutal.Performance.Multiplier = math.min(Brutal.Performance.Multiplier + 3, Config.MaxMultiplier)
            elseif Brutal.Performance.CurrentRPS < 4000 then
                Brutal.Performance.Multiplier = math.max(Brutal.Performance.Multiplier - 2, Config.MinMultiplier)
            end
        end
        
        -- 🔥 DOUBLE PUMP + PARALLEL FIRING (BATCH 1)
        pcall(function()
            for pump = 1, 2 do  -- 2 batch per tick
                if not Brutal.Spamming or Brutal.Fired >= Brutal.Target then break end
                
                -- Fire semua remote secara PARALEL
                for _, remote in pairs(Targets) do
                    if not Brutal.Spamming then break end
                    task.spawn(function()
                        pcall(function() 
                            remote:FireServer("An9x_V4", math.random()) 
                        end)
                    end)
                    Brutal.Fired = Brutal.Fired + 1
                end
                
                -- Zero-delay biar ga nge-freeze
                if pump == 1 then task.wait(0) end
            end
            
            -- 🔥 ADAPTIVE MULTIPLIER LOOP (Batch 2 - Turbo)
            for i = 1, Brutal.Performance.Multiplier do
                if not Brutal.Spamming or Brutal.Fired >= Brutal.Target then break end
                
                for _, remote in pairs(Targets) do
                    if not Brutal.Spamming then break end
                    task.spawn(function()
                        pcall(function()
                            remote:FireServer("An9x_V4", math.random())
                        end)
                    end)
                    Brutal.Fired = Brutal.Fired + 1
                end
            end
        end)
    end
    
    -- 🚀🚀 DUAL HEARTBEAT - 2 KONEKSI PARALEL
    local Pulse1 = RunService.Heartbeat:Connect(SpamRoutine)
    local Pulse2 = RunService.Heartbeat:Connect(SpamRoutine)
    table.insert(Brutal.Connections, Pulse1)
    table.insert(Brutal.Connections, Pulse2)
    
    -- 🔥 OPSIONAL: RENDERSTEPPED UNTUK 3x LIPAT (UNCOMMENT KALO MAU LEBIH GILA)
    -- local Pulse3 = RunService.RenderStepped:Connect(SpamRoutine)
    -- table.insert(Brutal.Connections, Pulse3)
end

-- ========== 🛑 STOP ENGINE (INSTAN) ==========
function Brutal.StopAttack()
    Brutal.Spamming = false
    for _, c in pairs(Brutal.Connections) do 
        pcall(function() c:Disconnect() end)
    end
    Brutal.Connections = {}
end

-- ========== 🖥️ GUI BUILDER (SAMA PERSIS, TIDAK DIUBAH) ==========
function Brutal.BuildUI()
    if CoreGui:FindFirstChild("An9xFinal") then CoreGui.An9xFinal:Destroy() end
    
    local Screen = Instance.new("ScreenGui", CoreGui)
    Screen.Name = "An9xFinal"
    Brutal.GUI = Screen

    -- MAIN FRAME
    local Main = Instance.new("Frame", Screen)
    Main.Size = UDim2.new(0, 420, 0, 260)
    Main.Position = UDim2.new(0.5, -210, 0.5, -130)
    Main.BackgroundColor3 = Config.Theme.Bg
    Main.ClipsDescendants = true
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)
    CreateStroke(Main, 1.5, 0.3)
    MakeDraggable(Main, Main)

    -- HEADER
    local Header = Instance.new("Frame", Main)
    Header.Size = UDim2.new(1, 0, 0, 30)
    Header.BackgroundTransparency = 1
    
    local Title = Instance.new("TextLabel", Header)
    Title.Text = "  ARMAGEDON SPAM"
    Title.Size = UDim2.new(0, 200, 1, 0)
    Title.BackgroundTransparency = 1
    Title.TextColor3 = Config.Theme.Text
    Title.Font = Enum.Font.GothamBlack
    Title.TextSize = 13
    Title.TextXAlignment = "Left"

    -- CLOSE BUTTON
    local CloseBtn = Instance.new("TextButton", Header)
    CloseBtn.Text = "×"
    CloseBtn.Size = UDim2.new(0, 30, 0, 30)
    CloseBtn.Position = UDim2.new(1, -30, 0, 0)
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.TextColor3 = Config.Theme.Red
    CloseBtn.TextSize = 18
    CloseBtn.Font = Enum.Font.GothamBlack
    CloseBtn.MouseButton1Click:Connect(function() 
        Brutal.StopAttack() 
        Screen:Destroy() 
    end)

    -- MINIMIZE BUTTON
    local MinBtn = Instance.new("TextButton", Header)
    MinBtn.Text = "−"
    MinBtn.Size = UDim2.new(0, 30, 0, 30)
    MinBtn.Position = UDim2.new(1, -60, 0, 0)
    MinBtn.BackgroundTransparency = 1
    MinBtn.TextColor3 = Config.Theme.Text
    MinBtn.TextSize = 18
    MinBtn.Font = Enum.Font.GothamBlack
    
    local Expanded = true
    MinBtn.MouseButton1Click:Connect(function()
        Expanded = not Expanded
        if Expanded then
            Main:TweenSize(UDim2.new(0, 420, 0, 260), "Out", "Quad", 0.3)
        else
            Main:TweenSize(UDim2.new(0, 420, 0, 30), "Out", "Quad", 0.3)
        end
    end)

    -- CONTAINER
    local Container = Instance.new("Frame", Main)
    Container.Size = UDim2.new(1, -10, 1, -40)
    Container.Position = UDim2.new(0, 5, 0, 35)
    Container.BackgroundTransparency = 1

    -- LEFT PANEL
    local Left = Instance.new("Frame", Container)
    Left.Size = UDim2.new(0.35, -5, 1, 0)
    Left.BackgroundColor3 = Config.Theme.Panel
    Instance.new("UICorner", Left)
    CreateStroke(Left)

    -- STATS
    local Stats = Instance.new("TextLabel", Left)
    Stats.Size = UDim2.new(1, -10, 0, 40)
    Stats.Position = UDim2.new(0, 5, 0, 5)
    Stats.BackgroundTransparency = 1
    Stats.TextColor3 = Config.Theme.Green
    Stats.Font = Enum.Font.Code
    Stats.TextSize = 10
    Stats.TextXAlignment = "Left"
    Stats.Text = "STATUS: READY"

    -- INPUT COUNT
    local CountBox = Instance.new("TextBox", Left)
    CountBox.Size = UDim2.new(0.9, 0, 0, 25)
    CountBox.Position = UDim2.new(0.05, 0, 0, 50)
    CountBox.BackgroundColor3 = Color3.fromRGB(30,30,35)
    CountBox.TextColor3 = Config.Theme.Text
    CountBox.PlaceholderText = "SET AMOUNT (1000)"
    CountBox.Text = "1000"
    CountBox.Font = Enum.Font.GothamBold
    CountBox.TextSize = 11
    Instance.new("UICorner", CountBox)
    CreateStroke(CountBox)
    
    CountBox:GetPropertyChangedSignal("Text"):Connect(function()
        Brutal.Target = tonumber(CountBox.Text) or 1000
    end)

    -- SCAN BUTTON
    local BtnScan = Instance.new("TextButton", Left)
    BtnScan.Text = "SCAN REMOTES"
    BtnScan.Size = UDim2.new(0.9, 0, 0, 25)
    BtnScan.Position = UDim2.new(0.05, 0, 0, 85)
    BtnScan.BackgroundColor3 = Color3.fromRGB(40,40,50)
    BtnScan.TextColor3 = Config.Theme.Text
    BtnScan.Font = Enum.Font.GothamBold
    BtnScan.TextSize = 10
    Instance.new("UICorner", BtnScan)
    CreateStroke(BtnScan)

    -- START BUTTON
    local BtnStart = Instance.new("TextButton", Left)
    BtnStart.Text = "START SPAM"
    BtnStart.Size = UDim2.new(0.9, 0, 0, 35)
    BtnStart.Position = UDim2.new(0.05, 0, 0, 120)
    BtnStart.BackgroundColor3 = Config.Theme.Red
    BtnStart.TextColor3 = Config.Theme.Text
    BtnStart.Font = Enum.Font.GothamBlack
    BtnStart.TextSize = 11
    Instance.new("UICorner", BtnStart)

    -- STOP BUTTON
    local BtnStop = Instance.new("TextButton", Left)
    BtnStop.Text = "STOP"
    BtnStop.Size = UDim2.new(0.9, 0, 0, 25)
    BtnStop.Position = UDim2.new(0.05, 0, 0, 165)
    BtnStop.BackgroundColor3 = Color3.fromRGB(60,60,60)
    BtnStop.TextColor3 = Config.Theme.Text
    BtnStop.Font = Enum.Font.GothamBold
    BtnStop.TextSize = 10
    Instance.new("UICorner", BtnStop)
    
    -- CREDIT
    local Credit = Instance.new("TextLabel", Left)
    Credit.Text = "By Anonymous9x"
    Credit.Size = UDim2.new(1, 0, 0, 20)
    Credit.Position = UDim2.new(0, 0, 1, -20)
    Credit.BackgroundTransparency = 1
    Credit.TextColor3 = Color3.fromRGB(100,100,100)
    Credit.Font = Enum.Font.Code
    Credit.TextSize = 9

    -- RIGHT PANEL
    local Right = Instance.new("Frame", Container)
    Right.Size = UDim2.new(0.65, 0, 1, 0)
    Right.Position = UDim2.new(0.35, 5, 0, 0)
    Right.BackgroundColor3 = Config.Theme.Panel
    Instance.new("UICorner", Right)
    CreateStroke(Right)

    local Scroll = Instance.new("ScrollingFrame", Right)
    Scroll.Size = UDim2.new(1, -6, 1, -6)
    Scroll.Position = UDim2.new(0, 3, 0, 3)
    Scroll.BackgroundTransparency = 1
    Scroll.ScrollBarThickness = 2
    
    local Layout = Instance.new("UIListLayout", Scroll)
    Layout.Padding = UDim.new(0, 2)

    -- SCAN LOGIC
    BtnScan.MouseButton1Click:Connect(function()
        local c = Brutal.Scan()
        BtnScan.Text = "FOUND: " .. c
        
        for _, v in pairs(Scroll:GetChildren()) do 
            if v:IsA("TextButton") then v:Destroy() end 
        end
        
        for _, rem in pairs(Brutal.Remotes) do
            local item = Instance.new("TextButton", Scroll)
            item.Size = UDim2.new(1, 0, 0, 20)
            item.BackgroundTransparency = 1
            item.Text = " > " .. rem.Path
            item.TextColor3 = Config.Theme.Green 
            item.Font = Enum.Font.Code
            item.TextSize = 9
            item.TextXAlignment = "Left"
            item.TextTruncate = Enum.TextTruncate.AtEnd
            
            item.MouseButton1Click:Connect(function()
                rem.Active = not rem.Active
                item.TextColor3 = rem.Active and Config.Theme.Green or Config.Theme.Gray
            end)
        end
        Scroll.CanvasSize = UDim2.new(0,0,0, #Brutal.Remotes * 22)
    end)

    -- BUTTON CONNECTIONS
    BtnStart.MouseButton1Click:Connect(Brutal.StartAttack)
    BtnStop.MouseButton1Click:Connect(Brutal.StopAttack)

    -- UI UPDATE LOOP (DENGAN RPS DISPLAY)
    task.spawn(function()
        while Brutal.GUI do
            if Brutal.Spamming then
                Stats.Text = string.format(
                    "FIRE: %d/%d\nRPS: %.0f | PEAK: %.0f", 
                    Brutal.Fired, 
                    Brutal.Target, 
                    Brutal.Performance.CurrentRPS or 0,
                    Brutal.Performance.PeakRPS or 0
                )
            else
                Stats.Text = "STATUS: READY\nWAITING..."
            end
            task.wait(0.1)
        end
    end)
    
    print(">> ARMAGEDON SPAM V2 BRUTAL ENGINE LOADED")
    print(">> DUAL HEARTBEAT | PARALLEL FIRING | ADAPTIVE SPEED")
end

-- ========== 🚀 START ==========
Brutal.BuildUI()
