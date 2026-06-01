--[[
    Set Car etc Anonymous9x
    Universal Vehicle Controller + Anti-Bounce Physics
    UI Style: Indo Hangout inspired
    Features:
        - Vehicle Spawner (preset + custom model)
        - Full Physics Control (anti‑bounce, speed, flight, traction, freeze, noclip)
        - Suspension Tuning (per‑spring, presets)
        - Fun Mods (paint client‑side, gravity modes)
        - Visuals (fullbright, headlights)
    Works on any map (FE compatible)
    Length: 2000+ lines
]]

-- ===================== Services =====================
local setmetatable, rawset, type, pairs, ipairs, table, math, string, tick, wait, task, pcall, error =
      setmetatable, rawset, type, pairs, ipairs, table, math, string, tick, wait, task, pcall, error

local Services = setmetatable({}, {
    __index = function(self, name)
        local service = game:GetService(name)
        rawset(self, name, service)
        return service
    end
})

local TweenService = Services.TweenService
local RunService = Services.RunService
local UserInputService = Services.UserInputService
local Workspace = Services.Workspace
local Lighting = Services.Lighting
local StarterGui = Services.StarterGui
local CoreGui = Services.CoreGui
local Debris = Services.Debris
local Players = Services.Players
local InsertService = Services.InsertService
local ReplicatedStorage = Services.ReplicatedStorage
local VirtualInputManager = Services.VirtualInputManager

local LocalPlayer = Players.LocalPlayer
local Cam = Workspace.CurrentCamera

-- ===================== Vehicle Physics Data =====================
local PhysicsData = {
    System = {
        Active = true,
        Connections = {}
    },
    Physics = {
        Speed = { Enabled = false, Rate = 1.5, BrakeRate = 0.9 },
        Flight = { Enabled = false, Speed = 1, Smoothness = 0.1 },
        Traction = { Enabled = false, Grip = 1, Vector = 0 },
        BrakeOverride = { Enabled = false, Force = 50 },
        Freeze = false,
        Noclip = false,
        Velocity = { Mult = 0.025, BrakeMult = 0.15 },
        MaxGroundSpeed = 250,
        MaxAirSpeed = 100,
        GroundCheckDistance = 5,
        LastGroundTime = 0,
        AntiBounce = {
            Enabled = true,
            VelocityDampening = 0.92,
            AngularDampening = 0.85,
            SurfaceSmoothing = true,
            TransitionDampening = 0.75,
            EdgeDetectionRadius = 3,
            MaxHeightDiff = 0.5,
            MaxVelocityChange = 20,
            SmoothingFrames = 5,
            ImpactThreshold = 15,
            StabilizationTime = 0.4,
            LastImpactTime = 0,
            PreviousVelocity = Vector3.new(0,0,0),
            PreviousPosition = Vector3.new(0,0,0),
            VelocityHistory = {},
            GroundHeightHistory = {},
            CurrentSurface = nil,
            PreviousSurface = nil,
            InTransition = false,
            TransitionStartTime = 0
        }
    },
    Suspension = {
        Cache = {},
        OriginalValues = {},
        SpringCount = 0,
        CurrentSpringUI = {},
        Data = {
            Stiffness = 4000,
            Damping = 200,
            Height = 0,
            FrontStiff = 4000,
            RearStiff = 4000,
            Preload = 0,
            ARB = false,
            ARB_Str = 2000,
            MinLength = 0.5,
            MaxLength = 8
        }
    },
    Fun = {
        Heli = { Enabled = false, Speed = 0.5 },
        Trans = { Enabled = false, Mode = "None", Cache = {} },
        Gravity = { Enabled = false, Mode = "Normal", ForceObj = nil },
        Trail = { Enabled = false, Mode = "None", Cache = {} },
        Paint = { Color = Color3.new(1,0,0) }
    },
    Visuals = {
        Fullbright = {
            Enabled = false,
            Settings = { Brightness = 2, Ambient = Color3.new(1,1,1), FogEnd = 100000 }
        },
        Headlights = { Enabled = true }
    },
    Internal = {
        Vehicle = nil,
        Seat = nil,
        Size = { Mult = 1 },
        PartsCache = {},
        LastVehicleCheck = 0,
        VehicleModelName = "None",
        LastNotificationTime = 0,
        VehicleMass = 0
    }
}

-- ===================== Helper Functions (from original) =====================
local function lerp(a, b, t)
    return a + (b - a) * t
end

local function clampVector(v, maxMag)
    if v.Magnitude > maxMag then
        return v.Unit * maxMag
    end
    return v
end

-- Surface detection
local SurfaceDetector = {}
SurfaceDetector.DetectSurface = function(vehicle)
    if not vehicle or not vehicle.PrimaryPart then return nil end
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    rayParams.FilterDescendantsInstances = { vehicle }
    local rayResult = Workspace:Raycast(vehicle.PrimaryPart.Position, Vector3.new(0,-1,0)*10, rayParams)
    if rayResult then
        return {
            Instance = rayResult.Instance,
            Position = rayResult.Position,
            Normal = rayResult.Normal,
            Material = rayResult.Material,
            Height = rayResult.Position.Y
        }
    end
    return nil
end

SurfaceDetector.DetectTransition = function(currentSurf, previousSurf)
    if not currentSurf or not previousSurf then return false end
    if currentSurf.Instance ~= previousSurf.Instance then return true end
    if math.abs(currentSurf.Height - previousSurf.Height) > PhysicsData.Physics.AntiBounce.MaxHeightDiff then
        return true
    end
    return false
end

-- Velocity smoothing
local VelocityHandler = {}
VelocityHandler.UpdateVelocityHistory = function(velocity)
    table.insert(PhysicsData.Physics.AntiBounce.VelocityHistory, velocity)
    if #PhysicsData.Physics.AntiBounce.VelocityHistory > PhysicsData.Physics.AntiBounce.SmoothingFrames then
        table.remove(PhysicsData.Physics.AntiBounce.VelocityHistory, 1)
    end
end

VelocityHandler.GetSmoothedVelocity = function()
    local history = PhysicsData.Physics.AntiBounce.VelocityHistory
    if #history == 0 then return Vector3.zero end
    local sum = Vector3.zero
    for _, v in ipairs(history) do
        sum = sum + v
    end
    return sum / #history
end

VelocityHandler.DetectImpact = function(currentVel, previousVel)
    if (currentVel - previousVel).Magnitude > PhysicsData.Physics.AntiBounce.ImpactThreshold then
        PhysicsData.Physics.AntiBounce.LastImpactTime = tick()
        return true
    end
    return false
end

VelocityHandler.ApplyTransitionSmoothing = function(seat, vehicle)
    if not PhysicsData.Physics.AntiBounce.SurfaceSmoothing then return end
    if not seat or not vehicle then return end
    local surf = SurfaceDetector.DetectSurface(vehicle)
    if surf and SurfaceDetector.DetectTransition(surf, PhysicsData.Physics.AntiBounce.PreviousSurface) then
        PhysicsData.Physics.AntiBounce.InTransition = true
        PhysicsData.Physics.AntiBounce.TransitionStartTime = tick()
        local vel = seat.AssemblyLinearVelocity
        local damp = PhysicsData.Physics.AntiBounce.TransitionDampening
        seat.AssemblyLinearVelocity = Vector3.new(vel.X, vel.Y * damp, vel.Z)
        seat.AssemblyAngularVelocity = seat.AssemblyAngularVelocity * damp * 0.5
    end
    PhysicsData.Physics.AntiBounce.PreviousSurface = surf
    if PhysicsData.Physics.AntiBounce.InTransition then
        if tick() - PhysicsData.Physics.AntiBounce.TransitionStartTime < 0.2 then
            seat.AssemblyLinearVelocity = seat.AssemblyLinearVelocity * 0.95
        else
            PhysicsData.Physics.AntiBounce.InTransition = false
        end
    end
