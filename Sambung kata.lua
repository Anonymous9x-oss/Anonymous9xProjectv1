-- =================================================================
-- AUTO SAMBUNG KATA v17 - ADAPTIF (Anonymous9x)
-- FIX: Deteksi kegagalan, blacklist kata invalid, getconnections fallback
-- =================================================================

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local parentGui = CoreGui or PlayerGui

-- Hapus GUI lama
if parentGui:FindFirstChild("AutoSambungKataAdaptif") then
    parentGui.AutoSambungKataAdaptif:Destroy()
end

-- =================================================================
-- KAMUS + BLACKLIST
-- =================================================================
local KAMUS = {}
local KAMUS_BY_HURUF = {}
local usedWords = {}        -- kata sudah dipakai (berhasil)
local failedWords = {}      -- kata yang pernah gagal (tidak valid)
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
        print("[KAMUS] " .. #KAMUS .. " kata")
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

-- =================================================================
-- CARI KATA (dengan filter usedWords & failedWords)
-- =================================================================
local function CariKataAwalan(awalan)
    awalan = awalan:lower()
    local list = KAMUS_BY_HURUF[awalan:sub(1,1)]
    if not list then return nil end

    local candidates = {}
    for _, kata in ipairs(list) do
        if kata:sub(1, #awalan) == awalan 
            and not usedWords[kata] 
            and not failedWords[kata] then
            table.insert(candidates, kata)
            if #candidates >= 50 then break end
        end
    end

    if #candidates > 0 then
        local pilihan = candidates[math.random(1, #candidates)]
        return pilihan
    end

    -- Fallback acak (dengan filter used & failed)
    for i = 1, 30 do
        local c = list[math.random(1, #list)]
        if not usedWords[c] and not failedWords[c] then
            return c
        end
    end
    return nil
end

-- =================================================================
-- DETEKSI GILIRAN
-- =================================================================
local function IsGiliranKita()
    local keyCount = 0
    for _, gui in ipairs(PlayerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Enabled and gui.Name ~= "AutoSambungKataAdaptif" then
            for _, v in ipairs(gui:GetDescendants()) do
                if v:IsA("TextButton") and v.Visible then
                    local t = v.Text:match("^%s*(.-)%s*$")
                    if #t == 1 and t:match("^[a-zA-Z]$") then
                        keyCount = keyCount + 1
                        if keyCount >= 15 then return true end
                    end
                end
            end
        end
    end
    return false
end

-- =================================================================
-- SCAN KEYBOARD
-- =================================================================
local keyCache = {}
local masukCache = nil
local lastScan = 0

local function ScanKeyboard()
    if tick() - lastScan < 0.2 and next(keyCache) then
        return keyCache, masukCache
    end
    local keys = {}
    local tombolMasuk = nil
    for _, gui in ipairs(PlayerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Enabled and gui.Name ~= "AutoSambungKataAdaptif" then
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
    lastScan = tick()
    return keys, tombolMasuk
end

-- =================================================================
-- DETEKSI AWALAN (lebih akurat)
-- =================================================================
local function DeteksiAwalan()
    -- Cek TextBox dulu
    for _, gui in ipairs(PlayerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Enabled then
            for _, v in ipairs(gui:GetDescendants()) do
                if v:IsA("TextBox") and v.Visible then
                    local txt = v.Text:lower():match("^%s*(.-)%s*$")
                    if txt and #txt >= 1 and #txt <= 5 and not txt:find("%s") then
                        return txt
                    end
                end
            end
        end
    end

    -- Cek label
    for _, gui in ipairs(PlayerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Enabled and gui.Name ~= "AutoSambungKataAdaptif" then
            for _, v in ipairs(gui:GetDescendants()) do
                if v:IsA("TextLabel") and v.Visible then
                    local txt = v.Text:gsub("%s+", " ")
                    local awalan = txt:match("[Hh]uruf[^:]-:[%s]*([A-Za-z]+)")
                    if awalan and #awalan >= 1 and #awalan <= 5 then return awalan:lower() end
                    awalan = txt:match("[Aa]walan[^:]-:[%s]*([A-Za-z]+)")
                    if awalan and #awalan >= 1 and #awalan <= 5 then return awalan:lower() end
                    if txt:match("^[A-Z][A-Z]?[A-Z]?$") and #txt <= 3 then
                        local parent = v.Parent
                        if parent then
                            for _, sib in ipairs(parent:GetChildren()) do
                                if sib:IsA("TextLabel") and sib.Text:lower():find("huruf") then
                                    return txt:lower()
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
-- KLIK MAKSIMAL (getconnections + fallback)
-- =================================================================
local function DeltaKlik(button)
    if not button or not button.Parent then return false end
    local ok = false
    pcall(function()
        if getconnections then
            for _, ev in ipairs({"Activated", "MouseButton1Click", "MouseButton1Down"}) do
                local conns = getconnections(button[ev])
                if conns and #conns > 0 then
                    for _, c in ipairs(conns) do pcall(function() c.Function() end) end
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
-- CEK APAKAH JAWABAN DITERIMA GAME
-- =================================================================
local function CekJawabanDiterima(textBox, awalan)
    if not textBox then return false end
    task.wait(0.3)  -- beri waktu game memproses
    local current = textBox.Text:lower():match("^%s*(.-)%s*$") or ""
    -- Jika setelah submit, textBox kosong atau hanya berisi awalan, mungkin diterima?
    -- Tapi kita tidak tahu persis. Alternatif: jika textBox berubah menjadi kosong, itu tandanya game menerima dan lanjut.
    -- Atau jika tetap berisi awalan, mungkin ditolak.
    if current == "" then
        return true  -- kosong, game lanjut
    elseif current == awalan then
        return false  -- masih awalan, kemungkinan ditolak
    else
        -- Ada teks lain, mungkin belum submit atau error
        return nil  -- tidak pasti
    end
end

-- =================================================================
-- KETIK KATA DENGAN VERIFIKASI DAN DETEKSI KEGAGALAN
-- =================================================================
local function KetikKata(jawaban, awalan, keys, tombolMasuk)
    jawaban = jawaban:lower()
    awalan = awalan:lower()

    -- Cari TextBox
    local textBox = nil
    for _, gui in ipairs(PlayerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Enabled then
            for _, v in ipairs(gui:GetDescendants()) do
                if v:IsA("TextBox") and v.Visible then
                    textBox = v
                    break
                end
            end
        end
    end

    local inputNow = ""
    if textBox then
        inputNow = textBox.Text:lower():match("^%s*(.-)%s*$") or ""
    end

    local sisaKetik
    if #inputNow > 0 and jawaban:sub(1, #inputNow) == inputNow then
        sisaKetik = jawaban:sub(#inputNow + 1)
    else
        sisaKetik = jawaban:sub(#awalan + 1)
        if #sisaKetik == 0 then sisaKetik = jawaban end
    end

    if #sisaKetik == 0 then
        if tombolMasuk and tombolMasuk.Parent then
            DeltaKlik(tombolMasuk)
            -- Setelah submit, cek apakah diterima
            if textBox then
                local diterima = CekJawabanDiterima(textBox, awalan)
                if diterima == false then
                    print("[GAGAL] Kata '" .. jawaban .. "' ditolak game, blacklist")
                    failedWords[jawaban] = true
                elseif diterima == true then
                    print("[BERHASIL] Kata '" .. jawaban .. "' diterima")
                    usedWords[jawaban] = true
                end
            end
        end
        return
    end

    -- Ketik huruf
    for i = 1, #sisaKetik do
        if not IsGiliranKita() then return end
        local huruf = sisaKetik:sub(i, i)
        local btn = keys[huruf]
        if not btn or not btn.Parent or not btn.Visible then
            keys, tombolMasuk = ScanKeyboard()
            btn = keys[huruf]
        end
        if btn and btn.Parent and btn.Visible then
            DeltaKlik(btn)
            task.wait(0.01)
        else
            print("[ERROR] Tombol '" .. huruf .. "' hilang")
            return
        end
    end

    -- Jika tidak ada TextBox, langsung submit
    if not textBox then
        task.wait(0.05)
        if IsGiliranKita() and tombolMasuk and tombolMasuk.Parent then
            DeltaKlik(tombolMasuk)
        end
        return
    end

    -- Verifikasi dengan TextBox
    task.wait(0.15)
    local finalInput = textBox.Text:lower():match("^%s*(.-)%s*$") or ""
    if finalInput == jawaban then
        if IsGiliranKita() and tombolMasuk then
            DeltaKlik(tombolMasuk)
            -- Cek hasil submit
            local diterima = CekJawabanDiterima(textBox, awalan)
            if diterima == false then
                print("[GAGAL] Kata '" .. jawaban .. "' ditolak game, blacklist")
                failedWords[jawaban] = true
            elseif diterima == true then
                print("[BERHASIL] Kata '" .. jawaban .. "' diterima")
                usedWords[jawaban] = true
            end
        end
        return
    end

    -- Jika tidak sama, cek apakah masih kurang
    if jawaban:sub(1, #finalInput) == finalInput then
        local kurang = jawaban:sub(#finalInput + 1)
        if #kurang > 0 then
            print("[PERBAIKAN] Kurang: " .. kurang)
            for i = 1, #kurang do
                local h = kurang:sub(i,i)
                local btn = keys[h]
                if btn then DeltaKlik(btn) end
                task.wait(0.01)
            end
            task.wait(0.1)
            if IsGiliranKita() and tombolMasuk then
                DeltaKlik(tombolMasuk)
                local diterima = CekJawabanDiterima(textBox, awalan)
                if diterima == false then
                    failedWords[jawaban] = true
                elseif diterima == true then
                    usedWords[jawaban] = true
                end
            end
        else
            if tombolMasuk then
                DeltaKlik(tombolMasuk)
                local diterima = CekJawabanDiterima(textBox, awalan)
                if diterima == false then
                    failedWords[jawaban] = true
                elseif diterima == true then
                    usedWords[jawaban] = true
                end
            end
        end
    elseif finalInput == "" then
        -- Input kosong, mungkin game sangat lambat, tunggu lagi
        task.wait(0.2)
        finalInput = textBox.Text:lower():match("^%s*(.-)%s*$") or ""
        if finalInput == jawaban then
            if tombolMasuk then
                DeltaKlik(tombolMasuk)
                local diterima = CekJawabanDiterima(textBox, awalan)
                if diterima == false then
                    failedWords[jawaban] = true
                elseif diterima == true then
                    usedWords[jawaban] = true
                end
            end
        else
            print("[WARNING] Input kosong, tetap submit")
            if tombolMasuk then
                DeltaKlik(tombolMasuk)
                -- Anggap gagal? Tidak tahu
            end
        end
    else
        -- Input tidak sesuai, mungkin salah, tetap submit
        print("[WARNING] Input tidak sesuai: '" .. finalInput .. "', tetap submit")
        if tombolMasuk then
            DeltaKlik(tombolMasuk)
            -- Cek setelah submit
            local diterima = CekJawabanDiterima(textBox, awalan)
            if diterima == false then
                failedWords[jawaban] = true
            elseif diterima == true then
                usedWords[jawaban] = true
            end
        end
    end
end

-- =================================================================
-- MAIN LOOP
-- =================================================================
local ENABLED = false
local lastAwalan = ""
local lastTime = 0
local COOLDOWN = 1.0
local proses = false

local function MainLoop()
    if not ENABLED or proses then return end
    if tick() - lastTime < COOLDOWN then return end

    if not IsGiliranKita() then
        if lastAwalan ~= "" then lastAwalan = "" end
        return
    end

    local awalan = DeteksiAwalan()
    if not awalan or awalan == "" then return end

    if awalan ~= lastAwalan then
        print("[TURN] Awalan: " .. awalan)
    end

    if awalan == lastAwalan and tick() - lastTime < COOLDOWN * 1.5 then return end

    local jawaban = CariKataAwalan(awalan)
    if not jawaban then
        print("[NO WORD] " .. awalan)
        lastAwalan = awalan
        lastTime = tick()
        return
    end

    print(">>> JAWABAN: " .. jawaban .. " (" .. #jawaban .. " huruf)")

    proses = true
    lastAwalan = awalan

    task.spawn(function()
        local keys, tombolMasuk = ScanKeyboard()
        if not keys or not next(keys) then
            proses = false
            lastTime = tick()
            return
        end
        KetikKata(jawaban, awalan, keys, tombolMasuk)
        lastTime = tick()
        proses = false
    end)
end

RunService.RenderStepped:Connect(MainLoop)

-- =================================================================
-- GUI MINIMALIS
-- =================================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AutoSambungKataAdaptif"
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
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

local Header = Instance.new("TextLabel")
Header.Size = UDim2.new(1, -40, 0, 30)
Header.Position = UDim2.new(0, 10, 0, 5)
Header.BackgroundTransparency = 1
Header.Text = "Auto Sambung Ano9x"
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
Info.Text = "Auto Stable Mode | just for fun"
Info.TextColor3 = Color3.new(1, 1, 1)
Info.Font = Enum.Font.SourceSans
Info.TextSize = 13
Info.Parent = Content

local Credit = Instance.new("TextLabel")
Credit.Size = UDim2.new(1, 0, 0, 20)
Credit.Position = UDim2.new(0, 0, 1, -20)
Credit.BackgroundTransparency = 1
Credit.Text = "Anonymous9x"
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
        usedWords = {}
        failedWords = {}
        print("[v1 ON] Mode adaptif, blacklist kata gagal")
    else
        ToggleBtn.Text = "OFF"
        ToggleBtn.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
        print("[OFF]")
    end
end)

-- =================================================================
-- INIT
-- =================================================================
LoadKamus()
print("=== AUTO SAMBUNG KATA v1 ADAPTIF ===")
print("Ketik ON | Blacklist otomatis | Deteksi kegagalan")
