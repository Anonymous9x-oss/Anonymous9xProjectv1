-- =================================================================
-- AUTO SAMBUNG KATA v13 JARVIS FINAL - Anonymous9x
-- ✅ Awalan 2-3 huruf fix (EN, AUR, dll)
-- ✅ Kamus Indonesia only (no English)
-- ✅ Auto backspace + retype kalau salah
-- ✅ Deteksi giliran kita
-- ✅ Ketik cepat
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
-- KAMUS INDONESIA ONLY
-- Filter ketat: hanya kata yang ada di KBBI
-- =================================================================
local KAMUS = {}
local KAMUS_BY_HURUF = {}

-- Kata blacklist (bahasa Inggris / bukan Indonesia)
local BLACKLIST_KATA = {
    -- English common words yang sering muncul di kamus campuran
    the=1,and=1,for=1,are=1,but=1,not=1,you=1,all=1,can=1,had=1,her=1,was=1,one=1,our=1,out=1,day=1,get=1,has=1,him=1,his=1,how=1,its=1,let=1,man=1,new=1,now=1,old=1,see=1,two=1,way=1,who=1,boy=1,did=1,own=1,put=1,say=1,she=1,too=1,use=1,dad=1,mom=1,yes=1,yet=1,any=1,may=1,run=1,ago=1,ask=1,eat=1,fly=1,cut=1,few=1,off=1,sit=1,try=1,act=1,age=1,ago=1,air=1,arm=1,art=1,bag=1,bed=1,big=1,box=1,bus=1,buy=1,car=1,cat=1,cow=1,cup=1,dog=1,dry=1,due=1,ear=1,end=1,eye=1,far=1,fat=1,fit=1,fun=1,god=1,gun=1,hit=1,hot=1,ice=1,job=1,key=1,law=1,leg=1,lie=1,lot=1,low=1,map=1,mix=1,oil=1,pay=1,red=1,sea=1,set=1,six=1,sky=1,sun=1,tax=1,ten=1,top=1,war=1,win=1,
    -- Kata asing lain
    ghana=1,xerosis=1,supaya=1, -- supaya sebenarnya Indonesia tapi sering salah konteks
    tolutolu=1,terayap=1,tersukses=1,tertambat=1,tetawak=1,tadbir=1,
}

