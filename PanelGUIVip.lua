-- Anonymous9x RepText UI v3.0
-- Center Locked | Scrollable | Mobile + PC | No Help Button | Modern B&W Theme

local TweenService = game:GetService("TweenService")

local UI_CONFIG = {
    Name = "Anonymous9x RepText",
    Version = "3.0",
    Theme = {
        Background   = Color3.fromRGB(12, 12, 12),
        Dark         = Color3.fromRGB(18, 18, 18),
        Card         = Color3.fromRGB(22, 22, 22),
        Border       = Color3.fromRGB(235, 235, 235),
        Text         = Color3.fromRGB(245, 245, 245),
        TextSub      = Color3.fromRGB(190, 190, 190),
        Hover        = Color3.fromRGB(38, 38, 38),
        Accent       = Color3.fromRGB(40, 40, 40),
        CopyActive   = Color3.fromRGB(55, 55, 55),
    }
}

-- ===== REPORT TEXTS DATA =====
local REPORT_TEXTS = {
    ["Harassment"] = {
        title = "Harassment",
        texts = {
            "I was repeatedly targeted with persistent harassment including toxic language, insults, and disrespectful comments directed specifically at me during gameplay sessions. This player's behavior clearly violates Roblox community standards and creates a significantly negative environment that affects other players' enjoyment of the game. The harassment continued even after I requested them to stop, demonstrating intentional disregard for community guidelines.",
            "I am a victim of ongoing systematic harassment from another player. They used offensive language and personal insults directed at me specifically, attempting to provoke confrontation and make me uncomfortable in the game environment. Multiple witnesses were present during these incidents and can confirm the repeated nature of this behavior.",
            "A player engaged in a coordinated harassment campaign against me including persistent name-calling, derogatory remarks, and public humiliation attempts. This constitutes clear bullying behavior that significantly disrupts normal gameplay experience for me and observers. The targeting was clearly intentional and persistent over multiple game sessions.",
            "I was harassed by a player with constant insults and toxic behavior throughout multiple consecutive game sessions. When I requested them to stop engaging in this behavior, the harassment continued unabated and even intensified. This is a clear and serious violation of Roblox community guidelines and creates an unsafe gaming environment."
        }
    },
    ["18+ Content"] = {
        title = "18+ Content",
        texts = {
            "A player created and distributed inappropriate 18+ sexual content within the game environment. Sexual dialogue, explicit material, and adult-themed messaging are clearly present which directly violates Roblox community standards for an all-ages platform. The content is deliberately designed to be inappropriate and has made other players visibly uncomfortable.",
            "A player repeatedly engaged in explicit sexual roleplay and posted adult content throughout the public game chat and communication channels. This explicitly violates platform policy regarding mature content that has absolutely no place on a family-friendly game where minors are present.",
            "I witnessed inappropriate and explicit sexual behavior including graphic language and adult roleplay scenarios from another player directed at multiple people. Multiple players witnessed this conduct and reported feeling uncomfortable and distressed. Immediate action is required as this is a serious violation of content policies.",
            "A player repeatedly spammed 18+ content and explicit sexual messages throughout the public chat system. They actively attempted to engage other players in adult conversations and continued despite being ignored and asked to stop. This is a clear and serious policy violation affecting the entire player base.",
            "A player actively promoted adult content with direct links and references to inappropriate material that is completely unsuitable for the platform. This directly violates Roblox Terms of Service regarding sexual content that is completely inappropriate on a youth-oriented platform."
        }
    },
    ["Advertising"] = {
        title = "Advertising",
        texts = {
            "A player repeatedly spammed advertisements and promotional messages in the game chat system. They posted multiple external links and promotional content in direct violation of platform rules and continued doing so even after being asked to stop. This behavior significantly disrupted the normal game experience for everyone playing.",
            "I observed a player continuously advertising external Discord servers, YouTube channels, streaming platforms, and other promotional links throughout the game chat. This is prohibited advertising behavior that clearly violates Roblox platform policies and creates spam.",
            "There was significant and disruptive spam flooding in the game chat with repetitive messages, multiple external links, and promotional content that severely disrupted normal gameplay. The same player posted these identical messages numerous times, demonstrating clearly intentional spam behavior.",
            "A player engaged in persistent and aggressive spam advertising including game recommendations, Discord server invites, external links, and various promotional content throughout their gaming session. This behavior clearly violates anti-spam policy and makes the game unenjoyable.",
            "I observed a player repeatedly advertise and spam the same promotional content and external links multiple times within a short timeframe. This creates clear and significant disruption to the game environment and chat quality for all players trying to enjoy the game."
        }
    },
    ["Exploiting"] = {
        title = "Exploiting",
        texts = {
            "I observed another player utilizing an exploit or hack that clearly grants them unfair gameplay advantage over legitimate players. I directly witnessed them flying through the air, using speed hacks to move unnaturally fast, and becoming invisible in a game where none of these abilities exist normally or legitimately. This breaches game integrity completely.",
            "A player was actively using a game exploit or vulnerability that I could clearly observe and document. They were walking through solid walls, having infinite health that never decreases, and teleporting around the map instantly. This unfair advantage was confirmed by multiple other players in the game.",
            "I detected clear and obvious exploitation from another player using unfair methods. They were using external tools or scripts to gain an unfair advantage in the game. This behavior is ruining the experience for all legitimate players and severely affects competitive fairness.",
            "I confirmed a player using exploits with impossible abilities that absolutely should not exist in normal gameplay. They were generating infinite money and items from nothing, clearly demonstrating a serious code violation that breaks the game balance.",
            "A player was utilizing a paid exploit menu or mod tool to gain unfair advantages. I observed wallhacking and speedhacking which was clearly affecting other players' gameplay experience negatively and creating unfair competition that ruins the game."
        }
    },
    ["Scamming"] = {
        title = "Scamming",
        texts = {
            "I was scammed by a player in a game trade interaction. They promised certain valuable items in exchange for my items but completely failed to deliver on their promise. This is fraudulent behavior that directly violates the game's trading guidelines and took advantage of my trust.",
            "A player conducted a clear and intentional scam operation targeting me. They took my valuable items and in-game currency with false promises of return that never happened. Multiple other players have reported being scammed by the same person using the same deceptive methods.",
            "I am a victim of a scam from another player who was deliberately fraudulent. They promised to provide specific services or items but completely failed to deliver as promised, leaving me worse off. I lost significant in-game currency due to this deliberate scam.",
            "A player is running an ongoing scam scheme actively targeting multiple players. They make false promises to players in exchange for items and currency, taking what they want without delivering. Multiple reports from other players confirm this is an ongoing pattern of fraudulent activity.",
            "I was scammed by a player who engaged in item and currency fraud deliberately. They took my items claiming they would be doubled or returned, but kept everything and ghosted me. This is clear scamming behavior and intentional theft of player items."
        }
    },
    ["Racism"] = {
        title = "Racism",
        texts = {
            "A player used racist slurs and discriminatory language toward other players in the game. They engaged in hate speech that was directed at players based on race and ethnicity. This behavior is completely unacceptable and violates community standards.",
            "I observed a player engaged in discriminatory behavior and hate speech. They made racist comments and hateful language directed at multiple players creating a hostile environment. Multiple witnesses were present and can confirm this behavior.",
            "A player directed racism at other players in a clearly intentional way. They used racial slurs and discriminatory statements about race and nationality. This violates anti-discrimination policy and creates an unsafe environment for targeted players.",
            "I witnessed a player make discriminatory comments based on religion and ethnicity. They used hateful language that violates community standards for a respectful and inclusive environment.",
            "A player actively promoted discriminatory ideology through racist remarks and hate speech. This directly violates platform policy on equality and respect for all players of any background."
        }
    },
    ["Threats"] = {
        title = "Threats",
        texts = {
            "A player made serious threatening statements toward me in the game. They made death threats and used intimidation tactics attempting to scare me and coerce my behavior. These are direct threats that create genuine fear and concern.",
            "I reported another player who threatened me with doxxing and real-world physical harm. This is serious threatening behavior that requires immediate action and investigation by the safety team.",
            "A player engaged in targeted intimidation directed at me. They made threatening statements about hacking my account and falsely reporting me to coerce compliance with their demands.",
            "I received violent threats from a player including specific threats of harm. This constitutes serious threatening behavior that is a clear policy violation and creates genuine safety concerns.",
            "A player threatened to file false reports against me, hack my account, and cause real-world harm to me personally. These are intimidation tactics creating an unsafe environment and require investigation."
        }
    },
    ["Username"] = {
        title = "Username",
        texts = {
            "A player has an inappropriate username containing offensive language and slurs. This violates username policy requirements that are necessary for maintaining a respectful community environment for all players.",
            "The username I observed contains explicit adult content that is inappropriate and unsuitable for this platform. This represents a clear breach of username policy as it contains adult references and offensive slurs.",
            "A player's username contains hate speech and slurs. This directly violates Roblox naming standards and community conduct requirements that prohibit discriminatory and hateful usernames.",
            "I found a username that includes sexual and adult content that is completely inappropriate for a family-friendly platform. This breaches username conduct policy significantly.",
            "A player's username contains offensive language and slurs that creates a hostile environment. This violates community standards for username selection and appropriateness."
        }
    },
    ["Game Content"] = {
        title = "Game Content",
        texts = {
            "This game contains inappropriate 18+ sexual content throughout the game. Explicit dialogue, animations, and digital assets are present that violate platform content policy for what should be an all-ages game. The sexual content is clear and intentional.",
            "This game features adult content including repeated sexual references and mature material that is unsuitable for the Roblox platform. It violates content guidelines that protect younger players.",
            "This game includes hate speech and offensive content throughout. Racial slurs and discriminatory material are present in game mechanics and dialogue. This is a clear policy violation.",
            "This game contains excessive violence and gore that is inappropriate for platform standards. The graphic content violates age-appropriate content guidelines and is disturbing.",
            "This game is designed to promote adult behavior and sexual roleplay. The content and game mechanics explicitly violate Roblox community standards for appropriate game experiences."
        }
    },
    ["Impersonation"] = {
        title = "Impersonation",
        texts = {
            "Another player is impersonating me or another legitimate player. Their username and avatar are designed to look identical to the real account, causing confusion and enabling fraud through deception.",
            "A player is impersonating a game developer or staff member. They make false claims of authority which cause confusion among other players. This violates impersonation policy and enables deception.",
            "A player created an account impersonating a legitimate account to scam and deceive other players. The fake account is designed to look nearly identical to the real account and has fooled multiple people.",
            "A player is pretending to be my friend or a content creator to deceive other players. They are deceiving players for personal gain through this false identity. This is a clear impersonation violation.",
            "I observed a clear impersonation attempt where a player mimicked a verified account appearance to conduct fraud. Multiple players were deceived by this false identity."
        }
    },
    ["Child Safety"] = {
        title = "Child Safety",
        texts = {
            "A player exhibited behavior that is deeply concerning regarding child safety. They made inappropriate comments directed toward younger players in the game which raises serious safety concerns.",
            "I observed a player engaged in grooming behavior toward younger players. They attempted to manipulate children into private conversations for inappropriate purposes. This is predatory behavior.",
            "I am reporting a critical child safety concern: A player made solicitations toward minors that are inappropriate and concerning. This is a clear policy violation requiring immediate investigation by the safety team.",
            "I witnessed predatory behavior from a player who was targeting younger players. They made inappropriate proposals and requests that caused visible discomfort to the minors. This requires urgent attention.",
            "A player attempted to contact younger players for inappropriate offline communication. This is a major safety concern requiring immediate action to protect minors on the platform."
        }
    },
    ["Bot Account"] = {
        title = "Bot Account",
        texts = {
            "I identified another account that appears to be a bot or fake account. The automated behavior and spam patterns are obvious and suspicious. This account does not appear to be a legitimate player.",
            "An account is displaying clear bot characteristics including highly repetitive behavior and suspicious activity patterns. The account appears to be completely automated and not controlled by a real person.",
            "I observed a suspicious account exhibiting bot-like behavior. Automated responses and unnatural gameplay patterns strongly suggest this is a fake account.",
            "I confirmed an account is likely a bot. It shows zero legitimate gameplay interaction and only engages in repetitive spam and advertising behavior.",
            "An account has been confirmed as a bot account. It displays automated advertising and spam patterns with a suspicious activity timeline. This is not a genuine player account."
        }
    },
    ["Toxicity"] = {
        title = "Toxicity",
        texts = {
            "I observed a player exhibiting toxic and rude behavior toward multiple other players. They used aggressive language and made disrespectful comments throughout their entire gameplay session.",
            "A player displayed extremely toxic behavior in the game chat. They made rude comments, complained excessively, and created a negative atmosphere affecting everyone.",
            "I witnessed toxicity from a player who made rude remarks to other players, complained constantly, and created a very negative game atmosphere.",
            "A player displayed rudeness and a generally toxic attitude. They gave aggressive responses and treated other players with disrespect.",
            "A player exhibited toxic behavior including rude language and disrespectful treatment of other players. This creates a negative community experience for all."
        }
    }
}

