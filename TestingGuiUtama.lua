--[[
    ANONYMOUS9x VIP - MAIN GUI (UPGRADED v2.1)
    FIX: LOADING ANIMATION POSITION & TEXT SEQUENCE
    MOD: REMOVED KEY SYSTEM, ADDED ANIMATED BACKGROUND + TOGGLE
    V4 FINAL REVISI TERAKHIR: +JEDA 5.5 DETIK SEBELUM WHITE FLASH
--]]

-- Main Configuration
local Config = {
    Title = "ANONYMOUS9x VIP",
    LogoID = "rbxassetid://97269958324726",
    Theme = {
        Primary = Color3.fromRGB(255, 255, 255),
        Background = Color3.fromRGB(8, 8, 8),
        Card = Color3.fromRGB(15, 15, 15),
        Border = Color3.fromRGB(255, 255, 255),
        HackerGreen = Color3.fromRGB(0, 255, 100),
        Text = Color3.fromRGB(255, 255, 255)
    },
    Scripts = {
        {Name = "Hybrid Attack", Icon = "Chaos", URL = "https://pastebin.com/raw/yTv5hwc5", Desc = "spam attack v1 automatic unlimited attack, click stop if you want to stop"},
        {Name = "Spam Armagedon", Icon = "Chaos", URL = "https://pastebin.com/raw/dXNtX5PB", Desc = "spam attack v2 with customizable attacks, with full scan"},
        {Name = "Fly Noclip", Icon = "Main", URL = "https://pastebin.com/raw/ZrRwsPAe", Desc = "universal mobile fly with analog, keyboard with wasd"},
        {Name = "ESP Master", Icon = "Main", URL = "https://pastebin.com/raw/zdqzRRDe", Desc = "can see other players without range"},
        {Name = "Speed Walk", Icon = "Main", URL = "https://pastebin.com/raw/BAqbsBx0", Desc = "easily adjust your running speed"},
        {Name = "Ghost Mode", Icon = "Main", URL = "https://pastebin.com/raw/A26bz69Q", Desc = "set yourself to be invisible so you can become a ghost equipped with speedboost"},
        {Name = "No Clip", Icon = "Main", URL = "https://pastebin.com/raw/4Y3ium6c", Desc = "set you up so you can go through walls or other parts"},
        {Name = "Infinite Jump", Icon = "Main", URL = "https://pastebin.com/raw/qrMSz160", Desc = "you can do jump spam"},
        {Name = "Spectator Full", Icon = "Player", URL = "https://pastebin.com/raw/yYrK3kNi", Desc = "Spectator All Player with tp, follow, kick features"},
        {Name = "Fling Player", Icon = "Chaos", URL = "https://pastebin.com/raw/0r27fM5A", Desc = "can kick a player very high"},
        {Name = "Follow Target", Icon = "Player", URL = "https://pastebin.com/raw/9wx2KS2Z", Desc = "stick to the player like a magnet with realtime player list"}, 
        {Name = "Bringpart Wrld", Icon = "Chaos", URL = "https://pastebin.com/raw/a26kitCS", Desc = "lift all parts with a super wide radius up to one map but low strength"},
        {Name = "Adidas animasi", Icon = "FE", URL = "https://pastebin.com/raw/tzx26Sbr", Desc = "full pack adidas animation FE"}, 
        {Name = "Magnetpart", Icon = "Chaos", URL = "https://pastebin.com/raw/LNVRDWZD", Desc = "can pull large parts with super strength but small radius"},
        {Name = "Emote", Icon = "FE", URL = "https://pastebin.com/raw/2uudnFFW", Desc = "full emote with simple UI"}, 
        {Name = "Copy Avatar", Icon = "VIs/FE", URL = "https://pastebin.com/raw/DbvucrBF", Desc = "copy avatar with dual engine can FE if there is a map that is affected, Visual if the map is good"},
        {Name = "Boost Fps", Icon = "Misc", URL = "https://pastebin.com/raw/2vMAdcms", Desc = "can improve the performance of your device"}, 
        {Name = "Tp Tool", Icon = "Main", URL = "https://pastebin.com/raw/8pczZX3P", Desc = "give you simple teleport tool without ui"},
        {Name = "Dex Explorer", Icon = "Misc", URL = "https://raw.githubusercontent.com/infyiff/backup/main/dex.lua", Desc = "can check the contents of the script map"}, 
        {Name = "FakeDonate", Icon = "Chaos", URL = "https://pastebin.com/raw/yaGNQ4i3", Desc = "donate FE with a system that manipulates product developers"},
        {Name = "Hitbox Universal", Icon = "Main", URL = "https://pastebin.com/raw/BWD0p374", Desc = "can help you hit players with hitboxes with a sophisticated engine that auto scans maps to see if they can hitbox or not"}, 
        {Name = "Report Text", Icon = "Misc", URL = "https://raw.githubusercontent.com/Anonymous9x-oss/Anonymous9xProjectv1/refs/heads/main/PanelGUIVip.lua", Desc = "copy text that can make it easier for you to ban players who are in violation by reporting"},
        {Name = "Aimbot Universal", Icon = "Main", URL = "https://pastebin.com/raw/ey0WnWUv", Desc = "can help you hit players with lock aim or aim assist"}, 
        {Name = "AutoWalk Universal", Icon = "Main", URL = "https://pastebin.com/raw/fbUrKRbG", Desc = "autowalk with full features, record manually"},
        {Name = "Jump Power", Icon = "Main", URL = "https://pastebin.com/raw/eiDMNdLC", Desc = "can adjust your jump height with particle effects"}, 
        {Name = "AutoTp Universal", Icon = "Main", URL = "https://pastebin.com/raw/1Q3ZLFT6", Desc = "teleport by getting location manually"},
        {Name = "Fun3", Icon = "Vis/FE", URL = "https://pastebin.com/raw/Ld1WEWVt", Desc = "features for fun in one ui panel with 3 features"}, 
        {Name = "Freecam", Icon = "Main", URL = "https://pastebin.com/raw/sHvYLsGW", Desc = "fly freely with your camera like a drone"},
        {Name = "Executor", Icon = "Misc", URL = "https://pastebin.com/raw/bdPnW9mn", Desc = "loader executor that can run other scripts here"},
        {Name = "Glitcher Crash", Icon = "Chaos", URL = "https://raw.githubusercontent.com/Anonymous9x-oss/Anonymous9xProjectv1/refs/heads/main/GlitcherCrash.lua", Desc = "Super chaotic glitcher with many mode, if you have a grudge you can use this"},
        {Name = "God Mode", Icon = "Main", URL = "https://raw.githubusercontent.com/Anonymous9x-oss/Anonymous9xProjectv1/refs/heads/main/Godmode.lua", Desc = "Immune to all obstacle damage, ragdoll damage, anti-slap, etc. with 11 layer fallback function"},
        {Name = "KillAura Npc", Icon = "Main", URL = "https://raw.githubusercontent.com/Anonymous9x-oss/Anonymous9xProjectv1/refs/heads/main/KillAura.lua", Desc = "kill all npc with sigma aura that radiates from you, studs that can be adjusted flexibly"},
        {Name = "SambungKata", Icon = "Main", URL = "https://raw.githubusercontent.com/Anonymous9x-oss/Anonymous9xProjectv1/refs/heads/main/Sambung%20kata.lua", Desc = "script for in sambung kata,taken from kkbi"},
        {Name = "SambungKata Collab", Icon = "Main", URL = "https://raw.githubusercontent.com/Fiqqzr7Lua/SCRIPTFIQQZR7/refs/heads/main/Fiqqzr7XAnonymous9x%20SAMBUNG%20KATA", Desc = "special collab with FIQQZR7"},
        {Name = "FakeDonate Collab", Icon = "Chaos", URL = "https://pastefy.app/28xUWzZX/raw", Desc = "special collab with FIQQZR7"},
        {Name = "Xray", Icon = "Misc", URL = "https://raw.githubusercontent.com/Anonymous9x-oss/Anonymous9xProjectv1/refs/heads/main/XrayUniversal.lua", Desc = "can see through all parts, houses etc., without ui"},
        {Name = "Full Rtx", Icon = "Misc", URL = "https://raw.githubusercontent.com/Anonymous9x-oss/Anonymous9xProjectv1/refs/heads/main/Rtx.lua", Desc = "full preset hd with filters like rtx panel"},
        {Name = "Spiderman Walk", Icon = "Main", URL = "https://raw.githubusercontent.com/Anonymous9x-oss/Anonymous9xProjectv1/refs/heads/main/Walkonwall.lua", Desc = "FE can run on walls, etc., without ui"},
        {Name = "Backdoor Tester", Icon = "Chaos", URL = "https://raw.githubusercontent.com/Anonymous9x-oss/Anonymous9xProjectv1/refs/heads/main/Scan%20backdoor.lua", Desc = "tools and backdoor scan tests, if there is a backdoor, you can run require"}
    }
}

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StatsService = game:GetService("Stats")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Find existing ScreenGui
local ScreenGui = PlayerGui:FindFirstChild("HorizontalHub")
if not ScreenGui then
    ScreenGui = Instance.new("ScreenGui", PlayerGui)
    ScreenGui.Name = "HorizontalHub"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
