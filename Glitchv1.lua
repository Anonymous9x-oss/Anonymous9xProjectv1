--[[
╔══════════════════════════════════════════════════════════╗
║     Anonymous9x Glitch v1 — DELTA MOBILE FIXED          ║
║     FE Sky Destroyer Glitch Script                       ║
║     Compatible: Delta Mobile / Delta iOS                 ║
╠══════════════════════════════════════════════════════════╣
║  ROOT CAUSE FIX:                                         ║
║  - AutomaticCanvasSize DIHAPUS (crash silent di Delta)   ║
║  - UIListLayout DIHAPUS (AbsoluteContentSize bug)        ║
║  - UIPadding di ScrollingFrame DIHAPUS (compress bug)    ║
║  - Manual Y positioning → paling kompatibel              ║
║  - CanvasSize di-set manual + fixed                      ║
║  - gethui() support untuk Delta Native                   ║
╚══════════════════════════════════════════════════════════╝
]]

-- ============================================================
-- SAFETY WAIT (DELTA BUTUH EXTRA DELAY SAAT INJECT)
-- ============================================================
if not game:IsLoaded() then game.Loaded:Wait() end
task.wait(2)

-- ============================================================
-- SERVICES
-- ============================================================
local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local UserInputService  = game:GetService("UserInputService")
local TweenService      = game:GetService("TweenService")

-- ============================================================
-- LOCAL PLAYER
-- ============================================================
local LP = Players.LocalPlayer
local Char, HRP, Hum

local function RefreshRefs()
    Char = LP.Character
    if Char then
        HRP  = Char:FindFirstChild("HumanoidRootPart")
        Hum  = Char:FindFirstChildOfClass("Humanoid")
    end
end
RefreshRefs()

-- ============================================================
-- GUI PARENT — gethui() jika tersedia (Delta Native API)
-- ============================================================
local GuiParent
do
    local ok, h = pcall(function() return gethui() end)
    if ok and h then
        GuiParent = h
    else
        GuiParent = LP:WaitForChild("PlayerGui", 15)
    end
end

-- ============================================================
-- DESTROY DUPLICATE
-- ============================================================
for _, v in pairs(GuiParent:GetChildren()) do
    if v.Name == "Anon9x_Main" or v.Name == "Anon9x_Notif" then
        v:Destroy()
    end
end

-- ============================================================
-- CONSTANTS / STATE
-- ============================================================
local W, H_FULL = 318, 500
local TITLE_H   = 44
local CONTENT_H = H_FULL - TITLE_H   -- 456
-- Total canvas height semua elemen (dihitung manual di bawah)
local CANVAS_TOTAL = 720  -- akan di-set ulang setelah build

local GlitchActive = false
local GlitchSpeed  = 85
local GlitchConns  = {}
local Saved_C0     = {}
local Saved_C1     = {}

local SpeedOn  = false
local FlyOn    = false
local NoclipOn = false
local InvisOn  = false
local JumpOn   = false
local GravOn   = false
local AfkOn    = false
local SavedPos = nil

local FlyVel, FlyGyr, FlyCon = nil, nil, nil
local NoclipCon, AfkCon      = nil, nil

local DEF_WS, DEF_JP = 16, 50
local HACK_WS, HACK_JP = 80, 80

local function sDes(o) if o and o.Parent then pcall(function() o:Destroy() end) end end
local function sDis(c) if c then pcall(function() c:Disconnect() end) end end

-- ============================================================
-- NOTIFICATION GUI  (dibuat terpisah dari main)
-- ============================================================
local NotifSG = Instance.new("ScreenGui")
NotifSG.Name         = "Anon9x_Notif"
NotifSG.ResetOnSpawn = false
NotifSG.DisplayOrder = 9999
NotifSG.Parent       = GuiParent

local NF = Instance.new("Frame", NotifSG)
NF.Size              = UDim2.new(0, 300, 0, 56)
NF.Position          = UDim2.new(0.5, -150, 0, 10)
NF.BackgroundColor3  = Color3.fromRGB(12, 12, 12)
NF.BorderSizePixel   = 0
NF.Visible           = false
NF.ZIndex            = 200
Instance.new("UICorner", NF).CornerRadius = UDim.new(0, 10)
local NS = Instance.new("UIStroke", NF)
NS.Thickness = 2
NS.Color     = Color3.fromRGB(200, 0, 220)

local NIcon = Instance.new("TextLabel", NF)
NIcon.Size             = UDim2.new(0, 42, 1, 0)
NIcon.BackgroundColor3 = Color3.fromRGB(160, 0, 190)
NIcon.BorderSizePixel  = 0
NIcon.Text             = "☠"
NIcon.TextColor3       = Color3.fromRGB(255,255,255)
NIcon.TextScaled       = true
NIcon.Font             = Enum.Font.GothamBold
NIcon.ZIndex           = 201
Instance.new("UICorner", NIcon).CornerRadius = UDim.new(0, 10)

local NLbl = Instance.new("TextLabel", NF)
NLbl.Size             = UDim2.new(1, -50, 1, 0)
NLbl.Position         = UDim2.new(0, 47, 0, 0)
NLbl.BackgroundTransparency = 1
NLbl.Text             = ""
NLbl.TextColor3       = Color3.fromRGB(255,255,255)
NLbl.TextScaled       = true
NLbl.Font             = Enum.Font.GothamBold
NLbl.TextWrapped      = true
NLbl.TextXAlignment   = Enum.TextXAlignment.Left
NLbl.ZIndex           = 201

