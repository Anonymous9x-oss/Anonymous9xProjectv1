--[[
    ╔══════════════════════════════════════════════════════════╗
    ║   Ano9x Aura Sigma 99999+  — v5                          ║
    ║   Universal NPC Kill Aura  — Delta Mobile / iOS          ║
    ╠══════════════════════════════════════════════════════════╣
    ║   KILL METHOD STACK (3 layers, no void teleport):        ║
    ║   [1] SetHumanoidStateEnabled(Dead,true)+ChangeState     ║
    ║       Primary FE — replicates via Network Ownership      ║
    ║   [2] MaxHealth=0, Health=0, Health=-1                   ║
    ║       Bypasses MinHealth clamp                           ║
    ║   [3] TakeDamage(math.huge) + TakeDamage(9999999)        ║
    ║       Fallback for games with custom health              ║
    ╚══════════════════════════════════════════════════════════╝
]]

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer      = Players.LocalPlayer

pcall(function() game.CoreGui:FindFirstChild("__Ano9xAura"):Destroy() end)

-- ── Device detect ────────────────────────────────────────────────
local deviceLabel
do
    local touch    = UserInputService.TouchEnabled
    local keyboard = UserInputService.KeyboardEnabled
    if touch and not keyboard then
        deviceLabel = "Delta Mobile"
    elseif touch and keyboard then
        deviceLabel = "Delta iOS / iPad"
    else
        deviceLabel = "Delta Desktop"
    end
end

-- ── Constants ────────────────────────────────────────────────────
local PW        = 200
local PH_FULL   = 170
local PH_MIN    = 22
local SPARK_LEN = 40
local SPARK_SPD = 0.40

-- ── State ────────────────────────────────────────────────────────
local S = {
    auraOn   = false,
    visualOn = false,
    range    = 30,
    kills    = 0,
    mini     = false,
}
local _killDebounce = {}
local _auraConn     = nil
local _scanTimer    = 0
local _hitboxPart   = nil
local _hitboxFollow = nil
local _touchConn    = nil
local _visualParts  = {}
local _visualFollow = nil
local _sparkToken   = {}    -- replaced to kill old loop

-- ═════════════════════════════════════════════════════════════════
--  SCREEN GUI
-- ═════════════════════════════════════════════════════════════════
local gui = Instance.new("ScreenGui")
gui.Name           = "__Ano9xAura"
gui.ResetOnSpawn   = false
gui.DisplayOrder   = 998
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function() gui.Parent = game.CoreGui end)
if not gui.Parent then gui.Parent = LocalPlayer.PlayerGui end

-- ═════════════════════════════════════════════════════════════════
--  PANEL
-- ═════════════════════════════════════════════════════════════════
-- Start panel at pure pixel offset (Scale=0) so drag math is clean
local startX = math.floor((workspace.CurrentCamera.ViewportSize.X - PW) / 2)
local startY = 80

local panel = Instance.new("Frame")
panel.Size                   = UDim2.new(0, PW, 0, PH_FULL)
panel.Position               = UDim2.new(0, startX, 0, startY)
panel.BackgroundColor3       = Color3.new(0, 0, 0)
panel.BackgroundTransparency = 0
panel.BorderSizePixel        = 0
panel.ClipsDescendants       = false
panel.ZIndex                 = 10
panel.Parent                 = gui
Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 6)

-- Static white border always visible
local panelBorder = Instance.new("UIStroke")
panelBorder.Color        = Color3.new(1, 1, 1)
panelBorder.Thickness    = 1.4
panelBorder.Transparency = 0
panelBorder.Parent       = panel

-- ═════════════════════════════════════════════════════════════════
--  SPARK FRAME
-- ═════════════════════════════════════════════════════════════════
local spark = Instance.new("Frame")
spark.Name                   = "Spark"
spark.BackgroundColor3       = Color3.new(1, 1, 1)
spark.BackgroundTransparency = 1   -- hidden until loop starts
spark.BorderSizePixel        = 0
spark.ZIndex                 = 22
spark.Parent                 = panel
Instance.new("UICorner", spark).CornerRadius = UDim.new(1, 0)

-- Kill spark loop
local function killSpark()
    _sparkToken = {}
    spark.BackgroundTransparency = 1
end

