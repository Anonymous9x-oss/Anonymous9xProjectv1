--[[ Indo Voice Auto Fish | Custom UI by @Anonymous9x ]]

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LP = Players.LocalPlayer
local Cam = workspace.CurrentCamera

-- Character
local char, hum, hrp
local function linkChar(c)
    char = c
    hum = c:WaitForChild("Humanoid", 10)
    hrp = c:WaitForChild("HumanoidRootPart", 10)
end
if LP.Character then linkChar(LP.Character) end
LP.CharacterAdded:Connect(linkChar)

-- Remotes (fallback mencari di Events/Remote)
local sellAllRemote, rodRemote, equipRemote
pcall(function()
    local Events = ReplicatedStorage:FindFirstChild("Events")
    if Events then
        local RemoteEvent = Events:FindFirstChild("RemoteEvent")
        local RemoteFunction = Events:FindFirstChild("RemoteFunction")
        if RemoteEvent then
            rodRemote = RemoteEvent:FindFirstChild("Rod") or RemoteEvent:FindFirstChild("RodRemoteEvent")
        end
        if RemoteFunction then
            sellAllRemote = RemoteFunction:FindFirstChild("SellAllFishFunction") or RemoteFunction:FindFirstChild("SellFish")
            equipRemote = RemoteFunction:FindFirstChild("EquipTools") or RemoteFunction:FindFirstChild("EquipRod")
        end
    end
    -- fallback direct
    if not sellAllRemote then
        sellAllRemote = ReplicatedStorage:FindFirstChild("SellAllFishFunction") or ReplicatedStorage:FindFirstChild("Remote"):FindFirstChild("SellAllFishFunction")
    end
end)

-- Animation IDs
local CAST_ANIM_ID = "rbxassetid://107858786510758"
local PULL_ANIM_ID = "rbxassetid://136444937709795"

-- State
local autoFishing = false
local stage = "Idle"
local timer = 0
local castAnimPlayed = false
local pullAnimPlayed = false
local fishCaught = 0
local totalTimeouts = 0
local animConn
local fishingThread

-- Timing config (bisa diubah nanti)
local timeouts = {
    CAST_HOLD_DURATION = 0.7,
    POST_PULL_DELAY = 1.8,
    PRE_END_DELAY = 0,
    POST_END_DELAY = 0.3,
    PRE_CAST_DELAY = 0.3,
    VERIFY_CAST_TIMEOUT = 2.5,
    WAITING_PULL_TIMEOUT = 20,
    POST_PULL_TIMEOUT = 5,
}

-- ==================== UI ====================
local gui = Instance.new("ScreenGui")
gui.Name = "_A9xIV"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = game.CoreGui or LP.PlayerGui

local T = {
    bg = Color3.fromRGB(7, 7, 9),
    hdr = Color3.fromRGB(5, 5, 7),
    card = Color3.fromRGB(15, 15, 19),
    cardH = Color3.fromRGB(21, 21, 27),
    sep = Color3.fromRGB(26, 26, 34),
    border = Color3.fromRGB(40, 40, 56),
    white = Color3.new(1, 1, 1),
    pri = Color3.fromRGB(218, 218, 226),
    sec = Color3.fromRGB(110, 110, 130),
    purple = Color3.fromRGB(170, 110, 255),
    safe = Color3.fromRGB(80, 185, 90),
    danger = Color3.fromRGB(210, 55, 55),
}
local W = 240
local HDR = 32
local H = 360

local win = Instance.new("Frame")
win.Name = "Win"
win.Size = UDim2.fromOffset(W, H)
win.Position = UDim2.fromScale(0.5, 0.5)
win.AnchorPoint = Vector2.new(0.5, 0.5)
win.BackgroundColor3 = T.bg
win.BorderSizePixel = 0
win.ClipsDescendants = true
win.ZIndex = 10
win.Parent = gui
Instance.new("UICorner", win).CornerRadius = UDim.new(0, 8)
local winS = Instance.new("UIStroke", win)
winS.Thickness = 1.3
winS.Color = T.border

