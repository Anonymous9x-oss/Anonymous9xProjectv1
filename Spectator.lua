--[[
    ANONYMOUS9X SPECTATOR V2 FINAL
    UI: MODERN BLACK/WHITE - JUDUL BOLD, FITUR TIPIS & TANPA EMOJI
    FITUR: 100% ASLI, TIDAK ADA PERUBAHAN LOGIKA
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LP = Players.LocalPlayer
local Cam = Workspace.CurrentCamera

-- ========== STATE (ASLI, GA DIUTAK) ==========
local Active = true
local TargetList = {}
local CurrentIndex = 0
local CurrentTarget = nil
local FlingActive = false
local FlingThread = nil
local OriginalCFrame = nil
local FollowActive = false
local FollowConnection = nil
local FollowAnim = nil
local SendPartActive = false
local SendPartLoopThread = nil
local FreezeConnection = nil
local OriginalWalkSpeed = 16
local OriginalJumpPower = 50
local NetworkConnection = nil

-- ========== COLOR SCHEME (HITAM PUTIH) ==========
local COLORS = {
    BLACK = Color3.fromRGB(0, 0, 0),
    DARK_BLACK = Color3.fromRGB(8, 8, 8),
    DARK_GRAY = Color3.fromRGB(20, 20, 20),
    GRAY = Color3.fromRGB(40, 40, 40),
    WHITE = Color3.fromRGB(255, 255, 255),
    GREEN = Color3.fromRGB(0, 255, 128),
    RED = Color3.fromRGB(255, 70, 70)
}

-- ========== FUNGSI BACKEND (ASLI, 0% DIUBAH) ==========
local humanoid, rootPart

local function refreshCharacterRefs()
    local char = LP.Character
    if char then
        humanoid = char:FindFirstChildOfClass("Humanoid")
        rootPart = char:FindFirstChild("HumanoidRootPart")
        if humanoid then
            OriginalWalkSpeed = humanoid.WalkSpeed
            OriginalJumpPower = humanoid.JumpPower
        end
    else
        humanoid = nil
        rootPart = nil
    end
end
refreshCharacterRefs()

LP.CharacterAdded:Connect(function(char)
    pcall(function()
        char:WaitForChild("Humanoid", 5)
        char:WaitForChild("HumanoidRootPart", 5)
    end)
    refreshCharacterRefs()
    if FollowActive then
        if FollowConnection then FollowConnection:Disconnect(); FollowConnection = nil end
        if FollowAnim then pcall(function() FollowAnim:Stop() end); FollowAnim = nil end
        FollowActive = false
    end
end)

local function freezeCharacter()
    if FreezeConnection then FreezeConnection:Disconnect() end
    FreezeConnection = RunService.Heartbeat:Connect(function()
        if humanoid and rootPart then
            humanoid.WalkSpeed = 0
            humanoid.JumpPower = 0
            pcall(function()
                rootPart.AssemblyLinearVelocity = Vector3.zero
                rootPart.AssemblyAngularVelocity = Vector3.zero
            end)
        end
    end)
    if humanoid then
        humanoid.WalkSpeed = 0
        humanoid.JumpPower = 0
    end
end

local function unfreezeCharacter()
    if FreezeConnection then
        FreezeConnection:Disconnect()
        FreezeConnection = nil
    end
    if humanoid then
        humanoid.WalkSpeed = OriginalWalkSpeed
        humanoid.JumpPower = OriginalJumpPower
    end
end

-- ========== SEND PART FUNCTION (ORI JSY) ==========
local function OneTimeUnanchor()
    if _G.__JSY_UnanchorCooldown then return end
    _G.__JSY_UnanchorCooldown = true
    task.spawn(function()
        local startTime = tick()
        while tick() - startTime < 1 do
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("RopeConstraint") then
                    local part0 = obj.Attachment0 and obj.Attachment0.Parent
                    local part1 = obj.Attachment1 and obj.Attachment1.Parent
                    pcall(function() obj:Destroy() end)
                    if part0 and part0:IsA("BasePart") then part0.Anchored = false end
                    if part1 and part1:IsA("BasePart") then part1.Anchored = false end
                end
            end
            for _, part in pairs(Workspace:GetDescendants()) do
                if part:IsA("BasePart") and not part.Anchored then
                    part.AssemblyLinearVelocity = Vector3.new(
                        math.random(-50, 50),
                        math.random(20, 100),
                        math.random(-50, 50)
                    )
                end
            end
            task.wait(0.2)
        end
        _G.__JSY_UnanchorCooldown = false
    end)
end

local function GetAllPartsRecursive(parent)
    local parts = {}
    for _, obj in ipairs(parent:GetChildren()) do
        if obj:IsA("BasePart") then
            table.insert(parts, obj)
        elseif obj:IsA("Folder") or obj:IsA("Model") then
            for _, childPart in ipairs(GetAllPartsRecursive(obj)) do
                table.insert(parts, childPart)
            end
        end
    end
    return parts
end

local function EnableNetwork()
    if NetworkConnection then return end
    NetworkConnection = RunService.Heartbeat:Connect(function()
        pcall(function()
            sethiddenproperty(LP, "SimulationRadius", math.huge)
        end)
    end)
end

local function DisableNetwork()
    if NetworkConnection then
        NetworkConnection:Disconnect()
        NetworkConnection = nil
    end
end

local function ForcePart(v, attach1)
    if v:IsA("BasePart") and not v.Anchored and not v.Parent:FindFirstChildOfClass("Humanoid") and v.Name ~= "Handle" then
        for _, x in ipairs(v:GetChildren()) do
            if x:IsA("BodyMover") or x:IsA("RocketPropulsion") then
                x:Destroy()
            end
        end
        if v:FindFirstChild("Attachment") then v:FindFirstChild("Attachment"):Destroy() end
        if v:FindFirstChild("AlignPosition") then v:FindFirstChild("AlignPosition"):Destroy() end
        if v:FindFirstChild("Torque") then v:FindFirstChild("Torque"):Destroy() end
        v.CanCollide = false
        local Torque = Instance.new("Torque", v)
        Torque.Torque = Vector3.new(100000, 100000, 100000)
        local AlignPosition = Instance.new("AlignPosition", v)
        local Attachment2 = Instance.new("Attachment", v)
        Torque.Attachment0 = Attachment2
        AlignPosition.MaxForce = math.huge
        AlignPosition.MaxVelocity = math.huge
        AlignPosition.Responsiveness = 200
        AlignPosition.Attachment0 = Attachment2
        AlignPosition.Attachment1 = attach1
    end
end

local function sendUnanchoredPartsToTarget(target)
    if not target or not target.Character then return end
    local targetHRP = target.Character:FindFirstChild("HumanoidRootPart")
    if not targetHRP then return end
    EnableNetwork()
    OneTimeUnanchor()
    local folder = Workspace:FindFirstChild("JSY_SendPartFolder") or Instance.new("Folder", Workspace)
    folder.Name = "JSY_SendPartFolder"
    local targetPart = folder:FindFirstChild("TargetPart") or Instance.new("Part", folder)
    targetPart.Name = "TargetPart"
    targetPart.Anchored = true
    targetPart.CanCollide = false
    targetPart.Transparency = 1
    targetPart.Size = Vector3.new(1,1,1)
    targetPart.CFrame = targetHRP.CFrame
    local attach1 = targetPart:FindFirstChild("Attachment") or Instance.new("Attachment", targetPart)
    local parts = GetAllPartsRecursive(Workspace)
    for _, v in ipairs(parts) do
        pcall(function()
            ForcePart(v, attach1)
        end)
    end
    task.spawn(function()
        local duration = 5
        local start = tick()
        while tick() - start < duration do
            if attach1 and targetHRP then
                pcall(function()
                    attach1.WorldCFrame = targetHRP.CFrame
                    targetPart.CFrame = targetHRP.CFrame
                end)
            end
            task.wait()
        end
        pcall(function()
            folder:Destroy()
        end)
        DisableNetwork()
    end)
end

local function turnOffSendPart()
    if SendPartActive then
        SendPartActive = false
        if SendPartBtn then
            SendPartBtn.Text = "SEND PART"
            TweenService:Create(SendPartBtn, TweenInfo.new(0.3), {BackgroundColor3 = COLORS.DARK_BLACK}):Play()
        end
        unfreezeCharacter()
    end
end

local function getTargetablePlayers()
    local list = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            table.insert(list, p)
        end
    end
    return list
end

local function refreshTargetList()
    local oldTarget = CurrentTarget
    TargetList = getTargetablePlayers()
    if #TargetList == 0 then
        CurrentIndex = 0
        CurrentTarget = nil
        if updateProfile then updateProfile(nil) end
        return
    end
    if oldTarget and table.find(TargetList, oldTarget) then
        CurrentIndex = table.find(TargetList, oldTarget)
        CurrentTarget = oldTarget
        if updateProfile then updateProfile(CurrentTarget) end
        return
    end
    if oldTarget then
        for i, player in ipairs(TargetList) do
            if player.UserId == oldTarget.UserId then
                CurrentIndex = i
                CurrentTarget = player
                if updateProfile then updateProfile(CurrentTarget) end
                return
            end
        end
    end
    if CurrentIndex < 1 or CurrentIndex > #TargetList then
        CurrentIndex = 1
    end
    CurrentTarget = TargetList[CurrentIndex]
    if updateProfile then updateProfile(CurrentTarget) end
end

local refreshDebounce = false
local function safeRefreshTargetList()
    if refreshDebounce then return end
    refreshDebounce = true
    refreshTargetList()
    task.wait(0.5)
    refreshDebounce = false
end
refreshTargetList()

Players.PlayerAdded:Connect(function(plr)
    task.wait(0.1)
    safeRefreshTargetList()
end)

Players.PlayerRemoving:Connect(function(plr)
    task.wait(0.1)
    safeRefreshTargetList()
    if CurrentTarget and plr == CurrentTarget then
        CurrentTarget = nil
        if updateProfile then updateProfile(nil) end
        if FollowActive then
            if FollowConnection then FollowConnection:Disconnect(); FollowConnection = nil end
            if FollowAnim then pcall(function() FollowAnim:Stop() end); FollowAnim = nil end
            FollowActive = false
        end
        if FlingActive then
            FlingActive = false
            if KickBtn then
                KickBtn.Text = "KICK"
                TweenService:Create(KickBtn, TweenInfo.new(0.3), {BackgroundColor3 = COLORS.DARK_BLACK}):Play()
            end
        end
        if SendPartActive then
            turnOffSendPart()
        end
    end
end)

-- ========== FLING LOOP (ASLI) ==========
local function flingLoop()
    while FlingActive do
        RunService.Heartbeat:Wait()
        local lpHRP = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        local targetHRP = CurrentTarget and CurrentTarget.Character and CurrentTarget.Character:FindFirstChild("HumanoidRootPart")
        if lpHRP and targetHRP then
            local dir = (targetHRP.Position - lpHRP.Position)
            if dir.Magnitude > 0 then
                lpHRP.AssemblyLinearVelocity = dir.Unit * 500
            end
            lpHRP.CFrame = targetHRP.CFrame
        end
    end
end

-- ========== FOLLOW FUNCTIONS (ASLI) ==========
local function stopFollow()
    FollowActive = false
    if FollowConnection then FollowConnection:Disconnect(); FollowConnection = nil end
    if FollowAnim then pcall(function() FollowAnim:Stop() end); FollowAnim = nil end
    if FollowBtn then
        FollowBtn.Text = "FOLLOW"
        TweenService:Create(FollowBtn, TweenInfo.new(0.3), {BackgroundColor3 = COLORS.DARK_BLACK}):Play()
    end
end

local function startFollowToTarget(target)
    if not target or not rootPart or not humanoid then return end
    FollowActive = true
    if FollowBtn then
        FollowBtn.Text = "FOLLOWING"
        TweenService:Create(FollowBtn, TweenInfo.new(0.3), {BackgroundColor3 = COLORS.GREEN}):Play()
    end
    pcall(function()
        local anim = Instance.new("Animation")
        anim.AnimationId = "rbxassetid://100681208320300"
        FollowAnim = humanoid:LoadAnimation(anim)
        FollowAnim.Looped = true
        FollowAnim:Play()
    end)
    FollowConnection = RunService.Heartbeat:Connect(function()
        if not FollowActive then return end
        if not target.Character then stopFollow(); return end
        local targetHRP = target.Character:FindFirstChild("HumanoidRootPart")
        if not targetHRP then stopFollow(); return end
        rootPart.CFrame = targetHRP.CFrame * CFrame.new(0, 0, 3)
    end)
end

-- ========== CAMERA SPECTATE (ASLI) ==========
RunService.RenderStepped:Connect(function()
    if not Active then return end
    if CurrentTarget and CurrentTarget.Character then
        local hrp = CurrentTarget.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            Cam.CameraSubject = hrp
        end
    end
end)

-- ========== UI MODERN - JUDUL BOLD, TEKS TIPIS, TANPA EMOJI ==========
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Anonymous9xSpectator"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = game.CoreGui

-- Panel utama
local MainPanel = Instance.new("Frame")
MainPanel.Name = "MainPanel"
MainPanel.Size = UDim2.new(0, 320, 0, 260)
MainPanel.Position = UDim2.new(0.5, -160, 0.5, -130)
MainPanel.BackgroundColor3 = COLORS.BLACK
MainPanel.BorderSizePixel = 0
MainPanel.Parent = ScreenGui

-- Stroke putih (border)
local PanelStroke = Instance.new("UIStroke", MainPanel)
PanelStroke.Color = COLORS.WHITE
PanelStroke.Thickness = 2

-- Sudut
local PanelCorner = Instance.new("UICorner", MainPanel)
PanelCorner.CornerRadius = UDim.new(0, 8)

-- Title bar
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 35)
TitleBar.BackgroundColor3 = COLORS.DARK_BLACK
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainPanel

local TitleCorner = Instance.new("UICorner", TitleBar)
TitleCorner.CornerRadius = UDim.new(0, 8)

-- JUDUL PANEL (FONT BOLD sesuai request)
local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(1, -110, 1, 0)
TitleText.Position = UDim2.new(0, 10, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "Anonymous9x Spectator"
TitleText.TextColor3 = COLORS.WHITE
TitleText.Font = Enum.Font.GothamBold  -- BOLD
TitleText.TextSize = 14
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.Parent = TitleBar

-- Tombol MINIMIZE (tetap pake simbol, bukan emoji)
local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Name = "MinimizeBtn"
MinimizeBtn.Size = UDim2.new(0, 30, 0, 30)
MinimizeBtn.Position = UDim2.new(1, -70, 0.5, -15)
MinimizeBtn.BackgroundColor3 = COLORS.GRAY
MinimizeBtn.Text = "−"
MinimizeBtn.TextColor3 = COLORS.WHITE
MinimizeBtn.Font = Enum.Font.Gotham
MinimizeBtn.TextSize = 16
MinimizeBtn.BorderSizePixel = 0
MinimizeBtn.Parent = TitleBar
local MinimizeCorner = Instance.new("UICorner", MinimizeBtn)
MinimizeCorner.CornerRadius = UDim.new(0, 6)

-- Tombol CLOSE (tetap pake X)
local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -35, 0.5, -15)
CloseButton.BackgroundColor3 = COLORS.GRAY
CloseButton.Text = "✕"
CloseButton.TextColor3 = COLORS.WHITE
CloseButton.Font = Enum.Font.Gotham
CloseButton.TextSize = 16
CloseButton.BorderSizePixel = 0
CloseButton.Parent = TitleBar
local CloseCorner = Instance.new("UICorner", CloseButton)
CloseCorner.CornerRadius = UDim.new(0, 6)

-- Hover effect
MinimizeBtn.MouseEnter:Connect(function()
    TweenService:Create(MinimizeBtn, TweenInfo.new(0.2), {BackgroundColor3 = COLORS.DARK_GRAY}):Play()
end)
MinimizeBtn.MouseLeave:Connect(function()
    TweenService:Create(MinimizeBtn, TweenInfo.new(0.2), {BackgroundColor3 = COLORS.GRAY}):Play()
end)
CloseButton.MouseEnter:Connect(function()
    TweenService:Create(CloseButton, TweenInfo.new(0.2), {BackgroundColor3 = COLORS.RED}):Play()
end)
CloseButton.MouseLeave:Connect(function()
    TweenService:Create(CloseButton, TweenInfo.new(0.2), {BackgroundColor3 = COLORS.GRAY}):Play()
end)

-- Konten panel (bisa di-hide pas minimize)
local Content = Instance.new("Frame")
Content.Name = "Content"
Content.Size = UDim2.new(1, -20, 1, -45)
Content.Position = UDim2.new(0, 10, 0, 40)
Content.BackgroundTransparency = 1
Content.Parent = MainPanel

-- Info player (avatar, nama, age, id) - TEKS TIPIS (Gotham)
local InfoFrame = Instance.new("Frame")
InfoFrame.Size = UDim2.new(1, 0, 0, 70)
InfoFrame.BackgroundColor3 = COLORS.DARK_BLACK
InfoFrame.BorderSizePixel = 0
InfoFrame.Parent = Content
local InfoCorner = Instance.new("UICorner", InfoFrame)
InfoCorner.CornerRadius = UDim.new(0, 6)
local InfoStroke = Instance.new("UIStroke", InfoFrame)
InfoStroke.Color = COLORS.WHITE
InfoStroke.Thickness = 1

-- Avatar
local AvatarImg = Instance.new("ImageLabel")
AvatarImg.Size = UDim2.new(0, 50, 0, 50)
AvatarImg.Position = UDim2.new(0, 8, 0.5, -25)
AvatarImg.BackgroundColor3 = COLORS.GRAY
AvatarImg.BorderSizePixel = 0
AvatarImg.Parent = InfoFrame
local AvatarCorner = Instance.new("UICorner", AvatarImg)
AvatarCorner.CornerRadius = UDim.new(0, 6)
local AvatarStroke = Instance.new("UIStroke", AvatarImg)
AvatarStroke.Color = COLORS.WHITE
AvatarStroke.Thickness = 1

-- Status dot
local StatusDot = Instance.new("Frame")
StatusDot.Size = UDim2.new(0, 8, 0, 8)
StatusDot.Position = UDim2.new(0, 50, 0, 45)
StatusDot.AnchorPoint = Vector2.new(0.5, 0.5)
StatusDot.BackgroundColor3 = COLORS.RED
StatusDot.BorderSizePixel = 0
StatusDot.Parent = AvatarImg
local StatusDotCorner = Instance.new("UICorner", StatusDot)
StatusDotCorner.CornerRadius = UDim.new(1, 0)

-- Label nama (TIPIS - Gotham)
local PlayerNameLabel = Instance.new("TextLabel")
PlayerNameLabel.Size = UDim2.new(0, 180, 0, 22)
PlayerNameLabel.Position = UDim2.new(0, 68, 0, 10)
PlayerNameLabel.BackgroundTransparency = 1
PlayerNameLabel.Text = "No Target"
PlayerNameLabel.TextColor3 = COLORS.WHITE
PlayerNameLabel.Font = Enum.Font.Gotham
PlayerNameLabel.TextSize = 14
PlayerNameLabel.TextXAlignment = Enum.TextXAlignment.Left
PlayerNameLabel.Parent = InfoFrame

-- Label age (TIPIS)
local AgeLabel = Instance.new("TextLabel")
AgeLabel.Size = UDim2.new(0, 180, 0, 16)
AgeLabel.Position = UDim2.new(0, 68, 0, 34)
AgeLabel.BackgroundTransparency = 1
AgeLabel.Text = "Age: -"
AgeLabel.TextColor3 = COLORS.WHITE
AgeLabel.Font = Enum.Font.Gotham
AgeLabel.TextSize = 11
AgeLabel.TextXAlignment = Enum.TextXAlignment.Left
AgeLabel.Parent = InfoFrame

-- Label ID (TIPIS)
local IdLabel = Instance.new("TextLabel")
IdLabel.Size = UDim2.new(0, 180, 0, 16)
IdLabel.Position = UDim2.new(0, 68, 0, 50)
IdLabel.BackgroundTransparency = 1
IdLabel.Text = "ID: -"
IdLabel.TextColor3 = COLORS.WHITE
IdLabel.Font = Enum.Font.Gotham
IdLabel.TextSize = 11
IdLabel.TextXAlignment = Enum.TextXAlignment.Left
IdLabel.Parent = InfoFrame

-- Navigasi PREV / NEXT (TANPA EMOJI, FONT TIPIS)
local NavFrame = Instance.new("Frame")
NavFrame.Size = UDim2.new(1, 0, 0, 40)
NavFrame.Position = UDim2.new(0, 0, 0, 80)
NavFrame.BackgroundTransparency = 1
NavFrame.Parent = Content

-- Tombol PREV (TIPIS, TANPA EMOJI)
local PrevBtn = Instance.new("TextButton")
PrevBtn.Size = UDim2.new(0, 130, 0, 30)
PrevBtn.Position = UDim2.new(0, 0, 0.5, -15)
PrevBtn.BackgroundColor3 = COLORS.DARK_BLACK
PrevBtn.Text = "PREV"
PrevBtn.TextColor3 = COLORS.WHITE
PrevBtn.Font = Enum.Font.Gotham
PrevBtn.TextSize = 12
PrevBtn.BorderSizePixel = 0
PrevBtn.Parent = NavFrame
local PrevCorner = Instance.new("UICorner", PrevBtn)
PrevCorner.CornerRadius = UDim.new(0, 6)
local PrevStroke = Instance.new("UIStroke", PrevBtn)
PrevStroke.Color = COLORS.WHITE
PrevStroke.Thickness = 1

-- Tombol NEXT (TIPIS, TANPA EMOJI)
local NextBtn = Instance.new("TextButton")
NextBtn.Size = UDim2.new(0, 130, 0, 30)
NextBtn.Position = UDim2.new(1, -130, 0.5, -15)
NextBtn.BackgroundColor3 = COLORS.DARK_BLACK
NextBtn.Text = "NEXT"
NextBtn.TextColor3 = COLORS.WHITE
NextBtn.Font = Enum.Font.Gotham
NextBtn.TextSize = 12
NextBtn.BorderSizePixel = 0
NextBtn.Parent = NavFrame
local NextCorner = Instance.new("UICorner", NextBtn)
NextCorner.CornerRadius = UDim.new(0, 6)
local NextStroke = Instance.new("UIStroke", NextBtn)
NextStroke.Color = COLORS.WHITE
NextStroke.Thickness = 1

-- Hover nav
local function navHover(btn)
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = COLORS.GRAY}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = COLORS.DARK_BLACK}):Play()
    end)
