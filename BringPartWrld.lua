-- =============================================================
-- PROJECT: ANONYMOUS9X BRINGPART (V1)
-- THEME: NOIR 
-- LOGIC: Body Thrust
-- STATUS: FINAL VERSION (ENGINE UPGRADED)
-- =============================================================

local Services = {
    Players = game:GetService("Players"),
    RunService = game:GetService("RunService"),
    CoreGui = game:GetService("CoreGui"),
    Workspace = game:GetService("Workspace")
}

local LP = Services.Players.LocalPlayer
local State = {
    Active = false,
    Minimized = false,
    ForcePower = 600, -- Power V17 Murni
    Radius = 2000,
    FPS = 60,
    UpdateTick = 0
}

-- 🛠️ OMEGA-THRUST ENGINE (UPGRADED FOR MAXIMUM POWER & REACH)
local function ApplyOmegaThrust(part, targetPos)
    pcall(function()
        -- [UPGRADE] FORCE NETWORK OWNERSHIP PERSISTENCE
        sethiddenproperty(LP, "SimulationRadius", 1e15)
        sethiddenproperty(LP, "MaxSimulationRadius", 1e15)
        settings().Physics.AllowSleep = false -- Memaksa part tetap aktif di server
        
        local direction = (targetPos - part.Position)
        
        local thrust = part:FindFirstChild("An9xThrust") or Instance.new("BodyThrust")
        thrust.Name = "An9xThrust"
        thrust.Parent = part
        
        -- [UPGRADE] STRENGTH MULTIPLIER (Ditingkatkan agar lebih berat & kuat)
        local mass = part:GetMass()
        local forceForce = direction.Unit * (mass * (State.ForcePower * 1.25)) -- Booster 25% lebih kuat
        thrust.Force = forceForce + Vector3.new(0, mass * 25, 0) -- Anti-Gravity Compensation
        thrust.Location = Vector3.new(0, 0, 0)

        part.RotVelocity = Vector3.new(math.random(-100,100), math.random(-100,100), math.random(-100,100))
        
        part.CanCollide = false
        -- [UPGRADE] VELOCITY LOCK (Mencegah part 'ketinggalan' saat lari cepat)
        part.Velocity = direction.Unit * (State.ForcePower * 0.5) 
    end)
end

