-- Anonymous9x Retroslop
-- Transforms text into retroslop and spams 5 chat messages
-- FE Compatible | All games | No external libraries

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInput = game:GetService("UserInputService")
local TextChatSvc = game:GetService("TextChatService")
local ReplicatedSto = game:GetService("ReplicatedStorage")
local LP = Players.LocalPlayer

-- ══════════════════════════════════════
-- RETROSLOP ENGINE
-- ══════════════════════════════════════

local SLANG = {
    ["hello"] = "haiii", ["hi"] = "hai", ["love"] = "wuv", ["what"] = "wut",
    ["why"] = "wai", ["stop"] = "stahp", ["cool"] = "kewl", ["please"] = "plz",
}

local LEET = {
    ["a"] = "4", ["A"] = "4", ["e"] = "3", ["E"] = "3", ["i"] = "1", ["I"] = "1",
    ["o"] = "0", ["O"] = "0", ["s"] = "5", ["S"] = "5", ["t"] = "7", ["T"] = "7",
}

local EMOTES = {
    ":333","xD","OwO","UwU",">_<","^_^","T_T",";3","x_x","XD",":P","rawr","rawrrr","rawer",">w<",
    "qwq","ono","unu"," :3 ","X3","ツ",
}

local function slopify(str)
    local s = str:lower()
    for word, replacement in pairs(SLANG) do
        s = s:gsub("%f[%a]" .. word .. "%f[%A]", replacement)
    end
    local leet = {}
    for i = 1, #s do
        local ch = s:sub(i, i)
        leet[i] = LEET[ch] or ch
    end
    s = table.concat(leet)
    local alt = {}
    for i = 1, #s do
        local ch = s:sub(i, i)
        if ch:match("%a") then
            alt[i] = (math.random() < 0.5) and ch:upper() or ch:lower()
        else
            alt[i] = ch
        end
    end
    s = table.concat(alt)
    local excl = math.random(4, 8)
    s = s .. string.rep("!", excl)
    s = s .. " " .. EMOTES[math.random(1, #EMOTES)]
    return s
end

-- ══════════════════════════════════════
-- CHAT SENDER
-- ══════════════════════════════════════

local function sendChat(msg)
    pcall(function()
        if TextChatSvc.ChatVersion == Enum.ChatVersion.TextChatService then
            local ch = TextChatSvc:FindFirstChild("TextChannels")
            if ch then
                local gen = ch:FindFirstChild("RBXGeneral")
                if gen then
                    gen:SendAsync(msg)
                    return
                end
            end
        end
    end)
    pcall(function()
        local chatEvents = ReplicatedSto:FindFirstChild("DefaultChatSystemChatEvents")
        if chatEvents then
            local sayEvent = chatEvents:FindFirstChild("SayMessageRequest")
            if sayEvent then
                sayEvent:FireServer(msg, "All")
            end
        end
    end)
end

-- ══════════════════════════════════════
-- GUI SETUP
-- ══════════════════════════════════════

pcall(function() local old = LP.PlayerGui:FindFirstChild("RetroslopGUI") if old then old:Destroy() end end)
pcall(function() local old = game.CoreGui:FindFirstChild("RetroslopGUI") if old then old:Destroy() end end)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RetroslopGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true
pcall(function() ScreenGui.Parent = game.CoreGui end)
if not ScreenGui.Parent then ScreenGui.Parent = LP.PlayerGui end

local PW, PH = 330, 180
local PURPLE = Color3.fromRGB(165, 55, 255)
local WHITE = Color3.new(1, 1, 1)
local BGDARK = Color3.fromRGB(10, 10, 10)
local BGINPUT = Color3.fromRGB(26, 26, 26)
local GREY = Color3.fromRGB(110, 110, 110)

local Panel = Instance.new("Frame")
Panel.Name = "Panel"
Panel.Size = UDim2.fromOffset(PW, PH)
Panel.Position = UDim2.fromScale(0.5, 0.5)
Panel.AnchorPoint = Vector2.new(0.5, 0.5)
Panel.BackgroundColor3 = BGDARK
Panel.BackgroundTransparency = 0
Panel.BorderSizePixel = 0
Panel.Active = true
Panel.Draggable = true
Panel.ZIndex = 10
Panel.Parent = ScreenGui
Instance.new("UICorner", Panel).CornerRadius = UDim.new(0, 10)

local BorderStroke = Instance.new("UIStroke")
BorderStroke.Color = WHITE
BorderStroke.Thickness = 1.4
BorderStroke.Transparency = 0
BorderStroke.Parent = Panel

task.spawn(function()
    local t = 0
    while Panel.Parent do
        t = t + task.wait(0.04)
        local s = (math.sin(t * 1.8) + 1) / 2
        BorderStroke.Color = WHITE:Lerp(PURPLE, s)
        BorderStroke.Thickness = 1.2 + s * 0.9
    end
end)

Panel.Size = UDim2.fromOffset(0, 0)
Panel.Position = UDim2.fromScale(0.5, 0.5)
TweenService:Create(Panel, TweenInfo.new(0.5, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {
    Size = UDim2.fromOffset(PW, PH),
    Position = UDim2.fromScale(0.5, 0.5),
}):Play()

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 42)
Header.BackgroundTransparency = 1
Header.ZIndex = 11
Header.Parent = Panel

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0.75, 0, 0, 20)
Title.Position = UDim2.fromOffset(12, 8)
Title.BackgroundTransparency = 1
Title.Text = "Anonymous9x Retroslop"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 13
Title.TextColor3 = WHITE
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.ZIndex = 12
Title.Parent = Header

local Subtitle = Instance.new("TextLabel")
Subtitle.Size = UDim2.new(0.75, 0, 0, 14)
Subtitle.Position = UDim2.fromOffset(12, 27)
Subtitle.BackgroundTransparency = 1
Subtitle.Text = "Spam slank random chat"
Subtitle.Font = Enum.Font.Gotham
Subtitle.TextSize = 9
Subtitle.TextColor3 = GREY
Subtitle.TextXAlignment = Enum.TextXAlignment.Left
Subtitle.ZIndex = 12
Subtitle.Parent = Header

local function makeCtrlBtn(xOff, label)
    local b = Instance.new("TextButton")
    b.Size = UDim2.fromOffset(20, 18)
    b.Position = UDim2.new(1, xOff, 0, 7)
    b.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    b.BackgroundTransparency = 0
    b.BorderSizePixel = 0
    b.Text = label
    b.Font = Enum.Font.GothamBold
    b.TextSize = 12
    b.TextColor3 = GREY
    b.ZIndex = 13
    b.Parent = Panel
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
    b.MouseEnter:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.10), {TextColor3 = WHITE}):Play()
    end)
    b.MouseLeave:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.10), {TextColor3 = GREY}):Play()
    end)
    return b
