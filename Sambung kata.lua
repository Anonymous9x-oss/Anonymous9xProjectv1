-- AUTO SAMBUNG KATA v22 - Anonymous9x
-- BASE: v12 PERSIS (proven work Delta iOS)
-- TAMBAH: awalan 2-3 huruf + auto backspace + Indo+Inggris
-- TIDAK ADA: continue, coroutine, spawn(), wait() tanpa task

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local parentGui = CoreGui or PlayerGui

if parentGui:FindFirstChild("AutoSambungKataReal") then
    parentGui.AutoSambungKataReal:Destroy()
end

-- =================================================================
-- KAMUS - Indo prioritas, English fallback
-- =================================================================
local KAMUS = {}
local KAMUS_BY_HURUF = {}

local function TambahKata(kata)
    kata = kata:lower()
    if #kata < 2 or #kata > 20 then return end
    if kata:find("%-") then return end
    local h = kata:sub(1,1)
    if not KAMUS_BY_HURUF[h] then KAMUS_BY_HURUF[h] = {} end
    -- Cek duplikat sederhana
    for _, k in ipairs(KAMUS_BY_HURUF[h]) do
        if k == kata then return end
    end
    table.insert(KAMUS, kata)
    table.insert(KAMUS_BY_HURUF[h], kata)
end

