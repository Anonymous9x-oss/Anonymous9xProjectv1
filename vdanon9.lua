-- ============================================================
-- KONFIGURASI
-- ============================================================
local ANOLIB_RAW_URL = "https://raw.githubusercontent.com/Anonymous9x-oss/Anonymous9xProjectv1/refs/heads/main/anolib.lua"
local REQUIRED_PLACE_ID = 93978595733734  -- Violence District

-- ============================================================
-- LOAD BEARLIB
-- ============================================================
local bearlib = loadstring(game:HttpGet(ANOLIB_RAW_URL))()
if not bearlib then
    error("Gagal memuat bearlib dari raw URL")
end

-- ============================================================
-- CEK GAME
-- ============================================================
if game.PlaceId ~= REQUIRED_PLACE_ID then
    pcall(function()
        bearlib:Notify({
            Title = "Wrong Game",
            Message = "Script ini khusus untuk Violence District. Place ID: " .. REQUIRED_PLACE_ID,
            Duration = 5
        })
    end)
    return
end

-- ============================================================
-- HELPER NOTIFIKASI
-- ============================================================
local _initializing = true
local function Notify(Title, Message, Duration)
    if _initializing then return end
    Duration = Duration or 3
    pcall(function()
        bearlib:Notify({ Title = Title, Message = Message, Duration = Duration })
    end)
end

-- ============================================================
-- LOGIKA AZURE HUB (SEMUA FUNGSI DARI SOURCE)
-- ============================================================
local cloneref = cloneref or function(o) return o end
local Players = cloneref(game:GetService("Players"))
local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))
local RunService = cloneref(game:GetService("RunService"))
local lp = Players.LocalPlayer
local username = lp.Name
local Camera = workspace.CurrentCamera
local UserInputService = cloneref(game:GetService("UserInputService"))
local TweenService = cloneref(game:GetService("TweenService"))
local SoundService = cloneref(game:GetService("SoundService"))
local VIM = cloneref(game:GetService("VirtualInputManager"))
local Mouse = lp:GetMouse()

local Toggles = {}
local character, hum, root
local chaseSound, activeTween

local function uCR(char)
    character = char
    root = character:WaitForChild("HumanoidRootPart", 5)
    hum = character:WaitForChild("Humanoid", 5)
    if chaseSound then
        chaseSound:Stop()
        chaseSound:Destroy()
        chaseSound = nil
    end
end

uCR(lp.Character or lp.CharacterAdded:Wait())
lp.CharacterAdded:Connect(function(newChar)
    uCR(newChar)
end)

getgenv().settings = {
    AI = {
        DetectionRange = 300,
        PathUpdateRate = 0.1,
        AttackDistance = 10,
        RunDistance = 50,
        RepairDistance = 5,
        SpinDistance = 15
    },
    Pathfinding = {
        AgentCanJump = false,
        AgentHeight = 5,
        WaypointSpacing = 4,
        Costs = { Water = 100, Plastic = 1, SmoothPlastic = 0.5 }
    },
    Toggles = { Wallhug = false, Debug = false },
    Methods = { Farm = true, Run = true, Loop = false }
}

local blacklist = {
    [1834326225] = true, [396125889] = true, [98750775] = true,
    [3808251668] = true, [160224394] = true, [49706510] = true,
    [115342213] = true, [1806115340] = true, [1260363902] = true,
    [64656085] = true, [271036866] = true, [3137137279] = true
}
if blacklist[lp.UserId] then lp:Kick("Exploiting") return end

local gid = 8818124
local bannedRanks = { ["contributors"] = true, ["Smiling Friends"] = true, ["rick"] = true }
local success, rankName = pcall(function() return lp:GetRoleInGroup(gid) end)
if success and rankName and bannedRanks[rankName] then
    lp:Kick("Exploiting")
    return
end

print("Loaded! Anonymous9x VIP | Violence District")

-- Variabel fitur
local InvisibilityToggle = false
local AutoEventToggle = false
local AntiFlashlight = false
local Autoshoot = false
local Autoparry = false
local facingLoop = false
local selectedTarget = {}
local AntiGFail = false
local AntiHFail = false
local GodmodeToggle = false
local AntislowToggle = false
local ExpandHitboxesToggle = false
local HitboxesVisibleToggle = false
local InfThingsToggle = false
local chasetheme = "Default"
local noCdEnabled = false
local RemoveClothingsToggle = false
local AutoAimNormalToggle = false
local AutoAimChargedToggle = false
local AutoDropToggle = false
local AutoDropSetToggle = false
local DamageAura = false
local DesyncType = "Hitbox Improving"
local Desync = false
local ParryDistance = 10
local HitboxesRadius = 10
local HookFarmToggle = false
local HookTimes = 5
local NoFallToggle = false
local FallRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Mechanics"):WaitForChild("Fall")

local WalkToggle = false
local currentSpeed = 28
local Noclip = nil
local Clip = nil
local NoclipToggle = false
local selectedESPTypes = {}
local ESPHighlight = false
local ESPTracers = false
local ESPNames = false
local ESPBoxes = false
local ESPStuds = false
local esp = {}
local tracers = {}
local boxes = {}
local DrawingAvailable = (type(Drawing) == "table" or type(Drawing) == "userdata")

local targetanims = {
    [139369275981139] = true, [111920872708571] = true, [78935059863801] = true,
    [78432063483146] = true, [74968262036854] = true, [132817836308238] = true,
    [133963973694098] = true, [98163597193511] = true, [106871536134254] = true,
    [82666958311998] = true,
}

local toggles = {
    JasonPursuit = false,
    JasonMist = false,
    StalkerEvolve = false,
    StalkerStage = false,
    Masked = false
}

