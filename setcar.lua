--[[
╔══════════════════════════════════════════════════════════════════╗
║   Anonymous9x Vehicle FE  —  v1.0                                ║
║   Universal Vehicle Control  |  All Executors                    ║
║   Delta Mobile / iOS / iPad / PC                                 ║
╠══════════════════════════════════════════════════════════════════╣
║   HOW IT WORKS (FE / client-side physics):                       ║
║   When you sit in a vehicle, we claim network ownership of all   ║
║   BaseParts in that vehicle. Once we own them client-side, we    ║
║   can set their physical properties (velocity, CanCollide,        ║
║   Anchored, SpringConstraint params) and they replicate to       ║
║   other clients. This is the same method the leaked source used. ║
║                                                                  ║
║   TABS:                                                          ║
║   Physics   — Anti-Bounce, Speed, Flight, Traction, Freeze       ║
║   Suspension — Global sliders, Presets, Per-spring fine-tune     ║
║   Visual    — Vehicle color presets + custom RGB                 ║
║   Fun       — Gravity modes, Fullbright                          ║
╚══════════════════════════════════════════════════════════════════╝
]]

-- ═══════════════════════════════════════════════
-- SERVICES
-- ═══════════════════════════════════════════════
local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UIS        = game:GetService("UserInputService")
local Lighting   = game:GetService("Lighting")
local LP         = Players.LocalPlayer
local Cam        = workspace.CurrentCamera

-- ═══════════════════════════════════════════════
-- DESTROY OLD
-- ═══════════════════════════════════════════════
pcall(function() game.CoreGui:FindFirstChild("_A9xVeh"):Destroy() end)
pcall(function() LP.PlayerGui:FindFirstChild("_A9xVeh"):Destroy() end)

-- ═══════════════════════════════════════════════
-- ROOT
-- ═══════════════════════════════════════════════
local gui = Instance.new("ScreenGui")
gui.Name             = "_A9xVeh"
gui.ResetOnSpawn     = false
gui.ZIndexBehavior   = Enum.ZIndexBehavior.Sibling
gui.IgnoreGuiInset   = true
pcall(function() gui.Parent = game.CoreGui end)
if not gui.Parent then gui.Parent = LP.PlayerGui end

-- ═══════════════════════════════════════════════
-- VEHICLE STATE
-- ═══════════════════════════════════════════════
local V = {
    vehicle      = nil,   -- Model
    seat         = nil,   -- VehicleSeat or Seat BasePart
    partsCache   = {},    -- all BaseParts in vehicle
    springsCache = {},    -- all SpringConstraints
    origSpring   = {},    -- {[spring] = {Stiffness,Damping,FreeLength,Min,Max}}
    mass         = 0,
    lastCheck    = 0,
    modelName    = "None",
}

-- Physics flags
local Phys = {
    antiBounce       = true,
    velDamp          = 0.92,
    angDamp          = 0.85,
    surfSmooth       = true,
    transDamp        = 0.75,
    impactThresh     = 15,
    stabTime         = 0.4,
    lastImpact       = 0,
    prevVel          = Vector3.zero,
    prevPos          = Vector3.zero,
    velHistory       = {},
    historyMax       = 5,
    inTransition     = false,
    transStart       = 0,

    speedEnabled     = false,
    accelRate        = 1.5,
    brakeRate        = 0.9,
    maxGroundSpeed   = 250,

    flightEnabled    = false,
    flightSpeed      = 1.0,

    tractionEnabled  = false,
    tractionGrip     = 1.0,

    freeze           = false,
    noclip           = false,
}

-- Suspension data
local Sus = {
    stiffness   = 4000,
    damping     = 200,
    height      = 0,
    frontStiff  = 4000,
    rearStiff   = 4000,
    minLength   = 0.5,
    maxLength   = 8.0,
}

-- Fun / Visual
local Fun = {
    gravEnabled   = false,
    gravMode      = "Normal",
    gravForceObj  = nil,
    gravAttach    = nil,
    fullbright    = false,
    origAmbient   = Lighting.Ambient,
    origBrightness= Lighting.Brightness,
    origFogEnd    = Lighting.FogEnd,
    customColor   = Color3.fromRGB(200, 0, 0),
}

-- ═══════════════════════════════════════════════
-- NOTIFICATION  (bottom-right custom)
-- ═══════════════════════════════════════════════
local notifQ = {}; local notifBusy = false
local function showNotif(title, body, dur)
    table.insert(notifQ, {t=title, b=body, d=dur or 3})
    if notifBusy then return end
    notifBusy = true
    task.spawn(function()
        while #notifQ > 0 do
            local n = table.remove(notifQ,1)
            local f = Instance.new("Frame")
            f.Size             = UDim2.fromOffset(220,50)
            f.Position         = UDim2.new(1,10,1,-65)
            f.BackgroundColor3 = Color3.fromRGB(7,7,9)
            f.BackgroundTransparency=0
            f.BorderSizePixel  = 0
            f.ZIndex           = 800
            f.Parent           = gui
            Instance.new("UICorner",f).CornerRadius = UDim.new(0,6)
            local fs = Instance.new("UIStroke",f)
            fs.Color = Color3.fromRGB(160,100,255); fs.Thickness=1.1
            local t1 = Instance.new("TextLabel")
            t1.Size=UDim2.new(1,-10,0,17); t1.Position=UDim2.fromOffset(7,4)
            t1.BackgroundTransparency=1; t1.Text=n.t
            t1.Font=Enum.Font.GothamBold; t1.TextSize=9
            t1.TextColor3=Color3.new(1,1,1); t1.TextXAlignment=Enum.TextXAlignment.Left
            t1.ZIndex=801; t1.Parent=f
            local t2 = Instance.new("TextLabel")
            t2.Size=UDim2.new(1,-10,0,20); t2.Position=UDim2.fromOffset(7,21)
            t2.BackgroundTransparency=1; t2.Text=n.b
            t2.Font=Enum.Font.Gotham; t2.TextSize=8
            t2.TextColor3=Color3.fromRGB(110,110,130); t2.TextXAlignment=Enum.TextXAlignment.Left
            t2.TextWrapped=true; t2.ZIndex=801; t2.Parent=f
            TweenService:Create(f,TweenInfo.new(0.18),{Position=UDim2.new(1,-228,1,-65)}):Play()
            task.wait(n.d)
            TweenService:Create(f,TweenInfo.new(0.15),{Position=UDim2.new(1,10,1,-65)}):Play()
            task.wait(0.18); pcall(function() f:Destroy() end); task.wait(0.06)
        end
        notifBusy = false
    end)
end

-- ═══════════════════════════════════════════════
-- VEHICLE DETECTION + NETWORK OWNERSHIP
-- ═══════════════════════════════════════════════
local function cacheVehicle(model)
    V.partsCache   = {}
    V.springsCache = {}
    V.origSpring   = {}
    V.mass         = 0

    for _, p in ipairs(model:GetDescendants()) do
        if p:IsA("BasePart") then
            table.insert(V.partsCache, p)
            pcall(function() V.mass = V.mass + p:GetMass() end)
            -- Claim network ownership
            pcall(function() p:SetNetworkOwner(LP) end)
            -- Set good physical props
            if not p.Anchored then
                pcall(function()
                    p.CustomPhysicalProperties = PhysicalProperties.new(
                        0.7, 0.6, 0.15, 100, 100)
                end)
            end
        elseif p:IsA("SpringConstraint") then
            table.insert(V.springsCache, p)
            V.origSpring[p] = {
                Stiffness  = p.Stiffness,
                Damping    = p.Damping,
                FreeLength = p.FreeLength,
                MinLength  = p.MinLength,
                MaxLength  = p.MaxLength,
            }
        end
    end