-- 🎨 UI CONSTRUCTION (TIDAK DISENTUH SAMA SEKALI - TETAP ORI)
local function BuildUI()
    if Services.CoreGui:FindFirstChild("An9xV22") then Services.CoreGui.An9xV22:Destroy() end
    local Screen = Instance.new("ScreenGui", Services.CoreGui); Screen.Name = "An9xV22"

    local Main = Instance.new("Frame", Screen)
    Main.Size = UDim2.new(0, 330, 0, 430)
    Main.Position = UDim2.new(0.5, -165, 0.4, 0)
    Main.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Main.BorderSizePixel = 0; Main.Active = true; Main.Draggable = true; Main.ClipsDescendants = true
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)
    
    local Stroke = Instance.new("UIStroke", Main)
    Stroke.Color = Color3.fromRGB(255, 255, 255)
    Stroke.Thickness = 2

    -- Header
    local Header = Instance.new("Frame", Main); Header.Size = UDim2.new(1, 0, 0, 50); Header.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    local Title = Instance.new("TextLabel", Header); Title.Text = "ANONYMOUS9X BRINGPART"; Title.Size = UDim2.new(1, -80, 1, 0); Title.Position = UDim2.new(0, 15, 0, 0); Title.TextColor3 = Color3.fromRGB(255, 255, 255); Title.Font = Enum.Font.GothamBlack; Title.TextSize = 13; Title.TextXAlignment = Enum.TextXAlignment.Left; Title.BackgroundTransparency = 1
    
    local MinBtn = Instance.new("TextButton", Header); MinBtn.Text = "−"; MinBtn.Size = UDim2.new(0, 45, 1, 0); MinBtn.Position = UDim2.new(1, -90, 0, 0); MinBtn.BackgroundTransparency = 1; MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255); MinBtn.TextSize = 25
    local CloseBtn = Instance.new("TextButton", Header); CloseBtn.Text = "×"; CloseBtn.Size = UDim2.new(0, 45, 1, 0); CloseBtn.Position = UDim2.new(1, -45, 0, 0); CloseBtn.BackgroundTransparency = 1; CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255); CloseBtn.TextSize = 30

    local Content = Instance.new("Frame", Main); Content.Size = UDim2.new(1, 0, 1, -50); Content.Position = UDim2.new(0, 0, 0, 50); Content.BackgroundTransparency = 1

    -- ⚠️ WARNING TEXT (HIJAU HACKER - REQUESTED)
    local Warn = Instance.new("TextLabel", Content)
    Warn.Size = UDim2.new(0.9, 0, 0, 45); Warn.Position = UDim2.new(0.05, 0, 0, 10)
    Warn.BackgroundColor3 = Color3.fromRGB(15, 15, 15); Warn.TextColor3 = Color3.fromRGB(0, 255, 0) -- Hijau Hacker
    Warn.Font = Enum.Font.Code; Warn.TextSize = 10; Warn.TextWrapped = true
    Warn.Text = "[!] SYSTEM ADVISORY: HEAVY PHYSICS LOAD DETECTED. HIGH PART COUNTS MAY CAUSE FPS REDUCTION."
    Instance.new("UICorner", Warn); 
    Instance.new("UIStroke", Warn).Color = Color3.fromRGB(0, 255, 0)

    -- Stats Container
    local StatsBox = Instance.new("Frame", Content)
    StatsBox.Size = UDim2.new(0.9, 0, 0, 160); StatsBox.Position = UDim2.new(0.05, 0, 0, 65)
    StatsBox.BackgroundColor3 = Color3.fromRGB(10, 10, 10); Instance.new("UICorner", StatsBox)
    Instance.new("UIStroke", StatsBox).Color = Color3.fromRGB(60, 60, 60)

    local function CreateLabel(pos)
        local l = Instance.new("TextLabel", StatsBox)
        l.Size = UDim2.new(1, -20, 0, 25); l.Position = pos; l.BackgroundTransparency = 1
        l.TextColor3 = Color3.fromRGB(255, 255, 255); l.Font = Enum.Font.Code; l.TextSize = 12
        l.TextXAlignment = Enum.TextXAlignment.Left
        return l
    end

    local LabelFPS = CreateLabel(UDim2.new(0, 15, 0, 10))
    local LabelCreated = CreateLabel(UDim2.new(0, 15, 0, 35)); LabelCreated.Text = "Created : Anonymous9x"
    local LabelParts = CreateLabel(UDim2.new(0, 15, 0, 60))
    local LabelPower = CreateLabel(UDim2.new(0, 15, 0, 85))
    local LabelScan = CreateLabel(UDim2.new(0, 15, 0, 110))
    LabelScan.TextColor3 = Color3.fromRGB(255, 255, 255); LabelScan.TextWrapped = true; LabelScan.Size = UDim2.new(1, -20, 0, 45)

    -- Action Button
    local ActionBtn = Instance.new("TextButton", Content)
    ActionBtn.Size = UDim2.new(0.9, 0, 0, 65); ActionBtn.Position = UDim2.new(0.05, 0, 1, -115)
    ActionBtn.Text = "BringPart World"
    ActionBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255); ActionBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
    ActionBtn.Font = Enum.Font.GothamBlack; ActionBtn.TextSize = 16; Instance.new("UICorner", ActionBtn)

    ActionBtn.MouseButton1Click:Connect(function()
        State.Active = not State.Active
        ActionBtn.Text = State.Active and "BRINGWORLD ACTIVE" or "BringPart World"
        ActionBtn.TextColor3 = State.Active and Color3.fromRGB(200, 0, 0) or Color3.fromRGB(0, 0, 0)
    end)

    MinBtn.MouseButton1Click:Connect(function()
        State.Minimized = not State.Minimized
        Content.Visible = not State.Minimized
        Main:TweenSize(State.Minimized and UDim2.new(0, 330, 0, 50) or UDim2.new(0, 330, 0, 430), "Out", "Quad", 0.3, true)
        MinBtn.Text = State.Minimized and "+" or "−"
    end)

    CloseBtn.MouseButton1Click:Connect(function() State.Active = false; Screen:Destroy() end)

    -- ⚙️ THE HEARTBEAT LOOP (ENGINE UPGRADED FOR BETTER SCANNING)
    Services.RunService.Heartbeat:Connect(function()
        if tick() - State.UpdateTick > 1 then
            State.FPS = math.floor(1/Services.RunService.RenderStepped:Wait())
            LabelFPS.Text = string.format("FPS Real-time : %d", State.FPS)
            
            local potentialParts = 0
            for _, v in pairs(Services.Workspace:GetDescendants()) do
                if v:IsA("BasePart") and not v.Anchored and not v:IsDescendantOf(LP.Character) then
                    potentialParts = potentialParts + 1
                end
            end
            
            if potentialParts > 300 then
                LabelScan.Text = "Scan: High potential for total world chaos detected!"
            elseif potentialParts > 50 then
                LabelScan.Text = "Scan: Moderate physics activity available."
            else
                LabelScan.Text = "Scan: Low part count detected."
            end
            State.UpdateTick = tick()
        end

        LabelPower.Text = string.format("Power Real-time : %d OMEGA", State.ForcePower)
        
        if not State.Active then 
            LabelParts.Text = "Real Part Push : 0"
            return 
        end
        
        local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        local count = 0
        for _, v in pairs(Services.Workspace:GetDescendants()) do
            -- [UPGRADE] RADIUS CHECK INTEGRATION (Lebih Luas & Terarah)
            if v:IsA("BasePart") and not v.Anchored then
                if not v:IsDescendantOf(LP.Character) and v.Name ~= "Baseplate" then
                    if (v.Position - hrp.Position).Magnitude < State.Radius then
                        if not v.Parent:FindFirstChildOfClass("Humanoid") then
                            count = count + 1
                            ApplyOmegaThrust(v, hrp.Position + Vector3.new(0, 20, 0))
                        end
                    end
                end
            end
        end
        LabelParts.Text = string.format("Real Part Push : %d", count)
    end)
end

BuildUI()