-- Start spark loop with explicit height h
local function startSpark(h)
    local myToken = {}
    _sparkToken   = myToken
    spark.BackgroundTransparency = 0

    task.spawn(function()
        task.wait(0.06)
        while _sparkToken == myToken do
            local H = h
            -- TOP
            spark.Size     = UDim2.new(0, SPARK_LEN, 0, 2)
            spark.Position = UDim2.new(0, 0, 0, 0)
            local tw = TweenService:Create(spark,
                TweenInfo.new(SPARK_SPD, Enum.EasingStyle.Linear),
                {Position = UDim2.new(0, PW - SPARK_LEN, 0, 0)})
            tw:Play(); task.wait(SPARK_SPD)
            if _sparkToken ~= myToken then spark.BackgroundTransparency = 1 return end

            -- RIGHT
            spark.Size     = UDim2.new(0, 2, 0, SPARK_LEN)
            spark.Position = UDim2.new(0, PW - 2, 0, 0)
            tw = TweenService:Create(spark,
                TweenInfo.new(SPARK_SPD, Enum.EasingStyle.Linear),
                {Position = UDim2.new(0, PW - 2, 0, H - SPARK_LEN)})
            tw:Play(); task.wait(SPARK_SPD)
            if _sparkToken ~= myToken then spark.BackgroundTransparency = 1 return end

            -- BOTTOM
            spark.Size     = UDim2.new(0, SPARK_LEN, 0, 2)
            spark.Position = UDim2.new(0, PW - SPARK_LEN, 0, H - 2)
            tw = TweenService:Create(spark,
                TweenInfo.new(SPARK_SPD, Enum.EasingStyle.Linear),
                {Position = UDim2.new(0, 0, 0, H - 2)})
            tw:Play(); task.wait(SPARK_SPD)
            if _sparkToken ~= myToken then spark.BackgroundTransparency = 1 return end

            -- LEFT
            spark.Size     = UDim2.new(0, 2, 0, SPARK_LEN)
            spark.Position = UDim2.new(0, 0, 0, H - SPARK_LEN)
            tw = TweenService:Create(spark,
                TweenInfo.new(SPARK_SPD, Enum.EasingStyle.Linear),
                {Position = UDim2.new(0, 0, 0, 0)})
            tw:Play(); task.wait(SPARK_SPD)
            if _sparkToken ~= myToken then spark.BackgroundTransparency = 1 return end
        end
    end)
end

-- Glitch-entry spark: rapid X-jitter then lock + start loop
-- Called only when un-minimizing to full panel
local function glitchEntryThenSpark()
    killSpark()
    spark.BackgroundTransparency = 0

    -- Quick horizontal glitch jitters on the spark position
    local glitchSteps = {
        {0.00, UDim2.new(0, -8, 0, PH_FULL/2)},
        {0.04, UDim2.new(0,  6, 0, PH_FULL/2)},
        {0.08, UDim2.new(0, -4, 0, PH_FULL/2)},
        {0.12, UDim2.new(0,  2, 0, PH_FULL/2)},
        {0.15, UDim2.new(0,  0, 0, PH_FULL/2)},
    }
    for _, step in ipairs(glitchSteps) do
        task.delay(step[1], function()
            spark.Size     = UDim2.new(0, SPARK_LEN, 0, 2)
            spark.Position = step[2]
        end)
    end

    -- After glitch settles, start normal loop
    task.delay(0.22, function()
        startSpark(PH_FULL)
    end)
end

-- ═════════════════════════════════════════════════════════════════
--  TITLE BAR
-- ═════════════════════════════════════════════════════════════════
local titleBar = Instance.new("Frame")
titleBar.Size                   = UDim2.new(1, 0, 0, 22)
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
titleLbl.TextSize           = 9
titleLbl.TextColor3         = Color3.new(1, 1, 1)
titleLbl.TextXAlignment     = Enum.TextXAlignment.Left
titleLbl.TextTruncate       = Enum.TextTruncate.AtEnd
titleLbl.ZIndex             = 12
titleLbl.Parent             = titleBar

