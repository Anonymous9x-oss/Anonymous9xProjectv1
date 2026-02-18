-- Anonymous9x Emote FE Universal
-- Simple UI with list-based selection

local ContextActionService = game:GetService("ContextActionService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local AvatarEditorService = game:GetService("AvatarEditorService")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer
local Emotes = {}
local CurrentEmote = nil
local FavoritedEmotes = {}

-- Add emote function
local function AddEmote(name, id, price)
    if not (name and id) then
        return
    end
    table.insert(Emotes, {
        name = name,
        id = id,
        price = price or 0
    })
end

-- Notification function
local function SendNotification(title, text)
    StarterGui:SetCore("SendNotification", {
        Title = title,
        Text = text,
        Duration = 3
    })
end

-- Play emote function (R6 and R15 support)
local function PlayEmote(emoteName, emoteId)
    local Character = LocalPlayer.Character
    if not Character then return end
    
    local Humanoid = Character:FindFirstChildOfClass("Humanoid")
    if not Humanoid then return end
    
    -- Stop current animations first
    local AnimationTrack = Humanoid:GetPlayingAnimationTracks()
    for _, track in pairs(AnimationTrack) do
        track:Stop()
    end
    
    -- Play emote based on rig type
    if Humanoid.RigType == Enum.HumanoidRigType.R15 then
        -- R15 uses native emote system
        Humanoid:PlayEmote(emoteName)
    else
        -- R6 uses animation loading
        local Animation = Instance.new("Animation")
        Animation.AnimationId = "rbxassetid://" .. emoteId
        
        local Animator = Humanoid:FindFirstChildOfClass("Animator")
        if not Animator then
            Animator = Instance.new("Animator", Humanoid)
        end
        
        local Track = Animator:LoadAnimation(Animation)
        Track:Play()
        
        Animation:Destroy()
    end
end

-- Stop current emote
local function StopCurrentEmote()
    local Character = LocalPlayer.Character
    if not Character then return end
    
    local Humanoid = Character:FindFirstChildOfClass("Humanoid")
    if not Humanoid then return end
    
    local AnimationTrack = Humanoid:GetPlayingAnimationTracks()
    for _, track in pairs(AnimationTrack) do
        track:Stop()
    end
end

-- Create UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Anonymous9xEmote"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Main Frame (draggable)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 250, 0, 350)
MainFrame.Position = UDim2.new(0.5, -125, 0.5, -175)
MainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 8)
MainCorner.Parent = MainFrame

-- Title bar
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 35)
TitleBar.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = TitleBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(0.6, 0, 1, 0)
TitleLabel.Position = UDim2.new(0, 10, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "Anonymous9x Emote"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 14
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TitleBar

-- Minimize button
local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Name = "MinimizeBtn"
MinimizeBtn.Size = UDim2.new(0, 30, 0, 25)
MinimizeBtn.Position = UDim2.new(1, -70, 0, 5)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MinimizeBtn.Text = "_"
MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeBtn.TextSize = 18
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.BorderSizePixel = 0
MinimizeBtn.Parent = TitleBar

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 4)
MinCorner.Parent = MinimizeBtn

-- Close button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Name = "CloseBtn"
CloseBtn.Size = UDim2.new(0, 30, 0, 25)
CloseBtn.Position = UDim2.new(1, -35, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 30, 30)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 14
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.BorderSizePixel = 0
CloseBtn.Parent = TitleBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 4)
CloseCorner.Parent = CloseBtn

-- Content Frame
local ContentFrame = Instance.new("Frame")
ContentFrame.Name = "ContentFrame"
ContentFrame.Size = UDim2.new(1, -10, 1, -45)
ContentFrame.Position = UDim2.new(0, 5, 0, 40)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