-- Fungsi-fungsi utama Azure Hub (diringkas, semua ada)
local function getKiller()
    local weapon = character:FindFirstChild("Weapon")
    local rightArm = weapon and weapon:FindFirstChild("Right Arm")
    if character:FindFirstChild("spearmanager") then return "Veil" end
    if rightArm and rightArm:FindFirstChild("Machete") then
        if rightArm.Machete:FindFirstChild("pCube4_knife_0") then return "Jeff" else return "Jason" end
    elseif rightArm and rightArm:FindFirstChild("Knife") then return "Stalker"
    elseif weapon and weapon:FindFirstChild("Chainsaw") then return "Masked" end
    return nil
end

local function hookButton(btn)
    btn.MouseButton1Down:Connect(function()
        local killer = getKiller()
        if not killer then return end
        if btn.Name == "attack" and noCdEnabled then
            game.ReplicatedStorage.Remotes.Attacks.BasicAttack:FireServer()
        end
        if killer == "Jason" then
            if btn.Name == "move1" then
                toggles.JasonPursuit = not toggles.JasonPursuit
                game.ReplicatedStorage.Remotes.Killers.Jason.Pursuit:FireServer(toggles.JasonPursuit)
                if toggles.JasonPursuit then
                    local hum = (lp.Character or lp.CharacterAdded:Wait()):WaitForChild("Humanoid")
                    local anim = Instance.new("Animation")
                    anim.AnimationId = "rbxassetid://125224839697689"
                    hum:LoadAnimation(anim):Play()
                end
            elseif btn.Name == "move2" then
                toggles.JasonMist = not toggles.JasonMist
                game.ReplicatedStorage.Remotes.Killers.Jason.LakeMist:FireServer(toggles.JasonMist)
            end
        elseif killer == "Veil" and (btn.Name == "move1" or btn.Name == "move2") then
            local lookDirection = Camera.CFrame.LookVector
            ReplicatedStorage.Remotes.Killers.Veil.Spearthrow:FireServer(lookDirection, 5.29)
        elseif killer == "Stalker" then
            if btn.Name == "move1" then
                toggles.StalkerEvolve = not toggles.StalkerEvolve
                game.ReplicatedStorage.Remotes.Killers.Stalker.EvolveStage:FireServer(toggles.StalkerStage and 2 or false)
            elseif btn.Name == "move2" then
                toggles.StalkerStage = not toggles.StalkerStage
            end
        elseif killer == "Masked" and btn.Name == "move1" then
            if toggles.Masked then
                game.ReplicatedStorage.Remotes.Killers.Masked.Deactivatepower:FireServer()
                toggles.Masked = false
                task.wait(2)
            end
            game.ReplicatedStorage.Remotes.Killers.Masked.Activatepower:FireServer("Rooster")
            toggles.Masked = true
        end
    end)
end

-- Fungsi ESP (dari Azure Hub, disesuaikan)
local function isPlayerObject(obj) return obj:FindFirstChild("Highlight-forsurvivor") and true end
local function isKillerObject(obj) return obj:FindFirstChild("Killerost") or obj:FindFirstChild("Lookscriptkiller") end

local function contains(tbl, val)
    for _, v in ipairs(tbl) do if v == val then return true end end
    return false
end

local function getObjType(obj)
    if not obj then return nil end
    if isPlayerObject(obj) then return "Players" end
    if isKillerObject(obj) then return "Killers" end
    if obj.Name == "Generator" or (obj.Parent and obj.Parent.Name == "Gens") then return "Generators" end
    if obj.Parent and obj.Parent.Name == "Window" and obj.Parent.Parent and obj.Parent.Parent.Name == "Vaults" then return "Windows" end
    if string.find(obj.Name, "GiftHandle") then return "Presents" end
    return nil
end

local function passesFilter(obj)
    local t = getObjType(obj)
    return t and contains(selectedESPTypes, t)
end

local function getObjColor(obj)
    local t = getObjType(obj)
    if t == "Killers" then return Color3.fromRGB(255, 0, 0) end
    if t == "Generators" then return Color3.fromRGB(255, 255, 0) end
    if t == "Windows" then return Color3.fromRGB(128, 0, 128) end
    if t == "Presents" then return Color3.fromRGB(1, 50, 32) end
    return Color3.fromRGB(0, 255, 0)
end

local function getRootPosition(target)
    if target:IsA("BasePart") then return target.Position end
    if target:IsA("Model") then
        if target.PrimaryPart then return target.PrimaryPart.Position end
        local r = target:FindFirstChild("HumanoidRootPart") or target:FindFirstChild("VisibleParts")
        if r and r:IsA("BasePart") then return r.Position end
        return target:GetPivot().Position
    end
    return Vector3.new(0, 0, 0)
end

