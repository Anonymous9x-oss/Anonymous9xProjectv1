--[[
    Anonymous9x Detector Manager v1.1
    Compact | Black/White | Touch + Mouse Drag
    Delta Mobile / iOS / PC — All Executors

    UPDATES:
    - Copy Script button now full-width inside each row, clean & centered.
    - Row layout redesigned: badge + name/path + single Copy button (no overflow).
    - Copy action copies full executable Lua script for the selected remote.
    - Panel width slightly increased to 320px for better mobile fit.
    - All other features remain identical.
]]

-- ══════════════════════════════════════════
-- SERVICES
-- ══════════════════════════════════════════
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local TS = game:GetService("TweenService")
local LP = Players.LocalPlayer

-- ══════════════════════════════════════════
-- DESTROY OLD INSTANCE
-- ══════════════════════════════════════════
pcall(function()
    local old = LP.PlayerGui:FindFirstChild("_A9xDetMgr")
    if old then old:Destroy() end
    game.CoreGui:FindFirstChild("_A9xDetMgr"):Destroy()
end)

-- ══════════════════════════════════════════
-- ROOT GUI
-- ══════════════════════════════════════════
local gui = Instance.new("ScreenGui")
gui.Name = "_A9xDetMgr"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.IgnoreGuiInset = true
pcall(function() gui.Parent = game.CoreGui end)
if not gui.Parent then gui.Parent = LP.PlayerGui end

-- ══════════════════════════════════════════
-- THEME
-- ══════════════════════════════════════════
local C = {
    bg = Color3.fromRGB(8, 8, 10),
    header = Color3.fromRGB(5, 5, 7),
    card = Color3.fromRGB(16, 16, 20),
    cardH = Color3.fromRGB(22, 22, 28),
    sep = Color3.fromRGB(28, 28, 38),
    border = Color3.fromRGB(42, 42, 58),
    white = Color3.new(1, 1, 1),
    pri = Color3.fromRGB(220, 220, 226),
    sec = Color3.fromRGB(110, 110, 128),
    dim = Color3.fromRGB(62, 62, 80),
    danger = Color3.fromRGB(200, 50, 50),
    safe = Color3.fromRGB(80, 180, 90),
    accent = Color3.fromRGB(170, 130, 255),
    remClr = Color3.fromRGB(180, 180, 220),
    bindClr = Color3.fromRGB(140, 140, 180),
    clickClr = Color3.fromRGB(120, 170, 120),
    proxClr = Color3.fromRGB(120, 150, 170),
    touchClr = Color3.fromRGB(160, 120, 120),
    otherClr = Color3.fromRGB(100, 100, 100),
}
local W = 320  -- panel width (slightly wider for button comfort)
local HDR = 30
local BTH = 28 -- button height in rows
local RH = 66 -- row height (now taller to accommodate badge + texts + full-width button)

-- ══════════════════════════════════════════
-- WINDOW
-- ══════════════════════════════════════════
local win = Instance.new("Frame")
win.Name = "Win"
win.Size = UDim2.fromOffset(W, 300)
win.Position = UDim2.new(0.5, -(W/2), 0.5, -150)
win.BackgroundColor3 = C.bg
win.BackgroundTransparency = 0
win.BorderSizePixel = 0
win.ClipsDescendants = true
win.ZIndex = 10
win.Parent = gui
Instance.new("UICorner", win).CornerRadius = UDim.new(0, 7)

local winStroke = Instance.new("UIStroke", win)
winStroke.Thickness = 1.2
winStroke.Color = C.border

-- Glitch border animation (white↔purple pulse)
task.spawn(function()
    local t = 0
    while win.Parent do
        t = t + task.wait(0.04)
        local s = (math.sin(t * 2.8) + 1) / 2
        winStroke.Color = Color3.new(0.90 + s * 0.10, 0.82 + s * 0.08, 0.90 + s * 0.42)
        winStroke.Thickness = 1.1 + s * 0.5
        if math.random(1, 80) == 1 then
            winStroke.Color = C.accent
            task.wait(0.045)
        end
    end
end)

-- ══════════════════════════════════════════
-- HEADER
-- ══════════════════════════════════════════
local hdr = Instance.new("Frame")
hdr.Size = UDim2.new(1, 0, 0, HDR)
hdr.BackgroundColor3 = C.header
hdr.BackgroundTransparency = 0
hdr.BorderSizePixel = 0
hdr.ZIndex = 11
hdr.Parent = win
Instance.new("UICorner", hdr).CornerRadius = UDim.new(0, 7)

local hPatch = Instance.new("Frame")
hPatch.Size = UDim2.new(1, 0, 0, 7)
hPatch.Position = UDim2.new(0, 0, 1, -7)
hPatch.BackgroundColor3 = C.header
hPatch.BorderSizePixel = 0
hPatch.ZIndex = 10
hPatch.Parent = hdr

