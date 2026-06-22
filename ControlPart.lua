-- ═══════════════════════════════════════════════
-- SERVICES
-- ═══════════════════════════════════════════════
local Players       = game:GetService("Players")
local RunService    = game:GetService("RunService")
local TweenService  = game:GetService("TweenService")
local UIS           = game:GetService("UserInputService")
local Workspace      = game:GetService("Workspace")
local LP             = Players.LocalPlayer
local Cam            = Workspace.CurrentCamera

-- ═══════════════════════════════════════════════
-- CLEANUP OLD INSTANCE
-- ═══════════════════════════════════════════════
pcall(function() game.CoreGui:FindFirstChild("_A9xCtrlPart"):Destroy() end)
pcall(function() LP.PlayerGui:FindFirstChild("_A9xCtrlPart"):Destroy() end)

-- ═══════════════════════════════════════════════
-- ROOT
-- ═══════════════════════════════════════════════
local gui = Instance.new("ScreenGui")
gui.Name             = "_A9xCtrlPart"
gui.ResetOnSpawn     = false
gui.ZIndexBehavior   = Enum.ZIndexBehavior.Sibling
gui.IgnoreGuiInset   = true
pcall(function() gui.Parent = game.CoreGui end)
if not gui.Parent then gui.Parent = LP.PlayerGui end

-- ═══════════════════════════════════════════════
-- THEME
-- ═══════════════════════════════════════════════
local C = {
    bg      = Color3.fromRGB(8,   8,   9),
    hdr     = Color3.fromRGB(5,   5,   6),
    card    = Color3.fromRGB(17,  17,  19),
    cardH   = Color3.fromRGB(25,  25,  28),
    sep     = Color3.fromRGB(28,  28,  31),
    border  = Color3.fromRGB(46,  46,  50),
    white   = Color3.new(1, 1, 1),
    pri     = Color3.fromRGB(222, 222, 226),
    sec     = Color3.fromRGB(118, 118, 126),
    dim     = Color3.fromRGB(60,  60,  66),
    btnBg   = Color3.fromRGB(28,  28,  30),   -- grey-black for ctrl buttons
}

local LOGO_ID  = "rbxassetid://97269958324726"
local TOGGLE_SOUND_ID = "rbxassetid://942127495"

local W   = 190
local H   = 215
local HDR = 26

-- ═══════════════════════════════════════════════
-- SOUND
-- ═══════════════════════════════════════════════
local toggleSound = Instance.new("Sound")
toggleSound.SoundId = TOGGLE_SOUND_ID
toggleSound.Volume  = 0.5
toggleSound.Parent  = gui
local function playToggleSound()
    pcall(function()
        if toggleSound.IsPlaying then toggleSound:Stop() end
        toggleSound:Play()
    end)
end

-- ═══════════════════════════════════════════════
-- NOTIFICATION SYSTEM  (bottom-right, black/white, smooth)
-- ═══════════════════════════════════════════════
local notifStack = {}

local function showNotif(title, body, dur)
    local f = Instance.new("Frame")
    f.Size               = UDim2.fromOffset(190, 46)
    f.Position           = UDim2.new(1, 12, 1, -58)
    f.BackgroundColor3   = C.bg
    f.BackgroundTransparency = 0
    f.BorderSizePixel    = 0
    f.ZIndex             = 900
    f.Parent             = gui
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 6)
    local fs = Instance.new("UIStroke", f)
    fs.Color = C.white; fs.Thickness = 1; fs.Transparency = 0.3

    local t1 = Instance.new("TextLabel")
    t1.Size               = UDim2.new(1, -10, 0, 16)
    t1.Position           = UDim2.fromOffset(7, 4)
    t1.BackgroundTransparency = 1
    t1.Text               = title
    t1.Font               = Enum.Font.GothamBold
    t1.TextSize            = 9
    t1.TextColor3          = C.white
    t1.TextXAlignment      = Enum.TextXAlignment.Left
    t1.ZIndex              = 901
    t1.Parent              = f

    local t2 = Instance.new("TextLabel")
    t2.Size               = UDim2.new(1, -10, 0, 20)
    t2.Position           = UDim2.fromOffset(7, 20)
    t2.BackgroundTransparency = 1
    t2.Text               = body
    t2.Font               = Enum.Font.Gotham
    t2.TextSize            = 7
    t2.TextColor3          = C.sec
    t2.TextXAlignment      = Enum.TextXAlignment.Left
    t2.TextWrapped         = true
    t2.ZIndex              = 901
    t2.Parent              = f

    local function recalc()
        for i, nf in ipairs(notifStack) do
            TweenService:Create(nf, TweenInfo.new(0.20, Enum.EasingStyle.Quad), {
                Position = UDim2.new(1, -202, 1, -58 - (i-1)*50)
            }):Play()
        end
    end

    table.insert(notifStack, 1, f)
    recalc()

    TweenService:Create(f, TweenInfo.new(0.20, Enum.EasingStyle.Quad), {
        Position = UDim2.new(1, -202, 1, -58)
    }):Play()

    task.delay(dur or 2.6, function()
        TweenService:Create(f, TweenInfo.new(0.18, Enum.EasingStyle.Quad), {
            Position = UDim2.new(1, 12, 1, f.Position.Y.Offset)
        }):Play()
        task.wait(0.20)
        for i, nf in ipairs(notifStack) do
            if nf == f then table.remove(notifStack, i); break end
        end
        recalc()
        pcall(function() f:Destroy() end)
    end)