end

local CloseBtn = makeCtrlBtn(-26, "x")
local MinimizeBtn = makeCtrlBtn(-50, "-")

local minimized = false
local ContentFrame

CloseBtn.MouseButton1Click:Connect(function()
    TweenService:Create(Panel, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        Size = UDim2.fromOffset(0, 0),
        Position = UDim2.fromScale(0.5, 0.5),
    }):Play()
    task.delay(0.22, function() pcall(function() ScreenGui:Destroy() end) end)
end)

local Sep = Instance.new("Frame")
Sep.Size = UDim2.new(0.92, 0, 0, 1)
Sep.Position = UDim2.new(0.04, 0, 0, 42)
Sep.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Sep.BorderSizePixel = 0
Sep.ZIndex = 11
Sep.Parent = Panel

ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, 0, 1, -44)
ContentFrame.Position = UDim2.fromOffset(0, 44)
ContentFrame.BackgroundTransparency = 1
ContentFrame.ZIndex = 11
ContentFrame.Parent = Panel

-- PERBAIKAN MINIMIZE: sembunyikan garis pemisah juga
MinimizeBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if ContentFrame then ContentFrame.Visible = not minimized end
    Sep.Visible = not minimized   -- garis pemisah ikut hilang saat minimize

    local targetH = minimized and 42 or PH
    TweenService:Create(Panel, TweenInfo.new(0.16, Enum.EasingStyle.Quad), {
        Size = UDim2.fromOffset(PW, targetH)
    }):Play()
    MinimizeBtn.Text = minimized and "+" or "-"
