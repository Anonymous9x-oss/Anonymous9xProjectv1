--[[
    Anonymous9x Ghost Mode  —  Upgraded Visual Edition
    By Anonymous9x
    Logic ORI 100% untouched. UI + visuals only upgraded.
    Fix: invis ON/OFF loop + mini status notif (bottom-right)
    Status now updates instantly on click (Ghost only)
    Status hides when panel closed.
]]

-- ═══════════════════════════════════════════════════
-- ORI CONFIG (UNCHANGED)
-- ═══════════════════════════════════════════════════
local key           = Enum.KeyCode.X
local invis_on      = false
local defaultSpeed  = 16
local boostedSpeed  = 48
local isSpeedBoosted = false

local player     = game.Players.LocalPlayer
local TweenSvc   = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- ═══════════════════════════════════════════════════
-- SOUND (ORI)
-- ═══════════════════════════════════════════════════
local sound = Instance.new("Sound", player:WaitForChild("PlayerGui"))
sound.SoundId = "rbxassetid://942127495"
sound.Volume  = 1

-- ═══════════════════════════════════════════════════
-- ORI FUNCTION: setTransparency (UNCHANGED)
-- ═══════════════════════════════════════════════════
local function setTransparency(character, transparency)
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") or part:IsA("Decal") then
            part.Transparency = transparency
        end
    end
end

-- ═══════════════════════════════════════════════════
-- GHOST TRAIL (afterimage visual — runs only when invis ON)
-- ═══════════════════════════════════════════════════
local AfterimageDuration = 0.7
local SpawnInterval      = 0.10
local trailActive        = false
local trailThread        = nil

