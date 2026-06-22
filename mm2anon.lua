-- ============================================================
-- KONFIGURASI
-- ============================================================
local ANOLIB_RAW_URL = "https://raw.githubusercontent.com/Anonymous9x-oss/Anonymous9xProjectv1/refs/heads/main/anolib.lua"
local REQUIRED_PLACE_ID = 142823291  -- Murder Mystery 2

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
            Message = "Script ini khusus untuk Murder Mystery 2. Place ID: " .. REQUIRED_PLACE_ID,
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
-- LOGIKA DASAR AZURE HUB (TIDAK DIUBAH)
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
local character, hum, root

local function uCR(char)
    character = char
    root = character:WaitForChild("HumanoidRootPart", 5)
    hum = character:WaitForChild("Humanoid", 5)
end

uCR(lp.Character or lp.CharacterAdded:Wait())
lp.CharacterAdded:Connect(function(newChar) uCR(newChar) end)

-- Blacklist dan Discord (dihilangkan fungsi kick)
local blacklist = {}
local discordLink = "https://discord.gg/ptvyFfK3pU"

local gid = 0
local bannedRanks = {}
local rankName = lp:GetRoleInGroup(0)
if bannedRanks[rankName] then
    lp:Kick("Exploiting")
end

print("Loaded! Anonymous9x VIP | Murder Mystery 2")

-- ============================================================
-- VARIABEL FITUR AZURE HUB
-- ============================================================
local KillAuraToggle = false
local KillAuraRadius = 15
local AutoKillToggle = false
local AutoShootToggle = false
local PredictionToggle = false
local AutoFarmToggle = false
local AutoGrabToggle = false
local AutoFarmAvoidToggle = false
local AutoFarmMethod = "Closest"
local WalkToggle = false
local currentSpeed = 28
local Noclip = nil
local Clip = nil
local NoclipToggle = false
local antiAfkToggle = false
local FlingToggle = false          -- Touch Fling
local antiFlingToggle = false
local antiAdminToggle = false

-- ============================================================
-- VARIABEL ESP (BARU)
-- ============================================================
local ESPEnabled = false
local ESPAll = false
local ESPMurderer = false
local ESPSheriff = false
local ESPName = false
local ESPStuds = false
local ESPHealth = false
local ESPTracers = false
local ESPBoxes = false
local espBillboards = {}           -- player -> billboard
local espHighlights = {}           -- player -> highlight
local espTracers = {}              -- player -> drawing line
local espBoxes = {}                -- player -> box lines
local espLoopRunning = false

-- ============================================================
-- VARIABEL FLING SYSTEM (SIEXTHER LOGIC)
-- ============================================================
local FlingTargetPlayer = nil
local FlingTargetToggle = false
local FlingLoopToggle = false
local FlingAllToggle = false
local FlingAllRunning = false
local FlingLoopRunning = false
local SelectedTargets = {}         -- name -> player
local FlingActive = false
local FlingConnection = nil
local OldPos = nil
local FPDH = workspace.FallenPartsDestroyHeight

-- ============================================================
-- FUNGSI AZURE HUB (TIDAK DIUBAH)
-- ============================================================
local function fling()
    local movel = 0.1
    while FlingToggle do
        RunService.Heartbeat:Wait()
        local c = lp.Character
        local hrp = c and c:FindFirstChild("HumanoidRootPart")
        if hrp then
            local vel = hrp.Velocity
            hrp.Velocity = vel * 10000 + Vector3.new(0, 10000, 0)
            RunService.RenderStepped:Wait()
            hrp.Velocity = vel
            RunService.Stepped:Wait()
            hrp.Velocity = vel + Vector3.new(0, movel, 0)
            movel = -movel
        end
    end
end

task.spawn(function()
    while task.wait(60) do
        if antiAfkToggle then
            root.CFrame = root.CFrame + Vector3.new(0, 3, 0)
        end
    end
end)

local function autograb()
    task.spawn(function()
        while AutoGrabToggle do
            local gun = workspace:FindFirstChild("GunDrop", true)
            if gun and gun:IsA("BasePart") and root then
                local oldPos = root.CFrame
                root.CFrame = gun.CFrame
                task.wait(0.3)
                root.CFrame = oldPos
                task.wait(1)
            end
            task.wait(0.5)
        end
    end)
end

