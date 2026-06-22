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
    btnBg   = Color3.fromRGB(28,  28,  30),
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
-- STATUS BAR (replaces notification popups)
-- ═══════════════════════════════════════════════
local statusFrame = Instance.new("Frame")
statusFrame.Size               = UDim2.fromOffset(W, 20)
statusFrame.Position           = UDim2.fromScale(0.5, 0.5)
statusFrame.AnchorPoint        = Vector2.new(0.5, 0.5)
statusFrame.BackgroundColor3   = C.bg
statusFrame.BackgroundTransparency = 0.2
statusFrame.BorderSizePixel    = 0
statusFrame.ZIndex             = 1000
statusFrame.Parent             = gui
Instance.new("UICorner", statusFrame).CornerRadius = UDim.new(0, 6)
local statusStroke = Instance.new("UIStroke", statusFrame)
statusStroke.Color = C.white
statusStroke.Thickness = 1
statusStroke.Transparency = 0.5

local statusLabel = Instance.new("TextLabel")
statusLabel.Size               = UDim2.new(1, 0, 1, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.Text               = ""
statusLabel.Font               = Enum.Font.GothamBold
statusLabel.TextSize            = 9
statusLabel.TextColor3          = C.white
statusLabel.TextXAlignment      = Enum.TextXAlignment.Center
statusLabel.ZIndex              = 1001
statusLabel.Parent              = statusFrame

local statusTween
local function setStatus(msg, color)
    if not color then color = C.white end
    if statusTween then statusTween:Cancel() end
    statusLabel.Text = msg
    statusLabel.TextColor3 = color
    statusFrame.Visible = true
    local vp = Cam.ViewportSize
    statusFrame.Position = UDim2.fromOffset(vp.X/2 - W/2, vp.Y - 60)
    statusTween = TweenService:Create(statusFrame, TweenInfo.new(2.0, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundTransparency = 0.85
    })
    statusTween:Play()
    task.delay(2.2, function()
        pcall(function()
            statusFrame.Visible = false
            statusLabel.Text = ""
            statusFrame.BackgroundTransparency = 0.2
        end)
    end)
end

-- ═══════════════════════════════════════════════
-- SHARED ANCHOR (above head)
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
-- TARGET ANCHOR (for send-part-to-target)
-- ═══════════════════════════════════════════════
local targetFolder = Instance.new("Folder", Workspace)
targetFolder.Name = "_A9xCtrlPartTarget"

local targetPart = Instance.new("Part", targetFolder)
targetPart.Anchored     = true
targetPart.CanCollide   = false
targetPart.Transparency = 1
targetPart.Size         = Vector3.new(0.2, 0.2, 0.2)

local targetAttachment = Instance.new("Attachment", targetPart)
targetAttachment.Name = "TargetAnchor"

local currentTargetPlayer = nil

local function updateTargetAnchor()
    if currentTargetPlayer then
        local char = currentTargetPlayer.Character
        local hrp  = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            targetAttachment.WorldCFrame = hrp.CFrame
        end
    end
end
RunService.RenderStepped:Connect(updateTargetAnchor)

local function setTargetPlayer(player)
    if currentTargetPlayer == player then return end
    currentTargetPlayer = player
    if player then
        local char = player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            targetAttachment.WorldCFrame = hrp.CFrame
        end
        setStatus("Target set: " .. player.Name, C.white)
    else
        setStatus("Target cleared", C.sec)
    end
end

-- ═══════════════════════════════════════════════
-- PART STATE TRACKING
-- ═══════════════════════════════════════════════
-- forcedParts[part] = {align=AlignPosition, torque=Torque, att=Attachment,
--                       origAnchored=bool, origCollide=bool,
--                       mode="bring"/"unanchor"/"throw"}
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
    if part:IsDescendantOf(targetFolder) then return false end
    if isCharacterPart(part) then return false end
    local nl = part.Name:lower()
    if nl:find("baseplate") then return false end
    if part.Size.Magnitude > 60 then return false end
    return true
end

local function forcePart(part, mode, targetAtt)
    if forcedParts[part] then return end   -- already forced

    local origAnchored = part.Anchored
    local origCollide  = part.CanCollide

    -- Clean any pre-existing movers
    for _, x in ipairs(part:GetChildren()) do
        if x:IsA("BodyMover") or x:IsA("RocketPropulsion") then
            pcall(function() x:Destroy() end)
        end
    end

    part.CanCollide = false
    if mode == "unanchor" or mode == "throw" then
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
    if mode == "throw" and targetAtt then
        align.Attachment1 = targetAtt
        align.Responsiveness = 500   -- brutal throw
        align.MaxVelocity  = 500
    else
        align.Attachment1 = anchorAttachment
    end

    forcedParts[part] = {
        align = align, torque = torque, att = att,
        origAnchored = origAnchored, origCollide = origCollide,
        mode = mode,
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
            if entry.mode == "unanchor" or entry.mode == "throw" then
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

local function releaseThrowParts()
    for part, entry in pairs(forcedParts) do
        if entry.mode == "throw" then
            releasePart(part)
        end
    end
end

-- ═══════════════════════════════════════════════
-- NEARBY PART SCAN
-- ═══════════════════════════════════════════════
local SCAN_RADIUS = 80
local SCAN_LIMIT  = 20   -- increased for throw

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
-- HEADER (with drag)
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

-- Title with 3D color shift
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

task.spawn(function()
    local t = 0
    while hdr.Parent do
        t = t + task.wait(0.05)
        local s = (math.sin(t * 1.1) + 1) / 2
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
-- DRAG (main panel only)
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
-- FLOAT ICON (minimized)
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
    pcall(function() targetFolder:Destroy() end)
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
        setStatus("Unanchor Nearby: Active", C.white)
    else
        for part, entry in pairs(forcedParts) do
            if entry.mode == "unanchor" then
                releasePart(part)
            end
        end
        setStatus("Unanchor Nearby: Stopped", C.sec)
    end
end})

-- ═══════════════════════════════════════════════
-- FEATURE 2 — BRING ALL NEARBY (upgraded brutal)
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
                                forcePart(obj, "bring")  -- already brutal with upgraded responsiveness
                            end
                        end
                    end
                end
                task.wait(0.8)
            end
        end)
        setStatus("Bring All Nearby: Active", C.white)
    else
        for part, entry in pairs(forcedParts) do
            if entry.mode == "bring" then
                releasePart(part)
            end
        end
        setStatus("Bring All Nearby: Stopped", C.sec)
    end
