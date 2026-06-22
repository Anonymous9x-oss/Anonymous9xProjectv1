-- ============================================================
-- KONFIGURASI
-- ============================================================
local ANOLIB_RAW_URL = "https://raw.githubusercontent.com/Anonymous9x-oss/Anonymous9xProjectv1/refs/heads/main/anolib.lua"
local REQUIRED_PLACE_ID = 142823291  -- Place ID Murder Mystery 2 (atau sesuaikan)

-- ============================================================
-- LOAD BEARLIB
-- ============================================================
local bearlib = loadstring(game:HttpGet(ANOLIB_RAW_URL))()
if not bearlib then
    error("Gagal memuat bearlib dari raw URL")
end

-- ============================================================
-- CEK GAME (OPSIONAL, BISA DISESUAIKAN)
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

local blacklist = { [1848960] = true }
local discordLink = "https://discord.gg/ptvyFfK3pU"

if blacklist[lp.UserId] then
    lp:Kick("Exploiting")
    return
end

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
local selectedESPTypes = {}
local ESPHighlight = false
local ESPTracers = false
local ESPNames = false
local ESPBoxes = false
local ESPStuds = false
local esp = {}
local tracers = {}
local boxes = {}
local names = {}
local studs = {}
local DrawingAvailable = (type(Drawing) == "table" or type(Drawing) == "userdata")

-- ============================================================
-- FUNGSI-FUNGSI DARI AZURE HUB
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
-- FUNGSI ESP (DARI AZURE HUB)
-- ============================================================
local function contains(tbl, val)
    if not tbl or type(tbl) ~= "table" then return false end
    for _, v in ipairs(tbl) do
        if v == val then return true end
    end
    return false
end

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

local function passesDropdownFilter(obj)
    if not selectedESPTypes or #selectedESPTypes == 0 then return false end
    if contains(selectedESPTypes, "Murderer") and isMurderObject(obj) then return true end
    if contains(selectedESPTypes, "Sheriff") and isSheriffObject(obj) then return true end
    if contains(selectedESPTypes, "Players") and isPlayerObject(obj) then return true end
    if contains(selectedESPTypes, "Gun") and isGunObject(obj) then return true end
    return false
end

local function getObjColor(obj)
    if isPlayerObject(obj) then return Color3.fromRGB(0, 255, 0) end
    if isSheriffObject(obj) then return Color3.fromRGB(0, 0, 255) end
    if isMurderObject(obj) then return Color3.fromRGB(255, 0, 0) end
    if isGunObject(obj) then return Color3.fromRGB(0, 0, 255) end
    return Color3.fromRGB(0, 255, 0)
end

local function getRootPosition(target)
    if target:IsA("BasePart") then return target.Position end
    if target:IsA("Model") then
        if target.PrimaryPart then return target.PrimaryPart.Position end
        local root = target:FindFirstChild("HumanoidRootPart") or target:FindFirstChild("VisibleParts")
        if root and root:IsA("BasePart") then return root.Position end
        return target:GetPivot().Position
    end
    return Vector3.new(0, 0, 0)
end

local function ensureHighlight(obj)
    if not ESPHighlight then
        if esp[obj] and esp[obj].highlight then
            esp[obj].highlight:Destroy()
            esp[obj].highlight = nil
        end
        return
    end
    if not esp[obj].highlight then
        local h = Instance.new("Highlight")
        h.Adornee = obj
        h.FillTransparency = 0.5
        h.OutlineTransparency = 0
        h.FillColor = getObjColor(obj)
        h.OutlineColor = Color3.new(1, 1, 1)
        h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        h.Parent = obj
        esp[obj].highlight = h
    end
end

local function ensureBillboard(obj)
    if not (ESPNames or ESPStuds) then
        if esp[obj].billboard then
            esp[obj].billboard:Destroy()
            esp[obj].billboard = nil
        end
        return
    end
    if not esp[obj].billboard then
        local head = obj:FindFirstChild("Head") or obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChildWhichIsA("BasePart")
        if not head then return end
        local b = Instance.new("BillboardGui")
        b.Name = "roblox"
        b.Size = UDim2.new(0, 200, 0, 50)
        b.Adornee = head
        b.AlwaysOnTop = true
        b.MaxDistance = 5000
        b.Parent = obj
        local n = Instance.new("TextLabel")
        n.Name = "MainLabel"
        n.Parent = b
        n.BackgroundTransparency = 1
        n.Size = UDim2.new(1, 0, 1, 0)
        n.Text = ""
        n.Font = Enum.Font.SourceSansBold
        n.TextSize = 14
        n.TextStrokeTransparency = 0
        n.RichText = true
        esp[obj].billboard = b
        esp[obj].nameLabel = n
        esp[obj].studsLabel = nil
    end