end

-- ═══════════════════════════════════════════════
-- SHARED "BRING ANCHOR"  (follows head + offset)
-- ═══════════════════════════════════════════════
local anchorFolder = Instance.new("Folder", Workspace)
anchorFolder.Name = "_A9xCtrlPartAnchor"

local anchorPart = Instance.new("Part", anchorFolder)
anchorPart.Anchored     = true
anchorPart.CanCollide   = false
anchorPart.Transparency = 1
anchorPart.Size         = Vector3.new(0.2, 0.2, 0.2)

local anchorAttachment = Instance.new("Attachment", anchorPart)
anchorAttachment.Name = "BringAnchor"

local BRING_OFFSET = Vector3.new(0, 6, 0)

local function updateAnchor()
    local char = LP.Character
    local head = char and char:FindFirstChild("Head")
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    if head then
        anchorAttachment.WorldCFrame = head.CFrame * CFrame.new(BRING_OFFSET)
    elseif hrp then
        anchorAttachment.WorldCFrame = hrp.CFrame * CFrame.new(BRING_OFFSET)
    end
end

RunService.RenderStepped:Connect(updateAnchor)

-- ═══════════════════════════════════════════════
-- PART STATE TRACKING  (so we can cleanly release everything)
-- ═══════════════════════════════════════════════
-- forcedParts[part] = {align=AlignPosition, torque=Torque, att=Attachment,
--                       origAnchored=bool, origCollide=bool, mode="bring"/"unanchor"}
local forcedParts = {}

local function isCharacterPart(part)
    for _, plr in ipairs(Players:GetPlayers()) do
        local c = plr.Character
        if c and part:IsDescendantOf(c) then return true end
    end
    return false
end

local function isSafeToGrab(part)
    if not part:IsA("BasePart") then return false end
    if part:IsDescendantOf(Workspace.Terrain) then return false end
    if part:IsDescendantOf(anchorFolder) then return false end
    if isCharacterPart(part) then return false end
    local nl = part.Name:lower()
    if nl:find("baseplate") then return false end
    if part.Size.Magnitude > 60 then return false end   -- skip giant map chunks
    return true
end

-- Attach Torque + AlignPosition pulling toward the shared anchor.
-- Mirrors the proven JSY values (MaxForce=huge, Responsiveness=200).
local function forcePart(part, mode)
    if forcedParts[part] then return end   -- already forced

    local origAnchored = part.Anchored
    local origCollide  = part.CanCollide

    -- Clean any pre-existing movers so they don't fight our AlignPosition
    for _, x in ipairs(part:GetChildren()) do
        if x:IsA("BodyMover") or x:IsA("RocketPropulsion") then
            pcall(function() x:Destroy() end)
        end
    end

    part.CanCollide = false
    if mode == "unanchor" then
        part.Anchored = false
    end

    local att = Instance.new("Attachment", part)
    att.Name = "_A9xForceAtt"

    local torque = Instance.new("Torque", part)
    torque.Torque = Vector3.new(80000, 80000, 80000)
    torque.Attachment0 = att

    local align = Instance.new("AlignPosition", part)
    align.MaxForce       = math.huge
    align.MaxVelocity    = math.huge
    align.Responsiveness = 200
    align.Attachment0    = att
    align.Attachment1    = anchorAttachment

    forcedParts[part] = {
        align = align, torque = torque, att = att,
        origAnchored = origAnchored, origCollide = origCollide, mode = mode,
    }
end

local function releasePart(part)
    local entry = forcedParts[part]
    if not entry then return end
    pcall(function() entry.align:Destroy() end)
    pcall(function() entry.torque:Destroy() end)
    pcall(function() entry.att:Destroy() end)
    if part and part.Parent then
        pcall(function()
            part.CanCollide = entry.origCollide
            if entry.mode == "unanchor" then
                part.Anchored = entry.origAnchored
            end
        end)
    end
    forcedParts[part] = nil
