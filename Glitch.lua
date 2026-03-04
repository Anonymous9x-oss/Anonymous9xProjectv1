--[[
    Anonymous9x Glitch
    Delta Mobile / Delta iOS — Sky Destroyer Edition
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
local function isR15()   local h=getHum(); return h and h.RigType==Enum.HumanoidRigType.R15 end

local GuiParent
do
    local ok,h = pcall(function() return gethui() end)
    GuiParent = (ok and h) or LP:WaitForChild("PlayerGui",15)
end
for _,v in pairs(GuiParent:GetChildren()) do
    if v.Name=="Anon9x_Main" or v.Name=="Anon9x_Notif" or v.Name=="Anon9x_Icon" then v:Destroy() end
end

-- ============================================================
-- STATE
-- ============================================================
local GlitchActive = false
local GlitchSpeed  = 85
local GlitchConns  = {}
local HandleData   = {}

local GravOn,FreezeOn,JumpOn,AfkOn = false,false,false,false
local FreezeConn,AfkConn = nil,nil
local SavedCF = nil
local DEF_JP,HACK_JP = 50,100

local function sDes(o) if o and o.Parent then pcall(function() o:Destroy() end) end end
local function sDis(c) if c then pcall(function() c:Disconnect() end) end end
local function tw(obj,props,t,sty,dir)
    TweenService:Create(obj,TweenInfo.new(t or 0.18,sty or Enum.EasingStyle.Quad,dir or Enum.EasingDirection.Out),props):Play()
end

-- ============================================================
-- LAYOUT
-- ============================================================
local GW,GH,TH = 258,210,38
local PD,IW,GP  = 9, 258-18, 5

-- ============================================================
-- NOTIFICATION — bottom-right, fade, 2 sec
-- ============================================================
local NotifSG = Instance.new("ScreenGui")
NotifSG.Name="Anon9x_Notif"; NotifSG.ResetOnSpawn=false; NotifSG.DisplayOrder=9999
NotifSG.Parent=GuiParent

local NF=Instance.new("Frame",NotifSG)
NF.AnchorPoint=Vector2.new(1,1); NF.Size=UDim2.new(0,195,0,30)
NF.Position=UDim2.new(1,-8,1,-10); NF.BackgroundColor3=Color3.fromRGB(13,13,13)
NF.BackgroundTransparency=1; NF.BorderSizePixel=0; NF.ZIndex=200
Instance.new("UICorner",NF).CornerRadius=UDim.new(0,6)

local NFBar=Instance.new("Frame",NF)
NFBar.Size=UDim2.new(0,3,1,0); NFBar.BackgroundColor3=Color3.fromRGB(175,0,205)
NFBar.BackgroundTransparency=1; NFBar.BorderSizePixel=0; NFBar.ZIndex=201
Instance.new("UICorner",NFBar).CornerRadius=UDim.new(0,6)

local NFLbl=Instance.new("TextLabel",NF)
NFLbl.Size=UDim2.new(1,-13,1,0); NFLbl.Position=UDim2.new(0,10,0,0)
NFLbl.BackgroundTransparency=1; NFLbl.Text=""; NFLbl.TextColor3=Color3.fromRGB(220,220,220)
NFLbl.TextTransparency=1; NFLbl.TextScaled=true; NFLbl.Font=Enum.Font.GothamSemibold
NFLbl.TextXAlignment=Enum.TextXAlignment.Left; NFLbl.ZIndex=201

local notifThr=nil
local function Notif(msg,accent,dur)
    if notifThr then task.cancel(notifThr) end
    NFBar.BackgroundColor3=accent or Color3.fromRGB(175,0,205)
    NFLbl.Text=msg
    tw(NF,   {BackgroundTransparency=0},0.14)
    tw(NFBar,{BackgroundTransparency=0},0.14)
    tw(NFLbl,{TextTransparency=0},      0.14)
    notifThr=task.delay(dur or 2,function()
        tw(NF,   {BackgroundTransparency=1},0.14)
        tw(NFBar,{BackgroundTransparency=1},0.14)
        tw(NFLbl,{TextTransparency=1},      0.14)
    end)
end

-- ============================================================
-- FLOATING ICON (top-right, fixed, shows when minimized)
-- ============================================================
local IconSG=Instance.new("ScreenGui")
IconSG.Name="Anon9x_Icon"; IconSG.ResetOnSpawn=false; IconSG.DisplayOrder=9997
IconSG.Parent=GuiParent

local IconBtn=Instance.new("ImageButton",IconSG)
IconBtn.AnchorPoint=Vector2.new(1,0)
IconBtn.Size=UDim2.new(0,46,0,46)
IconBtn.Position=UDim2.new(1,-10,0,10)
IconBtn.BackgroundColor3=Color3.fromRGB(12,12,12)
IconBtn.BorderSizePixel=0
IconBtn.Image="rbxassetid://97269958324726"
IconBtn.ZIndex=100
IconBtn.Visible=false
Instance.new("UICorner",IconBtn).CornerRadius=UDim.new(0,10)

-- Animated glitch border on icon
local IconStroke=Instance.new("UIStroke",IconBtn)
IconStroke.Color=Color3.fromRGB(255,255,255)
IconStroke.Thickness=2.5
IconStroke.Transparency=0

-- Animate the icon border: pulse between white and purple + glitch flicker
local iconAnimConn=nil
local function startIconAnim()
    if iconAnimConn then return end
    local t=0
    -- Cycle: 2s full white → fast glitch flicker to purple → 2s full purple → fast glitch back to white
    -- Period = 6s total
    local PERIOD    = 6
    local WHITE     = Color3.fromRGB(255,255,255)
    local PURPLE    = Color3.fromRGB(180,0,220)
    local GLITCH_DUR = 0.5  -- transition zone length in seconds

    iconAnimConn=RunService.Heartbeat:Connect(function(dt)
        if not IconBtn.Visible then return end
        t = (t + dt) % PERIOD

        -- Phase map within one period:
        -- 0.0 - 2.0  → full white
        -- 2.0 - 2.5  → glitch flicker white→purple
        -- 2.5 - 4.5  → full purple
        -- 4.5 - 5.0  → glitch flicker purple→white
        -- 5.0 - 6.0  → full white

        local color
        local thickness = 2.5

        if t < 2.0 then
            -- steady white
            color = WHITE
        elseif t < 2.0 + GLITCH_DUR then
            -- glitch transition: rapid flicker between white and purple
            color = (math.random(2)==1) and WHITE or PURPLE
            thickness = math.random(100)<=20 and math.random(1,5) or 2.5
        elseif t < 4.5 then
            -- steady purple
            color = PURPLE
        elseif t < 4.5 + GLITCH_DUR then
            -- glitch transition: rapid flicker purple back to white
            color = (math.random(2)==1) and PURPLE or WHITE
            thickness = math.random(100)<=20 and math.random(1,5) or 2.5
        else
            -- steady white again
            color = WHITE
        end

        IconStroke.Color     = color
        IconStroke.Thickness = thickness
    end)
end
local function stopIconAnim()
    sDis(iconAnimConn); iconAnimConn=nil
    IconStroke.Color=Color3.fromRGB(255,255,255); IconStroke.Thickness=2.5
end

-- ============================================================
-- MAIN GUI
-- ============================================================
local SG=Instance.new("ScreenGui")
SG.Name="Anon9x_Main"; SG.ResetOnSpawn=false; SG.DisplayOrder=9998; SG.Parent=GuiParent

local Main=Instance.new("Frame",SG)
Main.AnchorPoint=Vector2.new(0.5,0.5)
Main.Size=UDim2.new(0,GW,0,GH)
Main.Position=UDim2.new(0.5,0,0.5,0)
Main.BackgroundColor3=Color3.fromRGB(10,10,10)
Main.BackgroundTransparency=1
Main.BorderSizePixel=0
Main.ClipsDescendants=true
Main.ZIndex=2
Instance.new("UICorner",Main).CornerRadius=UDim.new(0,9)
local MStroke=Instance.new("UIStroke",Main)
MStroke.Color=Color3.fromRGB(255,255,255); MStroke.Thickness=1.2; MStroke.Transparency=1

task.defer(function()
    tw(Main,   {BackgroundTransparency=0},0.24,Enum.EasingStyle.Quad)
    tw(MStroke,{Transparency=0},          0.24,Enum.EasingStyle.Quad)
end)

-- ── TITLE BAR
local TBar=Instance.new("Frame",Main)
TBar.Size=UDim2.new(1,0,0,TH); TBar.BackgroundColor3=Color3.fromRGB(15,15,15)
TBar.BorderSizePixel=0; TBar.ZIndex=10

local TLine=Instance.new("Frame",TBar)
TLine.Size=UDim2.new(1,0,0,1); TLine.Position=UDim2.new(0,0,1,-1)
TLine.BackgroundColor3=Color3.fromRGB(38,38,38); TLine.BorderSizePixel=0; TLine.ZIndex=11

local TTxt=Instance.new("TextLabel",TBar)
TTxt.Size=UDim2.new(1,-64,1,0); TTxt.Position=UDim2.new(0,10,0,0)
TTxt.BackgroundTransparency=1; TTxt.Text="Anonymous9x Glitch"
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

-- ── DRAG — whole Main frame (non-scroll areas naturally)
do
    local active,ds,dp=false,nil,nil
    -- attach to Main so any tap on the dark frame area drags
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

-- ── SCROLL
local SCH=GH-TH
local Scroll=Instance.new("ScrollingFrame",Main)
Scroll.Size=UDim2.new(1,0,0,SCH); Scroll.Position=UDim2.new(0,0,0,TH)
Scroll.BackgroundTransparency=1; Scroll.BorderSizePixel=0
Scroll.ScrollBarThickness=3; Scroll.ScrollBarImageColor3=Color3.fromRGB(85,0,115)
Scroll.ScrollingDirection=Enum.ScrollingDirection.Y
Scroll.CanvasSize=UDim2.new(0,0,0,800)
Scroll.ZIndex=3; Scroll.ClipsDescendants=true

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

local function SecLbl(txt)
    local l=Instance.new("TextLabel",Scroll)
    l.Size=UDim2.new(0,IW,0,19); l.Position=UDim2.new(0,PD,0,adv(19))
    l.BackgroundTransparency=1; l.Text=txt
    l.TextColor3=Color3.fromRGB(165,0,195); l.TextScaled=true
    l.Font=Enum.Font.GothamBold; l.TextXAlignment=Enum.TextXAlignment.Left; l.ZIndex=4
end

local function StatusBar()
    local f=Instance.new("Frame",Scroll)
    f.Size=UDim2.new(0,IW,0,25); f.Position=UDim2.new(0,PD,0,adv(25))
    f.BackgroundColor3=Color3.fromRGB(17,17,17); f.BorderSizePixel=0; f.ZIndex=4
    Instance.new("UICorner",f).CornerRadius=UDim.new(0,5)
    Instance.new("UIStroke",f).Color=Color3.fromRGB(38,38,38)
    local l=Instance.new("TextLabel",f)
    l.Size=UDim2.new(1,-10,1,0); l.Position=UDim2.new(0,5,0,0)
    l.BackgroundTransparency=1; l.Text="Status: Ready  |  Rig: Checking..."
    l.TextColor3=Color3.fromRGB(190,190,190); l.TextScaled=true
    l.Font=Enum.Font.GothamSemibold; l.TextXAlignment=Enum.TextXAlignment.Left; l.ZIndex=5
    return l
end

local function PBtn(txt,h,bg)
    local b=Instance.new("TextButton",Scroll)
    b.Size=UDim2.new(0,IW,0,h); b.Position=UDim2.new(0,PD,0,adv(h))
    b.BackgroundColor3=bg or Color3.fromRGB(112,0,142); b.BorderSizePixel=0
    b.Text=txt; b.TextColor3=Color3.fromRGB(255,255,255)
    b.TextScaled=true; b.Font=Enum.Font.GothamBold; b.ZIndex=4
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,7)
    return b
end

local function SBtn(txt,h)
    local b=Instance.new("TextButton",Scroll)
    b.Size=UDim2.new(0,IW,0,h); b.Position=UDim2.new(0,PD,0,adv(h))
    b.BackgroundColor3=Color3.fromRGB(20,20,20); b.BorderSizePixel=0
    b.Text=txt; b.TextColor3=Color3.fromRGB(200,200,200)
    b.TextScaled=true; b.Font=Enum.Font.GothamSemibold; b.ZIndex=4
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,7)
    local s=Instance.new("UIStroke",b); s.Color=Color3.fromRGB(42,42,42); s.Thickness=1
    return b
