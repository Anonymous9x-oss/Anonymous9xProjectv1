-- ============================================
-- ANONYMOUS9X LIBRARY - BLACK & WHITE THEME
-- Compatible with Blox Fruit Script
-- Language: INDONESIAN
-- Logo ID: 97269958324726
-- ============================================

local MarketplaceService = game:GetService("MarketplaceService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer

local bearlib = {
    Themes = {
        Monochrome = {
            ["Color Hub 1"] = ColorSequence.new({
                ColorSequenceKeypoint.new(0.00, Color3.fromRGB(20, 20, 20)),
                ColorSequenceKeypoint.new(0.50, Color3.fromRGB(35, 35, 35)),
                ColorSequenceKeypoint.new(1.00, Color3.fromRGB(20, 20, 20))
            }),
            ["Color Hub 2"] = Color3.fromRGB(18, 18, 18),
            ["Color Stroke"] = Color3.fromRGB(80, 80, 80),
            ["Color Theme"] = Color3.fromRGB(255, 255, 255),
            ["Color Text"] = Color3.fromRGB(255, 255, 255),
            ["Color Dark Text"] = Color3.fromRGB(170, 170, 170),
            ["Color Toggle On"] = Color3.fromRGB(220, 220, 220),
            ["Color Toggle Off"] = Color3.fromRGB(50, 50, 50),
            ["Color Toggle Knob On"] = Color3.fromRGB(30, 30, 30),
            ["Color Toggle Knob Off"] = Color3.fromRGB(200, 200, 200),
            ["UI Border Color"] = Color3.fromRGB(100, 100, 100),
            ["Border Thickness"] = 1.5,
        }
    },
    Info = { Version = "1.2.0" },
    Save = { UISize = {550, 380}, TabSize = 160, Theme = "Monochrome" },
    Settings = {},
    Connection = {},
    Instances = {},
    Elements = {},
    Options = {},
    Flags = {},
    Tabs = {},
    AllElements = {},
}

local ViewportSize = workspace.CurrentCamera.ViewportSize
local UIScale = ViewportSize.Y / 450

local function GetStr(val)
    if type(val) == "function" then return val() end
    return val
end

local function CreateTween(Configs)
    local Instance = Configs[1] or Configs.Instance
    local Prop = Configs[2] or Configs.Prop
    local NewVal = Configs[3] or Configs.NewVal
    local Time = Configs[4] or Configs.Time or 0.5
    local TweenWait = Configs[5] or Configs.wait or false
    local TweenInfo = TweenInfo.new(Time, Enum.EasingStyle.Quint)
    local Tween = TweenService:Create(Instance, TweenInfo, {[Prop] = NewVal})
    Tween:Play()
    if TweenWait then Tween.Completed:Wait() end
    return Tween
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Anonymous9x Hub"
ScreenGui.Parent = CoreGui

local UIScaleObj = Instance.new("UIScale")
UIScaleObj.Scale = UIScale
UIScaleObj.Parent = ScreenGui

local Theme = bearlib.Themes[bearlib.Save.Theme]

local function MakeDrag(Instance)
    local dragStart, startPos
    Instance.Active = true
    Instance.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragStart = input.Position
            startPos = Instance.Position
            while UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
                RunService.Heartbeat:Wait()
                local delta = UserInputService:GetMouseLocation() - dragStart
                Instance.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X / UIScale, startPos.Y.Scale, startPos.Y.Offset + delta.Y / UIScale)
            end
        end
    end)
    return Instance
end

local MainFrame = MakeDrag(Instance.new("ImageButton"))
MainFrame.Name = "Hub"
MainFrame.Size = UDim2.fromOffset(550, 380)
MainFrame.Position = UDim2.new(0.5, -275, 0.5, -190)
MainFrame.BackgroundTransparency = 0.03
MainFrame.Parent = ScreenGui

local UIGradient = Instance.new("UIGradient")
UIGradient.Rotation = 45
UIGradient.Color = Theme["Color Hub 1"]
UIGradient.Parent = MainFrame

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 7)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Theme["UI Border Color"]
UIStroke.Thickness = Theme["Border Thickness"]
UIStroke.Parent = MainFrame

local Components = Instance.new("Folder")
Components.Name = "Components"
Components.Parent = MainFrame

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 28)
TopBar.BackgroundTransparency = 1
TopBar.Parent = Components

local Title = Instance.new("TextLabel")
Title.Font = Enum.Font.GothamMedium
Title.TextColor3 = Theme["Color Text"]
Title.Size = UDim2.new(0, 0, 0, 0)
Title.AutomaticSize = "XY"
Title.Position = UDim2.new(0, 15, 0.5)
Title.AnchorPoint = Vector2.new(0, 0.5)
Title.Text = "Anonymous9x Blox Fruit"
Title.BackgroundTransparency = 1
Title.TextSize = 12
Title.Parent = TopBar

local SubTitle = Instance.new("TextLabel")
SubTitle.Font = Enum.Font.Gotham
SubTitle.TextColor3 = Theme["Color Dark Text"]
SubTitle.Size = UDim2.new(0, 0, 0, 0)
SubTitle.AutomaticSize = "XY"
SubTitle.Position = UDim2.new(1, 5, 0.9)
SubTitle.AnchorPoint = Vector2.new(0, 1)
SubTitle.Text = "VIP Script Anonymous9x"
SubTitle.BackgroundTransparency = 1
SubTitle.TextSize = 8
SubTitle.Parent = Title

local ButtonsFolder = Instance.new("Folder")
ButtonsFolder.Name = "Buttons"
ButtonsFolder.Parent = TopBar

local CloseButton = Instance.new("ImageButton")
CloseButton.Size = UDim2.new(0, 14, 0, 14)
CloseButton.Position = UDim2.new(1, -10, 0.5)
CloseButton.AnchorPoint = Vector2.new(1, 0.5)
CloseButton.BackgroundTransparency = 1
CloseButton.Image = "rbxassetid://10747384394"
CloseButton.AutoButtonColor = false
CloseButton.Parent = ButtonsFolder