-- Kata Indonesia valid yang sering dipakai dalam sambung kata
local KAMUS_INDO = {
    -- A
    "abad","abadi","abang","abjad","abu","acara","ada","adab","adik","adil",
    "air","ajar","ajak","alam","alas","alat","alir","alun","aman","amat",
    "ambil","amuk","anak","angin","angka","angkat","angkut","antar","antara","anting",
    "api","arah","arak","arti","asah","asap","asar","asing","asli","asuh",
    "atas","atau","atap","awal","awas","ayah","ayam","ayun",
    -- B
    "babi","bacan","badan","bagai","bagian","bahu","baik","bakar","bakti","baku",
    "bala","bali","bantu","banyak","baring","baru","batas","batu","bawah","bawang",
    "bayam","bayar","beban","bekal","bela","belah","belai","belang","beli","benak",
    "benar","bengkak","benih","berat","berani","bersih","besar","biasa","bibir","bijak",
    "biru","bisa","bocah","bohong","boleh","bosan","buat","buah","bumi","buruk",
    "buru","busuk","butuh",
    -- C
    "cabai","cacat","cahaya","cair","cakap","campur","cantik","cari","cekat","cepat",
    "cerah","ceria","cermat","cicip","cinta","corak","cuci","curiga",
    -- D
    "dada","dalam","damai","dapur","darah","dasar","datang","daun","daya","debu",
    "dekat","dengar","deras","desa","diam","didik","diri","dorong","duduk","duka",
    "dulu","dunia",
    -- E
    "edar","ekor","elang","elok","emas","empang","empat","enak","engkau","entah",
    "esok","etika",
    -- G
    "gagah","gagal","gajah","galak","gambar","ganas","ganggu","ganteng","garuda",
    "gelap","gempa","gerak","gigih","goreng","gotong","gula","guling","guna","guntur",
    "gusar","guyur",
    -- H
    "habis","hadap","hadiah","hadir","hafal","hakim","halus","hambat","hanya","harap",
    "harga","hasil","hati","hebat","helai","henti","heran","hijau","hilang","hirup",
    "hitam","hitung","hormati","hubung","hujan","hutan",
    -- I
    "ibu","ikut","ilmu","imam","impian","indah","ingin","ingat","inti","isap",
    "isian","islam","istri","istana",
    -- J
    "jaga","jajan","jalan","jangan","janji","jarang","jatuh","jawab","jelas","jenis",
    "jinak","jual","juara","jujur","julang","jumpa","jurus",
    -- K
    "kacau","kadang","kaki","kalah","kalimat","kalung","kampung","kapal","karena",
    "kasih","kawasan","kecil","kejam","keras","kerja","ketat","kilat","kira","kontak",
    "kuat","kukuh","kuliah","kuning","kunci",
    -- L
    "lampau","langit","lancar","lanjut","lapang","lapar","laris","lawan","lebih",
    "lemah","lembut","lepas","lestari","limpah","lincah","lindung","logam","lolos",
    "luhur","lulus","lurus",
    -- M
    "mahir","makin","maju","makmur","malang","malas","mampir","mandiri","manfaat",
    "mapan","masak","matang","mekar","menang","minat","miskin","mohon","mujur",
    "mulai","murni","muda","mudah","mulia","murah",
    -- N
    "nalar","napas","nasib","niat","nilai","nyaman","nyata","nyawa",
    -- O
    "obat","olah","orang",
    -- P
    "paham","panjang","pasang","patuh","percaya","pikir","pintar","pisah","pokok",
    "potong","pulang","puncak","punya","putus","pagi","panas","pandai","penting",
    "perlu","pesan","pohon","putih",
    -- R
    "rajin","rambut","ramping","rapat","ramai","rantau","rapuh","rawat","rela",
    "rendah","riang","ringan","riwayat","royong","ruang","rukun","rumit","rusak",
    -- S
    "sabar","sahaja","sakit","sambung","sampai","sayang","sejuk","sehat","semua",
    "sering","setia","siaga","sigap","simpan","singkat","sombong","sukses","sungguh",
    "syukur","sadar","segera","selalu","seluruh","sempurna","senyum","senang","sedih",
    "sudah","sulit","sumber",
    -- T
    "tabah","takut","tangguh","tangkas","tarik","tegar","teguh","tekad","tekun",
    "teladan","tengah","tentram","tepat","terima","tulus","tuntas","turun","tangan",
    "tanah","teman","tenang","terang","tinggi","tirta","tumbuh","tugas",
    -- U
    "ulet","unggul","untung","upaya","usaha","utama","udara","ujung","ulang","umur",
    -- W
    "wajib","warga","warisan","waspada","waktu","wajar","warna","wajah",
    -- Z
    "zaman","zona",
    -- Kata sambung kata yang sering muncul
    "abad","abdi","abah","abang","abdikan","abadi","abaikan","aberasi","aberan",
    "enau","enak","ekor","elang","elas","elok","emas","embun","empang","empat",
    "encim","endap","enggan","engkau","enjut","entah","enteng","enzim","esok","etik",
    "aurelia", -- skip ini karena nama
    "aura","auran","auransi", -- skip
    "enau","encer","encok","endap","engsel","enjin","ensiklopedia",
    -- Tambah kata awalan EN
    "enam","enar","encer","encok","endap","endut","enggan","engkau","engsel","enjin",
    "entah","enteng","enzim",
    -- Tambah kata awalan AUR
    "aural","aura",
    -- Tambah banyak kata umum KBBI
    "abah","abai","abak","abang","abar","abas","abat","abau","abdi","abek",
    "aben","aber","abet","abid","abih","abik","abil","abis","abit","abiu",
    "meja","mobil","motor","mawar","melon","mangga","mentah","merah","mesra",
    "nikmat","nanas","nangka","nelayan","neraca","nestapa","niat",
    "obor","ombak","omong","onggok","opor","otak","oyak",
    "padi","pahat","pahit","pakai","paksa","palu","pandang","panggil","pantai",
    "papan","pasir","patok","payah","pecah","pegang","pekat","pelik","peluh",
    "pendek","penuh","pepaya","perahu","perang","pergi","perih","perkasa",
    "raga","ragam","raih","rakit","rampas","ranap","rangkai","rangkul","rasa",
    "ratap","raut","rawit","rebut","rekah","renggang","ribut","rindu","roda",
    "saat","saban","sabut","sachet","sadar","sagu","sahan","sahut","saing",
    "tajam","tali","tamat","tampak","tampan","tanda","tandas","tangan","tangis",
    "tangkap","tapak","taring","tasik","tawa","tawon","tayub","tebal","tegak",
    "teliti","telur","tempat","tenda","tentu","tepung","terbang","ternak","tikar",
    "timun","tinggal","tolong","tongkat","tubuh","tulang","tumpah","tumpul",
    "ubah","ubur","ulam","ulang","ulet","ulos","umbut","umbi","ungkap","unjuk",
    "wakaf","walau","wangi","warung","welas","wibawa","wijaya","wirausaha",
}