local hSep = Instance.new("Frame")
hSep.Size = UDim2.new(1, 0, 0, 1)
hSep.Position = UDim2.new(0, 0, 1, -1)
hSep.BackgroundColor3 = C.sep
hSep.BorderSizePixel = 0
hSep.ZIndex = 12
hSep.Parent = hdr

local hTitle = Instance.new("TextLabel")
hTitle.Size = UDim2.new(1, -54, 1, 0)
hTitle.Position = UDim2.fromOffset(8, 0)
hTitle.BackgroundTransparency = 1
hTitle.Text = "Ano9x Detector Manager"
hTitle.Font = Enum.Font.GothamBold
hTitle.TextSize = 10
hTitle.TextColor3 = C.pri
hTitle.TextXAlignment = Enum.TextXAlignment.Left
hTitle.TextTruncate = Enum.TextTruncate.AtEnd
hTitle.ZIndex = 12
hTitle.Parent = hdr

-- Control buttons (ImageButton = no cursor bug)
local function makeCtrl(xOff, sym)
    local b = Instance.new("ImageButton")
    b.Size = UDim2.fromOffset(20, 17)
    b.Position = UDim2.new(1, xOff, 0.5, -8)
    b.BackgroundColor3 = C.card
    b.BackgroundTransparency = 0
    b.BorderSizePixel = 0
    b.Image = ""
    b.AutoButtonColor = false
    b.ZIndex = 13
    b.Parent = hdr
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.fromScale(1, 1)
    l.BackgroundTransparency = 1
    l.Text = sym
    l.Font = Enum.Font.GothamBold
    l.TextSize = 12
    l.TextColor3 = C.sec
    l.ZIndex = 14
    l.Parent = b
    b.MouseEnter:Connect(function()
        TS:Create(b, TweenInfo.new(0.10), {BackgroundColor3 = C.cardH}):Play()
        l.TextColor3 = C.white
    end)
    b.MouseLeave:Connect(function()
        TS:Create(b, TweenInfo.new(0.10), {BackgroundColor3 = C.card}):Play()
        l.TextColor3 = C.sec
    end)
    return b
end

local minBtn = makeCtrl(-44, "-")
local closeBtn = makeCtrl(-22, "x")

-- ══════════════════════════════════════════
-- DRAG (global UIS — reliable on Delta)
-- ══════════════════════════════════════════
do
    local drag = false
    local dRef = nil
    local sIP = nil
    local sWP = nil
    local minH = false

    UIS.InputBegan:Connect(function(inp, gp)
        if gp or minH then return end
        local isT = inp.UserInputType == Enum.UserInputType.Touch
        local isM = inp.UserInputType == Enum.UserInputType.MouseButton1
        if not (isT or isM) then return end
        local ap = hdr.AbsolutePosition
        local az = hdr.AbsoluteSize
        local px, py = inp.Position.X, inp.Position.Y
        if px < ap.X or px > ap.X + az.X - 50 then return end
        if py < ap.Y or py > ap.Y + az.Y then return end
        drag = true
        dRef = inp
        sIP = Vector2.new(px, py)
        sWP = Vector2.new(win.AbsolutePosition.X, win.AbsolutePosition.Y)
    end)

    UIS.InputChanged:Connect(function(inp)
        if not drag then return end
        local isT = inp.UserInputType == Enum.UserInputType.Touch
        local isM = inp.UserInputType == Enum.UserInputType.MouseMove
        if not (isT or isM) then return end
        if isT and inp ~= dRef then return end
        local d = Vector2.new(inp.Position.X, inp.Position.Y) - sIP
        local vp2 = game.Workspace.CurrentCamera.ViewportSize
        win.Position = UDim2.fromOffset(
            math.clamp(sWP.X + d.X, 0, vp2.X - W),
            math.clamp(sWP.Y + d.Y, 0, vp2.Y - 30)
        )
    end)

    UIS.InputEnded:Connect(function(inp)
        if inp == dRef or inp.UserInputType == Enum.UserInputType.MouseButton1 then
            drag = false
            dRef = nil
        end
    end)

    -- Minimize
    local fullH = 300
    minBtn.MouseButton1Click:Connect(function()
        minH = not minH
        local targetH = minH and HDR or fullH
        TS:Create(win, TweenInfo.new(0.16, Enum.EasingStyle.Quad), {Size = UDim2.fromOffset(W, targetH)}):Play()
        minBtn:FindFirstChildOfClass("TextLabel").Text = minH and "+" or "-"
    end)
end

-- Close
closeBtn.MouseButton1Click:Connect(function()
    TS:Create(win, TweenInfo.new(0.15), {BackgroundTransparency = 1}):Play()
    task.delay(0.16, function() pcall(function() gui:Destroy() end) end)
end)

-- ══════════════════════════════════════════
-- SEARCH BAR
-- ══════════════════════════════════════════
local searchF = Instance.new("Frame")
searchF.Size = UDim2.new(1, -10, 0, 22)
searchF.Position = UDim2.fromOffset(5, HDR + 4)
searchF.BackgroundColor3 = C.card
searchF.BackgroundTransparency = 0
searchF.BorderSizePixel = 0
searchF.ZIndex = 11
searchF.Parent = win
Instance.new("UICorner", searchF).CornerRadius = UDim.new(0, 5)
local sS = Instance.new("UIStroke", searchF)
sS.Color = C.border
sS.Thickness = 0.8

