-- =================================================================
-- AUTO SAMBUNG KATA REAL v3 - Anonymous9x
-- FIX: Tidak pakai Remote ngaco, fokus TextBox + tombol Masuk
-- =================================================================

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local VirtualInputManager = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local parentGui = CoreGui or PlayerGui

if parentGui:FindFirstChild("AutoSambungKataReal") then
    parentGui.AutoSambungKataReal:Destroy()
end

-- =================================================================
-- KAMUS
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
    else
        local fallback = {"aku","kamu","dia","mereka","kami","kita","siapa","apa","mana","kapan","mengapa","bagaimana","bisa","dapat","mau","akan","sedang","telah","sudah","belum","pernah","selalu","sering","jarang","kadang","mungkin","harus","wajib","boleh","dilarang","jangan","ayo","coba","lihat","dengar","rasa","sentuh","ambil","beri","simpan","buang","buka","tutup","hidup","mati","besar","kecil","panjang","pendek","tinggi","rendah","berat","ringan","cepat","lambat","kuat","lemah","terang","gelap","panas","dingin","basah","kering","bersih","kotor","baru","lama","muda","tua","kaya","miskin","pintar","cantik","baik","buruk","senang","sedih","marah","takut","berani","malas","rajin","angin","bumi","api","langit","laut","hutan","gunung","sungai","danau","kota","desa","jalan","rumah","pintu","kursi","meja","buku","pena","kertas","makan","minum","masak","cuci","tidur","duduk","berjalan","berlari","naik","turun","masuk","keluar","pergi","datang","beli","jual","baca","tulis","bicara","tertawa","senyum","bahagia","gembira","indah","cantik","gagah","elok","anggun","mewah","sederhana","tulus","setia","jujur","adil","bijak","arif","cerdas","pandai","rajin","tekun","sabar","ikhlas","tabah","tegar","berani","percaya","harap","cinta","kasih","sayang","rindu","kenang","ingat","lupa","tahu","paham","mengerti","pikir","rasa","hati","jiwa","roh","hidup","nyawa","tubuh","tangan","kaki","mata","telinga","hidung","mulut","lidah","gigi","rambut","wajah","leher","dada","perut","punggung","bahu","siku","lutut","jari","kuku"}
        for _, kata in ipairs(fallback) do
            table.insert(KAMUS, kata)
            local h = string.sub(kata, 1, 1)
            if not KAMUS_BY_HURUF[h] then KAMUS_BY_HURUF[h] = {} end
            table.insert(KAMUS_BY_HURUF[h], kata)
        end
        print("[KAMUS] Fallback: " .. #KAMUS .. " kata")
    end
end

local function CariKata(kataSebelum)
    if not kataSebelum or kataSebelum == "" then return nil end
    local huruf = string.lower(string.sub(kataSebelum, -1))
    local list = KAMUS_BY_HURUF[huruf]
    if not list or #list == 0 then return nil end
    for i = 1, 40 do
        local calon = list[math.random(1, #list)]
        if calon ~= kataSebelum then return calon end
    end
    return list[1]
end

-- =================================================================
-- SCAN ELEMEN GAME
-- =================================================================

-- Kata-kata yang BUKAN kata game (blacklist)
local BLACKLIST = {
    purchased=1,robux=1,buy=1,sale=1,shop=1,store=1,free=1,item=1,
    player=1,players=1,score=1,level=1,round=1,time=1,timer=1,
    loading=1,lobby=1,waiting=1,start=1,win=1,lose=1,game=1,
    play=1,chat=1,rank=1,invite=1,join=1,leave=1,server=1,
    topbarplus=1,admin=1,running=1,ready=1,flash=1,mode=1,
}

local function IsKataValid(text)
    if not text then return false end
    text = text:match("^%s*(.-)%s*$")
    if not text or #text < 2 or #text > 25 then return false end
    if not text:match("^[a-zA-Z]+$") then return false end
    if BLACKLIST[text:lower()] then return false end
    return true
end

-- Cari TextBox input game
local function CariTextBox()
    for _, gui in ipairs(PlayerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Enabled and gui.Name ~= "AutoSambungKataReal" then
            for _, v in ipairs(gui:GetDescendants()) do
                if v:IsA("TextBox") and v.Visible then
                    return v
                end
            end
        end
    end
    return nil
end

-- Cari tombol Masuk / Submit
local function CariTombolMasuk()
    for _, gui in ipairs(PlayerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Enabled and gui.Name ~= "AutoSambungKataReal" then
            for _, v in ipairs(gui:GetDescendants()) do
                if v:IsA("TextButton") and v.Visible then
                    local t = v.Text:lower():match("^%s*(.-)%s*$")
                    if t == "masuk" or t == "jawab" or t == "kirim" or t == "submit" or t == "ok" or t == "send" or t == "enter" then
                        return v
                    end
                end
            end
        end
    end
    return nil
end

-- Track TextLabel yang berubah = kata game
local labelHistory = {}  -- [label] = {text, changes}

local function TrackLabels()
    for _, gui in ipairs(PlayerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Enabled and gui.Name ~= "AutoSambungKataReal" then
            for _, v in ipairs(gui:GetDescendants()) do
                if v:IsA("TextLabel") and v.Visible then
                    if not labelHistory[v] then
                        labelHistory[v] = {text = v.Text, changes = 0}
                    elseif v.Text ~= labelHistory[v].text then
                        labelHistory[v].changes = labelHistory[v].changes + 1
                        labelHistory[v].text = v.Text
                    end
                end
            end
        end
    end
    -- Bersihkan label mati
    for lbl in pairs(labelHistory) do
        if not lbl or not lbl.Parent then
            labelHistory[lbl] = nil
        end
    end
end

-- Cari kata game dari label yang paling sering berubah
local function CariKataGame()
    local best, bestScore = nil, -1
    for lbl, data in pairs(labelHistory) do
        if lbl and lbl.Parent and lbl.Visible then
            local txt = lbl.Text:match("^%s*(.-)%s*$")
            if IsKataValid(txt) then
                if data.changes > bestScore then
                    bestScore = data.changes
                    best = lbl
                end
            end
        end
    end
    -- Fallback: scan biasa jika tidak ada yang pernah berubah
    if not best then
        for _, gui in ipairs(PlayerGui:GetChildren()) do
            if gui:IsA("ScreenGui") and gui.Enabled and gui.Name ~= "AutoSambungKataReal" then
                for _, v in ipairs(gui:GetDescendants()) do
                    if v:IsA("TextLabel") and v.Visible then
                        local txt = v.Text:match("^%s*(.-)%s*$")
                        if IsKataValid(txt) then
                            return v
                        end
                    end
                end
            end
        end
    end
    return best
end

-- =================================================================
-- SUBMIT JAWABAN
-- =================================================================
local function SubmitJawaban(jawaban)
    local textBox = CariTextBox()
    local tombolMasuk = CariTombolMasuk()
    
    if textBox then
        -- Fokus ke TextBox
        pcall(function() textBox:CaptureFocus() end)
        task.wait(0.05)
        
        -- Isi jawaban
        textBox.Text = jawaban
        task.wait(0.05)
        
        -- Cara 1: ReleaseFocus (simulasi Enter)
        pcall(function() textBox:ReleaseFocus(true) end)
        task.wait(0.05)
        
        -- Cara 2: Klik tombol Masuk
        if tombolMasuk then
            pcall(function() tombolMasuk:Click() end)
            task.wait(0.05)
        end
        
        -- Cara 3: VirtualInput Enter
        pcall(function()
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, nil)
            task.wait(0.03)
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, nil)
        end)
        
        print("[OK] Jawaban: " .. jawaban .. " (TextBox mode)")
        return true
        
    elseif tombolMasuk then
        -- Ada tombol tapi tidak ada textbox - game pakai keyboard custom
        -- Coba inject text via properti game
        print("[WARN] TextBox tidak ditemukan, coba klik Masuk saja")
        pcall(function() tombolMasuk:Click() end)
        return false
    else
        print("[ERROR] TextBox dan tombol Masuk tidak ditemukan!")
        return false
    end
end

-- =================================================================
-- STATE
-- =================================================================
local ENABLED = false
local kataSebelum = ""
local lastJawabTime = 0
local COOLDOWN = 0.8

-- =================================================================
-- LOOP UTAMA
-- =================================================================
local function MainLoop()
    TrackLabels()
    if not ENABLED then return end
    if tick() - lastJawabTime < COOLDOWN then return end
    
    local wordLabel = CariKataGame()
    if not wordLabel then return end
    
    local kataSekarang = wordLabel.Text:match("^%s*(.-)%s*$"):lower()
    if kataSekarang == "" or kataSekarang == kataSebelum then return end
    
    -- Cari jawaban
    local jawaban = CariKata(kataSekarang)
    if not jawaban then
        print("[SKIP] Tidak ada kata untuk huruf: " .. kataSekarang:sub(-1))
        return
    end
    
    print("[FLASH] '" .. kataSekarang .. "' -> '" .. jawaban .. "'")
    
    if SubmitJawaban(jawaban) then
        kataSebelum = kataSekarang
        lastJawabTime = tick()
    end
end

-- =================================================================
-- GUI (TIDAK DIUBAH)
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

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

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

ToggleBtn.MouseButton1Click:Connect(function()
    ENABLED = not ENABLED
    if ENABLED then
        ToggleBtn.Text = "ON"
        ToggleBtn.BackgroundColor3 = Color3.new(0, 0.7, 0)
        kataSebelum = ""
        lastJawabTime = 0
        print("[STATUS] Auto answer ENABLED")
    else
        ToggleBtn.Text = "OFF"
        ToggleBtn.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
        print("[STATUS] Auto answer DISABLED")
    end
end)

-- =================================================================
-- START
-- =================================================================
LoadKamus()

-- Background tracking loop
task.spawn(function()
    while true do
        task.wait(0.3)
        pcall(TrackLabels)
    end
end)

-- Main loop
task.spawn(function()
    while true do
        task.wait(0.3)
        pcall(MainLoop)
    end
end)

print("=== AUTO SAMBUNG KATA REAL v3 READY ===")
print("Tekan tombol ON untuk memulai")
print("Cek console [FLASH] dan [OK] untuk konfirmasi")
