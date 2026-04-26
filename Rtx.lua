--[[
╔══════════════════════════════════════════════════════════════════╗
║                                                                  ║
║   Anonymous9x Full RTX  —  v1.0                                  ║
║   Universal Graphics Shader  |  All Executors                    ║
║   Delta Mobile / iOS / iPad / PC                                 ║
║                                                                  ║
║   SHADER ENGINE (learned from pshade source + upgraded):         ║
║   · Backup ALL original Lighting values on load                  ║
║   · Clone lighting effects to keep originals untouched           ║
║   · PreRender loop applies shader settings every frame           ║
║   · ChildRemoved guard restores deleted effects instantly         ║
║   · 6 Time-of-Day presets + Default restore                      ║
║   · Full manual adjustment: Bloom, Blur, DOF, ColorCorrection,   ║
║     Atmosphere, SunRays, Fog, Exposure, Shadows                  ║
║   · Restore everything on script re-execute or GUI close          ║
║                                                                  ║
╚══════════════════════════════════════════════════════════════════╝
]]

-- ═══════════════════════════════════════════
-- GUARD  (prevent double load)
-- ═══════════════════════════════════════════
if _G._A9RTXLoaded then
    _G._A9RTXLoaded = false
    if _G._A9RTXStop then _G._A9RTXStop() end
    return
end
_G._A9RTXLoaded = true

-- ═══════════════════════════════════════════
-- SERVICES
-- ═══════════════════════════════════════════
local Players    = game:GetService("Players")
local RS         = game:GetService("RunService")
local TS         = game:GetService("TweenService")
local UIS        = game:GetService("UserInputService")
local LP         = Players.LocalPlayer
local Lighting   = game:GetService("Lighting")
local Camera     = workspace.CurrentCamera

-- Wait for game loaded
if not game:IsLoaded() then game.Loaded:Wait() end

-- ═══════════════════════════════════════════
-- EFFECT REFERENCES (create / clone)
-- ═══════════════════════════════════════════
local function getOrCreate(class, parent)
    local existing = parent:FindFirstChildOfClass(class)
    if existing then
        local c = existing:Clone()
        c.Parent = parent
        return c, existing
    else
        local c = Instance.new(class)
        c.Parent = parent
        return c, nil
    end
end

local bloom, blur, dof, colorcor, sunrays, atmosphere, sky
local bloomOrig, blurOrig, dofOrig, colorOrig, sunrayOrig

bloom,    bloomOrig   = getOrCreate("BloomEffect",         Lighting)
blur,     blurOrig    = getOrCreate("BlurEffect",          Lighting)
dof,      dofOrig     = getOrCreate("DepthOfFieldEffect",  Lighting)
colorcor, colorOrig   = getOrCreate("ColorCorrectionEffect", Lighting)
sunrays,  sunrayOrig  = getOrCreate("SunRaysEffect",       Lighting)

pcall(function() if bloomOrig   then bloomOrig.Enabled  = false end end)
pcall(function() if blurOrig    then blurOrig.Enabled   = false end end)
pcall(function() if dofOrig     then dofOrig.Enabled    = false end end)
pcall(function() if colorOrig   then colorOrig.Enabled  = false end end)
pcall(function() if sunrayOrig  then sunrayOrig.Enabled = false end end)

-- CRITICAL: disable and zero cloned effects immediately on load.
-- Without this the cloned instances inherit original values (DOF intensity,
-- blur size etc) and cause immediate blur when script executes.
pcall(function()
    bloom.Enabled    = false; bloom.Intensity = 0; bloom.Size = 0
    blur.Enabled     = false; blur.Size = 0
    dof.Enabled      = false; dof.FarIntensity=0; dof.NearIntensity=0
    colorcor.Enabled = false; colorcor.Brightness=0; colorcor.Contrast=0; colorcor.Saturation=0
    sunrays.Enabled  = false; sunrays.Intensity=0
end)

pcall(function()
    atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
    if not atmosphere then
        atmosphere = Instance.new("Atmosphere")
        atmosphere.Parent = Lighting
    end
end)
pcall(function()
    sky = Lighting:FindFirstChildOfClass("Sky")
end)

-- ═══════════════════════════════════════════
-- BACKUP ORIGINAL LIGHTING VALUES
-- ═══════════════════════════════════════════
local backup = {
    ClockTime              = Lighting.ClockTime,
    Ambient                = Lighting.Ambient,
    Brightness             = Lighting.Brightness,
    ColorShift_Bottom      = Lighting.ColorShift_Bottom,
    ColorShift_Top         = Lighting.ColorShift_Top,
    EnvironmentDiffuseScale= Lighting.EnvironmentDiffuseScale,
    EnvironmentSpecularScale=Lighting.EnvironmentSpecularScale,
    GlobalShadows          = Lighting.GlobalShadows,
    OutdoorAmbient         = Lighting.OutdoorAmbient,
    ExposureCompensation   = Lighting.ExposureCompensation,
    FogEnd                 = Lighting.FogEnd,
    FogStart               = Lighting.FogStart,
    FogColor               = Lighting.FogColor,
    GeographicLatitude     = Lighting.GeographicLatitude,
    ShadowSoftness         = Lighting.ShadowSoftness,
}

local backupEffects = {
    bloom   = {Intensity=bloom.Intensity,   Size=bloom.Size,           Threshold=bloom.Threshold,  Enabled=bloom.Enabled},
    blur    = {Size=blur.Size,              Enabled=blur.Enabled},
    dof     = {FarIntensity=dof.FarIntensity, FocusDistance=dof.FocusDistance,
               InFocusRadius=dof.InFocusRadius, NearIntensity=dof.NearIntensity, Enabled=dof.Enabled},
    colorcor= {Brightness=colorcor.Brightness, Contrast=colorcor.Contrast,
               Saturation=colorcor.Saturation, TintColor=colorcor.TintColor, Enabled=colorcor.Enabled},
    sunrays = {Intensity=sunrays.Intensity, Spread=sunrays.Spread, Enabled=sunrays.Enabled},
}

local backupAtmo = atmosphere and {
    Density = atmosphere.Density,
    Offset  = atmosphere.Offset,
    Color   = atmosphere.Color,
    Decay   = atmosphere.Decay,
    Glare   = atmosphere.Glare,
    Haze    = atmosphere.Haze,
} or {}

-- ═══════════════════════════════════════════
-- ACTIVE SETTINGS TABLE  (what PreRender applies)
-- ═══════════════════════════════════════════
local active = {
    -- Lighting
    ClockTime              = backup.ClockTime,
    Ambient                = backup.Ambient,
    Brightness             = backup.Brightness,
    OutdoorAmbient         = backup.OutdoorAmbient,
    ExposureCompensation   = backup.ExposureCompensation,
    GlobalShadows          = backup.GlobalShadows,
    FogEnd                 = backup.FogEnd,

    -- Bloom
    bloomOn     = false,
    bloomInt    = 0.9,
    bloomSize   = 24,
    bloomThresh = 0.95,

    -- Blur
    blurOn   = false,
    blurSize = 0,

    -- DOF
    dofOn      = false,
    dofFar     = 0,
    dofFocus   = 50,
    dofRadius  = 15,
    dofNear    = 0,

    -- ColorCorrection
    ccOn    = true,
    ccBrt   = 0,
    ccCon   = 0,
    ccSat   = 0,

    -- SunRays
    srOn     = false,
    srInt    = 0.25,
    srSpread = 0.5,

    -- Atmosphere
    atDensity = atmosphere and atmosphere.Density or 0,
    atOffset  = atmosphere and atmosphere.Offset  or 0,
    atGlare   = atmosphere and atmosphere.Glare   or 0,
    atHaze    = atmosphere and atmosphere.Haze    or 0,

    shaderOn = false,
}

