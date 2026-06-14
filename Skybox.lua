--[[
    Ano9x Skybox
    Delta Mobile / Delta iOS
    FE Skybox Engine — Mode System
]]

if not game:IsLoaded() then game.Loaded:Wait() end
task.wait(1.5)

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")

local LP = Players.LocalPlayer
local function getChar() return LP.Character end
local function getHRP()  local c=getChar(); return c and c:FindFirstChild("HumanoidRootPart") end
local function getHum()  local c=getChar(); return c and c:FindFirstChildOfClass("Humanoid") end

local GuiParent
do
    local ok, h = pcall(function() return gethui() end)
    GuiParent = (ok and h) or LP:WaitForChild("PlayerGui", 15)
end
for _, v in pairs(GuiParent:GetChildren()) do
    if v.Name=="Ano9x_SBMain" or v.Name=="Ano9x_SBNotif" or v.Name=="Ano9x_SBIcon" then
        v:Destroy()
    end
end

-- ============================================================
-- ENGINE
-- ============================================================
local DEFAULT_ID = "93224413172183"

local MODES = {
    Skybox1 = {
        StopOnMove   = false,
        AllowInvis   = true,
        TimePosition = 0.24,
        Speed        = 0.00,
        Weight       = 0.23,
        FadeIn       = 0.00,
        FadeOut      = 0.00,
    },
    Flickering = {
        StopOnMove   = false,
        AllowInvis   = true,
        TimePosition = 0.24,
        Speed        = 0.39,
        Weight       = 0.23,
        FadeIn       = 0.00,
        FadeOut      = 0.00,
    },
    Skybox2 = {
        StopOnMove   = false,
        AllowInvis   = true,
        TimePosition = 0.15,
        Speed        = 0.00,
        Weight       = 0.19,
        FadeIn       = 0.00,
        FadeOut      = 0.00,
    },
}

local S = {
    StopOnMove   = false,
    AllowInvis   = true,
    TimePosition = 0.24,
    Speed        = 0.00,
    Weight       = 0.23,
    FadeIn       = 0.00,
    FadeOut      = 0.00,
}

local CurrentTrack  = nil
local origCollide   = {}
local isActive      = false
local selectedMode  = nil

-- Freeze
local freezeConn    = nil
local frozenPos     = nil
local origWS        = 16
local origJP        = 50
local spinAngle     = 0

-- Spin 1 (very slow — skybox friendly)
local spinOn        = false
local SPIN1_DEG     = 14   -- degrees per second (slow)

-- Unzoom
local unzoomOn      = false
local DEFAULT_FOV   = 70
local WIDE_FOV      = 115

-- ============================================================
-- COLLIDE
-- ============================================================
local function saveCollide()
    origCollide = {}
    local c = getChar(); if not c then return end
    for _, p in pairs(c:GetDescendants()) do
        if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
            origCollide[p] = p.CanCollide
        end
    end
end
local function disableCollide()
    local c = getChar(); if not c then return end
    for _, p in pairs(c:GetDescendants()) do
        if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
            pcall(function() p.CanCollide = false end)
        end
    end
end
local function restoreCollide()
    for p, v in pairs(origCollide) do
        if p and p.Parent then pcall(function() p.CanCollide = v end) end
    end
    origCollide = {}
end

-- ============================================================
-- FREEZE ENGINE
-- Character position locked, thumbstick hidden, camera FREE
-- ============================================================
local function startFreeze()
    local hrp = getHRP(); if not hrp then return end
    local hum = getHum()
    frozenPos = hrp.CFrame
    spinAngle = 0
    if hum then
        origWS = hum.WalkSpeed; origJP = hum.JumpPower
        pcall(function() hum.WalkSpeed = 0; hum.JumpPower = 0 end)
    end
    -- Hide mobile analog/thumbstick
    pcall(function() UserInputService.ModalEnabled = true end)
    if freezeConn then freezeConn:Disconnect(); freezeConn = nil end
    freezeConn = RunService.Heartbeat:Connect(function(dt)
        local hrp2 = getHRP(); if not hrp2 then return end
        if spinOn then
            spinAngle = spinAngle + SPIN1_DEG * dt
            pcall(function()
                hrp2.CFrame = CFrame.new(frozenPos.Position)
                    * CFrame.Angles(0, math.rad(spinAngle), 0)
            end)
        else
            pcall(function() hrp2.CFrame = frozenPos end)
        end
    end)
