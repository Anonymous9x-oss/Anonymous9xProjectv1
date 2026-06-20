--[[
╔══════════════════════════════════════════════════════════════════╗
║   Anonymous9x Animated Pack  —  v1.0                            ║
║   Full Animation Library  |  Idle / Walk / Run / Jump / Fall /  ║
║   Swim / SwimIdle / Climb / Emotes / Donate                     ║
║   By Anonymous9x                                                 ║
╠══════════════════════════════════════════════════════════════════╣
║   Core animation-swap logic preserved from source (freeze →     ║
║   edit Animate script AnimationId → refresh humanoid state →    ║
║   unfreeze). UI fully rebuilt: black/white, WindUI-style wide    ║
║   layout, search, categories, smooth notifications, no emoji.   ║
╚══════════════════════════════════════════════════════════════════╝
]]

pcall(function()

-- ═══════════════════════════════════════════════
-- R15 CHECK
-- ═══════════════════════════════════════════════
local LocalPlayerCheck = game.Players.LocalPlayer
if not LocalPlayerCheck.Character
or LocalPlayerCheck.Character:WaitForChild("Humanoid").RigType ~= Enum.HumanoidRigType.R15 then
    pcall(function()
        game.StarterGui:SetCore("SendNotification", {
            Title    = "R6 Detected",
            Text     = "This pack requires R15. Please switch your avatar rig.",
            Duration = 8,
        })
    end)
    return
end

-- ═══════════════════════════════════════════════
-- SERVICES
-- ═══════════════════════════════════════════════
local Players       = game:GetService("Players")
local TweenService  = game:GetService("TweenService")
local RunService     = game:GetService("RunService")
local UIS            = game:GetService("UserInputService")
local HttpService    = game:GetService("HttpService")
local MarketplaceSvc = game:GetService("MarketplaceService")

local LP   = Players.LocalPlayer
local Char = LP.Character or LP.CharacterAdded:Wait()

cloneref = cloneref or function(o) return o end
local CoreGuiRef = cloneref(game:GetService("CoreGui"))

-- ═══════════════════════════════════════════════
-- CLEANUP OLD INSTANCE
-- ═══════════════════════════════════════════════
pcall(function() CoreGuiRef:FindFirstChild("_A9xAnimPack"):Destroy() end)
pcall(function() LP.PlayerGui:FindFirstChild("_A9xAnimPack"):Destroy() end)

-- ═══════════════════════════════════════════════
-- ROOT GUI
-- ═══════════════════════════════════════════════
local gui = Instance.new("ScreenGui")
gui.Name             = "_A9xAnimPack"
gui.ResetOnSpawn     = false
gui.ZIndexBehavior   = Enum.ZIndexBehavior.Sibling
gui.IgnoreGuiInset   = true
pcall(function() gui.Parent = CoreGuiRef end)
if not gui.Parent then gui.Parent = LP.PlayerGui end

-- ═══════════════════════════════════════════════
-- THEME
-- ═══════════════════════════════════════════════
local C = {
    bg      = Color3.fromRGB(8,   8,   9),
    hdr     = Color3.fromRGB(5,   5,   6),
    card    = Color3.fromRGB(16,  16,  18),
    cardH   = Color3.fromRGB(24,  24,  27),
    sep     = Color3.fromRGB(28,  28,  31),
    border  = Color3.fromRGB(45,  45,  50),
    white   = Color3.new(1, 1, 1),
    pri     = Color3.fromRGB(222, 222, 226),
    sec     = Color3.fromRGB(120, 120, 128),
    dim     = Color3.fromRGB(64,  64,  70),
    accentBg= Color3.fromRGB(235, 235, 238),
}

local LOGO_ID = "rbxassetid://97269958324726"

-- ═══════════════════════════════════════════════
-- WINDOW DIMENSIONS  — wide, short, mobile friendly
-- ═══════════════════════════════════════════════
local W   = 340
local H   = 400
local HDR = 34
local SRCH= 30
local TAB = 28

-- ═══════════════════════════════════════════════
-- SMOOTH NOTIFICATION SYSTEM
-- ═══════════════════════════════════════════════
local notifStack = {}

local function showNotif(title, body, dur)
    local f = Instance.new("Frame")
    f.Size               = UDim2.fromOffset(230, 50)
    f.Position           = UDim2.new(1, 12, 1, -64)
    f.BackgroundColor3   = C.bg
    f.BackgroundTransparency = 0
    f.BorderSizePixel    = 0
    f.ZIndex             = 900
    f.Parent             = gui
    f.ClipsDescendants   = true
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 7)
    local fs = Instance.new("UIStroke", f)
    fs.Color = C.white; fs.Thickness = 1.1; fs.Transparency = 0.25

    local t1 = Instance.new("TextLabel")
    t1.Size               = UDim2.new(1, -12, 0, 18)
    t1.Position           = UDim2.fromOffset(8, 5)
    t1.BackgroundTransparency = 1
    t1.Text               = title
    t1.Font               = Enum.Font.GothamBold
    t1.TextSize            = 10
    t1.TextColor3          = C.white
    t1.TextXAlignment      = Enum.TextXAlignment.Left
    t1.ZIndex              = 901
    t1.Parent              = f

    local t2 = Instance.new("TextLabel")
    t2.Size               = UDim2.new(1, -12, 0, 20)
    t2.Position           = UDim2.fromOffset(8, 22)
    t2.BackgroundTransparency = 1
    t2.Text               = body
    t2.Font               = Enum.Font.Gotham
    t2.TextSize            = 8
    t2.TextColor3          = C.sec
    t2.TextXAlignment      = Enum.TextXAlignment.Left
    t2.TextWrapped         = true
    t2.ZIndex              = 901
    t2.Parent              = f

    -- Calculate stacked Y offset
    local function recalcPositions()
        for i, nf in ipairs(notifStack) do
            local targetY = -64 - ((i-1) * 58)
            TweenService:Create(nf, TweenInfo.new(0.22, Enum.EasingStyle.Quad), {
                Position = UDim2.new(1, -242, 1, targetY)
            }):Play()
        end
    end

    table.insert(notifStack, 1, f)
    recalcPositions()

    -- Slide in
    TweenService:Create(f, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Position = UDim2.new(1, -242, 1, -64)
    }):Play()

    task.delay(dur or 3, function()
        -- Slide out
        TweenService:Create(f, TweenInfo.new(0.20, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Position = UDim2.new(1, 12, 1, f.Position.Y.Offset)
        }):Play()
        task.wait(0.22)
        for i, nf in ipairs(notifStack) do
            if nf == f then table.remove(notifStack, i); break end
        end
        recalcPositions()
        pcall(function() f:Destroy() end)
    end)
