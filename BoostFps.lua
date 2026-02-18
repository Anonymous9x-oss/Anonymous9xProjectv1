-- ================================================
-- ANONYMOUS9X ULTRA BOOSTFPS - FIXED
-- Modern Performance Optimization (2026)
-- Map-Safe | Real Performance Boost
-- Toggle: Execute once to enable, execute again to disable
-- ================================================

local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer

-- Check if already active
local BoostActive = _G.Anonymous9xBoostActive or false

-- Storage for original settings
local OriginalSettings = _G.Anonymous9xOriginalSettings or {
    Lighting = {},
    Camera = {},
    PostEffects = {}
}

-- ==================== NOTIFICATION SYSTEM ====================

local function CreateNotification(message, duration)
    local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
    
    -- Remove old notification if exists
    local oldNotif = PlayerGui:FindFirstChild("BoostFPSNotification")
    if oldNotif then oldNotif:Destroy() end
    
    -- Create ScreenGui
    local notifGui = Instance.new("ScreenGui")
    notifGui.Name = "BoostFPSNotification"
    notifGui.ResetOnSpawn = false
    notifGui.DisplayOrder = 9999
    notifGui.IgnoreGuiInset = true
    notifGui.Parent = PlayerGui
    
    -- Create notification frame
    local notifFrame = Instance.new("Frame")
    notifFrame.Name = "NotificationFrame"
    notifFrame.Size = UDim2.new(0, 0, 0, 50)
    notifFrame.Position = UDim2.new(0.5, 0, 0, -60)
    notifFrame.AnchorPoint = Vector2.new(0.5, 0)
    notifFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    notifFrame.BorderSizePixel = 0
    notifFrame.Parent = notifGui
    
    local notifCorner = Instance.new("UICorner")
    notifCorner.CornerRadius = UDim.new(0, 10)
    notifCorner.Parent = notifFrame
    
    local notifStroke = Instance.new("UIStroke")
    notifStroke.Color = Color3.fromRGB(255, 255, 255)
    notifStroke.Thickness = 2
    notifStroke.Transparency = 0
    notifStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    notifStroke.Parent = notifFrame
    
    -- Glow effect
    local glowEffect = Instance.new("ImageLabel")
    glowEffect.Name = "Glow"
    glowEffect.Size = UDim2.new(1, 40, 1, 40)
    glowEffect.Position = UDim2.new(0.5, 0, 0.5, 0)
    glowEffect.AnchorPoint = Vector2.new(0.5, 0.5)
    glowEffect.BackgroundTransparency = 1
    glowEffect.Image = "rbxassetid://5028857084"
    glowEffect.ImageColor3 = Color3.fromRGB(255, 255, 255)
    glowEffect.ImageTransparency = 0.7
    glowEffect.ScaleType = Enum.ScaleType.Slice
    glowEffect.SliceCenter = Rect.new(24, 24, 276, 276)
    glowEffect.Parent = notifFrame
    
    -- Text label
    local notifText = Instance.new("TextLabel")
    notifText.Name = "NotificationText"
    notifText.Size = UDim2.new(1, -20, 1, 0)
    notifText.Position = UDim2.new(0, 10, 0, 0)
    notifText.BackgroundTransparency = 1
    notifText.Text = message
    notifText.TextColor3 = Color3.fromRGB(255, 255, 255)
    notifText.Font = Enum.Font.GothamBold
    notifText.TextSize = 14
    notifText.TextXAlignment = Enum.TextXAlignment.Center
    notifText.Parent = notifFrame
    
    -- Calculate text size for frame width
    local textBounds = notifText.TextBounds.X
    local targetWidth = math.max(textBounds + 40, 300)
    
    -- Slide in animation
    local slideInTween = TweenService:Create(
        notifFrame,
        TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        {
            Size = UDim2.new(0, targetWidth, 0, 50),
            Position = UDim2.new(0.5, 0, 0, 20)
        }
    )
    
    -- Glow pulse animation
    local glowPulse = TweenService:Create(
        glowEffect,
        TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
        {ImageTransparency = 0.9}
    )
    
    slideInTween:Play()
    task.wait(0.3)
    glowPulse:Play()
    
    -- Wait duration
    task.wait(duration or 3)
    
    -- Slide out animation
    local slideOutTween = TweenService:Create(
        notifFrame,
        TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In),
        {
            Size = UDim2.new(0, 0, 0, 50),
            Position = UDim2.new(0.5, 0, 0, -60)
        }
    )
    
    slideOutTween:Play()
    slideOutTween.Completed:Wait()
    
    notifGui:Destroy()
end

-- ==================== SAVE ORIGINAL SETTINGS ====================

