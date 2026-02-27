-- AUTO SAMBUNG KATA v19 - Anonymous9x
-- FIX EXECUTE ERROR: Hapus semua "continue" (tidak support di Delta iOS)
-- ULTRA FAST typing + backspace + awalan 2-3 huruf fix

task.wait(0.5)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

pcall(function()
    local old = PlayerGui:FindFirstChild("AutoSambungKataReal")
    if old then old:Destroy() end
end)

-- =================================================================
-- KAMUS
-- =================================================================
local KAMUS = {}

local function addWord(w, lang)
    w = w:lower()
    if #w < 2 or #w > 20 then return end
    local h = w:sub(1,1)
    if not KAMUS[h] then KAMUS[h] = {} end
    table.insert(KAMUS[h], {w=w, l=lang or "ID"})
end

-- KBBI Indonesia
local INDO_WORDS = "abad,abadi,abah,abang,abdi,abu,acara,ada,adab,adik,adil,air,ajar,ajak,alam,alas,alat,alir,aman,amat,ambil,amuk,anak,angin,angka,angkat,antar,antara,api,arah,arti,asah,asap,asing,asli,asuh,atas,atau,atap,awal,awas,ayah,ayam,ayun,akar,alami,alang,alba,alih,alit,alpa,amah,ambang,babi,badan,bagai,bahu,baik,bakar,bakti,baku,bantu,banyak,baring,baru,batas,batu,bawah,bayar,beban,bekal,bela,belah,belai,beli,benak,benar,benih,berat,berani,bersih,besar,biasa,bibir,bijak,biru,bisa,bocah,bohong,boleh,bosan,buat,buah,bumi,buruk,buru,busuk,butuh,baja,bajak,balai,balam,balas,baldi,cahaya,cair,cakap,campur,cantik,cari,cekat,cepat,cerah,ceria,cermat,cicip,cinta,corak,cuci,curiga,cabul,cacar,cadik,dada,dalam,damai,dapur,darah,dasar,datang,daun,daya,debu,dekat,dengar,deras,desa,diam,didik,diri,dorong,duduk,duka,dulu,dunia,danau,dampak,dahaga,edar,ekor,elang,elok,emas,empang,empat,enam,enak,engkau,entah,esok,etika,encer,endap,enggan,engsel,enau,encim,encok,endut,enjut,enteng,enzim,erat,faham,fakir,famili,fasih,fajar,fadil,fana,fatwa,fauna,fikir,fitna,flora,gagah,gagal,gajah,galak,gambar,ganas,ganggu,ganteng,garuda,gelap,gempa,gerak,gigih,goreng,gotong,gula,guling,guna,guntur,gusar,guyur,gadis,gading,gaib,gairah,galau,gali,galon,gamit,gampang,gandum,ganjal,ganjil,gapai,gardu,garis,habis,hadap,hadiah,hadir,hafal,hakim,halus,hambat,hanya,harap,harga,hasil,hati,hebat,helai,henti,heran,hijau,hilang,hirup,hitam,hitung,hormati,hubung,hujan,hutan,halal,halaman,halau,halia,hambar,hampir,ibu,ikut,ilmu,imam,impian,indah,ingin,ingat,inti,isap,isian,islam,istri,istana,ibarat,ibadat,idam,idaman,ikhlas,iman,imban,imbang,jaga,jajan,jalan,jangan,janji,jarang,jatuh,jawab,jelas,jenis,jinak,jual,juara,jujur,julang,jumpa,jurus,jalang,jalur,jamah,jambak,jambu,jamin,janda,jangka,jangkau,kacau,kadang,kaki,kalah,kalimat,kalung,kampung,kapal,karena,kasih,kawasan,kecil,kejam,keras,kerja,ketat,kilat,kira,kuat,kukuh,kuliah,kuning,kunci,kuda,kursi,kaba,kabul,kacang,kadar,kagum,kait,kajian,kakak,kakap,lampau,langit,lancar,lanjut,lapang,lapar,laris,lawan,lebih,lemah,lembut,lepas,lestari,limpah,lincah,lindung,logam,lolos,luhur,lulus,lurus,laut,ladang,langkah,labrak,lacak,lacur,lagak,lahap,lahar,lahir,lakar,laknat,laku,mahir,makin,maju,makmur,malang,malas,mampir,mandiri,manfaat,mapan,masak,matang,mekar,menang,minat,miskin,mohon,mujur,mulai,murni,muda,mudah,mulia,murah,meja,mawar,merah,mesra,malam,manusia,musim,musuh,macam,macan,macet,mahal,mahkota,maklum,makna,nalar,napas,nasib,niat,nilai,nyaman,nyata,nyawa,nanas,nangka,nelayan,neraca,nestapa,nabi,nada,nadir,nafas,nafkah,naga,naik,nakal,naluri,nanar,nangis,narasi,naskah,nata,naung,obat,olah,orang,obor,ombak,omong,obral,ogah,olok,otak,padi,pahat,pahit,pakai,paksa,palu,pandang,panggil,pantai,papan,pasir,patok,payah,pecah,pegang,pekat,pelik,peluh,pendek,penuh,pepaya,perahu,perang,pergi,perih,perkasa,paham,panjang,pasang,patuh,percaya,pikir,pintar,pisah,pokok,potong,pulang,puncak,punya,putus,pagi,panas,pandai,penting,perlu,pesan,pohon,putih,pacul,padang,pagar,raga,ragam,raih,rakit,rampas,rangkai,rangkul,rasa,ratap,raut,rawit,rebut,rekah,ribut,rindu,roda,rajin,rambut,ramping,rapat,ramai,rantau,rapuh,rawat,rela,rendah,riang,ringan,riwayat,royong,ruang,rukun,rumit,rusak,rabak,rabat,racau,racik,racun,saat,sabar,sahaja,sakit,sambung,sampai,sayang,sejuk,sehat,semua,sering,setia,siaga,sigap,simpan,singkat,sombong,sukses,sungguh,syukur,sadar,segera,selalu,seluruh,sempurna,senyum,senang,sedih,sudah,sulit,sumber,sungai,sawah,salak,salju,salam,sayur,sekolah,semangat,sepatu,sabuk,sabun,sadis,tabah,takut,tangguh,tangkas,tarik,tegar,teguh,tekad,tekun,teladan,tengah,tentram,tepat,terima,tulus,tuntas,turun,tangan,tanah,teman,tenang,terang,tinggi,tirta,tumbuh,tugas,tajam,tali,tamat,tampak,tampan,tanda,tandas,tangis,tangkap,tapak,taring,tasik,tawa,tebal,tegak,teliti,telur,tempat,tenda,tentu,tepung,terbang,ternak,tikar,timun,tinggal,tolong,tongkat,tubuh,tulang,tumpah,tumpul,tabik,tabir,ubah,ulam,ulang,ulet,ulos,umbut,umbi,ungkap,unjuk,udara,ujung,umur,usaha,utama,untung,upaya,unggul,uban,ucap,ujar,ujaran,ujian,ukir,ukur,ulak,ulat,ulur,umpan,umpat,umum,unggas,unsur,untai,urut,visi,vital,vaksin,wakaf,walau,wangi,warung,welas,wibawa,wirausaha,wajib,warga,warisan,waspada,waktu,wajar,warna,wajah,wabak,wacana,wadah,wafat,wahana,wajik,wakal,wakil,wanita,warak,waris,yakin,yakni,yang,yatim,zaman,zona,zakat,zat,zikir"