end

local function Row2(t1,t2,h)
    local H2=math.floor((IW-GP)/2); local y=adv(h)
    local function mk(txt,xo)
        local b=Instance.new("TextButton",Scroll)
        b.Size=UDim2.new(0,H2,0,h); b.Position=UDim2.new(0,PD+xo,0,y)
        b.BackgroundColor3=Color3.fromRGB(20,20,20); b.BorderSizePixel=0
        b.Text=txt; b.TextColor3=Color3.fromRGB(190,190,190)
        b.TextScaled=true; b.Font=Enum.Font.GothamSemibold; b.ZIndex=4
        Instance.new("UICorner",b).CornerRadius=UDim.new(0,7)
        local s=Instance.new("UIStroke",b); s.Color=Color3.fromRGB(42,42,42); s.Thickness=1
        return b
    end
    return mk(t1,0), mk(t2,H2+GP)
end

local function MkSlider(lbl,def,mn,mx)
    local ly=adv(17)
    local le=Instance.new("TextLabel",Scroll)
    le.Size=UDim2.new(0,IW,0,17); le.Position=UDim2.new(0,PD,0,ly)
    le.BackgroundTransparency=1; le.Text=lbl..": "..def
    le.TextColor3=Color3.fromRGB(165,165,165); le.TextScaled=true
    le.Font=Enum.Font.GothamSemibold; le.TextXAlignment=Enum.TextXAlignment.Left; le.ZIndex=4
    local ty=adv(14)
    local tr=Instance.new("Frame",Scroll)
    tr.Size=UDim2.new(0,IW,0,14); tr.Position=UDim2.new(0,PD,0,ty)
    tr.BackgroundColor3=Color3.fromRGB(26,26,26); tr.BorderSizePixel=0; tr.ZIndex=4
    Instance.new("UICorner",tr).CornerRadius=UDim.new(1,0)
    local iR=(def-mn)/(mx-mn)
    local fi=Instance.new("Frame",tr)
    fi.Size=UDim2.new(iR,0,1,0); fi.BackgroundColor3=Color3.fromRGB(140,0,170)
    fi.BorderSizePixel=0; fi.ZIndex=5
    Instance.new("UICorner",fi).CornerRadius=UDim.new(1,0)
    local kn=Instance.new("TextButton",tr)
    kn.Size=UDim2.new(0,18,0,18); kn.Position=UDim2.new(iR,-9,0.5,-9)
    kn.BackgroundColor3=Color3.fromRGB(228,228,228); kn.BorderSizePixel=0
    kn.Text=""; kn.ZIndex=6
    Instance.new("UICorner",kn).CornerRadius=UDim.new(1,0)
    local curV=def; local active=false; local cb=nil
    local function apply(r)
        r=math.clamp(r,0,1); curV=math.floor(mn+r*(mx-mn))
        fi.Size=UDim2.new(r,0,1,0); kn.Position=UDim2.new(r,-9,0.5,-9)
        le.Text=lbl..": "..curV; if cb then cb(curV) end
    end
    local function dn(i)
        if i.UserInputType==Enum.UserInputType.Touch
        or i.UserInputType==Enum.UserInputType.MouseButton1 then active=true end
    end
    local function up(i)
        if i.UserInputType==Enum.UserInputType.Touch
        or i.UserInputType==Enum.UserInputType.MouseButton1 then active=false end
    end
    tr.InputBegan:Connect(dn); kn.InputBegan:Connect(dn)
    UserInputService.InputEnded:Connect(up)
    UserInputService.InputChanged:Connect(function(i)
        if not active then return end
        if i.UserInputType~=Enum.UserInputType.Touch
        and i.UserInputType~=Enum.UserInputType.MouseMovement then return end
        local ax=tr.AbsolutePosition.X; local aw=tr.AbsoluteSize.X
        if aw<=0 then return end; apply((i.Position.X-ax)/aw)
    end)
    return {get=function() return curV end, onChange=function(f) cb=f end}