local function autoshoot()
    task.spawn(function()
        while AutoShootToggle do
            local gun = lp.Character and lp.Character:FindFirstChild("Gun")
            if gun and gun:FindFirstChild("Shoot") then
                local murderer = nil
                local targetHRP = nil
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= lp and p.Character then
                        local char = p.Character
                        local isMrd = char:FindFirstChild("Footsteps") or char:FindFirstChild("Sleight") or char:FindFirstChild("Decoy") or char:FindFirstChild("Ghost") or char:FindFirstChild("Fake Gun") or char:FindFirstChild("Xray") or char:FindFirstChild("Haste") or char:FindFirstChild("Trap") or char:FindFirstChild("Sprint") or char:FindFirstChild("Ninja")
                        if isMrd then
                            targetHRP = char:FindFirstChild("HumanoidRootPart")
                            murderer = char
                            break
                        end
                    end
                end
                if targetHRP and root then
                    local origin = root.Position
                    local direction = (targetHRP.Position - origin)
                    local rayParams = RaycastParams.new()
                    rayParams.FilterDescendantsInstances = {lp.Character, workspace.CurrentCamera}
                    rayParams.FilterType = Enum.RaycastFilterType.Exclude
                    local result = workspace:Raycast(origin, direction, rayParams)
                    if result and result.Instance:IsDescendantOf(murderer) then
                        local finalTargetCFrame = targetHRP.CFrame
                        if PredictionToggle then
                            local velocity = targetHRP.Velocity
                            local predictionOffset = velocity * 0.15
                            finalTargetCFrame = targetHRP.CFrame + predictionOffset
                        end
                        local args = { root.CFrame, finalTargetCFrame }
                        gun.Shoot:FireServer(unpack(args))
                        task.wait(0.5)
                    end
                end
            end
            task.wait()
        end
    end)
end

local function loopkillaura()
    task.spawn(function()
        while KillAuraToggle do
            local isMurderer = character:FindFirstChild("Footsteps") or character:FindFirstChild("Sleight") or character:FindFirstChild("Decoy") or character:FindFirstChild("Ghost") or character:FindFirstChild("Fake Gun") or character:FindFirstChild("Xray") or character:FindFirstChild("Haste") or character:FindFirstChild("Trap") or character:FindFirstChild("Sprint") or character:FindFirstChild("Ninja")
            if isMurderer and root then
                for _, plr in ipairs(Players:GetPlayers()) do
                    if plr ~= lp and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                        local targetRoot = plr.Character.HumanoidRootPart
                        local distance = (root.Position - targetRoot.Position).Magnitude
                        if distance <= KillAuraRadius then
                            local targetPos = root.CFrame:ToWorldSpace(CFrame.new(0, 0, -1.5))
                            targetRoot.CFrame = CFrame.new(targetPos.Position) * targetRoot.CFrame.Rotation
                        end
                    end
                end
            end
            task.wait(0.05)
        end
    end)
end

local function killplayers()
    task.spawn(function()
        while AutoKillToggle do
            local isMurderer = character:FindFirstChild("Footsteps") or character:FindFirstChild("Sleight") or character:FindFirstChild("Decoy") or character:FindFirstChild("Ghost") or character:FindFirstChild("Fake Gun") or character:FindFirstChild("Xray") or character:FindFirstChild("Haste") or character:FindFirstChild("Trap") or character:FindFirstChild("Sprint") or character:FindFirstChild("Ninja")
            if isMurderer and root then
                for _, plr in ipairs(Players:GetPlayers()) do
                    if plr ~= lp and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                        local targetRoot = plr.Character.HumanoidRootPart
                        local targetPos = root.CFrame:ToWorldSpace(CFrame.new(0, 0, -1.5))
                        targetRoot.CFrame = CFrame.new(targetPos.Position) * targetRoot.CFrame.Rotation
                    end
                end
            end
            task.wait(0.05)
        end
    end)
end

