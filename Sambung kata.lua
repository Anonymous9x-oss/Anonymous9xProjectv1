-- =================================================================
-- AUTO SAMBUNG KATA v6 - Anonymous9x
-- ENGINE: Direct RemoteEvent fire + Hook internal game functions
-- Analisa game ZenoVa KBBI
-- =================================================================

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RS = game:GetService("ReplicatedStorage")
local VIM = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local parentGui = CoreGui or PlayerGui

if parentGui:FindFirstChild("AutoSambungKataReal") then
    parentGui.AutoSambungKataReal:Destroy()
end

-- =================================================================
-- KAMUS
-- =================================================================
local DICTIONARY_URL = "https://raw.githubusercontent.com/eenvyexe/KBBI/refs/heads/main/words.txt"
local KAMUS = {}
local KAMUS_BY_HURUF = {}

local function LoadKamus()
    local ok, res = pcall(function() return game:HttpGet(DICTIONARY_URL) end)
    if ok and res then
        local unique = {}
        for line in res:gmatch("[^\r\n]+") do
            local kata = line:match("([%a]+)")
            if kata and #kata > 1 then
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
        local fb = {"aku","kamu","dia","mereka","kami","kita","angin","bumi","api","langit","laut","hutan","gunung","sungai","danau","kota","desa","jalan","rumah","pintu","kursi","meja","buku","pena","kertas","makan","minum","masak","cuci","tidur","duduk","berjalan","berlari","naik","turun","masuk","keluar","pergi","datang","beli","jual","baca","tulis","bicara","tertawa","senyum","bahagia","gembira","indah","cantik","gagah","elok","anggun","mewah","sederhana","tulus","setia","jujur","adil","bijak","arif","cerdas","pandai","rajin","tekun","sabar","ikhlas","tabah","tegar","berani","percaya","harap","cinta","kasih","sayang","rindu","ingat","tahu","paham","pikir","rasa","hati","jiwa","hidup","tubuh","tangan","kaki","mata","telinga","hidung","mulut","rambut","wajah"}
        for _, kata in ipairs(fb) do
            table.insert(KAMUS, kata)
            local h = kata:sub(1,1)
            if not KAMUS_BY_HURUF[h] then KAMUS_BY_HURUF[h] = {} end
            table.insert(KAMUS_BY_HURUF[h], kata)
        end
        print("[KAMUS] Fallback: " .. #KAMUS)
    end
end

-- Cari kata berdasarkan huruf awal (support "RI", "BA", dll)
local function CariKata(inputHuruf)
    if not inputHuruf or inputHuruf == "" then return nil end
    inputHuruf = inputHuruf:lower()
    
    -- Jika 2+ huruf (misal "RI"), cari kata yang diawali dengan itu
    if #inputHuruf >= 2 then
        local kandidat = {}
        for _, kata in ipairs(KAMUS) do
            if kata:sub(1, #inputHuruf) == inputHuruf and not kata:find("%-") then
                table.insert(kandidat, kata)
            end
        end
        if #kandidat > 0 then
            return kandidat[math.random(1, #kandidat)]
        end
        return nil
    end
    
    -- 1 huruf: gunakan index
    local list = KAMUS_BY_HURUF[inputHuruf]
    if not list or #list == 0 then return nil end
    for i = 1, 60 do
        local c = list[math.random(1, #list)]
        if not c:find("%-") then return c end
    end
    return nil
end

-- Cari kata yang dimulai dari huruf TERAKHIR kata sebelumnya
local function CariKataLanjut(kataSebelum)
    if not kataSebelum or kataSebelum == "" then return nil end
    local huruf = kataSebelum:lower():sub(-1)
    local list = KAMUS_BY_HURUF[huruf]
    if not list or #list == 0 then return nil end
    for i = 1, 60 do
        local c = list[math.random(1, #list)]
        if c ~= kataSebelum and not c:find("%-") then return c end
    end
    return nil
end

-- =================================================================
-- SCAN SEMUA REMOTE EVENTS
-- =================================================================
local allRemotes = {}
local function ScanAllRemotes()
    local found = {}
    pcall(function()
        for _, v in ipairs(RS:GetDescendants()) do
            if v:IsA("RemoteEvent") then
                table.insert(found, v)
                -- Print nama untuk debug
                print("[REMOTE FOUND] " .. v:GetFullName())
            end
        end
    end)
    pcall(function()
        for _, v in ipairs(game.Workspace:GetDescendants()) do
            if v:IsA("RemoteEvent") then
                table.insert(found, v)
                print("[REMOTE WS] " .. v:GetFullName())
            end
        end
    end)
    allRemotes = found
    print("[SCAN] Total " .. #found .. " RemoteEvent ditemukan")
    return found
end

-- Cari remote yang paling relevan untuk submit kata
local function CariRemoteSubmit()
    local keywords = {
        "answer","jawab","word","kata","submit","send","input","guess",
        "type","ketik","sambung","game","play","round","turn"
    }
    for _, remote in ipairs(allRemotes) do
        local name = remote.Name:lower()
        for _, kw in ipairs(keywords) do
            if name:find(kw) then
                print("[MATCH] Remote cocok: " .. remote:GetFullName() .. " (keyword: " .. kw .. ")")
                return remote
            end
        end
    end
    return nil
end

-- =================================================================
-- SCAN GUI & HOOK KONEKSI TOMBOL
-- =================================================================
local hookedButtons = {}  -- cache tombol yang sudah dihook

local function GetButtonConnections(button)
    -- Coba ambil koneksi internal button
    -- Method: clone button dan lihat apa yang terjadi
    return nil
end

local function CariKeyboard()
    local keys = {}
    local tombolMasuk = nil
    local allButtons = {}

    for _, gui in ipairs(PlayerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Enabled and gui.Name ~= "AutoSambungKataReal" then
            for _, v in ipairs(gui:GetDescendants()) do
                if v:IsA("TextButton") and v.Visible then
                    table.insert(allButtons, v)
                    local t = v.Text:match("^%s*(.-)%s*$")
                    if #t == 1 and t:match("^[a-zA-Z]$") then
                        keys[t:lower()] = v
                    end
                    local tl = t:lower()
                    if tl == "masuk" or tl == "jawab" or tl == "kirim" or tl == "submit" or tl == "enter" or tl == "send" then
                        tombolMasuk = v
                    end
                end
            end
        end
    end

    return keys, tombolMasuk, allButtons
end

-- =================================================================
-- DETEKSI KATA GAME
-- Mode baru: cari label "Hurufnya adalah:" dan ambil nilai di sebelahnya
-- =================================================================
local function CariKataGameAdvanced()
    -- Method 1: Cari label "Hurufnya adalah:" (sesuai screenshot!)
    for _, gui in ipairs(PlayerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Enabled and gui.Name ~= "AutoSambungKataReal" then
            for _, v in ipairs(gui:GetDescendants()) do
                if v:IsA("TextLabel") and v.Visible then
                    local txt = v.Text
                    -- "Hurufnya adalah: RI" atau "Kata sebelumnya: RIANG"
                    local huruf = txt:match("[Hh]uruf[^:]*:%s*([%a]+)")
                    if huruf then
                        print("[DETECT] Huruf dari label: '" .. huruf .. "'")
                        return huruf, "huruf_awal"
                    end
                    local kata = txt:match("[Kk]ata[^:]*:%s*([%a]+)")
                    if kata then
                        print("[DETECT] Kata dari label: '" .. kata .. "'")
                        return kata, "kata_sebelum"
                    end
                end
            end
        end
    end
    
    -- Method 2: TextLabel yang berubah dengan teks valid
    local BLACKLIST = {purchased=1,robux=1,buy=1,sale=1,shop=1,item=1,player=1,players=1,score=1,level=1,round=1,time=1,timer=1,loading=1,lobby=1,win=1,lose=1,game=1,rank=1,invite=1,server=1,admin=1,masuk=1,jawab=1,kirim=1}
    
    for _, gui in ipairs(PlayerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Enabled and gui.Name ~= "AutoSambungKataReal" then
            for _, v in ipairs(gui:GetDescendants()) do
                if v:IsA("TextLabel") and v.Visible then
                    local txt = v.Text:match("^%s*(.-)%s*$"):upper()
                    -- Di game ZenoVa, kata ditampilkan ALL CAPS
                    if txt:match("^[A-Z]+$") and #txt >= 2 and #txt <= 20 and not BLACKLIST[txt:lower()] then
                        return txt:lower(), "kata_sebelum"
                    end
                end
            end
        end
    end
    
    return nil, nil
end

-- =================================================================
-- SUBMIT ENGINE - SEMUA METODE
-- =================================================================
local lastRemoteArgs = {}  -- rekam argumen sukses

local function SubmitSemua(jawaban, keys, tombolMasuk)
    local submitted = false
    
    -- ===== METODE 1: Fire RemoteEvent langsung =====
    local remoteSubmit = CariRemoteSubmit()
    if remoteSubmit then
        -- Coba berbagai format argumen
        local argFormats = {
            {jawaban},                          -- string biasa
            {jawaban:upper()},                  -- uppercase
            {jawaban:lower()},                  -- lowercase
            {"answer", jawaban},                -- dengan prefix
            {"submit", jawaban},
            {"word", jawaban},
            {"kata", jawaban},
        }
        
        for _, args in ipairs(argFormats) do
            pcall(function()
                remoteSubmit:FireServer(table.unpack(args))
            end)
            task.wait(0.05)
        end
        print("[REMOTE] Fired ke: " .. remoteSubmit.Name)
        submitted = true
    end
    
    -- ===== METODE 2: Coba SEMUA remote dengan jawaban =====
    if not submitted or true then  -- selalu coba
        for _, remote in ipairs(allRemotes) do
            -- Skip remote yang jelas bukan game (voice, dll)
            local name = remote.Name:lower()
            if not name:find("voice") and not name:find("speak") and not name:find("chat") and not name:find("topbar") then
                pcall(function()
                    remote:FireServer(jawaban)
                end)
            end
        end
    end
    
    -- ===== METODE 3: Klik keyboard custom (sebagai backup) =====
    if keys then
        local jumlah = 0
        for _ in pairs(keys) do jumlah = jumlah + 1 end
        
        if jumlah >= 10 then
            task.spawn(function()
                for i = 1, #jawaban do
                    local huruf = jawaban:sub(i,i):lower()
                    local tombol = keys[huruf]
                    if tombol and tombol.Parent then
                        -- Klik via semua cara
                        pcall(function()
                            local pos = tombol.AbsolutePosition
                            local sz = tombol.AbsoluteSize
                            local cx = pos.X + sz.X/2
                            local cy = pos.Y + sz.Y/2
                            
                            -- Mouse click
                            VIM:SendMouseMoveEvent(cx, cy, game)
                            VIM:SendMouseButtonEvent(cx, cy, 0, true, game, 0)
                            task.wait(0.02)
                            VIM:SendMouseButtonEvent(cx, cy, 0, false, game, 0)
                        end)
                        -- Fire event
                        pcall(function() tombol:Click() end)
                        task.wait(0.04)
                    end
                end
                -- Klik masuk
                if tombolMasuk and tombolMasuk.Parent then
                    task.wait(0.05)
                    pcall(function()
                        local pos = tombolMasuk.AbsolutePosition
                        local sz = tombolMasuk.AbsoluteSize
                        local cx = pos.X + sz.X/2
                        local cy = pos.Y + sz.Y/2
                        VIM:SendMouseMoveEvent(cx, cy, game)
                        VIM:SendMouseButtonEvent(cx, cy, 0, true, game, 0)
                        task.wait(0.02)
                        VIM:SendMouseButtonEvent(cx, cy, 0, false, game, 0)
                    end)
                    pcall(function() tombolMasuk:Click() end)
                end
            end)
        end
    end
    
    return submitted
end

-- =================================================================
-- STATE
-- =================================================================
local ENABLED = false
local kataSebelum = ""
local lastJawabTime = 0
local COOLDOWN = 1.5
local sedangProses = false

-- =================================================================
-- LOOP UTAMA
-- =================================================================
local function MainLoop()
    if not ENABLED or sedangProses then return end
    if tick() - lastJawabTime < COOLDOWN then return end

    local inputHuruf, mode = CariKataGameAdvanced()
    if not inputHuruf then return end
    if inputHuruf == kataSebelum then return end

    -- Cari jawaban berdasarkan mode
    local jawaban
    if mode == "huruf_awal" then
        -- Game tunjukkan huruf awal yang harus kita isi
        jawaban = CariKata(inputHuruf)
    else
        -- Game tunjukkan kata sebelumnya, kita lanjutkan
        jawaban = CariKataLanjut(inputHuruf)
    end

    if not jawaban then
        print("[SKIP] Tidak ada kata untuk: '" .. inputHuruf .. "'")
        kataSebelum = inputHuruf
        return
    end

    print("[FLASH] Input: '" .. inputHuruf .. "' -> Jawab: '" .. jawaban .. "' (mode: " .. (mode or "?") .. ")")

    sedangProses = true
    kataSebelum = inputHuruf

    task.spawn(function()
        local keys, tombolMasuk = CariKeyboard()
        SubmitSemua(jawaban, keys, tombolMasuk)
        lastJawabTime = tick()
        sedangProses = false
        print("[DONE] '" .. jawaban .. "'")
    end)
end

-- =================================================================
-- GUI (TIDAK DIUBAH)
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
        kataSebelum = ""
        lastJawabTime = 0
        sedangProses = false
        print("[STATUS] ENABLED")
    else
        ToggleBtn.Text = "OFF"
        ToggleBtn.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
        sedangProses = false
        print("[STATUS] DISABLED")
    end
end)

-- =================================================================
-- START
-- =================================================================
LoadKamus()

-- Scan semua remote dulu
task.spawn(function()
    task.wait(1)
    ScanAllRemotes()
end)

task.spawn(function()
    while true do
        task.wait(0.3)
        pcall(MainLoop)
    end
end)

print("=== AUTO SAMBUNG KATA v6 - MULTI ENGINE ===")
print("Cek console untuk lihat Remote yang ditemukan")
print("Tekan ON untuk mulai")