local function makeTitleBtn(xOff, lbl)
    local b = Instance.new("TextButton")
    b.Size             = UDim2.new(0, 18, 0, 15)
    b.Position         = UDim2.new(1, xOff, 0.5, -7)
    b.BackgroundColor3 = Color3.new(0.15, 0.15, 0.15)
    b.BorderSizePixel  = 0
    b.Text             = lbl
    b.Font             = Enum.Font.GothamBold
    b.TextSize         = 9
    b.TextColor3       = Color3.new(1, 1, 1)
    b.ZIndex           = 13
    b.Parent           = titleBar
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 3)
    local s = Instance.new("UIStroke")
    s.Color = Color3.new(0.38, 0.38, 0.38)
    s.Thickness = 0.6
    s.Parent = b
    return b
end

local minBtn   = makeTitleBtn(-40, "_")
local closeBtn = makeTitleBtn(-20, "X")

-- ═════════════════════════════════════════════════════════════════
--  CONTENT
-- ═════════════════════════════════════════════════════════════════
local content = Instance.new("Frame")
content.Size                 = UDim2.new(1, 0, 1, -22)
content.Position             = UDim2.new(0, 0, 0, 22)
content.BackgroundTransparency = 1
content.ClipsDescendants     = true
content.ZIndex               = 11
content.Parent               = panel

local cPad = Instance.new("UIPadding")
cPad.PaddingLeft = UDim.new(0, 8); cPad.PaddingRight  = UDim.new(0, 8)
cPad.PaddingTop  = UDim.new(0, 8); cPad.PaddingBottom = UDim.new(0, 8)
cPad.Parent      = content

local cList = Instance.new("UIListLayout")
cList.SortOrder = Enum.SortOrder.LayoutOrder
cList.Padding   = UDim.new(0, 6)
cList.Parent    = content

local function makeRowBtn(text, order, h)
    local b = Instance.new("TextButton")
    b.Size             = UDim2.new(1, 0, 0, h or 28)
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
    bs.Color = Color3.new(0.28, 0.28, 0.28); bs.Thickness = 0.8; bs.Parent = b
    return b, bs
end

local killBtn, killBtnS = makeRowBtn("KILL AURA  :  INACTIVE", 1, 28)

-- Range row
local rangeRow = Instance.new("Frame")
rangeRow.Size                 = UDim2.new(1, 0, 0, 22)
rangeRow.BackgroundTransparency = 1
rangeRow.LayoutOrder          = 2
rangeRow.ZIndex               = 12
rangeRow.Parent               = content

local rRL = Instance.new("UIListLayout")
rRL.FillDirection     = Enum.FillDirection.Horizontal
rRL.VerticalAlignment = Enum.VerticalAlignment.Center
rRL.Padding           = UDim.new(0, 6)
rRL.Parent            = rangeRow

local rangeLbl = Instance.new("TextLabel")
rangeLbl.Size               = UDim2.new(0, 46, 1, 0)
rangeLbl.BackgroundTransparency = 1
rangeLbl.Text               = "RANGE"
rangeLbl.Font               = Enum.Font.GothamSemibold
rangeLbl.TextSize           = 9
rangeLbl.TextColor3         = Color3.new(0.70, 0.70, 0.70)
rangeLbl.TextXAlignment     = Enum.TextXAlignment.Left
rangeLbl.ZIndex             = 12
rangeLbl.Parent             = rangeRow

local rangeBox = Instance.new("TextBox")
rangeBox.Size              = UDim2.new(1, -52, 1, 0)
rangeBox.BackgroundColor3  = Color3.new(0.09, 0.09, 0.09)
rangeBox.BorderSizePixel   = 0
rangeBox.Text              = tostring(S.range)
rangeBox.Font              = Enum.Font.GothamSemibold
rangeBox.TextSize          = 9
rangeBox.TextColor3        = Color3.new(1, 1, 1)
rangeBox.PlaceholderText   = "studs"
rangeBox.PlaceholderColor3 = Color3.new(0.36, 0.36, 0.36)
rangeBox.ClearTextOnFocus  = false
rangeBox.ZIndex            = 12
rangeBox.Parent            = rangeRow
Instance.new("UICorner", rangeBox).CornerRadius = UDim.new(0, 3)
local rbS = Instance.new("UIStroke")
rbS.Color = Color3.new(0.28, 0.28, 0.28); rbS.Thickness = 0.8; rbS.Parent = rangeBox

local visBtn, visBtnS = makeRowBtn("VISUALIZER  :  OFF", 3, 26)