end

local function stopFreeze()
    if freezeConn then freezeConn:Disconnect(); freezeConn = nil end
    local hum = getHum()
    if hum then
        pcall(function() hum.WalkSpeed = origWS; hum.JumpPower = origJP end)
    end
    pcall(function() UserInputService.ModalEnabled = false end)
    frozenPos = nil; spinAngle = 0
end

-- ============================================================
-- EMOTE ENGINE
-- ============================================================
local function doStop()
    isActive = false
    if CurrentTrack then
        pcall(function() CurrentTrack:Stop(S.FadeOut) end)
        CurrentTrack = nil
    end
    restoreCollide()
    stopFreeze()
end

local function doPlay()
    local hum = getHum()
    if not hum then return false, "Humanoid not found" end
    doStop()

    local animId
    local ok, res = pcall(function() return game:GetObjects("rbxassetid://" .. DEFAULT_ID) end)
    if ok and res and res[1] and res[1]:IsA("Animation") then
        animId = res[1].AnimationId
    else
        animId = "rbxassetid://" .. DEFAULT_ID
    end

    local anim = Instance.new("Animation")
    anim.AnimationId = animId

    local ok2, track = pcall(function() return hum:LoadAnimation(anim) end)
    if not ok2 or not track then return false, "Failed to load animation" end

    track.Looped = true   -- FIX: Skybox2 & all static poses

    track.Priority = Enum.AnimationPriority.Action4
    local w = S.Weight == 0 and 0.001 or S.Weight
    -- Use tiny non-zero speed if Speed=0 so track actually starts
    local sp = S.Speed == 0 and 0.001 or S.Speed
    track:Play(S.FadeIn, w, sp)
    CurrentTrack = track

    -- Set time position after short delay (track needs to be playing)
    task.spawn(function()
        task.wait(0.12)
        for _ = 1, 6 do
            if CurrentTrack then  -- FIX: removed IsPlaying check
                pcall(function()
                    CurrentTrack.TimePosition = S.TimePosition
                    CurrentTrack:AdjustSpeed(S.Speed)  -- set to real speed (0 = frozen pose)
                    CurrentTrack:AdjustWeight(w)
                end)
                break
            end
            task.wait(0.05)
        end
    end)

    saveCollide()
    if S.AllowInvis then disableCollide() end

    -- Freeze character, camera stays free
    startFreeze()

    isActive = true
    return true
end

-- ============================================================
-- HELPERS
-- ============================================================
local function sDes(o) if o and o.Parent then pcall(function() o:Destroy() end) end end
local function sDis(c) if c then pcall(function() c:Disconnect() end) end end
local function tw(obj, props, t, sty, dir)
    TweenService:Create(obj,
        TweenInfo.new(t or 0.18, sty or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out),
        props
    ):Play()
end

-- ============================================================
-- LAYOUT
-- ============================================================
local GW = 265
local GH = 220
local TH = 38
local PD = 9
local IW = GW - PD * 2
local GP = 5

-- ============================================================
-- NOTIFICATION — bottom-right, 2s
-- ============================================================
local NotifSG = Instance.new("ScreenGui")
NotifSG.Name="Ano9x_SBNotif"; NotifSG.ResetOnSpawn=false
NotifSG.DisplayOrder=9999; NotifSG.Parent=GuiParent

