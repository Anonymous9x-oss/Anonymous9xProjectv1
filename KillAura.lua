--[[
    ╔══════════════════════════════════════════════════════╗
    ║   Ano9x Aura Sigma 99999+                            ║
    ║   Universal Kill Aura — FE Engine                    ║
    ║   Delta Mobile / iOS Only                            ║
    ╠══════════════════════════════════════════════════════╣
    ║   KILL METHODS:                                      ║
    ║   [A] Humanoid.Health = 0        (NPC / weak-FE)     ║
    ║   [B] Humanoid:TakeDamage(99999) (FE partial)        ║
    ║   [C] BodyVelocity Fling         (universal FE void) ║
    ║   [D] Heartbeat Scan  @ 0.15s    (range proximity)   ║
    ║   [E] Part.Touched Sphere        (hitbox trigger)     ║
    ╠══════════════════════════════════════════════════════╣
    ║   BEST GAME TYPES:                                   ║
    ║   Obby  /  RPG  /  Simulator  /  Open World          ║
    ╠══════════════════════════════════════════════════════╣
    ║   PLAYER KILL (FE):                                  ║
    ║   Health = 0 works if game lacks server protection.  ║
    ║   Fling is the near-universal FE fallback.           ║
    ║   NPC Kill works on standard Roblox Humanoid only.   ║
    ╚══════════════════════════════════════════════════════╝
]]

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Debris           = game:GetService("Debris")
local LocalPlayer      = Players.LocalPlayer

-- ══════════════════════════════════════════════════════════════════
--  DESTROY OLD INSTANCE
-- ══════════════════════════════════════════════════════════════════
pcall(function()
    game.CoreGui:FindFirstChild("__Ano9xAura"):Destroy()
end)

-- ══════════════════════════════════════════════════════════════════
--  CONSTANTS
-- ══════════════════════════════════════════════════════════════════
local PW         = 162        -- panel width  px
local PH_FULL    = 165        -- panel height px (expanded)
local PH_MIN     = 22         -- panel height px (minimized)
local currentPH  = PH_FULL    -- tracks live height for spark

-- ══════════════════════════════════════════════════════════════════
--  STATE
-- ══════════════════════════════════════════════════════════════════
local S = {
    auraOn    = false,
    visualOn  = false,
    range     = 30,
    kills     = 0,
    minimized = false,
}

local _auraConn      = nil
local _scanTimer     = 0
local _hitboxPart    = nil
local _hitboxFollow  = nil
local _touchConn     = nil
local _visualPart    = nil
local _visualFollow  = nil
local _killDebounce  = {}
local _sparkAlive    = true

-- ══════════════════════════════════════════════════════════════════
--  SCREEN GUI
-- ══════════════════════════════════════════════════════════════════
local gui = Instance.new("ScreenGui")
gui.Name           = "__Ano9xAura"
gui.ResetOnSpawn   = false
gui.DisplayOrder   = 998
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function() gui.Parent = game.CoreGui end)
if not gui.Parent then gui.Parent = LocalPlayer.PlayerGui end

-- ══════════════════════════════════════════════════════════════════
--  MAIN PANEL
-- ══════════════════════════════════════════════════════════════════
local panel = Instance.new("Frame")
panel.Name                   = "Panel"
panel.Size                   = UDim2.new(0, PW, 0, PH_FULL)
panel.Position               = UDim2.new(0.5, -(PW / 2), 0, 80)
panel.BackgroundColor3       = Color3.new(0, 0, 0)
panel.BackgroundTransparency = 0
panel.BorderSizePixel        = 0
panel.ClipsDescendants       = false
panel.ZIndex                 = 10
panel.Parent                 = gui
Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 6)

-- Static white border
local panelBorder = Instance.new("UIStroke")
panelBorder.Color       = Color3.new(1, 1, 1)
panelBorder.Thickness   = 1.3
panelBorder.Transparency = 0
panelBorder.Parent      = panel

-- ══════════════════════════════════════════════════════════════════
--  ANIMATED BORDER — white spark traveling clockwise
--  This is the ONLY animation on the panel itself.
--  Background never flickers.
-- ══════════════════════════════════════════════════════════════════
local spark = Instance.new("Frame")
spark.Name                   = "Spark"
spark.BackgroundColor3       = Color3.new(1, 1, 1)
spark.BackgroundTransparency = 0
spark.BorderSizePixel        = 0
spark.ZIndex                 = 22
spark.Parent                 = panel
Instance.new("UICorner", spark).CornerRadius = UDim.new(1, 0)