end

local function InputPair(ph,btxt,h)
    local H2=math.floor(IW*0.60); local H2b=IW-H2-GP; local y=adv(h)
    local bx=Instance.new("TextBox",Scroll)
    bx.Size=UDim2.new(0,H2,0,h); bx.Position=UDim2.new(0,PD,0,y)
    bx.BackgroundColor3=Color3.fromRGB(18,18,18); bx.BorderSizePixel=0
    bx.PlaceholderText=ph; bx.PlaceholderColor3=Color3.fromRGB(72,72,72)
    bx.Text=""; bx.TextColor3=Color3.fromRGB(205,205,205)
    bx.TextScaled=true; bx.Font=Enum.Font.GothamSemibold
    bx.ClearTextOnFocus=false; bx.ZIndex=4
    Instance.new("UICorner",bx).CornerRadius=UDim.new(0,7)
    local bs=Instance.new("UIStroke",bx); bs.Color=Color3.fromRGB(42,42,42); bs.Thickness=1
    local bn=Instance.new("TextButton",Scroll)
    bn.Size=UDim2.new(0,H2b,0,h); bn.Position=UDim2.new(0,PD+H2+GP,0,y)
    bn.BackgroundColor3=Color3.fromRGB(0,88,135); bn.BorderSizePixel=0
    bn.Text=btxt; bn.TextColor3=Color3.fromRGB(255,255,255)
    bn.TextScaled=true; bn.Font=Enum.Font.GothamBold; bn.ZIndex=4
    Instance.new("UICorner",bn).CornerRadius=UDim.new(0,7)
    return bx,bn
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

