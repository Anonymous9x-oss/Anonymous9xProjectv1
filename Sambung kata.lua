-- =================================================================
-- AUTO SAMBUNG KATA v7 - Anonymous9x
-- FIX MOBILE: Touch event + getconnections direct invoke
-- =================================================================

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local VIM = game:GetService("VirtualInputManager")
local UIS = game:GetService("UserInputService")

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
        print("[KAMUS] " .. #KAMUS .. " kata")
    else
        local fb = {"aku","kamu","dia","angin","bumi","api","langit","laut","hutan","gunung","sungai","danau","kota","desa","jalan","rumah","pintu","kursi","meja","buku","makan","minum","tidur","duduk","berjalan","berlari","naik","turun","masuk","keluar","pergi","datang","beli","jual","baca","tulis","bicara","tertawa","senyum","bahagia","gembira","indah","cantik","gagah","elok","anggun","mewah","sederhana","tulus","setia","jujur","adil","bijak","arif","cerdas","pandai","rajin","tekun","sabar","ikhlas","tabah","tegar","berani","percaya","harap","cinta","kasih","sayang","rindu","ingat","tahu","paham","pikir","rasa","hati","jiwa","hidup","tubuh","tangan","kaki","mata","telinga","hidung","mulut","rambut","wajah","leher","dada","perut","bahu","lutut","jari"}
        for _, kata in ipairs(fb) do
            table.insert(KAMUS, kata)
            local h = kata:sub(1,1)
            if not KAMUS_BY_HURUF[h] then KAMUS_BY_HURUF[h] = {} end
            table.insert(KAMUS_BY_HURUF[h], kata)
        end
        print("[KAMUS] Fallback: " .. #KAMUS)
    end
end

local function CariKataAwalan(awalan)
    awalan = awalan:lower()
    local hasil = {}
    for _, kata in ipairs(KAMUS) do
        if kata:sub(1, #awalan) == awalan and not kata:find("%-") then
            table.insert(hasil, kata)
        end
    end
    if #hasil > 0 then return hasil[math.random(1, #hasil)] end
    return nil
end

local function CariKataLanjut(kataSebelum)
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
-- CLICK ENGINE - MOBILE FOCUSED
-- =================================================================

-- Method 1: getconnections (exploit feature - paling reliable)
local function InvokeButtonDirect(button)
    local ok = false
    pcall(function()
        if getconnections then
            local conns = getconnections(button.MouseButton1Click)
            for _, conn in ipairs(conns) do
                if conn.Function then
                    conn.Function()
                    ok = true
                end
            end
            if not ok then
                conns = getconnections(button.Activated)
                for _, conn in ipairs(conns) do
                    if conn.Function then
                        conn.Function()
                        ok = true
                    end
                end
            end
        end
    end)
    return ok
end

-- Method 2: Touch event mobile
local function TouchKlik(button)
    if not button or not button.Parent then return false end
    pcall(function()
        local pos = button.AbsolutePosition
        local sz = button.AbsoluteSize
        local cx = pos.X + sz.X / 2
        local cy = pos.Y + sz.Y / 2

        -- Touch begin
        VIM:SendTouchEvent(0, Enum.UserInputType.Touch, cx, cy, 0, 0, 1, true, game)
        task.wait(0.05)
        -- Touch end
        VIM:SendTouchEvent(0, Enum.UserInputType.Touch, cx, cy, 0, 0, 1, false, game)
    end)
    return true
end

-- Method 3: Mouse click (PC fallback)
local function MouseKlik(button)
    if not button or not button.Parent then return false end
    pcall(function()
        local pos = button.AbsolutePosition
        local sz = button.AbsoluteSize
        local cx = pos.X + sz.X / 2
        local cy = pos.Y + sz.Y / 2
        VIM:SendMouseMoveEvent(cx, cy, game)
        task.wait(0.02)
        VIM:SendMouseButtonEvent(cx, cy, 0, true, game, 0)
        task.wait(0.05)
        VIM:SendMouseButtonEvent(cx, cy, 0, false, game, 0)
    end)
    return true
end

-- Klik dengan SEMUA method
local function KlikButton(button)
    if not button or not button.Parent then return false end

    -- Coba getconnections dulu (paling powerful)
    if InvokeButtonDirect(button) then
        return true
    end

    -- Touch (mobile)
    TouchKlik(button)
    task.wait(0.03)

    -- Mouse (PC)
    MouseKlik(button)
    task.wait(0.03)

    -- Built-in click
    pcall(function() button:Click() end)
    pcall(function() button.MouseButton1Click:Fire() end)
    pcall(function() button.Activated:Fire() end)

    return true
end

-- =================================================================
-- SCAN KEYBOARD & MASUK
-- =================================================================
local function CariKeyboard()
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
                    if tl == "masuk" or tl == "jawab" or tl == "kirim" or tl == "submit" or tl == "enter" or tl == "send" then
                        tombolMasuk = v
                    end
                end
            end
        end
    end

    return keys, tombolMasuk
end

-- =================================================================
-- KETIK KATA - KLIK PER HURUF
-- =================================================================
local function KetikKata(kata, keys, tombolMasuk)
    print("[KETIK] Mulai ketik: '" .. kata .. "'")
    for i = 1, #kata do
        local huruf = kata:sub(i, i):lower()
        local tombol = keys[huruf]
        if tombol and tombol.Parent then
            KlikButton(tombol)
            task.wait(0.06)
        else
            print("[MISS] Huruf '" .. huruf .. "' tidak ada di keyboard")
        end
    end

    task.wait(0.1)

    if tombolMasuk and tombolMasuk.Parent then
        print("[MASUK] Klik tombol Masuk...")
        KlikButton(tombolMasuk)
    else
        -- Fallback: Enter key
        pcall(function()
            VIM:SendKeyEvent(true, Enum.KeyCode.Return, false, nil)
            task.wait(0.05)
            VIM:SendKeyEvent(false, Enum.KeyCode.Return, false, nil)
        end)
    end
    print("[KETIK] Selesai!")
end

-- =================================================================
-- DETEKSI KATA GAME
-- =================================================================
local function DeteksiKataGame()
    -- Priority 1: "Hurufnya adalah: XX"
    for _, gui in ipairs(PlayerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Enabled and gui.Name ~= "AutoSambungKataReal" then
            for _, v in ipairs(gui:GetDescendants()) do
                if v:IsA("TextLabel") and v.Visible then
                    local txt = v.Text
                    -- "Hurufnya adalah: RI" 
                    local huruf = txt:match("[Hh]uruf[^:]*:%s*([%a]+)")
                    if huruf then return huruf, "awalan" end
                    -- "Kata sebelumnya: RIANG"
                    local kata = txt:match("[Kk]ata[^:]*:%s*([%a]+)")
                    if kata then return kata, "lanjut" end
                end
            end
        end
    end

    -- Priority 2: Label ALL CAPS yang berubah
    local SKIP = {PURCHASED=1,ROBUX=1,BUY=1,PLAYER=1,PLAYERS=1,SCORE=1,LEVEL=1,ROUND=1,WIN=1,LOSE=1,GAME=1,ADMIN=1,MASUK=1,JAWAB=1,AUTO=1,FLASH=1,OFF=1,ON=1}
    for _, gui in ipairs(PlayerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Enabled and gui.Name ~= "AutoSambungKataReal" then
            for _, v in ipairs(gui:GetDescendants()) do
                if v:IsA("TextLabel") and v.Visible then
                    local txt = v.Text:match("^%s*(.-)%s*$")
                    if txt:match("^[A-Z][A-Z]+$") and #txt >= 2 and #txt <= 20 and not SKIP[txt] then
                        return txt:lower(), "lanjut"
                    end
                end
            end
        end
    end

    return nil, nil
end

-- =================================================================
-- STATE & MAIN LOOP
-- =================================================================
local ENABLED = false
local lastKata = ""
local lastTime = 0
local COOLDOWN = 2
local proses = false

local function MainLoop()
    if not ENABLED or proses then return end
    if tick() - lastTime < COOLDOWN then return end

    local input, mode = DeteksiKataGame()
    if not input or input == lastKata then return end

    local jawaban
    if mode == "awalan" then
        jawaban = CariKataAwalan(input)
        print("[DETECT] Awalan: '" .. input .. "'")
    else
        jawaban = CariKataLanjut(input)
        print("[DETECT] Lanjut dari: '" .. input .. "'")
    end

    if not jawaban then
        print("[SKIP] Tidak ada kata untuk: " .. input)
        lastKata = input
        return
    end

    print("[ANSWER] '" .. input .. "' -> '" .. jawaban .. "'")

    proses = true
    lastKata = input

    task.spawn(function()
        local keys, tombolMasuk = CariKeyboard()
        local jk = 0
        for _ in pairs(keys) do jk = jk + 1 end
        print("[KEY] " .. jk .. " tombol keyboard ditemukan")

        if jk >= 10 then
            KetikKata(jawaban, keys, tombolMasuk)
        else
            print("[ERROR] Keyboard tidak cukup terdeteksi!")
        end

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
        lastKata = ""
        lastTime = 0
        proses = false
        print("[ON] Mobile Touch Engine aktif!")
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
        task.wait(0.25)
        pcall(MainLoop)
    end
end)

print("=== AUTO SAMBUNG KATA v7 - MOBILE TOUCH ENGINE ===")
print("Tekan ON, lihat console [KETIK] dan [MASUK]")