end

-- ═══════════════════════════════════════════════
-- MAIN WINDOW  (locked, no drag)
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
win.Draggable          = false   -- locked
win.ZIndex             = 10
win.Parent             = gui
Instance.new("UICorner", win).CornerRadius = UDim.new(0, 9)

local winS = Instance.new("UIStroke", win)
winS.Thickness = 1.3; winS.Color = C.white; winS.Transparency = 0.35

-- Subtle white pulse glow loop (modern, calm — no flashy colors)
task.spawn(function()
    local t = 0
    while win.Parent do
        t = t + task.wait(0.05)
        local s = (math.sin(t * 1.3) + 1) / 2
        winS.Transparency = 0.20 + s * 0.30
    end
end)

-- ═══════════════════════════════════════════════
-- HEADER
-- ═══════════════════════════════════════════════
local hdr = Instance.new("Frame")
hdr.Size             = UDim2.new(1, 0, 0, HDR)
hdr.BackgroundColor3 = C.hdr
hdr.BackgroundTransparency = 0
hdr.BorderSizePixel  = 0
hdr.ZIndex           = 11
hdr.Parent           = win
Instance.new("UICorner", hdr).CornerRadius = UDim.new(0, 9)

local hPatch = Instance.new("Frame")
hPatch.Size = UDim2.new(1,0,0,9); hPatch.Position = UDim2.new(0,0,1,-9)
hPatch.BackgroundColor3 = C.hdr; hPatch.BorderSizePixel = 0
hPatch.ZIndex = 10; hPatch.Parent = hdr

local hSep = Instance.new("Frame")
hSep.Size = UDim2.new(1,0,0,1); hSep.Position = UDim2.new(0,0,1,-1)
hSep.BackgroundColor3 = C.sep; hSep.BorderSizePixel = 0
hSep.ZIndex = 12; hSep.Parent = hdr

local hLogo = Instance.new("ImageLabel")
hLogo.Size               = UDim2.fromOffset(22, 22)
hLogo.Position           = UDim2.fromOffset(8, 6)
hLogo.BackgroundTransparency = 1
hLogo.Image              = LOGO_ID
hLogo.ScaleType          = Enum.ScaleType.Fit
hLogo.ZIndex             = 12
hLogo.Parent             = hdr

local hTitle = Instance.new("TextLabel")
hTitle.Size               = UDim2.new(1, -100, 1, 0)
hTitle.Position           = UDim2.fromOffset(36, 0)
hTitle.BackgroundTransparency = 1
hTitle.Text               = "Anonymous9x Animated Pack"
hTitle.Font               = Enum.Font.GothamBold
hTitle.TextSize            = 11
hTitle.TextColor3          = C.pri
hTitle.TextXAlignment      = Enum.TextXAlignment.Left
hTitle.TextTruncate        = Enum.TextTruncate.AtEnd
hTitle.ZIndex              = 12
hTitle.Parent              = hdr

local function makeCtrl(xOff, sym)
    local b = Instance.new("ImageButton")
    b.Size               = UDim2.fromOffset(22, 19)
    b.Position           = UDim2.new(1, xOff, 0.5, -9)
    b.BackgroundColor3   = C.card
    b.BackgroundTransparency = 0
    b.BorderSizePixel    = 0
    b.Image              = ""
    b.AutoButtonColor    = false
    b.ZIndex             = 13
    b.Parent             = hdr
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
    local l = Instance.new("TextLabel")
    l.Size               = UDim2.fromScale(1, 1)
    l.BackgroundTransparency = 1
    l.Text               = sym
    l.Font               = Enum.Font.GothamBold
    l.TextSize            = 12
    l.TextColor3          = C.sec
    l.ZIndex              = 14
    l.Parent              = b
    b.MouseEnter:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.10), {BackgroundColor3=C.cardH}):Play()
        l.TextColor3 = C.white
    end)
    b.MouseLeave:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.10), {BackgroundColor3=C.card}):Play()
        l.TextColor3 = C.sec
    end)
    return b, l
end

local minBtn, minL   = makeCtrl(-50, "-")
local closeBtn, _    = makeCtrl(-26, "x")

-- ═══════════════════════════════════════════════
-- FLOAT ICON (minimized state)
-- ═══════════════════════════════════════════════
local floatF = Instance.new("Frame")
floatF.Name             = "FloatIcon"
floatF.Size             = UDim2.fromOffset(48, 48)
floatF.BackgroundColor3 = C.hdr
floatF.BackgroundTransparency = 0
floatF.BorderSizePixel  = 0
floatF.Visible          = false
floatF.ZIndex           = 500
floatF.Parent           = gui
Instance.new("UICorner", floatF).CornerRadius = UDim.new(0, 11)
local fiS = Instance.new("UIStroke", floatF)
fiS.Color = C.white; fiS.Thickness = 1.2; fiS.Transparency = 0.3

task.spawn(function()
    local t = 0
    while gui.Parent do
        t = t + task.wait(0.05)
        local s = (math.sin(t * 1.6) + 1) / 2
        fiS.Transparency = 0.15 + s * 0.35
    end
end)

local fiImg = Instance.new("ImageLabel")
fiImg.Size               = UDim2.fromOffset(40, 40)
fiImg.Position           = UDim2.fromOffset(4, 4)
fiImg.BackgroundTransparency = 1
fiImg.Image              = LOGO_ID
fiImg.ScaleType          = Enum.ScaleType.Fit
fiImg.ZIndex             = 501
fiImg.Parent             = floatF

local function anchorFloat()
    local vp = workspace.CurrentCamera.ViewportSize
    if vp.X < 10 then vp = Vector2.new(800, 600) end
    -- bottom-right area, slightly toward center
    floatF.Position = UDim2.fromOffset(vp.X - 70, vp.Y - 170)
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
    pcall(function() gui:Destroy() end)