end
navHover(PrevBtn)
navHover(NextBtn)

-- Action buttons (2x2) - TANPA EMOJI, FONT TIPIS
local ActionFrame = Instance.new("Frame")
ActionFrame.Size = UDim2.new(1, 0, 0, 110)
ActionFrame.Position = UDim2.new(0, 0, 0, 125)
ActionFrame.BackgroundTransparency = 1
ActionFrame.Parent = Content

-- TELEPORT (TIPIS, TANPA EMOJI)
local TeleBtn = Instance.new("TextButton")
TeleBtn.Size = UDim2.new(0, 130, 0, 40)
TeleBtn.Position = UDim2.new(0, 0, 0, 0)
TeleBtn.BackgroundColor3 = COLORS.DARK_BLACK
TeleBtn.Text = "TELEPORT"
TeleBtn.TextColor3 = COLORS.WHITE
TeleBtn.Font = Enum.Font.Gotham
TeleBtn.TextSize = 12
TeleBtn.BorderSizePixel = 0
TeleBtn.Parent = ActionFrame
local TeleCorner = Instance.new("UICorner", TeleBtn)
TeleCorner.CornerRadius = UDim.new(0, 6)
local TeleStroke = Instance.new("UIStroke", TeleBtn)
TeleStroke.Color = COLORS.WHITE
TeleStroke.Thickness = 1

