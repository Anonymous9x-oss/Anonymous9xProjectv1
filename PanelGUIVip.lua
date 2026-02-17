-- Anonymous9x RepText UI v2.3 - FINAL PRODUCTION VERSION -- Ultra Compact 240x290px | Back Button | Improved Help | Longer Texts
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local UI_CONFIG = {
    Name = "Anonymous9x RepText",
    Creator = "Anonymous9x",
    Version = "2.3",
    Theme = {
        Background = Color3.fromRGB(12, 12, 12),
        Dark = Color3.fromRGB(18, 18, 18),
        Card = Color3.fromRGB(22, 22, 22),
        Border = Color3.fromRGB(255, 255, 255),
        Text = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(200, 200, 200),
        Hover = Color3.fromRGB(35, 35, 35),
        Accent = Color3.fromRGB(45, 45, 45)
    }
}

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

local function createRepTextUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "RepTextUI"
    screenGui.ResetOnSpawn = false
    screenGui.DisplayOrder = 999

    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 240, 0, 290)
    mainFrame.Position = UDim2.new(0.5, -120, 0.5, -145)
    mainFrame.BackgroundColor3 = UI_CONFIG.Theme.Background
    mainFrame.BorderColor3 = UI_CONFIG.Theme.Border
    mainFrame.BorderSizePixel = 2
    mainFrame.Parent = screenGui

    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 6)
    mainCorner.Parent = mainFrame

    -- Title Bar (ALWAYS VISIBLE) -- SUDAH DIPERBAIKI
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 32)
    titleBar.BackgroundColor3 = UI_CONFIG.Theme.Dark
    titleBar.BorderColor3 = UI_CONFIG.Theme.Border
    titleBar.BorderSizePixel = 1
    titleBar.ZIndex = 100
    titleBar.Parent = mainFrame

    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 6)
    titleCorner.Parent = titleBar

    -- FIX: Judul Panel (Teks "Anonymous9x") dengan ZIndex lebih tinggi dan padding
    local titleText = Instance.new("TextLabel")
    titleText.Name = "TitleText"
    titleText.Size = UDim2.new(1, -78, 1, 0)  -- Lebar dikurangi 78px untuk button container
    titleText.BackgroundTransparency = 1
    titleText.TextColor3 = UI_CONFIG.Theme.Text
    titleText.TextSize = 10
    titleText.Font = Enum.Font.GothamBold
    titleText.Text = "Anonymous9x"
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.ZIndex = 102  -- FIX: ZIndex lebih tinggi dari button container (101)
    titleText.Parent = titleBar

    local titlePadding = Instance.new("UIPadding")
    titlePadding.PaddingLeft = UDim.new(0, 8)  -- FIX: Padding kiri 8px agar teks tidak menempel
    titlePadding.Parent = titleText

    -- Button Container (tetap sama)
    local buttonContainer = Instance.new("Frame")
    buttonContainer.Name = "ButtonContainer"
    buttonContainer.Size = UDim2.new(0, 72, 1, 0)
    buttonContainer.Position = UDim2.new(1, -72, 0, 0)
    buttonContainer.BackgroundTransparency = 1
    buttonContainer.ZIndex = 101  -- FIX: ZIndex button container 101
    buttonContainer.Parent = titleBar

    -- Help Button
    local helpBtn = Instance.new("TextButton")
    helpBtn.Name = "HelpBtn"
    helpBtn.Size = UDim2.new(0, 22, 0, 22)
    helpBtn.Position = UDim2.new(0, 2, 0.5, -11)
    helpBtn.BackgroundColor3 = UI_CONFIG.Theme.Accent
    helpBtn.BorderColor3 = UI_CONFIG.Theme.Border
    helpBtn.BorderSizePixel = 1
    helpBtn.TextColor3 = UI_CONFIG.Theme.Text
    helpBtn.TextSize = 11
    helpBtn.Font = Enum.Font.GothamBold
    helpBtn.Text = "?"
    helpBtn.ZIndex = 101
    helpBtn.Parent = buttonContainer

    local helpCorner = Instance.new("UICorner")
    helpCorner.CornerRadius = UDim.new(0, 3)
    helpCorner.Parent = helpBtn

    -- Minimize Button
    local minimizeBtn = Instance.new("TextButton")
    minimizeBtn.Name = "MinimizeBtn"
    minimizeBtn.Size = UDim2.new(0, 22, 0, 22)
    minimizeBtn.Position = UDim2.new(0, 26, 0.5, -11)
    minimizeBtn.BackgroundColor3 = UI_CONFIG.Theme.Accent
    minimizeBtn.BorderColor3 = UI_CONFIG.Theme.Border
    minimizeBtn.BorderSizePixel = 1
    minimizeBtn.TextColor3 = UI_CONFIG.Theme.Text
    minimizeBtn.TextSize = 13
    minimizeBtn.Font = Enum.Font.GothamBold
    minimizeBtn.Text = "−"
    minimizeBtn.ZIndex = 101
    minimizeBtn.Parent = buttonContainer

    local minCorner = Instance.new("UICorner")
    minCorner.CornerRadius = UDim.new(0, 3)
    minCorner.Parent = minimizeBtn

    -- Close Button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "CloseBtn"
    closeBtn.Size = UDim2.new(0, 22, 0, 22)
    closeBtn.Position = UDim2.new(0, 50, 0.5, -11)
    closeBtn.BackgroundColor3 = UI_CONFIG.Theme.Accent
    closeBtn.BorderColor3 = UI_CONFIG.Theme.Border
    closeBtn.BorderSizePixel = 1
    closeBtn.TextColor3 = UI_CONFIG.Theme.Text
    closeBtn.TextSize = 13
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Text = "×"
    closeBtn.ZIndex = 101
    closeBtn.Parent = buttonContainer

    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 3)
    closeCorner.Parent = closeBtn

    -- Content Frame
    local contentFrame = Instance.new("Frame")
    contentFrame.Name = "ContentFrame"
    contentFrame.Size = UDim2.new(1, 0, 1, -32)
    contentFrame.Position = UDim2.new(0, 0, 0, 32)
    contentFrame.BackgroundTransparency = 1
    contentFrame.Parent = mainFrame

    -- Category Scroll
    local categoryScroll = Instance.new("ScrollingFrame")
    categoryScroll.Name = "CategoryScroll"
    categoryScroll.Size = UDim2.new(1, 0, 0, 38)
    categoryScroll.BackgroundColor3 = UI_CONFIG.Theme.Dark
    categoryScroll.BorderColor3 = UI_CONFIG.Theme.Border
    categoryScroll.BorderSizePixel = 1
    categoryScroll.ScrollBarThickness = 2
    categoryScroll.CanvasSize = UDim2.new(4, 0, 0, 38)
    categoryScroll.Parent = contentFrame
    pcall(function() categoryScroll.ScrollDirection = Enum.ScrollDirection.X end)

    local catLayout = Instance.new("UIListLayout")
    catLayout.FillDirection = Enum.FillDirection.Horizontal
    catLayout.Padding = UDim.new(0, 4)
    catLayout.Parent = categoryScroll

    local catPadding = Instance.new("UIPadding")
    catPadding.PaddingLeft = UDim.new(0, 4)
    catPadding.PaddingRight = UDim.new(0, 4)
    catPadding.Parent = categoryScroll

    -- Text Scroll
    local textScroll = Instance.new("ScrollingFrame")
    textScroll.Name = "TextScroll"
    textScroll.Size = UDim2.new(1, 0, 1, -42)
    textScroll.Position = UDim2.new(0, 0, 0, 38)
    textScroll.BackgroundColor3 = UI_CONFIG.Theme.Background
    textScroll.BorderColor3 = UI_CONFIG.Theme.Border
    textScroll.BorderSizePixel = 1
    textScroll.ScrollBarThickness = 2
    textScroll.CanvasSize = UDim2.new(0, 0, 10, 0)
    textScroll.Parent = contentFrame

    local textLayout = Instance.new("UIListLayout")
    textLayout.FillDirection = Enum.FillDirection.Vertical
    textLayout.Padding = UDim.new(0, 4)
    textLayout.Parent = textScroll

    local textPadding = Instance.new("UIPadding")
    textPadding.PaddingLeft = UDim.new(0, 5)
    textPadding.PaddingRight = UDim.new(0, 5)
    textPadding.PaddingTop = UDim.new(0, 5)
    textPadding.PaddingBottom = UDim.new(0, 5)
    textPadding.Parent = textScroll

    -- Help Panel (with Back button)
    local helpPanel = Instance.new("Frame")
    helpPanel.Name = "HelpPanel"
    helpPanel.Size = UDim2.new(1, 0, 1, -32)
    helpPanel.Position = UDim2.new(0, 0, 0, 32)
    helpPanel.BackgroundColor3 = UI_CONFIG.Theme.Background
    helpPanel.Visible = false
    helpPanel.Parent = mainFrame

    -- Back Button in Help Panel
    local backBtn = Instance.new("TextButton")
    backBtn.Name = "BackBtn"
    backBtn.Size = UDim2.new(1, -10, 0, 24)
    backBtn.Position = UDim2.new(0, 5, 0, 5)
    backBtn.BackgroundColor3 = UI_CONFIG.Theme.Accent
    backBtn.BorderColor3 = UI_CONFIG.Theme.Border
    backBtn.BorderSizePixel = 1
    backBtn.TextColor3 = UI_CONFIG.Theme.Text
    backBtn.TextSize = 9
    backBtn.Font = Enum.Font.GothamBold
    backBtn.Text = "← Back"
    backBtn.Parent = helpPanel

    local backCorner = Instance.new("UICorner")
    backCorner.CornerRadius = UDim.new(0, 3)
    backCorner.Parent = backBtn

    -- Help Scroll
    local helpScroll = Instance.new("ScrollingFrame")
    helpScroll.Name = "HelpScroll"
    helpScroll.Size = UDim2.new(1, 0, 1, -34)
    helpScroll.Position = UDim2.new(0, 0, 0, 30)
    helpScroll.BackgroundTransparency = 1
    helpScroll.ScrollBarThickness = 2
    helpScroll.CanvasSize = UDim2.new(0, 0, 5, 0)
    helpScroll.Parent = helpPanel

    local helpText = Instance.new("TextLabel")
    helpText.Name = "HelpText"
    helpText.Size = UDim2.new(1, -10, 0, 200)
    helpText.BackgroundTransparency = 1
    helpText.TextColor3 = UI_CONFIG.Theme.TextSecondary
    helpText.TextSize = 7.5
    helpText.Font = Enum.Font.Gotham
    helpText.Text = "📋 HOW TO USE:\n\n1️⃣ SCROLL CATEGORIES\nSwipe left/right to find category\n\n2️⃣ CLICK CATEGORY\nClick to load report texts\n\n3️⃣ READ PREVIEW\nRead text in card\n\n4️⃣ COPY TEXT\nClick COPY button\n\n5️⃣ OPEN REPORT FORM\nGo to Roblox report\n\n6️⃣ PASTE\nCtrl+V or Cmd+V\n\n7️⃣ SUBMIT\nSubmit your report\n\n🎮 DRAG UI:\nClick & drag title bar anywhere\n\n➖ MINIMIZE:\nClick − button (header stays visible)\n\n❌ CLOSE:\nClick × button\n\n❓ HELP:\nClick ? button (you are here)"
    helpText.TextWrapped = true
    helpText.TextXAlignment = Enum.TextXAlignment.Left
    helpText.TextYAlignment = Enum.TextYAlignment.Top
    helpText.Parent = helpScroll

    local helpPadding = Instance.new("UIPadding")
    helpPadding.PaddingLeft = UDim.new(0, 5)
    helpPadding.PaddingRight = UDim.new(0, 5)
    helpPadding.PaddingTop = UDim.new(0, 5)
    helpPadding.Parent = helpText

    -- Loading Screen
    local loadingScreen = Instance.new("Frame")
    loadingScreen.Name = "LoadingScreen"
    loadingScreen.Size = UDim2.new(1, 0, 1, 0)
    loadingScreen.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    loadingScreen.BackgroundTransparency = 0.5
    loadingScreen.Visible = false
    loadingScreen.ZIndex = 50
    loadingScreen.Parent = mainFrame

    local loadingBox = Instance.new("Frame")
    loadingBox.Size = UDim2.new(0, 90, 0, 60)
    loadingBox.Position = UDim2.new(0.5, -45, 0.5, -30)
    loadingBox.BackgroundColor3 = UI_CONFIG.Theme.Dark
    loadingBox.BorderColor3 = UI_CONFIG.Theme.Border
    loadingBox.BorderSizePixel = 2
    loadingBox.ZIndex = 51
    loadingBox.Parent = loadingScreen

    local loadCorner = Instance.new("UICorner")
    loadCorner.CornerRadius = UDim.new(0, 4)
    loadCorner.Parent = loadingBox

    local dotsContainer = Instance.new("Frame")
    dotsContainer.Size = UDim2.new(1, 0, 0.5, 0)
    dotsContainer.BackgroundTransparency = 1
    dotsContainer.Parent = loadingBox

    local dots = {}
    for i = 1, 3 do
        local dot = Instance.new("TextLabel")
        dot.Size = UDim2.new(0, 4, 0, 4)
        dot.Position = UDim2.new(0.5, -10 + (i-1)*10, 0.5, -2)
        dot.BackgroundColor3 = UI_CONFIG.Theme.Border
        dot.BorderSizePixel = 0
        dot.Text = ""
        dot.Parent = dotsContainer
        local dotCorner = Instance.new("UICorner")
        dotCorner.CornerRadius = UDim.new(1, 0)
        dotCorner.Parent = dot
        dots[i] = dot
    end

    local loadText = Instance.new("TextLabel")
    loadText.Size = UDim2.new(1, 0, 0.5, 0)
    loadText.Position = UDim2.new(0, 0, 0.5, 0)
    loadText.BackgroundTransparency = 1
    loadText.TextColor3 = UI_CONFIG.Theme.Text
    loadText.TextSize = 8
    loadText.Font = Enum.Font.GothamBold
    loadText.Text = "Loading..."
    loadText.Parent = loadingBox

    -- Variables
    local isMinimized = false
    local helpShowing = false
    local selectedCategory = nil

    -- Create Category Button
    local function createCategoryButton(categoryName)
        local btn = Instance.new("TextButton")
        btn.Name = categoryName
        btn.Size = UDim2.new(0, 50, 0, 30)
        btn.BackgroundColor3 = UI_CONFIG.Theme.Dark
        btn.BorderColor3 = UI_CONFIG.Theme.Border
        btn.BorderSizePixel = 1
        btn.TextColor3 = UI_CONFIG.Theme.TextSecondary
        btn.TextSize = 7
        btn.Font = Enum.Font.GothamBold
        btn.Text = REPORT_TEXTS[categoryName].title
        btn.TextWrapped = true
        btn.Parent = categoryScroll

        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 3)
        btnCorner.Parent = btn

        btn.MouseEnter:Connect(function()
            btn.BackgroundColor3 = UI_CONFIG.Theme.Hover
            btn.TextColor3 = UI_CONFIG.Theme.Text
        end)

        btn.MouseLeave:Connect(function()
            if selectedCategory ~= categoryName then
                btn.BackgroundColor3 = UI_CONFIG.Theme.Dark
                btn.TextColor3 = UI_CONFIG.Theme.TextSecondary
            end
        end)

        btn.MouseButton1Click:Connect(function()
            loadingScreen.Visible = true
            helpPanel.Visible = false
            helpShowing = false

            if selectedCategory and categoryScroll:FindFirstChild(selectedCategory) then
                categoryScroll:FindFirstChild(selectedCategory).BackgroundColor3 = UI_CONFIG.Theme.Dark
                categoryScroll:FindFirstChild(selectedCategory).TextColor3 = UI_CONFIG.Theme.TextSecondary
            end

            selectedCategory = categoryName
            btn.BackgroundColor3 = UI_CONFIG.Theme.Accent
            btn.TextColor3 = UI_CONFIG.Theme.Text

            for _, child in ipairs(textScroll:GetChildren()) do
                if child:IsA("Frame") then
                    child:Destroy()
                end
            end

            wait(0.2)

            for i, text in ipairs(REPORT_TEXTS[categoryName].texts) do
                local textCard = Instance.new("Frame")
                textCard.Size = UDim2.new(1, -10, 0, 70)
                textCard.BackgroundColor3 = UI_CONFIG.Theme.Card
                textCard.BorderColor3 = UI_CONFIG.Theme.Border
                textCard.BorderSizePixel = 1
                textCard.Parent = textScroll

                local cardCorner = Instance.new("UICorner")
                cardCorner.CornerRadius = UDim.new(0, 4)
                cardCorner.Parent = textCard

                local textLabel = Instance.new("TextLabel")
                textLabel.Size = UDim2.new(1, -6, 1, -26)
                textLabel.BackgroundTransparency = 1
                textLabel.TextColor3 = UI_CONFIG.Theme.TextSecondary
                textLabel.TextSize = 6.5
                textLabel.Font = Enum.Font.Gotham
                textLabel.Text = text
                textLabel.TextWrapped = true
                textLabel.TextXAlignment = Enum.TextXAlignment.Left
                textLabel.TextYAlignment = Enum.TextYAlignment.Top
                textLabel.Parent = textCard

                local labelPadding = Instance.new("UIPadding")
                labelPadding.PaddingLeft = UDim.new(0, 3)
                labelPadding.PaddingRight = UDim.new(0, 3)
                labelPadding.PaddingTop = UDim.new(0, 3)
                labelPadding.Parent = textLabel

                local copyBtn = Instance.new("TextButton")
                copyBtn.Size = UDim2.new(1, -6, 0, 18)
                copyBtn.Position = UDim2.new(0, 3, 1, -21)
                copyBtn.BackgroundColor3 = UI_CONFIG.Theme.Accent
                copyBtn.BorderColor3 = UI_CONFIG.Theme.Border
                copyBtn.BorderSizePixel = 1
                copyBtn.TextColor3 = UI_CONFIG.Theme.Text
                copyBtn.TextSize = 7
                copyBtn.Font = Enum.Font.GothamBold
                copyBtn.Text = "COPY"
                copyBtn.Parent = textCard

                local btnCorner2 = Instance.new("UICorner")
                btnCorner2.CornerRadius = UDim.new(0, 2)
                btnCorner2.Parent = copyBtn

                copyBtn.MouseEnter:Connect(function()
                    copyBtn.BackgroundColor3 = UI_CONFIG.Theme.Hover
                end)

                copyBtn.MouseLeave:Connect(function()
                    copyBtn.BackgroundColor3 = UI_CONFIG.Theme.Accent
                end)

                copyBtn.MouseButton1Click:Connect(function()
                    pcall(function()
                        setclipboard(text)
                        copyBtn.Text = "✓"
                        task.wait(1)
                        copyBtn.Text = "COPY"
                    end)
                end)

                textCard.LayoutOrder = i
            end

            textScroll.CanvasSize = UDim2.new(0, 0, 0, textLayout.AbsoluteContentSize.Y + 10)
            loadingScreen.Visible = false
        end)

        return btn
    end

    for categoryName, _ in pairs(REPORT_TEXTS) do
        createCategoryButton(categoryName)
    end

    -- Button Event Handlers
    helpBtn.MouseButton1Click:Connect(function()
        helpShowing = not helpShowing
        if helpShowing then
            helpPanel.Visible = true
            contentFrame.Visible = false
            helpBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        else
            helpPanel.Visible = false
            contentFrame.Visible = true
            helpBtn.BackgroundColor3 = UI_CONFIG.Theme.Accent
        end
    end)

    backBtn.MouseButton1Click:Connect(function()
        helpShowing = false
        helpPanel.Visible = false
        contentFrame.Visible = true
        helpBtn.BackgroundColor3 = UI_CONFIG.Theme.Accent
    end)

    backBtn.MouseEnter:Connect(function()
        backBtn.BackgroundColor3 = UI_CONFIG.Theme.Hover
    end)

    backBtn.MouseLeave:Connect(function()
        backBtn.BackgroundColor3 = UI_CONFIG.Theme.Accent
    end)

    minimizeBtn.MouseButton1Click:Connect(function()
        if not isMinimized then
            isMinimized = true
            contentFrame.Visible = false
            helpPanel.Visible = false
            mainFrame.Size = UDim2.new(0, 240, 0, 32)
            minimizeBtn.Text = "+"
        else
            isMinimized = false
            contentFrame.Visible = true
            mainFrame.Size = UDim2.new(0, 240, 0, 290)
            minimizeBtn.Text = "−"
        end
    end)

    closeBtn.MouseButton1Click:Connect(function()
        pcall(function()
            screenGui:Destroy()
        end)
    end)

    -- Drag Support
    local isDragging = false
    local dragOffset = Vector2.new(0, 0)

    titleText.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
            isDragging = true
            dragOffset = Vector2.new(mainFrame.Position.X.Offset - input.Position.X, mainFrame.Position.Y.Offset - input.Position.Y)
        end
    end)

    titleText.InputEnded:Connect(function(input, gameProcessed)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = false
        end
    end)

    titleText.InputChanged:Connect(function(input, gameProcessed)
        if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local newX = input.Position.X + dragOffset.X
            local newY = input.Position.Y + dragOffset.Y
            mainFrame.Position = UDim2.new(0, newX, 0, newY)
        end
    end)

    -- Loading Animation
    RunService.RenderStepped:Connect(function()
        if loadingScreen.Visible then
            local elapsed = tick() % 0.6
            for i, dot in ipairs(dots) do
                local delay = (i - 1) * 0.1
                local phase = (elapsed - delay) % 0.6
                if phase < 0.3 then
                    local t = phase / 0.3
                    dot.BackgroundTransparency = 0.5 - (0.3 * t)
                else
                    local t = (phase - 0.3) / 0.3
                    dot.BackgroundTransparency = 0.2 + (0.3 * t)
                end
            end
        end
    end)

    -- Mobile Swipe
    local startX = 0
    contentFrame.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.UserInputType == Enum.UserInputType.Touch then
            startX = input.Position.X
        end
    end)

    contentFrame.InputChanged:Connect(function(input, gameProcessed)
        if input.UserInputType == Enum.UserInputType.Touch then
            local deltaX = startX - input.Position.X
            if math.abs(deltaX) > 2 then
                categoryScroll.CanvasPosition = categoryScroll.CanvasPosition + Vector2.new(deltaX * 0.5, 0)
                startX = input.Position.X
            end
        end
    end)

    screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    return screenGui
end

local function safeInit()
    local success, err = pcall(createRepTextUI)
    if not success then
        warn("RepText Error: " .. tostring(err))
    else
        print("✓ Anonymous9x RepText v2.3 - FINAL VERSION LOADED!")
    end
end

safeInit()
