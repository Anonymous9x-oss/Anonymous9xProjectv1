--[[
    ╔═══════════════════════════════════════════════════════════════╗
    ║      Anonymous9x AutoTP Universal V1.0 FINAL                ║
    ║                                                               ║
    ║        Simple Teleport Recorder + Playback                   ║
    ║     Simpan lokasi (CFrame) dengan sekali tekan               ║
    ║     Kode base64 sangat pendek (hanya koordinat)              ║
    ║     Fitur: Play, Loop, Speed, File Manager + Copy/Paste      ║
    ║     Tema: Hitam-putih, border putih, drag, minimize          ║
    ╚═══════════════════════════════════════════════════════════════╝
]]

print("═════════════════════════════════════════════════════════")
print("Anonymous9x AutoTP V1.0 - Initializing...")
print("═════════════════════════════════════════════════════════")

-- Anti-duplicate
if _G.Anonymous9xTP then
    warn("[AutoTP] Already loaded! Cleaning up...")
    if _G.Anonymous9xTP_GUI then pcall(function() _G.Anonymous9xTP_GUI:Destroy() end) end
    if _G.Anonymous9xTP_Loader then pcall(function() _G.Anonymous9xTP_Loader:Destroy() end) end
    if _G.Anonymous9xTP_FileManager then pcall(function() _G.Anonymous9xTP_FileManager:Destroy() end) end
end
_G.Anonymous9xTP = true

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local Debris = game:GetService("Debris")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- Executor detection
local Capabilities = {
    writefile = writefile ~= nil,
    readfile = readfile ~= nil and isfile ~= nil,
    clipboard = setclipboard ~= nil,
    name = "Unknown"
}

if identifyexecutor then
    Capabilities.name = identifyexecutor() or "Unknown"
elseif DELTA_LOADED then
    Capabilities.name = "Delta"
elseif syn then
    Capabilities.name = "Synapse"
elseif KRNL_LOADED then
    Capabilities.name = "KRNL"
end

print(string.format("[AutoTP] Executor: %s", Capabilities.name))
print(string.format("[AutoTP] writefile: %s", tostring(Capabilities.writefile)))
print(string.format("[AutoTP] readfile: %s", tostring(Capabilities.readfile)))
print(string.format("[AutoTP] clipboard: %s", tostring(Capabilities.clipboard)))

-- Helper functions
local function notify(title, text, duration)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = duration or 3
        })
    end)
end

local function formatTime(seconds)
    return string.format("%02d:%02d", math.floor(seconds / 60), math.floor(seconds % 60))
end

local function createTween(instance, props, dur, style, dir)
    local tween = TweenService:Create(
        instance,
        TweenInfo.new(dur or 0.3, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out),
        props
    )
    tween:Play()
    return tween
end

-- Map functions
local function getMapId()
    return tostring(game.PlaceId)
end

local function getGameName()
    local s, n = pcall(function()
        return game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
    end)
    return s and n or ("Game " .. game.PlaceId)
end

-- ═══════════════════════════════════════════════════════════════
-- DATA STRUCTURE (simple, hanya CFrame)
-- ═══════════════════════════════════════════════════════════════

local SAVE_FILE = "Anonymous9x_TP_V1.json"

-- State global
_G.AutoTP = {
    recordings = {},  -- name -> { locations = {CFrame,...}, mapId, timestamp, count }
    currentLocations = {},  -- array CFrame sementara
    currentName = nil,
    lastLoadedName = nil,
    lastLoadedMap = nil,

    recording = false,  -- apakah sedang dalam mode "merekam"? (menambah lokasi)
    playbackState = "IDLE",  -- IDLE, PLAYING, LOOPING, PAUSED, LOOP_PAUSED
    playbackData = nil,
    playbackIndex = 1,
    playbackConnection = nil,
    playbackTimer = nil,

    settings = {
        speed = 1,  -- delay antar teleport (detik)
        teleportThreshold = 15,  -- jika jarak > threshold, langsung teleport, else move?
        walkSpeed = 16
    }
}