for w in INDO_WORDS:gmatch("[^,]+") do
    addWord(w, "ID")
end

-- English fallback
local ENG_WORDS = "able,about,above,across,after,again,ahead,almost,alone,along,already,also,among,apart,around,away,action,adult,back,ball,band,base,bath,bear,beat,bell,belt,best,bird,blow,blue,body,bold,bone,book,born,bowl,burn,busy,cage,cake,call,came,card,care,case,cash,cast,cave,cell,chat,chip,city,clap,clay,clip,club,code,coin,cold,come,cool,copy,core,cost,crew,crop,cube,curl,cute,dark,dash,data,date,dawn,dead,dear,deck,deep,deny,desk,dial,dirt,disk,dive,door,dose,down,draw,drop,drum,duck,dump,dust,duty,each,earn,ease,east,edge,else,even,ever,evil,exam,exit,echo,epic,face,fact,fail,fall,fame,farm,fast,feel,feet,fell,felt,file,fill,film,find,fire,firm,fish,fist,five,flag,flat,flew,flip,flow,foam,fold,folk,fond,food,foot,fore,form,fort,free,fuel,full,fund,fuse,gain,game,gang,gate,gave,gaze,gear,gift,give,glad,glow,glue,goal,gold,gone,good,grab,gray,grew,grid,grim,grip,grow,gulf,gust,hack,hail,half,hall,halt,hand,hang,hard,harm,hate,have,head,heal,heap,heat,held,help,here,hero,hide,high,hill,hint,hold,hole,home,hook,hope,horn,host,hour,huge,hung,hunt,hurt,idea,into,iron,item,inch,jack,jail,join,jump,just,keen,kept,kick,kill,kind,king,knew,knot,know,lack,lake,land,lane,last,late,lead,lean,leap,left,lend,less,lift,like,lime,link,list,live,load,lock,lone,long,look,loop,lord,lose,lost,loud,love,luck,lung,made,mail,main,make,mall,many,mark,mass,mast,mate,math,meal,mean,meet,melt,menu,mere,mesh,mild,milk,mill,mind,mine,mint,miss,mist,mode,moon,more,most,move,much,must,nail,name,neat,need,news,next,nice,node,none,noon,norm,note,noun,null,numb,oath,odds,once,only,open,oral,over,oven,pace,pack,page,pain,pair,palm,park,part,pass,path,peak,pick,pile,pill,pine,ping,pipe,plan,play,plot,plug,plus,poem,poll,pool,poor,port,pose,post,pour,pray,prey,pull,pump,pure,push,race,rack,rage,raid,rail,rain,rake,ramp,rank,rare,rate,read,real,rear,rely,rent,rest,rich,ride,ring,riot,rise,risk,road,roam,roar,role,roll,roof,room,root,rope,rose,ruin,rule,safe,sage,sail,sake,sale,salt,same,sand,sane,save,scan,scar,seal,seat,seed,seem,self,sell,send,shed,ship,shoe,shop,shot,show,shut,sick,side,silk,sing,sink,site,size,skin,skip,slam,slap,slim,slip,slot,slow,slug,snap,snow,sock,soft,soil,sole,some,song,soon,sort,soul,span,spin,spot,star,stay,stem,step,stop,stub,such,suit,swap,swim,tail,tale,tall,tank,tape,task,team,tear,tell,tend,term,test,text,than,that,then,they,thin,this,thus,tide,tile,time,tiny,tire,toll,tone,tool,torn,town,trap,tree,trim,trio,trip,true,tube,tune,turn,twin,type,ugly,undo,unit,upon,user,used,vale,vary,vast,vein,verb,very,vice,view,vine,void,volt,vote,wade,wage,wait,wake,walk,wall,want,warm,wash,wave,weak,wear,week,well,went,wide,wife,wild,will,wind,wine,wing,wire,wise,wish,with,word,work,worm,worn,wrap,yard,year,yell,zero,zinc,zoom"