-- ============================================================
-- BUILD ELEMENTS
-- ============================================================
local StatusLbl=StatusBar()
Sep()
SecLbl("AVATAR GLITCH")
local BrokenBtn=PBtn("BROKEN",42)
local StopBtn  =SBtn("STOP",32)
local SpSl     =MkSlider("Speed",GlitchSpeed,1,200)
SpSl.onChange(function(v) GlitchSpeed=v end)
Sep()
SecLbl("EXTRA FEATURES")
local GravBtn,  FreezeBtn=Row2("Anti Gravity  OFF","Freeze  OFF",40)
local JumpBtn,  AfkBtn   =Row2("High Jump  OFF","Anti AFK  OFF",40)
Sep()
SecLbl("TOOLS")
local ResetBtn, TpBtn =Row2("Reset","TP Up",34)
local SaveBtn,  LoadBtn=Row2("Save Position","Load Position",34)
local HatBox,   WearBtn=InputPair("Accessory Asset ID","Wear",32)
Sep()
InfoBox("Anonymous9x Glitch  |  Delta Mobile & Delta iOS\nFE Sky Destroyer — visible to all players\nRequires R15 avatar — R6 will not work",52)
curY=curY+PD
Scroll.CanvasSize=UDim2.new(0,0,0,curY)