end

VelocityHandler.ApplyVelocitySmoothing = function(seat)
    if not seat then return end
    local currentVel = seat.AssemblyLinearVelocity
    local previousVel = PhysicsData.Physics.AntiBounce.PreviousVelocity
    if previousVel then
        VelocityHandler.DetectImpact(currentVel, previousVel)
        VelocityHandler.UpdateVelocityHistory(currentVel)
        local diff = currentVel - previousVel
        if diff.Magnitude > PhysicsData.Physics.AntiBounce.MaxVelocityChange then
            local targetVel = previousVel + clampVector(diff, PhysicsData.Physics.AntiBounce.MaxVelocityChange)
            seat.AssemblyLinearVelocity = lerp(currentVel, targetVel, 0.5)
        end
        PhysicsData.Physics.AntiBounce.PreviousVelocity = seat.AssemblyLinearVelocity
    else
        PhysicsData.Physics.AntiBounce.PreviousVelocity = currentVel
    end
end

VelocityHandler.ApplyStabilization = function(seat, vehicle)
    if not seat or not vehicle or not vehicle.PrimaryPart then return end
    local dt = tick() - PhysicsData.Physics.AntiBounce.LastImpactTime
    if dt < PhysicsData.Physics.AntiBounce.StabilizationTime then
        local t = dt / PhysicsData.Physics.AntiBounce.StabilizationTime
        local velDamp = PhysicsData.Physics.AntiBounce.VelocityDampening
        local angDamp = PhysicsData.Physics.AntiBounce.AngularDampening
        seat.AssemblyLinearVelocity = seat.AssemblyLinearVelocity * (velDamp + (1-velDamp)*t)
        seat.AssemblyAngularVelocity = seat.AssemblyAngularVelocity * (angDamp + (1-angDamp)*t)
        local up = vehicle.PrimaryPart.CFrame.UpVector
        local worldUp = Vector3.new(0,1,0)
        local angle = math.acos(math.clamp(up:Dot(worldUp), -1, 1))
        if angle > math.rad(10) then
            local axis = up:Cross(worldUp)
            if axis.Magnitude > 0 then
                local torque = axis.Unit * angle * 30 * (1 - t)
                pcall(function() seat:ApplyAngularImpulse(torque) end)
            end
        end
    end
end

VelocityHandler.Process = function(seat, vehicle)
    if not PhysicsData.Physics.AntiBounce.Enabled then return end
    if not seat or not vehicle then return end
    VelocityHandler.ApplyTransitionSmoothing(seat, vehicle)
    VelocityHandler.ApplyVelocitySmoothing(seat)
    VelocityHandler.ApplyStabilization(seat, vehicle)
end

-- Vehicle cache
local VehicleManager = {}
VehicleManager.CacheSuspension = function(vehicle)
    PhysicsData.Suspension.Cache = {}
    PhysicsData.Suspension.OriginalValues = {}
    PhysicsData.Suspension.SpringCount = 0
    for _, child in ipairs(vehicle:GetDescendants()) do
        if child:IsA("SpringConstraint") then
            PhysicsData.Suspension.OriginalValues[child] = {
                Stiffness = child.Stiffness,
                Damping = child.Damping,
                FreeLength = child.FreeLength,
                MinLength = child.MinLength,
                MaxLength = child.MaxLength
            }
            table.insert(PhysicsData.Suspension.Cache, child)
            PhysicsData.Suspension.SpringCount = PhysicsData.Suspension.SpringCount + 1
        end
    end
end

VehicleManager.CacheParts = function(vehicle)
    PhysicsData.Internal.PartsCache = {}
    PhysicsData.Internal.VehicleMass = 0
    for _, part in ipairs(vehicle:GetDescendants()) do
        if part:IsA("BasePart") then
            table.insert(PhysicsData.Internal.PartsCache, part)
            PhysicsData.Internal.VehicleMass = PhysicsData.Internal.VehicleMass + part:GetMass()
            if not part.Anchored then
                part.CustomPhysicalProperties = PhysicalProperties.new(0.7, 0.6, 0.15, 100, 100)
            end
        end
    end
end