local searchBox = Instance.new("TextBox")
searchBox.Size = UDim2.new(1, -28, 1, 0)
searchBox.Position = UDim2.fromOffset(8, 0)
searchBox.BackgroundTransparency = 1
searchBox.PlaceholderText = "Search by name, class, path..."
searchBox.PlaceholderColor3 = C.dim
searchBox.Text = ""
searchBox.Font = Enum.Font.Gotham
searchBox.TextSize = 9
searchBox.TextColor3 = C.pri
searchBox.ClearTextOnFocus = false
searchBox.ZIndex = 12
searchBox.Parent = searchF

local searchClear = Instance.new("ImageButton")
searchClear.Size = UDim2.fromOffset(18, 18)
searchClear.Position = UDim2.new(1, -20, 0.5, -9)
searchClear.BackgroundTransparency = 1
searchClear.Image = ""
searchClear.AutoButtonColor = false
searchClear.ZIndex = 12
searchClear.Parent = searchF
local scL = Instance.new("TextLabel")
scL.Size = UDim2.fromScale(1, 1)
scL.BackgroundTransparency = 1
scL.Text = "x"
scL.Font = Enum.Font.GothamBold
scL.TextSize = 9
scL.TextColor3 = C.dim
scL.ZIndex = 13
scL.Parent = searchClear
searchClear.MouseButton1Click:Connect(function() searchBox.Text = "" end)

-- ══════════════════════════════════════════
-- TOOLBAR (Refresh | AutoScan | AntiKill | Rescan)
-- ══════════════════════════════════════════
local toolBar = Instance.new("Frame")
toolBar.Size = UDim2.new(1, -10, 0, 22)
toolBar.Position = UDim2.fromOffset(5, HDR + 30)
toolBar.BackgroundTransparency = 1
toolBar.BorderSizePixel = 0
toolBar.ZIndex = 11
toolBar.Parent = win
local tLL = Instance.new("UIListLayout")
tLL.FillDirection = Enum.FillDirection.Horizontal
tLL.VerticalAlignment = Enum.VerticalAlignment.Center
tLL.Padding = UDim.new(0, 3)
tLL.Parent = toolBar

local function makeToolBtn(lbl, w)
    local b = Instance.new("ImageButton")
    b.Size = UDim2.fromOffset(w, 20)
    b.BackgroundColor3 = C.card
    b.BackgroundTransparency = 0
    b.BorderSizePixel = 0
    b.Image = ""
    b.AutoButtonColor = false
    b.ZIndex = 12
    b.Parent = toolBar
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
    local bS = Instance.new("UIStroke", b)
    bS.Color = C.border
    bS.Thickness = 0.8
    local l = Instance.new("TextLabel")
    l.Size = UDim2.fromScale(1, 1)
    l.BackgroundTransparency = 1
    l.Text = lbl
    l.Font = Enum.Font.GothamBold
    l.TextSize = 8
    l.TextColor3 = C.sec
    l.ZIndex = 13
    l.Parent = b
    b.MouseEnter:Connect(function()
        TS:Create(b, TweenInfo.new(0.10), {BackgroundColor3 = C.cardH}):Play()
        l.TextColor3 = C.white
    end)
    b.MouseLeave:Connect(function()
        TS:Create(b, TweenInfo.new(0.10), {BackgroundColor3 = C.card}):Play()
        l.TextColor3 = C.sec
    end)
    return b, l
end

local refBtn, refL = makeToolBtn("Refresh", 62)
local autoBtn, autoL = makeToolBtn("Auto: OFF", 60)
local akBtn, akL = makeToolBtn("AntiKill", 56)
local stopBtn, stopL = makeToolBtn("Rescan", 56)

-- ══════════════════════════════════════════
-- COUNT LABEL
-- ══════════════════════════════════════════
local countL = Instance.new("TextLabel")
countL.Size = UDim2.new(1, -10, 0, 12)
countL.Position = UDim2.fromOffset(5, HDR + 56)
countL.BackgroundTransparency = 1
countL.Text = "0 remotes found"
countL.Font = Enum.Font.Gotham
countL.TextSize = 8
countL.TextColor3 = C.dim
countL.TextXAlignment = Enum.TextXAlignment.Left
countL.ZIndex = 11
countL.Parent = win

-- ══════════════════════════════════════════
-- SCROLL LIST
-- ══════════════════════════════════════════
local BODY_Y = HDR + 72
local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, 0, 1, -BODY_Y)
scroll.Position = UDim2.fromOffset(0, BODY_Y)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 3
scroll.ScrollBarImageColor3 = C.border
scroll.ScrollingDirection = Enum.ScrollingDirection.Y
scroll.CanvasSize = UDim2.fromOffset(0, 0)
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.ZIndex = 11
scroll.Parent = win