for w in ENG_WORDS:gmatch("[^,]+") do
    addWord(w, "EN")
end

-- Load KBBI online
task.spawn(function()
    local ok, res = pcall(game.HttpGet, game, "https://raw.githubusercontent.com/eenvyexe/KBBI/refs/heads/main/words.txt")
    if ok and res then
        local bad = {the=1,and=1,for=1,are=1,was=1,you=1,all=1,can=1,get=1,has=1,him=1,his=1,new=1,now=1,see=1,who=1,did=1,say=1,she=1,too=1,use=1,yes=1}
        for line in res:gmatch("[^\r\n]+") do
            local w = line:match("^([%a]+)")
            if w and #w>=2 and #w<=20 then
                w = w:lower()
                if not bad[w] and not w:match("tion$") and not w:match("ness$") then
                    local h = w:sub(1,1)
                    if not KAMUS[h] then KAMUS[h]={} end
                    table.insert(KAMUS[h], 1, {w=w, l="ID"})
                end
            end
        end
        print("[KAMUS] KBBI loaded!")
    end
end)

local used = {}

local function cariKata(awalan)
    awalan = awalan:lower()
    -- Coba dari panjang penuh sampai 1 huruf, ID dulu baru EN
    for pjg = #awalan, 1, -1 do
        local aw = awalan:sub(1, pjg)
        local h = aw:sub(1,1)
        local list = KAMUS[h]
        if list then
            for _, pass in ipairs({"ID","EN"}) do
                local cocok = {}
                for _, e in ipairs(list) do
                    if e.l==pass and e.w:sub(1,#aw)==aw and #e.w>#aw and not used[e.w] then
                        table.insert(cocok, e.w)
                    end
                end
                if #cocok > 0 then
                    local p = cocok[math.random(1,math.min(#cocok,50))]
                    used[p] = true
                    return p, aw
                end
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
            for _, evName in ipairs({"Activated","MouseButton1Click","MouseButton1Down"}) do
                local conns = getconnections(btn[evName])
                if conns and #conns>0 then
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
    if tick()-KB.t<1.5 and next(KB.keys)~=nil then
        return KB.keys, KB.masuk, KB.hapus
    end
    local keys,masuk,hapus = {},{},nil

    pcall(function()
        for _, gui in ipairs(PlayerGui:GetChildren()) do
            if gui:IsA("ScreenGui") and gui.Enabled and gui.Name~="AutoSambungKataReal" then
                for _, v in ipairs(gui:GetDescendants()) do
                    if v:IsA("TextButton") and v.Visible then
                        local t = (v.Text or ""):match("^%s*(.-)%s*$") or ""
                        if #t==1 and t:match("^[a-zA-Z]$") then
                            keys[t:lower()] = v
                        end
                        local tl = t:lower()
                        if tl=="masuk" or tl=="jawab" or tl=="kirim" or tl=="enter" or tl=="submit" then
                            masuk = v
                        end
                        pcall(function()
                            local r=v.BackgroundColor3.R
                            local g=v.BackgroundColor3.G
                            local b=v.BackgroundColor3.B
                            if r>0.5 and g<0.4 and b<0.4 then hapus=v end
                        end)
                    end
                end
            end
        end
    end)

    local n=0
    for _ in pairs(keys) do n=n+1 end
    if n>=10 then KB.keys=keys; KB.masuk=masuk; KB.hapus=hapus; KB.t=tick() end
    return keys, masuk, hapus
end

-- =================================================================
-- CEK GILIRAN
-- =================================================================
local function isGiliran()
    local n=0
    pcall(function()
        for _, gui in ipairs(PlayerGui:GetChildren()) do
            if gui:IsA("ScreenGui") and gui.Enabled and gui.Name~="AutoSambungKataReal" then
                for _, v in ipairs(gui:GetDescendants()) do
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
        for _, gui in ipairs(PlayerGui:GetChildren()) do
            if gui:IsA("ScreenGui") and gui.Enabled and gui.Name~="AutoSambungKataReal" then
                for _, v in ipairs(gui:GetDescendants()) do
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
-- BACKSPACE CEPAT
-- =================================================================
local function hapusCepat(tombolHapus, n)
    n = math.max(n or 0, 0) + 3 -- safety extra
    if tombolHapus and tombolHapus.Parent then
        for i=1,n do
            if tombolHapus.Parent and tombolHapus.Visible then
                klik(tombolHapus)
                task.wait(0.025) -- SUPER CEPAT
            end
        end
    end
    task.wait(0.05)
end

-- =================================================================
-- DETEKSI AWALAN
-- =================================================================
local function deteksiAwalan()
    local result = nil
    pcall(function()
        for _, gui in ipairs(PlayerGui:GetChildren()) do
            if gui:IsA("ScreenGui") and gui.Enabled and gui.Name~="AutoSambungKataReal" then
                for _, v in ipairs(gui:GetDescendants()) do
                    if v:IsA("TextLabel") and v.Visible then
                        local txt = v.Text or ""
                        local txtL = txt:lower()

                        -- CARA 1: "Hurufnya adalah: EN" inline
                        if txtL:find("huruf") then
                            local a = txt:match("[Aa]dalah[%s:]*([A-Za-z]+)")
                            if a and #a>=1 and #a<=6 then
                                result=a:lower()
                                return
                            end

                            -- Cek sibling di parent yang sama
                            if v.Parent then
                                for _, sib in ipairs(v.Parent:GetChildren()) do
                                    if sib~=v and sib.Visible then
                                        -- TextLabel sibling
                                        if sib:IsA("TextLabel") then
                                            local st=(sib.Text or ""):match("^%s*([A-Za-z]+)%s*$")
                                            if st and #st>=1 and #st<=6 then
                                                result=st:lower()
                                                return
                                            end
                                        end
                                        -- Frame = kotak huruf
                                        if sib:IsA("Frame") then
                                            local ch={}
                                            for _, c in ipairs(sib:GetChildren()) do
                                                table.insert(ch, c)
                                            end
                                            table.sort(ch, function(a2,b2)
                                                local ax,bx=0,0
                                                pcall(function() ax=a2.AbsolutePosition.X end)
                                                pcall(function() bx=b2.AbsolutePosition.X end)
                                                return ax<bx
                                            end)
                                            local combined=""
                                            for _, c in ipairs(ch) do
                                                local ct=""
                                                pcall(function()
                                                    if c:IsA("TextLabel") or c:IsA("TextButton") then
                                                        ct=(c.Text or ""):match("^%s*([A-Za-z])%s*$") or ""
                                                    else
                                                        for _, inner in ipairs(c:GetDescendants()) do
                                                            if inner:IsA("TextLabel") then
                                                                local it=(inner.Text or ""):match("^%s*([A-Za-z])%s*$")
                                                                if it then ct=it break end
                                                            end
                                                        end
                                                    end
                                                end)
                                                combined=combined..ct
                                            end
                                            if #combined>=1 and #combined<=6 then
                                                result=combined:lower()
                                                return
                                            end
                                        end
                                    end
                                end
                            end
                        end

                        -- CARA 2: ALL CAPS 1-5 huruf di dekat label huruf
                        local caps=txt:match("^%s*([A-Z][A-Z]?[A-Z]?[A-Z]?[A-Z]?)%s*$")
                        if caps and #caps>=1 and #caps<=5 then
                            local SKIP={ON=1,OFF=1,OK=1,GO=1,NO=1,AI=1,HI=1,MY=1,AN=1}
                            if not SKIP[caps] then
                                if v.Parent then
                                    for _, sib in ipairs(v.Parent:GetChildren()) do
                                        local st=(sib.Text or ""):lower()
                                        if st:find("huruf") or st:find("adalah") then
                                            result=caps:lower()
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
-- KETIK ULTRA FAST
-- =================================================================
local DELAY_HURUF = 0.03 -- 30ms per huruf = KILAT

local function ketikKata(jawaban, aw, keys, masuk, hapus)
    jawaban = jawaban:lower()
    aw = (aw or ""):lower()

    -- Deteksi pre-fill: cek input box
    local input = getInput()
    local toKetik = jawaban

    if input and #input > 0 then
        -- Ada isi di input box
        if jawaban:sub(1,#input) == input then
            -- Awalan sudah ada, ketik sisanya
            toKetik = jawaban:sub(#input+1)
            if #input > 0 then print("[PRE] '" .. input .. "' ada, sisa: '" .. toKetik .. "'") end
        else
            -- Input ada tapi beda kata -> hapus semua dulu
            print("[CLEAR] Input salah '" .. input .. "', hapus...")
            hapusCepat(hapus, #input)
            toKetik = jawaban:sub(#aw+1)
            if #toKetik == 0 then toKetik = jawaban end
        end
    else
        -- Tidak ada TextBox atau kosong
        -- Asumsi game pre-fill awalan via kotak (bukan TextBox)
        -- Jadi kita ketik hanya sisa setelah awalan
        toKetik = jawaban:sub(#aw+1)
        if #toKetik == 0 then toKetik = jawaban end
    end

    print("[KETIK] '" .. toKetik .. "' (full: '" .. jawaban .. "')")

    if #toKetik == 0 then
        if masuk then task.wait(0.05); klik(masuk) end
        return true
    end

    local ketikCount = 0
    for i = 1, #toKetik do
        if not isGiliran() then print("[STOP] Giliran habis") return false end
        local h = toKetik:sub(i,i)
        local btn = keys[h]
        if btn and btn.Parent and btn.Visible then
            klik(btn)
            ketikCount = ketikCount + 1
            task.wait(DELAY_HURUF)
        else
            -- Huruf tidak ada di keyboard -> hapus & ganti kata
            print("[MISS] '" .. h .. "' -> hapus " .. ketikCount .. " char")
            hapusCepat(hapus, ketikCount)
            return false -- signal retry
        end
    end

    task.wait(0.05)
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
local ENABLED = false
local lastAw = ""
local lastT = 0
local proses = false

local function mainLoop()
    if not ENABLED or proses then return end
    if tick()-lastT < 1.2 then return end

    if not isGiliran() then
        if lastAw ~= "" then
            print("[TUNGGU] Giliran lawan...")
            lastAw = ""
            used = {}
            KB.t = 0
        end
        return
    end

    local awalan = deteksiAwalan()
    if not awalan or awalan == "" then return end

    if awalan ~= lastAw then
        used = {}
        print("[GILIRAN] Awalan: '" .. awalan:upper() .. "'")
    end
    if awalan == lastAw and tick()-lastT < 2.5 then return end

    local jawaban, awalanPakai = cariKata(awalan)
    if not jawaban then
        print("[SKIP] Tidak ada kata untuk '" .. awalan .. "'")
        lastAw = awalan; lastT = tick()
        return
    end

    print("[FLASH] '" .. awalan:upper() .. "' -> '" .. jawaban .. "'")
    proses = true; lastAw = awalan

    task.spawn(function()
        pcall(function()
            local keys, masuk, hapus = scanKB()
            local n = 0
            for _ in pairs(keys) do n=n+1 end
            if n < 10 then print("[ERR] KB=" .. n); return end

            for attempt = 1, 3 do
                if not isGiliran() then break end
                local ok = ketikKata(jawaban, awalanPakai, keys, masuk, hapus)
                if ok then break end
                -- Retry dengan kata lain
                used[jawaban] = true
                jawaban, awalanPakai = cariKata(awalan)
                if not jawaban then print("[HABIS] Kata habis"); break end
                print("[RETRY#" .. attempt .. "] -> '" .. jawaban .. "'")
                task.wait(0.15)
            end
        end)
        lastT = tick(); proses = false
    end)
end

-- =================================================================
-- GUI
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

local function mkTxt(p,txt,sz,pos,fs,bold,ax)
    local l = Instance.new("TextLabel")
    l.Size=sz; l.Position=pos
    l.BackgroundTransparency=1
    l.Text=txt; l.TextColor3=Color3.new(1,1,1)
    l.Font=bold and Enum.Font.SourceSansBold or Enum.Font.SourceSans
    l.TextSize=fs or 14
    l.TextXAlignment=ax or Enum.TextXAlignment.Left
    l.Parent=p; return l
end

local function mkBtn(p,txt,sz,pos,col,fs)
    local b=Instance.new("TextButton")
    b.Size=sz; b.Position=pos
    b.BackgroundColor3=col; b.Text=txt
    b.TextColor3=Color3.new(1,1,1)
    b.Font=Enum.Font.SourceSansBold
    b.TextSize=fs or 16; b.Parent=p
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,5)
    return b
end

mkTxt(MF,"Auto Sambung Kata",UDim2.new(1,-40,0,28),UDim2.new(0,10,0,5),18,true)

local CloseBtn = mkBtn(MF,"X",UDim2.new(0,25,0,25),UDim2.new(1,-60,0,5),Color3.new(0.8,0,0))
local MinBtn = mkBtn(MF,"-",UDim2.new(0,25,0,25),UDim2.new(1,-30,0,5),Color3.new(0.45,0.45,0.45))

local sep=Instance.new("Frame"); sep.Size=UDim2.new(1,-20,0,1)
sep.Position=UDim2.new(0,10,0,33); sep.BackgroundColor3=Color3.new(1,1,1)
sep.BorderSizePixel=0; sep.Parent=MF

local Ct=Instance.new("Frame"); Ct.Size=UDim2.new(1,-20,1,-43)
Ct.Position=UDim2.new(0,10,0,38); Ct.BackgroundTransparency=1; Ct.Parent=MF

local TogBtn = mkBtn(Ct,"OFF",UDim2.new(0,100,0,36),UDim2.new(0.5,-50,0,5),Color3.new(0.3,0.3,0.3),20)

local StatusLbl = mkTxt(Ct,"Siap",UDim2.new(1,0,0,18),UDim2.new(0,0,0,46),12,false,Enum.TextXAlignment.Center)
StatusLbl.TextColor3=Color3.new(0.7,0.7,0.7)

mkTxt(Ct,"By Anonymous9x",UDim2.new(1,0,0,16),UDim2.new(0,0,1,-16),11,false,Enum.TextXAlignment.Right).TextColor3=Color3.new(0.6,0.6,0.6)

local minimized=false
MinBtn.MouseButton1Click:Connect(function()
    minimized=not minimized
    if minimized then MF.Size=UDim2.new(0,240,0,38); Ct.Visible=false; MinBtn.Text="+"
    else MF.Size=UDim2.new(0,240,0,150); Ct.Visible=true; MinBtn.Text="-" end
end)

CloseBtn.MouseButton1Click:Connect(function()
    ENABLED=false; pcall(function() SG:Destroy() end)
end)

TogBtn.MouseButton1Click:Connect(function()
    ENABLED=not ENABLED
    if ENABLED then
        TogBtn.Text="ON"; TogBtn.BackgroundColor3=Color3.new(0,0.72,0)
        lastAw=""; lastT=0; proses=false; used={}
        KB.keys={}; KB.t=0
        StatusLbl.Text="Aktif..."
        print("[ON] v19 - Ultra Fast!")
        print("[INFO] getconnections: " .. (type(getconnections)=="function" and "ADA" or "TIDAK (fallback)"))
        task.spawn(scanKB)
    else
        TogBtn.Text="OFF"; TogBtn.BackgroundColor3=Color3.new(0.3,0.3,0.3)
        proses=false; StatusLbl.Text="Mati"; print("[OFF]")
    end
end)

-- Update status label
task.spawn(function()
    while SG.Parent do
        task.wait(0.8)
        if ENABLED then
            local g=isGiliran()
            local aw=deteksiAwalan()
            StatusLbl.Text=(g and "🎯 " or "⏳ ")..(aw and aw:upper() or "...")..(proses and " ⚡" or "")
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(0.2)
        pcall(mainLoop)
    end
end)

print("=== AUTO SAMBUNG KATA v19 - Anonymous9x ===")
print("Ultra Fast | Indo+Inggris | Auto Backspace")
print("Tekan ON!")