end

local function releaseAll()
    for part, _ in pairs(forcedParts) do
        releasePart(part)
    end
end

-- ═══════════════════════════════════════════════
-- NEARBY PART SCAN  (radius-limited, capped count)
-- ═══════════════════════════════════════════════
local SCAN_RADIUS = 80
local SCAN_LIMIT  = 12

local function scanNearbyParts()
    local results = {}
    local char = LP.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return results end

    for _, obj in ipairs(Workspace:GetDescendants()) do
        if isSafeToGrab(obj) then
            local d = (obj.Position - hrp.Position).Magnitude
            if d <= SCAN_RADIUS then
                table.insert(results, {part = obj, dist = d})
            end
        end
    end

    table.sort(results, function(a, b) return a.dist < b.dist end)

    local capped = {}
    for i = 1, math.min(SCAN_LIMIT, #results) do
        capped[i] = results[i]
    end
    return capped
end

-- ═══════════════════════════════════════════════
-- WINDOW
-- ═══════════════════════════════════════════════
local win = Instance.new("Frame")
win.Name               = "Win"
win.Size               = UDim2.fromOffset(W, H)
win.Position           = UDim2.fromScale(0.5, 0.5)
win.AnchorPoint        = Vector2.new(0.5, 0.5)
win.BackgroundColor3   = C.bg
win.BackgroundTransparency = 0
win.BorderSizePixel    = 0
win.ClipsDescendants   = true
win.Active             = true
win.ZIndex             = 10
win.Parent             = gui
Instance.new("UICorner", win).CornerRadius = UDim.new(0, 8)

local winS = Instance.new("UIStroke", win)
winS.Thickness = 1.2; winS.Color = C.white; winS.Transparency = 0.35

task.spawn(function()
    local t = 0
    while win.Parent do
        t = t + task.wait(0.05)
        local s = (math.sin(t * 1.4) + 1) / 2
        winS.Transparency = 0.20 + s * 0.35
    end
end)

-- ═══════════════════════════════════════════════
-- HEADER  (with drag)
-- ═══════════════════════════════════════════════
local hdr = Instance.new("Frame")
hdr.Size             = UDim2.new(1, 0, 0, HDR)
hdr.BackgroundColor3 = C.hdr
hdr.BackgroundTransparency = 0
hdr.BorderSizePixel  = 0
hdr.ZIndex           = 11
hdr.Parent           = win
Instance.new("UICorner", hdr).CornerRadius = UDim.new(0, 8)

local hPatch = Instance.new("Frame")
hPatch.Size = UDim2.new(1,0,0,8); hPatch.Position = UDim2.new(0,0,1,-8)
hPatch.BackgroundColor3 = C.hdr; hPatch.BorderSizePixel=0; hPatch.ZIndex=10; hPatch.Parent=hdr

local hSep = Instance.new("Frame")
hSep.Size=UDim2.new(1,0,0,1); hSep.Position=UDim2.new(0,0,1,-1)
hSep.BackgroundColor3=C.sep; hSep.BorderSizePixel=0; hSep.ZIndex=12; hSep.Parent=hdr

-- Title with 3D black<->white color shift animation (default white)
local hTitle = Instance.new("TextLabel")
hTitle.Size               = UDim2.new(1, -50, 1, 0)
hTitle.Position           = UDim2.fromOffset(8, 0)
hTitle.BackgroundTransparency = 1
hTitle.Text               = "Anonymous9x ControlPart"
hTitle.Font               = Enum.Font.GothamBold
hTitle.TextSize            = 9
hTitle.TextColor3          = C.white
hTitle.TextStrokeTransparency = 0
hTitle.TextStrokeColor3    = Color3.fromRGB(20, 20, 22)
hTitle.TextXAlignment      = Enum.TextXAlignment.Left
hTitle.TextTruncate        = Enum.TextTruncate.AtEnd
hTitle.ZIndex              = 12
hTitle.Parent              = hdr

-- 3D embossed shift: main text fades white -> light grey,
-- stroke fades dark grey -> black, creating a subtle depth flip.
task.spawn(function()
    local t = 0
    while hdr.Parent do
        t = t + task.wait(0.05)
        local s = (math.sin(t * 1.1) + 1) / 2   -- 0..1
        hTitle.TextColor3       = Color3.new(1,1,1):Lerp(Color3.fromRGB(150,150,155), s*0.45)
        hTitle.TextStrokeColor3 = Color3.fromRGB(20,20,22):Lerp(Color3.new(0,0,0), s)
    end
end)

local function makeCtrl(xOff, sym)
    local b = Instance.new("ImageButton")
    b.Size               = UDim2.fromOffset(18, 16)
    b.Position           = UDim2.new(1, xOff, 0.5, -8)
    b.BackgroundColor3   = C.btnBg
    b.BackgroundTransparency = 0
    b.BorderSizePixel    = 0
    b.Image              = ""
    b.AutoButtonColor    = false
    b.ZIndex             = 13
    b.Parent             = hdr
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
    local bS = Instance.new("UIStroke", b)
    bS.Color = C.white; bS.Thickness = 0.9; bS.Transparency = 0.4
    -- glow loop
    task.spawn(function()
        local t = 0
        while b.Parent do
            t = t + task.wait(0.05)
            local s = (math.sin(t * 2.2) + 1) / 2
            bS.Transparency = 0.15 + s * 0.45
        end
    end)
    local l = Instance.new("TextLabel")
    l.Size               = UDim2.fromScale(1, 1)
    l.BackgroundTransparency = 1
    l.Text               = sym
    l.Font               = Enum.Font.GothamBold
    l.TextSize            = 11
    l.TextColor3          = C.sec
    l.ZIndex              = 14
    l.Parent              = b
    b.MouseEnter:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.10), {BackgroundColor3=C.cardH}):Play()
        l.TextColor3 = C.white
    end)
    b.MouseLeave:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.10), {BackgroundColor3=C.btnBg}):Play()
        l.TextColor3 = C.sec
    end)
    return b, l