local listLL = Instance.new("UIListLayout")
listLL.SortOrder = Enum.SortOrder.LayoutOrder
listLL.Padding = UDim.new(0, 2)
listLL.Parent = scroll

local listPad = Instance.new("UIPadding")
listPad.PaddingLeft = UDim.new(0, 5)
listPad.PaddingRight = UDim.new(0, 5)
listPad.PaddingTop = UDim.new(0, 3)
listPad.PaddingBottom = UDim.new(0, 8)
listPad.Parent = scroll

-- ══════════════════════════════════════════
-- STATE
-- ══════════════════════════════════════════
local allInst = {}
local loops = {}
local disabled = {}
local antiKillOn = false
local antiKillData = {}
local autoScanOn = false
local autoConA, autoConR

-- ══════════════════════════════════════════
-- HELPERS
-- ══════════════════════════════════════════
local DANGER_KEYWORDS = {
    "kick", "ban", "crash", "shutdown", "destroy", "kill", "damage",
    "exploit", "inject", "backdoor", "anticheat", "ac", "punish", "reset"
}

local function typeColor(inst)
    local cn = inst.ClassName
    if cn == "RemoteEvent" or cn == "RemoteFunction" then return C.remClr end
    if cn == "BindableEvent" or cn == "BindableFunction" then return C.bindClr end
    if cn == "ClickDetector" then return C.clickClr end
    if cn == "ProximityPrompt" then return C.proxClr end
    if cn == "TouchTransmitter" then return C.touchClr end
    return C.otherClr
end

local function isDangerous(inst)
    local n = inst.Name:lower()
    for _, kw in ipairs(DANGER_KEYWORDS) do
        if n:find(kw, 1, true) then return true end
    end
    return false
end

