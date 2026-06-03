-- ========== KONFIGURASI ==========
local ANOLIB_RAW_URL = "https://raw.githubusercontent.com/Anonymous9x-oss/Anonymous9xProjectv1/refs/heads/main/anolib.lua"
-- =================================

-- Load library dari raw URL (persis seperti Blox Fruit)
local bearlib = loadstring(game:HttpGet(ANOLIB_RAW_URL))()
if not bearlib then
    error("Gagal memuat bearlib dari raw URL")
end

-- Helper untuk notifikasi (durasi 3 detik, seperti bf1.lua)
local function Notify(Title, Message, Duration)
    Duration = Duration or 3
    pcall(function()
        bearlib:Notify({ Title = Title, Message = Message, Duration = Duration })
    end)
end

repeat task.wait() until game:IsLoaded()

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local Workspace = game:GetService("Workspace")

-- Buat window (sama seperti bf1.lua)
local Window = bearlib:MakeWindow({
    Name = "Evade Script by SARpastes | SARHUB",
    SubTitle = "Powered by bearlib (raw URL)",
    SaveFolder = "EvadeConfig.json"
})

-- Buat tab dengan Icon (seperti bf1.lua)
local PlayerTab = Window:MakeTab({ Title = "Player", Icon = "rbxassetid://10734975692" })
local AutoTab   = Window:MakeTab({ Title = "Auto", Icon = "rbxassetid://10709769508" })
local EspTab    = Window:MakeTab({ Title = "ESP", Icon = "rbxassetid://10723346959" })
local MiscTab   = Window:MakeTab({ Title = "Misc", Icon = "rbxassetid://10734950309" })

-- Variabel
local ValueSpeed = 16
local ActiveCFrameSpeedBoost = false
local cframeSpeedConnection = nil
local IsHoldingSpace = false
local bhopEnabled = false
local ButtonGui = nil
local InputConnections = {}
local IsHoldingButton = false
local afk = true
local selectedMapNumber = 1
local autoVoteEnabled = false
local voteConnection = nil
local ActiveEspPlayers = false
local ActiveEspBots = false
local ActiveDistanceEsp = false
local playerAddedConnection = nil
local botLoopConnection = nil

local originalBrightness = game.Lighting.Brightness
local originalOutdoorAmbient = game.Lighting.OutdoorAmbient
local originalAmbient = game.Lighting.Ambient
local originalGlobalShadows = game.Lighting.GlobalShadows
local originalFogEnd = game.Lighting.FogEnd
local originalFogStart = game.Lighting.FogStart
local originalColorCorrectionEnabled = game.Lighting.ColorCorrection.Enabled
local originalSaturation = game.Lighting.ColorCorrection.Saturation
local originalContrast = game.Lighting.ColorCorrection.Contrast
local autoReviveEnabled = false
local lastCheckTime = 0
local checkInterval = 5

-- Helper functions (sama seperti sebelumnya)
local function fireVoteServer(selectedMapNumber)
    local eventsFolder = ReplicatedStorage:WaitForChild("Events", 10)
    if eventsFolder then
        local playerFolder = eventsFolder:WaitForChild("Player", 10)
        if playerFolder then
            local voteEvent = playerFolder:WaitForChild("Vote", 10)
            if voteEvent and voteEvent:IsA("RemoteEvent") then
                voteEvent:FireServer(selectedMapNumber)
            end
        end
    end
end

local function applyFullBrightness()
    game.Lighting.Brightness = 2
    game.Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
    game.Lighting.Ambient = Color3.fromRGB(255, 255, 255)
    game.Lighting.GlobalShadows = false
end

local function removeFullBrightness()
    game.Lighting.Brightness = originalBrightness
    game.Lighting.OutdoorAmbient = originalOutdoorAmbient
    game.Lighting.Ambient = originalAmbient
    game.Lighting.GlobalShadows = originalGlobalShadows
end

local function applySuperFullBrightness()
    game.Lighting.Brightness = 15
    game.Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
    game.Lighting.Ambient = Color3.fromRGB(255, 255, 255)
    game.Lighting.GlobalShadows = false
end

local function applyNoFog()
    game.Lighting.FogEnd = 1000000
    game.Lighting.FogStart = 999999
end