end})

mkBtn({title="Bring Selected", sub="Pulls only the tagged part above", cb=function()
    if not selectedPart or not selectedPart.Parent then
        setStatus("No part selected. Use Smart ESP to tag one.", C.sec)
        return
    end
    if selectedPart.Anchored then
        setStatus("That part is anchored — unanchor it first.", C.sec)
        return
    end
    forcePart(selectedPart, "bring")
    setStatus(selectedPart.Name .. " is now being pulled to you.", C.white)
end})

-- ═══════════════════════════════════════════════
-- FEATURE 3 — SMART ESP (nearby unanchored parts)
-- ═══════════════════════════════════════════════
mkSec("Smart ESP")
local espOn = false
local espTags = {}

local function clearEspTags()
    for part, data in pairs(espTags) do
        pcall(function() data.gui:Destroy() end)
        pcall(function() data.hl:Destroy() end)
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
        setStatus(part.Name .. " selected.", C.white)
    end)

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
                for part, _ in pairs(espTags) do
                    if not seen[part] then removeEspTag(part) end
                end
                task.wait(0.6)
            end
            clearEspTags()
        end)
        setStatus("Smart ESP: Active", C.white)
    else
        setStatus("Smart ESP: Disabled", C.sec)
    end
end})

-- ═══════════════════════════════════════════════
-- FEATURE 4 — SEND PART TO TARGET
-- ═══════════════════════════════════════════════
mkSec("Send Part To Target")

