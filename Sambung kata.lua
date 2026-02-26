-- AUTO SAMBUNG KATA v17 JARVIS - Anonymous9x
-- FIX TOTAL: Backspace agresif + awalan brute force scan

task.wait(1)
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui", 10)
if not PlayerGui then return end

local old = PlayerGui:FindFirstChild("AutoSambungKataReal")
if old then old:Destroy() end

-- =================================================================
-- KAMUS
-- =================================================================
local KAMUS_BY_HURUF = {
    a={"abad","abadi","abah","abang","abdi","abjad","abu","acara","ada","adab","adik","adil","air","ajar","ajak","alam","alas","alat","alir","alun","aman","amat","ambil","amuk","anak","angin","angka","angkat","antar","antara","api","arah","arti","asah","asap","asing","asli","asuh","atas","atau","atap","awal","awas","ayah","ayam","ayun","akar","alami","alang","alba","alga","alih","alit","alpa","amah","ambang","ambis"},
    b={"babi","badan","bagai","bagian","bahu","baik","bakar","bakti","baku","bantu","banyak","baring","baru","batas","batu","bawah","bayar","beban","bekal","bela","belah","belai","beli","benak","benar","benih","berat","berani","bersih","besar","biasa","bibir","bijak","biru","bisa","bocah","bohong","boleh","bosan","buat","buah","bumi","buruk","buru","busuk","butuh","baja","bajak","balai","balam","balas","baldi","balai"},
    c={"cabai","cacat","cahaya","cair","cakap","campur","cantik","cari","cekat","cepat","cerah","ceria","cermat","cicip","cinta","corak","cuci","curiga","cabul","cacar","cacah","cadik","cagak"},
    d={"dada","dalam","damai","dapur","darah","dasar","datang","daun","daya","debu","dekat","dengar","deras","desa","diam","didik","diri","dorong","duduk","duka","dulu","dunia","danau","dandan","dampak","dagul","dahaga"},
    e={"edar","ekor","elang","elok","emas","empang","empat","enam","enak","engkau","entah","esok","etika","encer","endap","enggan","engsel","enau","encim","encok","endut","enjut","enteng","enzim","erat"},
    f={"faham","fakir","famili","fasih","fajar","fadil","fana","fatwa","fauna","fikir","fikih","fitna","flora"},
    g={"gagah","gagal","gajah","galak","gambar","ganas","ganggu","ganteng","garuda","gelap","gempa","gerak","gigih","goreng","gotong","gula","guling","guna","guntur","gusar","guyur","gadis","gading","gaib","gairah","galau","gali","galon","gamit","gampang","gandum","ganjal","ganjil","gapai","gardu","garis"},
    h={"habis","hadap","hadiah","hadir","hafal","hakim","halus","hambat","hanya","harap","harga","hasil","hati","hebat","helai","henti","heran","hijau","hilang","hirup","hitam","hitung","hormati","hubung","hujan","hutan","halal","halaman","halau","halia","hambar","hampir"},
    i={"ibu","ikut","ilmu","imam","impian","indah","ingin","ingat","inti","isap","isian","islam","istri","istana","ibarat","ibadat","idam","idaman","ikhlas","iman","imban","imbang"},
    j={"jaga","jajan","jalan","jangan","janji","jarang","jatuh","jawab","jelas","jenis","jinak","jual","juara","jujur","julang","jumpa","jurus","jalang","jalur","jamah","jambak","jambu","jamin","janda","jangka","jangkau"},
    k={"kacau","kadang","kaki","kalah","kalimat","kalung","kampung","kapal","karena","kasih","kawasan","kecil","kejam","keras","kerja","ketat","kilat","kira","kontak","kuat","kukuh","kuliah","kuning","kunci","kuda","kursi","kaba","kabul","kacang","kadar","kafan","kagum","kait","kajian","kakak","kakap","kakus"},
    l={"lampau","langit","lancar","lanjut","lapang","lapar","laris","lawan","lebih","lemah","lembut","lepas","lestari","limpah","lincah","lindung","logam","lolos","luhur","lulus","lurus","laut","ladang","langkah","labrak","lacak","lacur","lagak","lahap","lahar","lahir","lakar","laknat","laku"},
    m={"mahir","makin","maju","makmur","malang","malas","mampir","mandiri","manfaat","mapan","masak","matang","mekar","menang","minat","miskin","mohon","mujur","mulai","murni","muda","mudah","mulia","murah","meja","mawar","merah","mesra","malam","manusia","musim","musuh","macam","macan","macet","mahkamah","mahal","mahkota","maklum","makna"},
    n={"nalar","napas","nasib","niat","nilai","nyaman","nyata","nyawa","nanas","nangka","nelayan","neraca","nestapa","nabi","nada","nadir","nafas","nafkah","naga","naik","nakal","naluri","nanar","nangis","narasi","naskah","nata","naung"},
    o={"obat","olah","orang","obor","ombak","omong","obral","ogah","olok","ombang","otak"},
    p={"padi","pahat","pahit","pakai","paksa","palu","pandang","panggil","pantai","papan","pasir","patok","payah","pecah","pegang","pekat","pelik","peluh","pendek","penuh","pepaya","perahu","perang","pergi","perih","perkasa","paham","panjang","pasang","patuh","percaya","pikir","pintar","pisah","pokok","potong","pulang","puncak","punya","putus","pagi","panas","pandai","penting","perlu","pesan","pohon","putih","pacul","padang","pagar","pagut"},
    r={"raga","ragam","raih","rakit","rampas","rangkai","rangkul","rasa","ratap","raut","rawit","rebut","rekah","ribut","rindu","roda","rajin","rambut","ramping","rapat","ramai","rantau","rapuh","rawat","rela","rendah","riang","ringan","riwayat","royong","ruang","rukun","rumit","rusak","rabak","rabat","racau","racik","racun","ragbi","ragukan","rahang"},
    s={"saat","sabar","sahaja","sakit","sambung","sampai","sayang","sejuk","sehat","semua","sering","setia","siaga","sigap","simpan","singkat","sombong","sukses","sungguh","syukur","sadar","segera","selalu","seluruh","sempurna","senyum","senang","sedih","sudah","sulit","sumber","sungai","sawah","salak","salju","salam","sayur","sekolah","semangat","sepatu","sabah","sabak","sabar","sabet","sabuk","sabun","sadis"},
    t={"tabah","takut","tangguh","tangkas","tarik","tegar","teguh","tekad","tekun","teladan","tengah","tentram","tepat","terima","tulus","tuntas","turun","tangan","tanah","teman","tenang","terang","tinggi","tirta","tumbuh","tugas","tajam","tali","tamat","tampak","tampan","tanda","tandas","tangis","tangkap","tapak","taring","tasik","tawa","tebal","tegak","teliti","telur","tempat","tenda","tentu","tepung","terbang","ternak","tikar","timun","tinggal","tolong","tongkat","tubuh","tulang","tumpah","tumpul","tabik","tabir","tabuh","tabung"},
    u={"ubah","ulam","ulang","ulet","ulos","umbut","umbi","ungkap","unjuk","udara","ujung","umur","usaha","utama","untung","upaya","unggul","uban","ucap","ujar","ujaran","ujian","ukir","ukur","ulak","ulat","ulur","umpan","umpat","umum","unggas","unsur","untai","urut"},
    v={"visi","vital","vaksin"},
    w={"wakaf","walau","wangi","warung","welas","wibawa","wirausaha","wajib","warga","warisan","waspada","waktu","wajar","warna","wajah","wabak","wacana","wadah","wafat","wahana","wajik","wakal","wakas","wakil","wanita","warak","waris"},
    y={"yakin","yakni","yang","yatim"},
    z={"zaman","zona","zakat","zat","zikir"},
}