local notifThr = nil
local function Notif(msg, color, dur)
    if notifThr then task.cancel(notifThr) end
    NS.Color    = color or Color3.fromRGB(200, 0, 220)
    NIcon.BackgroundColor3 = color or Color3.fromRGB(160, 0, 190)
    NLbl.Text   = msg
    NF.Visible  = true
    notifThr = task.delay(dur or 3, function() NF.Visible = false end)
end

-- ============================================================
-- MAIN SCREEN GUI
-- ============================================================
local SG = Instance.new("ScreenGui")
SG.Name         = "Anon9x_Main"
SG.ResetOnSpawn = false
SG.DisplayOrder = 9998
-- JANGAN set IgnoreGuiInset = true, bisa buggy di Delta
SG.Parent       = GuiParent

-- ── SHADOW ─────────────────────────────────────────────────
local Shadow = Instance.new("Frame", SG)
Shadow.Size             = UDim2.new(0, W+4, 0, H_FULL+4)
Shadow.Position         = UDim2.new(0.5, -(W/2)-2, 0.5, -(H_FULL/2)-2)
Shadow.BackgroundColor3 = Color3.fromRGB(160, 0, 200)
Shadow.BorderSizePixel  = 0
Shadow.ZIndex           = 1
Instance.new("UICorner", Shadow).CornerRadius = UDim.new(0, 12)

-- ── OUTER FRAME ────────────────────────────────────────────
local Main = Instance.new("Frame", SG)
Main.Name              = "Main"
Main.Size              = UDim2.new(0, W, 0, H_FULL)
Main.Position          = UDim2.new(0.5, -(W/2), 0.5, -(H_FULL/2))
Main.BackgroundColor3  = Color3.fromRGB(10, 10, 10)
Main.BorderSizePixel   = 0
Main.ClipsDescendants  = true
Main.ZIndex            = 2
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)
local MainStk = Instance.new("UIStroke", Main)
MainStk.Color     = Color3.fromRGB(255,255,255)
MainStk.Thickness = 2

-- ── DRAG (Touch & Mouse compatible) ────────────────────────
do
    local drag, ds, sp = false, nil, nil
    Main.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch
        or i.UserInputType == Enum.UserInputType.MouseButton1 then
            drag = true; ds = i.Position; sp = Main.Position
        end
    end)
    Main.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch
        or i.UserInputType == Enum.UserInputType.MouseButton1 then drag = false end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if not drag then return end
        if i.UserInputType ~= Enum.UserInputType.Touch
        and i.UserInputType ~= Enum.UserInputType.MouseMovement then return end
        local d = i.Position - ds
        Main.Position   = UDim2.new(sp.X.Scale, sp.X.Offset+d.X, sp.Y.Scale, sp.Y.Offset+d.Y)
        Shadow.Position = UDim2.new(sp.X.Scale, sp.X.Offset+d.X-2, sp.Y.Scale, sp.Y.Offset+d.Y-2)
    end)
end

-- ── TITLE BAR ──────────────────────────────────────────────
local TBar = Instance.new("Frame", Main)
TBar.Size             = UDim2.new(1, 0, 0, TITLE_H)
TBar.Position         = UDim2.new(0, 0, 0, 0)
TBar.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
TBar.BorderSizePixel  = 0
TBar.ZIndex           = 10
-- bottom border line
local TLine = Instance.new("Frame", TBar)
TLine.Size            = UDim2.new(1, 0, 0, 2)
TLine.Position        = UDim2.new(0, 0, 1, -2)
TLine.BackgroundColor3 = Color3.fromRGB(255,255,255)
TLine.BorderSizePixel = 0
TLine.ZIndex          = 11

local TIcon = Instance.new("TextLabel", TBar)
TIcon.Size             = UDim2.new(0, 34, 0, 34)
TIcon.Position         = UDim2.new(0, 6, 0.5, -17)
TIcon.BackgroundColor3 = Color3.fromRGB(160, 0, 190)
TIcon.BorderSizePixel  = 0
TIcon.Text             = "☠"
TIcon.TextColor3       = Color3.fromRGB(255,255,255)
TIcon.TextScaled       = true
TIcon.Font             = Enum.Font.GothamBold
TIcon.ZIndex           = 11
Instance.new("UICorner", TIcon).CornerRadius = UDim.new(0,6)

local TTxt = Instance.new("TextLabel", TBar)
TTxt.Size             = UDim2.new(1, -108, 1, 0)
TTxt.Position         = UDim2.new(0, 46, 0, 0)
TTxt.BackgroundTransparency = 1
TTxt.Text             = "Anonymous9x Glitch v1"
TTxt.TextColor3       = Color3.fromRGB(255,255,255)
TTxt.TextScaled       = true
TTxt.Font             = Enum.Font.GothamBold
TTxt.TextXAlignment   = Enum.TextXAlignment.Left
TTxt.ZIndex           = 11

local MinBtn = Instance.new("TextButton", TBar)
MinBtn.Size            = UDim2.new(0, 28, 0, 28)
MinBtn.Position        = UDim2.new(1, -60, 0.5, -14)
MinBtn.BackgroundColor3 = Color3.fromRGB(40,40,40)
MinBtn.BorderSizePixel = 0
MinBtn.Text            = "—"
MinBtn.TextColor3      = Color3.fromRGB(255,255,255)
MinBtn.TextScaled      = true
MinBtn.Font            = Enum.Font.GothamBold
MinBtn.ZIndex          = 12
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0,6)
Instance.new("UIStroke", MinBtn).Color = Color3.fromRGB(255,255,255)

local CloseBtn = Instance.new("TextButton", TBar)
CloseBtn.Size            = UDim2.new(0, 28, 0, 28)
CloseBtn.Position        = UDim2.new(1, -28, 0.5, -14)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200,30,30)
CloseBtn.BorderSizePixel = 0
CloseBtn.Text            = "✕"
CloseBtn.TextColor3      = Color3.fromRGB(255,255,255)
CloseBtn.TextScaled      = true
CloseBtn.Font            = Enum.Font.GothamBold
CloseBtn.ZIndex          = 12
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0,6)