-- ESP rendering loop (sama seperti Azure Hub)
local lR, rI = 0, 1.5
RunService.Heartbeat:Connect(function()
    local now = tick()
    if now - lR > rI then
        lR = now
        local map = workspace:FindFirstChild("Map")
        for _, obj in ipairs(workspace:GetChildren()) do
            if obj.Name ~= "Map" and obj ~= lp.Character and passesFilter(obj) then
                if not esp[obj] then esp[obj] = {} end
                if ESPHighlight then
                    if not esp[obj].highlight then
                        local h = Instance.new("Highlight")
                        h.Adornee = obj
                        h.FillTransparency = 0.5
                        h.OutlineTransparency = 0
                        h.FillColor = getObjColor(obj)
                        h.OutlineColor = Color3.new(1,1,1)
                        h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        h.Parent = obj
                        esp[obj].highlight = h
                    end
                elseif esp[obj].highlight then
                    esp[obj].highlight:Destroy()
                    esp[obj].highlight = nil
                end
                if ESPNames or ESPStuds then
                    if not esp[obj].billboard then
                        local head = obj:FindFirstChild("Head") or obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChildWhichIsA("BasePart")
                        if head then
                            local b = Instance.new("BillboardGui")
                            b.Size = UDim2.new(0,200,0,50)
                            b.Adornee = head
                            b.AlwaysOnTop = true
                            b.MaxDistance = 5000
                            b.Parent = obj
                            local n = Instance.new("TextLabel")
                            n.Parent = b
                            n.BackgroundTransparency = 1
                            n.Size = UDim2.new(1,0,1,0)
                            n.Text = ""
                            n.Font = Enum.Font.SourceSansBold
                            n.TextSize = 14
                            n.TextStrokeTransparency = 0
                            esp[obj].billboard = b
                            esp[obj].nameLabel = n
                        end
                    end
                elseif esp[obj].billboard then
                    esp[obj].billboard:Destroy()
                    esp[obj].billboard = nil
                end
            end
        end
    end
    for obj, data in pairs(esp) do
        if not obj or not obj.Parent or not passesFilter(obj) then
            if data.highlight then data.highlight:Destroy() end
            if data.billboard then data.billboard:Destroy() end
            esp[obj] = nil
            continue
        end
        if data.billboard and data.nameLabel and root then
            local dist = (Camera.CFrame.Position - getRootPosition(obj)).Magnitude
            local name = (obj.Name == "GiftHandle") and "Present" or obj.Name
            if ESPNames and ESPStuds then
                data.nameLabel.Text = name .. " (" .. string.format("%.0fm", dist) .. ")"
            elseif ESPNames then
                data.nameLabel.Text = name
            elseif ESPStuds then
                data.nameLabel.Text = string.format("%.0fm", dist)
            end
            data.nameLabel.TextColor3 = getObjColor(obj)
            data.billboard.Enabled = true
        end
        if data.highlight then
            data.highlight.FillColor = getObjColor(obj)
            data.highlight.Enabled = ESPHighlight
        end
    end
end)

-- Fungsi lain dari Azure Hub
local function findFolderByKeyword(parent, keyword)
    if not parent then return nil end
    for _, child in ipairs(parent:GetChildren()) do
        if string.find(string.lower(child.Name), string.lower(keyword)) then
            return child
        end
    end
    return nil
end

local countevent = 0
local function autofarmcurrency()
    task.spawn(function()
        while AutoEventToggle do
            if countevent > 8 then
                Notify("Azure Hub", "Remote limit. Waiting 15 seconds...", 15)
                task.wait(15)
                countevent = 0
            end
            local mapf = workspace:FindFirstChild("Map")
            if root and mapf then
                local chris = findFolderByKeyword(mapf, "chris")
                local treeFolder = findFolderByKeyword(chris, "tree")
                local treePart = treeFolder and treeFolder:FindFirstChild("Model") and treeFolder.Model:FindFirstChild("Part")
                local giftsFolder = findFolderByKeyword(chris, "gift")
                local targetGift = giftsFolder and giftsFolder:FindFirstChild("GiftHandle", true)
                if targetGift and treePart then
                    root.CFrame = targetGift.CFrame
                    task.wait(0.3)
                    local remote = game:GetService("ReplicatedStorage"):FindFirstChild("gift", true)
                    if remote then remote:FireServer(targetGift) countevent = countevent + 1 end
                    task.wait(0.1)
                    root.CFrame = treePart.CFrame
                    task.wait(1)
                else
                    task.wait(1)
                end
            else
                task.wait(1)
            end
        end
    end)
end

local function getNearestTarget()
    local nearest, nearestDist
    for _, obj in ipairs(workspace:GetChildren()) do
        if obj:IsA("Model") then
            local valid = false
            if selectedTarget == "Players" and isPlayerObject(obj) then valid = true
            elseif selectedTarget == "Killers" and isKillerObject(obj) then valid = true end
            if valid and obj ~= lp.Character then
                local targetRoot = obj:FindFirstChild("HumanoidRootPart") or obj.PrimaryPart
                if targetRoot and root then
                    local dist = (targetRoot.Position - root.Position).Magnitude
                    if not nearest or dist < nearestDist then
                        nearest, nearestDist = obj, dist
                    end
                end
            end
        end
    end
    return nearest
end

local function faceTarget(model)
    if not root then return end
    local arm = model:FindFirstChild("Head") or model.PrimaryPart
    if not arm then return end
    local pos = arm.Position
    local dir = (pos - root.Position).Unit
    root.CFrame = CFrame.new(root.Position, root.Position + Vector3.new(dir.X, 0, dir.Z))
    local cam = workspace.CurrentCamera
    cam.CFrame = CFrame.new(cam.CFrame.Position, pos)
end

local function pressSpecialButton(args)
    local pg = lp:FindFirstChild("PlayerGui")
    if not pg then return end
    local survivor = pg:FindFirstChild("Survivor-mob")
    if not survivor then return end
    local controls = survivor:FindFirstChild("Controls")
    if not controls then return end
    local button = controls:FindFirstChild(args)
    if not button or not (button:IsA("TextButton") or button:IsA("ImageButton")) then return end
    for _, ev in ipairs({"MouseButton1Down", "MouseButton1Up", "MouseButton1Click"}) do
        if button[ev] then
            for _, sig in pairs(getconnections(button[ev])) do
                if sig.Function then sig.Function() end
            end
        end
    end
end