end

local minBtn, minL   = makeCtrl(-40, "-")
local closeBtn, _    = makeCtrl(-20, "x")

-- ═══════════════════════════════════════════════
-- DRAG  (main panel only — header drag, global UIS)
-- ═══════════════════════════════════════════════
do
    local drag=false; local dRef=nil; local sI=nil; local sW=nil

    UIS.InputBegan:Connect(function(inp, gp)
        if gp then return end
        local isT = inp.UserInputType == Enum.UserInputType.Touch
        local isM = inp.UserInputType == Enum.UserInputType.MouseButton1
        if not (isT or isM) then return end
        local ap = hdr.AbsolutePosition
        local az = hdr.AbsoluteSize
        local px, py = inp.Position.X, inp.Position.Y
        if px < ap.X or px > ap.X+az.X-44 or py < ap.Y or py > ap.Y+az.Y then return end
        drag=true; dRef=inp
        sI = Vector2.new(px,py)
        sW = Vector2.new(win.AbsolutePosition.X, win.AbsolutePosition.Y)
    end)

    UIS.InputChanged:Connect(function(inp)
        if not drag then return end
        if inp.UserInputType ~= Enum.UserInputType.Touch
        and inp.UserInputType ~= Enum.UserInputType.MouseMove then return end
        if inp.UserInputType == Enum.UserInputType.Touch and inp ~= dRef then return end
        local d = Vector2.new(inp.Position.X,inp.Position.Y) - sI
        local vp = Cam.ViewportSize
        win.Position = UDim2.fromOffset(
            math.clamp(sW.X+d.X, 0, vp.X-W),
            math.clamp(sW.Y+d.Y, 0, vp.Y-H))
    end)

    UIS.InputEnded:Connect(function(inp)
        if inp==dRef or inp.UserInputType==Enum.UserInputType.MouseButton1 then
            drag=false; dRef=nil
        end
    end)
end

-- ═══════════════════════════════════════════════
-- FLOAT ICON  (minimized state — fixed position, no drag)
-- ═══════════════════════════════════════════════
local floatF = Instance.new("Frame")
floatF.Name             = "FloatIcon"
floatF.Size             = UDim2.fromOffset(40, 40)
floatF.BackgroundColor3 = C.hdr
floatF.BackgroundTransparency = 0
floatF.BorderSizePixel  = 0
floatF.Visible          = false
floatF.ZIndex           = 500
floatF.Parent           = gui
Instance.new("UICorner", floatF).CornerRadius = UDim.new(0, 9)
local fiS = Instance.new("UIStroke", floatF)
fiS.Color = C.white; fiS.Thickness = 1.1; fiS.Transparency = 0.3

task.spawn(function()
    local t = 0
    while gui.Parent do
        t = t + task.wait(0.05)
        local s = (math.sin(t * 1.6) + 1) / 2
        fiS.Transparency = 0.15 + s * 0.40
    end
end)

local fiImg = Instance.new("ImageLabel")
fiImg.Size               = UDim2.fromOffset(34, 34)
fiImg.Position           = UDim2.fromOffset(3, 3)
fiImg.BackgroundTransparency = 1
fiImg.Image              = LOGO_ID
fiImg.ScaleType          = Enum.ScaleType.Fit
fiImg.ZIndex             = 501
fiImg.Parent             = floatF

