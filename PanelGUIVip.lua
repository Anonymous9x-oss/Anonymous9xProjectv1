-- Anonymous9x RepText UI v4.0
-- Center Locked | Mobile + PC | Fixed Layout | No AutomaticSize bugs

local TweenService = game:GetService("TweenService")
local PlayerGui    = game.Players.LocalPlayer:WaitForChild("PlayerGui")

local T = {
    BG      = Color3.fromRGB(12, 12, 12),
    Dark    = Color3.fromRGB(18, 18, 18),
    Card    = Color3.fromRGB(22, 22, 22),
    Border  = Color3.fromRGB(235, 235, 235),
    Text    = Color3.fromRGB(245, 245, 245),
    Sub     = Color3.fromRGB(185, 185, 185),
    Hover   = Color3.fromRGB(40, 40, 40),
    Btn     = Color3.fromRGB(38, 38, 38),
    Copy    = Color3.fromRGB(55, 55, 55),
}

-- ===== DATA =====
local CATEGORIES = {
    "Harassment","18+ Content","Advertising","Exploiting",
    "Scamming","Racism","Threats","Username",
    "Game Content","Impersonation","Child Safety","Bot Account","Toxicity"
}

local TEXTS = {
    ["Harassment"] = {
        "I was repeatedly targeted with persistent harassment including toxic language, insults, and disrespectful comments directed specifically at me during gameplay sessions. This player's behavior clearly violates Roblox community standards and creates a significantly negative environment that affects other players' enjoyment of the game. The harassment continued even after I requested them to stop, demonstrating intentional disregard for community guidelines.",
        "I am a victim of ongoing systematic harassment from another player. They used offensive language and personal insults directed at me specifically, attempting to provoke confrontation and make me uncomfortable in the game environment. Multiple witnesses were present during these incidents and can confirm the repeated nature of this behavior.",
        "A player engaged in a coordinated harassment campaign against me including persistent name-calling, derogatory remarks, and public humiliation attempts. This constitutes clear bullying behavior that significantly disrupts normal gameplay experience for me and observers. The targeting was clearly intentional and persistent over multiple game sessions.",
        "I was harassed by a player with constant insults and toxic behavior throughout multiple consecutive game sessions. When I requested them to stop engaging in this behavior, the harassment continued unabated and even intensified. This is a clear and serious violation of Roblox community guidelines and creates an unsafe gaming environment."
    },
    ["18+ Content"] = {
        "A player created and distributed inappropriate 18+ sexual content within the game environment. Sexual dialogue, explicit material, and adult-themed messaging are clearly present which directly violates Roblox community standards for an all-ages platform. The content is deliberately designed to be inappropriate and has made other players visibly uncomfortable.",
        "A player repeatedly engaged in explicit sexual roleplay and posted adult content throughout the public game chat and communication channels. This explicitly violates platform policy regarding mature content that has absolutely no place on a family-friendly game where minors are present.",
        "I witnessed inappropriate and explicit sexual behavior including graphic language and adult roleplay scenarios from another player directed at multiple people. Multiple players witnessed this conduct and reported feeling uncomfortable and distressed. Immediate action is required as this is a serious violation of content policies.",
        "A player repeatedly spammed 18+ content and explicit sexual messages throughout the public chat system. They actively attempted to engage other players in adult conversations and continued despite being ignored and asked to stop. This is a clear and serious policy violation affecting the entire player base.",
        "A player actively promoted adult content with direct links and references to inappropriate material that is completely unsuitable for the platform. This directly violates Roblox Terms of Service regarding sexual content that is completely inappropriate on a youth-oriented platform."
    },
    ["Advertising"] = {
        "A player repeatedly spammed advertisements and promotional messages in the game chat system. They posted multiple external links and promotional content in direct violation of platform rules and continued doing so even after being asked to stop. This behavior significantly disrupted the normal game experience for everyone playing.",
        "I observed a player continuously advertising external Discord servers, YouTube channels, streaming platforms, and other promotional links throughout the game chat. This is prohibited advertising behavior that clearly violates Roblox platform policies and creates spam.",
        "There was significant and disruptive spam flooding in the game chat with repetitive messages, multiple external links, and promotional content that severely disrupted normal gameplay. The same player posted these identical messages numerous times, demonstrating clearly intentional spam behavior.",
        "A player engaged in persistent and aggressive spam advertising including game recommendations, Discord server invites, external links, and various promotional content throughout their gaming session. This behavior clearly violates anti-spam policy and makes the game unenjoyable.",
        "I observed a player repeatedly advertise and spam the same promotional content and external links multiple times within a short timeframe. This creates clear and significant disruption to the game environment and chat quality for all players trying to enjoy the game."
    },
    ["Exploiting"] = {
        "I observed another player utilizing an exploit or hack that clearly grants them unfair gameplay advantage over legitimate players. I directly witnessed them flying through the air, using speed hacks to move unnaturally fast, and becoming invisible in a game where none of these abilities exist normally or legitimately. This breaches game integrity completely.",
        "A player was actively using a game exploit or vulnerability that I could clearly observe and document. They were walking through solid walls, having infinite health that never decreases, and teleporting around the map instantly. This unfair advantage was confirmed by multiple other players in the game.",
        "I detected clear and obvious exploitation from another player using unfair methods. They were using external tools or scripts to gain an unfair advantage in the game. This behavior is ruining the experience for all legitimate players and severely affects competitive fairness.",
        "I confirmed a player using exploits with impossible abilities that absolutely should not exist in normal gameplay. They were generating infinite money and items from nothing, clearly demonstrating a serious code violation that breaks the game balance.",
        "A player was utilizing a paid exploit menu or mod tool to gain unfair advantages. I observed wallhacking and speedhacking which was clearly affecting other players' gameplay experience negatively and creating unfair competition that ruins the game."
    },
    ["Scamming"] = {
        "I was scammed by a player in a game trade interaction. They promised certain valuable items in exchange for my items but completely failed to deliver on their promise. This is fraudulent behavior that directly violates the game's trading guidelines and took advantage of my trust.",
        "A player conducted a clear and intentional scam operation targeting me. They took my valuable items and in-game currency with false promises of return that never happened. Multiple other players have reported being scammed by the same person using the same deceptive methods.",
        "I am a victim of a scam from another player who was deliberately fraudulent. They promised to provide specific services or items but completely failed to deliver as promised, leaving me worse off. I lost significant in-game currency due to this deliberate scam.",
        "A player is running an ongoing scam scheme actively targeting multiple players. They make false promises to players in exchange for items and currency, taking what they want without delivering. Multiple reports from other players confirm this is an ongoing pattern of fraudulent activity.",
        "I was scammed by a player who engaged in item and currency fraud deliberately. They took my items claiming they would be doubled or returned, but kept everything and ghosted me. This is clear scamming behavior and intentional theft of player items."
    },
    ["Racism"] = {
        "A player used racist slurs and discriminatory language toward other players in the game. They engaged in hate speech that was directed at players based on race and ethnicity. This behavior is completely unacceptable and violates community standards.",
        "I observed a player engaged in discriminatory behavior and hate speech. They made racist comments and hateful language directed at multiple players creating a hostile environment. Multiple witnesses were present and can confirm this behavior.",
        "A player directed racism at other players in a clearly intentional way. They used racial slurs and discriminatory statements about race and nationality. This violates anti-discrimination policy and creates an unsafe environment for targeted players.",
        "I witnessed a player make discriminatory comments based on religion and ethnicity. They used hateful language that violates community standards for a respectful and inclusive environment.",
        "A player actively promoted discriminatory ideology through racist remarks and hate speech. This directly violates platform policy on equality and respect for all players of any background."
    },
    ["Threats"] = {
        "A player made serious threatening statements toward me in the game. They made death threats and used intimidation tactics attempting to scare me and coerce my behavior. These are direct threats that create genuine fear and concern.",
        "I reported another player who threatened me with doxxing and real-world physical harm. This is serious threatening behavior that requires immediate action and investigation by the safety team.",
        "A player engaged in targeted intimidation directed at me. They made threatening statements about hacking my account and falsely reporting me to coerce compliance with their demands.",
        "I received violent threats from a player including specific threats of harm. This constitutes serious threatening behavior that is a clear policy violation and creates genuine safety concerns.",
        "A player threatened to file false reports against me, hack my account, and cause real-world harm to me personally. These are intimidation tactics creating an unsafe environment and require investigation."
    },
    ["Username"] = {
        "A player has an inappropriate username containing offensive language and slurs. This violates username policy requirements that are necessary for maintaining a respectful community environment for all players.",
        "The username I observed contains explicit adult content that is inappropriate and unsuitable for this platform. This represents a clear breach of username policy as it contains adult references and offensive slurs.",
        "A player's username contains hate speech and slurs. This directly violates Roblox naming standards and community conduct requirements that prohibit discriminatory and hateful usernames.",
        "I found a username that includes sexual and adult content that is completely inappropriate for a family-friendly platform. This breaches username conduct policy significantly.",
        "A player's username contains offensive language and slurs that creates a hostile environment. This violates community standards for username selection and appropriateness."
    },
    ["Game Content"] = {
        "This game contains inappropriate 18+ sexual content throughout the game. Explicit dialogue, animations, and digital assets are present that violate platform content policy for what should be an all-ages game. The sexual content is clear and intentional.",
        "This game features adult content including repeated sexual references and mature material that is unsuitable for the Roblox platform. It violates content guidelines that protect younger players.",
        "This game includes hate speech and offensive content throughout. Racial slurs and discriminatory material are present in game mechanics and dialogue. This is a clear policy violation.",
        "This game contains excessive violence and gore that is inappropriate for platform standards. The graphic content violates age-appropriate content guidelines and is disturbing.",
        "This game is designed to promote adult behavior and sexual roleplay. The content and game mechanics explicitly violate Roblox community standards for appropriate game experiences."
    },
    ["Impersonation"] = {
        "Another player is impersonating me or another legitimate player. Their username and avatar are designed to look identical to the real account, causing confusion and enabling fraud through deception.",
        "A player is impersonating a game developer or staff member. They make false claims of authority which cause confusion among other players. This violates impersonation policy and enables deception.",
        "A player created an account impersonating a legitimate account to scam and deceive other players. The fake account is designed to look nearly identical to the real account and has fooled multiple people.",
        "A player is pretending to be my friend or a content creator to deceive other players. They are deceiving players for personal gain through this false identity. This is a clear impersonation violation.",
        "I observed a clear impersonation attempt where a player mimicked a verified account appearance to conduct fraud. Multiple players were deceived by this false identity."
    },
    ["Child Safety"] = {
        "A player exhibited behavior that is deeply concerning regarding child safety. They made inappropriate comments directed toward younger players in the game which raises serious safety concerns.",
        "I observed a player engaged in grooming behavior toward younger players. They attempted to manipulate children into private conversations for inappropriate purposes. This is predatory behavior.",
        "I am reporting a critical child safety concern: A player made solicitations toward minors that are inappropriate and concerning. This is a clear policy violation requiring immediate investigation by the safety team.",
        "I witnessed predatory behavior from a player who was targeting younger players. They made inappropriate proposals and requests that caused visible discomfort to the minors. This requires urgent attention.",
        "A player attempted to contact younger players for inappropriate offline communication. This is a major safety concern requiring immediate action to protect minors on the platform."
    },
    ["Bot Account"] = {
        "I identified another account that appears to be a bot or fake account. The automated behavior and spam patterns are obvious and suspicious. This account does not appear to be a legitimate player.",
        "An account is displaying clear bot characteristics including highly repetitive behavior and suspicious activity patterns. The account appears to be completely automated and not controlled by a real person.",
        "I observed a suspicious account exhibiting bot-like behavior. Automated responses and unnatural gameplay patterns strongly suggest this is a fake account.",
        "I confirmed an account is likely a bot. It shows zero legitimate gameplay interaction and only engages in repetitive spam and advertising behavior.",
        "An account has been confirmed as a bot account. It displays automated advertising and spam patterns with a suspicious activity timeline. This is not a genuine player account."
    },
    ["Toxicity"] = {
        "I observed a player exhibiting toxic and rude behavior toward multiple other players. They used aggressive language and made disrespectful comments throughout their entire gameplay session.",
        "A player displayed extremely toxic behavior in the game chat. They made rude comments, complained excessively, and created a negative atmosphere affecting everyone.",
        "I witnessed toxicity from a player who made rude remarks to other players, complained constantly, and created a very negative game atmosphere.",
        "A player displayed rudeness and a generally toxic attitude. They gave aggressive responses and treated other players with disrespect.",
        "A player exhibited toxic behavior including rude language and disrespectful treatment of other players. This creates a negative community experience for all."
    },
}

