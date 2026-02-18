--[[
    ANONYMOUS9X SMART ASSIST V2 (Legit/Smooth Mode)
    Type: Aim Assist / Magnet Aim
    Status: UNDETECTED / TOGGLEABLE
    Note: Allows manual camera movement while locking!
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- // SMART CONFIGURATION //
local Config = {
    FOVSize = 100,            -- Lingkaran target (Jangan terlalu besar biar akurat)
    HitboxSize = 8,           -- Ukuran Hitbox (Medium biar ga mencolok)
    Smoothness = 0.2,         -- 0.1 = Kasar/Lengket, 0.5 = Halus banget/Licin
    TeamCheck = false,        -- Nyalakan jika ada tim
    TargetPart = "HumanoidRootPart", -- Bagian tubuh yg dikejar
    PredictMovement = true    -- Coba prediksi gerakan musuh dikit
}

-- // TOGGLE SYSTEM //
if getgenv().Ano9x_Smart == nil then
    getgenv().Ano9x_Smart = false
end

getgenv().Ano9x_Smart = not getgenv().Ano9x_Smart

-- // CLEANUP FUNCTION //
local function Cleanup()
    if getgenv().Ano9x_Circle then getgenv().Ano9x_Circle:Remove() end
    if getgenv().Ano9x_Connection then getgenv().Ano9x_Connection:Disconnect() end
    
    -- Reset Visuals
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character then
            if v.Character:FindFirstChild("HumanoidRootPart") then
                v.Character.HumanoidRootPart.Size = Vector3.new(2, 2, 1)
                v.Character.HumanoidRootPart.Transparency = 1
            end
            if v.Character:FindFirstChild("Ano9x_SmartESP") then
                v.Character.Ano9x_SmartESP:Destroy()
            end
        end
    end
    
    StarterGui:SetCore("SendNotification", {
        Title = "Anonymous9x Smart Aim",
        Text = "ASSIST OFF 🔴",
        Duration = 2
    })
end

if not getgenv().Ano9x_Smart then
    Cleanup()
    return
end

-- // INITIALIZATION //
StarterGui:SetCore("SendNotification", {
    Title = "Anonymous9x Smart Aim",
    Text = "ASSIST ON 🟢 (Smooth Mode)",
    Duration = 3
})

-- Visual FOV Circle
local Circle = Drawing.new("Circle")
Circle.Color = Color3.fromRGB(0, 255, 150) -- Warna Hijau Cyber
Circle.Thickness = 1.5
Circle.NumSides = 60
Circle.Radius = Config.FOVSize
Circle.Filled = false
Circle.Visible = true
Circle.Transparency = 0.8
getgenv().Ano9x_Circle = Circle

-- Variables
local IsAiming = false

-- // INPUT HANDLING (PC & MOBILE) //
UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        IsAiming = true -- PC Right Click
    elseif input.UserInputType == Enum.UserInputType.Touch then
        IsAiming = true -- Mobile Touch
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 or input.UserInputType == Enum.UserInputType.Touch then
        IsAiming = false
    end
end)

-- // FUNGSI PINTAR: CARI TARGET //
local function GetSmartTarget()
    local closest = nil
    local shortestDist = Config.FOVSize
    local centerScreen = Camera.ViewportSize / 2

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild(Config.TargetPart) and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            
            if Config.TeamCheck and player.Team == LocalPlayer.Team then continue end

            -- Cek apakah player terlihat di layar
            local pos, onScreen = Camera:WorldToViewportPoint(player.Character[Config.TargetPart].Position)
            
            if onScreen then
                local dist = (Vector2.new(pos.X, pos.Y) - centerScreen).Magnitude
                
                -- Hanya target yang benar-benar ada dalam lingkaran
                if dist < shortestDist then
                    closest = player
                    shortestDist = dist
                end
            end
        end
    end
    return closest
end

-- // CORE LOGIC (HEARTBEAT) //
getgenv().Ano9x_Connection = RunService.RenderStepped:Connect(function()
    if not getgenv().Ano9x_Smart then return end

    -- 1. Update FOV Position
    Circle.Position = Camera.ViewportSize / 2

    -- 2. ESP & Hitbox Manager
    for _, pl in pairs(Players:GetPlayers()) do
        if pl ~= LocalPlayer and pl.Character and pl.Character:FindFirstChild("HumanoidRootPart") then
            -- Smart Hitbox (Gak terlalu lebay)
            local hrp = pl.Character.HumanoidRootPart
            hrp.Size = Vector3.new(Config.HitboxSize, Config.HitboxSize, Config.HitboxSize)
            hrp.Transparency = 0.9 -- Hampir invisible biar enak dilihat
            hrp.CanCollide = false
            
            -- Smart ESP (Kotak Hijau Tipis)
            if not pl.Character:FindFirstChild("Ano9x_SmartESP") then
                local hl = Instance.new("Highlight")
                hl.Name = "Ano9x_SmartESP"
                hl.Parent = pl.Character
                hl.FillColor = Color3.fromRGB(0, 255, 0)
                hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                hl.FillTransparency = 0.7
                hl.OutlineTransparency = 0.5
            end
        end
    end

    -- 3. SMART AIM LOGIC (INTERPOLASI)
    if IsAiming then
        local target = GetSmartTarget()
        if target and target.Character and target.Character:FindFirstChild(Config.TargetPart) then
            local targetPos = target.Character[Config.TargetPart].Position
            
            -- Prediksi Gerakan (Opsional)
            if Config.PredictMovement then
                targetPos = targetPos + (target.Character.HumanoidRootPart.Velocity * 0.045)
            end
            
            -- TEKNIK LERRP (LINEAR INTERPOLATION)
            -- Ini rahasianya kenapa bisa digeser. Kita gak maksa kamera ke target,
            -- tapi kita geser kamera pelan-pelan ke arah target.
            
            local currentCFrame = Camera.CFrame
            local targetCFrame = CFrame.new(currentCFrame.Position, targetPos)
            
            -- Smoothness Factor menentukan seberapa kuat tarikannya
            Camera.CFrame = currentCFrame:Lerp(targetCFrame, Config.Smoothness)
        end
    end
end)
