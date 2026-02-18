-- ================================================
-- FLING ANO9X (ARMAGEDON EDITION) 
-- FULL ORIGINAL LOGIC - NO REDUCTION
-- ================================================

local Players = game:GetService("Players") 
local RunService = game:GetService("RunService") 
local CoreGui = game:GetService("CoreGui")
local Player = Players.LocalPlayer 

local Theme = {
    Bg = Color3.fromRGB(10, 10, 12),
    Panel = Color3.fromRGB(18, 18, 20),
    Stroke = Color3.fromRGB(255, 255, 255),
    Red = Color3.fromRGB(255, 0, 0),
    Text = Color3.fromRGB(255, 255, 255)
}

if CoreGui:FindFirstChild("FlingAno9xV4") then CoreGui.FlingAno9xV4:Destroy() end

local ScreenGui = Instance.new("ScreenGui", CoreGui) 
ScreenGui.Name = "FlingAno9x" 

local Main = Instance.new("Frame", ScreenGui) 
Main.Size = UDim2.new(0, 280, 0, 330) 
Main.Position = UDim2.new(0.5, -140, 0.5, -165) 
Main.BackgroundColor3 = Theme.Bg 
Main.ClipsDescendants = true 
Main.Active = true

local MainStroke = Instance.new("UIStroke", Main)
MainStroke.Color = Theme.Stroke
MainStroke.Transparency = 0.8
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 6)

-- Drag Logic
local dragging, dragInput, dragStart, startPos
Main.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true; dragStart = input.Position; startPos = Main.Position
    end
end)
Main.InputChanged:Connect(function(input)
    if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and dragging then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
Main.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)

-- Title & Buttons
local TitleBar = Instance.new("Frame", Main) 
TitleBar.Size = UDim2.new(1, 0, 0, 30) 
TitleBar.BackgroundTransparency = 1

local Title = Instance.new("TextLabel", TitleBar) 
Title.Size = UDim2.new(1, -70, 1, 0) 
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1 
Title.Text = "FLING ANO9X" 
Title.TextColor3 = Theme.Red 
Title.Font = Enum.Font.SourceSansBold 
Title.TextSize = 16 
Title.TextXAlignment = "Left"

local MinBtn = Instance.new("TextButton", TitleBar)
MinBtn.Text = "-"
MinBtn.Size = UDim2.new(0, 30, 0, 30)
MinBtn.Position = UDim2.new(1, -60, 0, 0)
MinBtn.BackgroundTransparency = 1
MinBtn.TextColor3 = Theme.Text
MinBtn.TextSize = 20
MinBtn.Font = Enum.Font.SourceSansBold

local Expanded = true
MinBtn.MouseButton1Click:Connect(function()
    Expanded = not Expanded
    Main:TweenSize(Expanded and UDim2.new(0, 280, 0, 330) or UDim2.new(0, 280, 0, 30), "Out", "Quad", 0.2, true)
end)

local Close = Instance.new("TextButton", TitleBar) 
Close.Position = UDim2.new(1, -30, 0, 0) 
Close.Size = UDim2.new(0, 30, 0, 30) 
Close.BackgroundTransparency = 1; Close.Text = "X"; Close.TextColor3 = Theme.Text; Close.Font = Enum.Font.SourceSansBold; Close.TextSize = 16 
Close.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

local StatusLabel = Instance.new("TextLabel", Main) 
StatusLabel.Position = UDim2.new(0, 10, 0, 35); StatusLabel.Size = UDim2.new(1, -20, 0, 20) 
StatusLabel.BackgroundTransparency = 1; StatusLabel.Text = "Select targets to fling"; StatusLabel.TextColor3 = Theme.Red; StatusLabel.Font = Enum.Font.SourceSans; StatusLabel.TextSize = 14; StatusLabel.TextXAlignment = "Left" 

local SelectionFrame = Instance.new("Frame", Main) 
SelectionFrame.Position = UDim2.new(0, 10, 0, 60); SelectionFrame.Size = UDim2.new(1, -20, 0, 180); SelectionFrame.BackgroundColor3 = Theme.Panel; Instance.new("UICorner", SelectionFrame)