local NF = Instance.new("Frame", NotifSG)
NF.AnchorPoint=Vector2.new(1,1); NF.Size=UDim2.new(0,200,0,30)
NF.Position=UDim2.new(1,-8,1,-10)
NF.BackgroundColor3=Color3.fromRGB(13,13,13)
NF.BackgroundTransparency=1; NF.BorderSizePixel=0; NF.ZIndex=200
Instance.new("UICorner",NF).CornerRadius=UDim.new(0,6)
local NFBar = Instance.new("Frame",NF)
NFBar.Size=UDim2.new(0,3,1,0); NFBar.BackgroundColor3=Color3.fromRGB(175,0,205)
NFBar.BackgroundTransparency=1; NFBar.BorderSizePixel=0; NFBar.ZIndex=201
Instance.new("UICorner",NFBar).CornerRadius=UDim.new(0,6)
local NFLbl = Instance.new("TextLabel",NF)
NFLbl.Size=UDim2.new(1,-13,1,0); NFLbl.Position=UDim2.new(0,10,0,0)
NFLbl.BackgroundTransparency=1; NFLbl.TextTransparency=1
NFLbl.TextScaled=true; NFLbl.Font=Enum.Font.GothamSemibold
NFLbl.TextColor3=Color3.fromRGB(220,220,220)
NFLbl.TextXAlignment=Enum.TextXAlignment.Left; NFLbl.ZIndex=201

local notifThr=nil
local function Notif(msg,accent,dur)
    if notifThr then task.cancel(notifThr) end
    NFBar.BackgroundColor3=accent or Color3.fromRGB(175,0,205); NFLbl.Text=msg
    tw(NF,{BackgroundTransparency=0},0.14); tw(NFBar,{BackgroundTransparency=0},0.14)
    tw(NFLbl,{TextTransparency=0},0.14)
    notifThr=task.delay(dur or 2,function()
        tw(NF,{BackgroundTransparency=1},0.14); tw(NFBar,{BackgroundTransparency=1},0.14)
        tw(NFLbl,{TextTransparency=1},0.14)
    end)
end

-- ============================================================
-- FLOATING ICON — top-right fixed, animated border
-- ============================================================
local IconSG = Instance.new("ScreenGui")
IconSG.Name="Ano9x_SBIcon"; IconSG.ResetOnSpawn=false
IconSG.DisplayOrder=9997; IconSG.Parent=GuiParent

local IconBtn = Instance.new("ImageButton",IconSG)
IconBtn.AnchorPoint=Vector2.new(1,0); IconBtn.Size=UDim2.new(0,46,0,46)
IconBtn.Position=UDim2.new(1,-10,0,10)
IconBtn.BackgroundColor3=Color3.fromRGB(12,12,12); IconBtn.BorderSizePixel=0
IconBtn.Image="rbxassetid://97269958324726"; IconBtn.ZIndex=100; IconBtn.Visible=false
Instance.new("UICorner",IconBtn).CornerRadius=UDim.new(0,10)
local IconStroke = Instance.new("UIStroke",IconBtn)
IconStroke.Color=Color3.fromRGB(255,255,255); IconStroke.Thickness=2.5

local iconConn=nil
local function startIconAnim()
    if iconConn then return end
    local t=0
    local W=Color3.fromRGB(255,255,255); local P=Color3.fromRGB(180,0,220)
    iconConn=RunService.Heartbeat:Connect(function(dt)
        if not IconBtn.Visible then return end
        t=(t+dt)%6
        local col,thk=W,2.5
        if     t<2.0 then col=W
        elseif t<2.5 then col=(math.random(2)==1)and W or P; thk=math.random(100)<=20 and math.random(1,5) or 2.5
        elseif t<4.5 then col=P
        elseif t<5.0 then col=(math.random(2)==1)and P or W; thk=math.random(100)<=20 and math.random(1,5) or 2.5
        else               col=W
        end
        IconStroke.Color=col; IconStroke.Thickness=thk
    end)
end
local function stopIconAnim()
    sDis(iconConn); iconConn=nil
    IconStroke.Color=Color3.fromRGB(255,255,255); IconStroke.Thickness=2.5
end

-- ============================================================
-- MAIN GUI
-- ============================================================
local SG = Instance.new("ScreenGui")
SG.Name="Ano9x_SBMain"; SG.ResetOnSpawn=false; SG.DisplayOrder=9998; SG.Parent=GuiParent

