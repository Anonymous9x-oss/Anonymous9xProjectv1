--[[
    ╔══════════════════════════════════════════════════════════╗
    ║      GOD MODE  //  UNIVERSAL ENGINE  — v3                ║
    ║      By Anonymous9x                                      ║
    ║      Delta Mobile / iOS ONLY                             ║
    ║      Execute again to toggle OFF                         ║
    ╠══════════════════════════════════════════════════════════╣
    ║   BASE ENGINE (original 8 layers):                       ║
    ║   [1]  Health Loop        — Heartbeat: Health = MAX      ║
    ║   [2]  ForceField         — Invisible, blocks projectile ║
    ║   [3]  Kill Part Scan     — Disable kill/lava/acid parts ║
    ║   [4]  Part Watcher       — Auto-disable new kill parts  ║
    ║   [5]  Anti-Void          — Rescue if Y < -500           ║
    ║   [6]  State Hijack       — Force GettingUp on ragdoll   ║
    ║   [7]  MaxHealth Clamp    — Lock MaxHealth at max        ║
    ║   [8]  Auto Respawn       — Re-apply on CharacterAdded   ║
    ║                                                          ║
    ║   NEW ANTI-DAMAGE LAYERS:                                ║
    ║   [9]  Anti-Fling         — BodyVelocity/BodyForce/      ║
    ║        RocketPropulsion detector: any force injected     ║
    ║        into our character is destroyed instantly.        ║
    ║        Also clamps velocity > threshold back to zero.    ║
    ║                                                          ║
    ║   [10] Remote Damage Block — scan ReplicatedStorage for  ║
    ║        damage-named RemoteEvents, hook FireServer via    ║
    ║        __newindex metatable to silently drop calls that  ║
    ║        target LocalPlayer. ~50% of FE combat games.      ║
    ║                                                          ║
    ║   [11] Property Lock      — Heartbeat clamp WalkSpeed,   ║
    ║        JumpPower, JumpHeight to prevent speed-zero kills ║
    ║                                                          ║
    ║   [12] Humanoid Protection — SetHumanoidStateEnabled     ║
    ║        (Dead, false) on every Heartbeat so no script     ║
    ║        can force-kill us via ChangeState(Dead).          ║
    ║                                                          ║
    ║   [13] NPC Weapon Disabler — disable CanTouch on Tool    ║
    ║        Handle parts of NPC models within 40 studs so     ║
    ║        melee NPC hits cannot register.                   ║
    ╚══════════════════════════════════════════════════════════╝
]]

local Players      = game:GetService("Players")
local RunService   = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local LocalPlayer  = Players.LocalPlayer

if _G.GodModeActive == nil then _G.GodModeActive = false end
_G.GodModeActive = not _G.GodModeActive
local ENTERING = _G.GodModeActive