-- ===== HELPERS =====
local function corner(p, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 10)
    c.Parent = p
end

local function stroke(p, th, tr)
    local s = Instance.new("UIStroke")
    s.Color = T.Border
    s.Thickness = th or 1.5
    s.Transparency = tr or 0.25
    s.Parent = p
end

local function tween(obj, props, t)
    TweenService:Create(obj, TweenInfo.new(t or 0.12, Enum.EasingStyle.Quint), props):Play()
end

-- ===== BUILD =====
local function build()
    local old = PlayerGui:FindFirstChild("RepTextUI")
    if old then old:Destroy() end

    -- Dimensi panel (mobile-friendly, sedikit lebih besar dari v2)
    local PW = 268   -- panel width
    local PH = 340   -- panel height (full)
    local TH = 36    -- titlebar height
    local CH = 42    -- category bar height
    local CONTENT_H = PH - TH  -- 304px untuk area bawah titlebar

    -- ScreenGui
    local sg = Instance.new("ScreenGui")
    sg.Name = "RepTextUI"
    sg.ResetOnSpawn = false
    sg.DisplayOrder = 999
    sg.IgnoreGuiInset = true
    sg.Parent = PlayerGui

    -- Main frame — dikunci di tengah
    local mf = Instance.new("Frame")
    mf.Name = "Main"
    mf.AnchorPoint = Vector2.new(0.5, 0.5)
    mf.Size = UDim2.fromOffset(PW, PH)
    mf.Position = UDim2.new(0.5, 0, -0.8, 0)  -- start dari atas, lalu tween masuk
    mf.BackgroundColor3 = T.BG
    mf.BorderSizePixel = 0
    mf.Parent = sg
    corner(mf, 14)
    stroke(mf, 1.5, 0.2)

    -- ===== TITLEBAR =====
    local tb = Instance.new("Frame")
    tb.Size = UDim2.new(1, 0, 0, TH)
    tb.BackgroundColor3 = T.Dark
    tb.BorderSizePixel = 0
    tb.ZIndex = 5
    tb.Parent = mf
    corner(tb, 14)

    -- Tutup bagian bawah rounded titlebar
    local tbFix = Instance.new("Frame")
    tbFix.Size = UDim2.new(1, 0, 0, 14)
    tbFix.Position = UDim2.new(0, 0, 1, -14)
    tbFix.BackgroundColor3 = T.Dark
    tbFix.BorderSizePixel = 0
    tbFix.ZIndex = 4
    tbFix.Parent = tb

    -- Garis pemisah
    local sep = Instance.new("Frame")
    sep.Size = UDim2.new(1, 0, 0, 1)
    sep.Position = UDim2.new(0, 0, 1, -1)
    sep.BackgroundColor3 = T.Border
    sep.BackgroundTransparency = 0.6
    sep.BorderSizePixel = 0
    sep.ZIndex = 6
    sep.Parent = tb

    -- Title label
    local tl = Instance.new("TextLabel")
    tl.Size = UDim2.new(1, -72, 1, 0)
    tl.Position = UDim2.new(0, 12, 0, 0)
    tl.BackgroundTransparency = 1
    tl.TextColor3 = T.Text
    tl.TextSize = 12
    tl.Font = Enum.Font.GothamBold
    tl.Text = "Anonymous9x  RepText"
    tl.TextXAlignment = Enum.TextXAlignment.Left
    tl.ZIndex = 6
    tl.Parent = tb

    -- Header buttons (Minimize + Close saja)
    local function makeBtn(icon, xOff)
        local b = Instance.new("TextButton")
        b.Size = UDim2.fromOffset(24, 24)
        b.Position = UDim2.new(1, xOff, 0.5, -12)
        b.BackgroundColor3 = T.Btn
        b.BorderSizePixel = 0
        b.TextColor3 = T.Text
        b.TextSize = 15
        b.Font = Enum.Font.GothamBold
        b.Text = icon
        b.ZIndex = 7
        b.Parent = tb
        corner(b, 6)
        stroke(b, 1, 0.55)
        b.MouseEnter:Connect(function() tween(b, {BackgroundColor3 = T.Hover}) end)
        b.MouseLeave:Connect(function() tween(b, {BackgroundColor3 = T.Btn}) end)
        return b
    end

    local minBtn   = makeBtn("−", -56)
    local closeBtn = makeBtn("×", -28)

    -- ===== CONTENT WRAPPER =====
    local cw = Instance.new("Frame")
    cw.Name = "ContentWrap"
    cw.Size = UDim2.new(1, 0, 0, CONTENT_H)
    cw.Position = UDim2.new(0, 0, 0, TH)
    cw.BackgroundTransparency = 1
    cw.ClipsDescendants = true
    cw.Parent = mf

    -- ===== CATEGORY BAR (fixed height 42px) =====
    local catBar = Instance.new("ScrollingFrame")
    catBar.Name = "CatBar"
    catBar.Size = UDim2.new(1, 0, 0, CH)
    catBar.Position = UDim2.new(0, 0, 0, 0)
    catBar.BackgroundColor3 = T.Dark
    catBar.BorderSizePixel = 0
    catBar.ScrollBarThickness = 0
    catBar.ScrollingDirection = Enum.ScrollingDirection.X
    catBar.CanvasSize = UDim2.new(0, 800, 0, CH)  -- canvas lebar, di-update nanti
    catBar.ZIndex = 3
    catBar.Parent = cw

    -- Garis bawah category bar
    local catSep = Instance.new("Frame")
    catSep.Size = UDim2.new(1, 0, 0, 1)
    catSep.Position = UDim2.new(0, 0, 1, -1)
    catSep.BackgroundColor3 = T.Border
    catSep.BackgroundTransparency = 0.6
    catSep.BorderSizePixel = 0
    catSep.ZIndex = 4
    catSep.Parent = catBar

    local catLL = Instance.new("UIListLayout")
    catLL.FillDirection = Enum.FillDirection.Horizontal
    catLL.Padding = UDim.new(0, 4)
    catLL.SortOrder = Enum.SortOrder.LayoutOrder
    catLL.VerticalAlignment = Enum.VerticalAlignment.Center
    catLL.Parent = catBar

    local catPad = Instance.new("UIPadding")
    catPad.PaddingLeft  = UDim.new(0, 6)
    catPad.PaddingRight = UDim.new(0, 6)
    catPad.Parent = catBar

    -- ===== TEXT SCROLL (area isi, di bawah category bar) =====
    local SCROLL_H = CONTENT_H - CH  -- 262px
    local ts = Instance.new("ScrollingFrame")
    ts.Name = "TextScroll"
    ts.Size = UDim2.new(1, 0, 0, SCROLL_H)
    ts.Position = UDim2.new(0, 0, 0, CH)
    ts.BackgroundColor3 = T.BG
    ts.BorderSizePixel = 0
    ts.ScrollBarThickness = 3
    ts.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80)
    ts.CanvasSize = UDim2.new(0, 0, 0, 0)
    ts.Parent = cw

    local tsLL = Instance.new("UIListLayout")
    tsLL.FillDirection = Enum.FillDirection.Vertical
    tsLL.Padding = UDim.new(0, 6)
    tsLL.SortOrder = Enum.SortOrder.LayoutOrder
    tsLL.Parent = ts

    local tsPad = Instance.new("UIPadding")
    tsPad.PaddingLeft   = UDim.new(0, 7)
    tsPad.PaddingRight  = UDim.new(0, 7)
    tsPad.PaddingTop    = UDim.new(0, 7)
    tsPad.PaddingBottom = UDim.new(0, 7)
    tsPad.Parent = ts

    -- Placeholder
    local ph = Instance.new("TextLabel")
    ph.Name = "Placeholder"
    ph.Size = UDim2.new(1, 0, 0, 60)
    ph.BackgroundTransparency = 1
    ph.TextColor3 = Color3.fromRGB(75, 75, 75)
    ph.TextSize = 11
    ph.Font = Enum.Font.Gotham
    ph.Text = "Pilih kategori di atas"
    ph.TextXAlignment = Enum.TextXAlignment.Center
    ph.TextYAlignment = Enum.TextYAlignment.Center
    ph.LayoutOrder = 0
    ph.Parent = ts

    -- ===== STATE =====
    local isMinimized = false
    local selectedCat = nil
    local catBtns = {}

    -- Update canvas size textscroll berdasarkan konten
    local function updateCanvas()
        task.wait()
        ts.CanvasSize = UDim2.new(0, 0, 0, tsLL.AbsoluteContentSize.Y + 14)
    end

    -- ===== LOAD TEXTS =====
    local CARD_H = 118  -- tinggi kartu fixed, cukup untuk teks panjang

    local function loadCategory(catName)
        -- Reset semua tombol kategori
        for n, b in pairs(catBtns) do
            b.BackgroundColor3 = T.Dark
            b.BackgroundTransparency = 0
            b.TextColor3 = T.Sub
        end
        catBtns[catName].BackgroundColor3 = T.Btn
        catBtns[catName].TextColor3 = T.Text
        selectedCat = catName

        -- Hapus kartu lama
        for _, c in ipairs(ts:GetChildren()) do
            if c:IsA("Frame") then c:Destroy() end
        end
        ph.Visible = false

        local list = TEXTS[catName]
        if not list then return end

        for i, txt in ipairs(list) do
            -- Card frame
            local card = Instance.new("Frame")
            card.Name = "Card"..i
            card.Size = UDim2.new(1, 0, 0, CARD_H)
            card.BackgroundColor3 = T.Card
            card.BorderSizePixel = 0
            card.LayoutOrder = i
            card.Parent = ts
            corner(card, 8)
            stroke(card, 1, 0.7)

            -- Nomor pojok kanan atas
            local num = Instance.new("TextLabel")
            num.Size = UDim2.fromOffset(16, 14)
            num.Position = UDim2.new(1, -20, 0, 5)
            num.BackgroundTransparency = 1
            num.TextColor3 = Color3.fromRGB(65, 65, 65)
            num.TextSize = 9
            num.Font = Enum.Font.GothamBold
            num.Text = tostring(i)
            num.ZIndex = 2
            num.Parent = card

            -- Teks isi (area: dari atas sampai 30px sebelum bawah)
            local tLabel = Instance.new("TextLabel")
            tLabel.Size = UDim2.new(1, -14, 0, CARD_H - 32)
            tLabel.Position = UDim2.new(0, 7, 0, 5)
            tLabel.BackgroundTransparency = 1
            tLabel.TextColor3 = T.Sub
            tLabel.TextSize = 9
            tLabel.Font = Enum.Font.Gotham
            tLabel.Text = txt
            tLabel.TextWrapped = true
            tLabel.TextXAlignment = Enum.TextXAlignment.Left
            tLabel.TextYAlignment = Enum.TextYAlignment.Top
            tLabel.ZIndex = 2
            tLabel.Parent = card

            -- Copy button (bawah kartu)
            local cp = Instance.new("TextButton")
            cp.Size = UDim2.new(1, -14, 0, 22)
            cp.Position = UDim2.new(0, 7, 1, -26)
            cp.BackgroundColor3 = T.Btn
            cp.BorderSizePixel = 0
            cp.TextColor3 = T.Text
            cp.TextSize = 10
            cp.Font = Enum.Font.GothamBold
            cp.Text = "COPY"
            cp.ZIndex = 3
            cp.Parent = card
            corner(cp, 5)
            stroke(cp, 1, 0.6)

            cp.MouseEnter:Connect(function() tween(cp, {BackgroundColor3 = T.Copy}) end)
            cp.MouseLeave:Connect(function()
                if cp.Text == "COPY" then tween(cp, {BackgroundColor3 = T.Btn}) end
            end)
            cp.MouseButton1Click:Connect(function()
                pcall(function()
                    setclipboard(txt)
                    local prev = cp.BackgroundColor3
                    cp.Text = "✓  Copied!"
                    cp.BackgroundColor3 = T.Copy
                    task.wait(1.5)
                    cp.Text = "COPY"
                    tween(cp, {BackgroundColor3 = T.Btn})
                end)
            end)
        end

        updateCanvas()
        ts.CanvasPosition = Vector2.new(0, 0)
    end

    -- ===== BUAT TOMBOL KATEGORI =====
    local totalCatW = 6  -- kiri padding
    for idx, catName in ipairs(CATEGORIES) do
        if TEXTS[catName] then
            -- Estimasi lebar tombol dari panjang nama
            local btnW = math.max(48, #catName * 6 + 16)

            local btn = Instance.new("TextButton")
            btn.Name = catName
            btn.Size = UDim2.fromOffset(btnW, 28)
            btn.BackgroundColor3 = T.Dark
            btn.BorderSizePixel = 0
            btn.TextColor3 = T.Sub
            btn.TextSize = 10
            btn.Font = Enum.Font.GothamBold
            btn.Text = catName
            btn.LayoutOrder = idx
            btn.ZIndex = 4
            btn.Parent = catBar
            corner(btn, 6)

            btn.MouseEnter:Connect(function()
                if selectedCat ~= catName then
                    tween(btn, {TextColor3 = T.Text})
                end
            end)
            btn.MouseLeave:Connect(function()
                if selectedCat ~= catName then
                    tween(btn, {TextColor3 = T.Sub})
                end
            end)
            btn.MouseButton1Click:Connect(function()
                loadCategory(catName)
            end)

            catBtns[catName] = btn
            totalCatW = totalCatW + btnW + 4
        end
    end

    -- Set canvas lebar category scroll sesuai total tombol
    catBar.CanvasSize = UDim2.new(0, totalCatW + 12, 0, CH)

    -- ===== MOBILE SWIPE kategori =====
    local swX = 0
    catBar.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.Touch then swX = inp.Position.X end
    end)
    catBar.InputChanged:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.Touch then
            local d = swX - inp.Position.X
            if math.abs(d) > 1 then
                catBar.CanvasPosition = catBar.CanvasPosition + Vector2.new(d * 0.65, 0)
                swX = inp.Position.X
            end
        end
    end)

    -- ===== MINIMIZE =====
    minBtn.MouseButton1Click:Connect(function()
        if not isMinimized then
            isMinimized = true
            cw.Visible = false
            tween(mf, {Size = UDim2.fromOffset(PW, TH)}, 0.2)
            minBtn.Text = "+"
        else
            isMinimized = false
            tween(mf, {Size = UDim2.fromOffset(PW, PH)}, 0.2)
            task.wait(0.15)
            cw.Visible = true
            minBtn.Text = "−"
        end
    end)

    -- ===== CLOSE =====
    closeBtn.MouseButton1Click:Connect(function()
        tween(mf, {Position = UDim2.new(0.5, 0, -0.8, 0)}, 0.25)
        task.wait(0.28)
        pcall(function() sg:Destroy() end)
    end)

    -- ===== ENTRY ANIMATION =====
    tween(mf, {Position = UDim2.fromScale(0.5, 0.5)}, 0.4)

    print("Anonymous9x RepText v4.0 loaded!")
end

-- Run
local ok, err = pcall(build)
if not ok then warn("RepText Error: "..tostring(err)) end