local Main = Instance.new("Frame",SG)
Main.AnchorPoint=Vector2.new(0.5,0.5)
Main.Size=UDim2.new(0,GW,0,GH); Main.Position=UDim2.new(0.5,0,0.5,0)
Main.BackgroundColor3=Color3.fromRGB(10,10,10); Main.BackgroundTransparency=1
Main.BorderSizePixel=0; Main.ClipsDescendants=true; Main.ZIndex=2
Instance.new("UICorner",Main).CornerRadius=UDim.new(0,9)
local MStroke=Instance.new("UIStroke",Main)
MStroke.Color=Color3.fromRGB(255,255,255); MStroke.Thickness=1.2; MStroke.Transparency=1

task.defer(function()
    tw(Main,{BackgroundTransparency=0},0.24,Enum.EasingStyle.Quad)
    tw(MStroke,{Transparency=0},0.24,Enum.EasingStyle.Quad)
end)

-- Title bar
local TBar=Instance.new("Frame",Main)
TBar.Size=UDim2.new(1,0,0,TH); TBar.BackgroundColor3=Color3.fromRGB(15,15,15)
TBar.BorderSizePixel=0; TBar.ZIndex=10
local TLine=Instance.new("Frame",TBar)
TLine.Size=UDim2.new(1,0,0,1); TLine.Position=UDim2.new(0,0,1,-1)
TLine.BackgroundColor3=Color3.fromRGB(38,38,38); TLine.BorderSizePixel=0; TLine.ZIndex=11
local TTxt=Instance.new("TextLabel",TBar)
TTxt.Size=UDim2.new(1,-64,1,0); TTxt.Position=UDim2.new(0,10,0,0)
TTxt.BackgroundTransparency=1; TTxt.Text="Ano9x Skybox"
TTxt.TextColor3=Color3.fromRGB(235,235,235); TTxt.TextScaled=true
TTxt.Font=Enum.Font.GothamBold; TTxt.TextXAlignment=Enum.TextXAlignment.Left; TTxt.ZIndex=11

local MinBtn=Instance.new("TextButton",TBar)
MinBtn.Size=UDim2.new(0,24,0,24); MinBtn.Position=UDim2.new(1,-54,0.5,-12)
MinBtn.BackgroundColor3=Color3.fromRGB(35,35,35); MinBtn.BorderSizePixel=0
MinBtn.Text="-"; MinBtn.TextColor3=Color3.fromRGB(185,185,185)
MinBtn.TextScaled=true; MinBtn.Font=Enum.Font.GothamBold; MinBtn.ZIndex=12
Instance.new("UICorner",MinBtn).CornerRadius=UDim.new(0,5)
Instance.new("UIStroke",MinBtn).Color=Color3.fromRGB(55,55,55)

local CloseBtn=Instance.new("TextButton",TBar)
CloseBtn.Size=UDim2.new(0,24,0,24); CloseBtn.Position=UDim2.new(1,-26,0.5,-12)
CloseBtn.BackgroundColor3=Color3.fromRGB(168,28,28); CloseBtn.BorderSizePixel=0
CloseBtn.Text="x"; CloseBtn.TextColor3=Color3.fromRGB(255,255,255)
CloseBtn.TextScaled=true; CloseBtn.Font=Enum.Font.GothamBold; CloseBtn.ZIndex=12
Instance.new("UICorner",CloseBtn).CornerRadius=UDim.new(0,5)

-- Drag whole panel
do
    local active,ds,dp=false,nil,nil
    Main.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.Touch
        or i.UserInputType==Enum.UserInputType.MouseButton1 then
            active=true; ds=i.Position; dp=Main.Position
        end
    end)
    Main.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.Touch
        or i.UserInputType==Enum.UserInputType.MouseButton1 then active=false end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if not active then return end
        if i.UserInputType~=Enum.UserInputType.Touch
        and i.UserInputType~=Enum.UserInputType.MouseMovement then return end
        local d=i.Position-ds
        Main.Position=UDim2.new(dp.X.Scale,dp.X.Offset+d.X,dp.Y.Scale,dp.Y.Offset+d.Y)
    end)
end

