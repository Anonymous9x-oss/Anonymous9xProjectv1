-- ==================== SIMPLE INFINITE JUMP TOGGLE ====================
-- Execute sekali: Jump ON
-- Execute lagi: Jump OFF
-- No UI, hanya notifikasi
-- Pakai tombol jump Roblox, bisa spam jump, bisa turun normal

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- ==================== GLOBAL STATE ====================
-- Cek apakah jump sudah aktif
if _G.InfiniteJumpActive == nil then
    _G.InfiniteJumpActive = false
    _G.JumpConnection = nil
    _G.JumpVelocity = nil
    _G.JumpHeight = 50
end

-- ==================== NOTIFICATION SYSTEM ====================
local function ShowNotification(message, color)
    local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
    
    -- Hapus notif lama
    if PlayerGui:FindFirstChild("JumpNotif") then
        PlayerGui.JumpNotif:Destroy()
    end
    
    -- Buat notif
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "JumpNotif"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local NotifFrame = Instance.new("Frame")
    NotifFrame.Size = UDim2.new(0, 300, 0, 70)
    NotifFrame.Position = UDim2.new(0.5, -150, 0.1, 0)
    NotifFrame.BackgroundColor3 = color or Color3.fromRGB(30, 30, 50)
    NotifFrame.BackgroundTransparency = 0.1
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 10)
    Corner.Parent = NotifFrame
    
    -- Icon
    local Icon = Instance.new("TextLabel")
    Icon.Size = UDim2.new(0, 40, 0, 40)
    Icon.Position = UDim2.new(0, 15, 0.5, -20)
    Icon.BackgroundTransparency = 1
    Icon.Text = "🦘"
    Icon.TextColor3 = Color3.new(1, 1, 1)
    Icon.Font = Enum.Font.GothamBold
    Icon.TextSize = 24
    Icon.Parent = NotifFrame
    
    -- Text
    local TextLabel = Instance.new("TextLabel")
    TextLabel.Size = UDim2.new(0, 230, 0, 60)
    TextLabel.Position = UDim2.new(0, 60, 0, 5)
    TextLabel.BackgroundTransparency = 1
    TextLabel.Text = message
    TextLabel.TextColor3 = Color3.new(1, 1, 1)
    TextLabel.Font = Enum.Font.Gotham
    TextLabel.TextSize = 14
    TextLabel.TextXAlignment = Enum.TextXAlignment.Left
    TextLabel.TextYAlignment = Enum.TextYAlignment.Top
    TextLabel.TextWrapped = true
    TextLabel.Parent = NotifFrame
    
    NotifFrame.Parent = ScreenGui
    ScreenGui.Parent = PlayerGui
    
    -- Auto remove
    task.wait(4)
    ScreenGui:Destroy()
end

-- ==================== SIMPLE JUMP SYSTEM ====================
local function EnableInfiniteJump()
    if _G.InfiniteJumpActive then return end
    
    _G.InfiniteJumpActive = true
    
    -- Jump function
    local function OnJumpRequest()
        if not _G.InfiniteJumpActive then return end
        
        local character = LocalPlayer.Character
        if not character then return end
        
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        
        if humanoid and rootPart then
            -- Normal jump
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            
            -- Extra boost (temporary)
            if _G.JumpVelocity then
                _G.JumpVelocity:Destroy()
            end
            
            _G.JumpVelocity = Instance.new("BodyVelocity")
            _G.JumpVelocity.Velocity = Vector3.new(0, _G.JumpHeight, 0)
            _G.JumpVelocity.MaxForce = Vector3.new(0, 40000, 0)
            _G.JumpVelocity.Parent = rootPart
            
            -- Remove velocity after short time (bisa turun normal)
            task.wait(0.15)
            if _G.JumpVelocity then
                _G.JumpVelocity:Destroy()
                _G.JumpVelocity = nil
            end
        end
    end
    
    -- Connect to Roblox jump button
    if _G.JumpConnection then
        _G.JumpConnection:Disconnect()
    end
    
    _G.JumpConnection = UserInputService.JumpRequest:Connect(OnJumpRequest)
    
    -- Notifikasi
    ShowNotification("INFINITE JUMP: ACTIVATED\n\n• Use Roblox jump button\n• Can spam jump\n• Can fall normally\n• Execute script again to disable", 
        Color3.fromRGB(30, 80, 30))
    
    print("========================================")
    print("🦘 INFINITE JUMP ACTIVATED")
    print("Features:")
    print("  • Use Roblox jump button (Space/Button)")
    print("  • Can spam jump repeatedly")
    print("  • Can fall normally (not fly)")
    print("  • Jump height: " .. _G.JumpHeight)
    print("To disable: Execute this script again")
    print("========================================")
end

local function DisableInfiniteJump()
    if not _G.InfiniteJumpActive then return end
    
    _G.InfiniteJumpActive = false
    
    -- Disconnect jump
    if _G.JumpConnection then
        _G.JumpConnection:Disconnect()
        _G.JumpConnection = nil
    end
    
    -- Clean velocity
    if _G.JumpVelocity then
        _G.JumpVelocity:Destroy()
        _G.JumpVelocity = nil
    end
    
    -- Notifikasi
    ShowNotification("INFINITE JUMP: DISABLED\n\n• Normal jump restored\n• Execute script again to re-enable",
        Color3.fromRGB(80, 30, 30))
    
    print("========================================")
    print("🦘 INFINITE JUMP DISABLED")
    print("Normal jump restored")
    print("Execute script again to re-enable")
    print("========================================")
end

-- ==================== TOGGLE FUNCTION ====================
local function ToggleInfiniteJump()
    if _G.InfiniteJumpActive then
        DisableInfiniteJump()
    else
        EnableInfiniteJump()
    end
end

-- ==================== AUTO REAPPLY ON RESPAWN ====================
local function SetupRespawnHandler()
    if _G.RespawnHandler then
        _G.RespawnHandler:Disconnect()
    end
    
    _G.RespawnHandler = LocalPlayer.CharacterAdded:Connect(function()
        task.wait(1)
        
        if _G.InfiniteJumpActive then
            print("[JUMP] Reapplying after respawn...")
            
            -- Reconnect jump
            if _G.JumpConnection then
                _G.JumpConnection:Disconnect()
                _G.JumpConnection = nil
            end
            
            EnableInfiniteJump()
        end
    end)
end

-- ==================== CONSOLE COMMANDS ====================
-- Buat bisa kontrol dari console juga
_G.Jump = {
    Toggle = ToggleInfiniteJump,
    Status = function()
        return _G.InfiniteJumpActive and "ACTIVE" or "INACTIVE"
    end,
    SetHeight = function(height)
        if type(height) == "number" and height >= 20 and height <= 100 then
            _G.JumpHeight = height
            print("[JUMP] Height set to: " .. height)
            ShowNotification("Jump height set to: " .. height, Color3.fromRGB(30, 30, 80))
        else
            print("[JUMP] Invalid height. Use 20-100")
        end
    end
}

-- ==================== MAIN EXECUTION ====================
-- Setup respawn handler
SetupRespawnHandler()

-- Toggle jump
ToggleInfiniteJump()

-- ==================== FINAL MESSAGE ====================
print("\n[EXTRA] Console commands available:")
print("  _G.Jump.Toggle() - Toggle infinite jump")
print("  _G.Jump.Status() - Check status")
print("  _G.Jump.SetHeight(50) - Set jump height (20-100)")
print("  Or just execute this script again to toggle")