-- ──────────────────────────────────────────
-- GENERATE EXECUTABLE SCRIPT for a remote
-- (Unchanged – already copies full functional code)
-- ──────────────────────────────────────────
local function generateScript(inst)
    local path = inst:GetFullName()
    local cn = inst.ClassName

    local function buildPath(obj)
        local parts = {}
        local current = obj
        while current and current ~= game do
            table.insert(parts, 1, current.Name)
            current = current.Parent
        end
        local acc = "game"
        local services = {
            ReplicatedStorage = true, Workspace = true, ServerStorage = true,
            ServerScriptService = true, StarterGui = true, StarterPack = true,
            Players = true, Lighting = true, RunService = true, TweenService = true,
            UserInputService = true, SoundService = true, HttpService = true,
            Chat = true, Teams = true, SocialService = true,
        }
        for i, name in ipairs(parts) do
            if i == 1 and services[name] then
                acc = 'game:GetService("' .. name .. '")'
            else
                local safe = name:gsub('"', '\\"')
                acc = acc .. ':FindFirstChild("' .. safe .. '")'
            end
        end
        return acc
    end

    local accessor = buildPath(inst)
    local lines = {
        "-- Anonymous9x Detector Manager – Generated Script",
        "-- Remote: " .. path,
        "-- Class: " .. cn,
        "",
        "local remote = " .. accessor,
        'if not remote then warn("Remote not found: ' .. path:gsub('"','\\"') .. '") return end',
        "",
    }

    if cn == "RemoteEvent" then
        table.insert(lines, "-- ╔══════════════════════════════════╗")
        table.insert(lines, "-- ║ RemoteEvent :: FireServer      ║")
        table.insert(lines, "-- ╚══════════════════════════════════╝")
        table.insert(lines, "")
        table.insert(lines, "-- Single fire (no args):")
        table.insert(lines, "remote:FireServer()")
        table.insert(lines, "")
        table.insert(lines, "-- Single fire with common arg types:")
        table.insert(lines, "-- remote:FireServer(true)")
        table.insert(lines, "-- remote:FireServer('action', 1, Vector3.new(0,0,0))")
        table.insert(lines, "-- remote:FireServer({key='value', num=99})")
        table.insert(lines, "")
        table.insert(lines, "-- Loop fire (runs until script is stopped):")
        table.insert(lines, "-- while task.wait(0.1) do")
        table.insert(lines, "-- remote:FireServer()")
        table.insert(lines, "-- end")
        table.insert(lines, "")
        table.insert(lines, "-- Rapid burst (fire N times):")
        table.insert(lines, "-- for i = 1, 10 do")
        table.insert(lines, "-- remote:FireServer()")
        table.insert(lines, "-- task.wait(0.05)")
        table.insert(lines, "-- end")
        table.insert(lines, "")
        table.insert(lines, "-- Listen to OnClientEvent (spy on server responses):")
        table.insert(lines, "-- remote.OnClientEvent:Connect(function(...)")
        table.insert(lines, "-- print('[Spy]', ...)")
        table.insert(lines, "-- end)")
    elseif cn == "RemoteFunction" then
        table.insert(lines, "-- ╔══════════════════════════════════╗")
        table.insert(lines, "-- ║ RemoteFunction :: InvokeServer  ║")
        table.insert(lines, "-- ╚══════════════════════════════════╝")
        table.insert(lines, "")
        table.insert(lines, "-- Invoke (no args) with full error capture:")
        table.insert(lines, "local ok, result = pcall(function()")
        table.insert(lines, " return remote:InvokeServer()")
        table.insert(lines, "end)")
        table.insert(lines, 'print("[A9x] InvokeServer ok:", ok, "| result:", result)')
        table.insert(lines, "")
        table.insert(lines, "-- Invoke with arguments:")
        table.insert(lines, "-- local ok2, res2 = pcall(function()")
        table.insert(lines, "-- return remote:InvokeServer('buy', 1, 'item_id')")
        table.insert(lines, "-- end)")
        table.insert(lines, "-- print('[A9x] result:', ok2, res2)")
        table.insert(lines, "")
        table.insert(lines, "-- Hook server response (if hookfunction available):")
        table.insert(lines, "-- local original = hookfunction(remote.InvokeServer, function(self, ...)")
        table.insert(lines, "-- print('[Hook] args:', ...)")
        table.insert(lines, "-- return original(self, ...)")
        table.insert(lines, "-- end)")
        table.insert(lines, "")
        table.insert(lines, "-- Intercept OnClientInvoke:")
        table.insert(lines, "-- remote.OnClientInvoke = function(...)")
        table.insert(lines, "-- print('[Intercept]', ...)")
        table.insert(lines, "-- return true")
        table.insert(lines, "-- end")
    elseif cn == "BindableEvent" then
        table.insert(lines, "-- ╔══════════════════════════════════╗")
        table.insert(lines, "-- ║ BindableEvent :: Fire          ║")
        table.insert(lines, "-- ╚══════════════════════════════════╝")
        table.insert(lines, "")
        table.insert(lines, "-- Fire with no args:")
        table.insert(lines, "remote:Fire()")
        table.insert(lines, "")
        table.insert(lines, "-- Fire with args:")
        table.insert(lines, "-- remote:Fire('param1', 42)")
        table.insert(lines, "")
        table.insert(lines, "-- Listen to Event:")
        table.insert(lines, "-- remote.Event:Connect(function(...)")
        table.insert(lines, "-- print('[BindableEvent]', ...)")
        table.insert(lines, "-- end)")
        table.insert(lines, "")
        table.insert(lines, "-- Loop fire:")
        table.insert(lines, "-- while task.wait(0.1) do remote:Fire() end")
    elseif cn == "BindableFunction" then
        table.insert(lines, "-- ╔══════════════════════════════════╗")
        table.insert(lines, "-- ║ BindableFunction :: Invoke     ║")
        table.insert(lines, "-- ╚══════════════════════════════════╝")
        table.insert(lines, "")
        table.insert(lines, "-- Invoke with error handling:")
        table.insert(lines, "local ok, result = pcall(function()")
        table.insert(lines, " return remote:Invoke()")
        table.insert(lines, "end)")
        table.insert(lines, 'print("[A9x] Invoke result:", ok, result)')
        table.insert(lines, "")
        table.insert(lines, "-- Hook OnInvoke to spy/override:")
        table.insert(lines, "-- local realFn = remote.OnInvoke")
        table.insert(lines, "-- remote.OnInvoke = function(...)")
        table.insert(lines, "-- print('[Hook OnInvoke]', ...)")
        table.insert(lines, "-- if realFn then return realFn(...) end")
        table.insert(lines, "-- end")
    elseif cn == "ClickDetector" then
        table.insert(lines, "-- ╔══════════════════════════════════╗")
        table.insert(lines, "-- ║ ClickDetector :: fireclickdetector║")
        table.insert(lines, "-- ╚══════════════════════════════════╝")
        table.insert(lines, "")
        table.insert(lines, "-- Fire click detector:")
        table.insert(lines, "fireclickdetector(remote)")
        table.insert(lines, "")
        table.insert(lines, "-- Rapid loop fire:")
        table.insert(lines, "-- while task.wait(0.05) do fireclickdetector(remote) end")
        table.insert(lines, "")
        table.insert(lines, "-- Listen to MouseClick event:")
        table.insert(lines, "-- remote.MouseClick:Connect(function(plr)")
        table.insert(lines, "-- print('[ClickDetector clicked by]', plr.Name)")
        table.insert(lines, "-- end)")
    elseif cn == "ProximityPrompt" then
        table.insert(lines, "-- ╔══════════════════════════════════╗")
        table.insert(lines, "-- ║ ProximityPrompt :: fireproximityprompt║")
        table.insert(lines, "-- ╚══════════════════════════════════╝")
        table.insert(lines, "")
        table.insert(lines, "-- Trigger proximity prompt:")
        table.insert(lines, "fireproximityprompt(remote)")
        table.insert(lines, "")
        table.insert(lines, "-- Loop trigger:")
        table.insert(lines, "-- while task.wait(0.1) do fireproximityprompt(remote) end")
        table.insert(lines, "")
        table.insert(lines, "-- Listen to Triggered event:")
        table.insert(lines, "-- remote.Triggered:Connect(function(plr)")
        table.insert(lines, "-- print('[Prompt triggered by]', plr.Name)")
        table.insert(lines, "-- end)")
        table.insert(lines, "")
        table.insert(lines, "-- Max distance override:")
        table.insert(lines, "-- remote.MaxActivationDistance = 9999")
    elseif cn == "TouchTransmitter" then
        table.insert(lines, "-- ╔══════════════════════════════════╗")
        table.insert(lines, "-- ║ TouchTransmitter :: firetouchinterest║")
        table.insert(lines, "-- ╚══════════════════════════════════╝")
        table.insert(lines, "")
        table.insert(lines, "local lp = game:GetService('Players').LocalPlayer")
        table.insert(lines, "local char = lp.Character or lp.CharacterAdded:Wait()")
        table.insert(lines, "local hrp = char:WaitForChild('HumanoidRootPart', 5)")
        table.insert(lines, "local touchPart = remote.Parent")
        table.insert(lines, "")
        table.insert(lines, "if hrp and touchPart then")
        table.insert(lines, " firetouchinterest(touchPart, hrp, 0) -- touch begin")
        table.insert(lines, " task.wait(0.10)")
        table.insert(lines, " firetouchinterest(touchPart, hrp, 1) -- touch end")
        table.insert(lines, " print('[A9x] TouchTransmitter fired on:', touchPart:GetFullName())")
        table.insert(lines, "else")
        table.insert(lines, " warn('[A9x] Could not find HumanoidRootPart or TouchPart')")
        table.insert(lines, "end")
        table.insert(lines, "")
        table.insert(lines, "-- Rapid loop:")
        table.insert(lines, "-- while task.wait(0.05) do")
        table.insert(lines, "-- pcall(firetouchinterest, touchPart, hrp, 0)")
        table.insert(lines, "-- task.wait(0.05)")
        table.insert(lines, "-- pcall(firetouchinterest, touchPart, hrp, 1)")
        table.insert(lines, "-- end")
    end

    table.insert(lines, "")
    table.insert(lines, '-- ════════════════════════════════════')
    table.insert(lines, '-- By Anonymous9x | Detector Manager')
    table.insert(lines, '-- ════════════════════════════════════')
    return table.concat(lines, "\n")