end

local function getVehicle()
    local c = LP.Character
    if not c then return end
    local h = c:FindFirstChildOfClass("Humanoid")
    if not h then return end
    local seat = h.SeatPart
    if not seat then
        -- exited vehicle
        if V.vehicle then
            V.vehicle = nil; V.seat = nil
            V.partsCache = {}; V.springsCache = {}
            V.mass = 0; V.modelName = "None"
            Phys.prevVel = Vector3.zero
            Phys.velHistory = {}
        end
        return
    end
    local model = seat:FindFirstAncestorOfClass("Model")
    if model and model ~= V.vehicle then
        V.vehicle   = model
        V.seat      = seat
        V.modelName = model.Name or "Unknown"
        cacheVehicle(model)
        showNotif("Vehicle Detected",
            V.modelName .. "  |  Springs: " .. #V.springsCache ..
            "  |  Mass: " .. math.floor(V.mass), 4)
    end
end

-- ═══════════════════════════════════════════════
-- PHYSICS ENGINE — called every Heartbeat
-- ═══════════════════════════════════════════════
local function lerp3(a,b,t) return a + (b-a)*t end
local function clampMag(v,m) return v.Magnitude>m and v.Unit*m or v end

local function processAntiBounce(seat)
    if not Phys.antiBounce or not seat then return end
    local vel = seat.AssemblyLinearVelocity
    local prev = Phys.prevVel

    -- Velocity history smoothing
    table.insert(Phys.velHistory, vel)
    if #Phys.velHistory > Phys.historyMax then
        table.remove(Phys.velHistory, 1)
    end

    -- Detect impact
    if (vel - prev).Magnitude > Phys.impactThresh then
        Phys.lastImpact = tick()
    end

    -- Velocity change clamping
    local delta = vel - prev
    if delta.Magnitude > 20 then
        local clamped = clampMag(delta, 20)
        seat.AssemblyLinearVelocity = lerp3(vel, prev + clamped, 0.5)
    end

    -- Stabilization after impact
    local elapsed = tick() - Phys.lastImpact
    if elapsed < Phys.stabTime then
        local t    = elapsed / Phys.stabTime
        local vd   = Phys.velDamp
        local ad   = Phys.angDamp
        local fade = vd + (1-vd)*t
        seat.AssemblyLinearVelocity  = seat.AssemblyLinearVelocity  * fade
        seat.AssemblyAngularVelocity = seat.AssemblyAngularVelocity * (ad+(1-ad)*t)
    end

    Phys.prevVel = seat.AssemblyLinearVelocity
end

local function processSpeed(seat, dt)
    if not Phys.speedEnabled or not seat then return end
    local vel = seat.AssemblyLinearVelocity
    local step = dt * 60

    if UIS:IsKeyDown(Enum.KeyCode.W) then
        local fwd = seat.CFrame.LookVector
        local newVel = vel + fwd * Phys.accelRate * step
        local hVel = Vector3.new(newVel.X, 0, newVel.Z)
        if hVel.Magnitude > Phys.maxGroundSpeed then
            local clamped = hVel.Unit * Phys.maxGroundSpeed
            newVel = Vector3.new(clamped.X, newVel.Y, clamped.Z)
        end
        seat.AssemblyLinearVelocity = newVel
    end
    if UIS:IsKeyDown(Enum.KeyCode.S) then
        local brakeF = math.clamp(1 - Phys.brakeRate * 0.1 * step, 0, 1)
        seat.AssemblyLinearVelocity = vel * Vector3.new(brakeF, 0.98, brakeF)
    end
    -- Hard cap
    if vel.Magnitude > 500 then
        seat.AssemblyLinearVelocity = vel.Unit * 300
    end
end

local function processFlight(model, seat)
    if not Phys.flightEnabled or not model or not seat then return end
    local sp = Phys.flightSpeed
    local move = Vector3.zero
    if UIS:IsKeyDown(Enum.KeyCode.W) then move = move + Vector3.new(0,0,-sp) end
    if UIS:IsKeyDown(Enum.KeyCode.S) then move = move + Vector3.new(0,0, sp) end
    if UIS:IsKeyDown(Enum.KeyCode.A) then move = move + Vector3.new(-sp,0,0) end
    if UIS:IsKeyDown(Enum.KeyCode.D) then move = move + Vector3.new( sp,0,0) end
    if UIS:IsKeyDown(Enum.KeyCode.E) then move = move + Vector3.new(0,sp/2,0) end
    if UIS:IsKeyDown(Enum.KeyCode.Q) then move = move + Vector3.new(0,-sp/2,0) end
    if move.Magnitude > 0 then
        local pp = model.PrimaryPart
        if pp then
            pcall(function()
                model:SetPrimaryPartCFrame(pp.CFrame + pp.CFrame.Rotation * move)
                seat.AssemblyLinearVelocity  = seat.AssemblyLinearVelocity  * 0.5
                seat.AssemblyAngularVelocity = seat.AssemblyAngularVelocity * 0.5
            end)
        end
    end
end

local function processTraction(model, seat)
    if not Phys.tractionEnabled or not model or not seat then return end
    local pp = model.PrimaryPart
    if not pp then return end
    pcall(function()
        local cf = pp.CFrame
        local sideSlip = cf:VectorToObjectSpace(seat.AssemblyLinearVelocity).X
        if math.abs(sideSlip) > 0.5 then
            seat:ApplyImpulse(cf.RightVector * -sideSlip * (1 - Phys.tractionGrip) * 50)
        end
    end)
end

local function processCollision()
    for _, p in ipairs(V.partsCache) do
        if p and p.Parent then
            pcall(function()
                if Phys.noclip  then p.CanCollide = false end
                if Phys.freeze  then
                    p.Anchored = true
                    p.AssemblyLinearVelocity  = Vector3.zero
                    p.AssemblyAngularVelocity = Vector3.zero
                else
                    if Phys.noclip == false then end -- keep existing CanCollide
                end
            end)
        end
    end
end

local function processSuspension()
    if not V.vehicle then return end
    for _, sp in ipairs(V.springsCache) do
        if sp and sp.Parent then
            pcall(function()
                -- Front/rear detection via attachment position
                local isF = false
                if sp.Attachment0 and sp.Attachment0.Parent then
                    local pp = V.vehicle.PrimaryPart
                    if pp then
                        isF = pp.CFrame:PointToObjectSpace(
                            sp.Attachment0.WorldPosition).Z > 0
                    end
                end
                local stiff = isF and Sus.frontStiff or Sus.rearStiff
                sp.Stiffness  = math.clamp(math.abs(stiff), 100, 50000)
                sp.Damping    = math.clamp(Sus.damping, 10, 5000)
                sp.FreeLength = math.clamp(2 + Sus.height, Sus.minLength, Sus.maxLength)
                sp.MinLength  = math.clamp(0.2 + Sus.height*0.5, 0.1, 2)
                sp.MaxLength  = math.clamp(4 + Sus.height, 1, 10)
            end)
        end
    end
end