local Scroll = Instance.new("ScrollingFrame", SelectionFrame) 
Scroll.Size = UDim2.new(1, -10, 1, -10); Scroll.Position = UDim2.new(0, 5, 0, 5); Scroll.BackgroundTransparency = 1; Scroll.ScrollBarThickness = 3; Scroll.CanvasSize = UDim2.new(0, 0, 0, 0) 
local Layout = Instance.new("UIListLayout", Scroll); Layout.Padding = UDim.new(0, 2)

-- ORIGINAL VARIABLES & LOGIC START
local SelectedTargets = {} 
local PlayerCheckboxes = {} 
local FlingActive = false 
getgenv().OldPos = nil 
getgenv().FPDH = workspace.FallenPartsDestroyHeight 

local function Message(Title, Text, Time) 
    game:GetService("StarterGui"):SetCore("SendNotification", { Title = Title, Text = Text, Duration = Time or 5 }) 
end

local function RefreshPlayerList() 
    for _, child in pairs(Scroll:GetChildren()) do if child:IsA("Frame") then child:Destroy() end end 
    PlayerCheckboxes = {} 
    local PlayerList = Players:GetPlayers() 
    for _, player in ipairs(PlayerList) do 
        if player ~= Player then 
            local Entry = Instance.new("Frame", Scroll)
            Entry.Size = UDim2.new(1, 0, 0, 25); Entry.BackgroundTransparency = 1
            local Label = Instance.new("TextLabel", Entry)
            Label.Size = UDim2.new(1, -10, 1, 0); Label.Position = UDim2.new(0, 5, 0, 0); Label.Text = "  " .. player.Name; Label.TextColor3 = SelectedTargets[player.Name] and Theme.Red or Theme.Text; Label.BackgroundTransparency = 1; Label.Font = Enum.Font.SourceSans; Label.TextSize = 14; Label.TextXAlignment = "Left"
            local Btn = Instance.new("TextButton", Entry); Btn.Size = UDim2.new(1, 0, 1, 0); Btn.BackgroundTransparency = 1; Btn.Text = ""
            Btn.MouseButton1Click:Connect(function()
                if SelectedTargets[player.Name] then SelectedTargets[player.Name] = nil; Label.TextColor3 = Theme.Text
                else SelectedTargets[player.Name] = player; Label.TextColor3 = Theme.Red end
                StatusLabel.Text = "Targets: " .. (function() local c=0 for _ in pairs(SelectedTargets) do c=c+1 end return c end)()
            end)
            PlayerCheckboxes[player.Name] = Label
        end 
    end 
    Scroll.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y)
end 

-- THE ORIGINAL SkidFling (DENGAN EFEK BLING-BLING/ROTASI PENUH)
local function SkidFling(TargetPlayer) 
    local Character = Player.Character 
    local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid") 
    local RootPart = Humanoid and Humanoid.RootPart 
    local TCharacter = TargetPlayer.Character 
    if not TCharacter then return end 
    local THumanoid = TCharacter:FindFirstChildOfClass("Humanoid") 
    local TRootPart = THumanoid and THumanoid.RootPart 
    local THead = TCharacter:FindFirstChild("Head") 
    local Accessory = TCharacter:FindFirstChildOfClass("Accessory") 
    local Handle = Accessory and Accessory:FindFirstChild("Handle") 
    
    if Character and Humanoid and RootPart then 
        if RootPart.Velocity.Magnitude < 50 then getgenv().OldPos = RootPart.CFrame end 
        if THumanoid and THumanoid.Sit then return end 
        if THead then workspace.CurrentCamera.CameraSubject = THead end 
        
        local FPos = function(BasePart, Pos, Ang) 
            RootPart.CFrame = CFrame.new(BasePart.Position) * Pos * Ang 
            Character:SetPrimaryPartCFrame(CFrame.new(BasePart.Position) * Pos * Ang) 
            RootPart.Velocity = Vector3.new(9e7, 9e7 * 10, 9e7) 
            RootPart.RotVelocity = Vector3.new(9e8, 9e8, 9e8) 
        end 
        
        local SFBasePart = function(BasePart) 
            local TimeToWait = 2; local Time = tick(); local Angle = 0 
            repeat 
                if RootPart and THumanoid then 
                    Angle = Angle + 100 
                    FPos(BasePart, CFrame.new(0, 1.5, 0), CFrame.Angles(math.rad(Angle),0 ,0)) 
                    task.wait()
                    FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(Angle), 0, 0)) 
                    task.wait()
                end 
            until Time + TimeToWait < tick() or not FlingActive 
        end 
        
        workspace.FallenPartsDestroyHeight = 0/0 
        local BV = Instance.new("BodyVelocity", RootPart); BV.Velocity = Vector3.new(0,0,0); BV.MaxForce = Vector3.new(9e9,9e9,9e9) 
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false) 
        
        if TRootPart then SFBasePart(TRootPart) elseif THead then SFBasePart(THead) end 
        
        BV:Destroy(); Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true) 
        workspace.CurrentCamera.CameraSubject = Humanoid 
        if getgenv().OldPos then 
            RootPart.CFrame = getgenv().OldPos; workspace.FallenPartsDestroyHeight = getgenv().FPDH 
        end 
    end 