-- KICK (TIPIS, TANPA EMOJI)
local KickBtn = Instance.new("TextButton")
KickBtn.Size = UDim2.new(0, 130, 0, 40)
KickBtn.Position = UDim2.new(1, -130, 0, 0)
KickBtn.BackgroundColor3 = COLORS.DARK_BLACK
KickBtn.Text = "KICK"
KickBtn.TextColor3 = COLORS.WHITE
KickBtn.Font = Enum.Font.Gotham
KickBtn.TextSize = 12
KickBtn.BorderSizePixel = 0
KickBtn.Parent = ActionFrame
local KickCorner = Instance.new("UICorner", KickBtn)
KickCorner.CornerRadius = UDim.new(0, 6)
local KickStroke = Instance.new("UIStroke", KickBtn)
KickStroke.Color = COLORS.WHITE
KickStroke.Thickness = 1

-- FOLLOW (TIPIS, TANPA EMOJI)
local FollowBtn = Instance.new("TextButton")
FollowBtn.Size = UDim2.new(0, 130, 0, 40)
FollowBtn.Position = UDim2.new(0, 0, 0, 50)
FollowBtn.BackgroundColor3 = COLORS.DARK_BLACK
FollowBtn.Text = "FOLLOW"
FollowBtn.TextColor3 = COLORS.WHITE
FollowBtn.Font = Enum.Font.Gotham
FollowBtn.TextSize = 12
FollowBtn.BorderSizePixel = 0
FollowBtn.Parent = ActionFrame
local FollowCorner = Instance.new("UICorner", FollowBtn)
FollowCorner.CornerRadius = UDim.new(0, 6)
local FollowStroke = Instance.new("UIStroke", FollowBtn)
FollowStroke.Color = COLORS.WHITE
FollowStroke.Thickness = 1

