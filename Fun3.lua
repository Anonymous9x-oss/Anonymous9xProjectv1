--[[
    Anonymous9x Fun FE - Fix Version
    Fitur: Flashback, Glitch Spin (FE), Sleep Mode
    Tema hitam-putih, drag, minimize, scroll
]]

-- Anti duplicate
if _G.Anonymous9xFun then pcall(function() _G.Anonymous9xFunGUI:Destroy() end) end
_G.Anonymous9xFun = true

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local CoreGui = game:GetService("CoreGui")
local LP = Players.LocalPlayer
local PlayerGui = LP:WaitForChild("PlayerGui")

-- Helper functions
local function getChar() return LP.Character or LP.CharacterAdded:Wait() end
local function getHRP(c) return c and (c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("Torso") or c:FindFirstChild("UpperTorso") or c:FindFirstChildWhichIsA("BasePart")) end
local function getHum(c) return c and c:FindFirstChildWhichIsA("Humanoid") end
local function notify(t) pcall(function() game:GetService("StarterGui"):SetCore("SendNotification", {Title="Fun FE", Text=t, Duration=1.5}) end) end

-- ========== FITUR 1: FLASHBACK (FE) ==========
local flashback = {frames = {}, active = false, step = 1}

local function record()
    local c = getChar()
    local hrp = getHRP(c)
    local hum = getHum(c)
    if not (c and hrp and hum) then return end
    if #flashback.frames > 10000 then table.remove(flashback.frames, 1) end
    table.insert(flashback.frames, {hrp.CFrame, hrp.Velocity, hum:GetState(), hum.PlatformStand})
end

local function revert()
    local c = getChar()
    local hrp = getHRP(c)
    local hum = getHum(c)
    if not (c and hrp and hum) then return end
    local n = #flashback.frames
    if n == 0 then return end
    for i=1, flashback.step do
        if n > 0 then table.remove(flashback.frames, n) n = n - 1 end
    end
    if n == 0 then return end
    local f = flashback.frames[n]
    table.remove(flashback.frames, n)
    hrp.CFrame = f[1]
    hrp.Velocity = -f[2]
    hum:ChangeState(f[3])
    hum.PlatformStand = f[4]
end

-- ========== FITUR 2: GLITCH SPIN (FE) ==========
local glitchSpin = {active = false, speed = 30}

local function createGlitchPart(pos)
    local p = Instance.new("Part")
    p.Size = Vector3.new(1,1,1)
    p.Position = pos
    p.Anchored = true
    p.CanCollide = false
    p.Material = Enum.Material.Neon
    p.BrickColor = BrickColor.new("Really black")
    p.Transparency = 0.3
    p.Parent = workspace  -- FE: semua orang lihat

    local mesh = Instance.new("SpecialMesh", p)
    mesh.MeshType = Enum.MeshType.Sphere
    mesh.Scale = Vector3.new(1.5,1.5,1.5)

    local particle = Instance.new("ParticleEmitter", p)
    particle.Texture = "rbxasset://textures/particles/sparkles_main.dds"
    particle.Rate = 50
    particle.Lifetime = NumberRange.new(0.1, 0.3)
    particle.Speed = NumberRange.new(5, 10)
    particle.SpreadAngle = Vector2.new(360,360)
    particle.Color = ColorSequence.new(Color3.new(0,0,0))
    particle.Transparency = NumberSequence.new(0.2)

    Debris:AddItem(p, 0.2)
    return p
end

local function glitchSpinUpdate()
    if not glitchSpin.active then return end
    local hrp = getHRP(getChar())
    if not hrp then return end

    hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(glitchSpin.speed), 0)

    if math.random() < 0.3 then
        local pos = hrp.Position + Vector3.new(math.random(-8,8), math.random(-5,5), math.random(-8,8))
        createGlitchPart(pos)
    end
end

-- ========== FITUR 3: SLEEP MODE ==========
local sleepMode = {active = false}
local originalWelds = {}  -- untuk menyimpan C0 asli jika perlu, tapi kita bisa reset dengan state