-- Scroll
local SCH=GH-TH
local Scroll=Instance.new("ScrollingFrame",Main)
Scroll.Size=UDim2.new(1,0,0,SCH); Scroll.Position=UDim2.new(0,0,0,TH)
Scroll.BackgroundTransparency=1; Scroll.BorderSizePixel=0
Scroll.ScrollBarThickness=3; Scroll.ScrollBarImageColor3=Color3.fromRGB(85,0,115)
Scroll.ScrollingDirection=Enum.ScrollingDirection.Y
Scroll.CanvasSize=UDim2.new(0,0,0,1200); Scroll.ZIndex=3; Scroll.ClipsDescendants=true

-- ============================================================
-- BUILDERS
-- ============================================================
local curY=PD
local function adv(h) local y=curY; curY=curY+h+GP; return y end

local function Sep()
    local f=Instance.new("Frame",Scroll)
    f.Size=UDim2.new(0,IW,0,1); f.Position=UDim2.new(0,PD,0,adv(1))
    f.BackgroundColor3=Color3.fromRGB(36,36,36); f.BorderSizePixel=0; f.ZIndex=4
end
local function SecLabel(txt)
    local l=Instance.new("TextLabel",Scroll)
    l.Size=UDim2.new(0,IW,0,18); l.Position=UDim2.new(0,PD,0,adv(18))
    l.BackgroundTransparency=1; l.Text=txt
    l.TextColor3=Color3.fromRGB(165,0,195); l.TextScaled=true
    l.Font=Enum.Font.GothamBold; l.TextXAlignment=Enum.TextXAlignment.Left; l.ZIndex=4
end
local function BigBtn(txt,h,bg)
    local b=Instance.new("TextButton",Scroll)
    b.Size=UDim2.new(0,IW,0,h); b.Position=UDim2.new(0,PD,0,adv(h))
    b.BackgroundColor3=bg or Color3.fromRGB(112,0,142); b.BorderSizePixel=0
    b.Text=txt; b.TextColor3=Color3.fromRGB(255,255,255)
    b.TextScaled=true; b.Font=Enum.Font.GothamBold; b.ZIndex=4
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,7)
    return b
end
local function SecBtn(txt,h)
    local b=Instance.new("TextButton",Scroll)
    b.Size=UDim2.new(0,IW,0,h); b.Position=UDim2.new(0,PD,0,adv(h))
    b.BackgroundColor3=Color3.fromRGB(20,20,20); b.BorderSizePixel=0
    b.Text=txt; b.TextColor3=Color3.fromRGB(200,200,200)
    b.TextScaled=true; b.Font=Enum.Font.GothamSemibold; b.ZIndex=4
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,7)
    local s=Instance.new("UIStroke",b); s.Color=Color3.fromRGB(42,42,42); s.Thickness=1
    return b
end
local function ModeBtn(txt,h)
    local b=Instance.new("TextButton",Scroll)
    b.Size=UDim2.new(0,IW,0,h); b.Position=UDim2.new(0,PD,0,adv(h))
    b.BackgroundColor3=Color3.fromRGB(20,20,20); b.BorderSizePixel=0
    b.Text=txt; b.TextColor3=Color3.fromRGB(190,190,190)
    b.TextScaled=true; b.Font=Enum.Font.GothamSemibold; b.ZIndex=4
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,7)
    local s=Instance.new("UIStroke",b); s.Color=Color3.fromRGB(60,0,80); s.Thickness=1
    return b,s
end
local function Row2(t1,t2,h)
    local hw=math.floor((IW-GP)/2); local y=adv(h)
    local function mk(txt,xo)
        local b=Instance.new("TextButton",Scroll)
        b.Size=UDim2.new(0,hw,0,h); b.Position=UDim2.new(0,PD+xo,0,y)
        b.BackgroundColor3=Color3.fromRGB(20,20,20); b.BorderSizePixel=0
        b.Text=txt; b.TextColor3=Color3.fromRGB(190,190,190)
        b.TextScaled=true; b.Font=Enum.Font.GothamSemibold; b.ZIndex=4
        Instance.new("UICorner",b).CornerRadius=UDim.new(0,7)
        local s=Instance.new("UIStroke",b); s.Color=Color3.fromRGB(42,42,42); s.Thickness=1
        return b
    end
    return mk(t1,0),mk(t2,hw+GP)