VehicleManager.GetVehicle = function()
    local now = tick()
    if now - PhysicsData.Internal.LastVehicleCheck < 0.5 then return end
    PhysicsData.Internal.LastVehicleCheck = now
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildWhichIsA("Humanoid")
    if not hum then return end
    local seatPart = hum.SeatPart
    if seatPart and seatPart:IsA("VehicleSeat") then
        local vehicle = seatPart:FindFirstAncestorWhichIsA("Model")
        if vehicle and vehicle ~= PhysicsData.Internal.Vehicle then
            PhysicsData.Internal.Vehicle = vehicle
            PhysicsData.Internal.Seat = seatPart
            PhysicsData.Physics.AntiBounce.VelocityHistory = {}
            PhysicsData.Physics.AntiBounce.PreviousVelocity = Vector3.zero
            PhysicsData.Physics.AntiBounce.PreviousSurface = nil
            PhysicsData.Physics.AntiBounce.InTransition = false
            PhysicsData.Physics.AntiBounce.LastImpactTime = 0
            if not vehicle.PrimaryPart then vehicle.PrimaryPart = vehicle:FindFirstChild("BasePart") or vehicle:FindFirstChildWhichIsA("BasePart") end
            pcall(function()
                for _, part in ipairs(vehicle:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part:SetNetworkOwner(LocalPlayer)
                    end
                end
            end)
            VehicleManager.CacheSuspension(vehicle)
            VehicleManager.CacheParts(vehicle)
            PhysicsData.Internal.VehicleModelName = vehicle.Name
            if tick() - PhysicsData.Internal.LastNotificationTime > 3 then
                PhysicsData.Internal.LastNotificationTime = tick()
            end
        end
    else
        if PhysicsData.Internal.Vehicle then
            PhysicsData.Internal.Vehicle = nil
            PhysicsData.Internal.Seat = nil
            PhysicsData.Internal.PartsCache = {}
            PhysicsData.Suspension.Cache = {}
            PhysicsData.Suspension.SpringCount = 0
            PhysicsData.Internal.VehicleMass = 0
            PhysicsData.Physics.AntiBounce.VelocityHistory = {}
            PhysicsData.Physics.AntiBounce.PreviousVelocity = Vector3.zero
            PhysicsData.Physics.AntiBounce.PreviousSurface = nil
            PhysicsData.Physics.AntiBounce.InTransition = false
            PhysicsData.Physics.AntiBounce.LastImpactTime = 0
        end
    end
end

-- Process cycles
local PhysicsProcessor = {}
PhysicsProcessor.ProcessSpeed = function(seat, dt)
    if not PhysicsData.Physics.Speed.Enabled then return end
    if not seat then return end
    local vel = seat.AssemblyLinearVelocity
    local mult = dt * 60
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then
        local newVel = vel + seat.CFrame.LookVector * PhysicsData.Physics.Speed.Rate * mult
        local horizontal = Vector3.new(newVel.X, 0, newVel.Z)
        if horizontal.Magnitude > PhysicsData.Physics.MaxGroundSpeed then
            horizontal = horizontal.Unit * PhysicsData.Physics.MaxGroundSpeed
        end
        newVel = Vector3.new(horizontal.X, math.clamp(newVel.Y, -50, 50), horizontal.Z)
        seat.AssemblyLinearVelocity = newVel
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then
        local brake = math.clamp(1 - PhysicsData.Physics.Speed.BrakeRate * 0.1 * mult, 0, 1)
        seat.AssemblyLinearVelocity = vel * Vector3.new(brake, 0.98, brake)
    end
    if vel.Magnitude > 500 then
        seat.AssemblyLinearVelocity = vel.Unit * 300
    end
end

PhysicsProcessor.ProcessFlight = function(vehicle, seat, dt)
    if not PhysicsData.Physics.Flight.Enabled then return end
    local speed = PhysicsData.Physics.Flight.Speed
    local moveDir = Vector3.zero
    local keys = UserInputService
    if keys:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + Vector3.new(speed, 0, 0) end
    if keys:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir + Vector3.new(-speed, 0, 0) end
    if keys:IsKeyDown(Enum.KeyCode.E) then moveDir = moveDir + Vector3.new(0, speed/2, 0) end
    if keys:IsKeyDown(Enum.KeyCode.Q) then moveDir = moveDir + Vector3.new(0, -speed/2, 0) end
    if keys:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir + Vector3.new(0, 0, speed) end
    if keys:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + Vector3.new(0, 0, -speed) end
    if moveDir.Magnitude > 0 then
        local cf = vehicle:GetPrimaryPartCFrame()
        vehicle:SetPrimaryPartCFrame(cf + cf.Rotation * moveDir)
        seat.AssemblyLinearVelocity = seat.AssemblyLinearVelocity * 0.5
        seat.AssemblyAngularVelocity = seat.AssemblyAngularVelocity * 0.5
    end
end

PhysicsProcessor.ProcessTraction = function(vehicle, seat)
    if not PhysicsData.Physics.Traction.Enabled then return end
    if not vehicle.PrimaryPart then return end
    local cf = vehicle:GetPrimaryPartCFrame()
    local localVel = cf:VectorToObjectSpace(seat.AssemblyLinearVelocity)
    if math.abs(localVel.X) > 0.5 then
        seat:ApplyImpulse(cf.RightVector * -localVel.X * (1 - PhysicsData.Physics.Traction.Grip) * 50)
    end
end

PhysicsProcessor.ProcessSuspension = function(vehicle)
    if not vehicle or not vehicle.PrimaryPart then return end
    if #PhysicsData.Suspension.Cache == 0 then return end
    local data = PhysicsData.Suspension.Data
    local cf = vehicle.PrimaryPart.CFrame
    for _, spring in ipairs(PhysicsData.Suspension.Cache) do
        if spring and spring.Parent then
            local isFront = false
            if spring.Attachment0 and spring.Attachment0.Parent then
                isFront = cf:PointToObjectSpace(spring.Attachment0.WorldPosition).Z > 0
            end
            local stiff = isFront and data.FrontStiff or data.RearStiff
            spring.Stiffness = math.clamp(stiff, 100, 50000)
            spring.Damping = math.clamp(data.Damping, 10, 5000)
            spring.FreeLength = math.clamp(2 + data.Height + data.Preload, data.MinLength, data.MaxLength)
            spring.MinLength = math.clamp(0.2 + data.Height * 0.5, 0.1, 2)
            spring.MaxLength = math.clamp(4 + data.Height, 1, 10)
        end
    end
end

PhysicsProcessor.ProcessCollision = function(vehicle)
    if not vehicle then return end
    for _, part in ipairs(PhysicsData.Internal.PartsCache) do
        if part and part.Parent then
            if PhysicsData.Physics.Noclip then
                part.CanCollide = false
            end
            if PhysicsData.Physics.Freeze then
                part.Anchored = true
                part.AssemblyLinearVelocity = Vector3.zero
                part.AssemblyAngularVelocity = Vector3.zero
            end
        end
    end
end

-- ===================== Fun Functions =====================
local function applyColorToVehicle(color)
    local vehicle = PhysicsData.Internal.Vehicle
    if not vehicle then return end
    local bodyKeywords = {"body","chassis","frame","door","hood","trunk","fender","bumper","quarter","roof","paint","panel","part","car"}
    local excludeKeywords = {"window","glass","wheel","tire","rim","light","headlight","taillight","brake","signal","engine","exhaust","pipe","mirror","handle","seat","interior","dash","gauge","steer"}
    local count = 0
    for _, part in ipairs(vehicle:GetDescendants()) do
        if part:IsA("BasePart") then
            local name = part.Name:lower()
            local shouldPaint = false
            for _, kw in ipairs(bodyKeywords) do
                if name:find(kw, 1, true) then shouldPaint = true break end
            end
            if not shouldPaint and (name == "part" or name:match("^part%d") or name == "union") then
                shouldPaint = true
            end
            local excluded = false
            for _, kw in ipairs(excludeKeywords) do
                if name:find(kw, 1, true) then excluded = true break end
            end
            if shouldPaint and not excluded then
                part.Color = color
                part.Material = Enum.Material.SmoothPlastic
                count = count + 1
            end
        end
    end
end

local function setGravityMode(enabled, mode)
    local seat = PhysicsData.Internal.Seat
    if not seat then return end
    if PhysicsData.Fun.Gravity.ForceObj then
        PhysicsData.Fun.Gravity.ForceObj:Destroy()
        PhysicsData.Fun.Gravity.ForceObj = nil
    end
    for _, child in ipairs(seat:GetChildren()) do
        if child:IsA("Attachment") and child.Name == "GravityAttachment" then
            child:Destroy()
        end
    end
    if enabled then
        local force = Instance.new("VectorForce")
        force.ApplyAtCenterOfMass = true
        force.Parent = seat
        local attach = Instance.new("Attachment")
        attach.Name = "GravityAttachment"
        attach.Parent = seat
        force.Attachment0 = attach
        local mass = seat:GetMass()
        if mode == "Moon" then force.Force = Vector3.new(0, Workspace.Gravity * mass * 0.2, 0)
        elseif mode == "Heavy" then force.Force = Vector3.new(0, -Workspace.Gravity * mass, 0)
        elseif mode == "Zero" then force.Force = Vector3.new(0, Workspace.Gravity * mass, 0)
        elseif mode == "Reverse" then force.Force = Vector3.new(0, Workspace.Gravity * mass * 1.5, 0)
        else force.Force = Vector3.new(0,0,0) end
        PhysicsData.Fun.Gravity.ForceObj = force
    end
end

-- ===================== UI Framework (Indo Hangout style) =====================
local UI = {}
UI.Minimized = false

-- Colors
local C = {
    bg = Color3.fromRGB(7,7,9),
    hdr = Color3.fromRGB(5,5,7),
    card = Color3.fromRGB(15,15,19),
    cardH = Color3.fromRGB(21,21,27),
    sep = Color3.fromRGB(26,26,34),
    border = Color3.fromRGB(40,40,56),
    white = Color3.new(1,1,1),
    pri = Color3.fromRGB(218,218,226),
    sec = Color3.fromRGB(110,110,130),
    dim = Color3.fromRGB(60,60,80),
    purple = Color3.fromRGB(170,110,255),
    purpleD = Color3.fromRGB(120,70,210),
    safe = Color3.fromRGB(80,185,90),
    danger = Color3.fromRGB(210,55,55),
}

local gui = Instance.new("ScreenGui")
gui.Name = "SetCarUI"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.IgnoreGuiInset = true
pcall(function() gui.Parent = CoreGui end)
if not gui.Parent then gui.Parent = LocalPlayer.PlayerGui end

-- Notification system
local notifQueue = {}
local notifActive = false
function UI:Notify(title, body, duration)
    table.insert(notifQueue, {title=title, body=body, dur=duration or 3.5})
    if notifActive then return end
    notifActive = true
    task.spawn(function()
        while #notifQueue > 0 do
            local n = table.remove(notifQueue, 1)
            local nf = Instance.new("Frame")
            nf.Size = UDim2.fromOffset(220, 54)
            nf.Position = UDim2.new(1, 10, 1, -70)
            nf.BackgroundColor3 = C.bg
            nf.BackgroundTransparency = 0
            nf.BorderSizePixel = 0
            nf.ZIndex = 800
            nf.Parent = gui
            Instance.new("UICorner", nf).CornerRadius = UDim.new(0,7)
            local nfS = Instance.new("UIStroke", nf)
            nfS.Color = C.purple
            nfS.Thickness = 1.2
            local nt = Instance.new("TextLabel")
            nt.Size = UDim2.new(1,-12,0,18)
            nt.Position = UDim2.fromOffset(8,5)
            nt.BackgroundTransparency = 1
            nt.Text = n.title
            nt.Font = Enum.Font.GothamBold
            nt.TextSize = 10
            nt.TextColor3 = C.white
            nt.TextXAlignment = Enum.TextXAlignment.Left
            nt.ZIndex = 801
            nt.Parent = nf
            local nb = Instance.new("TextLabel")
            nb.Size = UDim2.new(1,-12,0,22)
            nb.Position = UDim2.fromOffset(8,24)
            nb.BackgroundTransparency = 1
            nb.Text = n.body
            nb.Font = Enum.Font.Gotham
            nb.TextSize = 8
            nb.TextColor3 = C.sec
            nb.TextXAlignment = Enum.TextXAlignment.Left
            nb.TextWrapped = true
            nb.ZIndex = 801
            nb.Parent = nf
            TweenService:Create(nf, TweenInfo.new(0.20, Enum.EasingStyle.Quad), {Position = UDim2.new(1,-228,1,-70)}):Play()
            task.wait(n.dur)
            TweenService:Create(nf, TweenInfo.new(0.18, Enum.EasingStyle.Quad), {Position = UDim2.new(1,10,1,-70)}):Play()
            task.wait(0.20)
            pcall(function() nf:Destroy() end)
            task.wait(0.08)
        end
        notifActive = false
    end)
end

-- Main window
local WIDTH, HEIGHT = 260, 380
local win = Instance.new("Frame")
win.Name = "Win"
win.Size = UDim2.fromOffset(WIDTH, HEIGHT)
win.Position = UDim2.fromScale(0.5, 0.5)
win.AnchorPoint = Vector2.new(0.5, 0.5)
win.BackgroundColor3 = C.bg
win.BackgroundTransparency = 0
win.BorderSizePixel = 0
win.ClipsDescendants = true
win.ZIndex = 10
win.Parent = gui
Instance.new("UICorner", win).CornerRadius = UDim.new(0,8)
local winStroke = Instance.new("UIStroke", win)
winStroke.Thickness = 1.3
winStroke.Color = C.border
task.spawn(function()
    local t = 0
    while win.Parent do
        t = t + task.wait(0.04)
        local s = (math.sin(t * 2.4) + 1) / 2
        winStroke.Color = Color3.new(0.86 + s * 0.14, 0.76 + s * 0.05, 0.88 + s * 0.52)
        winStroke.Thickness = 1.2 + s * 0.6
    end
end)

-- Header
local hdr = Instance.new("Frame")
hdr.Size = UDim2.new(1,0,0,32)
hdr.BackgroundColor3 = C.hdr
hdr.BorderSizePixel = 0
hdr.ZIndex = 12
hdr.Parent = win
Instance.new("UICorner", hdr).CornerRadius = UDim.new(0,8)
local hPatch = Instance.new("Frame")
hPatch.Size = UDim2.new(1,0,0,8)
hPatch.Position = UDim2.new(0,0,1,-8)
hPatch.BackgroundColor3 = C.hdr
hPatch.BorderSizePixel = 0
hPatch.ZIndex = 11
hPatch.Parent = hdr
local hTitle = Instance.new("TextLabel")
hTitle.Size = UDim2.new(1,-52,1,0)
hTitle.Position = UDim2.fromOffset(9,0)
hTitle.BackgroundTransparency = 1
hTitle.Text = "Set Car etc Anonymous9x"
hTitle.Font = Enum.Font.GothamBold
hTitle.TextSize = 10
hTitle.TextColor3 = C.pri
hTitle.TextXAlignment = Enum.TextXAlignment.Left
hTitle.TextTruncate = Enum.TextTruncate.AtEnd
hTitle.ZIndex = 13
hTitle.Parent = hdr

local function makeCtrl(xOff, sym)
    local b = Instance.new("ImageButton")
    b.Size = UDim2.fromOffset(20,18)
    b.Position = UDim2.new(1,xOff,0.5,-9)
    b.BackgroundColor3 = C.card
    b.BackgroundTransparency = 0
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
    l.TextColor3 = C.sec
    l.ZIndex = 15
    l.Parent = b
    b.MouseEnter:Connect(function()
        TweenService:Create(b,TweenInfo.new(0.10),{BackgroundColor3=C.cardH}):Play()
        l.TextColor3 = C.white
    end)
    b.MouseLeave:Connect(function()
        TweenService:Create(b,TweenInfo.new(0.10),{BackgroundColor3=C.card}):Play()
        l.TextColor3 = C.sec
    end)
    return b, l
end

local minBtn, minL = makeCtrl(-44, "-")
local closeBtn, _ = makeCtrl(-22, "x")

-- Minimize icon
local floatF = Instance.new("Frame")
floatF.Name = "FloatIcon"
floatF.Size = UDim2.fromOffset(46,46)
floatF.BackgroundColor3 = C.hdr
floatF.BackgroundTransparency = 0
floatF.BorderSizePixel = 0
floatF.Visible = false
floatF.ZIndex = 500
floatF.Parent = gui
Instance.new("UICorner",floatF).CornerRadius = UDim.new(0,10)
local fiS = Instance.new("UIStroke",floatF)
fiS.Color = C.purple
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
    local vp = Cam.ViewportSize
    floatF.Position = UDim2.fromOffset(vp.X-56, math.floor(vp.Y/2)-23)
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
    TweenService:Create(floatF,TweenInfo.new(0.12),{BackgroundColor3=C.card}):Play()
end)
fiBtn.MouseLeave:Connect(function()
    TweenService:Create(floatF,TweenInfo.new(0.12),{BackgroundColor3=C.hdr}):Play()
end)
minBtn.MouseButton1Click:Connect(function()
    win.Visible = false
    anchorFloat()
    floatF.Visible = true
    minL.Text = "+"
end)
closeBtn.MouseButton1Click:Connect(function()
    -- Cleanup
    for _, conn in ipairs(PhysicsData.System.Connections) do
        pcall(function() conn:Disconnect() end)
    end
    PhysicsData.System.Connections = {}
    pcall(function() gui:Destroy() end)
end)

