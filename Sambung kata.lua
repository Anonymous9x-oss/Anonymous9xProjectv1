-- AUTO SAMBUNG KATA v18 - Anonymous9x
-- BASE: v12 (proven no errors)
-- NEW: Awalan 2-3 huruf + auto backspace + Indo+Inggris

task.wait(0.5)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local old = PlayerGui:FindFirstChild("AutoSambungKataReal")
if old then old:Destroy() end

-- =================================================================
-- KAMUS INDO (prioritas) + INGGRIS (fallback)
-- =================================================================
local KAMUS = {}

-- Kamus Indonesia (KBBI)
local INDO = {
    a={"abad","abadi","abah","abang","abdi","abu","acara","ada","adab","adik","adil","air","ajar","ajak","alam","alas","alat","alir","aman","amat","ambil","amuk","anak","angin","angka","angkat","antar","antara","api","arah","arti","asah","asap","asing","asli","asuh","atas","atau","atap","awal","awas","ayah","ayam","ayun","akar","alami","alba","alih","alit","alpa","amah","ambang","ambis","alang"},
    b={"babi","badan","bagai","bahu","baik","bakar","bakti","baku","bantu","banyak","baring","baru","batas","batu","bawah","bayar","beban","bekal","bela","belah","belai","beli","benak","benar","benih","berat","berani","bersih","besar","biasa","bibir","bijak","biru","bisa","bocah","bohong","boleh","bosan","buat","buah","bumi","buruk","buru","busuk","butuh","baja","bajak","balai","balam","balas","baldi"},
    c={"cabai","cacat","cahaya","cair","cakap","campur","cantik","cari","cekat","cepat","cerah","ceria","cermat","cicip","cinta","corak","cuci","curiga","cabul","cacar","cadik","cagak"},
    d={"dada","dalam","damai","dapur","darah","dasar","datang","daun","daya","debu","dekat","dengar","deras","desa","diam","didik","diri","dorong","duduk","duka","dulu","dunia","danau","dandan","dampak","dahaga"},
    e={"edar","ekor","elang","elok","emas","empang","empat","enam","enak","engkau","entah","esok","etika","encer","endap","enggan","engsel","enau","encim","encok","endut","enjut","enteng","enzim","erat"},
    f={"faham","fakir","famili","fasih","fajar","fadil","fana","fatwa","fauna","fikir","fitna","flora"},
    g={"gagah","gagal","gajah","galak","gambar","ganas","ganggu","ganteng","garuda","gelap","gempa","gerak","gigih","goreng","gotong","gula","guling","guna","guntur","gusar","guyur","gadis","gading","gaib","gairah","galau","gali","galon","gamit","gampang","gandum","ganjal","ganjil","gapai","gardu","garis"},
    h={"habis","hadap","hadiah","hadir","hafal","hakim","halus","hambat","hanya","harap","harga","hasil","hati","hebat","helai","henti","heran","hijau","hilang","hirup","hitam","hitung","hormati","hubung","hujan","hutan","halal","halaman","halau","halia","hambar","hampir"},
    i={"ibu","ikut","ilmu","imam","impian","indah","ingin","ingat","inti","isap","isian","islam","istri","istana","ibarat","ibadat","idam","idaman","ikhlas","iman","imban","imbang"},
    j={"jaga","jajan","jalan","jangan","janji","jarang","jatuh","jawab","jelas","jenis","jinak","jual","juara","jujur","julang","jumpa","jurus","jalang","jalur","jamah","jambak","jambu","jamin","janda","jangka","jangkau"},
    k={"kacau","kadang","kaki","kalah","kalimat","kalung","kampung","kapal","karena","kasih","kawasan","kecil","kejam","keras","kerja","ketat","kilat","kira","kuat","kukuh","kuliah","kuning","kunci","kuda","kursi","kaba","kabul","kacang","kadar","kafan","kagum","kait","kajian","kakak","kakap"},
    l={"lampau","langit","lancar","lanjut","lapang","lapar","laris","lawan","lebih","lemah","lembut","lepas","lestari","limpah","lincah","lindung","logam","lolos","luhur","lulus","lurus","laut","ladang","langkah","labrak","lacak","lacur","lagak","lahap","lahar","lahir","lakar","laknat","laku"},
    m={"mahir","makin","maju","makmur","malang","malas","mampir","mandiri","manfaat","mapan","masak","matang","mekar","menang","minat","miskin","mohon","mujur","mulai","murni","muda","mudah","mulia","murah","meja","mawar","merah","mesra","malam","manusia","musim","musuh","macam","macan","macet","mahkamah","mahal","mahkota","maklum","makna","makruh"},
    n={"nalar","napas","nasib","niat","nilai","nyaman","nyata","nyawa","nanas","nangka","nelayan","neraca","nestapa","nabi","nada","nadir","nafas","nafkah","naga","naik","nakal","naluri","nanar","nangis","narasi","naskah","nata","naung"},
    o={"obat","olah","orang","obor","ombak","omong","obral","ogah","olok","otak"},
    p={"padi","pahat","pahit","pakai","paksa","palu","pandang","panggil","pantai","papan","pasir","patok","payah","pecah","pegang","pekat","pelik","peluh","pendek","penuh","pepaya","perahu","perang","pergi","perih","perkasa","paham","panjang","pasang","patuh","percaya","pikir","pintar","pisah","pokok","potong","pulang","puncak","punya","putus","pagi","panas","pandai","penting","perlu","pesan","pohon","putih","pacul","padang","pagar"},
    r={"raga","ragam","raih","rakit","rampas","rangkai","rangkul","rasa","ratap","raut","rawit","rebut","rekah","ribut","rindu","roda","rajin","rambut","ramping","rapat","ramai","rantau","rapuh","rawat","rela","rendah","riang","ringan","riwayat","royong","ruang","rukun","rumit","rusak","rabak","rabat","racau","racik","racun","ragbi"},
    s={"saat","sabar","sahaja","sakit","sambung","sampai","sayang","sejuk","sehat","semua","sering","setia","siaga","sigap","simpan","singkat","sombong","sukses","sungguh","syukur","sadar","segera","selalu","seluruh","sempurna","senyum","senang","sedih","sudah","sulit","sumber","sungai","sawah","salak","salju","salam","sayur","sekolah","semangat","sepatu","sabuk","sabun","sadis"},
    t={"tabah","takut","tangguh","tangkas","tarik","tegar","teguh","tekad","tekun","teladan","tengah","tentram","tepat","terima","tulus","tuntas","turun","tangan","tanah","teman","tenang","terang","tinggi","tirta","tumbuh","tugas","tajam","tali","tamat","tampak","tampan","tanda","tandas","tangis","tangkap","tapak","taring","tasik","tawa","tebal","tegak","teliti","telur","tempat","tenda","tentu","tepung","terbang","ternak","tikar","timun","tinggal","tolong","tongkat","tubuh","tulang","tumpah","tumpul","tabik","tabir"},
    u={"ubah","ulam","ulang","ulet","ulos","umbut","umbi","ungkap","unjuk","udara","ujung","umur","usaha","utama","untung","upaya","unggul","uban","ucap","ujar","ujaran","ujian","ukir","ukur","ulak","ulat","ulur","umpan","umpat","umum","unggas","unsur","untai","urut"},
    v={"visi","vital","vaksin"},
    w={"wakaf","walau","wangi","warung","welas","wibawa","wirausaha","wajib","warga","warisan","waspada","waktu","wajar","warna","wajah","wabak","wacana","wadah","wafat","wahana","wajik","wakal","wakil","wanita","warak","waris"},
    y={"yakin","yakni","yang","yatim"},
    z={"zaman","zona","zakat","zat","zikir"},
}