-- ═══════════════════════════════════════════
-- SHADER PRESETS  (time-of-day)
-- ═══════════════════════════════════════════
local PRESETS = {
    Default = {
        ClockTime=backup.ClockTime, Ambient=backup.Ambient,
        Brightness=backup.Brightness, OutdoorAmbient=backup.OutdoorAmbient,
        ExposureCompensation=backup.ExposureCompensation, GlobalShadows=backup.GlobalShadows,
        FogEnd=backup.FogEnd,
        bloomOn=false, bloomInt=0.9,  bloomSize=24, bloomThresh=0.95,
        blurOn=false,  blurSize=0,
        dofOn=false,   dofFar=0, dofFocus=50, dofRadius=15, dofNear=0,
        ccOn=false, ccBrt=0, ccCon=0, ccSat=0,
        srOn=false, srInt=0.25, srSpread=0.5,
        atDensity=backupAtmo.Density or 0, atOffset=backupAtmo.Offset or 0,
        atGlare=backupAtmo.Glare or 0, atHaze=backupAtmo.Haze or 0,
    },
    Morning = {
        ClockTime=6.5,  Ambient=Color3.fromRGB(90,70,50),
        Brightness=2.4, OutdoorAmbient=Color3.fromRGB(200,165,100),
        ExposureCompensation=0.3, GlobalShadows=true, FogEnd=1500000,
        bloomOn=true, bloomInt=1.2, bloomSize=28, bloomThresh=0.85,
        blurOn=false, blurSize=0,
        dofOn=false, dofFar=0, dofFocus=60, dofRadius=18, dofNear=0,
        ccOn=true, ccBrt=0.08, ccCon=0.05, ccSat=0.15,
        srOn=true, srInt=0.40, srSpread=0.60,
        atDensity=0.28, atOffset=0.06, atGlare=2.0, atHaze=1.8,
    },
    Midday = {
        ClockTime=12,   Ambient=Color3.fromRGB(130,130,130),
        Brightness=3.8, OutdoorAmbient=Color3.fromRGB(180,180,180),
        ExposureCompensation=0.0, GlobalShadows=true, FogEnd=1500000,
        bloomOn=true, bloomInt=0.8, bloomSize=22, bloomThresh=1.0,
        blurOn=false, blurSize=0,
        dofOn=false, dofFar=0.05, dofFocus=80, dofRadius=25, dofNear=0,
        ccOn=true, ccBrt=0.04, ccCon=0.08, ccSat=0.08,
        srOn=true, srInt=0.18, srSpread=0.45,
        atDensity=0.20, atOffset=0.04, atGlare=1.0, atHaze=0.8,
    },
    Afternoon = {
        ClockTime=15.5, Ambient=Color3.fromRGB(110,80,55),
        Brightness=2.6, OutdoorAmbient=Color3.fromRGB(210,160,90),
        ExposureCompensation=0.1, GlobalShadows=true, FogEnd=1500000,
        bloomOn=true, bloomInt=1.0, bloomSize=26, bloomThresh=0.90,
        blurOn=false, blurSize=0,
        dofOn=false, dofFar=0, dofFocus=55, dofRadius=18, dofNear=0,
        ccOn=true, ccBrt=0.05, ccCon=0.06, ccSat=0.18,
        srOn=true, srInt=0.38, srSpread=0.55,
        atDensity=0.30, atOffset=0.05, atGlare=2.5, atHaze=2.0,
    },
    Evening = {
        ClockTime=18,   Ambient=Color3.fromRGB(80,50,30),
        Brightness=1.6, OutdoorAmbient=Color3.fromRGB(180,100,50),
        ExposureCompensation=0.2, GlobalShadows=true, FogEnd=1500000,
        bloomOn=true, bloomInt=1.5, bloomSize=32, bloomThresh=0.80,
        blurOn=false, blurSize=0,
        dofOn=false, dofFar=0.1, dofFocus=45, dofRadius=14, dofNear=0,
        ccOn=true, ccBrt=0.02, ccCon=0.05, ccSat=0.22,
        srOn=true, srInt=0.55, srSpread=0.70,
        atDensity=0.40, atOffset=0.08, atGlare=4.0, atHaze=3.5,
    },
    Night = {
        ClockTime=22,   Ambient=Color3.fromRGB(15,20,40),
        Brightness=0.35,OutdoorAmbient=Color3.fromRGB(20,25,55),
        ExposureCompensation=0.6, GlobalShadows=true, FogEnd=1500000,
        bloomOn=true, bloomInt=1.8, bloomSize=36, bloomThresh=0.70,
        blurOn=false, blurSize=0,
        dofOn=false, dofFar=0.15, dofFocus=35, dofRadius=12, dofNear=0,
        ccOn=true, ccBrt=-0.08, ccCon=0.12, ccSat=-0.10,
        srOn=false, srInt=0.05, srSpread=0.30,
        atDensity=0.55, atOffset=0.10, atGlare=0.5, atHaze=4.5,
    },
    Midnight = {
        ClockTime=0,    Ambient=Color3.fromRGB(5,7,18),
        Brightness=0.12,OutdoorAmbient=Color3.fromRGB(8,10,28),
        ExposureCompensation=0.8, GlobalShadows=true, FogEnd=1500000,
        bloomOn=true, bloomInt=2.2, bloomSize=40, bloomThresh=0.60,
        blurOn=false, blurSize=0,
        dofOn=false, dofFar=0.20, dofFocus=25, dofRadius=10, dofNear=0,
        ccOn=true, ccBrt=-0.14, ccCon=0.16, ccSat=-0.18,
        srOn=false, srInt=0, srSpread=0.20,
        atDensity=0.70, atOffset=0.12, atGlare=0.2, atHaze=6.0,
    },
}

local function applyPreset(p)
    for k, v in pairs(p) do
        active[k] = v
    end
    active.shaderOn = true
end

-- ═══════════════════════════════════════════
-- PRERENDER LOOP
-- ═══════════════════════════════════════════
local shaderConn

local function startLoop()
    if shaderConn then shaderConn:Disconnect() end
    shaderConn = RS.PreRender:Connect(function()
        if not active.shaderOn then return end
        pcall(function()
            Lighting.ClockTime               = active.ClockTime
            Lighting.Ambient                 = active.Ambient
            Lighting.Brightness              = active.Brightness
            Lighting.OutdoorAmbient          = active.OutdoorAmbient
            Lighting.ExposureCompensation    = active.ExposureCompensation
            Lighting.GlobalShadows           = active.GlobalShadows
            Lighting.FogEnd                  = active.FogEnd

            bloom.Enabled   = active.bloomOn
            bloom.Intensity = active.bloomInt
            bloom.Size      = active.bloomSize
            bloom.Threshold = active.bloomThresh

            blur.Enabled = active.blurOn
            blur.Size    = active.blurSize

            dof.Enabled       = active.dofOn
            dof.FarIntensity  = active.dofFar
            dof.FocusDistance = active.dofFocus
            dof.InFocusRadius = active.dofRadius
            dof.NearIntensity = active.dofNear

            colorcor.Enabled    = active.ccOn
            colorcor.Brightness = active.ccBrt
            colorcor.Contrast   = active.ccCon
            colorcor.Saturation = active.ccSat

            sunrays.Enabled   = active.srOn
            sunrays.Intensity = active.srInt
            sunrays.Spread    = active.srSpread

            if atmosphere then
                atmosphere.Density = active.atDensity
                atmosphere.Offset  = active.atOffset
                atmosphere.Glare   = active.atGlare
                atmosphere.Haze    = active.atHaze
            end
        end)
    end)
end

startLoop()

-- ═══════════════════════════════════════════
-- RESTORE FUNCTION
-- ═══════════════════════════════════════════
local function restoreAll()
    active.shaderOn = false
    pcall(function()
        Lighting.ClockTime               = backup.ClockTime
        Lighting.Ambient                 = backup.Ambient
        Lighting.Brightness              = backup.Brightness
        Lighting.ColorShift_Bottom       = backup.ColorShift_Bottom
        Lighting.ColorShift_Top          = backup.ColorShift_Top
        Lighting.EnvironmentDiffuseScale = backup.EnvironmentDiffuseScale
        Lighting.EnvironmentSpecularScale= backup.EnvironmentSpecularScale
        Lighting.GlobalShadows           = backup.GlobalShadows
        Lighting.OutdoorAmbient          = backup.OutdoorAmbient
        Lighting.ExposureCompensation    = backup.ExposureCompensation
        Lighting.FogEnd                  = backup.FogEnd
        Lighting.FogStart                = backup.FogStart
        Lighting.FogColor                = backup.FogColor
        Lighting.GeographicLatitude      = backup.GeographicLatitude

        -- Bloom — full property reset
        bloom.Enabled    = backupEffects.bloom.Enabled
        bloom.Intensity  = backupEffects.bloom.Intensity
        bloom.Size       = backupEffects.bloom.Size
        bloom.Threshold  = backupEffects.bloom.Threshold

        -- Blur — full property reset (prevents leftover blur from presets)
        blur.Enabled     = backupEffects.blur.Enabled
        blur.Size        = backupEffects.blur.Size

        -- DOF — MUST reset all properties, not just Enabled.
        -- Even when Enabled=false the internal values persist and cause blur
        -- if the effect is re-enabled later. Reset to safe neutral values.
        dof.Enabled       = false   -- always off on restore
        dof.FarIntensity  = 0
        dof.NearIntensity = 0
        dof.FocusDistance = backupEffects.dof.FocusDistance
        dof.InFocusRadius = backupEffects.dof.InFocusRadius

        -- ColorCorrection — reset all channels to neutral zero
        colorcor.Enabled    = backupEffects.colorcor.Enabled
        colorcor.Brightness = 0
        colorcor.Contrast   = 0
        colorcor.Saturation = 0
        colorcor.TintColor  = backupEffects.colorcor.TintColor

        -- SunRays — disable and neutral
        sunrays.Enabled   = false
        sunrays.Intensity = 0
        sunrays.Spread    = backupEffects.sunrays.Spread

        -- Atmosphere — full reset to original values
        if atmosphere and backupAtmo then
            atmosphere.Density = backupAtmo.Density or 0
            atmosphere.Offset  = backupAtmo.Offset  or 0
            atmosphere.Color   = backupAtmo.Color   or atmosphere.Color
            atmosphere.Decay   = backupAtmo.Decay   or atmosphere.Decay
            atmosphere.Glare   = backupAtmo.Glare   or 0
            atmosphere.Haze    = backupAtmo.Haze    or 0
        end
    end)
    if shaderConn then shaderConn:Disconnect() end