local SPARK_LEN = 38
local SPARK_SPD = 0.46  -- seconds per side

task.spawn(function()
    while _sparkAlive do
        local H = currentPH
        -- TOP  left → right
        spark.Size     = UDim2.new(0, SPARK_LEN, 0, 2)
        spark.Position = UDim2.new(0, 0, 0, 0)
        TweenService:Create(spark,
            TweenInfo.new(SPARK_SPD, Enum.EasingStyle.Linear),
            {Position = UDim2.new(0, PW - SPARK_LEN, 0, 0)}
        ):Play()
        task.wait(SPARK_SPD)
        if not _sparkAlive then break end

        -- RIGHT  top → bottom
        spark.Size     = UDim2.new(0, 2, 0, SPARK_LEN)
        spark.Position = UDim2.new(0, PW - 2, 0, 0)
        TweenService:Create(spark,
            TweenInfo.new(SPARK_SPD, Enum.EasingStyle.Linear),
            {Position = UDim2.new(0, PW - 2, 0, H - SPARK_LEN)}
        ):Play()
        task.wait(SPARK_SPD)
        if not _sparkAlive then break end

        -- BOTTOM  right → left
        spark.Size     = UDim2.new(0, SPARK_LEN, 0, 2)
        spark.Position = UDim2.new(0, PW - SPARK_LEN, 0, H - 2)
        TweenService:Create(spark,
            TweenInfo.new(SPARK_SPD, Enum.EasingStyle.Linear),
            {Position = UDim2.new(0, 0, 0, H - 2)}
        ):Play()
        task.wait(SPARK_SPD)
        if not _sparkAlive then break end

        -- LEFT  bottom → top
        spark.Size     = UDim2.new(0, 2, 0, SPARK_LEN)
        spark.Position = UDim2.new(0, 0, 0, H - SPARK_LEN)
        TweenService:Create(spark,
            TweenInfo.new(SPARK_SPD, Enum.EasingStyle.Linear),
            {Position = UDim2.new(0, 0, 0, 0)}
        ):Play()
        task.wait(SPARK_SPD)
    end
end)

-- ══════════════════════════════════════════════════════════════════
--  TITLE BAR
-- ══════════════════════════════════════════════════════════════════
local titleBar = Instance.new("Frame")
titleBar.Size                   = UDim2.new(1, 0, 0, 22)
titleBar.Position               = UDim2.new(0, 0, 0, 0)
titleBar.BackgroundColor3       = Color3.new(0.07, 0.07, 0.07)
titleBar.BackgroundTransparency = 0
titleBar.BorderSizePixel        = 0
titleBar.ZIndex                 = 11
titleBar.Parent                 = panel
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 6)

local titleLbl = Instance.new("TextLabel")
titleLbl.Size               = UDim2.new(1, -48, 1, 0)
titleLbl.Position           = UDim2.new(0, 7, 0, 0)
titleLbl.BackgroundTransparency = 1
titleLbl.Text               = "Ano9x Aura Sigma 99999+"
titleLbl.Font               = Enum.Font.GothamBold
titleLbl.TextSize           = 8
titleLbl.TextColor3         = Color3.new(1, 1, 1)
titleLbl.TextXAlignment     = Enum.TextXAlignment.Left
titleLbl.TextTruncate       = Enum.TextTruncate.AtEnd
titleLbl.ZIndex             = 12
titleLbl.Parent             = titleBar

local function makeTitleBtn(xOff, label)
    local b = Instance.new("TextButton")
    b.Size             = UDim2.new(0, 16, 0, 14)
    b.Position         = UDim2.new(1, xOff, 0.5, -7)
    b.BackgroundColor3 = Color3.new(0.15, 0.15, 0.15)
    b.BorderSizePixel  = 0
    b.Text             = label
    b.Font             = Enum.Font.GothamBold
    b.TextSize         = 9
    b.TextColor3       = Color3.new(1, 1, 1)
    b.ZIndex           = 13
    b.Parent           = titleBar
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 3)
    local s = Instance.new("UIStroke")
    s.Color     = Color3.new(0.38, 0.38, 0.38)
    s.Thickness = 0.6
    s.Parent    = b
    return b
