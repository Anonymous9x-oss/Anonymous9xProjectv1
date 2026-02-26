-- =================================================================
-- AUTO SAMBUNG KATA v8 - Anonymous9x
-- DELTA iOS ENGINE: getconnections direct function invoke
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
        print("[KAMUS] OK: " .. #KAMUS .. " kata")
    else
        local fb = {
            "aku","kamu","dia","itu","ini","ada","dan","yang","dengan","untuk",
            "angin","bumi","api","langit","laut","hutan","gunung","sungai","danau",
            "kota","desa","jalan","rumah","pintu","kursi","meja","buku","makan",
            "minum","tidur","duduk","berjalan","berlari","naik","turun","masuk",
            "keluar","pergi","datang","beli","jual","baca","tulis","bicara",
            "tertawa","senyum","bahagia","gembira","indah","cantik","gagah",
            "tulus","setia","jujur","adil","bijak","cerdas","pandai","rajin",
            "tekun","sabar","tabah","tegar","berani","cinta","kasih","sayang",
            "rindu","ingat","tahu","paham","rasa","hati","jiwa","hidup",
            "tangan","kaki","mata","telinga","hidung","mulut","rambut","wajah",
            "nasi","air","ikan","ayam","daging","sayur","buah","gula","garam",
            "ibu","ayah","anak","adik","kakak","nenek","kakek","teman","guru",
            "nama","nomor","warna","merah","biru","hijau","putih","hitam","kuning",
            "pagi","siang","malam","hari","bulan","tahun","waktu","saat","lama",
            "besar","kecil","tinggi","rendah","panjang","pendek","berat","ringan",
            "panas","dingin","basah","kering","bersih","kotor","baru","lama",
            "rapi","baik","buruk","senang","sedih","marah","takut","lelah",
            "dalam","luar","atas","bawah","depan","belakang","kiri","kanan",
            "dekat","jauh","cepat","lambat","keras","pelan","penuh","kosong",
            "umur","usaha","upaya","ujung","udara","ulang","uang","unggas",
            "niat","nilai","negara","nyata","nada","napas",
            "tanah","tumbuh","tulis","tujuan","tenang","terima","tolong",
            "pohon","panjang","perlu","pikir","putus","pasang","paham","pintar",
            "langkah","libur","lemah","lepas","letak","lurus","logam",
            "keras","kuasa","kasur","kebun","kejar","kerja","kepala",
            "harap","harga","hasil","hubung","habis","hadap",
            "gempa","getaran","gerak","guna","gelap","gembira",
            "jarak","jawab","jelas","jinak","jual","jaga","jenis",
            "faham","fokus","fungsi",
            "sama","sejuk","sehat","semua","sering","selalu","sudah",
            "diam","dalam","dasar","dekat","dapat","damai",
            "mulai","mudah","muda","mula","mimpi","maju","makan",
            "bantu","bangsa","bawah","bayar","benar","besar","bijak",
            "alam","alur","arah","awal","ambil","antar","aman","asli",
            "cahaya","cepat","cerita","cinta","cobaan","campur",
            "rasa","rajin","ringan","ruang","ramai","rendah",
            "olah","obat","orang",
            "kuat","kurang","kursi","kunci","kumpul","kulit","kembang",
            "ingin","ikut","ilmu","iman","indah",
            "wajah","waktu","wajar","warna","warga","warisan",
            "zaman","zona",
        }
        for _, kata in ipairs(fb) do
            kata = kata:lower()
            table.insert(KAMUS, kata)
            local h = kata:sub(1,1)
            if not KAMUS_BY_HURUF[h] then KAMUS_BY_HURUF[h] = {} end
            table.insert(KAMUS_BY_HURUF[h], kata)
        end
        print("[KAMUS] Fallback: " .. #KAMUS)
    end
end

local function CariKataAwalan(awalan)
    awalan = awalan:lower()
    local hasil = {}
    for _, kata in ipairs(KAMUS) do
        if kata:sub(1, #awalan) == awalan and not kata:find("%-") and #kata >= 2 then
            table.insert(hasil, kata)
        end
    end
    if #hasil > 0 then return hasil[math.random(1, math.min(#hasil, 50))] end
    -- fallback: cari yang dimulai huruf pertama saja
    local h = awalan:sub(1,1)
    local list = KAMUS_BY_HURUF[h]
    if list and #list > 0 then
        for i = 1, 30 do
            local c = list[math.random(1, #list)]
            if not c:find("%-") then return c end
        end
    end
    return nil
end

local function CariKataLanjut(kataSebelum)
    local huruf = kataSebelum:lower():sub(-1)
    local list = KAMUS_BY_HURUF[huruf]
    if not list or #list == 0 then return nil end
    for i = 1, 60 do
        local c = list[math.random(1, #list)]
        if c ~= kataSebelum and not c:find("%-") then return c end
    end
    return nil
end

-- =================================================================
-- DELTA iOS: INVOKE LANGSUNG PAKAI getconnections
-- =================================================================
local function DeltaKlik(button)
    if not button or not button.Parent then return false end
    local berhasil = false

    -- === CARA 1: getconnections MouseButton1Click ===
    pcall(function()
        local conns = getconnections(button.MouseButton1Click)
        if conns and #conns > 0 then
            for _, c in ipairs(conns) do
                pcall(c.Function)
            end
            berhasil = true
            print("[DELTA] getconnections MouseButton1Click OK - " .. (button.Text or "?"))
        end
    end)

    if berhasil then return true end

    -- === CARA 2: getconnections Activated ===
    pcall(function()
        local conns = getconnections(button.Activated)
        if conns and #conns > 0 then
            for _, c in ipairs(conns) do
                pcall(c.Function)
            end
            berhasil = true
            print("[DELTA] getconnections Activated OK - " .. (button.Text or "?"))
        end
    end)

    if berhasil then return true end

    -- === CARA 3: getconnections MouseButton1Down ===
    pcall(function()
        local conns = getconnections(button.MouseButton1Down)
        if conns and #conns > 0 then
            for _, c in ipairs(conns) do
                pcall(c.Function)
            end
            berhasil = true
        end
    end)

    if berhasil then return true end

    -- === CARA 4: Fire events langsung ===
    pcall(function()
        button.MouseButton1Click:Fire()
        berhasil = true
    end)
    pcall(function()
        button.Activated:Fire(LocalPlayer, UDim2.new(), 1)
    end)
    pcall(function()
        button:Click()
    end)

    return berhasil
end

-- =================================================================
-- SCAN KEYBOARD
-- =================================================================
local keyCache = {}
local masukCache = nil
local lastScanTime = 0

local function ScanKeyboard()
    -- Cache 1 detik supaya cepat
    if tick() - lastScanTime < 1 and next(keyCache) ~= nil then
        return keyCache, masukCache
    end

    local keys = {}
    local tombolMasuk = nil

    for _, gui in ipairs(PlayerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Enabled and gui.Name ~= "AutoSambungKataReal" then
            for _, v in ipairs(gui:GetDescendants()) do
                if v:IsA("TextButton") and v.Visible then
                    local t = v.Text:match("^%s*(.-)%s*$")
                    -- Huruf tunggal A-Z
                    if #t == 1 and t:match("^[a-zA-Z]$") then
                        keys[t:lower()] = v
                    end
                    -- Tombol submit
                    local tl = t:lower()
                    if tl == "masuk" or tl == "jawab" or tl == "kirim" or tl == "submit" or tl == "enter" or tl == "send" or tl == "ok" then
                        tombolMasuk = v
                    end
                end
            end
        end
    end

    keyCache = keys
    masukCache = tombolMasuk
    lastScanTime = tick()

    local jk = 0
    for _ in pairs(keys) do jk = jk + 1 end
    print("[SCAN] Keyboard: " .. jk .. " tombol | Masuk: " .. (tombolMasuk and tombolMasuk.Text or "NOT FOUND"))

    return keys, tombolMasuk
end

-- =================================================================
-- KETIK KATA
-- =================================================================
local function KetikKata(kata, keys, tombolMasuk)
    kata = kata:lower()
    print("[KETIK] >> " .. kata)

    for i = 1, #kata do
        local huruf = kata:sub(i, i)
        local tombol = keys[huruf]

        if tombol and tombol.Parent then
            DeltaKlik(tombol)
            task.wait(0.07)
        else
            print("[MISS] '" .. huruf .. "' tidak ditemukan")
        end
    end

    task.wait(0.15)

    if tombolMasuk and tombolMasuk.Parent then
        print("[SUBMIT] Klik Masuk...")
        DeltaKlik(tombolMasuk)
        print("[SUBMIT] Done!")
    else
        print("[WARN] Tombol Masuk tidak ditemukan!")
    end
end

-- =================================================================
-- DETEKSI KATA DARI GAME
-- =================================================================
local SKIP = {
    PURCHASED=1,ROBUX=1,BUY=1,PLAYER=1,PLAYERS=1,SCORE=1,LEVEL=1,
    ROUND=1,WIN=1,LOSE=1,GAME=1,ADMIN=1,MASUK=1,JAWAB=1,
    AUTO=1,FLASH=1,OFF=1,ON=1,KETIK=1,KATA=1,NORMAL=1,
    SEARCH=1,TURN=1,OPPONENT=1,AI=1,GROQ=1,OUTPUT=1,
}

local function DeteksiKata()
    for _, gui in ipairs(PlayerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Enabled and gui.Name ~= "AutoSambungKataReal" then
            for _, v in ipairs(gui:GetDescendants()) do
                if v:IsA("TextLabel") and v.Visible then
                    local txt = v.Text

                    -- "Hurufnya adalah: RI" / "Hurufnya adalah: R"
                    local huruf = txt:match("[Hh]uruf[%w%s]*:%s*([A-Za-z]+)")
                    if huruf and #huruf >= 1 and #huruf <= 5 then
                        return huruf:lower(), "awalan"
                    end

                    -- "Kata sebelumnya: RIANG"
                    local prev = txt:match("[Kk]ata[%w%s]*:%s*([A-Za-z]+)")
                    if prev and #prev >= 2 then
                        return prev:lower(), "lanjut"
                    end
                end
            end
        end
    end

    -- Fallback: cari TextLabel ALL CAPS yang valid (kata game ditampilkan besar)
    for _, gui in ipairs(PlayerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Enabled and gui.Name ~= "AutoSambungKataReal" then
            for _, v in ipairs(gui:GetDescendants()) do
                if v:IsA("TextLabel") and v.Visible then
                    local txt = v.Text:match("^%s*(.-)%s*$")
                    if txt:match("^[A-Z][A-Z]+$") and #txt >= 2 and #txt <= 20 and not SKIP[txt] then
                        return txt:lower(), "lanjut"
                    end
                end
            end
        end
    end

    return nil, nil
end

-- =================================================================
-- MAIN STATE
-- =================================================================
local ENABLED = false
local lastKata = ""
local lastTime = 0
local COOLDOWN = 1.8
local proses = false
local LocalPlayer = Players.LocalPlayer

-- =================================================================
-- LOOP
-- =================================================================
local function MainLoop()
    if not ENABLED or proses then return end
    if tick() - lastTime < COOLDOWN then return end

    local input, mode = DeteksiKata()
    if not input then return end
    if input == lastKata then return end

    local jawaban
    if mode == "awalan" then
        jawaban = CariKataAwalan(input)
    else
        jawaban = CariKataLanjut(input)
    end

    if not jawaban then
        print("[SKIP] Tidak ada kata untuk: '" .. input .. "'")
        lastKata = input
        return
    end

    print("==============================")
    print("[FLASH] " .. input .. " -> " .. jawaban)
    print("==============================")

    proses = true
    lastKata = input

    task.spawn(function()
        local keys, tombolMasuk = ScanKeyboard()
        local jk = 0
        for _ in pairs(keys) do jk = jk + 1 end

        if jk < 10 then
            print("[ERROR] Keyboard hanya " .. jk .. " tombol - kurang!")
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
-- GUI - TIDAK DIUBAH
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
        lastKata = ""
        lastTime = 0
        proses = false
        -- Test getconnections tersedia
        if getconnections then
            print("[DELTA] getconnections TERSEDIA - Full power mode!")
        else
            print("[WARN] getconnections tidak ada - pakai fallback")
        end
        print("[ON] Siap! Tunggu giliran kamu...")
        -- Langsung scan keyboard sekali
        task.spawn(function()
            ScanKeyboard()
        end)
    else
        ToggleBtn.Text = "OFF"
        ToggleBtn.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
        proses = false
        print("[OFF]")
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

print("=== AUTO SAMBUNG KATA v8 - DELTA iOS ===")
print("Tekan ON lalu tunggu giliran kamu")
print("Lihat console: [FLASH], [KETIK], [DELTA], [SUBMIT]")
