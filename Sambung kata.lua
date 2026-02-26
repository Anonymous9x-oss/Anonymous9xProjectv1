-- =================================================================
-- AUTO SAMBUNG KATA v10 - Anonymous9x
-- FIX: "Hurufnya adalah: IS" -> cari kata DIAWALI "IS"
-- Engine: getconnections Activated (CONFIRMED WORK)
-- =================================================================

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local parentGui = CoreGui or PlayerGui

if parentGui:FindFirstChild("AutoSambungKataReal") then
    parentGui.AutoSambungKataReal:Destroy()
end

-- =================================================================
-- KAMUS
-- =================================================================
local KAMUS = {}
local KAMUS_BY_HURUF = {}

local function LoadKamus()
    local ok, res = pcall(function()
        return game:HttpGet("https://raw.githubusercontent.com/eenvyexe/KBBI/refs/heads/main/words.txt")
    end)
    if ok and res and #res > 100 then
        local unique = {}
        for line in res:gmatch("[^\r\n]+") do
            local kata = line:match("([%a]+)")
            if kata and #kata >= 2 then
                kata = kata:lower()
                if not unique[kata] then
                    unique[kata] = true
                    table.insert(KAMUS, kata)
                    local h = kata:sub(1,1)
                    if not KAMUS_BY_HURUF[h] then KAMUS_BY_HURUF[h] = {} end
                    table.insert(KAMUS_BY_HURUF[h], kata)
                end
            end
        end
        print("[KAMUS] " .. #KAMUS .. " kata loaded")
    else
        local fb = {"aku","kamu","dia","itu","ini","ada","dan","yang","dengan","untuk","angin","bumi","api","langit","laut","hutan","gunung","sungai","danau","kota","desa","jalan","rumah","pintu","kursi","meja","buku","makan","minum","tidur","duduk","berjalan","berlari","naik","turun","masuk","keluar","pergi","datang","beli","jual","baca","tulis","bicara","tertawa","senyum","bahagia","gembira","indah","cantik","gagah","elok","tulus","setia","jujur","adil","bijak","cerdas","pandai","rajin","tekun","sabar","tabah","tegar","berani","cinta","kasih","sayang","rindu","ingat","tahu","paham","rasa","hati","jiwa","hidup","tangan","kaki","mata","telinga","hidung","mulut","rambut","wajah","ibu","ayah","anak","adik","kakak","nenek","teman","guru","nama","warna","merah","biru","hijau","putih","hitam","kuning","pagi","siang","malam","hari","bulan","tahun","dalam","luar","atas","bawah","depan","belakang","kiri","kanan","dekat","jauh","cepat","lambat","besar","kecil","tinggi","rendah","panjang","pendek","berat","ringan","panas","dingin","bersih","kotor","baru","lama","baik","buruk","senang","sedih","marah","takut","isap","isak","iseng","isi","islam","isra","istri","istana","iskemia","isobar","isomer","isyarat","ispaya","menang","menari","menarik","menata","mendapat","mendalam","mengapa","mengajak","mengaku","mengambil","mengatur","mengawali","mengeja","mengeras","menggunakan","menghitung","mengirim","menuju","menumpuk","menulis","menyambung","menyapa","menyatu","merah","merasa","merawat","merdeka","merebut","mereka","meriah","merintis","merobek","meronce"}
        for _, kata in ipairs(fb) do
            kata = kata:lower()
            local unique_check = true
            for _, k in ipairs(KAMUS) do
                if k == kata then unique_check = false break end
            end
            if unique_check then
                table.insert(KAMUS, kata)
                local h = kata:sub(1,1)
                if not KAMUS_BY_HURUF[h] then KAMUS_BY_HURUF[h] = {} end
                table.insert(KAMUS_BY_HURUF[h], kata)
            end
        end
        print("[KAMUS] Fallback: " .. #KAMUS)
    end
end

-- =================================================================
-- CARI KATA BERDASARKAN AWALAN
-- "Hurufnya adalah: IS" -> cari kata yang dimulai "is..."
-- "Hurufnya adalah: I"  -> cari kata yang dimulai "i..."
-- =================================================================
local usedWords = {}  -- hindari kata yang sudah dipakai

local function CariKataAwalan(awalan)
    awalan = awalan:lower()
    local hasil = {}
    
    for _, kata in ipairs(KAMUS) do
        if kata:sub(1, #awalan) == awalan 
           and not kata:find("%-") 
           and #kata >= #awalan + 1
           and not usedWords[kata] then
            table.insert(hasil, kata)
        end
    end
    
    if #hasil > 0 then
        local pilihan = hasil[math.random(1, #hasil)]
        usedWords[pilihan] = true
        return pilihan
    end
    
    -- Fallback: cari dari huruf pertama awalan saja
    if #awalan > 1 then
        local h = awalan:sub(1,1)
        local list = KAMUS_BY_HURUF[h]
        if list and #list > 0 then
            for i = 1, 50 do
                local c = list[math.random(1, #list)]
                if not c:find("%-") and not usedWords[c] then
                    usedWords[c] = true
                    return c
                end
            end
        end
    end
    
    return nil
end

-- =================================================================
-- GETCONNECTIONS ENGINE (CONFIRMED WORK DI v8)
-- =================================================================
local function DeltaKlik(button)
    if not button or not button.Parent then return false end
    local ok = false

    pcall(function()
        if getconnections then
            -- Coba Activated dulu (v8 confirmed work pakai ini)
            local conns = getconnections(button.Activated)
            if conns and #conns > 0 then
                for _, c in ipairs(conns) do
                    pcall(function() c.Function() end)
                end
                ok = true
                return
            end
            -- Fallback MouseButton1Click
            conns = getconnections(button.MouseButton1Click)
            if conns and #conns > 0 then
                for _, c in ipairs(conns) do
                    pcall(function() c.Function() end)
                end
                ok = true
            end
        end
    end)

    if not ok then
        pcall(function() button.MouseButton1Click:Fire() end)
        pcall(function() button.Activated:Fire() end)
        pcall(function() button:Click() end)
    end

    return ok
end

-- =================================================================
-- SCAN KEYBOARD
-- =================================================================
local keyCache = {}
local masukCache = nil
local cacheTime = 0

local function ScanKeyboard()
    if tick() - cacheTime < 2 and next(keyCache) ~= nil then
        return keyCache, masukCache
    end

    local keys = {}
    local tombolMasuk = nil

    for _, gui in ipairs(PlayerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Enabled and gui.Name ~= "AutoSambungKataReal" then
            for _, v in ipairs(gui:GetDescendants()) do
                if v:IsA("TextButton") and v.Visible then
                    local t = v.Text:match("^%s*(.-)%s*$")
                    if #t == 1 and t:match("^[a-zA-Z]$") then
                        keys[t:lower()] = v
                    end
                    local tl = t:lower()
                    if tl == "masuk" or tl == "jawab" or tl == "kirim" or tl == "submit" or tl == "enter" then
                        tombolMasuk = v
                    end
                end
            end
        end
    end

    keyCache = keys
    masukCache = tombolMasuk
    cacheTime = tick()

    local jk = 0
    for _ in pairs(keys) do jk = jk + 1 end
    print("[KEY] " .. jk .. " tombol | Masuk: " .. (tombolMasuk and tombolMasuk.Text or "?"))
    return keys, tombolMasuk
end

-- =================================================================
-- KETIK KATA
-- =================================================================
local DELAY_HURUF = 0.06  -- jeda antar huruf (bisa dikurangi)

local function KetikKata(kata, keys, tombolMasuk)
    kata = kata:lower()
    print("[KETIK] >> '" .. kata .. "'")

    for i = 1, #kata do
        local huruf = kata:sub(i, i)
        local btn = keys[huruf]
        if btn and btn.Parent then
            DeltaKlik(btn)
            task.wait(DELAY_HURUF)
        else
            -- Coba tombol cadangan A (sesuai UI game ada "Tombol cadangan huruf A")
            if huruf == "a" then
                -- Cari tombol cadangan A
                for _, gui in ipairs(PlayerGui:GetChildren()) do
                    if gui:IsA("ScreenGui") and gui.Enabled and gui.Name ~= "AutoSambungKataReal" then
                        for _, v in ipairs(gui:GetDescendants()) do
                            if v:IsA("TextButton") and v.Visible then
                                local path = v:GetFullName():lower()
                                if path:find("cadangan") or (v.Text:match("^%s*A%s*$") and v.Size.X.Offset < 80) then
                                    DeltaKlik(v)
                                    break
                                end
                            end
                        end
                    end
                end
            end
            task.wait(DELAY_HURUF)
        end
    end

    task.wait(0.12)
    if tombolMasuk and tombolMasuk.Parent then
        print("[SUBMIT] Masuk!")
        DeltaKlik(tombolMasuk)
    end
end

-- =================================================================
-- DETEKSI KATA GAME - PERBAIKAN UTAMA
-- Fokus: "Hurufnya adalah: IS" -> awalan = "IS"
-- =================================================================
local function DeteksiKata()
    for _, gui in ipairs(PlayerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Enabled and gui.Name ~= "AutoSambungKataReal" then
            for _, v in ipairs(gui:GetDescendants()) do
                if v:IsA("TextLabel") and v.Visible then
                    local txt = v.Text

                    -- === PATTERN UTAMA: "Hurufnya adalah: IS" ===
                    -- TextLabel teks "Hurufnya adalah:" + TextLabel/Frame sebelahnya berisi "IS"
                    if txt:find("[Hh]uruf") and txt:find("[Aa]dalah") then
                        -- Cek apakah awalan ada di teks yang sama
                        local awalan = txt:match("[Aa]dalah[%s:]*([A-Za-z]+)")
                        if awalan and #awalan >= 1 then
                            return awalan:lower()
                        end

                        -- Cari di sibling/children Frame
                        local parent = v.Parent
                        if parent then
                            for _, sibling in ipairs(parent:GetChildren()) do
                                if sibling ~= v then
                                    -- TextLabel sibling
                                    if sibling:IsA("TextLabel") and sibling.Visible then
                                        local st = sibling.Text:match("^%s*([A-Za-z]+)%s*$")
                                        if st and #st >= 1 and #st <= 5 then
                                            return st:lower()
                                        end
                                    end
                                    -- Frame yang berisi huruf-huruf kotak
                                    if sibling:IsA("Frame") then
                                        local combined = ""
                                        for _, child in ipairs(sibling:GetChildren()) do
                                            if child:IsA("TextLabel") then
                                                local ct = child.Text:match("^%s*([A-Za-z])%s*$")
                                                if ct then combined = combined .. ct end
                                            end
                                        end
                                        if #combined >= 1 then
                                            return combined:lower()
                                        end
                                    end
                                end
                            end
                        end
                    end
                    
                    -- === Kotak huruf di atas (seperti screenshot "I S P A Y A") ===
                    -- Ini adalah TextLabel yang teksnya 1 huruf dalam grid/frame
                end
            end
        end
    end

    -- === FALLBACK: Baca kotak huruf yang ditampilkan di tengah layar ===
    -- Screenshot menunjukkan huruf-huruf dalam kotak putih individual (I S P A Y A)
    -- dan di bawahnya "Hurufnya adalah: IS"
    -- Kita baca label "Hurufnya adalah: XX" tapi XX mungkin di TextLabel terpisah
    
    for _, gui in ipairs(PlayerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Enabled and gui.Name ~= "AutoSambungKataReal" then
            for _, v in ipairs(gui:GetDescendants()) do
                if v:IsA("TextLabel") and v.Visible then
                    local txt = v.Text:match("^%s*(.-)%s*$")
                    -- Label pendek 2-4 huruf ALL CAPS = awalan yang diberikan game
                    if txt:match("^[A-Z][A-Z]?[A-Z]?[A-Z]?$") and #txt >= 1 and #txt <= 4 then
                        local SKIP = {ON=1,OFF=1,OK=1,AI=1,GO=1,NO=1}
                        if not SKIP[txt] then
                            -- Cek apakah parent-nya ada label "Huruf"
                            local parent = v.Parent
                            if parent then
                                for _, sib in ipairs(parent:GetChildren()) do
                                    if sib:IsA("TextLabel") and sib.Text:find("[Hh]uruf") then
                                        return txt:lower()
                                    end
                                end
                            end
                            return txt:lower()
                        end
                    end
                end
            end
        end
    end

    return nil
end

-- =================================================================
-- MAIN STATE
-- =================================================================
local ENABLED = false
local lastAwalan = ""
local lastTime = 0
local COOLDOWN = 1.5
local proses = false

local function MainLoop()
    if not ENABLED or proses then return end
    if tick() - lastTime < COOLDOWN then return end

    local awalan = DeteksiKata()
    if not awalan then return end

    -- Reset usedWords kalau awalan berubah
    if awalan ~= lastAwalan then
        usedWords = {}
        print("[NEW] Awalan baru: '" .. awalan .. "'")
    end

    if awalan == lastAwalan and tick() - lastTime < 3 then return end

    local jawaban = CariKataAwalan(awalan)
    if not jawaban then
        print("[SKIP] Tidak ada kata untuk awalan: '" .. awalan .. "'")
        lastAwalan = awalan
        lastTime = tick()
        return
    end

    print("==============================")
    print("[FLASH] Awalan: '" .. awalan .. "' -> Jawab: '" .. jawaban .. "'")
    print("==============================")

    proses = true
    lastAwalan = awalan

    task.spawn(function()
        local keys, tombolMasuk = ScanKeyboard()
        local jk = 0
        for _ in pairs(keys) do jk = jk + 1 end

        if jk < 10 then
            print("[ERROR] Keyboard tidak terdeteksi!")
            proses = false
            lastTime = tick()
            return
        end

        KetikKata(jawaban, keys, tombolMasuk)
        lastTime = tick()
        proses = false
    end)
end

-- =================================================================
-- GUI TIDAK DIUBAH
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
        lastAwalan = ""
        lastTime = 0
        proses = false
        usedWords = {}
        print("[ON] v10 aktif - Awalan mode fix!")
        task.spawn(ScanKeyboard)
    else
        ToggleBtn.Text = "OFF"
        ToggleBtn.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
        proses = false
        print("[OFF]")
    end
end)

-- =================================================================
-- DIAGNOSTIC: Tambahan print untuk debug deteksi kata
-- =================================================================
task.spawn(function()
    task.wait(3)
    -- Print semua TextLabel yang relevan untuk debug
    print("[DEBUG] Scan label 'Huruf':")
    for _, gui in ipairs(PlayerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Enabled and gui.Name ~= "AutoSambungKataReal" then
            for _, v in ipairs(gui:GetDescendants()) do
                if v:IsA("TextLabel") and v.Visible then
                    local txt = v.Text:match("^%s*(.-)%s*$")
                    if txt:find("[Hh]uruf") or txt:match("^[A-Z][A-Z]+$") then
                        print("  >> '" .. txt .. "' | path: " .. v:GetFullName())
                    end
                end
            end
        end
    end
end)

-- =================================================================
-- START
-- =================================================================
LoadKamus()

task.spawn(function()
    while true do
        task.wait(0.25)
        pcall(MainLoop)
    end
end)

print("=== AUTO SAMBUNG KATA v10 - AWALAN FIX ===")
print("Tekan ON | Lihat [FLASH] Awalan: 'IS' -> Jawab: 'isap'")