end

local minBtn   = makeTitleBtn(-36, "_")
local closeBtn = makeTitleBtn(-18, "X")

-- ══════════════════════════════════════════════════════════════════
--  CONTENT FRAME
-- ══════════════════════════════════════════════════════════════════
local content = Instance.new("Frame")
content.Size                 = UDim2.new(1, 0, 1, -22)
content.Position             = UDim2.new(0, 0, 0, 22)
content.BackgroundTransparency = 1
content.ClipsDescendants     = true
content.ZIndex               = 11
content.Parent               = panel

local cPad = Instance.new("UIPadding")
cPad.PaddingLeft   = UDim.new(0, 7)
cPad.PaddingRight  = UDim.new(0, 7)
cPad.PaddingTop    = UDim.new(0, 7)
cPad.PaddingBottom = UDim.new(0, 7)
cPad.Parent        = content

local cList = Instance.new("UIListLayout")
cList.SortOrder = Enum.SortOrder.LayoutOrder
cList.Padding   = UDim.new(0, 5)
cList.Parent    = content

-- ── HELPER: create a toggle-style button ──────────────────────────
local function makeRowBtn(text, order, h)
    local b = Instance.new("TextButton")
    b.Size             = UDim2.new(1, 0, 0, h or 25)
    b.BackgroundColor3 = Color3.new(0.09, 0.09, 0.09)
    b.BorderSizePixel  = 0
    b.Text             = text
    b.Font             = Enum.Font.GothamBold
    b.TextSize         = 9
    b.TextColor3       = Color3.new(0.48, 0.48, 0.48)
    b.LayoutOrder      = order
    b.ZIndex           = 12
    b.Parent           = content
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
    local bs = Instance.new("UIStroke")
    bs.Color     = Color3.new(0.28, 0.28, 0.28)
    bs.Thickness = 0.8
    bs.Parent    = b
    return b, bs
end

-- ── Kill Aura Button ──────────────────────────────────────────────
local killBtn, killBtnS = makeRowBtn("KILL AURA  :  INACTIVE", 1, 27)

-- ── Range Row ─────────────────────────────────────────────────────
local rangeRow = Instance.new("Frame")
rangeRow.Size                 = UDim2.new(1, 0, 0, 20)
rangeRow.BackgroundTransparency = 1
rangeRow.LayoutOrder          = 2
rangeRow.ZIndex               = 12
rangeRow.Parent               = content

local rRowL = Instance.new("UIListLayout")
rRowL.FillDirection     = Enum.FillDirection.Horizontal
rRowL.VerticalAlignment = Enum.VerticalAlignment.Center
rRowL.Padding           = UDim.new(0, 4)
rRowL.Parent            = rangeRow

local rangeLbl = Instance.new("TextLabel")
rangeLbl.Size             = UDim2.new(0, 44, 1, 0)
rangeLbl.BackgroundTransparency = 1
rangeLbl.Text             = "RANGE"
rangeLbl.Font             = Enum.Font.GothamSemibold
rangeLbl.TextSize         = 8
rangeLbl.TextColor3       = Color3.new(0.70, 0.70, 0.70)
rangeLbl.TextXAlignment   = Enum.TextXAlignment.Left
rangeLbl.ZIndex           = 12
rangeLbl.Parent           = rangeRow

local rangeBox = Instance.new("TextBox")
rangeBox.Size             = UDim2.new(1, -48, 1, 0)
rangeBox.BackgroundColor3 = Color3.new(0.09, 0.09, 0.09)
rangeBox.BorderSizePixel  = 0
rangeBox.Text             = tostring(S.range)
rangeBox.Font             = Enum.Font.GothamSemibold
rangeBox.TextSize         = 9
rangeBox.TextColor3       = Color3.new(1, 1, 1)
rangeBox.PlaceholderText  = "studs"
rangeBox.PlaceholderColor3 = Color3.new(0.36, 0.36, 0.36)
rangeBox.ClearTextOnFocus = false
rangeBox.ZIndex           = 12
rangeBox.Parent           = rangeRow
Instance.new("UICorner", rangeBox).CornerRadius = UDim.new(0, 3)
local rbS = Instance.new("UIStroke")
rbS.Color     = Color3.new(0.28, 0.28, 0.28)
rbS.Thickness = 0.8
rbS.Parent    = rangeBox

