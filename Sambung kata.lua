-- =================================================================
-- AUTO SAMBUNG KATA REAL - Roblox Game
-- Author: Anonymous9x
-- FIXED ENGINE: Flash mode, real auto type, smart word detection
-- =================================================================

-- Services
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local VirtualInputManager = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local parentGui = CoreGui or PlayerGui

-- Hapus GUI lama
if parentGui:FindFirstChild("AutoSambungKataReal") then
    parentGui.AutoSambungKataReal:Destroy()
end

-- =================================================================
-- KAMUS DATA
-- =================================================================
local DICTIONARY_URL = "https://raw.githubusercontent.com/eenvyexe/KBBI/refs/heads/main/words.txt"
local KAMUS = {}
local KAMUS_BY_HURUF = {}

local function LoadKamus()
    local success, response = pcall(function()
        return game:HttpGet(DICTIONARY_URL)
    end)
    if success and response then
        local unique = {}
        for line in string.gmatch(response, "[^\r\n]+") do
            local kata = string.match(line, "([%a%-]+)")
            if kata and #kata > 1 then
                kata = string.lower(kata)
                if not unique[kata] then
                    unique[kata] = true
                    table.insert(KAMUS, kata)
                    local h = string.sub(kata, 1, 1)
                    if not KAMUS_BY_HURUF[h] then KAMUS_BY_HURUF[h] = {} end
                    table.insert(KAMUS_BY_HURUF[h], kata)
                end
            end
        end
        print("[KAMUS] Loaded " .. #KAMUS .. " words")
        return true
    else
        local fallback = {"aku","kamu","dia","mereka","kami","kita","siapa","apa","mana","kapan","mengapa","bagaimana","bisa","dapat","mau","akan","sedang","telah","sudah","belum","pernah","selalu","sering","jarang","kadang","mungkin","harus","wajib","boleh","dilarang","jangan","ayo","coba","lihat","dengar","rasa","cium","sentuh","pegang","ambil","beri","taruh","simpan","buang","buka","tutup","hidup","mati","nyala","padam","besar","kecil","panjang","pendek","tinggi","rendah","berat","ringan","cepat","lambat","kuat","lemah","terang","gelap","panas","dingin","basah","kering","bersih","kotor","baru","lama","muda","tua","kaya","miskin","pintar","bodoh","cantik","jelek","baik","buruk","senang","sedih","marah","takut","berani","malas","rajin","sabar","emosi","angin","bumi","api","tanah","langit","laut","hutan","gunung","sungai","danau","pulau","kota","desa","jalan","rumah","pintu","jendela","atap","lantai","dinding","kursi","meja","lemari","tempat","tidur","kasur","bantal","selimut","pakaian","baju","celana","sepatu","sandal","tas","dompet","kunci","lampu","kipas","kulkas","komputer","handphone","televisi","radio","kamera","buku","pena","pensil","kertas","papan","tulis","makan","minum","masak","cuci","bersih","kotor","rapi","berantakan","tidur","bangun","duduk","berdiri","berjalan","berlari","melompat","berenang","terbang","jatuh","naik","turun","masuk","keluar","pergi","datang","pulang","beli","jual","bayar","hitung","baca","tulis","bicara","diam","tertawa","menangis","senyum","ceria","gembira","bahagia"}
        for _, kata in ipairs(fallback) do
            table.insert(KAMUS, kata)
            local h = string.sub(kata, 1, 1)
            if not KAMUS_BY_HURUF[h] then KAMUS_BY_HURUF[h] = {} end
            table.insert(KAMUS_BY_HURUF[h], kata)
        end
        print("[KAMUS] Using fallback dictionary (" .. #KAMUS .. " words)")
        return false
    end
end

local function CariKataLanjutan(kataSebelum)
    if not kataSebelum or kataSebelum == "" then return nil end
    local hurufTerakhir = string.lower(string.sub(kataSebelum, -1, -1))
    local kandidat = KAMUS_BY_HURUF[hurufTerakhir]
    if not kandidat or #kandidat == 0 then return nil end
    for attempt = 1, 30 do
        local idx = math.random(1, #kandidat)
        local calon = kandidat[idx]
        if calon ~= kataSebelum then
            return calon
        end
    end
    return kandidat[math.random(1, #kandidat)]
end

-- =================================================================
-- SMART WORD DETECTOR
-- Lacak TextLabel yang BERUBAH-UBAH = itu kata game
-- =================================================================
local trackedLabels = {}   -- [TextLabel] = {lastText, changeCount}
local BLACKLIST_WORDS = {  -- kata-kata yang BUKAN kata game
    ["purchased"] = true, ["robux"] = true, ["buy"] = true, ["sale"] = true,
    ["shop"] = true, ["store"] = true, ["free"] = true, ["item"] = true,
    ["player"] = true, ["players"] = true, ["score"] = true, ["level"] = true,
    ["round"] = true, ["time"] = true, ["timer"] = true, ["loading"] = true,
    ["lobby"] = true, ["waiting"] = true, ["start"] = true, ["end"] = true,
    ["win"] = true, ["lose"] = true, ["draw"] = true, ["game"] = true,
    ["play"] = true, ["chat"] = true, ["leaderboard"] = true, ["rank"] = true,
}

local function IsValidGameWord(text)
    if not text or text == "" then return false end
    text = string.gsub(text, "^%s*(.-)%s*$", "%1")
    -- Harus hanya huruf alfabet (kata Indonesia)
    if not string.match(text, "^[a-zA-Z]+$") then return false end
    if #text < 2 or #text > 30 then return false end
    -- Tidak boleh kata blacklist
    if BLACKLIST_WORDS[string.lower(text)] then return false end
    return true
end

-- Scan dan track semua TextLabel
local function UpdateTrackedLabels()
    for _, gui in ipairs(PlayerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Enabled then
            for _, v in ipairs(gui:GetDescendants()) do
                if v:IsA("TextLabel") and v.Visible then
                    if not trackedLabels[v] then
                        trackedLabels[v] = {lastText = v.Text, changeCount = 0}
                    else
                        if v.Text ~= trackedLabels[v].lastText then
                            trackedLabels[v].changeCount = trackedLabels[v].changeCount + 1
                            trackedLabels[v].lastText = v.Text
                        end
                    end
                end
            end
        end
    end
end

-- Cari TextLabel kata game: yang sering berubah DAN teksnya valid
local function FindGameWordLabel()
    local best = nil
    local bestScore = -1
    for label, data in pairs(trackedLabels) do
        -- Cek label masih valid/exists
        if label and label.Parent and label.Visible then
            local text = string.gsub(label.Text, "^%s*(.-)%s*$", "%1")
            if IsValidGameWord(text) then
                -- Score: berapa kali berubah (lebih banyak = lebih mungkin kata game)
                local score = data.changeCount
                if score > bestScore then
                    bestScore = score
                    best = label
                end
            end
        else
            -- Hapus label yang sudah tidak ada
            trackedLabels[label] = nil
        end
    end
    return best
end

-- Cari TextBox input
local function FindInputBox()
    for _, gui in ipairs(PlayerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Enabled then
            for _, v in ipairs(gui:GetDescendants()) do
                if v:IsA("TextBox") and v.Visible then
                    return v
                end
            end
        end
    end
    return nil
end

-- Cari tombol submit
local function FindSubmitButton()
    for _, gui in ipairs(PlayerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Enabled then
            for _, v in ipairs(gui:GetDescendants()) do
                if v:IsA("TextButton") and v.Visible then
                    local t = string.lower(v.Text)
                    if t == "jawab" or t == "submit" or t == "kirim" or t == "ok" or t == "enter" or t == "masuk" or t == "send" then
                        return v
                    end
                end
            end
        end
    end
    return nil
end

-- Cari Remote Events submit (lebih reliable!)
local function FindSubmitRemote()
    -- Scan di ReplicatedStorage / workspace
    local remotes = {}
    pcall(function()
        for _, v in ipairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
            if v:IsA("RemoteEvent") then
                local name = string.lower(v.Name)
                if name:find("submit") or name:find("answer") or name:find("jawab") or name:find("word") or name:find("kata") or name:find("send") then
                    table.insert(remotes, v)
                end
            end
        end
    end)
    return remotes[1]  -- return pertama yang ditemukan
end

-- =================================================================
-- FLASH TYPE ENGINE - Ketik super cepat!
-- =================================================================
local function FlashType(textBox, kata)
    if not textBox or not kata then return false end
    
    -- Method 1: CaptureFocus + set text langsung
    pcall(function()
        textBox:CaptureFocus()
    end)
    task.wait(0.03)
    
    -- Set text
    textBox.Text = kata
    task.wait(0.03)
    
    -- Method 2: Fire FocusLost dengan ReleaseFocus (simulates pressing Enter)
    pcall(function()
        textBox:ReleaseFocus(true)  -- true = enter pressed
    end)
    task.wait(0.03)
    
    -- Method 3: VirtualInputManager Enter
    pcall(function()
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, nil)
        task.wait(0.03)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, nil)
    end)
    
    return true
end

-- =================================================================
-- VARIABEL STATE
-- =================================================================
local ENABLED = false
local lastProcessedWord = ""
local lastAnswerTime = 0
local ANSWER_COOLDOWN = 0.8  -- minimal jeda antar jawaban
local foundSubmitRemote = nil

-- Tracking scan
local scanInitialized = false
local TRACKING_DURATION = 5  -- detik tracking sebelum mulai jawab

-- =================================================================
-- FUNGSI UTAMA AUTO ANSWER (FLASH MODE)
-- =================================================================
local function AutoAnswer()
    if not ENABLED then return end
    
    -- Update tracking labels dulu
    UpdateTrackedLabels()
    
    -- Jika belum cukup tracking, tunggu dulu
    if not scanInitialized then
        return
    end
    
    -- Cooldown
    if tick() - lastAnswerTime < ANSWER_COOLDOWN then return end
    
    -- Cari kata game
    local wordLabel = FindGameWordLabel()
    
    -- Fallback: jika tidak ada yang berubah, scan biasa
    if not wordLabel then
        -- Coba scan semua label valid
        for _, gui in ipairs(PlayerGui:GetChildren()) do
            if gui:IsA("ScreenGui") and gui.Enabled then
                for _, v in ipairs(gui:GetDescendants()) do
                    if v:IsA("TextLabel") and v.Visible then
                        local text = string.gsub(v.Text, "^%s*(.-)%s*$", "%1")
                        if IsValidGameWord(text) then
                            wordLabel = v
                            break
                        end
                    end
                end
                if wordLabel then break end
            end
        end
    end
    
    if not wordLabel then
        return
    end
    
    local currentWord = string.lower(string.gsub(wordLabel.Text, "^%s*(.-)%s*$", "%1"))
    
    if currentWord == "" or currentWord == lastProcessedWord then
        return
    end
    
    -- Cari kata jawaban
    local nextWord = CariKataLanjutan(currentWord)
    if not nextWord then
        print("[WARN] Tidak ada kata untuk huruf: " .. string.sub(currentWord, -1))
        return
    end
    
    print("[FLASH] Kata: '" .. currentWord .. "' -> Jawab: '" .. nextWord .. "'")
    
    -- Cari input box
    local inputBox = FindInputBox()
    
    if inputBox then
        -- Flash type!
        FlashType(inputBox, nextWord)
        
        -- Coba klik tombol submit juga
        local submitBtn = FindSubmitButton()
        if submitBtn then
            task.wait(0.05)
            pcall(function() submitBtn:Click() end)
            pcall(function() submitBtn.MouseButton1Click:Fire() end)
        end
        
        lastProcessedWord = currentWord
        lastAnswerTime = tick()
        print("[SUCCESS] Jawaban terkirim: " .. nextWord)
    else
        -- Tidak ada TextBox - coba fire Remote langsung
        if not foundSubmitRemote then
            foundSubmitRemote = FindSubmitRemote()
        end
        if foundSubmitRemote then
            pcall(function()
                foundSubmitRemote:FireServer(nextWord)
            end)
            lastProcessedWord = currentWord
            lastAnswerTime = tick()
            print("[REMOTE] Jawaban via Remote: " .. nextWord)
        else
            print("[ERROR] Tidak ada TextBox dan Remote ditemukan!")
        end
    end
end

-- =================================================================
-- GUI (TIDAK DIUBAH - SAMA PERSIS)
-- =================================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AutoSambungKataReal"
ScreenGui.Parent = parentGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 240, 0, 150)
MainFrame.Position = UDim2.new(0.5, -120, 0.5, -75)
MainFrame.BackgroundColor3 = Color3.new(0, 0, 0)
MainFrame.BorderColor3 = Color3.new(1, 1, 1)
MainFrame.BorderSizePixel = 2
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

local Header = Instance.new("TextLabel")
Header.Size = UDim2.new(1, -40, 0, 30)
Header.Position = UDim2.new(0, 10, 0, 5)
Header.BackgroundTransparency = 1
Header.Text = "Auto Sambung Kata"
Header.TextColor3 = Color3.new(1, 1, 1)
Header.Font = Enum.Font.SourceSansBold
Header.TextSize = 18
Header.TextXAlignment = Enum.TextXAlignment.Left
Header.Parent = MainFrame

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 25, 0, 25)
CloseBtn.Position = UDim2.new(1, -60, 0, 5)
CloseBtn.BackgroundColor3 = Color3.new(0.8, 0, 0)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.new(1, 1, 1)
CloseBtn.Font = Enum.Font.SourceSansBold
CloseBtn.TextSize = 16
CloseBtn.Parent = MainFrame
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 4)

local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 25, 0, 25)
MinBtn.Position = UDim2.new(1, -30, 0, 5)
MinBtn.BackgroundColor3 = Color3.new(0.6, 0.6, 0.6)
MinBtn.Text = "-"
MinBtn.TextColor3 = Color3.new(1, 1, 1)
MinBtn.Font = Enum.Font.SourceSansBold
MinBtn.TextSize = 16
MinBtn.Parent = MainFrame
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 4)

local Separator = Instance.new("Frame")
Separator.Size = UDim2.new(1, -20, 0, 1)
Separator.Position = UDim2.new(0, 10, 0, 35)
Separator.BackgroundColor3 = Color3.new(1, 1, 1)
Separator.BorderSizePixel = 0
Separator.Parent = MainFrame

local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -20, 1, -45)
Content.Position = UDim2.new(0, 10, 0, 40)
Content.BackgroundTransparency = 1
Content.Parent = MainFrame

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 100, 0, 35)
ToggleBtn.Position = UDim2.new(0.5, -50, 0, 5)
ToggleBtn.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
ToggleBtn.Text = "OFF"
ToggleBtn.TextColor3 = Color3.new(1, 1, 1)
ToggleBtn.Font = Enum.Font.SourceSansBold
ToggleBtn.TextSize = 18
ToggleBtn.Parent = Content
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 6)