local MinimizeButton = Instance.new("ImageButton")
MinimizeButton.Size = UDim2.new(0, 14, 0, 14)
MinimizeButton.Position = UDim2.new(1, -35, 0.5)
MinimizeButton.AnchorPoint = Vector2.new(1, 0.5)
MinimizeButton.BackgroundTransparency = 1
MinimizeButton.Image = "rbxassetid://97269958324726"
MinimizeButton.ImageColor3 = Theme["Color Text"]
MinimizeButton.AutoButtonColor = false
MinimizeButton.Parent = ButtonsFolder

local SearchButton = Instance.new("ImageButton")
SearchButton.Size = UDim2.new(0, 14, 0, 14)
SearchButton.Position = UDim2.new(1, -60, 0.5)
SearchButton.AnchorPoint = Vector2.new(1, 0.5)
SearchButton.BackgroundTransparency = 1
SearchButton.Image = "rbxassetid://10734943674"
SearchButton.ImageColor3 = Theme["Color Text"]
SearchButton.Parent = ButtonsFolder

local MainScroll = Instance.new("ScrollingFrame")
MainScroll.Size = UDim2.new(0, 160, 1, -28)
MainScroll.Position = UDim2.new(0, 0, 1, 0)
MainScroll.AnchorPoint = Vector2.new(0, 1)
MainScroll.BackgroundTransparency = 1
MainScroll.ScrollBarThickness = 1.5
MainScroll.ScrollBarImageColor3 = Theme["Color Theme"]
MainScroll.ScrollBarImageTransparency = 0.2
MainScroll.CanvasSize = UDim2.new()
MainScroll.AutomaticCanvasSize = "Y"
MainScroll.ScrollingDirection = "Y"
MainScroll.BorderSizePixel = 0
MainScroll.Parent = Components

local UIPaddingMain = Instance.new("UIPadding")
UIPaddingMain.PaddingLeft = UDim.new(0, 10)
UIPaddingMain.PaddingRight = UDim.new(0, 10)
UIPaddingMain.PaddingTop = UDim.new(0, 10)
UIPaddingMain.PaddingBottom = UDim.new(0, 10)
UIPaddingMain.Parent = MainScroll

local UIListLayoutMain = Instance.new("UIListLayout")
UIListLayoutMain.Padding = UDim.new(0, 5)
UIListLayoutMain.Parent = MainScroll

local Containers = Instance.new("Frame")
Containers.Size = UDim2.new(1, -160, 1, -28)
Containers.Position = UDim2.new(1, 0, 1, 0)
Containers.AnchorPoint = Vector2.new(1, 1)
Containers.BackgroundTransparency = 1
Containers.ClipsDescendants = true
Containers.Parent = Components

local ContainerList = {}
local Tabs = {}

