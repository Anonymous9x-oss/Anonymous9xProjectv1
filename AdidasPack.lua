--// Anonymous9x Adidas Pack Animation
--// FE Visible | Universal R6 + R15 | Toggle | No Menu GUI

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer

-- ===== GLOBAL STATE =====
getgenv().ADIDAS_ON     = getgenv().ADIDAS_ON     or false
getgenv().ANIM_BACKUP   = getgenv().ANIM_BACKUP   or {}
getgenv().ADIDAS_BUSY   = getgenv().ADIDAS_BUSY   or false  -- mutex lock

-- Disconnect old CharacterAdded connection (cegah stacking tiap re-execute)
if getgenv().ADIDAS_CHAR_CONN then
    pcall(function() getgenv().ADIDAS_CHAR_CONN:Disconnect() end)
    getgenv().ADIDAS_CHAR_CONN = nil
end

-- ===== MUTEX GUARD =====
-- Kalau proses sebelumnya belum selesai, tolak execute baru
if getgenv().ADIDAS_BUSY then
    warn("Anonymous9x | Masih loading, tunggu sebentar lalu execute lagi")
    return
end
getgenv().ADIDAS_BUSY = true

-- ===== CENTER TOP NOTIFICATION =====
local function CenterNotify(text)
    pcall(function()
        local core = game:GetService("CoreGui")
        if core:FindFirstChild("Anonymous9xNotify") then
            core.Anonymous9xNotify:Destroy()
        end

        local gui = Instance.new("ScreenGui")
        gui.Name = "Anonymous9xNotify"
        gui.ResetOnSpawn = false
        gui.Parent = core

        local frame = Instance.new("Frame", gui)
        frame.AnchorPoint = Vector2.new(0.5, 0)
        frame.Position = UDim2.fromScale(0.5, -0.25)
        frame.Size = UDim2.fromScale(0.5, 0.1)
        frame.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
        frame.BackgroundTransparency = 0.05

        Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 14)

        local stroke = Instance.new("UIStroke", frame)
        stroke.Color = Color3.fromRGB(235, 235, 235)
        stroke.Thickness = 1.5
        stroke.Transparency = 0.25

        local txt = Instance.new("TextLabel", frame)
        txt.Size = UDim2.fromScale(1, 1)
        txt.BackgroundTransparency = 1
        txt.Text = text
        txt.TextWrapped = true
        txt.TextColor3 = Color3.fromRGB(245, 245, 245)
        txt.Font = Enum.Font.GothamMedium
        txt.TextScaled = true

        TweenService:Create(
            frame,
            TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
            {Position = UDim2.fromScale(0.5, 0.04)}
        ):Play()

        task.delay(3.5, function()
            TweenService:Create(
                frame,
                TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.In),
                {Position = UDim2.fromScale(0.5, -0.3)}
            ):Play()
            task.wait(0.45)
            if gui and gui.Parent then gui:Destroy() end
        end)
    end)
end

-- ===== UTILS =====

local function safeGet(parent, ...)
    local cur = parent
    for _, name in ipairs({...}) do
        if typeof(cur) ~= "Instance" then return nil end
        cur = cur:FindFirstChild(name)
        if not cur then return nil end
    end
    return cur
end

local function stopAll(humanoid)
    pcall(function()
        local animator = humanoid:FindFirstChildOfClass("Animator")
        if not animator then return end
        for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
            pcall(function() track:Stop(0) end)
        end
    end)
end

-- Cari script animasi: daftar nama umum + fallback scan
local function findAnimScript(char)
    local candidates = {
        "Animate", "AnimationsLoader", "AnimationScript",
        "AnimHandler", "CharacterAnimate", "R15Animate", "R6Animate",
    }
    for _, name in ipairs(candidates) do
        local s = char:FindFirstChild(name)
        if s then return s end
    end
    for _, child in ipairs(char:GetChildren()) do
        if child:IsA("LocalScript") then
            if child:FindFirstChild("idle") or child:FindFirstChild("walk") then
                return child
            end
        end
    end
    return nil
end

-- Reload animasi: 3 method, semua async di task.spawn agar tidak blocking
local function reloadAnimate(char, humanoid)
    task.spawn(function()
        pcall(function()
            humanoid:ChangeState(Enum.HumanoidStateType.Landed)
            task.wait(0.05)
            humanoid:ChangeState(Enum.HumanoidStateType.Running)
        end)
        task.wait(0.1)
        pcall(function()
            local animScript = findAnimScript(char)
            if animScript and animScript:IsA("LocalScript") then
                animScript.Disabled = true
                task.wait(0.08)
                animScript.Disabled = false
            end
        end)
        task.wait(0.1)
        pcall(function()
            humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
        end)
    end)
end

-- ===== ANIMATION IDs =====
local ADIDAS_IDS = {
    idle1    = "rbxassetid://122257458498464",
    idle2    = "rbxassetid://98173568987992",
    walk     = "rbxassetid://122150855457006",
    run      = "rbxassetid://82598234841035",
    jump     = "rbxassetid://75290611992385",
    fall     = "rbxassetid://18537367238",
    climb    = "rbxassetid://88763136693023",
    swim     = "rbxassetid://133308483266208",
    swimidle = "rbxassetid://109346520324160",
}

