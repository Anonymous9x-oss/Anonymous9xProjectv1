-- AUTO SAMBUNG KATA v20 FINAL - Anonymous9x
-- BULLETPROOF: GUI pertama, task compat, no continue, no wait() mix

-- Compat shim: task mungkin tidak ada di semua executor
local TW = (task and task.wait) or wait
local TS = (task and task.spawn) or function(f) coroutine.wrap(f)() end

-- Services
local Players   = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PG = LocalPlayer.PlayerGui

-- Hapus GUI lama
local _old = PG:FindFirstChild("AutoSambungKataReal")
if _old then _old:Destroy() end

-- ======================================================
-- GUI - DIBUAT PALING AWAL, TANPA PCALL
-- ======================================================
local SG = Instance.new("ScreenGui")
SG.Name = "AutoSambungKataReal"
SG.ResetOnSpawn = false
SG.Parent = PG

local MF = Instance.new("Frame")
MF.Size     = UDim2.new(0,240,0,150)
MF.Position = UDim2.new(0.5,-120,0.5,-75)
MF.BackgroundColor3 = Color3.new(0,0,0)
MF.BorderSizePixel  = 2
MF.Active   = true
MF.Draggable = true
MF.ClipsDescendants = true
MF.Parent = SG
Instance.new("UICorner",MF).CornerRadius = UDim.new(0,8)

-- Header
local Hdr = Instance.new("TextLabel")
Hdr.Size=UDim2.new(1,-40,0,28); Hdr.Position=UDim2.new(0,10,0,4)
Hdr.BackgroundTransparency=1; Hdr.Text="Auto Sambung Kata"
Hdr.TextColor3=Color3.new(1,1,1); Hdr.Font=Enum.Font.SourceSansBold
Hdr.TextSize=18; Hdr.TextXAlignment=Enum.TextXAlignment.Left
Hdr.Parent=MF

-- Close
local CB = Instance.new("TextButton")
CB.Size=UDim2.new(0,26,0,26); CB.Position=UDim2.new(1,-60,0,3)
CB.BackgroundColor3=Color3.new(0.8,0,0); CB.Text="X"
CB.TextColor3=Color3.new(1,1,1); CB.Font=Enum.Font.SourceSansBold
CB.TextSize=16; CB.Parent=MF
Instance.new("UICorner",CB).CornerRadius=UDim.new(0,4)

-- Min
local MB = Instance.new("TextButton")
MB.Size=UDim2.new(0,26,0,26); MB.Position=UDim2.new(1,-30,0,3)
MB.BackgroundColor3=Color3.new(0.4,0.4,0.4); MB.Text="-"
MB.TextColor3=Color3.new(1,1,1); MB.Font=Enum.Font.SourceSansBold
MB.TextSize=16; MB.Parent=MF
Instance.new("UICorner",MB).CornerRadius=UDim.new(0,4)

-- Sep
local Sep=Instance.new("Frame"); Sep.Size=UDim2.new(1,-20,0,1)
Sep.Position=UDim2.new(0,10,0,32); Sep.BackgroundColor3=Color3.new(0.3,0.3,0.3)
Sep.BorderSizePixel=0; Sep.Parent=MF

-- Content
local Ct=Instance.new("Frame"); Ct.Size=UDim2.new(1,-20,1,-42)
Ct.Position=UDim2.new(0,10,0,37); Ct.BackgroundTransparency=1; Ct.Parent=MF

-- Toggle
local TB=Instance.new("TextButton")
TB.Size=UDim2.new(0,105,0,38); TB.Position=UDim2.new(0.5,-52,0,3)
TB.BackgroundColor3=Color3.new(0.25,0.25,0.25); TB.Text="OFF"
TB.TextColor3=Color3.new(1,1,1); TB.Font=Enum.Font.SourceSansBold
TB.TextSize=20; TB.Parent=Ct
Instance.new("UICorner",TB).CornerRadius=UDim.new(0,6)