-- Glow
task.spawn(function()
    local t = 0
    while win.Parent do
        t = t + task.wait(0.04)
        local s = (math.sin(t * 2.4) + 1) / 2
        winS.Color = Color3.new(0.86 + s * 0.14, 0.76 + s * 0.05, 0.88 + s * 0.52)
        winS.Thickness = 1.2 + s * 0.6
        if math.random(1, 90) == 1 then winS.Color = T.purple task.wait(0.04) end
    end
end)

local shimmerF = Instance.new("Frame")
shimmerF.Size = UDim2.fromOffset(W*3, H)
shimmerF.Position = UDim2.fromOffset(-W, 0)
shimmerF.BackgroundColor3 = Color3.new(1,1,1)
shimmerF.BackgroundTransparency = 1
shimmerF.BorderSizePixel = 0
shimmerF.ZIndex = 9
shimmerF.Parent = win
local shimmerGrad = Instance.new("UIGradient")
shimmerGrad.Rotation = 35
shimmerGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.new(1,1,1)),
    ColorSequenceKeypoint.new(0.4, Color3.new(1,1,1)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(180,140,255)),
    ColorSequenceKeypoint.new(0.6, Color3.new(1,1,1)),
    ColorSequenceKeypoint.new(1, Color3.new(1,1,1)),
})
shimmerGrad.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 1),
    NumberSequenceKeypoint.new(0.4, 1),
    NumberSequenceKeypoint.new(0.5, 0.92),
    NumberSequenceKeypoint.new(0.6, 1),
    NumberSequenceKeypoint.new(1, 1),
})
shimmerGrad.Parent = shimmerF
task.spawn(function()
    while win.Parent do
        TweenService:Create(shimmerF, TweenInfo.new(3.2, Enum.EasingStyle.Linear), {Position = UDim2.fromOffset(W, 0)}):Play()
        task.wait(3.3)
        shimmerF.Position = UDim2.fromOffset(-W, 0)
        task.wait(0.1)
    end
end)

local hdr = Instance.new("Frame")
hdr.Size = UDim2.new(1,0,0,HDR)
hdr.BackgroundColor3 = T.hdr
hdr.BorderSizePixel = 0
hdr.ZIndex = 12
hdr.Parent = win
Instance.new("UICorner", hdr).CornerRadius = UDim.new(0, 8)
local hPatch = Instance.new("Frame")
hPatch.Size = UDim2.new(1,0,0,8)
hPatch.Position = UDim2.new(0,0,1,-8)
hPatch.BackgroundColor3 = T.hdr
hPatch.BorderSizePixel = 0
hPatch.ZIndex = 11
hPatch.Parent = hdr
local hSep = Instance.new("Frame")
hSep.Size = UDim2.new(1,0,0,1)
hSep.Position = UDim2.new(0,0,1,-1)
hSep.BackgroundColor3 = T.sep
hSep.BorderSizePixel = 0
hSep.ZIndex = 13
hSep.Parent = hdr
local hTitle = Instance.new("TextLabel")
hTitle.Size = UDim2.new(1,-52,1,0)
hTitle.Position = UDim2.fromOffset(9,0)
hTitle.BackgroundTransparency = 1
hTitle.Text = "Indo Voice | @Anonymous9x"
hTitle.Font = Enum.Font.GothamBold
hTitle.TextSize = 10
hTitle.TextColor3 = T.pri
hTitle.TextXAlignment = Enum.TextXAlignment.Left
hTitle.TextTruncate = Enum.TextTruncate.AtEnd
hTitle.ZIndex = 13
hTitle.Parent = hdr

