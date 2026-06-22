-- ============================================================
-- KONFIGURASI
-- ============================================================
local ANOLIB_RAW_URL = "https://raw.githubusercontent.com/Anonymous9x-oss/Anonymous9xProjectv1/refs/heads/main/anolib.lua"
local REQUIRED_PLACE_ID = 142823291  -- Place ID Murder Mystery 2

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
-- SEMUA LOGIKA DARI AZURE HUB (TIDAK DIUBAH)
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

-- Blacklist dan Discord (dihilangkan fungsi kick, hanya placeholder)
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
-- VARIABEL FITUR
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
local FlingToggle = false
local antiFlingToggle = false
local flingThread
local antiAdminToggle = false

-- ESP Variables (baru, lebih robust)
local ESPEnabled = false
local ESPHighlightEnabled = false
local ESPNamesEnabled = false
local ESPDistanceEnabled = false
local ESPBoxesEnabled = false
local ESPTracersEnabled = false
local ESPObjects = {}
local espHighlights = {}
local espBillboards = {}
local espBoxes = {}
local espTracers = {}
local espLoopRunning = false
local selectedESPTypes = {}

-- ============================================================
-- VARIABEL FLING SYSTEM (TAMBAHAN)
-- ============================================================
local FlingTargetPlayer = nil          -- Target player yang dipilih
local FlingTargetToggle = false        -- Fling satu target
local FlingLoopToggle = false          -- Loop fling (terus menerus)
local FlingAllToggle = false           -- Fling semua player
local FlingAllRunning = false          -- Status sedang menjalankan fling all
local FlingLoopRunning = false         -- Status loop fling

-- ============================================================
-- FUNGSI-FUNGSI DARI AZURE HUB (TIDAK DIUBAH)
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
-- FUNGSI FLING TARGET (TAMBAHAN)
-- ============================================================
local function FlingTargetPlayerFunction(targetPlayer)
    if not targetPlayer or not targetPlayer.Character then
        Notify("Fling Error", "Target tidak valid atau tidak memiliki karakter", 2)
        return
    end

    local targetHRP = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not targetHRP then
        Notify("Fling Error", "Target tidak memiliki HumanoidRootPart", 2)
        return
    end

    local myHRP = root
    if not myHRP then
        Notify("Fling Error", "Karakter Anda tidak valid", 2)
        return
    end

    -- Simpan posisi awal
    local originalPos = myHRP.CFrame

    -- Fling logic (sama seperti touch fling tapi untuk target spesifik)
    for i = 1, 5 do
        if not FlingTargetToggle and not FlingLoopToggle and not FlingAllToggle then break end
        myHRP.CFrame = targetHRP.CFrame * CFrame.new(0, 0, 1)
        task.wait(0.1)
        myHRP.Velocity = Vector3.new(0, 1000, 0)
        task.wait(0.1)
        myHRP.CFrame = targetHRP.CFrame * CFrame.new(0, 5, 0)
        task.wait(0.1)
        myHRP.Velocity = Vector3.new(1000, 0, 0)
        task.wait(0.1)
        myHRP.CFrame = targetHRP.CFrame * CFrame.new(0, -5, 0)
        task.wait(0.1)
        myHRP.Velocity = Vector3.new(-1000, 0, 0)
        task.wait(0.1)
    end

    -- Kembali ke posisi awal
    myHRP.CFrame = originalPos
    myHRP.Velocity = Vector3.new(0, 0, 0)
end