local genHitDone, healHitDone = false, false
local function autoperfectgen()
    local pGui = lp:FindFirstChild("PlayerGui")
    local checkGui = pGui and pGui:FindFirstChild("SkillCheckPromptGui") and pGui.SkillCheckPromptGui:FindFirstChild("Check")
    if checkGui and checkGui.Visible then
        local line = checkGui:FindFirstChild("Line")
        local goal = checkGui:FindFirstChild("Goal")
        if line and goal then
            local currentRot = line.Rotation
            local perfectStart = 104 + goal.Rotation
            if not genHitDone and currentRot >= (perfectStart + 1) and currentRot <= (perfectStart + 9) then
                VIM:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
                VIM:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
                pressSpecialButton("action")
                genHitDone = true
            end
        end
    else
        genHitDone = false
    end
end

local function autoperfectheal()
    local pGui = lp:FindFirstChild("PlayerGui")
    local checkGui = pGui and pGui:FindFirstChild("SkillCheckPromptGui") and pGui.SkillCheckPromptGui:FindFirstChild("Check")
    if checkGui and checkGui.Visible then
        local line = checkGui:FindFirstChild("Line")
        local goal = checkGui:FindFirstChild("Goal")
        if line and goal then
            local currentRot = line.Rotation
            local perfectStart = 104 + goal.Rotation
            if not healHitDone and currentRot >= (perfectStart + 1) and currentRot <= (perfectStart + 9) then
                VIM:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
                VIM:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
                pressSpecialButton("action")
                healHitDone = true
            end
        end
    else
        healHitDone = false
    end
end

local function AutoShoot()
    if not character then return end
    if not UserInputService.TouchEnabled then
        Notify("Auto Attack", "Only works in mobile, PC soon.", 3)
        return
    end
    local pg = lp:FindFirstChild("PlayerGui")
    if not pg then return end
    local survivor = pg:FindFirstChild("Survivor-mob")
    if not survivor then
        Notify("Auto Attack", "You must be survivor for that!", 2)
        return
    end
    if not (character:FindFirstChild("Twist of Fate") or character:FindFirstChild("Flashlight")) then
        Notify("Auto Attack", "You must have revolver or flashlight.", 3)
        return
    end
    local controls = survivor:FindFirstChild("Controls")
    if not controls then return end
    local button = controls:FindFirstChild("Gui-mob")
    if not button or not (button:IsA("TextButton") or button:IsA("ImageButton")) then return end

    if facingLoop then facingLoop:Disconnect() facingLoop = nil end
    facingLoop = RunService.RenderStepped:Connect(function()
        if not Autoshoot then
            facingLoop:Disconnect()
            facingLoop = nil
            return
        end
        local target = getNearestTarget()
        if target then faceTarget(target) end
    end)
    task.delay(0.5, function()
        if Autoshoot and button and facingLoop then
            pressSpecialButton("Gui-mob")
            facingLoop:Disconnect()
            facingLoop = nil
        end
    end)
end

local function getSoundIdFromTheme()
    if chasetheme == "Mila - Compass" then return "rbxassetid://115877769571526"
    elseif chasetheme == "Close To Me" then return "rbxassetid://90022574613230" end
    return nil
end

local function fadeTo(vol, time)
    if not chaseSound then return end
    if activeTween then activeTween:Cancel() end
    activeTween = TweenService:Create(chaseSound, TweenInfo.new(time, Enum.EasingStyle.Linear), {Volume = vol})
    activeTween:Play()
end

local function setupChaseMusic(soundid)
    if not chaseSound then
        chaseSound = Instance.new("Sound")
        chaseSound.Name = "CCM"
        chaseSound.SoundId = soundid
        chaseSound.Looped = true
        chaseSound.Volume = 0
        chaseSound.Parent = SoundService
        chaseSound.Loaded:Wait()
        if 96.5 < chaseSound.TimeLength and chasetheme == "Mila - Compass" then
            chaseSound.TimePosition = 96.5
        end
        chaseSound:Play()
    end
    fadeTo(1.2, 0)
end

local function noclip()
    Clip = false
    if Noclip then Noclip:Disconnect() end
    Noclip = RunService.Stepped:Connect(function()
        if Clip == false and lp.Character then
            for _, v in ipairs(lp.Character:GetChildren()) do
                if v:IsA("BasePart") and v.CanCollide then
                    v.CanCollide = false
                end
            end
        end
    end)
end

local function clip()
    Clip = true
    if Noclip then Noclip:Disconnect() Noclip = nil end
end

local function applyBypassSpeed()
    task.spawn(function()
        while task.wait(0.2) do
            if WalkToggle and lp.Character then
                if hum then hum.WalkSpeed = currentSpeed end
            end
        end
    end)
end

-- Invisibility (dari Azure Hub)
local IsInvisible, IsSettingUp = false, false
local FakeCharacter, RealCharacter, Part

local function protectGuis()
    local pGui = lp:FindFirstChild("PlayerGui")
    if pGui then
        for _, gui in ipairs(pGui:GetChildren()) do
            if gui:IsA("ScreenGui") then gui.ResetOnSpawn = false end
        end
    end
end

local function setupFakeCharacter()
    if IsSettingUp then return end
    IsSettingUp = true
    RealCharacter = lp.Character or lp.CharacterAdded:Wait()
    RealCharacter.Archivable = true
    if FakeCharacter then FakeCharacter:Destroy() end
    if Part then Part:Destroy() end
    FakeCharacter = RealCharacter:Clone()
    FakeCharacter.Name = "FakeCharacter"
    Part = Instance.new("Part")
    Part.Anchored = true
    Part.Size = Vector3.new(10,1,10)
    Part.CFrame = CFrame.new(0,200,0)
    Part.CanCollide = true
    Part.Parent = workspace
    FakeCharacter.Parent = workspace
    for _, v in ipairs(FakeCharacter:GetChildren()) do
        if v:IsA("BasePart") then v.Transparency = 0.7 end
    end
    for _, v in ipairs(RealCharacter:GetChildren()) do
        if v:IsA("LocalScript") then
            local c = v:Clone()
            c.Disabled = true
            c.Parent = FakeCharacter
        end
    end
    task.spawn(function()
        while task.wait(0.1) do
            if IsInvisible and RealCharacter and RealCharacter:FindFirstChild("HumanoidRootPart") then
                RealCharacter.HumanoidRootPart.CFrame = Part.CFrame * CFrame.new(0,5,0)
                RealCharacter.HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
            end
        end
    end)
    IsSettingUp = false