-- SEND PART (TIPIS, TANPA EMOJI)
local SendPartBtn = Instance.new("TextButton")
SendPartBtn.Size = UDim2.new(0, 130, 0, 40)
SendPartBtn.Position = UDim2.new(1, -130, 0, 50)
SendPartBtn.BackgroundColor3 = COLORS.DARK_BLACK
SendPartBtn.Text = "SEND PART"
SendPartBtn.TextColor3 = COLORS.WHITE
SendPartBtn.Font = Enum.Font.Gotham
SendPartBtn.TextSize = 12
SendPartBtn.BorderSizePixel = 0
SendPartBtn.Parent = ActionFrame
local SendCorner = Instance.new("UICorner", SendPartBtn)
SendCorner.CornerRadius = UDim.new(0, 6)
local SendStroke = Instance.new("UIStroke", SendPartBtn)
SendStroke.Color = COLORS.WHITE
SendStroke.Thickness = 1

-- Hover action buttons
local function actionHover(btn)
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = COLORS.GRAY}):Play()
    end)
    btn.MouseLeave:Connect(function()
        if btn == TeleBtn or btn == KickBtn or btn == FollowBtn or btn == SendPartBtn then
            if (btn == KickBtn and FlingActive) or (btn == FollowBtn and FollowActive) or (btn == SendPartBtn and SendPartActive) then
                -- jangan ubah, biar warnanya sesuai status
            else
                TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = COLORS.DARK_BLACK}):Play()
            end
        else
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = COLORS.DARK_BLACK}):Play()
        end
    end)
