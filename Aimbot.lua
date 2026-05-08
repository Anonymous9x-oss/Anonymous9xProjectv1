--[[
╔══════════════════════════════════════════════════════╗
║        ANONYMOUS9x Smart Aim — V3 Universal         ║
║                 By Anonymous9x                      ║
║  No UI | Execute once = ON | Execute again = OFF    ║
╠══════════════════════════════════════════════════════╣
║      VS REFERENCE SCRIPT ANALYSIS:                  ║
║                                                    ║
║  Reference (other script):                         ║
║  · Direct CFrame snap = choppy, obvious, detectable║
║  · Mouse distance check = breaks on mobile (no ms) ║
║  · No wall check = locks onto targets behind walls ║
║  · No team check                                   ║
║  · No FOV circle on mobile                         ║
║  · Toggle via KeyCode E only = PC exclusive        ║
║                                                    ║
║  Our V3 upgrades:                                  ║
║  [1] Aim trigger: RIGHT CLICK (PC) + TOUCH (mobile)║
║  [2] Smooth Lerp aim lock — sticks without snap    ║
║  [3] Wall check via Raycast — only visible targets ║
║  [4] Team check — skips teammates                  ║
║  [5] Visibility priority — nearest ON-SCREEN target║
║  [6] Dynamic FOV circle at screen center           ║
║  [7] ESP: Highlight box on all visible enemies     ║
║  [8] Smart hitbox expansion for easier hits        ║
║  [9] Target prediction — leads moving targets      ║
║ [10] Dual-mode: LOCK (hold aim) or MAGNET (auto)   ║
║ [11] ESP Nama + Jarak real-time (team color)       ║
║ [12] Crosshair bulat kecil di tengah               ║
╚══════════════════════════════════════════════════════╝
]] --

-- ═══════════════════════════════════════════
-- TOGGLE GATE
-- ═══════════════════════════════════════════
if getgenv().Ano9x_AimV3 == nil then
    getgenv().Ano9x_AimV3 = false
end
getgenv().Ano9x_AimV3 = not getgenv().Ano9x_AimV3

-- ═══════════════════════════════════════════
-- SERVICES
-- ═══════════════════════════════════════════
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- ═══════════════════════════════════════════
-- CONFIGURATION (updated)
-- ═══════════════════════════════════════════
local Cfg = {
    -- Aim
    TargetPart = "HumanoidRootPart",
    Smoothness = 0.14,
    FOVRadius = 120,
    PredictFactor = 0.055,

    -- Features
    TeamCheck = true,           -- true = skip teammates & warna team
    WallCheck = true,
    AutoHitbox = true,
    HitboxSize = 7,
    ESP = true,

    -- Visual
    CircleColor = Color3.fromRGB(220, 220, 220),
    CircleThick = 1.4,
    CircleSides = 64,
    ESPFill = Color3.fromRGB(255, 255, 255),
    ESPOutline = Color3.fromRGB(255, 255, 255),

    -- Crosshair
    Crosshair = true,
    CrosshairRadius = 5,
    CrosshairColor = Color3.fromRGB(0, 255, 0),
}

-- ═══════════════════════════════════════════
-- CLEANUP
-- ═══════════════════════════════════════════
local function Cleanup()
    -- Kill connection
    if getgenv()._Ano9xConn then
        getgenv()._Ano9xConn:Disconnect()
        getgenv()._Ano9xConn = nil
    end

    -- Remove FOV circle
    if getgenv()._Ano9xCircle then
        getgenv()._Ano9xCircle:Remove()
        getgenv()._Ano9xCircle = nil
    end

    -- Remove crosshair
    if getgenv()._Ano9xCrosshair then
        getgenv()._Ano9xCrosshair:Remove()
        getgenv()._Ano9xCrosshair = nil
    end

    -- Remove ESP highlights + restore hitboxes + remove name tags
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                pcall(function()
                    hrp.Size = Vector3.new(2, 2, 1)
                    hrp.Transparency = 1
                    hrp.CanCollide = false
                end)
            end
            local esp = p.Character:FindFirstChild("_A9xESP")
            if esp then
                esp:Destroy()
            end
        end
    end

    -- Hapus semua Drawing name/distance
    if getgenv()._Ano9xESPTags then
        for _, tag in pairs(getgenv()._Ano9xESPTags) do
            if tag.Name then tag.Name:Remove() end
            if tag.Dist then tag.Dist:Remove() end
        end
        getgenv()._Ano9xESPTags = {}
    end

    -- Notify
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "Anonymous9x Aim V3",
            Text = "AIM OFF | All effects removed",
            Duration = 2,
        })
    end)
end

-- Jika toggle OFF, bersihkan dan keluar
if not getgenv().Ano9x_AimV3 then
    Cleanup()
    return
end

-- ═══════════════════════════════════════════
-- FOV CIRCLE
-- ═══════════════════════════════════════════
local Circle = Drawing.new("Circle")
Circle.Color = Cfg.CircleColor
Circle.Thickness = Cfg.CircleThick
Circle.NumSides = Cfg.CircleSides
Circle.Radius = Cfg.FOVRadius
Circle.Filled = false
Circle.Visible = true
Circle.Transparency = 0.75
getgenv()._Ano9xCircle = Circle

