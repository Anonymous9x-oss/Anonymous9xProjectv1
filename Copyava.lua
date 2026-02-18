-- ================================================
-- ANONYMOUS9X COPY AVATAR v1.0
-- Real-time Player List with Horizontal Scroll
-- Fixed Visual Copy + Auto-Detect FE
-- Mobile & PC Compatible
-- ================================================

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- State
local State = {
    Minimized = false,
    PlayerCards = {},
    OriginalDescription = nil,
    CurrentMode = "Visual",
    BackdoorDetected = false,
    RemoteEvents = {}
}

-- ==================== DUAL MODE DETECTION ENGINE ====================

local function DetectBackdoorMethods()
    State.RemoteEvents = {}
    State.BackdoorDetected = false
    
    local potentialRemotes = {
        "UpdateAppearance", "ChangeAvatar", "SetCharacter", "AvatarUpdate",
        "ChangeOutfit", "UpdateCharacter", "Appearance", "CharacterUpdate",
        "ReplicateAvatar", "ServerAvatar", "FECharacter", "AppearanceRemote",
        "Character", "Avatar", "UpdatePlayer", "SetAppearance", "ChangeLook"
    }
    
    -- Scan ReplicatedStorage
    for _, name in ipairs(potentialRemotes) do
        local remote = ReplicatedStorage:FindFirstChild(name)
        if remote and (remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction")) then
            table.insert(State.RemoteEvents, {Name = name, Object = remote})
            State.BackdoorDetected = true
        end
    end
    
    return State.BackdoorDetected
end

-- ==================== NOTIFICATION SYSTEM ====================

local function ShowNotification(message, color, duration)
    duration = duration or 3
    
    local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
    
    -- Remove old notifications
    for _, v in ipairs(PlayerGui:GetChildren()) do
        if v.Name == "AvatarCopyNotification" then
            v:Destroy()
        end
    end
    
    -- Create notification
    local notification = Instance.new("ScreenGui")
    notification.Name = "AvatarCopyNotification"
    notification.ResetOnSpawn = false
    notification.DisplayOrder = 1000
    notification.Parent = PlayerGui
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 0, 0, 40)
    frame.Position = UDim2.new(0.5, 0, 0.1, 0)
    frame.AnchorPoint = Vector2.new(0.5, 0)
    frame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    frame.BorderSizePixel = 0
    frame.BackgroundTransparency = 0.5
    frame.Parent = notification
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or Color3.fromRGB(255, 255, 255)
    stroke.Thickness = 2
    stroke.Transparency = 0.3
    stroke.Parent = frame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -20, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = message
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextTruncate = Enum.TextTruncate.AtEnd
    label.Parent = frame
    
    -- Animate in
    local tweenIn = TweenService:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, math.min(#message * 7 + 40, 400), 0, 40)
    })
    tweenIn:Play()
    
    -- Wait and animate out
    task.wait(duration)
    
    local tweenOut = TweenService:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
        Size = UDim2.new(0, 0, 0, 40),
        BackgroundTransparency = 1
    })
    tweenOut:Play()
    
    tweenOut.Completed:Wait()
    notification:Destroy()
end

-- ==================== FIXED COPY FUNCTIONS ====================

local function SaveOriginalAvatar()
    if State.OriginalDescription then return end
    local myCharacter = LocalPlayer.Character
    if not myCharacter then return end
    
    local myHumanoid = myCharacter:FindFirstChildOfClass("Humanoid")
    if not myHumanoid then return end
    
    local success, desc = pcall(function()
        return myHumanoid:GetAppliedDescription()
    end)
    
    if success and desc then
        State.OriginalDescription = desc
        print("[SAVE] Original avatar saved")
    end
end

