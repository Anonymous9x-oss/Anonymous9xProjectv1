-- ================================================================
-- ANONYMOUS9x BACKDOOR SCANNER v1.0
-- Scan remotes, detect backdoor patterns, execute via require
-- UI: hitam/putih/hijau, GothamBold, no emoji
-- ================================================================

local Players       = game:GetService("Players")
local RunService    = game:GetService("RunService")
local CoreGui       = game:GetService("CoreGui")
local HttpService   = game:GetService("HttpService")

local LocalPlayer   = Players.LocalPlayer

-- ================================================================
-- THEME
-- ================================================================
local T = {
    Bg       = Color3.fromRGB(8,  8,  10),
    Panel    = Color3.fromRGB(14, 14, 18),
    PanelAlt = Color3.fromRGB(20, 20, 26),
    Border   = Color3.fromRGB(50, 50, 60),
    Text     = Color3.fromRGB(240, 240, 240),
    Dim      = Color3.fromRGB(120, 120, 130),
    Green    = Color3.fromRGB(0,   220, 100),
    Red      = Color3.fromRGB(220, 50,  50),
    Yellow   = Color3.fromRGB(220, 180, 30),
    White    = Color3.fromRGB(255, 255, 255),
}

-- ================================================================
-- BACKDOOR KEYWORD PATTERNS
-- ================================================================
local BACKDOOR_NAMES = {
    -- Executor / loader patterns
    "loadstring","require","exec","execute","eval","runscript",
    "remoteexec","remotecmd","remoterun","cmd","command","shell",
    "inject","payload","exploit","hack","cheat","bypass",
    -- Common backdoor remote names
    "rc7","rc_7","remote7","backdoor","door","gate","tunnel",
    "hookfunc","hookmethod","hookremote",
    "serverexec","serverrun","serverload","servercmd",
    "adminexec","adminrun","admincmd","adminloader",
    "loader","loaderremote","mainloader","scriptloader",
    "fe2","feloader","feexec",
    -- Obfuscated / random-ish patterns (single letter or very short)
    -- also suspicious: remotes in non-standard locations
}

-- Check if a remote name/path matches backdoor pattern
local function isSuspicious(name, path)
    name = name:lower()
    path = path:lower()
    -- Exact or partial match
    for _, kw in ipairs(BACKDOOR_NAMES) do
        if name:find(kw, 1, true) or path:find(kw, 1, true) then
            return true, kw
        end
    end
    -- Unusually short remote names (1-2 chars) = suspicious
    if #name <= 2 and name:match("^[a-z0-9]+$") then
        return true, "short-name"
    end
    -- Names that are just random chars (no vowels, long consonant chains)
    if #name >= 5 then
        local vowels = name:gsub("[^aeiou]","")
        if #vowels == 0 then return true, "no-vowels" end
    end
    return false, nil
end

-- ================================================================
-- STATE
-- ================================================================
local Scanner = {
    Remotes     = {},    -- all remotes found
    Backdoors   = {},    -- suspected backdoors
    Scanning    = false,
    GUI         = nil,
}

-- ================================================================
-- UI HELPERS
-- ================================================================
local function Stroke(obj, color, thick, trans)
    local s = Instance.new("UIStroke", obj)
    s.Color = color or T.Border
    s.Thickness = thick or 1
    s.Transparency = trans or 0
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    return s
end

local function Corner(obj, r)
    Instance.new("UICorner", obj).CornerRadius = UDim.new(0, r or 6)
end

local function Label(parent, text, x, y, w, h, size, color, font, xalign)
    local L = Instance.new("TextLabel", parent)
    L.Text = text
    L.Position = UDim2.new(0, x, 0, y)
    L.Size = UDim2.new(0, w, 0, h)
    L.BackgroundTransparency = 1
    L.TextColor3 = color or T.Text
    L.Font = font or Enum.Font.GothamBold
    L.TextSize = size or 11
    L.TextXAlignment = xalign or Enum.TextXAlignment.Left
    L.TextTruncate = Enum.TextTruncate.AtEnd
    return L
end

