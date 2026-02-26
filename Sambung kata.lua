-- =================================================================
-- AUTO SAMBUNG KATA v14 FINAL - Anonymous9x
-- FIX: attempt to call a nil value -> semua nil check aman
-- SAFE: Tidak butuh getconnections, jalan di semua executor
-- =================================================================

local ok_init, err_init = pcall(function()

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Safe parent GUI
local parentGui
pcall(function() parentGui = CoreGui end)
if not parentGui then parentGui = PlayerGui end

-- Hapus GUI lama
pcall(function()
    if parentGui:FindFirstChild("AutoSambungKataReal") then
        parentGui.AutoSambungKataReal:Destroy()
    end
end)

-- =================================================================
-- SAFE CALL WRAPPER
-- =================================================================
local function safe(fn, ...)
    if type(fn) ~= "function" then return nil end
    local ok, result = pcall(fn, ...)
    if ok then return result end
    return nil
end

-- =================================================================
-- KAMUS INDONESIA
-- =================================================================
local KAMUS = {}
local KAMUS_BY_HURUF = {}

local BLACKLIST = {
    the=1,and=1,for=1,are=1,but=1,not=1,you=1,all=1,can=1,
    had=1,her=1,was=1,one=1,our=1,out=1,day=1,get=1,has=1,
    him=1,his=1,how=1,its=1,let=1,man=1,new=1,now=1,old=1,
    see=1,two=1,way=1,who=1,boy=1,did=1,own=1,put=1,say=1,
    she=1,too=1,use=1,yes=1,yet=1,any=1,may=1,run=1,act=1,
    age=1,air=1,arm=1,art=1,bag=1,bed=1,big=1,box=1,bus=1,
    buy=1,car=1,cat=1,cow=1,cup=1,dog=1,dry=1,ear=1,end=1,
    eye=1,far=1,fat=1,fit=1,fun=1,god=1,gun=1,hit=1,hot=1,
    ice=1,job=1,key=1,law=1,leg=1,lie=1,lot=1,low=1,map=1,
    mix=1,oil=1,pay=1,red=1,sea=1,set=1,six=1,sky=1,sun=1,
    tax=1,ten=1,top=1,war=1,win=1,ghana=1,xerosis=1,
    tolutolu=1,tersukses=1,terayap=1,
}

local KAMUS_INDO = {
    "abad","abadi","abah","abang","abdikan","abdi","abjad","abu","acara","ada",
    "adab","adik","adil","air","ajar","ajak","alam","alas","alat","alir",
    "alun","aman","amat","ambil","amuk","anak","angin","angka","angkat","angkut",
    "antar","antara","anting","api","arah","arak","arti","asah","asap","asing",
    "asli","asuh","atas","atau","atap","awal","awas","ayah","ayam","ayun",
    "babi","badan","bagai","bagian","bahu","baik","bakar","bakti","baku","bala",
    "bantu","banyak","baring","baru","batas","batu","bawah","bawang","bayam","bayar",
    "beban","bekal","bela","belah","belai","belang","beli","benak","benar","benih",
    "berat","berani","bersih","besar","biasa","bibir","bijak","biru","bisa","bocah",
    "bohong","boleh","bosan","buat","buah","bumi","buruk","buru","busuk","butuh",
    "cabai","cacat","cahaya","cair","cakap","campur","cantik","cari","cekat","cepat",
    "cerah","ceria","cermat","cicip","cinta","corak","cuci","curiga",
    "dada","dalam","damai","dapur","darah","dasar","datang","daun","daya","debu",
    "dekat","dengar","deras","desa","diam","didik","diri","dorong","duduk","duka",
    "dulu","dunia",
    "edar","ekor","elang","elok","emas","empang","empat","enam","enak","engkau",
    "entah","esok","etika","encer","endap","enggan","engsel",
    "faham","fakir","famili","fasih","fatal","fajar",
    "gagah","gagal","gajah","galak","gambar","ganas","ganggu","ganteng","garuda",
    "gelap","gempa","gerak","gigih","goreng","gotong","gula","guling","guna",
    "guntur","gusar","guyur","gadis","gading","gagang",
    "habis","hadap","hadiah","hadir","hafal","hakim","halus","hambat","hanya",
    "harap","harga","hasil","hati","hebat","helai","henti","heran","hijau",
    "hilang","hirup","hitam","hitung","hormati","hubung","hujan","hutan",
    "ibu","ikut","ilmu","imam","impian","indah","ingin","ingat","inti",
    "isap","isian","islam","istri","istana",
    "jaga","jajan","jalan","jangan","janji","jarang","jatuh","jawab","jelas",
    "jenis","jinak","jual","juara","jujur","julang","jumpa","jurus",
    "kacau","kadang","kaki","kalah","kalimat","kalung","kampung","kapal","karena",
    "kasih","kawasan","kecil","kejam","keras","kerja","ketat","kilat","kira",
    "kontak","kuat","kukuh","kuliah","kuning","kunci","kuda","kursi","kulit",
    "lampau","langit","lancar","lanjut","lapang","lapar","laris","lawan","lebih",
    "lemah","lembut","lepas","lestari","limpah","lincah","lindung","logam",
    "lolos","luhur","lulus","lurus","laut","lautan","ladang","langkah",
    "mahir","makin","maju","makmur","malang","malas","mampir","mandiri","manfaat",
    "mapan","masak","matang","mekar","menang","minat","miskin","mohon","mujur",
    "mulai","murni","muda","mudah","mulia","murah","meja","mobil","mawar","melon",
    "mangga","mentah","merah","mesra","malam","manusia","musim","musuh",
    "nalar","napas","nasib","niat","nilai","nyaman","nyata","nyawa","nanas",
    "nangka","nelayan","neraca","nestapa",
    "obat","olah","orang","obor","ombak","omong",
    "padi","pahat","pahit","pakai","paksa","palu","pandang","panggil","pantai",
    "papan","pasir","patok","payah","pecah","pegang","pekat","pelik","peluh",
    "pendek","penuh","pepaya","perahu","perang","pergi","perih","perkasa",
    "paham","panjang","pasang","patuh","percaya","pikir","pintar","pisah",
    "pokok","potong","pulang","puncak","punya","putus","pagi","panas","pandai",
    "penting","perlu","pesan","pohon","putih","pantas","pelajar","pelaut",
    "raga","ragam","raih","rakit","rampas","rangkai","rangkul","rasa","ratap",
    "raut","rawit","rebut","rekah","ribut","rindu","roda","rajin","rambut",
    "ramping","rapat","ramai","rantau","rapuh","rawat","rela","rendah","riang",
    "ringan","riwayat","royong","ruang","rukun","rumit","rusak",
    "saat","sabar","sahaja","sakit","sambung","sampai","sayang","sejuk","sehat",
    "semua","sering","setia","siaga","sigap","simpan","singkat","sombong",
    "sukses","sungguh","syukur","sadar","segera","selalu","seluruh","sempurna",
    "senyum","senang","sedih","sudah","sulit","sumber","sungai","sawah","salak",
    "salju","salam","sayur","sekolah","selimut","semangat","sepatu","serang",
    "tabah","takut","tangguh","tangkas","tarik","tegar","teguh","tekad","tekun",
    "teladan","tengah","tentram","tepat","terima","tulus","tuntas","turun",
    "tangan","tanah","teman","tenang","terang","tinggi","tirta","tumbuh","tugas",
    "tajam","tali","tamat","tampak","tampan","tanda","tandas","tangis","tangkap",
    "tapak","taring","tasik","tawa","tawon","tebal","tegak","teliti","telur",
    "tempat","tenda","tentu","tepung","terbang","ternak","tikar","timun","tinggal",
    "tolong","tongkat","tubuh","tulang","tumpah","tumpul",
    "ubah","ulam","ulang","ulet","ulos","umbut","umbi","ungkap","unjuk",
    "udara","ujung","umur","usaha","utama","untung","upaya","unggul","ulet",
    "wakaf","walau","wangi","warung","welas","wibawa","wirausaha","wajib",
    "warga","warisan","waspada","waktu","wajar","warna","wajah",
    "zaman","zona",
}

local function TambahKata(kata)
    kata = kata:lower()
    if #kata < 2 or #kata > 20 then return end
    if BLACKLIST[kata] then return end
    if kata:find("%-") then return end
    if kata:match("tion$") or kata:match("ness$") or kata:match("ment$") then return end
    local h = kata:sub(1,1)
    if not KAMUS_BY_HURUF[h] then KAMUS_BY_HURUF[h] = {} end
    -- Check duplikat
    for _, k in ipairs(KAMUS_BY_HURUF[h]) do
        if k == kata then return end
    end
    table.insert(KAMUS, kata)
    table.insert(KAMUS_BY_HURUF[h], kata)
end

local function LoadKamus()
    for _, kata in ipairs(KAMUS_INDO) do
        TambahKata(kata)
    end
    print("[KAMUS] Internal: " .. #KAMUS .. " kata")
    
    task.spawn(function()
        local ok2, res = pcall(function()
            return game:HttpGet("https://raw.githubusercontent.com/eenvyexe/KBBI/refs/heads/main/words.txt")
        end)
        if ok2 and res and #res > 100 then
            for line in res:gmatch("[^\r\n]+") do
                local kata = line:match("^([%a]+)")
                if kata then TambahKata(kata) end
            end
            print("[KAMUS] Total setelah online: " .. #KAMUS .. " kata")
        end
    end)
end

local usedWords = {}

local function CariKataAwalan(awalan)
    awalan = awalan:lower()
    local hasil = {}
    local h = awalan:sub(1,1)
    local list = KAMUS_BY_HURUF[h]
    if not list then return nil end
    
    for _, kata in ipairs(list) do
        if kata:sub(1, #awalan) == awalan
            and #kata > #awalan
            and not usedWords[kata] then
            table.insert(hasil, kata)
        end
    end
    
    if #hasil > 0 then
        local pilihan = hasil[math.random(1, math.min(#hasil, 50))]
        usedWords[pilihan] = true
        return pilihan
    end
    
    -- Fallback: kurangi awalan
    if #awalan > 1 then
        return CariKataAwalan(awalan:sub(1, #awalan - 1))
    end
    
    return nil
end

-- =================================================================
-- KLIK ENGINE - TANPA getconnections (SAFE untuk semua executor)
-- =================================================================
local function KlikButton(button)
    if not button then return false end
    if not button.Parent then return false end
    
    -- Method 1: getconnections (kalau ada)
    local gcOk = false
    if type(getconnections) == "function" then
        pcall(function()
            for _, evName in ipairs({"Activated","MouseButton1Click","MouseButton1Down"}) do
                local ev = button[evName]
                if ev then
                    local conns = getconnections(ev)
                    if conns and #conns > 0 then
                        for _, c in ipairs(conns) do
                            if c and type(c.Function) == "function" then
                                pcall(c.Function)
                            end
                        end
                        gcOk = true
                        return
                    end
                end
            end
        end)
    end
    
    if gcOk then return true end
    
    -- Method 2: Fire events langsung (ALWAYS works)
    pcall(function() button.MouseButton1Click:Fire() end)
    task.wait(0.01)
    pcall(function() button.Activated:Fire() end)
    task.wait(0.01)
    pcall(function() button:Click() end)
    
    return true
end

-- =================================================================
-- SCAN KEYBOARD
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

    pcall(function()
        for _, gui in ipairs(PlayerGui:GetChildren()) do
            if gui:IsA("ScreenGui") and gui.Enabled and gui.Name ~= "AutoSambungKataReal" then
                for _, v in ipairs(gui:GetDescendants()) do
                    if v:IsA("TextButton") and v.Visible then
                        local t = v.Text:match("^%s*(.-)%s*$") or ""
                        
                        -- Huruf tunggal
                        if #t == 1 and t:match("^[a-zA-Z]$") then
                            keys[t:lower()] = v
                        end
                        
                        -- Tombol masuk
                        local tl = t:lower()
                        if tl == "masuk" or tl == "jawab" or tl == "kirim" or tl == "submit" or tl == "enter" then
                            tombolMasuk = v
                        end
                        
                        -- Tombol hapus (background merah)
                        if v.BackgroundColor3 then
                            local r = v.BackgroundColor3.R
                            local g = v.BackgroundColor3.G
                            local b = v.BackgroundColor3.B
                            if r > 0.6 and g < 0.3 and b < 0.3 and tl ~= "x" then
                                tombolHapus = v
                            end
                        end
                    end
                end
            end
        end
    end)

    keyCache = keys
    masukCache = tombolMasuk
    hapusCache = tombolHapus
    cacheTime = tick()

    local jk = 0
    for _ in pairs(keys) do jk = jk + 1 end
    print("[KEY] " .. jk .. " huruf | Masuk: " .. (tombolMasuk and tombolMasuk.Text or "?") .. " | Hapus: " .. (tombolHapus and "✓" or "✗"))
    return keys, tombolMasuk, tombolHapus
end

-- =================================================================
-- CEK GILIRAN KITA
-- =================================================================
local function IsGiliranKita()
    local keyCount = 0
    pcall(function()
        for _, gui in ipairs(PlayerGui:GetChildren()) do
            if gui:IsA("ScreenGui") and gui.Enabled and gui.Name ~= "AutoSambungKataReal" then
                for _, v in ipairs(gui:GetDescendants()) do
                    if v:IsA("TextButton") and v.Visible then
                        local t = v.Text:match("^%s*(.-)%s*$") or ""
                        if #t == 1 and t:match("^[a-zA-Z]$") then
                            keyCount = keyCount + 1
                        end
                    end
                end
            end
        end
    end)
    return keyCount >= 20, keyCount
end

-- =================================================================
-- CEK INPUT SAAT INI
-- =================================================================
local function GetCurrentInput()
    local result = ""
    pcall(function()
        for _, gui in ipairs(PlayerGui:GetChildren()) do
            if gui:IsA("ScreenGui") and gui.Enabled and gui.Name ~= "AutoSambungKataReal" then
                for _, v in ipairs(gui:GetDescendants()) do
                    if v:IsA("TextBox") and v.Visible then
                        result = (v.Text or ""):lower():match("^%s*(.-)%s*$") or ""
                        return
                    end
                end
            end
        end
    end)
    return result
end

-- =================================================================
-- AUTO HAPUS (BACKSPACE)
-- =================================================================
local function AutoHapus(tombolHapus, n)
    if not tombolHapus then return end
    n = n or 1
    print("[HAPUS] " .. n .. " huruf...")
    for i = 1, n + 2 do
        if tombolHapus and tombolHapus.Parent and tombolHapus.Visible then
            KlikButton(tombolHapus)
            task.wait(0.04)
        else
            break
        end
    end
    task.wait(0.1)
end

-- =================================================================
-- KETIK KATA
-- =================================================================
local function KetikKata(jawaban, awalan, keys, tombolMasuk, tombolHapus, attempt)
    attempt = attempt or 1
    if attempt > 3 then
        print("[GIVE UP] 3x gagal, skip")
        return false
    end

    jawaban = (jawaban or ""):lower()
    awalan = (awalan or ""):lower()
    if #jawaban == 0 then return false end

    -- Hitung yang harus diketik
    local toKetik = jawaban
    local inputNow = GetCurrentInput()

    if inputNow and #inputNow > 0 then
        if jawaban:sub(1, #inputNow) == inputNow then
            toKetik = jawaban:sub(#inputNow + 1)
            print("[PRE-FILL] '" .. inputNow .. "' -> sisa: '" .. toKetik .. "'")
        else
            -- Input beda, hapus dulu
            AutoHapus(tombolHapus, #inputNow + 2)
            toKetik = jawaban:sub(#awalan + 1)
        end
    else
        -- Tidak ada TextBox, asumsi awalan sudah ada
        toKetik = jawaban:sub(#awalan + 1)
        if #toKetik == 0 then toKetik = jawaban end
    end

    print("[KETIK] attempt#" .. attempt .. " | '" .. toKetik .. "'")

    if #toKetik == 0 then
        if tombolMasuk then KlikButton(tombolMasuk) end
        return true
    end

    local hurufDiketik = 0
    for i = 1, #toKetik do
        -- Cek giliran masih kita
        local masih = IsGiliranKita()
        if not masih then
            print("[STOP] Giliran habis saat ketik!")
            return false
        end

        local huruf = toKetik:sub(i, i)
        local btn = keys[huruf]

        if btn and btn.Parent and btn.Visible then
            KlikButton(btn)
            hurufDiketik = hurufDiketik + 1
            task.wait(0.055)
        else
            -- Huruf tidak ada -> hapus & ganti kata
            print("[MISS] '" .. huruf .. "' -> ganti kata")
            AutoHapus(tombolHapus, hurufDiketik)
            usedWords[jawaban] = true
            local newJawaban = CariKataAwalan(awalan)
            if newJawaban and IsGiliranKita() then
                task.wait(0.15)
                return KetikKata(newJawaban, awalan, keys, tombolMasuk, tombolHapus, attempt + 1)
            end
            return false
        end
    end

    -- Submit
    task.wait(0.1)
    if IsGiliranKita() and tombolMasuk and tombolMasuk.Parent then
        print("[✅ SUBMIT] -> '" .. jawaban .. "'")
        KlikButton(tombolMasuk)
        return true
    end

    print("[STOP] Waktu habis sebelum submit")
    return false
end

-- =================================================================
-- DETEKSI AWALAN
-- =================================================================
local function DeteksiAwalan()
    local result = nil
    
    pcall(function()
        for _, gui in ipairs(PlayerGui:GetChildren()) do
            if gui:IsA("ScreenGui") and gui.Enabled and gui.Name ~= "AutoSambungKataReal" then
                for _, v in ipairs(gui:GetDescendants()) do
                    if v:IsA("TextLabel") and v.Visible then
                        local txt = v.Text or ""

                        -- "Hurufnya adalah: IS"
                        if txt:find("[Hh]uruf") and txt:find("[Aa]dalah") then
                            local awalan = txt:match("[Aa]dalah[%s:]*([A-Za-z]+)")
                            if awalan and #awalan >= 1 and #awalan <= 5 then
                                result = awalan:lower()
                                return
                            end

                            -- Cari di sibling
                            local parent = v.Parent
                            if parent then
                                for _, sib in ipairs(parent:GetChildren()) do
                                    if sib ~= v and sib.Visible then
                                        if sib:IsA("TextLabel") then
                                            local st = (sib.Text or ""):match("^%s*([A-Za-z]+)%s*$")
                                            if st and #st >= 1 and #st <= 5 then
                                                result = st:lower()
                                                return
                                            end
                                        end
                                        if sib:IsA("Frame") then
                                            local combined = ""
                                            local children = {}
                                            for _, c in ipairs(sib:GetChildren()) do
                                                table.insert(children, c)
                                            end
                                            table.sort(children, function(a, b)
                                                return (a.AbsolutePosition.X or 0) < (b.AbsolutePosition.X or 0)
                                            end)
                                            for _, child in ipairs(children) do
                                                local ct = ""
                                                if child:IsA("TextLabel") or child:IsA("TextButton") then
                                                    ct = (child.Text or ""):match("^%s*([A-Za-z])%s*$") or ""
                                                else
                                                    for _, inner in ipairs(child:GetChildren()) do
                                                        if inner:IsA("TextLabel") then
                                                            ct = (inner.Text or ""):match("^%s*([A-Za-z])%s*$") or ""
                                                            break
                                                        end
                                                    end
                                                end
                                                combined = combined .. ct
                                            end
                                            if #combined >= 1 and #combined <= 5 then
                                                result = combined:lower()
                                                return
                                            end
                                        end
                                    end
                                end
                            end
                        end

                        -- Fallback: ALL CAPS 1-4 huruf di dekat label Huruf
                        local txt2 = txt:match("^%s*([A-Z][A-Z]?[A-Z]?[A-Z]?)%s*$")
                        if txt2 and #txt2 >= 1 and #txt2 <= 4 then
                            local SKIP = {ON=1,OFF=1,OK=1,AI=1,GO=1,NO=1,HI=1,MY=1,AN=1}
                            if not SKIP[txt2] then
                                local parent = v.Parent
                                if parent then
                                    for _, sib in ipairs(parent:GetChildren()) do
                                        if sib:IsA("TextLabel") and (sib.Text or ""):lower():find("huruf") then
                                            result = txt2:lower()
                                            return
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end)

    return result
end

-- =================================================================
-- MAIN LOOP
-- =================================================================
local ENABLED = false
local lastAwalan = ""
local lastTime = 0
local COOLDOWN = 1.5
local proses = false

local function MainLoop()
    if not ENABLED or proses then return end
    if tick() - lastTime < COOLDOWN then return end

    local giliran, keyCount = IsGiliranKita()
    if not giliran then
        if lastAwalan ~= "" then
            print("[⏳] Giliran lawan (" .. keyCount .. " tombol)")
            lastAwalan = ""
            usedWords = {}
            proses = false
        end
        return
    end

    local awalan = DeteksiAwalan()
    if not awalan or awalan == "" then return end

    if awalan ~= lastAwalan then
        usedWords = {}
        print("[🎯 GILIRAN KITA] Awalan: '" .. awalan:upper() .. "'")
    end

    if awalan == lastAwalan and tick() - lastTime < COOLDOWN * 2 then return end

    local jawaban = CariKataAwalan(awalan)
    if not jawaban then
        print("[❌] Tidak ada kata untuk: '" .. awalan .. "'")
        lastAwalan = awalan
        lastTime = tick()
        return
    end

    print("================================")
    print("[⚡ FLASH] '" .. awalan:upper() .. "' -> '" .. jawaban .. "'")
    print("================================")

    proses = true
    lastAwalan = awalan

    task.spawn(function()
        local ok3, err3 = pcall(function()
            local keys, tombolMasuk, tombolHapus = ScanKeyboard()
            local jk = 0
            for _ in pairs(keys) do jk = jk + 1 end

            if jk < 10 then
                print("[❌] Keyboard tidak ditemukan (" .. jk .. ")")
                return
            end

            KetikKata(jawaban, awalan, keys, tombolMasuk, tombolHapus, 1)
        end)
        
        if not ok3 then
            print("[ERR] " .. tostring(err3))
        end
        
        lastTime = tick()
        proses = false
    end)
end

-- =================================================================
-- GUI
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
    pcall(function() ScreenGui:Destroy() end)
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
        print("[⚡ ON] v14 FINAL aktif!")
        print("[INFO] getconnections: " .. (type(getconnections) == "function" and "✓ ADA" or "✗ pakai fallback"))
        print("[INFO] Kamus: " .. #KAMUS .. " kata")
        local g, k = IsGiliranKita()
        print("[INFO] Giliran: " .. (g and "KITA" or "LAWAN") .. " | Keyboard: " .. k)
        task.spawn(ScanKeyboard)
    else
        ToggleBtn.Text = "OFF"
        ToggleBtn.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
        proses = false
        print("[OFF]")
    end
end)

-- Start loop
LoadKamus()

task.spawn(function()
    while true do
        task.wait(0.2)
        pcall(MainLoop)
    end
end)

print("=== AUTO SAMBUNG KATA v14 FINAL - Anonymous9x ===")
print("✅ No nil errors | ✅ Indo only | ✅ Auto backspace")
print("✅ Giliran detection | ✅ Retry sistem")
print("Tekan ON untuk mulai!")

end) -- end pcall utama

if not ok_init then
    print("[CRITICAL ERROR] " .. tostring(err_init))
    -- Coba minimal fallback
    print("Coba restart executor dan jalankan ulang")
end