end

local function ensureTracer(obj)
    if not ESPTracers then
        if tracers[obj] then tracers[obj]:Remove() tracers[obj] = nil end
        return
    end
    if not tracers[obj] then
        local L = Drawing.new("Line")
        L.Thickness = 1
        L.Transparency = 1
        tracers[obj] = L
    end
end

local function ensureBox(obj)
    if not ESPBoxes then
        if boxes[obj] then
            for _, l in pairs(boxes[obj]) do l:Remove() end
            boxes[obj] = nil
        end
        return
    end
    if not boxes[obj] then
        boxes[obj] = {
            tl = Drawing.new("Line"),
            tr = Drawing.new("Line"),
            bl = Drawing.new("Line"),
            br = Drawing.new("Line")
        }
        for _, line in pairs(boxes[obj]) do
            line.Thickness = 1
            line.Transparency = 1
        end
    end
end

local function ensureAllFor(obj)
    if not esp[obj] then esp[obj] = {} end
    ensureHighlight(obj)
    ensureBillboard(obj)
    ensureTracer(obj)
    ensureBox(obj)
end

local function removeESP(obj)
    local d = esp[obj]
    if d then
        if d.highlight then pcall(function() d.highlight:Destroy() end) end
        if d.billboard then pcall(function() d.billboard:Destroy() end) end
        esp[obj] = nil
    end
    if tracers[obj] then pcall(function() tracers[obj]:Remove() end) tracers[obj] = nil end
    if boxes[obj] then
        for _, l in pairs(boxes[obj]) do pcall(function() l:Remove() end) end
        boxes[obj] = nil
    end
end

-- ESP Loop
local lR, rI = 0, 1.5
RunService.Heartbeat:Connect(function()
    local now = tick()
    if now - lR > rI then
        lR = now
        for _, obj in ipairs(workspace:GetChildren()) do
            if obj ~= lp.Character and passesDropdownFilter(obj) then
                ensureAllFor(obj)
            end
        end
        local dropgun = workspace:FindFirstChild("GunDrop", true)
        if dropgun and passesDropdownFilter(dropgun) then
            ensureAllFor(dropgun)
        end
    end

    local viewportSize = Camera.ViewportSize
    local myRoot = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")

    for obj, data in pairs(esp) do
        local color = getObjColor(obj)
        if not obj or not obj.Parent or not passesDropdownFilter(obj) then
            removeESP(obj)
            continue
        end

        if obj:IsA("Model") and obj:FindFirstChild("Head") then
            local p = Players:GetPlayerFromCharacter(obj)
            if p then
                local b = p:FindFirstChild("Backpack")
                if obj:FindFirstChild("Gun") or (b and b:FindFirstChild("Gun")) then
                    color = Color3.fromRGB(0, 0, 255)
                end
            end
        end

        local worldPos = getRootPosition(obj)
        local screenPos, onScreen = Camera:WorldToViewportPoint(worldPos)
        local isVisible = onScreen and screenPos.Z > 0

        if tracers[obj] then
            tracers[obj].Visible = isVisible and ESPTracers
            if tracers[obj].Visible then
                tracers[obj].Color = color
                tracers[obj].From = Vector2.new(viewportSize.X / 2, viewportSize.Y)
                tracers[obj].To = Vector2.new(screenPos.X, screenPos.Y)
            end
        end

        if data.billboard then
            data.billboard.Enabled = isVisible and (ESPNames or ESPStuds)
            if data.billboard.Enabled and myRoot then
                local targetLabel = data.nameLabel or data.billboard:FindFirstChildOfClass("TextLabel")
                if targetLabel then
                    targetLabel.Visible = true
                    local dist = (Camera.CFrame.Position - worldPos).Magnitude
                    if ESPNames and ESPStuds then
                        targetLabel.Text = obj.Name .. " (" .. string.format("%.0fm", dist) .. ")"
                    elseif ESPNames then
                        targetLabel.Text = obj.Name
                    elseif ESPStuds then
                        targetLabel.Text = string.format("%.0fm", dist)
                    end
                    targetLabel.TextColor3 = color
                end
            end
        end

        if boxes[obj] then
            local box = boxes[obj]
            local showBox = isVisible and ESPBoxes
            for _, line in pairs(box) do line.Visible = showBox; line.Color = color end
            if showBox then
                local size = (1 / screenPos.Z) * 1000
                local w, h = size * 0.6, size
                local x, y = screenPos.X, screenPos.Y
                box.tl.From = Vector2.new(x-w, y-h); box.tl.To = Vector2.new(x+w, y-h)
                box.tr.From = Vector2.new(x+w, y-h); box.tr.To = Vector2.new(x+w, y+h)
                box.br.From = Vector2.new(x+w, y+h); box.br.To = Vector2.new(x-w, y+h)
                box.bl.From = Vector2.new(x-w, y+h); box.bl.To = Vector2.new(x-w, y-h)
            end
        end

        if data.highlight then data.highlight.FillColor = color end
    end
end)