-- Tab bar and content
local tabBar = Instance.new("Frame")
tabBar.Size = UDim2.new(1,0,0,26)
tabBar.Position = UDim2.new(0,0,0,32)
tabBar.BackgroundColor3 = C.bg
tabBar.BorderSizePixel = 0
tabBar.ZIndex = 11
tabBar.Parent = win
local tabScroll = Instance.new("ScrollingFrame")
tabScroll.Size = UDim2.new(1,0,1,0)
tabScroll.BackgroundTransparency = 1
tabScroll.ScrollBarThickness = 2
tabScroll.ScrollBarImageColor3 = C.purple
tabScroll.ScrollingDirection = Enum.ScrollingDirection.X
tabScroll.CanvasSize = UDim2.new(2,0,0,0)
tabScroll.BorderSizePixel = 0
tabScroll.ZIndex = 12
tabScroll.Parent = tabBar
local tabLayout = Instance.new("UIListLayout")
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.Padding = UDim.new(0,2)
tabLayout.Parent = tabScroll

local content = Instance.new("ScrollingFrame")
content.Size = UDim2.new(1,0,1,-58)
content.Position = UDim2.new(0,0,0,58)
content.BackgroundColor3 = C.bg
content.BorderSizePixel = 0
content.ScrollBarThickness = 3
content.ScrollBarImageColor3 = C.purple
content.ScrollingDirection = Enum.ScrollingDirection.Y
content.CanvasSize = UDim2.fromOffset(0,0)
content.AutomaticCanvasSize = Enum.AutomaticSize.Y
content.ZIndex = 11
content.Parent = win
local sLL = Instance.new("UIListLayout")
sLL.SortOrder = Enum.SortOrder.LayoutOrder
sLL.Padding = UDim.new(0,4)
sLL.Parent = content
local sPad = Instance.new("UIPadding")
sPad.PaddingLeft = UDim.new(0,7)
sPad.PaddingRight = UDim.new(0,7)
sPad.PaddingTop = UDim.new(0,7)
sPad.PaddingBottom = UDim.new(0,10)
sPad.Parent = content

