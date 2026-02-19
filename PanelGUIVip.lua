-- Anonymous9x RepText UI v5.0
-- EXECUTOR PROOF: No UIListLayout, No AutomaticSize, No AutomaticCanvasSize
-- Full manual positioning, works on Delta, Fluxus, Arceus X, Hydrogen, etc.

local TweenService = game:GetService("TweenService")
local PlayerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")

-- THEME
local T = {
    BG     = Color3.fromRGB(12, 12, 12),
    Dark   = Color3.fromRGB(18, 18, 18),
    Card   = Color3.fromRGB(22, 22, 22),
    Border = Color3.fromRGB(235, 235, 235),
    White  = Color3.fromRGB(245, 245, 245),
    Sub    = Color3.fromRGB(180, 180, 180),
    Btn    = Color3.fromRGB(38, 38, 38),
    Hover  = Color3.fromRGB(55, 55, 55),
}

-- HELPERS
local function mkCorner(p, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 8)
    c.Parent = p
end

local function mkStroke(p, th, tr)
    local s = Instance.new("UIStroke")
    s.Color = T.Border
    s.Thickness = th or 1.5
    s.Transparency = tr or 0.25
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = p
end

local function tw(obj, props, t)
    TweenService:Create(obj, TweenInfo.new(t or 0.13, Enum.EasingStyle.Quint), props):Play()
end

-- DATA
local CATS = {
    "Harassment", "18+ Content", "Advertising", "Exploiting",
    "Scamming",   "Racism",      "Threats",     "Username",
    "Game Content","Impersonation","Child Safety","Bot Account","Toxicity"
}