local function createAfterimage(character)
    local ok, _ = pcall(function()
        character.Archivable = true
        local clone = character:Clone()
        local hum = clone:FindFirstChildOfClass("Humanoid")
        if hum then hum:Destroy() end
        local hrpC = clone:FindFirstChild("HumanoidRootPart")
        if hrpC then hrpC:Destroy() end

        for _, part in ipairs(clone:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Transparency = 0.25
                part.CanCollide   = false
                part.Anchored     = true
                part.CastShadow   = false
                TweenSvc:Create(part,
                    TweenInfo.new(AfterimageDuration),
                    {Transparency = 1}):Play()
            elseif part:IsA("Decal") then
                part.Transparency = 0.25
                TweenSvc:Create(part,
                    TweenInfo.new(AfterimageDuration),
                    {Transparency = 1}):Play()
            end
        end
        clone.Parent = workspace
        task.delay(AfterimageDuration + 0.1, function()
            pcall(function() clone:Destroy() end)
        end)
    end)
end

local function startTrail()
    trailActive = true
    trailThread = task.spawn(function()
        local lastPos = Vector3.new(0, -9999, 0)
        while trailActive do
            local char = player.Character
            if char then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local cur = hrp.Position
                    if (cur - lastPos).Magnitude > 0.15 then
                        task.spawn(createAfterimage, char)
                    end
                    lastPos = cur
                end
            end
            task.wait(SpawnInterval)
        end
    end)
end

local function stopTrail()
    trailActive = false
    trailThread = nil
end

-- ═══════════════════════════════════════════════════
-- GHOST BILLBOARD (floating "GhostAno9x" text above head)
-- ═══════════════════════════════════════════════════
local ghostBillboard = nil
local glitchConn     = nil

local GCHARS = {"#","X","/","_","!","0","G","h","o","s","t","@","*"}
local function scramble(s)
    local chars = {}
    for c in s:gmatch(".") do table.insert(chars, c) end
    local n = math.random(1, 2)
    for _ = 1, n do
        local i = math.random(1, #chars)
        chars[i] = GCHARS[math.random(1, #GCHARS)]
    end
    return table.concat(chars)
end

local function showGhostLabel()
    if ghostBillboard then ghostBillboard:Destroy() end
    if glitchConn     then glitchConn:Disconnect() end

    local char = player.Character
    if not char then return end
    local head = char:FindFirstChild("Head")
    if not head then return end

    ghostBillboard = Instance.new("BillboardGui")
    ghostBillboard.Name             = "_GhostBB"
    ghostBillboard.Size             = UDim2.fromOffset(130, 28)
    ghostBillboard.StudsOffset      = Vector3.new(0, 2.8, 0)
    ghostBillboard.AlwaysOnTop      = true
    ghostBillboard.ResetOnSpawn     = false
    ghostBillboard.ZIndexBehavior   = Enum.ZIndexBehavior.Sibling
    ghostBillboard.Parent           = head

    local lbl = Instance.new("TextLabel", ghostBillboard)
    lbl.Size               = UDim2.fromScale(1, 1)
    lbl.BackgroundTransparency = 1
    lbl.Text               = "GhostAno9x"
    lbl.Font               = Enum.Font.GothamBlack
    lbl.TextSize           = 13
    lbl.TextColor3         = Color3.new(1, 1, 1)
    lbl.TextStrokeColor3   = Color3.fromRGB(180, 130, 255)
    lbl.TextStrokeTransparency = 0.4
    lbl.TextXAlignment     = Enum.TextXAlignment.Center

    local t = 0
    local glitching = false
    local origText  = "GhostAno9x"
    glitchConn = RunService.Heartbeat:Connect(function(dt)
        t = t + dt
        if t > 0.70 then
            t = 0
            glitching = true
            lbl.TextColor3 = Color3.fromRGB(200, 160, 255)
            task.delay(0.055, function()
                glitching    = false
                lbl.Text     = origText
                lbl.TextColor3 = Color3.new(1, 1, 1)
            end)
        end
        if glitching then
            lbl.Text = scramble(origText)
        end
    end)
end

local function hideGhostLabel()
    if glitchConn     then glitchConn:Disconnect(); glitchConn = nil end
    if ghostBillboard then ghostBillboard:Destroy(); ghostBillboard = nil end
end

-- ═══════════════════════════════════════════════════
-- TOGGLE INVISIBILITY (BUG FIX + INSTANT MINI STATUS)
-- ═══════════════════════════════════════════════════
local _invisBusy = false

local statusLabel = nil

local function setStatus(text, color)
    if statusLabel then
        statusLabel.Text = text
        statusLabel.TextColor3 = color or Color3.new(1,1,1)
    end
end

local function turnOffInvis()
    _invisBusy = false
    invis_on = false
    local invisChair = workspace:FindFirstChild("invischair")
    if invisChair then invisChair:Destroy() end
    if player.Character then setTransparency(player.Character, 0) end
    hideGhostLabel()
    stopTrail()
    toggleButton.BackgroundColor3 = Color3.fromRGB(18, 18, 22)

    pcall(function()
        game.StarterGui:SetCore("SendNotification", {
            Title    = "Anonymous9x Ghost",
            Text     = "Back to reality, shadows clear — visible once more, nothing to fear.",
            Duration = 5,
        })
    end)
end

local function turnOnInvis()
    if _invisBusy then return end
    _invisBusy = true

    local char = player.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then _invisBusy = false; return end

    invis_on = true
    local savedpos = hrp.CFrame
    local farPos   = Vector3.new(-25.95, 84, 3537.55)

    task.wait(0.05)
    char:MoveTo(farPos)

    for _ = 1, 30 do
        task.wait(0.06)
        if not invis_on then _invisBusy = false; return end
        local curHRP = char:FindFirstChild("HumanoidRootPart")
        if curHRP and (curHRP.Position - farPos).Magnitude < 8 then break end
    end
    task.wait(0.05)

    if not invis_on then _invisBusy = false; return end

    local Seat = Instance.new("Seat", workspace)
    Seat.Anchored     = false
    Seat.CanCollide   = false
    Seat.Name         = "invischair"
    Seat.Transparency = 1
    Seat.Position     = farPos

    local Weld = Instance.new("Weld", Seat)
    Weld.Part0 = Seat
    Weld.Part1 = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
    Weld.C0    = CFrame.new()
    Weld.C1    = CFrame.new()

    task.wait(0.12)
    Seat.CFrame = savedpos
    task.wait(0.08)

    setTransparency(char, 0.5)

    showGhostLabel()
    startTrail()
    toggleButton.BackgroundColor3 = Color3.fromRGB(35, 35, 45)

    pcall(function()
        game.StarterGui:SetCore("SendNotification", {
            Title    = "Anonymous9x Ghost — ON",
            Text     = "A ghost unseen, a shadow free — none can catch what eyes can't see. Stay sharp!",
            Duration = 6,
        })
    end)

    _invisBusy = false
end

local function toggleInvisibility()
    sound:Play()
    if invis_on then
        setStatus("INVISIBLE OFF", Color3.fromRGB(255, 100, 100))
        turnOffInvis()
    else
        setStatus("INVISIBLE ON", Color3.fromRGB(100, 255, 100))
        task.spawn(turnOnInvis)
    end
end

-- ═══════════════════════════════════════════════════
-- ORI TOGGLE SPEED (UNCHANGED)
-- ═══════════════════════════════════════════════════
local function toggleSpeedBoost()
    isSpeedBoosted = not isSpeedBoosted
    sound:Play()
    local humanoid = player.Character and player.Character:FindFirstChild("Humanoid")
    if humanoid then
        if isSpeedBoosted then
            humanoid.WalkSpeed = boostedSpeed
            speedButton.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
            game.StarterGui:SetCore("SendNotification", {
                Title = "Anonymous9x Ghost", Duration = 3,
                Text  = "SPEED BOOST  ON  — " .. boostedSpeed
            })
        else
            humanoid.WalkSpeed = defaultSpeed
            speedButton.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
            game.StarterGui:SetCore("SendNotification", {
                Title = "Anonymous9x Ghost", Duration = 3,
                Text  = "SPEED BOOST  OFF  — " .. defaultSpeed
            })
        end
    end
end

-- ═══════════════════════════════════════════════════
-- ORI TURN OFF ALL (UNCHANGED)
-- ═══════════════════════════════════════════════════
local function turnOffAllFeatures()
    if invis_on then
        turnOffInvis()
    end
    if isSpeedBoosted then
        isSpeedBoosted = false
        local humanoid = player.Character and player.Character:FindFirstChild("Humanoid")
        if humanoid then humanoid.WalkSpeed = defaultSpeed end
        speedButton.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
    end
    sound:Play()
    game.StarterGui:SetCore("SendNotification", {
        Title = "Anonymous9x Ghost", Duration = 3,
        Text  = "All features OFF"
    })
    setStatus("Ghost Ready", Color3.new(0.7,0.7,0.7))
end

-- ═══════════════════════════════════════════════════
-- ORI CHARACTER RESPAWN RESET (UNCHANGED)
-- ═══════════════════════════════════════════════════
player.CharacterAdded:Connect(function(character)
    isSpeedBoosted = false
    invis_on       = false
    hideGhostLabel()
    stopTrail()
    local humanoid = character:WaitForChild("Humanoid")
    humanoid.WalkSpeed = defaultSpeed
    toggleButton.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
    speedButton.BackgroundColor3  = Color3.fromRGB(18, 18, 22)
    setStatus("Ghost Ready", Color3.new(0.5,0.5,0.5))
end)

-- ═══════════════════════════════════════════════════
-- UPGRADED UI
-- ═══════════════════════════════════════════════════
local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
screenGui.Name         = "GhostModeUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function() screenGui.Parent = game.CoreGui end)
if screenGui.Parent ~= game.CoreGui then
    screenGui.Parent = player.PlayerGui
end

-- Main card frame
local frame = Instance.new("Frame", screenGui)
frame.Size             = UDim2.fromOffset(118, 120)
frame.Position         = UDim2.new(0.5, -59, 0.5, -60)
frame.BackgroundColor3 = Color3.fromRGB(7, 7, 9)
frame.BackgroundTransparency = 0
frame.BorderSizePixel  = 0
frame.Active           = true
frame.Draggable        = true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

-- White border with glitch animation
local borderStroke = Instance.new("UIStroke", frame)
borderStroke.Color     = Color3.new(1, 1, 1)
borderStroke.Thickness = 1.5
borderStroke.Transparency = 0

task.spawn(function()
    local bt = 0
    while screenGui.Parent do
        bt = bt + task.wait(0.04)
        local pulse = math.sin(bt * 3)
        local r = 1
        local g = 0.92 + pulse * 0.08
        local b = 0.92 + math.abs(pulse) * 0.50
        borderStroke.Color = Color3.new(r, g, b)
        borderStroke.Thickness = 1.4 + math.abs(pulse) * 0.5

        if math.random(1, 90) == 1 then
            borderStroke.Color = Color3.fromRGB(200, 140, 255)
            task.wait(0.045)
        end
    end
end)

-- Title label
local titleLbl = Instance.new("TextLabel", frame)
titleLbl.Size               = UDim2.new(1, -28, 0, 20)
titleLbl.Position           = UDim2.fromOffset(8, 5)
titleLbl.BackgroundTransparency = 1
titleLbl.Text               = "Anonymous9x Ghost"
titleLbl.Font               = Enum.Font.GothamBlack
titleLbl.TextSize           = 9
titleLbl.TextColor3         = Color3.new(1, 1, 1)
titleLbl.TextXAlignment     = Enum.TextXAlignment.Left
titleLbl.TextTruncate       = Enum.TextTruncate.AtEnd

-- Close button
local closeButton = Instance.new("TextButton", frame)
closeButton.Size             = UDim2.fromOffset(19, 17)
closeButton.Position         = UDim2.new(1, -23, 0, 4)
closeButton.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
closeButton.BorderSizePixel  = 0
closeButton.Text             = "X"
closeButton.Font             = Enum.Font.GothamBold
closeButton.TextSize         = 10
closeButton.TextColor3       = Color3.new(1, 1, 1)
closeButton.AutoButtonColor  = false
Instance.new("UICorner", closeButton).CornerRadius = UDim.new(0, 4)

-- Helper: make a button
local function makeBtn(yOff, labelTxt)
    local b = Instance.new("TextButton", frame)
    b.Size             = UDim2.new(1, -16, 0, 30)
    b.Position         = UDim2.fromOffset(8, yOff)
    b.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
    b.BorderSizePixel  = 0
    b.Text             = labelTxt
    b.Font             = Enum.Font.GothamBold
    b.TextSize         = 10
    b.TextColor3       = Color3.new(1, 1, 1)
    b.AutoButtonColor  = false
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 5)
    local bS = Instance.new("UIStroke", b)
    bS.Color     = Color3.fromRGB(42, 42, 58)
    bS.Thickness = 0.9
    b.MouseEnter:Connect(function()
        TweenSvc:Create(b, TweenInfo.new(0.10),
            {BackgroundColor3 = Color3.fromRGB(26, 26, 34)}):Play()
    end)
    b.MouseLeave:Connect(function()
        if b.BackgroundColor3 ~= Color3.fromRGB(35, 35, 45) then
            TweenSvc:Create(b, TweenInfo.new(0.10),
                {BackgroundColor3 = Color3.fromRGB(18, 18, 22)}):Play()
        end
    end)
    return b
end

local toggleButton = makeBtn(28, "INVISIBLE")
local speedButton  = makeBtn(64, "SPEED BOOST")

-- Signature
local signatureLabel = Instance.new("TextLabel", frame)
signatureLabel.Size               = UDim2.new(1, 0, 0, 10)
signatureLabel.Position           = UDim2.new(0, 0, 1, -13)
signatureLabel.BackgroundTransparency = 1
signatureLabel.Text               = "By Anonymous9x"
signatureLabel.Font               = Enum.Font.Gotham
signatureLabel.TextSize           = 7
signatureLabel.TextColor3         = Color3.fromRGB(70, 70, 88)
signatureLabel.TextXAlignment     = Enum.TextXAlignment.Center

-- ═══════════════════════════════════════════════════
-- MINI STATUS UI (KANAN BAWAH) — HANYA UNTUK INVISIBLE
-- ═══════════════════════════════════════════════════
local statusFrame = Instance.new("Frame", screenGui)
statusFrame.Size = UDim2.fromOffset(160, 22)
statusFrame.Position = UDim2.new(1, -170, 1, -30)
statusFrame.BackgroundColor3 = Color3.fromRGB(10,10,10)
statusFrame.BackgroundTransparency = 0.4
statusFrame.BorderSizePixel = 0
Instance.new("UICorner", statusFrame).CornerRadius = UDim.new(0,6)

statusLabel = Instance.new("TextLabel", statusFrame)
statusLabel.Size = UDim2.fromScale(1,1)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Ghost Ready"
statusLabel.Font = Enum.Font.GothamBold
statusLabel.TextSize = 11
statusLabel.TextColor3 = Color3.new(0.7,0.7,0.7)
statusLabel.TextXAlignment = Enum.TextXAlignment.Center

-- ═══════════════════════════════════════════════════
-- WIRE BUTTONS
-- ═══════════════════════════════════════════════════
toggleButton.MouseButton1Click:Connect(toggleInvisibility)
speedButton.MouseButton1Click:Connect(toggleSpeedBoost)
closeButton.MouseButton1Click:Connect(function()
    turnOffAllFeatures()
    frame.Visible = false
    statusFrame.Visible = false  -- ✅ hide status when panel closed
end)

-- Init status
setStatus("Ghost Ready", Color3.new(0.7,0.7,0.7))
print("Anonymous9x Ghost — Upgraded V2")