-- Fixed position: bottom-right area, vertically toward the bottom — locked, no drag
local function anchorFloat()
    local vp = Cam.ViewportSize
    if vp.X < 10 then vp = Vector2.new(800, 600) end
    floatF.Position = UDim2.fromOffset(vp.X - 56, vp.Y - 130)
end
anchorFloat()

local fiBtn = Instance.new("ImageButton")
fiBtn.Size               = UDim2.fromScale(1, 1)
fiBtn.BackgroundTransparency = 1
fiBtn.Image              = ""
fiBtn.AutoButtonColor    = false
fiBtn.ZIndex             = 502
fiBtn.Parent             = floatF
fiBtn.MouseButton1Click:Connect(function()
    floatF.Visible = false
    win.Visible    = true
    minL.Text      = "-"
end)

minBtn.MouseButton1Click:Connect(function()
    win.Visible = false
    anchorFloat()
    floatF.Visible = true
    minL.Text = "+"
end)

closeBtn.MouseButton1Click:Connect(function()
    releaseAll()
    pcall(function() anchorFolder:Destroy() end)
    pcall(function() gui:Destroy() end)
end)

-- ═══════════════════════════════════════════════
-- SCROLL BODY
-- ═══════════════════════════════════════════════
local scroll = Instance.new("ScrollingFrame")
scroll.Size                 = UDim2.new(1, 0, 1, -HDR)
scroll.Position             = UDim2.fromOffset(0, HDR)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel      = 0
scroll.ScrollBarThickness   = 2
scroll.ScrollBarImageColor3 = C.border
scroll.ScrollingDirection   = Enum.ScrollingDirection.Y
scroll.CanvasSize           = UDim2.fromOffset(0, 0)
scroll.AutomaticCanvasSize  = Enum.AutomaticSize.Y
scroll.ZIndex               = 11
scroll.Parent               = win

local sLL = Instance.new("UIListLayout")
sLL.SortOrder = Enum.SortOrder.LayoutOrder
sLL.Padding   = UDim.new(0, 4)
sLL.Parent    = scroll

local sPad = Instance.new("UIPadding")
sPad.PaddingLeft   = UDim.new(0, 6)
sPad.PaddingRight  = UDim.new(0, 6)
sPad.PaddingTop    = UDim.new(0, 6)
sPad.PaddingBottom = UDim.new(0, 8)
sPad.Parent        = scroll

local _o = 0
local function o() _o = _o + 1; return _o end

-- ═══════════════════════════════════════════════
-- COMPONENT LIBRARY
-- ═══════════════════════════════════════════════
local function mkSec(title)
    local f = Instance.new("Frame")
    f.Size               = UDim2.new(1, 0, 0, 14)
    f.BackgroundTransparency = 1
    f.LayoutOrder        = o()
    f.ZIndex             = 12
    f.Parent             = scroll
    local l = Instance.new("TextLabel")
    l.Size               = UDim2.fromScale(1, 1)
    l.BackgroundTransparency = 1
    l.Text               = title:upper()
    l.Font               = Enum.Font.GothamBold
    l.TextSize            = 6
    l.TextColor3          = C.dim
    l.TextXAlignment      = Enum.TextXAlignment.Left
    l.ZIndex              = 13
    l.Parent              = f
end