-- Scrolling Frame for emotes list
local EmoteList = Instance.new("ScrollingFrame")
EmoteList.Name = "EmoteList"
EmoteList.Size = UDim2.new(1, 0, 1, 0)
EmoteList.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
EmoteList.BorderSizePixel = 0
EmoteList.ScrollBarThickness = 6
EmoteList.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
EmoteList.CanvasSize = UDim2.new(0, 0, 0, 0)
EmoteList.AutomaticCanvasSize = Enum.AutomaticSize.Y
EmoteList.Parent = ContentFrame

local ListCorner = Instance.new("UICorner")
ListCorner.CornerRadius = UDim.new(0, 6)
ListCorner.Parent = EmoteList

local ListLayout = Instance.new("UIListLayout")
ListLayout.Padding = UDim.new(0, 2)
ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ListLayout.Parent = EmoteList

local ListPadding = Instance.new("UIPadding")
ListPadding.PaddingTop = UDim.new(0, 5)
ListPadding.PaddingBottom = UDim.new(0, 5)
ListPadding.PaddingLeft = UDim.new(0, 5)
ListPadding.PaddingRight = UDim.new(0, 5)
ListPadding.Parent = EmoteList

-- Loading text
local LoadingText = Instance.new("TextLabel")
LoadingText.Name = "LoadingText"
LoadingText.Size = UDim2.new(1, -10, 0, 40)
LoadingText.Position = UDim2.new(0, 5, 0.5, -20)
LoadingText.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
LoadingText.Text = "Loading Emotes..."
LoadingText.TextColor3 = Color3.fromRGB(255, 255, 255)
LoadingText.TextSize = 14
LoadingText.Font = Enum.Font.Gotham
LoadingText.BorderSizePixel = 0
LoadingText.Parent = ContentFrame

local LoadCorner = Instance.new("UICorner")
LoadCorner.CornerRadius = UDim.new(0, 6)
LoadCorner.Parent = LoadingText

-- Button functions
local isMinimized = false

MinimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    
    if isMinimized then
        ContentFrame.Visible = false
        MainFrame.Size = UDim2.new(0, 250, 0, 35)
        MinimizeBtn.Text = "+"
    else
        ContentFrame.Visible = true
        MainFrame.Size = UDim2.new(0, 250, 0, 350)
        MinimizeBtn.Text = "_"
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui.Enabled = false
end)