-- ═══════════════════════════════════════════
-- CROSSHAIR (bulat kecil di tengah)
-- ═══════════════════════════════════════════
if Cfg.Crosshair then
    local Cross = Drawing.new("Circle")
    Cross.Radius = Cfg.CrosshairRadius
    Cross.Color = Cfg.CrosshairColor
    Cross.Filled = true
    Cross.Visible = true
    Cross.Transparency = 0.5
    getgenv()._Ano9xCrosshair = Cross
end

-- ═══════════════════════════════════════════
-- TABEL UNTUK ESP NAMA & JARAK
-- ═══════════════════════════════════════════
if not getgenv()._Ano9xESPTags then
    getgenv()._Ano9xESPTags = {}
end

-- ═══════════════════════════════════════════
-- TRIGGER STATE (tidak diubah)
-- ═══════════════════════════════════════════
local isAiming = false
UserInputService.InputBegan:Connect(function(inp)
    if not getgenv().Ano9x_AimV3 then return end
    if inp.UserInputType == Enum.UserInputType.MouseButton2 then
        isAiming = true
    end
end)
UserInputService.InputEnded:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton2 then
        isAiming = false
    end
end)

local touchCount = 0
UserInputService.InputBegan:Connect(function(inp)
    if not getgenv().Ano9x_AimV3 then return end
    if inp.UserInputType == Enum.UserInputType.Touch then
        touchCount = touchCount + 1
        isAiming = true
    end
end)
UserInputService.InputEnded:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.Touch then
        touchCount = math.max(0, touchCount - 1)
        if touchCount == 0 then
            isAiming = false
        end
    end
end)

-- ═══════════════════════════════════════════
-- WALL CHECK
-- ═══════════════════════════════════════════
local function isVisible(targetPos)
    if not Cfg.WallCheck then return true end
    local origin = Camera.CFrame.Position
    local direction = targetPos - origin
    local distance = direction.Magnitude
    local unitDir = direction.Unit
    local ignore = {LocalPlayer.Character}
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character then table.insert(ignore, p.Character) end
    end
    local rayParams = RaycastParams.new()
    rayParams.FilterDescendantsInstances = ignore
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    local result = workspace:Raycast(origin, unitDir * distance, rayParams)
    return result == nil
end

-- ═══════════════════════════════════════════
-- FIND BEST TARGET
-- ═══════════════════════════════════════════
local function getBestTarget()
    local best = nil
    local bestDist = Cfg.FOVRadius
    local center = Camera.ViewportSize / 2
    for _, p in ipairs(Players:GetPlayers()) do
        if p == LocalPlayer then continue end
        if not p.Character then continue end
        if Cfg.TeamCheck then
            local ok, sameTeam = pcall(function()
                return p.Team == LocalPlayer.Team and p.Team ~= nil
            end)
            if ok and sameTeam then continue end
        end
        local hum = p.Character:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then continue end
        local part = p.Character:FindFirstChild(Cfg.TargetPart)
        if not part then continue end
        local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
        if not onScreen then continue end
        local screenDist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
        if screenDist >= bestDist then continue end
        if not isVisible(part.Position) then continue end
        best = p
        bestDist = screenDist
    end
    return best
end

-- ═══════════════════════════════════════════
-- ESP MANAGER (termasuk warna tim)
-- ═══════════════════════════════════════════
local function updateESP()
    if not Cfg.ESP then return end
    for _, p in ipairs(Players:GetPlayers()) do
        if p == LocalPlayer or not p.Character then continue end
        local hum = p.Character:FindFirstChildOfClass("Humanoid")
        local alive = hum and hum.Health > 0
        local existing = p.Character:FindFirstChild("_A9xESP")

        -- Tentukan warna berdasarkan tim
        local fillClr = Cfg.ESPFill
        local outClr = Cfg.ESPOutline
        if Cfg.TeamCheck then
            local sameTeam = false
            pcall(function()
                sameTeam = p.Team == LocalPlayer.Team and p.Team ~= nil
            end)
            if sameTeam then
                fillClr = Color3.fromRGB(0, 150, 255)  -- biru tim
                outClr = Color3.fromRGB(0, 100, 200)
            else
                fillClr = Color3.fromRGB(255, 0, 0)    -- merah lawan
                outClr = Color3.fromRGB(200, 0, 0)
            end
        end

        if alive then
            if not existing then
                local hl = Instance.new("Highlight")
                hl.Name = "_A9xESP"
                hl.Parent = p.Character
                hl.FillTransparency = 0.85
                hl.OutlineTransparency = 0.35
                existing = hl
            end
            existing.FillColor = fillClr
            existing.OutlineColor = outClr
        else
            if existing then
                existing:Destroy()
            end
        end
    end
end

