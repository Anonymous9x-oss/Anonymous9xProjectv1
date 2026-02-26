-- =================================================================
-- Nama Script : Auto Sambung Kata (Game Roblox)
-- Author      : Anonymous9x
-- Description : Otomatis mendeteksi kata dan mengisi jawaban
-- Fitur       : GUI hitam dengan border putih, toggle on/off
-- =================================================================

-- Services
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local parentGui = CoreGui or LocalPlayer:WaitForChild("PlayerGui")

-- Hapus GUI lama jika ada
if parentGui:FindFirstChild("AutoSambungKata") then
    parentGui.AutoSambungKata:Destroy()
end

-- =================================================================
-- KONFIGURASI
-- =================================================================
local ENABLED = false
local DICTIONARY_URL = "https://raw.githubusercontent.com/eenvyexe/KBBI/refs/heads/main/words.txt"
local DICTIONARY = {}          -- Semua kata
local WORDS_BY_FIRST_LETTER = {} -- Indeks kata berdasarkan huruf pertama
local SCAN_INTERVAL = 0.5       -- Detik
local lastWord = ""             -- Kata terakhir yang diproses
local currentWordLabel = nil    -- Referensi ke label kata
local inputTextBox = nil        -- Referensi ke kotak input

-- =================================================================
-- FUNGSI MEMUAT KAMUS
-- =================================================================
local function loadDictionary()
    local success, response = pcall(function()
        return game:HttpGet(DICTIONARY_URL)
    end)
    if success and response then
        local unique = {}
        for line in string.gmatch(response, "[^\r\n]+") do
            local word = string.match(line, "([%a%-]+)")
            if word and #word > 1 then
                word = string.lower(word)
                if not unique[word] then
                    unique[word] = true
                    table.insert(DICTIONARY, word)
                    local first = string.sub(word, 1, 1)
                    if not WORDS_BY_FIRST_LETTER[first] then
                        WORDS_BY_FIRST_LETTER[first] = {}
                    end
                    table.insert(WORDS_BY_FIRST_LETTER[first], word)
                end
            end
        end
        return true
    else
        warn("Gagal memuat kamus, menggunakan daftar kecil cadangan.")
        -- Fallback sederhana
        local fallback = {"aku", "kamu", "dia", "makan", "minum", "tidur", "jalan", "rumah", "mobil", "buku", "pensil", "meja", "kursi"}
        for _, w in ipairs(fallback) do
            table.insert(DICTIONARY, w)
            local first = string.sub(w, 1, 1)
            if not WORDS_BY_FIRST_LETTER[first] then
                WORDS_BY_FIRST_LETTER[first] = {}
            end
            table.insert(WORDS_BY_FIRST_LETTER[first], w)
        end
        return false
    end
end

-- =================================================================
-- FUNGSI MENCARI KATA BERIKUTNYA
-- =================================================================
local function getNextWord(previous)
    if not previous or previous == "" then return nil end
    local lastChar = string.lower(string.sub(previous, -1, -1))
    local candidates = WORDS_BY_FIRST_LETTER[lastChar]
    if not candidates or #candidates == 0 then return nil end
    -- Pilih kata acak yang tidak sama dengan sebelumnya (opsional)
    local randomIndex = math.random(1, #candidates)
    return candidates[randomIndex]
end

-- =================================================================
-- FUNGSI MENDETEKSI ELEMEN GAME
-- =================================================================
local function findGameElements()
    -- Coba cari label kata di PlayerGui (asumsi ada TextLabel besar)
    for _, gui in ipairs(LocalPlayer:WaitForChild("PlayerGui"):GetChildren()) do
        if gui:IsA("ScreenGui") then
            for _, v in ipairs(gui:GetDescendants()) do
                if v:IsA("TextLabel") and v.Visible and #v.Text > 1 then
                    -- Heuristik: kemungkinan kata adalah label dengan font besar dan teks tidak panjang
                    if v.TextBounds.Y > 30 and string.match(v.Text, "^[%a]+$") then
                        currentWordLabel = v
                        break
                    end
                end
            end
        end
        if currentWordLabel then break end
    end

    -- Cari kotak input (TextBox)
    if not inputTextBox then
        for _, gui in ipairs(LocalPlayer:WaitForChild("PlayerGui"):GetChildren()) do
            if gui:IsA("ScreenGui") then
                for _, v in ipairs(gui:GetDescendants()) do
                    if v:IsA("TextBox") and v.Visible then
                        inputTextBox = v
                        break
                    end
                end
            end
            if inputTextBox then break end
        end
    end
end

-- =================================================================
-- FUNGSI OTOMATIS ISI JAWABAN
-- =================================================================
local function autoFill()
    if not ENABLED then return end
    if not currentWordLabel or not inputTextBox then
        findGameElements()
        if not currentWordLabel or not inputTextBox then
            return -- belum ditemukan, coba lagi nanti
        end
    end

    local word = currentWordLabel.Text
    word = string.gsub(word, "^%s*(.-)%s*$", "%1") -- trim
    if word == "" or word == lastWord then return end

    local nextWord = getNextWord(word)
    if nextWord then
        -- Ketik jawaban
        inputTextBox.Text = nextWord
        -- Simulasikan tekan Enter
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, nil)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, nil)
        lastWord = word
    end