local function CopyAvatarVisual(targetPlayer)
    -- Save original first time
    SaveOriginalAvatar()
    
    -- METHOD 1: Get HumanoidDescription from UserId (WORKING METHOD)
    local success, targetDescription = pcall(function()
        return Players:GetHumanoidDescriptionFromUserId(targetPlayer.UserId)
    end)
    
    if not success or not targetDescription then
        ShowNotification("❌ Failed to get avatar data", Color3.fromRGB(255, 50, 50), 2)
        return false, "Failed to get avatar description"
    end
    
    local myCharacter = LocalPlayer.Character
    if not myCharacter then
        ShowNotification("❌ Your character not found", Color3.fromRGB(255, 50, 50), 2)
        return false, "Your character not found"
    end
    
    local myHumanoid = myCharacter:FindFirstChildOfClass("Humanoid")
    if not myHumanoid then
        ShowNotification("❌ Your humanoid not found", Color3.fromRGB(255, 50, 50), 2)
        return false, "Your humanoid not found"
    end
    
    -- Clear current appearance first
    pcall(function()
        for _, obj in ipairs(myCharacter:GetChildren()) do
            if obj:IsA("Accessory") or obj:IsA("Shirt") or obj:IsA("Pants") or obj:IsA("ShirtGraphic") then
                obj:Destroy()
            end
        end
    end)
    
    -- Apply new description
    local applySuccess = false
    
    if pcall(function() return myHumanoid.ApplyDescriptionClientServer end) then
        applySuccess = pcall(function()
            myHumanoid:ApplyDescriptionClientServer(targetDescription)
        end)
    end
    
    if not applySuccess then
        applySuccess = pcall(function()
            myHumanoid:ApplyDescription(targetDescription)
        end)
    end
    
    if applySuccess then
        ShowNotification("✅ Visual copy successful!", Color3.fromRGB(100, 255, 100), 2)
        return true, "Visual copy successful"
    else
        ShowNotification("❌ Failed to apply avatar", Color3.fromRGB(255, 50, 50), 2)
        return false, "Failed to apply description"
    end
end

local function CopyAvatarFE(targetPlayer)
    if not State.BackdoorDetected or #State.RemoteEvents == 0 then
        return false, "No backdoor detected"
    end
    
    -- Get target description
    local success, targetDescription = pcall(function()
        return Players:GetHumanoidDescriptionFromUserId(targetPlayer.UserId)
    end)
    
    if not success or not targetDescription then
        return false, "Failed to get avatar description"
    end
    
    SaveOriginalAvatar()
    
    -- Try all detected remotes
    for _, remoteData in ipairs(State.RemoteEvents) do
        local remote = remoteData.Object
        local remoteSuccess = pcall(function()
            if remote:IsA("RemoteEvent") then
                remote:FireServer(LocalPlayer, targetDescription)
                return true
            elseif remote:IsA("RemoteFunction") then
                remote:InvokeServer(LocalPlayer, targetDescription)
                return true
            end
            return false
        end)
        
        if remoteSuccess then
            State.CurrentMode = "FE"
            return true, "FE via " .. remoteData.Name
        end
    end
    
    return false, "All FE methods failed"
end

local function CopyAvatar(targetPlayer)
    -- First, try FE if available
    if State.BackdoorDetected then
        local feSuccess, feMessage = CopyAvatarFE(targetPlayer)
        
        if feSuccess then
            ShowNotification("✅ FE Copy Successful!", Color3.fromRGB(0, 255, 100), 4)
            ShowNotification("Others can see your avatar!", Color3.fromRGB(255, 200, 0), 3)
            return true
        else
            print("[COPY] FE failed: " .. tostring(feMessage))
        end
    end
    
    -- Always fallback to visual
    local visualSuccess, visualMessage = CopyAvatarVisual(targetPlayer)
    
    if visualSuccess then
        ShowNotification("👁️ Visual Copy Completed", Color3.fromRGB(100, 150, 255), 3)
        State.CurrentMode = "Visual"
        return true
    else
        ShowNotification("❌ Copy failed", Color3.fromRGB(255, 50, 50), 3)
        return false
    end
end