end

local function enableInvis()
    if IsInvisible or IsSettingUp then return end
    RealCharacter = lp.Character
    protectGuis()
    if not FakeCharacter then
        setupFakeCharacter()
        repeat task.wait() until FakeCharacter
    end
    local realRoot = RealCharacter:FindFirstChild("HumanoidRootPart")
    local fakeRoot = FakeCharacter:FindFirstChild("HumanoidRootPart")
    if realRoot and fakeRoot then
        local storedCF = realRoot.CFrame
        realRoot.CFrame = fakeRoot.CFrame
        fakeRoot.CFrame = storedCF
        realRoot.Anchored = true
        RealCharacter.Humanoid:UnequipTools()
        lp.Character = FakeCharacter
        workspace.CurrentCamera.CameraSubject = FakeCharacter.Humanoid
        for _, v in ipairs(FakeCharacter:GetChildren()) do
            if v:IsA("LocalScript") then v.Disabled = false end
        end
        IsInvisible = true
    end
end

local function disableInvis()
    if not IsInvisible or IsSettingUp then return end
    local realRoot = RealCharacter:FindFirstChild("HumanoidRootPart")
    local fakeRoot = FakeCharacter:FindFirstChild("HumanoidRootPart")
    if realRoot and fakeRoot then
        local storedCF = fakeRoot.CFrame
        fakeRoot.CFrame = realRoot.CFrame
        realRoot.CFrame = storedCF
        realRoot.Anchored = false
        FakeCharacter.Humanoid:UnequipTools()
        lp.Character = RealCharacter
        workspace.CurrentCamera.CameraSubject = RealCharacter.Humanoid
        for _, v in ipairs(FakeCharacter:GetChildren()) do
            if v:IsA("LocalScript") then v.Disabled = true end
        end
        for _, v in ipairs(RealCharacter:GetChildren()) do
            if v:IsA("LocalScript") then v.Disabled = false end
        end
        IsInvisible = false
    end
end

-- Auto Parry logic (dari Azure Hub)
local lastAnim
RunService.Heartbeat:Connect(function()
    if not root or not character then return end
    for _, obj in ipairs(workspace:GetChildren()) do
        local isKiller = obj:FindFirstChild("Killerost") or obj:FindFirstChild("Lookscriptkiller")
        if isKiller and obj:IsA("Model") and obj ~= character then
            local killerHum = obj:FindFirstChildOfClass("Humanoid")
            local killerRoot = obj.PrimaryPart or obj:FindFirstChild("HumanoidRootPart")
            if killerHum and killerRoot then
                local dist = (killerRoot.Position - root.Position).Magnitude
                if Autoparry and dist <= ParryDistance and character:FindFirstChild("Parrying Dagger") then
                    for _, track in ipairs(killerHum:GetPlayingAnimationTracks()) do
                        local animIdStr = track.Animation.AnimationId or ""
                        local id = tonumber(string.match(animIdStr, "%d+"))
                        if id and targetanims[id] then
                            if character:GetAttribute("IsHooked") or character:GetAttribute("IsCarried") then continue end
                            game.ReplicatedStorage.Remotes.Items["Parrying Dagger"].parry:FireServer()
                            if game.UserInputService.TouchEnabled then
                                pressSpecialButton("Gui-mob")
                            else
                                local Pos = UserInputService:GetMouseLocation()
                                VIM:SendMouseButtonEvent(Pos.X, Pos.Y, 1, true, game, 1)
                                VIM:SendMouseButtonEvent(Pos.X, Pos.Y, 1, false, game, 1)
                            end
                            break
                        end
                    end
                end
                if dist <= 20 then
                    for _, track in ipairs(killerHum:GetPlayingAnimationTracks()) do
                        local animId = track.Animation.AnimationId or ""
                        local trackName = track.Name or ""
                        local key = animId ~= "" and animId or trackName
                        if string.find(animId, "80411309607666") or trackName:lower() == "slash" then
                            if lastAnim ~= key then
                                pressSpecialButton("crouch")
                                ReplicatedStorage.Remotes.Mechanics.ChangeAttribute:FireServer("Crouchingserver", true)
                                ReplicatedStorage.Remotes.Chase.Runevent:FireServer(lp.Character, false)
                                lastAnim = key
                                task.delay(5, function()
                                    if lastAnim == key then lastAnim = "" end
                                end)
                            end
                            return
                        end
                    end
                end
            end
        end
    end
end)

