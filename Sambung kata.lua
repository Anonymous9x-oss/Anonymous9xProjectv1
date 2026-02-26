-- =================================================================
-- AUTO SAMBUNG KATA REAL - Roblox Game
-- Author: Anonymous9x
-- Description: Auto detect word and fill answer instantly
-- Metode: Scanning semua TextLabel di PlayerGui, auto type + Enter
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
-- KAMUS DATA (KBBI lengkap + kata umum)
-- =================================================================
local DICTIONARY_URL = "https://raw.githubusercontent.com/eenvyexe/KBBI/refs/heads/main/words.txt"
local KAMUS = {}
local KAMUS_BY_HURUF = {}  -- index berdasarkan huruf pertama

-- Load kamus
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
                    local hurufAwal = string.sub(kata, 1, 1)
                    if not KAMUS_BY_HURUF[hurufAwal] then
                        KAMUS_BY_HURUF[hurufAwal] = {}
                    end
                    table.insert(KAMUS_BY_HURUF[hurufAwal], kata)
                end
            end
        end
        print("[KAMUS] Loaded " .. #KAMUS .. " words")
        return true
    else
        -- Fallback kata umum
        local fallback = {"aku","kamu","dia","mereka","kami","kita","siapa","apa","mana","kapan","mengapa","bagaimana","bisa","dapat","mau","akan","sedang","telah","sudah","belum","pernah","selalu","sering","jarang","kadang","mungkin","harus","wajib","boleh","dilarang","jangan","ayo","coba","lihat","dengar","rasa","cium","sentuh","pegang","ambil","beri","taruh","simpan","buang","buka","tutup","hidup","mati","nyala","padam","besar","kecil","panjang","pendek","tinggi","rendah","berat","ringan","cepat","lambat","kuat","lemah","terang","gelap","panas","dingin","basah","kering","bersih","kotor","baru","lama","muda","tua","kaya","miskin","pintar","bodoh","cantik","jelek","baik","buruk","senang","sedih","marah","takut","berani","malas","rajin","sabar","emosi"}
        for _, kata in ipairs(fallback) do
            table.insert(KAMUS, kata)
            local hurufAwal = string.sub(kata, 1, 1)
            if not KAMUS_BY_HURUF[hurufAwal] then
                KAMUS_BY_HURUF[hurufAwal] = {}
            end
            table.insert(KAMUS_BY_HURUF[hurufAwal], kata)
        end
        print("[KAMUS] Using fallback dictionary")
        return false
    end
end

-- Fungsi cari kata lanjutan
local function CariKataLanjutan(kataSebelum)
    if not kataSebelum or kataSebelum == "" then return nil end
    local hurufTerakhir = string.lower(string.sub(kataSebelum, -1, -1))
    local kandidat = KAMUS_BY_HURUF[hurufTerakhir]
    if not kandidat or #kandidat == 0 then return nil end
    -- Pilih kata acak yang tidak sama dengan sebelumnya
    local maxAttempts = 20
    for attempt = 1, maxAttempts do
        local idx = math.random(1, #kandidat)
        local calon = kandidat[idx]
        if calon ~= kataSebelum then
            return calon
        end
    end
    return kandidat[math.random(1, #kandidat)]
end

-- =================================================================
-- DETEKSI ELEMEN GAME (AGGRESSIVE)
-- =================================================================
local function ScanGameElements()
    local results = {
        wordLabel = nil,
        inputBox = nil,
        submitButton = nil
    }
    
    -- Scan semua ScreenGui di PlayerGui
    for _, gui in ipairs(PlayerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Enabled then
            -- Cari TextLabel besar yang kemungkinan kata
            for _, v in ipairs(gui:GetDescendants()) do
                if v:IsA("TextLabel") and v.Visible and v.Text and #v.Text > 0 then
                    -- Filter: teks hanya huruf, panjang antara 2-20 karakter
                    if string.match(v.Text, "^[%a%s]+$") and #v.Text >= 2 and #v.Text <= 25 then
                        local text = string.gsub(v.Text, "^%s*(.-)%s*$", "%1")
                        if #text >= 2 then
                            results.wordLabel = v
                            break
                        end
                    end
                end
            end
            
            -- Cari TextBox (input)
            for _, v in ipairs(gui:GetDescendants()) do
                if v:IsA("TextBox") and v.Visible then
                    results.inputBox = v
                    break
                end
            end
            
            -- Cari tombol submit (TextButton dengan teks pendek)
            for _, v in ipairs(gui:GetDescendants()) do
                if v:IsA("TextButton") and v.Visible then
                    local btnText = string.lower(v.Text)
                    if btnText == "jawab" or btnText == "submit" or btnText == "kirim" or btnText == "ok" or btnText == "enter" then
                        results.submitButton = v
                        break
                    end
                end
            end
        end
        if results.wordLabel and results.inputBox then break end
    end
    
    return results
end

-- =================================================================
-- VARIABEL STATE
-- =================================================================
local ENABLED = false
local lastProcessedWord = ""
local currentWordLabel = nil
local currentInputBox = nil
local currentSubmitBtn = nil
local lastScanTime = 0
local SCAN_COOLDOWN = 2  -- scan ulang setiap 2 detik jika elemen hilang

-- =================================================================
-- FUNGSI UTAMA AUTO ANSWER
-- =================================================================
local function AutoAnswer()
    if not ENABLED then return end
    
    -- Scan elemen secara berkala
    if not currentWordLabel or not currentInputBox or tick() - lastScanTime > SCAN_COOLDOWN then
        local elements = ScanGameElements()
        currentWordLabel = elements.wordLabel
        currentInputBox = elements.inputBox
        currentSubmitBtn = elements.submitButton
        lastScanTime = tick()
        
        -- Debug
        if currentWordLabel then print("[DEBUG] Word:", currentWordLabel.Text) end
        if currentInputBox then print("[DEBUG] Input box ditemukan") end
    end
    
    if not currentWordLabel or not currentInputBox then
        -- Elemen belum ditemukan
        return
    end
    
    -- Ambil kata saat ini
    local currentWord = currentWordLabel.Text
    currentWord = string.gsub(currentWord, "^%s*(.-)%s*$", "%1")
    currentWord = string.lower(currentWord)
    
    if currentWord == "" or currentWord == lastProcessedWord then
        return -- kata sama atau kosong
    end
    
    -- Cari kata lanjutan
    local nextWord = CariKataLanjutan(currentWord)
    if nextWord then
        -- Isi input box
        currentInputBox.Text = nextWord
        
        -- Kirim event Enter (simulasi tekan tombol)
        task.wait(0.1)
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, nil)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, nil)
        
        -- Alternatif: klik tombol submit jika ada
        if currentSubmitBtn then
            task.wait(0.1)
            currentSubmitBtn:Click()
        end
        
        lastProcessedWord = currentWord
        print("[ANSWER]", currentWord, "->", nextWord)
    end
end

-- =================================================================
-- GUI
-- =================================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AutoSambungKataReal"
ScreenGui.Parent = parentGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Frame utama
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

-- Sudut
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

-- Header
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

-- Close button
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

-- Minimize button
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

-- Separator
local Separator = Instance.new("Frame")
Separator.Size = UDim2.new(1, -20, 0, 1)
Separator.Position = UDim2.new(0, 10, 0, 35)
Separator.BackgroundColor3 = Color3.new(1, 1, 1)
Separator.BorderSizePixel = 0
Separator.Parent = MainFrame

-- Content
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -20, 1, -45)
Content.Position = UDim2.new(0, 10, 0, 40)
Content.BackgroundTransparency = 1
Content.Parent = MainFrame

-- Toggle button
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

-- Info text
local Info = Instance.new("TextLabel")
Info.Size = UDim2.new(1, 0, 0, 30)
Info.Position = UDim2.new(0, 0, 0, 45)
Info.BackgroundTransparency = 1
Info.Text = "Automatically fill in conjunctions"
Info.TextColor3 = Color3.new(1, 1, 1)
Info.Font = Enum.Font.SourceSans
Info.TextSize = 13
Info.Parent = Content

-- Credit
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
-- FUNGSI MINIMIZE
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
        -- Reset last processed agar langsung merespon
        lastProcessedWord = ""
        print("[STATUS] Auto answer ENABLED")
    else
        ToggleBtn.Text = "OFF"
        ToggleBtn.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
        print("[STATUS] Auto answer DISABLED")
    end
end)

-- =================================================================
-- LOAD KAMUS DAN MULAI LOOP
-- =================================================================
LoadKamus()

-- Loop utama
task.spawn(function()
    while true do
        task.wait(0.5)  -- cek setiap 0.5 detik
        pcall(AutoAnswer)
    end
end)

print("=== AUTO SAMBUNG KATA REAL READY ===")
print("Tekan tombol ON untuk memulai")
print("Jika tidak work, cek console (F9) untuk debug")