-- ============================================================
-- SCROLL FRAME
-- KRITIS: TIDAK pakai AutomaticCanvasSize, TIDAK pakai
-- UIListLayout, TIDAK pakai UIPadding di dalam scroll
-- CanvasSize di-set manual setelah semua elemen dibuat
-- ============================================================
local Scroll = Instance.new("ScrollingFrame", Main)
Scroll.Name                 = "Scroll"
Scroll.Size                 = UDim2.new(1, 0, 0, CONTENT_H)
Scroll.Position             = UDim2.new(0, 0, 0, TITLE_H)
Scroll.BackgroundTransparency = 1
Scroll.BorderSizePixel      = 0
Scroll.ScrollBarThickness   = 5
Scroll.ScrollBarImageColor3 = Color3.fromRGB(180, 0, 210)
Scroll.ScrollingDirection   = Enum.ScrollingDirection.Y
-- TIDAK set AutomaticCanvasSize
-- CanvasSize akan di-set di akhir
Scroll.CanvasSize           = UDim2.new(0, 0, 0, 800) -- placeholder besar
Scroll.ZIndex               = 3
Scroll.ClipsDescendants     = true

-- ============================================================
-- MANUAL Y BUILDER SYSTEM
-- Setiap elemen ditaruh langsung di Scroll dengan posisi Y manual
-- Tidak ada UIListLayout, tidak ada UIPadding
-- ============================================================
local PAD_L   = 10  -- padding left
local PAD_R   = 10  -- padding right
local GAP     = 6   -- jarak antar elemen
local ITEM_W  = W - PAD_L - PAD_R  -- 298px

local curY = 8  -- mulai dari Y=8

local function advY(h)
    local y = curY
    curY = curY + h + GAP
    return y
end

-- Helper: buat Frame separator
local function Sep()
    local f = Instance.new("Frame", Scroll)
    f.Size             = UDim2.new(0, ITEM_W, 0, 1)
    f.Position         = UDim2.new(0, PAD_L, 0, advY(1))
    f.BackgroundColor3 = Color3.fromRGB(255,255,255)
    f.BackgroundTransparency = 0.55
    f.BorderSizePixel  = 0
    f.ZIndex           = 4
    return f
end

-- Helper: buat header label section
local function Header(txt)
    local y = advY(26)
    local f = Instance.new("Frame", Scroll)
    f.Size             = UDim2.new(0, ITEM_W, 0, 26)
    f.Position         = UDim2.new(0, PAD_L, 0, y)
    f.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    f.BorderSizePixel  = 0
    f.ZIndex           = 4
    Instance.new("UICorner", f).CornerRadius = UDim.new(0,6)
    local l = Instance.new("TextLabel", f)
    l.Size             = UDim2.new(1, -10, 1, 0)
    l.Position         = UDim2.new(0, 6, 0, 0)
    l.BackgroundTransparency = 1
    l.Text             = txt
    l.TextColor3       = Color3.fromRGB(200, 0, 230)
    l.TextScaled       = true
    l.Font             = Enum.Font.GothamBold
    l.TextXAlignment   = Enum.TextXAlignment.Left
    l.ZIndex           = 5
    return f, l
end

-- Helper: buat label status
local function StatusBar(txt)
    local y = advY(30)
    local f = Instance.new("Frame", Scroll)
    f.Size             = UDim2.new(0, ITEM_W, 0, 30)
    f.Position         = UDim2.new(0, PAD_L, 0, y)
    f.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
    f.BorderSizePixel  = 0
    f.ZIndex           = 4
    Instance.new("UICorner", f).CornerRadius = UDim.new(0,6)
    Instance.new("UIStroke", f).Color = Color3.fromRGB(255,255,255)
    local l = Instance.new("TextLabel", f)
    l.Size             = UDim2.new(1, -12, 1, 0)
    l.Position         = UDim2.new(0, 6, 0, 0)
    l.BackgroundTransparency = 1
    l.Text             = txt
    l.TextColor3       = Color3.fromRGB(255,255,255)
    l.TextScaled       = true
    l.Font             = Enum.Font.GothamBold
    l.TextXAlignment   = Enum.TextXAlignment.Left
    l.ZIndex           = 5
    return f, l
end

-- Helper: buat 1 tombol full width
local function Btn(txt, h, bg)
    local y = advY(h)
    local b = Instance.new("TextButton", Scroll)
    b.Size             = UDim2.new(0, ITEM_W, 0, h)
    b.Position         = UDim2.new(0, PAD_L, 0, y)
    b.BackgroundColor3 = bg or Color3.fromRGB(22,22,22)
    b.BorderSizePixel  = 0
    b.Text             = txt
    b.TextColor3       = Color3.fromRGB(255,255,255)
    b.TextScaled       = true
    b.Font             = Enum.Font.GothamBold
    b.ZIndex           = 4
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,8)
    local s = Instance.new("UIStroke", b)
    s.Color = Color3.fromRGB(255,255,255); s.Thickness = 2
    return b
end