-- ============================================================
-- REAL-TIME RIG STATUS
-- ============================================================
local lastRig=""
RunService.Heartbeat:Connect(function()
    local h=getHum()
    local rig=(h and h.RigType==Enum.HumanoidRigType.R15) and "R15" or "R6"
    if rig==lastRig then return end; lastRig=rig
    if rig=="R15" then
        StatusLbl.Text="Status: Ready  |  Rig: R15 — Glitch works"
        StatusLbl.TextColor3=Color3.fromRGB(65,200,105)
    else
        StatusLbl.Text="Status: Ready  |  Rig: R6 — Glitch disabled"
        StatusLbl.TextColor3=Color3.fromRGB(205,65,65)
    end
end)

-- ============================================================
-- SKY DESTROYER — SPINNING BLINKING LASER ENGINE
-- ─────────────────────────────────────────────────────────────
-- Each accessory Handle is freed from its weld.
-- Every Heartbeat:
--   • Handles fan out at evenly-spaced angles around player
--   • The entire fan rotates over time (spin)
--   • Each beam also adds independent turbulence offset
--   • Beam Y-size = reach (300–3300 studs) = laser length
--   • Blink: alternate between full reach and near-zero each
--     few frames → flicker effect visible to all players
--   • Thickness pulses rapidly for blinding laser look
-- ─────────────────────────────────────────────────────────────
-- ============================================================
local function collectHandles()
    HandleData={}
    local c=getChar(); if not c then return end
    for _,acc in pairs(c:GetChildren()) do
        if acc:IsA("Accessory") then
            local h=acc:FindFirstChild("Handle")
            if h then
                local origCF=h.CFrame; local origSz=h.Size
                for _,w in pairs(h:GetChildren()) do
                    if w:IsA("Weld") or w:IsA("WeldConstraint") or w:IsA("Motor6D") then
                        pcall(function() w.Enabled=false end)
                    end
                end
                table.insert(HandleData,{handle=h,origCF=origCF,origSize=origSz})
            end
        end
    end
end