local function SaveOriginalSettings()
    -- Lighting settings
    pcall(function()
        OriginalSettings.Lighting = {
            Brightness = Lighting.Brightness,
            GlobalShadows = Lighting.GlobalShadows,
            OutdoorAmbient = Lighting.OutdoorAmbient,
            Ambient = Lighting.Ambient,
            EnvironmentDiffuseScale = Lighting.EnvironmentDiffuseScale,
            EnvironmentSpecularScale = Lighting.EnvironmentSpecularScale,
            Technology = Lighting.Technology
        }
    end)
    
    -- Camera settings
    pcall(function()
        local camera = Workspace.CurrentCamera
        if camera then
            OriginalSettings.Camera = {
                FieldOfView = camera.FieldOfView
            }
        end
    end)
    
    -- Save post-processing effects
    pcall(function()
        OriginalSettings.PostEffects = {}
        for _, effect in pairs(Lighting:GetChildren()) do
            if effect:IsA("BloomEffect") or effect:IsA("BlurEffect") or 
               effect:IsA("ColorCorrectionEffect") or effect:IsA("SunRaysEffect") or
               effect:IsA("DepthOfFieldEffect") or effect:IsA("Atmosphere") then
                OriginalSettings.PostEffects[effect.Name] = {
                    Enabled = effect.Enabled,
                    ClassName = effect.ClassName
                }
            end
        end
    end)
    
    _G.Anonymous9xOriginalSettings = OriginalSettings
end

-- ==================== FPS BOOST FUNCTIONS ====================