task.spawn(function()
    local ok, res = pcall(game.HttpGet, game, "https://raw.githubusercontent.com/eenvyexe/KBBI/refs/heads/main/words.txt")
    if ok and res then
        local bad = {the=1,and=1,for=1,are=1,was=1,you=1,all=1,can=1,get=1,has=1,him=1,his=1,new=1,now=1,see=1,who=1,did=1,say=1,she=1,too=1,use=1,yes=1,any=1,may=1,run=1}
        for line in res:gmatch("[^\r\n]+") do
            local w = line:match("^([%a]+)")
            if w and #w>=2 and #w<=20 then
                w = w:lower()
                if not bad[w] and not w:match("tion$") and not w:match("ness$") then
                    local h = w:sub(1,1)
                    if not KAMUS_BY_HURUF[h] then KAMUS_BY_HURUF[h]={} end
                    table.insert(KAMUS_BY_HURUF[h], w)
                end
            end
        end
        print("[KAMUS] Online loaded")
    end
end)

local used = {}
local function cariKata(awalan)
    awalan = awalan:lower()
    for pjg = #awalan, 1, -1 do
        local aw = awalan:sub(1,pjg)
        local h = aw:sub(1,1)
        local list = KAMUS_BY_HURUF[h]
        if list then
            local ok2 = {}
            for _, k in ipairs(list) do
                if k:sub(1,#aw)==aw and #k>#aw and not used[k] then
                    table.insert(ok2, k)
                end
            end
            if #ok2 > 0 then
                local p = ok2[math.random(1, math.min(#ok2,50))]
                used[p] = true
                return p, aw
            end
        end
    end
    return nil, awalan
end

-- =================================================================
-- KLIK
-- =================================================================
local function klik(btn)
    if not btn or not btn.Parent then return end
    if type(getconnections)=="function" then
        pcall(function()
            for _,ev in ipairs({"Activated","MouseButton1Click"}) do
                local conns = getconnections(btn[ev])
                if conns and #conns>0 then
                    for _,c in ipairs(conns) do
                        if type(c.Function)=="function" then pcall(c.Function) end
                    end
                    return
                end
            end
        end)
    end
    pcall(function() btn.MouseButton1Click:Fire() end)
    pcall(function() btn.Activated:Fire() end)
    pcall(function() btn:Click() end)
end

-- =================================================================
-- SCAN KEYBOARD
-- =================================================================
local KB = {keys={}, masuk=nil, hapus=nil, t=0}

local function scanKB()
    if tick()-KB.t < 1.5 and next(KB.keys)~=nil then return KB.keys, KB.masuk, KB.hapus end
    local keys,masuk,hapus = {}, nil, nil
    
    -- Kumpulkan semua TextButton visible
    local allBtns = {}
    pcall(function()
        for _,gui in ipairs(PlayerGui:GetChildren()) do
            if gui:IsA("ScreenGui") and gui.Enabled and gui.Name~="AutoSambungKataReal" then
                for _,v in ipairs(gui:GetDescendants()) do
                    if v:IsA("TextButton") and v.Visible then
                        table.insert(allBtns, v)
                    end
                end
            end
        end
    end)

    for _,v in ipairs(allBtns) do
        local t = (v.Text or ""):match("^%s*(.-)%s*$") or ""
        -- Huruf
        if #t==1 and t:match("^[a-zA-Z]$") then
            keys[t:lower()] = v
        end
        -- Masuk
        local tl = t:lower()
        if tl=="masuk" or tl=="jawab" or tl=="kirim" or tl=="enter" or tl=="submit" then
            masuk = v
        end
        -- Hapus: cari tombol merah
        pcall(function()
            local r,g,b = v.BackgroundColor3.R, v.BackgroundColor3.G, v.BackgroundColor3.B
            if r>0.5 and g<0.4 and b<0.4 then
                hapus = v
            end
        end)
    end
    
    -- Kalau hapus tidak ketemu by color, cari by name/position
    if not hapus then
        for _,v in ipairs(allBtns) do
            local nm = v.Name:lower()
            if nm:find("hapus") or nm:find("del") or nm:find("back") or nm:find("clear") or nm:find("erase") then
                hapus = v
                print("[KB] Hapus by name: " .. v.Name)
                break
            end
        end
    end
    
    -- Last resort: tombol paling kanan di baris bawah keyboard
    if not hapus then
        local rightmost = nil
        local maxX = 0
        for _,v in ipairs(allBtns) do
            local t = (v.Text or ""):match("^%s*(.-)%s*$") or ""
            local tl = t:lower()
            -- Bukan tombol masuk, bukan huruf biasa
            if tl~="masuk" and tl~="jawab" and tl~="kirim" and tl~="enter" and not (tl:match("^[a-z]$")) then
                pcall(function()
                    local x = v.AbsolutePosition.X
                    if x > maxX then
                        maxX = x
                        rightmost = v
                    end
                end)
            end
        end
        if rightmost then
            hapus = rightmost
            print("[KB] Hapus by position: " .. rightmost.Name .. " pos=" .. maxX)
        end
    end

    local n = 0
    for _ in pairs(keys) do n=n+1 end
    if n >= 10 then
        KB.keys, KB.masuk, KB.hapus, KB.t = keys, masuk, hapus, tick()
        print("[KB] " .. n .. " huruf | Masuk:" .. (masuk and masuk.Text or "?") .. " | Hapus:" .. (hapus and hapus.Name or "TIDAK ADA"))
    end
    return keys, masuk, hapus
end

-- =================================================================
-- CEK GILIRAN
-- =================================================================
local function isGiliran()
    local n=0
    pcall(function()
        for _,gui in ipairs(PlayerGui:GetChildren()) do
            if gui:IsA("ScreenGui") and gui.Enabled and gui.Name~="AutoSambungKataReal" then
                for _,v in ipairs(gui:GetDescendants()) do
                    if v:IsA("TextButton") and v.Visible then
                        local t=(v.Text or ""):match("^%s*(.-)%s*$") or ""
                        if #t==1 and t:match("^[a-zA-Z]$") then n=n+1 end
                    end
                end
            end
        end
    end)
    return n>=20
end

-- =================================================================
-- GET INPUT
-- =================================================================
local function getInput()
    local r=""
    pcall(function()
        for _,gui in ipairs(PlayerGui:GetChildren()) do
            if gui:IsA("ScreenGui") and gui.Enabled and gui.Name~="AutoSambungKataReal" then
                for _,v in ipairs(gui:GetDescendants()) do
                    if v:IsA("TextBox") and v.Visible then
                        r=(v.Text or ""):lower():match("^%s*(.-)%s*$") or ""
                        return
                    end
                end
            end
        end
    end)
    return r
end

-- =================================================================
-- BACKSPACE - 3 METODE
-- =================================================================
local function doBackspace(hapus, n)
    n = (n or 0) + 3  -- extra safety
    print("[BS] Hapus " .. n .. " huruf via " .. (hapus and "tombol merah" or "fallback"))
    
    -- Method 1: Klik tombol hapus
    if hapus and hapus.Parent then
        for i=1,n do
            if hapus.Parent and hapus.Visible then
                klik(hapus)
                task.wait(0.04)
            end
        end
        task.wait(0.1)
        return
    end
    
    -- Method 2: VirtualInputManager Backspace
    pcall(function()
        local VIM = game:GetService("VirtualInputManager")
        for i=1,n do
            VIM:SendKeyEvent(true, Enum.KeyCode.Backspace, false, nil)
            task.wait(0.03)
            VIM:SendKeyEvent(false, Enum.KeyCode.Backspace, false, nil)
            task.wait(0.03)
        end
    end)
    
    task.wait(0.1)
end

-- =================================================================
-- DETEKSI AWALAN - BRUTE FORCE SEMUA CARA
-- =================================================================
local function deteksiAwalan()
    local result = nil
    
    pcall(function()
        -- Kumpulkan semua TextLabel visible
        local allLabels = {}
        for _,gui in ipairs(PlayerGui:GetChildren()) do
            if gui:IsA("ScreenGui") and gui.Enabled and gui.Name~="AutoSambungKataReal" then
                for _,v in ipairs(gui:GetDescendants()) do
                    if v:IsA("TextLabel") and v.Visible then
                        table.insert(allLabels, v)
                    end
                end
            end
        end
        
        -- Cari label "Huruf"
        local hurufLabel = nil
        for _,v in ipairs(allLabels) do
            local t = (v.Text or ""):lower()
            if t:find("huruf") then
                hurufLabel = v
                
                -- CARA 1: Awalan inline di teks yang sama
                local a = (v.Text or ""):match("[Aa]dalah[%s:]+([A-Za-z]+)")
                if a and #a>=1 and #a<=6 then
                    result = a:lower()
                    return
                end
                
                break
            end
        end
        
        if not hurufLabel then return end
        
        -- CARA 2: Sibling langsung dari parent hurufLabel
        local parent = hurufLabel.Parent
        if parent then
            for _,sib in ipairs(parent:GetChildren()) do
                if sib~=hurufLabel and sib.Visible then
                    -- TextLabel sibling
                    if sib:IsA("TextLabel") then
                        local st=(sib.Text or ""):match("^%s*([A-Za-z]+)%s*$")
                        if st and #st>=1 and #st<=6 then
                            result=st:lower()
                            return
                        end
                    end
                    
                    -- Frame sibling -> collect huruf dari children
                    if sib:IsA("Frame") or sib:IsA("ScrollingFrame") then
                        local hurufList = {}
                        local ch = sib:GetChildren()
                        table.sort(ch, function(a2,b2)
                            local ax,bx=0,0
                            pcall(function() ax=a2.AbsolutePosition.X end)
                            pcall(function() bx=b2.AbsolutePosition.X end)
                            return ax<bx
                        end)
                        for _,c in ipairs(ch) do
                            local ct=""
                            -- Direct TextLabel
                            if c:IsA("TextLabel") or c:IsA("TextButton") then
                                ct=(c.Text or ""):match("^%s*([A-Za-z])%s*$") or ""
                            else
                                -- Frame dalam frame (kotak huruf)
                                for _,inner in ipairs(c:GetDescendants()) do
                                    if inner:IsA("TextLabel") then
                                        local it=(inner.Text or ""):match("^%s*([A-Za-z])%s*$")
                                        if it then ct=it break end
                                    end
                                end
                            end
                            if ct~="" then table.insert(hurufList, ct) end
                        end
                        local combined=table.concat(hurufList)
                        if #combined>=1 and #combined<=6 then
                            result=combined:lower()
                            return
                        end
                    end
                end
            end
        end
        
        -- CARA 3: Scan SEMUA label ALL CAPS di dekat hurufLabel (radius posisi)
        local hx, hy = 0, 0
        pcall(function() hx=hurufLabel.AbsolutePosition.X hy=hurufLabel.AbsolutePosition.Y end)
        
        local capsCandidates = {}
        for _,v in ipairs(allLabels) do
            if v~=hurufLabel then
                local t=(v.Text or ""):match("^%s*([A-Za-z][A-Za-z]?[A-Za-z]?[A-Za-z]?[A-Za-z]?)%s*$")
                if t and #t>=1 and #t<=5 and t==t:upper() then
                    local SKIP={ON=1,OFF=1,OK=1,GO=1,NO=1,AI=1,HI=1}
                    if not SKIP[t] then
                        -- Cek jarak dari hurufLabel
                        local vx,vy=0,0
                        pcall(function() vx=v.AbsolutePosition.X vy=v.AbsolutePosition.Y end)
                        local dist=math.abs(vx-hx)+math.abs(vy-hy)
                        table.insert(capsCandidates, {label=v, text=t, dist=dist})
                    end
                end
            end
        end
        -- Sort by jarak terdekat
        table.sort(capsCandidates, function(a2,b2) return a2.dist<b2.dist end)
        if #capsCandidates>0 then
            result=capsCandidates[1].text:lower()
            return
        end
        
        -- CARA 4: Cari TextLabel yang BARU SAJA berubah (di-track)
        -- ini harus pake sistem tracking, skip dulu
        
    end)
    
    return result
end

-- =================================================================
-- KETIK
-- =================================================================
local function ketik(jawaban, aw, keys, masuk, hapus)
    jawaban=jawaban:lower()
    aw=(aw or ""):lower()
    
    local input=getInput()
    local toKetik=jawaban
    
    if input and #input>0 then
        if jawaban:sub(1,#input)==input then
            toKetik=jawaban:sub(#input+1)
            print("[PRE] '" .. input .. "' -> sisa: '" .. toKetik .. "'")
        else
            print("[CLEAR] input salah, hapus...")
            doBackspace(hapus, #input)
            toKetik=jawaban:sub(#aw+1)
            if #toKetik==0 then toKetik=jawaban end
        end
    else
        toKetik=jawaban:sub(#aw+1)
        if #toKetik==0 then toKetik=jawaban end
    end
    
    print("[KETIK] '" .. toKetik .. "'")
    if #toKetik==0 then
        if masuk then klik(masuk) end
        return true
    end
    
    local ketikN=0
    for i=1,#toKetik do
        if not isGiliran() then print("[STOP]") return false end
        local h=toKetik:sub(i,i)
        local btn=keys[h]
        if btn and btn.Parent and btn.Visible then
            klik(btn)
            ketikN=ketikN+1
            task.wait(0.055)
        else
            print("[MISS] '" .. h .. "'")
            doBackspace(hapus, ketikN)
            return false
        end
    end
    
    task.wait(0.1)
    if isGiliran() and masuk and masuk.Parent then
        klik(masuk)
        print("[✅] '" .. jawaban .. "'")
        return true
    end
    return false
end

-- =================================================================
-- MAIN
-- =================================================================
local ENABLED=false
local lastAw=""
local lastT=0
local proses=false

local function mainLoop()
    if not ENABLED or proses then return end
    if tick()-lastT<1.3 then return end
    
    if not isGiliran() then
        if lastAw~="" then
            print("[⏳] Giliran lawan")
            lastAw=""
            used={}
            KB.t=0  -- reset cache KB
        end
        return
    end
    
    local awalan=deteksiAwalan()
    if not awalan or awalan=="" then return end
    
    if awalan~=lastAw then
        used={}
        print("[🎯] Awalan: '" .. awalan:upper() .. "'")
    end
    if awalan==lastAw and tick()-lastT<2.5 then return end
    
    local jawaban, awalanPakai = cariKata(awalan)
    if not jawaban then
        print("[❌] Tidak ada kata: '" .. awalan .. "'")
        lastAw=awalan
        lastT=tick()
        return
    end
    
    print("[⚡] '" .. awalan:upper() .. "' -> '" .. jawaban .. "'")
    proses=true
    lastAw=awalan
    
    task.spawn(function()
        pcall(function()
            local keys,masuk,hapus=scanKB()
            local n=0
            for _ in pairs(keys) do n=n+1 end
            if n<10 then
                print("[❌] KB " .. n .. " tombol")
                return
            end
            
            for attempt=1,3 do
                if not isGiliran() then break end
                local ok=ketik(jawaban, awalanPakai, keys, masuk, hapus)
                if ok then break end
                used[jawaban]=true
                jawaban,awalanPakai=cariKata(awalan)
                if not jawaban then break end
                print("[RETRY#" .. attempt .. "] -> '" .. jawaban .. "'")
                task.wait(0.2)
            end
        end)
        lastT=tick()
        proses=false
    end)
end

-- =================================================================
-- GUI
-- =================================================================
local SG=Instance.new("ScreenGui")
SG.Name="AutoSambungKataReal"
SG.ResetOnSpawn=false
SG.Parent=PlayerGui

local MF=Instance.new("Frame")
MF.Size=UDim2.new(0,240,0,155)
MF.Position=UDim2.new(0.5,-120,0.5,-77)
MF.BackgroundColor3=Color3.new(0,0,0)
MF.BorderSizePixel=2
MF.Active=true
MF.Draggable=true
MF.ClipsDescendants=true
MF.Parent=SG
Instance.new("UICorner",MF).CornerRadius=UDim.new(0,8)

local function mkLabel(parent, text, size, pos, bold, align)
    local l=Instance.new("TextLabel")
    l.Size=size
    l.Position=pos
    l.BackgroundTransparency=1
    l.Text=text
    l.TextColor3=Color3.new(1,1,1)
    l.Font=bold and Enum.Font.SourceSansBold or Enum.Font.SourceSans
    l.TextSize=bold and 18 or 13
    l.TextXAlignment=align or Enum.TextXAlignment.Left
    l.Parent=parent
    return l
end

local function mkBtn(parent, text, size, pos, color)
    local b=Instance.new("TextButton")
    b.Size=size
    b.Position=pos
    b.BackgroundColor3=color
    b.Text=text
    b.TextColor3=Color3.new(1,1,1)
    b.Font=Enum.Font.SourceSansBold
    b.TextSize=14
    b.Parent=parent
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,4)
    return b
end

mkLabel(MF,"Auto Sambung Kata",UDim2.new(1,-40,0,30),UDim2.new(0,10,0,5),true)
local CloseBtn=mkBtn(MF,"X",UDim2.new(0,25,0,25),UDim2.new(1,-60,0,5),Color3.new(0.8,0,0))
local MinBtn=mkBtn(MF,"-",UDim2.new(0,25,0,25),UDim2.new(1,-30,0,5),Color3.new(0.5,0.5,0.5))

local sep=Instance.new("Frame")
sep.Size=UDim2.new(1,-20,0,1)
sep.Position=UDim2.new(0,10,0,35)
sep.BackgroundColor3=Color3.new(1,1,1)
sep.BorderSizePixel=0
sep.Parent=MF

local Content=Instance.new("Frame")
Content.Size=UDim2.new(1,-20,1,-45)
Content.Position=UDim2.new(0,10,0,40)
Content.BackgroundTransparency=1
Content.Parent=MF

local ToggleBtn=mkBtn(Content,"OFF",UDim2.new(0,100,0,35),UDim2.new(0.5,-50,0,5),Color3.new(0.3,0.3,0.3))
ToggleBtn.TextSize=18

-- Status label
local StatusLbl=mkLabel(Content,"Menunggu...",UDim2.new(1,0,0,20),UDim2.new(0,0,0,45),false,Enum.TextXAlignment.Center)
StatusLbl.TextSize=12

-- Debug button (scan awalan manual)
local DbgBtn=mkBtn(Content,"SCAN",UDim2.new(0,55,0,22),UDim2.new(1,-60,0,48),Color3.new(0.2,0.4,0.8))
DbgBtn.TextSize=12

mkLabel(Content,"By Anonymous9x",UDim2.new(1,0,0,18),UDim2.new(0,0,1,-18),false,Enum.TextXAlignment.Right).TextSize=11

local minimized=false
MinBtn.MouseButton1Click:Connect(function()
    minimized=not minimized
    if minimized then
        MF.Size=UDim2.new(0,240,0,40)
        Content.Visible=false
        MinBtn.Text="+"
    else
        MF.Size=UDim2.new(0,240,0,155)
        Content.Visible=true
        MinBtn.Text="-"
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    ENABLED=false
    pcall(function() SG:Destroy() end)
end)

-- Tombol SCAN: debug manual
DbgBtn.MouseButton1Click:Connect(function()
    print("=== MANUAL SCAN ===")
    local aw=deteksiAwalan()
    print("Awalan terdeteksi: " .. (aw and ("'" .. aw:upper() .. "'") or "TIDAK ADA"))
    local _,_,hapus=scanKB()
    print("Hapus: " .. (hapus and (hapus.Name .. " pos=" .. tostring(hapus.AbsolutePosition)) or "TIDAK ADA"))
    StatusLbl.Text="Awalan: " .. (aw and aw:upper() or "?") .. " | Hapus: " .. (hapus and "✓" or "✗")
    print("===================")
end)

ToggleBtn.MouseButton1Click:Connect(function()
    ENABLED=not ENABLED
    if ENABLED then
        ToggleBtn.Text="ON"
        ToggleBtn.BackgroundColor3=Color3.new(0,0.7,0)
        lastAw=""
        lastT=0
        proses=false
        used={}
        KB.keys={}
        KB.t=0
        StatusLbl.Text="Aktif - menunggu giliran"
        print("[ON] v17!")
        task.spawn(scanKB)
    else
        ToggleBtn.Text="OFF"
        ToggleBtn.BackgroundColor3=Color3.new(0.3,0.3,0.3)
        proses=false
        StatusLbl.Text="Mati"
        print("[OFF]")
    end
end)

-- Update status
task.spawn(function()
    while SG.Parent do
        task.wait(1)
        if ENABLED then
            local aw=deteksiAwalan()
            local g=isGiliran()
            StatusLbl.Text=(g and "🎯 " or "⏳ ") .. (aw and aw:upper() or "...") .. (proses and " [ketik]" or "")
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(0.2)
        pcall(mainLoop)
    end
end)

print("=== AUTO SAMBUNG KATA v17 - Anonymous9x ===")
print("Tekan SCAN saat giliran kamu untuk debug awalan!")
print("Tekan ON untuk mulai!")