end
actionHover(TeleBtn)
actionHover(KickBtn)
actionHover(FollowBtn)
actionHover(SendPartBtn)

-- ========== MINIMIZE LOGIC ==========
local MainPanelOriginalSize = MainPanel.Size
local isMinimized = false

MinimizeBtn.MouseButton1Click:Connect(function()
    if isMinimized then
        MainPanel.Size = MainPanelOriginalSize
        Content.Visible = true
        MinimizeBtn.Text = "−"
        isMinimized = false
    else
        MainPanel.Size = UDim2.new(0, 320, 0, 35)
        Content.Visible = false
        MinimizeBtn.Text = "□"
        isMinimized = true
    end
end)

-- ========== DRAG PANEL ==========
local dragging = false
local dragInput, dragStart, startPos

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainPanel.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

TitleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainPanel.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

-- ========== UPDATE PROFILE (ASLI) ==========
local function updateProfile(plr)
    if plr and plr:IsA("Player") then
        PlayerNameLabel.Text = plr.Name
        AgeLabel.Text = "Age: " .. tostring(plr.AccountAge or 0) .. " days"
        IdLabel.Text = "ID: " .. tostring(plr.UserId)
        StatusDot.BackgroundColor3 = COLORS.GREEN
        pcall(function()
            AvatarImg.Image = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. plr.UserId .. "&width=150&height=150&format=png"
        end)
    else
        PlayerNameLabel.Text = "No Target"
        AgeLabel.Text = "Age: -"
        IdLabel.Text = "ID: -"
        AvatarImg.Image = ""
        StatusDot.BackgroundColor3 = COLORS.RED
    end