-- ══════════════════════════════════════════════════════════════════
--  NOTIFICATION BUILDER  (unchanged from last version)
-- ══════════════════════════════════════════════════════════════════
local function buildNotif(guiName, mainText, subText, entering, displaySecs)
    pcall(function()
        local old = game.CoreGui:FindFirstChild(guiName)
        if old then old:Destroy() end
    end)

    local PAL = entering and {
        panel  = Color3.fromRGB(10,  6,   0),
        stroke = Color3.fromRGB(255, 200,  40),
        strokeB= Color3.fromRGB(200,  70,   0),
        main   = Color3.fromRGB(255, 228, 110),
        sub    = Color3.fromRGB(255, 148,  20),
        aberR  = Color3.fromRGB(255,  20,   0),
        aberB  = Color3.fromRGB(  0, 200, 255),
        bolt   = Color3.fromRGB(255, 255, 190),
        bar    = Color3.fromRGB(255, 175,   0),
        sep    = Color3.fromRGB(255, 180,  10),
        cred   = Color3.fromRGB(150, 130,  90),
    } or {
        panel  = Color3.fromRGB(  3,   5,  18),
        stroke = Color3.fromRGB( 65, 148, 255),
        strokeB= Color3.fromRGB( 15,  50, 200),
        main   = Color3.fromRGB(150, 205, 255),
        sub    = Color3.fromRGB( 65, 128, 225),
        aberR  = Color3.fromRGB(185,  20, 255),
        aberB  = Color3.fromRGB(  0, 215, 255),
        bolt   = Color3.fromRGB(195, 225, 255),
        bar    = Color3.fromRGB( 55, 135, 255),
        sep    = Color3.fromRGB( 55, 120, 255),
        cred   = Color3.fromRGB( 90, 120, 170),
    }

    local gui = Instance.new("ScreenGui")
    gui.Name = guiName; gui.ResetOnSpawn = false
    gui.DisplayOrder = 999; gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    pcall(function() gui.Parent = game.CoreGui end)
    if not gui.Parent then gui.Parent = LocalPlayer.PlayerGui end

    local PANEL_H = 92
    local wrap = Instance.new("Frame")
    wrap.Name = "Wrap"; wrap.Size = UDim2.new(0, 298, 0, PANEL_H)
    wrap.Position = UDim2.new(0.5, 0, 0, 18); wrap.AnchorPoint = Vector2.new(0.5, 0)
    wrap.BackgroundTransparency = 1; wrap.ClipsDescendants = false
    wrap.ZIndex = 10; wrap.Parent = gui

    local panel = Instance.new("Frame")
    panel.Size = UDim2.new(1,0,1,0); panel.BackgroundColor3 = PAL.panel
    panel.BackgroundTransparency = 1; panel.BorderSizePixel = 0
    panel.ZIndex = 10; panel.Parent = wrap
    Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 7)

    local borderStroke = Instance.new("UIStroke")
    borderStroke.Color = PAL.stroke; borderStroke.Thickness = 1.8
    borderStroke.Transparency = 1; borderStroke.Parent = panel

    local topLine = Instance.new("Frame")
    topLine.Size = UDim2.new(0.86,0,0,2); topLine.Position = UDim2.new(0.07,0,0,0)
    topLine.BackgroundColor3 = PAL.stroke; topLine.BackgroundTransparency = 1
    topLine.BorderSizePixel = 0; topLine.ZIndex = 14; topLine.Parent = wrap
    Instance.new("UICorner", topLine).CornerRadius = UDim.new(1,0)

    local botLine = Instance.new("Frame")
    botLine.Size = UDim2.new(0.50,0,0,1); botLine.Position = UDim2.new(0.25,0,1,-1)
    botLine.BackgroundColor3 = PAL.sub; botLine.BackgroundTransparency = 1
    botLine.BorderSizePixel = 0; botLine.ZIndex = 14; botLine.Parent = wrap
    Instance.new("UICorner", botLine).CornerRadius = UDim.new(1,0)

    local leftBar = Instance.new("Frame")
    leftBar.Size = UDim2.new(0,3,0.65,0); leftBar.Position = UDim2.new(0,0,0.175,0)
    leftBar.BackgroundColor3 = PAL.bar; leftBar.BackgroundTransparency = 1
    leftBar.BorderSizePixel = 0; leftBar.ZIndex = 15; leftBar.Parent = wrap
    Instance.new("UICorner", leftBar).CornerRadius = UDim.new(1,0)
    local rightBar = leftBar:Clone(); rightBar.Position = UDim2.new(1,-3,0.175,0); rightBar.Parent = wrap

    local tickFrames = {}
    local function tick(parent, ax, ay)
        local hw = Instance.new("Frame")
        hw.Size = UDim2.new(0,9,0,2); hw.Position = UDim2.new(ax, ax==0 and 1 or -10, ay, ay==0 and 1 or -3)
        hw.BackgroundColor3 = PAL.stroke; hw.BackgroundTransparency = 1
        hw.BorderSizePixel = 0; hw.ZIndex = 17; hw.Parent = parent
        local vw = Instance.new("Frame")
        vw.Size = UDim2.new(0,2,0,9); vw.Position = UDim2.new(ax, ax==0 and 1 or -3, ay, ay==0 and 1 or -10)
        vw.BackgroundColor3 = PAL.stroke; vw.BackgroundTransparency = 1
        vw.BorderSizePixel = 0; vw.ZIndex = 17; vw.Parent = parent
        return hw, vw
    end
    local function addTick(ax, ay) local a,b = tick(wrap,ax,ay); table.insert(tickFrames,a); table.insert(tickFrames,b) end
    addTick(0,0) addTick(1,0) addTick(0,1) addTick(1,1)

    local boltSegments = {}
    local function makeBolt(parent, ox, oy)
        local segs = {{dx=5,dy=0,r=52,w=11,h=2},{dx=3,dy=6,r=-48,w=9,h=2},{dx=6,dy=12,r=55,w=12,h=2},{dx=2,dy=18,r=-42,w=8,h=2}}
        for _, s in ipairs(segs) do
            local seg = Instance.new("Frame")
            seg.Size = UDim2.new(0,s.w,0,s.h); seg.Position = UDim2.new(0,ox+s.dx,0,oy+s.dy)
            seg.Rotation = s.r; seg.BackgroundColor3 = PAL.bolt; seg.BackgroundTransparency = 1
            seg.BorderSizePixel = 0; seg.ZIndex = 16; seg.Parent = parent
            table.insert(boltSegments, seg)
        end
    end
    makeBolt(wrap,6,10); makeBolt(wrap,16,6); makeBolt(wrap,268,10); makeBolt(wrap,278,6)

    local aberR = Instance.new("TextLabel")
    aberR.Size=UDim2.new(1,0,0,28); aberR.Position=UDim2.new(0,2.5,0,10)
    aberR.BackgroundTransparency=1; aberR.Text=mainText; aberR.Font=Enum.Font.GothamBlack
    aberR.TextSize=15; aberR.TextColor3=PAL.aberR; aberR.TextTransparency=1
    aberR.TextXAlignment=Enum.TextXAlignment.Center; aberR.ZIndex=11; aberR.Parent=wrap

    local aberB = Instance.new("TextLabel")
    aberB.Size=UDim2.new(1,0,0,28); aberB.Position=UDim2.new(0,-2.5,0,8)
    aberB.BackgroundTransparency=1; aberB.Text=mainText; aberB.Font=Enum.Font.GothamBlack
    aberB.TextSize=15; aberB.TextColor3=PAL.aberB; aberB.TextTransparency=1
    aberB.TextXAlignment=Enum.TextXAlignment.Center; aberB.ZIndex=11; aberB.Parent=wrap

    local mainLbl = Instance.new("TextLabel")
    mainLbl.Size=UDim2.new(1,0,0,28); mainLbl.Position=UDim2.new(0,0,0,9)
    mainLbl.BackgroundTransparency=1; mainLbl.Text=mainText; mainLbl.Font=Enum.Font.GothamBlack
    mainLbl.TextSize=15; mainLbl.TextColor3=PAL.main; mainLbl.TextStrokeColor3=PAL.strokeB
    mainLbl.TextStrokeTransparency=1; mainLbl.TextTransparency=1
    mainLbl.TextXAlignment=Enum.TextXAlignment.Center; mainLbl.ZIndex=18; mainLbl.Parent=wrap
    local lStroke = Instance.new("UIStroke")
    lStroke.Color=PAL.stroke; lStroke.Thickness=1.1; lStroke.Transparency=1; lStroke.Parent=mainLbl

    local subLbl = Instance.new("TextLabel")
    subLbl.Size=UDim2.new(1,-20,0,18); subLbl.Position=UDim2.new(0,10,0,40)
    subLbl.BackgroundTransparency=1; subLbl.Text=subText; subLbl.Font=Enum.Font.GothamSemibold
    subLbl.TextSize=10; subLbl.TextColor3=PAL.sub; subLbl.TextTransparency=1
    subLbl.TextXAlignment=Enum.TextXAlignment.Center; subLbl.ZIndex=18; subLbl.Parent=wrap

    local sepLine = Instance.new("Frame")
    sepLine.Size=UDim2.new(0.7,0,0,1); sepLine.Position=UDim2.new(0.15,0,1,-18)
    sepLine.BackgroundColor3=PAL.sep; sepLine.BackgroundTransparency=1
    sepLine.BorderSizePixel=0; sepLine.ZIndex=17; sepLine.Parent=wrap
    Instance.new("UICorner", sepLine).CornerRadius=UDim.new(1,0)

    local cred = Instance.new("TextLabel")
    cred.Size=UDim2.new(1,-16,0,14); cred.Position=UDim2.new(0,8,1,-16)
    cred.BackgroundTransparency=1; cred.Text="By  Anonymous9x"; cred.Font=Enum.Font.Gotham
    cred.TextSize=8; cred.TextColor3=PAL.cred; cred.TextTransparency=1
    cred.TextXAlignment=Enum.TextXAlignment.Center; cred.ZIndex=18; cred.Parent=wrap

    local function revealAll()
        panel.BackgroundTransparency=0.08; borderStroke.Transparency=0.05
        topLine.BackgroundTransparency=0.0; botLine.BackgroundTransparency=0.35
        leftBar.BackgroundTransparency=0.0; rightBar.BackgroundTransparency=0.0
        for _,f in ipairs(tickFrames) do f.BackgroundTransparency=0.15 end
        for _,s in ipairs(boltSegments) do s.BackgroundTransparency=0.15 end
        sepLine.BackgroundTransparency=0.55; mainLbl.TextTransparency=0.0
        mainLbl.TextStrokeTransparency=0.0; subLbl.TextTransparency=0.08
        cred.TextTransparency=0.20; aberR.TextTransparency=0.68; aberB.TextTransparency=0.68
        lStroke.Transparency=0.18
    end

    local function hideAll()
        panel.BackgroundTransparency=1; borderStroke.Transparency=1
        topLine.BackgroundTransparency=1; botLine.BackgroundTransparency=1
        leftBar.BackgroundTransparency=1; rightBar.BackgroundTransparency=1
        for _,f in ipairs(tickFrames) do f.BackgroundTransparency=1 end
        for _,s in ipairs(boltSegments) do s.BackgroundTransparency=1 end
        sepLine.BackgroundTransparency=1; mainLbl.TextTransparency=1
        mainLbl.TextStrokeTransparency=1; subLbl.TextTransparency=1
        cred.TextTransparency=1; aberR.TextTransparency=1; aberB.TextTransparency=1; lStroke.Transparency=1
    end

    local function snapX(px) wrap.Position = UDim2.new(0.5, px, 0, 18) end

    task.delay(0.00, function() snapX(-10); borderStroke.Transparency=0.1; for _,s in ipairs(boltSegments) do s.BackgroundTransparency=0.0 end; for _,f in ipairs(tickFrames) do f.BackgroundTransparency=0.0 end end)
    task.delay(0.05, function() hideAll(); snapX(7) end)
    task.delay(0.09, function() panel.BackgroundTransparency=0.35; borderStroke.Transparency=0.0; topLine.BackgroundTransparency=0.0; for _,s in ipairs(boltSegments) do s.BackgroundTransparency=0.05 end; mainLbl.TextTransparency=0.5; mainLbl.TextStrokeTransparency=0.5; aberR.TextTransparency=0.5; aberB.TextTransparency=0.5 end)
    task.delay(0.14, function() hideAll(); snapX(-4) end)
    task.delay(0.17, function() panel.BackgroundTransparency=0.15; borderStroke.Transparency=0.05; topLine.BackgroundTransparency=0.0; botLine.BackgroundTransparency=0.35; for _,s in ipairs(boltSegments) do s.BackgroundTransparency=0.1 end; for _,f in ipairs(tickFrames) do f.BackgroundTransparency=0.2 end; mainLbl.TextTransparency=0.2; mainLbl.TextStrokeTransparency=0.2; subLbl.TextTransparency=0.4; aberR.TextTransparency=0.6; aberB.TextTransparency=0.6; lStroke.Transparency=0.3 end)
    task.delay(0.21, function() wrap.Position = UDim2.new(0.5,0,0,18); revealAll() end)

    local t, gTimer, glitching = 0, 0, false
    local origText = mainText
    local GCHARS = {"#","X","/","_","!","I","1","\\","|","0","T","V","Z","N"}
    local function scramble(s)
        local chars = {}; for c in s:gmatch(".") do table.insert(chars,c) end
        local n = math.random(2,4)
        for _ = 1,n do local i=math.random(1,#chars); if chars[i]~=" " then chars[i]=GCHARS[math.random(1,#GCHARS)] end end
        return table.concat(chars)
    end

    local effectConn
    effectConn = RunService.Heartbeat:Connect(function(dt)
        t+=dt; gTimer+=dt
        local fast=(math.sin(t*6)+1)/2; local slow=(math.sin(t*1.6)+1)/2
        borderStroke.Transparency=0.05+fast*0.50; lStroke.Transparency=0.10+fast*0.55
        leftBar.BackgroundTransparency=fast*0.60; rightBar.BackgroundTransparency=fast*0.60
        topLine.BackgroundTransparency=slow*0.40; botLine.BackgroundTransparency=0.30+fast*0.45
        for _,f in ipairs(tickFrames) do f.BackgroundTransparency=0.10+fast*0.55 end
        for _,s in ipairs(boltSegments) do s.BackgroundTransparency=0.08+fast*0.68 end
        sepLine.BackgroundTransparency=0.45+slow*0.35; cred.TextTransparency=0.15+slow*0.28
        local jitter=fast*2.6
        aberR.Position=UDim2.new(0,jitter,0,10); aberB.Position=UDim2.new(0,-jitter,0,8)
        aberR.TextTransparency=0.58+slow*0.22; aberB.TextTransparency=0.58+slow*0.22
        subLbl.TextTransparency=0.05+slow*0.32
        if gTimer>0.85 then gTimer=0; glitching=true; task.delay(0.065,function() glitching=false; mainLbl.Text=origText; aberR.Text=origText; aberB.Text=origText end) end
        if glitching then local g=scramble(origText); mainLbl.Text=g; aberR.Text=g; aberB.Text=g end
    end)

    task.delay(displaySecs, function()
        effectConn:Disconnect(); mainLbl.Text=origText; aberR.Text=origText; aberB.Text=origText
        local steps={{0.00,5,0.35,0.35},{0.05,-7,0.65,0.55},{0.09,3,0.25,0.20},{0.13,-4,0.80,0.70},{0.17,0,1.00,1.00}}
        for _,step in ipairs(steps) do
            task.delay(step[1], function()
                if not gui or not gui.Parent then return end
                snapX(step[2]); panel.BackgroundTransparency=step[3]; borderStroke.Transparency=step[3]
                mainLbl.TextTransparency=step[4]; mainLbl.TextStrokeTransparency=step[4]
                subLbl.TextTransparency=step[4]; aberR.TextTransparency=math.min(1,step[4]+0.15)
                aberB.TextTransparency=math.min(1,step[4]+0.15); cred.TextTransparency=step[4]
                topLine.BackgroundTransparency=step[3]; botLine.BackgroundTransparency=step[3]
                leftBar.BackgroundTransparency=step[3]; rightBar.BackgroundTransparency=step[3]
                sepLine.BackgroundTransparency=step[3]; lStroke.Transparency=step[4]
                for _,f in ipairs(tickFrames) do f.BackgroundTransparency=step[3] end
                for _,s in ipairs(boltSegments) do s.BackgroundTransparency=step[3] end
                if step[4]<0.9 and step[4]>0 then mainLbl.Text=scramble(origText); aberR.Text=mainLbl.Text; aberB.Text=mainLbl.Text end
            end)
        end
        task.delay(0.22, function() pcall(function() gui:Destroy() end) end)
    end)
end

local function showMainNotif(entering)
    if entering then
        buildNotif("__GodNotif9x","GOD MODE ACTIVATED","PROTECTION SYSTEMS  ONLINE",true,3.0)
    else
        buildNotif("__GodNotif9x","NORMAL MODE RESTORED","ALL SYSTEMS  OFFLINE",false,3.0)
    end
end

local function showRespawnNotif()
    buildNotif("__GodRespawnNotif9x","GOD MODE RE-APPLIED","AUTO REACTIVATED  ON RESPAWN",true,2.8)
end

-- ══════════════════════════════════════════════════════════════════
--  GOD MODE ENGINE  — v3  (13 layers)
-- ══════════════════════════════════════════════════════════════════
local _connections = _G._GodModeConnections or {}
local _savedParts  = _G._GodModeParts       or {}
_G._GodModeConnections = _connections
_G._GodModeParts       = _savedParts

-- Cached damage remotes (for layer 10)
local _dmgRemotes = _G._GodDmgRemotes or {}
_G._GodDmgRemotes = _dmgRemotes

local KILL_KEYWORDS = {
    "kill","lava","acid","death","damage","spike","poison","void",
    "laser","fire","toxic","instant","drown","nuke","hot","burn",
    "explode","electric","zap","hazard","danger","lethal","harmful",
    "magma","boil","trap","deadly","dead","hurt","hit","ouch",
}

local DMG_REMOTE_KEYS = {
    "damage","hurt","takedamage","dealdamage","hit","strike",
    "attack","playerattack","attackplayer","combat","slash","punch",
    "kill","wound","inflict","register"
}

local function isKillPart(part)
    if not part:IsA("BasePart") then return false end
    local n = part.Name:lower()
    for _, kw in ipairs(KILL_KEYWORDS) do
        if n:find(kw,1,true) then return true end
    end
    if part.Material == Enum.Material.Neon then return true end
    return false
end

local function disableKillPart(part)
    if isKillPart(part) then
        if _savedParts[part] == nil then
            _savedParts[part] = {CanTouch=part.CanTouch, CanCollide=part.CanCollide}
        end
        pcall(function() part.CanTouch=false; part.CanCollide=false end)
    end
end

local function restoreKillPart(part, props)
    pcall(function() part.CanTouch=props.CanTouch; part.CanCollide=props.CanCollide end)
end

local function disconnectAll()
    for _, c in ipairs(_connections) do pcall(function() c:Disconnect() end) end
    table.clear(_connections)
end

local function addConn(c) table.insert(_connections, c) end

-- ── LAYER 10: Scan & hook damage remotes ─────────────────────────
local function scanDamageRemotes()
    table.clear(_dmgRemotes)
    local function check(obj)
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            local n = obj.Name:lower()
            for _, kw in ipairs(DMG_REMOTE_KEYS) do
                if n:find(kw,1,true) then
                    table.insert(_dmgRemotes, obj)
                    break
                end
            end
        end
    end
    pcall(function()
        for _, d in ipairs(game:GetService("ReplicatedStorage"):GetDescendants()) do check(d) end
    end)
    pcall(function()
        for _, d in ipairs(workspace:GetDescendants()) do check(d) end
    end)
end

-- ── LAYER 9: Anti-Fling ───────────────────────────────────────────
-- Destroys any BodyVelocity/BodyForce/RocketPropulsion/LinearVelocity
-- injected into our character parts by outside scripts.
-- Also hard-clamps AssemblyLinearVelocity if it exceeds threshold.
local FLING_THRESHOLD  = 80   -- studs/s — above this = fling, reset to 0
local FLING_INSTANCES  = {
    "BodyVelocity", "BodyForce", "BodyAngularVelocity",
    "BodyGyro",     "RocketPropulsion", "BodyPosition",
    "LinearVelocity", "AngularVelocity", "AlignPosition",
}

local function cleanFlingObjects(char)
    for _, part in ipairs(char:GetDescendants()) do
        for _, fname in ipairs(FLING_INSTANCES) do
            if part:IsA(fname) then
                pcall(function() part:Destroy() end)
            end
        end
    end
end

-- ── LAYER 13: NPC Weapon Disabler ────────────────────────────────
local _disabledNPCWeapons = {}

local function disableNPCWeaponsNear(char)
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local pos = hrp.Position

    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Tool") or obj.Name:lower():find("weapon") or obj.Name:lower():find("sword")
        or obj.Name:lower():find("gun") or obj.Name:lower():find("knife") then
            -- Check it's not ours
            local isOurs = false
            local c = LocalPlayer.Character
            if c then
                local p = obj
                while p and p ~= workspace do
                    if p == c then isOurs = true; break end
                    p = p.Parent
                end
            end
            if not isOurs then
                for _, part in ipairs(obj:GetDescendants()) do
                    if part:IsA("BasePart") and (part.Name == "Handle" or part.Name:lower():find("blade") or part.Name:lower():find("hit")) then
                        local d = (part.Position - pos).Magnitude
                        if d <= 40 and not _disabledNPCWeapons[part] then
                            _disabledNPCWeapons[part] = part.CanTouch
                            pcall(function() part.CanTouch = false end)
                        end
                    end
                end
            end
        end
    end
end

local function restoreNPCWeapons()
    for part, val in pairs(_disabledNPCWeapons) do
        pcall(function() part.CanTouch = val end)
    end
    table.clear(_disabledNPCWeapons)
end

-- ── MAIN ENABLE ───────────────────────────────────────────────────
local function enableGodMode()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    -- [1] Set health to max immediately
    hum.MaxHealth = math.huge
    hum.Health    = math.huge

    -- [2] ForceField
    for _, v in ipairs(char:GetChildren()) do
        if v.Name == "_GodFF" then v:Destroy() end
    end
    local ff = Instance.new("ForceField")
    ff.Visible = false; ff.Name = "_GodFF"; ff.Parent = char

    -- [3] Initial kill-part scan
    for _, part in ipairs(workspace:GetDescendants()) do
        disableKillPart(part)
    end

    -- [9] Initial fling cleanup
    cleanFlingObjects(char)

    -- [10] Scan damage remotes once
    task.spawn(scanDamageRemotes)

    -- ── Heartbeat: layers 1, 6, 7, 9, 11, 12, 13 ─────────────────
    addConn(RunService.Heartbeat:Connect(function(dt)
        local c2 = LocalPlayer.Character
        if not c2 then return end
        local h2 = c2:FindFirstChildOfClass("Humanoid")
        if not h2 then return end

        -- [1] + [7] Health & MaxHealth lock
        if h2.MaxHealth ~= math.huge then h2.MaxHealth = math.huge end
        if h2.Health    < h2.MaxHealth then h2.Health  = math.huge end

        -- [6] State Hijack
        local st = h2:GetState()
        if st == Enum.HumanoidStateType.Dead or st == Enum.HumanoidStateType.FallingDown then
            h2:ChangeState(Enum.HumanoidStateType.GettingUp)
        end

        -- [11] Property Lock — prevent zero-speed / zero-jump kills
        if h2.WalkSpeed   < 4   then h2.WalkSpeed   = 16  end
        if h2.JumpPower   < 25  then h2.JumpPower   = 50  end
        pcall(function()
            if h2.JumpHeight < 4 then h2.JumpHeight = 7.2 end
        end)

        -- [12] Humanoid Protection — keep Dead state disabled
        -- so no outside script can ChangeState(Dead) on us
        pcall(function()
            h2:SetHumanoidStateEnabled(Enum.HumanoidStateType.Dead, false)
        end)

        -- [9] Anti-Fling — destroy injected force objects
        for _, part in ipairs(c2:GetDescendants()) do
            for _, fname in ipairs(FLING_INSTANCES) do
                if part.ClassName == fname then
                    pcall(function() part:Destroy() end)
                end
            end
        end

        -- [9] Anti-Fling — velocity clamp
        local hrp = c2:FindFirstChild("HumanoidRootPart")
        if hrp then
            local vel = hrp.AssemblyLinearVelocity
            if vel.Magnitude > FLING_THRESHOLD then
                pcall(function()
                    hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                end)
            end
        end

        -- [13] NPC Weapon Disabler (every 0.5s via dt accumulation handled externally)
    end))

    -- [5] Anti-Void
    addConn(RunService.Heartbeat:Connect(function()
        local c2 = LocalPlayer.Character
        if not c2 then return end
        local hrp = c2:FindFirstChild("HumanoidRootPart")
        if hrp and hrp.Position.Y < -500 then
            hrp.CFrame = CFrame.new(hrp.Position.X, 100, hrp.Position.Z)
        end
    end))

    -- [4] Part Watcher
    addConn(workspace.DescendantAdded:Connect(function(p)
        if _G.GodModeActive then disableKillPart(p) end
    end))

    -- [13] NPC weapon scan loop (every 0.5s)
    local _npcTimer = 0
    addConn(RunService.Heartbeat:Connect(function(dt)
        if not _G.GodModeActive then return end
        _npcTimer = _npcTimer + dt
        if _npcTimer >= 0.5 then
            _npcTimer = 0
            local c2 = LocalPlayer.Character
            if c2 then disableNPCWeaponsNear(c2) end
        end
    end))

    -- [9] Watch for new objects added to our character (fling injection)
    addConn(char.DescendantAdded:Connect(function(obj)
        if not _G.GodModeActive then return end
        for _, fname in ipairs(FLING_INSTANCES) do
            if obj.ClassName == fname then
                pcall(function() task.defer(function() obj:Destroy() end) end)
            end
        end
    end))

    -- [8] Auto re-apply on respawn
    addConn(LocalPlayer.CharacterAdded:Connect(function()
        task.wait(0.18)
        if _G.GodModeActive then
            enableGodMode()
            showRespawnNotif()
        end
    end))
end

local function disableGodMode()
    disconnectAll()
    for part, props in pairs(_savedParts) do restoreKillPart(part, props) end
    table.clear(_savedParts)
    restoreNPCWeapons()

    local char = LocalPlayer.Character
    if char then
        for _, v in ipairs(char:GetChildren()) do
            if v.Name == "_GodFF" then v:Destroy() end
        end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            -- Re-enable Dead state so character can die normally
            pcall(function()
                hum:SetHumanoidStateEnabled(Enum.HumanoidStateType.Dead, true)
            end)
            hum.MaxHealth = 100
            hum.Health    = 100
            hum.WalkSpeed  = 16
            hum.JumpPower  = 50
        end
    end
end

-- Run
if ENTERING then enableGodMode() else disableGodMode() end
showMainNotif(ENTERING)