end

_G._A9RTXStop = restoreAll

-- ═══════════════════════════════════════════
-- STOP OLD GUI IF EXISTS
-- ═══════════════════════════════════════════
pcall(function() game.CoreGui:FindFirstChild("_A9RTX"):Destroy() end)
pcall(function() LP.PlayerGui:FindFirstChild("_A9RTX"):Destroy() end)

-- ═══════════════════════════════════════════
-- ROOT SCREENGUI
-- ═══════════════════════════════════════════
local root = Instance.new("ScreenGui")
root.Name             = "_A9RTX"
root.DisplayOrder     = 998
root.ResetOnSpawn     = false
root.ZIndexBehavior   = Enum.ZIndexBehavior.Sibling
root.IgnoreGuiInset   = true
pcall(function() root.Parent = game.CoreGui end)
if not root.Parent then root.Parent = LP.PlayerGui end

-- ═══════════════════════════════════════════
-- COLOURS
-- ═══════════════════════════════════════════
local C = {
    bg      = Color3.fromRGB(10, 10, 13),
    header  = Color3.fromRGB( 7,  7,  9),
    card    = Color3.fromRGB(18, 18, 22),
    cardH   = Color3.fromRGB(24, 24, 30),
    sep     = Color3.fromRGB(28, 28, 36),
    border  = Color3.fromRGB(40, 40, 52),
    borderH = Color3.fromRGB(60, 60, 78),
    trk     = Color3.fromRGB(30, 30, 40),
    trkF    = Color3.fromRGB(180,180,192),
    tOn     = Color3.fromRGB(175,175,190),
    tOff    = Color3.fromRGB(36, 36, 48),
    white   = Color3.new(1, 1, 1),
    pri     = Color3.fromRGB(218,218,224),
    sec     = Color3.fromRGB(115,115,130),
    dim     = Color3.fromRGB(65,  65, 80),
    sLbl    = Color3.fromRGB(125,125,140),
}

-- ═══════════════════════════════════════════
-- DIMENSIONS
-- ═══════════════════════════════════════════
local W   = 228
local H   = 342
local HDR = 30
local TAB = 28

-- ═══════════════════════════════════════════
-- LOADING SCREEN  (covers panel only)
-- ═══════════════════════════════════════════
-- Built after win is created at bottom of script

-- ═══════════════════════════════════════════
-- WINDOW  (fixed center, no drag)
-- ═══════════════════════════════════════════
-- No manual vp needed — pure AnchorPoint centering works on all orientations
local win = Instance.new("Frame")
win.Name               = "Win"
win.Size               = UDim2.fromOffset(W, H)
win.Position           = UDim2.fromScale(0.5, 0.5)   -- exact center on any screen
win.AnchorPoint        = Vector2.new(0.5, 0.5)        -- anchor from its own center
win.BackgroundColor3   = C.bg
win.BackgroundTransparency = 0
win.BorderSizePixel    = 0
win.ClipsDescendants   = true   -- prevent ANY child from leaking outside panel
win.ZIndex             = 10
win.Parent             = root
Instance.new("UICorner", win).CornerRadius = UDim.new(0, 7)
local winS = Instance.new("UIStroke", win)
winS.Color = C.border; winS.Thickness = 1

-- ═══════════════════════════════════════════
-- HEADER
-- ═══════════════════════════════════════════
local hdr = Instance.new("Frame")
hdr.Size             = UDim2.new(1, 0, 0, HDR)
hdr.BackgroundColor3 = C.header
hdr.BackgroundTransparency = 0
hdr.BorderSizePixel  = 0
hdr.ZIndex           = 11
hdr.Parent           = win
Instance.new("UICorner", hdr).CornerRadius = UDim.new(0, 7)

-- patch bottom corners of header
local hPatch = Instance.new("Frame")
hPatch.Size             = UDim2.new(1, 0, 0, 7)
hPatch.Position         = UDim2.new(0, 0, 1, -7)
hPatch.BackgroundColor3 = C.header
hPatch.BackgroundTransparency = 0
hPatch.BorderSizePixel  = 0
hPatch.ZIndex           = 10
hPatch.Parent           = hdr

local hdrSep = Instance.new("Frame")
hdrSep.Size             = UDim2.new(1, 0, 0, 1)
hdrSep.Position         = UDim2.new(0, 0, 1, -1)
hdrSep.BackgroundColor3 = C.sep
hdrSep.BorderSizePixel  = 0
hdrSep.ZIndex           = 12
hdrSep.Parent           = hdr

local hdrLbl = Instance.new("TextLabel")
hdrLbl.Size               = UDim2.new(1, -52, 1, 0)
hdrLbl.Position           = UDim2.fromOffset(10, 0)
hdrLbl.BackgroundTransparency = 1
hdrLbl.Text               = "Anonymous9x Full RTX"
hdrLbl.Font               = Enum.Font.GothamBold
hdrLbl.TextSize            = 10
hdrLbl.TextColor3          = C.pri
hdrLbl.TextXAlignment      = Enum.TextXAlignment.Left
hdrLbl.ZIndex              = 12
hdrLbl.Parent              = hdr

-- Version
local verF = Instance.new("Frame")
verF.Size             = UDim2.fromOffset(30, 13)
verF.Position         = UDim2.new(1, -74, 0.5, -6)
verF.BackgroundColor3 = C.card
verF.BorderSizePixel  = 0
verF.ZIndex           = 12
verF.Parent           = hdr
Instance.new("UICorner", verF).CornerRadius = UDim.new(1, 0)
local verS = Instance.new("UIStroke", verF); verS.Color = C.borderH; verS.Thickness = 1
local verL = Instance.new("TextLabel")
verL.Size               = UDim2.fromScale(1,1)
verL.BackgroundTransparency = 1
verL.Text               = "v1.0"
verL.Font               = Enum.Font.GothamBold
verL.TextSize           = 7
verL.TextColor3         = C.sec
verL.ZIndex             = 13
verL.Parent             = verF

-- Minimize btn
local function makeHdrBtn(xOff, sym)
    local b = Instance.new("ImageButton")
    b.Size               = UDim2.fromOffset(20, 17)
    b.Position           = UDim2.new(1, xOff, 0.5, -8)
    b.BackgroundColor3   = C.card
    b.BackgroundTransparency = 0
    b.BorderSizePixel    = 0
    b.Image              = ""
    b.AutoButtonColor    = false
    b.ZIndex             = 13
    b.Parent             = hdr
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
    local l = Instance.new("TextLabel")
    l.Size               = UDim2.fromScale(1,1)
    l.BackgroundTransparency = 1
    l.Text               = sym
    l.Font               = Enum.Font.GothamBold
    l.TextSize            = 12
    l.TextColor3          = C.sec
    l.ZIndex              = 14
    l.Parent              = b
    b.MouseEnter:Connect(function()
        TS:Create(b, TweenInfo.new(0.10), {BackgroundColor3=C.cardH}):Play()
        l.TextColor3 = C.white
    end)
    b.MouseLeave:Connect(function()
        TS:Create(b, TweenInfo.new(0.10), {BackgroundColor3=C.card}):Play()
        l.TextColor3 = C.sec
    end)
    return b