local DATA = {
    ["Harassment"] = {
        "I was repeatedly targeted with persistent harassment including toxic language, insults, and disrespectful comments directed specifically at me during gameplay sessions. This player's behavior clearly violates Roblox community standards and creates a significantly negative environment that affects other players' enjoyment of the game. The harassment continued even after I requested them to stop, demonstrating intentional disregard for community guidelines.",
        "I am a victim of ongoing systematic harassment from another player. They used offensive language and personal insults directed at me specifically, attempting to provoke confrontation and make me uncomfortable in the game environment. Multiple witnesses were present during these incidents and can confirm the repeated nature of this behavior.",
        "A player engaged in a coordinated harassment campaign against me including persistent name-calling, derogatory remarks, and public humiliation attempts. This constitutes clear bullying behavior that significantly disrupts normal gameplay experience for me and observers. The targeting was clearly intentional and persistent over multiple game sessions.",
        "I was harassed by a player with constant insults and toxic behavior throughout multiple consecutive game sessions. When I requested them to stop engaging in this behavior, the harassment continued unabated and even intensified. This is a clear and serious violation of Roblox community guidelines and creates an unsafe gaming environment.",
    },
    ["18+ Content"] = {
        "A player created and distributed inappropriate 18+ sexual content within the game environment. Sexual dialogue, explicit material, and adult-themed messaging are clearly present which directly violates Roblox community standards for an all-ages platform.",
        "A player repeatedly engaged in explicit sexual roleplay and posted adult content throughout the public game chat. This explicitly violates platform policy regarding mature content that has absolutely no place on a family-friendly game where minors are present.",
        "I witnessed inappropriate and explicit sexual behavior including graphic language and adult roleplay scenarios from another player. Multiple players witnessed this conduct and reported feeling uncomfortable. Immediate action is required as this is a serious violation.",
        "A player repeatedly spammed 18+ content and explicit sexual messages throughout the public chat system. They actively attempted to engage other players in adult conversations and continued despite being asked to stop.",
        "A player actively promoted adult content with direct links and references to inappropriate material. This directly violates Roblox Terms of Service regarding sexual content on a youth-oriented platform.",
    },
    ["Advertising"] = {
        "A player repeatedly spammed advertisements and promotional messages in the game chat. They posted multiple external links in direct violation of platform rules and continued even after being asked to stop.",
        "I observed a player continuously advertising external Discord servers, YouTube channels, and other promotional links throughout the game chat. This prohibited behavior clearly violates Roblox platform policies.",
        "There was significant spam flooding in the game chat with repetitive messages and multiple external links that severely disrupted normal gameplay. The same player posted identical messages numerous times.",
        "A player engaged in persistent spam advertising including Discord server invites, external links, and various promotional content. This behavior clearly violates anti-spam policy.",
        "I observed a player repeatedly spam the same promotional content multiple times within a short timeframe, creating clear disruption to the game environment for all players.",
    },
    ["Exploiting"] = {
        "I observed another player utilizing an exploit that clearly grants them unfair gameplay advantage. I witnessed them flying, using speed hacks, and becoming invisible in a game where none of these abilities exist normally.",
        "A player was actively using a game exploit I could clearly document. They were walking through walls, having infinite health, and teleporting around the map. This was confirmed by multiple other players.",
        "I detected clear exploitation from another player using unfair methods and external tools to gain an unfair advantage. This is ruining the experience for all legitimate players.",
        "I confirmed a player using exploits with impossible abilities that should not exist in normal gameplay. They were generating infinite money and items, demonstrating a serious code violation.",
        "A player was utilizing a paid exploit menu to gain unfair advantages. I observed wallhacking and speedhacking which clearly affected other players negatively.",
    },
    ["Scamming"] = {
        "I was scammed by a player in a trade. They promised certain valuable items in exchange for my items but completely failed to deliver. This is fraudulent behavior violating trading guidelines.",
        "A player conducted a clear scam targeting me. They took my valuable items with false promises that never materialized. Multiple other players have reported being scammed by the same person.",
        "I am a victim of a deliberate scam. A player promised to provide specific items but completely failed to deliver, leaving me worse off. I lost significant in-game currency.",
        "A player is running an ongoing scam scheme targeting multiple players. They make false promises in exchange for items without delivering. Multiple reports confirm this is a pattern.",
        "I was scammed by a player who took my items claiming they would be doubled or returned, but kept everything. This is clear intentional theft of player items.",
    },
    ["Racism"] = {
        "A player used racist slurs and discriminatory language toward other players. They engaged in hate speech directed at players based on race and ethnicity. This is completely unacceptable.",
        "I observed a player engaged in discriminatory behavior and hate speech making racist comments toward multiple players creating a hostile environment.",
        "A player directed racism at others using racial slurs and discriminatory statements about race and nationality. This violates anti-discrimination policy.",
        "I witnessed a player make discriminatory comments based on religion and ethnicity using hateful language that violates community standards.",
        "A player actively promoted discriminatory ideology through racist remarks and hate speech, directly violating platform policy on equality and respect.",
    },
    ["Threats"] = {
        "A player made serious threatening statements toward me including death threats and intimidation tactics attempting to scare and coerce me. These direct threats create genuine fear.",
        "I am reporting a player who threatened me with doxxing and real-world physical harm. This serious behavior requires immediate action from the safety team.",
        "A player engaged in targeted intimidation making threatening statements about hacking my account and filing false reports to coerce compliance.",
        "I received violent threats including specific threats of harm. This constitutes serious threatening behavior that is a clear policy violation.",
        "A player threatened to hack my account and cause real-world harm. These intimidation tactics create an unsafe environment and require investigation.",
    },
    ["Username"] = {
        "A player has an inappropriate username containing offensive language and slurs, violating username policy for maintaining a respectful community environment.",
        "The username I observed contains explicit adult content that is inappropriate and unsuitable for this platform, containing adult references and offensive slurs.",
        "A player's username contains hate speech and slurs directly violating Roblox naming standards and community conduct requirements.",
        "I found a username that includes sexual and adult content completely inappropriate for a family-friendly platform.",
        "A player's username contains offensive language creating a hostile environment, violating community standards for username appropriateness.",
    },
    ["Game Content"] = {
        "This game contains inappropriate 18+ sexual content. Explicit dialogue, animations, and assets are present that violate platform content policy for what should be an all-ages game.",
        "This game features adult content including repeated sexual references and mature material unsuitable for the Roblox platform, violating content guidelines.",
        "This game includes hate speech and offensive content with racial slurs and discriminatory material in game mechanics and dialogue. This is a clear policy violation.",
        "This game contains excessive violence and gore inappropriate for platform standards. The graphic content violates age-appropriate content guidelines.",
        "This game is designed to promote adult behavior and sexual roleplay. The content explicitly violates Roblox community standards.",
    },
    ["Impersonation"] = {
        "Another player is impersonating a legitimate player. Their username and avatar are designed to look identical to a real account, causing confusion and enabling fraud.",
        "A player is impersonating a game developer or staff member, making false claims of authority which cause confusion among other players.",
        "A player created an account impersonating a legitimate user to scam and deceive others. The fake account has fooled multiple people.",
        "A player is pretending to be a content creator to deceive others for personal gain through false identity. This is a clear impersonation violation.",
        "I observed a clear impersonation attempt where a player mimicked a verified account to conduct fraud, deceiving multiple players.",
    },
    ["Child Safety"] = {
        "A player exhibited deeply concerning behavior regarding child safety. They made inappropriate comments toward younger players which raises serious safety concerns.",
        "I observed a player engaged in grooming behavior toward younger players, attempting to manipulate children into private conversations for inappropriate purposes.",
        "I am reporting a critical child safety concern: A player made inappropriate solicitations toward minors requiring immediate investigation by the safety team.",
        "I witnessed predatory behavior from a player targeting younger players with inappropriate proposals causing visible discomfort. This requires urgent attention.",
        "A player attempted to contact younger players for inappropriate offline communication. This is a major safety concern requiring immediate action.",
    },
    ["Bot Account"] = {
        "I identified an account that appears to be a bot. The automated behavior and spam patterns are obvious and suspicious. This account is not a legitimate player.",
        "An account displays clear bot characteristics including highly repetitive behavior and suspicious activity patterns, appearing completely automated.",
        "I observed a suspicious account exhibiting bot-like behavior. Automated responses and unnatural gameplay strongly suggest this is a fake account.",
        "I confirmed an account is likely a bot showing zero legitimate gameplay and only engaging in repetitive spam and advertising behavior.",
        "An account has been confirmed as a bot displaying automated advertising and spam patterns. This is not a genuine player account.",
    },
    ["Toxicity"] = {
        "I observed a player exhibiting toxic and rude behavior toward multiple other players using aggressive language and disrespectful comments throughout their session.",
        "A player displayed extremely toxic behavior in the game chat making rude comments and creating a negative atmosphere affecting everyone.",
        "I witnessed toxicity from a player who made rude remarks to others, complained constantly, and created a very negative game atmosphere.",
        "A player displayed rudeness and a generally toxic attitude giving aggressive responses and treating other players with disrespect.",
        "A player exhibited toxic behavior including rude language and disrespectful treatment creating a negative community experience.",
    },
}