-- ============================================================
-- FUNGSI FLING ALL (TAMBAHAN)
-- ============================================================
local function FlingAllPlayers()
    if FlingAllRunning then return end
    FlingAllRunning = true

    local playersToFling = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            table.insert(playersToFling, p)
        end
    end

    if #playersToFling == 0 then
        Notify("Fling All", "Tidak ada player lain yang ditemukan", 2)
        FlingAllRunning = false
        return
    end

    Notify("Fling All", "Memulai fling " .. #playersToFling .. " player(s)", 3)

    for _, target in ipairs(playersToFling) do
        if not FlingAllToggle and not FlingLoopToggle then
            FlingAllRunning = false
            return
        end
        FlingTargetPlayerFunction(target)
        task.wait(0.5)
    end

    FlingAllRunning = false
    if FlingLoopToggle then
        -- Jika loop aktif, jalankan ulang
        task.wait(1)
        FlingAllPlayers()
    else
        Notify("Fling All", "Selesai fling semua player", 2)
    end
end

-- ============================================================
-- FUNGSI FLING TARGET DENGAN LOOP (TAMBAHAN)
-- ============================================================
local function FlingTargetLoop()
    if FlingLoopRunning then return end
    FlingLoopRunning = true

    while FlingLoopToggle and FlingTargetPlayer do
        if not FlingTargetToggle then
            task.wait(0.5)
            continue
        end
        FlingTargetPlayerFunction(FlingTargetPlayer)
        task.wait(1)
    end

    FlingLoopRunning = false
end

-- ============================================================
-- FUNGSI ESP (BARU, LEBIH ROBUST)
-- ============================================================
-- Helper: cek apakah objek termasuk tipe yang dipilih
local function isMurderObject(obj)
    local child = obj:FindFirstChild("Footsteps") or obj:FindFirstChild("Sleight") or obj:FindFirstChild("Decoy") or obj:FindFirstChild("Ghost") or obj:FindFirstChild("Fake Gun") or obj:FindFirstChild("Xray") or obj:FindFirstChild("Haste") or obj:FindFirstChild("Trap") or obj:FindFirstChild("Sprint") or obj:FindFirstChild("Ninja")
    return child and child:IsA("Folder")
end

local function isSheriffObject(obj)
    if obj.Name == "Gun" and obj:IsA("Tool") then return true end
    return false
end

local function isPlayerObject(obj)
    if obj:IsA("Model") and obj:FindFirstChild("Head") and obj.Name ~= lp.Name then
        if not isMurderObject(obj) and not isSheriffObject(obj) then
            return true
        end
    end
    return false
end

local function isGunObject(obj)
    if obj.Name == "GunDrop" and obj:IsA("BasePart") then return true end
    return false
end

local function contains(tbl, val)
    for _, v in ipairs(tbl) do
        if v == val then return true end
    end
    return false
end

local function passesESPFilter(obj)
    if not selectedESPTypes or #selectedESPTypes == 0 then return false end
    if contains(selectedESPTypes, "Murderer") and isMurderObject(obj) then return true end
    if contains(selectedESPTypes, "Sheriff") and isSheriffObject(obj) then return true end
    if contains(selectedESPTypes, "Players") and isPlayerObject(obj) then return true end
    if contains(selectedESPTypes, "Gun") and isGunObject(obj) then return true end
    return false
end

local function getESPColor(obj)
    if isPlayerObject(obj) then return Color3.fromRGB(0, 255, 0) end
    if isSheriffObject(obj) then return Color3.fromRGB(0, 0, 255) end
    if isMurderObject(obj) then return Color3.fromRGB(255, 0, 0) end
    if isGunObject(obj) then return Color3.fromRGB(0, 0, 255) end
    return Color3.fromRGB(0, 255, 0)
end

local function getRootPart(obj)
    if obj:IsA("BasePart") then return obj end
    if obj:IsA("Model") then
        if obj.PrimaryPart then return obj.PrimaryPart end
        local r = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Head") or obj:FindFirstChild("VisibleParts")
        if r and r:IsA("BasePart") then return r end
        return obj:FindFirstChildWhichIsA("BasePart", true)
    end
    return nil
end

-- ESP Loop utama (berjalan terus, update setiap 0.5 detik)
local function ESPLoop()
    if espLoopRunning then return end
    espLoopRunning = true

    task.spawn(function()
        while ESPEnabled do
            -- Kumpulkan semua objek yang memenuhi filter
            local validObjects = {}
            for _, obj in ipairs(workspace:GetChildren()) do
                if obj ~= lp.Character and passesESPFilter(obj) then
                    table.insert(validObjects, obj)
                end
            end

            -- Hapus ESP untuk objek yang sudah tidak valid
            for obj, _ in pairs(espHighlights) do
                if not table.find(validObjects, obj) then
                    if espHighlights[obj] then espHighlights[obj]:Destroy() end
                    espHighlights[obj] = nil
                    if espBillboards[obj] then espBillboards[obj]:Destroy() end
                    espBillboards[obj] = nil
                    if espBoxes[obj] then
                        for _, line in pairs(espBoxes[obj]) do line:Remove() end
                        espBoxes[obj] = nil
                    end
                    if espTracers[obj] then espTracers[obj]:Remove() end
                    espTracers[obj] = nil
                end
            end

            -- Buat atau update ESP untuk setiap objek valid
            for _, obj in ipairs(validObjects) do
                local color = getESPColor(obj)
                local rootPart = getRootPart(obj)
                if not rootPart then continue end

                -- Highlight
                if ESPHighlightEnabled then
                    if not espHighlights[obj] then
                        local h = Instance.new("Highlight")
                        h.Adornee = obj
                        h.FillTransparency = 0.5
                        h.OutlineTransparency = 0
                        h.FillColor = color
                        h.OutlineColor = Color3.new(1, 1, 1)
                        h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        h.Parent = obj
                        espHighlights[obj] = h
                    else
                        espHighlights[obj].FillColor = color
                        espHighlights[obj].Enabled = true
                    end
                else
                    if espHighlights[obj] then
                        espHighlights[obj]:Destroy()
                        espHighlights[obj] = nil
                    end
                end

                -- Billboard (Nama + Jarak)
                if ESPNamesEnabled or ESPDistanceEnabled then
                    if not espBillboards[obj] then
                        local b = Instance.new("BillboardGui")
                        b.Size = UDim2.new(0, 200, 0, 50)
                        b.Adornee = rootPart
                        b.AlwaysOnTop = true
                        b.MaxDistance = 5000
                        b.Parent = obj
                        local l = Instance.new("TextLabel")
                        l.Name = "Label"
                        l.Parent = b
                        l.BackgroundTransparency = 1
                        l.Size = UDim2.new(1, 0, 1, 0)
                        l.Font = Enum.Font.SourceSansBold
                        l.TextSize = 14
                        l.TextStrokeTransparency = 0
                        espBillboards[obj] = b
                    end
                    local label = espBillboards[obj]:FindFirstChild("Label")
                    if label then
                        local dist = (Camera.CFrame.Position - rootPart.Position).Magnitude
                        local text = ""
                        if ESPNamesEnabled then
                            text = obj.Name
                        end
                        if ESPDistanceEnabled then
                            if text ~= "" then text = text .. " " end
                            text = text .. string.format("%.0fm", dist)
                        end
                        label.Text = text
                        label.TextColor3 = color
                        espBillboards[obj].Enabled = true
                    end
                else
                    if espBillboards[obj] then
                        espBillboards[obj]:Destroy()
                        espBillboards[obj] = nil
                    end
                end

                -- Tracers (garis ke objek)
                if ESPTracersEnabled then
                    if not espTracers[obj] then
                        local L = Drawing.new("Line")
                        L.Thickness = 1
                        L.Transparency = 1
                        espTracers[obj] = L
                    end
                    local screenPos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
                    if onScreen and screenPos.Z > 0 then
                        espTracers[obj].Visible = true
                        espTracers[obj].Color = color
                        espTracers[obj].From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                        espTracers[obj].To = Vector2.new(screenPos.X, screenPos.Y)
                    else
                        espTracers[obj].Visible = false
                    end
                else
                    if espTracers[obj] then
                        espTracers[obj]:Remove()
                        espTracers[obj] = nil
                    end
                end

                -- Boxes (kotak di sekitar objek)
                if ESPBoxesEnabled then
                    if not espBoxes[obj] then
                        espBoxes[obj] = {
                            tl = Drawing.new("Line"),
                            tr = Drawing.new("Line"),
                            bl = Drawing.new("Line"),
                            br = Drawing.new("Line")
                        }
                        for _, line in pairs(espBoxes[obj]) do
                            line.Thickness = 1
                            line.Transparency = 1
                        end
                    end
                    local screenPos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
                    if onScreen and screenPos.Z > 0 then
                        local size = (1 / screenPos.Z) * 1000
                        local w, h = size * 0.6, size
                        local x, y = screenPos.X, screenPos.Y
                        local box = espBoxes[obj]
                        box.tl.From = Vector2.new(x-w, y-h); box.tl.To = Vector2.new(x+w, y-h)
                        box.tr.From = Vector2.new(x+w, y-h); box.tr.To = Vector2.new(x+w, y+h)
                        box.br.From = Vector2.new(x+w, y+h); box.br.To = Vector2.new(x-w, y+h)
                        box.bl.From = Vector2.new(x-w, y+h); box.bl.To = Vector2.new(x-w, y-h)
                        for _, line in pairs(box) do
                            line.Visible = true
                            line.Color = color
                        end
                    else
                        for _, line in pairs(espBoxes[obj]) do
                            line.Visible = false
                        end
                    end
                else
                    if espBoxes[obj] then
                        for _, line in pairs(espBoxes[obj]) do line:Remove() end
                        espBoxes[obj] = nil
                    end
                end
            end

            task.wait(0.5)
        end
        espLoopRunning = false
    end)
end

-- Fungsi untuk memulai/menghentikan ESP
local function ToggleESP(state)
    ESPEnabled = state
    if state then
        ESPLoop()
        Notify("ESP", "Enabled", 2)
    else
        -- Hapus semua ESP
        for obj, _ in pairs(espHighlights) do
            if espHighlights[obj] then espHighlights[obj]:Destroy() end
            if espBillboards[obj] then espBillboards[obj]:Destroy() end
            if espBoxes[obj] then
                for _, line in pairs(espBoxes[obj]) do line:Remove() end
            end
            if espTracers[obj] then espTracers[obj]:Remove() end
        end
        espHighlights = {}
        espBillboards = {}
        espBoxes = {}
        espTracers = {}
        espLoopRunning = false
        Notify("ESP", "Disabled", 2)
    end
end

-- Fungsi untuk update dropdown ESP Types
local function UpdateESPTypes(types)
    selectedESPTypes = types
    Notify("ESP Types", "Updated: " .. table.concat(types, ", "), 2)
end

-- ============================================================
-- MEMBUAT WINDOW BEARLIB (ANONYMOUS9x VIP | MM2)
-- ============================================================
local Window = bearlib:MakeWindow({
    Name = "Anonymous9x VIP",
    SubTitle = "For Murder Mystery 2",
    SaveFolder = "MM2_Config.json"  -- tetap ada meski config tab dihapus, tidak masalah
})

-- ============================================================
-- TAB
-- ============================================================
local MainTab   = Window:MakeTab({ Title = "Main",   Icon = "rbxassetid://10734971339" })
local EspTab    = Window:MakeTab({ Title = "ESP",    Icon = "rbxassetid://10723346959" })
local PlayerTab = Window:MakeTab({ Title = "Player", Icon = "rbxassetid://10734975692" })
local MiscTab   = Window:MakeTab({ Title = "Misc",   Icon = "rbxassetid://10734950309" })

-- ============================================================
-- MAIN TAB - MURDERER SECTION
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
-- MAIN TAB - SHERIFF SECTION
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
-- MAIN TAB - INNOCENT SECTION
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
-- MAIN TAB - FARMING SECTION
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
-- MAIN TAB - FLING SYSTEM (TAMBAHAN)
-- ============================================================
MainTab:AddSection("Fling System")

-- Dropdown pilih target player (update saat player join/leave)
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

-- Toggle Fling Target (fling satu kali atau berulang jika loop aktif)
MainTab:AddToggle({
    Name = "Fling Selected Target",
    Default = false,
    Flag = "MM2_FlingTargetToggle",
    Callback = function(state)
        FlingTargetToggle = state
        if state then
            if FlingTargetPlayer then
                if FlingLoopToggle then
                    task.spawn(FlingTargetLoop)
                else
                    FlingTargetPlayerFunction(FlingTargetPlayer)
                    Notify("Fling Target", "Flinged " .. FlingTargetPlayer.Name, 2)
                end
            else
                Notify("Fling Target", "Pilih target terlebih dahulu", 2)
                FlingTargetToggle = false
            end
        else
            Notify("Fling Target", "Disabled", 2)
        end
    end
})

-- Toggle Loop Fling (fling terus menerus)
MainTab:AddToggle({
    Name = "Loop Fling",
    Default = false,
    Flag = "MM2_LoopFling",
    Callback = function(state)
        FlingLoopToggle = state
        if state then
            Notify("Loop Fling", "Enabled - akan fling terus sampai dimatikan", 2)
            if FlingTargetToggle and FlingTargetPlayer then
                task.spawn(FlingTargetLoop)
            end
        else
            FlingLoopRunning = false
            Notify("Loop Fling", "Disabled", 2)
        end
    end
})

-- Button Fling All (fling semua player)
MainTab:AddButton({
    Name = "Fling All Players",
    Callback = function()
        if FlingLoopToggle then
            if FlingAllRunning then
                Notify("Fling All", "Already running", 2)
                return
            end
            FlingAllToggle = true
            task.spawn(FlingAllPlayers)
            Notify("Fling All", "Started (loop mode)", 2)
        else
            FlingAllToggle = true
            task.spawn(FlingAllPlayers)
        end
    end
})

-- Button Stop All Fling
MainTab:AddButton({
    Name = "Stop All Fling",
    Callback = function()
        FlingTargetToggle = false
        FlingLoopToggle = false
        FlingAllToggle = false
        FlingAllRunning = false
        FlingLoopRunning = false
        Notify("Fling", "All fling stopped", 2)
    end
})

-- ============================================================
-- ESP TAB
-- ============================================================
EspTab:AddSection("ESP Types")

EspTab:AddDropdown({
    Name = "ESP Objects",
    Options = {"Murderer", "Sheriff", "Players", "Gun"},
    Default = {},
    Multi = true,
    Flag = "MM2_ESP_Types",
    Callback = function(opt)
        UpdateESPTypes(opt)
    end
})

EspTab:AddSection("ESP Options")

EspTab:AddToggle({
    Name = "Enable ESP",
    Default = false,
    Flag = "MM2_ESP_Enable",
    Callback = function(state)
        ToggleESP(state)
    end
})

EspTab:AddToggle({
    Name = "Highlight Objects",
    Default = false,
    Flag = "MM2_ESP_Highlight",
    Callback = function(state)
        ESPHighlightEnabled = state
        Notify("ESP Highlight", state and "Enabled" or "Disabled", 2)
    end
})

EspTab:AddToggle({
    Name = "Show Names",
    Default = false,
    Flag = "MM2_ESP_Names",
    Callback = function(state)
        ESPNamesEnabled = state
        Notify("ESP Names", state and "Enabled" or "Disabled", 2)
    end
})

EspTab:AddToggle({
    Name = "Show Distance (Studs)",
    Default = false,
    Flag = "MM2_ESP_Distance",
    Callback = function(state)
        ESPDistanceEnabled = state
        Notify("ESP Distance", state and "Enabled" or "Disabled", 2)
    end
})

EspTab:AddToggle({
    Name = "Show Tracers",
    Default = false,
    Flag = "MM2_ESP_Tracers",
    Callback = function(state)
        ESPTracersEnabled = state
        Notify("ESP Tracers", state and "Enabled" or "Disabled", 2)
    end
})

EspTab:AddToggle({
    Name = "Show Boxes",
    Default = false,
    Flag = "MM2_ESP_Boxes",
    Callback = function(state)
        ESPBoxesEnabled = state
        Notify("ESP Boxes", state and "Enabled" or "Disabled", 2)
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

-- Anti Admin Loop (tetap berjalan)
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