-- ── Visualizer Button ─────────────────────────────────────────────
local visBtn, visBtnS = makeRowBtn("VISUALIZER  :  OFF", 3, 24)

-- ── Status Frame ──────────────────────────────────────────────────
local statFrame = Instance.new("Frame")
statFrame.Size             = UDim2.new(1, 0, 0, 44)
statFrame.BackgroundColor3 = Color3.new(0.05, 0.05, 0.05)
statFrame.BorderSizePixel  = 0
statFrame.LayoutOrder      = 4
statFrame.ZIndex           = 12
statFrame.Parent           = content
Instance.new("UICorner", statFrame).CornerRadius = UDim.new(0, 4)
local sfS = Instance.new("UIStroke")
sfS.Color     = Color3.new(0.18, 0.18, 0.18)
sfS.Thickness = 0.8
sfS.Parent    = statFrame

local sfPad = Instance.new("UIPadding")
sfPad.PaddingLeft = UDim.new(0, 6)
sfPad.PaddingTop  = UDim.new(0, 4)
sfPad.Parent      = statFrame

local sfList = Instance.new("UIListLayout")
sfList.Padding = UDim.new(0, 2)
sfList.Parent  = statFrame

local function makeStat(order)
    local l = Instance.new("TextLabel")
    l.Size               = UDim2.new(1, -8, 0, 11)
    l.BackgroundTransparency = 1
    l.Font               = Enum.Font.Gotham
    l.TextSize           = 8
    l.TextColor3         = Color3.new(0.65, 0.65, 0.65)
    l.TextXAlignment     = Enum.TextXAlignment.Left
    l.LayoutOrder        = order
    l.ZIndex             = 13
    l.Parent             = statFrame
    return l
end

local sKills  = makeStat(1)
local sRange  = makeStat(2)
local sStatus = makeStat(3)

local function refreshStatus()
    sKills.Text  = "Kills     " .. S.kills
    sRange.Text  = "Range     " .. S.range .. " studs"
    sStatus.Text = "Status    " .. (S.auraOn and "ACTIVE" or "INACTIVE")
    sStatus.TextColor3 = S.auraOn
        and Color3.new(1, 1, 1)
        or  Color3.new(0.40, 0.40, 0.40)
end
refreshStatus()

-- ══════════════════════════════════════════════════════════════════
--  NOTIFICATION SYSTEM
--  Position: bottom-right corner, small, black bg / white text
--  Stacks upward. Fades in/out (no slide to avoid clash with GUI)
-- ══════════════════════════════════════════════════════════════════
local nHolder = Instance.new("Frame")
nHolder.Name                = "NotifHolder"
nHolder.Size                = UDim2.new(0, 202, 0, 300)
nHolder.Position            = UDim2.new(1, -210, 1, -308)
nHolder.BackgroundTransparency = 1
nHolder.ZIndex              = 200
nHolder.Parent              = gui

local nList = Instance.new("UIListLayout")
nList.SortOrder         = Enum.SortOrder.LayoutOrder
nList.VerticalAlignment = Enum.VerticalAlignment.Bottom
nList.Padding           = UDim.new(0, 4)
nList.Parent            = nHolder

local _nCount = 0