-- Helper: buat 2 tombol dalam 1 baris
local function BtnRow(t1, t2, h, c1, c2)
    local HALF = (ITEM_W - 6) / 2
    local y    = advY(h)

    local b1 = Instance.new("TextButton", Scroll)
    b1.Size             = UDim2.new(0, HALF, 0, h)
    b1.Position         = UDim2.new(0, PAD_L, 0, y)
    b1.BackgroundColor3 = c1 or Color3.fromRGB(22,22,22)
    b1.BorderSizePixel  = 0
    b1.Text             = t1
    b1.TextColor3       = Color3.fromRGB(255,255,255)
    b1.TextScaled       = true
    b1.Font             = Enum.Font.GothamBold
    b1.ZIndex           = 4
    Instance.new("UICorner", b1).CornerRadius = UDim.new(0,8)
    local s1 = Instance.new("UIStroke", b1)
    s1.Color = Color3.fromRGB(255,255,255); s1.Thickness = 2

    local b2 = Instance.new("TextButton", Scroll)
    b2.Size             = UDim2.new(0, HALF, 0, h)
    b2.Position         = UDim2.new(0, PAD_L + HALF + 6, 0, y)
    b2.BackgroundColor3 = c2 or Color3.fromRGB(22,22,22)
    b2.BorderSizePixel  = 0
    b2.Text             = t2
    b2.TextColor3       = Color3.fromRGB(255,255,255)
    b2.TextScaled       = true
    b2.Font             = Enum.Font.GothamBold
    b2.ZIndex           = 4
    Instance.new("UICorner", b2).CornerRadius = UDim.new(0,8)
    local s2 = Instance.new("UIStroke", b2)
    s2.Color = Color3.fromRGB(255,255,255); s2.Thickness = 2

    return b1, b2
end

-- Helper: buat slider
local function MkSlider(lbl_txt, def, minV, maxV)
    -- label
    local ly  = advY(20)
    local lbl = Instance.new("TextLabel", Scroll)
    lbl.Size             = UDim2.new(0, ITEM_W, 0, 20)
    lbl.Position         = UDim2.new(0, PAD_L, 0, ly)
    lbl.BackgroundTransparency = 1
    lbl.Text             = lbl_txt .. ": " .. def
    lbl.TextColor3       = Color3.fromRGB(255,255,255)
    lbl.TextScaled       = true
    lbl.Font             = Enum.Font.GothamBold
    lbl.TextXAlignment   = Enum.TextXAlignment.Left
    lbl.ZIndex           = 4

    -- track
    local ty    = advY(18)
    local track = Instance.new("Frame", Scroll)
    track.Size             = UDim2.new(0, ITEM_W, 0, 18)
    track.Position         = UDim2.new(0, PAD_L, 0, ty)
    track.BackgroundColor3 = Color3.fromRGB(35,35,35)
    track.BorderSizePixel  = 0
    track.ZIndex           = 4
    Instance.new("UICorner", track).CornerRadius = UDim.new(1,0)
    local ts = Instance.new("UIStroke", track)
    ts.Color = Color3.fromRGB(255,255,255); ts.Thickness = 1

    local iR   = (def - minV) / (maxV - minV)
    local fill = Instance.new("Frame", track)
    fill.Size             = UDim2.new(iR, 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(180,0,210)
    fill.BorderSizePixel  = 0
    fill.ZIndex           = 5
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1,0)

    local knob = Instance.new("TextButton", track)
    knob.Size             = UDim2.new(0, 22, 0, 22)
    knob.Position         = UDim2.new(iR, -11, 0.5, -11)
    knob.BackgroundColor3 = Color3.fromRGB(255,255,255)
    knob.BorderSizePixel  = 0
    knob.Text             = ""
    knob.ZIndex           = 6
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1,0)

    local curV   = def
    local active = false
    local onCB   = nil

    local function apply(ratio)
        ratio = math.clamp(ratio, 0, 1)
        curV  = math.floor(minV + ratio*(maxV-minV))
        fill.Size     = UDim2.new(ratio, 0, 1, 0)
        knob.Position = UDim2.new(ratio, -11, 0.5, -11)
        lbl.Text      = lbl_txt .. ": " .. curV
        if onCB then onCB(curV) end
    end

    track.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then active=true end
    end)
    knob.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then active=true end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then active=false end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if not active then return end
        if i.UserInputType~=Enum.UserInputType.Touch and i.UserInputType~=Enum.UserInputType.MouseMovement then return end
        local ax = track.AbsolutePosition.X
        local aw = track.AbsoluteSize.X
        if aw<=0 then return end
        apply((i.Position.X - ax)/aw)
    end)

    return { label=lbl, getValue=function() return curV end, setOnChange=function(cb) onCB=cb end }
end

-- Helper: TextBox + Button row
local function InputRow(ph, btxt, h)
    local HALF = (ITEM_W - 6) * 0.62
    local HALF2 = ITEM_W - HALF - 6
    local y    = advY(h)

    local box = Instance.new("TextBox", Scroll)
    box.Size             = UDim2.new(0, HALF, 0, h)
    box.Position         = UDim2.new(0, PAD_L, 0, y)
    box.BackgroundColor3 = Color3.fromRGB(22,22,22)
    box.BorderSizePixel  = 0
    box.PlaceholderText  = ph
    box.PlaceholderColor3 = Color3.fromRGB(100,100,100)
    box.Text             = ""
    box.TextColor3       = Color3.fromRGB(255,255,255)
    box.TextScaled       = true
    box.Font             = Enum.Font.GothamBold
    box.ClearTextOnFocus = false
    box.ZIndex           = 4
    Instance.new("UICorner", box).CornerRadius = UDim.new(0,8)
    local bs = Instance.new("UIStroke",box); bs.Color=Color3.fromRGB(255,255,255); bs.Thickness=2

    local btn = Instance.new("TextButton", Scroll)
    btn.Size             = UDim2.new(0, HALF2, 0, h)
    btn.Position         = UDim2.new(0, PAD_L + HALF + 6, 0, y)
    btn.BackgroundColor3 = Color3.fromRGB(0, 120, 180)
    btn.BorderSizePixel  = 0
    btn.Text             = btxt
    btn.TextColor3       = Color3.fromRGB(255,255,255)
    btn.TextScaled       = true
    btn.Font             = Enum.Font.GothamBold
    btn.ZIndex           = 4
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,8)
    local bs2=Instance.new("UIStroke",btn); bs2.Color=Color3.fromRGB(255,255,255); bs2.Thickness=2

    return box, btn