local function makeCtrl(xOff, sym)
    local b = Instance.new("ImageButton")
    b.Size = UDim2.fromOffset(20,18)
    b.Position = UDim2.new(1,xOff,0.5,-9)
    b.BackgroundColor3 = T.card
    b.BorderSizePixel = 0
    b.Image = ""
    b.AutoButtonColor = false
    b.ZIndex = 14
    b.Parent = hdr
    Instance.new("UICorner",b).CornerRadius = UDim.new(0,4)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.fromScale(1,1)
    l.BackgroundTransparency = 1
    l.Text = sym
    l.Font = Enum.Font.GothamBold
    l.TextSize = 12
    l.TextColor3 = T.sec
    l.ZIndex = 15
    l.Parent = b
    b.MouseEnter:Connect(function()
        TweenService:Create(b,TweenInfo.new(0.10),{BackgroundColor3=T.cardH}):Play()
        l.TextColor3 = T.white
    end)
    b.MouseLeave:Connect(function()
        TweenService:Create(b,TweenInfo.new(0.10),{BackgroundColor3=T.card}):Play()
        l.TextColor3 = T.sec
    end)
    return b, l
end
local minBtn, minL = makeCtrl(-44, "-")
local closeBtn, _ = makeCtrl(-22, "x")

local floatF = Instance.new("Frame")
floatF.Name = "FloatIcon"
floatF.Size = UDim2.fromOffset(46,46)
floatF.BackgroundColor3 = T.hdr
floatF.BorderSizePixel = 0
floatF.Visible = false
floatF.ZIndex = 500
floatF.Parent = gui
Instance.new("UICorner",floatF).CornerRadius = UDim.new(0,10)
local fiS = Instance.new("UIStroke",floatF)
fiS.Color = T.purple
fiS.Thickness = 1.4
task.spawn(function()
    local t = 0
    while gui.Parent do
        t = t + task.wait(0.05)
        local s = (math.sin(t*3)+1)/2
        fiS.Color = Color3.new(0.8+s*0.2, 0.5+s*0.1, 1)
        fiS.Thickness = 1.2+s*0.6
    end
end)
local fiImg = Instance.new("ImageLabel")
fiImg.Size = UDim2.fromOffset(40,40)
fiImg.Position = UDim2.fromOffset(3,3)
fiImg.BackgroundTransparency = 1
fiImg.Image = "rbxassetid://97269958324726"
fiImg.ScaleType = Enum.ScaleType.Crop
fiImg.ZIndex = 501
fiImg.Parent = floatF
Instance.new("UICorner",fiImg).CornerRadius = UDim.new(0,8)
local function anchorFloat()
    floatF.Position = UDim2.fromOffset(Cam.ViewportSize.X-56, math.floor(Cam.ViewportSize.Y/2)-23)
end
anchorFloat()
local fiBtn = Instance.new("ImageButton")
fiBtn.Size = UDim2.fromScale(1,1)
fiBtn.BackgroundTransparency = 1
fiBtn.Image = ""
fiBtn.AutoButtonColor = false
fiBtn.ZIndex = 502
fiBtn.Parent = floatF
fiBtn.MouseButton1Click:Connect(function()
    floatF.Visible = false
    win.Visible = true
    minL.Text = "-"
end)
fiBtn.MouseEnter:Connect(function()
    TweenService:Create(floatF,TweenInfo.new(0.12),{BackgroundColor3=T.card}):Play()
end)
fiBtn.MouseLeave:Connect(function()
    TweenService:Create(floatF,TweenInfo.new(0.12),{BackgroundColor3=T.hdr}):Play()
end)

minBtn.MouseButton1Click:Connect(function()
    win.Visible = false
    anchorFloat()
    floatF.Visible = true
    minL.Text = "+"
end)

closeBtn.MouseButton1Click:Connect(function()
    autoFishing = false
    if animConn then animConn:Disconnect() end
    gui:Destroy()
end)

-- Scroll area
local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1,0,1,-HDR)
scroll.Position = UDim2.fromOffset(0,HDR)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 3
scroll.ScrollBarImageColor3 = T.purple
scroll.ScrollingDirection = Enum.ScrollingDirection.Y
scroll.CanvasSize = UDim2.fromOffset(0,0)
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.ZIndex = 11
scroll.Parent = win
local sLL = Instance.new("UIListLayout")
sLL.SortOrder = Enum.SortOrder.LayoutOrder
sLL.Padding = UDim.new(0,4)
sLL.Parent = scroll
local sPad = Instance.new("UIPadding")
sPad.PaddingLeft = UDim.new(0,7)
sPad.PaddingRight = UDim.new(0,7)
sPad.PaddingTop = UDim.new(0,7)
sPad.PaddingBottom = UDim.new(0,10)
sPad.Parent = scroll