-- Load emotes from catalog
local function LoadEmotes()
    local params = CatalogSearchParams.new()
    params.AssetTypes = {Enum.AvatarAssetType.EmoteAnimation}
    params.SortType = Enum.CatalogSortType.RecentlyCreated
    params.SortAggregation = Enum.CatalogSortAggregation.AllTime
    params.IncludeOffSale = true
    params.CreatorName = "Roblox"
    params.Limit = 120
    
    local success, catalogPage = pcall(function()
        return AvatarEditorService:SearchCatalog(params)
    end)
    
    if not success then
        task.wait(2)
        return LoadEmotes()
    end
    
    local pages = {}
    
    while true do
        local currentPage = catalogPage:GetCurrentPage()
        table.insert(pages, currentPage)
        if catalogPage.IsFinished then
            break
        end
        
        local pageSuccess = pcall(function()
            catalogPage:AdvanceToNextPageAsync()
        end)
        
        if not pageSuccess then
            task.wait(2)
        end
    end
    
    for _, page in pairs(pages) do
        for _, emote in pairs(page) do
            AddEmote(emote.Name, emote.Id, emote.Price)
        end
    end
    
    -- Add unreleased and popular emotes
    AddEmote("Arm Wave", 5915773155)
    AddEmote("Head Banging", 5915779725)
    AddEmote("Face Calisthenics", 9830731012)
    AddEmote("Stadium", 3360686498)
    AddEmote("Shuffle", 3361276673)
    AddEmote("Wave", 3360686498)
    AddEmote("Point", 3361276673)
    AddEmote("Dance", 3361276673)
    AddEmote("Laugh", 3361276673)
    AddEmote("Cheer", 3361276673)
    AddEmote("Salute", 3360689775)
    AddEmote("Stadium Cheer", 3360686498)
    AddEmote("Curtsy", 3361276673)
    AddEmote("Bow", 3361276673)
    AddEmote("Tilt", 3361276673)
    AddEmote("Shrug", 3361276673)
    AddEmote("Barrel Roll", 3361276673)
    AddEmote("Scared", 3361276673)
    AddEmote("Insane", 3361276673)
    AddEmote("Hero Landing", 3361276673)
    AddEmote("Zombie Walk", 3361276673)
    AddEmote("Robot", 3361276673)
    AddEmote("Ninja Run", 3361276673)
    AddEmote("Werewolf", 3361276673)
    AddEmote("Elder", 3361276673)
    AddEmote("Levitate", 3361276673)
    AddEmote("Astronaut", 3361276673)
    AddEmote("Ninja Jump", 3361276673)
    AddEmote("Floss Dance", 4841397952)
    AddEmote("Heisman", 3361276673)
    AddEmote("Bunny Hop", 3361276673)
    AddEmote("Fashionable", 3361276673)
    AddEmote("Head Nod", 3361276673)
    AddEmote("Headless", 3361276673)
    AddEmote("Dizzy", 3361276673)
    AddEmote("Tilt Head", 3361276673)
    AddEmote("Sleep", 3361276673)
    AddEmote("Sit", 3361276673)
    AddEmote("Kick", 3361276673)
    AddEmote("Facepalm", 3361276673)
    AddEmote("Thinking", 3361276673)
    AddEmote("Crying", 3361276673)
    AddEmote("Confused", 3361276673)
    AddEmote("Shocked", 3361276673)
    AddEmote("Grin", 3361276673)
    AddEmote("Sad", 3361276673)
    AddEmote("Celebrate", 3361276673)
    AddEmote("Fall", 3361276673)
    AddEmote("Jump", 3361276673)
    AddEmote("Run", 3361276673)
    AddEmote("Swim", 3361276673)
    AddEmote("Climb", 3361276673)
    AddEmote("Die", 3361276673)
    AddEmote("Tool Slash", 3361276673)
    AddEmote("Tool Lunge", 3361276673)
    AddEmote("Idle Variation 1", 3361276673)
    AddEmote("Idle Variation 2", 3361276673)
    AddEmote("Idle Shiver", 3361276673)
    AddEmote("Superhero Idle", 3361276673)
    AddEmote("Zombie Idle", 3361276673)
    AddEmote("Stylish Idle", 3361276673)
    AddEmote("Popstar Idle", 3361276673)
    AddEmote("Princess Idle", 3361276673)
    AddEmote("Cowboy Idle", 3361276673)
    AddEmote("Ninja Idle", 3361276673)
    AddEmote("Werewolf Idle", 3361276673)
    AddEmote("Pirate Idle", 3361276673)
    AddEmote("Knight Idle", 3361276673)
    AddEmote("Mage Idle", 3361276673)
    AddEmote("Astronaut Idle", 3361276673)
    AddEmote("Bubbly Idle", 3361276673)
    AddEmote("Cartoony Idle", 3361276673)
    AddEmote("Elder Idle", 3361276673)
    AddEmote("Levitate Idle", 3361276673)
    AddEmote("Rthro Idle", 3361276673)
    AddEmote("Vampire Idle", 3361276673)
    AddEmote("Toy Idle", 3361276673)
    AddEmote("Confident", 3361276673)
    AddEmote("Happy", 3361276673)
    AddEmote("Angry", 3361276673)
    AddEmote("Relaxed", 3361276673)
    AddEmote("Energetic", 3361276673)
    AddEmote("Nervous", 3361276673)
    AddEmote("Determined", 3361276673)
    AddEmote("Peaceful", 3361276673)
    AddEmote("Excited", 3361276673)
    AddEmote("Bored", 3361276673)
    AddEmote("Victory", 3361276673)
    AddEmote("Defeat", 3361276673)
    AddEmote("Freeze", 3361276673)
    AddEmote("Electrocuted", 3361276673)
    AddEmote("Disappear", 3361276673)
    AddEmote("Appear", 3361276673)
    AddEmote("Float", 3361276673)
    AddEmote("Spin", 3361276673)
    AddEmote("Backflip", 3361276673)
    AddEmote("Cartwheel", 3361276673)
    AddEmote("Handstand", 3361276673)
    AddEmote("Split", 3361276673)
    
    -- Sort alphabetically
    table.sort(Emotes, function(a, b)
        return a.name:lower() < b.name:lower()
    end)
    
    return true