end

-- Helper: teks info kecil
local function InfoBox(txt, h)
    local y = advY(h)
    local f = Instance.new("Frame", Scroll)
    f.Size             = UDim2.new(0, ITEM_W, 0, h)
    f.Position         = UDim2.new(0, PAD_L, 0, y)
    f.BackgroundColor3 = Color3.fromRGB(18,18,18)
    f.BorderSizePixel  = 0
    f.ZIndex           = 4
    Instance.new("UICorner", f).CornerRadius = UDim.new(0,8)
    Instance.new("UIStroke",f).Color = Color3.fromRGB(255,255,255)
    local l = Instance.new("TextLabel", f)
    l.Size             = UDim2.new(1, -12, 1, -8)
    l.Position         = UDim2.new(0, 6, 0, 4)
    l.BackgroundTransparency = 1
    l.Text             = txt
    l.TextColor3       = Color3.fromRGB(170,170,170)
    l.TextScaled       = true
    l.Font             = Enum.Font.Gotham
    l.TextXAlignment   = Enum.TextXAlignment.Left
    l.TextWrapped      = true
    l.ZIndex           = 5
    return f, l
end

-- ============================================================
-- BUILD SEMUA ELEMENT (urut dari atas ke bawah)
-- ============================================================

-- STATUS
local _, StatusLbl = StatusBar("◉ Status: Ready  |  Rig: Checking...")
Sep()

-- SECTION 1: GLITCH
Header("[ ☠  AVATAR GLITCH  ☠ ]")
local BrokenBtn = Btn("💀   B R O K E N   💀", 52, Color3.fromRGB(130,0,160))
local StopBtn   = Btn("■   STOP GLITCH", 40)
local SpeedSlider = MkSlider("Speed", GlitchSpeed, 1, 200)
SpeedSlider.setOnChange(function(v) GlitchSpeed = v end)
Sep()

-- SECTION 2: EXTRA
Header("[ ⚡  EXTRA FEATURES ]")
local SpeedBtn, FlyBtn    = BtnRow("SpeedHack\nOFF", "Fly\nOFF",   50)
local NoclipBtn, InvisBtn = BtnRow("Noclip\nOFF",    "Invis\nOFF", 50)
local JumpBtn, GravBtn    = BtnRow("HighJump\nOFF",  "LowGrav\nOFF", 50)
Sep()

-- SECTION 3: TOOLS
Header("[ 🔧  TOOLS ]")
local ResetBtn, TpUpBtn   = BtnRow("↺ Reset Char", "⬆ TP Up",    42)
local SaveBtn, AfkBtn     = BtnRow("📍 Save Pos",  "⏱ Anti-AFK", 42)
local HatBox, WearBtn     = InputRow("Hat/Acc Asset ID...", "WEAR", 40)
local SfxBox, SfxBtn      = InputRow("Sound Asset ID...",   "PLAY", 40)
Sep()

-- SECTION 4: INFO
Header("[ ℹ  INFO ]")
InfoBox("☠ Anon9x Glitch v1  |  Delta Mobile Edition\nFE Script — Visible semua player di server\n⚠ Wajib Avatar R15 untuk glitch aktif", 62)

-- bottom padding
curY = curY + 10

-- ============================================================
-- SET CANVAS SIZE MANUAL (KRITIS — SETELAH SEMUA ELEMEN)
-- ============================================================
Scroll.CanvasSize = UDim2.new(0, 0, 0, curY)

-- ============================================================
-- GLITCH LOGIC
-- ============================================================
local function saveMotors()
    Saved_C0 = {}; Saved_C1 = {}
    if not Char then return end
    for _, m in pairs(Char:GetDescendants()) do
        if m:IsA("Motor6D") and m.Part0 and m.Part1 then
            Saved_C0[m] = m.C0
            Saved_C1[m] = m.C1
        end
    end
end

local function restoreMotors()
    if not Char then return end
    for _, m in pairs(Char:GetDescendants()) do
        if m:IsA("Motor6D") then
            if Saved_C0[m] then pcall(function() m.C0=Saved_C0[m] end) end
            if Saved_C1[m] then pcall(function() m.C1=Saved_C1[m] end) end
        end
    end
end

local function resetAccs()
    if not Char then return end
    for _, a in pairs(Char:GetChildren()) do
        if a:IsA("Accessory") then
            local h = a:FindFirstChild("Handle")
            if h then pcall(function() h.Size=Vector3.new(1,1,1); h.Transparency=0 end) end
        end
    end
end

local function stopGlitch(silent)
    GlitchActive = false
    for _, c in pairs(GlitchConns) do sDis(c) end
    GlitchConns = {}
    task.wait(0.06)
    restoreMotors()
    resetAccs()
    if Hum then pcall(function() Hum.PlatformStand=false end) end
    BrokenBtn.BackgroundColor3 = Color3.fromRGB(130,0,160)
    BrokenBtn.Text = "💀   B R O K E N   💀"
    local rig = (Hum and Hum.RigType==Enum.HumanoidRigType.R15) and "R15 ✓" or "R6 ✗"
    StatusLbl.Text      = "◉ Status: Ready  |  Rig: " .. rig
    StatusLbl.TextColor3 = Color3.fromRGB(255,255,255)
    if not silent then Notif("✓ Glitch STOP — Avatar direset!", Color3.fromRGB(50,200,100)) end