-- UI Components
local _order = 0
local function ord() _order = _order + 1 return _order end
local function mkSec(title)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1,0,0,18)
    f.BackgroundTransparency = 1
    f.BorderSizePixel = 0
    f.LayoutOrder = ord()
    f.ZIndex = 12
    f.Parent = scroll
    local l = Instance.new("TextLabel")
    l.Size = UDim2.fromScale(1,1)
    l.BackgroundTransparency = 1
    l.Text = title:upper()
    l.Font = Enum.Font.GothamBold
    l.TextSize = 7
    l.TextColor3 = T.purple
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.ZIndex = 13
    l.Parent = f
    local ln = Instance.new("Frame")
    ln.Size = UDim2.new(1,0,0,1)
    ln.Position = UDim2.new(0,0,1,-1)
    ln.BackgroundColor3 = T.sep
    ln.BorderSizePixel = 0
    ln.ZIndex = 13
    ln.Parent = f
    return f
end
local function mkBtn(title, sub, cb)
    local h = sub and 40 or 30
    local b = Instance.new("ImageButton")
    b.Size = UDim2.new(1,0,0,h)
    b.BackgroundColor3 = T.card
    b.BorderSizePixel = 0
    b.Image = ""
    b.AutoButtonColor = false
    b.LayoutOrder = ord()
    b.ZIndex = 12
    b.Parent = scroll
    Instance.new("UICorner",b).CornerRadius = UDim.new(0,6)
    local bS = Instance.new("UIStroke",b)
    bS.Color = T.border; bS.Thickness = 0.8
    local tl = Instance.new("TextLabel")
    tl.Size = UDim2.new(1,-10,0,14)
    tl.Position = UDim2.fromOffset(8, sub and 5 or 8)
    tl.BackgroundTransparency = 1
    tl.Text = title
    tl.Font = Enum.Font.GothamBold
    tl.TextSize = 10
    tl.TextColor3 = T.pri
    tl.TextXAlignment = Enum.TextXAlignment.Left
    tl.ZIndex = 13
    tl.Parent = b
    if sub then
        local sl = Instance.new("TextLabel")
        sl.Size = UDim2.new(1,-10,0,11)
        sl.Position = UDim2.fromOffset(8,20)
        sl.BackgroundTransparency = 1
        sl.Text = sub
        sl.Font = Enum.Font.Gotham
        sl.TextSize = 7
        sl.TextColor3 = T.sec
        sl.TextXAlignment = Enum.TextXAlignment.Left
        sl.ZIndex = 13
        sl.Parent = b
    end
    b.MouseButton1Click:Connect(function()
        TweenService:Create(b,TweenInfo.new(0.08),{BackgroundColor3=T.cardH}):Play()
        task.delay(0.15,function() TweenService:Create(b,TweenInfo.new(0.10),{BackgroundColor3=T.card}):Play() end)
        if cb then cb() end
    end)
    b.MouseEnter:Connect(function() TweenService:Create(b,TweenInfo.new(0.10),{BackgroundColor3=T.cardH}):Play() end)
    b.MouseLeave:Connect(function() TweenService:Create(b,TweenInfo.new(0.10),{BackgroundColor3=T.card}):Play() end)
    return b, tl