local function showNotif(line1, line2, secs)
    secs    = secs or 4
    _nCount = _nCount + 1

    local h  = (line2 and line2 ~= "") and 42 or 26
    local nf = Instance.new("Frame")
    nf.Size             = UDim2.new(1, 0, 0, h)
    nf.BackgroundColor3 = Color3.new(0, 0, 0)
    nf.BackgroundTransparency = 0.90   -- start invisible
    nf.BorderSizePixel  = 0
    nf.LayoutOrder      = _nCount
    nf.ZIndex           = 201
    nf.Parent           = nHolder
    Instance.new("UICorner", nf).CornerRadius = UDim.new(0, 4)

    local nfBdr = Instance.new("UIStroke")
    nfBdr.Color       = Color3.new(1, 1, 1)
    nfBdr.Thickness   = 0.8
    nfBdr.Transparency = 1
    nfBdr.Parent      = nf

    local nPad = Instance.new("UIPadding")
    nPad.PaddingLeft = UDim.new(0, 6)
    nPad.PaddingTop  = UDim.new(0, 4)
    nPad.Parent      = nf

    local nLL = Instance.new("UIListLayout")
    nLL.Padding = UDim.new(0, 2)
    nLL.Parent  = nf

    local nl1 = Instance.new("TextLabel")
    nl1.Size               = UDim2.new(1, -8, 0, 13)
    nl1.BackgroundTransparency = 1
    nl1.Text               = line1
    nl1.Font               = Enum.Font.GothamBold
    nl1.TextSize           = 8
    nl1.TextColor3         = Color3.new(1, 1, 1)
    nl1.TextTransparency   = 1
    nl1.TextXAlignment     = Enum.TextXAlignment.Left
    nl1.TextTruncate       = Enum.TextTruncate.AtEnd
    nl1.ZIndex             = 202
    nl1.Parent             = nf

    local nl2 = nil
    if line2 and line2 ~= "" then
        nl2 = Instance.new("TextLabel")
        nl2.Size               = UDim2.new(1, -8, 0, 11)
        nl2.BackgroundTransparency = 1
        nl2.Text               = line2
        nl2.Font               = Enum.Font.Gotham
        nl2.TextSize           = 8
        nl2.TextColor3         = Color3.new(0.60, 0.60, 0.60)
        nl2.TextTransparency   = 1
        nl2.TextXAlignment     = Enum.TextXAlignment.Left
        nl2.TextTruncate       = Enum.TextTruncate.AtEnd
        nl2.ZIndex             = 202
        nl2.Parent             = nf
    end

    local T = TweenInfo.new(0.18, Enum.EasingStyle.Quad)
    TweenService:Create(nf,    T, {BackgroundTransparency = 0.08}):Play()
    TweenService:Create(nfBdr, T, {Transparency = 0.20}):Play()
    TweenService:Create(nl1,   T, {TextTransparency = 0}):Play()
    if nl2 then TweenService:Create(nl2, T, {TextTransparency = 0}):Play() end

    task.delay(secs, function()
        local T2 = TweenInfo.new(0.18, Enum.EasingStyle.Quad)
        TweenService:Create(nf,    T2, {BackgroundTransparency = 1}):Play()
        TweenService:Create(nfBdr, T2, {Transparency = 1}):Play()
        TweenService:Create(nl1,   T2, {TextTransparency = 1}):Play()
        if nl2 then TweenService:Create(nl2, T2, {TextTransparency = 1}):Play() end
        task.delay(0.22, function() pcall(function() nf:Destroy() end) end)
    end)
end

-- ══════════════════════════════════════════════════════════════════
--  DRAG (touch + mouse, on title bar only)
-- ══════════════════════════════════════════════════════════════════
do
    local _drag, _ds, _pp = false, nil, nil

    titleBar.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.Touch or
           inp.UserInputType == Enum.UserInputType.MouseButton1 then
            _drag = true
            _ds   = Vector2.new(inp.Position.X, inp.Position.Y)
            _pp   = Vector2.new(panel.Position.X.Offset, panel.Position.Y.Offset)
        end
    end)

    UserInputService.InputChanged:Connect(function(inp)
        if not _drag then return end
        if inp.UserInputType == Enum.UserInputType.Touch or
           inp.UserInputType == Enum.UserInputType.MouseMove then
            local d = Vector2.new(inp.Position.X, inp.Position.Y) - _ds
            panel.Position = UDim2.new(0, _pp.X + d.X, 0, _pp.Y + d.Y)
        end
    end)

    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.Touch or
           inp.UserInputType == Enum.UserInputType.MouseButton1 then
            _drag = false
        end
    end)
end

-- ══════════════════════════════════════════════════════════════════
--  MINIMIZE / CLOSE
-- ══════════════════════════════════════════════════════════════════
minBtn.MouseButton1Click:Connect(function()
    S.minimized = not S.minimized
    local targetH = S.minimized and PH_MIN or PH_FULL
    currentPH     = targetH
    content.Visible = not S.minimized
    TweenService:Create(panel,
        TweenInfo.new(0.18, Enum.EasingStyle.Quad),
        {Size = UDim2.new(0, PW, 0, targetH)}
    ):Play()
    minBtn.Text = S.minimized and "+" or "_"
end)