-- Kamus English (fallback terakhir)
local ENGLISH = {
    a={"able","about","above","across","after","again","against","ahead","almost","alone","along","already","also","among","apart","around","away","action","adult","after"},
    b={"back","ball","band","base","bath","bear","beat","been","bell","belt","best","bird","blow","blue","body","bold","bone","book","born","both","bowl","burn","busy"},
    c={"cage","cake","call","came","card","care","case","cash","cast","cave","cell","chat","chip","city","clap","clay","clip","club","code","coin","cold","come","cool","copy","core","cost","crew","crop","cube","curl","cute"},
    d={"dark","dash","data","date","dawn","dead","dear","deck","deep","deny","desk","dial","dirt","disk","dive","door","dose","down","draw","drop","drum","duck","dump","dust","duty"},
    e={"each","earn","ease","east","edge","else","even","ever","evil","exam","exit","eyes","echo","epic"},
    f={"face","fact","fail","fall","fame","farm","fast","feel","feet","fell","felt","file","fill","film","find","fire","firm","fish","fist","five","flag","flat","flew","flip","flow","foam","fold","folk","fond","food","foot","fore","form","fort","foul","free","from","fuel","full","fund","fuse"},
    g={"gain","game","gang","gate","gave","gaze","gear","gift","give","glad","glow","glue","goal","gold","gone","good","grab","gray","grew","grid","grim","grip","grow","gulf","gust"},
    h={"hack","hail","half","hall","halt","hand","hang","hard","harm","hate","have","head","heal","heap","heat","held","help","here","hero","hide","high","hill","hint","hold","hole","home","hook","hope","horn","host","hour","huge","hung","hunt","hurt"},
    i={"idea","into","iron","item","inch"},
    j={"jack","jail","join","jump","just","java","july","june"},
    k={"keen","kept","kick","kill","kind","king","knew","knot","know"},
    l={"lack","lake","land","lane","last","late","lead","lean","leap","left","lend","less","lift","like","lime","link","list","live","load","lock","lone","long","look","loop","lord","lose","lost","loud","love","luck","lung"},
    m={"made","mail","main","make","mall","many","mark","mass","mast","mate","math","meal","mean","meet","melt","menu","mere","mesh","mild","milk","mill","mind","mine","mint","miss","mist","mode","moon","more","most","move","much","must"},
    n={"nail","name","neat","need","news","next","nice","node","none","noon","norm","note","noun","null","numb"},
    o={"oath","odds","once","only","open","oral","over","oven","onto","ours","oval","owed"},
    p={"pace","pack","page","pain","pair","palm","park","part","pass","path","peak","pick","pile","pill","pine","ping","pipe","plan","play","plot","plug","plus","poem","poll","pool","poor","port","pose","post","pour","pray","prey","pull","pump","pure","push"},
    r={"race","rack","rage","raid","rail","rain","rake","ramp","rank","rare","rate","read","real","rear","rely","rent","rest","rich","ride","ring","riot","rise","risk","road","roam","roar","role","roll","roof","room","root","rope","rose","ruin","rule"},
    s={"safe","sage","sail","sake","sale","salt","same","sand","sane","save","scan","scar","seal","seat","seed","seem","self","sell","send","shed","ship","shoe","shop","shot","show","shut","sick","side","silk","sing","sink","site","size","skin","skip","slam","slap","slim","slip","slot","slow","slug","snap","snow","sock","soft","soil","sole","some","song","soon","sort","soul","span","spin","spot","stab","star","stay","stem","step","stop","stub","such","suit","swap","swim","sync"},
    t={"tail","tale","tall","tank","tape","task","team","tear","tell","tend","term","test","text","than","that","then","they","thin","this","thus","tide","tile","time","tiny","tire","toll","tone","tool","torn","town","trap","tree","trim","trio","trip","true","tube","tune","turn","twin","type"},
    u={"ugly","undo","unit","upon","user","used","util"},
    v={"vale","vary","vast","vein","verb","very","vice","view","vine","void","volt","vote"},
    w={"wade","wage","wait","wake","walk","wall","want","warm","wash","wave","weak","wear","week","well","went","what","when","whom","wide","wife","wild","will","wind","wine","wing","wire","wise","wish","with","word","work","worm","worn","wrap","writ"},
    y={"yard","year","yell","your"},
    z={"zero","zinc","zone","zoom"},
}