local function mkToggle(opts)
    local h = opts.sub and 36 or 26
    local card = Instance.new("Frame")
    card.Size               = UDim2.new(1, 0, 0, h)
    card.BackgroundColor3   = C.card
    card.BackgroundTransparency = 0
    card.BorderSizePixel    = 0
    card.LayoutOrder        = o()
    card.ZIndex             = 12
    card.Parent             = scroll
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 5)
    local tl = Instance.new("TextLabel")
    tl.Size               = UDim2.new(1, -38, 0, 12)
    tl.Position           = UDim2.fromOffset(7, opts.sub and 4 or 7)
    tl.BackgroundTransparency = 1
    tl.Text               = opts.title
    tl.Font               = Enum.Font.GothamSemibold
    tl.TextSize            = 8
    tl.TextColor3          = C.pri
    tl.TextXAlignment      = Enum.TextXAlignment.Left
    tl.ZIndex              = 13
    tl.Parent              = card
    if opts.sub then
        local sl = Instance.new("TextLabel")
        sl.Size               = UDim2.new(1, -10, 0, 10)
        sl.Position           = UDim2.fromOffset(7, 18)
        sl.BackgroundTransparency = 1
        sl.Text               = opts.sub
        sl.Font               = Enum.Font.Gotham
        sl.TextSize            = 6
        sl.TextColor3          = C.sec
        sl.TextXAlignment      = Enum.TextXAlignment.Left
        sl.ZIndex              = 13
        sl.Parent              = card
    end
    local TW, TH2 = 22, 12
    local trk = Instance.new("Frame")
    trk.Size             = UDim2.fromOffset(TW, TH2)
    trk.Position         = UDim2.new(1, -(TW+6), 0.5, -(TH2/2))
    trk.BackgroundColor3 = C.border
    trk.BorderSizePixel  = 0
    trk.ZIndex           = 13
    trk.Parent           = card
    Instance.new("UICorner", trk).CornerRadius = UDim.new(1, 0)
    local KS = TH2 - 4
    local knob = Instance.new("Frame")
    knob.Size             = UDim2.fromOffset(KS, KS)
    knob.Position         = UDim2.fromOffset(2, 2)
    knob.BackgroundColor3 = C.white
    knob.BorderSizePixel  = 0
    knob.ZIndex           = 14
    knob.Parent           = trk
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
    local state = false
    local hit = Instance.new("ImageButton")
    hit.Size               = UDim2.fromScale(1, 1)
    hit.BackgroundTransparency = 1
    hit.Image              = ""
    hit.AutoButtonColor    = false
    hit.ZIndex             = 15
    hit.Parent             = card
    hit.MouseButton1Click:Connect(function()
        state = not state
        TweenService:Create(trk, TweenInfo.new(0.12), {
            BackgroundColor3 = state and C.white or C.border
        }):Play()
        TweenService:Create(knob, TweenInfo.new(0.12), {
            Position = state and UDim2.fromOffset(TW-KS-2, 2) or UDim2.fromOffset(2, 2),
            BackgroundColor3 = state and C.bg or C.white,
        }):Play()
        playToggleSound()
        if opts.cb then opts.cb(state) end
    end)
    hit.MouseEnter:Connect(function() TweenService:Create(card, TweenInfo.new(0.10), {BackgroundColor3=C.cardH}):Play() end)
    hit.MouseLeave:Connect(function() TweenService:Create(card, TweenInfo.new(0.10), {BackgroundColor3=C.card}):Play() end)
    return card
end

local function mkBtn(opts)
    local h = opts.sub and 32 or 24
    local btn = Instance.new("ImageButton")
    btn.Size               = UDim2.new(1, 0, 0, h)
    btn.BackgroundColor3   = C.card
    btn.BackgroundTransparency = 0
    btn.BorderSizePixel    = 0
    btn.Image              = ""
    btn.AutoButtonColor    = false
    btn.LayoutOrder        = o()
    btn.ZIndex             = 12
    btn.Parent             = scroll
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
    local bS = Instance.new("UIStroke", btn); bS.Color=C.border; bS.Thickness=0.8
    local tl = Instance.new("TextLabel")
    tl.Size               = UDim2.new(1, -10, 0, 11)
    tl.Position           = UDim2.fromOffset(7, opts.sub and 4 or 6)
    tl.BackgroundTransparency = 1
    tl.Text               = opts.title
    tl.Font               = Enum.Font.GothamBold
    tl.TextSize            = 8
    tl.TextColor3          = C.pri
    tl.TextXAlignment      = Enum.TextXAlignment.Left
    tl.ZIndex              = 13
    tl.Parent              = btn
    if opts.sub then
        local sl = Instance.new("TextLabel")
        sl.Size               = UDim2.new(1, -10, 0, 10)
        sl.Position           = UDim2.fromOffset(7, 17)
        sl.BackgroundTransparency = 1
        sl.Text               = opts.sub
        sl.Font               = Enum.Font.Gotham
        sl.TextSize            = 6
        sl.TextColor3          = C.sec
        sl.TextXAlignment      = Enum.TextXAlignment.Left
        sl.ZIndex              = 13
        sl.Parent              = btn
    end
    btn.MouseButton1Click:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.08), {BackgroundColor3=C.cardH}):Play()
        task.delay(0.14, function() pcall(function() TweenService:Create(btn, TweenInfo.new(0.10), {BackgroundColor3=C.card}):Play() end) end)
        playToggleSound()
        if opts.cb then opts.cb() end
    end)
    btn.MouseEnter:Connect(function() TweenService:Create(btn, TweenInfo.new(0.10), {BackgroundColor3=C.cardH}):Play() end)
    btn.MouseLeave:Connect(function() TweenService:Create(btn, TweenInfo.new(0.10), {BackgroundColor3=C.card}):Play() end)
    return btn
end