closeBtn.MouseButton1Click:Connect(function()
    _sparkAlive = false
    if _auraConn     then _auraConn:Disconnect()     end
    if _hitboxFollow then _hitboxFollow:Disconnect()  end
    if _touchConn    then _touchConn:Disconnect()     end
    if _visualFollow then _visualFollow:Disconnect()  end
    pcall(function() if _hitboxPart then _hitboxPart:Destroy() end end)
    pcall(function() if _visualPart then _visualPart:Destroy() end end)
    pcall(function() gui:Destroy() end)
end)

-- ══════════════════════════════════════════════════════════════════
--  KILL ENGINE
-- ══════════════════════════════════════════════════════════════════
local function getHRP()
    local c = LocalPlayer.Character
    return c and c:FindFirstChild("HumanoidRootPart")
end

local function killTarget(model)
    if not model or not model.Parent then return end
    if _killDebounce[model] then return end
    local hum = model:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return end

    _killDebounce[model] = true
    task.delay(1.5, function() _killDebounce[model] = nil end)

    -- Method A: direct health zero (NPC + non-FE)
    pcall(function() hum.Health = 0 end)

    -- Method B: TakeDamage (FE partial cover)
    pcall(function() hum:TakeDamage(99999) end)

    -- Method C: BodyVelocity fling (near-universal FE void kill)
    pcall(function()
        local tHRP = model:FindFirstChild("HumanoidRootPart")
        if tHRP then
            local bv       = Instance.new("BodyVelocity")
            bv.Velocity    = Vector3.new(
                math.random(-40, 40), 9999, math.random(-40, 40)
            )
            bv.MaxForce    = Vector3.new(math.huge, math.huge, math.huge)
            bv.P           = math.huge
            bv.Parent      = tHRP
            Debris:AddItem(bv, 0.12)
        end
    end)

    S.kills = S.kills + 1
    refreshStatus()
end

-- Finds NPC models up to 2 levels deep in workspace
local function scanNPCsNear(pos, r)
    local playerChars = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character then playerChars[p.Character] = true end
    end

    local function tryModel(obj)
        if obj:IsA("Model")
        and obj ~= LocalPlayer.Character
        and not playerChars[obj] then
            local root = obj:FindFirstChild("HumanoidRootPart")
                      or obj:FindFirstChild("Torso")
                      or obj:FindFirstChild("UpperTorso")
            if root and (root.Position - pos).Magnitude <= r then
                local h = obj:FindFirstChildOfClass("Humanoid")
                if h and h.Health > 0 then
                    killTarget(obj)
                end
            end
        end
    end

    for _, child in ipairs(workspace:GetChildren()) do
        tryModel(child)
        if child:IsA("Folder") or child:IsA("Model") then
            for _, sub in ipairs(child:GetChildren()) do
                tryModel(sub)
            end
        end
    end
end

local function doScan()
    local hrp = getHRP()
    if not hrp then return end
    local pos = hrp.Position
    local r   = S.range

    -- Players
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local pHRP = plr.Character:FindFirstChild("HumanoidRootPart")
            if pHRP and (pHRP.Position - pos).Magnitude <= r then
                local ph = plr.Character:FindFirstChildOfClass("Humanoid")
                if ph and ph.Health > 0 then
                    killTarget(plr.Character)
                end
            end
        end
    end

    -- NPCs
    scanNPCsNear(pos, r)
end