end

local function startGlitch()
    if GlitchActive then return end
    RefreshRefs()
    if not Hum or Hum.RigType~=Enum.HumanoidRigType.R15 then
        Notif("⚠ R6 Detected!\nGanti ke Avatar R15 lalu coba lagi.", Color3.fromRGB(255,120,0), 5)
        return
    end
    if not HRP then return end
    GlitchActive = true
    saveMotors()
    BrokenBtn.BackgroundColor3 = Color3.fromRGB(200,0,220)
    BrokenBtn.Text = "💀  GLITCHING...  💀"
    StatusLbl.Text = "◉ Status: GLITCHING  |  R15 ✓"
    StatusLbl.TextColor3 = Color3.fromRGB(255,50,255)

    -- CONN 1: Motor6D randomizer (FE replicated)
    local c1 = RunService.Heartbeat:Connect(function()
        if not GlitchActive then return end
        local c = LP.Character; if not c then return end
        local sp=GlitchSpeed; local t=tick()
        local wX=math.sin(t*sp*0.25); local wY=math.cos(t*sp*0.30); local wZ=math.sin(t*sp*0.20+0.8)
        for _, m in pairs(c:GetDescendants()) do
            if m:IsA("Motor6D") and Saved_C0[m] then
                if math.random(100)<=75 then
                    local rx=math.rad(math.random(-360,360)*(sp/100))
                    local ry=math.rad(math.random(-360,360)*(sp/100))
                    local rz=math.rad(math.random(-360,360)*(sp/100))
                    pcall(function()
                        m.C0 = Saved_C0[m]
                            * CFrame.new(wX*(sp/40), wY*(sp/22), wZ*(sp/40))
                            * CFrame.Angles(rx,ry,rz)
                    end)
                end
            end
        end
    end)

    -- CONN 2: Accessory scale (FE visible — sky stretch)
    local c2 = RunService.Heartbeat:Connect(function()
        if not GlitchActive then return end
        local c = LP.Character; if not c then return end
        local sp=GlitchSpeed; local t=tick()
        for _, a in pairs(c:GetChildren()) do
            if a:IsA("Accessory") then
                local h = a:FindFirstChild("Handle")
                if h then
                    pcall(function()
                        h.Size = Vector3.new(
                            1+math.abs(math.sin(t*sp*0.09))*(sp/20),
                            1+math.abs(math.cos(t*sp*0.07))*(sp/8),
                            1+math.abs(math.sin(t*sp*0.11))*(sp/20)
                        )
                    end)
                end
            end
        end
    end)

    -- CONN 3: HRP jitter (position replicated FE)
    local c3 = RunService.Heartbeat:Connect(function()
        if not GlitchActive then return end
        local hrp2 = HRP; if not hrp2 then return end
        local sp=GlitchSpeed
        if math.random(math.max(2,14-math.floor(sp/18)))==1 then
            pcall(function()
                hrp2.CFrame = hrp2.CFrame + Vector3.new(
                    (math.random()-0.5)*sp*0.10,
                    (math.random()-0.5)*sp*0.05,
                    (math.random()-0.5)*sp*0.10
                )
            end)
        end
    end)

    -- CONN 4: PlatformStand pulse
    local c4 = RunService.Heartbeat:Connect(function()
        if not GlitchActive then return end
        if Hum then pcall(function() Hum.PlatformStand=(math.random(4)==1) end) end
    end)

    GlitchConns={c1,c2,c3,c4}
    Notif("💀 BROKEN! Speed: "..GlitchSpeed.." — Semua player lihat!", Color3.fromRGB(200,0,220))
end

-- ============================================================
-- BUTTON EVENTS
-- ============================================================
BrokenBtn.MouseButton1Click:Connect(function()
    if GlitchActive then Notif("Tekan STOP untuk hentikan!", Color3.fromRGB(255,160,0))
    else startGlitch() end
end)

StopBtn.MouseButton1Click:Connect(function()
    if GlitchActive then stopGlitch(false)
    else Notif("Glitch sudah tidak aktif.", Color3.fromRGB(150,150,150)) end
end)

-- Speed Hack
SpeedBtn.MouseButton1Click:Connect(function()
    SpeedOn = not SpeedOn
    RefreshRefs()
    if Hum then pcall(function() Hum.WalkSpeed = SpeedOn and HACK_WS or DEF_WS end) end
    SpeedBtn.BackgroundColor3 = SpeedOn and Color3.fromRGB(120,0,160) or Color3.fromRGB(22,22,22)
    SpeedBtn.Text = SpeedOn and "SpeedHack\nON ✓" or "SpeedHack\nOFF"
    Notif(SpeedOn and "⚡ SpeedHack ON! WS:"..HACK_WS or "SpeedHack OFF",
          SpeedOn and Color3.fromRGB(180,0,220) or Color3.fromRGB(120,120,120))
end)