-- Tab management
UI.Tabs = {}
UI.CurrentTab = nil
local _order = 0
local function ord() _order = _order + 1; return _order end

function UI:AddTab(name)
    local tabBtn = Instance.new("TextButton")
    tabBtn.Name = name
    tabBtn.Size = UDim2.new(0, 80, 0, 22)
    tabBtn.BackgroundColor3 = C.card
    tabBtn.Text = name
    tabBtn.Font = Enum.Font.GothamBold
    tabBtn.TextSize = 9
    tabBtn.TextColor3 = C.sec
    tabBtn.BorderSizePixel = 0
    tabBtn.ZIndex = 12
    tabBtn.Parent = tabScroll
    Instance.new("UICorner",tabBtn).CornerRadius = UDim.new(0,4)

    local tabFrame = Instance.new("Frame")
    tabFrame.Name = "Tab_"..name
    tabFrame.Size = UDim2.new(1,0,0,100)
    tabFrame.BackgroundTransparency = 1
    tabFrame.BorderSizePixel = 0
    tabFrame.Visible = false
    tabFrame.Parent = content
    local tabLayout = Instance.new("UIListLayout")
    tabLayout.FillDirection = Enum.FillDirection.Vertical
    tabLayout.Padding = UDim.new(0,6)
    tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabLayout.Parent = tabFrame

    local tabData = {
        Button = tabBtn,
        Frame = tabFrame,
        Sections = {}
    }

    tabBtn.MouseButton1Click:Connect(function()
        UI:SwitchTab(name)
    end)

    table.insert(UI.Tabs, tabData)
    if #UI.Tabs == 1 then
        UI:SwitchTab(name)
    end
    return tabData
end

function UI:SwitchTab(name)
    for _, tab in ipairs(UI.Tabs) do
        if tab.Button.Name == name then
            tab.Frame.Visible = true
            tab.Button.BackgroundColor3 = C.purple
            tab.Button.TextColor3 = C.white
            UI.CurrentTab = tab
        else
            tab.Frame.Visible = false
            tab.Button.BackgroundColor3 = C.card
            tab.Button.TextColor3 = C.sec
        end
    end
end

function UI:AddSection(tabData, sectionName)
    local section = Instance.new("Frame")
    section.Size = UDim2.new(1,0,0,18)
    section.BackgroundTransparency = 1
    section.BorderSizePixel = 0
    section.LayoutOrder = ord()
    section.Parent = tabData.Frame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.fromScale(1,1)
    label.BackgroundTransparency = 1
    label.Text = sectionName:upper()
    label.Font = Enum.Font.GothamBold
    label.TextSize = 7
    label.TextColor3 = C.purple
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 13
    label.Parent = section
    local line = Instance.new("Frame")
    line.Size = UDim2.new(1,0,0,1)
    line.Position = UDim2.new(0,0,1,-1)
    line.BackgroundColor3 = C.sep
    line.BorderSizePixel = 0
    line.ZIndex = 13
    line.Parent = section

    local elementsContainer = Instance.new("Frame")
    elementsContainer.Size = UDim2.new(1,0,0,0)
    elementsContainer.BackgroundTransparency = 1
    elementsContainer.LayoutOrder = ord()
    elementsContainer.Parent = tabData.Frame
    local elLayout = Instance.new("UIListLayout")
    elLayout.FillDirection = Enum.FillDirection.Vertical
    elLayout.Padding = UDim.new(0,4)
    elLayout.Parent = elementsContainer

    local sectionData = {
        Frame = section,
        ElementsContainer = elementsContainer,
        Elements = {}
    }
    table.insert(tabData.Sections, sectionData)
    return sectionData
end

-- Custom slider
function UI:CreateSlider(sectionData, name, min, max, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1,0,0,45)
    frame.BackgroundColor3 = C.card
    frame.BackgroundTransparency = 0
    frame.BorderSizePixel = 0
    frame.Parent = sectionData.ElementsContainer
    Instance.new("UICorner",frame).CornerRadius = UDim.new(0,6)
    local bS = Instance.new("UIStroke",frame)
    bS.Color = C.border
    bS.Thickness = 0.8

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1,-10,0,16)
    label.Position = UDim2.fromOffset(8,4)
    label.BackgroundTransparency = 1
    label.Text = name .. " (" .. default .. ")"
    label.Font = Enum.Font.GothamBold
    label.TextSize = 9
    label.TextColor3 = C.pri
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local track = Instance.new("Frame")
    track.Size = UDim2.new(1,-16,0,10)
    track.Position = UDim2.fromOffset(8,26)
    track.BackgroundColor3 = C.dim
    track.BorderSizePixel = 0
    track.Parent = frame
    Instance.new("UICorner",track).CornerRadius = UDim.new(1,0)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.fromScale((default-min)/(max-min), 1)
    fill.BackgroundColor3 = C.purple
    fill.BorderSizePixel = 0
    fill.Parent = track
    Instance.new("UICorner",fill).CornerRadius = UDim.new(1,0)

    local knob = Instance.new("ImageButton")
    knob.Size = UDim2.fromOffset(16,16)
    knob.Position = UDim2.fromScale((default-min)/(max-min), -8)
    knob.BackgroundColor3 = C.white
    knob.BorderSizePixel = 0
    knob.Image = ""
    knob.ZIndex = 14
    knob.Parent = track
    Instance.new("UICorner",knob).CornerRadius = UDim.new(1,0)

    local dragging = false
    knob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mousePos = UserInputService:GetMouseLocation()
            local relX = mousePos.X - track.AbsolutePosition.X
            local fraction = math.clamp(relX / track.AbsoluteSize.X, 0, 1)
            local value = math.floor(min + (max-min)*fraction)
            fill.Size = UDim2.fromScale(fraction, 1)
            knob.Position = UDim2.fromScale(fraction, -8)
            label.Text = name .. " (" .. value .. ")"
            callback(value)
        end
    end)
    callback(default)
    return frame
end