-- Status frame
local statFrame = Instance.new("Frame")
statFrame.Size             = UDim2.new(1, 0, 0, 48)
statFrame.BackgroundColor3 = Color3.new(0.05, 0.05, 0.05)
statFrame.BorderSizePixel  = 0
statFrame.LayoutOrder      = 4
statFrame.ZIndex           = 12
statFrame.Parent           = content
Instance.new("UICorner", statFrame).CornerRadius = UDim.new(0, 4)
local sfS = Instance.new("UIStroke")
sfS.Color = Color3.new(0.18, 0.18, 0.18); sfS.Thickness = 0.8; sfS.Parent = statFrame
local sfPad = Instance.new("UIPadding")
sfPad.PaddingLeft = UDim.new(0, 7); sfPad.PaddingTop = UDim.new(0, 5)
sfPad.Parent = statFrame
local sfList = Instance.new("UIListLayout")
sfList.Padding = UDim.new(0, 2); sfList.Parent = statFrame

local function makeStat(order)
    local l = Instance.new("TextLabel")
    l.Size               = UDim2.new(1, -8, 0, 12)
    l.BackgroundTransparency = 1
    l.Font               = Enum.Font.Gotham
    l.TextSize           = 9
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
    sStatus.TextColor3 = S.auraOn and Color3.new(1,1,1) or Color3.new(0.40,0.40,0.40)
end
refreshStatus()

-- ═════════════════════════════════════════════════════════════════
--  NOTIFICATIONS  (bottom-right, small, black/white)
-- ═════════════════════════════════════════════════════════════════
local nHolder = Instance.new("Frame")
nHolder.Size                = UDim2.new(0, 210, 0, 300)
nHolder.Position            = UDim2.new(1, -218, 1, -308)
nHolder.BackgroundTransparency = 1
nHolder.ZIndex              = 200
nHolder.Parent              = gui

local nListL = Instance.new("UIListLayout")
nListL.SortOrder         = Enum.SortOrder.LayoutOrder
nListL.VerticalAlignment = Enum.VerticalAlignment.Bottom
nListL.Padding           = UDim.new(0, 4)
nListL.Parent            = nHolder

local _nCount = 0

local function showNotif(l1, l2, secs)
    secs = secs or 4; _nCount = _nCount + 1
    local h = (l2 and l2 ~= "") and 44 or 27

    local nf = Instance.new("Frame")
    nf.Size             = UDim2.new(1, 0, 0, h)
    nf.BackgroundColor3 = Color3.new(0, 0, 0)
    nf.BackgroundTransparency = 1
    nf.BorderSizePixel  = 0
    nf.LayoutOrder      = _nCount
    nf.ZIndex           = 201
    nf.Parent           = nHolder
    Instance.new("UICorner", nf).CornerRadius = UDim.new(0, 4)

    local nfB = Instance.new("UIStroke")
    nfB.Color = Color3.new(1,1,1); nfB.Thickness = 0.8
    nfB.Transparency = 1; nfB.Parent = nf

    local nPad = Instance.new("UIPadding")
    nPad.PaddingLeft = UDim.new(0, 6); nPad.PaddingTop = UDim.new(0, 4); nPad.Parent = nf

    local nLL = Instance.new("UIListLayout"); nLL.Padding = UDim.new(0, 2); nLL.Parent = nf

    local nl1 = Instance.new("TextLabel")
    nl1.Size = UDim2.new(1,-8,0,14); nl1.BackgroundTransparency = 1
    nl1.Text = l1; nl1.Font = Enum.Font.GothamBold; nl1.TextSize = 9
    nl1.TextColor3 = Color3.new(1,1,1); nl1.TextTransparency = 1
    nl1.TextXAlignment = Enum.TextXAlignment.Left
    nl1.TextTruncate = Enum.TextTruncate.AtEnd; nl1.ZIndex = 202; nl1.Parent = nf

    local nl2 = nil
    if l2 and l2 ~= "" then
        nl2 = Instance.new("TextLabel")
        nl2.Size = UDim2.new(1,-8,0,12); nl2.BackgroundTransparency = 1
        nl2.Text = l2; nl2.Font = Enum.Font.Gotham; nl2.TextSize = 8
        nl2.TextColor3 = Color3.new(0.60,0.60,0.60); nl2.TextTransparency = 1
        nl2.TextXAlignment = Enum.TextXAlignment.Left
        nl2.TextTruncate = Enum.TextTruncate.AtEnd; nl2.ZIndex = 202; nl2.Parent = nf
    end

    local Ti = TweenInfo.new(0.18, Enum.EasingStyle.Quad)
    TweenService:Create(nf,   Ti, {BackgroundTransparency = 0.08}):Play()
    TweenService:Create(nfB,  Ti, {Transparency = 0.20}):Play()
    TweenService:Create(nl1,  Ti, {TextTransparency = 0}):Play()
    if nl2 then TweenService:Create(nl2, Ti, {TextTransparency = 0}):Play() end

    task.delay(secs, function()
        local To = TweenInfo.new(0.18, Enum.EasingStyle.Quad)
        TweenService:Create(nf,  To, {BackgroundTransparency = 1}):Play()
        TweenService:Create(nfB, To, {Transparency = 1}):Play()
        TweenService:Create(nl1, To, {TextTransparency = 1}):Play()
        if nl2 then TweenService:Create(nl2, To, {TextTransparency = 1}):Play() end
        task.delay(0.22, function() pcall(function() nf:Destroy() end) end)
    end)
