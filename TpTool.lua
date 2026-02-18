-- ================================================
-- ANONYMOUS9X TP TOOL v2.0
-- Universal Teleport Tool - Minimalist
-- ON/OFF Toggle with Notification
-- ================================================

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TweenService = game:GetService("TweenService")

-- State untuk toggle
local TP_TOOL_ACTIVE = false
local TP_TOOL_INSTANCE = nil

-- ==================== NOTIFICATION SYSTEM ====================

local function ShowNotification(message, color)
    local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
    
    -- Hapus notif lama
    for _, v in ipairs(PlayerGui:GetChildren()) do
        if v.Name == "TPToolNotify" then
            v:Destroy()
        end
    end
    
    -- Buat notif
    local notify = Instance.new("ScreenGui")
    notify.Name = "TPToolNotify"
    notify.ResetOnSpawn = false
    notify.DisplayOrder = 1000
    notify.Parent = PlayerGui
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 0, 0, 40)
    frame.Position = UDim2.new(0.5, 0, 0.1, 0)
    frame.AnchorPoint = Vector2.new(0.5, 0)
    frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    frame.BorderSizePixel = 0
    frame.BackgroundTransparency = 0.3
    frame.Parent = notify
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255, 255, 255)
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
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Center
    label.Parent = frame
    
    -- Animasi masuk
    frame.Position = UDim2.new(0.5, 0, 0, -50)
    frame.BackgroundTransparency = 1
    
    local tweenIn = TweenService:Create(frame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, 0, 0.1, 0),
        BackgroundTransparency = 0.3,
        Size = UDim2.new(0, math.min(#message * 8 + 40, 350), 0, 40)
    })
    tweenIn:Play()
    
    -- Tunggu dan animasi keluar
    task.wait(3)
    
    local tweenOut = TweenService:Create(frame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
        Position = UDim2.new(0.5, 0, 0, -50),
        BackgroundTransparency = 1
    })
    tweenOut:Play()
    
    tweenOut.Completed:Wait()
    notify:Destroy()
end

-- ==================== TP TOOL CREATION ====================

local function CreateTPTool()
    local backpack = LocalPlayer:WaitForChild("Backpack")
    local mouse = LocalPlayer:GetMouse()
    
    -- Cek apakah tool sudah ada
    local existingTool = backpack:FindFirstChild("Anonymous9x TP Tool")
    if existingTool then
        existingTool:Destroy()
        TP_TOOL_ACTIVE = false
        ShowNotification("🔴 TP Tool OFF", Color3.fromRGB(255, 100, 100))
        return
    end
    
    -- Buat tool baru
    local tool = Instance.new("Tool")
    tool.Name = "Anonymous9x TP Tool"
    tool.RequiresHandle = false
    tool.Parent = backpack
    
    -- Fungsi teleport
    tool.Activated:Connect(function()
        local character = LocalPlayer.Character
        if not character then return end
        
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if not humanoidRootPart then return end
        
        -- Teleport ke posisi mouse
        local targetPos = mouse.Hit + Vector3.new(0, 3, 0)
        humanoidRootPart.CFrame = CFrame.new(targetPos.X, targetPos.Y, targetPos.Z)
        
        -- Notif sukses
        ShowNotification("✓ Teleported", Color3.fromRGB(100, 255, 100))
    end)
    
    TP_TOOL_ACTIVE = true
    TP_TOOL_INSTANCE = tool
    ShowNotification("🟢 TP Tool ON - Check Backpack", Color3.fromRGB(100, 255, 100))
end

-- ==================== MAIN EXECUTION ====================

-- Tunggu sampai player load
if not LocalPlayer.Character then
    LocalPlayer.CharacterAdded:Wait()
end

-- Tunggu backpack
if not LocalPlayer:FindFirstChild("Backpack") then
    LocalPlayer:WaitForChild("Backpack")
end

-- Create atau destroy tool
CreateTPTool()

print("=================================")
print("ANONYMOUS9X TP TOOL")
print("Status: " .. (TP_TOOL_ACTIVE and "ACTIVE" or "INACTIVE"))
print("Execute again to toggle ON/OFF")
print("=================================")