end
local function mkToggleBtn(title, sub, onCb, offCb)
    local h = sub and 40 or 30
    local b = Instance.new("ImageButton")
    b.Size = UDim2.new(1,0,0,h)
    b.BackgroundColor3 = T.card
    b.BorderSizePixel = 0
    b.Image = ""
    b.AutoButtonColor = false
    b.LayoutOrder = ord()
    b.ZIndex = 12
    b.Parent = scroll
    Instance.new("UICorner",b).CornerRadius = UDim.new(0,6)
    local bS = Instance.new("UIStroke",b)
    bS.Color = T.border; bS.Thickness = 0.8
    local tl = Instance.new("TextLabel")
    tl.Name = "TL"
    tl.Size = UDim2.new(1,-36,0,14)
    tl.Position = UDim2.fromOffset(8, sub and 5 or 8)
    tl.BackgroundTransparency = 1
    tl.Text = title
    tl.Font = Enum.Font.GothamBold
    tl.TextSize = 10
    tl.TextColor3 = T.pri
    tl.TextXAlignment = Enum.TextXAlignment.Left
    tl.ZIndex = 13
    tl.Parent = b
    if sub then
        local sl = Instance.new("TextLabel")
        sl.Size = UDim2.new(1,-36,0,11)
        sl.Position = UDim2.fromOffset(8,20)
        sl.BackgroundTransparency = 1
        sl.Text = sub
        sl.Font = Enum.Font.Gotham
        sl.TextSize = 7
        sl.TextColor3 = T.sec
        sl.TextXAlignment = Enum.TextXAlignment.Left
        sl.ZIndex = 13
        sl.Parent = b
    end
    local TW, TH2 = 24, 13
    local trk = Instance.new("Frame")
    trk.Size = UDim2.fromOffset(TW, TH2)
    trk.Position = UDim2.new(1,-(TW+6),0.5,-(TH2/2))
    trk.BackgroundColor3 = T.border
    trk.BorderSizePixel = 0
    trk.ZIndex = 13
    trk.Parent = b
    Instance.new("UICorner",trk).CornerRadius = UDim.new(1,0)
    local KS = TH2 - 4
    local knob = Instance.new("Frame")
    knob.Size = UDim2.fromOffset(KS, KS)
    knob.Position = UDim2.fromOffset(2,2)
    knob.BackgroundColor3 = T.white
    knob.BorderSizePixel = 0
    knob.ZIndex = 14
    knob.Parent = trk
    Instance.new("UICorner",knob).CornerRadius = UDim.new(1,0)
    local state = false
    b.MouseButton1Click:Connect(function()
        state = not state
        local onColor = T.purple
        TweenService:Create(trk,TweenInfo.new(0.12),{BackgroundColor3 = state and onColor or T.border}):Play()
        TweenService:Create(knob,TweenInfo.new(0.12),{Position = state and UDim2.fromOffset(TW-KS-2,2) or UDim2.fromOffset(2,2)}):Play()
        TweenService:Create(b,TweenInfo.new(0.08),{BackgroundColor3=T.cardH}):Play()
        task.delay(0.15,function() TweenService:Create(b,TweenInfo.new(0.10),{BackgroundColor3=T.card}):Play() end)
        if state then if onCb then onCb() end else if offCb then offCb() end end
    end)
    b.MouseEnter:Connect(function() TweenService:Create(b,TweenInfo.new(0.10),{BackgroundColor3=T.cardH}):Play() end)
    b.MouseLeave:Connect(function() TweenService:Create(b,TweenInfo.new(0.10),{BackgroundColor3=T.card}):Play() end)
    return b
end

