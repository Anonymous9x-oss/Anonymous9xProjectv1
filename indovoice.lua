-- Indo Voice Auto Fish | Original Rayfield UI, Rebranded by Anonymous9x
-- Load Rayfield library
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LP = Players.LocalPlayer
local Char = LP.Character or LP.CharacterAdded:Wait()
local Hum = Char:WaitForChild("Humanoid")

-- Remote sell
local SellRemote = ReplicatedStorage:FindFirstChild("SellAllFishFunction")

-- Animation IDs (from leak)
local CAST_ANIM = "rbxassetid://107858786510758"
local PULL_ANIM = "rbxassetid://136444937709795"

-- State
local autoFishing = false
local stage = "Idle"
local timer = 0
local castPlayed, pullPlayed = false, false
local fishCaught = 0
local timeoutCount = 0
local animConn
local fishThread

-- Timing settings (default from leak)
local T = {
    CAST_HOLD = 0.7,
    POST_PULL = 1.8,
    PRE_END = 0,
    POST_END = 0.3,
    PRE_CAST = 0.3,
    VERIFY_TIMEOUT = 2.5,
    WAIT_PULL_TIMEOUT = 20,
    POST_PULL_TIMEOUT = 5,
}

-- Helper: get currently equipped rod
local function getRod()
    if Char then
        for _, tool in ipairs(Char:GetChildren()) do
            if tool:IsA("Tool") and tool.Name:lower():find("rod") then
                return tool
            end
        end
    end
    local bp = LP:FindFirstChild("Backpack")
    if bp then
        for _, tool in ipairs(bp:GetChildren()) do
            if tool:IsA("Tool") and tool.Name:lower():find("rod") then
                return tool
            end
        end
    end
    return nil
end

-- Equip rod from backpack
local function equipRod()
    local rod = getRod()
    if not rod then
        local bp = LP:FindFirstChild("Backpack")
        if bp then
            for _, tool in ipairs(bp:GetChildren()) do
                if tool:IsA("Tool") and tool.Name:lower():find("rod") then
                    pcall(function() Hum:EquipTool(tool) end)
                    return
                end
            end
        end
    end
end

-- Reset animation detection
local function resetAnimDetection()
    if animConn then animConn:Disconnect() end
    castPlayed = false
    pullPlayed = false
    animConn = Hum.AnimationPlayed:Connect(function(track)
        if track.Animation.AnimationId == CAST_ANIM then
            castPlayed = true
            animConn:Disconnect()
        elseif track.Animation.AnimationId == PULL_ANIM then
            pullPlayed = true
            animConn:Disconnect()
        end
    end)
end

-- Stop fishing safely
local function stopFishing()
    autoFishing = false
    if animConn then animConn:Disconnect() end
    stage = "Idle"
    timer = 0
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0) -- release mouse
end