-- Gabungkan kamus, Indo dulu
for h, list in pairs(INDO) do
    KAMUS[h] = {}
    for _, k in ipairs(list) do table.insert(KAMUS[h], {word=k, lang="ID"}) end
end
-- Tambah English sebagai fallback
for h, list in pairs(ENGLISH) do
    if not KAMUS[h] then KAMUS[h] = {} end
    for _, k in ipairs(list) do table.insert(KAMUS[h], {word=k, lang="EN"}) end
end

-- Load KBBI online
task.spawn(function()
    local ok, res = pcall(game.HttpGet, game, "https://raw.githubusercontent.com/eenvyexe/KBBI/refs/heads/main/words.txt")
    if ok and res then
        local bad = {the=1,and=1,for=1,are=1,was=1,you=1,all=1,can=1,get=1,has=1,him=1,his=1,new=1,now=1,see=1,who=1,did=1,say=1,she=1,too=1,use=1,yes=1}
        local added = 0
        for line in res:gmatch("[^\r\n]+") do
            local w = line:match("^([%a]+)")
            if w and #w>=2 and #w<=20 then
                w = w:lower()
                if not bad[w] and not w:match("tion$") and not w:match("ness$") then
                    local h = w:sub(1,1)
                    if not KAMUS[h] then KAMUS[h]={} end
                    -- Insert di posisi awal (prioritas tinggi)
                    table.insert(KAMUS[h], 1, {word=w, lang="ID"})
                    added = added + 1
                end
            end
        end
        print("[KAMUS] KBBI +" .. added)
    end
end)