end)

-- ═══════════════════════════════════════════════
-- SEARCH BAR
-- ═══════════════════════════════════════════════
local searchF = Instance.new("Frame")
searchF.Size             = UDim2.new(1, -12, 0, 24)
searchF.Position         = UDim2.fromOffset(6, HDR + 5)
searchF.BackgroundColor3 = C.card
searchF.BackgroundTransparency = 0
searchF.BorderSizePixel  = 0
searchF.ZIndex           = 11
searchF.Parent           = win
Instance.new("UICorner", searchF).CornerRadius = UDim.new(0, 5)
local sS = Instance.new("UIStroke", searchF); sS.Color=C.border; sS.Thickness=0.8

local searchBox = Instance.new("TextBox")
searchBox.Size               = UDim2.new(1, -30, 1, 0)
searchBox.Position           = UDim2.fromOffset(8, 0)
searchBox.BackgroundTransparency = 1
searchBox.PlaceholderText    = "Search animations..."
searchBox.PlaceholderColor3  = C.dim
searchBox.Text               = ""
searchBox.Font               = Enum.Font.Gotham
searchBox.TextSize            = 9
searchBox.TextColor3          = C.pri
searchBox.ClearTextOnFocus   = false
searchBox.ZIndex              = 12
searchBox.Parent              = searchF

local searchClear = Instance.new("ImageButton")
searchClear.Size               = UDim2.fromOffset(20, 20)
searchClear.Position           = UDim2.new(1, -22, 0.5, -10)
searchClear.BackgroundTransparency = 1
searchClear.Image              = ""
searchClear.AutoButtonColor    = false
searchClear.ZIndex             = 12
searchClear.Parent             = searchF
local scL = Instance.new("TextLabel")
scL.Size=UDim2.fromScale(1,1); scL.BackgroundTransparency=1; scL.Text="x"
scL.Font=Enum.Font.GothamBold; scL.TextSize=9; scL.TextColor3=C.dim
scL.ZIndex=13; scL.Parent=searchClear
searchClear.MouseButton1Click:Connect(function() searchBox.Text = "" end)

-- ═══════════════════════════════════════════════
-- CATEGORY TAB BAR  (horizontal scroll)
-- ═══════════════════════════════════════════════
local tabScroll = Instance.new("ScrollingFrame")
tabScroll.Size                 = UDim2.new(1, -12, 0, TAB)
tabScroll.Position             = UDim2.fromOffset(6, HDR + SRCH + 8)
tabScroll.BackgroundTransparency = 1
tabScroll.BorderSizePixel      = 0
tabScroll.ScrollBarThickness   = 0
tabScroll.ScrollingDirection   = Enum.ScrollingDirection.X
tabScroll.CanvasSize           = UDim2.fromOffset(0, 0)
tabScroll.AutomaticCanvasSize  = Enum.AutomaticSize.X
tabScroll.ZIndex               = 11
tabScroll.Parent               = win

local tabLL = Instance.new("UIListLayout")
tabLL.FillDirection      = Enum.FillDirection.Horizontal
tabLL.VerticalAlignment  = Enum.VerticalAlignment.Center
tabLL.Padding            = UDim.new(0, 4)
tabLL.SortOrder          = Enum.SortOrder.LayoutOrder
tabLL.Parent             = tabScroll

local CATS = {"All","Idle","Walk","Run","Jump","Fall","Swim","SwimIdle","Climb","Emotes","Donate","Info"}
local activeCat = "All"
local tabBtns = {}

local function setCat(cat)
    activeCat = cat
    for _, def in ipairs(CATS) do
        local b = tabBtns[def]
        if b then
            local on = def == cat
            TweenService:Create(b, TweenInfo.new(0.12), {
                BackgroundColor3 = on and C.accentBg or C.card
            }):Play()
            local l = b:FindFirstChildOfClass("TextLabel")
            if l then l.TextColor3 = on and Color3.new(0,0,0) or C.sec end
        end
    end
end

for i, cat in ipairs(CATS) do
    local b = Instance.new("ImageButton")
    b.Size               = UDim2.fromOffset(#cat * 6 + 22, TAB - 2)
    b.BackgroundColor3   = cat=="All" and C.accentBg or C.card
    b.BackgroundTransparency = 0
    b.BorderSizePixel    = 0
    b.Image              = ""
    b.AutoButtonColor    = false
    b.LayoutOrder        = i
    b.ZIndex             = 12
    b.Parent             = tabScroll
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 12)
    local l = Instance.new("TextLabel")
    l.Size               = UDim2.fromScale(1,1)
    l.BackgroundTransparency = 1
    l.Text               = cat
    l.Font               = Enum.Font.GothamSemibold
    l.TextSize            = 8
    l.TextColor3          = cat=="All" and Color3.new(0,0,0) or C.sec
    l.ZIndex              = 13
    l.Parent              = b
    b.MouseButton1Click:Connect(function() setCat(cat) end)
    tabBtns[cat] = b
end

-- ═══════════════════════════════════════════════
-- CONTENT SCROLL LIST
-- ═══════════════════════════════════════════════
local BODY_Y = HDR + SRCH + TAB + 14

local scroll = Instance.new("ScrollingFrame")
scroll.Size                 = UDim2.new(1, 0, 1, -BODY_Y)
scroll.Position             = UDim2.fromOffset(0, BODY_Y)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel      = 0
scroll.ScrollBarThickness   = 3
scroll.ScrollBarImageColor3 = C.border
scroll.ScrollingDirection   = Enum.ScrollingDirection.Y
scroll.CanvasSize           = UDim2.fromOffset(0, 0)
scroll.AutomaticCanvasSize  = Enum.AutomaticSize.Y
scroll.ZIndex               = 11
scroll.Parent               = win

local listLL = Instance.new("UIListLayout")
listLL.SortOrder = Enum.SortOrder.LayoutOrder
listLL.Padding   = UDim.new(0, 3)
listLL.Parent    = scroll

local listPad = Instance.new("UIPadding")
listPad.PaddingLeft   = UDim.new(0, 6)
listPad.PaddingRight  = UDim.new(0, 6)
listPad.PaddingTop    = UDim.new(0, 4)
listPad.PaddingBottom = UDim.new(0, 10)
listPad.Parent        = scroll