-- Gravity VectorForce
local function applyGravity(enabled, mode)
    -- Clean old
    if Fun.gravForceObj then
        pcall(function() Fun.gravForceObj:Destroy() end)
        Fun.gravForceObj = nil
    end
    if Fun.gravAttach then
        pcall(function() Fun.gravAttach:Destroy() end)
        Fun.gravAttach = nil
    end
    if not enabled or not V.seat then return end

    local g = workspace.Gravity
    local mass = V.seat:GetMass()
    local attach = Instance.new("Attachment")
    attach.Name   = "_A9xGravAtt"
    attach.Parent = V.seat
    Fun.gravAttach = attach

    local vf = Instance.new("VectorForce")
    vf.ApplyAtCenterOfMass = true
    vf.Attachment0 = attach
    vf.Parent = V.seat
    Fun.gravForceObj = vf

    if mode == "Moon" then
        vf.Force = Vector3.new(0, g * mass * 0.2, 0)      -- lighter gravity
    elseif mode == "Heavy" then
        vf.Force = Vector3.new(0, -g * mass, 0)            -- double gravity
    elseif mode == "Zero" then
        vf.Force = Vector3.new(0, g * mass, 0)             -- cancel gravity
    elseif mode == "Reverse" then
        vf.Force = Vector3.new(0, g * mass * 1.5, 0)       -- float upward
    else
        -- Normal — no force needed, destroy
        pcall(function() vf:Destroy() end)
        pcall(function() attach:Destroy() end)
        Fun.gravForceObj = nil; Fun.gravAttach = nil
    end
end

-- Fullbright
local function setFullbright(on)
    if on then
        Lighting.Ambient    = Color3.new(1,1,1)
        Lighting.Brightness = 2
        Lighting.FogEnd     = 100000
    else
        Lighting.Ambient    = Fun.origAmbient
        Lighting.Brightness = Fun.origBrightness
        Lighting.FogEnd     = Fun.origFogEnd
    end
end

-- Color changer (client-side, body parts only)
local SKIP_KEYWORDS = {
    "window","glass","wheel","tire","rim","light","headlight",
    "taillight","brake","signal","engine","exhaust","pipe",
    "mirror","handle","interior","dash","gauge","steer",
    "seat","pedal","windshield","number",
}
local PAINT_KEYWORDS = {
    "body","chassis","frame","door","hood","trunk","fender",
    "bumper","quarter","roof","paint","panel","part","car","union",
}
local function hasKeyword(name, list)
    local nl = name:lower()
    for _, k in ipairs(list) do
        if nl:find(k, 1, true) then return true end
    end
    return false
end
local function paintVehicle(color)
    if not V.vehicle then showNotif("No Vehicle","Sit in a vehicle first.",3); return end
    local count = 0
    for _, p in ipairs(V.partsCache) do
        if p and p.Parent and p:IsA("BasePart") then
            if not hasKeyword(p.Name, SKIP_KEYWORDS) then
                if hasKeyword(p.Name, PAINT_KEYWORDS) or
                   p.Name:lower() == "union" or
                   p.Name:lower():match("^part%d") then
                    pcall(function()
                        p.Color    = color
                        p.Material = Enum.Material.SmoothPlastic
                        count      = count + 1
                    end)
                end
            end
        end
    end
    showNotif("Color Applied", count .. " parts painted (client-side)", 3)
end

-- Reset all springs to original
local function resetAllSprings()
    local n = 0
    for sp, orig in pairs(V.origSpring) do
        if sp and sp.Parent then
            pcall(function()
                sp.Stiffness  = orig.Stiffness
                sp.Damping    = orig.Damping
                sp.FreeLength = orig.FreeLength
                sp.MinLength  = orig.MinLength
                sp.MaxLength  = orig.MaxLength
                n = n + 1
            end)
        end
    end
    showNotif("Springs Reset", n .. " springs restored to original.", 3)
end

-- ═══════════════════════════════════════════════
-- MAIN HEARTBEAT LOOP
-- ═══════════════════════════════════════════════
RunService.Heartbeat:Connect(function(dt)
    -- Vehicle detection every 0.5s
    if tick() - V.lastCheck > 0.5 then
        V.lastCheck = tick()
        getVehicle()
    end

    if not V.seat or not V.vehicle then return end

    processAntiBounce(V.seat)
    processSpeed(V.seat, dt)
    processFlight(V.vehicle, V.seat)
    processTraction(V.vehicle, V.seat)
    processCollision()
end)

RunService.Stepped:Connect(function()
    if V.vehicle then processSuspension() end
end)

-- ═══════════════════════════════════════════════
-- COLOURS + DIMS
-- ═══════════════════════════════════════════════
local C = {
    bg     = Color3.fromRGB(7,   7,   9),
    hdr    = Color3.fromRGB(5,   5,   7),
    card   = Color3.fromRGB(15,  15,  19),
    cardH  = Color3.fromRGB(21,  21,  27),
    sep    = Color3.fromRGB(26,  26,  34),
    border = Color3.fromRGB(40,  40,  56),
    white  = Color3.new(1,1,1),
    pri    = Color3.fromRGB(218,218,226),
    sec    = Color3.fromRGB(110,110,130),
    dim    = Color3.fromRGB(60,  60,  80),
    purple = Color3.fromRGB(160, 100, 255),
    safe   = Color3.fromRGB(80,  185,  90),
    danger = Color3.fromRGB(210,  50,  50),
}

local W   = 248   -- panel width
local H   = 300   -- panel height
local HDR = 30    -- header
local TAB = 24    -- tab bar

-- ═══════════════════════════════════════════════
-- WINDOW  (fixed center, no drag)
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
win.ZIndex             = 10
win.Parent             = gui
Instance.new("UICorner", win).CornerRadius = UDim.new(0, 7)

local winS = Instance.new("UIStroke", win)
winS.Thickness = 1.2; winS.Color = C.border

-- Border glow
task.spawn(function()
    local t = 0
    while win.Parent do
        t = t + task.wait(0.04)
        local s = (math.sin(t*2.4)+1)/2
        winS.Color = Color3.new(
            0.85 + s*0.15,
            0.75 + s*0.05,
            0.87 + s*0.53)
        winS.Thickness = 1.1 + s*0.55
        if math.random(1,85) == 1 then
            winS.Color = C.purple; task.wait(0.04)
        end
    end
end)

-- ═══════════════════════════════════════════════
-- HEADER
-- ═══════════════════════════════════════════════
local hdr = Instance.new("Frame")
hdr.Size             = UDim2.new(1,0,0,HDR)
hdr.BackgroundColor3 = C.hdr
hdr.BackgroundTransparency = 0
hdr.BorderSizePixel  = 0
hdr.ZIndex           = 11
hdr.Parent           = win
Instance.new("UICorner", hdr).CornerRadius = UDim.new(0, 7)

local hPatch = Instance.new("Frame")
hPatch.Size = UDim2.new(1,0,0,7); hPatch.Position = UDim2.new(0,0,1,-7)
hPatch.BackgroundColor3 = C.hdr; hPatch.BorderSizePixel=0; hPatch.ZIndex=10; hPatch.Parent=hdr

local hSep = Instance.new("Frame")
hSep.Size=UDim2.new(1,0,0,1); hSep.Position=UDim2.new(0,0,1,-1)
hSep.BackgroundColor3=C.sep; hSep.BorderSizePixel=0; hSep.ZIndex=12; hSep.Parent=hdr

-- Vehicle status in header
local hTitleL = Instance.new("TextLabel")
hTitleL.Size = UDim2.new(0,110,1,0); hTitleL.Position = UDim2.fromOffset(8,0)
hTitleL.BackgroundTransparency=1; hTitleL.Text="Ano9x Vehicle FE"
hTitleL.Font=Enum.Font.GothamBold; hTitleL.TextSize=9
hTitleL.TextColor3=C.pri; hTitleL.TextXAlignment=Enum.TextXAlignment.Left
hTitleL.TextTruncate=Enum.TextTruncate.AtEnd; hTitleL.ZIndex=12; hTitleL.Parent=hdr

local hVehicleL = Instance.new("TextLabel")
hVehicleL.Size = UDim2.new(0,96,1,0); hVehicleL.Position = UDim2.fromOffset(122,0)
hVehicleL.BackgroundTransparency=1; hVehicleL.Text="No Vehicle"
hVehicleL.Font=Enum.Font.Gotham; hVehicleL.TextSize=7
hVehicleL.TextColor3=C.sec; hVehicleL.TextXAlignment=Enum.TextXAlignment.Right
hVehicleL.TextTruncate=Enum.TextTruncate.AtEnd; hVehicleL.ZIndex=12; hVehicleL.Parent=hdr