local function removeNoFog()
    game.Lighting.FogEnd = originalFogEnd
    game.Lighting.FogStart = originalFogStart
end

local function applyVibrant()
    game.Lighting.ColorCorrection.Enabled = true
    game.Lighting.ColorCorrection.Saturation = 0.8
    game.Lighting.ColorCorrection.Contrast = 0.4
end

local function removeVibrant()
    game.Lighting.ColorCorrection.Enabled = originalColorCorrectionEnabled
    game.Lighting.ColorCorrection.Saturation = originalSaturation
    game.Lighting.ColorCorrection.Contrast = originalContrast
end

local function CreateEsp(Char, Color, Text, ParentPart, YOffset)
    if not Char or not ParentPart or not ParentPart:IsA("BasePart") then return end
    if Char:FindFirstChild("ESP_Highlight") and ParentPart:FindFirstChild("ESP") then return end
    local highlight = Instance.new("Highlight")
    highlight.Name = "ESP_Highlight"
    highlight.Adornee = Char
    highlight.FillColor = Color
    highlight.FillTransparency = 0.5
    highlight.OutlineColor = Color
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Enabled = true
    highlight.Parent = Char
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESP"
    billboard.Size = UDim2.new(0, 100, 0, 50)
    billboard.AlwaysOnTop = true
    billboard.StudsOffset = Vector3.new(0, YOffset, 0)
    billboard.Adornee = ParentPart
    billboard.Enabled = true
    billboard.Parent = ParentPart
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = tostring(Text) or ""
    label.TextColor3 = Color
    label.TextScaled = true
    label.Font = Enum.Font.SourceSansBold
    label.Parent = billboard
    spawn(function()
        local Camera = Workspace.CurrentCamera
        while highlight.Parent and billboard.Parent and ParentPart.Parent and Camera do
            local cameraPosition = Camera.CFrame.Position
            local distance = (cameraPosition - ParentPart.Position).Magnitude
            if ActiveDistanceEsp then
                label.Text = tostring(Text) .. " " .. tostring(math.floor(distance + 0.5)) .. "m"
            else
                label.Text = tostring(Text)
            end
            task.wait(0.1)
        end
        if highlight then highlight:Destroy() end
        if billboard then billboard:Destroy() end
    end)
end

local function RemoveEsp(Char, ParentPart)
    if Char then
        local highlight = Char:FindFirstChild("ESP_Highlight")
        if highlight then highlight:Destroy() end
    end
    if ParentPart then
        local billboard = ParentPart:FindFirstChild("ESP")
        if billboard then billboard:Destroy() end
    end
end

local function handlePlayerEsp(player)
    if player ~= LocalPlayer and player.Character then
        local function createPlayerEspOnCharacter(character)
            if ActiveEspPlayers and character:FindFirstChild("Head") then
                CreateEsp(character, Color3.new(0.4, 0.8, 0.4), player.Name, character.Head, 1)
            end
        end
        createPlayerEspOnCharacter(player.Character)
        player.CharacterAdded:Connect(function(newCharacter)
            task.wait(0.1)
            createPlayerEspOnCharacter(newCharacter)
        end)
        player.CharacterRemoving:Connect(function(oldCharacter)
            if oldCharacter:FindFirstChild("Head") then
                RemoveEsp(oldCharacter, oldCharacter.Head)
            end
        end)
    end
end

local function MobileBhopButton(Character)
    if ButtonGui then
        ButtonGui:Destroy()
        ButtonGui = nil
    end
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "BhopButtonGui"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(0,50,0,50)
    Button.Position = UDim2.new(0.9, -25, 0.8, 0)
    Button.BackgroundColor3 = Color3.fromRGB(0,200,0)
    Button.BackgroundTransparency = 0.3
    Button.Text = "Bhop"
    Button.TextScaled = true
    Button.Parent = ScreenGui
    ButtonGui = ScreenGui
    local dragging = false
    local dragInput, mousePos, framePos
    Button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            mousePos = input.Position
            framePos = Button.Position
            IsHoldingButton = true
        end
    end)
    Button.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - mousePos
            Button.Position = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
        end
    end)
    Button.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
            IsHoldingButton = false
        end
    end)
    local Humanoid = Character:WaitForChild("Humanoid")
    table.insert(InputConnections, RunService.RenderStepped:Connect(function()
        if IsHoldingButton and Humanoid.FloorMaterial ~= Enum.Material.Air then
            Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end))