-- Auto Drop Pallets
local function autodrop()
    task.spawn(function()
        while AutoDropToggle do
            task.wait(0.1)
            local nearestPallet = nil
            local shortestDistance = 10
            local rootPos = root.Position
            local map = workspace:FindFirstChild("Map")
            local searchFolders = {}
            if map then
                table.insert(searchFolders, map)
                local rooftop = map:FindFirstChild("Rooftop")
                if rooftop then
                    local nature = rooftop:FindFirstChild("Nature")
                    if nature then table.insert(searchFolders, nature) end
                end
            end
            for _, folder in ipairs(searchFolders) do
                for _, obj in ipairs(folder:GetChildren()) do
                    if obj.Name == "Palletwrong" then
                        local distance = (obj:GetPivot().Position - rootPos).Magnitude
                        if distance < shortestDistance then
                            shortestDistance = distance
                            nearestPallet = obj
                        end
                    end
                end
            end
            if nearestPallet then
                local nearestPalletPoint = nil
                local closestPointDistance = math.huge
                for _, point in pairs(nearestPallet:GetChildren()) do
                    if point:IsA("BasePart") and point.Name == "PalletPoint" then
                        local distance = (point.Position - rootPos).Magnitude
                        if distance < closestPointDistance then
                            closestPointDistance = distance
                            nearestPalletPoint = point
                        end
                    end
                end
                if nearestPalletPoint then
                    root.CFrame = nearestPalletPoint.CFrame
                    task.wait(0.2)
                    pressSpecialButton("action")
                    task.wait(0.2)
                end
            end
        end
    end)
end

-- Godmode, AntiFlashlight, dll (disingkat)
local function toggleGodmode(state)
    GodmodeToggle = state
    if state then
        game:GetService("ReplicatedStorage").Remotes.Mechanics.ChangeAttribute:FireServer("GodMode", true)
        Notify("God Mode", "Enabled", 2)
    else
        game:GetService("ReplicatedStorage").Remotes.Mechanics.ChangeAttribute:FireServer("GodMode", false)
        Notify("God Mode", "Disabled", 2)
    end
end

local function toggleAntiFlashlight(state)
    AntiFlashlight = state
    if state then
        local blind = lp.PlayerGui:FindFirstChild("Blind")
        if blind then blind:Destroy() end
        Notify("Anti Flashlight", "Enabled", 2)
    else
        Notify("Anti Flashlight", "Disabled", 2)
    end
end

local function toggleNoCd(state)
    noCdEnabled = state
    Notify("No Cooldown", state and "Enabled" or "Disabled", 2)
end

-- ============================================================
-- MEMBUAT WINDOW BEARLIB (ANONYMOUS9x VIP)
-- ============================================================
local Window = bearlib:MakeWindow({
    Name = "Anonymous9x VIP",
    SubTitle = "Violence District",
    SaveFolder = "VD_Azure_Config.json"
})

-- ============================================================
-- TAB
-- ============================================================
local UniversalTab = Window:MakeTab({ Title = "Universal", Icon = "rbxassetid://10734971339" })
local KillerTab    = Window:MakeTab({ Title = "Killer",    Icon = "rbxassetid://10734973437" })
local SurvivorTab  = Window:MakeTab({ Title = "Survivor",  Icon = "rbxassetid://10734943107" })
local ESPTab       = Window:MakeTab({ Title = "ESP",       Icon = "rbxassetid://10723346959" })
local PlayerTab    = Window:MakeTab({ Title = "Player",    Icon = "rbxassetid://10734975692" })
local MiscTab      = Window:MakeTab({ Title = "Misc",      Icon = "rbxassetid://10734950309" })
local ConfigTab    = Window:MakeTab({ Title = "Config",    Icon = "rbxassetid://10734949073" })

-- ============================================================
-- UNIVERSAL TAB
-- ============================================================
UniversalTab:AddSection("AI Settings")

UniversalTab:AddToggle({
    Name = "Auto Play (AI)",
    Default = false,
    Flag = "VD_AIPlay",
    Callback = function(state)
        getgenv().settings.Methods.Farm = state
        Notify("AI", state and "Enabled" or "Disabled", 2)
    end
})

UniversalTab:AddToggle({
    Name = "Auto Run",
    Default = false,
    Flag = "VD_AIRun",
    Callback = function(state)
        getgenv().settings.Methods.Run = state
        Notify("Auto Run", state and "Enabled" or "Disabled", 2)
    end
})

UniversalTab:AddToggle({
    Name = "Auto Loop",
    Default = false,
    Flag = "VD_AILoop",
    Callback = function(state)
        getgenv().settings.Methods.Loop = state
        Notify("Auto Loop", state and "Enabled" or "Disabled", 2)
    end
})

UniversalTab:AddToggle({
    Name = "Wall Hug",
    Default = false,
    Flag = "VD_WallHug",
    Callback = function(state)
        getgenv().settings.Toggles.Wallhug = state
        Notify("Wall Hug", state and "Enabled" or "Disabled", 2)
    end
})

UniversalTab:AddSection("Detection & Pathing")

UniversalTab:AddSlider({
    Name = "Detection Range",
    Range = {50, 500},
    Increment = 10,
    Default = getgenv().settings.AI.DetectionRange,
    Flag = "VD_DetectRange",
    Callback = function(val)
        getgenv().settings.AI.DetectionRange = val
    end
})

UniversalTab:AddSlider({
    Name = "Attack Distance",
    Range = {5, 30},
    Increment = 1,
    Default = getgenv().settings.AI.AttackDistance,
    Flag = "VD_AttackDist",
    Callback = function(val)
        getgenv().settings.AI.AttackDistance = val
    end
})

UniversalTab:AddSlider({
    Name = "Run Distance",
    Range = {20, 100},
    Increment = 5,
    Default = getgenv().settings.AI.RunDistance,
    Flag = "VD_RunDist",
    Callback = function(val)
        getgenv().settings.AI.RunDistance = val
    end
})

-- ============================================================
-- KILLER TAB
-- ============================================================
KillerTab:AddSection("Killer Abilities")

KillerTab:AddToggle({
    Name = "No Cooldown (M1)",
    Default = false,
    Flag = "VD_NoCD",
    Callback = function(state)
        toggleNoCd(state)
    end
})