Workspace.ChildAdded:Connect(function(child)
    task.wait(0.5)
    if passesDropdownFilter(child) then ensureAllFor(child) end
end)

Workspace.ChildRemoved:Connect(function(child) removeESP(child) end)

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
-- MEMBUAT WINDOW BEARLIB (ANONYMOUS9x VIP | MM2)
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
local ConfigTab = Window:MakeTab({ Title = "Config", Icon = "rbxassetid://10734949073" })

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
        if state then loopkillaura() end
        Notify("Kill Aura", state and "Enabled" or "Disabled", 2)
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
    end
})

MainTab:AddToggle({
    Name = "Kill Everyone",
    Default = false,
    Flag = "MM2_KillAll",
    Callback = function(state)
        AutoKillToggle = state
        if state then killplayers() end
        Notify("Kill Everyone", state and "Enabled" or "Disabled", 2)
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
        if state then autoshoot() end
        Notify("Auto Shoot", state and "Enabled" or "Disabled", 2)
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
        if state then autograb() end
        Notify("Auto Grab", state and "Enabled" or "Disabled", 2)
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
        else
            NoclipToggle = false
            clip()
        end
        Notify("Auto Farm", state and "Enabled" or "Disabled", 2)
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
        selectedESPTypes = opt
    end
})

EspTab:AddSection("ESP Options")

EspTab:AddToggle({
    Name = "Highlight Objects",
    Default = false,
    Flag = "MM2_ESP_Highlight",
    Callback = function(state)
        ESPHighlight = state
    end
})

EspTab:AddToggle({
    Name = "Show Tracers",
    Default = false,
    Flag = "MM2_ESP_Tracers",
    Callback = function(state)
        ESPTracers = state
    end
})

EspTab:AddToggle({
    Name = "Show Boxes",
    Default = false,
    Flag = "MM2_ESP_Boxes",
    Callback = function(state)
        ESPBoxes = state
    end
})

EspTab:AddToggle({
    Name = "Show Names",
    Default = false,
    Flag = "MM2_ESP_Names",
    Callback = function(state)
        ESPNames = state
    end
})

EspTab:AddToggle({
    Name = "Show Studs (Distance)",
    Default = false,
    Flag = "MM2_ESP_Studs",
    Callback = function(state)
        ESPStuds = state
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
        else
            clip()
        end
        Notify("Noclip", state and "Enabled" or "Disabled", 2)
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
        else
            if idConn then idConn:Disconnect() end
        end
        Notify("Protect Identity", state and "Enabled" or "Disabled", 2)
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
        if state then fling() end
        Notify("Fling", state and "Enabled" or "Disabled", 2)
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

-- Anti Admin Loop
local antiAdminToggle = false
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
-- CONFIG TAB
-- ============================================================
ConfigTab:AddSection("Configuration")

local configName = "MM2_Config"
ConfigTab:AddTextbox({
    Name = "Config Name",
    Placeholder = "Config Name",
    Default = configName,
    Callback = function(value)
        configName = value
        Notify("Config", "Name set to: " .. value, 2)
    end
})

ConfigTab:AddButton({
    Name = "Save Config",
    Callback = function()
        Notify("Config", "Saved automatically by bearlib", 2)
    end
})

ConfigTab:AddButton({
    Name = "Load Config",
    Callback = function()
        Notify("Config", "Loaded from bearlib storage", 2)
    end
})

-- ============================================================
-- INISIALISASI
-- ============================================================
_initializing = false
Notify("Anonymous9x VIP", "Loaded for Murder Mystery 2! All features ready.", 4)
print("Anonymous9x VIP | Murder Mystery 2 loaded.")