end

LocalPlayer.CharacterAdded:Connect(function(Character)
    if ButtonGui then
        ButtonGui:Destroy()
        ButtonGui = nil
    end
    for _, conn in pairs(InputConnections) do
        conn:Disconnect()
    end
    InputConnections = {}
end)

-- ==================== PLAYER TAB ====================
PlayerTab:AddSection("Movement")

PlayerTab:AddSlider({
    Name = "Speed Value",
    Range = {1, 50},
    Increment = 1,
    Suffix = "Speed",
    CurrentValue = 16,
    Flag = "SpeedValue",
    Callback = function(Value)
        ValueSpeed = Value
        if ActiveCFrameSpeedBoost and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = ValueSpeed
        end
        Notify("Speed", "Set to " .. Value, 2)
    end,
})

PlayerTab:AddToggle({
    Name = "Speed Power",
    CurrentValue = false,
    Flag = "CFrameSpeed",
    Callback = function(Value)
        ActiveCFrameSpeedBoost = Value
        if Value then
            if cframeSpeedConnection then cframeSpeedConnection:Disconnect() end
            cframeSpeedConnection = RunService.RenderStepped:Connect(function()
                local char = LocalPlayer.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if char and hum and hrp then
                    local moveDir = hum.MoveDirection
                    if moveDir.Magnitude > 0 then
                        hrp.CFrame = hrp.CFrame + moveDir * math.max(ValueSpeed, 1) * 0.080
                    end
                end
            end)
            Notify("Speed Power", "Enabled", 2)
        else
            if cframeSpeedConnection then cframeSpeedConnection:Disconnect(); cframeSpeedConnection = nil end
            Notify("Speed Power", "Disabled", 2)
        end
    end,
})

PlayerTab:AddToggle({
    Name = "Jump Power (Enable)",
    CurrentValue = false,
    Flag = "JumpBoost",
    Callback = function(Value)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            LocalPlayer.Character.Humanoid.UseJumpPower = Value
        end
        Notify("Jump Power", Value and "Enabled" or "Disabled", 2)
    end,
})

PlayerTab:AddSlider({
    Name = "Jump Power Value",
    Range = {0, 1000},
    Increment = 1,
    Suffix = "%",
    CurrentValue = 50,
    Flag = "JumpBoostSlider",
    Callback = function(Value)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            LocalPlayer.Character.Humanoid.JumpPower = Value
        end
        Notify("Jump Power", "Set to " .. Value, 2)
    end,
})

PlayerTab:AddToggle({
    Name = "Auto Bhop (Just hold space)",
    CurrentValue = false,
    Flag = "AutoBhopToggle",
    Callback = function(Value)
        bhopEnabled = Value
        Notify("Bhop", Value and "Enabled" or "Disabled", 2)
    end,
})

PlayerTab:AddButton({
    Name = "Auto Bhop (Mobile)",
    Callback = function()
        if LocalPlayer.Character then
            MobileBhopButton(LocalPlayer.Character)
            Notify("Bhop", "Mobile button added", 2)
        else
            Notify("Error", "No character found", 2)
        end
    end
})

PlayerTab:AddSection("Gravity")

local GravitySlider = PlayerTab:AddSlider({
    Name = "Gravity",
    Range = {0, 1000},
    Increment = 1,
    Suffix = "%",
    CurrentValue = 50,
    Flag = "GravitySlider",
    Callback = function(Value)
        Workspace.Gravity = Value
        Notify("Gravity", "Set to " .. Value, 2)
    end,
})

PlayerTab:AddButton({
    Name = "Reset Gravity",
    Callback = function()
        Workspace.Gravity = 50
        GravitySlider:Set(50)
        Notify("Gravity", "Reset to 50", 2)
    end
})

-- Bhop input handling
UserInputService.InputBegan:Connect(function(InputObject, GameProcessedEvent)
    if InputObject.KeyCode == Enum.KeyCode.Space and not GameProcessedEvent then
        IsHoldingSpace = true
    end
end)

UserInputService.InputEnded:Connect(function(InputObject, GameProcessedEvent)
    if InputObject.KeyCode == Enum.KeyCode.Space then
        IsHoldingSpace = false
    end
end)