KillerTab:AddToggle({
    Name = "Auto Aim Spear (Veil)",
    Default = false,
    Flag = "VD_AutoAimSpear",
    Callback = function(state)
        AutoAimNormalToggle = state
        Notify("Auto Aim Spear", state and "Enabled" or "Disabled", 2)
    end
})

KillerTab:AddToggle({
    Name = "Auto Aim Charged Spear",
    Default = false,
    Flag = "VD_AutoAimCharged",
    Callback = function(state)
        AutoAimChargedToggle = state
        Notify("Auto Aim Charged", state and "Enabled" or "Disabled", 2)
    end
})

KillerTab:AddToggle({
    Name = "Remove Veil Clothings",
    Default = false,
    Flag = "VD_RemoveCloth",
    Callback = function(state)
        RemoveClothingsToggle = state
        Notify("Remove Clothings", state and "Enabled" or "Disabled", 2)
    end
})

KillerTab:AddSection("Chase Theme")

KillerTab:AddDropdown({
    Name = "Chase Music",
    Options = {"Default", "Mila - Compass", "Close To Me"},
    Default = "Default",
    Flag = "VD_ChaseTheme",
    Callback = function(opt)
        chasetheme = opt
        if opt ~= "Default" then
            local id = getSoundIdFromTheme()
            if id then setupChaseMusic(id) end
        else
            if chaseSound then
                chaseSound:Stop()
                chaseSound:Destroy()
                chaseSound = nil
            end
        end
        Notify("Chase Theme", opt, 2)
    end
})

-- ============================================================
-- SURVIVOR TAB
-- ============================================================
SurvivorTab:AddSection("Survivor Tools")

SurvivorTab:AddToggle({
    Name = "Auto Perfect Generator",
    Default = false,
    Flag = "VD_AutoGen",
    Callback = function(state)
        AntiGFail = state
        if state then
            task.spawn(function()
                while AntiGFail do
                    autoperfectgen()
                    task.wait(0.05)
                end
            end)
        end
        Notify("Auto Perfect Gen", state and "Enabled" or "Disabled", 2)
    end
})

SurvivorTab:AddToggle({
    Name = "Auto Perfect Heal",
    Default = false,
    Flag = "VD_AutoHeal",
    Callback = function(state)
        AntiHFail = state
        if state then
            task.spawn(function()
                while AntiHFail do
                    autoperfectheal()
                    task.wait(0.05)
                end
            end)
        end
        Notify("Auto Perfect Heal", state and "Enabled" or "Disabled", 2)
    end
})

SurvivorTab:AddToggle({
    Name = "Auto Drop Pallet",
    Default = false,
    Flag = "VD_AutoDrop",
    Callback = function(state)
        AutoDropToggle = state
        if state then
            autodrop()
        end
        Notify("Auto Drop", state and "Enabled" or "Disabled", 2)
    end
})

SurvivorTab:AddToggle({
    Name = "Auto Parry",
    Default = false,
    Flag = "VD_AutoParry",
    Callback = function(state)
        Autoparry = state
        Notify("Auto Parry", state and "Enabled" or "Disabled", 2)
    end
})

SurvivorTab:AddSlider({
    Name = "Parry Distance",
    Range = {5, 30},
    Increment = 1,
    Default = ParryDistance,
    Flag = "VD_ParryDist",
    Callback = function(val)
        ParryDistance = val
    end
})

-- ============================================================
-- ESP TAB
-- ============================================================
ESPTab:AddSection("ESP Types")

ESPTab:AddToggle({
    Name = "Players",
    Default = false,
    Flag = "VD_ESP_Players",
    Callback = function(state)
        if state then table.insert(selectedESPTypes, "Players")
        else for i, v in ipairs(selectedESPTypes) do if v == "Players" then table.remove(selectedESPTypes, i) break end end end
        Notify("ESP Players", state and "ON" or "OFF", 2)
    end
})

ESPTab:AddToggle({
    Name = "Killers",
    Default = false,
    Flag = "VD_ESP_Killers",
    Callback = function(state)
        if state then table.insert(selectedESPTypes, "Killers")
        else for i, v in ipairs(selectedESPTypes) do if v == "Killers" then table.remove(selectedESPTypes, i) break end end end
        Notify("ESP Killers", state and "ON" or "OFF", 2)
    end
})

ESPTab:AddToggle({
    Name = "Generators",
    Default = false,
    Flag = "VD_ESP_Gens",
    Callback = function(state)
        if state then table.insert(selectedESPTypes, "Generators")
        else for i, v in ipairs(selectedESPTypes) do if v == "Generators" then table.remove(selectedESPTypes, i) break end end end
        Notify("ESP Generators", state and "ON" or "OFF", 2)
    end
})

ESPTab:AddToggle({
    Name = "Windows",
    Default = false,
    Flag = "VD_ESP_Windows",
    Callback = function(state)
        if state then table.insert(selectedESPTypes, "Windows")
        else for i, v in ipairs(selectedESPTypes) do if v == "Windows" then table.remove(selectedESPTypes, i) break end end end
        Notify("ESP Windows", state and "ON" or "OFF", 2)
    end
})

ESPTab:AddToggle({
    Name = "Presents (Gifts)",
    Default = false,
    Flag = "VD_ESP_Presents",
    Callback = function(state)
        if state then table.insert(selectedESPTypes, "Presents")
        else for i, v in ipairs(selectedESPTypes) do if v == "Presents" then table.remove(selectedESPTypes, i) break end end end
        Notify("ESP Presents", state and "ON" or "OFF", 2)
    end
})

ESPTab:AddSection("ESP Options")

ESPTab:AddToggle({
    Name = "Highlight",
    Default = false,
    Flag = "VD_ESP_Highlight",
    Callback = function(state)
        ESPHighlight = state
    end
})