end

-- ═════════════════════════════════════════════════════════════════
--  DRAG  ── FIXED for mobile/iOS
--
--  Root cause of "kepental" bug:
--  Panel was positioned with Scale=0.5 (UDim2.new(0.5, offset, ...)).
--  When we read panel.Position.X.Offset at drag start, we only get
--  the Offset component, ignoring the Scale component. So the delta
--  math is wrong and the panel jumps/snaps on first touch move.
--
--  Fix: Panel is now positioned at pure Scale=0 from init.
--  On InputBegan we record AbsolutePosition (absolute screen pixel)
--  of the panel, not UDim2 offsets. On move we set panel.Position
--  directly from absolute coords → no scale confusion, no kepental.
-- ═════════════════════════════════════════════════════════════════
do
    local _drag  = false
    local _touch = nil   -- tracks which input we are following
    local _startInputPos = Vector2.new()
    local _startPanelPos = Vector2.new()

    local function isBtnInput(pos)
        -- Ignore touches that land on the two title buttons
        local abs = titleBar.AbsolutePosition
        local sz  = titleBar.AbsoluteSize
        -- right 50px of titlebar = button zone
        return pos.X > abs.X + sz.X - 50
    end

    titleBar.InputBegan:Connect(function(inp)
        if inp.UserInputType ~= Enum.UserInputType.Touch
        and inp.UserInputType ~= Enum.UserInputType.MouseButton1 then return end

        -- Ignore if touch is on a button
        if isBtnInput(Vector2.new(inp.Position.X, inp.Position.Y)) then return end

        _drag            = true
        _touch           = inp
        _startInputPos   = Vector2.new(inp.Position.X, inp.Position.Y)
        _startPanelPos   = Vector2.new(panel.AbsolutePosition.X, panel.AbsolutePosition.Y)
    end)

    UserInputService.InputChanged:Connect(function(inp)
        if not _drag then return end
        if inp ~= _touch
        and inp.UserInputType ~= Enum.UserInputType.MouseMove then return end

        local cur = Vector2.new(inp.Position.X, inp.Position.Y)
        local d   = cur - _startInputPos
        -- Clamp to screen bounds
        local vp  = workspace.CurrentCamera.ViewportSize
        local nx  = math.clamp(_startPanelPos.X + d.X, 0, vp.X - PW)
        local ny  = math.clamp(_startPanelPos.Y + d.Y, 0, vp.Y - (S.mini and PH_MIN or PH_FULL))

        panel.Position = UDim2.new(0, nx, 0, ny)
    end)

    UserInputService.InputEnded:Connect(function(inp)
        if inp == _touch
        or inp.UserInputType == Enum.UserInputType.MouseButton1 then
            _drag  = false
            _touch = nil
        end
    end)
end