local function ConnectBhop(Humanoid)
    Humanoid.StateChanged:Connect(function(_, NewState)
        if NewState == Enum.HumanoidStateType.Landed then
            if IsHoldingSpace and bhopEnabled then
                Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end)
end

if LocalPlayer.Character then
    local Humanoid = LocalPlayer.Character:WaitForChild("Humanoid")
    ConnectBhop(Humanoid)
end

LocalPlayer.CharacterAdded:Connect(function(NewCharacter)
    local Humanoid = NewCharacter:WaitForChild("Humanoid")
    ConnectBhop(Humanoid)
end)

-- ==================== AUTO TAB ====================
AutoTab:AddSection("Map Voting")

AutoTab:AddDropdown({
    Name = "Select Map",
    Options = {"Map 1", "Map 2", "Map 3", "Map 4"},
    CurrentOption = "Map 1",
    Flag = "MapSelection",
    Callback = function(Option)
        if Option == "Map 1" then selectedMapNumber = 1
        elseif Option == "Map 2" then selectedMapNumber = 2
        elseif Option == "Map 3" then selectedMapNumber = 3
        elseif Option == "Map 4" then selectedMapNumber = 4 end
        Notify("Map", "Selected " .. Option, 2)
    end,
})

AutoTab:AddButton({
    Name = "Vote Map",
    Callback = function()
        fireVoteServer(selectedMapNumber)
        Notify("Vote", "Voted for Map " .. selectedMapNumber, 2)
    end,
})

AutoTab:AddToggle({
    Name = "Auto Vote",
    CurrentValue = false,
    Flag = "AutoVote",
    Callback = function(Value)
        autoVoteEnabled = Value
        if Value then
            if not voteConnection then
                voteConnection = RunService.Heartbeat:Connect(function()
                    fireVoteServer(selectedMapNumber)
                end)
            end
            Notify("Auto Vote", "Enabled", 2)
        else
            if voteConnection then voteConnection:Disconnect(); voteConnection = nil end
            Notify("Auto Vote", "Disabled", 2)
        end
    end,
})

AutoTab:AddSection("Revive")

AutoTab:AddButton({
    Name = "Revive Yourself",
    Callback = function()
        local char = LocalPlayer.Character
        if char and char:GetAttribute("Downed") then
            ReplicatedStorage.Events.Player.ChangePlayerMode:FireServer(true)
            Notify("Revive", "Attempted to revive", 2)
        else
            Notify("Revive", "You are not downed", 2)
        end
    end,
})

AutoTab:AddToggle({
    Name = "Auto Revive Yourself",
    CurrentValue = false,
    Flag = "AutoRevive",
    Callback = function(Value)
        autoReviveEnabled = Value
        Notify("Auto Revive", Value and "Enabled" or "Disabled", 2)
    end,
})

-- ==================== ESP TAB ====================
EspTab:AddToggle({
    Name = "Players ESP",
    CurrentValue = false,
    Flag = "PlayersESP",
    Callback = function(Value)
        ActiveEspPlayers = Value
        if Value then
            for _, plr in pairs(Players:GetPlayers()) do
                handlePlayerEsp(plr)
            end
            playerAddedConnection = Players.PlayerAdded:Connect(handlePlayerEsp)
            Notify("ESP", "Players ESP enabled", 2)
        else
            if playerAddedConnection then playerAddedConnection:Disconnect(); playerAddedConnection = nil end
            for _, plr in pairs(Players:GetPlayers()) do
                if plr.Character and plr.Character:FindFirstChild("Head") then
                    RemoveEsp(plr.Character, plr.Character.Head)
                end
            end
            Notify("ESP", "Players ESP disabled", 2)
        end
    end,
})