local function autofarm()
    task.spawn(function()
        while AutoFarmToggle do
            local myChar = lp.Character
            local isMurderer = myChar and (myChar:FindFirstChild("Footsteps") or myChar:FindFirstChild("Sleight") or myChar:FindFirstChild("Decoy") or myChar:FindFirstChild("Ghost") or myChar:FindFirstChild("Fake Gun") or myChar:FindFirstChild("Xray") or myChar:FindFirstChild("Haste") or myChar:FindFirstChild("Trap") or myChar:FindFirstChild("Sprint") or myChar:FindFirstChild("Ninja"))
            local CoinContainer = workspace:FindFirstChild("CoinContainer", true)
            if CoinContainer then
                local currentMurderer = nil
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= lp and p.Character then
                        local char = p.Character
                        if char:FindFirstChild("Footsteps") or char:FindFirstChild("Decoy") or char:FindFirstChild("Sleight") or char:FindFirstChild("Ghost") or char:FindFirstChild("Ninja") or char:FindFirstChild("Fake Gun") or char:FindFirstChild("Xray") or char:FindFirstChild("Haste") or char:FindFirstChild("Trap") or char:FindFirstChild("Sprint") or char:FindFirstChild("Ninja") then
                            currentMurderer = char:FindFirstChild("HumanoidRootPart")
                            break
                        end
                    end
                end
                local allCoins = {}
                for _, c in ipairs(CoinContainer:GetChildren()) do
                    if c:IsA("BasePart") and string.find(c.Name, "Coin_Server") then
                        local isDangerous = false
                        if AutoFarmAvoidToggle and currentMurderer then
                            if (c.Position - currentMurderer.Position).Magnitude < 15 then
                                isDangerous = true
                            end
                        end
                        if not isDangerous then
                            table.insert(allCoins, c)
                        end
                    end
                end
                local targetCoin = nil
                local tweenTime = 1
                local waitTime = 1.1
                if #allCoins > 0 then
                    if AutoFarmMethod == "Closest" and root then
                        local closestDist = math.huge
                        for _, coin in ipairs(allCoins) do
                            local dist = (root.Position - coin.Position).Magnitude
                            if dist < closestDist then
                                closestDist = dist
                                targetCoin = coin
                            end
                        end
                    elseif AutoFarmMethod == "Randomized" then
                        targetCoin = allCoins[math.random(1, #allCoins)]
                        tweenTime = 3
                        waitTime = 3.1
                    end
                end
                if targetCoin and root then
                    local distance = (root.Position - targetCoin.Position).Magnitude
                    if distance > 10 then
                        tweenTime = tweenTime + 0.5; waitTime = waitTime + 0.6
                    elseif distance < 5 then
                        tweenTime = 0.3; waitTime = 0.4
                    end
                    local tween = TweenService:Create(root, TweenInfo.new(tweenTime, Enum.EasingStyle.Linear), {CFrame = CFrame.new(targetCoin.Position)})
                    tween:Play()
                    local start = tick()
                    local cancelled = false
                    while tick() - start < waitTime do
                        if not AutoFarmToggle then tween:Cancel(); break end
                        if AutoFarmAvoidToggle and currentMurderer and not isMurderer then
                            if (root.Position - currentMurderer.Position).Magnitude < 7 then
                                tween:Cancel()
                                cancelled = true
                                break
                            end
                        end
                        task.wait(0.1)
                    end
                    if not cancelled and targetCoin and targetCoin.Parent then
                        targetCoin:Destroy()
                    end
                else
                    task.wait(0.5)
                end
            else
                task.wait(1)
            end
        end
    end)
end

-- ============================================================
-- NOCLIP & SPEED
-- ============================================================
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
    if Noclip then
        Noclip:Disconnect()
        Noclip = nil
    end
end

local function applyBypassSpeed()
    task.spawn(function()
        while task.wait(0.2) do
            if not WalkToggle then continue end
            if hum then
                for _, conn in ipairs(getconnections(hum:GetPropertyChangedSignal("WalkSpeed"))) do
                    conn:Disable()
                end
                hum.WalkSpeed = currentSpeed
            end
        end
    end)
end
applyBypassSpeed()

-- ============================================================
-- ANTI FLING LOOP
-- ============================================================
task.spawn(function()
    while task.wait(0.02) do
        if antiFlingToggle then
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= lp and plr.Character then
                    for _, part in ipairs(plr.Character:GetChildren()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
            end
        end
    end
end)

-- ============================================================
-- FUNGSI FLING (SIEXTHER LOGIC)
-- ============================================================
local function SkidFling(TargetPlayer)
    local Character = lp.Character
    local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
    local RootPart = Humanoid and Humanoid.RootPart
    local TCharacter = TargetPlayer.Character
    if not TCharacter then return end

    local THumanoid, TRootPart, THead, Accessory, Handle
    if TCharacter:FindFirstChildOfClass("Humanoid") then
        THumanoid = TCharacter:FindFirstChildOfClass("Humanoid")
    end
    if THumanoid and THumanoid.RootPart then
        TRootPart = THumanoid.RootPart
    end
    if TCharacter:FindFirstChild("Head") then
        THead = TCharacter.Head
    end
    if TCharacter:FindFirstChildOfClass("Accessory") then
        Accessory = TCharacter:FindFirstChildOfClass("Accessory")
    end
    if Accessory and Accessory:FindFirstChild("Handle") then
        Handle = Accessory.Handle
    end

    if Character and Humanoid and RootPart then
        if RootPart.Velocity.Magnitude < 50 then
            OldPos = RootPart.CFrame
        end

        if THumanoid and THumanoid.Sit then
            Notify("Fling Error", TargetPlayer.Name .. " is sitting", 2)
            return
        end

        if THead then
            workspace.CurrentCamera.CameraSubject = THead
        elseif Handle then
            workspace.CurrentCamera.CameraSubject = Handle
        elseif THumanoid and TRootPart then
            workspace.CurrentCamera.CameraSubject = THumanoid
        end

        if not TCharacter:FindFirstChildWhichIsA("BasePart") then
            return
        end

        local FPos = function(BasePart, Pos, Ang)
            RootPart.CFrame = CFrame.new(BasePart.Position) * Pos * Ang
            Character:SetPrimaryPartCFrame(CFrame.new(BasePart.Position) * Pos * Ang)
            RootPart.Velocity = Vector3.new(9e7, 9e7 * 10, 9e7)
            RootPart.RotVelocity = Vector3.new(9e8, 9e8, 9e8)
        end

        local SFBasePart = function(BasePart)
            local TimeToWait = 2
            local Time = tick()
            local Angle = 0
            repeat
                if RootPart and THumanoid then
                    if BasePart.Velocity.Magnitude < 50 then
                        Angle = Angle + 100
                        FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle),0 ,0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle),0 ,0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection, CFrame.Angles(math.rad(Angle),0 ,0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection, CFrame.Angles(math.rad(Angle), 0, 0))
                        task.wait()
                    else
                        FPos(BasePart, CFrame.new(0, 1.5, THumanoid.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, -THumanoid.WalkSpeed), CFrame.Angles(0, 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, 1.5, THumanoid.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(90), 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(90), 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0))
                        task.wait()
                    end
                end
            until Time + TimeToWait < tick() or not FlingActive
        end

        workspace.FallenPartsDestroyHeight = math.huge

        local BV = Instance.new("BodyVelocity")
        BV.Parent = RootPart
        BV.Velocity = Vector3.new(0, 0, 0)
        BV.MaxForce = Vector3.new(9e9, 9e9, 9e9)

        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)

        if TRootPart then
            SFBasePart(TRootPart)
        elseif THead then
            SFBasePart(THead)
        elseif Handle then
            SFBasePart(Handle)
        else
            Notify("Fling Error", TargetPlayer.Name .. " has no valid parts", 2)
            return
        end

        BV:Destroy()
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
        workspace.CurrentCamera.CameraSubject = Humanoid

        if OldPos then
            repeat
                RootPart.CFrame = OldPos * CFrame.new(0, .5, 0)
                Character:SetPrimaryPartCFrame(OldPos * CFrame.new(0, .5, 0))
                Humanoid:ChangeState("GettingUp")
                for _, part in pairs(Character:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.Velocity, part.RotVelocity = Vector3.new(), Vector3.new()
                    end
                end
                task.wait()
            until (RootPart.Position - OldPos.p).Magnitude < 25
            workspace.FallenPartsDestroyHeight = FPDH
        end
    else
        Notify("Fling Error", "Your character is not ready", 2)
    end
end

local function StartFling()
    if FlingActive then return end
    local count = 0
    for _ in pairs(SelectedTargets) do count = count + 1 end
    if count == 0 then
        Notify("Fling", "No targets selected!", 2)
        return
    end
    FlingActive = true
    Notify("Fling", "Flinging " .. count .. " target(s)", 2)

    task.spawn(function()
        while FlingActive do
            local validTargets = {}
            for name, player in pairs(SelectedTargets) do
                if player and player.Parent then
                    validTargets[name] = player
                else
                    SelectedTargets[name] = nil
                end
            end
            for _, player in pairs(validTargets) do
                if FlingActive then
                    SkidFling(player)
                    task.wait(0.1)
                else
                    break
                end
            end
            task.wait(0.5)
        end
    end)
end

local function StopFling()
    if not FlingActive then return end
    FlingActive = false
    Notify("Fling", "Stopped", 2)
end

-- ============================================================
-- FUNGSI ESP (BARU DENGAN BILLBOARD + HIGHLIGHT + TRACER + BOX + HEALTH)
-- ============================================================
-- Helper: cek role player
local function GetPlayerRole(player)
    if not player.Character then return "Innocent" end
    local char = player.Character
    local backpack = player.Backpack
    if char:FindFirstChild("Knife") or (backpack and backpack:FindFirstChild("Knife")) then
        return "Murderer"
    elseif char:FindFirstChild("Gun") or (backpack and backpack:FindFirstChild("Gun")) then
        return "Sheriff"
    end
    return "Innocent"
end

-- Fungsi membuat/update billboard untuk satu player
local function UpdatePlayerESP(player)
    if player == lp then return end
    if not player.Character then
        -- hapus ESP jika ada
        if espBillboards[player] then espBillboards[player]:Destroy() end
        espBillboards[player] = nil
        if espHighlights[player] then espHighlights[player]:Destroy() end
        espHighlights[player] = nil
        if espTracers[player] then espTracers[player]:Remove() end
        espTracers[player] = nil
        if espBoxes[player] then
            for _, line in pairs(espBoxes[player]) do line:Remove() end
            espBoxes[player] = nil
        end
        return
    end

    local role = GetPlayerRole(player)
    local show = false
    if ESPAll then
        show = true
    elseif role == "Murderer" and ESPMurderer then
        show = true
    elseif role == "Sheriff" and ESPSheriff then
        show = true
    end
    if not show or not ESPEnabled then
        -- sembunyikan atau hapus
        if espBillboards[player] then espBillboards[player].Enabled = false end
        if espHighlights[player] then espHighlights[player].Enabled = false end
        if espTracers[player] then espTracers[player].Visible = false end
        if espBoxes[player] then
            for _, line in pairs(espBoxes[player]) do line.Visible = false end
        end
        return
    end

    local head = player.Character:FindFirstChild("Head")
    if not head then return end

    -- Warna sesuai role
    local color
    if role == "Murderer" then color = Color3.fromRGB(255, 0, 0)
    elseif role == "Sheriff" then color = Color3.fromRGB(0, 0, 255)
    else color = Color3.fromRGB(0, 255, 0) end

    -- Billboard
    if not espBillboards[player] then
        local b = Instance.new("BillboardGui")
        b.Size = UDim2.new(0, 200, 0, 50)
        b.Adornee = head
        b.AlwaysOnTop = true
        b.MaxDistance = 5000
        b.Parent = player.Character
        local l = Instance.new("TextLabel")
        l.Name = "Label"
        l.Parent = b
        l.BackgroundTransparency = 1
        l.Size = UDim2.new(1, 0, 1, 0)
        l.Font = Enum.Font.SourceSansBold
        l.TextSize = 14
        l.TextStrokeTransparency = 0
        espBillboards[player] = b
    end
    local b = espBillboards[player]
    b.Adornee = head
    b.Enabled = true
    local label = b:FindFirstChild("Label")
    if label then
        local text = ""
        if ESPName then
            text = player.Name
        end
        if ESPStuds then
            local dist = (Camera.CFrame.Position - head.Position).Magnitude
            if text ~= "" then text = text .. " " end
            text = text .. string.format("%.0fm", dist)
        end
        if ESPHealth then
            local hum = player.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                if text ~= "" then text = text .. " " end
                text = text .. string.format("[%d/%d]", hum.Health, hum.MaxHealth)
            end
        end
        label.Text = text
        label.TextColor3 = color
    end

    -- Highlight
    if not espHighlights[player] then
        local h = Instance.new("Highlight")
        h.Adornee = player.Character
        h.FillTransparency = 0.5
        h.OutlineTransparency = 0
        h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        h.Parent = player.Character
        espHighlights[player] = h
    end
    local h = espHighlights[player]
    h.FillColor = color
    h.OutlineColor = color
    h.Enabled = true

    -- Tracer (Drawing)
    if ESPTracers then
        if not espTracers[player] then
            local L = Drawing.new("Line")
            L.Thickness = 1
            L.Transparency = 1
            espTracers[player] = L
        end
        local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
        if onScreen and screenPos.Z > 0 then
            espTracers[player].Visible = true
            espTracers[player].Color = color
            espTracers[player].From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
            espTracers[player].To = Vector2.new(screenPos.X, screenPos.Y)
        else
            espTracers[player].Visible = false
        end
    else
        if espTracers[player] then
            espTracers[player]:Remove()
            espTracers[player] = nil
        end
    end

    -- Boxes (4 lines)
    if ESPBoxes then
        if not espBoxes[player] then
            espBoxes[player] = {
                tl = Drawing.new("Line"),
                tr = Drawing.new("Line"),
                bl = Drawing.new("Line"),
                br = Drawing.new("Line")
            }
            for _, line in pairs(espBoxes[player]) do
                line.Thickness = 1
                line.Transparency = 1
            end
        end
        local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
        if onScreen and screenPos.Z > 0 then
            local size = (1 / screenPos.Z) * 1000
            local w, h = size * 0.6, size
            local x, y = screenPos.X, screenPos.Y
            local box = espBoxes[player]
            box.tl.From = Vector2.new(x-w, y-h); box.tl.To = Vector2.new(x+w, y-h)
            box.tr.From = Vector2.new(x+w, y-h); box.tr.To = Vector2.new(x+w, y+h)
            box.br.From = Vector2.new(x+w, y+h); box.br.To = Vector2.new(x-w, y+h)
            box.bl.From = Vector2.new(x-w, y+h); box.bl.To = Vector2.new(x-w, y-h)
            for _, line in pairs(box) do
                line.Visible = true
                line.Color = color
            end
        else
            for _, line in pairs(espBoxes[player]) do
                line.Visible = false
            end
        end
    else
        if espBoxes[player] then
            for _, line in pairs(espBoxes[player]) do line:Remove() end
            espBoxes[player] = nil
        end
    end
end

-- ESP Loop utama
local function ESPLoop()
    if espLoopRunning then return end
    espLoopRunning = true
    task.spawn(function()
        while ESPEnabled do
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= lp then
                    UpdatePlayerESP(player)
                end
            end
            task.wait(0.3)
        end
        -- cleanup
        for player, b in pairs(espBillboards) do
            if b then b:Destroy() end
            espBillboards[player] = nil
        end
        for player, h in pairs(espHighlights) do
            if h then h:Destroy() end
            espHighlights[player] = nil
        end
        for player, t in pairs(espTracers) do
            if t then t:Remove() end
            espTracers[player] = nil
        end
        for player, box in pairs(espBoxes) do
            for _, line in pairs(box) do line:Remove() end
            espBoxes[player] = nil
        end
        espLoopRunning = false
    end)
end

-- Fungsi toggle ESP
local function ToggleESP(state)
    ESPEnabled = state
    if state then
        ESPLoop()
        Notify("ESP", "Enabled", 2)
    else
        Notify("ESP", "Disabled", 2)
    end
end

-- ============================================================
-- MEMBUAT WINDOW BEARLIB
-- ============================================================
local Window = bearlib:MakeWindow({
    Name = "Anonymous9x VIP",
    SubTitle = "For Murder Mystery 2",
    SaveFolder = "MM2_Config.json"
})

-- ============================================================
-- TAB
-- ============================================================
local MainTab   = Window:MakeTab({ Title = "Main",   Icon = "rbxassetid://10734971339" })
local EspTab    = Window:MakeTab({ Title = "ESP",    Icon = "rbxassetid://10723346959" })
local PlayerTab = Window:MakeTab({ Title = "Player", Icon = "rbxassetid://10734975692" })
local MiscTab   = Window:MakeTab({ Title = "Misc",   Icon = "rbxassetid://10734950309" })

-- ============================================================
-- MAIN TAB - MURDERER
-- ============================================================
MainTab:AddSection("Murderer")

MainTab:AddToggle({
    Name = "Kill Aura",
    Default = false,
    Flag = "MM2_KillAura",
    Callback = function(state)
        KillAuraToggle = state
        if state then
            loopkillaura()
            Notify("Kill Aura", "Enabled", 2)
        else
            Notify("Kill Aura", "Disabled", 2)
        end
    end
})

MainTab:AddSlider({
    Name = "Kill Aura Radius",
    Range = {1, 50},
    Increment = 1,
    Default = KillAuraRadius,
    Flag = "MM2_KillAuraRadius",
    Callback = function(val)
        KillAuraRadius = tonumber(val)
        Notify("Kill Aura Radius", "Set to " .. val, 2)
    end
})

MainTab:AddToggle({
    Name = "Kill Everyone",
    Default = false,
    Flag = "MM2_KillAll",
    Callback = function(state)
        AutoKillToggle = state
        if state then
            killplayers()
            Notify("Kill Everyone", "Enabled", 2)
        else
            Notify("Kill Everyone", "Disabled", 2)
        end
    end
})

-- ============================================================
-- MAIN TAB - SHERIFF
-- ============================================================
MainTab:AddSection("Sheriff")

MainTab:AddToggle({
    Name = "Auto Shoot Murder",
    Default = false,
    Flag = "MM2_AutoShoot",
    Callback = function(state)
        AutoShootToggle = state
        if state then
            autoshoot()
            Notify("Auto Shoot", "Enabled", 2)
        else
            Notify("Auto Shoot", "Disabled", 2)
        end
    end
})

MainTab:AddToggle({
    Name = "Auto Shoot Prediction (Premium)",
    Default = false,
    Flag = "MM2_Prediction",
    Callback = function(state)
        PredictionToggle = state
        if state and not getgenv().PREMIUM_KEY then
            PredictionToggle = false
            Notify("Premium Feature", "Get premium in our discord server.", 3)
            return
        end
        Notify("Prediction", state and "Enabled" or "Disabled", 2)
    end
})

-- ============================================================
-- MAIN TAB - INNOCENT
-- ============================================================
MainTab:AddSection("Innocent")

MainTab:AddToggle({
    Name = "Auto Grab Gun",
    Default = false,
    Flag = "MM2_AutoGrab",
    Callback = function(state)
        AutoGrabToggle = state
        if state then
            autograb()
            Notify("Auto Grab", "Enabled", 2)
        else
            Notify("Auto Grab", "Disabled", 2)
        end
    end
})

-- ============================================================
-- MAIN TAB - FARMING
-- ============================================================
MainTab:AddSection("Farming")

MainTab:AddToggle({
    Name = "Auto Farm Coins",
    Default = false,
    Flag = "MM2_AutoFarm",
    Callback = function(state)
        AutoFarmToggle = state
        if state then
            NoclipToggle = true
            noclip()
            autofarm()
            Notify("Auto Farm", "Enabled", 2)
        else
            NoclipToggle = false
            clip()
            Notify("Auto Farm", "Disabled", 2)
        end
    end
})

MainTab:AddToggle({
    Name = "Avoid Murderer",
    Default = false,
    Flag = "MM2_AvoidMurder",
    Callback = function(state)
        AutoFarmAvoidToggle = state
        Notify("Avoid Murderer", state and "Enabled" or "Disabled", 2)
    end
})

MainTab:AddDropdown({
    Name = "Farm Method",
    Options = {"Closest", "Randomized"},
    Default = "Closest",
    Flag = "MM2_FarmMethod",
    Callback = function(opt)
        AutoFarmMethod = opt
        Notify("Farm Method", "Set to " .. opt, 2)
    end
})

-- ============================================================
-- MAIN TAB - FLING SYSTEM
-- ============================================================
MainTab:AddSection("Fling System")

-- Dropdown pilih target (update otomatis)
local function UpdateFlingDropdown()
    local names = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= lp then table.insert(names, p.Name) end
    end
    if #names == 0 then table.insert(names, "No players") end
    return names
end

local flingDropdown = MainTab:AddDropdown({
    Name = "Select Fling Target",
    Options = UpdateFlingDropdown(),
    Default = "No players",
    Flag = "MM2_FlingTarget",
    Callback = function(opt)
        for _, p in ipairs(Players:GetPlayers()) do
            if p.Name == opt then
                FlingTargetPlayer = p
                break
            end
        end
        if FlingTargetPlayer then
            Notify("Fling Target", "Target set: " .. FlingTargetPlayer.Name, 2)
        else
            Notify("Fling Target", "Player not found", 2)
        end
    end
})

-- Update dropdown saat player join/leave
Players.PlayerAdded:Connect(function()
    flingDropdown:Refresh(UpdateFlingDropdown(), true)
end)
Players.PlayerRemoving:Connect(function()
    flingDropdown:Refresh(UpdateFlingDropdown(), true)
end)

-- Toggle Fling Selected Target
MainTab:AddToggle({
    Name = "Fling Selected Target",
    Default = false,
    Flag = "MM2_FlingTargetToggle",
    Callback = function(state)
        FlingTargetToggle = state
        if state then
            if FlingTargetPlayer then
                -- tambahkan ke SelectedTargets
                SelectedTargets[FlingTargetPlayer.Name] = FlingTargetPlayer
                if FlingLoopToggle then
                    -- jika loop aktif, mulai loop
                    if not FlingActive then
                        StartFling()
                    end
                else
                    -- fling sekali
                    FlingActive = true
                    task.spawn(function()
                        SkidFling(FlingTargetPlayer)
                        FlingActive = false
                    end)
                    Notify("Fling Target", "Flinged " .. FlingTargetPlayer.Name, 2)
                end
            else
                Notify("Fling Target", "Pilih target terlebih dahulu", 2)
                FlingTargetToggle = false
            end
        else
            -- hapus dari SelectedTargets jika tidak loop
            if FlingTargetPlayer then
                SelectedTargets[FlingTargetPlayer.Name] = nil
            end
            if not FlingLoopToggle then
                StopFling()
            end
            Notify("Fling Target", "Disabled", 2)
        end
    end
})

-- Toggle Loop Fling
MainTab:AddToggle({
    Name = "Loop Fling",
    Default = false,
    Flag = "MM2_LoopFling",
    Callback = function(state)
        FlingLoopToggle = state
        if state then
            Notify("Loop Fling", "Enabled - akan fling terus sampai dimatikan", 2)
            if FlingTargetToggle and FlingTargetPlayer then
                -- pastikan target ada di SelectedTargets
                SelectedTargets[FlingTargetPlayer.Name] = FlingTargetPlayer
                StartFling()
            end
        else
            StopFling()
            Notify("Loop Fling", "Disabled", 2)
        end
    end
})

-- Button Fling All Players
MainTab:AddButton({
    Name = "Fling All Players",
    Callback = function()
        -- tambahkan semua player ke SelectedTargets
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= lp then
                SelectedTargets[p.Name] = p
            end
        end
        StartFling()
        Notify("Fling All", "Started flinging all players", 2)
    end
})

-- Button Stop All Fling
MainTab:AddButton({
    Name = "Stop All Fling",
    Callback = function()
        StopFling()
        SelectedTargets = {}
        FlingTargetToggle = false
        FlingLoopToggle = false
        Notify("Fling", "All fling stopped", 2)
    end
})

-- ============================================================
-- ESP TAB
-- ============================================================
EspTab:AddSection("ESP Toggles")

EspTab:AddToggle({
    Name = "Enable ESP",
    Default = false,
    Flag = "MM2_ESP_Enable",
    Callback = function(state)
        ToggleESP(state)
    end
})

EspTab:AddToggle({
    Name = "All Players",
    Default = false,
    Flag = "MM2_ESP_All",
    Callback = function(state)
        ESPAll = state
        Notify("ESP All", state and "ON" or "OFF", 2)
    end
})

EspTab:AddToggle({
    Name = "Murderer Only",
    Default = false,
    Flag = "MM2_ESP_Murderer",
    Callback = function(state)
        ESPMurderer = state
        Notify("ESP Murderer", state and "ON" or "OFF", 2)
    end
})

EspTab:AddToggle({
    Name = "Sheriff Only",
    Default = false,
    Flag = "MM2_ESP_Sheriff",
    Callback = function(state)
        ESPSheriff = state
        Notify("ESP Sheriff", state and "ON" or "OFF", 2)
    end
})

EspTab:AddSection("ESP Options")

EspTab:AddToggle({
    Name = "Show Name",
    Default = false,
    Flag = "MM2_ESP_Name",
    Callback = function(state)
        ESPName = state
        Notify("ESP Name", state and "ON" or "OFF", 2)
    end
})

EspTab:AddToggle({
    Name = "Show Distance (Studs)",
    Default = false,
    Flag = "MM2_ESP_Studs",
    Callback = function(state)
        ESPStuds = state
        Notify("ESP Studs", state and "ON" or "OFF", 2)
    end
})

EspTab:AddToggle({
    Name = "Show Health",
    Default = false,
    Flag = "MM2_ESP_Health",
    Callback = function(state)
        ESPHealth = state
        Notify("ESP Health", state and "ON" or "OFF", 2)
    end
})

EspTab:AddToggle({
    Name = "Show Tracers",
    Default = false,
    Flag = "MM2_ESP_Tracers",
    Callback = function(state)
        ESPTracers = state
        Notify("ESP Tracers", state and "ON" or "OFF", 2)
    end
})

EspTab:AddToggle({
    Name = "Show Boxes",
    Default = false,
    Flag = "MM2_ESP_Boxes",
    Callback = function(state)
        ESPBoxes = state
        Notify("ESP Boxes", state and "ON" or "OFF", 2)
    end
})

EspTab:AddButton({
    Name = "Full Bright",
    Callback = function()
        local Lighting = game:GetService("Lighting")
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
        Lighting.Brightness = 2
        Lighting.ShadowSoftness = 0
        Lighting.GlobalShadows = false
        Notify("Full Bright", "Enabled", 2)
    end
})

-- ============================================================
-- PLAYER TAB
-- ============================================================
PlayerTab:AddSection("Movement")

PlayerTab:AddToggle({
    Name = "Noclip",
    Default = false,
    Flag = "MM2_Noclip",
    Callback = function(state)
        NoclipToggle = state
        if state then
            noclip()
            Notify("Noclip", "Enabled", 2)
        else
            clip()
            Notify("Noclip", "Disabled", 2)
        end
    end
})

PlayerTab:AddToggle({
    Name = "WalkSpeed Changer",
    Default = false,
    Flag = "MM2_WalkSpeed",
    Callback = function(state)
        WalkToggle = state
        Notify("WalkSpeed", state and "Enabled" or "Disabled", 2)
    end
})

PlayerTab:AddSlider({
    Name = "WalkSpeed Value",
    Range = {16, 100},
    Increment = 1,
    Default = currentSpeed,
    Flag = "MM2_WalkSpeedVal",
    Callback = function(val)
        currentSpeed = val
        Notify("WalkSpeed Value", "Set to " .. val, 2)
    end
})

-- ============================================================
-- MISC TAB
-- ============================================================
MiscTab:AddSection("Misc Features")

MiscTab:AddToggle({
    Name = "Protect Identity",
    Default = false,
    Flag = "MM2_ProtectIdentity",
    Callback = function(state)
        local idConn
        local function bacon(c)
            if not character then return end
            for _, v in pairs(character:GetChildren()) do
                if v:IsA("Accessory") or v:IsA("Clothing") or v:IsA("ShirtGraphic") or v:IsA("CharacterMesh") then
                    v:Destroy()
                end
            end
            if character:FindFirstChild("Head") and character.Head:FindFirstChild("face") then
                character.Head.face.Texture = "rbxassetid://144075659"
            end
            local bc = character:FindFirstChild("BodyColors") or Instance.new("BodyColors", c)
            bc.HeadColor3 = Color3.fromRGB(234, 184, 146)
            bc.TorsoColor3 = Color3.fromRGB(116, 134, 157)
            bc.LeftLegColor3 = Color3.fromRGB(82, 84, 82)
            bc.RightLegColor3 = Color3.fromRGB(82, 84, 82)
            bc.LeftArmColor3 = bc.HeadColor3
            bc.RightArmColor3 = bc.HeadColor3
            if lp then
                lp.Name = "azurehub"
                lp.DisplayName = "azurehub"
            end
        end
        if state then
            bacon(character)
            if idConn then idConn:Disconnect() end
            idConn = lp.CharacterAdded:Connect(function(c)
                bacon(c)
                task.wait(2)
                bacon(c)
            end)
            Notify("Protect Identity", "Enabled", 2)
        else
            if idConn then idConn:Disconnect() end
            Notify("Protect Identity", "Disabled", 2)
        end
    end
})

MiscTab:AddToggle({
    Name = "Anti AFK",
    Default = false,
    Flag = "MM2_AntiAFK",
    Callback = function(state)
        antiAfkToggle = state
        Notify("Anti AFK", state and "Enabled" or "Disabled", 2)
    end
})

MiscTab:AddToggle({
    Name = "Touch Fling",
    Default = false,
    Flag = "MM2_Fling",
    Callback = function(state)
        FlingToggle = state
        if state then
            fling()
            Notify("Touch Fling", "Enabled", 2)
        else
            Notify("Touch Fling", "Disabled", 2)
        end
    end
})

MiscTab:AddToggle({
    Name = "Anti Fling",
    Default = false,
    Flag = "MM2_AntiFling",
    Callback = function(state)
        antiFlingToggle = state
        if not state then
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= lp and plr.Character then
                    for _, part in ipairs(plr.Character:GetChildren()) do
                        if part:IsA("BasePart") then part.CanCollide = true end
                    end
                end
            end
        end
        Notify("Anti Fling", state and "Enabled" or "Disabled", 2)
    end
})

MiscTab:AddToggle({
    Name = "Anti Admin (Kick)",
    Default = false,
    Flag = "MM2_AntiAdmin",
    Callback = function(state)
        antiAdminToggle = state
        Notify("Anti Admin", state and "Enabled" or "Disabled", 2)
    end
})

-- ============================================================
-- ANTI ADMIN LOOP
-- ============================================================
task.spawn(function()
    while task.wait(1) do
        if antiAdminToggle then
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= lp and (table.find(blacklist, plr.UserId) or bannedRanks[plr:GetRoleInGroup(gid)]) then
                    lp:Kick("Admin detected: " .. plr.Name)
                end
            end
        end
        local target = workspace:FindFirstChild("GlitchProof", true)
        if target then target:Destroy() end
    end
end)

-- ============================================================
-- INISIALISASI
-- ============================================================
_initializing = false
Notify("Anonymous9x VIP", "Loaded for Murder Mystery 2! All features ready.", 4)
print("Anonymous9x VIP | Murder Mystery 2 loaded.")
