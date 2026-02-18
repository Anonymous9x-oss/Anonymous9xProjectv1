--// Anonymous9x Adidas Pack Animation
--// FE Visible | Universal R6 + R15 | Toggle | No Menu GUI

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer

-- ===== GLOBAL STATE =====
getgenv().ADIDAS_ON = getgenv().ADIDAS_ON or false
getgenv().ANIM_BACKUP = getgenv().ANIM_BACKUP or {R6=nil, R15=nil}

-- ===== CENTER TOP NOTIFICATION =====
local function CenterNotify(text)
    local core = game:GetService("CoreGui")
    if core:FindFirstChild("Anonymous9xNotify") then
        core.Anonymous9xNotify:Destroy()
    end

    local gui = Instance.new("ScreenGui")
    gui.Name = "Anonymous9xNotify"
    gui.ResetOnSpawn = false
    gui.Parent = core

    local frame = Instance.new("Frame", gui)
    frame.AnchorPoint = Vector2.new(0.5,0)
    frame.Position = UDim2.fromScale(0.5,-0.25)
    frame.Size = UDim2.fromScale(0.5,0.1)
    frame.BackgroundColor3 = Color3.fromRGB(12,12,12)
    frame.BackgroundTransparency = 0.05

    Instance.new("UICorner", frame).CornerRadius = UDim.new(0,14)

    local stroke = Instance.new("UIStroke", frame)
    stroke.Color = Color3.fromRGB(235,235,235)
    stroke.Thickness = 1.5
    stroke.Transparency = 0.25

    local txt = Instance.new("TextLabel", frame)
    txt.Size = UDim2.fromScale(1,1)
    txt.BackgroundTransparency = 1
    txt.Text = text
    txt.TextWrapped = true
    txt.TextColor3 = Color3.fromRGB(245,245,245)
    txt.Font = Enum.Font.GothamMedium
    txt.TextScaled = true

    TweenService:Create(
        frame,
        TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
        {Position = UDim2.fromScale(0.5,0.04)}
    ):Play()

    task.delay(3.5, function()
        TweenService:Create(
            frame,
            TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.In),
            {Position = UDim2.fromScale(0.5,-0.3)}
        ):Play()
        task.wait(0.45)
        gui:Destroy()
    end)
end

-- ===== UTILS =====
local function stopAll(humanoid)
    local animator = humanoid:FindFirstChildOfClass("Animator")
    if animator then
        for _,t in ipairs(animator:GetPlayingAnimationTracks()) do
            t:Stop()
        end
    end
end

-- ===== R15 =====
local function R15_Backup(a)
    if getgenv().ANIM_BACKUP.R15 then return end
    getgenv().ANIM_BACKUP.R15 = {
        idle1=a.idle.Animation1.AnimationId,
        idle2=a.idle.Animation2.AnimationId,
        walk=a.walk.WalkAnim.AnimationId,
        run=a.run.RunAnim.AnimationId,
        jump=a.jump.JumpAnim.AnimationId,
        fall=a.fall.FallAnim.AnimationId,
        climb=a.climb.ClimbAnim.AnimationId,
        swim=a.swim.Swim.AnimationId,
        swimidle=a.swimidle.SwimIdle.AnimationId
    }
end

local function R15_Apply(a)
    a.idle.Animation1.AnimationId="rbxassetid://122257458498464"
    a.idle.Animation2.AnimationId="rbxassetid://98173568987992"
    a.walk.WalkAnim.AnimationId="rbxassetid://122150855457006"
    a.run.RunAnim.AnimationId="rbxassetid://82598234841035"
    a.jump.JumpAnim.AnimationId="rbxassetid://75290611992385"
    a.fall.FallAnim.AnimationId="rbxassetid://18537367238"
    a.climb.ClimbAnim.AnimationId="rbxassetid://88763136693023"
    a.swim.Swim.AnimationId="rbxassetid://133308483266208"
    a.swimidle.SwimIdle.AnimationId="rbxassetid://109346520324160"
end

local function R15_Restore(a)
    local b=getgenv().ANIM_BACKUP.R15 if not b then return end
    a.idle.Animation1.AnimationId=b.idle1
    a.idle.Animation2.AnimationId=b.idle2
    a.walk.WalkAnim.AnimationId=b.walk
    a.run.RunAnim.AnimationId=b.run
    a.jump.JumpAnim.AnimationId=b.jump
    a.fall.FallAnim.AnimationId=b.fall
    a.climb.ClimbAnim.AnimationId=b.climb
    a.swim.Swim.AnimationId=b.swim
    a.swimidle.SwimIdle.AnimationId=b.swimidle
end

-- ===== R6 =====
local function R6_Backup(a)
    if getgenv().ANIM_BACKUP.R6 then return end
    getgenv().ANIM_BACKUP.R6 = {
        idle=a.idle.Animation1.AnimationId,
        walk=a.walk.WalkAnim.AnimationId,
        jump=a.jump.JumpAnim.AnimationId
    }
end

local function R6_Apply(a)
    a.idle.Animation1.AnimationId="rbxassetid://122257458498464"
    a.walk.WalkAnim.AnimationId="rbxassetid://122150855457006"
    a.jump.JumpAnim.AnimationId="rbxassetid://75290611992385"
end

local function R6_Restore(a)
    local b=getgenv().ANIM_BACKUP.R6 if not b then return end
    a.idle.Animation1.AnimationId=b.idle
    a.walk.WalkAnim.AnimationId=b.walk
    a.jump.JumpAnim.AnimationId=b.jump
end

-- ===== APPLY =====
local function apply(char)
    local hum=char:WaitForChild("Humanoid")
    local anim=char:WaitForChild("Animate")
    stopAll(hum)

    if hum.RigType==Enum.HumanoidRigType.R15 then
        if not getgenv().ADIDAS_ON then R15_Backup(anim);R15_Apply(anim)
        else R15_Restore(anim) end
    else
        if not getgenv().ADIDAS_ON then R6_Backup(anim);R6_Apply(anim)
        else R6_Restore(anim) end
    end

    hum:ChangeState(Enum.HumanoidStateType.GettingUp)
end

-- ===== RUN =====
if player.Character then apply(player.Character) end
getgenv().ADIDAS_ON = not getgenv().ADIDAS_ON

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

player.CharacterAdded:Connect(function(c)
    task.wait(0.8)
    if getgenv().ADIDAS_ON then apply(c) end
end)