end

-- Helper Functions
local function AddStroke(obj, thickness, color)
    local s = Instance.new("UIStroke", obj)
    s.Color = color or Config.Theme.Border
    s.Thickness = thickness or 1
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    return s
end

-- ==================== MAIN PANEL ====================
local AppWindow = Instance.new("Frame", ScreenGui)
AppWindow.Size = UDim2.new(0, 420, 0, 320)
AppWindow.Position = UDim2.new(0.5, -210, 0.5, -160)
AppWindow.BackgroundColor3 = Config.Theme.Background
AppWindow.Visible = false
AppWindow.Active = true
Instance.new("UICorner", AppWindow).CornerRadius = UDim.new(0, 10)
AddStroke(AppWindow, 2)

-- ==================== ANIMATED BACKGROUND SYSTEM ====================
local AnimBackgroundEnabled = true
local animatedCards = {}
local cardStrokes = {}

-- Frame background animasi
local AnimBG = Instance.new("Frame", AppWindow)
AnimBG.Name = "AnimBG"
AnimBG.Size = UDim2.new(1, 0, 1, 0)
AnimBG.BackgroundTransparency = 1
AnimBG.ZIndex = 0

-- Rain container
local RainContainer = Instance.new("Frame", AnimBG)
RainContainer.Size = UDim2.new(1, 0, 1, 0)
RainContainer.BackgroundTransparency = 1
RainContainer.ZIndex = 0
RainContainer.ClipsDescendants = true