-- Load saved data
local function loadData()
    if not Capabilities.readfile or not isfile(SAVE_FILE) then return end
    local s, d = pcall(function()
        return HttpService:JSONDecode(readfile(SAVE_FILE))
    end)
    if s and d then
        _G.AutoTP.recordings = d.recordings or {}
        _G.AutoTP.lastLoadedName = d.lastLoadedName
        _G.AutoTP.lastLoadedMap = d.lastLoadedMap
        print(string.format("[AutoTP] Loaded %d recordings", d.recordings and #d.recordings or 0))
    end
end
loadData()

local function saveData()
    if not Capabilities.writefile then return false end
    local data = {
        recordings = _G.AutoTP.recordings,
        lastLoadedName = _G.AutoTP.lastLoadedName,
        lastLoadedMap = _G.AutoTP.lastLoadedMap,
        version = "1.0"
    }
    local s, e = pcall(function()
        writefile(SAVE_FILE, HttpService:JSONEncode(data))
    end)
    if s then print("[AutoTP] Saved to file") end
    return s
end

-- Character references
local Character, Humanoid, HRP
local function getCharacter()
    Character = Player.Character or Player.CharacterAdded:Wait()
    Humanoid = Character:WaitForChild("Humanoid")
    HRP = Character:WaitForChild("HumanoidRootPart")
    return Character, Humanoid, HRP
end
getCharacter()
Player.CharacterAdded:Connect(getCharacter)

-- ═══════════════════════════════════════════════════════════════
-- CORE FUNCTIONS
-- ═══════════════════════════════════════════════════════════════

-- Get current location (CFrame)
local function getCurrentCFrame()
    if HRP then return HRP.CFrame end
    return nil
end

-- Mulai recording baru (hapus yang lama)
local function startNewRecording()
    _G.AutoTP.currentLocations = {}
    _G.AutoTP.recording = true
    _G.AutoTP.currentMapId = getMapId()
    notify("AutoTP", "Recording started. Press GET LOCATION at each point.", 3)
    print("[AutoTP] New recording started")
end

-- Tambah lokasi saat ini
local function addLocation()
    if not _G.AutoTP.recording then
        notify("AutoTP", "Not recording. Press NEW first.", 2)
        return
    end
    local cf = getCurrentCFrame()
    if not cf then
        notify("Error", "No character", 2)
        return
    end
    table.insert(_G.AutoTP.currentLocations, cf)
    local count = #_G.AutoTP.currentLocations
    notify("AutoTP", string.format("📍 Location %d saved", count), 1.5)
    print(string.format("[AutoTP] Added location %d: %s", count, tostring(cf.Position)))
end

-- Hapus lokasi terakhir (undo)
local function undoLastLocation()
    if #_G.AutoTP.currentLocations == 0 then
        notify("AutoTP", "No locations to undo", 2)
        return
    end
    table.remove(_G.AutoTP.currentLocations)
    local count = #_G.AutoTP.currentLocations
    notify("AutoTP", string.format("Undo. Now %d locations", count), 1.5)
    print(string.format("[AutoTP] Undo, now %d locations", count))
end

-- Stop recording (selesai)
local function stopRecording()
    _G.AutoTP.recording = false
    local count = #_G.AutoTP.currentLocations
    notify("AutoTP", string.format("Recording stopped. %d locations.", count), 2)
    print(string.format("[AutoTP] Recording stopped, %d locations", count))
end

-- Simpan rekaman ke file
local function saveRecording(name)
    if not name or name == "" then
        notify("AutoTP", "Enter name!", 2)
        return false
    end
    if #_G.AutoTP.currentLocations == 0 then
        notify("AutoTP", "No locations recorded!", 2)
        return false
    end

    _G.AutoTP.recordings[name] = {
        locations = _G.AutoTP.currentLocations,
        timestamp = os.time(),
        count = #_G.AutoTP.currentLocations,
        mapId = _G.AutoTP.currentMapId or getMapId(),
        gameName = getGameName()
    }
    _G.AutoTP.lastLoadedName = name
    _G.AutoTP.lastLoadedMap = _G.AutoTP.currentMapId or getMapId()
    _G.AutoTP.currentName = name

    saveData()
    notify("AutoTP", string.format("✓ '%s' saved (%d locs)", name, #_G.AutoTP.currentLocations), 3)
    print(string.format("[AutoTP] Saved '%s' (%d locations)", name, #_G.AutoTP.currentLocations))
    return true
end

-- Hapus rekaman
local function deleteRecording(name)
    if _G.AutoTP.recordings[name] then
        _G.AutoTP.recordings[name] = nil
        saveData()
        notify("AutoTP", string.format("'%s' deleted", name), 2)
        return true
    end
    return false
end

local function deleteAll()
    _G.AutoTP.recordings = {}
    saveData()
    notify("AutoTP", "All deleted!", 2)
end

local function countRecordings()
    local c = 0
    for _ in pairs(_G.AutoTP.recordings) do c = c + 1 end
    return c
end

-- ═══════════════════════════════════════════════════════════════
-- PLAYBACK ENGINE (sederhana, teleport berurutan)
-- ═══════════════════════════════════════════════════════════════

local function stopPlayback()
    if _G.AutoTP.playbackConnection then
        _G.AutoTP.playbackConnection:Disconnect()
        _G.AutoTP.playbackConnection = nil
    end
    if _G.AutoTP.playbackTimer then
        _G.AutoTP.playbackTimer:Disconnect()
        _G.AutoTP.playbackTimer = nil
    end
    _G.AutoTP.playbackState = "IDLE"
    _G.AutoTP.playbackIndex = 1
    print("[AutoTP] Playback stopped")
end

local function startPlayback(locations, isLoop)
    if not locations or #locations == 0 then
        notify("Error", "No locations to play", 2)
        return false
    end

    stopPlayback()

    _G.AutoTP.playbackState = isLoop and "LOOPING" or "PLAYING"
    _G.AutoTP.playbackData = locations
    _G.AutoTP.playbackIndex = 1

    local delay = _G.AutoTP.settings.speed

    local function teleportTo(index)
        if not HRP then
            stopPlayback()
            return
        end
        local cf = locations[index]
        if not cf then return end

        -- Teleport langsung (bisa juga dengan tween jika ingin smooth)
        HRP.CFrame = cf

        -- Efek kecil (opsional)
        if index == #locations and not isLoop then
            -- selesai
        end
    end

    local function nextStep()
        if not HRP then
            stopPlayback()
            return
        end
        if _G.AutoTP.playbackState == "PAUSED" or _G.AutoTP.playbackState == "LOOP_PAUSED" then
            return
        end

        if _G.AutoTP.playbackIndex > #_G.AutoTP.playbackData then
            if _G.AutoTP.playbackState == "LOOPING" then
                _G.AutoTP.playbackIndex = 1
            else
                stopPlayback()
                notify("AutoTP", "Playback finished", 2)
                return
            end
        end

        teleportTo(_G.AutoTP.playbackIndex)
        _G.AutoTP.playbackIndex = _G.AutoTP.playbackIndex + 1
    end

    -- Mulai timer
    nextStep()  -- langsung ke pertama
    _G.AutoTP.playbackConnection = RunService.Heartbeat:Connect(function()
        -- timer manual? lebih baik pakai task.wait di loop sendiri
    end)
    -- Kita pakai task.spawn loop dengan wait
    task.spawn(function()
        while _G.AutoTP.playbackState == "LOOPING" or _G.AutoTP.playbackState == "PLAYING" do
            if _G.AutoTP.playbackState == "PAUSED" or _G.AutoTP.playbackState == "LOOP_PAUSED" then
                task.wait(0.1)
            else
                task.wait(delay)
                if _G.AutoTP.playbackState == "PLAYING" or _G.AutoTP.playbackState == "LOOPING" then
                    if _G.AutoTP.playbackIndex > #_G.AutoTP.playbackData then
                        if _G.AutoTP.playbackState == "LOOPING" then
                            _G.AutoTP.playbackIndex = 1
                        else
                            break
                        end
                    end
                    teleportTo(_G.AutoTP.playbackIndex)
                    _G.AutoTP.playbackIndex = _G.AutoTP.playbackIndex + 1
                end
            end
        end
        stopPlayback()
    end)

    print(string.format("[AutoTP] Playback started, %d locations, delay %.2fs", #locations, delay))
    return true
end

-- Fungsi untuk play/pause/toggle
local function playRecording(locations, mapId)
    if not locations or #locations == 0 then
        notify("Error", "No recording loaded!", 3)
        return false
    end
    if mapId and mapId ~= getMapId() then
        notify("Map Error", "Wrong map! (Rec: " .. mapId .. ")", 4)
        return false
    end

    local state = _G.AutoTP.playbackState
    if state == "PLAYING" then
        _G.AutoTP.playbackState = "PAUSED"
        notify("Playback", "Paused", 2)
        return true
    elseif state == "PAUSED" then
        _G.AutoTP.playbackState = "PLAYING"
        notify("Playback", "Resumed", 2)
        return true
    elseif state == "LOOPING" then
        _G.AutoTP.playbackState = "LOOP_PAUSED"
        notify("Loop", "Paused", 2)
        return true
    elseif state == "LOOP_PAUSED" then
        _G.AutoTP.playbackState = "LOOPING"
        notify("Loop", "Resumed", 2)
        return true
    else
        return startPlayback(locations, false)
    end
end

local function loopRecording(locations, mapId)
    if not locations or #locations == 0 then
        notify("Error", "No recording loaded!", 3)
        return false
    end
    if mapId and mapId ~= getMapId() then
        notify("Map Error", "Wrong map!", 4)
        return false
    end

    local state = _G.AutoTP.playbackState
    if state == "LOOPING" then
        _G.AutoTP.playbackState = "LOOP_PAUSED"
        notify("Loop", "Paused", 2)
        return true
    elseif state == "LOOP_PAUSED" then
        _G.AutoTP.playbackState = "LOOPING"
        notify("Loop", "Resumed", 2)
        return true
    elseif state == "PLAYING" then
        _G.AutoTP.playbackState = "PAUSED"
        notify("Playback", "Paused", 2)
        return true
    elseif state == "PAUSED" then
        _G.AutoTP.playbackState = "PLAYING"
        notify("Playback", "Resumed", 2)
        return true
    else
        return startPlayback(locations, true)
    end
end

-- ═══════════════════════════════════════════════════════════════
-- CODE GENERATION (Base64-like, sederhana)
-- ═══════════════════════════════════════════════════════════════

local function compressLocations(locs)
    local t = {}
    for _, cf in ipairs(locs) do
        local x, y, z = cf.Position.X, cf.Position.Y, cf.Position.Z
        -- Kita simpan juga rotasi? opsional, untuk sederhana hanya posisi
        -- Tapi untuk akurasi, simpan sebagai CFrame (pos + rot) via matrix?
        -- Kita simpan sebagai {px,py,pz, r00,r01,r02, r10,...} terlalu panjang.
        -- Alternatif: simpan posisi saja, saat playback set CFrame baru dengan rotasi default (lookAt?)
        -- Lebih baik simpan CFrame lengkap: px,py,pz, r00,r01,r02, r10,r11,r12, r20,r21,r22
        -- Tapi akan panjang. Untuk TP, posisi saja cukup, karena kita bisa set orientasi tetap.
        -- Saya pilih simpan posisi + arah hadap (lookVector?) atau rotasi sederhana.
        -- Untuk kemudahan, simpan {x,y,z, rx,ry,rz} dari ToEulerAnglesXYZ
        local rx, ry, rz = cf:ToEulerAnglesXYZ()
        table.insert(t, {
            x = math.floor(x*100)/100,
            y = math.floor(y*100)/100,
            z = math.floor(z*100)/100,
            rx = math.floor(rx*1000)/1000,
            ry = math.floor(ry*1000)/1000,
            rz = math.floor(rz*1000)/1000
        })
    end
    return t
end

local function decompressLocations(t)
    local locs = {}
    for _, v in ipairs(t) do
        local cf = CFrame.new(v.x, v.y, v.z) * CFrame.Angles(v.rx, v.ry, v.rz)
        table.insert(locs, cf)
    end
    return locs
end

local function generateCode(name, locs, mapId)
    local compressed = compressLocations(locs)
    local data = {
        n = name,
        m = mapId,
        d = compressed,
        v = "1.0"
    }
    local json = HttpService:JSONEncode(data)
    local code = "AUTOTP://" .. HttpService:JSONEncode({x = json})  -- bungkus lagi
    return code
end

local function parseCode(code)
    if not code or code == "" then return nil, "Empty code" end
    if not code:match("^AUTOTP://") then return nil, "Invalid format" end
    local base64 = code:gsub("^AUTOTP://", "")
    local success, res = pcall(function()
        local wrapper = HttpService:JSONDecode(base64)
        local data = HttpService:JSONDecode(wrapper.x)
        local locs = decompressLocations(data.d)
        return {
            name = data.n,
            mapId = data.m,
            locations = locs
        }
    end)
    if success then return res, nil else return nil, "Parse failed" end
end

-- ═══════════════════════════════════════════════════════════════
-- FILE MANAGER (copy-paste dari AutoWalk, disesuaikan)
-- ═══════════════════════════════════════════════════════════════

local function createFileManager(updateStatus, updatePlayBtn, updateLoopBtn)
    if _G.Anonymous9xTP_FileManager then
        pcall(function() _G.Anonymous9xTP_FileManager:Destroy() end)
    end

    print("[AutoTP] Opening file manager")

    local FM = Instance.new("ScreenGui")
    FM.Name = "Anonymous9xTP_FileManager"
    FM.ResetOnSpawn = false
    pcall(function() FM.Parent = CoreGui end)
    if not FM.Parent then FM.Parent = PlayerGui end
    _G.Anonymous9xTP_FileManager = FM

    local Blur = Instance.new("Frame", FM)
    Blur.Size = UDim2.new(1, 0, 1, 0)
    Blur.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Blur.BackgroundTransparency = 0.15
    Blur.BorderSizePixel = 0

    local Panel = Instance.new("Frame", FM)
    Panel.Size = UDim2.new(0, 300, 0, 360)
    Panel.Position = UDim2.new(0.5, -150, 0.5, -180)
    Panel.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    Panel.BorderSizePixel = 0
    Instance.new("UICorner", Panel).CornerRadius = UDim.new(0, 10)
    local stroke = Instance.new("UIStroke", Panel)
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Thickness = 2

    local TBar = Instance.new("Frame", Panel)
    TBar.Size = UDim2.new(1, 0, 0, 38)
    TBar.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
    TBar.BorderSizePixel = 0
    Instance.new("UICorner", TBar).CornerRadius = UDim.new(0, 10)

    local Title = Instance.new("TextLabel", TBar)
    Title.Size = UDim2.new(1, -45, 1, 0)
    Title.Position = UDim2.new(0, 10, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "📁 TP FILE MANAGER"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 14
    Title.TextXAlignment = Enum.TextXAlignment.Left

    local CloseBtn = Instance.new("TextButton", TBar)
    CloseBtn.Size = UDim2.new(0, 30, 0, 30)
    CloseBtn.Position = UDim2.new(1, -35, 0, 4)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
    CloseBtn.BorderSizePixel = 0
    CloseBtn.Text = "✕"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextSize = 14
    Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

    local Count = Instance.new("TextLabel", Panel)
    Count.Size = UDim2.new(1, -18, 0, 18)
    Count.Position = UDim2.new(0, 9, 0, 43)
    Count.BackgroundTransparency = 1
    Count.Text = string.format("Total: %d recordings", countRecordings())
    Count.TextColor3 = Color3.fromRGB(150, 150, 150)
    Count.Font = Enum.Font.Gotham
    Count.TextSize = 10
    Count.TextXAlignment = Enum.TextXAlignment.Left

    local Scroll = Instance.new("ScrollingFrame", Panel)
    Scroll.Size = UDim2.new(1, -18, 0, 170)
    Scroll.Position = UDim2.new(0, 9, 0, 68)
    Scroll.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
    Scroll.BorderSizePixel = 0
    Scroll.ScrollBarThickness = 4
    Scroll.ScrollBarImageColor3 = Color3.fromRGB(100,100,100)
    Scroll.CanvasSize = UDim2.new(0,0,0,0)
    Instance.new("UICorner", Scroll).CornerRadius = UDim.new(0,7)

    local List = Instance.new("UIListLayout", Scroll)
    List.SortOrder = Enum.SortOrder.LayoutOrder
    List.Padding = UDim.new(0,5)
    List:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Scroll.CanvasSize = UDim2.new(0,0,0, List.AbsoluteContentSize.Y + 8)
    end)

    local function createEntry(name, data)
        local Entry = Instance.new("Frame", Scroll)
        Entry.Size = UDim2.new(1, -6, 0, 58)
        Entry.BackgroundColor3 = Color3.fromRGB(25,25,25)
        Entry.BorderSizePixel = 0
        Instance.new("UICorner", Entry).CornerRadius = UDim.new(0,5)

        local NameLbl = Instance.new("TextLabel", Entry)
        NameLbl.Size = UDim2.new(1, -110, 0, 16)
        NameLbl.Position = UDim2.new(0,6,0,4)
        NameLbl.BackgroundTransparency = 1
        NameLbl.Text = "📍 " .. name
        NameLbl.TextColor3 = Color3.fromRGB(255,255,255)
        NameLbl.Font = Enum.Font.GothamBold
        NameLbl.TextSize = 11
        NameLbl.TextXAlignment = Enum.TextXAlignment.Left
        NameLbl.TextTruncate = Enum.TextTruncate.AtEnd

        local InfoLbl = Instance.new("TextLabel", Entry)
        InfoLbl.Size = UDim2.new(1, -110, 0, 12)
        InfoLbl.Position = UDim2.new(0,6,0,21)
        InfoLbl.BackgroundTransparency = 1
        InfoLbl.Text = string.format("%d locations", data.count)
        InfoLbl.TextColor3 = Color3.fromRGB(140,140,140)
        InfoLbl.Font = Enum.Font.Gotham
        InfoLbl.TextSize = 8
        InfoLbl.TextXAlignment = Enum.TextXAlignment.Left

        local function createBtn(text, x, y, color, callback)
            local btn = Instance.new("TextButton", Entry)
            btn.Size = UDim2.new(0,24,0,24)
            btn.Position = UDim2.new(1, x, 0, y)
            btn.BackgroundColor3 = color
            btn.BorderSizePixel = 0
            btn.Text = text
            btn.TextColor3 = Color3.fromRGB(255,255,255)
            btn.Font = Enum.Font.GothamBold
            btn.TextSize = 10
            btn.AutoButtonColor = false
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0,4)
            btn.MouseButton1Click:Connect(callback)
            return btn
        end

        -- Play
        createBtn("▶", -104, 3, Color3.fromRGB(50,200,100), function()
            _G.AutoTP.currentLocations = data.locations
            _G.AutoTP.currentName = name
            _G.AutoTP.currentMapId = data.mapId
            _G.AutoTP.lastLoadedName = name
            _G.AutoTP.lastLoadedMap = data.mapId
            saveData()
            playRecording(data.locations, data.mapId)
            updateStatus(string.format("▶ '%s'", name))
            updatePlayBtn()
            FM:Destroy()
            _G.Anonymous9xTP_FileManager = nil
        end)

        -- Loop
        createBtn("↻", -78, 3, Color3.fromRGB(100,150,255), function()
            _G.AutoTP.currentLocations = data.locations
            _G.AutoTP.currentName = name
            _G.AutoTP.currentMapId = data.mapId
            _G.AutoTP.lastLoadedName = name
            _G.AutoTP.lastLoadedMap = data.mapId
            saveData()
            loopRecording(data.locations, data.mapId)
            updateStatus(string.format("↻ '%s'", name))
            updateLoopBtn()
            FM:Destroy()
            _G.Anonymous9xTP_FileManager = nil
        end)

        -- Copy Code
        createBtn("📋", -52, 3, Color3.fromRGB(255,150,50), function()
            local code = generateCode(name, data.locations, data.mapId)
            if Capabilities.clipboard then
                setclipboard(code)
                notify("Copied!", "Code in clipboard", 2)
            else
                notify("Copy Code", "No clipboard - use popup", 2)
            end
            -- Popup
            local Popup = Instance.new("Frame", FM)
            Popup.Size = UDim2.new(0,280,0,150)
            Popup.Position = UDim2.new(0.5,-140,0.5,-75)
            Popup.BackgroundColor3 = Color3.fromRGB(20,20,20)
            Popup.BorderSizePixel = 0
            Popup.ZIndex = 10
            Instance.new("UICorner", Popup).CornerRadius = UDim.new(0,10)
            local PopTitle = Instance.new("TextLabel", Popup)
            PopTitle.Size = UDim2.new(1,-20,0,25)
            PopTitle.Position = UDim2.new(0,10,0,5)
            PopTitle.BackgroundTransparency = 1
            PopTitle.Text = "📋 COPY THIS CODE"
            PopTitle.TextColor3 = Color3.new(1,1,1)
            PopTitle.Font = Enum.Font.GothamBold
            PopTitle.TextSize = 12
            PopTitle.ZIndex = 11
            local CodeBox = Instance.new("TextBox", Popup)
            CodeBox.Size = UDim2.new(1,-20,0,80)
            CodeBox.Position = UDim2.new(0,10,0,35)
            CodeBox.BackgroundColor3 = Color3.fromRGB(30,30,30)
            CodeBox.BorderSizePixel = 0
            CodeBox.Text = code
            CodeBox.TextColor3 = Color3.new(1,1,1)
            CodeBox.Font = Enum.Font.Code
            CodeBox.TextSize = 8
            CodeBox.TextXAlignment = "Left"
            CodeBox.TextYAlignment = "Top"
            CodeBox.TextWrapped = true
            CodeBox.MultiLine = true
            CodeBox.ZIndex = 11
            Instance.new("UICorner", CodeBox).CornerRadius = UDim.new(0,5)
            local ClosePopup = Instance.new("TextButton", Popup)
            ClosePopup.Size = UDim2.new(1,-20,0,25)
            ClosePopup.Position = UDim2.new(0,10,1,-30)
            ClosePopup.BackgroundColor3 = Color3.fromRGB(200,60,60)
            ClosePopup.Text = "CLOSE"
            ClosePopup.TextColor3 = Color3.new(1,1,1)
            ClosePopup.Font = Enum.Font.GothamBold
            ClosePopup.TextSize = 11
            ClosePopup.ZIndex = 11
            Instance.new("UICorner", ClosePopup).CornerRadius = UDim.new(0,5)
            ClosePopup.MouseButton1Click:Connect(function() Popup:Destroy() end)
        end)

        -- Delete
        createBtn("🗑", -26, 3, Color3.fromRGB(200,60,60), function()
            deleteRecording(name)
            Entry:Destroy()
            Count.Text = string.format("Total: %d recordings", countRecordings())
        end)
    end

    local has = false
    for name, data in pairs(_G.AutoTP.recordings) do
        createEntry(name, data)
        has = true
    end
    if not has then
        local Empty = Instance.new("TextLabel", Scroll)
        Empty.Size = UDim2.new(1,0,1,0)
        Empty.BackgroundTransparency = 1
        Empty.Text = "No Recordings\n📍\nSave one first!"
        Empty.TextColor3 = Color3.fromRGB(100,100,100)
        Empty.Font = Enum.Font.GothamBold
        Empty.TextSize = 12
    end

    -- PASTE SECTION
    local PasteLabel = Instance.new("TextLabel", Panel)
    PasteLabel.Size = UDim2.new(1,-18,0,16)
    PasteLabel.Position = UDim2.new(0,9,0,245)
    PasteLabel.BackgroundTransparency = 1
    PasteLabel.Text = "PASTE CODE PLAYBACK:"
    PasteLabel.TextColor3 = Color3.fromRGB(200,200,200)
    PasteLabel.Font = Enum.Font.GothamBold
    PasteLabel.TextSize = 10
    PasteLabel.TextXAlignment = "Left"

    local PasteBox = Instance.new("TextBox", Panel)
    PasteBox.Size = UDim2.new(1,-18,0,45)
    PasteBox.Position = UDim2.new(0,9,0,265)
    PasteBox.BackgroundColor3 = Color3.fromRGB(25,25,25)
    PasteBox.BorderSizePixel = 0
    PasteBox.Text = ""
    PasteBox.PlaceholderText = "Paste AUTOTP:// code here..."
    PasteBox.TextColor3 = Color3.new(1,1,1)
    PasteBox.PlaceholderColor3 = Color3.fromRGB(100,100,100)
    PasteBox.Font = Enum.Font.Code
    PasteBox.TextSize = 8
    PasteBox.TextXAlignment = "Left"
    PasteBox.TextYAlignment = "Top"
    PasteBox.TextWrapped = true
    PasteBox.MultiLine = true
    Instance.new("UICorner", PasteBox).CornerRadius = UDim.new(0,5)

    local RunBtn = Instance.new("TextButton", Panel)
    RunBtn.Size = UDim2.new(1,-18,0,28)
    RunBtn.Position = UDim2.new(0,9,0,315)
    RunBtn.BackgroundColor3 = Color3.fromRGB(50,200,100)
    RunBtn.BorderSizePixel = 0
    RunBtn.Text = "▶ RUN PLAYBACK"
    RunBtn.TextColor3 = Color3.new(1,1,1)
    RunBtn.Font = Enum.Font.GothamBold
    RunBtn.TextSize = 12
    Instance.new("UICorner", RunBtn).CornerRadius = UDim.new(0,6)

    RunBtn.MouseButton1Click:Connect(function()
        local code = PasteBox.Text
        if code == "" then notify("Error","Paste code first!",2) return end
        local parsed, err = parseCode(code)
        if not parsed then notify("Error","Invalid code",3) return end
        _G.AutoTP.currentLocations = parsed.locations
        _G.AutoTP.currentName = parsed.name
        _G.AutoTP.currentMapId = parsed.mapId
        _G.AutoTP.lastLoadedName = parsed.name
        _G.AutoTP.lastLoadedMap = parsed.mapId
        _G.AutoTP.recordings[parsed.name] = {
            locations = parsed.locations,
            timestamp = os.time(),
            count = #parsed.locations,
            mapId = parsed.mapId,
            gameName = getGameName()
        }
        saveData()
        notify("Success", string.format("Loaded '%s' (%d locs)", parsed.name, #parsed.locations), 4)
        PasteBox.Text = ""
        FM:Destroy()
        _G.Anonymous9xTP_FileManager = nil
    end)

    local DeleteAll = Instance.new("TextButton", Panel)
    DeleteAll.Size = UDim2.new(1,-18,0,10)
    DeleteAll.Position = UDim2.new(0,9,1,-15)
    DeleteAll.BackgroundColor3 = Color3.fromRGB(180,40,40)
    DeleteAll.BorderSizePixel = 0
    DeleteAll.Text = "🗑 DELETE ALL"
    DeleteAll.TextColor3 = Color3.new(1,1,1)
    DeleteAll.Font = Enum.Font.GothamBold
    DeleteAll.TextSize = 8
    Instance.new("UICorner", DeleteAll).CornerRadius = UDim.new(0,4)
    DeleteAll.MouseButton1Click:Connect(function()
        deleteAll()
        FM:Destroy()
        _G.Anonymous9xTP_FileManager = nil
    end)

    CloseBtn.MouseButton1Click:Connect(function()
        createTween(Panel, {Size = UDim2.new(0,0,0,0)}, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        createTween(Blur, {BackgroundTransparency = 1}, 0.3)
        task.wait(0.35)
        FM:Destroy()
        _G.Anonymous9xTP_FileManager = nil
    end)

    Panel.Size = UDim2.new(0,0,0,0)
    Blur.BackgroundTransparency = 1
    createTween(Panel, {Size = UDim2.new(0,300,0,360)}, 0.4, Enum.EasingStyle.Back)
    createTween(Blur, {BackgroundTransparency = 0.15}, 0.4)
end

-- ═══════════════════════════════════════════════════════════════
-- LOADING SCREEN
-- ═══════════════════════════════════════════════════════════════

local function createLoader(callback)
    local L = Instance.new("ScreenGui")
    L.Name = "Anonymous9xTP_Loader"
    L.ResetOnSpawn = false
    pcall(function() L.Parent = CoreGui end)
    if not L.Parent then L.Parent = PlayerGui end
    _G.Anonymous9xTP_Loader = L

    local BG = Instance.new("Frame", L)
    BG.Size = UDim2.new(1,0,1,0)
    BG.BackgroundColor3 = Color3.fromRGB(5,5,5)
    BG.BorderSizePixel = 0

    local T1 = Instance.new("TextLabel", BG)
    T1.Size = UDim2.new(0,600,0,80)
    T1.Position = UDim2.new(0.5,-300,0.5,-100)
    T1.BackgroundTransparency = 1
    T1.Text = "ANONYMOUS9X"
    T1.TextColor3 = Color3.new(1,1,1)
    T1.Font = Enum.Font.GothamBold
    T1.TextSize = 42
    T1.TextTransparency = 1

    local T2 = Instance.new("TextLabel", BG)
    T2.Size = UDim2.new(0,600,0,40)
    T2.Position = UDim2.new(0.5,-300,0.5,-20)
    T2.BackgroundTransparency = 1
    T2.Text = "AutoTP V1.0 • UNIVERSAL"
    T2.TextColor3 = Color3.fromRGB(100,200,255)
    T2.Font = Enum.Font.GothamBold
    T2.TextSize = 16
    T2.TextTransparency = 1

    task.spawn(function()
        createTween(T1, {TextTransparency = 0}, 0.8)
        task.wait(0.3)
        createTween(T2, {TextTransparency = 0}, 0.8)
        task.wait(1.2)
        createTween(T1, {TextTransparency = 1}, 0.4)
        createTween(T2, {TextTransparency = 1}, 0.4)
        createTween(BG, {BackgroundTransparency = 1}, 0.6)
        task.wait(0.7)
        L:Destroy()
        _G.Anonymous9xTP_Loader = nil
        if callback then callback() end
    end)
end

-- ═══════════════════════════════════════════════════════════════
-- MAIN GUI
-- ═══════════════════════════════════════════════════════════════

local function createMainGUI()
    if _G.Anonymous9xTP_GUI then
        pcall(function() _G.Anonymous9xTP_GUI:Destroy() end)
    end

    print("[AutoTP] Creating main GUI")

    local GUI = Instance.new("ScreenGui")
    GUI.Name = "Anonymous9xAutoTP"
    GUI.ResetOnSpawn = false
    pcall(function() GUI.Parent = CoreGui end)
    if not GUI.Parent then GUI.Parent = PlayerGui end
    _G.Anonymous9xTP_GUI = GUI

    local Main = Instance.new("Frame", GUI)
    Main.Size = UDim2.new(0, 250, 0, 320)  -- sedikit lebih kecil
    Main.Position = UDim2.new(0.5, -125, 0.5, -160)
    Main.BackgroundColor3 = Color3.fromRGB(10,10,10)
    Main.BorderSizePixel = 0
    Main.Active = true
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0,10)
    local stroke = Instance.new("UIStroke", Main)
    stroke.Color = Color3.fromRGB(255,255,255)
    stroke.Thickness = 2

    local TBar = Instance.new("Frame", Main)
    TBar.Size = UDim2.new(1,0,0,38)
    TBar.BackgroundColor3 = Color3.fromRGB(15,15,15)
    TBar.BorderSizePixel = 0
    Instance.new("UICorner", TBar).CornerRadius = UDim.new(0,10)

    local Title = Instance.new("TextLabel", TBar)
    Title.Size = UDim2.new(1,-70,0,22)
    Title.Position = UDim2.new(0,8,0,3)
    Title.BackgroundTransparency = 1
    Title.Text = "Anonymous9x"
    Title.TextColor3 = Color3.new(1,1,1)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 13
    Title.TextXAlignment = "Left"

    local Ver = Instance.new("TextLabel", TBar)
    Ver.Size = UDim2.new(1,-70,0,11)
    Ver.Position = UDim2.new(0,8,0,24)
    Ver.BackgroundTransparency = 1
    Ver.Text = "AutoTP V1.0"
    Ver.TextColor3 = Color3.fromRGB(120,120,120)
    Ver.Font = Enum.Font.Gotham
    Ver.TextSize = 7
    Ver.TextXAlignment = "Left"

    local MinBtn = Instance.new("TextButton", TBar)
    MinBtn.Size = UDim2.new(0,28,0,28)
    MinBtn.Position = UDim2.new(1,-62,0,5)
    MinBtn.BackgroundColor3 = Color3.fromRGB(40,40,40)
    MinBtn.BorderSizePixel = 0
    MinBtn.Text = "—"
    MinBtn.TextColor3 = Color3.new(1,1,1)
    MinBtn.Font = Enum.Font.GothamBold
    MinBtn.TextSize = 12
    Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0,5)

    local CloseBtn = Instance.new("TextButton", TBar)
    CloseBtn.Size = UDim2.new(0,28,0,28)
    CloseBtn.Position = UDim2.new(1,-31,0,5)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(200,40,40)
    CloseBtn.BorderSizePixel = 0
    CloseBtn.Text = "✕"
    CloseBtn.TextColor3 = Color3.new(1,1,1)
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextSize = 14
    Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0,5)

    local Content = Instance.new("Frame", Main)
    Content.Size = UDim2.new(1,-14,1,-48)
    Content.Position = UDim2.new(0,7,0,45)
    Content.BackgroundTransparency = 1

    local Status = Instance.new("TextLabel", Content)
    Status.Size = UDim2.new(1,0,0,22)
    Status.BackgroundColor3 = Color3.fromRGB(20,20,20)
    Status.BorderSizePixel = 0
    Status.Text = "● Idle"
    Status.TextColor3 = Color3.fromRGB(100,255,100)
    Status.Font = Enum.Font.GothamBold
    Status.TextSize = 10
    Instance.new("UICorner", Status).CornerRadius = UDim.new(0,5)

    -- Helper to create buttons
    local function createBtn(parent, text, pos, size, color, callback)
        local btn = Instance.new("TextButton", parent)
        btn.Size = size
        btn.Position = pos
        btn.BackgroundColor3 = color
        btn.BorderSizePixel = 0
        btn.Text = text
        btn.TextColor3 = Color3.new(1,1,1)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 9
        btn.AutoButtonColor = false
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0,5)
        btn.MouseButton1Click:Connect(callback)
        return btn
    end

    local function createSec(title, y, h)
        local sec = Instance.new("Frame", Content)
        sec.Size = UDim2.new(1,0,0,h)
        sec.Position = UDim2.new(0,0,0,y)
        sec.BackgroundColor3 = Color3.fromRGB(18,18,18)
        sec.BorderSizePixel = 0
        Instance.new("UICorner", sec).CornerRadius = UDim.new(0,6)
        local s = Instance.new("UIStroke", sec)
        s.Color = Color3.fromRGB(45,45,45)
        s.Thickness = 1
        local lbl = Instance.new("TextLabel", sec)
        lbl.Size = UDim2.new(1,-10,0,16)
        lbl.Position = UDim2.new(0,6,0,4)
        lbl.BackgroundTransparency = 1
        lbl.Text = title
        lbl.TextColor3 = Color3.fromRGB(170,170,170)
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 9
        lbl.TextXAlignment = "Left"
        return sec
    end

    -- Section: RECORD
    local RecSec = createSec("RECORD", 27, 90)
    createBtn(RecSec, "🆕 NEW", UDim2.new(0,6,0,24), UDim2.new(0.48,-5,0,28),
        Color3.fromRGB(220,50,50), startNewRecording)
    createBtn(RecSec, "📍 GET LOC", UDim2.new(0.52,1,0,24), UDim2.new(0.48,-5,0,28),
        Color3.fromRGB(50,150,255), addLocation)
    createBtn(RecSec, "↩ UNDO", UDim2.new(0,6,0,60), UDim2.new(0.48,-5,0,22),
        Color3.fromRGB(150,150,150), undoLastLocation)
    createBtn(RecSec, "■ STOP", UDim2.new(0.52,1,0,60), UDim2.new(0.48,-5,0,22),
        Color3.fromRGB(180,60,60), function()
            stopRecording()
            Status.Text = string.format("■ Stopped (%d)", #_G.AutoTP.currentLocations)
            Status.TextColor3 = Color3.fromRGB(255,150,100)
        end)

    -- Section: PLAYBACK
    local PlaySec = createSec("PLAYBACK", 122, 70)
    local PlayBtn = createBtn(PlaySec, "▶ PLAY", UDim2.new(0,6,0,24), UDim2.new(0.48,-5,0,34),
        Color3.fromRGB(50,200,100), function()
            if #_G.AutoTP.currentLocations == 0 then
                notify("Error","No recording loaded!",3)
                return
            end
            playRecording(_G.AutoTP.currentLocations, _G.AutoTP.currentMapId)
            local st = _G.AutoTP.playbackState
            if st == "PLAYING" then
                Status.Text = "▶ Playing..."; Status.TextColor3 = Color3.fromRGB(100,255,100)
                PlayBtn.BackgroundColor3 = Color3.fromRGB(255,150,50); PlayBtn.Text = "⏸ PAUSE"
            elseif st == "PAUSED" then
                Status.Text = "⏸ Paused"; Status.TextColor3 = Color3.fromRGB(255,200,100)
                PlayBtn.BackgroundColor3 = Color3.fromRGB(50,200,100); PlayBtn.Text = "▶ RESUME"
            else
                Status.Text = "● Idle"; Status.TextColor3 = Color3.fromRGB(100,255,100)
                PlayBtn.BackgroundColor3 = Color3.fromRGB(50,200,100); PlayBtn.Text = "▶ PLAY"
            end
        end)
    local LoopBtn = createBtn(PlaySec, "↻ LOOP", UDim2.new(0.52,1,0,24), UDim2.new(0.48,-5,0,34),
        Color3.fromRGB(100,150,255), function()
            if #_G.AutoTP.currentLocations == 0 then
                notify("Error","No recording loaded!",3)
                return
            end
            loopRecording(_G.AutoTP.currentLocations, _G.AutoTP.currentMapId)
            local st = _G.AutoTP.playbackState
            if st == "LOOPING" then
                Status.Text = "↻ Looping..."; Status.TextColor3 = Color3.fromRGB(150,150,255)
                LoopBtn.BackgroundColor3 = Color3.fromRGB(255,150,50); LoopBtn.Text = "⏸ PAUSE"
            elseif st == "LOOP_PAUSED" then
                Status.Text = "⏸ Paused"; Status.TextColor3 = Color3.fromRGB(255,200,100)
                LoopBtn.BackgroundColor3 = Color3.fromRGB(100,150,255); LoopBtn.Text = "⏸ RESUME"
            else
                Status.Text = "● Idle"; Status.TextColor3 = Color3.fromRGB(100,255,100)
                LoopBtn.BackgroundColor3 = Color3.fromRGB(100,150,255); LoopBtn.Text = "↻ LOOP"
            end
        end)

    -- Section: SAVE/LOAD
    local SaveSec = createSec(string.format("SAVE/LOAD • %d", countRecordings()), 197, 80)
    local NameInput = Instance.new("TextBox", SaveSec)
    NameInput.Size = UDim2.new(1,-12,0,28)
    NameInput.Position = UDim2.new(0,6,0,24)
    NameInput.BackgroundColor3 = Color3.fromRGB(25,25,25)
    NameInput.BorderSizePixel = 0
    NameInput.Text = ""
    NameInput.PlaceholderText = "Recording name..."
    NameInput.TextColor3 = Color3.new(1,1,1)
    NameInput.PlaceholderColor3 = Color3.fromRGB(100,100,100)
    NameInput.Font = Enum.Font.Gotham
    NameInput.TextSize = 9
    Instance.new("UICorner", NameInput).CornerRadius = UDim.new(0,5)

    createBtn(SaveSec, "💾 SAVE", UDim2.new(0,6,0,56), UDim2.new(0.48,-5,0,18),
        Color3.fromRGB(255,150,50), function()
            if saveRecording(NameInput.Text) then
                NameInput.Text = ""
                SaveSec:FindFirstChild("TextLabel").Text = string.format("SAVE/LOAD • %d", countRecordings())
            end
        end)

    local function updatePlayBtn()
        local st = _G.AutoTP.playbackState
        if st == "PLAYING" then
            PlayBtn.BackgroundColor3 = Color3.fromRGB(255,150,50); PlayBtn.Text = "⏸ PAUSE"
        elseif st == "PAUSED" then
            PlayBtn.BackgroundColor3 = Color3.fromRGB(50,200,100); PlayBtn.Text = "▶ RESUME"
        else
            PlayBtn.BackgroundColor3 = Color3.fromRGB(50,200,100); PlayBtn.Text = "▶ PLAY"
        end
    end
    local function updateLoopBtn()
        local st = _G.AutoTP.playbackState
        if st == "LOOPING" then
            LoopBtn.BackgroundColor3 = Color3.fromRGB(255,150,50); LoopBtn.Text = "⏸ PAUSE"
        elseif st == "LOOP_PAUSED" then
            LoopBtn.BackgroundColor3 = Color3.fromRGB(100,150,255); LoopBtn.Text = "⏸ RESUME"
        else
            LoopBtn.BackgroundColor3 = Color3.fromRGB(100,150,255); LoopBtn.Text = "↻ LOOP"
        end
    end

    createBtn(SaveSec, "📁 LOAD", UDim2.new(0.52,1,0,56), UDim2.new(0.48,-5,0,18),
        Color3.fromRGB(100,200,255), function()
            createFileManager(
                function(txt) Status.Text = txt end,
                updatePlayBtn,
                updateLoopBtn
            )
        end)

    -- Speed slider (optional)
    local SpeedSec = createSec("SPEED (delay sec)", 282, 35)
    local SpeedSlider = Instance.new("Frame", SpeedSec)
    SpeedSlider.Size = UDim2.new(1,-24,0,10)
    SpeedSlider.Position = UDim2.new(0,6,0,20)
    SpeedSlider.BackgroundColor3 = Color3.fromRGB(40,40,40)
    Instance.new("UICorner", SpeedSlider).CornerRadius = UDim.new(0,3)
    local SpeedFill = Instance.new("Frame", SpeedSlider)
    SpeedFill.Size = UDim2.new(_G.AutoTP.settings.speed / 5, 0, 1, 0)  -- max 5 detik
    SpeedFill.BackgroundColor3 = Color3.fromRGB(255,255,255)
    Instance.new("UICorner", SpeedFill).CornerRadius = UDim.new(0,3)

    local SpeedValue = Instance.new("TextLabel", SpeedSec)
    SpeedValue.Size = UDim2.new(0,40,0,16)
    SpeedValue.Position = UDim2.new(1,-46,0,18)
    SpeedValue.BackgroundTransparency = 1
    SpeedValue.Text = string.format("%.1fs", _G.AutoTP.settings.speed)
    SpeedValue.TextColor3 = Color3.new(1,1,1)
    SpeedValue.Font = Enum.Font.Gotham
    SpeedValue.TextSize = 8

    -- Drag functionality for slider
    local draggingSpeed = false
    SpeedSlider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            draggingSpeed = true
        end
    end)
    SpeedSlider.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            draggingSpeed = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if draggingSpeed and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local pos = input.Position.X - SpeedSlider.AbsolutePosition.X
            local w = SpeedSlider.AbsoluteSize.X
            local p = math.clamp(pos / w, 0, 1)
            local speed = p * 5  -- max 5 detik
            speed = math.floor(speed*10)/10
            _G.AutoTP.settings.speed = speed
            SpeedFill.Size = UDim2.new(p,0,1,0)
            SpeedValue.Text = string.format("%.1fs", speed)
        end
    end)

    -- Minimize
    local minimized = false
    MinBtn.MouseButton1Click:Connect(function()
        if not minimized then
            createTween(Main, {Size = UDim2.new(0,250,0,38)}, 0.3)
            Content.Visible = false
            minimized = true
            MinBtn.Text = "+"
        else
            createTween(Main, {Size = UDim2.new(0,250,0,320)}, 0.3)
            Content.Visible = true
            minimized = false
            MinBtn.Text = "—"
        end
    end)

    -- Close
    CloseBtn.MouseButton1Click:Connect(function()
        stopPlayback()
        createTween(Main, {Size = UDim2.new(0,0,0,0), Position = UDim2.new(0.5,0,0.5,0)}, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        createTween(Main, {BackgroundTransparency = 1}, 0.5)
        createTween(stroke, {Transparency = 1}, 0.5)
        task.wait(0.55)
        GUI:Destroy()
        _G.Anonymous9xTP_GUI = nil
        notify("Anonymous9x", "AutoTP closed", 2)
    end)

    -- Dragging
    local dragging, dragInput, dragStart, startPos
    TBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = Main.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    TBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input == dragInput then
            local delta = input.Position - dragStart
            createTween(Main, {Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )}, 0.08)
        end
    end)

    -- Entry animation
    Main.Size = UDim2.new(0,0,0,0)
    Main.BackgroundTransparency = 1
    stroke.Transparency = 1
    createTween(Main, {Size = UDim2.new(0,250,0,320)}, 0.6, Enum.EasingStyle.Back)
    createTween(Main, {BackgroundTransparency = 0}, 0.6)
    createTween(stroke, {Transparency = 0}, 0.6)

    notify("AutoTP", "Ready!", 2)
    print("[AutoTP] Main GUI ready")
end

-- Initialize
createLoader(createMainGUI)

Player.CharacterAdded:Connect(function()
    task.wait(1)
    if not _G.Anonymous9xTP_GUI then createMainGUI() end
end)

print([[
╔═══════════════════════════════════════════════════════════════╗
║      Anonymous9x AutoTP Universal V1.0 FINAL                ║
║                                                               ║
║  ✅ Get Location - simpan posisi sekali tekan                 ║
║  ✅ Undo, Stop, New Recording                                 ║
║  ✅ Play, Loop dengan delay adjustable                       ║
║  ✅ File Manager + Copy Code (base64 pendek)                 ║
║  ✅ Paste Code + Run Playback                                 ║
║  ✅ Tema hitam-putih, drag, minimize                          ║
║                                                               ║
║  🔥 Kode sangat pendek karena hanya berisi koordinat!         ║
║  🔥 Cocok untuk speedrun summit / checkpoint                  ║
║  🔥 Universal (FE) - semua orang lihat teleport?             ║
║     (Teleport client-side, hanya untuk pemilik)               ║
╚═══════════════════════════════════════════════════════════════╝
]])