end
local function InfoBox(txt,h)
    local y=adv(h)
    local f=Instance.new("Frame",Scroll)
    f.Size=UDim2.new(0,IW,0,h); f.Position=UDim2.new(0,PD,0,y)
    f.BackgroundColor3=Color3.fromRGB(14,14,14); f.BorderSizePixel=0; f.ZIndex=4
    Instance.new("UICorner",f).CornerRadius=UDim.new(0,6)
    Instance.new("UIStroke",f).Color=Color3.fromRGB(34,34,34)
    local l=Instance.new("TextLabel",f)
    l.Size=UDim2.new(1,-10,1,-6); l.Position=UDim2.new(0,5,0,3)
    l.BackgroundTransparency=1; l.Text=txt
    l.TextColor3=Color3.fromRGB(95,95,95); l.TextScaled=true
    l.Font=Enum.Font.Gotham; l.TextXAlignment=Enum.TextXAlignment.Left
    l.TextWrapped=true; l.ZIndex=5
end
local function NoteBox(txt,h)
    local y=adv(h)
    local f=Instance.new("Frame",Scroll)
    f.Size=UDim2.new(0,IW,0,h); f.Position=UDim2.new(0,PD,0,y)
    f.BackgroundColor3=Color3.fromRGB(30,0,40); f.BorderSizePixel=0; f.ZIndex=4
    Instance.new("UICorner",f).CornerRadius=UDim.new(0,6)
    local fs=Instance.new("UIStroke",f); fs.Color=Color3.fromRGB(120,0,150); fs.Thickness=1
    local l=Instance.new("TextLabel",f)
    l.Size=UDim2.new(1,-10,1,-6); l.Position=UDim2.new(0,5,0,3)
    l.BackgroundTransparency=1; l.Text=txt
    l.TextColor3=Color3.fromRGB(200,0,240); l.TextScaled=true
    l.Font=Enum.Font.GothamBold; l.TextXAlignment=Enum.TextXAlignment.Left
    l.TextWrapped=true; l.ZIndex=5
end

-- ============================================================
-- BUILD PANEL
-- ============================================================

-- NOTICE (highlighted note box at very top)
NoteBox("NOTE: Fly high above the map FIRST before pressing Activate!", 34)
Sep()

SecLabel("SKYBOX CONTROL")
local ActiveBtn = BigBtn("ACTIVATE ON", 44)
local StopBtn   = SecBtn("STOP",        30)
Sep()

SecLabel("SELECT MODE")
local SB1Btn,  SB1Stroke   = ModeBtn("Skybox 1",   40)
local FlickBtn,FlickStroke = ModeBtn("Flickering", 40)
local SB2Btn,  SB2Stroke   = ModeBtn("Skybox 2",   40)
Sep()

SecLabel("EXTRAS")
local Spin1Btn, UnzoomBtn = Row2("Spin 1  OFF", "Unzoom  OFF", 40)
local FlyBtn = SecBtn("Fly Script", 36)  -- ADDED: Fly Script button
Sep()

InfoBox(
[[NOTE: Use a Fly script and go HIGH above the map before activating any mode. The higher you are, the better the skybox covers the whole map.

HOW TO USE:
1. Fly up high above the map.
2. Select a mode: Skybox 1, Flickering, or Skybox 2.
3. Press ACTIVATE ON. Your character freezes automatically — analog/thumbstick is disabled, position locked. Camera stays free; swipe the right side of your screen to look around freely.
4. Press STOP to deactivate and unfreeze.

FOR SPIN + SKYBOX: Toggle Spin 1 ON first, then select your mode, then press Activate. Your character will rotate slowly while frozen — skybox spins with it.

MODE SKYBOX 1 — Clean static skybox. Stable full-sky coverage. Best overall mode. Pair with Unzoom to see the full effect from any angle.

MODE FLICKERING — Skybox with subtle animation loop. Creates a pulsing or flickering visual in the sky visible to all players nearby.

MODE SKYBOX 2 — Alternative skybox angle and lighter blend weight. Different visual coverage from Skybox 1. Great for variety.

SPIN 1 — Very slow rotation while frozen. Pairs well with any mode. Enable it before pressing Activate.

UNZOOM — Expands your camera to super wide FOV (115). Lets you see the full skybox spread across the sky. Drag the right side of your screen to look around. Your character will NOT move — only the camera rotates.

BEST COMBO: Fly high → Skybox 1 or Skybox 2 → Spin 1 ON → Activate → Unzoom ON → Look around and enjoy.]],
    555
)