-- Update vehicle label
RunService.Heartbeat:Connect(function()
    pcall(function()
        if V.vehicle then
            hVehicleL.Text = V.modelName
            hVehicleL.TextColor3 = C.safe
        else
            hVehicleL.Text = "No Vehicle"
            hVehicleL.TextColor3 = C.sec
        end
    end)
end)

-- Control buttons
local function makeCtrl(xOff, sym)
    local b = Instance.new("ImageButton")
    b.Size = UDim2.fromOffset(20,18); b.Position = UDim2.new(1,xOff,0.5,-9)
    b.BackgroundColor3=C.card; b.BackgroundTransparency=0
    b.BorderSizePixel=0; b.Image=""; b.AutoButtonColor=false
    b.ZIndex=13; b.Parent=hdr
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,4)
    local l = Instance.new("TextLabel")
    l.Size=UDim2.fromScale(1,1); l.BackgroundTransparency=1
    l.Text=sym; l.Font=Enum.Font.GothamBold; l.TextSize=12
    l.TextColor3=C.sec; l.ZIndex=14; l.Parent=b
    b.MouseEnter:Connect(function()
        TweenService:Create(b,TweenInfo.new(0.10),{BackgroundColor3=C.cardH}):Play()
        l.TextColor3=C.white
    end)
    b.MouseLeave:Connect(function()
        TweenService:Create(b,TweenInfo.new(0.10),{BackgroundColor3=C.card}):Play()
        l.TextColor3=C.sec
    end)
    return b, l
end

local minBtn, minL = makeCtrl(-44, "-")
local closeBtn, _  = makeCtrl(-22, "x")

-- ═══════════════════════════════════════════════
-- FLOAT ICON
-- ═══════════════════════════════════════════════
local floatF = Instance.new("Frame")
floatF.Name="FloatIcon"; floatF.Size=UDim2.fromOffset(42,42)
floatF.BackgroundColor3=C.hdr; floatF.BackgroundTransparency=0
floatF.BorderSizePixel=0; floatF.Visible=false; floatF.ZIndex=500; floatF.Parent=gui
Instance.new("UICorner",floatF).CornerRadius=UDim.new(0,9)
local fiS = Instance.new("UIStroke",floatF); fiS.Color=C.purple; fiS.Thickness=1.3
task.spawn(function()
    local t=0; while gui.Parent do t=t+task.wait(0.05)
        local s=(math.sin(t*3)+1)/2
        fiS.Color=Color3.new(0.8+s*0.2,0.5+s*0.1,1); fiS.Thickness=1.1+s*0.5
    end
end)
local fiImg = Instance.new("ImageLabel")
fiImg.Size=UDim2.fromOffset(36,36); fiImg.Position=UDim2.fromOffset(3,3)
fiImg.BackgroundTransparency=1; fiImg.Image="rbxassetid://97269958324726"
fiImg.ScaleType=Enum.ScaleType.Crop; fiImg.ZIndex=501; fiImg.Parent=floatF
Instance.new("UICorner",fiImg).CornerRadius=UDim.new(0,7)

local function anchorFloat()
    local vp2 = Cam.ViewportSize
    if vp2.X<10 then vp2=Vector2.new(800,600) end
    floatF.Position = UDim2.fromOffset(vp2.X-52, 60)
end
anchorFloat()

local fiBtn = Instance.new("ImageButton")
fiBtn.Size=UDim2.fromScale(1,1); fiBtn.BackgroundTransparency=1
fiBtn.Image=""; fiBtn.AutoButtonColor=false; fiBtn.ZIndex=502; fiBtn.Parent=floatF
fiBtn.MouseButton1Click:Connect(function()
    floatF.Visible=false; win.Visible=true; minL.Text="-"
end)
fiBtn.MouseEnter:Connect(function()
    TweenService:Create(floatF,TweenInfo.new(0.12),{BackgroundColor3=C.card}):Play()
end)
fiBtn.MouseLeave:Connect(function()
    TweenService:Create(floatF,TweenInfo.new(0.12),{BackgroundColor3=C.hdr}):Play()
end)

minBtn.MouseButton1Click:Connect(function()
    win.Visible=false; anchorFloat(); floatF.Visible=true; minL.Text="+"
end)

closeBtn.MouseButton1Click:Connect(function()
    Phys.speedEnabled=false; Phys.flightEnabled=false
    Phys.tractionEnabled=false; Phys.freeze=false; Phys.noclip=false
    Fun.gravEnabled=false; applyGravity(false,"Normal")
    setFullbright(false)
    pcall(function() gui:Destroy() end)
end)

-- ═══════════════════════════════════════════════
-- TAB BAR
-- ═══════════════════════════════════════════════
local tabBar = Instance.new("Frame")
tabBar.Size=UDim2.new(1,0,0,TAB); tabBar.Position=UDim2.fromOffset(0,HDR)
tabBar.BackgroundColor3=C.hdr; tabBar.BackgroundTransparency=0
tabBar.BorderSizePixel=0; tabBar.ZIndex=11; tabBar.Parent=win

local tbSep = Instance.new("Frame")
tbSep.Size=UDim2.new(1,0,0,1); tbSep.Position=UDim2.new(0,0,1,-1)
tbSep.BackgroundColor3=C.sep; tbSep.BorderSizePixel=0; tbSep.ZIndex=12; tbSep.Parent=tabBar

local tbLL = Instance.new("UIListLayout")
tbLL.FillDirection=Enum.FillDirection.Horizontal
tbLL.VerticalAlignment=Enum.VerticalAlignment.Center
tbLL.SortOrder=Enum.SortOrder.LayoutOrder; tbLL.Parent=tabBar

local TABS = {
    {id="Physics",    label="Physics"},
    {id="Suspension", label="Susp."},
    {id="Visual",     label="Visual"},
    {id="Fun",        label="Fun"},
}

local tabBtns   = {}
local tabPanels = {}
local activeTab = "Physics"

local function setTab(id)
    activeTab = id
    for _, def in ipairs(TABS) do
        local btn = tabBtns[def.id]
        local pan = tabPanels[def.id]
        local on  = def.id == id
        if btn then
            TweenService:Create(btn,TweenInfo.new(0.12),{
                BackgroundColor3        = on and C.card or C.hdr,
                BackgroundTransparency  = on and 0 or 1,
            }):Play()
            local l = btn:FindFirstChild("L")
            if l then l.TextColor3 = on and C.white or C.sec end
        end
        if pan then pan.Visible = on end
    end
end