-- Player list refresh / selection
local playerListFrame = Instance.new("Frame")
playerListFrame.Size               = UDim2.new(1, 0, 0, 80)
playerListFrame.BackgroundColor3   = C.card
playerListFrame.BackgroundTransparency = 0
playerListFrame.BorderSizePixel    = 0
playerListFrame.LayoutOrder        = o()
playerListFrame.ZIndex             = 12
playerListFrame.Parent             = scroll
Instance.new("UICorner", playerListFrame).CornerRadius = UDim.new(0, 5)
local playerScroll = Instance.new("ScrollingFrame", playerListFrame)
playerScroll.Size = UDim2.new(1, -4, 1, -22)
playerScroll.Position = UDim2.fromOffset(2, 2)
playerScroll.BackgroundTransparency = 1
playerScroll.BorderSizePixel = 0
playerScroll.ScrollBarThickness = 2
playerScroll.ScrollBarImageColor3 = C.border
playerScroll.ScrollingDirection = Enum.ScrollingDirection.Y
playerScroll.CanvasSize = UDim2.fromOffset(0, 0)
playerScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
playerScroll.ZIndex = 13
local playerLL = Instance.new("UIListLayout", playerScroll)
playerLL.SortOrder = Enum.SortOrder.LayoutOrder
playerLL.Padding = UDim.new(0, 2)

local refreshBtn = Instance.new("ImageButton")
refreshBtn.Size               = UDim2.new(1, -4, 0, 16)
refreshBtn.Position           = UDim2.new(0, 2, 1, -20)
refreshBtn.BackgroundColor3   = C.btnBg
refreshBtn.BackgroundTransparency = 0
refreshBtn.BorderSizePixel    = 0
refreshBtn.Image              = ""
refreshBtn.AutoButtonColor    = false
refreshBtn.ZIndex             = 14
refreshBtn.Parent             = playerListFrame
Instance.new("UICorner", refreshBtn).CornerRadius = UDim.new(0, 4)
local refreshLbl = Instance.new("TextLabel")
refreshLbl.Size = UDim2.fromScale(1, 1)
refreshLbl.BackgroundTransparency = 1
refreshLbl.Text = "Refresh Players"
refreshLbl.Font = Enum.Font.GothamBold
refreshLbl.TextSize = 8
refreshLbl.TextColor3 = C.sec
refreshLbl.ZIndex = 15
refreshLbl.Parent = refreshBtn
refreshBtn.MouseButton1Click:Connect(function() end) -- connected below

local selectedTargetLabel = Instance.new("TextLabel")
selectedTargetLabel.Size               = UDim2.new(1, -10, 0, 16)
selectedTargetLabel.Position           = UDim2.fromOffset(7, 0)  -- will be placed below playerListFrame
selectedTargetLabel.BackgroundTransparency = 1
selectedTargetLabel.Text               = "Target: None"
selectedTargetLabel.Font               = Enum.Font.GothamBold
selectedTargetLabel.TextSize            = 8
selectedTargetLabel.TextColor3          = C.sec
selectedTargetLabel.TextXAlignment      = Enum.TextXAlignment.Left
selectedTargetLabel.ZIndex              = 12
selectedTargetLabel.LayoutOrder        = o()
selectedTargetLabel.Parent             = scroll

-- Refresh player list
local function refreshPlayerList()
    -- Clear old buttons
    for _, child in ipairs(playerScroll:GetChildren()) do
        if child:IsA("TextButton") or child:IsA("ImageButton") then
            child:Destroy()
        end
    end
    local players = Players:GetPlayers()
    table.sort(players, function(a,b) return a.Name < b.Name end)
    for _, plr in ipairs(players) do
        if plr ~= LP then
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, -4, 0, 18)
            btn.BackgroundColor3 = C.btnBg
            btn.BackgroundTransparency = 0
            btn.BorderSizePixel = 0
            btn.Text = plr.Name
            btn.Font = Enum.Font.Gotham
            btn.TextSize = 8
            btn.TextColor3 = C.pri
            btn.AutoButtonColor = false
            btn.ZIndex = 14
            btn.LayoutOrder = o()
            btn.Parent = playerScroll
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 3)
            btn.MouseButton1Click:Connect(function()
                setTargetPlayer(plr)
                updateTargetLabel()
            end)
        end
    end