curY=curY+PD
Scroll.CanvasSize=UDim2.new(0,0,0,curY)

-- ============================================================
-- MODE VISUALS
-- ============================================================
local MODE_ON_BG   = Color3.fromRGB(112,0,142)
local MODE_OFF_BG  = Color3.fromRGB(20,20,20)
local MODE_ON_TC   = Color3.fromRGB(255,255,255)
local MODE_OFF_TC  = Color3.fromRGB(190,190,190)
local MODE_ON_STR  = Color3.fromRGB(200,0,255)
local MODE_OFF_STR = Color3.fromRGB(60,0,80)

local modeButtons = {
    {btn=SB1Btn,   stroke=SB1Stroke,   key="Skybox1",    label="Skybox 1"},
    {btn=FlickBtn, stroke=FlickStroke, key="Flickering", label="Flickering"},
    {btn=SB2Btn,   stroke=SB2Stroke,   key="Skybox2",    label="Skybox 2"},
}

local function setModeVisuals(activeKey)
    for _,m in ipairs(modeButtons) do
        local on=(m.key==activeKey)
        m.btn.BackgroundColor3=on and MODE_ON_BG or MODE_OFF_BG
        m.btn.TextColor3      =on and MODE_ON_TC or MODE_OFF_TC
        m.stroke.Color        =on and MODE_ON_STR or MODE_OFF_STR
        m.stroke.Thickness    =on and 1.5 or 1
        m.btn.Text            =m.label .. (on and "  [Selected]" or "")
    end
end

local function applyMode(key)
    selectedMode=key
    local p=MODES[key]
    S.StopOnMove=p.StopOnMove; S.AllowInvis=p.AllowInvis
    S.TimePosition=p.TimePosition; S.Speed=p.Speed
    S.Weight=p.Weight; S.FadeIn=p.FadeIn; S.FadeOut=p.FadeOut
    setModeVisuals(key)
    Notif("Mode " .. key .. " selected.",Color3.fromRGB(140,0,175))
end

SB1Btn.MouseButton1Click:Connect(function()   applyMode("Skybox1")    end)
FlickBtn.MouseButton1Click:Connect(function()  applyMode("Flickering") end)
SB2Btn.MouseButton1Click:Connect(function()   applyMode("Skybox2")    end)

-- ============================================================
-- ACTIVATE / STOP
-- ============================================================
ActiveBtn.MouseButton1Click:Connect(function()
    if not selectedMode then
        Notif("Select a mode first!",Color3.fromRGB(195,50,50)); return
    end
    Notif("Activating " .. selectedMode .. "...",Color3.fromRGB(148,0,185))
    task.spawn(function()
        local ok,err=doPlay()
        if ok then
            ActiveBtn.BackgroundColor3=Color3.fromRGB(172,0,202)
            ActiveBtn.Text="ACTIVATED  [" .. selectedMode .. "]"
            Notif("Skybox active! Frozen — camera free.",Color3.fromRGB(168,0,208))
        else
            Notif("Error: " .. tostring(err),Color3.fromRGB(195,50,50))
        end
    end)
end)

StopBtn.MouseButton1Click:Connect(function()
    if isActive or CurrentTrack then
        doStop()
        ActiveBtn.BackgroundColor3=Color3.fromRGB(112,0,142)
        ActiveBtn.Text="ACTIVATE ON"
        Notif("Skybox stopped. Character unfrozen.",Color3.fromRGB(48,182,92))
    else
        Notif("Not active.",Color3.fromRGB(82,82,82))
    end
end)

-- ============================================================
-- EXTRAS
-- ============================================================
local EXTRA_ON_BG  = Color3.fromRGB(90,0,115)
local EXTRA_OFF_BG = Color3.fromRGB(20,20,20)
local EXTRA_ON_TC  = Color3.fromRGB(255,255,255)
local EXTRA_OFF_TC = Color3.fromRGB(190,190,190)