-- ═══════════════════════════════════════════════
-- SELECTED PART LABEL
-- ═══════════════════════════════════════════════
local selectedPart = nil

mkSec("Status")
local statusCard = Instance.new("Frame")
statusCard.Size               = UDim2.new(1, 0, 0, 24)
statusCard.BackgroundColor3   = C.card
statusCard.BackgroundTransparency = 0
statusCard.BorderSizePixel    = 0
statusCard.LayoutOrder        = o()
statusCard.ZIndex             = 12
statusCard.Parent             = scroll
Instance.new("UICorner", statusCard).CornerRadius = UDim.new(0, 5)
local statusLbl = Instance.new("TextLabel")
statusLbl.Size               = UDim2.new(1, -10, 1, 0)
statusLbl.Position           = UDim2.fromOffset(7, 0)
statusLbl.BackgroundTransparency = 1
statusLbl.Text               = "Selected: None"
statusLbl.Font               = Enum.Font.GothamSemibold
statusLbl.TextSize            = 8
statusLbl.TextColor3          = C.sec
statusLbl.TextXAlignment      = Enum.TextXAlignment.Left
statusLbl.TextTruncate        = Enum.TextTruncate.AtEnd
statusLbl.ZIndex              = 13
statusLbl.Parent              = statusCard

local function setSelected(part)
    selectedPart = part
    statusLbl.Text = "Selected: " .. (part and part.Name or "None")
    statusLbl.TextColor3 = part and C.white or C.sec
end

-- ═══════════════════════════════════════════════
-- FEATURE 1 — UNANCHOR NEARBY
-- ═══════════════════════════════════════════════
mkSec("Chaos")
local unanchorOn = false
local unanchorLoop = nil

mkToggle({title="Unanchor Nearby", sub="Frees anchored parts near you", cb=function(v)
    unanchorOn = v
    if v then
        unanchorLoop = task.spawn(function()
            while unanchorOn do
                local char = LP.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    for _, obj in ipairs(Workspace:GetDescendants()) do
                        if obj:IsA("BasePart") and obj.Anchored and isSafeToGrab(obj) then
                            local d = (obj.Position - hrp.Position).Magnitude
                            if d <= SCAN_RADIUS then
                                forcePart(obj, "unanchor")
                            end
                        end
                    end
                end
                task.wait(0.8)
            end
        end)
        showNotif("Unanchor Nearby", "Active — freeing nearby parts.", 3)
    else
        -- Release only the parts we unanchored, not bring-mode parts
        for part, entry in pairs(forcedParts) do
            if entry.mode == "unanchor" then
                releasePart(part)
            end
        end
        showNotif("Unanchor Nearby", "Stopped. Parts restored.", 2.5)
    end
end})

-- ═══════════════════════════════════════════════
-- FEATURE 2 — BRING ALL NEARBY
-- ═══════════════════════════════════════════════
mkSec("Bring")
local bringAllOn = false

mkToggle({title="Bring All Nearby", sub="Pulls loose parts above your head", cb=function(v)
    bringAllOn = v
    if v then
        task.spawn(function()
            while bringAllOn do
                local char = LP.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    for _, obj in ipairs(Workspace:GetDescendants()) do
                        if obj:IsA("BasePart") and not obj.Anchored and isSafeToGrab(obj) then
                            local d = (obj.Position - hrp.Position).Magnitude
                            if d <= SCAN_RADIUS then
                                forcePart(obj, "bring")
                            end
                        end
                    end
                end
                task.wait(0.8)
            end
        end)
        showNotif("Bring All Nearby", "Active — pulling loose parts to you.", 3)
    else
        for part, entry in pairs(forcedParts) do
            if entry.mode == "bring" then
                releasePart(part)
            end
        end
        showNotif("Bring All Nearby", "Stopped. Parts released.", 2.5)
    end
end})

mkBtn({title="Bring Selected", sub="Pulls only the tagged part above", cb=function()
    if not selectedPart or not selectedPart.Parent then
        showNotif("Bring Selected", "No part selected. Use Smart ESP to tag one.", 3)
        return
    end
    if selectedPart.Anchored then
        showNotif("Bring Selected", "That part is anchored — unanchor it first.", 3)
        return
    end
    forcePart(selectedPart, "bring")
    showNotif("Bring Selected", selectedPart.Name .. " is now being pulled to you.", 2.5)
end})

-- ═══════════════════════════════════════════════
-- FEATURE 3 — SMART ESP  (nearby unanchored parts only)
-- ═══════════════════════════════════════════════
mkSec("Smart ESP")
local espOn = false
local espTags = {}   -- part -> {gui=BillboardGui}