local function ResetAvatar()
    if not State.OriginalDescription then
        ShowNotification("❌ No original avatar saved", Color3.fromRGB(255, 50, 50), 2)
        return
    end
    
    local myCharacter = LocalPlayer.Character
    if not myCharacter then
        ShowNotification("❌ Character not found", Color3.fromRGB(255, 50, 50), 2)
        return
    end
    
    local myHumanoid = myCharacter:FindFirstChildOfClass("Humanoid")
    if not myHumanoid then
        ShowNotification("❌ Humanoid not found", Color3.fromRGB(255, 50, 50), 2)
        return
    end
    
    -- Clear current appearance
    pcall(function()
        for _, obj in ipairs(myCharacter:GetChildren()) do
            if obj:IsA("Accessory") or obj:IsA("Shirt") or obj:IsA("Pants") or obj:IsA("ShirtGraphic") then
                obj:Destroy()
            end
        end
    end)
    
    -- Apply original description
    local success = false
    
    if pcall(function() return myHumanoid.ApplyDescriptionClientServer end) then
        success = pcall(function()
            myHumanoid:ApplyDescriptionClientServer(State.OriginalDescription)
        end)
    end
    
    if not success then
        success = pcall(function()
            myHumanoid:ApplyDescription(State.OriginalDescription)
        end)
    end
    
    if success then
        ShowNotification("🔄 Avatar reset successfully!", Color3.fromRGB(100, 200, 255), 2)
    else
        ShowNotification("⚠️ Reset partially completed", Color3.fromRGB(255, 150, 0), 2)
    end
end

local function GetPlayerThumbnail(userId)
    return "rbxthumb://type=AvatarHeadShot&id=" .. userId .. "&w=150&h=150"
end

-- ==================== UI CREATION ====================