end

refreshBtn.MouseButton1Click:Connect(function()
    refreshPlayerList()
    setStatus("Player list refreshed", C.sec)
end)
refreshPlayerList()

local function updateTargetLabel()
    if currentTargetPlayer and currentTargetPlayer.Parent then
        local char = currentTargetPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            local myChar = LP.Character
            local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
            if myHrp then
                local dist = (hrp.Position - myHrp.Position).Magnitude
                selectedTargetLabel.Text = string.format("Target: %s (%.0fm)", currentTargetPlayer.Name, dist)
            else
                selectedTargetLabel.Text = "Target: " .. currentTargetPlayer.Name
            end
        else
            selectedTargetLabel.Text = "Target: " .. currentTargetPlayer.Name .. " (no char)"
        end
    else
        selectedTargetLabel.Text = "Target: None"
    end
end

-- Smart Player ESP (auto-target nearest)
local smartPlayerESPon = false
local smartPlayerGui = nil

local function clearSmartPlayerGui()
    if smartPlayerGui then
        pcall(function() smartPlayerGui:Destroy() end)
        smartPlayerGui = nil
    end
end

local function updateSmartPlayerESP()
    if not smartPlayerESPon then return end
    local nearest = nil
    local nearestDist = math.huge
    local myChar = LP.Character
    local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myHrp then
        clearSmartPlayerGui()
        return
    end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP then
            local char = plr.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local dist = (hrp.Position - myHrp.Position).Magnitude
                if dist < nearestDist then
                    nearestDist = dist
                    nearest = plr
                end
            end
        end
    end
    if nearest then
        local char = nearest.Character
        local head = char and char:FindFirstChild("Head") or char and char:FindFirstChild("HumanoidRootPart")
        if head then
            if not smartPlayerGui or smartPlayerGui.Adornee ~= head then
                clearSmartPlayerGui()
                smartPlayerGui = Instance.new("BillboardGui")
                smartPlayerGui.Name = "_A9xSmartPlayer"
                smartPlayerGui.Size = UDim2.fromOffset(120, 36)
                smartPlayerGui.StudsOffset = Vector3.new(0, 2, 0)
                smartPlayerGui.AlwaysOnTop = true
                smartPlayerGui.Parent = head
                local box = Instance.new("Frame", smartPlayerGui)
                box.Size = UDim2.fromScale(1, 1)
                box.BackgroundColor3 = C.bg
                box.BackgroundTransparency = 0.1
                box.BorderSizePixel = 0
                Instance.new("UICorner", box).CornerRadius = UDim.new(0, 4)
                local boxS = Instance.new("UIStroke", box)
                boxS.Color = C.white; boxS.Thickness = 0.8; boxS.Transparency = 0.3
                local nameLbl = Instance.new("TextLabel", box)
                nameLbl.Size = UDim2.new(1, -6, 0, 14)
                nameLbl.Position = UDim2.fromOffset(3, 2)
                nameLbl.BackgroundTransparency = 1
                nameLbl.Text = nearest.Name
                nameLbl.Font = Enum.Font.GothamBold
                nameLbl.TextSize = 9
                nameLbl.TextColor3 = C.white
                nameLbl.ZIndex = 6
                local distLbl = Instance.new("TextLabel", box)
                distLbl.Size = UDim2.new(1, -6, 0, 11)
                distLbl.Position = UDim2.fromOffset(3, 15)
                distLbl.BackgroundTransparency = 1
                distLbl.Text = string.format("%.0f m", nearestDist)
                distLbl.Font = Enum.Font.Gotham
                distLbl.TextSize = 7
                distLbl.TextColor3 = C.sec
                distLbl.ZIndex = 6
                local selBtn = Instance.new("TextButton", box)
                selBtn.Size = UDim2.fromOffset(50, 12)
                selBtn.Position = UDim2.new(1, -56, 0, 2)
                selBtn.BackgroundColor3 = C.btnBg
                selBtn.BorderSizePixel = 0
                selBtn.Text = "Select"
                selBtn.Font = Enum.Font.GothamBold
                selBtn.TextSize = 7
                selBtn.TextColor3 = C.sec
                selBtn.AutoButtonColor = false
                selBtn.ZIndex = 7
                Instance.new("UICorner", selBtn).CornerRadius = UDim.new(0, 3)
                selBtn.MouseButton1Click:Connect(function()
                    setTargetPlayer(nearest)
                    updateTargetLabel()
                    playToggleSound()
                end)
            else
                -- update distance label
                local distLbl = smartPlayerGui:FindFirstChild("Frame") and smartPlayerGui.Frame:FindFirstChild("TextLabel")
                if distLbl then
                    distLbl.Text = string.format("%.0f m", nearestDist)
                end
            end
            return
        end
    end
    clearSmartPlayerGui()