end
_G.updateProfile = updateProfile
updateProfile(CurrentTarget)

-- ========== BUTTON EVENTS (ASLI) ==========
PrevBtn.MouseButton1Click:Connect(function()
    if #TargetList == 0 then safeRefreshTargetList() end
    if #TargetList == 0 then return end
    local nextIndex = CurrentIndex - 1
    if nextIndex < 1 then nextIndex = #TargetList end
    if nextIndex >= 1 and nextIndex <= #TargetList then
        CurrentIndex = nextIndex
        CurrentTarget = TargetList[CurrentIndex]
        updateProfile(CurrentTarget)
        turnOffSendPart()
    end
end)

NextBtn.MouseButton1Click:Connect(function()
    if #TargetList == 0 then safeRefreshTargetList() end
    if #TargetList == 0 then return end
    local nextIndex = CurrentIndex + 1
    if nextIndex > #TargetList then nextIndex = 1 end
    if nextIndex >= 1 and nextIndex <= #TargetList then
        CurrentIndex = nextIndex
        CurrentTarget = TargetList[CurrentIndex]
        updateProfile(CurrentTarget)
        turnOffSendPart()
    end
end)

TeleBtn.MouseButton1Click:Connect(function()
    if not CurrentTarget then return end
    local lpHRP = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    local targetHRP = CurrentTarget.Character and CurrentTarget.Character:FindFirstChild("HumanoidRootPart")
    if lpHRP and targetHRP then
        lpHRP.CFrame = targetHRP.CFrame + Vector3.new(0, 3, 0)
        TweenService:Create(TeleBtn, TweenInfo.new(0.5), {BackgroundColor3 = COLORS.GREEN}):Play()
        task.wait(0.5)
        TweenService:Create(TeleBtn, TweenInfo.new(0.5), {BackgroundColor3 = COLORS.DARK_BLACK}):Play()
    end
end)