local function setSleepMode(on)
    local char = getChar()
    local hum = getHum(char)
    local hrp = getHRP(char)
    if not (char and hum and hrp) then return end

    if on then
        -- Set humanoid state to sleeping? Tidak ada state tidur, jadi kita manipulasi welds
        hum.PlatformStand = true  -- biar seperti mati
        hum.AutoRotate = false
        -- Atur posisi tubuh seperti tidur
        local torso = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
        local head = char:FindFirstChild("Head")
        local rarm = char:FindFirstChild("Right Arm") or char:FindFirstChild("RightHand")
        local larm = char:FindFirstChild("Left Arm") or char:FindFirstChild("LeftHand")
        local rleg = char:FindFirstChild("Right Leg") or char:FindFirstChild("RightFoot")
        local lleg = char:FindFirstChild("Left Leg") or char:FindFirstChild("LeftFoot")

        if torso and head then
            -- Simpan welds asli? Tidak perlu, kita akan set C0 langsung dan nanti kembalikan
            -- Tapi karena mungkin ada weld asli, kita simpan dulu
            local neck = torso:FindFirstChild("Neck") or head:FindFirstChild("Neck")
            if neck then
                neck.C0 = CFrame.new(0, 1, 0) * CFrame.Angles(math.rad(90), 0, 0)
            end
        end
        -- Sederhananya, kita bisa menggunakan animation atau langsung set welds
        -- Untuk memudahkan, kita akan buat semua bagian menghadap ke bawah
        hrp.CFrame = hrp.CFrame * CFrame.Angles(math.rad(90), 0, 0)
        hum.PlatformStand = true
    else
        hum.PlatformStand = false
        hum.AutoRotate = true
        -- Kembalikan ke posisi normal (akan diurus oleh animasi default)
    end
end

-- ========== RENDER LOOP ==========
local conn = RunService.RenderStepped:Connect(function()
    if flashback.active then revert() else record() end
    glitchSpinUpdate()
end)

-- ========== UI PANEL ==========
local gui = Instance.new("ScreenGui")
gui.Name = "A9xFun"
gui.ResetOnSpawn = false
gui.Parent = CoreGui or PlayerGui
_G.Anonymous9xFunGUI = gui

-- Main panel (280x240)
local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 280, 0, 240)
main.Position = UDim2.new(0.5, -140, 0.5, -120)
main.BackgroundColor3 = Color3.fromRGB(10,10,10)
Instance.new("UICorner", main).CornerRadius = UDim.new(0,8)
Instance.new("UIStroke", main).Color = Color3.new(1,1,1)

-- Title bar
local bar = Instance.new("Frame", main)
bar.Size = UDim2.new(1,0,0,30)
bar.BackgroundColor3 = Color3.fromRGB(15,15,15)
Instance.new("UICorner", bar).CornerRadius = UDim.new(0,8)

local title = Instance.new("TextLabel", bar)
title.Size = UDim2.new(1,-60,1,0)
title.Position = UDim2.new(0,8,0,0)
title.BackgroundTransparency = 1
title.Text = "Anonymous9x Fun FE"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold
title.TextSize = 12
title.TextXAlignment = "Left"

local minBtn = Instance.new("TextButton", bar)
minBtn.Size = UDim2.new(0,24,0,24)
minBtn.Position = UDim2.new(1,-52,0.5,-12)
minBtn.BackgroundColor3 = Color3.fromRGB(40,40,40)
minBtn.Text = "−"
minBtn.TextColor3 = Color3.new(1,1,1)
minBtn.Font = Enum.Font.GothamBold
minBtn.TextSize = 14
Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0,4)

local closeBtn = Instance.new("TextButton", bar)
closeBtn.Size = UDim2.new(0,24,0,24)
closeBtn.Position = UDim2.new(1,-26,0.5,-12)
closeBtn.BackgroundColor3 = Color3.fromRGB(200,40,40)
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.new(1,1,1)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 12
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0,4)

-- Content with scrolling
local content = Instance.new("ScrollingFrame", main)
content.Size = UDim2.new(1,-12,1,-36)
content.Position = UDim2.new(0,6,0,34)
content.BackgroundTransparency = 1
content.ScrollBarThickness = 4
content.ScrollBarImageColor3 = Color3.fromRGB(255,255,255)
content.CanvasSize = UDim2.new(0,0,0,0)
content.AutomaticCanvasSize = Enum.AutomaticSize.Y

