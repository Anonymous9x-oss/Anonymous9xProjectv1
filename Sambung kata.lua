-- =================================================================
-- AUTO SAMBUNG KATA v13 - Anonymous9x
-- FIX: Auto hapus jika error, kecepatan tinggi, deteksi awalan akurat
-- Compatible: Mobile/PC (Delta Executor supported)
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
-- KAMUS (dari v12 + tambahan)
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
        local fb = {"aku","kamu","dia","itu","ini","ada","dan","yang","dengan","untuk","angin","bumi","api","langit","laut","hutan","gunung","sungai","danau","kota","desa","jalan","rumah","pintu","kursi","meja","buku","makan","minum","tidur","duduk","berjalan","berlari","naik","turun","masuk","keluar","pergi","datang","beli","jual","baca","tulis","bicara","tertawa","senyum","bahagia","gembira","indah","cantik","tulus","setia","jujur","bijak","cerdas","pandai","rajin","tekun","sabar","tabah","tegar","berani","cinta","kasih","sayang","rindu","ingat","tahu","paham","rasa","hati","jiwa","hidup","tangan","kaki","mata","telinga","hidung","mulut","rambut","wajah","ibu","ayah","anak","adik","kakak","teman","guru","nama","warna","merah","biru","hijau","putih","hitam","kuning","pagi","siang","malam","hari","bulan","tahun","dalam","luar","atas","bawah","depan","belakang","kiri","kanan","dekat","jauh","cepat","lambat","besar","kecil","tinggi","rendah","panjang","pendek","berat","ringan","panas","dingin","bersih","kotor","baru","lama","baik","buruk","senang","sedih","marah","takut","empangan","enak","ekor","elang","emas","emosi","engkau","entah","esok","gagang","gading","gadis","gagal","gagah","gajah","galak","gambar","ganas","ganggu","ganteng","garuda","gelap","gempa","gerak","gigih","goreng","gotong","gula","guling","guna","guntur","habis","hadap","hadiah","hadir","hakim","halus","hambat","hanya","harap","harga","hasil","hati","hebat","helai","henti","heran","hijau","hilang","hirup","hitam","hitung","hormati","hubung","hujan","hutan","ijin","ikut","ilmu","imam","impian","indah","ingin","ingkar","inti","isap","iseng","isian","islam","istri","istana","jaga","jajan","jalan","jangan","janji","jarang","jatuh","jawab","jelas","jenis","jinak","jual","juara","jujur","julang","jumpa","jurus","kacau","kadang","kaki","kalah","kalimat","kalung","kampung","kapal","karena","kasih","kawasan","kecil","kejam","keras","kerja","ketat","kilat","kira","kontak","kuat","kukuh","kuliah","lampau","langit","lancar","lanjut","lapang","lapar","laris","lawan","lebih","lemah","lembut","lepas","lestari","limpah","lincah","lindung","lintir","logam","lolos","luhur","lulus","lurus","mahir","makin","maju","makmur","malang","malas","mampir","mandiri","manfaat","mapan","masak","matang","mekar","menang","minat","miskin","mohon","mujur","mulai","murni","nalar","napas","nasib","niat","nilai","nyaman","nyata","obat","olah","orang","paham","panjang","pasang","patuh","percaya","pikir","pintar","pisah","pokok","potong","pulang","puncak","punya","putus","rajin","rambut","ramping","rapat","ramai","rantau","rapuh","rawat","rela","rendah","riang","ringan","riwayat","royong","ruang","rukun","rumit","sabar","sahaja","sakit","sambung","sampai","sayang","sejuk","sehat","semua","sering","setia","siaga","sigap","simpan","singkat","sombong","sukses","sungguh","syukur","tabah","takut","tangguh","tangkas","tarik","tegar","teguh","tekad","tekun","teladan","tengah","tentram","tepat","terima","tulus","tuntas","turun","ulet","unggul","untung","upaya","usaha","utama","wajib","warga","warisan","waspada","zaman"}
        local unique = {}
        for _, kata in ipairs(fb) do
            kata = kata:lower()
            if not unique[kata] then
                unique[kata] = true
                table.insert(KAMUS, kata)
                local h = kata:sub(1,1)
                if not KAMUS_BY_HURUF[h] then KAMUS_BY_HURUF[h] = {} end
                table.insert(KAMUS_BY_HURUF[h], kata)
            end
        end
        print("[KAMUS] Fallback: " .. #KAMUS)
    end
end

local usedWords = {}

local function CariKataAwalan(awalan)
    awalan = awalan:lower()
    local hasil = {}
    for _, kata in ipairs(KAMUS) do
        if kata:sub(1, #awalan) == awalan and not kata:find("%-") and #kata > #awalan and not usedWords[kata] then
            table.insert(hasil, kata)
        end
    end
    if #hasil > 0 then
        local pilihan = hasil[math.random(1, math.min(#hasil, 100))]
        usedWords[pilihan] = true
        return pilihan
    end
    if #awalan > 1 then
        local list = KAMUS_BY_HURUF[awalan:sub(1,1)]
        if list then
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
-- CEK GILIRAN KITA (keyboard visible)
-- =================================================================
local function IsGiliranKita()
    local keyCount = 0
    for _, gui in ipairs(PlayerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Enabled and gui.Name ~= "AutoSambungKataReal" then
            for _, v in ipairs(gui:GetDescendants()) do
                if v:IsA("TextButton") and v.Visible then
                    local t = v.Text:match("^%s*(.-)%s*$")
                    if #t == 1 and t:match("^[a-zA-Z]$") then
                        keyCount = keyCount + 1
                    end
                end
            end
        end
    end
    local visible = keyCount >= 20
    if not visible then
        -- cek tombol "Masuk" sebagai indikator tambahan
        for _, gui in ipairs(PlayerGui:GetChildren()) do
            if gui:IsA("ScreenGui") and gui.Enabled and gui.Name ~= "AutoSambungKataReal" then
                for _, v in ipairs(gui:GetDescendants()) do
                    if v:IsA("TextButton") and v.Visible then
                        local tl = v.Text:lower():match("^%s*(.-)%s*$")
                        if tl == "masuk" or tl == "jawab" or tl == "kirim" then
                            visible = true
                            break
                        end
                    end
                end
            end
        end
    end
    return visible, keyCount
end

-- =================================================================
-- GETCONNECTIONS ENGINE + FALLBACK
-- =================================================================
local function KlikTombol(button)
    if not button or not button.Parent then return false end
    local ok = false
    pcall(function()
        if getconnections then
            for _, ev in ipairs({"Activated", "MouseButton1Click", "MouseButton1Down"}) do
                local conns = getconnections(button[ev])
                if conns and #conns > 0 then
                    for _, c in ipairs(conns) do
                        pcall(c.Function)
                    end
                    ok = true
                    return
                end
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
-- SCAN KEYBOARD (termasuk tombol hapus)
-- =================================================================
local keyCache = {}
local masukCache = nil
local hapusCache = nil
local cacheTime = 0

local function ScanKeyboard()
    if tick() - cacheTime < 1 and next(keyCache) ~= nil then
        return keyCache, masukCache, hapusCache
    end
    local keys = {}
    local tombolMasuk = nil
    local tombolHapus = nil
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
                    -- Deteksi tombol hapus (biasanya merah atau icon)
                    if tl == "hapus" or tl == "delete" or tl == "backspace" then
                        tombolHapus = v
                    else
                        local bg = v.BackgroundColor3
                        if bg and bg.R > 0.7 and bg.G < 0.3 and bg.B < 0.3 then
                            tombolHapus = v -- merah
                        end
                    end
                end
            end
        end
    end
    keyCache = keys
    masukCache = tombolMasuk
    hapusCache = tombolHapus
    cacheTime = tick()
    return keys, tombolMasuk, tombolHapus
end

-- =================================================================
-- CEK INPUT BOX
-- =================================================================
local function GetCurrentInput()
    for _, gui in ipairs(PlayerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Enabled and gui.Name ~= "AutoSambungKataReal" then
            for _, v in ipairs(gui:GetDescendants()) do
                if v:IsA("TextBox") and v.Visible then
                    return v.Text:lower():match("^%s*(.-)%s*$") or ""
                end
            end
        end
    end
    return ""
end

-- =================================================================
-- CEK APAKAH JAWABAN SALAH (error indicator)
-- =================================================================
local function CekError()
    for _, gui in ipairs(PlayerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Enabled and gui.Name ~= "AutoSambungKataReal" then
            for _, v in ipairs(gui:GetDescendants()) do
                if v:IsA("TextLabel") and v.Visible then
                    local txt = v.Text:lower()
                    if txt:find("salah") or txt:find("wrong") or txt:find("invalid") then
                        return true
                    end
                end
                if v:IsA("ImageLabel") and v.Visible then
                    local img = v.Image:lower()
                    if img:find("x") or img:find("close") or img:find("error") or img:find("silang") then
                        return true
                    end
                end
            end
        end
    end
    return false
end

-- =================================================================
-- AUTO HAPUS (tekan backspace berkali-kali dengan cepat)
-- =================================================================
local function AutoHapus(tombolHapus, jumlah)
    if not tombolHapus then return end
    for i = 1, jumlah do
        if not IsGiliranKita() then break end
        KlikTombol(tombolHapus)
        task.wait(0.03) -- kecepatan tinggi
    end
    task.wait(0.05)
end

-- =================================================================
-- KETIK KATA DENGAN CEK ERROR DAN AUTO HAPUS
-- =================================================================
local function KetikKata(jawaban, awalan, keys, tombolMasuk, tombolHapus, percobaan)
    percobaan = percobaan or 1
    if percobaan > 3 then
        print("[GIVE UP] Gagal 3x, skip kata: " .. jawaban)
        return false
    end

    jawaban = jawaban:lower()
    awalan = awalan:lower()

    -- Cek apakah sudah ada pre-fill di TextBox
    local inputNow = GetCurrentInput()
    local toKetik = jawaban
    if inputNow and #inputNow > 0 and jawaban:sub(1, #inputNow) == inputNow then
        toKetik = jawaban:sub(#inputNow + 1)
        print("[PRE-FILL] '" .. inputNow .. "' -> ketik sisa: '" .. toKetik .. "'")
    else
        -- Biasanya game menampilkan awalan dalam bentuk kotak, bukan TextBox
        toKetik = jawaban:sub(#awalan + 1)
        if #toKetik == 0 then toKetik = jawaban end
        print("[SISA] Awalan '" .. awalan .. "' -> ketik: '" .. toKetik .. "'")
    end

    if #toKetik == 0 then
        -- Langsung submit (awalan sudah cukup)
        if tombolMasuk then
            KlikTombol(tombolMasuk)
            task.wait(0.2)
            if CekError() then
                print("[ERROR] Jawaban ditolak, coba kata lain...")
                usedWords[jawaban] = true
                local newJawaban = CariKataAwalan(awalan)
                if newJawaban then
                    return KetikKata(newJawaban, awalan, keys, tombolMasuk, tombolHapus, percobaan + 1)
                end
            end
        end
        return true
    end

    -- Ketik huruf per huruf dengan kecepatan tinggi
    for i = 1, #toKetik do
        if not IsGiliranKita() then
            print("[STOP] Bukan giliran kita, berhenti ketik.")
            return false
        end
        local huruf = toKetik:sub(i, i)
        local btn = keys[huruf]
        if btn and btn.Parent and btn.Visible then
            KlikTombol(btn)
            task.wait(0.04) -- kecepatan tinggi
        else
            print("[MISS] Tombol '" .. huruf .. "' tidak ditemukan, hentikan.")
            break
        end
    end

    task.wait(0.1)

    if not IsGiliranKita() then
        print("[STOP] Waktu habis sebelum submit.")
        return false
    end

    -- Submit
    if tombolMasuk and tombolMasuk.Parent then
        KlikTombol(tombolMasuk)
        print("[SUBMIT] '" .. jawaban .. "'")
    else
        print("[WARN] Tombol masuk tidak ditemukan.")
    end

    -- Tunggu sebentar lalu cek error
    task.wait(0.3)

    if CekError() then
        print("[ERROR] Jawaban salah! Menghapus...")
        -- Hapus kata yang sudah diketik
        local panjangDiketik = #toKetik
        if tombolHapus then
            AutoHapus(tombolHapus, panjangDiketik + 2) -- +2 untuk jaga
        else
            print("[WARN] Tombol hapus tidak ditemukan, tidak bisa auto-hapus.")
        end
        usedWords[jawaban] = true
        local newJawaban = CariKataAwalan(awalan)
        if newJawaban and IsGiliranKita() then
            return KetikKata(newJawaban, awalan, keys, tombolMasuk, tombolHapus, percobaan + 1)
        end
    end

    return true
end

-- =================================================================
-- DETEKSI AWALAN (2/3 huruf) - ditingkatkan
-- =================================================================
local function DeteksiAwalan()
    for _, gui in ipairs(PlayerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Enabled and gui.Name ~= "AutoSambungKataReal" then
            for _, v in ipairs(gui:GetDescendants()) do
                if v:IsA("TextLabel") and v.Visible then
                    local txt = v.Text
                    -- Cari pola "Hurufnya adalah: EN" atau "Huruf: EN"
                    if txt:find("[Hh]uruf") and txt:find("[Aa]dalah") then
                        local awalan = txt:match("[Aa]dalah[%s:]*([A-Za-z]+)")
                        if awalan and #awalan >= 1 and #awalan <= 5 then
                            return awalan:lower()
                        end
                    end
                    -- Cek di sibling (frame kotak huruf)
                    local parent = v.Parent
                    if parent then
                        for _, sib in ipairs(parent:GetChildren()) do
                            if sib ~= v and sib.Visible then
                                if sib:IsA("TextLabel") then
                                    local st = sib.Text:match("^%s*([A-Za-z]+)%s*$")
                                    if st and #st >= 1 and #st <= 5 then
                                        return st:lower()
                                    end
                                end
                                if sib:IsA("Frame") then
                                    local combined = ""
                                    local children = {}
                                    for _, c in ipairs(sib:GetChildren()) do
                                        if c:IsA("TextLabel") or c:IsA("TextButton") then
                                            table.insert(children, c)
                                        end
                                    end
                                    table.sort(children, function(a, b)
                                        return a.AbsolutePosition.X < b.AbsolutePosition.X
                                    end)
                                    for _, child in ipairs(children) do
                                        local ct = child.Text:match("^%s*([A-Za-z])%s*$")
                                        if ct then combined = combined .. ct end
                                    end
                                    if #combined >= 1 and #combined <= 5 then
                                        return combined:lower()
                                    end
                                end
                            end
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
local COOLDOWN = 1.2
local proses = false

local function MainLoop()
    if not ENABLED or proses then return end
    if tick() - lastTime < COOLDOWN then return end

    local giliran, keyCount = IsGiliranKita()
    if not giliran then
        if lastAwalan ~= "" then
            print("[TUNGGU] Giliran lawan (keyboard: " .. keyCount .. ")")
            lastAwalan = ""
            usedWords = {}
        end
        return
    end

    local awalan = DeteksiAwalan()
    if not awalan or awalan == "" then return end

    if awalan ~= lastAwalan then
        usedWords = {}
        print("[GILIRAN KITA!] Awalan: '" .. awalan .. "'")
    end

    if awalan == lastAwalan and tick() - lastTime < COOLDOWN * 2 then return end

    local jawaban = CariKataAwalan(awalan)
    if not jawaban then
        print("[SKIP] Tidak ada kata untuk '" .. awalan .. "'")
        lastAwalan = awalan
        lastTime = tick()
        return
    end

    print("==============================")
    print("[FLASH] '" .. awalan .. "' -> '" .. jawaban .. "'")
    print("==============================")

    proses = true
    lastAwalan = awalan

    task.spawn(function()
        local keys, tombolMasuk, tombolHapus = ScanKeyboard()
        local jk = 0
        for _ in pairs(keys) do jk = jk + 1 end
        if jk < 10 then
            print("[ERROR] Keyboard tidak ditemukan!")
            proses = false
            lastTime = tick()
            return
        end
        KetikKata(jawaban, awalan, keys, tombolMasuk, tombolHapus, 1)
        lastTime = tick()
        proses = false
    end)
end

-- =================================================================
-- GUI (sama seperti v12, hanya teks info diubah)
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
Header.Text = "Auto Sambung Kata v13"
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
Info.Text = "Auto isi + hapus jika error"
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
        print("[ON] v13 aktif - Auto hapus error enabled")
        local g, k = IsGiliranKita()
        print("[INFO] Giliran kita: " .. tostring(g) .. " | Keyboard: " .. k .. " tombol")
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
        task.wait(0.2)
        pcall(MainLoop)
    end
end)

print("=== AUTO SAMBUNG KATA v13 - AUTO HAPUS ERROR ===")
print("Tekan ON | Otomatis hapus jika jawaban salah")
print("Kecepatan tinggi | Compatible Mobile/PC")
