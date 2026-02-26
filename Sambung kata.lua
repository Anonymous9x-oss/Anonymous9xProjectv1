-- AUTO SAMBUNG KATA v15 - Anonymous9x
-- Maximum compatibility untuk Delta iOS

-- Tunggu sebentar biar game load
task.wait(1)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui", 10)
if not PlayerGui then return end

-- GUI parent: pakai PlayerGui saja (CoreGui sering restricted di Delta iOS)
local parentGui = PlayerGui

-- Hapus script lama
local old = parentGui:FindFirstChild("AutoSambungKataReal")
if old then old:Destroy() end

-- =================================================================
-- KAMUS
-- =================================================================
local KAMUS_BY_HURUF = {
    a={"abad","abadi","abah","abang","abdi","abjad","abu","acara","ada","adab","adik","adil","air","ajar","ajak","alam","alas","alat","alir","alun","aman","amat","ambil","amuk","anak","angin","angka","angkat","antar","antara","api","arah","arti","asah","asap","asing","asli","asuh","atas","atau","atap","awal","awas","ayah","ayam","ayun"},
    b={"babi","badan","bagai","bagian","bahu","baik","bakar","bakti","baku","bantu","banyak","baring","baru","batas","batu","bawah","bayar","beban","bekal","bela","belah","belai","beli","benak","benar","benih","berat","berani","bersih","besar","biasa","bibir","bijak","biru","bisa","bocah","bohong","boleh","bosan","buat","buah","bumi","buruk","buru","busuk","butuh"},
    c={"cabai","cacat","cahaya","cair","cakap","campur","cantik","cari","cekat","cepat","cerah","ceria","cermat","cicip","cinta","corak","cuci","curiga"},
    d={"dada","dalam","damai","dapur","darah","dasar","datang","daun","daya","debu","dekat","dengar","deras","desa","diam","didik","diri","dorong","duduk","duka","dulu","dunia"},
    e={"edar","ekor","elang","elok","emas","empang","empat","enam","enak","engkau","entah","esok","etika","encer","endap","enggan"},
    f={"faham","fakir","famili","fasih","fajar"},
    g={"gagah","gagal","gajah","galak","gambar","ganas","ganggu","ganteng","garuda","gelap","gempa","gerak","gigih","goreng","gotong","gula","guling","guna","guntur","gusar","guyur","gadis","gading"},
    h={"habis","hadap","hadiah","hadir","hafal","hakim","halus","hambat","hanya","harap","harga","hasil","hati","hebat","helai","henti","heran","hijau","hilang","hirup","hitam","hitung","hormati","hubung","hujan","hutan"},
    i={"ibu","ikut","ilmu","imam","impian","indah","ingin","ingat","inti","isap","isian","islam","istri","istana"},
    j={"jaga","jajan","jalan","jangan","janji","jarang","jatuh","jawab","jelas","jenis","jinak","jual","juara","jujur","julang","jumpa","jurus"},
    k={"kacau","kadang","kaki","kalah","kalimat","kalung","kampung","kapal","karena","kasih","kawasan","kecil","kejam","keras","kerja","ketat","kilat","kira","kontak","kuat","kukuh","kuliah","kuning","kunci","kuda","kursi"},
    l={"lampau","langit","lancar","lanjut","lapang","lapar","laris","lawan","lebih","lemah","lembut","lepas","lestari","limpah","lincah","lindung","logam","lolos","luhur","lulus","lurus","laut","ladang","langkah"},
    m={"mahir","makin","maju","makmur","malang","malas","mampir","mandiri","manfaat","mapan","masak","matang","mekar","menang","minat","miskin","mohon","mujur","mulai","murni","muda","mudah","mulia","murah","meja","mawar","merah","mesra","malam","manusia","musim"},
    n={"nalar","napas","nasib","niat","nilai","nyaman","nyata","nyawa","nanas","nangka","nelayan","neraca","nestapa"},
    o={"obat","olah","orang","obor","ombak","omong"},
    p={"padi","pahat","pahit","pakai","paksa","palu","pandang","panggil","pantai","papan","pasir","patok","payah","pecah","pegang","pekat","pelik","peluh","pendek","penuh","pepaya","perahu","perang","pergi","perih","perkasa","paham","panjang","pasang","patuh","percaya","pikir","pintar","pisah","pokok","potong","pulang","puncak","punya","putus","pagi","panas","pandai","penting","perlu","pesan","pohon","putih"},
    r={"raga","ragam","raih","rakit","rampas","rangkai","rangkul","rasa","ratap","raut","rawit","rebut","rekah","ribut","rindu","roda","rajin","rambut","ramping","rapat","ramai","rantau","rapuh","rawat","rela","rendah","riang","ringan","riwayat","royong","ruang","rukun","rumit","rusak"},
    s={"saat","sabar","sahaja","sakit","sambung","sampai","sayang","sejuk","sehat","semua","sering","setia","siaga","sigap","simpan","singkat","sombong","sukses","sungguh","syukur","sadar","segera","selalu","seluruh","sempurna","senyum","senang","sedih","sudah","sulit","sumber","sungai","sawah","salak","salju","salam","sayur","sekolah","semangat","sepatu"},
    t={"tabah","takut","tangguh","tangkas","tarik","tegar","teguh","tekad","tekun","teladan","tengah","tentram","tepat","terima","tulus","tuntas","turun","tangan","tanah","teman","tenang","terang","tinggi","tirta","tumbuh","tugas","tajam","tali","tamat","tampak","tampan","tanda","tandas","tangis","tangkap","tapak","taring","tasik","tawa","tebal","tegak","teliti","telur","tempat","tenda","tentu","tepung","terbang","ternak","tikar","timun","tinggal","tolong","tongkat","tubuh","tulang","tumpah","tumpul"},
    u={"ubah","ulam","ulang","ulet","ulos","umbut","umbi","ungkap","unjuk","udara","ujung","umur","usaha","utama","untung","upaya","unggul"},
    v={"visi","vital"},
    w={"wakaf","walau","wangi","warung","welas","wibawa","wirausaha","wajib","warga","warisan","waspada","waktu","wajar","warna","wajah"},
    y={"yakin","yakni","yang"},
    z={"zaman","zona"},
}