local function CreateUI()
    local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
    
    -- Remove old UI if exists
    local oldUI = PlayerGui:FindFirstChild("AvatarCopyUI")
    if oldUI then oldUI:Destroy() end
    
    -- Main ScreenGui
    local gui = Instance.new("ScreenGui")
    gui.Name = "AvatarCopyUI"
    gui.ResetOnSpawn = false
    gui.DisplayOrder = 999
    gui.IgnoreGuiInset = true
    gui.Parent = PlayerGui
    
    -- Main Frame (Container)
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 0, 0, 0)
    mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    mainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = gui
    
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 12)
    mainCorner.Parent = mainFrame
    
    local mainStroke = Instance.new("UIStroke")
    mainStroke.Color = Color3.fromRGB(255, 255, 255)
    mainStroke.Thickness = 2
    mainStroke.Transparency = 0.3
    mainStroke.Parent = mainFrame
    
    -- Title Bar
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 35)
    titleBar.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 12)
    titleCorner.Parent = titleBar
    
    -- Title Label (TEKS LEBIH PENDEK, TEXT TRUNCATE)
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "TitleLabel"
    titleLabel.Size = UDim2.new(1, -80, 1, 0)
    titleLabel.Position = UDim2.new(0, 10, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "ANONYMOUS9X COPY AVATAR | Detecting..."
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 13
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.TextTruncate = Enum.TextTruncate.AtEnd
    titleLabel.Parent = titleBar
    
    -- Minimize Button
    local minimizeBtn = Instance.new("TextButton")
    minimizeBtn.Name = "MinimizeBtn"
    minimizeBtn.Size = UDim2.new(0, 30, 0, 30)
    minimizeBtn.Position = UDim2.new(1, -65, 0, 2.5)
    minimizeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    minimizeBtn.Text = "-"
    minimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    minimizeBtn.Font = Enum.Font.GothamBold
    minimizeBtn.TextSize = 18
    minimizeBtn.BorderSizePixel = 0
    minimizeBtn.Parent = titleBar
    
    local minimizeCorner = Instance.new("UICorner")
    minimizeCorner.CornerRadius = UDim.new(0, 6)
    minimizeCorner.Parent = minimizeBtn
    
    -- Close Button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "CloseBtn"
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -32, 0, 2.5)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
    closeBtn.Text = "×"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 20
    closeBtn.BorderSizePixel = 0
    closeBtn.Parent = titleBar
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 6)
    closeCorner.Parent = closeBtn
    
    -- Content Frame
    local contentFrame = Instance.new("Frame")
    contentFrame.Name = "ContentFrame"
    contentFrame.Size = UDim2.new(1, 0, 1, -35)
    contentFrame.Position = UDim2.new(0, 0, 0, 35)
    contentFrame.BackgroundTransparency = 1
    contentFrame.ClipsDescendants = true
    contentFrame.Parent = mainFrame
    
    -- Reset Button
    local resetBtn = Instance.new("TextButton")
    resetBtn.Name = "ResetBtn"
    resetBtn.Size = UDim2.new(0, 100, 0, 30)
    resetBtn.Position = UDim2.new(0.5, -50, 0, 5)
    resetBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    resetBtn.Text = "Reset Avatar"
    resetBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
    resetBtn.Font = Enum.Font.GothamBold
    resetBtn.TextSize = 11
    resetBtn.BorderSizePixel = 0
    resetBtn.Parent = contentFrame
    
    local resetCorner = Instance.new("UICorner")
    resetCorner.CornerRadius = UDim.new(0, 6)
    resetCorner.Parent = resetBtn
    
    -- Player Count Label
    local playerCountLabel = Instance.new("TextLabel")
    playerCountLabel.Name = "PlayerCountLabel"
    playerCountLabel.Size = UDim2.new(1, -20, 0, 20)
    playerCountLabel.Position = UDim2.new(0, 10, 0, 42)
    playerCountLabel.BackgroundTransparency = 1
    playerCountLabel.Text = "Players: 0 | Status: Ready"
    playerCountLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    playerCountLabel.Font = Enum.Font.GothamBold
    playerCountLabel.TextSize = 10
    playerCountLabel.TextXAlignment = Enum.TextXAlignment.Left
    playerCountLabel.TextTruncate = Enum.TextTruncate.AtEnd
    playerCountLabel.Parent = contentFrame
    
    -- Scrolling Frame (Horizontal)
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Name = "PlayerScrollFrame"
    scrollFrame.Size = UDim2.new(1, -20, 1, -72)
    scrollFrame.Position = UDim2.new(0, 10, 0, 62)
    scrollFrame.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
    scrollFrame.BorderSizePixel = 0
    scrollFrame.ScrollBarThickness = 6
    scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255)
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrollFrame.ScrollingDirection = Enum.ScrollingDirection.X
    scrollFrame.HorizontalScrollBarInset = Enum.ScrollBarInset.ScrollBar
    scrollFrame.Parent = contentFrame
    
    local scrollCorner = Instance.new("UICorner")
    scrollCorner.CornerRadius = UDim.new(0, 8)
    scrollCorner.Parent = scrollFrame
    
    local scrollStroke = Instance.new("UIStroke")
    scrollStroke.Color = Color3.fromRGB(255, 255, 255)
    scrollStroke.Thickness = 1
    scrollStroke.Transparency = 0.5
    scrollStroke.Parent = scrollFrame
    
    -- UIListLayout
    local listLayout = Instance.new("UIListLayout")
    listLayout.FillDirection = Enum.FillDirection.Horizontal
    listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    listLayout.VerticalAlignment = Enum.VerticalAlignment.Top
    listLayout.Padding = UDim.new(0, 8)
    listLayout.Parent = scrollFrame
    
    local listPadding = Instance.new("UIPadding")
    listPadding.PaddingLeft = UDim.new(0, 8)
    listPadding.PaddingRight = UDim.new(0, 8)
    listPadding.PaddingTop = UDim.new(0, 8)
    listPadding.PaddingBottom = UDim.new(0, 8)
    listPadding.Parent = scrollFrame
    
    return {
        Gui = gui,
        MainFrame = mainFrame,
        ScrollFrame = scrollFrame,
        PlayerCountLabel = playerCountLabel,
        MinimizeBtn = minimizeBtn,
        CloseBtn = closeBtn,
        ResetBtn = resetBtn,
        ContentFrame = contentFrame,
        TitleLabel = titleLabel
    }
end

-- ==================== PLAYER CARD CREATION ====================