-- Dua label untuk teks sinematik
local WhoIsText = Instance.new("TextLabel", AnimBG)
WhoIsText.Name = "WhoIsText"
WhoIsText.AnchorPoint = Vector2.new(0.5, 0.5)
WhoIsText.Size = UDim2.new(0.4, 0, 0, 30)
WhoIsText.Position = UDim2.new(0.5, 0, 0.5, 0)
WhoIsText.BackgroundTransparency = 1
WhoIsText.Text = "Who is"
WhoIsText.TextColor3 = Color3.fromRGB(200, 200, 200)
WhoIsText.Font = Enum.Font.GothamBlack
WhoIsText.TextSize = 20
WhoIsText.TextTransparency = 1
WhoIsText.ZIndex = 5

local AnonText = Instance.new("TextLabel", AnimBG)
AnonText.Name = "AnonText"
AnonText.AnchorPoint = Vector2.new(0.5, 0.5)
AnonText.Size = UDim2.new(0.9, 0, 0, 55)
AnonText.Position = UDim2.new(0.5, 0, 0.5, 0)
AnonText.BackgroundTransparency = 1
AnonText.Text = "Anonymous9x?"
AnonText.TextColor3 = Color3.fromRGB(200, 200, 200)
AnonText.Font = Enum.Font.GothamBlack
AnonText.TextSize = 34
AnonText.TextTransparency = 1
AnonText.ZIndex = 5