EspTab:AddToggle({
    Name = "NextBot ESP",
    CurrentValue = false,
    Flag = "BotsESP",
    Callback = function(Value)
        ActiveEspBots = Value
        if Value then
            botLoopConnection = RunService.Heartbeat:Connect(function()
                local botsFolder = Workspace:FindFirstChild("Game") and Workspace.Game:FindFirstChild("Players")
                if botsFolder then
                    for _, bot in pairs(botsFolder:GetChildren()) do
                        if bot:IsA("Model") and bot:FindFirstChild("Hitbox") then
                            bot.Hitbox.Transparency = 0.5
                            CreateEsp(bot, Color3.new(0.8, 0.2, 0.2), bot.Name, bot.Hitbox, -2)
                        end
                    end
                end
            end)
            Notify("ESP", "Bots ESP enabled", 2)
        else
            if botLoopConnection then botLoopConnection:Disconnect(); botLoopConnection = nil end
            local botsFolder = Workspace:FindFirstChild("Game") and Workspace.Game:FindFirstChild("Players")
            if botsFolder then
                for _, bot in pairs(botsFolder:GetChildren()) do
                    if bot:IsA("Model") and bot:FindFirstChild("Hitbox") then
                        bot.Hitbox.Transparency = 1
                        RemoveEsp(bot, bot.Hitbox)
                    end
                end
            end
            Notify("ESP", "Bots ESP disabled", 2)
        end
    end,
})

EspTab:AddToggle({
    Name = "Distance ESP",
    CurrentValue = false,
    Flag = "DistanceESP",
    Callback = function(Value)
        ActiveDistanceEsp = Value
        Notify("ESP", "Distance " .. (Value and "ON" or "OFF"), 2)
    end,
})

-- ==================== MISC TAB ====================
MiscTab:AddToggle({
    Name = "Anti-AFK",
    CurrentValue = true,
    Flag = "AntiAFK",
    Callback = function(Value)
        afk = Value
        if Value then
            task.spawn(function()
                while afk do
                    if not LocalPlayer then return end
                    VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                    VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                    task.wait(60)
                end
            end)
            Notify("Anti-AFK", "Enabled", 2)
        else
            Notify("Anti-AFK", "Disabled", 2)
        end
    end
})

MiscTab:AddToggle({
    Name = "Full Brightness",
    CurrentValue = false,
    Flag = "FullBright",
    Callback = function(Value)
        if Value then
            applyFullBrightness()
            Notify("Brightness", "Full Bright ON", 2)
        else
            removeFullBrightness()
            Notify("Brightness", "Full Bright OFF", 2)
        end
    end,
})

MiscTab:AddToggle({
    Name = "Super Full Brightness",
    CurrentValue = false,
    Flag = "SuperFullBright",
    Callback = function(Value)
        if Value then
            applySuperFullBrightness()
            Notify("Brightness", "Super Full Bright ON", 2)
        else
            removeFullBrightness()
            Notify("Brightness", "Super Full Bright OFF", 2)
        end
    end,
})

MiscTab:AddToggle({
    Name = "No Fog",
    CurrentValue = false,
    Flag = "NoFog",
    Callback = function(Value)
        if Value then
            applyNoFog()
            Notify("Fog", "No Fog ON", 2)
        else
            removeNoFog()
            Notify("Fog", "No Fog OFF", 2)
        end
    end,
})

MiscTab:AddToggle({
    Name = "Vibrant Colors",
    CurrentValue = false,
    Flag = "Vibrant",
    Callback = function(Value)
        if Value then
            applyVibrant()
            Notify("Colors", "Vibrant ON", 2)
        else
            removeVibrant()
            Notify("Colors", "Vibrant OFF", 2)
        end
    end,
})

MiscTab:AddToggle({
    Name = "FPS Boost",
    CurrentValue = false,
    Flag = "FPSBoost",
    Callback = function(Value)
        if Value then
            for _, v in pairs(game:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.Material = Enum.Material.SmoothPlastic
                    v.Reflectance = 0
                elseif v:IsA("Decal") then
                    v.Transparency = 1
                end
            end
            settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
            Notify("FPS", "Boost enabled", 2)
        else
            Notify("FPS", "Boost disabled (rejoin to reset)", 2)
        end
    end,
})

-- Auto-revive loop
RunService.Heartbeat:Connect(function()
    if autoReviveEnabled then
        if tick() - lastCheckTime >= checkInterval then
            lastCheckTime = tick()
            local char = LocalPlayer.Character
            if char and char:GetAttribute("Downed") then
                ReplicatedStorage.Events.Player.ChangePlayerMode:FireServer(true)
            end
        end
    end
end)

Notify("Evade Script", "Loaded successfully! UI ready.", 3)
print("✓ Evade script dengan UI bearlib (raw URL) berhasil dimuat. GUI akan muncul dengan 4 tab berisi elemen.")