-- ============================================================
-- BUILD UI
-- ============================================================
local function build()
    -- Hapus instance lama
    local old = PlayerGui:FindFirstChild("RepTextUI")
    if old then pcall(function() old:Destroy() end) end

    -- DIMENSI
    local PW = 268      -- panel width
    local PH = 338      -- panel height
    local TH = 36       -- titlebar height
    local CAT_H = 40    -- category bar height
    local BODY_H = PH - TH - CAT_H   -- 262px untuk scroll area

    -- CARD: fixed 115px per card, 6px gap
    local CARD_H = 115
    local CARD_GAP = 6
    local CARD_PAD = 7  -- padding atas/bawah scroll area

    -- ScreenGui
    local sg = Instance.new("ScreenGui")
    sg.Name = "RepTextUI"
    sg.ResetOnSpawn = false
    sg.DisplayOrder = 999
    sg.IgnoreGuiInset = true
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    sg.Parent = PlayerGui

    -- Main frame
    local mf = Instance.new("Frame")
    mf.Name = "Main"
    mf.AnchorPoint = Vector2.new(0.5, 0.5)
    mf.Size = UDim2.fromOffset(PW, PH)
    mf.Position = UDim2.new(0.5, 0, -0.8, 0)
    mf.BackgroundColor3 = T.BG
    mf.BorderSizePixel = 0
    mf.ClipsDescendants = true
    mf.Parent = sg
    mkCorner(mf, 14)
    mkStroke(mf, 1.5, 0.2)

    -- ============================
    -- TITLEBAR
    -- ============================
    local tb = Instance.new("Frame")
    tb.Size = UDim2.fromOffset(PW, TH)
    tb.Position = UDim2.fromOffset(0, 0)
    tb.BackgroundColor3 = T.Dark
    tb.BorderSizePixel = 0
    tb.ZIndex = 10
    tb.Parent = mf
    mkCorner(tb, 14)

    -- patch bawah titlebar (cover rounded corners bawah)
    local tbp = Instance.new("Frame")
    tbp.Size = UDim2.fromOffset(PW, 14)
    tbp.Position = UDim2.fromOffset(0, TH - 14)
    tbp.BackgroundColor3 = T.Dark
    tbp.BorderSizePixel = 0
    tbp.ZIndex = 9
    tbp.Parent = mf

    -- separator line
    local sep = Instance.new("Frame")
    sep.Size = UDim2.fromOffset(PW, 1)
    sep.Position = UDim2.fromOffset(0, TH - 1)
    sep.BackgroundColor3 = T.Border
    sep.BackgroundTransparency = 0.6
    sep.BorderSizePixel = 0
    sep.ZIndex = 11
    sep.Parent = mf

    -- title text
    local ttxt = Instance.new("TextLabel")
    ttxt.Size = UDim2.fromOffset(PW - 68, TH)
    ttxt.Position = UDim2.fromOffset(12, 0)
    ttxt.BackgroundTransparency = 1
    ttxt.TextColor3 = T.White
    ttxt.TextSize = 12
    ttxt.Font = Enum.Font.GothamBold
    ttxt.Text = "Anonymous9x  RepText"
    ttxt.TextXAlignment = Enum.TextXAlignment.Left
    ttxt.ZIndex = 12
    ttxt.Parent = mf

    -- Minimize button
    local minBtn = Instance.new("TextButton")
    minBtn.Size = UDim2.fromOffset(24, 24)
    minBtn.Position = UDim2.fromOffset(PW - 58, 6)
    minBtn.BackgroundColor3 = T.Btn
    minBtn.BorderSizePixel = 0
    minBtn.TextColor3 = T.White
    minBtn.TextSize = 15
    minBtn.Font = Enum.Font.GothamBold
    minBtn.Text = "−"
    minBtn.ZIndex = 13
    minBtn.Parent = mf
    mkCorner(minBtn, 6)
    mkStroke(minBtn, 1, 0.55)

    -- Close button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.fromOffset(24, 24)
    closeBtn.Position = UDim2.fromOffset(PW - 30, 6)
    closeBtn.BackgroundColor3 = T.Btn
    closeBtn.BorderSizePixel = 0
    closeBtn.TextColor3 = T.White
    closeBtn.TextSize = 15
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Text = "×"
    closeBtn.ZIndex = 13
    closeBtn.Parent = mf
    mkCorner(closeBtn, 6)
    mkStroke(closeBtn, 1, 0.55)

    for _, b in ipairs({minBtn, closeBtn}) do
        b.MouseEnter:Connect(function() tw(b, {BackgroundColor3 = T.Hover}) end)
        b.MouseLeave:Connect(function() tw(b, {BackgroundColor3 = T.Btn}) end)
    end

    -- ============================
    -- CATEGORY BAR (Frame biasa, bukan ScrollingFrame)
    -- Ini kuncinya: pakai Frame + ClipsDescendants, scroll manual via swipe
    -- ============================
    local catClip = Instance.new("Frame")
    catClip.Name = "CatClip"
    catClip.Size = UDim2.fromOffset(PW, CAT_H)
    catClip.Position = UDim2.fromOffset(0, TH)
    catClip.BackgroundColor3 = T.Dark
    catClip.BorderSizePixel = 0
    catClip.ClipsDescendants = true  -- ini yang bikin tombol terpotong di pinggir
    catClip.ZIndex = 8
    catClip.Parent = mf

    -- separator bawah category
    local catSep = Instance.new("Frame")
    catSep.Size = UDim2.fromOffset(PW, 1)
    catSep.Position = UDim2.fromOffset(0, CAT_H - 1)
    catSep.BackgroundColor3 = T.Border
    catSep.BackgroundTransparency = 0.6
    catSep.BorderSizePixel = 0
    catSep.ZIndex = 9
    catSep.Parent = catClip

    -- Container tombol di dalam catClip (ini yang digeser saat swipe)
    local catTrack = Instance.new("Frame")
    catTrack.Name = "CatTrack"
    catTrack.Size = UDim2.fromOffset(2000, CAT_H)  -- lebar lebih dari cukup
    catTrack.Position = UDim2.fromOffset(0, 0)
    catTrack.BackgroundTransparency = 1
    catTrack.BorderSizePixel = 0
    catTrack.ZIndex = 8
    catTrack.Parent = catClip

    -- ============================
    -- BODY / TEXT SCROLL
    -- ============================
    local bodyClip = Instance.new("Frame")
    bodyClip.Name = "BodyClip"
    bodyClip.Size = UDim2.fromOffset(PW, BODY_H)
    bodyClip.Position = UDim2.fromOffset(0, TH + CAT_H)
    bodyClip.BackgroundColor3 = T.BG
    bodyClip.BorderSizePixel = 0
    bodyClip.ClipsDescendants = true
    bodyClip.ZIndex = 7
    bodyClip.Parent = mf

    -- Container kartu di dalam body (ini yang digeser saat scroll)
    local bodyTrack = Instance.new("Frame")
    bodyTrack.Name = "BodyTrack"
    bodyTrack.Size = UDim2.fromOffset(PW, 2000)   -- tinggi besar, dipotong clipper
    bodyTrack.Position = UDim2.fromOffset(0, 0)
    bodyTrack.BackgroundTransparency = 1
    bodyTrack.BorderSizePixel = 0
    bodyTrack.ZIndex = 7
    bodyTrack.Parent = bodyClip

    -- Placeholder
    local phLabel = Instance.new("TextLabel")
    phLabel.Name = "PH"
    phLabel.Size = UDim2.fromOffset(PW, 60)
    phLabel.Position = UDim2.fromOffset(0, BODY_H/2 - 30)
    phLabel.BackgroundTransparency = 1
    phLabel.TextColor3 = Color3.fromRGB(70, 70, 70)
    phLabel.TextSize = 11
    phLabel.Font = Enum.Font.Gotham
    phLabel.Text = "Pilih kategori di atas"
    phLabel.TextXAlignment = Enum.TextXAlignment.Center
    phLabel.ZIndex = 8
    phLabel.Parent = bodyClip  -- di bodyClip langsung, bukan bodyTrack

    -- ============================
    -- STATE
    -- ============================
    local isMinimized = false
    local selCat = nil
    local catBtns = {}
    local totalCatContent = 0  -- total lebar konten category
    local bodyScrollY = 0       -- posisi scroll body (px)
    local bodyMaxScroll = 0     -- max scroll body

    -- ============================
    -- FUNGSI LOAD KATEGORI
    -- ============================
    local function loadCat(catName)
        -- Reset semua tombol
        for n, b in pairs(catBtns) do
            b.BackgroundColor3 = T.Dark
            b.TextColor3 = T.Sub
        end
        if catBtns[catName] then
            catBtns[catName].BackgroundColor3 = T.Btn
            catBtns[catName].TextColor3 = T.White
        end
        selCat = catName

        -- Hapus kartu lama dari bodyTrack
        for _, c in ipairs(bodyTrack:GetChildren()) do
            if c:IsA("Frame") then pcall(function() c:Destroy() end) end
        end
        phLabel.Visible = false

        local list = DATA[catName]
        if not list then return end

        -- Reset scroll ke atas
        bodyScrollY = 0
        bodyTrack.Position = UDim2.fromOffset(0, 0)

        -- Buat kartu dengan posisi Y manual
        local curY = CARD_PAD
        for i, txt in ipairs(list) do
            local card = Instance.new("Frame")
            card.Name = "Card"..i
            card.Size = UDim2.fromOffset(PW - CARD_PAD*2, CARD_H)
            card.Position = UDim2.fromOffset(CARD_PAD, curY)
            card.BackgroundColor3 = T.Card
            card.BorderSizePixel = 0
            card.ZIndex = 8
            card.Parent = bodyTrack
            mkCorner(card, 8)
            mkStroke(card, 1, 0.72)

            -- Nomor
            local num = Instance.new("TextLabel")
            num.Size = UDim2.fromOffset(18, 14)
            num.Position = UDim2.fromOffset(PW - CARD_PAD*2 - 22, 5)
            num.BackgroundTransparency = 1
            num.TextColor3 = Color3.fromRGB(60, 60, 60)
            num.TextSize = 9
            num.Font = Enum.Font.GothamBold
            num.Text = tostring(i)
            num.ZIndex = 9
            num.Parent = card

            -- Teks isi
            local tl = Instance.new("TextLabel")
            tl.Size = UDim2.fromOffset(PW - CARD_PAD*2 - 14, CARD_H - 34)
            tl.Position = UDim2.fromOffset(7, 5)
            tl.BackgroundTransparency = 1
            tl.TextColor3 = T.Sub
            tl.TextSize = 9
            tl.Font = Enum.Font.Gotham
            tl.Text = txt
            tl.TextWrapped = true
            tl.TextXAlignment = Enum.TextXAlignment.Left
            tl.TextYAlignment = Enum.TextYAlignment.Top
            tl.ZIndex = 9
            tl.Parent = card

            -- Copy button
            local cp = Instance.new("TextButton")
            cp.Size = UDim2.fromOffset(PW - CARD_PAD*2 - 14, 22)
            cp.Position = UDim2.fromOffset(7, CARD_H - 27)
            cp.BackgroundColor3 = T.Btn
            cp.BorderSizePixel = 0
            cp.TextColor3 = T.White
            cp.TextSize = 10
            cp.Font = Enum.Font.GothamBold
            cp.Text = "COPY"
            cp.ZIndex = 10
            cp.Parent = card
            mkCorner(cp, 5)
            mkStroke(cp, 1, 0.6)

            cp.MouseEnter:Connect(function() tw(cp, {BackgroundColor3 = T.Hover}) end)
            cp.MouseLeave:Connect(function()
                if cp.Text == "COPY" then tw(cp, {BackgroundColor3 = T.Btn}) end
            end)

            local function doCopy()
                pcall(function()
                    setclipboard(txt)
                    cp.Text = "✓ Copied!"
                    cp.BackgroundColor3 = T.Hover
                    task.wait(1.5)
                    cp.Text = "COPY"
                    tw(cp, {BackgroundColor3 = T.Btn})
                end)
            end
            cp.MouseButton1Click:Connect(doCopy)
            cp.TouchTap:Connect(doCopy)

            curY = curY + CARD_H + CARD_GAP
        end

        -- Hitung max scroll
        local totalH = curY + CARD_PAD
        bodyMaxScroll = math.max(0, totalH - BODY_H)
    end

    -- ============================
    -- BUAT TOMBOL KATEGORI (manual X positioning)
    -- ============================
    local BTN_H = 28
    local BTN_PAD_X = 8    -- padding kiri kanan dalam tombol
    local BTN_GAP = 5
    local curX = 6

    for idx, catName in ipairs(CATS) do
        if DATA[catName] then
            -- Estimasi lebar teks: ~6.5px per karakter + 2 * BTN_PAD_X
            local btnW = math.max(52, math.floor(#catName * 6.5) + BTN_PAD_X * 2)

            local btn = Instance.new("TextButton")
            btn.Name = catName
            btn.Size = UDim2.fromOffset(btnW, BTN_H)
            btn.Position = UDim2.fromOffset(curX, (CAT_H - BTN_H) / 2)
            btn.BackgroundColor3 = T.Dark
            btn.BorderSizePixel = 0
            btn.TextColor3 = T.Sub
            btn.TextSize = 10
            btn.Font = Enum.Font.GothamBold
            btn.Text = catName
            btn.ZIndex = 9
            btn.Parent = catTrack
            mkCorner(btn, 6)

            btn.MouseEnter:Connect(function()
                if selCat ~= catName then tw(btn, {TextColor3 = T.White}) end
            end)
            btn.MouseLeave:Connect(function()
                if selCat ~= catName then tw(btn, {TextColor3 = T.Sub}) end
            end)

            local function doSelect()
                loadCat(catName)
            end
            btn.MouseButton1Click:Connect(doSelect)
            btn.TouchTap:Connect(doSelect)

            catBtns[catName] = btn
            curX = curX + btnW + BTN_GAP
        end
    end
    totalCatContent = curX + 6  -- total lebar semua tombol

    -- ============================
    -- SWIPE CATEGORY BAR (manual scroll catTrack)
    -- ============================
    local catScrollX = 0
    local catMaxScroll = math.max(0, totalCatContent - PW)
    local catSwipeStartX = 0
    local catSwiping = false

    catClip.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.Touch
        or inp.UserInputType == Enum.UserInputType.MouseButton1 then
            catSwipeStartX = inp.Position.X
            catSwiping = true
        end
    end)
    catClip.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.Touch
        or inp.UserInputType == Enum.UserInputType.MouseButton1 then
            catSwiping = false
        end
    end)
    catClip.InputChanged:Connect(function(inp)
        if catSwiping and (
            inp.UserInputType == Enum.UserInputType.Touch or
            inp.UserInputType == Enum.UserInputType.MouseMovement
        ) then
            local delta = catSwipeStartX - inp.Position.X
            catScrollX = math.clamp(catScrollX + delta * 0.7, 0, catMaxScroll)
            catTrack.Position = UDim2.fromOffset(-catScrollX, 0)
            catSwipeStartX = inp.Position.X
        end
    end)

    -- ============================
    -- SCROLL BODY (manual scroll bodyTrack)
    -- ============================
    local bodySwipeStartY = 0
    local bodySwiping = false

    bodyClip.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.Touch
        or inp.UserInputType == Enum.UserInputType.MouseButton1 then
            bodySwipeStartY = inp.Position.Y
            bodySwiping = true
        end
    end)
    bodyClip.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.Touch
        or inp.UserInputType == Enum.UserInputType.MouseButton1 then
            bodySwiping = false
        end
    end)
    bodyClip.InputChanged:Connect(function(inp)
        if bodySwiping and (
            inp.UserInputType == Enum.UserInputType.Touch or
            inp.UserInputType == Enum.UserInputType.MouseMovement
        ) then
            local delta = bodySwipeStartY - inp.Position.Y
            bodyScrollY = math.clamp(bodyScrollY + delta * 0.7, 0, bodyMaxScroll)
            bodyTrack.Position = UDim2.fromOffset(0, -bodyScrollY)
            bodySwipeStartY = inp.Position.Y
        end
    end)

    -- Mouse wheel scroll (PC)
    local UIS = game:GetService("UserInputService")
    UIS.InputChanged:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseWheel then
            bodyScrollY = math.clamp(bodyScrollY - inp.Position.Z * 30, 0, bodyMaxScroll)
            bodyTrack.Position = UDim2.fromOffset(0, -bodyScrollY)
        end
    end)

    -- ============================
    -- MINIMIZE / CLOSE
    -- ============================
    minBtn.MouseButton1Click:Connect(function()
        if not isMinimized then
            isMinimized = true
            catClip.Visible = false
            bodyClip.Visible = false
            tbp.Visible = false
            sep.Visible = false
            tw(mf, {Size = UDim2.fromOffset(PW, TH)}, 0.2)
            minBtn.Text = "+"
        else
            isMinimized = false
            tw(mf, {Size = UDim2.fromOffset(PW, PH)}, 0.2)
            task.wait(0.18)
            catClip.Visible = true
            bodyClip.Visible = true
            tbp.Visible = true
            sep.Visible = true
            minBtn.Text = "−"
        end
    end)

    closeBtn.MouseButton1Click:Connect(function()
        tw(mf, {Position = UDim2.new(0.5, 0, -0.8, 0)}, 0.22)
        task.wait(0.25)
        pcall(function() sg:Destroy() end)
    end)

    -- Entry animation
    task.wait(0.05)
    tw(mf, {Position = UDim2.fromScale(0.5, 0.5)}, 0.38)

    print("Anonymous9x RepText v5.0 - loaded!")
end

pcall(build)