-- Status
local SL=Instance.new("TextLabel")
SL.Size=UDim2.new(1,0,0,18); SL.Position=UDim2.new(0,0,0,47)
SL.BackgroundTransparency=1; SL.Text="Loading..."
SL.TextColor3=Color3.new(0.65,0.65,0.65); SL.Font=Enum.Font.SourceSans
SL.TextSize=12; SL.TextXAlignment=Enum.TextXAlignment.Center
SL.Parent=Ct

-- Credit
local CR=Instance.new("TextLabel")
CR.Size=UDim2.new(1,0,0,14); CR.Position=UDim2.new(0,0,1,-14)
CR.BackgroundTransparency=1; CR.Text="By Anonymous9x"
CR.TextColor3=Color3.new(0.45,0.45,0.45); CR.Font=Enum.Font.SourceSans
CR.TextSize=11; CR.TextXAlignment=Enum.TextXAlignment.Right
CR.Parent=Ct

-- Min event
local _mini=false
MB.MouseButton1Click:Connect(function()
    _mini=not _mini
    if _mini then MF.Size=UDim2.new(0,240,0,36); Ct.Visible=false; MB.Text="+"
    else MF.Size=UDim2.new(0,240,0,150); Ct.Visible=true; MB.Text="-" end
end)

CB.MouseButton1Click:Connect(function()
    pcall(function() SG:Destroy() end)
end)

print("[v20] GUI OK!")

