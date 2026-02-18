--[[
    Anonymous9x Exec - Universal Script Executor
    - Textbox dengan teks awal "input"
    - Tombol EXECUTE putih teks hitam
    - Notifikasi sukses/error
    - UI hitam-putih, ukuran 190x220, di tengah, tidak bisa di-drag
    - Animasi masuk modern
]]

-- Anti duplicate
if _G.Anonymous9xExec then
    pcall(function() _G.Anonymous9xExecGUI:Destroy() end)
end
_G.Anonymous9xExec = true

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Fungsi untuk membuat GUI (dipanggil setelah semuanya siap)
local function createGUI()
    -- Tentukan parent (prioritas CoreGui, fallback ke PlayerGui)
    local parent = CoreGui
    if not parent then parent = PlayerGui end

    local gui = Instance.new("ScreenGui")
    gui.Name = "Anonymous9xExec"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent = parent
    _G.Anonymous9xExecGUI = gui

    -- Main frame
    local main = Instance.new("Frame", gui)
    main.Size = UDim2.new(0, 190, 0, 220)
    main.Position = UDim2.new(0.5, -95, 0.5, -110)
    main.BackgroundColor3 = Color3.fromRGB(8,8,8)
    main.BorderSizePixel = 0
    main.BackgroundTransparency = 1
    Instance.new("UICorner", main).CornerRadius = UDim.new(0,8)
    local stroke = Instance.new("UIStroke", main)
    stroke.Color = Color3.fromRGB(255,255,255)
    stroke.Thickness = 1.5
    stroke.Transparency = 1

    -- Title bar
    local titleBar = Instance.new("Frame", main)
    titleBar.Size = UDim2.new(1,0,0,30)
    titleBar.BackgroundColor3 = Color3.fromRGB(15,15,15)
    titleBar.BorderSizePixel = 0
    titleBar.BackgroundTransparency = 1
    Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0,8)

    local title = Instance.new("TextLabel", titleBar)
    title.Size = UDim2.new(1,-35,1,0)
    title.Position = UDim2.new(0,8,0,0)
    title.BackgroundTransparency = 1
    title.Text = "Anonymous9x Exec"
    title.TextColor3 = Color3.new(1,1,1)
    title.Font = Enum.Font.Gotham
    title.TextSize = 12
    title.TextXAlignment = "Left"
    title.TextTransparency = 1

    -- Close button
    local closeBtn = Instance.new("TextButton", titleBar)
    closeBtn.Size = UDim2.new(0,25,0,25)
    closeBtn.Position = UDim2.new(1,-28,0.5,-12.5)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200,40,40)
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.new(1,1,1)
    closeBtn.Font = Enum.Font.Gotham
    closeBtn.TextSize = 14
    closeBtn.BorderSizePixel = 0
    closeBtn.BackgroundTransparency = 1
    closeBtn.TextTransparency = 1
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0,4)

    -- Content
    local content = Instance.new("Frame", main)
    content.Size = UDim2.new(1,-12,1,-36)
    content.Position = UDim2.new(0,6,0,34)
    content.BackgroundTransparency = 1

    -- TextBox dengan teks awal "input"
    local scriptBox = Instance.new("TextBox", content)
    scriptBox.Size = UDim2.new(1,0,0,120)
    scriptBox.Position = UDim2.new(0,0,0,0)
    scriptBox.BackgroundTransparency = 1
    scriptBox.BorderSizePixel = 0
    scriptBox.TextColor3 = Color3.new(1,1,1)
    scriptBox.PlaceholderColor3 = Color3.fromRGB(120,120,120)
    scriptBox.PlaceholderText = ""
    scriptBox.Text = "input"
    scriptBox.Font = Enum.Font.Gotham
    scriptBox.TextSize = 10
    scriptBox.TextXAlignment = "Left"
    scriptBox.TextYAlignment = "Top"
    scriptBox.TextWrapped = true
    scriptBox.MultiLine = true
    scriptBox.ClearTextOnFocus = false
    scriptBox.TextTransparency = 1

    -- Tombol Execute
    local execBtn = Instance.new("TextButton", content)
    execBtn.Size = UDim2.new(1,0,0,35)
    execBtn.Position = UDim2.new(0,0,0,130)
    execBtn.BackgroundColor3 = Color3.fromRGB(255,255,255)
    execBtn.Text = "EXECUTE"
    execBtn.TextColor3 = Color3.fromRGB(0,0,0)
    execBtn.Font = Enum.Font.Gotham
    execBtn.TextSize = 12
    execBtn.BorderSizePixel = 0
    execBtn.BackgroundTransparency = 1
    execBtn.TextTransparency = 1
    Instance.new("UICorner", execBtn).CornerRadius = UDim.new(0,6)
    local execStroke = Instance.new("UIStroke", execBtn)
    execStroke.Color = Color3.fromRGB(255,255,255)
    execStroke.Thickness = 1
    execStroke.Transparency = 1

    -- Status label
    local statusLabel = Instance.new("TextLabel", content)
    statusLabel.Size = UDim2.new(1,0,0,20)
    statusLabel.Position = UDim2.new(0,0,0,170)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = ""
    statusLabel.TextColor3 = Color3.fromRGB(150,150,150)
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.TextSize = 9
    statusLabel.TextXAlignment = "Center"
    statusLabel.TextTransparency = 1

    -- ========== NOTIFICATION SYSTEM ==========
    local function showNotification(title, text, duration, isSuccess)
        duration = duration or 3
        local notifGui = Instance.new("ScreenGui")
        notifGui.Name = "ExecNotification"
        notifGui.ResetOnSpawn = false
        notifGui.Parent = parent

        local notifFrame = Instance.new("Frame", notifGui)
        notifFrame.Size = UDim2.new(0, 250, 0, 50)
        notifFrame.Position = UDim2.new(0.5, -125, 0, -50)
        notifFrame.BackgroundColor3 = Color3.fromRGB(20,20,20)
        notifFrame.BorderSizePixel = 0
        Instance.new("UICorner", notifFrame).CornerRadius = UDim.new(0,6)
        local notifStroke = Instance.new("UIStroke", notifFrame)
        notifStroke.Color = isSuccess and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,0,0)
        notifStroke.Thickness = 1.5

        local icon = Instance.new("TextLabel", notifFrame)
        icon.Size = UDim2.new(0, 30, 1, 0)
        icon.Position = UDim2.new(0, 5, 0, 0)
        icon.BackgroundTransparency = 1
        icon.Text = isSuccess and "✅" or "❌"
        icon.TextColor3 = Color3.new(1,1,1)
        icon.Font = Enum.Font.Gotham
        icon.TextSize = 20

        local msg = Instance.new("TextLabel", notifFrame)
        msg.Size = UDim2.new(1, -45, 0.5, 0)
        msg.Position = UDim2.new(0, 40, 0, 5)
        msg.BackgroundTransparency = 1
        msg.Text = title
        msg.TextColor3 = Color3.new(1,1,1)
        msg.Font = Enum.Font.Gotham
        msg.TextSize = 12
        msg.TextXAlignment = "Left"

        local desc = Instance.new("TextLabel", notifFrame)
        desc.Size = UDim2.new(1, -45, 0.5, 0)
        desc.Position = UDim2.new(0, 40, 0, 22)
        desc.BackgroundTransparency = 1
        desc.Text = text
        desc.TextColor3 = Color3.fromRGB(200,200,200)
        desc.Font = Enum.Font.Gotham
        desc.TextSize = 10
        desc.TextXAlignment = "Left"

        notifFrame.Position = UDim2.new(0.5, -125, 0, -50)
        TweenService:Create(notifFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back), {Position = UDim2.new(0.5, -125, 0, 20)}):Play()

        task.delay(duration, function()
            TweenService:Create(notifFrame, TweenInfo.new(0.3), {Position = UDim2.new(0.5, -125, 0, -50)}):Play()
            task.wait(0.3)
            notifGui:Destroy()
        end)
    end

    -- ========== EXECUTE FUNCTION ==========
    local function executeScript()
        local scriptText = scriptBox.Text
        if scriptText == "" or scriptText == "input" then
            showNotification("Empty Script", "Please paste a script first.", 2, false)
            return
        end

        execBtn.BackgroundColor3 = Color3.fromRGB(200,200,200)
        TweenService:Create(execBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255,255,255)}):Play()

        local success, result = pcall(function()
            local func = loadstring(scriptText)
            if func then
                return func()
            else
                error("Failed to compile script.")
            end
        end)

        if success then
            showNotification("Success", "Script executed successfully!", 3, true)
            statusLabel.Text = "✓ Executed"
            statusLabel.TextColor3 = Color3.fromRGB(0,255,0)
        else
            showNotification("Error", tostring(result), 4, false)
            statusLabel.Text = "✗ Error"
            statusLabel.TextColor3 = Color3.fromRGB(255,0,0)
        end

        task.delay(3, function()
            statusLabel.Text = ""
        end)
    end

    execBtn.MouseButton1Click:Connect(executeScript)

    -- ========== CLOSE BUTTON ==========
    closeBtn.MouseButton1Click:Connect(function()
        TweenService:Create(main, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            Size = UDim2.new(0,0,0,0),
            BackgroundTransparency = 1,
            Position = UDim2.new(0.5, 0, 0.5, 0)
        }):Play()
        task.wait(0.3)
        gui:Destroy()
        _G.Anonymous9xExecGUI = nil
    end)

    -- ========== ANIMASI MASUK ==========
    main.BackgroundTransparency = 1
    stroke.Transparency = 1
    titleBar.BackgroundTransparency = 1
    title.TextTransparency = 1
    closeBtn.BackgroundTransparency = 1
    closeBtn.TextTransparency = 1
    scriptBox.TextTransparency = 1
    execBtn.BackgroundTransparency = 1
    execBtn.TextTransparency = 1
    execStroke.Transparency = 1
    statusLabel.TextTransparency = 1

    main.Size = UDim2.new(0,0,0,0)
    main.Position = UDim2.new(0.5, 0, 0.5, 0)

    TweenService:Create(main, TweenInfo.new(0.5, Enum.EasingStyle.Back), {
        Size = UDim2.new(0,190,0,220),
        Position = UDim2.new(0.5, -95, 0.5, -110),
        BackgroundTransparency = 0
    }):Play()

    TweenService:Create(stroke, TweenInfo.new(0.5), {Transparency = 0}):Play()
    TweenService:Create(titleBar, TweenInfo.new(0.5), {BackgroundTransparency = 0}):Play()
    TweenService:Create(title, TweenInfo.new(0.5), {TextTransparency = 0}):Play()
    TweenService:Create(closeBtn, TweenInfo.new(0.5), {BackgroundTransparency = 0, TextTransparency = 0}):Play()
    TweenService:Create(scriptBox, TweenInfo.new(0.5), {TextTransparency = 0}):Play()
    TweenService:Create(execBtn, TweenInfo.new(0.5), {BackgroundTransparency = 0, TextTransparency = 0}):Play()
    TweenService:Create(execStroke, TweenInfo.new(0.5), {Transparency = 0}):Play()
    TweenService:Create(statusLabel, TweenInfo.new(0.5), {TextTransparency = 0}):Play()
end

-- Panggil pembuatan GUI dengan sedikit jeda untuk memastikan semuanya siap
task.spawn(function()
    task.wait(0.1)
    local success, err = pcall(createGUI)
    if not success then
        warn("Gagal membuat GUI:", err)
        -- Fallback: coba buat di PlayerGui
        pcall(function()
            createGUI()  -- coba lagi, mungkin parent berbeda
        end)
    end
end)

print("Anonymous9x Exec loader started. V.1.01")