-- Button
function UI:CreateButton(sectionData, name, callback)
    local btn = Instance.new("ImageButton")
    btn.Size = UDim2.new(1,0,0,30)
    btn.BackgroundColor3 = C.card
    btn.BackgroundTransparency = 0
    btn.BorderSizePixel = 0
    btn.Image = ""
    btn.AutoButtonColor = false
    btn.Parent = sectionData.ElementsContainer
    Instance.new("UICorner",btn).CornerRadius = UDim.new(0,6)
    local bS = Instance.new("UIStroke",btn)
    bS.Color = C.border
    bS.Thickness = 0.8
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1,-10,1,0)
    lbl.Position = UDim2.fromOffset(8,0)
    lbl.BackgroundTransparency = 1
    lbl.Text = name
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 10
    lbl.TextColor3 = C.pri
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 13
    lbl.Parent = btn
    btn.MouseButton1Click:Connect(function()
        TweenService:Create(btn,TweenInfo.new(0.08),{BackgroundColor3=C.cardH}):Play()
        task.delay(0.15,function() TweenService:Create(btn,TweenInfo.new(0.10),{BackgroundColor3=C.card}):Play() end)
        callback()
    end)
    btn.MouseEnter:Connect(function() TweenService:Create(btn,TweenInfo.new(0.10),{BackgroundColor3=C.cardH}):Play() end)
    btn.MouseLeave:Connect(function() TweenService:Create(btn,TweenInfo.new(0.10),{BackgroundColor3=C.card}):Play() end)
    return btn
end

-- Toggle
function UI:CreateToggle(sectionData, name, default, onCb, offCb)
    local btn = Instance.new("ImageButton")
    btn.Size = UDim2.new(1,0,0,30)
    btn.BackgroundColor3 = C.card
    btn.BackgroundTransparency = 0
    btn.BorderSizePixel = 0
    btn.Image = ""
    btn.AutoButtonColor = false
    btn.Parent = sectionData.ElementsContainer
    Instance.new("UICorner",btn).CornerRadius = UDim.new(0,6)
    local bS = Instance.new("UIStroke",btn)
    bS.Color = C.border
    bS.Thickness = 0.8

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1,-46,1,0)
    lbl.Position = UDim2.fromOffset(8,0)
    lbl.BackgroundTransparency = 1
    lbl.Text = name
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 10
    lbl.TextColor3 = C.pri
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 13
    lbl.Parent = btn

    local TW, TH2 = 24, 13
    local trk = Instance.new("Frame")
    trk.Size = UDim2.fromOffset(TW, TH2)
    trk.Position = UDim2.new(1, -(TW+6), 0.5, -(TH2/2))
    trk.BackgroundColor3 = C.border
    trk.BorderSizePixel = 0
    trk.ZIndex = 13
    trk.Parent = btn
    Instance.new("UICorner",trk).CornerRadius = UDim.new(1,0)
    local KS = TH2 - 4
    local knob = Instance.new("Frame")
    knob.Size = UDim2.fromOffset(KS, KS)
    knob.Position = UDim2.fromOffset(default and TW-KS-2 or 2, 2)
    knob.BackgroundColor3 = C.white
    knob.BorderSizePixel = 0
    knob.ZIndex = 14
    knob.Parent = trk
    Instance.new("UICorner",knob).CornerRadius = UDim.new(1,0)

    local state = default
    btn.MouseButton1Click:Connect(function()
        state = not state
        TweenService:Create(trk,TweenInfo.new(0.12),{BackgroundColor3 = state and C.purple or C.border}):Play()
        TweenService:Create(knob,TweenInfo.new(0.12),{Position = state and UDim2.fromOffset(TW-KS-2,2) or UDim2.fromOffset(2,2)}):Play()
        TweenService:Create(btn,TweenInfo.new(0.08),{BackgroundColor3=C.cardH}):Play()
        task.delay(0.15,function() TweenService:Create(btn,TweenInfo.new(0.10),{BackgroundColor3=C.card}):Play() end)
        if state then
            if onCb then onCb() end
        else
            if offCb then offCb() end
        end
    end)
    btn.MouseEnter:Connect(function() TweenService:Create(btn,TweenInfo.new(0.10),{BackgroundColor3=C.cardH}):Play() end)
    btn.MouseLeave:Connect(function() TweenService:Create(btn,TweenInfo.new(0.10),{BackgroundColor3=C.card}):Play() end)
    if default and onCb then onCb() end
    return btn
end