for i, def in ipairs(TABS) do
    local id  = def.id
    local btn = Instance.new("ImageButton")
    btn.Name               = "TB_"..id
    btn.Size               = UDim2.new(1/#TABS,0,1,-1)
    btn.BackgroundColor3   = C.hdr
    btn.BackgroundTransparency = 1
    btn.BorderSizePixel    = 0
    btn.Image              = ""
    btn.AutoButtonColor    = false
    btn.LayoutOrder        = i
    btn.ZIndex             = 12
    btn.Parent             = tabBar
    local l = Instance.new("TextLabel")
    l.Name="L"; l.Size=UDim2.fromScale(1,1); l.BackgroundTransparency=1
    l.Text=def.label; l.Font=Enum.Font.GothamSemibold; l.TextSize=8
    l.TextColor3=C.sec; l.ZIndex=13; l.Parent=btn
    btn.MouseButton1Click:Connect(function() setTab(id) end)
    tabBtns[id] = btn
end

-- Tab underline
local tabUnder = Instance.new("Frame")
tabUnder.Size=UDim2.fromOffset(W/#TABS-4,2)
tabUnder.BackgroundColor3=C.purple; tabUnder.BackgroundTransparency=0
tabUnder.BorderSizePixel=0; tabUnder.ZIndex=13; tabUnder.Parent=tabBar
Instance.new("UICorner",tabUnder).CornerRadius=UDim.new(1,0)

local function moveUnder(id)
    local idx=0
    for i,def in ipairs(TABS) do if def.id==id then idx=i-1 end end
    local seg = W/#TABS
    TweenService:Create(tabUnder,TweenInfo.new(0.14,Enum.EasingStyle.Quad),{
        Position=UDim2.fromOffset(seg*idx+2, TAB-2)
    }):Play()
end

local _origSetTab = setTab
setTab = function(id)
    _origSetTab(id); moveUnder(id)
end

-- ═══════════════════════════════════════════════
-- CONTENT AREA
-- ═══════════════════════════════════════════════
local BODY_Y = HDR + TAB

local function mkPanel(id)
    local s = Instance.new("ScrollingFrame")
    s.Name=("P_"..id); s.Size=UDim2.new(1,0,1,-BODY_Y)
    s.Position=UDim2.fromOffset(0,BODY_Y)
    s.BackgroundTransparency=1; s.BorderSizePixel=0
    s.ScrollBarThickness=2; s.ScrollBarImageColor3=C.purple
    s.ScrollingDirection=Enum.ScrollingDirection.Y
    s.CanvasSize=UDim2.fromOffset(0,0); s.AutomaticCanvasSize=Enum.AutomaticSize.Y
    s.Visible=false; s.ZIndex=11; s.Parent=win
    local l=Instance.new("UIListLayout")
    l.SortOrder=Enum.SortOrder.LayoutOrder; l.Padding=UDim.new(0,3); l.Parent=s
    local p=Instance.new("UIPadding")
    p.PaddingLeft=UDim.new(0,6); p.PaddingRight=UDim.new(0,6)
    p.PaddingTop=UDim.new(0,6); p.PaddingBottom=UDim.new(0,8); p.Parent=s
    tabPanels[id]=s; return s
end

for _,def in ipairs(TABS) do mkPanel(def.id) end

-- ═══════════════════════════════════════════════
-- UI COMPONENT LIBRARY
-- ═══════════════════════════════════════════════
local _o=0; local function o() _o=_o+1; return _o end

local function mkSec(par, title)
    local f=Instance.new("Frame")
    f.Size=UDim2.new(1,0,0,16); f.BackgroundTransparency=1
    f.BorderSizePixel=0; f.LayoutOrder=o(); f.ZIndex=12; f.Parent=par
    local l=Instance.new("TextLabel")
    l.Size=UDim2.fromScale(1,1); l.BackgroundTransparency=1
    l.Text=title:upper(); l.Font=Enum.Font.GothamBold; l.TextSize=7
    l.TextColor3=C.purple; l.TextXAlignment=Enum.TextXAlignment.Left
    l.ZIndex=13; l.Parent=f
    local ln=Instance.new("Frame")
    ln.Size=UDim2.new(1,0,0,1); ln.Position=UDim2.new(0,0,1,-1)
    ln.BackgroundColor3=C.sep; ln.BorderSizePixel=0; ln.ZIndex=13; ln.Parent=f
end

-- Toggle with knob
local function mkToggle(par, opts)
    local h = opts.sub and 38 or 28
    local card=Instance.new("Frame")
    card.Size=UDim2.new(1,0,0,h); card.BackgroundColor3=C.card
    card.BackgroundTransparency=0; card.BorderSizePixel=0
    card.LayoutOrder=o(); card.ZIndex=12; card.Parent=par
    Instance.new("UICorner",card).CornerRadius=UDim.new(0,5)
    local tl=Instance.new("TextLabel")
    tl.Size=UDim2.new(1,-42,0,12); tl.Position=UDim2.fromOffset(7,opts.sub and 4 or 8)
    tl.BackgroundTransparency=1; tl.Text=opts.title
    tl.Font=Enum.Font.GothamSemibold; tl.TextSize=9
    tl.TextColor3=C.pri; tl.TextXAlignment=Enum.TextXAlignment.Left
    tl.ZIndex=13; tl.Parent=card
    if opts.sub then
        local sl=Instance.new("TextLabel")
        sl.Size=UDim2.new(1,-42,0,10); sl.Position=UDim2.fromOffset(7,17)
        sl.BackgroundTransparency=1; sl.Text=opts.sub
        sl.Font=Enum.Font.Gotham; sl.TextSize=7; sl.TextColor3=C.sec
        sl.TextXAlignment=Enum.TextXAlignment.Left; sl.ZIndex=13; sl.Parent=card
    end
    local TW,TH2=26,13
    local trk=Instance.new("Frame"); trk.Size=UDim2.fromOffset(TW,TH2)
    trk.Position=UDim2.new(1,-(TW+6),0.5,-(TH2/2))
    trk.BackgroundColor3=opts.val and C.purple or C.border
    trk.BorderSizePixel=0; trk.ZIndex=13; trk.Parent=card
    Instance.new("UICorner",trk).CornerRadius=UDim.new(1,0)
    local KS=TH2-4
    local knob=Instance.new("Frame"); knob.Size=UDim2.fromOffset(KS,KS)
    knob.Position=opts.val and UDim2.fromOffset(TW-KS-2,2) or UDim2.fromOffset(2,2)
    knob.BackgroundColor3=C.white; knob.BorderSizePixel=0; knob.ZIndex=14; knob.Parent=trk
    Instance.new("UICorner",knob).CornerRadius=UDim.new(1,0)
    local state=opts.val or false
    local setV; setV=function(v)
        state=v
        TweenService:Create(trk,TweenInfo.new(0.12),{BackgroundColor3=v and C.purple or C.border}):Play()
        TweenService:Create(knob,TweenInfo.new(0.12),{Position=v and UDim2.fromOffset(TW-KS-2,2) or UDim2.fromOffset(2,2)}):Play()
        if opts.cb then opts.cb(v) end
    end
    local hit=Instance.new("ImageButton"); hit.Size=UDim2.fromScale(1,1)
    hit.BackgroundTransparency=1; hit.Image=""; hit.AutoButtonColor=false
    hit.ZIndex=15; hit.Parent=card
    hit.MouseButton1Click:Connect(function() setV(not state) end)
    hit.MouseEnter:Connect(function() TweenService:Create(card,TweenInfo.new(0.10),{BackgroundColor3=C.cardH}):Play() end)
    hit.MouseLeave:Connect(function() TweenService:Create(card,TweenInfo.new(0.10),{BackgroundColor3=C.card}):Play() end)
    return card, setV
end

-- Slider
local function mkSlider(par, opts)
    local step=opts.step or 1
    local card=Instance.new("Frame")
    card.Size=UDim2.new(1,0,0,40); card.BackgroundColor3=C.card
    card.BackgroundTransparency=0; card.BorderSizePixel=0
    card.LayoutOrder=o(); card.ZIndex=12; card.Parent=par
    Instance.new("UICorner",card).CornerRadius=UDim.new(0,5)
    local tl=Instance.new("TextLabel"); tl.Size=UDim2.new(0.6,0,0,12)
    tl.Position=UDim2.fromOffset(7,5); tl.BackgroundTransparency=1; tl.Text=opts.title
    tl.Font=Enum.Font.GothamSemibold; tl.TextSize=9; tl.TextColor3=C.pri
    tl.TextXAlignment=Enum.TextXAlignment.Left; tl.ZIndex=13; tl.Parent=card
    local rng=math.max(0.001,opts.max-opts.min)
    local pct=(opts.def-opts.min)/rng
    local defStr=step<1 and string.format("%.1f",opts.def) or tostring(math.floor(opts.def))
    local vl=Instance.new("TextLabel"); vl.Size=UDim2.new(0.4,-7,0,12)
    vl.Position=UDim2.new(0.6,0,0,5); vl.BackgroundTransparency=1
    vl.Text=defStr..(opts.suf or ""); vl.Font=Enum.Font.GothamBold; vl.TextSize=9
    vl.TextColor3=C.pri; vl.TextXAlignment=Enum.TextXAlignment.Right; vl.ZIndex=13; vl.Parent=card
    local trk=Instance.new("Frame"); trk.Size=UDim2.new(1,-14,0,4)
    trk.Position=UDim2.fromOffset(7,23); trk.BackgroundColor3=Color3.fromRGB(30,30,40)
    trk.BorderSizePixel=0; trk.ZIndex=13; trk.Parent=card
    Instance.new("UICorner",trk).CornerRadius=UDim.new(1,0)
    local fill=Instance.new("Frame"); fill.Size=UDim2.new(pct,0,1,0)
    fill.BackgroundColor3=C.purple; fill.BorderSizePixel=0; fill.ZIndex=14; fill.Parent=trk
    Instance.new("UICorner",fill).CornerRadius=UDim.new(1,0)
    local KD=10; local knob=Instance.new("Frame"); knob.Size=UDim2.fromOffset(KD,KD)
    knob.Position=UDim2.new(pct,-KD/2,0.5,-KD/2); knob.BackgroundColor3=C.white
    knob.BorderSizePixel=0; knob.ZIndex=15; knob.Parent=trk
    Instance.new("UICorner",knob).CornerRadius=UDim.new(1,0)
    local value=opts.def; local isDrag=false
    local function updX(ax)
        local ta=trk.AbsolutePosition; local ts=trk.AbsoluteSize
        if ts.X<1 then return end
        local rel=math.clamp((ax-ta.X)/ts.X,0,1)
        value=math.floor((opts.min+rel*rng)/step+0.5)*step
        value=math.clamp(value,opts.min,opts.max)
        local p=(value-opts.min)/rng
        fill.Size=UDim2.new(p,0,1,0); knob.Position=UDim2.new(p,-KD/2,0.5,-KD/2)
        local disp=step<1 and string.format("%.1f",value) or tostring(math.floor(value))
        vl.Text=disp..(opts.suf or "")
        if opts.cb then opts.cb(value) end
    end
    local hit=Instance.new("ImageButton"); hit.Size=UDim2.fromScale(1,1)
    hit.BackgroundTransparency=1; hit.Image=""; hit.AutoButtonColor=false; hit.ZIndex=16; hit.Parent=trk
    hit.MouseButton1Down:Connect(function(x) isDrag=true; updX(x) end)
    hit.TouchLongPress:Connect(function() isDrag=true end)
    hit.TouchPan:Connect(function(_,pos) if isDrag and pos[1] then updX(pos[1].X) end end)
    UIS.InputChanged:Connect(function(inp)
        if not isDrag then return end
        if inp.UserInputType==Enum.UserInputType.MouseMovement
        or inp.UserInputType==Enum.UserInputType.Touch then updX(inp.Position.X) end
    end)
    UIS.InputEnded:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton1
        or inp.UserInputType==Enum.UserInputType.Touch then isDrag=false end
    end)
    return card
end

-- Button
local function mkBtn(par, opts)
    local h=opts.sub and 38 or 28
    local btn=Instance.new("ImageButton"); btn.Size=UDim2.new(1,0,0,h)
    btn.BackgroundColor3=C.card; btn.BackgroundTransparency=0
    btn.BorderSizePixel=0; btn.Image=""; btn.AutoButtonColor=false
    btn.LayoutOrder=o(); btn.ZIndex=12; btn.Parent=par
    Instance.new("UICorner",btn).CornerRadius=UDim.new(0,5)
    local bS=Instance.new("UIStroke",btn); bS.Color=C.border; bS.Thickness=0.8
    local tl=Instance.new("TextLabel"); tl.Size=UDim2.new(1,-10,0,13)
    tl.Position=UDim2.fromOffset(7,opts.sub and 4 or 7)
    tl.BackgroundTransparency=1; tl.Text=opts.title
    tl.Font=Enum.Font.GothamBold; tl.TextSize=9; tl.TextColor3=C.pri
    tl.TextXAlignment=Enum.TextXAlignment.Left; tl.ZIndex=13; tl.Parent=btn
    if opts.sub then
        local sl=Instance.new("TextLabel"); sl.Size=UDim2.new(1,-10,0,10)
        sl.Position=UDim2.fromOffset(7,20); sl.BackgroundTransparency=1; sl.Text=opts.sub
        sl.Font=Enum.Font.Gotham; sl.TextSize=7; sl.TextColor3=C.sec
        sl.TextXAlignment=Enum.TextXAlignment.Left; sl.ZIndex=13; sl.Parent=btn
    end
    btn.MouseButton1Click:Connect(function()
        TweenService:Create(btn,TweenInfo.new(0.08),{BackgroundColor3=C.cardH}):Play()
        task.delay(0.14,function() TweenService:Create(btn,TweenInfo.new(0.10),{BackgroundColor3=C.card}):Play() end)
        if opts.cb then opts.cb() end
    end)
    btn.MouseEnter:Connect(function() TweenService:Create(btn,TweenInfo.new(0.10),{BackgroundColor3=C.cardH}):Play() end)
    btn.MouseLeave:Connect(function() TweenService:Create(btn,TweenInfo.new(0.10),{BackgroundColor3=C.card}):Play() end)
    return btn
end

-- Dropdown (compact)
local function mkDrop(par, opts)
    local IH=22; local listH=#opts.opts*IH+4
    local card=Instance.new("Frame"); card.Size=UDim2.new(1,0,0,30)
    card.BackgroundColor3=C.card; card.BackgroundTransparency=0
    card.BorderSizePixel=0; card.LayoutOrder=o(); card.ClipsDescendants=false
    card.ZIndex=20; card.Parent=par
    Instance.new("UICorner",card).CornerRadius=UDim.new(0,5)
    local tl=Instance.new("TextLabel"); tl.Size=UDim2.new(0.48,0,0,12)
    tl.Position=UDim2.fromOffset(7,9); tl.BackgroundTransparency=1; tl.Text=opts.title
    tl.Font=Enum.Font.GothamSemibold; tl.TextSize=9; tl.TextColor3=C.pri
    tl.TextXAlignment=Enum.TextXAlignment.Left; tl.ZIndex=21; tl.Parent=card
    local sel=Instance.new("ImageButton"); sel.Size=UDim2.new(0.50,-4,0,22)
    sel.Position=UDim2.new(0.50,2,0.5,-11); sel.BackgroundColor3=Color3.fromRGB(16,16,22)
    sel.BackgroundTransparency=0; sel.BorderSizePixel=0; sel.Image=""
    sel.AutoButtonColor=false; sel.ZIndex=21; sel.Parent=card
    Instance.new("UICorner",sel).CornerRadius=UDim.new(0,4)
    local selL=Instance.new("TextLabel"); selL.Size=UDim2.new(1,-14,1,0)
    selL.Position=UDim2.fromOffset(5,0); selL.BackgroundTransparency=1
    selL.Text=opts.def or opts.opts[1]; selL.Font=Enum.Font.GothamSemibold; selL.TextSize=8
    selL.TextColor3=C.pri; selL.TextXAlignment=Enum.TextXAlignment.Left; selL.ZIndex=22; selL.Parent=sel
    local chv=Instance.new("TextLabel"); chv.Size=UDim2.fromOffset(10,22)
    chv.Position=UDim2.new(1,-12,0,0); chv.BackgroundTransparency=1; chv.Text="v"
    chv.Font=Enum.Font.GothamBold; chv.TextSize=7; chv.TextColor3=C.sec; chv.ZIndex=22; chv.Parent=sel
    local dList=Instance.new("Frame"); dList.Size=UDim2.fromOffset(10,listH)
    dList.Position=UDim2.new(sel.Position.X.Scale,sel.Position.X.Offset,1,2)
    dList.BackgroundColor3=Color3.fromRGB(14,14,20); dList.BackgroundTransparency=0
    dList.BorderSizePixel=0; dList.Visible=false; dList.ZIndex=30; dList.Parent=card
    Instance.new("UICorner",dList).CornerRadius=UDim.new(0,5)
    local dlS=Instance.new("UIStroke",dList); dlS.Color=C.border; dlS.Thickness=0.8
    local dlL=Instance.new("UIListLayout"); dlL.SortOrder=Enum.SortOrder.LayoutOrder; dlL.Parent=dList
    local dlP=Instance.new("UIPadding"); dlP.PaddingTop=UDim.new(0,2); dlP.PaddingBottom=UDim.new(0,2)
    dlP.PaddingLeft=UDim.new(0,2); dlP.PaddingRight=UDim.new(0,2); dlP.Parent=dList
    local isOpen=false; local selected=opts.def or opts.opts[1]
    local function closeDD() isOpen=false; dList.Visible=false end
    local function openDD()
        dList.Size=UDim2.fromOffset(math.max(sel.AbsoluteSize.X,80),listH)
        isOpen=true; dList.Visible=true
    end
    for i,opt in ipairs(opts.opts) do
        local o2=opt; local itm=Instance.new("ImageButton")
        itm.Size=UDim2.new(1,0,0,IH); itm.BackgroundColor3=Color3.fromRGB(14,14,20)
        itm.BackgroundTransparency=0; itm.BorderSizePixel=0; itm.Image=""; itm.AutoButtonColor=false
        itm.LayoutOrder=i; itm.ZIndex=31; itm.Parent=dList
        Instance.new("UICorner",itm).CornerRadius=UDim.new(0,3)
        local il=Instance.new("TextLabel"); il.Size=UDim2.fromScale(1,1)
        il.BackgroundTransparency=1; il.Text=o2; il.Font=Enum.Font.GothamSemibold; il.TextSize=8
        il.TextColor3=C.pri; il.TextXAlignment=Enum.TextXAlignment.Left; il.ZIndex=32; il.Parent=itm
        local ip=Instance.new("UIPadding"); ip.PaddingLeft=UDim.new(0,6); ip.Parent=il
        itm.MouseEnter:Connect(function() itm.BackgroundColor3=C.cardH end)
        itm.MouseLeave:Connect(function() itm.BackgroundColor3=Color3.fromRGB(14,14,20) end)
        itm.MouseButton1Click:Connect(function()
            selected=o2; selL.Text=o2; closeDD()
            if opts.cb then opts.cb(o2) end
        end)
    end
    sel.MouseButton1Click:Connect(function()
        if isOpen then closeDD() else openDD() end
    end)
    return card, function() return selected end
end

local function mkDiv(par)
    local f=Instance.new("Frame"); f.Size=UDim2.new(1,0,0,1)
    f.BackgroundColor3=C.sep; f.BackgroundTransparency=0.3
    f.BorderSizePixel=0; f.LayoutOrder=o(); f.ZIndex=12; f.Parent=par
end

-- ═══════════════════════════════════════════════
-- PHYSICS TAB
-- ═══════════════════════════════════════════════
local pp = tabPanels["Physics"]

mkSec(pp, "Anti-Bounce")
mkToggle(pp, {title="Anti-Bounce", sub="Smooths suspension bounce + impact", val=true, cb=function(v) Phys.antiBounce=v end})
mkSlider(pp, {title="Vel. Dampening", min=0, max=100, def=92, suf="%", step=1, cb=function(v) Phys.velDamp=v/100 end})
mkSlider(pp, {title="Ang. Dampening", min=0, max=100, def=85, suf="%", step=1, cb=function(v) Phys.angDamp=v/100 end})
mkSlider(pp, {title="Impact Sensitivity", min=5, max=50, def=15, suf="", step=1, cb=function(v) Phys.impactThresh=v end})

mkSec(pp, "Speed Control")
mkToggle(pp, {title="Speed Override", sub="W = accelerate  S = brake", val=false, cb=function(v) Phys.speedEnabled=v end})
mkSlider(pp, {title="Accel Rate", min=10, max=500, def=150, suf="", step=5, cb=function(v) Phys.accelRate=v/100 end})
mkSlider(pp, {title="Brake Rate",  min=10, max=200, def=90,  suf="%", step=1, cb=function(v) Phys.brakeRate=v/100 end})
mkSlider(pp, {title="Max Speed",   min=50, max=400, def=250, suf="", step=5, cb=function(v) Phys.maxGroundSpeed=v end})

mkSec(pp, "Flight")
mkToggle(pp, {title="Flight Mode", sub="WASD move  E=up  Q=down", val=false, cb=function(v) Phys.flightEnabled=v end})
mkSlider(pp, {title="Flight Speed", min=10, max=800, def=100, suf="", step=10, cb=function(v) Phys.flightSpeed=v/100 end})

mkSec(pp, "Traction")
mkToggle(pp, {title="Traction Control", sub="Reduce side-slip on corners", val=false, cb=function(v) Phys.tractionEnabled=v end})
mkSlider(pp, {title="Grip", min=10, max=150, def=100, suf="%", step=1, cb=function(v) Phys.tractionGrip=v/100 end})

mkSec(pp, "Collision")
mkToggle(pp, {title="Freeze Vehicle", sub="Lock all parts in place", val=false, cb=function(v) Phys.freeze=v end})
mkToggle(pp, {title="Noclip Vehicle", sub="Vehicle passes through objects", val=false, cb=function(v) Phys.noclip=v end})

mkDiv(pp)
mkBtn(pp, {title="Refresh / Reclaim Ownership", sub="Re-scan vehicle and claim network owner", cb=function()
    if not V.vehicle then showNotif("No Vehicle","Sit in a vehicle first.",3); return end
    cacheVehicle(V.vehicle)
    showNotif("Refreshed", "Network ownership claimed  |  Springs: "..#V.springsCache, 3)
end})

-- ═══════════════════════════════════════════════
-- SUSPENSION TAB
-- ═══════════════════════════════════════════════
local sp2 = tabPanels["Suspension"]

mkSec(sp2, "Global Settings")
mkSlider(sp2, {title="Stiffness",  min=0,   max=100, def=40,  suf="", step=1, cb=function(v) Sus.stiffness=v*100; Sus.frontStiff=v*100; Sus.rearStiff=v*100 end})
mkSlider(sp2, {title="Front Stiff",min=100, max=20000,def=4000,suf="",step=100,cb=function(v) Sus.frontStiff=v end})
mkSlider(sp2, {title="Rear Stiff", min=100, max=20000,def=4000,suf="",step=100,cb=function(v) Sus.rearStiff=v end})
mkSlider(sp2, {title="Damping",    min=0,   max=100, def=20,  suf="", step=1, cb=function(v) Sus.damping=v*20 end})
mkSlider(sp2, {title="Ride Height", min=-30, max=30, def=0,   suf="", step=1, cb=function(v) Sus.height=v/10 end})

mkSec(sp2, "Quick Presets")
local function applyPreset(name, fs, rs, d, h)
    Sus.frontStiff=fs; Sus.rearStiff=rs; Sus.damping=d; Sus.height=h
    showNotif("Preset: "..name, "Front:"..fs.."  Rear:"..rs.."  Damp:"..d, 3)
end

mkBtn(sp2, {title="Race",     sub="Hard + low — track use",         cb=function() applyPreset("Race",     8000,8000,1500,-1.5) end})
mkBtn(sp2, {title="Drift",    sub="Soft rear for rotation",          cb=function() applyPreset("Drift",    6000,3000,500,0) end})
mkBtn(sp2, {title="Off-Road", sub="Soft + high — rough terrain",     cb=function() applyPreset("Off-Road", 2000,2000,800,1.5) end})
mkBtn(sp2, {title="Comfort",  sub="Smooth ride for daily use",       cb=function() applyPreset("Comfort",  1500,1500,1800,0.5) end})
mkBtn(sp2, {title="Stance",   sub="Extremely low and stiff",         cb=function() applyPreset("Stance",   12000,12000,2000,-2) end})
mkBtn(sp2, {title="Rally",    sub="High + medium — mixed terrain",   cb=function() applyPreset("Rally",    3000,3000,800,2) end})
mkBtn(sp2, {title="Balanced", sub="Stock-like — neutral all-round",  cb=function() applyPreset("Balanced", 5000,5000,1200,0) end})

mkDiv(sp2)
mkBtn(sp2, {title="Reset All Springs", sub="Restore original SpringConstraint values", cb=function()
    resetAllSprings()
end})

mkBtn(sp2, {title="Rescan Springs", sub="Re-detect all SpringConstraints in vehicle", cb=function()
    if not V.vehicle then showNotif("No Vehicle","Sit in a vehicle first.",3); return end
    cacheVehicle(V.vehicle)
    showNotif("Rescanned", "#Springs found: "..#V.springsCache, 3)
end})

-- ═══════════════════════════════════════════════
-- VISUAL TAB
-- ═══════════════════════════════════════════════
local vp2 = tabPanels["Visual"]

mkSec(vp2, "Quick Color Presets")
local COLORS = {
    {"Red",          Color3.fromRGB(200, 25,  25)},
    {"Blue",         Color3.fromRGB(25,  80,  220)},
    {"Green",        Color3.fromRGB(25,  200, 50)},
    {"Yellow",       Color3.fromRGB(240, 220, 20)},
    {"Orange",       Color3.fromRGB(255, 128, 0)},
    {"Purple",       Color3.fromRGB(160, 40,  200)},
    {"Pink",         Color3.fromRGB(240, 100, 180)},
    {"White",        Color3.fromRGB(240, 240, 240)},
    {"Matte Black",  Color3.fromRGB(22,  22,  22)},
    {"Chrome Silver",Color3.fromRGB(190, 190, 190)},
    {"Gold",         Color3.fromRGB(255, 215, 0)},
    {"Carbon Black", Color3.fromRGB(30,  30,  35)},
}

for _, col in ipairs(COLORS) do
    local name  = col[1]
    local color = col[2]
    mkBtn(vp2, {title=name, cb=function() paintVehicle(color) end})
end

mkSec(vp2, "Custom Color (R,G,B 0-255)")

-- Simple R/G/B sliders for custom color
local customR, customG, customB = 200, 0, 0
mkSlider(vp2, {title="Red",   min=0,max=255,def=200,suf="",step=1, cb=function(v) customR=v end})
mkSlider(vp2, {title="Green", min=0,max=255,def=0,  suf="",step=1, cb=function(v) customG=v end})
mkSlider(vp2, {title="Blue",  min=0,max=255,def=0,  suf="",step=1, cb=function(v) customB=v end})

mkBtn(vp2, {title="Apply Custom Color", cb=function()
    paintVehicle(Color3.fromRGB(customR, customG, customB))
end})

-- ═══════════════════════════════════════════════
-- FUN TAB
-- ═══════════════════════════════════════════════
local fp2 = tabPanels["Fun"]

mkSec(fp2, "Gravity")

local gravModeSelected = "Normal"
mkDrop(fp2, {title="Gravity Mode",
    opts={"Normal","Moon","Heavy","Zero","Reverse"},
    def="Normal",
    cb=function(v)
        gravModeSelected = v
        if Fun.gravEnabled then
            applyGravity(true, v)
            showNotif("Gravity", "Mode changed to: "..v, 2)
        end
    end
})

mkToggle(fp2, {title="Gravity Enabled", sub="Apply selected gravity mode to vehicle", val=false, cb=function(v)
    Fun.gravEnabled = v
    applyGravity(v, gravModeSelected)
    showNotif("Gravity "..(v and "ON" or "OFF"), "Mode: "..gravModeSelected, 2)
end})

mkSec(fp2, "Lighting")

mkToggle(fp2, {title="Fullbright", sub="Max ambient lighting client-side", val=false, cb=function(v)
    Fun.fullbright=v; setFullbright(v)
    showNotif("Fullbright "..(v and "ON" or "OFF"), "Client-side lighting override.", 2)
end})

mkSec(fp2, "Utility")

mkBtn(fp2, {title="Eject from Vehicle", sub="Force-exit your current vehicle seat", cb=function()
    local c = LP.Character
    if not c then showNotif("Error","No character.",3); return end
    local h = c:FindFirstChildOfClass("Humanoid")
    if h then
        pcall(function() h.Sit = false end)
        showNotif("Ejected","Exited vehicle seat.",2)
    end
end})

mkBtn(fp2, {title="Reset Vehicle Position", sub="Move vehicle to your current position", cb=function()
    if not V.vehicle then showNotif("No Vehicle","Sit in a vehicle first.",3); return end
    local c = LP.Character
    local hrp = c and c:FindFirstChild("HumanoidRootPart")
    if not hrp then showNotif("Error","No HumanoidRootPart.",3); return end
    local pp = V.vehicle.PrimaryPart
    if pp then
        pcall(function()
            V.vehicle:SetPrimaryPartCFrame(
                CFrame.new(hrp.Position + Vector3.new(0,3,10))
            )
        end)
        showNotif("Repositioned","Vehicle moved near you.",3)
    end
end})

mkBtn(fp2, {title="Stabilize Vehicle", sub="Stop all spinning and velocity", cb=function()
    if not V.seat then showNotif("No Vehicle","Sit in a vehicle first.",3); return end
    for _, p in ipairs(V.partsCache) do
        pcall(function()
            if not p.Anchored then
                p.AssemblyLinearVelocity  = Vector3.zero
                p.AssemblyAngularVelocity = Vector3.zero
            end
        end)
    end
    showNotif("Stabilized","All vehicle velocity zeroed.",2)
end})

mkBtn(fp2, {title="Flip Vehicle Upright", sub="Reset vehicle to upright orientation", cb=function()
    if not V.vehicle then showNotif("No Vehicle","Sit in a vehicle first.",3); return end
    local pp = V.vehicle.PrimaryPart
    if not pp then showNotif("Error","No PrimaryPart on vehicle.",3); return end
    pcall(function()
        local pos = pp.Position
        V.vehicle:SetPrimaryPartCFrame(
            CFrame.new(pos + Vector3.new(0,2,0))
        )
        -- Zero angular velocity
        for _, p in ipairs(V.partsCache) do
            pcall(function()
                p.AssemblyAngularVelocity = Vector3.zero
            end)
        end
    end)
    showNotif("Flipped Upright","Vehicle orientation reset.",3)
end})

-- ═══════════════════════════════════════════════
-- INIT
-- ═══════════════════════════════════════════════
setTab("Physics")
moveUnder("Physics")

showNotif("Anonymous9x Vehicle FE", "v1.0  |  Sit in a vehicle to begin", 4)