end

-- =================================================================
-- MEMBUAT GUI
-- =================================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AutoSambungKata"
ScreenGui.Parent = parentGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Frame utama (hitam, border putih)
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 220, 0, 140)
MainFrame.Position = UDim2.new(0.5, -110, 0.5, -70)
MainFrame.BackgroundColor3 = Color3.new(0, 0, 0)
MainFrame.BorderColor3 = Color3.new(1, 1, 1)
MainFrame.BorderSizePixel = 2
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

-- Sudut membulat (opsional)
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

-- Header (judul)
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

-- Tombol Close (X)
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 25, 0, 25)
CloseBtn.Position = UDim2.new(1, -30, 0, 5)
CloseBtn.BackgroundColor3 = Color3.new(0.8, 0, 0)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.new(1, 1, 1)
CloseBtn.Font = Enum.Font.SourceSansBold
CloseBtn.TextSize = 16
CloseBtn.Parent = MainFrame
local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 4)
CloseCorner.Parent = CloseBtn

-- Tombol Minimize (-)
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 25, 0, 25)
MinBtn.Position = UDim2.new(1, -60, 0, 5)
MinBtn.BackgroundColor3 = Color3.new(0.6, 0.6, 0.6)
MinBtn.Text = "-"
MinBtn.TextColor3 = Color3.new(1, 1, 1)
MinBtn.Font = Enum.Font.SourceSansBold
MinBtn.TextSize = 16
MinBtn.Parent = MainFrame
local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 4)
MinCorner.Parent = MinBtn

-- Garis pemisah
local Separator = Instance.new("Frame")
Separator.Size = UDim2.new(1, -20, 0, 1)
Separator.Position = UDim2.new(0, 10, 0, 35)
Separator.BackgroundColor3 = Color3.new(1, 1, 1)
Separator.BorderSizePixel = 0
Separator.Parent = MainFrame

-- Konten dalam panel
local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, -20, 1, -45)
ContentFrame.Position = UDim2.new(0, 10, 0, 40)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

-- Toggle On/Off
local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 80, 0, 30)
ToggleButton.Position = UDim2.new(0.5, -40, 0, 10)
ToggleButton.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
ToggleButton.Text = "OFF"
ToggleButton.TextColor3 = Color3.new(1, 1, 1)
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.TextSize = 16
ToggleButton.Parent = ContentFrame
local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 4)
ToggleCorner.Parent = ToggleButton

-- Teks info
local InfoText = Instance.new("TextLabel")
InfoText.Size = UDim2.new(1, 0, 0, 40)
InfoText.Position = UDim2.new(0, 0, 0, 45)
InfoText.BackgroundTransparency = 1
InfoText.Text = "Automatically fill in conjunctions"
InfoText.TextColor3 = Color3.new(1, 1, 1)
InfoText.Font = Enum.Font.SourceSans
InfoText.TextSize = 12
InfoText.TextWrapped = true
InfoText.Parent = ContentFrame

-- Credit
local Credit = Instance.new("TextLabel")
Credit.Size = UDim2.new(1, 0, 0, 20)
Credit.Position = UDim2.new(0, 0, 1, -20)
Credit.BackgroundTransparency = 1
Credit.Text = "Created By Anonymous9x"
Credit.TextColor3 = Color3.new(1, 1, 1)
Credit.Font = Enum.Font.SourceSans
Credit.TextSize = 10
Credit.TextXAlignment = Enum.TextXAlignment.Right
Credit.Parent = ContentFrame

-- =================================================================
-- FUNGSI MINIMIZE
-- =================================================================
local minimized = false
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        MainFrame.Size = UDim2.new(0, 220, 0, 40)
        ContentFrame.Visible = false
        MinBtn.Text = "+"
    else
        MainFrame.Size = UDim2.new(0, 220, 0, 140)
        ContentFrame.Visible = true
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
ToggleButton.MouseButton1Click:Connect(function()
    ENABLED = not ENABLED
    if ENABLED then
        ToggleButton.Text = "ON"
        ToggleButton.BackgroundColor3 = Color3.new(0, 0.6, 0)
    else
        ToggleButton.Text = "OFF"
        ToggleButton.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
    end
end)

-- =================================================================
-- INISIALISASI: LOAD KAMUS DAN MULAI LOOP
-- =================================================================
loadDictionary()

-- Loop utama
task.spawn(function()
    while true do
        task.wait(SCAN_INTERVAL)
        if ENABLED then
            pcall(autoFill)
        end
    end
end)

-- Notifikasi
print("Auto Sambung Kata siap. Tekan tombol ON untuk memulai.")