end)

-- ========== UPGRADE TEXTBOX ==========
-- Ukuran lebih kecil, font regular, warna putih, tanpa stroke/glow
local InputBox = Instance.new("TextBox")
InputBox.Size = UDim2.new(0.92, 0, 0, 40)
InputBox.Position = UDim2.new(0.04, 0, 0, 6)
InputBox.BackgroundColor3 = BGINPUT
InputBox.BackgroundTransparency = 0
InputBox.BorderSizePixel = 0
InputBox.PlaceholderText = "Type message"
InputBox.PlaceholderColor3 = Color3.fromRGB(80, 80, 80)
InputBox.Text = ""
InputBox.Font = Enum.Font.Gotham          -- regular, tidak bold
InputBox.TextSize = 11                    -- lebih kecil dari sebelumnya (12)
InputBox.TextColor3 = WHITE               -- putih bersih
InputBox.ClearTextOnFocus = false
InputBox.MultiLine = false
InputBox.ZIndex = 12
InputBox.Parent = ContentFrame
Instance.new("UICorner", InputBox).CornerRadius = UDim.new(0, 6)

-- Hapus semua efek stroke/glow pada textbox (tidak ada UIStroke, tidak ada tween warna)
-- (Dulu ada InputStroke, sekarang dihilangkan total)

-- =====================================

local SpamBtn = Instance.new("TextButton")
SpamBtn.Size = UDim2.new(0.92, 0, 0, 38)
SpamBtn.Position = UDim2.new(0.04, 0, 0, 52)
SpamBtn.BackgroundColor3 = PURPLE
SpamBtn.BorderSizePixel = 0
SpamBtn.Text = "SLOP & SPAM 5X"
SpamBtn.Font = Enum.Font.GothamBold
SpamBtn.TextSize = 13
SpamBtn.TextColor3 = WHITE
SpamBtn.AutoButtonColor = false
SpamBtn.ZIndex = 12
SpamBtn.Parent = ContentFrame
Instance.new("UICorner", SpamBtn).CornerRadius = UDim.new(0, 7)

local PURPLE_BRIGHT = Color3.fromRGB(190, 85, 255)
SpamBtn.MouseEnter:Connect(function() TweenService:Create(SpamBtn, TweenInfo.new(0.12), {BackgroundColor3 = PURPLE_BRIGHT}):Play() end)
SpamBtn.MouseLeave:Connect(function() TweenService:Create(SpamBtn, TweenInfo.new(0.12), {BackgroundColor3 = PURPLE}):Play() end)

local ProgressBG = Instance.new("Frame")
ProgressBG.Size = UDim2.new(0.92, 0, 0, 5)
ProgressBG.Position = UDim2.new(0.04, 0, 0, 96)
ProgressBG.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ProgressBG.BackgroundTransparency = 0
ProgressBG.BorderSizePixel = 0
ProgressBG.Visible = false
ProgressBG.ZIndex = 12
ProgressBG.Parent = ContentFrame
Instance.new("UICorner", ProgressBG).CornerRadius = UDim.new(1, 0)

local ProgressFill = Instance.new("Frame")
ProgressFill.Size = UDim2.new(0, 0, 1, 0)
ProgressFill.BackgroundColor3 = PURPLE
ProgressFill.BorderSizePixel = 0
ProgressFill.ZIndex = 13
ProgressFill.Parent = ProgressBG
Instance.new("UICorner", ProgressFill).CornerRadius = UDim.new(1, 0)

local EmptyNotif = Instance.new("TextLabel")
EmptyNotif.Size = UDim2.new(0.92, 0, 0, 18)
EmptyNotif.Position = UDim2.new(0.04, 0, 0, 104)
EmptyNotif.BackgroundTransparency = 1
EmptyNotif.Text = "Text is empty!"
EmptyNotif.Font = Enum.Font.GothamBold
EmptyNotif.TextSize = 10
EmptyNotif.TextColor3 = Color3.fromRGB(255, 80, 80)
EmptyNotif.TextXAlignment = Enum.TextXAlignment.Center
EmptyNotif.TextTransparency = 1
EmptyNotif.ZIndex = 13
EmptyNotif.Parent = ContentFrame

