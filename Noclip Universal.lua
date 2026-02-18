-- ==================== SIMPLE NO CLIP TOGGLE ====================
-- Execute once: Noclip ON
-- Execute again: Noclip OFF
-- Universal, works in all games

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- ==================== GLOBAL VARIABLE CHECK ====================
-- Cek apakah noclip sudah aktif dari eksekusi sebelumnya
if _G.UniversalNoclipActive == nil then
    _G.UniversalNoclipActive = false
    _G.NoclipConnection = nil
    _G.OriginalCanCollide = {}
end

-- ==================== NOTIFICATION SYSTEM ====================
local function ShowNotification(message, duration)
    -- Buat ScreenGui untuk notif
    local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
    
    -- Hapus notif lama jika ada
    if PlayerGui:FindFirstChild("NoclipNotif") then
        PlayerGui.NoclipNotif:Destroy()
    end
    
    -- Buat notif UI
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "NoclipNotif"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local Notification = Instance.new("Frame")
    Notification.Size = UDim2.new(0, 300, 0, 80)
    Notification.Position = UDim2.new(0.5, -150, 0.1, 0)
    Notification.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    Notification.BackgroundTransparency = 0.1
    Notification.BorderSizePixel = 0
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 10)
    Corner.Parent = Notification
    
    -- Icon
    local Icon = Instance.new("TextLabel")
    Icon.Size = UDim2.new(0, 40, 0, 40)
    Icon.Position = UDim2.new(0, 10, 0.5, -20)
    Icon.BackgroundTransparency = 1
    Icon.Text = "👽"
    Icon.TextColor3 = Color3.fromRGB(0, 255, 100)
    Icon.Font = Enum.Font.GothamBold
    Icon.TextSize = 24
    Icon.Parent = Notification
    
    -- Title
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(0, 240, 0, 30)
    Title.Position = UDim2.new(0, 60, 0, 10)
    Title.BackgroundTransparency = 1
    Title.Text = "NO CLIP MODE"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 16
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Notification
    
    -- Message
    local Message = Instance.new("TextLabel")
    Message.Size = UDim2.new(0, 240, 0, 40)
    Message.Position = UDim2.new(0, 60, 0, 35)
    Message.BackgroundTransparency = 1
    Message.Text = message
    Message.TextColor3 = Color3.fromRGB(200, 200, 200)
    Message.Font = Enum.Font.Gotham
    Message.TextSize = 12
    Message.TextXAlignment = Enum.TextXAlignment.Left
    Message.TextYAlignment = Enum.TextYAlignment.Top
    Message.TextWrapped = true
    Message.Parent = Notification
    
    -- Assemble
    Notification.Parent = ScreenGui
    ScreenGui.Parent = PlayerGui
    
    -- Auto remove setelah beberapa detik
    task.wait(duration or 4)
    ScreenGui:Destroy()
end

-- ==================== NO CLIP SYSTEM ====================
local function EnableNoclip()
    if not LocalPlayer.Character then
        ShowNotification("No character found!\nWait for character to load.", 3)
        return false
    end
    
    _G.UniversalNoclipActive = true
    _G.OriginalCanCollide = {}
    
    local character = LocalPlayer.Character
    
    -- Save original CanCollide values
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            _G.OriginalCanCollide[part] = part.CanCollide
            part.CanCollide = false
        end
    end
    
    -- Noclip maintenance loop
    if _G.NoclipConnection then
        _G.NoclipConnection:Disconnect()
    end
    
    _G.NoclipConnection = RunService.Stepped:Connect(function()
        if not _G.UniversalNoclipActive or not character or not character.Parent then
            return
        end
        
        -- Maintain noclip state
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
        
        -- Juga handle parts baru (tools, accessories)
        for _, part in pairs(character:GetChildren()) do
            if part:IsA("Tool") or part:IsA("Accessory") then
                for _, part2 in pairs(part:GetDescendants()) do
                    if part2:IsA("BasePart") and part2.CanCollide then
                        part2.CanCollide = false
                    end
                end
            end
        end
    end)
    
    -- Print ke console juga
    print("========================================")
    print("🚀 UNIVERSAL NO CLIP - ACTIVATED")
    print("Features:")
    print("  ✅ Walk through walls")
    print("  ✅ Walk through objects")
    print("  ✅ Auto-maintain noclip state")
    print("  ✅ Works with tools/accessories")
    print("To disable: Execute this script again")
    print("========================================")
    
    return true
end

local function DisableNoclip()
    _G.UniversalNoclipActive = false
    
    -- Stop noclip loop
    if _G.NoclipConnection then
        _G.NoclipConnection:Disconnect()
        _G.NoclipConnection = nil
    end
    
    -- Restore original CanCollide values
    if LocalPlayer.Character then
        local character = LocalPlayer.Character
        
        for part, originalState in pairs(_G.OriginalCanCollide) do
            if part and part.Parent then
                part.CanCollide = originalState
            end
        end
        
        -- Juga restore untuk tools/accessories
        for _, tool in pairs(character:GetChildren()) do
            if tool:IsA("Tool") or tool:IsA("Accessory") then
                for _, part in pairs(tool:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = true
                    end
                end
            end
        end
    end
    
    _G.OriginalCanCollide = {}
    
    print("========================================")
    print("🚀 UNIVERSAL NO CLIP - DEACTIVATED")
    print("Normal collision restored")
    print("To enable: Execute this script again")
    print("========================================")
    
    return true
end

-- ==================== TOGGLE FUNCTION ====================
local function ToggleNoclip()
    if _G.UniversalNoclipActive then
        -- Matikan noclip
        DisableNoclip()
        ShowNotification("NO CLIP: DISABLED\nNormal collision restored\n\nExecute script again to re-enable", 5)
    else
        -- Nyalakan noclip
        if EnableNoclip() then
            ShowNotification("NO CLIP: ACTIVATED\nYou can walk through walls\n\nExecute script again to disable", 5)
        else
            ShowNotification("Failed to enable noclip\nMake sure you have a character", 3)
        end
    end
end

-- ==================== CHARACTER RESPAWN HANDLER ====================
local function SetupRespawnHandler()
    -- Hapus handler lama jika ada
    if _G.RespawnHandler then
        _G.RespawnHandler:Disconnect()
    end
    
    -- Setup handler baru
    _G.RespawnHandler = LocalPlayer.CharacterAdded:Connect(function(character)
        task.wait(1)  -- Tunggu character fully load
        
        if _G.UniversalNoclipActive then
            print("[NO CLIP] Re-applying after respawn...")
            
            -- Stop loop lama
            if _G.NoclipConnection then
                _G.NoclipConnection:Disconnect()
                _G.NoclipConnection = nil
            end
            
            -- Clear old data
            _G.OriginalCanCollide = {}
            
            -- Re-enable noclip
            EnableNoclip()
            
            -- Show notification
            task.wait(0.5)
            ShowNotification("NO CLIP: RE-APPLIED\nNoclip maintained after respawn", 3)
        end
    end)
end

-- ==================== MAIN EXECUTION ====================
-- Setup respawn handler
SetupRespawnHandler()

-- Toggle noclip
ToggleNoclip()

-- ==================== CONSOLE COMMANDS ====================
-- Buat bisa kontrol dari console juga
_G.Noclip = {
    Toggle = ToggleNoclip,
    Status = function()
        return _G.UniversalNoclipActive and "ACTIVE" or "INACTIVE"
    end
}

print("\n[EXTRA] Console commands available:")
print("  _G.Noclip.Toggle() - Toggle noclip")
print("  _G.Noclip.Status() - Check status")
print("  Or just execute this script again to toggle")