-- Main fishing loop
local function startFishingLoop()
    fishThread = task.spawn(function()
        while autoFishing do
            local rod = getRod()
            if not rod then
                task.wait(1)
                continue
            end
            -- Idle
            if stage == "Idle" then
                if Hum.MoveDirection.Magnitude < 0.1 then
                    task.wait(T.PRE_CAST)
                    if not autoFishing then break end
                    stage = "Casting"
                    timer = 0
                    resetAnimDetection()
                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0) -- hold
                    task.wait(0.05)
                else
                    task.wait(0.1)
                end
            -- Casting
            elseif stage == "Casting" then
                if timer < T.CAST_HOLD then
                    timer = timer + 0.05
                    task.wait(0.05)
                else
                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0) -- release
                    stage = "Verify Cast"
                    timer = 0
                end
            -- Verify Cast
            elseif stage == "Verify Cast" then
                if castPlayed then
                    stage = "Waiting Pull"
                    timer = 0
                else
                    timer = timer + 0.05
                    if timer > T.VERIFY_TIMEOUT then
                        timeoutCount = timeoutCount + 1
                        stage = "Idle"
                        equipRod()
                    end
                    task.wait(0.05)
                end
            -- Waiting Pull
            elseif stage == "Waiting Pull" then
                if pullPlayed then
                    stage = "Post Pull Wait"
                    timer = 0
                else
                    timer = timer + 0.05
                    if T.WAIT_PULL_TIMEOUT > 0 and timer > T.WAIT_PULL_TIMEOUT then
                        timeoutCount = timeoutCount + 1
                        stage = "Idle"
                        equipRod()
                    end
                    task.wait(0.05)
                end
            -- Post Pull Wait
            elseif stage == "Post Pull Wait" then
                if timer < T.POST_PULL then
                    timer = timer + 0.05
                    if timer > T.POST_PULL_TIMEOUT then
                        timeoutCount = timeoutCount + 1
                        stage = "Idle"
                        equipRod()
                    end
                    task.wait(0.05)
                else
                    stage = "Catch"
                    timer = 0
                end
            -- Catch
            elseif stage == "Catch" then
                local tool = getRod()
                local catchRemote = tool and tool:FindFirstChild("Catch")
                if catchRemote then
                    pcall(function() catchRemote:FireServer(true) end)
                    fishCaught = fishCaught + 1
                else
                    timeoutCount = timeoutCount + 1
                end
                stage = "Pre End Wait"
                timer = 0
            -- Pre End Wait
            elseif stage == "Pre End Wait" then
                if timer < T.PRE_END then
                    timer = timer + 0.05
                    task.wait(0.05)
                else
                    stage = "End"
                    timer = 0
                end
            -- End
            elseif stage == "End" then
                pcall(function()
                    for _, gui in ipairs(LP.PlayerGui:GetChildren()) do
                        if gui:IsA("ScreenGui") and gui:FindFirstChild("FishingHolder", true) then
                            gui:Destroy()
                        end
                    end
                end)
                stage = "Post End Wait"
                timer = 0
            -- Post End Wait
            elseif stage == "Post End Wait" then
                if timer < T.POST_END then
                    timer = timer + 0.05
                    task.wait(0.05)
                else
                    stage = "Idle"
                    timer = 0
                end
            end
        end
        stopFishing()
    end)
end

-- Create Window
local Window = Rayfield:CreateWindow({
    Name = "Indo Voice - Anonymous9x",
    LoadingTitle = "By Anonymous9x",
    LoadingSubtitle = "Auto Fish & Sell",
    ConfigurationSaving = { Enabled = false },
    Discord = { Enabled = false },
    KeySystem = false, -- no key
})

-- Tab Fishing
local Tab = Window:CreateTab("Fishing")

-- Status label
local statusLabel = Tab:CreateLabel("Status: Idle | Caught: 0")
task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            statusLabel:Set(string.format("Stage: %s | Caught: %d | Timeouts: %d", stage, fishCaught, timeoutCount))
        end)
    end
end)

-- Auto Fishing Toggle
Tab:CreateToggle({
    Name = "Auto Fishing",
    CurrentValue = false,
    Callback = function(val)
        autoFishing = val
        if autoFishing then
            stage = "Idle"
            timer = 0
            equipRod()
            startFishingLoop()
        else
            stopFishing()
        end
    end,
})

-- Sell All Button
Tab:CreateButton({
    Name = "Sell All Fish",
    Callback = function()
        if SellRemote then
            pcall(function() SellRemote:InvokeServer() end)
        else
            Rayfield:Notify({ Title = "Error", Content = "Sell remote not found", Duration = 3 })
        end
    end,
})

-- Clean up on close (optional)
-- Rayfield tidak memiliki event close global, tapi bisa diabaikan.

-- Handle character respawn
LP.CharacterAdded:Connect(function(newChar)
    Char = newChar
    Hum = Char:WaitForChild("Humanoid")
    if autoFishing then
        stopFishing()
        task.wait(1)
        autoFishing = true
        startFishingLoop()
    end
end)