end

local minBtn   = makeHdrBtn(-44, "−")
local closeBtn = makeHdrBtn(-22, "×")

-- ═══════════════════════════════════════════
-- TAB BAR
-- ═══════════════════════════════════════════
local tabBar = Instance.new("Frame")
tabBar.Size             = UDim2.new(1, 0, 0, TAB)
tabBar.Position         = UDim2.fromOffset(0, HDR)
tabBar.BackgroundColor3 = C.header
tabBar.BackgroundTransparency = 0
tabBar.BorderSizePixel  = 0
tabBar.ZIndex           = 11
tabBar.Parent           = win

local tbSep = Instance.new("Frame")
tbSep.Size             = UDim2.new(1, 0, 0, 1)
tbSep.Position         = UDim2.new(0, 0, 1, -1)
tbSep.BackgroundColor3 = C.sep
tbSep.BorderSizePixel  = 0
tbSep.ZIndex           = 12
tbSep.Parent           = tabBar

local tabLL = Instance.new("UIListLayout")
tabLL.FillDirection = Enum.FillDirection.Horizontal
tabLL.VerticalAlignment = Enum.VerticalAlignment.Center
tabLL.SortOrder = Enum.SortOrder.LayoutOrder
tabLL.Parent = tabBar

local TABS = {
    {id="Presets",  label="Presets"},
    {id="Adjust",   label="Adjust"},
    {id="Info",     label="Info"},
}

local tabBtns   = {}
local tabPanels = {}
local activeTab = "Presets"

local function setTab(id)
    activeTab = id
    for _, def in ipairs(TABS) do
        local btn = tabBtns[def.id]
        local pan = tabPanels[def.id]
        local on  = def.id == id
        if btn then
            TS:Create(btn, TweenInfo.new(0.12), {
                BackgroundColor3   = on and C.card or C.header,
                BackgroundTransparency = on and 0 or 1,
            }):Play()
            if btn:FindFirstChild("L") then
                btn.L.TextColor3 = on and C.white or C.sec
            end
        end
        if pan then pan.Visible = on end
    end
end