-- Notifications
local notifQueue = {}
local notifActive = false
local function showNotif(title, body, dur)
    table.insert(notifQueue, {title=title, body=body, dur=dur or 3})
    if notifActive then return end
    notifActive = true
    task.spawn(function()
        while #notifQueue > 0 do
            local n = table.remove(notifQueue, 1)
            local nf = Instance.new("Frame")
            nf.Size = UDim2.fromOffset(220, 54)
            nf.Position = UDim2.new(1, 10, 1, -70)
            nf.BackgroundColor3 = T.bg
            nf.BorderSizePixel = 0
            nf.ZIndex = 800
            nf.Parent = gui
            Instance.new("UICorner", nf).CornerRadius = UDim.new(0, 7)
            local nfS = Instance.new("UIStroke", nf)
            nfS.Color = T.purple; nfS.Thickness = 1.2
            local nt = Instance.new("TextLabel", nf)
            nt.Size = UDim2.new(1,-12,0,18)
            nt.Position = UDim2.fromOffset(8, 5)
            nt.BackgroundTransparency = 1
            nt.Text = n.title
            nt.Font = Enum.Font.GothamBold
            nt.TextSize = 10
            nt.TextColor3 = T.white
            nt.TextXAlignment = Enum.TextXAlignment.Left
            nt.ZIndex = 801
            local nb = Instance.new("TextLabel", nf)
            nb.Size = UDim2.new(1,-12,0,22)
            nb.Position = UDim2.fromOffset(8, 24)
            nb.BackgroundTransparency = 1
            nb.Text = n.body
            nb.Font = Enum.Font.Gotham
            nb.TextSize = 8
            nb.TextColor3 = T.sec
            nb.TextXAlignment = Enum.TextXAlignment.Left
            nb.ZIndex = 801
            TweenService:Create(nf, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Position = UDim2.new(1,-228,1,-70)}):Play()
            task.wait(n.dur)
            TweenService:Create(nf, TweenInfo.new(0.18, Enum.EasingStyle.Quad), {Position = UDim2.new(1,10,1,-70)}):Play()
            task.wait(0.2)
            nf:Destroy()
        end
        notifActive = false
    end)
end

task.delay(0.5, function()
    showNotif("Indo Voice", "Script loaded!", 4)
end)

-- ==================== FISHING LOGIC ====================
local function getRod()
    if char then
        for _, v in ipairs(char:GetChildren()) do
            if v:IsA("Tool") and string.find(v.Name:lower(), "rod") then return v end
        end
    end
    local bp = LP:FindFirstChild("Backpack")
    if bp then
        for _, v in ipairs(bp:GetChildren()) do
            if v:IsA("Tool") and string.find(v.Name:lower(), "rod") then return v end
        end
    end
    return nil
end

local function equipRod()
    local rod = getRod()
    if not rod then
        local bp = LP:FindFirstChild("Backpack")
        if bp then
            for _, v in ipairs(bp:GetChildren()) do
                if v:IsA("Tool") and string.find(v.Name:lower(), "rod") then
                    pcall(function() hum:EquipTool(v) end)
                    return
                end
            end
        end
    end
end

local function sellAllFish()
    if sellAllRemote then
        local s, e = pcall(function()
            sellAllRemote:InvokeServer()
        end)
        if s then
            showNotif("Sell", "All fish sold!", 3)
        else
            warn("Sell failed:", e)
        end
    else
        showNotif("Error", "Sell remote not found", 3)
    end
end

local function resetAnimDetection()
    if animConn then animConn:Disconnect() end
    castAnimPlayed = false
    pullAnimPlayed = false
    if hum then
        animConn = hum.AnimationPlayed:Connect(function(track)
            if track.Animation.AnimationId == CAST_ANIM_ID then
                castAnimPlayed = true
                animConn:Disconnect()
            elseif track.Animation.AnimationId == PULL_ANIM_ID then
                pullAnimPlayed = true
                animConn:Disconnect()
            end
        end)
    end
end

local function stopFishing()
    autoFishing = false
    if animConn then animConn:Disconnect() end
    stage = "Idle"
    timer = 0
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
end