local function LoadKamus()
    -- Load KBBI online
    local ok, res = pcall(function()
        return game:HttpGet("https://raw.githubusercontent.com/eenvyexe/KBBI/refs/heads/main/words.txt")
    end)
    if ok and res and #res > 100 then
        for line in res:gmatch("[^\r\n]+") do
            local kata = line:match("([%a]+)")
            if kata and #kata >= 2 and #kata <= 18 then
                -- Filter kata Inggris
                if not kata:match("tion$") and not kata:match("ness$") and not kata:match("ment$") then
                    TambahKata(kata)
                end
            end
        end
        print("[KAMUS] KBBI: " .. #KAMUS .. " kata")
    end

    -- Kata Indo internal (fallback + tambahan)
    local indo = "abad,abadi,abah,abang,abdi,abu,acara,ada,adab,adik,adil,air,ajar,ajak,alam,alas,alat,alir,aman,amat,ambil,amuk,anak,angin,angka,angkat,antar,antara,api,arah,arti,asah,asap,asing,asli,asuh,atas,atau,atap,awal,awas,ayah,ayam,ayun,akar,alami,alang,alih,alit,amah,ambang,babi,badan,bagai,bahu,baik,bakar,bakti,baku,bantu,banyak,baring,baru,batas,batu,bawah,bayar,beban,bekal,bela,belah,belai,beli,benak,benar,benih,berat,berani,bersih,besar,biasa,bibir,bijak,biru,bisa,bocah,bohong,boleh,bosan,buat,buah,bumi,buruk,buru,busuk,butuh,baja,bajak,balai,balam,balas,cahaya,cair,cakap,campur,cantik,cari,cekat,cepat,cerah,ceria,cermat,cicip,cinta,corak,cuci,curiga,dada,dalam,damai,dapur,darah,dasar,datang,daun,daya,debu,dekat,dengar,deras,desa,diam,didik,diri,dorong,duduk,duka,dulu,dunia,danau,dampak,dahaga,edar,ekor,elang,elok,emas,empang,empat,enam,enak,engkau,entah,esok,etika,encer,endap,enggan,engsel,enau,encim,encok,endut,enteng,enzim,erat,faham,fakir,famili,fasih,fajar,fana,fatwa,fauna,fikir,fitna,flora,gagah,gagal,gajah,galak,gambar,ganas,ganggu,ganteng,garuda,gelap,gempa,gerak,gigih,goreng,gotong,gula,guling,guna,guntur,gusar,guyur,gadis,gading,gaib,gairah,galau,gali,galon,gamit,gampang,gandum,ganjal,ganjil,gapai,gardu,garis,habis,hadap,hadiah,hadir,hafal,hakim,halus,hambat,hanya,harap,harga,hasil,hati,hebat,helai,henti,heran,hijau,hilang,hirup,hitam,hitung,hormati,hubung,hujan,hutan,halal,halaman,halau,hambar,hampir,ibu,ikut,ilmu,imam,impian,indah,ingin,ingat,inti,isap,isian,islam,istri,istana,ibarat,idam,idaman,ikhlas,iman,imbang,jaga,jajan,jalan,jangan,janji,jarang,jatuh,jawab,jelas,jenis,jinak,jual,juara,jujur,julang,jumpa,jurus,jalang,jalur,jambu,jamin,janda,jangka,jangkau,kacau,kadang,kaki,kalah,kalimat,kalung,kampung,kapal,karena,kasih,kawasan,kecil,kejam,keras,kerja,ketat,kilat,kira,kuat,kukuh,kuliah,kuning,kunci,kuda,kursi,kabul,kacang,kadar,kagum,kait,kajian,kakak,lampau,langit,lancar,lanjut,lapang,lapar,laris,lawan,lebih,lemah,lembut,lepas,lestari,limpah,lincah,lindung,logam,lolos,luhur,lulus,lurus,laut,ladang,langkah,lahap,lahar,lahir,laknat,laku,mahir,makin,maju,makmur,malang,malas,mampir,mandiri,manfaat,mapan,masak,matang,mekar,menang,minat,miskin,mohon,mujur,mulai,murni,muda,mudah,mulia,murah,meja,mawar,merah,mesra,malam,manusia,musim,musuh,macam,macan,macet,mahal,mahkota,maklum,makna,nalar,napas,nasib,niat,nilai,nyaman,nyata,nyawa,nanas,nangka,nelayan,neraca,nestapa,nabi,nada,nafas,nafkah,naga,naik,nakal,naluri,nanar,nangis,narasi,naskah,naung,obat,olah,orang,obor,ombak,omong,ogah,olok,otak,padi,pahat,pahit,pakai,paksa,palu,pandang,panggil,pantai,papan,pasir,patok,payah,pecah,pegang,pekat,pelik,peluh,pendek,penuh,pepaya,perahu,perang,pergi,perih,perkasa,paham,panjang,pasang,patuh,percaya,pikir,pintar,pisah,pokok,potong,pulang,puncak,punya,putus,pagi,panas,pandai,penting,perlu,pesan,pohon,putih,padang,pagar,raga,ragam,raih,rakit,rampas,rangkai,rangkul,rasa,ratap,raut,rawit,rebut,rekah,ribut,rindu,roda,rajin,rambut,ramping,rapat,ramai,rantau,rapuh,rawat,rela,rendah,riang,ringan,riwayat,royong,ruang,rukun,rumit,rusak,racun,saat,sabar,sahaja,sakit,sambung,sampai,sayang,sejuk,sehat,semua,sering,setia,siaga,sigap,simpan,singkat,sombong,sukses,sungguh,syukur,sadar,segera,selalu,seluruh,sempurna,senyum,senang,sedih,sudah,sulit,sumber,sungai,sawah,salak,salam,sayur,sekolah,semangat,sepatu,sabuk,sabun,tabah,takut,tangguh,tangkas,tarik,tegar,teguh,tekad,tekun,teladan,tengah,tepat,terima,tulus,tuntas,turun,tangan,tanah,teman,tenang,terang,tinggi,tumbuh,tugas,tajam,tali,tamat,tampak,tampan,tanda,tandas,tangis,tangkap,tapak,taring,tawa,tebal,tegak,teliti,telur,tempat,tenda,tentu,tepung,terbang,ternak,tikar,timun,tinggal,tolong,tongkat,tubuh,tulang,tumpah,tumpul,tabir,ubah,ulam,ulang,ulet,umbut,umbi,ungkap,unjuk,udara,ujung,umur,usaha,utama,untung,upaya,unggul,uban,ucap,ujar,ujian,ukir,ukur,ulat,ulur,umpan,umpat,umum,unggas,unsur,urut,visi,vital,wakaf,walau,wangi,warung,wibawa,wirausaha,wajib,warga,warisan,waspada,waktu,wajar,warna,wajah,wacana,wadah,wafat,wahana,wajik,wakil,wanita,waris,yakin,yakni,yatim,zaman,zona,zakat,zikir"
    for w in indo:gmatch("[^,]+") do TambahKata(w) end

    -- English fallback (hanya kalau Indo tidak ada)
    local eng = "able,about,above,across,after,again,ahead,almost,alone,along,already,also,among,apart,around,away,back,ball,band,base,bath,bear,beat,bell,belt,best,bird,blow,blue,body,bold,bone,book,born,bowl,burn,busy,cage,cake,call,came,card,care,case,cash,cast,cave,cell,chat,chip,city,clap,clay,clip,club,code,coin,cold,come,cool,copy,core,cost,crew,crop,cube,curl,cute,dark,dash,data,date,dawn,dead,dear,deck,deep,deny,desk,dial,dirt,disk,dive,door,dose,down,draw,drop,drum,duck,dump,dust,duty,each,earn,ease,east,edge,else,even,ever,evil,exam,exit,echo,face,fact,fail,fall,fame,farm,fast,feel,feet,fell,felt,file,fill,film,find,fire,firm,fish,flag,flat,flew,flip,flow,foam,fold,fond,food,foot,form,fort,free,fuel,full,fund,gain,game,gang,gate,gave,gaze,gear,gift,give,glad,glow,glue,goal,gold,gone,good,grab,gray,grew,grid,grip,grow,gulf,gust,hack,hail,half,hall,halt,hand,hang,hard,harm,hate,have,head,heal,heap,heat,held,help,here,hero,hide,high,hill,hint,hold,hole,home,hook,hope,horn,host,hour,huge,hung,hunt,hurt,idea,iron,item,inch,jack,jail,join,jump,just,keen,kept,kick,kill,kind,king,knew,knot,know,lack,lake,land,lane,last,late,lead,lean,leap,left,lend,less,lift,like,lime,link,list,live,load,lock,lone,long,look,loop,lose,lost,loud,love,luck,lung,made,mail,main,make,mall,many,mark,mass,mate,math,meal,mean,meet,melt,menu,mild,milk,mill,mind,mine,mint,miss,mist,mode,moon,more,most,move,much,must,nail,name,neat,need,news,next,nice,node,none,noon,norm,note,noun,once,only,open,oral,over,oven,pace,pack,page,pain,pair,palm,park,part,pass,path,peak,pick,pile,pill,pine,pipe,plan,play,plot,plug,plus,poll,pool,poor,port,pose,post,pour,pull,pump,pure,push,race,rack,raid,rail,rain,rake,ramp,rank,rare,rate,read,real,rear,rely,rent,rest,rich,ride,ring,riot,rise,risk,road,roam,role,roll,roof,room,root,rope,rose,ruin,rule,safe,sail,sake,sale,salt,same,sand,sane,save,scan,seal,seat,seed,seem,self,sell,send,shed,ship,shoe,shop,shot,show,shut,sick,side,silk,sing,sink,site,size,skin,skip,slam,slim,slip,slow,snap,snow,sock,soft,soil,some,song,soon,sort,soul,span,spin,spot,star,stay,stem,step,stop,such,suit,swap,swim,tail,tale,tall,tank,tape,team,tear,tell,tend,term,test,text,tide,tile,time,tiny,tire,toll,tone,tool,torn,town,trap,tree,trim,trip,true,tube,tune,turn,twin,type,ugly,undo,unit,upon,user,vale,vary,vast,vein,verb,vice,view,vine,void,vote,wade,wage,wait,wake,walk,wall,want,warm,wash,wave,weak,wear,week,well,went,wide,wife,wild,will,wind,wine,wing,wire,wise,wish,word,work,worm,worn,wrap,yard,year,yell,zero,zinc,zoom"
    -- English ditaruh terpisah supaya tidak campur dengan Indo
    local KAMUS_ENG = {}
    for w in eng:gmatch("[^,]+") do
        local h = w:sub(1,1)
        if not KAMUS_ENG[h] then KAMUS_ENG[h] = {} end
        table.insert(KAMUS_ENG[h], w)
    end
    -- Simpan sebagai global fallback
    _G._ASK_ENG = KAMUS_ENG

    print("[KAMUS] Total indo: " .. #KAMUS .. " | Eng fallback: ok")
end

local usedWords = {}

-- Cari kata: awalan bisa 1, 2, atau 3 huruf
-- Prioritas Indo, fallback English
local function CariKataAwalan(awalan)
    awalan = awalan:lower()

    -- Coba dari awalan penuh, kurangi kalau tidak ada
    local pjg = #awalan
    while pjg >= 1 do
        local aw = awalan:sub(1, pjg)
        local hasil = {}
        local h = aw:sub(1,1)
        local list = KAMUS_BY_HURUF[h]
        if list then
            for _, kata in ipairs(list) do
                if kata:sub(1, #aw) == aw and #kata > #aw and not usedWords[kata] then
                    table.insert(hasil, kata)
                end
            end
        end
        if #hasil > 0 then
            local pilihan = hasil[math.random(1, math.min(#hasil, 80))]
            usedWords[pilihan] = true
            return pilihan, aw
        end
        pjg = pjg - 1
    end

    -- Fallback English
    local eng = _G._ASK_ENG
    if eng then
        pjg = #awalan
        while pjg >= 1 do
            local aw = awalan:sub(1, pjg)
            local h = aw:sub(1,1)
            local list = eng[h]
            if list then
                local hasil = {}
                for _, kata in ipairs(list) do
                    if kata:sub(1, #aw) == aw and #kata > #aw and not usedWords[kata] then
                        table.insert(hasil, kata)
                    end
                end
                if #hasil > 0 then
                    local pilihan = hasil[math.random(1, math.min(#hasil, 40))]
                    usedWords[pilihan] = true
                    return pilihan, aw
                end
            end
            pjg = pjg - 1
        end
    end

    return nil, awalan
end

-- =================================================================
-- CEK GILIRAN KITA - SAMA PERSIS v12
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

    keyboardVisible = keyCount >= 20

    if not keyboardVisible then
        for _, gui in ipairs(PlayerGui:GetChildren()) do
            if gui:IsA("ScreenGui") and gui.Enabled and gui.Name ~= "AutoSambungKataReal" then
                for _, v in ipairs(gui:GetDescendants()) do
                    if v:IsA("TextButton") and v.Visible then
                        local tl = v.Text:lower():match("^%s*(.-)%s*$")
                        if tl == "masuk" or tl == "jawab" or tl == "kirim" then
                            keyboardVisible = true
                        end
                    end
                end
            end
        end
    end

    return keyboardVisible, keyCount
end

-- =================================================================
-- DELTA KLIK - SAMA PERSIS v12 (truthy check, bukan type check)
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
-- SCAN KEYBOARD - v12 + tambah tombol HAPUS
-- =================================================================
local keyCache = {}
local masukCache = nil
local hapusCache = nil  -- BARU: tombol backspace
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
                    -- Huruf A-Z
                    if #t == 1 and t:match("^[a-zA-Z]$") then
                        keys[t:lower()] = v
                    end
                    local tl = t:lower()
                    -- Masuk
                    if tl == "masuk" or tl == "jawab" or tl == "kirim" or tl == "submit" or tl == "enter" then
                        tombolMasuk = v
                    end
                    -- Hapus: cari tombol warna merah (cara yang sama dengan v12 check warna)
                    pcall(function()
                        local r = v.BackgroundColor3.R
                        local g = v.BackgroundColor3.G
                        local b = v.BackgroundColor3.B
                        if r > 0.55 and g < 0.35 and b < 0.35 then
                            tombolHapus = v
                        end
                    end)
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
    print("[KB] " .. jk .. " huruf | masuk=" .. (tombolMasuk and tombolMasuk.Text or "?") .. " | hapus=" .. (tombolHapus and "ADA" or "TIDAK"))
    return keys, tombolMasuk, tombolHapus
end

-- =================================================================
-- BACKSPACE CEPAT - CARA v12 (DeltaKlik)
-- =================================================================
local function AutoHapus(tombolHapus, n)
    if not tombolHapus or not tombolHapus.Parent then return end
    n = (n or 0) + 2  -- ekstra 2x safety
    for i = 1, n do
        if tombolHapus and tombolHapus.Parent and tombolHapus.Visible then
            DeltaKlik(tombolHapus)
            task.wait(0.03)  -- cepat: 30ms
        end
    end
    task.wait(0.05)
end

-- =================================================================
-- CEK INPUT BOX - SAMA PERSIS v12
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
-- KETIK KATA - v12 + auto backspace on miss
-- =================================================================
local function KetikKata(jawaban, awalan, keys, tombolMasuk, tombolHapus)
    jawaban = jawaban:lower()
    awalan = awalan:lower()

    -- Pre-fill check (sama v12)
    local inputNow = GetCurrentInput()
    local toKetik = jawaban

    if inputNow and #inputNow > 0 and jawaban:sub(1, #inputNow) == inputNow then
        toKetik = jawaban:sub(#inputNow + 1)
        print("[PRE-FILL] '" .. inputNow .. "' -> sisa: '" .. toKetik .. "'")
    elseif inputNow and #inputNow > 0 then
        -- Input ada tapi beda kata -> hapus dulu
        print("[CLEAR] input salah '" .. inputNow .. "' -> hapus")
        AutoHapus(tombolHapus, #inputNow)
        toKetik = jawaban:sub(#awalan + 1)
        if #toKetik == 0 then toKetik = jawaban end
    else
        toKetik = jawaban:sub(#awalan + 1)
        if #toKetik == 0 then toKetik = jawaban end
        print("[SISA] '" .. awalan .. "' -> ketik: '" .. toKetik .. "'")
    end

    if #toKetik == 0 then
        print("[SUBMIT LANGSUNG]")
        if tombolMasuk then DeltaKlik(tombolMasuk) end
        return true
    end

    print("[KETIK] '" .. toKetik .. "'")

    local ketikCount = 0
    local berhasil = true

    for i = 1, #toKetik do
        -- Cek giliran (sama v12)
        if not IsGiliranKita() then
            print("[STOP] Giliran habis!")
            return false
        end

        local huruf = toKetik:sub(i, i)
        local btn = keys[huruf]
        if btn and btn.Parent and btn.Visible then
            DeltaKlik(btn)
            ketikCount = ketikCount + 1
            task.wait(0.04)  -- sedikit lebih cepat dari v12 (0.06 -> 0.04)
        else
            print("[MISS] '" .. huruf .. "' -> hapus " .. ketikCount .. " char")
            AutoHapus(tombolHapus, ketikCount)
            berhasil = false
            break
        end
    end

    if not berhasil then return false end

    task.wait(0.08)
    if IsGiliranKita() then
        if tombolMasuk and tombolMasuk.Parent then
            print("[SUBMIT] '" .. jawaban .. "'")
            DeltaKlik(tombolMasuk)
            return true
        end
    else
        print("[STOP] Waktu habis sebelum submit!")
    end
    return false
end

-- =================================================================
-- DETEKSI AWALAN - v12 + fix Frame scan lebih dalam
-- =================================================================
local function DeteksiAwalan()
    for _, gui in ipairs(PlayerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Enabled and gui.Name ~= "AutoSambungKataReal" then
            for _, v in ipairs(gui:GetDescendants()) do
                if v:IsA("TextLabel") and v.Visible then
                    local txt = v.Text

                    if txt:find("[Hh]uruf") and txt:find("[Aa]dalah") then
                        -- Cara 1: inline "adalah: EN"
                        local awalan = txt:match("[Aa]dalah[%s:]*([A-Za-z]+)")
                        if awalan and #awalan >= 1 and #awalan <= 6 then
                            return awalan:lower()
                        end

                        -- Cara 2: sibling
                        local parent = v.Parent
                        if parent then
                            for _, sib in ipairs(parent:GetChildren()) do
                                if sib ~= v and sib.Visible then
                                    if sib:IsA("TextLabel") then
                                        local st = sib.Text:match("^%s*([A-Za-z]+)%s*$")
                                        if st and #st >= 1 and #st <= 6 then
                                            return st:lower()
                                        end
                                    end
                                    -- Frame berisi kotak huruf (1 huruf per kotak)
                                    if sib:IsA("Frame") then
                                        local combined = ""
                                        local children = sib:GetChildren()
                                        table.sort(children, function(a, b)
                                            return a.AbsolutePosition.X < b.AbsolutePosition.X
                                        end)
                                        for _, child in ipairs(children) do
                                            local ct = ""
                                            -- v12 cara asli (TextLabel/TextButton langsung)
                                            if child:IsA("TextLabel") or child:IsA("TextButton") then
                                                ct = child.Text:match("^%s*([A-Za-z])%s*$") or ""
                                            end
                                            -- BARU: Frame dalam Frame (kotak dalam kotak)
                                            if ct == "" and child:IsA("Frame") then
                                                for _, inner in ipairs(child:GetDescendants()) do
                                                    if inner:IsA("TextLabel") then
                                                        local it = inner.Text:match("^%s*([A-Za-z])%s*$")
                                                        if it then ct = it break end
                                                    end
                                                end
                                            end
                                            combined = combined .. ct
                                        end
                                        if #combined >= 1 and #combined <= 6 then
                                            return combined:lower()
                                        end
                                    end
                                end
                            end
                        end
                    end

                    -- Label ALL CAPS 1-5 huruf di dekat label "Huruf"
                    local txt2 = txt:match("^%s*([A-Z][A-Z]?[A-Z]?[A-Z]?[A-Z]?)%s*$")
                    if txt2 and #txt2 >= 1 and #txt2 <= 5 then
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
-- MAIN STATE - SAMA PERSIS v12
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
            print("[TUNGGU] Giliran lawan... (" .. keyCount .. " tombol)")
            lastAwalan = ""
            usedWords = {}
        end
        return
    end

    local awalan = DeteksiAwalan()
    if not awalan or awalan == "" then return end

    if awalan ~= lastAwalan then
        usedWords = {}
        print("[GILIRAN KITA!] Awalan: '" .. awalan:upper() .. "'")
    end

    if awalan == lastAwalan and tick() - lastTime < COOLDOWN * 2 then return end

    local jawaban, awalanPakai = CariKataAwalan(awalan)
    if not jawaban then
        print("[SKIP] Tidak ada kata: '" .. awalan .. "'")
        lastAwalan = awalan
        lastTime = tick()
        return
    end

    print("==============================")
    print("[FLASH] '" .. awalan:upper() .. "' -> '" .. jawaban .. "'")
    print("==============================")

    proses = true
    lastAwalan = awalan

    -- task.spawn SAMA PERSIS v12
    task.spawn(function()
        local keys, tombolMasuk, tombolHapus = ScanKeyboard()
        local jk = 0
        for _ in pairs(keys) do jk = jk + 1 end
        if jk < 10 then
            print("[ERROR] Keyboard tidak ditemukan! (" .. jk .. ")")
            proses = false
            lastTime = tick()
            return
        end

        -- Ketik, retry 3x kalau miss
        local sukses = KetikKata(jawaban, awalanPakai, keys, tombolMasuk, tombolHapus)
        if not sukses and IsGiliranKita() then
            usedWords[jawaban] = true
            local jawaban2, aw2 = CariKataAwalan(awalan)
            if jawaban2 then
                print("[RETRY] -> '" .. jawaban2 .. "'")
                task.wait(0.15)
                KetikKata(jawaban2, aw2, keys, tombolMasuk, tombolHapus)
            end
        end

        lastTime = tick()
        proses = false
    end)
end

-- =================================================================
-- GUI - SAMA PERSIS v12
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
        print("[ON] v22 aktif!")
        print("[INFO] getconnections: " .. (getconnections and "ADA" or "tidak ada"))
        local g, k = IsGiliranKita()
        print("[INFO] Giliran: " .. tostring(g) .. " | Keyboard: " .. k .. " tombol")
        local _, _, hh = ScanKeyboard()
        print("[INFO] Tombol hapus: " .. (hh and "ADA" or "TIDAK ADA"))
    else
        ToggleBtn.Text = "OFF"
        ToggleBtn.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
        proses = false
        print("[OFF]")
    end
end)

-- =================================================================
-- START - SAMA PERSIS v12
-- =================================================================
LoadKamus()

task.spawn(function()
    while true do
        task.wait(0.2)
        pcall(MainLoop)
    end
end)

print("=== AUTO SAMBUNG KATA v22 - Anonymous9x ===")
print("Base v12 + awalan 2-3 huruf + auto backspace + Indo+Eng")
print("Tekan ON!")