local Info = Instance.new("TextLabel")
Info.Size = UDim2.new(1, 0, 0, 30)
Info.Position = UDim2.new(0, 0, 0, 45)
Info.BackgroundTransparency = 1
Info.Text = "Automatically fill in conjunctions"
Info.TextColor3 = Color3.new(1, 1, 1)
Info.Font = Enum.Font.SourceSans
Info.TextSize = 13
Info.Parent = Content

local Credit = Instance.new("TextLabel")
Credit.Size = UDim2.new(1, 0, 0, 20)
Credit.Position = UDim2.new(0, 0, 1, -20)
Credit.BackgroundTransparency = 1
Credit.Text = "Created By Anonymous9x"
Credit.TextColor3 = Color3.new(1, 1, 1)
Credit.Font = Enum.Font.SourceSans
Credit.TextSize = 11
Credit.TextXAlignment = Enum.TextXAlignment.Right
Credit.Parent = Content

-- =================================================================
-- MINIMIZE & CLOSE
-- =================================================================
local minimized = false
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        MainFrame.Size = UDim2.new(0, 240, 0, 40)
        Content.Visible = false
        MinBtn.Text = "+"
    else
        MainFrame.Size = UDim2.new(0, 240, 0, 150)
        Content.Visible = true
        MinBtn.Text = "-"
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
    ENABLED = false