-- White flash effect
local WhiteFlash = Instance.new("Frame", AnimBG)
WhiteFlash.Size = UDim2.new(1, 0, 1, 0)
WhiteFlash.BackgroundColor3 = Color3.new(1, 1, 1)
WhiteFlash.BackgroundTransparency = 1
WhiteFlash.ZIndex = 10

-- Matrix rain: heavy downpour, random characters (printable ASCII)
local charPool = {}
for c = 33, 126 do
    table.insert(charPool, string.char(c))
end
local rainChars = {}
for i = 1, 120 do
    local lbl = Instance.new("TextLabel", RainContainer)
    lbl.Size = UDim2.new(0, 14, 0, 14)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = Color3.fromRGB(180, 180, 180)
    lbl.Font = Enum.Font.Code
    lbl.TextSize = 10 + math.random(6)
    lbl.Text = charPool[math.random(#charPool)]
    lbl.Position = UDim2.new(math.random(), 0, math.random(), 0)
    lbl.ZIndex = 0
    rainChars[#rainChars + 1] = {
        label = lbl,
        speed = 2 + math.random()*4,
        changeInterval = math.random(3, 10)
    }
end

-- Update rain loop
local function startRainLoop()
    task.spawn(function()
        local counter = 0
        while true do
            if not AnimBackgroundEnabled then task.wait(0.1) continue end
            counter = counter + 1
            for _, data in ipairs(rainChars) do
                local lbl = data.label
                local pos = lbl.Position
                local newY = pos.Y.Scale + data.speed * 0.002
                if newY > 1.1 then
                    newY = -0.1
                    lbl.Position = UDim2.new(math.random(), 0, newY, 0)
                    lbl.Text = charPool[math.random(#charPool)]
                else
                    lbl.Position = UDim2.new(pos.X.Scale, 0, newY, 0)
                    if counter % data.changeInterval == 0 then
                        lbl.Text = charPool[math.random(#charPool)]
                    end
                end
            end
            task.wait(0.03)
        end
    end)
end

-- ==================== CINEMATIC TEXT SEQUENCE (REVISI FINAL) ====================
local function startCinematicTextSequence()
    task.spawn(function()
        while true do
            if not AnimBackgroundEnabled then task.wait(0.5) continue end
            
            -- FASE 1: "Who is" zoom in → fade out
            WhoIsText.TextTransparency = 1
            WhoIsText.Size = UDim2.new(0.4, 0, 0, 30)   -- reset kecil
            WhoIsText.Visible = true
            local tweenZoom = TweenService:Create(WhoIsText, TweenInfo.new(0.4, Enum.EasingStyle.Back), {Size = UDim2.new(0.7, 0, 0, 45)})
            local tweenFadeIn = TweenService:Create(WhoIsText, TweenInfo.new(0.2), {TextTransparency = 0.2})
            tweenZoom:Play()
            tweenFadeIn:Play()
            tweenZoom.Completed:Wait()
            task.wait(0.8)
            -- fade out halus
            local tweenFadeOut = TweenService:Create(WhoIsText, TweenInfo.new(0.3), {TextTransparency = 1})
            tweenFadeOut:Play()
            tweenFadeOut.Completed:Wait()
            WhoIsText.Visible = false

            -- FASE 2: "Anonymous9x?" muncul besar → scramble → JEDA 5.5 DETIK → white flash
            AnonText.Text = "Anonymous9x?"
            AnonText.TextTransparency = 0.2
            AnonText.Visible = true

            -- Scramble karakter (10 putaran cepat)
            for _ = 1, 10 do
                local scrambled = ""
                for i = 1, #AnonText.Text do
                    scrambled = scrambled .. charPool[math.random(#charPool)]
                end
                AnonText.Text = scrambled
                task.wait(0.03)
            end
            AnonText.Text = "Anonymous9x?"   -- kembali normal

            -- JEDA 5.5 DETIK AGAR USER BISA BACA "Anonymous9x?"
            task.wait(5.5)

            -- White flash cinematic langsung
            WhiteFlash.BackgroundTransparency = 1
            local tweenFlash = TweenService:Create(WhiteFlash, TweenInfo.new(0.15), {BackgroundTransparency = 0})
            tweenFlash:Play()
            tweenFlash.Completed:Wait()
            AnonText.TextTransparency = 1
            AnonText.Visible = false
            local tweenOut = TweenService:Create(WhiteFlash, TweenInfo.new(0.3), {BackgroundTransparency = 1})
            tweenOut:Play()
            tweenOut.Completed:Wait()

            task.wait(0.8)   -- jeda sebelum loop
        end
    end)
end

-- Border blink animation (random double blinks)
local function startBorderBlink()
    task.spawn(function()
        local dimColor = Color3.fromRGB(60,60,60)
        while true do
            if not AnimBackgroundEnabled then task.wait(0.5) continue end
            task.wait(math.random(1, 3))
            local blinks = math.random(1,2)
            for _ = 1, blinks do
                for _, stroke in ipairs(cardStrokes) do
                    stroke.Color = dimColor
                end
                task.wait(0.06)
                for _, stroke in ipairs(cardStrokes) do
                    stroke.Color = Config.Theme.Border
                end
                if blinks == 2 then task.wait(0.06) end
            end
        end
    end)
end

-- Update visual mode (transparency, hide/show)
local function updateVisualMode()
    for _, card in ipairs(animatedCards) do
        if AnimBackgroundEnabled then
            card.BackgroundTransparency = 0.7
        else
            card.BackgroundTransparency = 0
        end
    end
    if Footer then
        if AnimBackgroundEnabled then
            Footer.BackgroundTransparency = 0.5
        else
            Footer.BackgroundTransparency = 0
        end
    end
    AnimBG.Visible = AnimBackgroundEnabled
    if not AnimBackgroundEnabled then
        for _, stroke in ipairs(cardStrokes) do
            stroke.Color = Config.Theme.Border
        end
        WhoIsText.Visible = false
        AnonText.Visible = false
    end
end

-- ==================== FIXED LOADING SCREEN ====================
local function RunLoadingScreen()
    local LoadingFrame = Instance.new("Frame", AppWindow)
    LoadingFrame.Name = "LoadingFrame"
    LoadingFrame.Size = UDim2.new(1, 0, 1, 0)
    LoadingFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    LoadingFrame.BackgroundTransparency = 0.1
    LoadingFrame.ZIndex = 2000
    LoadingFrame.Visible = true
    Instance.new("UICorner", LoadingFrame).CornerRadius = UDim.new(0, 10)
    
    local LoadingContainer = Instance.new("Frame", LoadingFrame)
    LoadingContainer.Size = UDim2.new(0.8, 0, 0, 100)
    LoadingContainer.Position = UDim2.new(0.1, 0, 0.4, 0)
    LoadingContainer.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    LoadingContainer.ZIndex = 2001
    Instance.new("UICorner", LoadingContainer).CornerRadius = UDim.new(0, 8)
    AddStroke(LoadingContainer, 1, Config.Theme.HackerGreen)
    
    local LoadingText = Instance.new("TextLabel", LoadingContainer)
    LoadingText.Size = UDim2.new(0.9, 0, 0.7, 0)
    LoadingText.Position = UDim2.new(0.05, 0, 0.1, 0)
    LoadingText.BackgroundTransparency = 1
    LoadingText.TextColor3 = Config.Theme.HackerGreen
    LoadingText.Font = Enum.Font.Code
    LoadingText.TextSize = 11
    LoadingText.TextXAlignment = "Left"
    LoadingText.TextYAlignment = "Top"
    LoadingText.Text = "> ACCESS VIP VERIFIED..."
    LoadingText.ZIndex = 2002
    
    local dotsConnection
    dotsConnection = RunService.Heartbeat:Connect(function() end)
    
    return LoadingFrame, LoadingText, dotsConnection
end

-- Header
local Header = Instance.new("Frame", AppWindow)
Header.Size = UDim2.new(1, 0, 0, 50)
Header.BackgroundTransparency = 1

local Avatar = Instance.new("ImageLabel", Header)
Avatar.Image = Config.LogoID
Avatar.Size = UDim2.new(0, 30, 0, 30)
Avatar.Position = UDim2.new(0, 15, 0.5, -15)
Avatar.BackgroundTransparency = 1

local Username = Instance.new("TextLabel", Header)
Username.Text = Config.Title
Username.Size = UDim2.new(0, 160, 0, 20)
Username.Position = UDim2.new(0, 55, 0.5, -10)
Username.TextColor3 = Config.Theme.Text
Username.Font = Enum.Font.GothamBlack
Username.TextSize = 14
Username.TextXAlignment = "Left"
Username.BackgroundTransparency = 1

-- Minimize Button
local MinimizedApp = Instance.new("TextButton", ScreenGui)
MinimizedApp.Size = UDim2.new(0, 45, 0, 45)
MinimizedApp.Position = UDim2.new(0.02, 0, 0.02, 0)
MinimizedApp.BackgroundColor3 = Config.Theme.Background
MinimizedApp.Visible = false
MinimizedApp.Text = ""
Instance.new("UICorner", MinimizedApp).CornerRadius = UDim.new(0, 8)
AddStroke(MinimizedApp, 2)

local MinIcon = Instance.new("ImageLabel", MinimizedApp)
MinIcon.Size = UDim2.new(0.6, 0, 0.6, 0)
MinIcon.Position = UDim2.new(0.2, 0, 0.2, 0)
MinIcon.Image = Config.LogoID
MinIcon.BackgroundTransparency = 1

-- Search
local Search = Instance.new("TextBox", Header)
Search.Size = UDim2.new(0, 100, 0, 24)
Search.Position = UDim2.new(1, -220, 0.5, -12)
Search.Text = ""
Search.PlaceholderText = "Search..."
Search.BackgroundColor3 = Config.Theme.Card
Search.TextColor3 = Color3.new(1,1,1)
Search.Font = Enum.Font.GothamBold
Search.TextSize = 11
Instance.new("UICorner", Search)
AddStroke(Search, 0.5)

-- Header Buttons
local function makeBtn(txt, x, col, func)
    local b = Instance.new("TextButton", Header)
    b.Size = UDim2.new(0, 28, 0, 28)
    b.Position = UDim2.new(1, x, 0.5, -14)
    b.BackgroundColor3 = col
    b.Text = txt
    b.Font = Enum.Font.GothamBlack
    b.TextSize = 14
    b.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(func)
end

makeBtn("×", -35, Color3.fromRGB(180, 0, 0), function() ScreenGui:Destroy() end)
makeBtn("−", -70, Config.Theme.Card, function() AppWindow.Visible = false MinimizedApp.Visible = true end)
makeBtn("ℹ", -105, Color3.fromRGB(50, 50, 50), function()
    if AppWindow:FindFirstChild("InfoPanel") then AppWindow.InfoPanel:Destroy() else
        local p = Instance.new("Frame", AppWindow)
        p.Name = "InfoPanel"
        p.Size = UDim2.new(0, 220, 0, 150)
        p.Position = UDim2.new(0.5, -110, 0.5, -75)
        p.BackgroundColor3 = Config.Theme.Card
        p.ZIndex = 500
        Instance.new("UICorner", p)
        AddStroke(p, 1)
        local t = Instance.new("TextLabel", p)
        t.Size = UDim2.new(1, -30, 1, -20)
        t.Position = UDim2.new(0, 15, 0, 10)
        t.BackgroundTransparency = 1
        t.TextColor3 = Color3.new(1,1,1)
        t.Font = Enum.Font.GothamBold
        t.TextSize = 11
        t.TextXAlignment = "Left"
        t.Text = "• Key Access : Lifetime\n• User : VIP\n• Version : PRIVATE\n• Created By : Anonymous9x\n• Tiktok : @anonymous9x_"
        t.ZIndex = 501
        local cl = Instance.new("TextButton", p)
        cl.Size = UDim2.new(1,0,1,0)
        cl.BackgroundTransparency = 1
        cl.Text = ""
        cl.ZIndex = 502
        cl.MouseButton1Click:Connect(function() p:Destroy() end)
    end
end)

-- Scrolling Frame
local Scroll = Instance.new("ScrollingFrame", AppWindow)
Scroll.Size = UDim2.new(1, -20, 0, 190)
Scroll.Position = UDim2.new(0, 10, 0, 60)
Scroll.BackgroundTransparency = 1
Scroll.ScrollBarThickness = 6
Scroll.ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255)
Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
Scroll.BorderSizePixel = 0

local ScrollPadding = Instance.new("UIPadding", Scroll)
ScrollPadding.PaddingTop = UDim.new(0, 12)
ScrollPadding.PaddingBottom = UDim.new(0, 12)

local Layout = Instance.new("UIListLayout", Scroll)
Layout.FillDirection = Enum.FillDirection.Horizontal
Layout.Padding = UDim.new(0, 15)
Layout.SortOrder = Enum.SortOrder.LayoutOrder

Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    Scroll.CanvasSize = UDim2.new(0, Layout.AbsoluteContentSize.X, 0, 0)
end)

animatedCards = {}
cardStrokes = {}

for _, s in ipairs(Config.Scripts) do
    local Card = Instance.new("Frame", Scroll)
    Card.Name = s.Name
    Card.Size = UDim2.new(0, 140, 0, 180)
    Card.BackgroundColor3 = Config.Theme.Card
    Card.LayoutOrder = _
    Instance.new("UICorner", Card)
    local stroke = AddStroke(Card, 1)
    table.insert(cardStrokes, stroke)
    table.insert(animatedCards, Card)
    
    local I = Instance.new("TextLabel", Card)
    I.Text = s.Icon
    I.Size = UDim2.new(1, 0, 0, 35)
    I.Position = UDim2.new(0, 0, 0, 10)
    I.TextColor3 = Color3.new(1,1,1)
    I.Font = Enum.Font.GothamBlack
    I.TextSize = 16
    I.BackgroundTransparency = 1
    
    local N = Instance.new("TextLabel", Card)
    N.Text = s.Name
    N.Size = UDim2.new(1, -10, 0, 20)
    N.Position = UDim2.new(0, 5, 0, 45)
    N.TextColor3 = Color3.new(1,1,1)
    N.Font = Enum.Font.GothamBlack
    N.TextSize = 12
    N.BackgroundTransparency = 1
    
    local D = Instance.new("TextLabel", Card)
    D.Text = s.Desc
    D.Size = UDim2.new(1,-20,0,60)
    D.Position = UDim2.new(0,10,0,75)
    D.TextColor3 = Color3.fromRGB(180,180,180)
    D.Font = Enum.Font.GothamBold
    D.TextSize = 9
    D.TextWrapped = true
    D.TextXAlignment = "Left"
    D.TextYAlignment = "Top"
    D.BackgroundTransparency = 1

    local L = Instance.new("TextButton", Card)
    L.Text = "EXECUTE"
    L.Size = UDim2.new(0.85, 0, 0, 28)
    L.Position = UDim2.new(0.075, 0, 1, -35)
    L.BackgroundColor3 = Color3.new(1,1,1)
    L.TextColor3 = Color3.new(0,0,0)
    L.Font = Enum.Font.GothamBlack
    L.TextSize = 10
    Instance.new("UICorner", L).CornerRadius = UDim.new(0, 6)
    L.MouseButton1Click:Connect(function() if s.URL ~= "" then loadstring(game:HttpGet(s.URL))() end end)
end

-- Marquee
local MarqueeContainer = Instance.new("Frame", AppWindow)
MarqueeContainer.Size = UDim2.new(1, -20, 0, 15)
MarqueeContainer.Position = UDim2.new(0, 10, 1, -63)
MarqueeContainer.BackgroundTransparency = 1
MarqueeContainer.ClipsDescendants = true

local MarqueeText = Instance.new("TextLabel", MarqueeContainer)
MarqueeText.Size = UDim2.new(0, 400, 1, 0)
MarqueeText.Position = UDim2.new(1, 0, 0, 0)
MarqueeText.BackgroundTransparency = 1
MarqueeText.TextColor3 = Config.Theme.HackerGreen
MarqueeText.Font = Enum.Font.Code
MarqueeText.TextSize = 10
MarqueeText.Text = "NOT GREAT BUT GROWING AND LEARNING || THX FOR YOUR SUPPORT AND PURCHASES LOVE YOU ALL"
MarqueeText.TextXAlignment = Enum.TextXAlignment.Left

task.spawn(function()
    while true do
        MarqueeText.Position = UDim2.new(1, 0, 0, 0)
        local tween = TweenService:Create(MarqueeText, TweenInfo.new(10, Enum.EasingStyle.Linear), {Position = UDim2.new(-1.2, 0, 0, 0)})
        tween:Play()
        tween.Completed:Wait()
    end
end)

-- Footer
local Footer = Instance.new("Frame", AppWindow)
Footer.Size = UDim2.new(1, -20, 0, 35)
Footer.Position = UDim2.new(0, 10, 1, -45)
Footer.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
Instance.new("UICorner", Footer)
AddStroke(Footer, 1, Config.Theme.HackerGreen)

local TerminalTxt = Instance.new("TextLabel", Footer)
TerminalTxt.Size = UDim2.new(0.75, 0, 1, 0)
TerminalTxt.Position = UDim2.new(0.025, 0, 0, 0)
TerminalTxt.BackgroundTransparency = 1
TerminalTxt.TextColor3 = Config.Theme.HackerGreen
TerminalTxt.Font = Enum.Font.Code
TerminalTxt.TextSize = 10
TerminalTxt.TextXAlignment = "Left"
TerminalTxt.Text = "> INITIALIZING MONITOR..."

-- Tombol toggle "C"
local ToggleBackgroundBtn = Instance.new("TextButton", Footer)
ToggleBackgroundBtn.Size = UDim2.new(0, 24, 0, 24)
ToggleBackgroundBtn.Position = UDim2.new(0.88, 0, 0.5, -12)
ToggleBackgroundBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
ToggleBackgroundBtn.Text = "C"
ToggleBackgroundBtn.Font = Enum.Font.GothamBlack
ToggleBackgroundBtn.TextSize = 14
ToggleBackgroundBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", ToggleBackgroundBtn)

ToggleBackgroundBtn.MouseButton1Click:Connect(function()
    AnimBackgroundEnabled = not AnimBackgroundEnabled
    updateVisualMode()
end)

-- Monitor
local function StartMonitor()
    task.spawn(function()
        while task.wait(0.5) do
            local ping = "0ms"
            pcall(function() ping = math.floor(StatsService.Network.ServerStatsItem["Data Ping"]:GetValue()) .. "ms" end)
            local mem = math.floor(StatsService:GetTotalMemoryUsageMb()) .. "MB"
            local fps = math.floor(1/RunService.RenderStepped:Wait())
            TerminalTxt.Text = string.format("> NET: %s | MEM: %s | FPS: %d | VIP ACTIVE", ping, mem, fps)
        end
    end)
end

-- Events
MinimizedApp.MouseButton1Click:Connect(function() AppWindow.Visible = true MinimizedApp.Visible = false end)
Search:GetPropertyChangedSignal("Text"):Connect(function()
    local q = Search.Text:lower()
    for _, card in pairs(Scroll:GetChildren()) do
        if card:IsA("Frame") then card.Visible = card.Name:lower():find(q) and true or false end
    end
end)

-- Mulai animasi
startRainLoop()
startBorderBlink()
startCinematicTextSequence()
updateVisualMode()

-- Initialize
local function InitializeGUI()
    AppWindow.Visible = true
    local LoadingFrame, LoadingText, dotsConnection = RunLoadingScreen()
    
    task.spawn(function()
        task.wait(1.2)
        LoadingText.Text = "> ACCESS VIP VERIFIED\n> ARE YOU READY?"
        task.wait(1.2)
        LoadingText.Text = "> ARE YOU READY?\n> LOADING MODULES..."
        task.wait(1.5)
        
        if dotsConnection then dotsConnection:Disconnect() end
        local fadeTween = TweenService:Create(LoadingFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {BackgroundTransparency = 1})
        fadeTween:Play()
        fadeTween.Completed:Connect(function()
            LoadingFrame:Destroy()
            StartMonitor()
            print(">> [ANONYMOUS9x VIP Main GUI]: Loaded Successfully!")
        end)
    end)
end

InitializeGUI()