local function ApplyFPSBoost()
    print("════════════════════════════════════")
    print("ANONYMOUS9X ULTRA BOOSTFPS")
    print("Applying optimizations...")
    print("════════════════════════════════════")
    
    -- Save original settings first
    SaveOriginalSettings()
    
    -- 1. LIGHTING OPTIMIZATIONS
    pcall(function()
        Lighting.GlobalShadows = false
        Lighting.Brightness = 2
        Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
        Lighting.Ambient = Color3.fromRGB(128, 128, 128)
        Lighting.EnvironmentDiffuseScale = 0
        Lighting.EnvironmentSpecularScale = 0
        Lighting.Technology = Enum.Technology.Compatibility
    end)
    print("✓ Lighting optimized")
    
    -- 2. DISABLE POST-PROCESSING EFFECTS
    pcall(function()
        for _, effect in pairs(Lighting:GetChildren()) do
            if effect:IsA("BloomEffect") or effect:IsA("BlurEffect") or 
               effect:IsA("ColorCorrectionEffect") or effect:IsA("SunRaysEffect") or
               effect:IsA("DepthOfFieldEffect") or effect:IsA("Atmosphere") then
                effect.Enabled = false
            end
        end
    end)
    print("✓ Post-processing disabled")
    
    -- 3. OPTIMIZE WORKSPACE
    local optimizedCount = 0
    pcall(function()
        for _, obj in pairs(Workspace:GetDescendants()) do
            pcall(function()
                if obj:IsA("BasePart") then
                    -- Keep terrain and essential parts, optimize others
                    if not obj:IsA("Terrain") and obj.Parent.Name ~= "Terrain" then
                        obj.CastShadow = false
                        obj.Reflectance = 0
                        
                        -- Optimize materials
                        if obj.Material == Enum.Material.Neon or 
                           obj.Material == Enum.Material.Glass or
                           obj.Material == Enum.Material.ForceField then
                            obj.Material = Enum.Material.SmoothPlastic
                        end
                        
                        -- Optimize MeshParts
                        if obj:IsA("MeshPart") then
                            obj.TextureID = ""
                        end
                        
                        optimizedCount = optimizedCount + 1
                    end
                end
                
                -- Optimize particle emitters
                if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") or 
                   obj:IsA("Fire") or obj:IsA("Sparkles") then
                    obj.Enabled = false
                end
                
                -- Optimize beams and lights
                if obj:IsA("Beam") or obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight") then
                    obj.Enabled = false
                end
            end)
        end
    end)
    print("✓ Workspace optimized (" .. optimizedCount .. " parts)")
    
    -- 4. OPTIMIZE OTHER PLAYERS (NOT LOCAL PLAYER)
    local playerCount = 0
    pcall(function()
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                pcall(function()
                    for _, part in pairs(player.Character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CastShadow = false
                            part.Reflectance = 0
                        end
                        if part:IsA("Decal") or part:IsA("Texture") then
                            part.Transparency = 1
                        end
                        if part:IsA("MeshPart") and part.Parent:IsA("Accessory") then
                            part.TextureID = ""
                        end
                    end
                    playerCount = playerCount + 1
                end)
            end
        end
    end)
    print("✓ Players optimized (" .. playerCount .. " players)")
    
    -- 5. CAMERA OPTIMIZATIONS
    pcall(function()
        local camera = Workspace.CurrentCamera
        if camera then
            camera.FieldOfView = 80
        end
    end)
    print("✓ Camera optimized")
    
    -- 6. RENDER SETTINGS
    pcall(function()
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
    end)
    print("✓ Render quality optimized")
    
    -- 7. GUI OPTIMIZATIONS
    pcall(function()
        local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
        if playerGui then
            for _, gui in pairs(playerGui:GetDescendants()) do
                if gui:IsA("BlurEffect") then
                    gui.Enabled = false
                end
            end
        end
    end)
    print("✓ GUI effects optimized")
    
    -- 8. TERRAIN OPTIMIZATION (WITHOUT HIDING)
    pcall(function()
        local terrain = Workspace:FindFirstChildOfClass("Terrain")
        if terrain then
            terrain.Decoration = false
        end
    end)
    print("✓ Terrain optimized")
    
    print("════════════════════════════════════")
    print("✓ FPS Boost Applied Successfully!")
    print("════════════════════════════════════")
end

-- ==================== RESTORE ORIGINAL SETTINGS ====================

local function RestoreOriginalSettings()
    print("════════════════════════════════════")
    print("Restoring original settings...")
    print("════════════════════════════════════")
    
    -- Restore Lighting
    pcall(function()
        for setting, value in pairs(OriginalSettings.Lighting) do
            Lighting[setting] = value
        end
    end)
    print("✓ Lighting restored")
    
    -- Restore post-processing effects
    pcall(function()
        for effectName, data in pairs(OriginalSettings.PostEffects) do
            local effect = Lighting:FindFirstChild(effectName)
            if effect then
                effect.Enabled = data.Enabled
            end
        end
    end)
    print("✓ Post-processing restored")
    
    -- Restore Camera
    pcall(function()
        local camera = Workspace.CurrentCamera
        if camera and OriginalSettings.Camera.FieldOfView then
            camera.FieldOfView = OriginalSettings.Camera.FieldOfView
        end
    end)
    print("✓ Camera restored")
    
    -- Re-enable particles and effects
    pcall(function()
        for _, obj in pairs(Workspace:GetDescendants()) do
            pcall(function()
                if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or 
                   obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") then
                    obj.Enabled = true
                end
                if obj:IsA("Beam") or obj:IsA("PointLight") or 
                   obj:IsA("SpotLight") or obj:IsA("SurfaceLight") then
                    obj.Enabled = true
                end
            end)
        end
    end)
    print("✓ Effects restored")
    
    print("════════════════════════════════════")
    print("✓ Original settings restored!")
    print("════════════════════════════════════")
end

-- ==================== MAIN TOGGLE LOGIC ====================

if BoostActive then
    -- DISABLE BOOST
    RestoreOriginalSettings()
    _G.Anonymous9xBoostActive = false
    
    -- Show notification
    task.spawn(function()
        CreateNotification("Anonymous9x Ultra BoostFPS UnActive", 3)
    end)
    
    print("FPS Boost: DISABLED")
else
    -- ENABLE BOOST
    ApplyFPSBoost()
    _G.Anonymous9xBoostActive = true
    
    -- Show notification
    task.spawn(function()
        CreateNotification("Anonymous9x Ultra BoostFPS Active\nIf you want to UnActive, click execute again.", 4)
    end)
    
    -- Monitor for new players joining
    pcall(function()
        Players.PlayerAdded:Connect(function(player)
            player.CharacterAdded:Connect(function(character)
                if _G.Anonymous9xBoostActive then
                    task.wait(0.5)
                    pcall(function()
                        for _, part in pairs(character:GetDescendants()) do
                            if part:IsA("BasePart") then
                                part.CastShadow = false
                                part.Reflectance = 0
                            end
                            if part:IsA("Decal") or part:IsA("Texture") then
                                part.Transparency = 1
                            end
                            if part:IsA("MeshPart") and part.Parent:IsA("Accessory") then
                                part.TextureID = ""
                            end
                        end
                    end)
                end
            end)
        end)
    end)
    
    -- Monitor workspace for new parts
    pcall(function()
        Workspace.DescendantAdded:Connect(function(obj)
            if _G.Anonymous9xBoostActive then
                task.wait(0.1)
                pcall(function()
                    if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or 
                       obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") then
                        obj.Enabled = false
                    end
                    if obj:IsA("Beam") or obj:IsA("PointLight") or 
                       obj:IsA("SpotLight") or obj:IsA("SurfaceLight") then
                        obj.Enabled = false
                    end
                    if obj:IsA("BasePart") and not obj:IsA("Terrain") then
                        obj.CastShadow = false
                        obj.Reflectance = 0
                    end
                end)
            end
        end)
    end)
    
    print("FPS Boost: ENABLED")
end