local function startFishingLoop()
    fishingThread = task.spawn(function()
        while autoFishing do
            local rod = getRod()
            if not rod then
                task.wait(1)
                continue
            end
            -- Idle
            if stage == "Idle" then
                if hum.MoveDirection.Magnitude < 0.1 then
                    task.wait(timeouts.PRE_CAST_DELAY)
                    if not autoFishing then break end
                    stage = "Casting"
                    timer = 0
                    resetAnimDetection()
                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                    task.wait(0.05)
                else
                    task.wait(0.1)
                end
            -- Casting
            elseif stage == "Casting" then
                if timer < timeouts.CAST_HOLD_DURATION then
                    timer = timer + 0.05
                    task.wait(0.05)
                else
                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                    stage = "Verify Cast"
                    timer = 0
                end
            -- Verify Cast
            elseif stage == "Verify Cast" then
                if castAnimPlayed then
                    stage = "Waiting Pull"
                    timer = 0
                else
                    timer = timer + 0.05
                    if timer > timeouts.VERIFY_CAST_TIMEOUT then
                        totalTimeouts = totalTimeouts + 1
                        stage = "Idle"
                        equipRod()
                    end
                    task.wait(0.05)
                end
            -- Waiting Pull
            elseif stage == "Waiting Pull" then
                if pullAnimPlayed then
                    stage = "Post Pull Wait"
                    timer = 0
                else
                    timer = timer + 0.05
                    if timeouts.WAITING_PULL_TIMEOUT > 0 and timer > timeouts.WAITING_PULL_TIMEOUT then
                        totalTimeouts = totalTimeouts + 1
                        stage = "Idle"
                        equipRod()
                    end
                    task.wait(0.05)
                end
            -- Post Pull Wait
            elseif stage == "Post Pull Wait" then
                if timer < timeouts.POST_PULL_DELAY then
                    timer = timer + 0.05
                    if timer > timeouts.POST_PULL_TIMEOUT then
                        totalTimeouts = totalTimeouts + 1
                        stage = "Idle"
                        equipRod()
                    end
                    task.wait(0.05)
                else
                    stage = "Catch"
                    timer = 0
                end
            -- Catch
            elseif stage == "Catch" then
                local tool = getRod()
                local catchRemote = tool and tool:FindFirstChild("Catch")
                if catchRemote then
                    pcall(function() catchRemote:FireServer(true) end)
                    fishCaught = fishCaught + 1
                else
                    totalTimeouts = totalTimeouts + 1
                end
                stage = "Pre End Wait"
                timer = 0
            -- Pre End Wait
            elseif stage == "Pre End Wait" then
                if timer < timeouts.PRE_END_DELAY then
                    timer = timer + 0.05
                    task.wait(0.05)
                else
                    stage = "End"
                    timer = 0
                end
            -- End
            elseif stage == "End" then
                pcall(function()
                    for _, sg in ipairs(LP.PlayerGui:GetChildren()) do
                        if sg:IsA("ScreenGui") and sg:FindFirstChild("FishingHolder", true) then
                            sg:Destroy()
                        end
                    end
                end)
                stage = "Post End Wait"
                timer = 0
            -- Post End Wait
            elseif stage == "Post End Wait" then
                if timer < timeouts.POST_END_DELAY then
                    timer = timer + 0.05
                    task.wait(0.05)
                else
                    stage = "Idle"
                    timer = 0
                end
            end
        end
        stopFishing()
    end)
end

-- ==================== UI CONTENT ====================
mkSec("Fishing")

mkToggleBtn("Auto Fishing", "Start bot fishing", function()
    autoFishing = true
    stage = "Idle"
    timer = 0
    equipRod()
    startFishingLoop()
    showNotif("Auto Fish ON", "Fishing started.", 3)
end, function()
    stopFishing()
    showNotif("Auto Fish OFF", "Fishing stopped.", 2)
end)

mkBtn("Sell All Fish", "Sell all caught fish", function()
    sellAllFish()
end)

-- Status label
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1,0,0,16)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Stage: Idle | Caught: 0"
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 9
statusLabel.TextColor3 = T.sec
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.ZIndex = 13
statusLabel.LayoutOrder = ord()
statusLabel.Parent = scroll

task.spawn(function()
    while win.Parent do
        task.wait(0.5)
        pcall(function()
            statusLabel.Text = string.format("Stage: %s | Caught: %d | Timeouts: %d", stage, fishCaught, totalTimeouts)
        end)
    end
end)

-- Character respawn handler
LP.CharacterAdded:Connect(function()
    if autoFishing then
        stopFishing()
        task.wait(1)
        autoFishing = true
        startFishingLoop()
    end
end)