-- ═══════════════════════════════════════════════
-- CORE ANIMATION ENGINE
-- (logic kept from source, structure unchanged)
-- ═══════════════════════════════════════════════
local lastAnimations = {}

local function freeze()
    local character = LP.Character or LP.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")
    humanoid.PlatformStand = true
    task.spawn(function()
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") and not part.Anchored then
                part.Anchored = true
            end
        end
    end)
end

local function unfreeze()
    local character = LP.Character or LP.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")
    humanoid.PlatformStand = false
    task.spawn(function()
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") and part.Anchored then
                part.Anchored = false
            end
        end
    end)
end

local function StopAnim()
    local character = LP.Character or LP.CharacterAdded:Wait()
    local hum = character:FindFirstChildOfClass("Humanoid")
              or character:FindFirstChildOfClass("AnimationController")
    if hum then
        for _, track in ipairs(hum:GetPlayingAnimationTracks()) do
            track:Stop(0)
        end
    end
end

local function refresh()
    local character = LP.Character or LP.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")
    humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
end

local function refreshswim()
    local character = LP.Character or LP.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")
    humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
    task.wait(0.1)
    humanoid:ChangeState(Enum.HumanoidStateType.Swimming)
end

local function refreshclimb()
    local character = LP.Character or LP.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")
    humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
    task.wait(0.1)
    humanoid:ChangeState(Enum.HumanoidStateType.Climbing)
end

local function ResetTrackFor(animateScript)
    local character = LP.Character or LP.CharacterAdded:Wait()
    local hum = character:FindFirstChildOfClass("Humanoid")
              or character:FindFirstChildOfClass("AnimationController")
    if hum then
        for _, v in ipairs(hum:GetPlayingAnimationTracks()) do
            v:Stop(0)
        end
    end
end

local function ResetIdle()
    ResetTrackFor()
    local character = LP.Character
    pcall(function()
        local Animate = character.Animate
        Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=0"
        Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=0"
    end)