local function CreatePlayerCard(player, scrollFrame)
    local card = Instance.new("Frame")
    card.Name = "PlayerCard_" .. player.UserId
    card.Size = UDim2.new(0, 140, 0, 180)
    card.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    card.BorderSizePixel = 0
    card.Parent = scrollFrame
    
    local cardCorner = Instance.new("UICorner")
    cardCorner.CornerRadius = UDim.new(0, 8)
    cardCorner.Parent = card
    
    local cardStroke = Instance.new("UIStroke")
    cardStroke.Color = Color3.fromRGB(255, 255, 255)
    cardStroke.Thickness = 1
    cardStroke.Transparency = 0.5
    cardStroke.Parent = card
    
    -- Avatar Thumbnail
    local thumbnail = Instance.new("ImageLabel")
    thumbnail.Name = "Thumbnail"
    thumbnail.Size = UDim2.new(0, 80, 0, 80)
    thumbnail.Position = UDim2.new(0.5, -40, 0, 10)
    thumbnail.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    thumbnail.BorderSizePixel = 0
    thumbnail.Image = GetPlayerThumbnail(player.UserId)
    thumbnail.Parent = card
    
    local thumbCorner = Instance.new("UICorner")
    thumbCorner.CornerRadius = UDim.new(0, 8)
    thumbCorner.Parent = thumbnail
    
    -- Player Name (WHITE TEXT - POSISI FIXED)
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "NameLabel"
    nameLabel.Size = UDim2.new(1, -10, 0, 20)
    nameLabel.Position = UDim2.new(0, 5, 0, 95)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = player.Name
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 11
    nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
    nameLabel.Parent = card
    
    -- User ID
    local idLabel = Instance.new("TextLabel")
    idLabel.Name = "IDLabel"
    idLabel.Size = UDim2.new(1, -10, 0, 16)
    idLabel.Position = UDim2.new(0, 5, 0, 115)
    idLabel.BackgroundTransparency = 1
    idLabel.Text = "ID: " .. player.UserId
    idLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    idLabel.Font = Enum.Font.Code
    idLabel.TextSize = 9
    idLabel.Parent = card
    
    -- Copy Button (MERAH dengan border putih)
    local copyBtn = Instance.new("TextButton")
    copyBtn.Name = "CopyBtn"
    copyBtn.Size = UDim2.new(1, -16, 0, 28)
    copyBtn.Position = UDim2.new(0, 8, 1, -40)
    copyBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    copyBtn.Text = "Copy Avatar"
    copyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    copyBtn.Font = Enum.Font.GothamBold
    copyBtn.TextSize = 10
    copyBtn.BorderSizePixel = 0
    copyBtn.Parent = card
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = copyBtn
    
    local btnStroke = Instance.new("UIStroke")
    btnStroke.Color = Color3.fromRGB(255, 255, 255)
    btnStroke.Thickness = 1
    btnStroke.Transparency = 0.3
    btnStroke.Parent = copyBtn
    
    -- Copy button functionality
    copyBtn.MouseButton1Click:Connect(function()
        local success = CopyAvatar(player)
        
        -- Visual feedback
        local originalColor = copyBtn.BackgroundColor3
        if success then
            copyBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
            copyBtn.Text = "Copied!"
        else
            copyBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
            copyBtn.Text = "Failed!"
        end
        
        task.wait(1)
        copyBtn.BackgroundColor3 = originalColor
        copyBtn.Text = "Copy Avatar"
    end)
    
    -- Hover effect
    copyBtn.MouseEnter:Connect(function()
        local tween = TweenService:Create(copyBtn, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(220, 70, 70)
        })
        tween:Play()
    end)
    
    copyBtn.MouseLeave:Connect(function()
        local tween = TweenService:Create(copyBtn, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        })
        tween:Play()
    end)
    
    return card
end

-- ==================== MAIN INITIALIZATION ====================