end

-- ══════════════════════════════════════════
-- BUILD ROW (redesigned for clean button)
-- ══════════════════════════════════════════
local rowOrder = 0
local rowFrames = {}

local function makeRow(inst)
    local fp = inst:GetFullName()
    local cn = inst.ClassName
    if rowFrames[fp] then return end

    rowOrder = rowOrder + 1
    local row = Instance.new("Frame")
    row.Name = "Row_" .. fp:sub(1, 32)
    row.Size = UDim2.new(1, 0, 0, RH)
    row.BackgroundColor3 = C.card
    row.BackgroundTransparency = 0
    row.BorderSizePixel = 0
    row.LayoutOrder = rowOrder
    row.ZIndex = 12
    row.Parent = scroll
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 5)

    local rStroke = Instance.new("UIStroke", row)
    rStroke.Color = isDangerous(inst) and C.danger or typeColor(inst)
    rStroke.Thickness = 0.7
    rStroke.Transparency = 0.45

    -- Color badge on the left
    local badge = Instance.new("Frame")
    badge.Size = UDim2.new(0, 6, 1, 0)
    badge.Position = UDim2.fromOffset(0, 0)
    badge.BackgroundColor3 = typeColor(inst)
    badge.BackgroundTransparency = 0.2
    badge.BorderSizePixel = 0
    badge.ZIndex = 13
    badge.Parent = row
    Instance.new("UICorner", badge).CornerRadius = UDim.new(1, 0)

    -- Right content area
    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, -12, 1, 0)
    content.Position = UDim2.fromOffset(10, 0)
    content.BackgroundTransparency = 1
    content.BorderSizePixel = 0
    content.ZIndex = 13
    content.Parent = row

    -- Name label
    local nameLbl = Instance.new("TextLabel")
    nameLbl.Size = UDim2.new(1, 0, 0, 16)
    nameLbl.Position = UDim2.fromOffset(0, 4)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Text = inst.Name
    nameLbl.Font = Enum.Font.GothamBold
    nameLbl.TextSize = 10
    nameLbl.TextColor3 = isDangerous(inst) and Color3.fromRGB(255, 110, 90) or C.pri
    nameLbl.TextXAlignment = Enum.TextXAlignment.Left
    nameLbl.TextTruncate = Enum.TextTruncate.AtEnd
    nameLbl.ZIndex = 14
    nameLbl.Parent = content

    -- Class + path
    local classLbl = Instance.new("TextLabel")
    classLbl.Size = UDim2.new(1, 0, 0, 14)
    classLbl.Position = UDim2.fromOffset(0, 20)
    classLbl.BackgroundTransparency = 1
    classLbl.Text = cn .. " | " .. fp
    classLbl.Font = Enum.Font.Gotham
    classLbl.TextSize = 7
    classLbl.TextColor3 = C.sec
    classLbl.TextXAlignment = Enum.TextXAlignment.Left
    classLbl.TextTruncate = Enum.TextTruncate.AtEnd
    classLbl.ZIndex = 14
    classLbl.Parent = content

    -- Copy Script button (full-width under text)
    local copyBtn = Instance.new("ImageButton")
    copyBtn.Size = UDim2.new(1, -4, 0, BTH)
    copyBtn.Position = UDim2.fromOffset(2, 36)
    copyBtn.BackgroundColor3 = C.accent
    copyBtn.BackgroundTransparency = 0.3
    copyBtn.BorderSizePixel = 0
    copyBtn.Image = ""
    copyBtn.AutoButtonColor = false
    copyBtn.ZIndex = 14
    copyBtn.Parent = content
    Instance.new("UICorner", copyBtn).CornerRadius = UDim.new(0, 4)

    local copyLbl = Instance.new("TextLabel")
    copyLbl.Size = UDim2.fromScale(1, 1)
    copyLbl.BackgroundTransparency = 1
    copyLbl.Text = "Copy Script"
    copyLbl.Font = Enum.Font.GothamBold
    copyLbl.TextSize = 9
    copyLbl.TextColor3 = C.white
    copyLbl.ZIndex = 15
    copyLbl.Parent = copyBtn

    copyBtn.MouseEnter:Connect(function()
        TS:Create(copyBtn, TweenInfo.new(0.10), {BackgroundColor3 = C.accent, BackgroundTransparency = 0}):Play()
    end)
    copyBtn.MouseLeave:Connect(function()
        TS:Create(copyBtn, TweenInfo.new(0.10), {BackgroundColor3 = C.accent, BackgroundTransparency = 0.3}):Play()
    end)

    copyBtn.MouseButton1Click:Connect(function()
        local script = generateScript(inst)
        local ok = pcall(function() setclipboard(script) end)
        if ok then
            copyLbl.Text = "Copied!"
        else
            print("=== Anonymous9x Generated Script ===")
            print(script)
            print("=== END ===")
            copyLbl.Text = "See Console"
        end
        task.delay(2.0, function()
            pcall(function() copyLbl.Text = "Copy Script" end)
        end)
    end)

    -- Cleanup
    local ancestConn
    ancestConn = inst.AncestryChanged:Connect(function()
        if not inst:IsDescendantOf(game) then
            pcall(function() ancestConn:Disconnect() end)
            rowFrames[fp] = nil
            pcall(function() row:Destroy() end)
            for i, v in ipairs(allInst) do
                if v == inst then table.remove(allInst, i); break end
            end
            countL.Text = #allInst .. " remotes found"
        end
    end)

    rowFrames[fp] = row