end

RunService.RenderStepped:Connect(function()
    if smartPlayerESPon then
        updateSmartPlayerESP()
    end
end)

mkToggle({title="Smart Player ESP", sub="Show nearest player, tap to select target", cb=function(v)
    smartPlayerESPon = v
    if v then
        updateSmartPlayerESP()
        setStatus("Smart Player ESP: Active", C.white)
    else
        clearSmartPlayerGui()
        setStatus("Smart Player ESP: Disabled", C.sec)
    end
end})

-- Throw button
local throwBtn = mkBtn({title="Throw All Nearby Parts", sub="Hurls nearby parts to selected target", cb=function()
    if not currentTargetPlayer then
        setStatus("No target selected!", C.sec)
        return
    end
    local char = LP.Character
    local myHrp = char and char:FindFirstChild("HumanoidRootPart")
    if not myHrp then
        setStatus("You have no character!", C.sec)
        return
    end
    local targetChar = currentTargetPlayer.Character
    local targetHrp = targetChar and targetChar:FindFirstChild("HumanoidRootPart")
    if not targetHrp then
        setStatus("Target has no character!", C.sec)
        return
    end
    local dist = (targetHrp.Position - myHrp.Position).Magnitude
    if dist > 600 then
        setStatus("Target too far! Max 600m.", Color3.fromRGB(255,100,100))
        return
    end

    local nearby = scanNearbyParts()
    local count = 0
    for _, entry in ipairs(nearby) do
        local part = entry.part
        if not forcedParts[part] then
            -- unanchor if needed
            if part.Anchored then
                -- unanchor and then force
                part.Anchored = false
            end
            forcePart(part, "throw", targetAttachment)
            count = count + 1
        end
    end
    setStatus(string.format("Throwing %d parts to %s!", count, currentTargetPlayer.Name), C.white)
end})

local stopThrowBtn = mkBtn({title="Stop Throwing", sub="Release all thrown parts", cb=function()
    local count = 0
    for part, entry in pairs(forcedParts) do
        if entry.mode == "throw" then
            count = count + 1
        end
    end
    releaseThrowParts()
    setStatus(string.format("Released %d thrown parts.", count), C.sec)
end})

-- ═══════════════════════════════════════════════
-- RELEASE ALL
-- ═══════════════════════════════════════════════
mkSec("Reset")

mkBtn({title="Stop & Release All", sub="Cleans up every effect and restores parts", cb=function()
    unanchorOn   = false
    bringAllOn   = false
    espOn        = false
    smartPlayerESPon = false
    clearSmartPlayerGui()
    releaseAll()
    clearEspTags()
    setSelected(nil)
    setTargetPlayer(nil)
    updateTargetLabel()
    setStatus("All parts restored.", C.white)
end})

-- ═══════════════════════════════════════════════
-- INIT
-- ═══════════════════════════════════════════════
setStatus("Anonymous9x ControlPart loaded.", C.white)