local used = {}

local function cariKata(awalan)
    awalan = awalan:lower()
    -- Coba dari panjang awalan penuh, kurangi kalau tidak ketemu
    for pjg = #awalan, 1, -1 do
        local aw = awalan:sub(1, pjg)
        local h = aw:sub(1,1)
        local list = KAMUS[h]
        if list then
            -- Coba Indo dulu
            for _, pass in ipairs({"ID","EN"}) do
                local cocok = {}
                for _, entry in ipairs(list) do
                    if entry.lang == pass
                       and entry.word:sub(1,#aw) == aw
                       and #entry.word > #aw
                       and not used[entry.word] then
                        table.insert(cocok, entry.word)
                    end
                end
                if #cocok > 0 then
                    local p = cocok[math.random(1, math.min(#cocok, 50))]
                    used[p] = true
                    return p, aw
                end
            end
        end
    end
    return nil, awalan
end

-- =================================================================
-- KLIK (sama persis seperti v12 yang confirmed work)
-- =================================================================
local function klik(btn)
    if not btn or not btn.Parent then return end
    if type(getconnections) == "function" then
        pcall(function()
            for _, evName in ipairs({"Activated","MouseButton1Click","MouseButton1Down"}) do
                local conns = getconnections(btn[evName])
                if conns and #conns > 0 then
                    for _, c in ipairs(conns) do
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
    if tick()-KB.t < 1.5 and next(KB.keys)~=nil then
        return KB.keys, KB.masuk, KB.hapus
    end

    local keys, masuk, hapus = {}, nil, nil
    pcall(function()
        for _, gui in ipairs(PlayerGui:GetChildren()) do
            if not gui:IsA("ScreenGui") or not gui.Enabled or gui.Name=="AutoSambungKataReal" then continue end
            for _, v in ipairs(gui:GetDescendants()) do
                if not v:IsA("TextButton") or not v.Visible then continue end
                local t = (v.Text or ""):match("^%s*(.-)%s*$") or ""
                -- Huruf A-Z
                if #t==1 and t:match("^[a-zA-Z]$") then
                    keys[t:lower()] = v
                end
                -- Masuk
                local tl = t:lower()
                if tl=="masuk" or tl=="jawab" or tl=="kirim" or tl=="enter" or tl=="submit" then
                    masuk = v
                end
                -- Hapus: warna merah
                pcall(function()
                    local r=v.BackgroundColor3.R
                    local g=v.BackgroundColor3.G
                    local b=v.BackgroundColor3.B
                    if r>0.5 and g<0.4 and b<0.4 then hapus=v end
                end)
            end
        end
    end)

    local n=0
    for _ in pairs(keys) do n=n+1 end
    if n>=10 then
        KB.keys=keys; KB.masuk=masuk; KB.hapus=hapus; KB.t=tick()
    end
    return keys, masuk, hapus
end

-- =================================================================
-- CEK GILIRAN (v12 method - confirmed work)
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
-- GET INPUT BOX
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
-- BACKSPACE
-- =================================================================
local function hapusChar(tombolHapus, n)
    if not tombolHapus then return end
    n = (n or 0) + 2
    for i=1,n do
        if tombolHapus and tombolHapus.Parent and tombolHapus.Visible then
            klik(tombolHapus)
            task.wait(0.04)
        end
    end
    task.wait(0.08)
end

-- =================================================================
-- DETEKSI AWALAN - IMPROVED
-- Scan semua label "Huruf" lalu ambil awalan dari sibling/inline
-- =================================================================
local function deteksiAwalan()
    local result = nil
    pcall(function()
        for _, gui in ipairs(PlayerGui:GetChildren()) do
            if not gui:IsA("ScreenGui") or not gui.Enabled or gui.Name=="AutoSambungKataReal" then continue end
            for _, v in ipairs(gui:GetDescendants()) do
                if not v:IsA("TextLabel") or not v.Visible then continue end
                local txt = v.Text or ""

                -- CARA 1: "Hurufnya adalah: IS" satu label
                if txt:lower():find("huruf") then
                    local a = txt:match("[Aa]dalah[%s:]+([A-Za-z]+)")
                    if a and #a>=1 and #a<=6 then
                        result = a:lower(); return
                    end

                    -- CARA 2: sibling dari parent
                    if v.Parent then
                        for _, sib in ipairs(v.Parent:GetChildren()) do
                            if sib==v or not sib.Visible then continue end

                            -- Sibling TextLabel
                            if sib:IsA("TextLabel") then
                                local st=(sib.Text or ""):match("^%s*([A-Za-z]+)%s*$")
                                if st and #st>=1 and #st<=6 then
                                    result=st:lower(); return
                                end
                            end

                            -- Sibling Frame = kotak huruf individual
                            if sib:IsA("Frame") then
                                local ch={}
                                for _, c in ipairs(sib:GetChildren()) do table.insert(ch,c) end
                                table.sort(ch,function(a2,b2)
                                    local ax,bx=0,0
                                    pcall(function() ax=a2.AbsolutePosition.X end)
                                    pcall(function() bx=b2.AbsolutePosition.X end)
                                    return ax<bx
                                end)
                                local combined=""
                                for _,c in ipairs(ch) do
                                    local ct=""
                                    pcall(function()
                                        if c:IsA("TextLabel") or c:IsA("TextButton") then
                                            ct=(c.Text or ""):match("^%s*([A-Za-z])%s*$") or ""
                                        else
                                            for _,inner in ipairs(c:GetDescendants()) do
                                                if inner:IsA("TextLabel") then
                                                    local it=(inner.Text or ""):match("^%s*([A-Za-z])%s*$")
                                                    if it then ct=it; break end
                                                end
                                            end
                                        end
                                    end)
                                    combined=combined..ct
                                end
                                if #combined>=1 and #combined<=6 then
                                    result=combined:lower(); return
                                end
                            end
                        end
                    end
                end

                -- CARA 3: label ALL CAPS 1-5 huruf, cari yang paling dekat dengan label "huruf"
                local caps=txt:match("^%s*([A-Z][A-Z]?[A-Z]?[A-Z]?[A-Z]?)%s*$")
                if caps and #caps>=1 and #caps<=5 then
                    local SKIP={ON=1,OFF=1,OK=1,GO=1,NO=1,AI=1,HI=1,MY=1,AN=1}
                    if not SKIP[caps] and v.Parent then
                        for _,sib in ipairs(v.Parent:GetChildren()) do
                            local st=(sib.Text or ""):lower()
                            if st:find("huruf") or st:find("adalah") then
                                result=caps:lower(); return
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
-- KETIK + AUTO HAPUS JIKA SALAH
-- =================================================================
local function ketikKata(jawaban, aw, keys, masuk, hapus)
    jawaban = jawaban:lower()
    aw = (aw or ""):lower()

    -- Hitung yang harus diketik
    local input = getInput()
    local toKetik = jawaban

    if input and #input>0 then
        if jawaban:sub(1,#input)==input then
            toKetik = jawaban:sub(#input+1)
            if #input>0 then print("[PRE] '" .. input .. "' -> sisa: '" .. toKetik .. "'") end
        else
            -- Input ada tapi beda, hapus
            print("[CLEAR] hapus input salah...")
            hapusChar(hapus, #input)
            toKetik = jawaban:sub(#aw+1)
            if #toKetik==0 then toKetik=jawaban end
        end
    else
        toKetik = jawaban:sub(#aw+1)
        if #toKetik==0 then toKetik=jawaban end
    end

    print("[KETIK] '" .. toKetik .. "'")

    if #toKetik==0 then
        if masuk then klik(masuk) end
        return true
    end

    local n=0
    for i=1,#toKetik do
        if not isGiliran() then print("[STOP]"); return false end
        local h=toKetik:sub(i,i)
        local btn=keys[h]
        if btn and btn.Parent and btn.Visible then
            klik(btn); n=n+1; task.wait(0.055)
        else
            print("[MISS] '" .. h .. "' -> hapus & ganti")
            hapusChar(hapus, n)
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
-- MAIN LOOP
-- =================================================================
local ENABLED = false
local lastAw = ""
local lastT = 0
local proses = false

local function mainLoop()
    if not ENABLED or proses then return end
    if tick()-lastT < 1.3 then return end

    -- Cek giliran dulu
    if not isGiliran() then
        if lastAw~="" then
            print("[⏳] Giliran lawan")
            lastAw=""
            used={}
            KB.t=0
        end
        return
    end

    local awalan = deteksiAwalan()
    if not awalan or awalan=="" then return end

    if awalan~=lastAw then
        used={}
        print("[🎯] Awalan: '" .. awalan:upper() .. "'")
    end
    if awalan==lastAw and tick()-lastT<2.5 then return end

    local jawaban, awalanPakai = cariKata(awalan)
    if not jawaban then
        print("[❌] Tidak ada kata: '" .. awalan .. "'")
        lastAw=awalan; lastT=tick(); return
    end

    print("[⚡] '" .. awalan:upper() .. "' -> '" .. jawaban .. "'")
    proses=true; lastAw=awalan

    task.spawn(function()
        pcall(function()
            local keys,masuk,hapus = scanKB()
            local n=0
            for _ in pairs(keys) do n=n+1 end
            if n<10 then print("[❌] KB " .. n); return end

            for attempt=1,3 do
                if not isGiliran() then break end
                local ok = ketikKata(jawaban, awalanPakai, keys, masuk, hapus)
                if ok then break end
                used[jawaban]=true
                jawaban,awalanPakai = cariKata(awalan)
                if not jawaban then print("[❌] Kata habis"); break end
                print("[RETRY#" .. attempt .. "] -> '" .. jawaban .. "'")
                task.wait(0.2)
            end
        end)
        lastT=tick(); proses=false
    end)
end

-- =================================================================
-- GUI (sama seperti v12)
-- =================================================================
local SG = Instance.new("ScreenGui")
SG.Name = "AutoSambungKataReal"
SG.ResetOnSpawn = false
SG.Parent = PlayerGui

local MF = Instance.new("Frame")
MF.Size = UDim2.new(0,240,0,150)
MF.Position = UDim2.new(0.5,-120,0.5,-75)
MF.BackgroundColor3 = Color3.new(0,0,0)
MF.BorderSizePixel = 2
MF.Active = true
MF.Draggable = true
MF.ClipsDescendants = true
MF.Parent = SG
Instance.new("UICorner",MF).CornerRadius = UDim.new(0,8)

local Header = Instance.new("TextLabel")
Header.Size = UDim2.new(1,-40,0,30)
Header.Position = UDim2.new(0,10,0,5)
Header.BackgroundTransparency = 1
Header.Text = "Auto Sambung Kata"
Header.TextColor3 = Color3.new(1,1,1)
Header.Font = Enum.Font.SourceSansBold
Header.TextSize = 18
Header.TextXAlignment = Enum.TextXAlignment.Left
Header.Parent = MF

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0,25,0,25)
CloseBtn.Position = UDim2.new(1,-60,0,5)
CloseBtn.BackgroundColor3 = Color3.new(0.8,0,0)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.new(1,1,1)
CloseBtn.Font = Enum.Font.SourceSansBold
CloseBtn.TextSize = 16
CloseBtn.Parent = MF
Instance.new("UICorner",CloseBtn).CornerRadius = UDim.new(0,4)

local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0,25,0,25)
MinBtn.Position = UDim2.new(1,-30,0,5)
MinBtn.BackgroundColor3 = Color3.new(0.5,0.5,0.5)
MinBtn.Text = "-"
MinBtn.TextColor3 = Color3.new(1,1,1)
MinBtn.Font = Enum.Font.SourceSansBold
MinBtn.TextSize = 16
MinBtn.Parent = MF
Instance.new("UICorner",MinBtn).CornerRadius = UDim.new(0,4)

local Sep = Instance.new("Frame")
Sep.Size = UDim2.new(1,-20,0,1)
Sep.Position = UDim2.new(0,10,0,35)
Sep.BackgroundColor3 = Color3.new(1,1,1)
Sep.BorderSizePixel = 0
Sep.Parent = MF

local Ct = Instance.new("Frame")
Ct.Size = UDim2.new(1,-20,1,-45)
Ct.Position = UDim2.new(0,10,0,40)
Ct.BackgroundTransparency = 1
Ct.Parent = MF

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0,100,0,35)
ToggleBtn.Position = UDim2.new(0.5,-50,0,5)
ToggleBtn.BackgroundColor3 = Color3.new(0.3,0.3,0.3)
ToggleBtn.Text = "OFF"
ToggleBtn.TextColor3 = Color3.new(1,1,1)
ToggleBtn.Font = Enum.Font.SourceSansBold
ToggleBtn.TextSize = 18
ToggleBtn.Parent = Ct
Instance.new("UICorner",ToggleBtn).CornerRadius = UDim.new(0,6)

local Info = Instance.new("TextLabel")
Info.Size = UDim2.new(1,0,0,20)
Info.Position = UDim2.new(0,0,0,46)
Info.BackgroundTransparency = 1
Info.Text = "Otomatis isi sambung kata"
Info.TextColor3 = Color3.new(0.8,0.8,0.8)
Info.Font = Enum.Font.SourceSans
Info.TextSize = 12
Info.TextXAlignment = Enum.TextXAlignment.Center
Info.Parent = Ct

local Credit = Instance.new("TextLabel")
Credit.Size = UDim2.new(1,0,0,18)
Credit.Position = UDim2.new(0,0,1,-18)
Credit.BackgroundTransparency = 1
Credit.Text = "Created By Anonymous9x"
Credit.TextColor3 = Color3.new(1,1,1)
Credit.Font = Enum.Font.SourceSans
Credit.TextSize = 11
Credit.TextXAlignment = Enum.TextXAlignment.Right
Credit.Parent = Ct

local minimized = false
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        MF.Size=UDim2.new(0,240,0,40)
        Ct.Visible=false; MinBtn.Text="+"
    else
        MF.Size=UDim2.new(0,240,0,150)
        Ct.Visible=true; MinBtn.Text="-"
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    ENABLED=false
    pcall(function() SG:Destroy() end)
end)

ToggleBtn.MouseButton1Click:Connect(function()
    ENABLED=not ENABLED
    if ENABLED then
        ToggleBtn.Text="ON"
        ToggleBtn.BackgroundColor3=Color3.new(0,0.7,0)
        lastAw=""; lastT=0; proses=false; used={}
        KB.keys={}; KB.t=0
        print("[ON] v18!")
        print("[INFO] getconnections: " .. (type(getconnections)=="function" and "✓" or "✗ fallback"))
        task.spawn(scanKB)
    else
        ToggleBtn.Text="OFF"
        ToggleBtn.BackgroundColor3=Color3.new(0.3,0.3,0.3)
        proses=false; print("[OFF]")
    end
end)

task.spawn(function()
    while true do
        task.wait(0.2)
        pcall(mainLoop)
    end
end)

print("=== AUTO SAMBUNG KATA v18 - Anonymous9x ===")
print("✅ v12 base (no errors) + awalan 1-5 huruf")
print("✅ Indo-first, English fallback")
print("✅ Auto backspace & retry")
print("Tekan ON!")