-- Fly
FlyBtn.MouseButton1Click:Connect(function()
    FlyOn = not FlyOn
    RefreshRefs()
    if not Char or not HRP or not Hum then Notif("Character error!", Color3.fromRGB(255,80,80)); FlyOn=false; return end
    if FlyOn then
        FlyBtn.BackgroundColor3=Color3.fromRGB(120,0,160); FlyBtn.Text="Fly\nON ✓"
        pcall(function() Hum.PlatformStand=true end)
        FlyVel=Instance.new("BodyVelocity"); FlyVel.Velocity=Vector3.zero; FlyVel.MaxForce=Vector3.new(1e9,1e9,1e9); FlyVel.Parent=HRP
        FlyGyr=Instance.new("BodyGyro"); FlyGyr.P=9e4; FlyGyr.MaxTorque=Vector3.new(9e9,9e9,9e9); FlyGyr.CFrame=HRP.CFrame; FlyGyr.Parent=HRP
        FlyCon=RunService.Heartbeat:Connect(function()
            if not FlyOn then return end
            local h2=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart"); if not h2 then return end
            local cam=workspace.CurrentCamera; local spd=60; local vel=Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then vel=vel+cam.CFrame.LookVector*spd end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then vel=vel-cam.CFrame.LookVector*spd end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then vel=vel-cam.CFrame.RightVector*spd end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then vel=vel+cam.CFrame.RightVector*spd end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space)     then vel=vel+Vector3.new(0,spd,0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then vel=vel-Vector3.new(0,spd,0) end
            FlyVel.Velocity=vel; FlyGyr.CFrame=cam.CFrame
        end)
        Notif("🛸 Fly ON! WASD+Space/Shift", Color3.fromRGB(180,0,220))
    else
        FlyBtn.BackgroundColor3=Color3.fromRGB(22,22,22); FlyBtn.Text="Fly\nOFF"
        sDis(FlyCon); sDes(FlyVel); sDes(FlyGyr)
        if Hum then pcall(function() Hum.PlatformStand=false end) end
        Notif("Fly OFF", Color3.fromRGB(120,120,120))
    end
end)

-- Noclip
NoclipBtn.MouseButton1Click:Connect(function()
    NoclipOn = not NoclipOn
    NoclipBtn.BackgroundColor3 = NoclipOn and Color3.fromRGB(120,0,160) or Color3.fromRGB(22,22,22)
    NoclipBtn.Text = NoclipOn and "Noclip\nON ✓" or "Noclip\nOFF"
    if NoclipOn then
        NoclipCon=RunService.Stepped:Connect(function()
            if not NoclipOn then return end
            local c=LP.Character; if not c then return end
            for _, p in pairs(c:GetDescendants()) do
                if p:IsA("BasePart") then pcall(function() p.CanCollide=false end) end
            end
        end)
        Notif("👻 Noclip ON!", Color3.fromRGB(180,0,220))
    else
        sDis(NoclipCon)
        local c=LP.Character
        if c then for _, p in pairs(c:GetDescendants()) do
            if p:IsA("BasePart") then pcall(function() p.CanCollide=true end) end
        end end
        Notif("Noclip OFF", Color3.fromRGB(120,120,120))
    end
end)

-- Invisible
InvisBtn.MouseButton1Click:Connect(function()
    InvisOn = not InvisOn
    local c=LP.Character
    if c then for _, p in pairs(c:GetDescendants()) do
        if p:IsA("BasePart") then pcall(function() p.LocalTransparencyModifier=InvisOn and 1 or 0 end) end
    end end
    InvisBtn.BackgroundColor3 = InvisOn and Color3.fromRGB(120,0,160) or Color3.fromRGB(22,22,22)
    InvisBtn.Text = InvisOn and "Invis\nON ✓" or "Invis\nOFF"
    Notif(InvisOn and "🫥 Invisible ON (lokal)" or "Invisible OFF",
          InvisOn and Color3.fromRGB(180,0,220) or Color3.fromRGB(120,120,120))
end)

-- HighJump
JumpBtn.MouseButton1Click:Connect(function()
    JumpOn = not JumpOn
    RefreshRefs()
    if Hum then pcall(function() Hum.JumpPower=JumpOn and HACK_JP or DEF_JP end) end
    JumpBtn.BackgroundColor3 = JumpOn and Color3.fromRGB(120,0,160) or Color3.fromRGB(22,22,22)
    JumpBtn.Text = JumpOn and "HighJump\nON ✓" or "HighJump\nOFF"
    Notif(JumpOn and "🦘 HighJump ON! JP:"..HACK_JP or "HighJump OFF",
          JumpOn and Color3.fromRGB(180,0,220) or Color3.fromRGB(120,120,120))
end)

-- LowGrav
GravBtn.MouseButton1Click:Connect(function()
    GravOn = not GravOn
    pcall(function() workspace.Gravity = GravOn and 10 or 196.2 end)
    GravBtn.BackgroundColor3 = GravOn and Color3.fromRGB(120,0,160) or Color3.fromRGB(22,22,22)
    GravBtn.Text = GravOn and "LowGrav\nON ✓" or "LowGrav\nOFF"
    Notif(GravOn and "🌌 Low Gravity ON!" or "Gravity normal",
          GravOn and Color3.fromRGB(180,0,220) or Color3.fromRGB(120,120,120))
end)

-- Reset
ResetBtn.MouseButton1Click:Connect(function()
    stopGlitch(true)
    RefreshRefs()
    if Hum then pcall(function() Hum.Health=0 end) end
    Notif("↺ Character reset!", Color3.fromRGB(100,200,255))
end)

-- TP Up
TpUpBtn.MouseButton1Click:Connect(function()
    RefreshRefs()
    if HRP then pcall(function() HRP.CFrame=HRP.CFrame+Vector3.new(0,200,0) end) end
    Notif("⬆ TP 200 studs ke atas!", Color3.fromRGB(100,200,255))
end)

-- Save Pos
SaveBtn.MouseButton1Click:Connect(function()
    RefreshRefs()
    if not HRP then return end
    if not SavedPos then
        SavedPos = HRP.CFrame
        SaveBtn.Text="📍 TP Now\n(Tap!)"
        SaveBtn.BackgroundColor3=Color3.fromRGB(0,140,80)
        Notif("📍 Posisi tersimpan! Tap lagi untuk TP.", Color3.fromRGB(100,200,255))
    else
        pcall(function() HRP.CFrame=SavedPos end)
        SavedPos=nil; SaveBtn.Text="📍 Save Pos"
        SaveBtn.BackgroundColor3=Color3.fromRGB(22,22,22)
        Notif("📍 Teleported!", Color3.fromRGB(100,200,255))
    end
end)