function bearlib:MakeWindow(Configs)
    local WTitle = Configs.Title or "Anonymous9x Blox Fruit"
    local WSubTitle = Configs.SubTitle or "VIP Script Anonymous9x"
    
    Title.Text = WTitle
    SubTitle.Text = WSubTitle
    
    local FirstTab = true
    
    local Window = {}
    
    function Window:MakeTab(Configs)
        local TName = Configs.Title or "Tab"
        local TIcon = Configs.Icon or ""
        
        local TabButton = Instance.new("TextButton")
        TabButton.Size = UDim2.new(1, 0, 0, 24)
        TabButton.BackgroundColor3 = Theme["Color Hub 2"]
        TabButton.Text = ""
        TabButton.AutoButtonColor = false
        TabButton.Parent = MainScroll
        
        local UICornerTab = Instance.new("UICorner")
        UICornerTab.CornerRadius = UDim.new(0, 6)
        UICornerTab.Parent = TabButton
        
        local TabLabel = Instance.new("TextLabel")
        TabLabel.Font = Enum.Font.GothamMedium
        TabLabel.TextColor3 = Theme["Color Text"]
        TabLabel.Size = UDim2.new(1, -15, 1, 0)
        TabLabel.Position = UDim2.new(0, 15, 0, 0)
        TabLabel.BackgroundTransparency = 1
        TabLabel.Text = TName
        TabLabel.TextSize = 10
        TabLabel.TextXAlignment = "Left"
        TabLabel.TextTransparency = FirstTab and 0 or 0.3
        TabLabel.Parent = TabButton
        
        local TabIcon = nil
        if TIcon and TIcon ~= "" then
            TabIcon = Instance.new("ImageLabel")
            TabIcon.Size = UDim2.new(0, 13, 0, 13)
            TabIcon.Position = UDim2.new(0, 8, 0.5)
            TabIcon.AnchorPoint = Vector2.new(0, 0.5)
            TabIcon.BackgroundTransparency = 1
            TabIcon.Image = TIcon
            TabIcon.ImageColor3 = Theme["Color Text"]
            TabIcon.ImageTransparency = FirstTab and 0 or 0.3
            TabIcon.Parent = TabButton
            TabLabel.Position = UDim2.new(0, 25, 0, 0)
            TabLabel.Size = UDim2.new(1, -30, 1, 0)
        end
        
        local Selected = Instance.new("Frame")
        Selected.Size = FirstTab and UDim2.new(0, 4, 0, 4) or UDim2.new(0, 4, 0, 13)
        Selected.Position = UDim2.new(0, 1, 0.5)
        Selected.AnchorPoint = Vector2.new(0, 0.5)
        Selected.BackgroundColor3 = Theme["Color Theme"]
        Selected.BackgroundTransparency = FirstTab and 1 or 0
        Selected.Parent = TabButton
        
        local UICornerSelected = Instance.new("UICorner")
        UICornerSelected.CornerRadius = UDim.new(0.5, 0)
        UICornerSelected.Parent = Selected
        
        local Container = Instance.new("ScrollingFrame")
        Container.Size = UDim2.new(1, 0, 1, 0)
        Container.Position = UDim2.new(0, 0, 1, 0)
        Container.AnchorPoint = Vector2.new(0, 1)
        Container.BackgroundTransparency = 1
        Container.ScrollBarThickness = 1.5
        Container.ScrollBarImageColor3 = Theme["Color Theme"]
        Container.ScrollBarImageTransparency = 0.2
        Container.CanvasSize = UDim2.new()
        Container.AutomaticCanvasSize = "Y"
        Container.ScrollingDirection = "Y"
        Container.BorderSizePixel = 0
        Container.Visible = FirstTab
        Container.Parent = Containers
        
        local UIPaddingCont = Instance.new("UIPadding")
        UIPaddingCont.PaddingLeft = UDim.new(0, 10)
        UIPaddingCont.PaddingRight = UDim.new(0, 10)
        UIPaddingCont.PaddingTop = UDim.new(0, 10)
        UIPaddingCont.PaddingBottom = UDim.new(0, 10)
        UIPaddingCont.Parent = Container
        
        local UIListLayoutCont = Instance.new("UIListLayout")
        UIListLayoutCont.Padding = UDim.new(0, 5)
        UIListLayoutCont.SortOrder = "LayoutOrder"
        UIListLayoutCont.Parent = Container
        
        table.insert(ContainerList, Container)
        
        local function SelectTab()
            for _, c in pairs(ContainerList) do
                c.Visible = false
            end
            Container.Visible = true
            for _, tab in pairs(Tabs) do
                if tab.Container ~= Container then
                    if tab.TabLabel then tab.TabLabel.TextTransparency = 0.3 end
                    if tab.TabIcon then tab.TabIcon.ImageTransparency = 0.3 end
                    if tab.Selected then
                        CreateTween({tab.Selected, "Size", UDim2.new(0, 4, 0, 4), 0.35})
                        CreateTween({tab.Selected, "BackgroundTransparency", 1, 0.35})
                    end
                end
            end
            CreateTween({TabLabel, "TextTransparency", 0, 0.35})
            if TabIcon then CreateTween({TabIcon, "ImageTransparency", 0, 0.35}) end
            CreateTween({Selected, "Size", UDim2.new(0, 4, 0, 13), 0.35})
            CreateTween({Selected, "BackgroundTransparency", 0, 0.35})
        end
        
        TabButton.Activated:Connect(SelectTab)
        
        local Tab = {
            Container = Container,
            TabButton = TabButton,
            TabLabel = TabLabel,
            TabIcon = TabIcon,
            Selected = Selected,
        }
        
        table.insert(Tabs, Tab)
        
        if FirstTab then
            SelectTab()
            FirstTab = false
        end
        
        local ElementCount = 0
        local function GetOrder()
            ElementCount = ElementCount + 1
            return ElementCount
        end
        
        local CurrentSection = nil
        
        function Tab:AddSection(Configs)
            local SectionName = type(Configs) == "string" and Configs or Configs.Title or "Bagian"
            
            local SectionFrame = Instance.new("Frame")
            SectionFrame.Size = UDim2.new(1, 0, 0, 30)
            SectionFrame.BackgroundTransparency = 1
            SectionFrame.LayoutOrder = GetOrder()
            SectionFrame.Parent = Container
            
            local SectionLabel = Instance.new("TextLabel")
            SectionLabel.Font = Enum.Font.GothamBold
            SectionLabel.Text = SectionName
            SectionLabel.TextColor3 = Theme["Color Text"]
            SectionLabel.Size = UDim2.new(1, -25, 0, 18)
            SectionLabel.Position = UDim2.new(0, 5, 0, 0)
            SectionLabel.BackgroundTransparency = 1
            SectionLabel.TextSize = 14
            SectionLabel.TextXAlignment = "Left"
            SectionLabel.Parent = SectionFrame
            
            local Underline = Instance.new("Frame")
            Underline.Size = UDim2.new(1, -10, 0, 1.5)
            Underline.Position = UDim2.new(0, 5, 1, -5)
            Underline.BackgroundColor3 = Theme["UI Border Color"]
            Underline.BorderSizePixel = 0
            Underline.Parent = SectionFrame
            
            local Section = {
                Frame = SectionFrame,
                Label = SectionLabel,
            }
            
            function Section:Visible(bool)
                SectionFrame.Visible = bool ~= nil and bool or not SectionFrame.Visible
            end
            
            function Section:Destroy()
                SectionFrame:Destroy()
            end
            
            return Section
        end
        
        function Tab:AddParagraph(Configs)
            local PTitle = Configs.Title or "Paragraf"
            local PText = Configs.Text or ""
            
            local Frame = Instance.new("Frame")
            Frame.Size = UDim2.new(1, 0, 0, 25)
            Frame.AutomaticSize = "Y"
            Frame.BackgroundColor3 = Theme["Color Hub 2"]
            Frame.LayoutOrder = GetOrder()
            Frame.Parent = Container
            
            local UICornerFrame = Instance.new("UICorner")
            UICornerFrame.CornerRadius = UDim.new(0, 6)
            UICornerFrame.Parent = Frame
            
            local TitleLabel = Instance.new("TextLabel")
            TitleLabel.Font = Enum.Font.GothamMedium
            TitleLabel.TextColor3 = Theme["Color Text"]
            TitleLabel.Size = UDim2.new(1, -20, 0, 0)
            TitleLabel.AutomaticSize = "Y"
            TitleLabel.Position = UDim2.new(0, 10, 0.5)
            TitleLabel.AnchorPoint = Vector2.new(0, 0.5)
            TitleLabel.BackgroundTransparency = 1
            TitleLabel.Text = PTitle
            TitleLabel.TextSize = 10
            TitleLabel.TextXAlignment = "Left"
            TitleLabel.Parent = Frame
            
            local DescLabel = Instance.new("TextLabel")
            DescLabel.Font = Enum.Font.Gotham
            DescLabel.TextColor3 = Theme["Color Dark Text"]
            DescLabel.Size = UDim2.new(1, -20, 0, 0)
            DescLabel.AutomaticSize = "Y"
            DescLabel.Position = UDim2.new(0, 10, 0.5)
            DescLabel.AnchorPoint = Vector2.new(0, 0.5)
            DescLabel.BackgroundTransparency = 1
            DescLabel.Text = PText
            DescLabel.TextSize = 8
            DescLabel.TextXAlignment = "Left"
            DescLabel.Visible = PText ~= ""
            DescLabel.Parent = Frame
            
            local Paragraph = {}
            
            function Paragraph:SetTitle(NewTitle)
                TitleLabel.Text = NewTitle
            end
            
            function Paragraph:SetDesc(NewDesc)
                DescLabel.Text = NewDesc
                DescLabel.Visible = NewDesc ~= ""
            end
            
            function Paragraph:Set(Title, Desc)
                if Title then Paragraph:SetTitle(Title) end
                if Desc then Paragraph:SetDesc(Desc) end
            end
            
            return Paragraph
        end
        
        function Tab:AddButton(Configs)
            local BTitle = Configs.Title or "Tombol"
            local BDesc = Configs.Desc or ""
            local Callback = Configs.Callback or function() end
            
            local Frame = Instance.new("TextButton")
            Frame.Size = UDim2.new(1, 0, 0, 25)
            Frame.AutomaticSize = "Y"
            Frame.BackgroundColor3 = Theme["Color Hub 2"]
            Frame.Text = ""
            Frame.AutoButtonColor = false
            Frame.LayoutOrder = GetOrder()
            Frame.Parent = Container
            
            local UICornerFrame = Instance.new("UICorner")
            UICornerFrame.CornerRadius = UDim.new(0, 6)
            UICornerFrame.Parent = Frame
            
            Frame.MouseEnter:Connect(function()
                Frame.BackgroundTransparency = 0.4
            end)
            Frame.MouseLeave:Connect(function()
                Frame.BackgroundTransparency = 0
            end)
            
            local TitleLabel = Instance.new("TextLabel")
            TitleLabel.Font = Enum.Font.GothamMedium
            TitleLabel.TextColor3 = Theme["Color Text"]
            TitleLabel.Size = UDim2.new(1, -20, 0, 0)
            TitleLabel.AutomaticSize = "Y"
            TitleLabel.Position = UDim2.new(0, 10, 0.5)
            TitleLabel.AnchorPoint = Vector2.new(0, 0.5)
            TitleLabel.BackgroundTransparency = 1
            TitleLabel.Text = BTitle
            TitleLabel.TextSize = 10
            TitleLabel.TextXAlignment = "Left"
            TitleLabel.Parent = Frame
            
            local DescLabel = Instance.new("TextLabel")
            DescLabel.Font = Enum.Font.Gotham
            DescLabel.TextColor3 = Theme["Color Dark Text"]
            DescLabel.Size = UDim2.new(1, -20, 0, 0)
            DescLabel.AutomaticSize = "Y"
            DescLabel.Position = UDim2.new(0, 10, 0.5)
            DescLabel.AnchorPoint = Vector2.new(0, 0.5)
            DescLabel.BackgroundTransparency = 1
            DescLabel.Text = BDesc
            DescLabel.TextSize = 8
            DescLabel.TextXAlignment = "Left"
            DescLabel.Visible = BDesc ~= ""
            DescLabel.Parent = Frame
            
            local Icon = Instance.new("ImageLabel")
            Icon.Size = UDim2.new(0, 14, 0, 14)
            Icon.Position = UDim2.new(1, -10, 0.5)
            Icon.AnchorPoint = Vector2.new(1, 0.5)
            Icon.BackgroundTransparency = 1
            Icon.Image = "rbxassetid://10709791437"
            Icon.Parent = Frame
            
            Frame.Activated:Connect(Callback)
            
            local Button = {}
            
            function Button:SetTitle(NewTitle)
                TitleLabel.Text = NewTitle
            end
            
            function Button:SetDesc(NewDesc)
                DescLabel.Text = NewDesc
                DescLabel.Visible = NewDesc ~= ""
            end
            
            return Button
        end
        
        function Tab:AddToggle(Configs)
            local TTitle = Configs.Title or "Toggle"
            local TDesc = Configs.Desc or ""
            local Default = Configs.Default or false
            local Flag = Configs.Flag or nil
            local Callback = Configs.Callback or function() end
            
            local Frame = Instance.new("TextButton")
            Frame.Size = UDim2.new(1, 0, 0, 25)
            Frame.AutomaticSize = "Y"
            Frame.BackgroundColor3 = Theme["Color Hub 2"]
            Frame.Text = ""
            Frame.AutoButtonColor = false
            Frame.LayoutOrder = GetOrder()
            Frame.Parent = Container
            
            local UICornerFrame = Instance.new("UICorner")
            UICornerFrame.CornerRadius = UDim.new(0, 6)
            UICornerFrame.Parent = Frame
            
            local TitleLabel = Instance.new("TextLabel")
            TitleLabel.Font = Enum.Font.GothamMedium
            TitleLabel.TextColor3 = Theme["Color Text"]
            TitleLabel.Size = UDim2.new(1, -48, 0, 0)
            TitleLabel.AutomaticSize = "Y"
            TitleLabel.Position = UDim2.new(0, 10, 0.5)
            TitleLabel.AnchorPoint = Vector2.new(0, 0.5)
            TitleLabel.BackgroundTransparency = 1
            TitleLabel.Text = TTitle
            TitleLabel.TextSize = 10
            TitleLabel.TextXAlignment = "Left"
            TitleLabel.Parent = Frame
            
            local DescLabel = Instance.new("TextLabel")
            DescLabel.Font = Enum.Font.Gotham
            DescLabel.TextColor3 = Theme["Color Dark Text"]
            DescLabel.Size = UDim2.new(1, -48, 0, 0)
            DescLabel.AutomaticSize = "Y"
            DescLabel.Position = UDim2.new(0, 10, 0.5)
            DescLabel.AnchorPoint = Vector2.new(0, 0.5)
            DescLabel.BackgroundTransparency = 1
            DescLabel.Text = TDesc
            DescLabel.TextSize = 8
            DescLabel.TextXAlignment = "Left"
            DescLabel.Visible = TDesc ~= ""
            DescLabel.Parent = Frame
            
            local ToggleHolder = Instance.new("Frame")
            ToggleHolder.Size = UDim2.new(0, 35, 0, 18)
            ToggleHolder.Position = UDim2.new(1, -10, 0.5)
            ToggleHolder.AnchorPoint = Vector2.new(1, 0.5)
            ToggleHolder.BackgroundColor3 = Default and Theme["Color Toggle On"] or Theme["Color Toggle Off"]
            ToggleHolder.Parent = Frame
            
            local UICornerToggle = Instance.new("UICorner")
            UICornerToggle.CornerRadius = UDim.new(0.5, 0)
            UICornerToggle.Parent = ToggleHolder
            
            local UIStrokeToggle = Instance.new("UIStroke")
            UIStrokeToggle.Color = Theme["Color Stroke"]
            UIStrokeToggle.Thickness = 1
            UIStrokeToggle.Parent = ToggleHolder
            
            local Knob = Instance.new("Frame")
            Knob.Size = UDim2.new(0, 12, 0, 12)
            Knob.Position = Default and UDim2.new(1, 0, 0.5) or UDim2.new(0, 0, 0.5)
            Knob.AnchorPoint = Default and Vector2.new(1, 0.5) or Vector2.new(0, 0.5)
            Knob.BackgroundColor3 = Default and Theme["Color Toggle Knob On"] or Theme["Color Toggle Knob Off"]
            Knob.Parent = ToggleHolder
            
            local UICornerKnob = Instance.new("UICorner")
            UICornerKnob.CornerRadius = UDim.new(0.5, 0)
            UICornerKnob.Parent = Knob
            
            local ToggleValue = Default
            
            local function UpdateToggle(Value)
                ToggleValue = Value
                if ToggleValue then
                    CreateTween({ToggleHolder, "BackgroundColor3", Theme["Color Toggle On"], 0.25})
                    CreateTween({Knob, "Position", UDim2.new(1, 0, 0.5), 0.25})
                    CreateTween({Knob, "AnchorPoint", Vector2.new(1, 0.5), 0.25})
                    CreateTween({Knob, "BackgroundColor3", Theme["Color Toggle Knob On"], 0.25})
                else
                    CreateTween({ToggleHolder, "BackgroundColor3", Theme["Color Toggle Off"], 0.25})
                    CreateTween({Knob, "Position", UDim2.new(0, 0, 0.5), 0.25})
                    CreateTween({Knob, "AnchorPoint", Vector2.new(0, 0.5), 0.25})
                    CreateTween({Knob, "BackgroundColor3", Theme["Color Toggle Knob Off"], 0.25})
                end
                Callback(ToggleValue)
                if Flag then
                    _G[Flag] = ToggleValue
                end
            end
            
            Frame.Activated:Connect(function()
                UpdateToggle(not ToggleValue)
            end)
            
            local Toggle = {}
            
            function Toggle:Set(Value)
                UpdateToggle(Value)
            end
            
            function Toggle:Get()
                return ToggleValue
            end
            
            return Toggle
        end
        
        function Tab:AddDropdown(Configs)
            local DTitle = Configs.Title or "Dropdown"
            local DDesc = Configs.Desc or ""
            local Options = Configs.Options or {}
            local Default = Configs.Default or Options[1] or ""
            local Callback = Configs.Callback or function() end
            
            local Frame = Instance.new("TextButton")
            Frame.Size = UDim2.new(1, 0, 0, 25)
            Frame.AutomaticSize = "Y"
            Frame.BackgroundColor3 = Theme["Color Hub 2"]
            Frame.Text = ""
            Frame.AutoButtonColor = false
            Frame.LayoutOrder = GetOrder()
            Frame.Parent = Container
            
            local UICornerFrame = Instance.new("UICorner")
            UICornerFrame.CornerRadius = UDim.new(0, 6)
            UICornerFrame.Parent = Frame
            
            local TitleLabel = Instance.new("TextLabel")
            TitleLabel.Font = Enum.Font.GothamMedium
            TitleLabel.TextColor3 = Theme["Color Text"]
            TitleLabel.Size = UDim2.new(1, -180, 0, 0)
            TitleLabel.AutomaticSize = "Y"
            TitleLabel.Position = UDim2.new(0, 10, 0.5)
            TitleLabel.AnchorPoint = Vector2.new(0, 0.5)
            TitleLabel.BackgroundTransparency = 1
            TitleLabel.Text = DTitle
            TitleLabel.TextSize = 10
            TitleLabel.TextXAlignment = "Left"
            TitleLabel.Parent = Frame
            
            local DescLabel = Instance.new("TextLabel")
            DescLabel.Font = Enum.Font.Gotham
            DescLabel.TextColor3 = Theme["Color Dark Text"]
            DescLabel.Size = UDim2.new(1, -180, 0, 0)
            DescLabel.AutomaticSize = "Y"
            DescLabel.Position = UDim2.new(0, 10, 0.5)
            DescLabel.AnchorPoint = Vector2.new(0, 0.5)
            DescLabel.BackgroundTransparency = 1
            DescLabel.Text = DDesc
            DescLabel.TextSize = 8
            DescLabel.TextXAlignment = "Left"
            DescLabel.Visible = DDesc ~= ""
            DescLabel.Parent = Frame
            
            local SelectedFrame = Instance.new("Frame")
            SelectedFrame.Size = UDim2.new(0, 150, 0, 18)
            SelectedFrame.Position = UDim2.new(1, -10, 0.5)
            SelectedFrame.AnchorPoint = Vector2.new(1, 0.5)
            SelectedFrame.BackgroundColor3 = Theme["Color Stroke"]
            SelectedFrame.Parent = Frame
            
            local UICornerSelected = Instance.new("UICorner")
            UICornerSelected.CornerRadius = UDim.new(0, 4)
            UICornerSelected.Parent = SelectedFrame
            
            local ValueLabel = Instance.new("TextLabel")
            ValueLabel.Font = Enum.Font.GothamBold
            ValueLabel.TextColor3 = Theme["Color Text"]
            ValueLabel.Size = UDim2.new(0.85, 0, 0.85, 0)
            ValueLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
            ValueLabel.AnchorPoint = Vector2.new(0.5, 0.5)
            ValueLabel.BackgroundTransparency = 1
            ValueLabel.TextScaled = true
            ValueLabel.Text = Default
            ValueLabel.Parent = SelectedFrame
            
            local Arrow = Instance.new("ImageLabel")
            Arrow.Size = UDim2.new(0, 15, 0, 15)
            Arrow.Position = UDim2.new(0, -5, 0.5)
            Arrow.AnchorPoint = Vector2.new(1, 0.5)
            Arrow.BackgroundTransparency = 1
            Arrow.Image = "rbxassetid://10709791523"
            Arrow.Parent = SelectedFrame
            
            local DropdownValue = Default
            local DropdownVisible = false
            
            local function SetValue(Value)
                DropdownValue = Value
                ValueLabel.Text = Value
                Callback(Value)
            end
            
            SetValue(Default)
            
            local DropdownFrame = nil
            
            Frame.Activated:Connect(function()
                if DropdownVisible then
                    if DropdownFrame then DropdownFrame:Destroy() end
                    DropdownVisible = false
                    CreateTween({Arrow, "Rotation", 0, 0.2})
                else
                    if DropdownFrame then DropdownFrame:Destroy() end
                    DropdownFrame = Instance.new("Frame")
                    DropdownFrame.Size = UDim2.new(0, 152, 0, 0)
                    DropdownFrame.BackgroundTransparency = 0.1
                    DropdownFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    DropdownFrame.AnchorPoint = Vector2.new(0, 1)
                    DropdownFrame.ClipsDescendants = true
                    DropdownFrame.Parent = ScreenGui
                    
                    local DropCorner = Instance.new("UICorner")
                    DropCorner.CornerRadius = UDim.new(0, 6)
                    DropCorner.Parent = DropdownFrame
                    
                    local DropStroke = Instance.new("UIStroke")
                    DropStroke.Color = Theme["Color Stroke"]
                    DropStroke.Parent = DropdownFrame
                    
                    local Scroll = Instance.new("ScrollingFrame")
                    Scroll.Size = UDim2.new(1, 0, 1, 0)
                    Scroll.BackgroundTransparency = 1
                    Scroll.ScrollBarThickness = 1.5
                    Scroll.ScrollBarImageColor3 = Theme["Color Theme"]
                    Scroll.CanvasSize = UDim2.new()
                    Scroll.AutomaticCanvasSize = "Y"
                    Scroll.ScrollingDirection = "Y"
                    Scroll.Parent = DropdownFrame
                    
                    local ScrollPad = Instance.new("UIPadding")
                    ScrollPad.PaddingLeft = UDim.new(0, 8)
                    ScrollPad.PaddingRight = UDim.new(0, 8)
                    ScrollPad.PaddingTop = UDim.new(0, 5)
                    ScrollPad.PaddingBottom = UDim.new(0, 5)
                    ScrollPad.Parent = Scroll
                    
                    local ScrollLayout = Instance.new("UIListLayout")
                    ScrollLayout.Padding = UDim.new(0, 4)
                    ScrollLayout.Parent = Scroll
                    
                    local Count = 0
                    for _, opt in ipairs(Options) do
                        Count = Count + 1
                        local OptButton = Instance.new("TextButton")
                        OptButton.Size = UDim2.new(1, 0, 0, 18)
                        OptButton.BackgroundTransparency = 1
                        OptButton.Text = opt
                        OptButton.Font = Enum.Font.Gotham
                        OptButton.TextColor3 = Theme["Color Text"]
                        OptButton.TextSize = 10
                        OptButton.TextXAlignment = "Left"
                        OptButton.Parent = Scroll
                        
                        OptButton.Activated:Connect(function()
                            SetValue(opt)
                            DropdownFrame:Destroy()
                            DropdownVisible = false
                            CreateTween({Arrow, "Rotation", 0, 0.2})
                        end)
                    end
                    
                    local FramePos = SelectedFrame.AbsolutePosition
                    local NewPos = UDim2.fromOffset(FramePos.X / UIScale, FramePos.Y / UIScale)
                    DropdownFrame.Position = NewPos
                    
                    local SizeY = math.clamp(Count, 1, 10) * 25 + 10
                    DropdownFrame.Size = UDim2.new(0, 152, 0, SizeY)
                    
                    DropdownVisible = true
                    CreateTween({Arrow, "Rotation", 180, 0.2})
                end
            end)
            
            local Dropdown = {}
            
            function Dropdown:Set(Value)
                SetValue(Value)
            end
            
            function Dropdown:Get()
                return DropdownValue
            end
            
            function Dropdown:Refresh(NewOptions)
                if DropdownFrame then DropdownFrame:Destroy() end
                DropdownVisible = false
                Options = NewOptions
                if Options[1] then
                    SetValue(Options[1])
                end
            end
            
            return Dropdown
        end
        
        function Tab:AddTextBox(Configs)
            local TTitle = Configs.Title or "Text Box"
            local TDesc = Configs.Desc or ""
            local Placeholder = Configs.Placeholder or ""
            local Default = Configs.Default or ""
            local Callback = Configs.Callback or function() end
            
            local Frame = Instance.new("Frame")
            Frame.Size = UDim2.new(1, 0, 0, 25)
            Frame.AutomaticSize = "Y"
            Frame.BackgroundColor3 = Theme["Color Hub 2"]
            Frame.LayoutOrder = GetOrder()
            Frame.Parent = Container
            
            local UICornerFrame = Instance.new("UICorner")
            UICornerFrame.CornerRadius = UDim.new(0, 6)
            UICornerFrame.Parent = Frame
            
            local TitleLabel = Instance.new("TextLabel")
            TitleLabel.Font = Enum.Font.GothamMedium
            TitleLabel.TextColor3 = Theme["Color Text"]
            TitleLabel.Size = UDim2.new(1, -180, 0, 0)
            TitleLabel.AutomaticSize = "Y"
            TitleLabel.Position = UDim2.new(0, 10, 0.5)
            TitleLabel.AnchorPoint = Vector2.new(0, 0.5)
            TitleLabel.BackgroundTransparency = 1
            TitleLabel.Text = TTitle
            TitleLabel.TextSize = 10
            TitleLabel.TextXAlignment = "Left"
            TitleLabel.Parent = Frame
            
            local DescLabel = Instance.new("TextLabel")
            DescLabel.Font = Enum.Font.Gotham
            DescLabel.TextColor3 = Theme["Color Dark Text"]
            DescLabel.Size = UDim2.new(1, -180, 0, 0)
            DescLabel.AutomaticSize = "Y"
            DescLabel.Position = UDim2.new(0, 10, 0.5)
            DescLabel.AnchorPoint = Vector2.new(0, 0.5)
            DescLabel.BackgroundTransparency = 1
            DescLabel.Text = TDesc
            DescLabel.TextSize = 8
            DescLabel.TextXAlignment = "Left"
            DescLabel.Visible = TDesc ~= ""
            DescLabel.Parent = Frame
            
            local BoxHolder = Instance.new("Frame")
            BoxHolder.Size = UDim2.new(0, 150, 0, 18)
            BoxHolder.Position = UDim2.new(1, -10, 0.5)
            BoxHolder.AnchorPoint = Vector2.new(1, 0.5)
            BoxHolder.BackgroundColor3 = Theme["Color Stroke"]
            BoxHolder.Parent = Frame
            
            local UICornerBox = Instance.new("UICorner")
            UICornerBox.CornerRadius = UDim.new(0, 4)
            UICornerBox.Parent = BoxHolder
            
            local TextBox = Instance.new("TextBox")
            TextBox.Size = UDim2.new(0.9, 0, 0.9, 0)
            TextBox.Position = UDim2.new(0.5, 0, 0.5, 0)
            TextBox.AnchorPoint = Vector2.new(0.5, 0.5)
            TextBox.BackgroundTransparency = 1
            TextBox.Font = Enum.Font.GothamBold
            TextBox.TextScaled = true
            TextBox.TextColor3 = Theme["Color Text"]
            TextBox.Text = Default
            TextBox.PlaceholderText = Placeholder
            TextBox.Parent = BoxHolder
            
            TextBox.FocusLost:Connect(function(enterPressed)
                if enterPressed then
                    Callback(TextBox.Text)
                end
            end)
            
            local Textbox = {}
            
            function Textbox:Set(Value)
                TextBox.Text = Value
                Callback(Value)
            end
            
            function Textbox:Get()
                return TextBox.Text
            end
            
            return Textbox
        end
        
        function Tab:AddSlider(Configs)
            local STitle = Configs.Title or "Slider"
            local SDesc = Configs.Desc or ""
            local Min = Configs.Min or 0
            local Max = Configs.Max or 100
            local Default = Configs.Default or Min
            local Increment = Configs.Increment or 1
            local Callback = Configs.Callback or function() end
            
            local Frame = Instance.new("Frame")
            Frame.Size = UDim2.new(1, 0, 0, 25)
            Frame.AutomaticSize = "Y"
            Frame.BackgroundColor3 = Theme["Color Hub 2"]
            Frame.LayoutOrder = GetOrder()
            Frame.Parent = Container
            
            local UICornerFrame = Instance.new("UICorner")
            UICornerFrame.CornerRadius = UDim.new(0, 6)
            UICornerFrame.Parent = Frame
            
            local TitleLabel = Instance.new("TextLabel")
            TitleLabel.Font = Enum.Font.GothamMedium
            TitleLabel.TextColor3 = Theme["Color Text"]
            TitleLabel.Size = UDim2.new(1, -180, 0, 0)
            TitleLabel.AutomaticSize = "Y"
            TitleLabel.Position = UDim2.new(0, 10, 0.5)
            TitleLabel.AnchorPoint = Vector2.new(0, 0.5)
            TitleLabel.BackgroundTransparency = 1
            TitleLabel.Text = STitle
            TitleLabel.TextSize = 10
            TitleLabel.TextXAlignment = "Left"
            TitleLabel.Parent = Frame
            
            local DescLabel = Instance.new("TextLabel")
            DescLabel.Font = Enum.Font.Gotham
            DescLabel.TextColor3 = Theme["Color Dark Text"]
            DescLabel.Size = UDim2.new(1, -180, 0, 0)
            DescLabel.AutomaticSize = "Y"
            DescLabel.Position = UDim2.new(0, 10, 0.5)
            DescLabel.AnchorPoint = Vector2.new(0, 0.5)
            DescLabel.BackgroundTransparency = 1
            DescLabel.Text = SDesc
            DescLabel.TextSize = 8
            DescLabel.TextXAlignment = "Left"
            DescLabel.Visible = SDesc ~= ""
            DescLabel.Parent = Frame
            
            local SliderFrame = Instance.new("Frame")
            SliderFrame.Size = UDim2.new(0, 150, 0, 18)
            SliderFrame.Position = UDim2.new(1, -10, 0.5)
            SliderFrame.AnchorPoint = Vector2.new(1, 0.5)
            SliderFrame.BackgroundColor3 = Theme["Color Hub 2"]
            SliderFrame.Parent = Frame
            
            local UICornerSlider = Instance.new("UICorner")
            UICornerSlider.CornerRadius = UDim.new(0, 4)
            UICornerSlider.Parent = SliderFrame
            
            local UIStrokeSlider = Instance.new("UIStroke")
            UIStrokeSlider.Color = Theme["Color Stroke"]
            UIStrokeSlider.Parent = SliderFrame
            
            local SliderBar = Instance.new("Frame")
            SliderBar.Size = UDim2.new(0, 0, 1, 0)
            SliderBar.BackgroundColor3 = Theme["Color Theme"]
            SliderBar.Parent = SliderFrame
            
            local BarCorner = Instance.new("UICorner")
            BarCorner.CornerRadius = UDim.new(0, 4)
            BarCorner.Parent = SliderBar
            
            local ValueLabel = Instance.new("TextLabel")
            ValueLabel.Font = Enum.Font.GothamBold
            ValueLabel.TextColor3 = Theme["Color Text"]
            ValueLabel.Size = UDim2.new(0.8, 0, 0.8, 0)
            ValueLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
            ValueLabel.AnchorPoint = Vector2.new(0.5, 0.5)
            ValueLabel.BackgroundTransparency = 1
            ValueLabel.TextScaled = true
            ValueLabel.Text = tostring(Default)
            ValueLabel.Parent = SliderFrame
            
            local SliderValue = Default
            local Dragging = false
            
            local function SetValue(Value)
                Value = math.clamp(Value, Min, Max)
                local Rounded = math.round(Value / Increment) * Increment
                SliderValue = Rounded
                local Percent = (Rounded - Min) / (Max - Min)
                SliderBar.Size = UDim2.new(Percent, 0, 1, 0)
                ValueLabel.Text = tostring(Rounded)
                Callback(Rounded)
            end
            
            SetValue(Default)
            
            SliderFrame.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    Dragging = true
                    local Percent = (input.Position.X - SliderFrame.AbsolutePosition.X) / SliderFrame.AbsoluteSize.X
                    local Value = Min + ((Max - Min) * math.clamp(Percent, 0, 1))
                    SetValue(Value)
                end
            end)
            
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    Dragging = false
                end
            end)
            
            UserInputService.InputChanged:Connect(function(input)
                if Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    local Percent = (input.Position.X - SliderFrame.AbsolutePosition.X) / SliderFrame.AbsoluteSize.X
                    local Value = Min + ((Max - Min) * math.clamp(Percent, 0, 1))
                    SetValue(Value)
                end
            end)
            
            local Slider = {}
            
            function Slider:Set(Value)
                SetValue(Value)
            end
            
            function Slider:Get()
                return SliderValue
            end
            
            return Slider
        end
        
        return Tab
    end
    
    CloseButton.Activated:Connect(function()
        local Screen = Instance.new("Frame")
        Screen.Size = UDim2.new(1, 0, 1, 0)
        Screen.BackgroundTransparency = 0.6
        Screen.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        Screen.Parent = MainFrame
        
        local DialogFrame = Instance.new("Frame")
        DialogFrame.Size = UDim2.new(0, 270, 0, 150)
        DialogFrame.Position = UDim2.new(0.5, -135, 0.5, -75)
        DialogFrame.AnchorPoint = Vector2.new(0.5, 0.5)
        DialogFrame.BackgroundColor3 = Theme["Color Hub 2"]
        DialogFrame.Parent = Screen
        
        local DialogCorner = Instance.new("UICorner")
        DialogCorner.CornerRadius = UDim.new(0, 7)
        DialogCorner.Parent = DialogFrame
        
        local DialogStroke = Instance.new("UIStroke")
        DialogStroke.Color = Theme["UI Border Color"]
        DialogStroke.Parent = DialogFrame
        
        local DialogTitle = Instance.new("TextLabel")
        DialogTitle.Font = Enum.Font.GothamBold
        DialogTitle.TextColor3 = Theme["Color Text"]
        DialogTitle.Size = UDim2.new(1, 0, 0, 30)
        DialogTitle.Position = UDim2.new(0, 15, 0, 5)
        DialogTitle.BackgroundTransparency = 1
        DialogTitle.Text = "Konfirmasi"
        DialogTitle.TextSize = 14
        DialogTitle.TextXAlignment = "Left"
        DialogTitle.Parent = DialogFrame
        
        local DialogText = Instance.new("TextLabel")
        DialogText.Font = Enum.Font.Gotham
        DialogText.TextColor3 = Theme["Color Dark Text"]
        DialogText.Size = UDim2.new(1, -30, 0, 0)
        DialogText.Position = UDim2.new(0, 15, 0, 40)
        DialogText.BackgroundTransparency = 1
        DialogText.Text = "Apakah kamu yakin ingin menutup script?"
        DialogText.TextSize = 12
        DialogText.TextWrapped = true
        DialogText.Parent = DialogFrame
        
        local ButtonHolder = Instance.new("Frame")
        ButtonHolder.Size = UDim2.new(1, 0, 0, 35)
        ButtonHolder.Position = UDim2.new(0, 0, 1, -40)
        ButtonHolder.BackgroundTransparency = 1
        ButtonHolder.Parent = DialogFrame
        
        local ConfirmBtn = Instance.new("TextButton")
        ConfirmBtn.Size = UDim2.new(0.45, 0, 1, 0)
        ConfirmBtn.Position = UDim2.new(0.05, 0, 0, 0)
        ConfirmBtn.BackgroundColor3 = Theme["Color Hub 2"]
        ConfirmBtn.Text = "Ya, Tutup"
        ConfirmBtn.Font = Enum.Font.GothamBold
        ConfirmBtn.TextColor3 = Theme["Color Text"]
        ConfirmBtn.TextSize = 12
        ConfirmBtn.Parent = ButtonHolder
        
        local ConfirmCorner = Instance.new("UICorner")
        ConfirmCorner.CornerRadius = UDim.new(0, 4)
        ConfirmCorner.Parent = ConfirmBtn
        
        local CancelBtn = Instance.new("TextButton")
        CancelBtn.Size = UDim2.new(0.45, 0, 1, 0)
        CancelBtn.Position = UDim2.new(0.5, 0, 0, 0)
        CancelBtn.BackgroundColor3 = Theme["Color Hub 2"]
        CancelBtn.Text = "Batal"
        CancelBtn.Font = Enum.Font.GothamBold
        CancelBtn.TextColor3 = Theme["Color Text"]
        CancelBtn.TextSize = 12
        CancelBtn.Parent = ButtonHolder
        
        local CancelCorner = Instance.new("UICorner")
        CancelCorner.CornerRadius = UDim.new(0, 4)
        CancelCorner.Parent = CancelBtn
        
        ConfirmBtn.Activated:Connect(function()
            ScreenGui:Destroy()
        end)
        
        CancelBtn.Activated:Connect(function()
            Screen:Destroy()
        end)
    end)
    
    MinimizeButton.Activated:Connect(function()
        MainFrame.Visible = not MainFrame.Visible
    end)
    
    return Window
end

return bearlib