end

-- ══════════════════════════════════════════
-- FILTER / REBUILD LIST
-- ══════════════════════════════════════════
local function filterText()
    local q = searchBox.Text:lower()
    for _, child in ipairs(scroll:GetChildren()) do
        if child:IsA("Frame") then
            if q == "" then
                child.Visible = true
            else
                local n = (child.Name or ""):lower()
                child.Visible = n:find(q, 1, true) ~= nil
            end
        end
    end
end

local function clearRows()
    for _, c in ipairs(scroll:GetChildren()) do
        if c:IsA("Frame") then c:Destroy() end
    end
    rowFrames = {}
end

local function buildList()
    clearRows()
    for _, inst in ipairs(allInst) do
        makeRow(inst)
    end
    countL.Text = #allInst .. " remotes found"
    filterText()
end

-- ══════════════════════════════════════════
-- SCAN GAME
-- ══════════════════════════════════════════
local SCAN_CLASSES = {
    RemoteEvent = true, RemoteFunction = true,
    BindableEvent = true, BindableFunction = true,
    ClickDetector = true, ProximityPrompt = true,
    TouchTransmitter = true,
}

local function scanGame()
    allInst = {}
    for _, obj in ipairs(game:GetDescendants()) do
        if SCAN_CLASSES[obj.ClassName] then
            table.insert(allInst, obj)
        end
    end
    buildList()
end

-- ══════════════════════════════════════════
-- AUTO SCAN
-- ══════════════════════════════════════════
local function startAutoScan()
    autoScanOn = true
    autoL.Text = "Auto: ON"
    autoBtn.BackgroundColor3 = C.safe
    autoConA = game.DescendantAdded:Connect(function(obj)
        if SCAN_CLASSES[obj.ClassName] then
            table.insert(allInst, obj)
            makeRow(obj)
            countL.Text = #allInst .. " remotes found"
            filterText()
        end
    end)
    autoConR = game.DescendantRemoving:Connect(function(obj)
        if SCAN_CLASSES[obj.ClassName] then
            for i, v in ipairs(allInst) do
                if v == obj then table.remove(allInst, i); break end
            end
            local fp = obj:GetFullName()
            local row = rowFrames[fp]
            if row then
                rowFrames[fp] = nil
                pcall(function() row:Destroy() end)
            end
            countL.Text = #allInst .. " remotes found"
        end
    end)