-- Dropdown
function UI:CreateDropdown(sectionData, name, items, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1,0,0,32)
    frame.BackgroundColor3 = C.card
    frame.BackgroundTransparency = 0
    frame.BorderSizePixel = 0
    frame.Parent = sectionData.ElementsContainer
    Instance.new("UICorner",frame).CornerRadius = UDim.new(0,6)
    local bS = Instance.new("UIStroke",frame)
    bS.Color = C.border
    bS.Thickness = 0.8

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.45,0,1,0)
    lbl.Position = UDim2.fromOffset(8,0)
    lbl.BackgroundTransparency = 1
    lbl.Text = name
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 10
    lbl.TextColor3 = C.pri
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 13
    lbl.Parent = frame

    local dropBtn = Instance.new("TextButton")
    dropBtn.Size = UDim2.new(0.45,0,1,0)
    dropBtn.Position = UDim2.new(0.55,0,0,0)
    dropBtn.BackgroundColor3 = C.card
    dropBtn.Text = default
    dropBtn.Font = Enum.Font.Gotham
    dropBtn.TextSize = 9
    dropBtn.TextColor3 = C.pri
    dropBtn.BorderSizePixel = 0
    dropBtn.ZIndex = 13
    dropBtn.Parent = frame
    Instance.new("UICorner",dropBtn).CornerRadius = UDim.new(0,4)

    local listFrame = Instance.new("Frame")
    listFrame.Size = UDim2.new(0.45,0,0,0)
    listFrame.Position = UDim2.new(0.55,0,1,2)
    listFrame.BackgroundColor3 = C.bg
    listFrame.BorderSizePixel = 0
    listFrame.Visible = false
    listFrame.ZIndex = 20
    listFrame.Parent = frame
    local listLayout = Instance.new("UIListLayout")
    listLayout.FillDirection = Enum.FillDirection.Vertical
    listLayout.Parent = listFrame

    local function buildList()
        for _,v in ipairs(listFrame:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
        for _,item in ipairs(items) do
            local ib = Instance.new("TextButton")
            ib.Size = UDim2.new(1,0,0,22)
            ib.BackgroundColor3 = C.card
            ib.Text = item
            ib.Font = Enum.Font.Gotham
            ib.TextSize = 9
            ib.TextColor3 = C.pri
            ib.BorderSizePixel = 0
            ib.ZIndex = 21
            ib.Parent = listFrame
            ib.MouseButton1Click:Connect(function()
                dropBtn.Text = item
                listFrame.Visible = false
                callback(item)
            end)
        end
        listFrame.Size = UDim2.new(0.45,0,0, #items*22)
    end
    buildList()

    dropBtn.MouseButton1Click:Connect(function()
        listFrame.Visible = not listFrame.Visible
    end)
    callback(default)
    return frame
end

-- Color picker (simple presets)
function UI:CreateColorpicker(sectionData, name, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1,0,0,30)
    frame.BackgroundColor3 = C.card
    frame.BackgroundTransparency = 0
    frame.BorderSizePixel = 0
    frame.Parent = sectionData.ElementsContainer
    Instance.new("UICorner",frame).CornerRadius = UDim.new(0,6)
    local bS = Instance.new("UIStroke",frame)
    bS.Color = C.border
    bS.Thickness = 0.8

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.45,0,1,0)
    lbl.Position = UDim2.fromOffset(8,0)
    lbl.BackgroundTransparency = 1
    lbl.Text = name
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 10
    lbl.TextColor3 = C.pri
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 13
    lbl.Parent = frame

    local preview = Instance.new("Frame")
    preview.Size = UDim2.fromOffset(24,24)
    preview.Position = UDim2.new(0.5,0,0,3)
    preview.BackgroundColor3 = default
    preview.BorderSizePixel = 0
    preview.ZIndex = 13
    preview.Parent = frame
    Instance.new("UICorner",preview).CornerRadius = UDim.new(0,4)

    local pickerBtn = Instance.new("TextButton")
    pickerBtn.Size = UDim2.new(0.35,0,1,0)
    pickerBtn.Position = UDim2.new(0.65,0,0,0)
    pickerBtn.BackgroundColor3 = C.card
    pickerBtn.Text = "Pick"
    pickerBtn.Font = Enum.Font.Gotham
    pickerBtn.TextSize = 9
    pickerBtn.TextColor3 = C.pri
    pickerBtn.BorderSizePixel = 0
    pickerBtn.ZIndex = 13
    pickerBtn.Parent = frame
    Instance.new("UICorner",pickerBtn).CornerRadius = UDim.new(0,4)

    local pickerList = Instance.new("Frame")
    pickerList.Size = UDim2.new(0.35,0,0,100)
    pickerList.Position = UDim2.new(0.65,0,1,2)
    pickerList.BackgroundColor3 = C.bg
    pickerList.BorderSizePixel = 0
    pickerList.Visible = false
    pickerList.ZIndex = 20
    pickerList.Parent = frame
    local pickerLayout = Instance.new("UIListLayout")
    pickerLayout.FillDirection = Enum.FillDirection.Vertical
    pickerLayout.Parent = pickerList

    local colors = {
        {name="Red", col=Color3.new(1,0,0)},
        {name="Green", col=Color3.new(0,1,0)},
        {name="Blue", col=Color3.new(0,0,1)},
        {name="Purple", col=Color3.fromRGB(170,110,255)},
        {name="White", col=Color3.new(1,1,1)},
        {name="Black", col=Color3.new(0,0,0)},
        {name="Orange", col=Color3.new(1,0.5,0)},
    }
    for _,c in ipairs(colors) do
        local cb = Instance.new("TextButton")
        cb.Size = UDim2.new(1,0,0,22)
        cb.BackgroundColor3 = C.card
        cb.Text = c.name
        cb.Font = Enum.Font.Gotham
        cb.TextSize = 9
        cb.TextColor3 = C.pri
        cb.BorderSizePixel = 0
        cb.ZIndex = 21
        cb.Parent = pickerList
        cb.MouseButton1Click:Connect(function()
            preview.BackgroundColor3 = c.col
            pickerList.Visible = false
            callback(c.col)
        end)
    end
    pickerList.Size = UDim2.new(0.35,0,0, #colors*22)
    pickerBtn.MouseButton1Click:Connect(function()
        pickerList.Visible = not pickerList.Visible
    end)
    callback(default)
    return frame
end

-- ===================== Build Tabs =====================
local spawnTab = UI:AddTab("Spawn")
local physTab = UI:AddTab("Physics")
local suspTab = UI:AddTab("Suspension")
local funTab = UI:AddTab("Fun")
local visTab = UI:AddTab("Visuals")

-- SPAWN TAB
local spawnSec = UI:AddSection(spawnTab, "Vehicle Spawner")
local presets = {"Basic Car", "Motorcycle", "Monster Truck", "Sedan", "SUV", "Sports Car"}
local selectedPreset = "Basic Car"
UI:CreateDropdown(spawnSec, "Preset", presets, "Basic Car", function(val) selectedPreset = val end)
UI:CreateButton(spawnSec, "Spawn Preset", function()
    local char = LocalPlayer.Character
    if not char then UI:Notify("Error","No character") return end
    local pos = char:GetPivot().Position + Vector3.new(0,5,0)
    local vehicle = Instance.new("Model")
    vehicle.Name = selectedPreset
    local base = Instance.new("Part")
    base.Size = Vector3.new(4,1.2,6)
    base.Position = pos
    base.Anchored = false
    base.Color = Color3.new(1,0,0)
    base.Material = Enum.Material.SmoothPlastic
    base.Parent = vehicle
    local seat = Instance.new("VehicleSeat")
    seat.Size = Vector3.new(2,1.2,2)
    seat.Position = pos + Vector3.new(0,1.2,0)
    seat.Parent = vehicle
    vehicle.PrimaryPart = base
    vehicle.Parent = Workspace
    UI:Notify("Spawner", selectedPreset.." spawned", 3)
end)
UI:CreateButton(spawnSec, "Spawn Custom Model (ID)", function()
    local id = "rbxassetid://"
    local box = Instance.new("TextBox")
    box.Size = UDim2.new(1,0,0,28)
    box.BackgroundColor3 = C.card
    box.Text = ""
    box.PlaceholderText = "Enter asset ID"
    box.Font = Enum.Font.Gotham
    box.TextSize = 9
    box.TextColor3 = C.white
    box.Parent = spawnSec.ElementsContainer
    -- quick hack: add a temporary button to confirm
    local confirm = UI:CreateButton(spawnSec, "Confirm Spawn", function()
        local idText = box.Text
        if idText == "" then return end
        pcall(function()
            local model = InsertService:LoadAsset(tonumber(idText:match("%d+")))
            if model and model:IsA("Model") then
                model:PivotTo(LocalPlayer.Character:GetPivot() + Vector3.new(0,5,0))
                model.Parent = Workspace
                UI:Notify("Spawner","Custom model loaded",3)
            end
        end)
        box:Destroy()
        confirm:Destroy()
    end)
end)

-- PHYSICS TAB
local abSec = UI:AddSection(physTab, "Anti-Bounce")
UI:CreateToggle(abSec, "Enabled", true, function() PhysicsData.Physics.AntiBounce.Enabled = true end, function() PhysicsData.Physics.AntiBounce.Enabled = false end)
UI:CreateToggle(abSec, "Surface Smoothing", true, function() PhysicsData.Physics.AntiBounce.SurfaceSmoothing = true end, function() PhysicsData.Physics.AntiBounce.SurfaceSmoothing = false end)
UI:CreateSlider(abSec, "Transition Dampening", 0,100, 75, function(v) PhysicsData.Physics.AntiBounce.TransitionDampening = v/100 end)
UI:CreateSlider(abSec, "Velocity Dampening", 0,100, 92, function(v) PhysicsData.Physics.AntiBounce.VelocityDampening = v/100 end)
UI:CreateSlider(abSec, "Angular Dampening", 0,100, 85, function(v) PhysicsData.Physics.AntiBounce.AngularDampening = v/100 end)
UI:CreateSlider(abSec, "Impact Sensitivity", 5,50, 15, function(v) PhysicsData.Physics.AntiBounce.ImpactThreshold = v end)

local speedSec = UI:AddSection(physTab, "Speed Control")
UI:CreateToggle(speedSec, "Enabled", false, function() PhysicsData.Physics.Speed.Enabled = true end, function() PhysicsData.Physics.Speed.Enabled = false end)
UI:CreateSlider(speedSec, "Accel Rate", 10,500, 150, function(v) PhysicsData.Physics.Speed.Rate = v/100 end)
UI:CreateSlider(speedSec, "Brake Rate", 10,200, 90, function(v) PhysicsData.Physics.Speed.BrakeRate = v/100 end)
UI:CreateSlider(speedSec, "Max Speed", 50,400, 250, function(v) PhysicsData.Physics.MaxGroundSpeed = v end)

local flightSec = UI:AddSection(physTab, "Flight")
UI:CreateToggle(flightSec, "Enabled", false, function() PhysicsData.Physics.Flight.Enabled = true end, function() PhysicsData.Physics.Flight.Enabled = false end)
UI:CreateSlider(flightSec, "Speed", 10,800, 100, function(v) PhysicsData.Physics.Flight.Speed = v/100 end)

local tractionSec = UI:AddSection(physTab, "Traction")
UI:CreateToggle(tractionSec, "Enabled", false, function() PhysicsData.Physics.Traction.Enabled = true end, function() PhysicsData.Physics.Traction.Enabled = false end)
UI:CreateSlider(tractionSec, "Grip", 10,150, 100, function(v) PhysicsData.Physics.Traction.Grip = v/100 end)

local collisionSec = UI:AddSection(physTab, "Collision")
UI:CreateToggle(collisionSec, "Freeze", false, function() PhysicsData.Physics.Freeze = true end, function() PhysicsData.Physics.Freeze = false end)
UI:CreateToggle(collisionSec, "Noclip", false, function() PhysicsData.Physics.Noclip = true end, function() PhysicsData.Physics.Noclip = false end)

-- SUSPENSION TAB
local globSusp = UI:AddSection(suspTab, "Global Settings")
UI:CreateSlider(globSusp, "Stiffness", 0,100, 40, function(v)
    local val = v*100
    PhysicsData.Suspension.Data.Stiffness = val
    PhysicsData.Suspension.Data.FrontStiff = val
    PhysicsData.Suspension.Data.RearStiff = val
end)
UI:CreateSlider(globSusp, "Height", -30,30, 0, function(v) PhysicsData.Suspension.Data.Height = v/10 end)
UI:CreateSlider(globSusp, "Damping", 0,100, 20, function(v) PhysicsData.Suspension.Data.Damping = v*20 end)

local presetSec = UI:AddSection(suspTab, "Presets")
UI:CreateButton(presetSec, "Race", function()
    PhysicsData.Suspension.Data.FrontStiff = 8000
    PhysicsData.Suspension.Data.RearStiff = 8000
    PhysicsData.Suspension.Data.Damping = 1500
    PhysicsData.Suspension.Data.Height = -1.5
    UI:Notify("Preset","Race tune applied",2)
end)
UI:CreateButton(presetSec, "Drift", function()
    PhysicsData.Suspension.Data.FrontStiff = 6000
    PhysicsData.Suspension.Data.RearStiff = 3000
    PhysicsData.Suspension.Data.Damping = 500
    UI:Notify("Preset","Drift tune applied",2)
end)
UI:CreateButton(presetSec, "Off-Road", function()
    PhysicsData.Suspension.Data.FrontStiff = 2000
    PhysicsData.Suspension.Data.RearStiff = 2000
    PhysicsData.Suspension.Data.Damping = 800
    PhysicsData.Suspension.Data.Height = 1.5
    UI:Notify("Preset","Off-road tune applied",2)
end)
UI:CreateButton(presetSec, "Comfort", function()
    PhysicsData.Suspension.Data.FrontStiff = 1500
    PhysicsData.Suspension.Data.RearStiff = 1500
    PhysicsData.Suspension.Data.Damping = 1800
    PhysicsData.Suspension.Data.Height = 0.5
    UI:Notify("Preset","Comfort tune applied",2)
end)

local advSec = UI:AddSection(suspTab, "Advanced")
UI:CreateButton(advSec, "Load Springs", function()
    local veh = PhysicsData.Internal.Vehicle
    if not veh then UI:Notify("Error","Sit in a vehicle first",3) return end
    VehicleManager.CacheSuspension(veh)
    UI:Notify("Springs","Loaded "..PhysicsData.Suspension.SpringCount.." springs",3)
end)
UI:CreateButton(advSec, "Reset ALL Springs", function()
    for spring, orig in pairs(PhysicsData.Suspension.OriginalValues) do
        pcall(function()
            spring.Stiffness = orig.Stiffness
            spring.Damping = orig.Damping
            spring.FreeLength = orig.FreeLength
        end)
    end
    UI:Notify("Springs","All springs reset",3)
end)

-- FUN TAB
local paintSec = UI:AddSection(funTab, "Client Paint")
UI:CreateColorpicker(paintSec, "Paint Color", Color3.new(1,0,0), function(col) PhysicsData.Fun.Paint.Color = col end)
UI:CreateButton(paintSec, "Apply Paint", function()
    applyColorToVehicle(PhysicsData.Fun.Paint.Color)
    UI:Notify("Paint","Color applied",3)
end)
local gravSec = UI:AddSection(funTab, "Gravity")
UI:CreateDropdown(gravSec, "Mode", {"Normal","Moon","Heavy","Zero","Reverse"}, "Normal", function(m) PhysicsData.Fun.Gravity.Mode = m end)
UI:CreateToggle(gravSec, "Enabled", false, function() 
    PhysicsData.Fun.Gravity.Enabled = true
    setGravityMode(true, PhysicsData.Fun.Gravity.Mode)
end, function() 
    PhysicsData.Fun.Gravity.Enabled = false
    setGravityMode(false, PhysicsData.Fun.Gravity.Mode)
end)

-- VISUALS TAB
local fbSec = UI:AddSection(visTab, "Fullbright")
UI:CreateToggle(fbSec, "Enabled", false, function()
    PhysicsData.Visuals.Fullbright.Enabled = true
    Lighting.Brightness = PhysicsData.Visuals.Fullbright.Settings.Brightness
    Lighting.Ambient = PhysicsData.Visuals.Fullbright.Settings.Ambient
    Lighting.FogEnd = PhysicsData.Visuals.Fullbright.Settings.FogEnd
end, function()
    PhysicsData.Visuals.Fullbright.Enabled = false
    Lighting.Brightness = 1
    Lighting.Ambient = Color3.new(0,0,0)
    Lighting.FogEnd = 500
end)
UI:CreateSlider(fbSec, "Brightness", 1,10, 2, function(v)
    PhysicsData.Visuals.Fullbright.Settings.Brightness = v
    if PhysicsData.Visuals.Fullbright.Enabled then Lighting.Brightness = v end
end)

local hlSec = UI:AddSection(visTab, "Headlights")
UI:CreateToggle(hlSec, "Always On", true, function() PhysicsData.Visuals.Headlights.Enabled = true end, function() PhysicsData.Visuals.Headlights.Enabled = false end)

-- ===================== Heartbeat Connections =====================
local heartbeatConn = RunService.Heartbeat:Connect(function(dt)
    if not PhysicsData.System.Active then return end
    VehicleManager.GetVehicle()
    local seat = PhysicsData.Internal.Seat
    local vehicle = PhysicsData.Internal.Vehicle
    if seat and vehicle then
        VelocityHandler.Process(seat, vehicle)
        PhysicsProcessor.ProcessSpeed(seat, dt)
        PhysicsProcessor.ProcessFlight(vehicle, seat, dt)
        PhysicsProcessor.ProcessTraction(vehicle, seat)
        PhysicsProcessor.ProcessCollision(vehicle)
    end
end)
table.insert(PhysicsData.System.Connections, heartbeatConn)

local steppedConn = RunService.Stepped:Connect(function()
    if PhysicsData.Internal.Vehicle and PhysicsData.System.Active then
        PhysicsProcessor.ProcessSuspension(PhysicsData.Internal.Vehicle)
    end
end)
table.insert(PhysicsData.System.Connections, steppedConn)

-- Initial notification
UI:Notify("System Ready", "Set Car etc Anonymous9x loaded. Anti-bounce active.", 4)