local ANIM_PATHS = {
    {"idle",     "Animation1", "idle1",    ADIDAS_IDS.idle1},
    {"idle",     "Animation2", "idle2",    ADIDAS_IDS.idle2},
    {"walk",     "WalkAnim",   "walk",     ADIDAS_IDS.walk},
    {"run",      "RunAnim",    "run",      ADIDAS_IDS.run},
    {"jump",     "JumpAnim",   "jump",     ADIDAS_IDS.jump},
    {"fall",     "FallAnim",   "fall",     ADIDAS_IDS.fall},
    {"climb",    "ClimbAnim",  "climb",    ADIDAS_IDS.climb},
    {"swim",     "Swim",       "swim",     ADIDAS_IDS.swim},
    {"swimidle", "SwimIdle",   "swimidle", ADIDAS_IDS.swimidle},
}

local function backupAnims(animScript)
    if getgenv().ANIM_BACKUP["UNIVERSAL"] then return end
    local backup = {}
    local count = 0
    for _, p in ipairs(ANIM_PATHS) do
        local inst = safeGet(animScript, p[1], p[2])
        if inst and inst.AnimationId and inst.AnimationId ~= "" then
            backup[p[3]] = inst.AnimationId
            count = count + 1
        end
    end
    getgenv().ANIM_BACKUP["UNIVERSAL"] = backup
    print(("Anonymous9x | Backup %d anim IDs OK"):format(count))
end

local function applyAnims(animScript)
    local applied = 0
    for _, p in ipairs(ANIM_PATHS) do
        local inst = safeGet(animScript, p[1], p[2])
        if inst then
            pcall(function() inst.AnimationId = p[4]; applied = applied + 1 end)
        end
    end
    print(("Anonymous9x | Applied %d Adidas anim IDs"):format(applied))
    return applied > 0
end

local function restoreAnims(animScript)
    local saved = getgenv().ANIM_BACKUP["UNIVERSAL"]
    if not saved or not next(saved) then
        warn("Anonymous9x | Tidak ada backup, skip restore")
        return
    end
    local restored = 0
    for _, p in ipairs(ANIM_PATHS) do
        local inst = safeGet(animScript, p[1], p[2])
        if inst and saved[p[3]] then
            pcall(function() inst.AnimationId = saved[p[3]]; restored = restored + 1 end)
        end
    end
    print(("Anonymous9x | Restored %d anim IDs"):format(restored))
end

-- ===== MAIN APPLY — SYNCHRONOUS (tidak pakai task.spawn di caller) =====
local function apply(char)
    local ok, err = pcall(function()
        local humanoid = char:WaitForChild("Humanoid", 10)
        if not humanoid then return end

        -- Tunggu semua script karakter load
        task.wait(0.5)

        local animScript = findAnimScript(char)
        if not animScript then
            warn("Anonymous9x | Script animasi tidak ditemukan")
            return
        end

        stopAll(humanoid)

        if not getgenv().ADIDAS_ON then
            -- Akan diaktifkan: backup dulu, lalu apply
            backupAnims(animScript)
            applyAnims(animScript)
            reloadAnimate(char, humanoid)
        else
            -- Akan dimatikan: restore original
            restoreAnims(animScript)
            reloadAnimate(char, humanoid)
            -- Reset backup agar ON berikutnya capture ID original yang beneran
            getgenv().ANIM_BACKUP = {}
        end
    end)
    if not ok then
        warn("Anonymous9x | Error di apply(): " .. tostring(err))
    end
end

-- ===== RUN — apply() dijalankan SYNC, state flip SETELAH selesai =====
-- Ini mencegah race condition: state tidak berubah sebelum apply selesai
if player.Character then
    apply(player.Character)   -- blocking, tidak pakai task.spawn
end

-- Flip state SETELAH apply selesai
getgenv().ADIDAS_ON = not getgenv().ADIDAS_ON

-- Unlock mutex
getgenv().ADIDAS_BUSY = false

-- Notifikasi
if getgenv().ADIDAS_ON then
    CenterNotify(
        "Anonymous9x Adidas Pack Animation Activated\n\n"..
        "To UnActive this animation,\nExecute this script again."
    )
    print("Anonymous9x Adidas Pack Animation : ON")
else
    CenterNotify(
        "Anonymous9x Adidas Pack Animation Disabled\n\n"..
        "To Active this animation again,\nExecute this script again."
    )
    print("Anonymous9x Adidas Pack Animation : OFF")
end

-- ===== CHARACTER RESPAWN HANDLER =====
getgenv().ADIDAS_CHAR_CONN = player.CharacterAdded:Connect(function(c)
    task.spawn(function()
        if getgenv().ADIDAS_ON then
            apply(c)
        end
    end)
end)