local function restoreHandles()
    for _,d in pairs(HandleData) do
        pcall(function()
            for _,w in pairs(d.handle:GetChildren()) do
                if w:IsA("Weld") or w:IsA("WeldConstraint") or w:IsA("Motor6D") then
                    pcall(function() w.Enabled=true end)
                end
            end
            d.handle.Size=d.origSize
            d.handle.CFrame=d.origCF
        end)
    end
    HandleData={}
end

local function stopGlitch(silent)
    GlitchActive=false
    for _,c in pairs(GlitchConns) do sDis(c) end
    GlitchConns={}
    task.wait(0.05)
    restoreHandles()
    local hum=getHum()
    if hum then pcall(function() hum.PlatformStand=false end) end
    BrokenBtn.BackgroundColor3=Color3.fromRGB(112,0,142)
    BrokenBtn.Text="BROKEN"
    if not silent then Notif("Glitch stopped. Avatar restored.",Color3.fromRGB(48,182,92)) end
end

local function startGlitch()
    if GlitchActive then return end
    if not isR15() then Notif("R6 detected. Switch to R15.",Color3.fromRGB(205,85,0)); return end
    local hrp=getHRP(); if not hrp then return end
    local c=getChar(); if not c then return end
    local accCount=0
    for _,a in pairs(c:GetChildren()) do if a:IsA("Accessory") then accCount+=1 end end
    if accCount==0 then
        Notif("No accessories found. Wear a glitch hat first.",Color3.fromRGB(205,85,0)); return
    end
    GlitchActive=true
    collectHandles()
    BrokenBtn.BackgroundColor3=Color3.fromRGB(172,0,202)
    BrokenBtn.Text="BROKEN — ACTIVE"

    -- ── LASER LOOP ───────────────────────────────────────────
    local blinkState = true
    local blinkTimer = 0

    local laserConn=RunService.Heartbeat:Connect(function(dt)
        if not GlitchActive then return end
        local hrp2=getHRP(); if not hrp2 then return end
        local sp   = GlitchSpeed
        local t    = tick()
        local n    = #HandleData
        if n==0 then return end

        -- blink timing: faster at higher speeds
        blinkTimer = blinkTimer + dt * (sp * 0.08 + 4)
        if blinkTimer >= 1 then
            blinkState = not blinkState
            blinkTimer = 0
        end

        local reach = 280 + sp * 14  -- 280–3080 studs

        for i,d in ipairs(HandleData) do
            if d.handle and d.handle.Parent then
                -- Base fan angle: spread beams evenly around 360°
                local fanAngle = (2*math.pi/n)*(i-1)

                -- Continuous spin: whole fan rotates over time
                local spin = t * (sp/80 + 0.4)

                -- Per-beam turbulence: each beam wiggles independently
                local turbH = math.sin(t * (sp*0.06+1.5) + i*2.1) * math.pi * 0.55
                local turbV = math.cos(t * (sp*0.05+1.2) + i*1.7) * 0.35

                -- Final horizontal angle = fan + spin + turbulence
                local yaw   = fanAngle + spin + turbH

                -- Elevation: beams sweep between near-horizontal and near-vertical
                local baseElev = math.pi * 0.30
                local elevWave = math.sin(t*(sp*0.03+0.8) + i*1.3) * 0.40
                local pitch    = baseElev + elevWave + turbV

                -- Beam midpoint CFrame
                local beamCF = hrp2.CFrame
                    * CFrame.Angles(0, yaw, 0)
                    * CFrame.Angles(pitch, 0, 0)
                    * CFrame.new(0, reach*0.5, 0)

                -- Thickness: rapid pulse for blinding effect
                local thickBase  = 0.35 + (sp/160)
                local thickPulse = math.abs(math.sin(t*(sp*0.15+3) + i*0.9)) * (sp/100)
                local thick      = thickBase + thickPulse

                -- Blink: alternate between full and collapsed to simulate flash
                local blinkedReach = blinkState and reach or (reach * 0.08)

                pcall(function()
                    d.handle.Size  = Vector3.new(thick, blinkedReach, thick)
                    d.handle.CFrame = beamCF
                end)
            end
        end
    end)

    local standConn=RunService.Heartbeat:Connect(function()
        if not GlitchActive then return end
        local hum2=getHum()
        if hum2 then pcall(function() hum2.PlatformStand=true end) end
    end)

    GlitchConns={laserConn,standConn}
    Notif("Sky Destroyer active. Speed: "..GlitchSpeed,Color3.fromRGB(168,0,208))