-- Spin 1 (slow)
Spin1Btn.MouseButton1Click:Connect(function()
    spinOn=not spinOn
    Spin1Btn.BackgroundColor3=spinOn and EXTRA_ON_BG or EXTRA_OFF_BG
    Spin1Btn.TextColor3=spinOn and EXTRA_ON_TC or EXTRA_OFF_TC
    Spin1Btn.Text=spinOn and "Spin 1  ON" or "Spin 1  OFF"
    Notif(spinOn and "Spin 1 enabled — activate to apply." or "Spin 1 disabled.",
          spinOn and Color3.fromRGB(148,0,185) or Color3.fromRGB(82,82,82))
end)

-- Unzoom
UnzoomBtn.MouseButton1Click:Connect(function()
    unzoomOn=not unzoomOn
    UnzoomBtn.BackgroundColor3=unzoomOn and EXTRA_ON_BG or EXTRA_OFF_BG
    UnzoomBtn.TextColor3=unzoomOn and EXTRA_ON_TC or EXTRA_OFF_TC
    UnzoomBtn.Text=unzoomOn and "Unzoom  ON" or "Unzoom  OFF"
    local cam=workspace.CurrentCamera
    if cam then
        pcall(function() cam.FieldOfView=unzoomOn and WIDE_FOV or DEFAULT_FOV end)
    end
    Notif(unzoomOn and "Unzoom ON — wide view!" or "Unzoom OFF — normal view.",
          unzoomOn and Color3.fromRGB(68,135,205) or Color3.fromRGB(82,82,82))
end)

-- Fly Script (ADDED)
FlyBtn.MouseButton1Click:Connect(function()
    Notif("Loading fly script...", Color3.fromRGB(148,0,185))
    task.spawn(function()
        local ok, err = pcall(function()
            loadstring(game:HttpGet("https://pastebin.com/raw/ZrRwsPAe"))()
        end)
        if not ok then
            Notif("Fly failed: " .. tostring(err), Color3.fromRGB(195,50,50))
        else
            Notif("Fly script executed.", Color3.fromRGB(48,182,92))
        end
    end)
end)

-- ============================================================
-- MINIMIZE <-> ICON
-- ============================================================
local minimized=false
local function showMain()
    minimized=false; Main.Visible=true
    tw(Main,{BackgroundTransparency=0},0.2); tw(MStroke,{Transparency=0},0.2)
    IconBtn.Visible=false; stopIconAnim(); MinBtn.Text="-"
end
local function showIcon()
    minimized=true
    tw(Main,{BackgroundTransparency=1},0.16); tw(MStroke,{Transparency=1},0.16)
    task.delay(0.18,function()
        Main.Visible=false; IconBtn.Visible=true; startIconAnim()
    end)
    MinBtn.Text="+"
end
MinBtn.MouseButton1Click:Connect(function()
    if minimized then showMain() else showIcon() end
end)
IconBtn.MouseButton1Click:Connect(showMain)

CloseBtn.MouseButton1Click:Connect(function()
    doStop(); stopIconAnim()
    if unzoomOn then
        pcall(function()
            local cam=workspace.CurrentCamera
            if cam then cam.FieldOfView=DEFAULT_FOV end
        end)
    end
    tw(Main,{BackgroundTransparency=1},0.16); tw(MStroke,{Transparency=1},0.16)
    task.delay(0.2,function() sDes(SG); sDes(NotifSG); sDes(IconSG) end)
end)

-- ============================================================
-- CHARACTER RESPAWN
-- ============================================================
LP.CharacterAdded:Connect(function()
    task.wait(1.5)
    CurrentTrack=nil; isActive=false; origCollide={}
    freezeConn=nil; frozenPos=nil; spinAngle=0
    ActiveBtn.BackgroundColor3=Color3.fromRGB(112,0,142)
    ActiveBtn.Text="ACTIVATE ON"
end)

-- ============================================================
-- INIT
-- ============================================================
task.wait(0.4)
Notif("Ano9x Skybox loaded.",Color3.fromRGB(148,0,188))
print("[Ano9x SB] Loaded. Canvas: "..curY.."px")