local layout = Instance.new("UIListLayout", content)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0,10)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- Helper to create toggle sections
local function createToggleSection(title, desc, callback)
    local section = Instance.new("Frame", content)
    section.Size = UDim2.new(1, -10, 0, 70)
    section.BackgroundColor3 = Color3.fromRGB(18,18,18)
    Instance.new("UICorner", section).CornerRadius = UDim.new(0,6)
    local secStroke = Instance.new("UIStroke", section)
    secStroke.Color = Color3.fromRGB(45,45,45)
    secStroke.Thickness = 1

    local titleLbl = Instance.new("TextLabel", section)
    titleLbl.Size = UDim2.new(1,-80,0,20)
    titleLbl.Position = UDim2.new(0,8,0,5)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = title
    titleLbl.TextColor3 = Color3.new(1,1,1)
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.TextSize = 12
    titleLbl.TextXAlignment = "Left"

    local descLbl = Instance.new("TextLabel", section)
    descLbl.Size = UDim2.new(1,-80,0,16)
    descLbl.Position = UDim2.new(0,8,0,26)
    descLbl.BackgroundTransparency = 1
    descLbl.Text = desc
    descLbl.TextColor3 = Color3.fromRGB(150,150,150)
    descLbl.Font = Enum.Font.Gotham
    descLbl.TextSize = 9
    descLbl.TextXAlignment = "Left"

    local toggle = Instance.new("TextButton", section)
    toggle.Size = UDim2.new(0,60,0,28)
    toggle.Position = UDim2.new(1,-70,0,10)
    toggle.BackgroundColor3 = Color3.fromRGB(40,40,40)
    toggle.Text = "OFF"
    toggle.TextColor3 = Color3.new(1,1,1)
    toggle.Font = Enum.Font.GothamBold
    toggle.TextSize = 10
    Instance.new("UICorner", toggle).CornerRadius = UDim.new(0,5)

    local isOn = false
    toggle.MouseButton1Click:Connect(function()
        isOn = not isOn
        toggle.Text = isOn and "ON" or "OFF"
        toggle.BackgroundColor3 = isOn and Color3.fromRGB(0,120,0) or Color3.fromRGB(40,40,40)
        callback(isOn)
    end)
end

-- Buat section
createToggleSection("⏪ Flashback", "Hold ON to rewind time", function(on)
    flashback.active = on
end)

createToggleSection("🌀 Glitch Spin", "Super fast spin with black glitch effects (FE)", function(on)
    glitchSpin.active = on
end)

createToggleSection("😴 Sleep Mode", "Lie down like sleeping (toggle off to wake)", function(on)
    setSleepMode(on)
end)

-- Tombol reset flashback (di bawah)
local reset = Instance.new("TextButton", content)
reset.Size = UDim2.new(1, -10, 0, 30)
reset.BackgroundColor3 = Color3.fromRGB(30,30,30)
reset.Text = "🗑 Reset Flashback Data"
reset.TextColor3 = Color3.fromRGB(200,200,200)
reset.Font = Enum.Font.Gotham
reset.TextSize = 9
Instance.new("UICorner", reset).CornerRadius = UDim.new(0,5)
reset.MouseButton1Click:Connect(function()
    flashback.frames = {}
    flashback.active = false
    notify("Flashback data cleared")
end)

-- Drag functionality
local dragging, dragStart, dragPos, dragInput
bar.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = i.Position
        dragPos = main.Position
        i.Changed:Connect(function()
            if i.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
bar.InputChanged:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then
        dragInput = i
    end
end)
UserInputService.InputChanged:Connect(function(i)
    if dragging and i == dragInput then
        local delta = i.Position - dragStart
        main.Position = UDim2.new(dragPos.X.Scale, dragPos.X.Offset + delta.X, dragPos.Y.Scale, dragPos.Y.Offset + delta.Y)
    end
end)

-- Minimize
local minimized = false
minBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        main:TweenSize(UDim2.new(0,280,0,30), "Out", "Quad", 0.2)
        content.Visible = false
        minBtn.Text = "+"
    else
        main:TweenSize(UDim2.new(0,280,0,240), "Out", "Quad", 0.2)
        content.Visible = true
        minBtn.Text = "−"
    end
end)

-- Close
closeBtn.MouseButton1Click:Connect(function()
    conn:Disconnect()
    setSleepMode(false)
    gui:Destroy()
    _G.Anonymous9xFunGUI = nil
end)

-- Animasi masuk
main.Size = UDim2.new(0,0,0,0)
main:TweenSize(UDim2.new(0,280,0,240), "Out", "Back", 0.5)

print("✅ Anonymous9x Fun FE loaded!")
print("🔥 Features: Flashback, Glitch Spin, Sleep Mode")