end
local function ResetWalk()
    ResetTrackFor()
    local character = LP.Character
    pcall(function() character.Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=0" end)
end
local function ResetRun()
    ResetTrackFor()
    local character = LP.Character
    pcall(function() character.Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=0" end)
end
local function ResetJump()
    ResetTrackFor()
    local character = LP.Character
    pcall(function() character.Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=0" end)
end
local function ResetFall()
    ResetTrackFor()
    local character = LP.Character
    pcall(function() character.Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=0" end)
end
local function ResetSwim()
    ResetTrackFor()
    local character = LP.Character
    pcall(function()
        if character.Animate.swim then
            character.Animate.swim.Swim.AnimationId = "http://www.roblox.com/asset/?id=0"
        end
    end)
end
local function ResetSwimIdle()
    ResetTrackFor()
    local character = LP.Character
    pcall(function()
        if character.Animate.swimidle then
            character.Animate.swimidle.SwimIdle.AnimationId = "http://www.roblox.com/asset/?id=0"
        end
    end)
end
local function ResetClimb()
    ResetTrackFor()
    local character = LP.Character
    pcall(function() character.Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=0" end)
end

local function saveLastAnimations()
    pcall(function()
        if writefile then
            local data = HttpService:JSONEncode(lastAnimations)
            writefile("Anonymous9xAnimPack.json", data)
        end
    end)
end

local function setAnimation(animationType, animationId)
    local character = LP.Character
    local Animate = character and character:FindFirstChild("Animate")
    if not Animate then return end

    freeze()
    task.wait(0.1)

    if animationType == "Idle" then
        lastAnimations.Idle = animationId
        ResetIdle()
        Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=" .. animationId[1]
        Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=" .. animationId[2]
        refresh()
    elseif animationType == "Walk" then
        lastAnimations.Walk = animationId
        ResetWalk()
        Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=" .. animationId
        refresh()
    elseif animationType == "Run" then
        lastAnimations.Run = animationId
        ResetRun()
        Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=" .. animationId
        refresh()
    elseif animationType == "Jump" then
        lastAnimations.Jump = animationId
        ResetJump()
        Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=" .. animationId
        refresh()
    elseif animationType == "Fall" then
        lastAnimations.Fall = animationId
        ResetFall()
        Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=" .. animationId
        refresh()
    elseif animationType == "Swim" then
        lastAnimations.Swim = animationId
        if Animate.swim then
            ResetSwim()
            Animate.swim.Swim.AnimationId = "http://www.roblox.com/asset/?id=" .. animationId
            refreshswim()
        end
    elseif animationType == "SwimIdle" then
        lastAnimations.SwimIdle = animationId
        if Animate.swimidle then
            ResetSwimIdle()
            Animate.swimidle.SwimIdle.AnimationId = "http://www.roblox.com/asset/?id=" .. animationId
            refreshswim()
        end
    elseif animationType == "Climb" then
        lastAnimations.Climb = animationId
        ResetClimb()
        Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=" .. animationId
        refreshclimb()
    end

    saveLastAnimations()
    task.wait(0.1)
    unfreeze()
end

local function PlayEmote(animationId)
    StopAnim()
    local character = LP.Character or LP.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")
    local anim = Instance.new("Animation")
    anim.AnimationId = "rbxassetid://" .. animationId
    local track = humanoid:LoadAnimation(anim)
    track:Play()
    local conn
    conn = RunService.RenderStepped:Connect(function()
        if humanoid.MoveDirection.Magnitude > 0 then
            track:Stop()
            if conn then conn:Disconnect() end
        end
    end)
end

local function Buy(gamePassID)
    local ok = pcall(function()
        MarketplaceSvc:PromptGamePassPurchase(LP, gamePassID)
    end)
    if not ok then
        pcall(function() setclipboard("https://www.roblox.com/game-pass/" .. gamePassID) end)
        showNotif("Link Copied", "Gamepass purchase link copied to clipboard.", 3)
    end
end

-- ═══════════════════════════════════════════════
-- ANIMATION DATA  (full table retained from source)
-- ═══════════════════════════════════════════════
local Animations = {
    ["Idle"] = {
        ["2016 Animation (mm2)"] = {"387947158", "387947464"},
        ["(UGC) Oh Really?"] = {"98004748982532", "98004748982532"},
        ["Astronaut"] = {"891621366", "891633237"},
        ["Adidas Community"] = {"122257458498464", "102357151005774"},
        ["Bold"] = {"16738333868", "16738334710"},
        ["(UGC) Slasher"] = {"140051337061095", "140051337061095"},
        ["(UGC) Retro"] = {"80479383912838", "80479383912838"},
        ["(UGC) Magician"] = {"139433213852503", "139433213852503"},
        ["(UGC) John Doe"] = {"72526127498800", "72526127498800"},
        ["(UGC) Noli"] = {"139360856809483", "139360856809483"},
        ["(UGC) Coolkid"] = {"95203125292023", "95203125292023"},
        ["(UGC) Survivor Injured"] = {"73905365652295", "73905365652295"},
        ["(UGC) Retro Zombie"] = {"90806086002292", "90806086002292"},
        ["(UGC) 1x1x1x1"] = {"76780522821306", "76780522821306"},
        ["Borock"] = {"3293641938", "3293642554"},
        ["Bubbly"] = {"910004836", "910009958"},
        ["Cartoony"] = {"742637544", "742638445"},
        ["Confident"] = {"1069977950", "1069987858"},
        ["Catwalk Glam"] = {"133806214992291","94970088341563"},
        ["Cowboy"] = {"1014390418", "1014398616"},
        ["Drooling Zombie"] = {"3489171152", "3489171152"},
        ["Elder"] = {"10921101664", "10921102574"},
        ["Ghost"] = {"616006778","616008087"},
        ["Knight"] = {"657595757", "657568135"},
        ["Levitation"] = {"616006778", "616008087"},
        ["Mage"] = {"707742142", "707855907"},
        ["MrToilet"] = {"4417977954", "4417978624"},
        ["Ninja"] = {"656117400", "656118341"},
        ["NFL"] = {"92080889861410", "74451233229259"},
        ["OldSchool"] = {"10921230744", "10921232093"},
        ["Patrol"] = {"1149612882", "1150842221"},
        ["Pirate"] = {"750781874", "750782770"},
        ["Default Retarget"] = {"95884606664820", "95884606664820"},
        ["Very Long"] = {"18307781743", "18307781743"},
        ["Sway"] = {"560832030", "560833564"},
        ["Popstar"] = {"1212900985", "1150842221"},
        ["Princess"] = {"941003647", "941013098"},
        ["R6"] = {"12521158637","12521162526"},
        ["R15 Reanimated"] = {"4211217646", "4211218409"},
        ["Realistic"] = {"17172918855", "17173014241"},
        ["Robot"] = {"616088211", "616089559"},
        ["Sneaky"] = {"1132473842", "1132477671"},
        ["Sports (Adidas)"] = {"18537376492", "18537371272"},
        ["Soldier"] = {"3972151362", "3972151362"},
        ["Stylish"] = {"616136790", "616138447"},
        ["Stylized Female"] = {"4708191566", "4708192150"},
        ["Superhero"] = {"10921288909", "10921290167"},
        ["Toy"] = {"782841498", "782845736"},
        ["Udzal"] = {"3303162274", "3303162549"},
        ["Vampire"] = {"1083445855", "1083450166"},
        ["Werewolf"] = {"1083195517", "1083214717"},
        ["Wicked (Popular)"] = {"118832222982049", "76049494037641"},
        ["No Boundaries (Walmart)"] = {"18747067405", "18747063918"},
        ["Zombie"] = {"616158929", "616160636"},
        ["(UGC) Zombie"] = {"77672872857991", "77672872857991"},
        ["(UGC) TailWag"] = {"129026910898635", "129026910898635"},
    },
    ["Walk"] = {
        ["Gojo"] = "95643163365384",
        ["Geto"] = "85811471336028",
        ["Astronaut"] = "891667138",
        ["(UGC) Zombie"] = "113603435314095",
        ["Adidas Community"] = "122150855457006",
        ["Bold"] = "16738340646",
        ["Bubbly"] = "910034870",
        ["(UGC) Smooth"] = "76630051272791",
        ["Cartoony"] = "742640026",
        ["Confident"] = "1070017263",
        ["Cowboy"] = "1014421541",
        ["(UGC) Retro"] = "107806791584829",
        ["(UGC) Retro Zombie"] = "140703855480494",
        ["Catwalk Glam"] = "109168724482748",
        ["Drooling Zombie"] = "3489174223",
        ["Elder"] = "10921111375",
        ["Ghost"] = "616013216",
        ["Knight"] = "10921127095",
        ["Levitation"] = "616013216",
        ["Mage"] = "707897309",
        ["Ninja"] = "656121766",
        ["NFL"] = "110358958299415",
        ["OldSchool"] = "10921244891",
        ["Patrol"] = "1151231493",
        ["Pirate"] = "750785693",
        ["Default Retarget"] = "115825677624788",
        ["Popstar"] = "1212980338",
        ["Princess"] = "941028902",
        ["R6"] = "12518152696",
        ["R15 Reanimated"] = "4211223236",
        ["2016 Animation (mm2)"] = "387947975",
        ["Robot"] = "616095330",
        ["Sneaky"] = "1132510133",
        ["Sports (Adidas)"] = "18537392113",
        ["Stylish"] = "616146177",
        ["Stylized Female"] = "4708193840",
        ["Superhero"] = "10921298616",
        ["Toy"] = "782843345",
        ["Udzal"] = "3303162967",
        ["Vampire"] = "1083473930",
        ["Werewolf"] = "1083178339",
        ["Wicked (Popular)"] = "92072849924640",
        ["No Boundaries (Walmart)"] = "18747074203",
        ["Zombie"] = "616168032",
    },
    ["Run"] = {
        ["2016 Animation (mm2)"] = "387947975",
        ["(UGC) Soccer"] = "116881956670910",
        ["Adidas Community"] = "82598234841035",
        ["Astronaut"] = "10921039308",
        ["Bold"] = "16738337225",
        ["Bubbly"] = "10921057244",
        ["Cartoony"] = "10921076136",
        ["(UGC) Dog"] = "130072963359721",
        ["Confident"] = "1070001516",
        ["(UGC) Pride"] = "116462200642360",
        ["(UGC) Retro"] = "107806791584829",
        ["(UGC) Retro Zombie"] = "140703855480494",
        ["Cowboy"] = "1014401683",
        ["Catwalk Glam"] = "81024476153754",
        ["Drooling Zombie"] = "3489173414",
        ["Elder"] = "10921104374",
        ["Ghost"] = "616013216",
        ["Heavy Run (Udzal / Borock)"] = "3236836670",
        ["Knight"] = "10921121197",
        ["Levitation"] = "616010382",
        ["Mage"] = "10921148209",
        ["MrToilet"] = "4417979645",
        ["Ninja"] = "656118852",
        ["NFL"] = "117333533048078",
        ["OldSchool"] = "10921240218",
        ["Patrol"] = "1150967949",
        ["Pirate"] = "750783738",
        ["Default Retarget"] = "102294264237491",
        ["Popstar"] = "1212980348",
        ["Princess"] = "941015281",
        ["R6"] = "12518152696",
        ["R15 Reanimated"] = "4211220381",
        ["Robot"] = "10921250460",
        ["Sneaky"] = "1132494274",
        ["Sports (Adidas)"] = "18537384940",
        ["Stylish"] = "10921276116",
        ["Stylized Female"] = "4708192705",
        ["Superhero"] = "10921291831",
        ["Toy"] = "10921306285",
        ["Vampire"] = "10921320299",
        ["Werewolf"] = "10921336997",
        ["Wicked (Popular)"] = "72301599441680",
        ["No Boundaries (Walmart)"] = "18747070484",
        ["Zombie"] = "616163682",
    },
    ["Jump"] = {
        ["Astronaut"] = "891627522",
        ["Adidas Community"] = "75290611992385",
        ["Bold"] = "16738336650",
        ["Bubbly"] = "910016857",
        ["Cartoony"] = "742637942",
        ["Catwalk Glam"] = "116936326516985",
        ["Confident"] = "1069984524",
        ["Cowboy"] = "1014394726",
        ["Elder"] = "10921107367",
        ["Ghost"] = "616008936",
        ["Knight"] = "910016857",
        ["Levitation"] = "616008936",
        ["Mage"] = "10921149743",
        ["Ninja"] = "656117878",
        ["NFL"] = "119846112151352",
        ["OldSchool"] = "10921242013",
        ["Patrol"] = "1148811837",
        ["Pirate"] = "750782230",
        ["(UGC) Retro"] = "139390570947836",
        ["Default Retarget"] = "117150377950987",
        ["Popstar"] = "1212954642",
        ["Princess"] = "941008832",
        ["Robot"] = "616090535",
        ["R15 Reanimated"] = "4211219390",
        ["R6"] = "12520880485",
        ["Sneaky"] = "1132489853",
        ["Sports (Adidas)"] = "18537380791",
        ["Stylish"] = "616139451",
        ["Stylized Female"] = "4708188025",
        ["Superhero"] = "10921294559",
        ["Toy"] = "10921308158",
        ["Vampire"] = "1083455352",
        ["Werewolf"] = "1083218792",
        ["Wicked (Popular)"] = "104325245285198",
        ["No Boundaries (Walmart)"] = "18747069148",
        ["Zombie"] = "616161997",
    },
    ["Fall"] = {
        ["Astronaut"] = "891617961",
        ["Adidas Community"] = "98600215928904",
        ["Bold"] = "16738333171",
        ["Bubbly"] = "910001910",
        ["Cartoony"] = "742637151",
        ["Catwalk Glam"] = "92294537340807",
        ["Confident"] = "1069973677",
        ["Cowboy"] = "1014384571",
        ["Elder"] = "10921105765",
        ["Knight"] = "10921122579",
        ["Levitation"] = "616005863",
        ["Mage"] = "707829716",
        ["Ninja"] = "656115606",
        ["NFL"] = "129773241321032",
        ["OldSchool"] = "10921241244",
        ["Patrol"] = "1148863382",
        ["Pirate"] = "750780242",
        ["Default Retarget"] = "110205622518029",
        ["Popstar"] = "1212900995",
        ["Princess"] = "941000007",
        ["Robot"] = "616087089",
        ["R15 Reanimated"] = "4211216152",
        ["R6"] = "12520972571",
        ["Sneaky"] = "1132469004",
        ["Sports (Adidas)"] = "18537367238",
        ["Stylish"] = "616134815",
        ["Stylized Female"] = "4708186162",
        ["Superhero"] = "10921293373",
        ["Toy"] = "782846423",
        ["Vampire"] = "1083443587",
        ["Werewolf"] = "1083189019",
        ["Wicked (Popular)"] = "121152442762481",
        ["No Boundaries (Walmart)"] = "18747062535",
        ["Zombie"] = "616157476",
    },
    ["SwimIdle"] = {
        ["Astronaut"] = "891663592",
        ["Adidas Community"] = "109346520324160",
        ["Bold"] = "16738339817",
        ["Bubbly"] = "910030921",
        ["Cartoony"] = "10921079380",
        ["Catwalk Glam"] = "98854111361360",
        ["Confident"] = "1070012133",
        ["CowBoy"] = "1014411816",
        ["Elder"] = "10921110146",
        ["Mage"] = "707894699",
        ["Ninja"] = "656118341",
        ["NFL"] = "79090109939093",
        ["Patrol"] = "1151221899",
        ["Knight"] = "10921125935",
        ["OldSchool"] = "10921244018",
        ["Levitation"] = "10921139478",
        ["Popstar"] = "1212998578",
        ["Princess"] = "941025398",
        ["Pirate"] = "750785176",
        ["R6"] = "12518152696",
        ["Robot"] = "10921253767",
        ["Sneaky"] = "1132506407",
        ["Sports (Adidas)"] = "18537387180",
        ["Stylish"] = "10921281964",
        ["Stylized"] = "4708190607",
        ["SuperHero"] = "10921297391",
        ["Toy"] = "10921310341",
        ["Vampire"] = "10921325443",
        ["Werewolf"] = "10921341319",
        ["Wicked (Popular)"] = "113199415118199",
        ["No Boundaries (Walmart)"] = "18747071682",
    },
    ["Swim"] = {
        ["Astronaut"] = "891663592",
        ["Adidas Community"] = "133308483266208",
        ["Bubbly"] = "910028158",
        ["Bold"] = "16738339158",
        ["Cartoony"] = "10921079380",
        ["Catwalk Glam"] = "134591743181628",
        ["CowBoy"] = "1014406523",
        ["Confident"] = "1070009914",
        ["Elder"] = "10921108971",
        ["Knight"] = "10921125160",
        ["Mage"] = "707876443",
        ["NFL"] = "132697394189921",
        ["OldSchool"] = "10921243048",
        ["PopStar"] = "1212998578",
        ["Princess"] = "941018893",
        ["Pirate"] = "750784579",
        ["Patrol"] = "1151204998",
        ["R6"] = "12518152696",
        ["Robot"] = "10921253142",
        ["Levitation"] = "10921138209",
        ["Stylish"] = "10921281000",
        ["SuperHero"] = "10921295495",
        ["Sneaky"] = "1132500520",
        ["Sports (Adidas)"] = "18537389531",
        ["Toy"] = "10921309319",
        ["Vampire"] = "10921324408",
        ["Werewolf"] = "10921340419",
        ["Wicked (Popular)"] = "99384245425157",
        ["No Boundaries (Walmart)"] = "18747073181",
        ["Zombie"] = "616165109",
    },
    ["Climb"] = {
        ["Astronaut"] = "10921032124",
        ["Adidas Community"] = "88763136693023",
        ["Bold"] = "16738332169",
        ["Cartoony"] = "742636889",
        ["Catwalk Glam"] = "119377220967554",
        ["Confident"] = "1069946257",
        ["CowBoy"] = "1014380606",
        ["Elder"] = "845392038",
        ["Ghost"] = "616003713",
        ["Knight"] = "10921125160",
        ["Levitation"] = "10921132092",
        ["Mage"] = "707826056",
        ["Ninja"] = "656114359",
        ["(UGC) Retro"] = "121075390792786",
        ["NFL"] = "134630013742019",
        ["OldSchool"] = "10921229866",
        ["Patrol"] = "1148811837",
        ["Popstar"] = "1213044953",
        ["Princess"] = "940996062",
        ["R6"] = "12520982150",
        ["Reanimated R15"] = "4211214992",
        ["Robot"] = "616086039",
        ["Sneaky"] = "1132461372",
        ["Sports (Adidas)"] = "18537363391",
        ["Stylish"] = "10921271391",
        ["Stylized Female"] = "4708184253",
        ["SuperHero"] = "10921286911",
        ["Toy"] = "10921300839",
        ["Vampire"] = "1083439238",
        ["WereWolf"] = "10921329322",
        ["Wicked (Popular)"] = "131326830509784",
        ["No Boundaries (Walmart)"] = "18747060903",
        ["Zombie"] = "616156119",
    },
}

local Emotes = {
    {"Dance 1", 12521009666},
    {"Dance 2", 12521169800},
    {"Dance 3", 12521178362},
    {"Cheer",   12521021991},
    {"Laugh",   12521018724},
    {"Point",   12521007694},
    {"Wave",    12521004586},
}

local Donations = {
    {20,   1131371530},
    {200,  1131065702},
    {183,  1129915318},
    {2000, 1128299749},
}

-- ═══════════════════════════════════════════════
-- ROW BUTTON FACTORY
-- ═══════════════════════════════════════════════
local allRows = {}   -- {frame=Frame, name=string, cat=string}

local function mkRow(name, cat, onClick)
    local row = Instance.new("ImageButton")
    row.Name               = "Row"
    row.Size                = UDim2.new(1, 0, 0, 30)
    row.BackgroundColor3   = C.card
    row.BackgroundTransparency = 0
    row.BorderSizePixel    = 0
    row.Image              = ""
    row.AutoButtonColor    = false
    row.LayoutOrder        = #allRows + 1
    row.ZIndex             = 12
    row.Parent             = scroll
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 5)

    local nameL = Instance.new("TextLabel")
    nameL.Size               = UDim2.new(1, -64, 1, 0)
    nameL.Position           = UDim2.fromOffset(9, 0)
    nameL.BackgroundTransparency = 1
    nameL.Text               = name
    nameL.Font               = Enum.Font.GothamSemibold
    nameL.TextSize            = 9
    nameL.TextColor3          = C.pri
    nameL.TextXAlignment      = Enum.TextXAlignment.Left
    nameL.TextTruncate        = Enum.TextTruncate.AtEnd
    nameL.ZIndex              = 13
    nameL.Parent              = row

    local catL = Instance.new("TextLabel")
    catL.Size               = UDim2.fromOffset(56, 16)
    catL.Position           = UDim2.new(1, -62, 0.5, -8)
    catL.BackgroundColor3   = Color3.fromRGB(24, 24, 26)
    catL.BackgroundTransparency = 0
    catL.BorderSizePixel    = 0
    catL.Text               = cat
    catL.Font               = Enum.Font.GothamBold
    catL.TextSize            = 7
    catL.TextColor3          = C.sec
    catL.ZIndex              = 13
    catL.Parent              = row
    Instance.new("UICorner", catL).CornerRadius = UDim.new(0, 4)

    row.MouseEnter:Connect(function()
        TweenService:Create(row, TweenInfo.new(0.10), {BackgroundColor3=C.cardH}):Play()
    end)
    row.MouseLeave:Connect(function()
        TweenService:Create(row, TweenInfo.new(0.10), {BackgroundColor3=C.card}):Play()
    end)
    row.MouseButton1Click:Connect(function()
        TweenService:Create(row, TweenInfo.new(0.06), {BackgroundColor3=C.accentBg}):Play()
        task.delay(0.12, function()
            pcall(function() TweenService:Create(row, TweenInfo.new(0.15), {BackgroundColor3=C.card}):Play() end)
        end)
        if onClick then onClick() end
    end)

    table.insert(allRows, {frame=row, name=name, cat=cat})
    return row
end

-- Build animation rows for all categories
for _, catName in ipairs({"Idle","Walk","Run","Jump","Fall","SwimIdle","Swim","Climb"}) do
    local data = Animations[catName]
    if data then
        for animName, animId in pairs(data) do
            mkRow(animName, catName, function()
                setAnimation(catName, animId)
                showNotif(catName, animName .. " applied.", 2.5)
            end)
        end
    end
end

-- Emotes rows
for _, e in ipairs(Emotes) do
    local name, id = e[1], e[2]
    mkRow(name, "Emotes", function()
        PlayEmote(id)
        showNotif("Emote", name .. " playing.", 2)
    end)
end

-- Donate rows
for _, d in ipairs(Donations) do
    local price, id = d[1], d[2]
    mkRow("Donate " .. price .. " Robux", "Donate", function()
        Buy(id)
    end)
end

-- ═══════════════════════════════════════════════
-- INFO SECTION  (rendered as special rows, category "Info")
-- ═══════════════════════════════════════════════
local function mkInfoCard(lines)
    local lineH  = 13
    local totalH = #lines * lineH + 10
    local f = Instance.new("Frame")
    f.Size               = UDim2.new(1, 0, 0, totalH)
    f.BackgroundColor3   = C.card
    f.BackgroundTransparency = 0
    f.BorderSizePixel    = 0
    f.LayoutOrder        = #allRows + 1
    f.ZIndex             = 12
    f.Parent             = scroll
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 5)
    local ll = Instance.new("UIListLayout")
    ll.SortOrder = Enum.SortOrder.LayoutOrder; ll.Parent = f
    local pad = Instance.new("UIPadding")
    pad.PaddingLeft=UDim.new(0,8); pad.PaddingTop=UDim.new(0,5); pad.Parent=f
    for i, line in ipairs(lines) do
        local l = Instance.new("TextLabel")
        l.Size               = UDim2.new(1, -14, 0, lineH)
        l.BackgroundTransparency = 1
        l.Text               = line
        l.Font               = line:sub(1,2)=="  " and Enum.Font.Gotham or Enum.Font.GothamBold
        l.TextSize            = 8
        l.TextColor3          = line:sub(1,2)=="  " and C.sec or C.pri
        l.TextXAlignment      = Enum.TextXAlignment.Left
        l.TextWrapped         = true
        l.LayoutOrder         = i
        l.ZIndex              = 13
        l.Parent              = f
    end
    table.insert(allRows, {frame=f, name="__info__", cat="Info"})
    return f
end

mkInfoCard({
    "Created By Anonymous9x",
    "  Full animation library for R15 characters",
    "  Idle, Walk, Run, Jump, Fall, Swim, Climb",
})

mkInfoCard({
    "How To Use",
    "  1. Pick a category tab above the list",
    "  2. Tap any animation name to apply it instantly",
    "  3. Use the search bar to find by name",
    "  4. Your last animations are saved automatically",
    "  5. They reload on respawn if file storage works",
})

mkInfoCard({
    "Notes",
    "  This pack edits the Animate script directly,",
    "  meaning all changes are client-side (FE).",
    "  Other players will not see your custom anims",
    "  unless the game replicates animation IDs.",
})

-- ═══════════════════════════════════════════════
-- FILTER LOGIC (category + search combined)
-- ═══════════════════════════════════════════════
local function applyFilter()
    local q = searchBox.Text:lower()
    for _, entry in ipairs(allRows) do
        local matchesCat = (activeCat == "All") or (entry.cat == activeCat)
        local matchesSearch = (q == "") or entry.name:lower():find(q, 1, true) ~= nil
        entry.frame.Visible = matchesCat and matchesSearch
    end
end

searchBox:GetPropertyChangedSignal("Text"):Connect(applyFilter)

local _origSetCat = setCat
setCat = function(cat)
    _origSetCat(cat)
    applyFilter()
end

applyFilter()

-- ═══════════════════════════════════════════════
-- PERSISTENCE  (load saved animations on start + respawn)
-- ═══════════════════════════════════════════════
local function loadLastAnimations()
    pcall(function()
        if isfile and isfile("Anonymous9xAnimPack.json") then
            local data = readfile("Anonymous9xAnimPack.json")
            local ok, decoded = pcall(function() return HttpService:JSONDecode(data) end)
            if ok and decoded then
                if decoded.Idle then setAnimation("Idle", decoded.Idle) end
                if decoded.Walk then setAnimation("Walk", decoded.Walk) end
                if decoded.Run then setAnimation("Run", decoded.Run) end
                if decoded.Jump then setAnimation("Jump", decoded.Jump) end
                if decoded.Fall then setAnimation("Fall", decoded.Fall) end
                if decoded.Climb then setAnimation("Climb", decoded.Climb) end
                if decoded.Swim then setAnimation("Swim", decoded.Swim) end
                if decoded.SwimIdle then setAnimation("SwimIdle", decoded.SwimIdle) end
                lastAnimations = decoded
                showNotif("Saved Animations", "Loaded your previous selections.", 3)
            end
        end
    end)
end

loadLastAnimations()

LP.CharacterAdded:Connect(function(character)
    -- Wait until alive and not ragdolled
    local humanoid = character:WaitForChild("Humanoid")
    while humanoid.Health <= 2 do task.wait(0.3) end
    while humanoid:GetState() == Enum.HumanoidStateType.Dead
       or humanoid:GetState() == Enum.HumanoidStateType.Ragdoll do
        task.wait(0.3)
    end
    task.wait(0.3)

    if lastAnimations.Idle then setAnimation("Idle", lastAnimations.Idle) end
    if lastAnimations.Walk then setAnimation("Walk", lastAnimations.Walk) end
    if lastAnimations.Run then setAnimation("Run", lastAnimations.Run) end
    if lastAnimations.Jump then setAnimation("Jump", lastAnimations.Jump) end
    if lastAnimations.Fall then setAnimation("Fall", lastAnimations.Fall) end
    if lastAnimations.Climb then setAnimation("Climb", lastAnimations.Climb) end
    if lastAnimations.Swim then setAnimation("Swim", lastAnimations.Swim) end
    if lastAnimations.SwimIdle then setAnimation("SwimIdle", lastAnimations.SwimIdle) end
end)

-- ═══════════════════════════════════════════════
-- INIT
-- ═══════════════════════════════════════════════
showNotif("Anonymous9x Animated Pack", "Loaded successfully. Pick a category to begin.", 4)

end)