local function Initialize()
    print("════════════════════════════════════")
    print("ANONYMOUS9X COPY AVATAR v1.0")
    print("UI + NO DRAG + SCROLL")
    print("════════════════════════════════════")
    
    -- Create UI
    local ui = CreateUI()
    
    -- Animate UI entrance (tetap di tengah)
    local targetSize = UDim2.new(0, 500, 0, 280)
    local entranceTween = TweenService:Create(ui.MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = targetSize
    })
    entranceTween:Play()
    
    -- Initial detection
    DetectBackdoorMethods()
    
    -- Update title based on mode (TEKS LEBIH PENDEK)
    if State.BackdoorDetected then
        ui.TitleLabel.Text = "ANONYMOUS9X | FE MODE"
    else
        ui.TitleLabel.Text = "ANONYMOUS9X | VISUAL MODE"
    end
    
    -- Function to update player list
    local function UpdatePlayerList()
        -- Clear existing cards
        for userId, card in pairs(State.PlayerCards) do
            if card and card.Parent then
                card:Destroy()
            end
        end
        State.PlayerCards = {}
        
        -- Create cards for all players except LocalPlayer
        local playerCount = 0
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                local card = CreatePlayerCard(player, ui.ScrollFrame)
                State.PlayerCards[player.UserId] = card
                playerCount = playerCount + 1
            end
        end
        
        -- Update player count with real-time status
        local statusText = ""
        if State.BackdoorDetected then
            statusText = "FE MODE | " .. playerCount .. " players"
        else
            statusText = "VISUAL MODE | " .. playerCount .. " players"
        end
        
        ui.PlayerCountLabel.Text = "Status: " .. statusText
        
        -- Update canvas size for horizontal scrolling
        local listLayout = ui.ScrollFrame:FindFirstChildOfClass("UIListLayout")
        if listLayout then
            ui.ScrollFrame.CanvasSize = UDim2.new(0, listLayout.AbsoluteContentSize.X + 16, 0, 0)
        end
    end
    
    -- Initial update
    UpdatePlayerList()
    
    -- Player events for real-time updates
    Players.PlayerAdded:Connect(function(player)
        task.wait(0.5)
        if not State.Minimized then
            UpdatePlayerList()
        end
    end)
    
    Players.PlayerRemoving:Connect(function(player)
        if State.PlayerCards[player.UserId] then
            State.PlayerCards[player.UserId]:Destroy()
            State.PlayerCards[player.UserId] = nil
        end
        UpdatePlayerList()
    end)
    
    -- UI Events
    ui.MinimizeBtn.MouseButton1Click:Connect(function()
        State.Minimized = not State.Minimized
        
        if State.Minimized then
            TweenService:Create(ui.MainFrame, TweenInfo.new(0.3), {
                Size = UDim2.new(0, 250, 0, 35)
            }):Play()
            ui.ContentFrame.Visible = false
            ui.MinimizeBtn.Text = "+"
        else
            TweenService:Create(ui.MainFrame, TweenInfo.new(0.3), {
                Size = targetSize
            }):Play()
            ui.ContentFrame.Visible = true
            ui.MinimizeBtn.Text = "-"
        end
    end)
    
    ui.CloseBtn.MouseButton1Click:Connect(function()
        TweenService:Create(ui.MainFrame, TweenInfo.new(0.3), {
            Size = UDim2.new(0, 0, 0, 0)
        }):Play()
        task.wait(0.3)
        ui.Gui:Destroy()
        ShowNotification("UI Closed", Color3.fromRGB(150, 150, 150), 2)
    end)
    
    ui.ResetBtn.MouseButton1Click:Connect(function()
        ResetAvatar()
        
        -- Visual feedback for reset button
        local originalColor = ui.ResetBtn.BackgroundColor3
        ui.ResetBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        ui.ResetBtn.Text = "Reset!"
        task.wait(1)
        ui.ResetBtn.BackgroundColor3 = originalColor
        ui.ResetBtn.Text = "Reset Avatar"
    end)
    
    -- Auto-refresh player list every 5 seconds
    while task.wait(5) do
        if not State.Minimized then
            UpdatePlayerList()
        end
    end
    
    print("✓ UI Loaded Successfully")
    print("✓ Mode: " .. (State.BackdoorDetected and "FE" or "VISUAL"))
    print("✓ Real-time player tracking: Enabled")
    print("✓ No drag feature, centered position")
    print("════════════════════════════════════")
end

-- Start
Initialize()