local usedWords = {}

local function cariKata(awalan)
    awalan = awalan:lower()
    local h = awalan:sub(1,1)
    local list = KAMUS_BY_HURUF[h]
    if not list then return nil end

    -- Kumpulkan yang cocok
    local cocok = {}
    for _, kata in ipairs(list) do
        if kata:sub(1, #awalan) == awalan and #kata > #awalan and not usedWords[kata] then
            table.insert(cocok, kata)
        end
    end
    if #cocok > 0 then
        local p = cocok[math.random(1, #cocok)]
        usedWords[p] = true
        return p
    end

    -- Fallback: 1 huruf
    if #awalan > 1 then
        local cocok2 = {}
        for _, kata in ipairs(list) do
            if not usedWords[kata] and #kata > 1 then
                table.insert(cocok2, kata)
            end
        end
        if #cocok2 > 0 then
            local p = cocok2[math.random(1, #cocok2)]
            usedWords[p] = true
            return p
        end
    end

    return nil
end

-- =================================================================
-- KLIK TOMBOL
-- =================================================================
local function klik(btn)
    if not btn or not btn.Parent then return end
    -- Coba getconnections kalau ada
    if type(getconnections) == "function" then
        pcall(function()
            for _, ev in ipairs({"Activated","MouseButton1Click"}) do
                local conns = getconnections(btn[ev])
                if conns and #conns > 0 then
                    for _, c in ipairs(conns) do
                        if type(c.Function) == "function" then
                            pcall(c.Function)
                        end
                    end
                    return
                end
            end
        end)
    end
    -- Selalu fire juga sebagai backup
    pcall(function() btn.MouseButton1Click:Fire() end)
    pcall(function() btn.Activated:Fire() end)
    pcall(function() btn:Click() end)
end

-- =================================================================
-- SCAN KEYBOARD
-- =================================================================
local function scanKeyboard()
    local keys, masuk, hapus = {}, nil, nil
    pcall(function()
        for _, gui in ipairs(PlayerGui:GetChildren()) do
            if gui:IsA("ScreenGui") and gui.Enabled and gui.Name ~= "AutoSambungKataReal" then
                for _, v in ipairs(gui:GetDescendants()) do
                    if v:IsA("TextButton") and v.Visible then
                        local t = (v.Text or ""):match("^%s*(.-)%s*$") or ""
                        if #t == 1 and t:match("^[a-zA-Z]$") then
                            keys[t:lower()] = v
                        end
                        local tl = t:lower()
                        if tl=="masuk" or tl=="jawab" or tl=="kirim" or tl=="enter" or tl=="submit" then
                            masuk = v
                        end
                        -- Tombol hapus: background merah
                        pcall(function()
                            local r = v.BackgroundColor3.R
                            local g2 = v.BackgroundColor3.G
                            local b = v.BackgroundColor3.B
                            if r > 0.6 and g2 < 0.3 and b < 0.3 then
                                hapus = v
                            end
                        end)
                    end
                end
            end
        end
    end)
    return keys, masuk, hapus
end

-- =================================================================
-- CEK GILIRAN
-- =================================================================
local function isGiliranKita()
    local n = 0
    pcall(function()
        for _, gui in ipairs(PlayerGui:GetChildren()) do
            if gui:IsA("ScreenGui") and gui.Enabled and gui.Name ~= "AutoSambungKataReal" then
                for _, v in ipairs(gui:GetDescendants()) do
                    if v:IsA("TextButton") and v.Visible then
                        local t = (v.Text or ""):match("^%s*(.-)%s*$") or ""
                        if #t == 1 and t:match("^[a-zA-Z]$") then n = n + 1 end
                    end
                end
            end
        end
    end)
    return n >= 20
end

-- =================================================================
-- CEK INPUT
-- =================================================================
local function getInput()
    local r = ""
    pcall(function()
        for _, gui in ipairs(PlayerGui:GetChildren()) do
            if gui:IsA("ScreenGui") and gui.Enabled and gui.Name ~= "AutoSambungKataReal" then
                for _, v in ipairs(gui:GetDescendants()) do
                    if v:IsA("TextBox") and v.Visible then
                        r = (v.Text or ""):lower():match("^%s*(.-)%s*$") or ""
                        return
                    end
                end
            end
        end
    end)
    return r
end

-- =================================================================
-- AUTO HAPUS
-- =================================================================
local function hapusHuruf(tombolHapus, n)
    if not tombolHapus then return end
    for i = 1, (n or 0) + 2 do
        if tombolHapus and tombolHapus.Parent and tombolHapus.Visible then
            klik(tombolHapus)
            task.wait(0.04)
        end
    end
    task.wait(0.1)
end

-- =================================================================
-- DETEKSI AWALAN
-- =================================================================
local function deteksiAwalan()
    local result = nil
    pcall(function()
        for _, gui in ipairs(PlayerGui:GetChildren()) do
            if gui:IsA("ScreenGui") and gui.Enabled and gui.Name ~= "AutoSambungKataReal" then
                for _, v in ipairs(gui:GetDescendants()) do
                    if v:IsA("TextLabel") and v.Visible then
                        local txt = v.Text or ""

                        -- "Hurufnya adalah: IS"
                        if txt:lower():find("huruf") and txt:lower():find("adalah") then
                            local a = txt:match("[Aa]dalah[%s:]*([A-Za-z]+)")
                            if a and #a >= 1 and #a <= 5 then
                                result = a:lower()
                                return
                            end
                            -- Cek sibling
                            if v.Parent then
                                for _, sib in ipairs(v.Parent:GetChildren()) do
                                    if sib ~= v and sib.Visible then
                                        local sibTxt = ""
                                        pcall(function() sibTxt = sib.Text or "" end)
                                        local st = sibTxt:match("^%s*([A-Za-z]+)%s*$")
                                        if st and #st >= 1 and #st <= 5 then
                                            result = st:lower()
                                            return
                                        end
                                        -- Frame berisi kotak huruf
                                        if sib:IsA("Frame") then
                                            local ch = {}
                                            for _, c in ipairs(sib:GetChildren()) do table.insert(ch, c) end
                                            table.sort(ch, function(a2,b2)
                                                local ax, bx = 0, 0
                                                pcall(function() ax = a2.AbsolutePosition.X end)
                                                pcall(function() bx = b2.AbsolutePosition.X end)
                                                return ax < bx
                                            end)
                                            local combined = ""
                                            for _, c in ipairs(ch) do
                                                local ct = ""
                                                pcall(function()
                                                    if c:IsA("TextLabel") or c:IsA("TextButton") then
                                                        ct = (c.Text or ""):match("^%s*([A-Za-z])%s*$") or ""
                                                    else
                                                        for _, inner in ipairs(c:GetChildren()) do
                                                            if inner:IsA("TextLabel") then
                                                                ct = (inner.Text or ""):match("^%s*([A-Za-z])%s*$") or ""
                                                                break
                                                            end
                                                        end
                                                    end
                                                end)
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

                        -- Fallback: ALL CAPS 1-4 huruf
                        local a2 = txt:match("^%s*([A-Z][A-Z]?[A-Z]?[A-Z]?)%s*$")
                        if a2 and #a2 >= 1 and #a2 <= 4 then
                            local SKIP = {ON=1,OFF=1,OK=1,AI=1,GO=1,NO=1,HI=1,MY=1,AN=1}
                            if not SKIP[a2] and v.Parent then
                                for _, sib in ipairs(v.Parent:GetChildren()) do
                                    local sibT = ""
                                    pcall(function() sibT = sib.Text or "" end)
                                    if sibT:lower():find("huruf") then
                                        result = a2:lower()
                                        return
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
-- STATE
-- =================================================================
local ENABLED = false
local lastAwalan = ""
local lastTime = 0
local proses = false

local function mainLoop()
    if not ENABLED or proses then return end
    if tick() - lastTime < 1.5 then return end

    if not isGiliranKita() then
        if lastAwalan ~= "" then
            print("[⏳] Tunggu giliran...")
            lastAwalan = ""
            usedWords = {}
        end
        return
    end

    local awalan = deteksiAwalan()
    if not awalan or awalan == "" then return end

    if awalan ~= lastAwalan then
        usedWords = {}
        print("[🎯] Giliran kita! Awalan: '" .. awalan:upper() .. "'")
    end

    if awalan == lastAwalan and tick() - lastTime < 3 then return end

    local jawaban = cariKata(awalan)
    if not jawaban then
        print("[❌] Tidak ada kata untuk '" .. awalan .. "'")
        lastAwalan = awalan
        lastTime = tick()
        return
    end

    print("[⚡] '" .. awalan:upper() .. "' -> '" .. jawaban .. "'")
    proses = true
    lastAwalan = awalan

    task.spawn(function()
        pcall(function()
            local keys, masuk, hapus = scanKeyboard()
            local n = 0
            for _ in pairs(keys) do n = n + 1 end
            if n < 10 then
                print("[❌] Keyboard tidak ditemukan (" .. n .. ")")
                return
            end

            -- Hitung yang harus diketik
            local input = getInput()
            local toKetik = jawaban:lower()
            local aw = awalan:lower()

            if input and #input > 0 and toKetik:sub(1, #input) == input then
                toKetik = toKetik:sub(#input + 1)
            else
                toKetik = toKetik:sub(#aw + 1)
                if #toKetik == 0 then toKetik = jawaban:lower() end
            end

            print("[KETIK] '" .. toKetik .. "'")

            local ketikCount = 0
            for i = 1, #toKetik do
                if not isGiliranKita() then print("[STOP]") return end
                local h = toKetik:sub(i,i)
                local btn = keys[h]
                if btn and btn.Parent and btn.Visible then
                    klik(btn)
                    ketikCount = ketikCount + 1
                    task.wait(0.055)
                else
                    -- Huruf tidak ada, hapus dan coba kata lain
                    print("[MISS] '" .. h .. "' -> retry")
                    hapusHuruf(hapus, ketikCount)
                    usedWords[jawaban] = true
                    local newKata = cariKata(awalan)
                    if newKata and isGiliranKita() then
                        task.wait(0.15)
                        -- Ketik kata baru
                        local tk2 = newKata:sub(#aw + 1)
                        if #tk2 == 0 then tk2 = newKata end
                        print("[RETRY] -> '" .. newKata .. "'")
                        for j = 1, #tk2 do
                            if not isGiliranKita() then return end
                            local h2 = tk2:sub(j,j)
                            local b2 = keys[h2]
                            if b2 and b2.Parent and b2.Visible then
                                klik(b2)
                                task.wait(0.055)
                            end
                        end
                    end
                    break
                end
            end

            task.wait(0.1)
            if isGiliranKita() and masuk and masuk.Parent then
                klik(masuk)
                print("[✅] Submit!")
            end
        end)
        lastTime = tick()
        proses = false
    end)
end

-- =================================================================
-- GUI
-- =================================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AutoSambungKataReal"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = parentGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 240, 0, 150)
MainFrame.Position = UDim2.new(0.5, -120, 0.5, -75)
MainFrame.BackgroundColor3 = Color3.new(0,0,0)
MainFrame.BorderSizePixel = 2
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0,8)

local Header = Instance.new("TextLabel")
Header.Size = UDim2.new(1,-40,0,30)
Header.Position = UDim2.new(0,10,0,5)
Header.BackgroundTransparency = 1
Header.Text = "Auto Sambung Kata"
Header.TextColor3 = Color3.new(1,1,1)
Header.Font = Enum.Font.SourceSansBold
Header.TextSize = 18
Header.TextXAlignment = Enum.TextXAlignment.Left
Header.Parent = MainFrame

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0,25,0,25)
CloseBtn.Position = UDim2.new(1,-60,0,5)
CloseBtn.BackgroundColor3 = Color3.new(0.8,0,0)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.new(1,1,1)
CloseBtn.Font = Enum.Font.SourceSansBold
CloseBtn.TextSize = 16
CloseBtn.Parent = MainFrame
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0,4)

local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0,25,0,25)
MinBtn.Position = UDim2.new(1,-30,0,5)
MinBtn.BackgroundColor3 = Color3.new(0.5,0.5,0.5)
MinBtn.Text = "-"
MinBtn.TextColor3 = Color3.new(1,1,1)
MinBtn.Font = Enum.Font.SourceSansBold
MinBtn.TextSize = 16
MinBtn.Parent = MainFrame
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0,4)

local Sep = Instance.new("Frame")
Sep.Size = UDim2.new(1,-20,0,1)
Sep.Position = UDim2.new(0,10,0,35)
Sep.BackgroundColor3 = Color3.new(1,1,1)
Sep.BorderSizePixel = 0
Sep.Parent = MainFrame

local Content = Instance.new("Frame")
Content.Size = UDim2.new(1,-20,1,-45)
Content.Position = UDim2.new(0,10,0,40)
Content.BackgroundTransparency = 1
Content.Parent = MainFrame

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0,100,0,35)
ToggleBtn.Position = UDim2.new(0.5,-50,0,5)
ToggleBtn.BackgroundColor3 = Color3.new(0.3,0.3,0.3)
ToggleBtn.Text = "OFF"
ToggleBtn.TextColor3 = Color3.new(1,1,1)
ToggleBtn.Font = Enum.Font.SourceSansBold
ToggleBtn.TextSize = 18
ToggleBtn.Parent = Content
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0,6)

local Info = Instance.new("TextLabel")
Info.Size = UDim2.new(1,0,0,30)
Info.Position = UDim2.new(0,0,0,45)
Info.BackgroundTransparency = 1
Info.Text = "Automatically fill in conjunctions"
Info.TextColor3 = Color3.new(1,1,1)
Info.Font = Enum.Font.SourceSans
Info.TextSize = 13
Info.Parent = Content

local Credit = Instance.new("TextLabel")
Credit.Size = UDim2.new(1,0,0,20)
Credit.Position = UDim2.new(0,0,1,-20)
Credit.BackgroundTransparency = 1
Credit.Text = "Created By Anonymous9x"
Credit.TextColor3 = Color3.new(1,1,1)
Credit.Font = Enum.Font.SourceSans
Credit.TextSize = 11
Credit.TextXAlignment = Enum.TextXAlignment.Right
Credit.Parent = Content

local minimized = false
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        MainFrame.Size = UDim2.new(0,240,0,40)
        Content.Visible = false
        MinBtn.Text = "+"
    else
        MainFrame.Size = UDim2.new(0,240,0,150)
        Content.Visible = true
        MinBtn.Text = "-"
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    ENABLED = false
    pcall(function() ScreenGui:Destroy() end)
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
        print("[ON] v15 aktif!")
    else
        ToggleBtn.Text = "OFF"
        ToggleBtn.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
        proses = false
        print("[OFF]")
    end
end)

task.spawn(function()
    while true do
        task.wait(0.2)
        pcall(mainLoop)
    end
end)

print("=== AUTO SAMBUNG KATA v15 - Anonymous9x ===")
print("Tekan ON untuk mulai!")