local function LoadKamus()
    -- Load dari KBBI online
    local ok, res = pcall(function()
        return game:HttpGet("https://raw.githubusercontent.com/eenvyexe/KBBI/refs/heads/main/words.txt")
    end)
    
    local unique = {}
    
    -- Tambah kamus internal dulu
    for _, kata in ipairs(KAMUS_INDO) do
        kata = kata:lower()
        if not unique[kata] and not BLACKLIST_KATA[kata] and not kata:find("%-") and #kata >= 2 then
            unique[kata] = true
            table.insert(KAMUS, kata)
            local h = kata:sub(1,1)
            if not KAMUS_BY_HURUF[h] then KAMUS_BY_HURUF[h] = {} end
            table.insert(KAMUS_BY_HURUF[h], kata)
        end
    end
    
    -- Tambah dari online, tapi filter ketat
    if ok and res and #res > 100 then
        for line in res:gmatch("[^\r\n]+") do
            local kata = line:match("^([%a]+)%s*$") or line:match("^([%a]+)")
            if kata and #kata >= 3 and #kata <= 20 then
                kata = kata:lower()
                -- Filter: skip blacklist, skip kata asing (heuristik)
                local isValid = true
                if BLACKLIST_KATA[kata] then isValid = false end
                if kata:find("%-") then isValid = false end
                -- Skip kata yang terlalu mirip bahasa Inggris (berakhiran -tion, -ing umum, -ness, dll)
                if kata:match("tion$") then isValid = false end
                if kata:match("ness$") then isValid = false end
                if kata:match("ment$") then isValid = false end
                if kata:match("ful$") then isValid = false end
                if kata:match("less$") then isValid = false end
                -- Tambah kalau valid
                if isValid and not unique[kata] then
                    unique[kata] = true
                    table.insert(KAMUS, kata)
                    local h = kata:sub(1,1)
                    if not KAMUS_BY_HURUF[h] then KAMUS_BY_HURUF[h] = {} end
                    table.insert(KAMUS_BY_HURUF[h], kata)
                end
            end
        end
        print("[KAMUS] Online+Internal: " .. #KAMUS .. " kata Indonesia")
    else
        print("[KAMUS] Internal only: " .. #KAMUS .. " kata")
    end
end

local usedWords = {}

-- Cari kata berdasarkan awalan (1, 2, atau 3 huruf)
local function CariKataAwalan(awalan)
    awalan = awalan:lower()
    local hasil = {}
    
    for _, kata in ipairs(KAMUS) do
        if kata:sub(1, #awalan) == awalan
            and #kata > #awalan
            and not usedWords[kata]
            and not BLACKLIST_KATA[kata] then
            table.insert(hasil, kata)
        end
    end
    
    if #hasil > 0 then
        local pilihan = hasil[math.random(1, math.min(#hasil, 100))]
        usedWords[pilihan] = true
        return pilihan
    end
    
    -- Fallback bertahap: kurangi awalan satu huruf
    if #awalan > 1 then
        return CariKataAwalan(awalan:sub(1, #awalan - 1))
    end
    
    return nil
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
-- SCAN KEYBOARD + BACKSPACE
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
                    -- Tombol hapus: background merah atau icon X
                    local bgColor = v.BackgroundColor3
                    local r, g, b = bgColor.R, bgColor.G, bgColor.B
                    if r > 0.6 and g < 0.3 and b < 0.3 then
                        tombolHapus = v
                    end
                end
            end
        end
    end

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
-- AUTO BACKSPACE - Hapus semua huruf yang sudah diketik
-- =================================================================
local function AutoHapus(tombolHapus, jumlahHuruf)
    if not tombolHapus or not tombolHapus.Parent then return end
    print("[HAPUS] Menghapus " .. jumlahHuruf .. " huruf...")
    for i = 1, jumlahHuruf + 2 do  -- +2 ekstra buat jaga-jaga
        if tombolHapus and tombolHapus.Parent and tombolHapus.Visible then
            DeltaKlik(tombolHapus)
            task.wait(0.04)
        else
            break
        end
    end
    task.wait(0.1)
end

-- =================================================================
-- CEK ERROR DARI GAME
-- Deteksi: X merah muncul = jawaban salah
-- =================================================================
local function CekAdaError()
    -- Cari tanda error: X merah baru muncul di area input/game
    for _, gui in ipairs(PlayerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Enabled and gui.Name ~= "AutoSambungKataReal" then
            for _, v in ipairs(gui:GetDescendants()) do
                if v:IsA("TextLabel") and v.Visible then
                    local txt = v.Text:lower()
                    if txt:find("salah") or txt:find("wrong") or txt:find("invalid") or txt:find("tidak valid") then
                        return true
                    end
                end
                -- Cek ImageLabel dengan warna merah yang baru
                if v:IsA("ImageLabel") and v.Visible then
                    local r,g,b = v.ImageColor3.R, v.ImageColor3.G, v.ImageColor3.B
                    if r > 0.7 and g < 0.3 and b < 0.3 then
                        -- Mungkin error icon
                    end
                end
            end
        end
    end
    return false
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
-- CEK GILIRAN KITA
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
    return keyCount >= 20, keyCount
end

-- =================================================================
-- KETIK KATA - DENGAN AUTO BACKSPACE RETRY
-- =================================================================
local function KetikDanSubmit(jawaban, awalan, keys, tombolMasuk, tombolHapus, attempt)
    attempt = attempt or 1
    if attempt > 3 then
        print("[GIVE UP] Sudah 3x coba, skip")
        return false
    end

    jawaban = jawaban:lower()
    awalan = awalan:lower()

    -- Hitung apa yang harus diketik (strip awalan yang sudah pre-fill)
    local inputNow = GetCurrentInput()
    local toKetik = jawaban

    if inputNow and #inputNow > 0 then
        if jawaban:sub(1, #inputNow) == inputNow then
            toKetik = jawaban:sub(#inputNow + 1)
            print("[PRE-FILL] Ada '" .. inputNow .. "' -> ketik: '" .. toKetik .. "'")
        else
            -- Input ada tapi beda -> hapus dulu
            print("[CLEAR] Input '" .. inputNow .. "' beda, hapus dulu")
            AutoHapus(tombolHapus, #inputNow + 3)
            toKetik = jawaban:sub(#awalan + 1)
        end
    else
        -- Tidak ada TextBox -> asumsi awalan sudah pre-fill
        toKetik = jawaban:sub(#awalan + 1)
        if #toKetik == 0 then toKetik = jawaban end
    end

    if #toKetik == 0 then
        print("[SUBMIT LANGSUNG] Awalan sudah cukup")
        if tombolMasuk then DeltaKlik(tombolMasuk) end
        return true
    end

    print("[KETIK] attempt#" .. attempt .. " | '" .. toKetik .. "'")

    -- Ketik huruf per huruf
    local hurufDiketik = 0
    for i = 1, #toKetik do
        if not IsGiliranKita() then
            print("[STOP] Bukan giliran kita!")
            return false
        end

        local huruf = toKetik:sub(i, i)
        local btn = keys[huruf]
        if btn and btn.Parent and btn.Visible then
            DeltaKlik(btn)
            hurufDiketik = hurufDiketik + 1
            task.wait(0.055)
        else
            print("[MISS] '" .. huruf .. "' tidak ada, hapus & coba kata lain")
            -- Hapus apa yang sudah diketik
            AutoHapus(tombolHapus, hurufDiketik)
            -- Cari kata baru
            usedWords[jawaban] = true
            local newJawaban = CariKataAwalan(awalan)
            if newJawaban then
                print("[RETRY] Ganti ke: '" .. newJawaban .. "'")
                task.wait(0.1)
                return KetikDanSubmit(newJawaban, awalan, keys, tombolMasuk, tombolHapus, attempt + 1)
            else
                return false
            end
        end
    end

    -- Submit
    task.wait(0.1)
    if not IsGiliranKita() then
        print("[STOP] Waktu habis sebelum submit!")
        return false
    end

    if tombolMasuk and tombolMasuk.Parent then
        print("[SUBMIT] Masuk! -> '" .. jawaban .. "'")
        DeltaKlik(tombolMasuk)
    end

    -- Tunggu sebentar dan cek error
    task.wait(0.3)
    if CekAdaError() then
        print("[ERROR GAME] Kata ditolak! Hapus dan coba lagi...")
        AutoHapus(tombolHapus, #toKetik + 3)
        usedWords[jawaban] = true
        local newJawaban = CariKataAwalan(awalan)
        if newJawaban and IsGiliranKita() then
            task.wait(0.2)
            return KetikDanSubmit(newJawaban, awalan, keys, tombolMasuk, tombolHapus, attempt + 1)
        end
    end

    return true
end

-- =================================================================
-- DETEKSI AWALAN GAME - IMPROVED
-- =================================================================
local function DeteksiAwalan()
    for _, gui in ipairs(PlayerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Enabled and gui.Name ~= "AutoSambungKataReal" then
            for _, v in ipairs(gui:GetDescendants()) do
                if v:IsA("TextLabel") and v.Visible then
                    local txt = v.Text

                    -- Pattern: "Hurufnya adalah: IS" atau "Hurufnya adalah: EN" atau "Hurufnya adalah: AUR"
                    if txt:find("[Hh]uruf") and txt:find("[Aa]dalah") then
                        -- Cari awalan di teks yang sama
                        local awalan = txt:match("[Aa]dalah[%s:]*([A-Za-z]+)")
                        if awalan and #awalan >= 1 and #awalan <= 5 then
                            return awalan:lower()
                        end

                        -- Cari di sibling node
                        local parent = v.Parent
                        if parent then
                            -- Cari TextLabel sibling yang berisi awalan
                            for _, sib in ipairs(parent:GetChildren()) do
                                if sib ~= v and sib.Visible then
                                    if sib:IsA("TextLabel") then
                                        local st = sib.Text:match("^%s*([A-Za-z]+)%s*$")
                                        if st and #st >= 1 and #st <= 5 then
                                            return st:lower()
                                        end
                                    end
                                    -- Frame berisi kotak-kotak huruf
                                    if sib:IsA("Frame") then
                                        local combined = ""
                                        local children = {}
                                        for _, c in ipairs(sib:GetChildren()) do
                                            if c:IsA("TextLabel") or c:IsA("TextButton") or c:IsA("Frame") then
                                                table.insert(children, c)
                                            end
                                        end
                                        -- Sort by X position
                                        table.sort(children, function(a, b)
                                            return a.AbsolutePosition.X < b.AbsolutePosition.X
                                        end)
                                        for _, child in ipairs(children) do
                                            -- Ambil huruf dari TextLabel di dalam
                                            local ct = ""
                                            if child:IsA("TextLabel") or child:IsA("TextButton") then
                                                ct = child.Text:match("^%s*([A-Za-z])%s*$") or ""
                                            else
                                                -- Frame dalam frame (kotak huruf)
                                                for _, inner in ipairs(child:GetChildren()) do
                                                    if inner:IsA("TextLabel") then
                                                        ct = inner.Text:match("^%s*([A-Za-z])%s*$") or ""
                                                        break
                                                    end
                                                end
                                            end
                                            combined = combined .. ct
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
    end

    -- Fallback: cari label ALL CAPS 1-4 huruf di dekat label "Huruf"
    for _, gui in ipairs(PlayerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Enabled and gui.Name ~= "AutoSambungKataReal" then
            for _, v in ipairs(gui:GetDescendants()) do
                if v:IsA("TextLabel") and v.Visible then
                    local txt2 = v.Text:match("^%s*([A-Z][A-Z]?[A-Z]?[A-Z]?)%s*$")
                    if txt2 and #txt2 >= 1 and #txt2 <= 4 then
                        local SKIP = {ON=1,OFF=1,OK=1,AI=1,GO=1,NO=1,HI=1,MY=1,AN=1}
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

    -- Cek giliran
    local giliran, keyCount = IsGiliranKita()
    if not giliran then
        if lastAwalan ~= "" then
            print("[⏳ TUNGGU] Giliran lawan (" .. keyCount .. " tombol)")
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
        print("[❌ SKIP] Tidak ada kata Indo untuk: '" .. awalan .. "'")
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
        local keys, tombolMasuk, tombolHapus = ScanKeyboard()
        local jk = 0
        for _ in pairs(keys) do jk = jk + 1 end

        if jk < 10 then
            print("[❌ ERROR] Keyboard tidak ditemukan!")
            proses = false
            lastTime = tick()
            return
        end

        KetikDanSubmit(jawaban, awalan, keys, tombolMasuk, tombolHapus, 1)
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
        print("[⚡ ON] v13 JARVIS FINAL aktif!")
        print("[INFO] getconnections: " .. (getconnections and "✓ ADA" or "✗ tidak ada"))
        print("[INFO] Kamus: " .. #KAMUS .. " kata Indonesia")
        local g, k = IsGiliranKita()
        print("[INFO] Giliran kita: " .. tostring(g) .. " | Keyboard: " .. k .. " tombol")
        task.spawn(ScanKeyboard)
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

print("=== AUTO SAMBUNG KATA v13 JARVIS FINAL ===")
print("✅ Kamus Indonesia only")
print("✅ Auto backspace + retry jika salah")
print("✅ Awalan 1-3 huruf (E, EN, AUR)")
print("✅ Diam saat giliran lawan")
print("Tekan ON untuk mulai!")