local function Button(parent, text, x, y, w, h, bg, tc, size)
    local B = Instance.new("TextButton", parent)
    B.Text = text
    B.Position = UDim2.new(0, x, 0, y)
    B.Size = UDim2.new(0, w, 0, h)
    B.BackgroundColor3 = bg or T.PanelAlt
    B.TextColor3 = tc or T.Text
    B.Font = Enum.Font.GothamBlack
    B.TextSize = size or 11
    B.AutoButtonColor = false
    Corner(B, 5)
    return B
end

local function MakeDraggable(frame, handle)
    local drag, dragStart, startPos = false, nil, nil
    handle.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            drag = true
            dragStart = inp.Position
            startPos = frame.Position
            inp.Changed:Connect(function()
                if inp.UserInputState == Enum.UserInputState.End then drag = false end
            end)
        end
    end)
    handle.InputChanged:Connect(function(inp)
        if drag and (inp.UserInputType == Enum.UserInputType.MouseMovement
                  or inp.UserInputType == Enum.UserInputType.Touch) then
            local d = inp.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X,
                                       startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
end

-- ================================================================
-- SCAN LOGIC
-- ================================================================
local function deepScan(root, out)
    pcall(function()
        for _, v in ipairs(root:GetDescendants()) do
            if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") or v:IsA("BindableEvent") then
                local path = v:GetFullName()
                local suspicious, keyword = isSuspicious(v.Name, path)
                table.insert(out, {
                    obj       = v,
                    name      = v.Name,
                    path      = path,
                    class     = v.ClassName,
                    sus       = suspicious,
                    keyword   = keyword or "",
                })
            end
        end
    end)
end

function Scanner.Run(onProgress, onDone)
    if Scanner.Scanning then return end
    Scanner.Scanning = true
    Scanner.Remotes  = {}
    Scanner.Backdoors = {}

    task.spawn(function()
        local roots = {
            game:GetService("ReplicatedStorage"),
            game:GetService("ReplicatedFirst"),
            workspace,
            game:GetService("ServerScriptService"),  -- may be visible
            game:GetService("Players"),
        }

        for i, root in ipairs(roots) do
            onProgress("Scanning " .. root.Name .. "...", i / #roots)
            deepScan(root, Scanner.Remotes)
            task.wait(0.05)  -- yield per-root supaya tidak freeze
        end

        -- Separate backdoors
        for _, r in ipairs(Scanner.Remotes) do
            if r.sus then
                table.insert(Scanner.Backdoors, r)
            end
        end

        Scanner.Scanning = false
        onDone(#Scanner.Remotes, #Scanner.Backdoors)
    end)
end

-- ================================================================
-- EXECUTE via backdoor remote
-- ================================================================
local function tryExecute(remote, code)
    if not remote or not remote.obj then return false, "No remote selected" end
    if not code or code == "" then return false, "Code kosong" end

    local obj = remote.obj
    local ok, err = pcall(function()
        if obj:IsA("RemoteEvent") then
            -- Coba berbagai argument pattern yang umum dipakai backdoor
            obj:FireServer(code)
            obj:FireServer("exec", code)
            obj:FireServer("run", code)
            obj:FireServer(loadstring, code)
            obj:FireServer(1, code)
            obj:FireServer(code, true)
        elseif obj:IsA("RemoteFunction") then
            obj:InvokeServer(code)
            obj:InvokeServer("exec", code)
            obj:InvokeServer("run", code)
        elseif obj:IsA("BindableEvent") then
            obj:Fire(code)
            obj:Fire("exec", code)
        end
    end)
    return ok, err
end

-- ================================================================
-- BUILD UI
-- ================================================================
function Scanner.BuildUI()
    if CoreGui:FindFirstChild("An9xScanner") then
        CoreGui.An9xScanner:Destroy()
    end

    local Screen = Instance.new("ScreenGui", CoreGui)
    Screen.Name = "An9xScanner"
    Screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    Scanner.GUI = Screen

    -- ---- MAIN FRAME ----
    -- TIDAK pakai ClipsDescendants (bug mobile) + ukuran lebih kecil buat HP
    local Main = Instance.new("Frame", Screen)
    Main.Name = "Main"
    Main.Size = UDim2.new(0, 460, 0, 360)
    Main.Position = UDim2.new(0.5, -230, 0.5, -180)
    Main.BackgroundColor3 = T.Bg
    Main.ClipsDescendants = false  -- FIX: jangan clip, bikin tombol hilang di mobile
    Corner(Main, 8)
    Stroke(Main, T.Border, 1.2, 0)
    MakeDraggable(Main, Main)

    -- ---- HEADER ---- (tinggi 36, cukup untuk semua tombol)
    local Header = Instance.new("Frame", Main)
    Header.Name = "Header"
    Header.Size = UDim2.new(1, 0, 0, 36)
    Header.Position = UDim2.new(0, 0, 0, 0)
    Header.BackgroundColor3 = T.Panel
    Header.BorderSizePixel = 0
    Header.ZIndex = 10
    Corner(Header, 8)  -- corner di header sendiri biar rapi

    local HdrLine = Instance.new("Frame", Header)
    HdrLine.Size = UDim2.new(1, 0, 0, 1)
    HdrLine.Position = UDim2.new(0, 0, 1, -1)
    HdrLine.BackgroundColor3 = T.Border
    HdrLine.BorderSizePixel = 0
    HdrLine.ZIndex = 10

    -- Title: satu label saja, ukuran pas tidak tumpang tindih tombol
    local TitleA = Instance.new("TextLabel", Header)
    TitleA.Text = "ANONYMOUS9x"
    TitleA.Position = UDim2.new(0, 10, 0, 0)
    TitleA.Size = UDim2.new(0, 120, 1, 0)
    TitleA.BackgroundTransparency = 1
    TitleA.TextColor3 = T.Green
    TitleA.Font = Enum.Font.GothamBlack
    TitleA.TextSize = 11
    TitleA.TextXAlignment = Enum.TextXAlignment.Left
    TitleA.ZIndex = 10

    local TitleB = Instance.new("TextLabel", Header)
    TitleB.Text = "BACKDOOR SCANNER"
    TitleB.Position = UDim2.new(0, 134, 0, 0)
    TitleB.Size = UDim2.new(0, 160, 1, 0)
    TitleB.BackgroundTransparency = 1
    TitleB.TextColor3 = T.Text
    TitleB.Font = Enum.Font.GothamBold
    TitleB.TextSize = 11
    TitleB.TextXAlignment = Enum.TextXAlignment.Left
    TitleB.ZIndex = 10

    -- MINIMIZE tombol — KANAN -1 dulu, close -2
    local BtnMin = Instance.new("TextButton", Header)
    BtnMin.Text = "-"
    BtnMin.Size = UDim2.new(0, 32, 0, 32)
    BtnMin.Position = UDim2.new(1, -68, 0, 2)
    BtnMin.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    BtnMin.TextColor3 = T.Text
    BtnMin.Font = Enum.Font.GothamBlack
    BtnMin.TextSize = 16
    BtnMin.ZIndex = 11
    Corner(BtnMin, 5)

    -- CLOSE tombol
    local BtnClose = Instance.new("TextButton", Header)
    BtnClose.Text = "x"
    BtnClose.Size = UDim2.new(0, 32, 0, 32)
    BtnClose.Position = UDim2.new(1, -34, 0, 2)
    BtnClose.BackgroundColor3 = Color3.fromRGB(140, 20, 20)
    BtnClose.TextColor3 = T.White
    BtnClose.Font = Enum.Font.GothamBlack
    BtnClose.TextSize = 12
    BtnClose.ZIndex = 11
    Corner(BtnClose, 5)
    BtnClose.MouseButton1Click:Connect(function() Screen:Destroy() end)

    -- ---- BODY (semua konten di bawah header) ----
    local Body = Instance.new("Frame", Main)
    Body.Name = "Body"
    Body.Position = UDim2.new(0, 6, 0, 42)
    Body.Size = UDim2.new(1, -12, 1, -48)
    Body.BackgroundTransparency = 1

    -- MINIMIZE LOGIC — toggle Body visibility, resize Main
    -- Ini cara yang benar untuk mobile: tidak pakai TweenSize
    local expanded = true
    BtnMin.MouseButton1Click:Connect(function()
        expanded = not expanded
        Body.Visible = expanded
        if expanded then
            Main.Size = UDim2.new(0, 460, 0, 360)
            BtnMin.Text = "-"
        else
            Main.Size = UDim2.new(0, 460, 0, 36)
            BtnMin.Text = "+"
        end
    end)

    -- ---- LEFT COLUMN ----
    local Left = Instance.new("Frame", Body)
    Left.Size = UDim2.new(0, 148, 1, 0)
    Left.BackgroundColor3 = T.Panel
    Left.BorderSizePixel = 0
    Corner(Left, 6)
    Stroke(Left, T.Border)

    -- Stats label
    local StatsLbl = Label(Left, "STATUS: READY", 8, 8, 132, 36, 10, T.Green, Enum.Font.Code)
    StatsLbl.TextWrapped = true
    StatsLbl.TextXAlignment = Enum.TextXAlignment.Left

    -- SCAN button
    local BtnScan = Button(Left, "SCAN BACKDOOR", 6, 52, 136, 28, T.PanelAlt, T.White, 10)
    Stroke(BtnScan, T.Border, 1)

    -- AUTO SELECT button (baru)
    local BtnAuto = Button(Left, "AUTO SELECT", 6, 84, 136, 24, Color3.fromRGB(15,45,20), T.Green, 10)
    Stroke(BtnAuto, T.Green, 1)

    -- progress bar bg
    local ProgBg = Instance.new("Frame", Left)
    ProgBg.Position = UDim2.new(0, 6, 0, 114)
    ProgBg.Size = UDim2.new(0, 136, 0, 4)
    ProgBg.BackgroundColor3 = T.PanelAlt
    ProgBg.BorderSizePixel = 0
    Corner(ProgBg, 2)

    local ProgFill = Instance.new("Frame", ProgBg)
    ProgFill.Size = UDim2.new(0, 0, 1, 0)
    ProgFill.BackgroundColor3 = T.Green
    ProgFill.BorderSizePixel = 0
    Corner(ProgFill, 2)

    -- FOUND count
    local FoundLbl = Label(Left, "FOUND: 0  |  SUS: 0", 8, 122, 132, 16, 9, T.Dim, Enum.Font.Code)

    -- Divider
    local Div = Instance.new("Frame", Left)
    Div.Position = UDim2.new(0, 6, 0, 144)
    Div.Size = UDim2.new(0, 136, 0, 1)
    Div.BackgroundColor3 = T.Border
    Div.BorderSizePixel = 0

    -- Section: EXECUTE
    Label(Left, "EXECUTE VIA REMOTE", 8, 150, 132, 14, 9, T.Dim, Enum.Font.GothamBold)

    local SelLbl = Label(Left, "No remote selected", 8, 166, 132, 14, 9, T.Yellow, Enum.Font.Code)
    SelLbl.TextTruncate = Enum.TextTruncate.AtEnd

    -- Execute button
    local BtnExec = Button(Left, "EXECUTE", 6, 184, 136, 26, T.Green, Color3.fromRGB(0,0,0), 11)

    -- Clear button
    local BtnClear = Button(Left, "CLEAR", 6, 216, 136, 22, T.PanelAlt, T.Dim, 10)
    Stroke(BtnClear, T.Border)

    -- credit
    local Credit = Label(Left, "By Anonymous9x", 0, 0, 148, 18, 9, T.Border, Enum.Font.Code, Enum.TextXAlignment.Center)
    Credit.Position = UDim2.new(0, 0, 1, -20)

    -- ---- RIGHT COLUMN ----
    local Right = Instance.new("Frame", Body)
    Right.Position = UDim2.new(0, 154, 0, 0)
    Right.Size = UDim2.new(1, -154, 1, -90)
    Right.BackgroundColor3 = T.Panel
    Right.BorderSizePixel = 0
    Corner(Right, 6)
    Stroke(Right, T.Border)

    local RightTitle = Label(Right, "BACKDOOR DETECTED", 8, 6, 200, 14, 9, T.Dim, Enum.Font.GothamBold)

    -- Scroll list
    local Scroll = Instance.new("ScrollingFrame", Right)
    Scroll.Position = UDim2.new(0, 4, 0, 24)
    Scroll.Size = UDim2.new(1, -8, 1, -28)
    Scroll.BackgroundTransparency = 1
    Scroll.ScrollBarThickness = 3
    Scroll.ScrollBarImageColor3 = T.Border
    Scroll.BorderSizePixel = 0
    Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)

    local Layout = Instance.new("UIListLayout", Scroll)
    Layout.Padding = UDim.new(0, 2)
    Layout.SortOrder = Enum.SortOrder.LayoutOrder

    -- ---- PASTE / EXECUTE BOX ----
    local BoxFrame = Instance.new("Frame", Body)
    BoxFrame.Position = UDim2.new(0, 154, 1, -86)
    BoxFrame.Size = UDim2.new(1, -154, 0, 86)
    BoxFrame.BackgroundColor3 = T.Panel
    BoxFrame.BorderSizePixel = 0
    Corner(BoxFrame, 6)
    Stroke(BoxFrame, T.Border)

    local BoxTitle = Label(BoxFrame, "PASTE REQUIRE / SCRIPT", 8, 5, 200, 13, 9, T.Dim, Enum.Font.GothamBold)

    local TextBox = Instance.new("TextBox", BoxFrame)
    TextBox.Position = UDim2.new(0, 6, 0, 22)
    TextBox.Size = UDim2.new(1, -12, 1, -28)
    TextBox.BackgroundColor3 = T.PanelAlt
    TextBox.TextColor3 = T.Green
    TextBox.Font = Enum.Font.Code
    TextBox.TextSize = 10
    TextBox.PlaceholderText = "require(1234567) -- paste script atau require di sini"
    TextBox.PlaceholderColor3 = T.Dim
    TextBox.Text = ""
    TextBox.ClearTextOnFocus = false
    TextBox.MultiLine = true
    TextBox.TextXAlignment = Enum.TextXAlignment.Left
    TextBox.TextYAlignment = Enum.TextYAlignment.Top
    Corner(TextBox, 4)
    Stroke(TextBox, T.Border, 1)

    -- Label highlight di TextBox
    local TbLabel = Label(BoxFrame, "TextBox", 8, 0, 60, 22, 8, T.Red, Enum.Font.Code)
    TbLabel.Position = UDim2.new(0, 8, 1, -12)
    TbLabel.Size = UDim2.new(0, 60, 0, 12)

    -- ================================================================
    -- LOADING ANIMATION (dots cycling on scan button)
    -- ================================================================
    local loadingActive = false
    local loadingFrames = {"SCANNING.", "SCANNING..", "SCANNING..."}
    local loadingIdx = 1

    task.spawn(function()
        while Screen.Parent do
            task.wait(0.4)
            if loadingActive then
                loadingIdx = (loadingIdx % #loadingFrames) + 1
                pcall(function()
                    BtnScan.Text = loadingFrames[loadingIdx]
                end)
            end
        end
    end)

    -- ================================================================
    -- STATE
    -- ================================================================
    local selectedRemote = nil

    local function setStatus(txt, col)
        pcall(function()
            StatsLbl.Text = txt
            StatsLbl.TextColor3 = col or T.Green
        end)
    end

    local function setSelected(remote)
        selectedRemote = remote
        pcall(function()
            SelLbl.Text = remote and remote.name or "No remote selected"
            SelLbl.TextColor3 = remote and T.Yellow or T.Dim
        end)
    end

    -- ================================================================
    -- SCORING: cari backdoor paling parah
    -- Skor lebih tinggi = lebih mungkin terima require()
    -- ================================================================
    local SCORE_MAP = {
        loadstring=10, require=10, exec=9, execute=9,
        serverexec=9, serverrun=9, serverload=9,
        loader=8, mainloader=8, scriptloader=8, adminloader=8,
        cmd=8, command=8, shell=8, run=8,
        backdoor=9, door=8, gate=7, tunnel=7,
        inject=7, payload=7, exploit=7,
        adminexec=7, admincmd=7,
        fe2=6, feloader=6, feexec=6,
        rc7=8, rc_7=8,
    }
    local function scoreRemote(rem)
        local score = 0
        local name = rem.name:lower()
        local path = rem.path:lower()
        -- Keyword match
        for kw, pts in pairs(SCORE_MAP) do
            if name:find(kw,1,true) or path:find(kw,1,true) then
                score = score + pts
            end
        end
        -- RemoteFunction lebih sering dipakai backdoor execute
        if rem.class == "RemoteFunction" then score = score + 2 end
        -- Nama sangat pendek (obfuscated)
        if #rem.name <= 2 then score = score + 3 end
        -- Di ReplicatedStorage root langsung (bukan nested)
        if path:match("^replicatedstorage%.%w+$") then score = score + 2 end
        return score
    end

    local function autoSelectBest()
        if #Scanner.Remotes == 0 then
            setStatus("Scan dulu sebelum Auto Select!", T.Red)
            return
        end
        local best, bestScore = nil, -1
        local pool = #Scanner.Backdoors > 0 and Scanner.Backdoors or Scanner.Remotes
        for _, rem in ipairs(pool) do
            local s = scoreRemote(rem)
            if s > bestScore then
                bestScore = s
                best = rem
            end
        end
        if best then
            setSelected(best)
            setStatus("AUTO: " .. best.name .. " (score " .. bestScore .. ")", T.Green)
            -- Highlight di list
            for _, row in ipairs(Scroll:GetChildren()) do
                if row:IsA("Frame") then
                    row.BackgroundColor3 = T.PanelAlt
                end
            end
        else
            setStatus("Tidak ada remote ditemukan", T.Red)
        end
    end

    BtnAuto.MouseButton1Click:Connect(autoSelectBest)

    -- Populate list with remote entries
    local function populateList(list, showAll)
        -- Clear
        for _, v in ipairs(Scroll:GetChildren()) do
            if v:IsA("Frame") then v:Destroy() end
        end

        local entries = showAll and Scanner.Remotes or Scanner.Backdoors
        local count = 0

        for _, rem in ipairs(entries) do
            count = count + 1
            local Row = Instance.new("Frame", Scroll)
            Row.Size = UDim2.new(1, 0, 0, 24)
            Row.BackgroundColor3 = rem.sus and Color3.fromRGB(30,10,10) or T.PanelAlt
            Row.BorderSizePixel = 0
            Row.LayoutOrder = count
            Corner(Row, 4)

            -- indicator dot
            local Dot = Instance.new("Frame", Row)
            Dot.Size = UDim2.new(0, 6, 0, 6)
            Dot.Position = UDim2.new(0, 6, 0.5, -3)
            Dot.BackgroundColor3 = rem.sus and T.Red or T.Green
            Dot.BorderSizePixel = 0
            Corner(Dot, 3)

            -- class tag
            local Tag = Label(Row, rem.class == "RemoteFunction" and "RF" or rem.class == "BindableEvent" and "BE" or "RE",
                16, 0, 22, 24, 8, T.Dim, Enum.Font.Code)

            -- path
            local PathLbl = Label(Row, rem.path, 40, 0, 0, 24, 9,
                rem.sus and T.Red or T.Text, Enum.Font.Code)
            PathLbl.Size = UDim2.new(1, -86, 1, 0)
            PathLbl.TextTruncate = Enum.TextTruncate.AtEnd

            -- keyword tag if suspicious
            if rem.sus and rem.keyword ~= "" then
                local KwLbl = Label(Row, rem.keyword, 0, 0, 44, 24, 8, T.Yellow, Enum.Font.Code, Enum.TextXAlignment.Right)
                KwLbl.Size = UDim2.new(0, 44, 1, 0)
                KwLbl.Position = UDim2.new(1, -46, 0, 0)
            end

            -- Select on click
            Row.InputBegan:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1
                or inp.UserInputType == Enum.UserInputType.Touch then
                    setSelected(rem)
                    -- Highlight selected
                    for _, r in ipairs(Scroll:GetChildren()) do
                        if r:IsA("Frame") then
                            r.BackgroundColor3 = r == Row
                                and Color3.fromRGB(10,40,20)
                                or (rem.sus and Color3.fromRGB(30,10,10) or T.PanelAlt)
                        end
                    end
                    Row.BackgroundColor3 = Color3.fromRGB(10, 40, 20)
                end
            end)
        end

        Scroll.CanvasSize = UDim2.new(0, 0, 0, count * 26)
        RightTitle.Text = "BACKDOOR DETECTED (" .. #Scanner.Backdoors .. ")  |  ALL: " .. #Scanner.Remotes
    end

    -- ================================================================
    -- SCAN BUTTON
    -- ================================================================
    local showingAll = false

    BtnScan.MouseButton1Click:Connect(function()
        if Scanner.Scanning then return end

        loadingActive = true
        BtnScan.BackgroundColor3 = Color3.fromRGB(30, 60, 30)
        setStatus("Initializing...", T.Dim)
        ProgFill.Size = UDim2.new(0, 0, 1, 0)
        setSelected(nil)

        Scanner.Run(
            -- onProgress
            function(msg, pct)
                pcall(function()
                    setStatus(msg, T.Dim)
                    ProgFill:TweenSize(
                        UDim2.new(pct, 0, 1, 0),
                        Enum.EasingDirection.Out, Enum.EasingStyle.Linear, 0.08, true
                    )
                end)
            end,
            -- onDone
            function(total, suspicious)
                loadingActive = false
                pcall(function()
                    BtnScan.Text = "FOUND: " .. suspicious .. " SUSPECT"
                    BtnScan.BackgroundColor3 = suspicious > 0 and Color3.fromRGB(50,15,15) or Color3.fromRGB(15,40,20)
                    ProgFill:TweenSize(UDim2.new(1,0,1,0), Enum.EasingDirection.Out, Enum.EasingStyle.Linear, 0.1, true)
                    FoundLbl.Text = "FOUND: " .. total .. "  |  SUS: " .. suspicious
                    setStatus(suspicious > 0 and ("BACKDOOR DETECTED (" .. suspicious .. ")") or "CLEAN - NO BACKDOOR FOUND",
                        suspicious > 0 and T.Red or T.Green)
                    showingAll = false
                    populateList(Scanner.Backdoors, false)
                end)
            end
        )
    end)

    -- Toggle show all / show sus only
    RightTitle.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            if #Scanner.Remotes == 0 then return end
            showingAll = not showingAll
            populateList(Scanner.Remotes, showingAll)
            RightTitle.Text = showingAll
                and ("ALL REMOTES (" .. #Scanner.Remotes .. ")")
                or ("BACKDOOR DETECTED (" .. #Scanner.Backdoors .. ")  |  ALL: " .. #Scanner.Remotes)
        end
    end)
    RightTitle.TextColor3 = T.Dim

    -- ================================================================
    -- EXECUTE
    -- ================================================================
    BtnExec.MouseButton1Click:Connect(function()
        local code = TextBox.Text
        if not selectedRemote then
            setStatus("Pilih remote dulu dari list!", T.Red)
            return
        end
        if code == "" then
            setStatus("Paste script/require dulu!", T.Red)
            return
        end

        setStatus("Executing via " .. selectedRemote.name .. "...", T.Yellow)
        task.spawn(function()
            local ok, err = tryExecute(selectedRemote, code)
            task.wait(0.5)
            if ok then
                setStatus("Executed via " .. selectedRemote.name, T.Green)
            else
                setStatus("Exec error: " .. tostring(err):sub(1, 40), T.Red)
            end
        end)
    end)

    -- ================================================================
    -- CLEAR
    -- ================================================================
    BtnClear.MouseButton1Click:Connect(function()
        TextBox.Text = ""
        setStatus("Cleared", T.Dim)
    end)

    print("[An9x Scanner] Loaded. Tap SCAN BACKDOOR untuk mulai.")
end

-- ================================================================
-- INIT
-- ================================================================
Scanner.BuildUI()