-- ===== HELPER: UIStroke (border gaya notif Adidas) =====
local function addStroke(parent, color, thickness, transparency)
    local s = Instance.new("UIStroke")
    s.Color = color or UI_CONFIG.Theme.Border
    s.Thickness = thickness or 1.5
    s.Transparency = transparency or 0.2
    s.Parent = parent
    return s
end

local function addCorner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 10)
    c.Parent = parent
    return c
end

-- ===== BUILD UI =====
local function createRepTextUI()
    -- Hapus instance lama kalau ada
    local PlayerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    local existing = PlayerGui:FindFirstChild("RepTextUI")
    if existing then existing:Destroy() end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "RepTextUI"
    screenGui.ResetOnSpawn = false
    screenGui.DisplayOrder = 999
    screenGui.IgnoreGuiInset = true
    screenGui.Parent = PlayerGui

    -- ===== MAIN FRAME =====
    -- Sedikit lebih besar dari versi lama (240x290 → 270x330), tetap mobile-friendly
    -- AnchorPoint center + Position center = terkunci di tengah layar
    local W, H = 270, 335
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    mainFrame.Size = UDim2.fromOffset(W, H)
    mainFrame.Position = UDim2.fromScale(0.5, 0.5)
    mainFrame.BackgroundColor3 = UI_CONFIG.Theme.Background
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    addCorner(mainFrame, 14)
    addStroke(mainFrame, UI_CONFIG.Theme.Border, 1.5, 0.2)

    -- ===== TITLE BAR =====
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 36)
    titleBar.BackgroundColor3 = UI_CONFIG.Theme.Dark
    titleBar.BorderSizePixel = 0
    titleBar.ZIndex = 10
    titleBar.Parent = mainFrame
    addCorner(titleBar, 14)

    -- Cover bottom rounded corners of titlebar (so it looks flat at bottom)
    local titleBarFill = Instance.new("Frame")
    titleBarFill.Size = UDim2.new(1, 0, 0.5, 0)
    titleBarFill.Position = UDim2.new(0, 0, 0.5, 0)
    titleBarFill.BackgroundColor3 = UI_CONFIG.Theme.Dark
    titleBarFill.BorderSizePixel = 0
    titleBarFill.ZIndex = 9
    titleBarFill.Parent = titleBar

    -- Divider garis tipis bawah titlebar
    local divider = Instance.new("Frame")
    divider.Size = UDim2.new(1, 0, 0, 1)
    divider.Position = UDim2.new(0, 0, 1, -1)
    divider.BackgroundColor3 = UI_CONFIG.Theme.Border
    divider.BackgroundTransparency = 0.65
    divider.BorderSizePixel = 0
    divider.ZIndex = 11
    divider.Parent = titleBar

    -- Title Text
    local titleText = Instance.new("TextLabel")
    titleText.Name = "TitleText"
    titleText.Size = UDim2.new(1, -70, 1, 0)
    titleText.Position = UDim2.new(0, 14, 0, 0)
    titleText.BackgroundTransparency = 1
    titleText.TextColor3 = UI_CONFIG.Theme.Text
    titleText.TextSize = 12
    titleText.Font = Enum.Font.GothamBold
    titleText.Text = "Anonymous9x  RepText"
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.ZIndex = 12
    titleText.Parent = titleBar

    -- Button container kanan (hanya Minimize + Close)
    local btnContainer = Instance.new("Frame")
    btnContainer.Size = UDim2.new(0, 58, 1, 0)
    btnContainer.Position = UDim2.new(1, -62, 0, 0)
    btnContainer.BackgroundTransparency = 1
    btnContainer.ZIndex = 12
    btnContainer.Parent = titleBar

    local function makeHeaderBtn(icon, xPos)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.fromOffset(24, 24)
        btn.Position = UDim2.new(0, xPos, 0.5, -12)
        btn.BackgroundColor3 = UI_CONFIG.Theme.Accent
        btn.BorderSizePixel = 0
        btn.TextColor3 = UI_CONFIG.Theme.Text
        btn.TextSize = 14
        btn.Font = Enum.Font.GothamBold
        btn.Text = icon
        btn.ZIndex = 13
        btn.Parent = btnContainer
        addCorner(btn, 6)
        addStroke(btn, UI_CONFIG.Theme.Border, 1, 0.5)

        btn.MouseEnter:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.12), {BackgroundColor3 = UI_CONFIG.Theme.Hover}):Play()
        end)
        btn.MouseLeave:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.12), {BackgroundColor3 = UI_CONFIG.Theme.Accent}):Play()
        end)
        return btn
    end

    local minimizeBtn = makeHeaderBtn("−", 2)
    local closeBtn    = makeHeaderBtn("×", 30)

    -- ===== CONTENT FRAME =====
    local contentFrame = Instance.new("Frame")
    contentFrame.Name = "ContentFrame"
    contentFrame.Size = UDim2.new(1, 0, 1, -37)
    contentFrame.Position = UDim2.new(0, 0, 0, 37)
    contentFrame.BackgroundTransparency = 1
    contentFrame.ClipsDescendants = true
    contentFrame.Parent = mainFrame

    -- ===== CATEGORY SCROLL (horizontal, di atas) =====
    local catScroll = Instance.new("ScrollingFrame")
    catScroll.Name = "CategoryScroll"
    catScroll.Size = UDim2.new(1, 0, 0, 40)
    catScroll.BackgroundColor3 = UI_CONFIG.Theme.Dark
    catScroll.BorderSizePixel = 0
    catScroll.ScrollBarThickness = 0         -- sembunyi, swipe manual
    catScroll.CanvasSize = UDim2.new(0, 0, 0, 40)
    catScroll.AutomaticCanvasSize = Enum.AutomaticSize.X
    catScroll.ScrollingDirection = Enum.ScrollingDirection.X
    catScroll.Parent = contentFrame
    pcall(function() catScroll.ScrollDirection = Enum.ScrollDirection.X end)

    -- Garis bawah category bar
    local catDivider = Instance.new("Frame")
    catDivider.Size = UDim2.new(1, 0, 0, 1)
    catDivider.Position = UDim2.new(0, 0, 1, -1)
    catDivider.BackgroundColor3 = UI_CONFIG.Theme.Border
    catDivider.BackgroundTransparency = 0.65
    catDivider.BorderSizePixel = 0
    catDivider.Parent = catScroll

    local catLayout = Instance.new("UIListLayout")
    catLayout.FillDirection = Enum.FillDirection.Horizontal
    catLayout.Padding = UDim.new(0, 5)
    catLayout.SortOrder = Enum.SortOrder.LayoutOrder
    catLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    catLayout.Parent = catScroll

    local catPad = Instance.new("UIPadding")
    catPad.PaddingLeft = UDim.new(0, 6)
    catPad.PaddingRight = UDim.new(0, 6)
    catPad.Parent = catScroll

    -- ===== TEXT SCROLL (vertical, isi teks) =====
    local textScroll = Instance.new("ScrollingFrame")
    textScroll.Name = "TextScroll"
    textScroll.Size = UDim2.new(1, 0, 1, -41)
    textScroll.Position = UDim2.new(0, 0, 0, 41)
    textScroll.BackgroundColor3 = UI_CONFIG.Theme.Background
    textScroll.BorderSizePixel = 0
    textScroll.ScrollBarThickness = 2
    textScroll.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
    textScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    textScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    textScroll.Parent = contentFrame

    local textLayout = Instance.new("UIListLayout")
    textLayout.FillDirection = Enum.FillDirection.Vertical
    textLayout.Padding = UDim.new(0, 6)
    textLayout.SortOrder = Enum.SortOrder.LayoutOrder
    textLayout.Parent = textScroll

    local textPad = Instance.new("UIPadding")
    textPad.PaddingLeft = UDim.new(0, 8)
    textPad.PaddingRight = UDim.new(0, 8)
    textPad.PaddingTop = UDim.new(0, 8)
    textPad.PaddingBottom = UDim.new(0, 8)
    textPad.Parent = textScroll

    -- Placeholder label sebelum kategori dipilih
    local placeholderLabel = Instance.new("TextLabel")
    placeholderLabel.Name = "Placeholder"
    placeholderLabel.Size = UDim2.new(1, 0, 0, 80)
    placeholderLabel.BackgroundTransparency = 1
    placeholderLabel.TextColor3 = Color3.fromRGB(90, 90, 90)
    placeholderLabel.TextSize = 11
    placeholderLabel.Font = Enum.Font.Gotham
    placeholderLabel.Text = "← Pilih kategori di atas"
    placeholderLabel.TextXAlignment = Enum.TextXAlignment.Center
    placeholderLabel.TextYAlignment = Enum.TextYAlignment.Center
    placeholderLabel.LayoutOrder = 0
    placeholderLabel.Parent = textScroll

    -- ===== STATE =====
    local isMinimized = false
    local selectedCat = nil
    local fullH = H   -- tinggi penuh saat expanded
    local catButtons = {}

    -- ===== CATEGORY BUTTON FACTORY =====
    local catOrder = {
        "Harassment","18+ Content","Advertising","Exploiting",
        "Scamming","Racism","Threats","Username",
        "Game Content","Impersonation","Child Safety","Bot Account","Toxicity"
    }

    local function selectCategory(catName)
        -- Reset highlight semua button
        for name, btn in pairs(catButtons) do
            if name == catName then
                btn.BackgroundColor3 = UI_CONFIG.Theme.Accent
                btn.TextColor3 = UI_CONFIG.Theme.Text
            else
                btn.BackgroundColor3 = Color3.fromRGB(0,0,0,0) -- transparan
                btn.BackgroundTransparency = 1
                btn.TextColor3 = UI_CONFIG.Theme.TextSub
            end
        end

        selectedCat = catName

        -- Hapus kartu lama
        for _, child in ipairs(textScroll:GetChildren()) do
            if child:IsA("Frame") then child:Destroy() end
        end
        if placeholderLabel then placeholderLabel.Visible = false end

        local data = REPORT_TEXTS[catName]
        if not data then return end

        for i, txt in ipairs(data.texts) do
            -- Card
            local card = Instance.new("Frame")
            card.Name = "Card_"..i
            card.Size = UDim2.new(1, 0, 0, 0)         -- height auto
            card.AutomaticSize = Enum.AutomaticSize.Y
            card.BackgroundColor3 = UI_CONFIG.Theme.Card
            card.BorderSizePixel = 0
            card.LayoutOrder = i
            card.Parent = textScroll
            addCorner(card, 8)
            addStroke(card, UI_CONFIG.Theme.Border, 1, 0.72)

            local cardPad = Instance.new("UIPadding")
            cardPad.PaddingLeft  = UDim.new(0, 8)
            cardPad.PaddingRight = UDim.new(0, 8)
            cardPad.PaddingTop   = UDim.new(0, 8)
            cardPad.PaddingBottom = UDim.new(0, 34)   -- ruang untuk copy button
            cardPad.Parent = card

            -- Nomor kecil di pojok kanan atas
            local numLabel = Instance.new("TextLabel")
            numLabel.Size = UDim2.fromOffset(18, 14)
            numLabel.Position = UDim2.new(1, -22, 0, 6)
            numLabel.BackgroundTransparency = 1
            numLabel.TextColor3 = Color3.fromRGB(70,70,70)
            numLabel.TextSize = 9
            numLabel.Font = Enum.Font.GothamBold
            numLabel.Text = tostring(i)
            numLabel.ZIndex = 2
            numLabel.Parent = card

            -- Teks isi
            local textLabel = Instance.new("TextLabel")
            textLabel.Size = UDim2.new(1, 0, 0, 0)
            textLabel.AutomaticSize = Enum.AutomaticSize.Y
            textLabel.BackgroundTransparency = 1
            textLabel.TextColor3 = UI_CONFIG.Theme.TextSub
            textLabel.TextSize = 9
            textLabel.Font = Enum.Font.Gotham
            textLabel.Text = txt
            textLabel.TextWrapped = true
            textLabel.TextXAlignment = Enum.TextXAlignment.Left
            textLabel.TextYAlignment = Enum.TextYAlignment.Top
            textLabel.LayoutOrder = 1
            textLabel.Parent = card

            local textInnerLayout = Instance.new("UIListLayout")
            textInnerLayout.FillDirection = Enum.FillDirection.Vertical
            textInnerLayout.Parent = card

            -- Copy button
            local copyBtn = Instance.new("TextButton")
            copyBtn.Size = UDim2.new(1, -16, 0, 24)
            copyBtn.Position = UDim2.new(0, 8, 1, -30)
            copyBtn.AnchorPoint = Vector2.new(0, 0)
            copyBtn.BackgroundColor3 = UI_CONFIG.Theme.Accent
            copyBtn.BorderSizePixel = 0
            copyBtn.TextColor3 = UI_CONFIG.Theme.Text
            copyBtn.TextSize = 10
            copyBtn.Font = Enum.Font.GothamBold
            copyBtn.Text = "COPY"
            copyBtn.ZIndex = 3
            copyBtn.Parent = card
            addCorner(copyBtn, 6)
            addStroke(copyBtn, UI_CONFIG.Theme.Border, 1, 0.6)

            copyBtn.MouseEnter:Connect(function()
                TweenService:Create(copyBtn, TweenInfo.new(0.1), {BackgroundColor3 = UI_CONFIG.Theme.CopyActive}):Play()
            end)
            copyBtn.MouseLeave:Connect(function()
                if copyBtn.Text == "COPY" then
                    TweenService:Create(copyBtn, TweenInfo.new(0.1), {BackgroundColor3 = UI_CONFIG.Theme.Accent}):Play()
                end
            end)
            copyBtn.MouseButton1Click:Connect(function()
                pcall(function()
                    setclipboard(txt)
                    copyBtn.Text = "✓ Copied!"
                    copyBtn.BackgroundColor3 = UI_CONFIG.Theme.CopyActive
                    task.wait(1.5)
                    copyBtn.Text = "COPY"
                    copyBtn.BackgroundColor3 = UI_CONFIG.Theme.Accent
                end)
            end)
        end

        -- Scroll balik ke atas setelah ganti kategori
        textScroll.CanvasPosition = Vector2.new(0, 0)
    end

    -- Build category buttons berdasarkan urutan
    for idx, catName in ipairs(catOrder) do
        if REPORT_TEXTS[catName] then
            local btn = Instance.new("TextButton")
            btn.Name = catName
            btn.Size = UDim2.fromOffset(0, 28)
            btn.AutomaticSize = Enum.AutomaticSize.X
            btn.BackgroundTransparency = 1
            btn.BackgroundColor3 = UI_CONFIG.Theme.Accent
            btn.BorderSizePixel = 0
            btn.TextColor3 = UI_CONFIG.Theme.TextSub
            btn.TextSize = 10
            btn.Font = Enum.Font.GothamBold
            btn.Text = REPORT_TEXTS[catName].title
            btn.LayoutOrder = idx
            btn.Parent = catScroll

            local btnPad = Instance.new("UIPadding")
            btnPad.PaddingLeft  = UDim.new(0, 8)
            btnPad.PaddingRight = UDim.new(0, 8)
            btnPad.Parent = btn
            addCorner(btn, 6)

            btn.MouseEnter:Connect(function()
                if selectedCat ~= catName then
                    btn.TextColor3 = UI_CONFIG.Theme.Text
                end
            end)
            btn.MouseLeave:Connect(function()
                if selectedCat ~= catName then
                    btn.BackgroundTransparency = 1
                    btn.TextColor3 = UI_CONFIG.Theme.TextSub
                end
            end)
            btn.MouseButton1Click:Connect(function()
                selectCategory(catName)
            end)

            catButtons[catName] = btn
        end
    end

    -- ===== MOBILE SWIPE untuk category scroll =====
    local swipeStartX = 0
    catScroll.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            swipeStartX = input.Position.X
        end
    end)
    catScroll.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            local delta = swipeStartX - input.Position.X
            if math.abs(delta) > 1 then
                catScroll.CanvasPosition = catScroll.CanvasPosition + Vector2.new(delta * 0.6, 0)
                swipeStartX = input.Position.X
            end
        end
    end)

    -- ===== MINIMIZE =====
    minimizeBtn.MouseButton1Click:Connect(function()
        if not isMinimized then
            isMinimized = true
            contentFrame.Visible = false
            TweenService:Create(mainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quint), {
                Size = UDim2.fromOffset(W, 36)
            }):Play()
            minimizeBtn.Text = "+"
        else
            isMinimized = false
            contentFrame.Visible = true
            TweenService:Create(mainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quint), {
                Size = UDim2.fromOffset(W, fullH)
            }):Play()
            minimizeBtn.Text = "−"
        end
    end)

    -- ===== CLOSE =====
    closeBtn.MouseButton1Click:Connect(function()
        -- Slide up keluar layar dulu baru destroy, mirip gaya notif
        TweenService:Create(mainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
            Position = UDim2.new(0.5, 0, -0.5, 0)
        }):Play()
        task.wait(0.28)
        pcall(function() screenGui:Destroy() end)
    end)

    -- ===== ENTRY ANIMATION =====
    mainFrame.Position = UDim2.new(0.5, 0, -0.5, 0)
    TweenService:Create(mainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
        Position = UDim2.fromScale(0.5, 0.5)
    }):Play()

    print("✓ Anonymous9x RepText v3.0 loaded!")
end

-- ===== RUN =====
local ok, err = pcall(createRepTextUI)
if not ok then
    warn("RepText Error: " .. tostring(err))
end
