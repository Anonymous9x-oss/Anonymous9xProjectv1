-- =================================================================
-- AUTO SAMBUNG KATA v12 - Anonymous9x
-- FIX UTAMA: Hanya ketik saat GILIRAN KITA (keyboard visible)
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
        if kata:sub(1, #awalan) == awalan
            and not kata:find("%-")
            and #kata > #awalan
            and not usedWords[kata] then
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
-- CEK GILIRAN KITA - INI FIX UTAMA
-- Keyboard hanya visible saat giliran kita!
-- =================================================================
local function IsGiliranKita()
    local keyboardVisible = false
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

    -- Keyboard dengan 20+ tombol huruf = giliran kita
    keyboardVisible = keyCount >= 20

    if not keyboardVisible then
        -- Double check: cari tombol "Masuk" yang visible
        for _, gui in ipairs(PlayerGui:GetChildren()) do
            if gui:IsA("ScreenGui") and gui.Enabled and gui.Name ~= "AutoSambungKataReal" then
                for _, v in ipairs(gui:GetDescendants()) do
                    if v:IsA("TextButton") and v.Visible then
                        local tl = v.Text:lower():match("^%s*(.-)%s*$")
                        if tl == "masuk" or tl == "jawab" or tl == "kirim" then
                            keyboardVisible = true
                            break
                        end
                    end
                end
            end
        end
    end

    return keyboardVisible, keyCount
end

-- =================================================================
-- GETCONNECTIONS ENGINE
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
-- SCAN KEYBOARD
-- =================================================================
local keyCache = {}
local masukCache = nil
local cacheTime = 0

local function ScanKeyboard()
    if tick() - cacheTime < 1 and next(keyCache) ~= nil then
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
    return keys, tombolMasuk
end

-- =================================================================
-- CEK INPUT BOX SEKARANG
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
-- KETIK KATA
-- =================================================================
local function KetikKata(jawaban, awalan, keys, tombolMasuk)
    jawaban = jawaban:lower()
    awalan = awalan:lower()

    -- Cek pre-fill: apakah awalan sudah ada di input box
    local inputNow = GetCurrentInput()
    local toKetik = jawaban

    if inputNow and #inputNow > 0 and jawaban:sub(1, #inputNow) == inputNow then
        toKetik = jawaban:sub(#inputNow + 1)
        print("[PRE-FILL] Ada '" .. inputNow .. "' -> ketik sisa: '" .. toKetik .. "'")
    else
        -- Tidak ada TextBox atau kosong
        -- Game kemungkinan pre-fill awalan lewat kotak huruf (bukan TextBox)
        -- Ketik hanya setelah huruf awalan
        toKetik = jawaban:sub(#awalan + 1)
        if #toKetik == 0 then toKetik = jawaban end
        print("[SISA] Awalan:'" .. awalan .. "' -> ketik sisa: '" .. toKetik .. "'")
    end

    if #toKetik == 0 then
        print("[SUBMIT LANGSUNG]")
        if tombolMasuk then DeltaKlik(tombolMasuk) end
        return
    end

    print("[KETIK] '" .. toKetik .. "'")

    for i = 1, #toKetik do
        -- Cek lagi giliran masih kita tidak (antisipasi timeout)
        local masihGiliran = IsGiliranKita()
        if not masihGiliran then
            print("[STOP] Bukan giliran kita lagi, berhenti ketik!")
            return
        end

        local huruf = toKetik:sub(i, i)
        local btn = keys[huruf]
        if btn and btn.Parent and btn.Visible then
            DeltaKlik(btn)
            task.wait(0.06)
        else
            print("[MISS] '" .. huruf .. "'")
        end
    end

    task.wait(0.1)
    -- Cek sekali lagi sebelum submit
    if IsGiliranKita() then
        if tombolMasuk and tombolMasuk.Parent then
            print("[SUBMIT] Masuk!")
            DeltaKlik(tombolMasuk)
        end
    else
        print("[STOP] Waktu habis sebelum submit!")
    end
end

-- =================================================================
-- DETEKSI AWALAN
-- =================================================================
local function DeteksiAwalan()
    for _, gui in ipairs(PlayerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Enabled and gui.Name ~= "AutoSambungKataReal" then
            for _, v in ipairs(gui:GetDescendants()) do
                if v:IsA("TextLabel") and v.Visible then
                    local txt = v.Text

                    -- "Hurufnya adalah: IS"
                    if txt:find("[Hh]uruf") and txt:find("[Aa]dalah") then
                        local awalan = txt:match("[Aa]dalah[%s:]*([A-Za-z]+)")
                        if awalan and #awalan >= 1 then return awalan:lower() end

                        -- Cari di sibling
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
                                        local children = sib:GetChildren()
                                        table.sort(children, function(a, b)
                                            return a.AbsolutePosition.X < b.AbsolutePosition.X
                                        end)
                                        for _, child in ipairs(children) do
                                            if child:IsA("TextLabel") or child:IsA("TextButton") then
                                                local ct = child.Text:match("^%s*([A-Za-z])%s*$")
                                                if ct then combined = combined .. ct end
                                            end
                                        end
                                        if #combined >= 1 and #combined <= 5 then
                                            return combined:lower()
                                        end
                                    end
                                end
                            end
                        end
                    end

                    -- Label ALL CAPS pendek di dekat label "Huruf"
                    local txt2 = txt:match("^%s*([A-Z][A-Z]?[A-Z]?[A-Z]?)%s*$")
                    if txt2 and #txt2 >= 1 and #txt2 <= 4 then
                        local SKIP = {ON=1,OFF=1,OK=1,AI=1,GO=1,NO=1,HI=1,MY=1}
                        if not SKIP[txt2] then
                            local parent = v.Parent
                            if parent then
                                for _, sib in ipairs(parent:GetChildren()) do
                                    if sib:IsA("TextLabel") and sib.Text:lower():find("huruf") then
                                        return txt2:lower()
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
local COOLDOWN = 1.5
local proses = false

local function MainLoop()
    if not ENABLED or proses then return end
    if tick() - lastTime < COOLDOWN then return end

    -- === CEK GILIRAN DULU ===
    local giliran, keyCount = IsGiliranKita()
    if not giliran then
        -- Bukan giliran kita, reset state
        if lastAwalan ~= "" then
            print("[TUNGGU] Giliran lawan... (keyboard: " .. keyCount .. " tombol)")
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
        print("[SKIP] Tidak ada kata untuk: '" .. awalan .. "'")
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
        local keys, tombolMasuk = ScanKeyboard()
        local jk = 0
        for _ in pairs(keys) do jk = jk + 1 end
        if jk < 10 then
            print("[ERROR] Keyboard tidak ditemukan!")
            proses = false
            lastTime = tick()
            return
        end
        KetikKata(jawaban, awalan, keys, tombolMasuk)
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
        print("[ON] v12 aktif!")
        print("[INFO] getconnections: " .. (getconnections and "ADA ✓" or "tidak ada"))
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

print("=== AUTO SAMBUNG KATA v12 - TURN DETECTION ===")
print("Tekan ON | Otomatis diam saat giliran lawan")
print("Console: [GILIRAN KITA!] = aktif | [TUNGGU] = lawan")