-- ======================================================
-- KAMUS
-- ======================================================
local KM = {}
local function addW(w,l)
    if type(w)~="string" or #w<2 or #w>20 then return end
    w=w:lower(); local h=w:sub(1,1)
    if not KM[h] then KM[h]={} end
    KM[h][#KM[h]+1]={w=w,l=l}
end

-- Indo
local IW="abad,abadi,abah,abang,abdi,abu,acara,ada,adab,adik,adil,air,ajar,ajak,alam,alas,alat,alir,aman,amat,ambil,amuk,anak,angin,angka,angkat,antar,antara,api,arah,arti,asah,asap,asing,asli,asuh,atas,atau,atap,awal,awas,ayah,ayam,ayun,akar,alami,alang,alih,alit,amah,ambang,babi,badan,bagai,bahu,baik,bakar,bakti,baku,bantu,banyak,baring,baru,batas,batu,bawah,bayar,beban,bekal,bela,belah,belai,beli,benak,benar,benih,berat,berani,bersih,besar,biasa,bibir,bijak,biru,bisa,bocah,bohong,boleh,bosan,buat,buah,bumi,buruk,buru,busuk,butuh,baja,bajak,balai,balam,balas,cahaya,cair,cakap,campur,cantik,cari,cekat,cepat,cerah,ceria,cermat,cicip,cinta,corak,cuci,curiga,dada,dalam,damai,dapur,darah,dasar,datang,daun,daya,debu,dekat,dengar,deras,desa,diam,didik,diri,dorong,duduk,duka,dulu,dunia,danau,dampak,dahaga,edar,ekor,elang,elok,emas,empang,empat,enam,enak,engkau,entah,esok,etika,encer,endap,enggan,engsel,enau,encim,encok,endut,enteng,enzim,erat,faham,fakir,famili,fasih,fajar,fana,fatwa,fauna,fikir,fitna,flora,gagah,gagal,gajah,galak,gambar,ganas,ganggu,ganteng,garuda,gelap,gempa,gerak,gigih,goreng,gotong,gula,guling,guna,guntur,gusar,guyur,gadis,gading,gaib,gairah,galau,gali,galon,gamit,gampang,gandum,ganjal,ganjil,gapai,gardu,garis,habis,hadap,hadiah,hadir,hafal,hakim,halus,hambat,hanya,harap,harga,hasil,hati,hebat,helai,henti,heran,hijau,hilang,hirup,hitam,hitung,hormati,hubung,hujan,hutan,halal,halaman,halau,hambar,hampir,ibu,ikut,ilmu,imam,impian,indah,ingin,ingat,inti,isap,isian,islam,istri,istana,ibarat,idam,idaman,ikhlas,iman,imbang,jaga,jajan,jalan,jangan,janji,jarang,jatuh,jawab,jelas,jenis,jinak,jual,juara,jujur,julang,jumpa,jurus,jalang,jalur,jambu,jamin,janda,jangka,jangkau,kacau,kadang,kaki,kalah,kalimat,kalung,kampung,kapal,karena,kasih,kawasan,kecil,kejam,keras,kerja,ketat,kilat,kira,kuat,kukuh,kuliah,kuning,kunci,kuda,kursi,kabul,kacang,kadar,kagum,kait,kajian,kakak,lampau,langit,lancar,lanjut,lapang,lapar,laris,lawan,lebih,lemah,lembut,lepas,lestari,limpah,lincah,lindung,logam,lolos,luhur,lulus,lurus,laut,ladang,langkah,lahap,lahar,lahir,laknat,laku,mahir,makin,maju,makmur,malang,malas,mampir,mandiri,manfaat,mapan,masak,matang,mekar,menang,minat,miskin,mohon,mujur,mulai,murni,muda,mudah,mulia,murah,meja,mawar,merah,mesra,malam,manusia,musim,musuh,macam,macan,macet,mahal,mahkota,maklum,makna,nalar,napas,nasib,niat,nilai,nyaman,nyata,nyawa,nanas,nangka,nelayan,neraca,nestapa,nabi,nada,nafas,nafkah,naga,naik,nakal,naluri,nanar,nangis,narasi,naskah,naung,obat,olah,orang,obor,ombak,omong,ogah,olok,otak,padi,pahat,pahit,pakai,paksa,palu,pandang,panggil,pantai,papan,pasir,patok,payah,pecah,pegang,pekat,pelik,peluh,pendek,penuh,pepaya,perahu,perang,pergi,perih,perkasa,paham,panjang,pasang,patuh,percaya,pikir,pintar,pisah,pokok,potong,pulang,puncak,punya,putus,pagi,panas,pandai,penting,perlu,pesan,pohon,putih,padang,pagar,raga,ragam,raih,rakit,rampas,rangkai,rangkul,rasa,ratap,raut,rawit,rebut,rekah,ribut,rindu,roda,rajin,rambut,ramping,rapat,ramai,rantau,rapuh,rawat,rela,rendah,riang,ringan,riwayat,royong,ruang,rukun,rumit,rusak,racak,racun,saat,sabar,sahaja,sakit,sambung,sampai,sayang,sejuk,sehat,semua,sering,setia,siaga,sigap,simpan,singkat,sombong,sukses,sungguh,syukur,sadar,segera,selalu,seluruh,sempurna,senyum,senang,sedih,sudah,sulit,sumber,sungai,sawah,salak,salam,sayur,sekolah,semangat,sepatu,sabuk,sabun,tabah,takut,tangguh,tangkas,tarik,tegar,teguh,tekad,tekun,teladan,tengah,tepat,terima,tulus,tuntas,turun,tangan,tanah,teman,tenang,terang,tinggi,tumbuh,tugas,tajam,tali,tamat,tampak,tampan,tanda,tandas,tangis,tangkap,tapak,taring,tawa,tebal,tegak,teliti,telur,tempat,tenda,tentu,tepung,terbang,ternak,tikar,timun,tinggal,tolong,tongkat,tubuh,tulang,tumpah,tumpul,tabir,ubah,ulam,ulang,ulet,umbut,umbi,ungkap,unjuk,udara,ujung,umur,usaha,utama,untung,upaya,unggul,uban,ucap,ujar,ujian,ukir,ukur,ulat,ulur,umpan,umpat,umum,unggas,unsur,urut,visi,vital,wakaf,walau,wangi,warung,wibawa,wirausaha,wajib,warga,warisan,waspada,waktu,wajar,warna,wajah,wacana,wadah,wafat,wahana,wajik,wakil,wanita,waris,yakin,yakni,yatim,zaman,zona,zakat,zikir"
for w in IW:gmatch("[^,]+") do addW(w,"ID") end

-- English fallback
local EW="able,about,above,across,after,again,ahead,almost,alone,along,already,also,among,apart,around,away,back,ball,band,base,bath,bear,beat,bell,belt,best,bird,blow,blue,body,bold,bone,book,born,bowl,burn,busy,cage,cake,call,came,card,care,case,cash,cast,cave,cell,chat,chip,city,clap,clay,clip,club,code,coin,cold,come,cool,copy,core,cost,crew,crop,cube,curl,cute,dark,dash,data,date,dawn,dead,dear,deck,deep,deny,desk,dial,dirt,disk,dive,door,dose,down,draw,drop,drum,duck,dump,dust,duty,each,earn,ease,east,edge,else,even,ever,evil,exam,exit,echo,epic,face,fact,fail,fall,fame,farm,fast,feel,feet,fell,felt,file,fill,film,find,fire,firm,fish,fist,flag,flat,flew,flip,flow,foam,fold,fond,food,foot,form,fort,free,fuel,full,fund,gain,game,gang,gate,gave,gaze,gear,gift,give,glad,glow,glue,goal,gold,gone,good,grab,gray,grew,grid,grim,grip,grow,gulf,gust,hack,hail,half,hall,halt,hand,hang,hard,harm,hate,have,head,heal,heap,heat,held,help,here,hero,hide,high,hill,hint,hold,hole,home,hook,hope,horn,host,hour,huge,hung,hunt,hurt,idea,iron,item,inch,jack,jail,join,jump,just,keen,kept,kick,kill,kind,king,knew,knot,know,lack,lake,land,lane,last,late,lead,lean,leap,left,lend,less,lift,like,lime,link,list,live,load,lock,lone,long,look,loop,lord,lose,lost,loud,love,luck,lung,made,mail,main,make,mall,many,mark,mass,mate,math,meal,mean,meet,melt,menu,mild,milk,mill,mind,mine,mint,miss,mist,mode,moon,more,most,move,much,must,nail,name,neat,need,news,next,nice,node,none,noon,norm,note,noun,null,numb,once,only,open,oral,over,oven,pace,pack,page,pain,pair,palm,park,part,pass,path,peak,pick,pile,pill,pine,pipe,plan,play,plot,plug,plus,poll,pool,poor,port,pose,post,pour,pull,pump,pure,push,race,rack,raid,rail,rain,rake,ramp,rank,rare,rate,read,real,rear,rely,rent,rest,rich,ride,ring,riot,rise,risk,road,roam,role,roll,roof,room,root,rope,rose,ruin,rule,safe,sail,sake,sale,salt,same,sand,sane,save,scan,seal,seat,seed,seem,self,sell,send,shed,ship,shoe,shop,shot,show,shut,sick,side,silk,sing,sink,site,size,skin,skip,slam,slim,slip,slow,snap,snow,sock,soft,soil,some,song,soon,sort,soul,span,spin,spot,star,stay,stem,step,stop,such,suit,swap,swim,tail,tale,tall,tank,tape,task,team,tear,tell,tend,term,test,text,tide,tile,time,tiny,tire,toll,tone,tool,torn,town,trap,tree,trim,trip,true,tube,tune,turn,twin,type,ugly,undo,unit,upon,user,vale,vary,vast,vein,verb,vice,view,vine,void,vote,wade,wage,wait,wake,walk,wall,want,warm,wash,wave,weak,wear,week,well,went,wide,wife,wild,will,wind,wine,wing,wire,wise,wish,word,work,worm,worn,wrap,yard,year,yell,zero,zinc,zoom"
for w in EW:gmatch("[^,]+") do addW(w,"EN") end

-- Load KBBI online background
TS(function()
    pcall(function()
        local res=game:HttpGet("https://raw.githubusercontent.com/eenvyexe/KBBI/refs/heads/main/words.txt")
        if not res or #res<10 then return end
        local bad={the=1,and_=1,are=1,was=1,you=1,all=1,get=1,has=1,him=1,his=1,see=1,who=1,say=1,she=1,too=1,use=1,yes=1}
        local n=0
        for line in res:gmatch("[^\r\n]+") do
            local w=line:match("^([%a]+)")
            if w then
                w=w:lower()
                if #w>=2 and #w<=20 and not bad[w] and not w:match("tion$") and not w:match("ness$") then
                    local h=w:sub(1,1)
                    if not KM[h] then KM[h]={} end
                    table.insert(KM[h],1,{w=w,l="ID"})
                    n=n+1
                end
            end
        end
        print("[KBBI] +"..n)
        SL.Text="Siap! Tekan ON"
    end)
end)

local used={}
local function cariKata(awalan)
    awalan=awalan:lower()
    local i=#awalan
    while i>=1 do
        local aw=awalan:sub(1,i)
        local h=aw:sub(1,1)
        local list=KM[h]
        if list then
            local p1,p2={},{}
            for _,e in ipairs(list) do
                if e.w:sub(1,#aw)==aw and #e.w>#aw and not used[e.w] then
                    if e.l=="ID" then p1[#p1+1]=e.w else p2[#p2+1]=e.w end
                end
            end
            local pool=#p1>0 and p1 or p2
            if #pool>0 then
                local p=pool[math.random(1,math.min(#pool,50))]
                used[p]=true
                return p,aw
            end
        end
        i=i-1
    end
    return nil,awalan
end

-- ======================================================
-- KLIK ENGINE
-- ======================================================
local function klik(btn)
    if not btn or not btn.Parent then return end
    if type(getconnections)=="function" then
        pcall(function()
            for _,en in ipairs({"Activated","MouseButton1Click","MouseButton1Down"}) do
                local cs=getconnections(btn[en])
                if cs and #cs>0 then
                    for _,c in ipairs(cs) do
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

-- ======================================================
-- SCAN KEYBOARD
-- ======================================================
local KB={k={},m=nil,h=nil,t=0}
local function scanKB()
    if tick()-KB.t<1.5 and next(KB.k)~=nil then return KB.k,KB.m,KB.h end
    local k,m,h={},nil,nil
    pcall(function()
        for _,gui in ipairs(PG:GetChildren()) do
            if gui:IsA("ScreenGui") and gui.Enabled and gui.Name~="AutoSambungKataReal" then
                for _,v in ipairs(gui:GetDescendants()) do
                    if v:IsA("TextButton") and v.Visible then
                        local t=(v.Text or ""):match("^%s*(.-)%s*$") or ""
                        if #t==1 and t:match("^[a-zA-Z]$") then k[t:lower()]=v end
                        local tl=t:lower()
                        if tl=="masuk" or tl=="jawab" or tl=="kirim" or tl=="enter" or tl=="submit" then m=v end
                        pcall(function()
                            if v.BackgroundColor3.R>0.5 and v.BackgroundColor3.G<0.4 and v.BackgroundColor3.B<0.4 then h=v end
                        end)
                    end
                end
            end
        end
    end)
    local n=0; for _ in pairs(k) do n=n+1 end
    if n>=10 then KB.k=k; KB.m=m; KB.h=h; KB.t=tick() end
    return k,m,h
end

-- ======================================================
-- CEK GILIRAN
-- ======================================================
local function isGiliran()
    local n=0
    pcall(function()
        for _,gui in ipairs(PG:GetChildren()) do
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

-- ======================================================
-- GET INPUT
-- ======================================================
local function getInput()
    local r=""
    pcall(function()
        for _,gui in ipairs(PG:GetChildren()) do
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

-- ======================================================
-- BACKSPACE CEPAT
-- ======================================================
local function doBS(tombol,n)
    if not tombol or not tombol.Parent then return end
    n=(n or 0)+3
    for _=1,n do
        if tombol.Parent and tombol.Visible then klik(tombol); TW(0.025) end
    end
    TW(0.05)
end

-- ======================================================
-- DETEKSI AWALAN
-- ======================================================
local function detAw()
    local res=nil
    pcall(function()
        for _,gui in ipairs(PG:GetChildren()) do
            if gui:IsA("ScreenGui") and gui.Enabled and gui.Name~="AutoSambungKataReal" then
                for _,v in ipairs(gui:GetDescendants()) do
                    if res then break end
                    if v:IsA("TextLabel") and v.Visible then
                        local txt=v.Text or ""
                        local tl=txt:lower()

                        -- Cara 1: inline "adalah: EN"
                        if tl:find("huruf") then
                            local a=txt:match("[Aa]dalah[%s:]*([A-Za-z]+)")
                            if a and #a>=1 and #a<=6 then res=a:lower() break end

                            -- Cara 2: sibling
                            if v.Parent then
                                for _,sib in ipairs(v.Parent:GetChildren()) do
                                    if res then break end
                                    if sib~=v and sib.Visible then
                                        if sib:IsA("TextLabel") then
                                            local st=(sib.Text or ""):match("^%s*([A-Za-z]+)%s*$")
                                            if st and #st>=1 and #st<=6 then res=st:lower(); break end
                                        end
                                        if sib:IsA("Frame") then
                                            local ch=sib:GetChildren()
                                            table.sort(ch,function(a2,b2)
                                                local ax,bx=0,0
                                                pcall(function() ax=a2.AbsolutePosition.X end)
                                                pcall(function() bx=b2.AbsolutePosition.X end)
                                                return ax<bx
                                            end)
                                            local combo=""
                                            for _,c in ipairs(ch) do
                                                local ct=""
                                                pcall(function()
                                                    if c:IsA("TextLabel") or c:IsA("TextButton") then
                                                        ct=(c.Text or ""):match("^%s*([A-Za-z])%s*$") or ""
                                                    else
                                                        for _,inn in ipairs(c:GetDescendants()) do
                                                            if inn:IsA("TextLabel") then
                                                                local it=(inn.Text or ""):match("^%s*([A-Za-z])%s*$")
                                                                if it then ct=it; break end
                                                            end
                                                        end
                                                    end
                                                end)
                                                combo=combo..ct
                                            end
                                            if #combo>=1 and #combo<=6 then res=combo:lower(); break end
                                        end
                                    end
                                end
                            end
                        end

                        -- Cara 3: ALL CAPS 1-5 huruf dekat label huruf
                        if not res then
                            local caps=txt:match("^%s*([A-Z][A-Z]?[A-Z]?[A-Z]?[A-Z]?)%s*$")
                            if caps and #caps>=1 and #caps<=5 then
                                local SK={ON=1,OFF=1,OK=1,GO=1,NO=1,AI=1,HI=1,MY=1,AN=1}
                                if not SK[caps] and v.Parent then
                                    for _,sib in ipairs(v.Parent:GetChildren()) do
                                        local st=(sib.Text or ""):lower()
                                        if st:find("huruf") or st:find("adalah") then
                                            res=caps:lower(); break
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
    return res
end

-- ======================================================
-- KETIK
-- ======================================================
local function ketik(jaw,aw,keys,masuk,hapus)
    jaw=jaw:lower(); aw=(aw or ""):lower()
    local inp=getInput()
    local tok=jaw

    if inp and #inp>0 then
        if jaw:sub(1,#inp)==inp then
            tok=jaw:sub(#inp+1)
            print("[PRE] '"..inp.."' -> sisa:'"..tok.."'")
        else
            print("[CLEAR] hapus:'"..inp.."'")
            doBS(hapus,#inp)
            tok=jaw:sub(#aw+1)
            if #tok==0 then tok=jaw end
        end
    else
        tok=jaw:sub(#aw+1)
        if #tok==0 then tok=jaw end
    end

    print("[KETIK] '"..tok.."'")
    if #tok==0 then
        if masuk then TW(0.05); klik(masuk) end
        return true
    end

    local n=0
    for i=1,#tok do
        if not isGiliran() then print("[STOP]"); return false end
        local c=tok:sub(i,i)
        local btn=keys[c]
        if btn and btn.Parent and btn.Visible then
            klik(btn); n=n+1; TW(0.03)
        else
            print("[MISS] '"..c.."' hapus "..n)
            doBS(hapus,n); return false
        end
    end

    TW(0.05)
    if isGiliran() and masuk and masuk.Parent then
        klik(masuk); print("[OK] '"..jaw.."'"); return true
    end
    return false
end

-- ======================================================
-- MAIN
-- ======================================================
local ON=false
local lastAw=""; local lastT=0; local busy=false

local function loop()
    if not ON or busy then return end
    if tick()-lastT<1.2 then return end

    if not isGiliran() then
        if lastAw~="" then
            lastAw=""; used={}; KB.t=0
            SL.Text="Giliran lawan..."
        end
        return
    end

    local aw=detAw()
    if not aw or aw=="" then return end

    if aw~=lastAw then used={}; print("[GILIRAN] '"..aw:upper().."'") end
    if aw==lastAw and tick()-lastT<2.5 then return end

    local jaw,awp=cariKata(aw)
    if not jaw then
        SL.Text="Tidak ada kata: "..aw
        lastAw=aw; lastT=tick(); return
    end

    print("[FLASH] '"..aw:upper().."' -> '"..jaw.."'")
    SL.Text=aw:upper().." -> "..jaw
    busy=true; lastAw=aw

    TS(function()
        pcall(function()
            local keys,masuk,hapus=scanKB()
            local n=0; for _ in pairs(keys) do n=n+1 end
            if n<10 then print("[ERR] KB="..n); return end

            for at=1,3 do
                if not isGiliran() then break end
                if ketik(jaw,awp,keys,masuk,hapus) then break end
                used[jaw]=true
                jaw,awp=cariKata(aw)
                if not jaw then break end
                print("[RETRY#"..at.."] '"..jaw.."'")
                TW(0.15)
            end
        end)
        lastT=tick(); busy=false
    end)
end

-- Toggle
TB.MouseButton1Click:Connect(function()
    ON=not ON
    if ON then
        TB.Text="ON"; TB.BackgroundColor3=Color3.new(0,0.72,0)
        lastAw=""; lastT=0; busy=false; used={}
        KB.k={}; KB.t=0
        SL.Text="Aktif..."
        print("[ON] v20 Final!")
        print("[GC] "..(type(getconnections)=="function" and "ADA" or "TIDAK/fallback"))
        TS(scanKB)
    else
        TB.Text="OFF"; TB.BackgroundColor3=Color3.new(0.25,0.25,0.25)
        busy=false; SL.Text="Mati"; print("[OFF]")
    end
end)

-- Status update
TS(function()
    while SG and SG.Parent do
        TW(1)
        if ON then
            local g=isGiliran()
            local a=detAw()
            SL.Text=(g and "Giliran kita! " or "Tunggu... ")..(a and a:upper() or "")
        end
    end
end)

-- Main loop
TS(function()
    while true do TW(0.2); pcall(loop) end
end)

SL.Text="Siap! Tekan ON"
print("[v20] Done! Tekan ON.")