end 

-- Buttons Setup Armagedon Style
local StartBtn = Instance.new("TextButton", Main) 
StartBtn.Position = UDim2.new(0, 10, 0, 250); StartBtn.Size = UDim2.new(0.5, -12, 0, 35); StartBtn.BackgroundColor3 = Theme.Red; StartBtn.Text = "START FLING"; StartBtn.TextColor3 = Theme.Text; StartBtn.Font = Enum.Font.SourceSansBold; StartBtn.TextSize = 14; Instance.new("UICorner", StartBtn)

local StopBtn = Instance.new("TextButton", Main) 
StopBtn.Position = UDim2.new(0.5, 2, 0, 250); StopBtn.Size = UDim2.new(0.5, -12, 0, 35); StopBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40); StopBtn.Text = "STOP FLING"; StopBtn.TextColor3 = Theme.Text; StopBtn.Font = Enum.Font.SourceSansBold; StopBtn.TextSize = 14; Instance.new("UICorner", StopBtn)

local SelectAll = Instance.new("TextButton", Main) 
SelectAll.Position = UDim2.new(0, 10, 0, 295); SelectAll.Size = UDim2.new(0.5, -12, 0, 25); SelectAll.BackgroundColor3 = Theme.Panel; SelectAll.Text = "SELECT ALL"; SelectAll.TextColor3 = Theme.Text; SelectAll.Font = Enum.Font.SourceSans; SelectAll.TextSize = 12; Instance.new("UICorner", SelectAll)

local DeselectAll = Instance.new("TextButton", Main) 
DeselectAll.Position = UDim2.new(0.5, 2, 0, 295); DeselectAll.Size = UDim2.new(0.5, -12, 0, 25); DeselectAll.BackgroundColor3 = Theme.Panel; DeselectAll.Text = "DESELECT ALL"; DeselectAll.TextColor3 = Theme.Text; DeselectAll.Font = Enum.Font.SourceSans; DeselectAll.TextSize = 12; Instance.new("UICorner", DeselectAll)

StartBtn.MouseButton1Click:Connect(function()
    if FlingActive then return end; FlingActive = true; StatusLabel.Text = "ATTACKING..."
    task.spawn(function()
        while FlingActive do
            for name, p in pairs(SelectedTargets) do
                if not FlingActive then break end
                if p and p.Parent then SkidFling(p) end
                task.wait(0.1)
            end
            task.wait(0.1)
        end
    end)
end)

StopBtn.MouseButton1Click:Connect(function() FlingActive = false; StatusLabel.Text = "Stopped." end)
SelectAll.MouseButton1Click:Connect(function()
    for _, p in pairs(Players:GetPlayers()) do if p ~= Player then SelectedTargets[p.Name] = p; if PlayerCheckboxes[p.Name] then PlayerCheckboxes[p.Name].TextColor3 = Theme.Red end end end
    StatusLabel.Text = "Targets: " .. (function() local c=0 for _ in pairs(SelectedTargets) do c=c+1 end return c end)()
end)
DeselectAll.MouseButton1Click:Connect(function()
    SelectedTargets = {}; for _, l in pairs(PlayerCheckboxes) do l.TextColor3 = Theme.Text end; StatusLabel.Text = "Targets: 0"
end)

RefreshPlayerList()
Players.PlayerAdded:Connect(RefreshPlayerList)
Players.PlayerRemoving:Connect(RefreshPlayerList)
Message("Hello", "Fling Ano9x Loaded!", 3)