local function clearEspTags()
    for part, data in pairs(espTags) do
        pcall(function() data.gui:Destroy() end)
    end
    espTags = {}
end

local function buildEspTag(part)
    if espTags[part] then return end

    local bb = Instance.new("BillboardGui")
    bb.Name           = "_A9xEspTag"
    bb.Size            = UDim2.fromOffset(86, 30)
    bb.StudsOffset     = Vector3.new(0, 1.2, 0)
    bb.AlwaysOnTop     = true
    bb.MaxDistance     = SCAN_RADIUS + 20
    bb.Parent          = part

    local box = Instance.new("Frame")
    box.Size               = UDim2.fromScale(1, 1)
    box.BackgroundColor3   = C.bg
    box.BackgroundTransparency = 0.1
    box.BorderSizePixel    = 0
    box.ZIndex             = 5
    box.Parent             = bb
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 4)
    local boxS = Instance.new("UIStroke", box)
    boxS.Color = C.white; boxS.Thickness = 0.8; boxS.Transparency = 0.3

    local nameLbl = Instance.new("TextLabel")
    nameLbl.Size               = UDim2.new(1, -6, 0, 14)
    nameLbl.Position           = UDim2.fromOffset(3, 2)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Text               = part.Name
    nameLbl.Font               = Enum.Font.GothamBold
    nameLbl.TextSize            = 9
    nameLbl.TextColor3          = C.white
    nameLbl.TextTruncate        = Enum.TextTruncate.AtEnd
    nameLbl.ZIndex              = 6
    nameLbl.Parent              = box

    local tapLbl = Instance.new("TextLabel")
    tapLbl.Size               = UDim2.new(1, -6, 0, 11)
    tapLbl.Position           = UDim2.fromOffset(3, 15)
    tapLbl.BackgroundTransparency = 1
    tapLbl.Text               = "Tap to select"
    tapLbl.Font               = Enum.Font.Gotham
    tapLbl.TextSize            = 7
    tapLbl.TextColor3          = C.sec
    tapLbl.ZIndex              = 6
    tapLbl.Parent              = box

    local hit = Instance.new("ImageButton")
    hit.Size               = UDim2.fromScale(1, 1)
    hit.BackgroundTransparency = 1
    hit.Image              = ""
    hit.AutoButtonColor    = false
    hit.ZIndex             = 7
    hit.Parent             = box
    hit.MouseButton1Click:Connect(function()
        setSelected(part)
        boxS.Color = C.white
        box.BackgroundTransparency = 0
        playToggleSound()
        showNotif("Part Selected", part.Name .. " tagged for Bring Selected.", 2.2)
    end)

    -- Thin highlight to make it pop visually
    local hl = Instance.new("Highlight")
    hl.Name             = "_A9xEspHL"
    hl.FillTransparency = 0.85
    hl.OutlineTransparency = 0.2
    hl.FillColor        = Color3.new(1,1,1)
    hl.OutlineColor     = Color3.new(1,1,1)
    hl.Adornee          = part
    hl.Parent           = part

    espTags[part] = {gui = bb, hl = hl}
end

local function removeEspTag(part)
    local data = espTags[part]
    if not data then return end
    pcall(function() data.gui:Destroy() end)
    pcall(function() data.hl:Destroy() end)
    espTags[part] = nil
end

mkToggle({title="Smart ESP", sub="Tags closest loose parts, tap to select", cb=function(v)
    espOn = v
    if v then
        task.spawn(function()
            while espOn do
                local nearby = scanNearbyParts()
                local seen = {}
                for _, entry in ipairs(nearby) do
                    seen[entry.part] = true
                    buildEspTag(entry.part)
                end
                -- Remove tags for parts no longer nearby
                for part, _ in pairs(espTags) do
                    if not seen[part] then removeEspTag(part) end
                end
                task.wait(0.6)
            end
            clearEspTags()
        end)
        showNotif("Smart ESP", "Scanning nearby loose parts.", 2.5)
    else
        showNotif("Smart ESP", "ESP disabled.", 2)
    end
end})

-- ═══════════════════════════════════════════════
-- RELEASE ALL
-- ═══════════════════════════════════════════════
mkSec("Reset")

mkBtn({title="Stop & Release All", sub="Cleans up every effect and restores parts", cb=function()
    unanchorOn   = false
    bringAllOn   = false
    espOn        = false
    releaseAll()
    clearEspTags()
    setSelected(nil)
    showNotif("Released", "All parts restored to their original state.", 3)
end})

-- ═══════════════════════════════════════════════
-- INIT
-- ═══════════════════════════════════════════════
showNotif("Anonymous9x ControlPart", "Loaded. Unanchor, Bring, and Smart ESP ready.", 4)