end

-- ============================================================
-- WEAR ACCESSORY — dual method (GetObjects + InsertService)
-- ============================================================
local function wearAccessory(id)
    local c=getChar(); if not c then Notif("Character not found.",Color3.fromRGB(195,50,50)); return end
    Notif("Loading accessory "..id.."...",Color3.fromRGB(68,112,188))
    task.spawn(function()
        -- METHOD 1: game:GetObjects (does not require InsertService permission)
        local ok1,res=pcall(function()
            local objs=game:GetObjects("rbxassetid://"..id)
            for _,obj in pairs(objs) do
                if obj:IsA("Accessory") or obj:IsA("Hat") then
                    obj.Parent=c
                    return true
                end
            end
            return false
        end)
        if ok1 and res then
            Notif("Accessory "..id.." equipped.",Color3.fromRGB(48,182,92)); return
        end
        -- METHOD 2: InsertService fallback
        local ok2=pcall(function()
            local IS=game:GetService("InsertService")
            local mdl=IS:LoadAsset(id)
            local acc=mdl:FindFirstChildOfClass("Accessory") or mdl:FindFirstChildOfClass("Hat")
            if acc then acc.Parent=c; mdl:Destroy()
            else mdl:Destroy(); error("not acc") end
        end)
        if ok2 then
            Notif("Accessory "..id.." equipped.",Color3.fromRGB(48,182,92)); return
        end
        -- Both failed
        Notif("Could not load ID "..id..". Try another game.",Color3.fromRGB(195,50,50))
    end)
end

-- ============================================================
-- TOGGLE HELPER
-- ============================================================
local ON_BG=Color3.fromRGB(98,0,128); local OFF_BG=Color3.fromRGB(20,20,20)
local function tog(btn,state,on,off)
    btn.BackgroundColor3=state and ON_BG or OFF_BG
    btn.TextColor3=state and Color3.fromRGB(255,255,255) or Color3.fromRGB(190,190,190)
    btn.Text=state and on or off
end

-- ============================================================
-- BUTTON EVENTS
-- ============================================================
BrokenBtn.MouseButton1Click:Connect(function()
    if GlitchActive then Notif("Press STOP to deactivate.",Color3.fromRGB(188,115,0))
    else startGlitch() end
end)
StopBtn.MouseButton1Click:Connect(function()
    if GlitchActive then stopGlitch(false)
    else Notif("Glitch is not active.",Color3.fromRGB(82,82,82)) end
end)
GravBtn.MouseButton1Click:Connect(function()
    GravOn=not GravOn
    pcall(function() workspace.Gravity=GravOn and 8 or 196.2 end)
    tog(GravBtn,GravOn,"Anti Gravity  ON","Anti Gravity  OFF")
    Notif(GravOn and "Anti Gravity enabled." or "Gravity restored.",
          GravOn and Color3.fromRGB(148,0,185) or Color3.fromRGB(82,82,82))
end)
FreezeBtn.MouseButton1Click:Connect(function()
    FreezeOn=not FreezeOn
    if FreezeOn then
        local hrp=getHRP()
        if hrp then
            local frz=hrp.CFrame
            FreezeConn=RunService.Heartbeat:Connect(function()
                if not FreezeOn then return end
                local h2=getHRP()
                if h2 then pcall(function() h2.CFrame=frz end) end
            end)
        end
        Notif("Freeze enabled. Position locked.",Color3.fromRGB(148,0,185))
    else
        sDis(FreezeConn)
        Notif("Freeze disabled.",Color3.fromRGB(82,82,82))
    end
    tog(FreezeBtn,FreezeOn,"Freeze  ON","Freeze  OFF")
end)
JumpBtn.MouseButton1Click:Connect(function()
    JumpOn=not JumpOn
    local hum=getHum()
    if hum then pcall(function() hum.JumpPower=JumpOn and HACK_JP or DEF_JP end) end
    tog(JumpBtn,JumpOn,"High Jump  ON","High Jump  OFF")
    Notif(JumpOn and "High Jump enabled." or "Jump restored.",
          JumpOn and Color3.fromRGB(148,0,185) or Color3.fromRGB(82,82,82))
end)
AfkBtn.MouseButton1Click:Connect(function()
    AfkOn=not AfkOn
    if AfkOn then
        AfkConn=RunService.Heartbeat:Connect(function()
            if not AfkOn then return end
            local h2=getHum()
            if h2 then pcall(function() h2:Move(Vector3.new(0.001,0,0),false) end) end
        end)
    else sDis(AfkConn) end
    tog(AfkBtn,AfkOn,"Anti AFK  ON","Anti AFK  OFF")
    Notif(AfkOn and "Anti AFK enabled." or "Anti AFK disabled.",
          AfkOn and Color3.fromRGB(148,0,185) or Color3.fromRGB(82,82,82))
end)
ResetBtn.MouseButton1Click:Connect(function()
    stopGlitch(true)
    local hum=getHum(); if hum then pcall(function() hum.Health=0 end) end
    Notif("Character reset.",Color3.fromRGB(68,135,205))
end)
TpBtn.MouseButton1Click:Connect(function()
    local hrp=getHRP()
    if hrp then pcall(function() hrp.CFrame=hrp.CFrame+Vector3.new(0,180,0) end) end
    Notif("Teleported upward.",Color3.fromRGB(68,135,205))
end)
SaveBtn.MouseButton1Click:Connect(function()
    local hrp=getHRP(); if not hrp then return end
    SavedCF=hrp.CFrame
    tog(SaveBtn,true,"Position Saved","Save Position")
    Notif("Position saved.",Color3.fromRGB(68,135,205))
end)
LoadBtn.MouseButton1Click:Connect(function()
    if not SavedCF then Notif("No position saved.",Color3.fromRGB(82,82,82)); return end
    local hrp=getHRP()
    if hrp then pcall(function() hrp.CFrame=SavedCF end) end
    Notif("Teleported to saved position.",Color3.fromRGB(68,135,205))
end)
WearBtn.MouseButton1Click:Connect(function()
    local id=tonumber(HatBox.Text)
    if not id then Notif("Enter a valid asset ID.",Color3.fromRGB(190,48,48)); return end
    wearAccessory(id)
end)

