-- =============================================================
-- PROJECT: ANONYMOUS9X FOLLOW (V3)
-- THEME: NOIR (RADAR EDITION)
-- LOGIC: HYBRID TWEEN + JAILBREAKER + REALTIME STUDS
-- STATUS: FE UNIVERSAL (Visible & Sticky)
-- =============================================================

local Services = {
    Players = game:GetService("Players"),
    RunService = game:GetService("RunService"),
    TweenService = game:GetService("TweenService"),
    UserInputService = game:GetService("UserInputService"),
    CoreGui = game:GetService("CoreGui"),
    Workspace = game:GetService("Workspace")
}

local LP = Services.Players.LocalPlayer
local State = {
    Active = false,
    Target = nil,
    Minimized = false,
    TweenSpeed = 0.06, -- Speed Jailbreak
    Offset = CFrame.new(0, 0, 3.5) -- Jarak tempel aman
}

-- 🛠️ LOGIC: PHYSICS ENGINE (JAILBREAKER)
local function GetRoot(char)
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function GetDist(p)
    if p and p.Character and GetRoot(p.Character) and LP.Character and GetRoot(LP.Character) then
        return (GetRoot(p.Character).Position - GetRoot(LP.Character).Position).Magnitude
    end
    return 999999 -- Anggap Inf jauh banget
end