end

local function stopAutoScan()
    autoScanOn = false
    autoL.Text = "Auto: OFF"
    autoBtn.BackgroundColor3 = C.card
    if autoConA then autoConA:Disconnect(); autoConA = nil end
    if autoConR then autoConR:Disconnect(); autoConR = nil end
end

autoBtn.MouseButton1Click:Connect(function()
    if autoScanOn then stopAutoScan() else startAutoScan() end
end)

-- ══════════════════════════════════════════
-- ANTIKILL
-- ══════════════════════════════════════════
local function applyAntiKill()
    for _, inst in ipairs(allInst) do
        if inst.ClassName == "TouchTransmitter" then
            local p = inst.Parent
            local fp = inst:GetFullName()
            if p and p:IsA("BasePart") then
                if antiKillOn then
                    antiKillData[fp] = p.CanTouch
                    pcall(function() p.CanTouch = false end)
                else
                    local orig = antiKillData[fp]
                    if orig ~= nil then
                        pcall(function() p.CanTouch = orig end)
                        antiKillData[fp] = nil
                    end
                end
            end
        end
    end
end

akBtn.MouseButton1Click:Connect(function()
    antiKillOn = not antiKillOn
    akL.Text = antiKillOn and "AntiKill ON" or "AntiKill"
    akBtn.BackgroundColor3 = antiKillOn and C.safe or C.card
    applyAntiKill()
end)

-- ══════════════════════════════════════════
-- STOP ALL LOOPS (Rescan)
-- ══════════════════════════════════════════
stopBtn.MouseButton1Click:Connect(function()
    for fp, loopD in pairs(loops) do
        if loopD then loopD.active = false end
    end
    loops = {}
    buildList()
end)

-- ══════════════════════════════════════════
-- REFRESH
-- ══════════════════════════════════════════
refBtn.MouseButton1Click:Connect(function()
    refL.Text = "..."
    task.spawn(function()
        scanGame()
        task.wait(0.1)
        pcall(function() refL.Text = "Refresh" end)
    end)
end)

-- Search filter live
searchBox:GetPropertyChangedSignal("Text"):Connect(function()
    filterText()
end)

-- ══════════════════════════════════════════
-- BOOT NOTIFICATION
-- ══════════════════════════════════════════
local function showBootNotif()
    local notif = Instance.new("Frame")
    notif.Size = UDim2.fromOffset(210, 42)
    notif.Position = UDim2.new(1, -220, 1, -60)
    notif.BackgroundColor3 = C.bg
    notif.BackgroundTransparency = 0
    notif.BorderSizePixel = 0
    notif.ZIndex = 900
    notif.Parent = gui
    Instance.new("UICorner", notif).CornerRadius = UDim.new(0, 6)
    local nS = Instance.new("UIStroke", notif)
    nS.Color = C.white; nS.Thickness = 1
    local nl1 = Instance.new("TextLabel")
    nl1.Size = UDim2.new(1, -10, 0, 18)
    nl1.Position = UDim2.fromOffset(8, 4)
    nl1.BackgroundTransparency = 1
    nl1.Text = "Anonymous9x Detector Manager"
    nl1.Font = Enum.Font.GothamBold
    nl1.TextSize = 9
    nl1.TextColor3 = C.white
    nl1.TextXAlignment = Enum.TextXAlignment.Left
    nl1.ZIndex = 901
    nl1.Parent = notif
    local nl2 = Instance.new("TextLabel")
    nl2.Size = UDim2.new(1, -10, 0, 14)
    nl2.Position = UDim2.fromOffset(8, 22)
    nl2.BackgroundTransparency = 1
    nl2.Text = "Loaded. Scanning remotes..."
    nl2.Font = Enum.Font.Gotham
    nl2.TextSize = 8
    nl2.TextColor3 = C.sec
    nl2.TextXAlignment = Enum.TextXAlignment.Left
    nl2.ZIndex = 901
    nl2.Parent = notif
    -- Slide in
    notif.Position = UDim2.new(1, 10, 1, -60)
    TS:Create(notif, TweenInfo.new(0.22, Enum.EasingStyle.Quad), {Position = UDim2.new(1, -220, 1, -60)}):Play()
    task.delay(3.5, function()
        TS:Create(notif, TweenInfo.new(0.22, Enum.EasingStyle.Quad), {Position = UDim2.new(1, 10, 1, -60)}):Play()
        task.delay(0.25, function() pcall(function() notif:Destroy() end) end)
    end)
end

-- ══════════════════════════════════════════
-- INIT
-- ══════════════════════════════════════════
showBootNotif()
task.spawn(function()
    task.wait(0.5)
    scanGame()
end)