end)

-- =================================================================
-- TOGGLE ON/OFF
-- =================================================================
ToggleBtn.MouseButton1Click:Connect(function()
    ENABLED = not ENABLED
    if ENABLED then
        ToggleBtn.Text = "ON"
        ToggleBtn.BackgroundColor3 = Color3.new(0, 0.7, 0)
        lastProcessedWord = ""
        lastAnswerTime = 0
        print("[STATUS] Auto answer ENABLED - Flash Mode Active")
    else
        ToggleBtn.Text = "OFF"
        ToggleBtn.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
        print("[STATUS] Auto answer DISABLED")
    end
end)

-- =================================================================
-- LOAD KAMUS DAN MULAI
-- =================================================================
LoadKamus()

-- Phase 1: Tracking selama beberapa detik untuk kenali UI game
print("[INIT] Tracking UI elemen selama " .. TRACKING_DURATION .. " detik...")
task.spawn(function()
    local startTime = tick()
    while tick() - startTime < TRACKING_DURATION do
        UpdateTrackedLabels()
        task.wait(0.3)
    end
    scanInitialized = true
    print("[INIT] Tracking selesai! " .. (function()
        local c = 0
        for _ in pairs(trackedLabels) do c = c + 1 end
        return c
    end)() .. " label ditemukan")
    
    -- Loop utama
    while true do
        task.wait(0.3)  -- lebih cepat dari sebelumnya (0.5 -> 0.3)
        pcall(AutoAnswer)
    end
end)

-- Tracking terus berjalan di background
task.spawn(function()
    while true do
        task.wait(0.5)
        UpdateTrackedLabels()
    end
end)

print("=== AUTO SAMBUNG KATA REAL READY ===")
print("Tekan tombol ON untuk memulai")
print("Flash mode aktif - akan tracking UI dulu 5 detik")
print("Jika tidak work, cek console (F9) untuk debug")