local function startAura()
    if _auraConn     then _auraConn:Disconnect()     _auraConn     = nil end
    if _hitboxFollow then _hitboxFollow:Disconnect()  _hitboxFollow = nil end
    if _touchConn    then _touchConn:Disconnect()     _touchConn    = nil end
    pcall(function()
        if _hitboxPart then _hitboxPart:Destroy() _hitboxPart = nil end
    end)

    local hrp = getHRP()
    if not hrp then return end

    -- Invisible sphere hitbox follows character
    local hp = Instance.new("Part")
    hp.Name         = "_AuraHitbox"
    hp.Shape        = Enum.PartType.Ball
    hp.Size         = Vector3.new(S.range * 2, S.range * 2, S.range * 2)
    hp.Transparency = 1
    hp.CanCollide   = false
    hp.Massless     = true
    hp.CastShadow   = false
    hp.Anchored     = false
    hp.CFrame       = hrp.CFrame
    hp.Parent       = workspace
    _hitboxPart     = hp

    -- CFrame follow connection
    _hitboxFollow = RunService.Heartbeat:Connect(function()
        local h2 = getHRP()
        if h2 and hp and hp.Parent then
            hp.CFrame = h2.CFrame
        end
    end)

    -- Touched trigger
    _touchConn = hp.Touched:Connect(function(hit)
        if not S.auraOn then return end
        local model = hit.Parent
        if model and model ~= LocalPlayer.Character then
            local hum = model:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                killTarget(model)
            end
        end
    end)

    -- Throttled heartbeat scan
    _scanTimer = 0
    _auraConn  = RunService.Heartbeat:Connect(function(dt)
        if not S.auraOn then return end
        _scanTimer = _scanTimer + dt
        if _scanTimer >= 0.15 then
            _scanTimer = 0
            doScan()
        end
    end)
end

local function stopAura()
    if _auraConn     then _auraConn:Disconnect()     _auraConn     = nil end
    if _hitboxFollow then _hitboxFollow:Disconnect()  _hitboxFollow = nil end
    if _touchConn    then _touchConn:Disconnect()     _touchConn    = nil end
    pcall(function()
        if _hitboxPart then _hitboxPart:Destroy() _hitboxPart = nil end
    end)
end

-- ══════════════════════════════════════════════════════════════════
--  VISUALIZER  (white Neon sphere showing aura radius)
-- ══════════════════════════════════════════════════════════════════
local function startVisual()
    local hrp = getHRP()
    if not hrp then return end
    if _visualFollow then _visualFollow:Disconnect() _visualFollow = nil end
    pcall(function() if _visualPart then _visualPart:Destroy() end end)

    local vp = Instance.new("Part")
    vp.Name        = "_AuraVis"
    vp.Shape       = Enum.PartType.Ball
    vp.Size        = Vector3.new(S.range * 2, S.range * 2, S.range * 2)
    vp.Transparency = 0.88
    vp.Color       = Color3.new(1, 1, 1)
    vp.Material    = Enum.Material.Neon
    vp.CanCollide  = false
    vp.Massless    = true
    vp.CastShadow  = false
    vp.Anchored    = false
    vp.CFrame      = hrp.CFrame
    vp.Parent      = workspace
    _visualPart    = vp

    _visualFollow = RunService.Heartbeat:Connect(function()
        local h2 = getHRP()
        if h2 and vp and vp.Parent then
            vp.CFrame = h2.CFrame
        end
    end)
end

local function stopVisual()
    if _visualFollow then _visualFollow:Disconnect() _visualFollow = nil end
    pcall(function()
        if _visualPart then _visualPart:Destroy() _visualPart = nil end
    end)
end