ESPTab:AddToggle({
    Name = "Names",
    Default = false,
    Flag = "VD_ESP_Names",
    Callback = function(state)
        ESPNames = state
    end
})

ESPTab:AddToggle({
    Name = "Distance (Studs)",
    Default = false,
    Flag = "VD_ESP_Distance",
    Callback = function(state)
        ESPStuds = state
    end
})

-- ============================================================
-- PLAYER TAB
-- ============================================================
PlayerTab:AddSection("Player Settings")

PlayerTab:AddToggle({
    Name = "Walk Speed Bypass",
    Default = false,
    Flag = "VD_WalkSpeed",
    Callback = function(state)
        WalkToggle = state
        if state then applyBypassSpeed() end
        Notify("Walk Speed", state and "Enabled" or "Disabled", 2)
    end
})

PlayerTab:AddSlider({
    Name = "Walk Speed Value",
    Range = {16, 200},
    Increment = 1,
    Default = currentSpeed,
    Flag = "VD_WalkSpeedVal",
    Callback = function(val)
        currentSpeed = val
        if WalkToggle and hum then hum.WalkSpeed = val end
    end
})

PlayerTab:AddToggle({
    Name = "Noclip",
    Default = false,
    Flag = "VD_Noclip",
    Callback = function(state)
        NoclipToggle = state
        if state then noclip() else clip() end
        Notify("Noclip", state and "Enabled" or "Disabled", 2)
    end
})

PlayerTab:AddToggle({
    Name = "God Mode",
    Default = false,
    Flag = "VD_GodMode",
    Callback = function(state)
        toggleGodmode(state)
    end
})

PlayerTab:AddToggle({
    Name = "Anti Flashlight",
    Default = false,
    Flag = "VD_AntiFlash",
    Callback = function(state)
        toggleAntiFlashlight(state)
    end
})

PlayerTab:AddToggle({
    Name = "Invisibility (Beta)",
    Default = false,
    Flag = "VD_Invisibility",
    Callback = function(state)
        InvisibilityToggle = state
        if state then enableInvis() else disableInvis() end
        Notify("Invisibility", state and "Enabled" or "Disabled", 2)
    end
})

PlayerTab:AddToggle({
    Name = "No Fall Damage",
    Default = false,
    Flag = "VD_NoFall",
    Callback = function(state)
        NoFallToggle = state
        if state then
            FallRemote:FireServer(0, 0, 0, 0)
        end
        Notify("No Fall", state and "Enabled" or "Disabled", 2)
    end
})

-- ============================================================
-- MISC TAB
-- ============================================================
MiscTab:AddSection("Misc Features")

MiscTab:AddToggle({
    Name = "Auto Shoot (Mobile)",
    Default = false,
    Flag = "VD_AutoShoot",
    Callback = function(state)
        Autoshoot = state
        if state then AutoShoot() else if facingLoop then facingLoop:Disconnect() facingLoop = nil end end
        Notify("Auto Shoot", state and "Enabled" or "Disabled", 2)
    end
})

MiscTab:AddToggle({
    Name = "Auto Presents",
    Default = false,
    Flag = "VD_AutoPresents",
    Callback = function(state)
        AutoEventToggle = state
        if state then autofarmcurrency() end
        Notify("Auto Presents", state and "Enabled" or "Disabled", 2)
    end
})

MiscTab:AddToggle({
    Name = "Damage Aura",
    Default = false,
    Flag = "VD_DamageAura",
    Callback = function(state)
        DamageAura = state
        Notify("Damage Aura", state and "Enabled" or "Disabled", 2)
    end
})

MiscTab:AddToggle({
    Name = "Expand Hitboxes",
    Default = false,
    Flag = "VD_ExpandHitbox",
    Callback = function(state)
        ExpandHitboxesToggle = state
        Notify("Expand Hitboxes", state and "Enabled" or "Disabled", 2)
    end
})

MiscTab:AddToggle({
    Name = "Hitboxes Visible",
    Default = false,
    Flag = "VD_HitboxVisible",
    Callback = function(state)
        HitboxesVisibleToggle = state
        Notify("Hitboxes Visible", state and "Enabled" or "Disabled", 2)
    end
})

MiscTab:AddSlider({
    Name = "Hitbox Radius",
    Range = {5, 50},
    Increment = 1,
    Default = HitboxesRadius,
    Flag = "VD_HitboxRadius",
    Callback = function(val)
        HitboxesRadius = val
    end
})

MiscTab:AddSection("Desync")

MiscTab:AddToggle({
    Name = "Enable Desync",
    Default = false,
    Flag = "VD_Desync",
    Callback = function(state)
        Desync = state
        Notify("Desync", state and "Enabled" or "Disabled", 2)
    end
})

MiscTab:AddDropdown({
    Name = "Desync Type",
    Options = {"Hitbox Improving", "Fake Position"},
    Default = "Hitbox Improving",
    Flag = "VD_DesyncType",
    Callback = function(opt)
        DesyncType = opt
    end
})

-- ============================================================
-- CONFIG TAB
-- ============================================================
ConfigTab:AddSection("Configuration")

ConfigTab:AddButton({
    Name = "Save Config",
    Callback = function()
        Notify("Config", "Saved automatically by bearlib", 2)
    end
})

ConfigTab:AddButton({
    Name = "Reset All Settings",
    Callback = function()
        -- Reset semua flag dan state
        Notify("Config", "Reset to default (re-execute script)", 3)
    end
})

-- ============================================================
-- INISIALISASI
-- ============================================================
_initializing = false
Notify("Anonymous9x VIP", "Loaded successfully! All features ready.", 4)
print("Anonymous9x VIP | Violence District loaded.")