local function showEmpty()
    EmptyNotif.TextTransparency = 1
    TweenService:Create(EmptyNotif, TweenInfo.new(0.25), {TextTransparency = 0}):Play()
    task.delay(1.0, function() TweenService:Create(EmptyNotif, TweenInfo.new(0.35), {TextTransparency = 1}):Play() end)
end

-- Drag support (mobile + PC)
do
    local dragging, dragRef, startIP, startPanelPos = false, nil, nil, nil
    UserInput.InputBegan:Connect(function(inp, gp)
        if gp then return end
        local isTouch = inp.UserInputType == Enum.UserInputType.Touch
        local isMouse = inp.UserInputType == Enum.UserInputType.MouseButton1
        if not (isTouch or isMouse) then return end
        local ap = Header.AbsolutePosition
        local az = Header.AbsoluteSize
        local px, py = inp.Position.X, inp.Position.Y
        if px < ap.X or px > ap.X + az.X - 52 then return end
        if py < ap.Y or py > ap.Y + az.Y then return end
        dragging = true
        dragRef = inp
        startIP = Vector2.new(px, py)
        startPanelPos = Vector2.new(Panel.AbsolutePosition.X, Panel.AbsolutePosition.Y)
    end)
    UserInput.InputChanged:Connect(function(inp)
        if not dragging then return end
        local isMove = inp.UserInputType == Enum.UserInputType.MouseMovement
        local isTouch = inp.UserInputType == Enum.UserInputType.Touch
        if not (isMove or isTouch) then return end
        if isTouch and inp ~= dragRef then return end
        local delta = Vector2.new(inp.Position.X, inp.Position.Y) - startIP
        local vp = game.Workspace.CurrentCamera.ViewportSize
        Panel.Position = UDim2.fromOffset(
            math.clamp(startPanelPos.X + delta.X, 0, vp.X - PW),
            math.clamp(startPanelPos.Y + delta.Y, 0, vp.Y - PH)
        )
    end)
    UserInput.InputEnded:Connect(function(inp)
        if inp == dragRef or inp.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
            dragRef = nil
        end
    end)
end

-- ══════════════════════════════════════
-- SPAM LOGIC
-- ══════════════════════════════════════

local spamming = false
SpamBtn.MouseButton1Click:Connect(function()
    if spamming then return end
    local raw = InputBox.Text
    if raw == "" or raw:match("^%s*$") then
        showEmpty()
        return
    end
    spamming = true
    InputBox.Text = ""
    SpamBtn.AutoButtonColor = false
    SpamBtn.BackgroundColor3 = Color3.fromRGB(100, 30, 160)
    SpamBtn.Text = "Sending..."
    ProgressBG.Visible = true
    ProgressFill.Size = UDim2.new(0, 0, 1, 0)
    local progTween = TweenService:Create(ProgressFill, TweenInfo.new(3.0, Enum.EasingStyle.Linear), { Size = UDim2.new(1, 0, 1, 0) })
    progTween:Play()
    task.spawn(function()
        for i = 1, 5 do
            local slopped = slopify(raw)
            sendChat(slopped)
            task.wait(0.6)
        end
        progTween:Cancel()
        TweenService:Create(ProgressFill, TweenInfo.new(0.2), { Size = UDim2.new(1, 0, 1, 0) }):Play()
        task.wait(0.25)
        TweenService:Create(ProgressBG, TweenInfo.new(0.3), { BackgroundTransparency = 1 }):Play()
        task.wait(0.35)
        ProgressBG.Visible = false
        ProgressBG.BackgroundTransparency = 0
        ProgressFill.Size = UDim2.new(0, 0, 1, 0)
        SpamBtn.Text = "SLOP & SPAM 5X"
        SpamBtn.BackgroundColor3 = PURPLE
        spamming = false
    end)
end)