-- ══════════════════════════════════════════════════════════════════
--  MAP COMPATIBILITY DETECTION
--  Runs once at load + watches for new NPCs mid-game.
--  Results delivered via notification only — real data, no guessing.
-- ══════════════════════════════════════════════════════════════════
local function detectMap()
    task.spawn(function()
        task.wait(2)  -- wait for workspace to fully load

        local npcCount  = 0
        local hasCustom = false

        local playerChars = {}
        for _, p in ipairs(Players:GetPlayers()) do
            if p.Character then playerChars[p.Character] = true end
        end

        local function checkModel(obj)
            if obj:IsA("Model")
            and not playerChars[obj]
            and obj ~= LocalPlayer.Character then
                local hum = obj:FindFirstChildOfClass("Humanoid")
                if hum then
                    npcCount = npcCount + 1
                    if obj:FindFirstChild("Health")
                    or obj:FindFirstChild("HealthScript")
                    or obj:FindFirstChild("CustomHealth")
                    or obj:FindFirstChild("HealthHandler") then
                        hasCustom = true
                    end
                end
            end
        end

        for _, child in ipairs(workspace:GetChildren()) do
            checkModel(child)
            if child:IsA("Folder") or child:IsA("Model") then
                for _, sub in ipairs(child:GetChildren()) do
                    checkModel(sub)
                end
            end
        end

        local pCount = math.max(0, #Players:GetPlayers() - 1)

        if npcCount > 0 and not hasCustom then
            showNotif(
                "MAP COMPATIBLE",
                npcCount .. " NPCs detected  |  Standard health  |  READY",
                7
            )
        elseif npcCount > 0 and hasCustom then
            showNotif(
                "MAP WARNING",
                "Custom health found  |  NPC kill may be limited",
                7
            )
        else
            showNotif(
                "NO NPCs FOUND",
                "Player kill mode only  |  " .. pCount .. " players",
                6
            )
        end

        -- Real-time watch for new NPCs spawning
        workspace.DescendantAdded:Connect(function(obj)
            if obj:IsA("Humanoid") then
                local isPlrChr = false
                for _, p in ipairs(Players:GetPlayers()) do
                    if p.Character and obj.Parent == p.Character then
                        isPlrChr = true
                        break
                    end
                end
                if not isPlrChr and obj.Parent ~= LocalPlayer.Character then
                    showNotif(
                        "NPC SPAWNED",
                        obj.Parent and obj.Parent.Name or "Unknown",
                        3
                    )
                end
            end
        end)
    end)
end

-- ══════════════════════════════════════════════════════════════════
--  INPUT HANDLERS
-- ══════════════════════════════════════════════════════════════════

-- Range box: update range on keyboard dismiss
rangeBox.FocusLost:Connect(function()
    local v = tonumber(rangeBox.Text)
    if v and v > 0 and v <= 9999 then
        S.range = math.floor(v)
    end
    rangeBox.Text = tostring(S.range)
    refreshStatus()
    -- Resize active hitbox and visualizer
    if S.auraOn and _hitboxPart then
        _hitboxPart.Size = Vector3.new(S.range * 2, S.range * 2, S.range * 2)
    end
    if S.visualOn and _visualPart then
        _visualPart.Size = Vector3.new(S.range * 2, S.range * 2, S.range * 2)
    end
    showNotif("Range updated", S.range .. " studs", 2)
end)

-- Kill Aura toggle
killBtn.MouseButton1Click:Connect(function()
    S.auraOn = not S.auraOn
    if S.auraOn then
        startAura()
        killBtn.Text        = "KILL AURA  :  ACTIVE"
        killBtn.TextColor3  = Color3.new(1, 1, 1)
        killBtnS.Color      = Color3.new(0.78, 0.78, 0.78)
        showNotif("Kill Aura ACTIVE", "Range  " .. S.range .. "  studs", 3)
    else
        stopAura()
        killBtn.Text        = "KILL AURA  :  INACTIVE"
        killBtn.TextColor3  = Color3.new(0.48, 0.48, 0.48)
        killBtnS.Color      = Color3.new(0.28, 0.28, 0.28)
        showNotif("Kill Aura INACTIVE", "", 2)
    end
    refreshStatus()
end)

-- Visualizer toggle
visBtn.MouseButton1Click:Connect(function()
    S.visualOn = not S.visualOn
    if S.visualOn then
        startVisual()
        visBtn.Text       = "VISUALIZER  :  ON"
        visBtn.TextColor3 = Color3.new(1, 1, 1)
        visBtnS.Color     = Color3.new(0.78, 0.78, 0.78)
    else
        stopVisual()
        visBtn.Text       = "VISUALIZER  :  OFF"
        visBtn.TextColor3 = Color3.new(0.48, 0.48, 0.48)
        visBtnS.Color     = Color3.new(0.28, 0.28, 0.28)
    end
end)

-- ══════════════════════════════════════════════════════════════════
--  RESPAWN — re-link aura & visualizer after character reset
-- ══════════════════════════════════════════════════════════════════
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    _killDebounce = {}
    if S.auraOn then
        startAura()
        showNotif("Kill Aura RE-LINKED", "Character respawned", 3)
    end
    if S.visualOn then
        startVisual()
    end
end)

-- ══════════════════════════════════════════════════════════════════
--  INIT
-- ══════════════════════════════════════════════════════════════════
detectMap()
showNotif("Ano9x Aura Sigma 99999+", "Loaded  |  Delta iOS", 4)