-- Anti-AFK
AfkBtn.MouseButton1Click:Connect(function()
    AfkOn = not AfkOn
    if AfkOn then
        AfkBtn.BackgroundColor3=Color3.fromRGB(120,0,160); AfkBtn.Text="⏱ Anti-AFK\nON ✓"
        AfkCon=RunService.Heartbeat:Connect(function()
            if not AfkOn then return end
            local h2=LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
            if h2 then pcall(function() h2:Move(Vector3.new(0.001,0,0.001),false) end) end
        end)
        Notif("⏱ Anti-AFK ON!", Color3.fromRGB(180,0,220))
    else
        sDis(AfkCon); AfkBtn.BackgroundColor3=Color3.fromRGB(22,22,22); AfkBtn.Text="⏱ Anti-AFK"
        Notif("Anti-AFK OFF", Color3.fromRGB(120,120,120))
    end
end)

-- Wear Hat
WearBtn.MouseButton1Click:Connect(function()
    local id=tonumber(HatBox.Text)
    if not id then Notif("⚠ Masukkan Asset ID yang valid!", Color3.fromRGB(255,80,80)); return end
    Notif("⏳ Loading Hat ID: "..id.."...", Color3.fromRGB(100,160,255))
    task.spawn(function()
        local ok2,_=pcall(function()
            local IS=game:GetService("InsertService")
            local mdl=IS:LoadAsset(id)
            local hat=mdl:FindFirstChildOfClass("Accessory") or mdl:FindFirstChildOfClass("Hat")
            if hat then hat.Parent=LP.Character; mdl:Destroy()
                Notif("✓ Hat ID "..id.." dipakai!", Color3.fromRGB(50,220,100))
            else mdl:Destroy(); Notif("⚠ Bukan Accessory valid.", Color3.fromRGB(255,80,80)) end
        end)
        if not ok2 then Notif("⚠ Gagal. Game block InsertService.", Color3.fromRGB(255,80,80)) end
    end)
end)

-- Play SFX
SfxBtn.MouseButton1Click:Connect(function()
    local id=tonumber(SfxBox.Text)
    if not id then Notif("⚠ Masukkan Sound ID yang valid!", Color3.fromRGB(255,80,80)); return end
    pcall(function()
        local s=Instance.new("Sound"); s.SoundId="rbxassetid://"..id; s.Volume=1; s.Parent=workspace; s:Play()
        game:GetService("Debris"):AddItem(s,60)
        Notif("🎵 Playing SFX: "..id, Color3.fromRGB(100,160,255))
    end)
end)

-- ============================================================
-- MINIMIZE / CLOSE
-- ============================================================
local minimized = false
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    Scroll.Visible  = not minimized
    Shadow.Visible  = not minimized
    Main.Size       = minimized and UDim2.new(0,W,0,TITLE_H) or UDim2.new(0,W,0,H_FULL)
    MinBtn.Text     = minimized and "+" or "—"
end)

CloseBtn.MouseButton1Click:Connect(function()
    stopGlitch(true)
    sDis(FlyCon); sDes(FlyVel); sDes(FlyGyr)
    sDis(NoclipCon); sDis(AfkCon)
    if GravOn then pcall(function() workspace.Gravity=196.2 end) end
    RefreshRefs()
    if Hum then pcall(function()
        Hum.WalkSpeed=DEF_WS; Hum.JumpPower=DEF_JP; Hum.PlatformStand=false
    end) end
    sDes(SG); sDes(NotifSG)
end)

-- ============================================================
-- CHARACTER RESPAWN HANDLER
-- ============================================================
LP.CharacterAdded:Connect(function(char)
    task.wait(1.5)
    Char=char; HRP=char:FindFirstChild("HumanoidRootPart"); Hum=char:FindFirstChildOfClass("Humanoid")
    GlitchActive=false; GlitchConns={}; Saved_C0={}; Saved_C1={}
    BrokenBtn.BackgroundColor3=Color3.fromRGB(130,0,160); BrokenBtn.Text="💀   B R O K E N   💀"
    task.wait(0.5)
    if Hum then
        if SpeedOn then pcall(function() Hum.WalkSpeed=HACK_WS end) end
        if JumpOn  then pcall(function() Hum.JumpPower=HACK_JP end) end
    end
    local rig=(Hum and Hum.RigType==Enum.HumanoidRigType.R15) and "R15 ✓" or "R6 ✗"
    StatusLbl.Text       = "◉ Status: Ready  |  Rig: "..rig
    StatusLbl.TextColor3 = (rig=="R15 ✓") and Color3.fromRGB(50,255,100) or Color3.fromRGB(255,80,80)
end)

-- ============================================================
-- INIT STATUS UPDATE
-- ============================================================
task.wait(0.5)
RefreshRefs()
local initRig = (Hum and Hum.RigType==Enum.HumanoidRigType.R15) and "R15 ✓" or "R6 ✗"
StatusLbl.Text       = "◉ Status: Ready  |  Rig: "..initRig
StatusLbl.TextColor3 = (initRig=="R15 ✓") and Color3.fromRGB(50,255,100) or Color3.fromRGB(255,80,80)

Notif("☠ Anon9x Glitch v1 — Loaded!\nDelta Mobile Fixed Edition", Color3.fromRGB(0,160,255), 5)

print("[Anon9x] Loaded OK — Canvas Y: "..curY.." px")
print("[Anon9x] Rig: "..initRig)