end

-- Create emote buttons
local function CreateEmoteButtons()
    local Character = LocalPlayer.Character
    if not Character then return end
    
    local Humanoid = Character:FindFirstChildOfClass("Humanoid")
    if not Humanoid then return end
    
    local Description = Humanoid:FindFirstChild("HumanoidDescription") or Instance.new("HumanoidDescription", Humanoid)
    
    -- Clear existing buttons
    for _, child in pairs(EmoteList:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    
    -- Create button for each emote
    for i, emote in pairs(Emotes) do
        Description:AddEmote(emote.name, emote.id)
        
        local EmoteBtn = Instance.new("TextButton")
        EmoteBtn.Name = emote.name
        EmoteBtn.Size = UDim2.new(1, -10, 0, 30)
        EmoteBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        EmoteBtn.Text = emote.name
        EmoteBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        EmoteBtn.TextSize = 12
        EmoteBtn.Font = Enum.Font.Gotham
        EmoteBtn.BorderSizePixel = 0
        EmoteBtn.LayoutOrder = i
        
        local BtnCorner = Instance.new("UICorner")
        BtnCorner.CornerRadius = UDim.new(0, 4)
        BtnCorner.Parent = EmoteBtn
        
        -- Click to play/stop emote
        EmoteBtn.MouseButton1Click:Connect(function()
            if CurrentEmote == emote.name then
                -- Stop current emote
                StopCurrentEmote()
                EmoteBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
                CurrentEmote = nil
            else
                -- Reset all buttons
                for _, btn in pairs(EmoteList:GetChildren()) do
                    if btn:IsA("TextButton") then
                        btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
                    end
                end
                
                -- Play new emote
                PlayEmote(emote.name, emote.id)
                EmoteBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
                CurrentEmote = emote.name
            end
        end)
        
        -- Hover effect
        EmoteBtn.MouseEnter:Connect(function()
            if CurrentEmote ~= emote.name then
                EmoteBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            end
        end)
        
        EmoteBtn.MouseLeave:Connect(function()
            if CurrentEmote ~= emote.name then
                EmoteBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            end
        end)
        
        EmoteBtn.Parent = EmoteList
    end
end

-- Initialize
local function Initialize()
    -- Load emotes
    local loaded = LoadEmotes()
    
    if loaded then
        LoadingText.Visible = false
        CreateEmoteButtons()
        
        -- Send notification
        SendNotification("Anonymous9x Emote", "Anonymous9x Emote Full Loaded")
    end
end

-- Character respawn handling
local function OnCharacterAdded(character)
    task.wait(1)
    CreateEmoteButtons()
end

if LocalPlayer.Character then
    OnCharacterAdded(LocalPlayer.Character)
end

LocalPlayer.CharacterAdded:Connect(OnCharacterAdded)

-- Parent ScreenGui
if gethui then
    ScreenGui.Parent = gethui()
elseif syn and syn.protect_gui then
    syn.protect_gui(ScreenGui)
    ScreenGui.Parent = game.CoreGui
else
    ScreenGui.Parent = game.CoreGui
end

-- Initialize
Initialize()

-- Toggle UI keybind (Comma key)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Comma then
        ScreenGui.Enabled = not ScreenGui.Enabled
    end
end)

print("Anonymous9x Emote Loaded - Press comma (,) to toggle UI")