KickBtn.MouseButton1Click:Connect(function()
    if not CurrentTarget then return end
    local lpHRP = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not lpHRP then return end
    FlingActive = not FlingActive
    if FlingActive then
        OriginalCFrame = lpHRP.CFrame
        KickBtn.Text = "KICKING"
        TweenService:Create(KickBtn, TweenInfo.new(0.3), {BackgroundColor3 = COLORS.RED}):Play()
        if not FlingThread then
            FlingThread = task.spawn(flingLoop)
        end
    else
        FlingActive = false
        KickBtn.Text = "KICK"
        TweenService:Create(KickBtn, TweenInfo.new(0.3), {BackgroundColor3 = COLORS.DARK_BLACK}):Play()
        FlingThread = nil
        task.defer(function()
            pcall(function()
                if lpHRP and OriginalCFrame then
                    lpHRP.AssemblyLinearVelocity = Vector3.zero
                    lpHRP.AssemblyAngularVelocity = Vector3.zero
                    task.wait(0.1)
                    lpHRP.CFrame = OriginalCFrame
                end
            end)
        end)
    end
end)

FollowBtn.MouseButton1Click:Connect(function()
    if FollowActive then
        stopFollow()
        return
    end
    if not CurrentTarget then return end
    refreshCharacterRefs()
    startFollowToTarget(CurrentTarget)
end)