-- ═════════════════════════════════════════════════════════════════
--  MINIMIZE / CLOSE
-- ═════════════════════════════════════════════════════════════════
minBtn.MouseButton1Click:Connect(function()
    S.mini = not S.mini

    if S.mini then
        -- Going to minimized: kill spark immediately, hide content
        killSpark()
        content.Visible = false
        minBtn.Text     = "+"
        TweenService:Create(panel,
            TweenInfo.new(0.16, Enum.EasingStyle.Quad),
            {Size = UDim2.new(0, PW, 0, PH_MIN)}
        ):Play()
    else
        -- Going back to full: show content, tween open, glitch-entry spark
        content.Visible = true
        minBtn.Text     = "_"
        TweenService:Create(panel,
            TweenInfo.new(0.20, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
            {Size = UDim2.new(0, PW, 0, PH_FULL)}
        ):Play()
        -- Glitch entry fires after tween (~0.22s)
        task.delay(0.22, glitchEntryThenSpark)
    end
end)

closeBtn.MouseButton1Click:Connect(function()
    killSpark()
    if _auraConn     then _auraConn:Disconnect()     end
    if _hitboxFollow then _hitboxFollow:Disconnect()  end
    if _touchConn    then _touchConn:Disconnect()    end
    if _visualFollow then _visualFollow:Disconnect()  end
    for _, p in ipairs(_visualParts) do pcall(function() p:Destroy() end) end
    _visualParts = {}
    pcall(function() if _hitboxPart then _hitboxPart:Destroy() end end)
    pcall(function() gui:Destroy() end)
end)

-- ═════════════════════════════════════════════════════════════════
--  HELPERS
-- ═════════════════════════════════════════════════════════════════
local function getHRP()
    local c = LocalPlayer.Character
    return c and c:FindFirstChild("HumanoidRootPart")
end

local function isPlayerChar(model)
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character == model then return true end
    end
    return false
end

-- ═════════════════════════════════════════════════════════════════
--  NPC KILL ENGINE  (3 layers, no void tp)
-- ═════════════════════════════════════════════════════════════════
local function killNPC(model)
    if not model or not model.Parent  then return end
    if model == LocalPlayer.Character  then return end
    if isPlayerChar(model)             then return end
    if _killDebounce[model]            then return end

    local hum = model:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0     then return end

    _killDebounce[model] = true
    task.delay(2.0, function() _killDebounce[model] = nil end)

    -- Layer 1: Network Ownership state replication (primary FE method)
    pcall(function()
        hum:SetHumanoidStateEnabled(Enum.HumanoidStateType.Dead, true)
        hum:ChangeState(Enum.HumanoidStateType.Dead)
    end)

    -- Layer 2: Health nullification (bypasses MinHealth clamp)
    pcall(function()
        hum.MaxHealth = 0
        hum.Health    = 0
        hum.Health    = -1
    end)

    -- Layer 3: TakeDamage fallback for custom health systems
    pcall(function()
        hum:TakeDamage(math.huge)
        hum:TakeDamage(9999999)
    end)

    S.kills = S.kills + 1
    refreshStatus()
end

local function deepScanNPCs(pos, r)
    local function tryModel(obj)
        if not obj:IsA("Model")         then return end
        if obj == LocalPlayer.Character  then return end
        if isPlayerChar(obj)             then return end
        local root = obj:FindFirstChild("HumanoidRootPart")
                  or obj:FindFirstChild("Torso")
                  or obj:FindFirstChild("UpperTorso")
        if root and (root.Position - pos).Magnitude <= r then
            local h = obj:FindFirstChildOfClass("Humanoid")
            if h and h.Health > 0 then killNPC(obj) end
        end
    end
    for _, child in ipairs(workspace:GetChildren()) do
        tryModel(child)
        if child:IsA("Folder") or child:IsA("Model") then
            for _, sub in ipairs(child:GetChildren()) do tryModel(sub) end
        end
    end
end

local function startAura()
    if _auraConn     then _auraConn:Disconnect()     _auraConn    = nil end
    if _hitboxFollow then _hitboxFollow:Disconnect()  _hitboxFollow = nil end
    if _touchConn    then _touchConn:Disconnect()    _touchConn   = nil end
    pcall(function() if _hitboxPart then _hitboxPart:Destroy() _hitboxPart = nil end end)

    local hrp = getHRP()
    if not hrp then return end

    local hp = Instance.new("Part")
    hp.Name         = "_AuraHitbox"
    hp.Shape        = Enum.PartType.Ball
    hp.Size         = Vector3.new(S.range*2, S.range*2, S.range*2)
    hp.Transparency = 1
    hp.CanCollide   = false
    hp.Massless     = true
    hp.CastShadow   = false
    hp.Anchored     = false
    hp.CFrame       = hrp.CFrame
    hp.Parent       = workspace
    _hitboxPart     = hp

    _hitboxFollow = RunService.Heartbeat:Connect(function()
        local h2 = getHRP()
        if h2 and hp and hp.Parent then hp.CFrame = h2.CFrame end
    end)

    _touchConn = hp.Touched:Connect(function(hit)
        if not S.auraOn or not hit then return end
        local model = hit.Parent
        if model and model ~= LocalPlayer.Character and not isPlayerChar(model) then
            local h = model:FindFirstChildOfClass("Humanoid")
            if h and h.Health > 0 then killNPC(model) end
        end
    end)

    _scanTimer = 0
    _auraConn  = RunService.Heartbeat:Connect(function(dt)
        if not S.auraOn then return end
        _scanTimer = _scanTimer + dt
        if _scanTimer >= 0.12 then
            _scanTimer = 0
            local h2 = getHRP()
            if h2 then deepScanNPCs(h2.Position, S.range) end
        end
    end)
end

local function stopAura()
    if _auraConn     then _auraConn:Disconnect()     _auraConn    = nil end
    if _hitboxFollow then _hitboxFollow:Disconnect()  _hitboxFollow = nil end
    if _touchConn    then _touchConn:Disconnect()    _touchConn   = nil end
    pcall(function() if _hitboxPart then _hitboxPart:Destroy() _hitboxPart = nil end end)
end

-- ═════════════════════════════════════════════════════════════════
--  VISUALIZER — hollow red box (6 face Parts, Neon)
-- ═════════════════════════════════════════════════════════════════
local function clearVisual()
    if _visualFollow then _visualFollow:Disconnect() _visualFollow = nil end
    for _, p in ipairs(_visualParts) do pcall(function() p:Destroy() end) end
    _visualParts = {}
end

local function startVisual()
    clearVisual()
    local hrp = getHRP()
    if not hrp then return end

    local r   = S.range
    local D   = r * 2
    local T   = 0.3
    local COL = Color3.fromRGB(255, 20, 20)

    local faces = {
        {pos = Vector3.new(0,  r, 0), size = Vector3.new(D, T, D)},
        {pos = Vector3.new(0, -r, 0), size = Vector3.new(D, T, D)},
        {pos = Vector3.new(0, 0,  r), size = Vector3.new(D, D, T)},
        {pos = Vector3.new(0, 0, -r), size = Vector3.new(D, D, T)},
        {pos = Vector3.new( r, 0, 0), size = Vector3.new(T, D, D)},
        {pos = Vector3.new(-r, 0, 0), size = Vector3.new(T, D, D)},
    }

    local visRoot = Instance.new("Model")
    visRoot.Name   = "_AuraVis"
    visRoot.Parent = workspace

    for _, f in ipairs(faces) do
        local p = Instance.new("Part")
        p.Size         = f.size
        p.Color        = COL
        p.Material     = Enum.Material.Neon
        p.Transparency = 0.30
        p.CanCollide   = false
        p.Massless     = true
        p.CastShadow   = false
        p.Anchored     = false
        p.CFrame       = hrp.CFrame + f.pos
        p.Parent       = visRoot
        table.insert(_visualParts, p)
    end
    table.insert(_visualParts, visRoot)

    _visualFollow = RunService.Heartbeat:Connect(function()
        local h2 = getHRP()
        if not h2 then return end
        for i, f in ipairs(faces) do
            local p = _visualParts[i]
            if p and p.Parent then
                p.CFrame = h2.CFrame + f.pos
            end
        end
    end)
end

-- ═════════════════════════════════════════════════════════════════
--  MAP DETECT
-- ═════════════════════════════════════════════════════════════════
local function detectMap()
    task.spawn(function()
        task.wait(2)
        local npcCount = 0; local hasCustom = false
        local function checkModel(obj)
            if obj:IsA("Model") and obj ~= LocalPlayer.Character and not isPlayerChar(obj) then
                local hum = obj:FindFirstChildOfClass("Humanoid")
                if hum then
                    npcCount = npcCount + 1
                    if obj:FindFirstChild("Health") or obj:FindFirstChild("HealthScript")
                    or obj:FindFirstChild("CustomHealth") or obj:FindFirstChild("HealthHandler") then
                        hasCustom = true
                    end
                end
            end
        end
        for _, child in ipairs(workspace:GetChildren()) do
            checkModel(child)
            if child:IsA("Folder") or child:IsA("Model") then
                for _, sub in ipairs(child:GetChildren()) do checkModel(sub) end
            end
        end
        local pCount = math.max(0, #Players:GetPlayers() - 1)
        if npcCount > 0 and not hasCustom then
            showNotif("MAP COMPATIBLE", npcCount.." NPCs  |  Standard Humanoid  |  READY", 7)
        elseif npcCount > 0 and hasCustom then
            showNotif("MAP WARNING", "Custom health found  |  kill may be limited", 7)
        else
            showNotif("NO NPCs FOUND", "No NPC  |  "..pCount.." players online", 6)
        end
        workspace.DescendantAdded:Connect(function(obj)
            if obj:IsA("Humanoid") then
                local isPlr = false
                for _, p in ipairs(Players:GetPlayers()) do
                    if p.Character and obj.Parent == p.Character then isPlr = true break end
                end
                if not isPlr and obj.Parent ~= LocalPlayer.Character then
                    showNotif("NPC SPAWNED", obj.Parent and obj.Parent.Name or "Unknown", 3)
                end
            end
        end)
    end)
end

-- ═════════════════════════════════════════════════════════════════
--  INPUT HANDLERS
-- ═════════════════════════════════════════════════════════════════
rangeBox.FocusLost:Connect(function()
    local v = tonumber(rangeBox.Text)
    if v and v > 0 and v <= 9999 then S.range = math.floor(v) end
    rangeBox.Text = tostring(S.range)
    refreshStatus()
    if S.auraOn and _hitboxPart then
        _hitboxPart.Size = Vector3.new(S.range*2, S.range*2, S.range*2)
    end
    if S.visualOn then startVisual() end
    showNotif("Range updated", S.range.." studs", 2)
end)

killBtn.MouseButton1Click:Connect(function()
    S.auraOn = not S.auraOn
    if S.auraOn then
        startAura()
        killBtn.Text       = "KILL AURA  :  ACTIVE"
        killBtn.TextColor3 = Color3.new(1, 1, 1)
        killBtnS.Color     = Color3.new(0.78, 0.78, 0.78)
        showNotif("Kill Aura ACTIVE", "Range  "..S.range.."  studs", 3)
    else
        stopAura()
        killBtn.Text       = "KILL AURA  :  INACTIVE"
        killBtn.TextColor3 = Color3.new(0.48, 0.48, 0.48)
        killBtnS.Color     = Color3.new(0.28, 0.28, 0.28)
        showNotif("Kill Aura INACTIVE", "", 2)
    end
    refreshStatus()
end)

visBtn.MouseButton1Click:Connect(function()
    S.visualOn = not S.visualOn
    if S.visualOn then
        startVisual()
        visBtn.Text       = "VISUALIZER  :  ON"
        visBtn.TextColor3 = Color3.new(1, 1, 1)
        visBtnS.Color     = Color3.new(0.78, 0.78, 0.78)
        showNotif("Visualizer ON", "Red box = kill radius", 2)
    else
        clearVisual()
        visBtn.Text       = "VISUALIZER  :  OFF"
        visBtn.TextColor3 = Color3.new(0.48, 0.48, 0.48)
        visBtnS.Color     = Color3.new(0.28, 0.28, 0.28)
    end
end)

-- ═════════════════════════════════════════════════════════════════
--  RESPAWN
-- ═════════════════════════════════════════════════════════════════
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5); _killDebounce = {}
    if S.auraOn   then startAura();   showNotif("Kill Aura RE-LINKED","Respawned",3) end
    if S.visualOn then startVisual() end
end)

-- ═════════════════════════════════════════════════════════════════
--  INIT
-- ═════════════════════════════════════════════════════════════════
startSpark(PH_FULL)
detectMap()
showNotif("Ano9x Aura Sigma 99999+", "Loaded  |  "..deviceLabel, 4)