-- Loop Utama (Physics)
Services.RunService.Heartbeat:Connect(function()
    if not State.Active or not State.Target then return end
    
    local myChar = LP.Character
    local targetChar = State.Target.Character
    
    if not myChar or not targetChar then return end
    
    local myRoot = GetRoot(myChar)
    local targetRoot = GetRoot(targetChar)
    local myHum = myChar:FindFirstChildOfClass("Humanoid")
    
    if myRoot and targetRoot and myHum then
        -- Force Lepas Jail/Anchor
        for _, part in pairs(myChar:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
                part.Anchored = false
            end
        end
        
        -- Logic Tween Nempel
        local targetCFrame = targetRoot.CFrame
        local desiredPos = targetCFrame * State.Offset
        local lookAt = CFrame.new(desiredPos.Position, targetRoot.Position)
        
        local info = TweenInfo.new(State.TweenSpeed, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
        local tween = Services.TweenService:Create(myRoot, info, {CFrame = lookAt})
        tween:Play()
        
        -- Stabilizer
        myRoot.Velocity = Vector3.new(0,0,0)
        myRoot.RotVelocity = Vector3.new(0,0,0)
        myHum.PlatformStand = true
    end
end)

-- 🎨 UI SYSTEM (NOIR + RADAR STUDS)
local function BuildUI()
    if Services.CoreGui:FindFirstChild("An9xFollowV3") then Services.CoreGui.An9xFollowV3:Destroy() end
    local Screen = Instance.new("ScreenGui", Services.CoreGui); Screen.Name = "An9xFollowV3"
    Screen.ResetOnSpawn = false

    local Main = Instance.new("Frame", Screen)
    Main.Size = UDim2.new(0, 260, 0, 340) -- Sedikit lebih tinggi buat list
    Main.Position = UDim2.new(0.5, -130, 0.3, 0)
    Main.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Main.BorderSizePixel = 0; Main.Active = true; Main.ClipsDescendants = true
    
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)
    local Stroke = Instance.new("UIStroke", Main); Stroke.Color = Color3.fromRGB(255, 255, 255); Stroke.Thickness = 2

    -- Drag Logic
    local dragging, dragInput, dragStart, startPos
    local function update(input)
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    Main.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = Main.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    Main.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
    end)
    Services.UserInputService.InputChanged:Connect(function(input) if input == dragInput and dragging then update(input) end end)

    -- Header
    local Header = Instance.new("Frame", Main); Header.Size = UDim2.new(1, 0, 0, 35); Header.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    local Title = Instance.new("TextLabel", Header); Title.Text = "ANONYMOUS9X FOLLOW"; Title.Size = UDim2.new(1, -60, 1, 0); Title.Position = UDim2.new(0, 10, 0, 0); Title.TextColor3 = Color3.fromRGB(255, 255, 255); Title.Font = Enum.Font.GothamBlack; Title.TextSize = 11; Title.TextXAlignment = Enum.TextXAlignment.Left; Title.BackgroundTransparency = 1
    
    local MinBtn = Instance.new("TextButton", Header); MinBtn.Text = "−"; MinBtn.Size = UDim2.new(0, 25, 1, 0); MinBtn.Position = UDim2.new(1, -55, 0, 0); MinBtn.BackgroundTransparency = 1; MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255); MinBtn.TextSize = 20
    local CloseBtn = Instance.new("TextButton", Header); CloseBtn.Text = "×"; CloseBtn.Size = UDim2.new(0, 25, 1, 0); CloseBtn.Position = UDim2.new(1, -25, 0, 0); CloseBtn.BackgroundTransparency = 1; CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255); CloseBtn.TextSize = 20

    local Content = Instance.new("Frame", Main); Content.Size = UDim2.new(1, 0, 1, -35); Content.Position = UDim2.new(0, 0, 0, 35); Content.BackgroundTransparency = 1

    -- Target Info
    local TargetTxt = Instance.new("TextLabel", Content)
    TargetTxt.Size = UDim2.new(0.9, 0, 0, 20); TargetTxt.Position = UDim2.new(0.05, 0, 0, 5)
    TargetTxt.BackgroundTransparency = 1; TargetTxt.TextColor3 = Color3.fromRGB(150, 150, 150)
    TargetTxt.Font = Enum.Font.Code; TargetTxt.TextSize = 10; TargetTxt.Text = "TARGET: NONE"

    -- Scrolling List
    local Scroll = Instance.new("ScrollingFrame", Content)
    Scroll.Size = UDim2.new(0.9, 0, 1, -80); Scroll.Position = UDim2.new(0.05, 0, 0, 30)
    Scroll.BackgroundColor3 = Color3.fromRGB(10, 10, 10); Scroll.BorderSizePixel = 0
    Scroll.ScrollBarThickness = 2
    Instance.new("UICorner", Scroll).CornerRadius = UDim.new(0, 6)
    local ListLayout = Instance.new("UIListLayout", Scroll); ListLayout.SortOrder = Enum.SortOrder.LayoutOrder; ListLayout.Padding = UDim.new(0, 2)
    Instance.new("UIPadding", Scroll).PaddingTop = UDim.new(0, 5); Instance.new("UIPadding", Scroll).PaddingLeft = UDim.new(0, 5)

    -- Action Button
    local ActionBtn = Instance.new("TextButton", Content)
    ActionBtn.Size = UDim2.new(0.9, 0, 0, 35); ActionBtn.Position = UDim2.new(0.05, 0, 1, -45)
    ActionBtn.Text = "START FOLLOW"
    ActionBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255); ActionBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
    ActionBtn.Font = Enum.Font.GothamBlack; ActionBtn.TextSize = 12; Instance.new("UICorner", ActionBtn).CornerRadius = UDim.new(0, 6)

    -- LOGIC LIST PLAYER & STUDS MONITOR
    local PlayerBtns = {} -- Table menyimpan {Player = Button}

    -- 1. Buat Button Baru
    local function AddButton(p)
        if PlayerBtns[p] then return end
        local btn = Instance.new("TextButton", Scroll)
        btn.Size = UDim2.new(1, -10, 0, 25)
        btn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.Gotham; btn.TextSize = 11
        btn.TextXAlignment = Enum.TextXAlignment.Left
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)

        btn.MouseButton1Click:Connect(function()
            State.Target = p
            TargetTxt.Text = "TARGET: " .. string.upper(p.Name)
            -- Reset warna semua tombol
            for _, b in pairs(PlayerBtns) do b.BackgroundColor3 = Color3.fromRGB(20, 20, 20) end
            btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        end)
        
        PlayerBtns[p] = btn
    end

    -- 2. Hapus Button Player Keluar
    local function CleanupButtons()
        for p, btn in pairs(PlayerBtns) do
            if not p or not p.Parent then
                btn:Destroy()
                PlayerBtns[p] = nil
            end
        end
    end

    -- 3. Loop Update Jarak (Studs) & Sorting
    spawn(function()
        while Screen.Parent do
            CleanupButtons()
            -- Cek player baru
            for _, p in pairs(Services.Players:GetPlayers()) do
                if p ~= LP then AddButton(p) end
            end
            
            -- Update Text Studs
            for p, btn in pairs(PlayerBtns) do
                local dist = GetDist(p)
                local distText = (dist > 90000) and "Inf" or string.format("%d", dist)
                
                -- Format: Nama [Jarak]
                btn.Text = string.format("  %s [%s Studs]", p.DisplayName, distText)
                
                -- Sorting: Yang dekat ditaruh di atas
                btn.LayoutOrder = (dist > 90000) and 9999 or dist
            end
            
            Scroll.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y + 10)
            wait(0.5) -- Update tiap setengah detik biar ga lag
        end
    end)

    -- Tombol Actions
    ActionBtn.MouseButton1Click:Connect(function()
        if not State.Target then ActionBtn.Text = "SELECT TARGET!"; wait(1); ActionBtn.Text = "START FOLLOW"; return end
        State.Active = not State.Active
        ActionBtn.Text = State.Active and "STOP FOLLOW" or "START FOLLOW"
        ActionBtn.TextColor3 = State.Active and Color3.fromRGB(200, 0, 0) or Color3.fromRGB(0, 0, 0)
        
        if not State.Active and LP.Character then
            LP.Character.Humanoid.PlatformStand = false
            for _, v in pairs(LP.Character:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide = true end
            end
        end
    end)

    MinBtn.MouseButton1Click:Connect(function()
        State.Minimized = not State.Minimized
        Content.Visible = not State.Minimized
        Main:TweenSize(State.Minimized and UDim2.new(0, 260, 0, 35) or UDim2.new(0, 260, 0, 340), "Out", "Quad", 0.3, true)
        MinBtn.Text = State.Minimized and "+" or "−"
    end)

    CloseBtn.MouseButton1Click:Connect(function()
        State.Active = false
        if LP.Character then LP.Character.Humanoid.PlatformStand = false end
        Screen:Destroy()
    end)
end

BuildUI()
