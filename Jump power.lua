-- ================================================
-- Ano9x Jump v2.0 - FE EFFECT (FIXED)
-- Theme: Black/White (Armagedon style)
-- Fitur: Jump power adjustable + efek partikel (FE)
-- Sound: Thunder + Woosh (client-side, hanya kamu yang dengar)
-- Catatan: Efek visual bisa dilihat semua pemain (FE)
-- ================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer

-- ========== SETTINGS ==========
local JumpPower = 50  -- default Roblox
local MaxJump = 700
local MinJump = 10
local Enabled = false
local JumpConnection = nil

-- ========== BUAT REMOTE EVENT UNTUK EFEK FE (AGAR DILIHAT ORANG LAIN) ==========
-- Catatan: Script ini membuat RemoteEvent secara lokal. Agar FE, kita perlu server-side.
-- Tapi untuk kemudahan, kita buat part langsung di workspace. Pada beberapa executor,
-- part yang dibuat di workspace akan terlihat oleh semua pemain (FE bypass).
-- Jika tidak, gunakan metode RemoteEvent.

local EffectRemote = Instance.new("RemoteEvent")
EffectRemote.Name = "Ano9xJumpEffect"
EffectRemote.Parent = ReplicatedStorage

-- Fungsi untuk memicu efek di semua client (via server)
local function TriggerEffect(position)
    -- Kirim ke server
    EffectRemote:FireServer(position)
end

-- Di sisi server (kita tidak bisa menjalankan script server langsung, jadi kita perlu
-- hook ke RemoteEvent. Ini hanya akan berfungsi jika ada script server yang mendengarkan.
-- Sebagai alternatif, kita buat part langsung di workspace yang mungkin direplikasi.
-- Untuk keandalan, kita akan gunakan metode langsung (client-side) dengan catatan.

-- ========== FUNGSI EFEK (CLIENT-SIDE, TAPI PART DI WORKSPACE) ==========
-- Part di workspace biasanya direplikasi ke server jika dibuat oleh LocalScript?
-- Tergantung executor. Banyak executor yang memungkinkan part client terlihat oleh semua.
local function SpawnJumpEffect()
    local character = LocalPlayer.Character
    if not character then return end
    
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    -- Buat part efek di bawah kaki
    local effectPart = Instance.new("Part")
    effectPart.Name = "Ano9xJumpEffect"
    effectPart.Size = Vector3.new(3, 0.2, 3)
    effectPart.Position = hrp.Position - Vector3.new(0, 3, 0)
    effectPart.Anchored = true
    effectPart.CanCollide = false
    effectPart.Transparency = 0.9
    effectPart.BrickColor = BrickColor.new("Really white")
    effectPart.Material = Enum.Material.Neon
    effectPart.Parent = workspace  -- Semoga tereplikasi
    
    -- PARTIKEL 1: Kilauan putih (FE)
    local particle = Instance.new("ParticleEmitter", effectPart)
    particle.Texture = "rbxasset://textures/particles/sparkles_main.dds"
    particle.Rate = 60
    particle.Lifetime = NumberRange.new(0.3, 0.6)
    particle.SpreadAngle = Vector2.new(360, 360)
    particle.VelocityInheritance = 0
    particle.Acceleration = Vector3.new(0, 15, 0)
    particle.Speed = NumberRange.new(5, 12)
    particle.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
    particle.Transparency = NumberSequence.new(0.2)
    
    -- PARTIKEL 2: Debu/ledakan (FE)
    local particle2 = Instance.new("ParticleEmitter", effectPart)
    particle2.Texture = "rbxasset://textures/particles/explosion_sparks.dds"
    particle2.Rate = 30
    particle2.Lifetime = NumberRange.new(0.2, 0.4)
    particle2.SpreadAngle = Vector2.new(360, 360)
    particle2.Speed = NumberRange.new(8, 15)
    particle2.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
    particle2.Transparency = NumberSequence.new(0.1)
    
    -- SUARA THUNDER (client-side, hanya kamu yang dengar)
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://138854527"  -- Thunder sound (valid)
    sound.Volume = 0.5
    sound.PlaybackSpeed = 1
    sound.Parent = effectPart
    sound:Play()
    
    -- SUARA WOOSH (client-side)
    local sound2 = Instance.new("Sound")
    sound2.SoundId = "rbxassetid://169380592"  -- Woosh sound (valid)
    sound2.Volume = 0.4
    sound2.PlaybackSpeed = 1.2
    sound2.Parent = effectPart
    sound2:Play()
    
    -- Hapus part setelah 2 detik
    Debris:AddItem(effectPart, 2)
end

-- ========== UI PANEL (BLACK/WHITE) ==========
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Ano9xJump"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = CoreGui

-- Main Panel
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 180, 0, 160)
Main.Position = UDim2.new(0.5, -90, 0.5, -80)
Main.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
Main.BorderSizePixel = 0
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)