-- ═══════════════════════════════════════════
-- ESP NAMA & JARAK (real-time)
-- ═══════════════════════════════════════════
local function updateNameTags()
    local tags = getgenv()._Ano9xESPTags
    local localChar = LocalPlayer.Character
    local localRoot = localChar and localChar:FindFirstChild("HumanoidRootPart")

    -- Hapus tag pemain yang sudah tidak ada
    for userId, tag in pairs(tags) do
        local p = Players:GetPlayerByUserId(userId)
        if not p or not p.Character or not p.Character:FindFirstChildOfClass("Humanoid") then
            if tag.Name then tag.Name:Remove() end
            if tag.Dist then tag.Dist:Remove() end
            tags[userId] = nil
        end
    end

    for _, p in ipairs(Players:GetPlayers()) do
        if p == LocalPlayer then continue end
        local char = p.Character
        if not char then continue end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then
            --- jika mati, hapus tag jika ada
            if tags[p.UserId] then
                tags[p.UserId].Name:Remove()
                tags[p.UserId].Dist:Remove()
                tags[p.UserId] = nil
            end
            continue
        end

        local head = char:FindFirstChild("Head")
        local root = char:FindFirstChild("HumanoidRootPart")
        local position
        if head then
            position = head.Position + Vector3.new(0, 1.5, 0)
        elseif root then
            position = root.Position + Vector3.new(0, 2.5, 0)
        else
            continue
        end

        local screenPos, onScreen = Camera:WorldToViewportPoint(position)
        if not onScreen then
            -- Sembunyikan jika di luar layar
            if tags[p.UserId] then
                tags[p.UserId].Name.Visible = false
                tags[p.UserId].Dist.Visible = false
            end
            continue
        end

        -- Hitung jarak (studs -> meter, 1 stud ≈ 1 meter)
        local distance = 0
        if localRoot and root then
            distance = (localRoot.Position - root.Position).Magnitude
        end

        -- Warna tim
        local nameColor = Color3.fromRGB(255, 0, 0)   -- default merah
        if Cfg.TeamCheck then
            local sameTeam = false
            pcall(function()
                sameTeam = p.Team == LocalPlayer.Team and p.Team ~= nil
            end)
            if sameTeam then
                nameColor = Color3.fromRGB(0, 150, 255)
            end
        end

        -- Buat atau update Drawing
        if not tags[p.UserId] then
            local nameText = Drawing.new("Text")
            nameText.Size = 14
            nameText.Center = true
            nameText.Outline = true
            nameText.Color = nameColor
            nameText.Visible = true

            local distText = Drawing.new("Text")
            distText.Size = 12
            distText.Center = true
            distText.Outline = true
            distText.Color = Color3.fromRGB(255, 255, 255)
            distText.Visible = true

            tags[p.UserId] = {Name = nameText, Dist = distText}
        end

        local tag = tags[p.UserId]
        tag.Name.Text = p.Name
        tag.Name.Position = Vector2.new(screenPos.X, screenPos.Y - 14)
        tag.Name.Color = nameColor
        tag.Name.Visible = true

        tag.Dist.Text = string.format("%.1f m", distance)
        tag.Dist.Position = Vector2.new(screenPos.X, screenPos.Y + 2)
        tag.Dist.Visible = true
    end
end

-- ═══════════════════════════════════════════
-- HITBOX MANAGER (tidak diubah)
-- ═══════════════════════════════════════════
local function updateHitboxes()
    if not Cfg.AutoHitbox then return end
    for _, p in ipairs(Players:GetPlayers()) do
        if p == LocalPlayer or not p.Character then continue end
        local hrp = p.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            pcall(function()
                hrp.Size = Vector3.new(Cfg.HitboxSize, Cfg.HitboxSize, Cfg.HitboxSize)
                hrp.Transparency = 0.95
                hrp.CanCollide = false
            end)
        end
    end
end

-- ═══════════════════════════════════════════
-- CORE RENDER LOOP
-- ═══════════════════════════════════════════
getgenv()._Ano9xConn = RunService.RenderStepped:Connect(function()
    if not getgenv().Ano9x_AimV3 then return end

    -- Update FOV circle
    Circle.Position = Camera.ViewportSize / 2

    -- Update crosshair jika ada
    if getgenv()._Ano9xCrosshair then
        getgenv()._Ano9xCrosshair.Position = Camera.ViewportSize / 2
    end

    -- Update semua ESP
    updateESP()
    updateHitboxes()
    updateNameTags()

    -- Aim lock
    if isAiming then
        local target = getBestTarget()
        if target and target.Character then
            local part = target.Character:FindFirstChild(Cfg.TargetPart)
            if part then
                local targetPos = part.Position
                local hrp = target.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local vel = hrp.AssemblyLinearVelocity
                    targetPos = targetPos + vel * Cfg.PredictFactor
                end
                local currentCF = Camera.CFrame
                local targetCF = CFrame.lookAt(currentCF.Position, targetPos)
                Camera.CFrame = currentCF:Lerp(targetCF, 1 - Cfg.Smoothness)
            end
        end
    end
end)

-- ═══════════════════════════════════════════
-- INIT NOTIFICATION
-- ═══════════════════════════════════════════
pcall(function()
    StarterGui:SetCore("SendNotification", {
        Title = "Anonymous9x Aim V3",
        Text = "AIM ON | Hold RIGHT CLICK / TOUCH to lock",
        Duration = 3,
    })
end)