for i, def in ipairs(TABS) do
    local id  = def.id
    local btn = Instance.new("ImageButton")
    btn.Name               = "T_"..id
    btn.Size               = UDim2.new(1/#TABS, 0, 1, -1)
    btn.BackgroundColor3   = C.header
    btn.BackgroundTransparency = 1
    btn.BorderSizePixel    = 0
    btn.Image              = ""
    btn.AutoButtonColor    = false
    btn.Selectable         = false   -- prevent Roblox selection highlight
    btn.LayoutOrder        = i
    btn.ZIndex             = 12
    btn.Parent             = tabBar
    local l = Instance.new("TextLabel")
    l.Name               = "L"
    l.Size               = UDim2.fromScale(1,1)
    l.BackgroundTransparency = 1
    l.Text               = def.label
    l.Font               = Enum.Font.GothamSemibold
    l.TextSize            = 9
    l.TextColor3          = C.sec
    l.ZIndex              = 13
    l.Parent              = btn
    btn.MouseButton1Click:Connect(function() setTab(id) end)
    tabBtns[id] = btn
end

-- Underscore indicator
-- Tab active state shown by background change only (no external underline frame)
-- This prevents any element from clipping/bleeding outside the panel.
local function moveUnderline(id)
    -- noop — visual handled by btn background tween in setTab
end

local _origSetTab = setTab
setTab = function(id)
    _origSetTab(id)
    -- update tab label in content header if needed
end

-- ═══════════════════════════════════════════
-- CONTENT AREA
-- ═══════════════════════════════════════════
local BODY_Y = HDR + TAB

local function mkPanel(id)
    local s = Instance.new("ScrollingFrame")
    s.Name                 = "P_"..id
    s.Size                 = UDim2.new(1, 0, 1, -BODY_Y)
    s.Position             = UDim2.fromOffset(0, BODY_Y)
    s.BackgroundTransparency = 1
    s.BorderSizePixel      = 0
    s.ScrollBarThickness   = 2
    s.ScrollBarImageColor3 = C.borderH
    s.ScrollingDirection   = Enum.ScrollingDirection.Y
    s.CanvasSize           = UDim2.fromOffset(0, 0)
    s.AutomaticCanvasSize  = Enum.AutomaticSize.Y
    s.Visible              = false
    s.ZIndex               = 11
    s.Parent               = win
    local l = Instance.new("UIListLayout")
    l.SortOrder = Enum.SortOrder.LayoutOrder
    l.Padding   = UDim.new(0, 3)
    l.Parent    = s
    local p = Instance.new("UIPadding")
    p.PaddingLeft = UDim.new(0,6); p.PaddingRight  = UDim.new(0,6)
    p.PaddingTop  = UDim.new(0,6); p.PaddingBottom = UDim.new(0,6)
    p.Parent = s
    tabPanels[id] = s
    return s
end

for _, def in ipairs(TABS) do mkPanel(def.id) end

-- ═══════════════════════════════════════════
-- COMPONENT LIBRARY  (all ImageButton = zero cursor bug)
-- ═══════════════════════════════════════════

local function mkSec(par, title, ord)
    local f = Instance.new("Frame")
    f.Size               = UDim2.new(1,0,0,16)
    f.BackgroundTransparency = 1
    f.LayoutOrder        = ord
    f.ZIndex             = 12
    f.Parent             = par
    local l = Instance.new("TextLabel")
    l.Size               = UDim2.fromScale(1,1)
    l.BackgroundTransparency = 1
    l.Text               = title:upper()
    l.Font               = Enum.Font.GothamBold
    l.TextSize            = 7
    l.TextColor3          = C.sLbl
    l.TextXAlignment      = Enum.TextXAlignment.Left
    l.ZIndex              = 13
    l.Parent              = f
    local ln = Instance.new("Frame")
    ln.Size             = UDim2.new(1,0,0,1)
    ln.Position         = UDim2.new(0,0,1,-1)
    ln.BackgroundColor3 = C.sep
    ln.BorderSizePixel  = 0
    ln.ZIndex           = 13
    ln.Parent           = f
    return f
end

local function mkToggle(par, opts)
    local h = opts.sub and 38 or 28
    local card = Instance.new("Frame")
    card.Size               = UDim2.new(1,0,0,h)
    card.BackgroundColor3   = C.card
    card.BackgroundTransparency = 0
    card.BorderSizePixel    = 0
    card.LayoutOrder        = opts.ord
    card.ZIndex             = 12
    card.Parent             = par
    Instance.new("UICorner",card).CornerRadius = UDim.new(0,5)
    local tl = Instance.new("TextLabel")
    tl.Size               = UDim2.new(1,-40,0,12)
    tl.Position           = UDim2.fromOffset(7, opts.sub and 4 or 8)
    tl.BackgroundTransparency = 1
    tl.Text               = opts.title
    tl.Font               = Enum.Font.GothamSemibold
    tl.TextSize            = 9
    tl.TextColor3          = C.pri
    tl.TextXAlignment      = Enum.TextXAlignment.Left
    tl.ZIndex              = 13
    tl.Parent              = card
    if opts.sub then
        local sl = Instance.new("TextLabel")
        sl.Size               = UDim2.new(1,-40,0,10)
        sl.Position           = UDim2.fromOffset(7,17)
        sl.BackgroundTransparency = 1
        sl.Text               = opts.sub
        sl.Font               = Enum.Font.Gotham
        sl.TextSize            = 7
        sl.TextColor3          = C.sec
        sl.TextXAlignment      = Enum.TextXAlignment.Left
        sl.ZIndex              = 13
        sl.Parent              = card
    end
    local TW,TH2 = 26,14
    local trk = Instance.new("Frame")
    trk.Size             = UDim2.fromOffset(TW,TH2)
    trk.Position         = UDim2.new(1,-(TW+6),0.5,-(TH2/2))
    trk.BackgroundColor3 = opts.val and C.tOn or C.tOff
    trk.BorderSizePixel  = 0
    trk.ZIndex           = 13
    trk.Parent           = card
    Instance.new("UICorner",trk).CornerRadius = UDim.new(1,0)
    local KS = TH2-4
    local knob = Instance.new("Frame")
    knob.Size             = UDim2.fromOffset(KS,KS)
    knob.Position         = (opts.val and UDim2.fromOffset(TW-KS-2,2)) or UDim2.fromOffset(2,2)
    knob.BackgroundColor3 = C.white
    knob.BorderSizePixel  = 0
    knob.ZIndex           = 14
    knob.Parent           = trk
    Instance.new("UICorner",knob).CornerRadius = UDim.new(1,0)
    local val = opts.val or false
    local setV
    setV = function(v)
        val = v
        TS:Create(trk,TweenInfo.new(0.12,Enum.EasingStyle.Quad),{BackgroundColor3=v and C.tOn or C.tOff}):Play()
        TS:Create(knob,TweenInfo.new(0.12,Enum.EasingStyle.Quad),{Position=v and UDim2.fromOffset(TW-KS-2,2) or UDim2.fromOffset(2,2)}):Play()
        if opts.cb then opts.cb(v) end
    end
    local hit = Instance.new("ImageButton")
    hit.Size               = UDim2.fromScale(1,1)
    hit.BackgroundTransparency = 1
    hit.Image              = ""
    hit.AutoButtonColor    = false
    hit.ZIndex             = 15
    hit.Parent             = card
    hit.MouseButton1Click:Connect(function() setV(not val) end)
    hit.MouseEnter:Connect(function() TS:Create(card,TweenInfo.new(0.10),{BackgroundColor3=C.cardH}):Play() end)
    hit.MouseLeave:Connect(function() TS:Create(card,TweenInfo.new(0.10),{BackgroundColor3=C.card}):Play() end)
    return card, setV
end

local function mkSlider(par, opts)
    local step = opts.step or 0.01
    local card = Instance.new("Frame")
    card.Size               = UDim2.new(1,0,0,40)
    card.BackgroundColor3   = C.card
    card.BackgroundTransparency = 0
    card.BorderSizePixel    = 0
    card.LayoutOrder        = opts.ord
    card.ZIndex             = 12
    card.Parent             = par
    Instance.new("UICorner",card).CornerRadius = UDim.new(0,5)
    local tl = Instance.new("TextLabel")
    tl.Size               = UDim2.new(0.6,0,0,12)
    tl.Position           = UDim2.fromOffset(7,5)
    tl.BackgroundTransparency = 1
    tl.Text               = opts.title
    tl.Font               = Enum.Font.GothamSemibold
    tl.TextSize            = 9
    tl.TextColor3          = C.pri
    tl.TextXAlignment      = Enum.TextXAlignment.Left
    tl.ZIndex              = 13
    tl.Parent              = card
    local rng = math.max(0.001, opts.max - opts.min)
    local pct = (opts.def - opts.min) / rng
    local defStr = step<1 and string.format("%.2f",opts.def) or tostring(math.floor(opts.def))
    local vl = Instance.new("TextLabel")
    vl.Size               = UDim2.new(0.4,-7,0,12)
    vl.Position           = UDim2.new(0.6,0,0,5)
    vl.BackgroundTransparency = 1
    vl.Text               = defStr .. (opts.suf or "")
    vl.Font               = Enum.Font.GothamBold
    vl.TextSize            = 9
    vl.TextColor3          = C.pri
    vl.TextXAlignment      = Enum.TextXAlignment.Right
    vl.ZIndex              = 13
    vl.Parent              = card
    local trk = Instance.new("Frame")
    trk.Size             = UDim2.new(1,-14,0,3)
    trk.Position         = UDim2.fromOffset(7,23)
    trk.BackgroundColor3 = C.trk
    trk.BorderSizePixel  = 0
    trk.ZIndex           = 13
    trk.Parent           = card
    Instance.new("UICorner",trk).CornerRadius = UDim.new(1,0)
    local fill = Instance.new("Frame")
    fill.Size             = UDim2.new(pct,0,1,0)
    fill.BackgroundColor3 = C.trkF
    fill.BorderSizePixel  = 0
    fill.ZIndex           = 14
    fill.Parent           = trk
    Instance.new("UICorner",fill).CornerRadius = UDim.new(1,0)
    local KD = 9
    local knob = Instance.new("Frame")
    knob.Size             = UDim2.fromOffset(KD,KD)
    knob.Position         = UDim2.new(pct,-KD/2,0.5,-KD/2)
    knob.BackgroundColor3 = C.white
    knob.BorderSizePixel  = 0
    knob.ZIndex           = 15
    knob.Parent           = trk
    Instance.new("UICorner",knob).CornerRadius = UDim.new(1,0)
    local value  = opts.def
    local isDrag = false
    local function updX(ax)
        local ta = trk.AbsolutePosition
        local ts = trk.AbsoluteSize
        if ts.X < 1 then return end
        local rel = math.clamp((ax-ta.X)/ts.X,0,1)
        value = math.floor((opts.min + rel*rng)/step+0.5)*step
        value = math.clamp(value, opts.min, opts.max)
        local p = (value-opts.min)/rng
        fill.Size     = UDim2.new(p,0,1,0)
        knob.Position = UDim2.new(p,-KD/2,0.5,-KD/2)
        local disp = step<1 and string.format("%.2f",value) or tostring(math.floor(value))
        vl.Text = disp..(opts.suf or "")
        if opts.cb then opts.cb(value) end
    end
    local hit = Instance.new("ImageButton")
    hit.Size               = UDim2.fromScale(1,1)
    hit.BackgroundTransparency = 1
    hit.Image              = ""
    hit.AutoButtonColor    = false
    hit.ZIndex             = 16
    hit.Parent             = trk
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

local function mkBtn(par, opts)
    local h = opts.sub and 36 or 26
    local btn = Instance.new("ImageButton")
    btn.Size               = UDim2.new(1,0,0,h)
    btn.BackgroundColor3   = C.card
    btn.BackgroundTransparency = 0
    btn.BorderSizePixel    = 0
    btn.Image              = ""
    btn.AutoButtonColor    = false
    btn.LayoutOrder        = opts.ord
    btn.ZIndex             = 12
    btn.Parent             = par
    Instance.new("UICorner",btn).CornerRadius = UDim.new(0,5)
    local bS = Instance.new("UIStroke",btn); bS.Color=C.border; bS.Thickness=1
    local lbl = Instance.new("TextLabel")
    lbl.Size               = UDim2.new(1,-10,0,12)
    lbl.Position           = UDim2.fromOffset(7, opts.sub and 4 or 7)
    lbl.BackgroundTransparency = 1
    lbl.Text               = opts.title
    lbl.Font               = Enum.Font.GothamBold
    lbl.TextSize            = 9
    lbl.TextColor3          = C.pri
    lbl.TextXAlignment      = Enum.TextXAlignment.Left
    lbl.ZIndex              = 13
    lbl.Parent              = btn
    if opts.sub then
        local sl = Instance.new("TextLabel")
        sl.Size               = UDim2.new(1,-10,0,10)
        sl.Position           = UDim2.fromOffset(7,18)
        sl.BackgroundTransparency = 1
        sl.Text               = opts.sub
        sl.Font               = Enum.Font.Gotham
        sl.TextSize            = 7
        sl.TextColor3          = C.sec
        sl.TextXAlignment      = Enum.TextXAlignment.Left
        sl.ZIndex              = 13
        sl.Parent              = btn
    end
    btn.MouseButton1Click:Connect(function()
        TS:Create(btn,TweenInfo.new(0.08),{BackgroundColor3=C.cardH}):Play()
        task.delay(0.15,function() TS:Create(btn,TweenInfo.new(0.10),{BackgroundColor3=C.card}):Play() end)
        if opts.cb then opts.cb() end
    end)
    btn.MouseEnter:Connect(function() TS:Create(btn,TweenInfo.new(0.10),{BackgroundColor3=C.cardH}):Play() end)
    btn.MouseLeave:Connect(function() TS:Create(btn,TweenInfo.new(0.10),{BackgroundColor3=C.card}):Play() end)
    return btn
end

local function mkTextCard(par, lines, ord)
    local lineH  = 13
    local totalH = #lines * lineH + 8
    local f = Instance.new("Frame")
    f.Size               = UDim2.new(1,0,0,totalH)
    f.BackgroundColor3   = C.card
    f.BackgroundTransparency = 0
    f.BorderSizePixel    = 0
    f.LayoutOrder        = ord
    f.ZIndex             = 12
    f.Parent             = par
    Instance.new("UICorner",f).CornerRadius = UDim.new(0,5)
    local ll = Instance.new("UIListLayout")
    ll.SortOrder = Enum.SortOrder.LayoutOrder; ll.Padding = UDim.new(0,0); ll.Parent = f
    local lp2 = Instance.new("UIPadding")
    lp2.PaddingLeft=UDim.new(0,7); lp2.PaddingTop=UDim.new(0,4); lp2.Parent = f
    for i, line in ipairs(lines) do
        local l = Instance.new("TextLabel")
        l.Size               = UDim2.new(1,-10,0,lineH)
        l.BackgroundTransparency = 1
        l.Text               = line
        l.Font               = line:sub(1,2) == "  " and Enum.Font.Gotham or Enum.Font.GothamBold
        l.TextSize            = 8
        l.TextColor3          = line:sub(1,2)=="  " and C.sec or C.pri
        l.TextXAlignment      = Enum.TextXAlignment.Left
        l.TextWrapped         = true
        l.LayoutOrder         = i
        l.ZIndex              = 13
        l.Parent              = f
    end
    return f
end

local function mkDiv(par, ord)
    local f = Instance.new("Frame")
    f.Size             = UDim2.new(1,0,0,1)
    f.BackgroundColor3 = C.sep
    f.BackgroundTransparency = 0.3
    f.BorderSizePixel  = 0
    f.LayoutOrder      = ord
    f.ZIndex           = 12
    f.Parent           = par
    return f
end

-- ═══════════════════════════════════════════
-- PRESET SELECTOR CARD  (image thumbnails)
-- pshade style: grid of clickable preset cards
-- ═══════════════════════════════════════════
-- Preset icon images (rbxassetid from pshade source)
local PRESET_IMGS = {
    Default   = "rbxassetid://10141946703",
    Morning   = "rbxassetid://113299445142241",
    Midday    = "rbxassetid://92217393876433",
    Afternoon = "rbxassetid://95808526176628",
    Evening   = "rbxassetid://132108667983758",
    Night     = "rbxassetid://100757920131658",
    Midnight  = "rbxassetid://97773466118344",
}
local PRESET_ORDER = {"Default","Morning","Midday","Afternoon","Evening","Night","Midnight"}

local presetPanel = tabPanels["Presets"]
local _po = 0; local function po() _po=_po+1; return _po end

mkSec(presetPanel, "Time of Day Presets", po())

-- Grid frame for preset thumbnails
local gridF = Instance.new("Frame")
gridF.Size               = UDim2.new(1,0,0,200)
gridF.BackgroundTransparency = 1
gridF.BorderSizePixel    = 0
gridF.LayoutOrder        = po()
gridF.ZIndex             = 12
gridF.Parent             = presetPanel

local gridLL = Instance.new("UIGridLayout")
gridLL.CellSize    = UDim2.fromOffset(62, 54)
gridLL.CellPadding = UDim2.fromOffset(4, 4)
gridLL.SortOrder   = Enum.SortOrder.LayoutOrder
gridLL.Parent      = gridF

local gridPad = Instance.new("UIPadding")
gridPad.PaddingTop  = UDim.new(0,2)
gridPad.PaddingLeft = UDim.new(0,2)
gridPad.Parent      = gridF

local selectedPreset = nil

for i, name in ipairs(PRESET_ORDER) do
    local nm   = name
    local cell = Instance.new("Frame")
    cell.Name             = "PC_"..nm
    cell.BackgroundColor3 = C.card
    cell.BackgroundTransparency = 0
    cell.BorderSizePixel  = 0
    cell.LayoutOrder      = i
    cell.ZIndex           = 13
    cell.Parent           = gridF
    Instance.new("UICorner",cell).CornerRadius = UDim.new(0,5)
    local cS = Instance.new("UIStroke",cell); cS.Color=C.border; cS.Thickness=1

    local img = Instance.new("ImageLabel")
    img.Size               = UDim2.new(1,0,0,36)
    img.BackgroundColor3   = C.trk
    img.BackgroundTransparency = 0
    img.BorderSizePixel    = 0
    img.Image              = PRESET_IMGS[nm] or ""
    img.ScaleType          = Enum.ScaleType.Crop
    img.ZIndex             = 14
    img.Parent             = cell
    Instance.new("UICorner",img).CornerRadius = UDim.new(0,5)

    local lbl = Instance.new("TextLabel")
    lbl.Size               = UDim2.new(1,0,0,16)
    lbl.Position           = UDim2.fromOffset(0,36)
    lbl.BackgroundTransparency = 1
    lbl.Text               = nm
    lbl.Font               = Enum.Font.GothamBold
    lbl.TextSize            = 7
    lbl.TextColor3          = C.sec
    lbl.ZIndex             = 14
    lbl.Parent             = cell

    local hit = Instance.new("ImageButton")
    hit.Size               = UDim2.fromScale(1,1)
    hit.BackgroundTransparency = 1
    hit.Image              = ""
    hit.AutoButtonColor    = false
    hit.ZIndex             = 15
    hit.Parent             = cell
    hit.MouseButton1Click:Connect(function()
        -- deselect previous
        if selectedPreset then
            local prev = gridF:FindFirstChild("PC_"..selectedPreset)
            if prev then
                local ps = prev:FindFirstChildOfClass("UIStroke")
                if ps then ps.Color=C.border; ps.Thickness=1 end
                local pl = prev:FindFirstChildOfClass("TextLabel")
                if pl then pl.TextColor3 = C.sec end
            end
        end
        selectedPreset = nm
        cS.Color     = C.white
        cS.Thickness = 1.5
        lbl.TextColor3 = C.white
        applyPreset(PRESETS[nm])
        startLoop()
    end)
    hit.MouseEnter:Connect(function()
        if selectedPreset ~= nm then
            TS:Create(cell,TweenInfo.new(0.10),{BackgroundColor3=C.cardH}):Play()
        end
    end)
    hit.MouseLeave:Connect(function()
        if selectedPreset ~= nm then
            TS:Create(cell,TweenInfo.new(0.10),{BackgroundColor3=C.card}):Play()
        end
    end)
end

-- Status indicator below grid
local statusLbl = Instance.new("TextLabel")
statusLbl.Size               = UDim2.new(1,0,0,14)
statusLbl.BackgroundTransparency = 1
statusLbl.Text               = "Shader  :  Off"
statusLbl.Font               = Enum.Font.GothamBold
statusLbl.TextSize            = 8
statusLbl.TextColor3          = C.sec
statusLbl.TextXAlignment      = Enum.TextXAlignment.Center
statusLbl.LayoutOrder         = po()
statusLbl.ZIndex              = 12
statusLbl.Parent              = presetPanel

-- Update status every 0.5s
task.spawn(function()
    while root.Parent do
        statusLbl.Text = active.shaderOn
            and ("Shader  :  " .. (selectedPreset or "Custom") .. "  (ON)")
            or  "Shader  :  Off"
        statusLbl.TextColor3 = active.shaderOn and C.white or C.sec
        task.wait(0.5)
    end
end)

mkDiv(presetPanel, po())

-- Info + how to use + creator
mkSec(presetPanel, "How to Use", po())
mkTextCard(presetPanel, {
    "1. Pick a preset from the grid above",
    "  Tap any shader card to apply it live",
    "2. Fine-tune in the Adjust tab",
    "  Bloom, Blur, DOF, Atmosphere + more",
    "3. Close panel — shader keeps running",
    "  GUI can be closed, effects stay on",
    "4. Execute script again to fully unload",
    "  Second execute removes all effects",
}, po())

mkSec(presetPanel, "Cinematic Recommendations", po())
mkTextCard(presetPanel, {
    "Solo cinematic footage:",
    "  Evening    — golden hour, warm glow",
    "  Morning    — soft mist, sunrise bloom",
    "  Night      — moody dark atmosphere",
    "Gameplay / competitive:",
    "  Midday     — clear, high visibility",
    "  Default    — original game lighting",
    "Dramatic / showcase:",
    "  Midnight   — deepest shadows + bloom",
    "  Afternoon  — sharp contrast, vivid",
}, po())

mkSec(presetPanel, "Creator", po())
mkTextCard(presetPanel, {
    "@Anonymous9x",
    "  Building tools no one dares to make,",
    "  Every script a risk we gladly take.",
    "  Shadows taught the code, bytes learned",
    "  the name — Anonymous9x, we stake",
    "  our claim.",
    "",
    "  Website : anonymous9x-site.pages.dev",
    "  YouTube : @anonymous9xch",
}, po())

-- ═══════════════════════════════════════════
-- ADJUST TAB
-- ═══════════════════════════════════════════
local adjPanel = tabPanels["Adjust"]
local _ao = 0; local function ao() _ao=_ao+1; return _ao end

mkSec(adjPanel, "Bloom", ao())
mkToggle(adjPanel, {title="Bloom Enable", val=false, ord=ao(), cb=function(v)
    active.bloomOn = v
    if not active.shaderOn then active.shaderOn=true; startLoop() end
end})
mkSlider(adjPanel, {title="Intensity", min=0, max=3,   def=0.9,  suf="", step=0.05, ord=ao(), cb=function(v) active.bloomInt=v end})
mkSlider(adjPanel, {title="Size",      min=0, max=56,  def=24,   suf="", step=1,    ord=ao(), cb=function(v) active.bloomSize=v end})
mkSlider(adjPanel, {title="Threshold", min=0, max=2,   def=0.95, suf="", step=0.05, ord=ao(), cb=function(v) active.bloomThresh=v end})

mkSec(adjPanel, "Color Correction", ao())
mkToggle(adjPanel, {title="ColorCorrection Enable", val=false, ord=ao(), cb=function(v)
    active.ccOn=v
    if not active.shaderOn then active.shaderOn=true; startLoop() end
end})
mkSlider(adjPanel, {title="Brightness", min=-1, max=1, def=0, suf="", step=0.02, ord=ao(), cb=function(v) active.ccBrt=v end})
mkSlider(adjPanel, {title="Contrast",   min=-1, max=1, def=0, suf="", step=0.02, ord=ao(), cb=function(v) active.ccCon=v end})
mkSlider(adjPanel, {title="Saturation", min=-1, max=1, def=0, suf="", step=0.02, ord=ao(), cb=function(v) active.ccSat=v end})

mkSec(adjPanel, "Atmosphere", ao())
mkSlider(adjPanel, {title="Density", min=0, max=1,  def=0, suf="", step=0.01, ord=ao(), cb=function(v) active.atDensity=v; if not active.shaderOn then active.shaderOn=true; startLoop() end end})
mkSlider(adjPanel, {title="Offset",  min=0, max=1,  def=0, suf="", step=0.01, ord=ao(), cb=function(v) active.atOffset=v  end})
mkSlider(adjPanel, {title="Glare",   min=0, max=10, def=0, suf="", step=0.1,  ord=ao(), cb=function(v) active.atGlare=v   end})
mkSlider(adjPanel, {title="Haze",    min=0, max=10, def=0, suf="", step=0.1,  ord=ao(), cb=function(v) active.atHaze=v    end})

mkSec(adjPanel, "Sun Rays", ao())
mkToggle(adjPanel, {title="SunRays Enable", val=false, ord=ao(), cb=function(v)
    active.srOn=v
    if not active.shaderOn then active.shaderOn=true; startLoop() end
end})
mkSlider(adjPanel, {title="Intensity", min=0, max=1, def=0.25, suf="", step=0.02, ord=ao(), cb=function(v) active.srInt=v    end})
mkSlider(adjPanel, {title="Spread",    min=0, max=1, def=0.50, suf="", step=0.02, ord=ao(), cb=function(v) active.srSpread=v end})

mkSec(adjPanel, "Depth of Field", ao())
mkToggle(adjPanel, {title="DOF Enable", val=false, ord=ao(), cb=function(v)
    active.dofOn=v
    if not active.shaderOn then active.shaderOn=true; startLoop() end
end})
mkSlider(adjPanel, {title="Focus Distance", min=0,   max=200, def=50, suf="", step=1,    ord=ao(), cb=function(v) active.dofFocus=v  end})
mkSlider(adjPanel, {title="Far Intensity",  min=0,   max=1,   def=0,  suf="", step=0.02, ord=ao(), cb=function(v) active.dofFar=v    end})
mkSlider(adjPanel, {title="Near Intensity", min=0,   max=1,   def=0,  suf="", step=0.02, ord=ao(), cb=function(v) active.dofNear=v   end})

mkSec(adjPanel, "Blur", ao())
mkToggle(adjPanel, {title="Blur Enable", val=false, ord=ao(), cb=function(v)
    active.blurOn=v
    if not active.shaderOn then active.shaderOn=true; startLoop() end
end})
mkSlider(adjPanel, {title="Blur Size", min=0, max=56, def=0, suf="", step=1, ord=ao(), cb=function(v) active.blurSize=v end})

mkSec(adjPanel, "World", ao())
mkToggle(adjPanel, {title="Global Shadows", val=backup.GlobalShadows, ord=ao(), cb=function(v)
    active.GlobalShadows=v
    if not active.shaderOn then active.shaderOn=true; startLoop() end
end})
mkSlider(adjPanel, {title="Exposure", min=-3, max=3,  def=0,  suf="", step=0.05, ord=ao(), cb=function(v) active.ExposureCompensation=v end})
mkSlider(adjPanel, {title="Brightness",min=0, max=10, def=2,  suf="", step=0.1,  ord=ao(), cb=function(v) active.Brightness=v end})
mkSlider(adjPanel, {title="Clock Time", min=0, max=24, def=backup.ClockTime, suf="h", step=0.5, ord=ao(), cb=function(v)
    active.ClockTime=v
    if not active.shaderOn then active.shaderOn=true; startLoop() end
end})

-- ═══════════════════════════════════════════
-- INFO TAB  (Anonymous9x pantun / info)
-- ═══════════════════════════════════════════
local infoPanel = tabPanels["Info"]
local _io = 0; local function io2() _io=_io+1; return _io end

mkSec(infoPanel, "About This Script", io2())

mkTextCard(infoPanel, {
    "Anonymous9x Full RTX",
    "  Universal shader for all Roblox games",
    "  Delta Mobile / iOS / PC supported",
    "  Execute again to fully unload",
}, io2())

mkSec(infoPanel, "Creator", io2())

mkTextCard(infoPanel, {
    "Anonymous9x",
    "  Scripting since the shadows knew our name,",
    "  Writing code like verses in a frame.",
    "  Every line a step, every byte a rhyme,",
    "  Building tools that stand the test of time.",
}, io2())

mkSec(infoPanel, "Website", io2())

mkBtn(infoPanel, {title="Copy Website URL", sub="anonymous9x-site.pages.dev", ord=io2(), cb=function()
    pcall(function() setclipboard("https://anonymous9x-site.pages.dev/") end)
end})

mkBtn(infoPanel, {title="Copy YouTube URL", sub="@anonymous9xch", ord=io2(), cb=function()
    pcall(function() setclipboard("https://youtube.com/@anonymous9xch") end)
end})

mkSec(infoPanel, "Engine Info", io2())

mkTextCard(infoPanel, {
    "Shader Engine",
    "  Based on pshade ultimate logic",
    "  + upgraded for mobile/Delta support",
    "  PreRender loop  |  Backup + Restore",
    "  6 presets  |  Full manual adjust",
}, io2())

mkDiv(infoPanel, io2())

mkTextCard(infoPanel, {
    "To remove all effects:",
    "  Execute the script a second time.",
    "  The toggle guard at the top will",
    "  detect the loaded state and call",
    "  restoreAll() automatically.",
}, io2())

-- ═══════════════════════════════════════════
-- MINIMIZE / CLOSE
-- ═══════════════════════════════════════════
local isMini   = false
local _drag    = false
local _dragRef = nil
local _startIP = nil
local _startWP = nil

-- Drag (active when minimized — header only):
-- Use global UIS so it works on Delta mobile (Frame.InputBegan can miss touches)
UIS.InputBegan:Connect(function(inp, gp)
    if gp then return end
    if not isMini then return end  -- drag only when minimized
    local isT = inp.UserInputType == Enum.UserInputType.Touch
    local isM = inp.UserInputType == Enum.UserInputType.MouseButton1
    if not (isT or isM) then return end
    -- Check touch/click is inside header bounds
    local ap = hdr.AbsolutePosition
    local az = hdr.AbsoluteSize
    local px, py = inp.Position.X, inp.Position.Y
    if px < ap.X or px > ap.X+az.X or py < ap.Y or py > ap.Y+az.Y then return end
    -- Exclude button zone (right 56px)
    if px > ap.X + az.X - 56 then return end
    _drag    = true
    _dragRef = inp
    _startIP = Vector2.new(px, py)
    _startWP = Vector2.new(win.AbsolutePosition.X, win.AbsolutePosition.Y)
end)

UIS.InputChanged:Connect(function(inp)
    if not _drag then return end
    local isT = inp.UserInputType == Enum.UserInputType.Touch
    local isM = inp.UserInputType == Enum.UserInputType.MouseMove
    if not (isT or isM) then return end
    if isT and inp ~= _dragRef then return end
    local d = Vector2.new(inp.Position.X, inp.Position.Y) - _startIP
    local vp2 = Camera.ViewportSize
    win.Position = UDim2.fromOffset(
        math.clamp(_startWP.X + d.X, 0, vp2.X - W),
        math.clamp(_startWP.Y + d.Y, 0, vp2.Y - HDR))
end)

UIS.InputEnded:Connect(function(inp)
    if inp == _dragRef or inp.UserInputType == Enum.UserInputType.MouseButton1 then
        _drag = false; _dragRef = nil
    end
end)

minBtn.MouseButton1Click:Connect(function()
    isMini = not isMini
    if isMini then
        -- Collapse: hide tabBar + all panels, shrink to header only
        tabBar.Visible = false
        for _, p in pairs(tabPanels) do p.Visible = false end
        TS:Create(win, TweenInfo.new(0.16, Enum.EasingStyle.Quad),
            {Size = UDim2.fromOffset(W, HDR)}):Play()
        -- Return panel to center when collapsing (reset any drag offset)
        TS:Create(win, TweenInfo.new(0.16, Enum.EasingStyle.Quad),
            {Position = UDim2.fromScale(0.5, 0.5)}):Play()
    else
        -- Expand: show tabBar + panels, restore full height
        tabBar.Visible = true
        TS:Create(win, TweenInfo.new(0.20, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
            {Size = UDim2.fromOffset(W, H)}):Play()
        task.delay(0.22, function() setTab(activeTab) end)
        -- Re-center after expand
        TS:Create(win, TweenInfo.new(0.20, Enum.EasingStyle.Quad),
            {Position = UDim2.fromScale(0.5, 0.5)}):Play()
    end
    minBtn:FindFirstChildOfClass("TextLabel").Text = isMini and "+" or "−"
end)

closeBtn.MouseButton1Click:Connect(function()
    -- Shader stays ON — closing GUI does NOT remove effects.
    -- To fully unload: execute the script again (toggle guard at top).
    _G._A9RTXLoaded = false
    pcall(function() root:Destroy() end)
end)

-- ═══════════════════════════════════════════
-- LOADING OVERLAY  (covers panel only)
-- ═══════════════════════════════════════════
task.spawn(function()
    RS.Heartbeat:Wait()  -- 1 frame: panel rendered

    local ov = Instance.new("Frame")
    ov.Size               = UDim2.fromScale(1, 1)
    ov.BackgroundColor3   = Color3.new(0, 0, 0)
    ov.BackgroundTransparency = 0
    ov.BorderSizePixel    = 0
    ov.ClipsDescendants   = true
    ov.ZIndex             = 8000
    ov.Parent             = win
    Instance.new("UICorner", ov).CornerRadius = UDim.new(0, 7)

    -- Title
    local t1 = Instance.new("TextLabel")
    t1.Size               = UDim2.new(1,0,0,24)
    t1.Position           = UDim2.new(0,0,0.32,0)
    t1.BackgroundTransparency = 1
    t1.Text               = "Anonymous9x Full RTX"
    t1.Font               = Enum.Font.GothamBlack
    t1.TextSize            = 13
    t1.TextColor3          = Color3.new(1,1,1)
    t1.TextXAlignment      = Enum.TextXAlignment.Center
    t1.ZIndex              = 8001
    t1.Parent              = ov

    local t2 = Instance.new("TextLabel")
    t2.Size               = UDim2.new(1,0,0,12)
    t2.Position           = UDim2.new(0,0,0.44,0)
    t2.BackgroundTransparency = 1
    t2.Text               = "Initializing graphics engine..."
    t2.Font               = Enum.Font.Gotham
    t2.TextSize            = 8
    t2.TextColor3          = Color3.fromRGB(100,100,100)
    t2.TextXAlignment      = Enum.TextXAlignment.Center
    t2.ZIndex              = 8001
    t2.Parent              = ov

    -- Bar (fixed 180px)
    local BAR = 180
    local barF = Instance.new("Frame")
    barF.Size             = UDim2.fromOffset(BAR, 2)
    barF.Position         = UDim2.new(0.5, -(BAR/2), 0.54, 0)
    barF.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
    barF.BackgroundTransparency = 0
    barF.BorderSizePixel  = 0
    barF.ZIndex           = 8001
    barF.Parent           = ov
    Instance.new("UICorner",barF).CornerRadius = UDim.new(1,0)

    local barFill = Instance.new("Frame")
    barFill.Size             = UDim2.fromOffset(0,2)
    barFill.BackgroundColor3 = Color3.new(1,1,1)
    barFill.BackgroundTransparency = 0
    barFill.BorderSizePixel  = 0
    barFill.ZIndex           = 8002
    barFill.Parent           = barF
    Instance.new("UICorner",barFill).CornerRadius = UDim.new(1,0)

    local subT = Instance.new("TextLabel")
    subT.Size               = UDim2.new(1,0,0,11)
    subT.Position           = UDim2.new(0,0,0.59,0)
    subT.BackgroundTransparency = 1
    subT.Text               = "Loading..."
    subT.Font               = Enum.Font.Gotham
    subT.TextSize            = 7
    subT.TextColor3          = Color3.fromRGB(60,60,70)
    subT.TextXAlignment      = Enum.TextXAlignment.Center
    subT.ZIndex              = 8001
    subT.Parent              = ov

    local verT = Instance.new("TextLabel")
    verT.Size               = UDim2.new(1,0,0,10)
    verT.Position           = UDim2.new(0,0,1,-13)
    verT.BackgroundTransparency = 1
    verT.Text               = "v1.0  |  By Anonymous9x"
    verT.Font               = Enum.Font.Gotham
    verT.TextSize            = 7
    verT.TextColor3          = Color3.fromRGB(35,35,42)
    verT.TextXAlignment      = Enum.TextXAlignment.Center
    verT.ZIndex              = 8001
    verT.Parent              = ov

    -- Animate
    local steps = {
        {p=0.20, msg="Backing up lighting values..."},
        {p=0.48, msg="Cloning effects..."},
        {p=0.72, msg="Preparing presets..."},
        {p=0.90, msg="Building interface..."},
        {p=1.00, msg="Ready."},
    }
    for _, s in ipairs(steps) do
        subT.Text = s.msg
        TS:Create(barFill, TweenInfo.new(0.38, Enum.EasingStyle.Quad),
            {Size = UDim2.fromOffset(math.floor(BAR*s.p), 2)}):Play()
        task.wait(0.48)
    end
    task.wait(0.20)

    local FI = TweenInfo.new(0.30, Enum.EasingStyle.Quad)
    TS:Create(ov,    FI, {BackgroundTransparency=1}):Play()
    TS:Create(t1,    FI, {TextTransparency=1}):Play()
    TS:Create(t2,    FI, {TextTransparency=1}):Play()
    TS:Create(subT,  FI, {TextTransparency=1}):Play()
    TS:Create(verT,  FI, {TextTransparency=1}):Play()
    TS:Create(barF,  FI, {BackgroundTransparency=1}):Play()
    TS:Create(barFill,FI,{BackgroundTransparency=1}):Play()
    task.wait(0.35)
    pcall(function() ov:Destroy() end)
end)

-- ═══════════════════════════════════════════
-- INIT
-- ═══════════════════════════════════════════
setTab("Presets")
moveUnderline("Presets")

task.spawn(function()
    task.wait(3.5)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title    = "Anonymous9x Full RTX",
            Text     = "v1.0 Ready  |  Select a preset to start",
            Duration = 4,
        })
    end)
end)

-- ChildRemoved guard: if a shader effect gets deleted by the game,
-- recreate it (learned from pshade source)
Lighting.ChildRemoved:Connect(function(obj)
    if not active.shaderOn then return end
    pcall(function()
        if obj == bloom then
            bloom = Instance.new("BloomEffect", Lighting)
        elseif obj == blur then
            blur = Instance.new("BlurEffect", Lighting)
        elseif obj == dof then
            dof = Instance.new("DepthOfFieldEffect", Lighting)
        elseif obj == colorcor then
            colorcor = Instance.new("ColorCorrectionEffect", Lighting)
        elseif obj == sunrays then
            sunrays = Instance.new("SunRaysEffect", Lighting)
        elseif obj == atmosphere then
            atmosphere = Instance.new("Atmosphere", Lighting)
        end
    end)
end)