SendPartBtn.MouseButton1Click:Connect(function()
    SendPartActive = not SendPartActive
    if SendPartActive then
        SendPartBtn.Text = "SENDING (ON)"
        TweenService:Create(SendPartBtn, TweenInfo.new(0.3), {BackgroundColor3 = COLORS.GREEN}):Play()
        freezeCharacter()
        if not SendPartLoopThread then
            SendPartLoopThread = task.spawn(function()
                while SendPartActive do
                    if CurrentTarget and CurrentTarget.Character then
                        pcall(function()
                            sendUnanchoredPartsToTarget(CurrentTarget)
                        end)
                    end
                    task.wait(2.2)
                end
                SendPartLoopThread = nil
            end)
        end
    else
        SendPartBtn.Text = "SEND PART"
        TweenService:Create(SendPartBtn, TweenInfo.new(0.3), {BackgroundColor3 = COLORS.DARK_BLACK}):Play()
        unfreezeCharacter()
    end
end)

CloseButton.MouseButton1Click:Connect(function()
    Active = false
    FlingActive = false
    SendPartActive = false
    unfreezeCharacter()
    if FollowConnection then FollowConnection:Disconnect(); FollowConnection = nil end
    if FollowAnim then pcall(function() FollowAnim:Stop() end); FollowAnim = nil end
    if LP.Character and LP.Character:FindFirstChild("Humanoid") then
        Cam.CameraSubject = LP.Character:FindFirstChild("Humanoid")
    end
    ScreenGui:Destroy()
end)

-- ========== AUTO REFRESH ==========
task.spawn(function()
    while true do
        task.wait(1)
        safeRefreshTargetList()
    end
end)

print("✅ ANONYMOUS9X SPECTATOR - Success")
print("V1.0 Beta")
print("Enjoyy")