-- ============================================================
-- MINIMIZE → FLOATING ICON (top-right, fixed, no drag)
-- ============================================================
local minimized=false

local function showMain()
    minimized=false
    Main.Visible=true
    tw(Main,   {BackgroundTransparency=0},0.2)
    tw(MStroke,{Transparency=0},          0.2)
    IconBtn.Visible=false
    stopIconAnim()
    MinBtn.Text="-"
end

local function showIcon()
    minimized=true
    tw(Main,   {BackgroundTransparency=1},0.16)
    tw(MStroke,{Transparency=1},          0.16)
    task.delay(0.18,function()
        Main.Visible=false
        IconBtn.Visible=true
        startIconAnim()
    end)
    MinBtn.Text="+"
end

MinBtn.MouseButton1Click:Connect(function()
    if minimized then showMain() else showIcon() end
end)

IconBtn.MouseButton1Click:Connect(function()
    showMain()
end)

CloseBtn.MouseButton1Click:Connect(function()
    stopGlitch(true)
    sDis(FreezeConn); sDis(AfkConn); stopIconAnim()
    if GravOn then pcall(function() workspace.Gravity=196.2 end) end
    local hum=getHum()
    if hum then pcall(function() hum.JumpPower=DEF_JP; hum.PlatformStand=false end) end
    tw(Main,   {BackgroundTransparency=1},0.16)
    tw(MStroke,{Transparency=1},          0.16)
    task.delay(0.2,function() sDes(SG); sDes(NotifSG); sDes(IconSG) end)
end)

-- ============================================================
-- CHARACTER RESPAWN
-- ============================================================
LP.CharacterAdded:Connect(function(char)
    task.wait(1.5)
    GlitchActive=false; GlitchConns={}; HandleData={}
    BrokenBtn.BackgroundColor3=Color3.fromRGB(112,0,142); BrokenBtn.Text="BROKEN"
    task.wait(0.4)
    local h2=char:FindFirstChildOfClass("Humanoid")
    if h2 and JumpOn then pcall(function() h2.JumpPower=HACK_JP end) end
end)

-- ============================================================
-- INIT
-- ============================================================
task.wait(0.4)
Notif("Anonymous9x Glitch loaded.",Color3.fromRGB(148,0,188))
print("[Anon9x] Loaded OK. Canvas: "..curY.."px")