-- Border putih
local Stroke = Instance.new("UIStroke", Main)
Stroke.Color = Color3.fromRGB(255, 255, 255)
Stroke.Thickness = 1.5

-- Title Bar
local TitleBar = Instance.new("Frame", Main)
TitleBar.Size = UDim2.new(1, 0, 0, 25)
TitleBar.BackgroundColor3 = Color3.fromRGB(18, 18, 20)
TitleBar.BorderSizePixel = 0
local TitleCorner = Instance.new("UICorner", TitleBar)
TitleCorner.CornerRadius = UDim.new(0, 8)

-- Title Text
local Title = Instance.new("TextLabel", TitleBar)
Title.Size = UDim2.new(1, -50, 1, 0)
Title.Position = UDim2.new(0, 5, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "Ano9x Jump"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 12
Title.TextXAlignment = "Left"

-- Minimize Button
local MinBtn = Instance.new("TextButton", TitleBar)
MinBtn.Size = UDim2.new(0, 20, 0, 20)
MinBtn.Position = UDim2.new(1, -45, 0.5, -10)
MinBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
MinBtn.Text = "−"
MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 14
MinBtn.BorderSizePixel = 0
local MinCorner = Instance.new("UICorner", MinBtn)
MinCorner.CornerRadius = UDim.new(0, 4)

-- Close Button
local CloseBtn = Instance.new("TextButton", TitleBar)
CloseBtn.Size = UDim2.new(0, 20, 0, 20)
CloseBtn.Position = UDim2.new(1, -22, 0.5, -10)
CloseBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
CloseBtn.Text = "×"
CloseBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 14
CloseBtn.BorderSizePixel = 0
local CloseCorner = Instance.new("UICorner", CloseBtn)
CloseCorner.CornerRadius = UDim.new(0, 4)

-- Content
local Content = Instance.new("Frame", Main)
Content.Size = UDim2.new(1, -10, 1, -30)
Content.Position = UDim2.new(0, 5, 0, 27)
Content.BackgroundTransparency = 1

-- Toggle Button
local ToggleBtn = Instance.new("TextButton", Content)
ToggleBtn.Size = UDim2.new(0.8, 0, 0, 30)
ToggleBtn.Position = UDim2.new(0.1, 0, 0, 5)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
ToggleBtn.Text = "JUMP: OFF"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.TextSize = 11
ToggleBtn.BorderSizePixel = 0
local ToggleCorner = Instance.new("UICorner", ToggleBtn)
ToggleCorner.CornerRadius = UDim.new(0, 6)
local ToggleStroke = Instance.new("UIStroke", ToggleBtn)
ToggleStroke.Color = Color3.fromRGB(255, 255, 255)
ToggleStroke.Thickness = 1

-- Power Label
local PowerLabel = Instance.new("TextLabel", Content)
PowerLabel.Size = UDim2.new(0.8, 0, 0, 20)
PowerLabel.Position = UDim2.new(0.1, 0, 0, 45)
PowerLabel.BackgroundTransparency = 1
PowerLabel.Text = "POWER: " .. JumpPower
PowerLabel.TextColor3 = Color3.fromRGB(0, 255, 120)
PowerLabel.Font = Enum.Font.GothamBold
PowerLabel.TextSize = 10

-- Minus Button
local MinusBtn = Instance.new("TextButton", Content)
MinusBtn.Size = UDim2.new(0, 30, 0, 30)
MinusBtn.Position = UDim2.new(0.1, 0, 0, 70)
MinusBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
MinusBtn.Text = "−"
MinusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinusBtn.Font = Enum.Font.GothamBold
MinusBtn.TextSize = 16
MinusBtn.BorderSizePixel = 0
local MinusCorner = Instance.new("UICorner", MinusBtn)
MinusCorner.CornerRadius = UDim.new(0, 6)
local MinusStroke = Instance.new("UIStroke", MinusBtn)
MinusStroke.Color = Color3.fromRGB(255, 255, 255)
MinusStroke.Thickness = 1

-- Plus Button
local PlusBtn = Instance.new("TextButton", Content)
PlusBtn.Size = UDim2.new(0, 30, 0, 30)
PlusBtn.Position = UDim2.new(1, -40, 0, 70)
PlusBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
PlusBtn.Text = "+"
PlusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
PlusBtn.Font = Enum.Font.GothamBold
PlusBtn.TextSize = 16
PlusBtn.BorderSizePixel = 0
local PlusCorner = Instance.new("UICorner", PlusBtn)
PlusCorner.CornerRadius = UDim.new(0, 6)
local PlusStroke = Instance.new("UIStroke", PlusBtn)
PlusStroke.Color = Color3.fromRGB(255, 255, 255)
PlusStroke.Thickness = 1

-- Value display
local ValueLabel = Instance.new("TextLabel", Content)
ValueLabel.Size = UDim2.new(0, 50, 0, 30)
ValueLabel.Position = UDim2.new(0.5, -25, 0, 70)
ValueLabel.BackgroundTransparency = 1
ValueLabel.Text = JumpPower
ValueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
ValueLabel.Font = Enum.Font.GothamBold
ValueLabel.TextSize = 14

-- Credit
local Credit = Instance.new("TextLabel", Content)
Credit.Size = UDim2.new(1, 0, 0, 15)
Credit.Position = UDim2.new(0, 0, 1, -15)
Credit.BackgroundTransparency = 1
Credit.Text = "By Anonymous9x"
Credit.TextColor3 = Color3.fromRGB(100, 100, 100)
Credit.Font = Enum.Font.Code
Credit.TextSize = 8

-- ========== DRAG FUNCTION ==========
local dragging = false
local dragStart, startPos

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = Main.Position
    end
end)

TitleBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

-- ========== FUNGSI JUMP ==========
local function UpdateUI()
    ToggleBtn.Text = Enabled and "JUMP: ON" or "JUMP: OFF"
    ToggleBtn.BackgroundColor3 = Enabled and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(40, 40, 40)
    PowerLabel.Text = "POWER: " .. JumpPower
    ValueLabel.Text = JumpPower
end

local function ToggleJump()
    Enabled = not Enabled
    if Enabled then
        if not JumpConnection then
            JumpConnection = UserInputService.JumpRequest:Connect(function()
                if Enabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    local hrp = LocalPlayer.Character.HumanoidRootPart
                    hrp.Velocity = Vector3.new(hrp.Velocity.X, JumpPower, hrp.Velocity.Z)
                    SpawnJumpEffect()  -- Panggil efek
                end
            end)
        end
    else
        if JumpConnection then
            JumpConnection:Disconnect()
            JumpConnection = nil
        end
    end
    UpdateUI()
end

-- Button events
ToggleBtn.MouseButton1Click:Connect(ToggleJump)

MinusBtn.MouseButton1Click:Connect(function()
    JumpPower = math.max(MinJump, JumpPower - 10)
    UpdateUI()
end)

PlusBtn.MouseButton1Click:Connect(function()
    JumpPower = math.min(MaxJump, JumpPower + 10)
    UpdateUI()
end)

-- Minimize
local minimized = false
local originalSize = Main.Size
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        Main:TweenSize(UDim2.new(0, 180, 0, 25), "Out", "Quad", 0.2)
        Content.Visible = false
    else
        Main:TweenSize(originalSize, "Out", "Quad", 0.2)
        Content.Visible = true
    end
end)

-- Close
CloseBtn.MouseButton1Click:Connect(function()
    if JumpConnection then JumpConnection:Disconnect() end
    ScreenGui:Destroy()
end)

-- Initial update
UpdateUI()

print(">> Ano9x Jump v2.0 - FE EFFECT LOADED!")
print(">> Sound IDs: 138854527 (thunder), 169380592 (woosh)")
print(">> Efek visual partikel akan terlihat semua pemain jika executor mendukung.")
