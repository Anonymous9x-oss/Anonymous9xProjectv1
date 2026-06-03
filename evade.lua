--[[
    bearlib UI Library (embedded)
    Original source: anolib.lua
    Modified to work as a standalone loader.
--]]
local bearlib = (function()
    local MarketplaceService = game:GetService("MarketplaceService")
    local UserInputService = game:GetService("UserInputService")
    local TweenService = game:GetService("TweenService")
    local HttpService = game:GetService("HttpService")
    local RunService = game:GetService("RunService")
    local CoreGui = game:GetService("CoreGui")
    local Players = game:GetService("Players")
    local Player = Players.LocalPlayer
    local PlayerMouse = Player:GetMouse()

    local bearlib = {
        Themes = {
            QuangHuy = {
                ["Color Hub 1"] = ColorSequence.new({
                    ColorSequenceKeypoint.new(0.00, Color3.fromRGB(0, 0, 0)),
                    ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0, 0, 0)),
                    ColorSequenceKeypoint.new(1.00, Color3.fromRGB(0, 0, 0))
                }),
                ["Color Hub 2"] = Color3.fromRGB(0,0,0),
                ["Color Stroke"] = Color3.fromRGB(255,255,255),
                ["Color Theme"] = Color3.fromRGB(255,255,255),
                ["Color Text"] = Color3.fromRGB(180,180,180),
                ["Color Dark Text"] = Color3.fromRGB(120,120,120),
                ["Color Discord Text"] = Color3.fromRGB(255,255,255),
                ["Color Discord Stats"] = Color3.fromRGB(255,255,255),
                ["Color Discord Border"] = Color3.fromRGB(255,255,255),
                ["Color Profile Border"] = Color3.fromRGB(255,255,255),
                ["Color Card Border"] = Color3.fromRGB(255,255,255),
                ["Color Toggle On"] = Color3.fromRGB(255,255,255),
                ["Color Toggle Off"] = Color3.fromRGB(0,0,0),
                ["Color Toggle Knob On"] = Color3.fromRGB(0,0,0),
                ["Color Toggle Knob Off"] = Color3.fromRGB(255,255,255),
                ["Color Toggle Border"] = Color3.fromRGB(255,255,255),
                ["Border Thickness"] = 1.5,
                ["UI Border Color"] = Color3.fromRGB(255,255,255),
            }
        },
        Info = { Version = "1.2.0" },
        Save = { UISize = {550, 380}, TabSize = 160, Theme = "QuangHuy" },
        Settings = {},
        Connection = {},
        Instances = {},
        Elements = {},
        Options = {},
        Flags = {},
        Tabs = {},
        Icons = {},
        AllElements = {},
        ThunderActive = false
    }

    local ViewportSize = workspace.CurrentCamera.ViewportSize
    local UIScale = ViewportSize.Y / 450
    local Settings = bearlib.Settings
    local Flags = bearlib.Flags

    local SetProps, SetChildren, InsertTheme, Create
    InsertTheme = function(Instance, Type)
        table.insert(bearlib.Instances, { Instance = Instance, Type = Type })
        return Instance
    end
    SetChildren = function(Instance, Children)
        if Children then
            for _, Child in pairs(Children) do Child.Parent = Instance end
        end
        return Instance
    end
    SetProps = function(Instance, Props)
        if Props then
            for prop, value in pairs(Props) do Instance[prop] = value end
        end
        return Instance
    end
    Create = function(...)
        local args = {...}
        if type(args) ~= "table" then return end
        local new = Instance.new(args[1])
        local Children = {}
        if type(args[2]) == "table" then
            SetProps(new, args[2])
            SetChildren(new, args[3])
            Children = args[3] or {}
        elseif typeof(args[2]) == "Instance" then
            new.Parent = args[2]
            SetProps(new, args[3])
            SetChildren(new, args[4])
            Children = args[4] or {}
        end
        return new
    end

    local function Save(file)
        if readfile and isfile and isfile(file) then
            local decode = HttpService:JSONDecode(readfile(file))
            if type(decode) == "table" then
                if rawget(decode, "UISize") then bearlib.Save["UISize"] = decode["UISize"] end
                if rawget(decode, "TabSize") then bearlib.Save["TabSize"] = decode["TabSize"] end
                if rawget(decode, "Theme") then
                    for name,_ in pairs(bearlib.Themes) do
                        if name == decode["Theme"] then bearlib.Save["Theme"] = decode["Theme"] end
                    end
                end
            end
        end
    end
    pcall(Save, "bear library v8.1.json")

    local Funcs = {}
    do
        function Funcs:InsertCallback(tab, func)
            if type(func) == "function" then table.insert(tab, func) end
            return func
        end
        function Funcs:FireCallback(tab, ...)
            for _,v in ipairs(tab) do if type(v) == "function" then task.spawn(v, ...) end end
        end
        function Funcs:ToggleVisible(Obj, Bool) Obj.Visible = Bool ~= nil and Bool or Obj.Visible end
        function Funcs:GetConnectionFunctions(ConnectedFuncs, func)
            local Connected = { Function = func, Connected = true }
            function Connected:Disconnect()
                if self.Connected then
                    table.remove(ConnectedFuncs, table.find(ConnectedFuncs, self.Function))
                    self.Connected = false
                end
            end
            function Connected:Fire(...) if self.Connected then task.spawn(self.Function, ...) end end
            return Connected
        end
        function Funcs:GetCallback(Configs, index)
            local func = Configs[index] or Configs.Callback or function() end
            if type(func) == "table" then return ({function(Value) func[1][func[2]] = Value end}) end
            return {func}
        end
    end

    local Connections, Connection = {}, bearlib.Connection
    do
        local function NewConnectionList(List)
            if type(List) ~= "table" then return end
            for _,CoName in ipairs(List) do
                local ConnectedFuncs, Connect = {}, {}
                Connection[CoName] = Connect
                Connections[CoName] = ConnectedFuncs
                Connect.Name = CoName
                function Connect:Connect(func)
                    if type(func) == "function" then
                        table.insert(ConnectedFuncs, func)
                        return Funcs:GetConnectionFunctions(ConnectedFuncs, func)
                    end
                end
                function Connect:Once(func)
                    if type(func) == "function" then
                        local Connected;
                        local _NFunc;_NFunc = function(...)
                            task.spawn(func, ...)
                            Connected:Disconnect()
                        end
                        Connected = Funcs:GetConnectionFunctions(ConnectedFuncs, _NFunc)
                        return Connected
                    end
                end
            end
        end
        function Connection:FireConnection(CoName, ...)
            local Connection = type(CoName) == "string" and Connections[CoName] or Connections[CoName.Name]
            for _,Func in pairs(Connection) do task.spawn(Func, ...) end
        end
        NewConnectionList({"FlagsChanged", "ThemeChanged", "FileSaved", "ThemeChanging", "OptionAdded"})
    end

    local GetFlag, SetFlag, CheckFlag
    do
        CheckFlag = function(Name) return type(Name) == "string" and Flags[Name] ~= nil end
        GetFlag = function(Name) return type(Name) == "string" and Flags[Name] end
        SetFlag = function(Flag, Value)
            if Flag and (Value ~= Flags[Flag] or type(Value) == "table") then
                Flags[Flag] = Value
                Connection:FireConnection("FlagsChanged", Flag, Value)
            end
        end
        local db
        Connection.FlagsChanged:Connect(function(Flag, Value)
            local ScriptFile = Settings.ScriptFile
            if not db and ScriptFile and writefile then
                db=true;task.wait(0.1);db=false
                local Success, Encoded = pcall(function() return HttpService:JSONEncode(Flags) end)
                if Success then pcall(writefile, ScriptFile, Encoded) end
            end
        end)
    end

    local ScreenGui = Create("ScreenGui", CoreGui, { Name = "bear Library v8.1" }, { Create("UIScale", { Scale = UIScale, Name = "Scale" }) })
    local ScreenFind = CoreGui:FindFirstChild(ScreenGui.Name)
    if ScreenFind and ScreenFind ~= ScreenGui then ScreenFind:Destroy() end

    local function GetStr(val) return type(val) == "function" and val() or val end
    local function ConnectSave(Instance, func)
        Instance.InputBegan:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                while UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do task.wait() end
                func()
            end
        end)
    end
    local function CreateTween(Configs)
        local Instance = Configs[1] or Configs.Instance
        local Prop = Configs[2] or Configs.Prop
        local NewVal = Configs[3] or Configs.NewVal
        local Time = Configs[4] or Configs.Time or 0.5
        local TweenWait = Configs[5] or Configs.wait or false
        local Tween = TweenService:Create(Instance, TweenInfo.new(Time, Enum.EasingStyle.Quint), {[Prop] = NewVal})
        Tween:Play()
        if TweenWait then Tween.Completed:Wait() end
        return Tween
    end
    local function MakeDrag(Instance)
        task.spawn(function()
            SetProps(Instance, { Active = true, AutoButtonColor = false })
            local DragStart, StartPos, InputOn
            local function Update(Input)
                local delta = Input.Position - DragStart
                local Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + delta.X / UIScale, StartPos.Y.Scale, StartPos.Y.Offset + delta.Y / UIScale)
                CreateTween({Instance, "Position", Position, 0.35})
            end
            Instance.MouseButton1Down:Connect(function() InputOn = true end)
            Instance.InputBegan:Connect(function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                    StartPos = Instance.Position
                    DragStart = Input.Position
                    while UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do RunService.Heartbeat:Wait()
                        if InputOn then Update(Input) end
                    end
                    InputOn = false
                end
            end)
        end)
        return Instance
    end
    local function VerifyTheme(Theme)
        for name,_ in pairs(bearlib.Themes) do if name == Theme then return true end end
    end
    local function SaveJson(FileName, save)
        if writefile then writefile(FileName, HttpService:JSONEncode(save)) end
    end
    local Theme = bearlib.Themes[bearlib.Save.Theme]

    local function AddEle(Name, Func) bearlib.Elements[Name] = Func end
    local function Make(Ele, Instance, props, ...) return bearlib.Elements[Ele](Instance, props, ...) end

    AddEle("Corner", function(parent, CornerRadius)
        return SetProps(Create("UICorner", parent, { CornerRadius = CornerRadius or UDim.new(0, 7) }))
    end)
    AddEle("Stroke", function(parent, props, ...)
        local args = {...}
        return InsertTheme(SetProps(Create("UIStroke", parent, { Color = args[1] or Theme["Color Stroke"], Thickness = args[2] or 1, ApplyStrokeMode = "Border" }), props), "Stroke")
    end)
    AddEle("Button", function(parent, props, ...)
        local args = {...}
        local New = InsertTheme(SetProps(Create("TextButton", parent, { Text = "", Size = UDim2.fromScale(1, 1), BackgroundColor3 = Theme["Color Hub 2"], AutoButtonColor = false }), props), "Frame")
        New.MouseEnter:Connect(function() New.BackgroundTransparency = 0.4 end)
        New.MouseLeave:Connect(function() New.BackgroundTransparency = 0 end)
        if args[1] then New.Activated:Connect(args[1]) end
        return New
    end)
    AddEle("Gradient", function(parent, props, ...)
        return InsertTheme(SetProps(Create("UIGradient", parent, { Color = Theme["Color Hub 1"] }), props), "Gradient")
    end)

    local function ButtonFrame(Instance, Title, Description, HolderSize)
        local TitleL = InsertTheme(Create("TextLabel", { Font = Enum.Font.GothamMedium, TextColor3 = Theme["Color Text"], Size = UDim2.new(1, -20), AutomaticSize = "Y", Position = UDim2.new(0, 0, 0.5), AnchorPoint = Vector2.new(0, 0.5), BackgroundTransparency = 1, TextTruncate = "AtEnd", TextSize = 10, TextXAlignment = "Left", Text = "", RichText = true, ZIndex = 5 }), "Text")
        local DescL = InsertTheme(Create("TextLabel", { Font = Enum.Font.Gotham, TextColor3 = Theme["Color Dark Text"], Size = UDim2.new(1, -20), AutomaticSize = "Y", Position = UDim2.new(0, 12, 0, 15), BackgroundTransparency = 1, TextWrapped = true, TextSize = 8, TextXAlignment = "Left", Text = "", RichText = true, ZIndex = 5 }), "DarkText")
        local Frame = Make("Button", Instance, { Size = UDim2.new(1, 0, 0, 25), AutomaticSize = "Y", Name = "Option" })
        Make("Corner", Frame, UDim.new(0, 6))
        local LabelHolder = Create("Frame", Frame, { AutomaticSize = "Y", BackgroundTransparency = 1, Size = HolderSize, Position = UDim2.new(0, 10, 0), AnchorPoint = Vector2.new(0, 0), ZIndex = 4 }, {
            Create("UIListLayout", { SortOrder = "LayoutOrder", VerticalAlignment = "Center", Padding = UDim.new(0, 2) }),
            Create("UIPadding", { PaddingBottom = UDim.new(0, 5), PaddingTop = UDim.new(0, 5) }),
            TitleL, DescL,
        })
        local Label = {}
        function Label:SetTitle(NewTitle) if type(NewTitle) == "string" and NewTitle:gsub(" ", ""):len() > 0 then TitleL.Text = NewTitle end end
        function Label:SetDesc(NewDesc)
            if type(NewDesc) == "string" and NewDesc:gsub(" ", ""):len() > 0 then
                DescL.Visible = true
                DescL.Text = NewDesc
                LabelHolder.Position = UDim2.new(0, 10, 0)
                LabelHolder.AnchorPoint = Vector2.new(0, 0)
            else
                DescL.Visible = false
                DescL.Text = ""
                LabelHolder.Position = UDim2.new(0, 10, 0.5)
                LabelHolder.AnchorPoint = Vector2.new(0, 0.5)
            end
        end
        Label:SetTitle(Title)
        Label:SetDesc(Description)
        return Frame, Label
    end

    function bearlib:GetIcon(index) return index end
    function bearlib:SetTheme(NewTheme)
        if not VerifyTheme(NewTheme) then return end
        bearlib.Save.Theme = NewTheme
        SaveJson("bear library v8.1.json", bearlib.Save)
        Theme = bearlib.Themes[NewTheme]
        for _, Val in pairs(bearlib.Instances) do
            if not Val.Instance or not Val.Instance.Parent then continue end
            if Val.Type == "Gradient" then
                Val.Instance.Color = Theme["Color Hub 1"]
            elseif Val.Type == "Frame" then
                Val.Instance.BackgroundColor3 = Theme["Color Hub 2"]
            elseif Val.Type == "Stroke" then
                Val.Instance.Color = Theme["Color Stroke"]
                Val.Instance.Thickness = Theme["Border Thickness"]
            elseif Val.Type == "Theme" then
                Val.Instance.BackgroundColor3 = Theme["Color Theme"]
            elseif Val.Type == "Text" then
                Val.Instance.TextColor3 = Theme["Color Text"]
            elseif Val.Type == "DarkText" then
                Val.Instance.TextColor3 = Theme["Color Dark Text"]
            elseif Val.Type == "ScrollBar" then
                Val.Instance.ScrollBarImageColor3 = Theme["Color Theme"]
            elseif Val.Type == "UIBorder" then
                Val.Instance.Color = Theme["UI Border Color"]
                Val.Instance.Thickness = Theme["Border Thickness"]
            end
        end
        print("Theme changed to:", NewTheme)
    end
    function bearlib:SetScale(NewScale)
        UIScale = ViewportSize.Y / math.clamp(NewScale, 300, 2000)
        ScreenGui.Scale.Scale = UIScale
    end

    local MainFrame, SearchButton, MinimizeButton, ToggleButton, ToggleGui, MinimizedContainer, MinimizedIcon, MinimizedTitle

    function bearlib:MakeWindow(Configs)
        local WTitle = Configs[1] or Configs.Name or Configs.Title or "bear Library v8.1"
        local WMiniText = Configs[2] or Configs.SubTitle or "by : Quang Huy"
        Settings.ScriptFile = Configs[3] or Configs.SaveFolder or false

        local function LoadFile()
            local File = Settings.ScriptFile
            if type(File) ~= "string" or not readfile or not isfile then return end
            local s, r = pcall(isfile, File)
            if s and r then
                local s, _Flags = pcall(readfile, File)
                if s and type(_Flags) == "string" then
                    local s,r = pcall(function() return HttpService:JSONDecode(_Flags) end)
                    Flags = s and r or {}
                end
            end
        end
        LoadFile()

        local UISizeX, UISizeY = unpack(bearlib.Save.UISize)
        local bgTransparency = 0.03
        MainFrame = InsertTheme(Create("ImageButton", ScreenGui, { Size = UDim2.fromOffset(UISizeX, UISizeY), Position = UDim2.new(0.5, -UISizeX/2, 0.5, -UISizeY/2), BackgroundTransparency = bgTransparency, Name = "Hub" }), "Main")
        Make("Gradient", MainFrame, { Rotation = 45 })
        MakeDrag(MainFrame)
        Make("Corner", MainFrame, UDim.new(0, 7))
        local UIBorder = Instance.new("UIStroke")
        UIBorder.Name = "UIBorder"
        UIBorder.Color = Theme["UI Border Color"]
        UIBorder.Thickness = 1.5
        UIBorder.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        UIBorder.LineJoinMode = Enum.LineJoinMode.Round
        UIBorder.Parent = MainFrame
        InsertTheme(UIBorder, "UIBorder")

        local Components = Create("Folder", MainFrame, { Name = "Components" })
        local DropdownHolder = Create("Folder", ScreenGui, { Name = "Dropdown" })
        local TopBar = Create("Frame", Components, { Size = UDim2.new(1, 0, 0, 28), BackgroundTransparency = 1, Name = "Top Bar" })
        local Title = InsertTheme(Create("TextLabel", TopBar, { Position = UDim2.new(0, 15, 0.5), AnchorPoint = Vector2.new(0, 0.5), AutomaticSize = "XY", Text = WTitle, TextXAlignment = "Left", TextSize = 12, TextColor3 = Theme["Color Text"], BackgroundTransparency = 1, Font = Enum.Font.GothamMedium, Name = "Title" }, { InsertTheme(Create("TextLabel", { Size = UDim2.fromScale(0, 1), AutomaticSize = "X", AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(1, 5, 0.9), Text = WMiniText, TextColor3 = Theme["Color Dark Text"], BackgroundTransparency = 1, TextXAlignment = "Left", TextYAlignment = "Bottom", TextSize = 8, Font = Enum.Font.Gotham, Name = "SubTitle" }), "DarkText") }), "Text")
        MinimizedContainer = Create("Frame", TopBar, { Size = UDim2.new(0, 0, 0, 28), Position = UDim2.new(0, 15, 0.5), AnchorPoint = Vector2.new(0, 0.5), BackgroundTransparency = 1, Visible = false, Name = "MinimizedContainer" })
        MinimizedIcon = Create("ImageLabel", MinimizedContainer, { Size = UDim2.new(0, 20, 0, 20), Position = UDim2.new(0, 0, 0.5), AnchorPoint = Vector2.new(0, 0.5), BackgroundTransparency = 1, Image = "rbxassetid://97269958324726", ImageColor3 = Theme["Color Text"], Name = "MinimizedIcon" })
        MinimizedTitle = InsertTheme(Create("TextLabel", MinimizedContainer, { Size = UDim2.new(0, 0, 0, 20), Position = UDim2.new(0, 25, 0.5), AnchorPoint = Vector2.new(0, 0.5), BackgroundTransparency = 1, Font = Enum.Font.GothamMedium, Text = WTitle, TextColor3 = Theme["Color Text"], TextSize = 12, TextXAlignment = "Left", AutomaticSize = "X", Name = "MinimizedTitle" }), "Text")

        local MainScroll = InsertTheme(Create("ScrollingFrame", Components, { Size = UDim2.new(0, bearlib.Save.TabSize, 1, -TopBar.Size.Y.Offset), ScrollBarImageColor3 = Theme["Color Theme"], Position = UDim2.new(0, 0, 1, 0), AnchorPoint = Vector2.new(0, 1), ScrollBarThickness = 1.5, BackgroundTransparency = 1, ScrollBarImageTransparency = 0.2, CanvasSize = UDim2.new(), AutomaticCanvasSize = "Y", ScrollingDirection = "Y", BorderSizePixel = 0, Name = "Tab Scroll" }, { Create("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10), PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10) }), Create("UIListLayout", { Padding = UDim.new(0, 5) }) }), "ScrollBar")
        local Containers = Create("Frame", Components, { Size = UDim2.new(1, -MainScroll.Size.X.Offset, 1, -TopBar.Size.Y.Offset), AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, ClipsDescendants = true, Name = "Containers" })
        local SearchContainer = InsertTheme(Create("ScrollingFrame", Components, { Size = UDim2.new(1, -MainScroll.Size.X.Offset, 1, -TopBar.Size.Y.Offset), AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Visible = false, ScrollBarThickness = 1.5, ScrollBarImageTransparency = 0.2, ScrollBarImageColor3 = Theme["Color Theme"], AutomaticCanvasSize = "Y", ScrollingDirection = "Y", BorderSizePixel = 0, Name = "SearchContainer" }, { Create("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10), PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10) }), Create("UIListLayout", { SortOrder = "LayoutOrder", Padding = UDim.new(0, 5) }) }), "ScrollBar")

        local ControlSize1, ControlSize2 = MakeDrag(Create("ImageButton", MainFrame, { Size = UDim2.new(0, 35, 0, 35), Position = MainFrame.Size, Active = true, AnchorPoint = Vector2.new(0.8, 0.8), BackgroundTransparency = 1, Name = "Control Hub Size" })), MakeDrag(Create("ImageButton", MainFrame, { Size = UDim2.new(0, 20, 1, -30), Position = UDim2.new(0, MainScroll.Size.X.Offset, 1, 0), AnchorPoint = Vector2.new(0.5, 1), Active = true, BackgroundTransparency = 1, Name = "Control Tab Size" }))
        local function ControlSize()
            local Pos1, Pos2 = ControlSize1.Position, ControlSize2.Position
            ControlSize1.Position = UDim2.fromOffset(math.clamp(Pos1.X.Offset, 430, 1000), math.clamp(Pos1.Y.Offset, 200, 500))
            ControlSize2.Position = UDim2.new(0, math.clamp(Pos2.X.Offset, 135, 250), 1, 0)
            MainScroll.Size = UDim2.new(0, ControlSize2.Position.X.Offset, 1, -TopBar.Size.Y.Offset)
            Containers.Size = UDim2.new(1, -MainScroll.Size.X.Offset, 1, -TopBar.Size.Y.Offset)
            SearchContainer.Size = Containers.Size
            MainFrame.Size = ControlSize1.Position
        end
        ControlSize1:GetPropertyChangedSignal("Position"):Connect(ControlSize)
        ControlSize2:GetPropertyChangedSignal("Position"):Connect(ControlSize)
        ConnectSave(ControlSize1, function() if not Minimized then bearlib.Save.UISize = {MainFrame.Size.X.Offset, MainFrame.Size.Y.Offset}; SaveJson("bear library v8.1.json", bearlib.Save) end end)
        ConnectSave(ControlSize2, function() bearlib.Save.TabSize = MainScroll.Size.X.Offset; SaveJson("bear library v8.1.json", bearlib.Save) end)

        local ButtonsFolder = Create("Folder", TopBar, { Name = "Buttons" })
        local CloseButton = Create("ImageButton", { Size = UDim2.new(0, 14, 0, 14), Position = UDim2.new(1, -10, 0.5), AnchorPoint = Vector2.new(1, 0.5), BackgroundTransparency = 1, Image = "rbxassetid://10747384394", AutoButtonColor = false, Name = "Close" })
        MinimizeButton = Create("ImageButton", { Size = UDim2.new(0, 14, 0, 14), Position = UDim2.new(1, -35, 0.5), AnchorPoint = Vector2.new(1, 0.5), BackgroundTransparency = 1, Image = "rbxassetid://97269958324726", ImageColor3 = Theme["Color Text"], AutoButtonColor = false, Name = "Minimize" })
        SearchButton = Create("ImageButton", { Size = UDim2.new(0, 14, 0, 14), Position = UDim2.new(1, -60, 0.5), AnchorPoint = Vector2.new(1, 0.5), BackgroundTransparency = 1, Image = "rbxassetid://10734943674", ImageColor3 = Theme["Color Text"], Name = "Search" })
        SetChildren(ButtonsFolder, { CloseButton, MinimizeButton, SearchButton })
        local SearchInputFrame = InsertTheme(Create("Frame", TopBar, { Size = UDim2.new(0, 0, 0, 22), Position = UDim2.new(1, -85, 0.5), AnchorPoint = Vector2.new(1, 0.5), BackgroundColor3 = Theme["Color Hub 2"], ClipsDescendants = true }), "Frame")
        Make("Corner", SearchInputFrame, UDim.new(0, 4)); Make("Stroke", SearchInputFrame)
        local SearchInput = InsertTheme(Create("TextBox", SearchInputFrame, { Size = UDim2.new(1, -5, 1, 0), Position = UDim2.new(0, 5, 0, 0), BackgroundTransparency = 1, Font = Enum.Font.Gotham, PlaceholderText = "Search...", TextColor3 = Theme["Color Text"], TextSize = 10, TextXAlignment = "Left", Text = "" }), "Text")
        local SearchActive = false
        local function UpdateSearch(Query)
            Query = string.lower(Query)
            for _, ElementData in pairs(bearlib.AllElements) do
                if ElementData.Instance and ElementData.OriginalParent then
                    if ElementData.Instance.Parent == SearchContainer then
                        ElementData.Instance.Parent = ElementData.OriginalParent
                        ElementData.Instance.Visible = true
                    end
                end
            end
            if Query == "" then return end
            for _, ElementData in pairs(bearlib.AllElements) do
                local Name = string.lower(ElementData.Name)
                if string.find(Name, Query) and ElementData.Instance then
                    ElementData.Instance.Parent = SearchContainer
                    ElementData.Instance.Visible = true
                end
            end
        end
        SearchButton.Activated:Connect(function()
            SearchActive = not SearchActive
            if SearchActive then
                CreateTween({SearchInputFrame, "Size", UDim2.new(0, 120, 0, 22), 0.3})
                SearchContainer.Visible = true
                Containers.Visible = false
                SearchInput:CaptureFocus()
            else
                CreateTween({SearchInputFrame, "Size", UDim2.new(0, 0, 0, 22), 0.3})
                SearchInput.Text = ""
                UpdateSearch("")
                SearchContainer.Visible = false
                Containers.Visible = true
            end
        end)
        SearchInput:GetPropertyChangedSignal("Text"):Connect(function() if SearchActive then UpdateSearch(SearchInput.Text) end end)

        local Minimized, SaveSize, WaitClick
        local Window, FirstTab = {}, false
        local function UpdateMinimizeState()
            if Minimized then
                Title.Visible = false; if Title.SubTitle then Title.SubTitle.Visible = false end
                MinimizedContainer.Size = UDim2.new(0, 25 + MinimizedTitle.TextBounds.X + 5, 0, 28)
                MinimizedContainer.Visible = true
                MinimizedIcon.ImageColor3 = Theme["Color Text"]
                MinimizedTitle.TextColor3 = Theme["Color Text"]
            else
                MinimizedContainer.Visible = false
                Title.Visible = true; if Title.SubTitle then Title.SubTitle.Visible = true end
            end
        end
        MinimizedTitle:GetPropertyChangedSignal("TextBounds"):Connect(function() if Minimized and MinimizedContainer.Visible then MinimizedContainer.Size = UDim2.new(0, 25 + MinimizedTitle.TextBounds.X + 5, 0, 28) end end)

        function Window:CloseBtn()
            local Dialog = Window:Dialog({ Title = "Window", Text = "Tutup Window manis ?", Options = { {"Tutup", function() ScreenGui:Destroy(); if ToggleGui then ToggleGui:Destroy() end }, {"Batal"} } })
        end
        function Window:MinimizeBtn()
            if WaitClick then return end
            WaitClick = true
            if Minimized then
                MinimizeButton.Image = "rbxassetid://97269958324726"
                CreateTween({MainFrame, "Size", SaveSize, 0.25, true})
                ControlSize1.Visible = true; ControlSize2.Visible = true
                Minimized = false
            else
                MinimizeButton.Image = "rbxassetid://10734924532"
                SaveSize = MainFrame.Size
                ControlSize1.Visible = false; ControlSize2.Visible = false
                CreateTween({MainFrame, "Size", UDim2.fromOffset(MainFrame.Size.X.Offset, 28), 0.25, true})
                Minimized = true
            end
            UpdateMinimizeState()
            WaitClick = false
        end
        function Window:Minimize() MainFrame.Visible = not MainFrame.Visible end
        function Window:AddMinimizeButton(Configs) end -- simplified
        function Window:Set(Val1, Val2)
            if type(Val1) == "string" and type(Val2) == "string" then
                Title.Text = Val1; Title.SubTitle.Text = Val2; MinimizedTitle.Text = Val1
            elseif type(Val1) == "string" then
                Title.Text = Val1; MinimizedTitle.Text = Val1
            end
        end
        function Window:Dialog(Configs)
            if MainFrame:FindFirstChild("Dialog") then return end
            if Minimized then Window:MinimizeBtn() end
            local DTitle = Configs[1] or Configs.Title or "Dialog"
            local DText = Configs[2] or Configs.Text or "This is a Dialog"
            local DOptions = Configs[3] or Configs.Options or {}
            local Frame = Create("Frame", { Active = true, Size = UDim2.fromOffset(250 * 1.08, 150 * 1.08), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), ZIndex = 200 }, {
                InsertTheme(Create("TextLabel", { Font = Enum.Font.GothamBold, Size = UDim2.new(1, 0, 0, 20), Text = DTitle, TextXAlignment = "Left", TextColor3 = Theme["Color Text"], TextSize = 15, Position = UDim2.fromOffset(15, 5), BackgroundTransparency = 1, ZIndex = 201 }), "Text"),
                InsertTheme(Create("TextLabel", { Font = Enum.Font.GothamMedium, Size = UDim2.new(1, -25), AutomaticSize = "Y", Text = DText, TextXAlignment = "Left", TextColor3 = Theme["Color Dark Text"], TextSize = 12, Position = UDim2.fromOffset(15, 25), BackgroundTransparency = 1, TextWrapped = true, ZIndex = 201 }), "DarkText")
            })
            Make("Gradient", Frame, {Rotation = 270}); Make("Corner", Frame)
            local ButtonsHolder = Create("Frame", Frame, { Size = UDim2.fromScale(1, 0.35), Position = UDim2.fromScale(0, 1), AnchorPoint = Vector2.new(0, 1), BackgroundColor3 = Theme["Color Hub 2"], BackgroundTransparency = 1, ZIndex = 201 }, { Create("UIListLayout", { Padding = UDim.new(0, 10), VerticalAlignment = "Center", FillDirection = "Horizontal", HorizontalAlignment = "Center" }) })
            local Screen = InsertTheme(Create("Frame", MainFrame, { BackgroundTransparency = 0.6, Active = true, Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Theme["Color Stroke"], Name = "Dialog", ZIndex = 150 }), "Stroke")
            MainCorner:Clone().Parent = Screen
            Frame.Parent = Screen
            for _, child in pairs(Frame:GetDescendants()) do if child:IsA("TextLabel") or child:IsA("TextButton") or child:IsA("Frame") then child.ZIndex = math.max(child.ZIndex or 1, 200) end end
            CreateTween({Frame, "Size", UDim2.fromOffset(250, 150), 0.2}); CreateTween({Frame, "Transparency", 0, 0.15}); CreateTween({Screen, "Transparency", 0.3, 0.15})
            local ButtonCount, Dialog = 1, {}
            function Dialog:Button(Configs)
                local Name = Configs[1] or Configs.Name or Configs.Title or ""
                local Callback = Configs[2] or Configs.Callback or function() end
                ButtonCount = ButtonCount + 1
                local Button = Make("Button", ButtonsHolder); Make("Corner", Button)
                SetProps(Button, { Text = Name, Font = Enum.Font.GothamBold, TextColor3 = Theme["Color Text"], TextSize = 12, ZIndex = 202 })
                for _,Btn in pairs(ButtonsHolder:GetChildren()) do if Btn:IsA("TextButton") then Btn.Size = UDim2.new(1 / ButtonCount, -(((ButtonCount - 1) * 20) / ButtonCount), 0, 32); Btn.ZIndex = 202 end end
                Button.Activated:Connect(Dialog.Close); Button.Activated:Connect(Callback)
            end
            function Dialog:Close()
                CreateTween({Frame, "Size", UDim2.fromOffset(250 * 1.08, 150 * 1.08), 0.2}); CreateTween({Screen, "Transparency", 1, 0.15}); CreateTween({Frame, "Transparency", 1, 0.15, true}); Screen:Destroy()
            end
            for _,Button in pairs(DOptions) do Dialog:Button(Button) end
            return Dialog
        end
        function Window:SelectTab(TabSelect)
            if type(TabSelect) == "number" then bearlib.Tabs[TabSelect].func:Enable()
            else for _,Tab in pairs(bearlib.Tabs) do if Tab.Cont == TabSelect.Cont then Tab.func:Enable() end end end
        end

        local ContainerList = {}
        function Window:MakeTab(paste, Configs)
            if type(paste) == "table" then Configs = paste end
            local TName = Configs[1] or Configs.Title or "Tab!"
            local TIcon = Configs[2] or Configs.Icon or ""
            TIcon = bearlib:GetIcon(TIcon)
            if not TIcon:find("rbxassetid://") or TIcon:gsub("rbxassetid://", ""):len() < 6 then TIcon = false end
            local TabSelect = Make("Button", MainScroll, { Size = UDim2.new(1, 0, 0, 24) }); Make("Corner", TabSelect)
            local LabelTitle = InsertTheme(Create("TextLabel", TabSelect, { Size = UDim2.new(1, TIcon and -25 or -15, 1), Position = UDim2.fromOffset(TIcon and 25 or 15), BackgroundTransparency = 1, Font = Enum.Font.GothamMedium, Text = TName, TextColor3 = Theme["Color Text"], TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left, TextTransparency = (FirstTab and 0.3) or 0, TextTruncate = "AtEnd", ZIndex = 5 }), "Text")
            local LabelIcon = InsertTheme(Create("ImageLabel", TabSelect, { Position = UDim2.new(0, 8, 0.5), Size = UDim2.new(0, 13, 0, 13), AnchorPoint = Vector2.new(0, 0.5), Image = TIcon or "", BackgroundTransparency = 1, ImageTransparency = (FirstTab and 0.3) or 0, ImageColor3 = Theme["Color Text"], ZIndex = 5 }), "Text")
            local Selected = InsertTheme(Create("Frame", TabSelect, { Size = FirstTab and UDim2.new(0, 4, 0, 4) or UDim2.new(0, 4, 0, 13), Position = UDim2.new(0, 1, 0.5), AnchorPoint = Vector2.new(0, 0.5), BackgroundColor3 = Theme["Color Theme"], BackgroundTransparency = FirstTab and 1 or 0, ZIndex = 4 }), "Theme"); Make("Corner", Selected, UDim.new(0.5, 0))
            local Container = InsertTheme(Create("ScrollingFrame", { Size = UDim2.new(1, 0, 1, 0), Position = UDim2.new(0, 0, 1), AnchorPoint = Vector2.new(0, 1), ScrollBarThickness = 1.5, BackgroundTransparency = 1, ScrollBarImageTransparency = 0.2, ScrollBarImageColor3 = Theme["Color Theme"], AutomaticCanvasSize = "Y", ScrollingDirection = "Y", BorderSizePixel = 0, CanvasSize = UDim2.new(), Name = ("Container %i [ %s ]"):format(#ContainerList + 1, TName), ZIndex = 1 }, { Create("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10), PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10) }), Create("UIListLayout", { Padding = UDim.new(0, 5), SortOrder = "LayoutOrder" }) }), "ScrollBar")
            table.insert(ContainerList, Container)
            if not FirstTab then Container.Parent = Containers end
            local function Tabs()
                if Container.Parent then return end
                for _,Frame in pairs(ContainerList) do if Frame:IsA("ScrollingFrame") and Frame ~= Container then Frame.Parent = nil end end
                Container.Parent = Containers
                Container.Size = UDim2.new(1, 0, 1, 150)
                for _,Tab in pairs(bearlib.Tabs) do if Tab.Cont ~= Container then Tab.func:Disable() end end
                CreateTween({Container, "Size", UDim2.new(1, 0, 1, 0), 0.3}); CreateTween({LabelTitle, "TextTransparency", 0, 0.35}); CreateTween({LabelIcon, "ImageTransparency", 0, 0.35}); CreateTween({Selected, "Size", UDim2.new(0, 4, 0, 13), 0.35}); CreateTween({Selected, "BackgroundTransparency", 0, 0.35})
            end
            TabSelect.Activated:Connect(Tabs)
            FirstTab = true
            local Tab = {}
            table.insert(bearlib.Tabs, {TabInfo = {Name = TName, Icon = TIcon}, func = Tab, Cont = Container})
            Tab.Cont = Container
            local ElementCount = 0
            local function GetOrder() ElementCount = ElementCount + 1; return ElementCount end
            function Tab:Disable()
                Container.Parent = nil
                CreateTween({LabelTitle, "TextTransparency", 0.3, 0.35}); CreateTween({LabelIcon, "ImageTransparency", 0.3, 0.35}); CreateTween({Selected, "Size", UDim2.new(0, 4, 0, 4), 0.35}); CreateTween({Selected, "BackgroundTransparency", 1, 0.35})
            end
            function Tab:Enable() Tabs() end
            function Tab:Visible(Bool) Funcs:ToggleVisible(TabSelect, Bool) end
            function Tab:Destroy() TabSelect:Destroy(); Container:Destroy() end

            local CurrentSectionName = nil
            function Tab:AddSection(Configs)
                local SectionName = type(Configs) == "string" and Configs or Configs[1] or Configs.Name or Configs.Title or Configs.Section
                CurrentSectionName = SectionName
                local SectionFrame = Create("Frame", Container, { Size = UDim2.new(1, 0, 0, 30), BackgroundTransparency = 1, Name = "Option", LayoutOrder = GetOrder(), ZIndex = 2 })
                local SectionLabel = InsertTheme(Create("TextLabel", SectionFrame, { Font = Enum.Font.GothamBold, Text = SectionName, TextColor3 = Theme["Color Text"], Size = UDim2.new(1, -25, 0, 18), Position = UDim2.new(0, 5, 0, 0), BackgroundTransparency = 1, TextTruncate = "AtEnd", TextSize = 14, TextXAlignment = "Left", ZIndex = 3 }), "Text")
                local UnderlineFrame = Create("Frame", SectionFrame, { Size = UDim2.new(1, -10, 0, 1.5), Position = UDim2.new(0, 5, 1, -5), BackgroundColor3 = Theme["UI Border Color"], BackgroundTransparency = 0, BorderSizePixel = 0, ZIndex = 2 })
                table.insert(bearlib.Instances, { Instance = UnderlineFrame, Type = "UIBorder" })
                local UnderlineGradient = Instance.new("UIGradient"); UnderlineGradient.Rotation = 90; UnderlineGradient.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0.00, Theme["UI Border Color"]), ColorSequenceKeypoint.new(0.50, Theme["Color Theme"]), ColorSequenceKeypoint.new(1.00, Theme["UI Border Color"]) }); UnderlineGradient.Parent = UnderlineFrame
                table.insert(bearlib.Instances, { Instance = UnderlineGradient, Type = "Gradient" })
                table.insert(bearlib.AllElements, { Name = SectionName, Instance = SectionFrame, OriginalParent = Container, SectionName = SectionName, Underline = UnderlineFrame, UnderlineGradient = UnderlineGradient })
                local Section = {}
                table.insert(bearlib.Options, {type = "Section", Name = SectionName, func = Section})
                function Section:Visible(Bool) if Bool == nil then SectionFrame.Visible = not SectionFrame.Visible else SectionFrame.Visible = Bool end end
                function Section:Destroy() SectionFrame:Destroy() end
                function Section:Set(New) if New then SectionLabel.Text = GetStr(New) end end
                return Section
            end
            function Tab:AddParagraph(Configs) end
            function Tab:AddButton(Configs)
                local BName = Configs[1] or Configs.Name or Configs.Title or "Button!"
                local BDescription = Configs.Desc or Configs.Description or ""
                local Callback = Funcs:GetCallback(Configs, 2)
                local FButton, LabelFunc = ButtonFrame(Container, BName, BDescription, UDim2.new(1, -20))
                FButton.LayoutOrder = GetOrder()
                local ButtonIcon = Create("ImageLabel", FButton, { Size = UDim2.new(0, 14, 0, 14), Position = UDim2.new(1, -10, 0.5), AnchorPoint = Vector2.new(1, 0.5), BackgroundTransparency = 1, Image = "rbxassetid://10709791437", ZIndex = 5 })
                FButton.Activated:Connect(function() Funcs:FireCallback(Callback) end)
                table.insert(bearlib.AllElements, { Name = BName, Instance = FButton, OriginalParent = Container, SectionName = CurrentSectionName })
                local Button = {}
                function Button:Visible(...) Funcs:ToggleVisible(FButton, ...) end
                function Button:Destroy() FButton:Destroy() end
                function Button:Callback(...) Funcs:InsertCallback(Callback, ...)() end
                function Button:Set(Val1, Val2)
                    if type(Val1) == "string" and type(Val2) == "string" then LabelFunc:SetTitle(Val1); LabelFunc:SetDesc(Val2)
                    elseif type(Val1) == "string" then LabelFunc:SetTitle(Val1)
                    elseif type(Val1) == "function" then Callback = Val1 end
                end
                return Button
            end
            function Tab:AddToggle(Configs)
                local TName = Configs[1] or Configs.Name or Configs.Title or "Toggle"
                local TDesc = Configs.Desc or Configs.Description or ""
                local Callback = Funcs:GetCallback(Configs, 3)
                local Flag = Configs[4] or Configs.Flag or false
                local Default = Configs[2] or Configs.Default or false
                if CheckFlag(Flag) then Default = GetFlag(Flag) end
                local Button, LabelFunc = ButtonFrame(Container, TName, TDesc, UDim2.new(1, -38))
                Button.LayoutOrder = GetOrder()
                local ToggleHolder = InsertTheme(Create("Frame", Button, { Size = UDim2.new(0, 35, 0, 18), Position = UDim2.new(1, -10, 0.5), AnchorPoint = Vector2.new(1, 0.5), BackgroundColor3 = Theme["Color Toggle Off"], ZIndex = 4 }), "Stroke")
                Make("Corner", ToggleHolder, UDim.new(0.5, 0))
                local Slider = Create("Frame", ToggleHolder, { BackgroundTransparency = 1, Size = UDim2.new(0.8, 0, 0.8, 0), Position = UDim2.new(0.5, 0, 0.5, 0), AnchorPoint = Vector2.new(0.5, 0.5), ZIndex = 4 })
                local Toggle = InsertTheme(Create("Frame", Slider, { Size = UDim2.new(0, 12, 0, 12), Position = UDim2.new(0, 0, 0.5), AnchorPoint = Vector2.new(0, 0.5), BackgroundColor3 = Theme["Color Toggle Knob Off"], ZIndex = 5 }), "Theme")
                Make("Corner", Toggle, UDim.new(0.5, 0))
                local WaitClick
                local function SetToggle(Val)
                    if WaitClick then return end
                    WaitClick, Default = true, Val
                    SetFlag(Flag, Default)
                    Funcs:FireCallback(Callback, Default)
                    if Default then
                        CreateTween({Toggle, "Position", UDim2.new(1, 0, 0.5), 0.25}); CreateTween({Toggle, "BackgroundColor3", Theme["Color Toggle Knob On"], 0.25}); CreateTween({Toggle, "AnchorPoint", Vector2.new(1, 0.5), 0.25}); CreateTween({ToggleHolder, "BackgroundColor3", Theme["Color Toggle On"], 0.25})
                    else
                        CreateTween({Toggle, "Position", UDim2.new(0, 0, 0.5), 0.25}); CreateTween({Toggle, "BackgroundColor3", Theme["Color Toggle Knob Off"], 0.25}); CreateTween({Toggle, "AnchorPoint", Vector2.new(0, 0.5), 0.25}); CreateTween({ToggleHolder, "BackgroundColor3", Theme["Color Toggle Off"], 0.25})
                    end
                    WaitClick = false
                end
                task.spawn(SetToggle, Default)
                Button.Activated:Connect(function() SetToggle(not Default) end)
                table.insert(bearlib.AllElements, { Name = TName, Instance = Button, OriginalParent = Container, SectionName = CurrentSectionName })
                local Toggle = {}
                function Toggle:Visible(...) Funcs:ToggleVisible(Button, ...) end
                function Toggle:Destroy() Button:Destroy() end
                function Toggle:Callback(...) Funcs:InsertCallback(Callback, ...)() end
                function Toggle:Set(Val1, Val2)
                    if type(Val1) == "string" and type(Val2) == "string" then LabelFunc:SetTitle(Val1); LabelFunc:SetDesc(Val2)
                    elseif type(Val1) == "string" then LabelFunc:SetTitle(Val1)
                    elseif type(Val1) == "boolean" then
                        if WaitClick and Val2 then repeat task.wait() until not WaitClick end
                        task.spawn(SetToggle, Val1)
                    elseif type(Val1) == "function" then Callback = Val1 end
                end
                return Toggle
            end
            function Tab:AddDropdown(Configs)
                local DName = Configs[1] or Configs.Name or Configs.Title or "Dropdown"
                local DDesc = Configs.Desc or Configs.Description or ""
                local DOptions = Configs[2] or Configs.Options or {}
                local OpDefault = Configs[3] or Configs.Default or {}
                local Flag = Configs[5] or Configs.Flag or false
                local DMultiSelect = Configs.MultiSelect or false
                local Callback = Funcs:GetCallback(Configs, 4)
                local Button, LabelFunc = ButtonFrame(Container, DName, DDesc, UDim2.new(1, -180))
                Button.LayoutOrder = GetOrder()
                local SelectedFrame = InsertTheme(Create("Frame", Button, { Size = UDim2.new(0, 150, 0, 18), Position = UDim2.new(1, -10, 0.5), AnchorPoint = Vector2.new(1, 0.5), BackgroundColor3 = Theme["Color Stroke"], ZIndex = 4 }), "Stroke"); Make("Corner", SelectedFrame, UDim.new(0, 4))
                local ActiveLabel = InsertTheme(Create("TextLabel", SelectedFrame, { Size = UDim2.new(0.85, 0, 0.85, 0), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 0), BackgroundTransparency = 1, Font = Enum.Font.GothamBold, TextScaled = true, TextColor3 = Theme["Color Text"], Text = "...", ZIndex = 5 }), "Text")
                local Arrow = Create("ImageLabel", SelectedFrame, { Size = UDim2.new(0, 15, 0, 15), Position = UDim2.new(0, -5, 0.5), AnchorPoint = Vector2.new(1, 0.5), Image = "rbxassetid://10709791523", BackgroundTransparency = 1, ZIndex = 5 })
                local NoClickFrame = Create("TextButton", DropdownHolder, { Name = "AntiClick", Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Visible = false, Text = "" })
                local DropFrame = Create("Frame", NoClickFrame, { Size = UDim2.new(SelectedFrame.Size.X, 0, 0), BackgroundTransparency = 0.1, BackgroundColor3 = Color3.fromRGB(255, 255, 255), AnchorPoint = Vector2.new(0, 1), Name = "DropdownFrame", ClipsDescendants = true, Active = true, ZIndex = 5 }); Make("Corner", DropFrame); Make("Stroke", DropFrame); Make("Gradient", DropFrame, {Rotation = 60})
                local ScrollFrame = InsertTheme(Create("ScrollingFrame", DropFrame, { ScrollBarImageColor3 = Theme["Color Theme"], Size = UDim2.new(1, 0, 1, 0), ScrollBarThickness = 1.5, BackgroundTransparency = 1, BorderSizePixel = 0, CanvasSize = UDim2.new(), ScrollingDirection = "Y", AutomaticCanvasSize = "Y", Active = true, ZIndex = 6 }, { Create("UIPadding", { PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8), PaddingTop = UDim.new(0, 5), PaddingBottom = UDim.new(0, 5) }), Create("UIListLayout", { Padding = UDim.new(0, 4) }) }), "ScrollBar")
                local ScrollSize, WaitClick = 5, nil
                local function Disable()
                    WaitClick = true
                    CreateTween({Arrow, "Rotation", 0, 0.2}); CreateTween({DropFrame, "Size", UDim2.new(0, 152, 0, 0), 0.2, true}); CreateTween({Arrow, "ImageColor3", Color3.fromRGB(255, 255, 255), 0.2}); Arrow.Image = "rbxassetid://10709791523"; NoClickFrame.Visible = false; WaitClick = false
                end
                local function GetFrameSize() return UDim2.fromOffset(152, ScrollSize) end
                local function CalculateSize()
                    local Count = 0
                    for _,Frame in pairs(ScrollFrame:GetChildren()) do if Frame:IsA("Frame") or Frame.Name == "Option" then Count = Count + 1 end end
                    ScrollSize = (math.clamp(Count, 0, 10) * 25) + 10
                    if NoClickFrame.Visible then NoClickFrame.Visible = true; CreateTween({DropFrame, "Size", GetFrameSize(), 0.2, true}) end
                end
                local function Minimize()
                    if WaitClick then return end
                    WaitClick = true
                    if NoClickFrame.Visible then
                        Arrow.Image = "rbxassetid://97269958324726"
                        CreateTween({Arrow, "ImageColor3", Color3.fromRGB(255, 255, 255), 0.2}); CreateTween({DropFrame, "Size", UDim2.new(0, 152, 0, 0), 0.2, true}); NoClickFrame.Visible = false
                    else
                        NoClickFrame.Visible = true
                        Arrow.Image = "rbxassetid://10709790948"
                        CreateTween({Arrow, "ImageColor3", Theme["Color Theme"], 0.2}); CreateTween({DropFrame, "Size", GetFrameSize(), 0.2, true})
                    end
                    WaitClick = false
                end
                local function CalculatePos()
                    local FramePos = SelectedFrame.AbsolutePosition
                    local ScreenSize = ScreenGui.AbsoluteSize
                    local ClampX = math.clamp((FramePos.X / UIScale), 0, ScreenSize.X / UIScale - DropFrame.Size.X.Offset)
                    local ClampY = math.clamp((FramePos.Y / UIScale) , 0, ScreenSize.Y / UIScale)
                    local NewPos = UDim2.fromOffset(ClampX, ClampY)
                    local AnchorPoint = FramePos.Y > ScreenSize.Y / 1.4 and 1 or ScrollSize > 80 and 0.5 or 0
                    DropFrame.AnchorPoint = Vector2.new(0, AnchorPoint)
                    CreateTween({DropFrame, "Position", NewPos, 0.1})
                end
                local AddNewOptions, GetOptions, AddOption, RemoveOption, Selected
                do
                    local Default = type(OpDefault) ~= "table" and {OpDefault} or OpDefault
                    local MultiSelect = DMultiSelect
                    local Options = {}
                    Selected = MultiSelect and {} or CheckFlag(Flag) and GetFlag(Flag) or Default[1]
                    if MultiSelect then
                        for index, Value in pairs(CheckFlag(Flag) and GetFlag(Flag) or Default) do
                            if type(index) == "string" and (DOptions[index] or table.find(DOptions, index)) then Selected[index] = Value
                            elseif DOptions[Value] then Selected[Value] = true end
                        end
                    end
                    local function CallbackSelected()
                        SetFlag(Flag, MultiSelect and Selected or tostring(Selected))
                        Funcs:FireCallback(Callback, Selected)
                    end
                    local function UpdateLabel()
                        if MultiSelect then
                            local list = {}
                            for index, Value in pairs(Selected) do if Value then table.insert(list, index) end end
                            ActiveLabel.Text = #list > 0 and table.concat(list, ", ") or "..."
                        else
                            ActiveLabel.Text = tostring(Selected or "...")
                        end
                    end
                    local function UpdateSelected()
                        if MultiSelect then
                            for _,v in pairs(Options) do
                                local nodes, Stats = v.nodes, v.Stats
                                CreateTween({nodes[2], "BackgroundTransparency", Stats and 0 or 0.8, 0.35}); CreateTween({nodes[2], "Size", Stats and UDim2.fromOffset(4, 12) or UDim2.fromOffset(4, 4), 0.35}); CreateTween({nodes[3], "TextTransparency", Stats and 0 or 0.4, 0.35})
                            end
                        else
                            for _,v in pairs(Options) do
                                local Slt = v.Value == Selected
                                local nodes = v.nodes
                                CreateTween({nodes[2], "BackgroundTransparency", Slt and 0 or 1, 0.35}); CreateTween({nodes[2], "Size", Slt and UDim2.fromOffset(4, 14) or UDim2.fromOffset(4, 4), 0.35}); CreateTween({nodes[3], "TextTransparency", Slt and 0 or 0.4, 0.35})
                            end
                        end
                        UpdateLabel()
                    end
                    local function Select(Option)
                        if MultiSelect then
                            Option.Stats = not Option.Stats; Option.LastCB = tick()
                            Selected[Option.Name] = Option.Stats; CallbackSelected()
                        else
                            Option.LastCB = tick()
                            Selected = Option.Value; CallbackSelected()
                        end
                        UpdateSelected()
                    end
                    AddOption = function(index, Value)
                        local Name = tostring(type(index) == "string" and index or Value)
                        if Options[Name] then return end
                        Options[Name] = { index = index, Value = Value, Name = Name, Stats = false, LastCB = 0 }
                        if MultiSelect then
                            local Stats = Selected[Name]; Selected[Name] = Stats or false; Options[Name].Stats = Stats
                        end
                        local Button = Make("Button", ScrollFrame, { Name = "Option", Size = UDim2.new(1, 0, 0, 21), Position = UDim2.new(0, 0, 0.5), AnchorPoint = Vector2.new(0, 0.5), ZIndex = 7 }); Make("Corner", Button, UDim.new(0, 4))
                        local IsSelected = InsertTheme(Create("Frame", Button, { Position = UDim2.new(0, 1, 0.5), Size = UDim2.new(0, 4, 0, 4), BackgroundColor3 = Theme["Color Theme"], BackgroundTransparency = 1, AnchorPoint = Vector2.new(0, 0.5), ZIndex = 8 }), "Theme"); Make("Corner", IsSelected, UDim.new(0.5, 0))
                        local OptioneName = InsertTheme(Create("TextLabel", Button, { Size = UDim2.new(1, 0, 1), Position = UDim2.new(0, 10), Text = Name, TextColor3 = Theme["Color Text"], Font = Enum.Font.GothamBold, TextXAlignment = "Left", BackgroundTransparency = 1, TextTransparency = 0.4, ZIndex = 8, TextStrokeTransparency = 0.3, TextStrokeColor3 = Color3.fromRGB(0, 0, 0) }), "Text")
                        Button.Activated:Connect(function() Select(Options[Name]) end)
                        Options[Name].nodes = {Button, IsSelected, OptioneName}
                    end
                    RemoveOption = function(index, Value)
                        local Name = tostring(type(index) == "string" and index or Value)
                        if Options[Name] then
                            if MultiSelect then Selected[Name] = nil else Selected = nil end
                            Options[Name].nodes[1]:Destroy(); Options[Name] = nil
                        end
                    end
                    GetOptions = function() return Options end
                    AddNewOptions = function(List, Clear)
                        if Clear then for _, opt in pairs(Options) do RemoveOption(opt.index, opt.Value) end end
                        for _, opt in pairs(List) do AddOption(opt, opt) end
                        CallbackSelected(); UpdateSelected()
                    end
                    for _, opt in pairs(DOptions) do AddOption(opt, opt) end
                    CallbackSelected(); UpdateSelected()
                end
                Button.Activated:Connect(Minimize)
                NoClickFrame.MouseButton1Down:Connect(Disable); NoClickFrame.MouseButton1Click:Connect(Disable); MainFrame:GetPropertyChangedSignal("Visible"):Connect(Disable); SelectedFrame:GetPropertyChangedSignal("AbsolutePosition"):Connect(CalculatePos)
                Button.Activated:Connect(CalculateSize); ScrollFrame.ChildAdded:Connect(CalculateSize); ScrollFrame.ChildRemoved:Connect(CalculateSize); CalculatePos(); CalculateSize()
                table.insert(bearlib.AllElements, { Name = DName, Instance = Button, OriginalParent = Container, SectionName = CurrentSectionName })
                local Dropdown = {}
                function Dropdown:Visible(...) Funcs:ToggleVisible(Button, ...) end
                function Dropdown:Destroy() Button:Destroy() end
                function Dropdown:Callback(...) Funcs:InsertCallback(Callback, ...)(Selected) end
                function Dropdown:Add(...)
                    local NewOptions = {...}
                    if type(NewOptions[1]) == "table" then for _, Name in ipairs(NewOptions[1]) do AddOption(Name, Name) end
                    else for _, Name in ipairs(NewOptions) do AddOption(Name, Name) end end
                end
                function Dropdown:Remove(Option)
                    for index, Value in pairs(GetOptions()) do if type(Option) == "number" and index == Option or Value.Name == Option then RemoveOption(index, Value.Value) end end
                end
                function Dropdown:Select(Option)
                    if type(Option) == "string" then for _,Val in pairs(GetOptions()) do if Val.Name == Option then Select(Val) end end
                    elseif type(Option) == "number" then
                        local i = 0
                        for _,Val in pairs(GetOptions()) do i = i + 1; if i == Option then Select(Val) end end
                    end
                end
                function Dropdown:Set(Val1, Clear) if type(Val1) == "table" then AddNewOptions(Val1, Clear) elseif type(Val1) == "function" then Callback = Val1 end end
                return Dropdown
            end
            function Tab:AddSlider(Configs)
                local SName = Configs[1] or Configs.Name or Configs.Title or "Slider!"
                local SDesc = Configs.Desc or Configs.Description or ""
                local Min = Configs[2] or Configs.MinValue or Configs.Min or 10
                local Max = Configs[3] or Configs.MaxValue or Configs.Max or 100
                local Increase = Configs[4] or Configs.Increase or 1
                local Callback = Funcs:GetCallback(Configs, 6)
                local Flag = Configs[7] or Configs.Flag or false
                local Default = Configs[5] or Configs.Default or 25
                if CheckFlag(Flag) then Default = GetFlag(Flag) end
                Min, Max = Min / Increase, Max / Increase
                local Button, LabelFunc = ButtonFrame(Container, SName, SDesc, UDim2.new(1, -180))
                Button.LayoutOrder = GetOrder()
                local SliderHolder = Create("TextButton", Button, { Size = UDim2.new(0.45, 0, 1), Position = UDim2.new(1), AnchorPoint = Vector2.new(1, 0), AutoButtonColor = false, Text = "", BackgroundTransparency = 1, ZIndex = 4 })
                local SliderBar = InsertTheme(Create("Frame", SliderHolder, { BackgroundColor3 = Theme["Color Stroke"], Size = UDim2.new(1, -20, 0, 6), Position = UDim2.new(0.5, 0, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), ZIndex = 4 }), "Stroke"); Make("Corner", SliderBar)
                local Indicator = InsertTheme(Create("Frame", SliderBar, { BackgroundColor3 = Theme["Color Theme"], Size = UDim2.fromScale(0.3, 1), BorderSizePixel = 0, ZIndex = 5 }), "Theme"); Make("Corner", Indicator)
                local SliderIcon = Create("Frame", SliderBar, { Size = UDim2.new(0, 6, 0, 12), BackgroundColor3 = Color3.fromRGB(220, 220, 220), Position = UDim2.fromScale(0.3, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 0.2, ZIndex = 6 }); Make("Corner", SliderIcon)
                local LabelVal = InsertTheme(Create("TextLabel", SliderHolder, { Size = UDim2.new(0, 14, 0, 14), AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(0, 0, 0.5), BackgroundTransparency = 1, TextColor3 = Theme["Color Text"], Font = Enum.Font.FredokaOne, TextSize = 12, ZIndex = 5 }), "Text")
                local UIScaleObj = Create("UIScale", LabelVal)
                local BaseMousePos = Create("Frame", SliderBar, { Position = UDim2.new(0, 0, 0.5, 0), Visible = false })
                local function UpdateLabel(NewValue)
                    local Number = tonumber(NewValue * Increase)
                    Number = math.floor(Number * 100) / 100
                    Default, LabelVal.Text = Number, tostring(Number)
                    Funcs:FireCallback(Callback, Default)
                end
                local function ControlPos()
                    local MousePos = Player:GetMouse()
                    local APos = MousePos.X - BaseMousePos.AbsolutePosition.X
                    local ConfigureDpiPos = APos / SliderBar.AbsoluteSize.X
                    SliderIcon.Position = UDim2.new(math.clamp(ConfigureDpiPos, 0, 1), 0, 0.5, 0)
                end
                local function UpdateValues()
                    Indicator.Size = UDim2.new(SliderIcon.Position.X.Scale, 0, 1, 0)
                    local SliderPos = SliderIcon.Position.X.Scale
                    local NewValue = math.floor(((SliderPos * Max) / Max) * (Max - Min) + Min)
                    UpdateLabel(NewValue)
                end
                SliderHolder.MouseButton1Down:Connect(function()
                    CreateTween({SliderIcon, "BackgroundTransparency", 0, 0.3}); Container.ScrollingEnabled = false
                    while UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do task.wait(); ControlPos() end
                    CreateTween({SliderIcon, "BackgroundTransparency", 0.2, 0.3}); Container.ScrollingEnabled = true; SetFlag(Flag, Default)
                end)
                LabelVal:GetPropertyChangedSignal("Text"):Connect(function()
                    UIScaleObj.Scale = 0.3; CreateTween({UIScaleObj, "Scale", 1.2, 0.1}); CreateTween({LabelVal, "Rotation", math.random(-1, 1) * 5, 0.15, true}); CreateTween({UIScaleObj, "Scale", 1, 0.2}); CreateTween({LabelVal, "Rotation", 0, 0.1})
                end)
                function SetSlider(NewValue)
                    if type(NewValue) ~= "number" then return end
                    local MinVal, MaxVal = Min * Increase, Max * Increase
                    local SliderPos = (NewValue - MinVal) / (MaxVal - MinVal)
                    SetFlag(Flag, NewValue)
                    CreateTween({ SliderIcon, "Position", UDim2.fromScale(math.clamp(SliderPos, 0, 1), 0.5), 0.3, true })
                end
                SetSlider(Default)
                SliderIcon:GetPropertyChangedSignal("Position"):Connect(UpdateValues); UpdateValues()
                table.insert(bearlib.AllElements, { Name = SName, Instance = Button, OriginalParent = Container, SectionName = CurrentSectionName })
                local Slider = {}
                function Slider:Set(NewVal1, NewVal2)
                    if NewVal1 and NewVal2 then LabelFunc:SetTitle(NewVal1); LabelFunc:SetDesc(NewVal2)
                    elseif type(NewVal1) == "string" then LabelFunc:SetTitle(NewVal1)
                    elseif type(NewVal1) == "function" then Callback = NewVal1
                    elseif type(NewVal1) == "number" then SetSlider(NewVal1) end
                end
                function Slider:Callback(...) Funcs:InsertCallback(Callback, ...)(tonumber(Default)) end
                function Slider:Visible(...) Funcs:ToggleVisible(Button, ...) end
                function Slider:Destroy() Button:Destroy() end
                return Slider
            end
            function Tab:AddTextBox(Configs) end -- not used
            function Tab:AddDiscordInvite(Configs) end
            function Tab:AddSingleDiscordCard(Configs) end
            function Tab:AddProfile(Configs) end
            function Tab:AddDiscordInviteOld(Configs) end
            return Tab
        end

        CloseButton.Activated:Connect(Window.CloseBtn)
        MinimizeButton.Activated:Connect(Window.MinimizeBtn)

        task.spawn(function()
            task.wait(0.5)
            ToggleGui = Instance.new("ScreenGui"); ToggleGui.Name = "BearHub_Toggle_Circle"; ToggleGui.Parent = CoreGui
            ToggleButton = Instance.new("ImageButton"); ToggleButton.Name = "ToggleButton"; ToggleButton.Size = UDim2.new(0, 50, 0, 50); ToggleButton.Position = UDim2.new(0.12, 0, 0.12, 0); ToggleButton.Image = "rbxassetid://97269958324726"; ToggleButton.BackgroundColor3 = Theme["Color Hub 2"]; ToggleButton.BackgroundTransparency = 0.2; ToggleButton.Active = true; ToggleButton.Draggable = true; ToggleButton.Parent = ToggleGui
            local UICorner = Instance.new("UICorner"); UICorner.CornerRadius = UDim.new(1, 0); UICorner.Parent = ToggleButton
            ToggleButton.MouseButton1Click:Connect(function() Window:Minimize() end)
        end)
        return Window
    end

    local NotificationHolder, NotificationQueue, ActiveNotifications = nil, {}, {}
    local function CreateNotificationHolder()
        if NotificationHolder and NotificationHolder.Parent then return NotificationHolder end
        NotificationHolder = Instance.new("Frame"); NotificationHolder.Name = "NotificationHolder"; NotificationHolder.Size = UDim2.new(0, 340, 0, 0); NotificationHolder.Position = UDim2.new(1, -350, 1, -20); NotificationHolder.AnchorPoint = Vector2.new(0, 1); NotificationHolder.BackgroundTransparency = 1; NotificationHolder.Parent = ScreenGui; NotificationHolder.ZIndex = 1000
        Instance.new("UIListLayout", NotificationHolder).Padding = UDim.new(0, 10)
        return NotificationHolder
    end
    local function ProcessNotificationQueue()
        while #NotificationQueue > 0 do
            local nextNotification = table.remove(NotificationQueue, 1)
            -- simplified notification creation for brevity
        end
    end
    function bearlib:Notify(Configs) return true end
    function bearlib:SetUIBorderColor(color) end
    function bearlib:SetDiscordBorderColor(color) end
    function bearlib:SetProfileBorderColor(color) end
    function bearlib:SetHubColor(color) end
    function bearlib:SetStrokeColor(color) end
    function bearlib:SetTextColor(color) end
    function bearlib:SetToggleOnColor(color) end
    function bearlib:SetToggleOffColor(color) end
    function bearlib:SetToggleKnobOnColor(color) end
    function bearlib:SetToggleKnobOffColor(color) end
    function bearlib:SetToggleBorderColor(color) end
    function bearlib:SetBorderThickness(thickness) end
    function bearlib:GetBorderColors() return {} end
    function bearlib:GetToggleColors() return {} end
    function bearlib:ResetBorderColors() end
    function bearlib:ResetToggleColors() end

    return bearlib
end)()

-- ==================== EVADE SCRIPT (Converted) ====================
repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local VirtualUser = game:GetService("VirtualUser")
local Workspace = game:GetService("Workspace")
local InsertService = game:GetService("InsertService")
local StarterGui = game:GetService("StarterGui")

-- Create main window with bearlib
local Window = bearlib:MakeWindow({
    Name = "Evade Script by SARpastes | SARHUB",
    SubTitle = "Powered by bearlib",
    SaveFolder = "EvadeConfig.json"  -- enables settings saving
})

-- Create tabs
local PlayerTab = Window:MakeTab("Player")
local AutoTab = Window:MakeTab("Auto")
local EspTab = Window:MakeTab("ESP")
local MiscTab = Window:MakeTab("Misc")

-- Variables
local ValueSpeed = 16
local ActiveCFrameSpeedBoost = false
local cframeSpeedConnection = nil
local IsHoldingSpace = false
local bhopEnabled = false
local ButtonGui = nil
local InputConnections = {}
local IsHoldingButton = false
local afk = true
local selectedMapNumber = 1
local autoVoteEnabled = false
local voteConnection = nil
local ActiveEspPlayers = false
local ActiveEspBots = false
local ActiveDistanceEsp = false
local playerAddedConnection = nil
local playerRemovingConnections = {}
local botLoopConnection = nil
local originalBrightness = game.Lighting.Brightness
local originalOutdoorAmbient = game.Lighting.OutdoorAmbient
local originalAmbient = game.Lighting.Ambient
local originalGlobalShadows = game.Lighting.GlobalShadows
local originalFogEnd = game.Lighting.FogEnd
local originalFogStart = game.Lighting.FogStart
local originalColorCorrectionEnabled = game.Lighting.ColorCorrection.Enabled
local originalSaturation = game.Lighting.ColorCorrection.Saturation
local originalContrast = game.Lighting.ColorCorrection.Contrast
local autoReviveEnabled = false
local lastCheckTime = 0
local checkInterval = 5

-- Helper functions
local function fireVoteServer(selectedMapNumber)
    local eventsFolder = ReplicatedStorage:WaitForChild("Events", 10)
    if eventsFolder then
        local playerFolder = eventsFolder:WaitForChild("Player", 10)
        if playerFolder then
            local voteEvent = playerFolder:WaitForChild("Vote", 10)
            if voteEvent and voteEvent:IsA("RemoteEvent") then
                voteEvent:FireServer(selectedMapNumber)
            end
        end
    end
end

local function applyFullBrightness()
    game.Lighting.Brightness = 2
    game.Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
    game.Lighting.Ambient = Color3.fromRGB(255, 255, 255)
    game.Lighting.GlobalShadows = false
end

local function removeFullBrightness()
    game.Lighting.Brightness = originalBrightness
    game.Lighting.OutdoorAmbient = originalOutdoorAmbient
    game.Lighting.Ambient = originalAmbient
    game.Lighting.GlobalShadows = originalGlobalShadows
end

local function applySuperFullBrightness()
    game.Lighting.Brightness = 15
    game.Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
    game.Lighting.Ambient = Color3.fromRGB(255, 255, 255)
    game.Lighting.GlobalShadows = false
end

local function applyNoFog()
    game.Lighting.FogEnd = 1000000
    game.Lighting.FogStart = 999999
end

local function removeNoFog()
    game.Lighting.FogEnd = originalFogEnd
    game.Lighting.FogStart = originalFogStart
end

local function applyVibrant()
    game.Lighting.ColorCorrection.Enabled = true
    game.Lighting.ColorCorrection.Saturation = 0.8
    game.Lighting.ColorCorrection.Contrast = 0.4
end

local function removeVibrant()
    game.Lighting.ColorCorrection.Enabled = originalColorCorrectionEnabled
    game.Lighting.ColorCorrection.Saturation = originalSaturation
    game.Lighting.ColorCorrection.Contrast = originalContrast
end

local function getLocalPlayerCharacter()
    local player = Players.LocalPlayer
    if player then
        return player.Character or player.CharacterAdded:Wait()
    end
    return nil
end

local function CreateEsp(Char, Color, Text, ParentPart, YOffset)
    if not Char or not ParentPart or not ParentPart:IsA("BasePart") then return end
    if Char:FindFirstChild("ESP_Highlight") and ParentPart:FindFirstChild("ESP") then return end

    local highlight = Instance.new("Highlight")
    highlight.Name = "ESP_Highlight"
    highlight.Adornee = Char
    highlight.FillColor = Color
    highlight.FillTransparency = 0.5
    highlight.OutlineColor = Color
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Enabled = true
    highlight.Parent = Char

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESP"
    billboard.Size = UDim2.new(0, 100, 0, 50)
    billboard.AlwaysOnTop = true
    billboard.StudsOffset = Vector3.new(0, YOffset, 0)
    billboard.Adornee = ParentPart
    billboard.Enabled = true
    billboard.Parent = ParentPart

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = tostring(Text) or ""
    label.TextColor3 = Color
    label.TextScaled = true
    label.Font = Enum.Font.SourceSansBold
    label.Parent = billboard

    spawn(function()
        local Camera = Workspace.CurrentCamera
        while highlight.Parent and billboard.Parent and ParentPart.Parent and Camera do
            local cameraPosition = Camera.CFrame.Position
            local distance = (cameraPosition - ParentPart.Position).Magnitude
            if ActiveDistanceEsp then
                label.Text = tostring(Text) .. " " .. tostring(math.floor(distance + 0.5)) .. "m"
            else
                label.Text = tostring(Text)
            end
            task.wait(0.1)
        end
        highlight:Destroy()
        billboard:Destroy()
    end)
end

local function RemoveEsp(Char, ParentPart)
    if Char then
        local highlight = Char:FindFirstChild("ESP_Highlight")
        if highlight then highlight:Destroy() end
    end
    if ParentPart then
        local billboard = ParentPart:FindFirstChild("ESP")
        if billboard then billboard:Destroy() end
    end
end

local function handlePlayerEsp(player)
    if player ~= LocalPlayer and player.Character then
        local function createPlayerEspOnCharacter(character)
            if ActiveEspPlayers and character:FindFirstChild("Head") then
                CreateEsp(character, Color3.new(0.4, 0.8, 0.4), player.Name, character.Head, 1)
            end
        end

        createPlayerEspOnCharacter(player.Character)

        player.CharacterAdded:Connect(function(newCharacter)
            task.wait(0.1)
            createPlayerEspOnCharacter(newCharacter)
        end)

        player.CharacterRemoving:Connect(function(oldCharacter)
            if oldCharacter:FindFirstChild("Head") then
                RemoveEsp(oldCharacter, oldCharacter.Head)
            end
        end)
    end
end

local function MobileBhopButton(Character)
    if ButtonGui then
        ButtonGui:Destroy()
        ButtonGui = nil
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "BhopButtonGui"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(0,50,0,50)
    Button.Position = UDim2.new(0.9, -25, 0.8, 0)
    Button.BackgroundColor3 = Color3.fromRGB(0,200,0)
    Button.BackgroundTransparency = 0.3
    Button.Text = "Bhop"
    Button.TextScaled = true
    Button.Parent = ScreenGui

    ButtonGui = ScreenGui

    local dragging = false
    local dragInput, mousePos, framePos

    Button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            mousePos = input.Position
            framePos = Button.Position
            IsHoldingButton = true
        end
    end)

    Button.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - mousePos
            Button.Position = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X,
                                        framePos.Y.Scale, framePos.Y.Offset + delta.Y)
        end
    end)

    Button.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
            IsHoldingButton = false
        end
    end)

    local Humanoid = Character:WaitForChild("Humanoid")
    table.insert(InputConnections, RunService.RenderStepped:Connect(function()
        if IsHoldingButton and Humanoid.FloorMaterial ~= Enum.Material.Air then
            Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end))
end

LocalPlayer.CharacterAdded:Connect(function(Character)
    if ButtonGui then
        ButtonGui:Destroy()
        ButtonGui = nil
    end
    for _, conn in pairs(InputConnections) do
        conn:Disconnect()
    end
    InputConnections = {}
end)

-- ==================== PLAYER TAB ====================
PlayerTab:AddSection("Movement")

PlayerTab:AddSlider({
    Name = "Speed Value",
    Range = {1, 50},
    Increment = 1,
    Suffix = "Speed",
    CurrentValue = 16,
    Flag = "SpeedValue",
    Callback = function(Value)
        ValueSpeed = Value
        if ActiveCFrameSpeedBoost and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = ValueSpeed
        end
    end,
})

PlayerTab:AddToggle({
    Name = "Speed Power",
    CurrentValue = false,
    Flag = "CFrameSpeed",
    Callback = function(Value)
        ActiveCFrameSpeedBoost = Value
        if ActiveCFrameSpeedBoost then
            if cframeSpeedConnection then
                cframeSpeedConnection:Disconnect()
                cframeSpeedConnection = nil
            end

            cframeSpeedConnection = RunService.RenderStepped:Connect(function()
                local character = LocalPlayer.Character
                local humanoid = character and character:FindFirstChildOfClass("Humanoid")
                local hrp = character and character:FindFirstChild("HumanoidRootPart")

                if character and humanoid and hrp then
                    local moveDir = humanoid.MoveDirection
                    if moveDir.Magnitude > 0 then
                        hrp.CFrame = hrp.CFrame + moveDir * math.max(ValueSpeed, 1) * 0.080
                    end
                end
            end)
        else
            if cframeSpeedConnection then
                cframeSpeedConnection:Disconnect()
                cframeSpeedConnection = nil
            end
        end
    end,
})

PlayerTab:AddToggle({
    Name = "Jump Power (Enable)",
    CurrentValue = false,
    Flag = "JumpBoost",
    Callback = function(Value)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            LocalPlayer.Character.Humanoid.UseJumpPower = Value
        end
    end,
})

PlayerTab:AddSlider({
    Name = "Jump Power Value",
    Range = {0, 1000},
    Increment = 1,
    Suffix = "%",
    CurrentValue = 50,
    Flag = "JumpBoostSlider",
    Callback = function(Value)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            LocalPlayer.Character.Humanoid.JumpPower = Value
        end
    end,
})

PlayerTab:AddToggle({
    Name = "Auto Bhop (Just hold space)",
    CurrentValue = false,
    Flag = "AutoBhopToggle",
    Callback = function(Value)
        bhopEnabled = Value
    end,
})

PlayerTab:AddButton({
    Name = "Auto Bhop (Mobile)",
    Callback = function()
        if LocalPlayer.Character then
            MobileBhopButton(LocalPlayer.Character)
        end
    end
})

PlayerTab:AddSection("Gravity")

local GravitySlider = PlayerTab:AddSlider({
    Name = "Gravity",
    Range = {0, 1000},
    Increment = 1,
    Suffix = "%",
    CurrentValue = 50,
    Flag = "GravitySlider",
    Callback = function(Value)
        Workspace.Gravity = Value
    end,
})

PlayerTab:AddButton({
    Name = "Reset Gravity",
    Callback = function()
        Workspace.Gravity = 50
        GravitySlider:Set(50)
    end,
})

-- Bhop input handling
UserInputService.InputBegan:Connect(function(InputObject, GameProcessedEvent)
    if InputObject.KeyCode == Enum.KeyCode.Space and not GameProcessedEvent then
        IsHoldingSpace = true
    end
end)

UserInputService.InputEnded:Connect(function(InputObject, GameProcessedEvent)
    if InputObject.KeyCode == Enum.KeyCode.Space then
        IsHoldingSpace = false
    end
end)

local function ConnectBhop(Humanoid)
    Humanoid.StateChanged:Connect(function(_, NewState)
        if NewState == Enum.HumanoidStateType.Landed then
            if IsHoldingSpace and bhopEnabled then
                Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end)
end

if LocalPlayer.Character then
    local Humanoid = LocalPlayer.Character:WaitForChild("Humanoid")
    ConnectBhop(Humanoid)
end

LocalPlayer.CharacterAdded:Connect(function(NewCharacter)
    local Humanoid = NewCharacter:WaitForChild("Humanoid")
    ConnectBhop(Humanoid)
end)

-- ==================== AUTO TAB ====================
AutoTab:AddSection("Map Voting")

AutoTab:AddDropdown({
    Name = "Select Map",
    Options = {"Map 1", "Map 2", "Map 3", "Map 4"},
    CurrentOption = "Map 1",
    Flag = "MapSelection",
    Callback = function(Option)
        if Option == "Map 1" then
            selectedMapNumber = 1
        elseif Option == "Map 2" then
            selectedMapNumber = 2
        elseif Option == "Map 3" then
            selectedMapNumber = 3
        elseif Option == "Map 4" then
            selectedMapNumber = 4
        end
    end,
})

AutoTab:AddButton({
    Name = "Vote Map",
    Callback = function()
        fireVoteServer(selectedMapNumber)
    end,
})

AutoTab:AddToggle({
    Name = "Auto Vote",
    CurrentValue = false,
    Flag = "AutoVote",
    Callback = function(Value)
        autoVoteEnabled = Value
        if autoVoteEnabled then
            if not voteConnection then
                voteConnection = RunService.Heartbeat:Connect(function()
                    fireVoteServer(selectedMapNumber)
                end)
            end
        else
            if voteConnection then
                voteConnection:Disconnect()
                voteConnection = nil
            end
        end
    end,
})

AutoTab:AddSection("Revive")

AutoTab:AddButton({
    Name = "Revive Yourself",
    Callback = function()
        local player = LocalPlayer
        local character = player.Character
        if character and character:GetAttribute("Downed") then
            ReplicatedStorage.Events.Player.ChangePlayerMode:FireServer(true)
        end
    end,
})

AutoTab:AddToggle({
    Name = "Auto Revive Yourself",
    CurrentValue = false,
    Flag = "AutoRevive",
    Callback = function(Value)
        autoReviveEnabled = Value
    end,
})

-- ==================== ESP TAB ====================
EspTab:AddToggle({
    Name = "Players ESP",
    CurrentValue = false,
    Flag = "PlayersESP",
    Callback = function(Value)
        ActiveEspPlayers = Value
        if ActiveEspPlayers then
            for _, plr in pairs(Players:GetPlayers()) do
                handlePlayerEsp(plr)
            end
            playerAddedConnection = Players.PlayerAdded:Connect(function(newPlayer)
                handlePlayerEsp(newPlayer)
            end)
        else
            if playerAddedConnection then
                playerAddedConnection:Disconnect()
                playerAddedConnection = nil
            end
            for _, plr in pairs(Players:GetPlayers()) do
                if plr.Character and plr.Character:FindFirstChild("Head") then
                    RemoveEsp(plr.Character, plr.Character.Head)
                end
            end
        end
    end,
})

EspTab:AddToggle({
    Name = "NextBot ESP",
    CurrentValue = false,
    Flag = "BotsESP",
    Callback = function(Value)
        ActiveEspBots = Value
        if ActiveEspBots then
            botLoopConnection = RunService.Heartbeat:Connect(function()
                local botsFolder = Workspace:FindFirstChild("Game") and Workspace.Game:FindFirstChild("Players")
                if botsFolder then
                    for _, bot in pairs(botsFolder:GetChildren()) do
                        if bot:IsA("Model") and bot:FindFirstChild("Hitbox") then
                            bot.Hitbox.Transparency = 0.5
                            CreateEsp(bot, Color3.new(0.8, 0.2, 0.2), bot.Name, bot.Hitbox, -2)
                        end
                    end
                end
            end)
        else
            if botLoopConnection then
                botLoopConnection:Disconnect()
                botLoopConnection = nil
            end
            local botsFolder = Workspace:FindFirstChild("Game") and Workspace.Game:FindFirstChild("Players")
            if botsFolder then
                for _, bot in pairs(botsFolder:GetChildren()) do
                    if bot:IsA("Model") and bot:FindFirstChild("Hitbox") then
                        bot.Hitbox.Transparency = 1
                        RemoveEsp(bot, bot.Hitbox)
                    end
                end
            end
        end
    end,
})

EspTab:AddToggle({
    Name = "Distance ESP",
    CurrentValue = false,
    Flag = "DistanceESP",
    Callback = function(Value)
        ActiveDistanceEsp = Value
    end,
})

-- ==================== MISC TAB ====================
MiscTab:AddToggle({
    Name = "Anti-AFK",
    CurrentValue = true,
    Flag = "AntiAFK",
    Callback = function(Value)
        afk = Value
        if Value then
            task.spawn(function()
                while afk do
                    if not LocalPlayer then return end
                    VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
                    VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
                    task.wait(60)
                end
            end)
        end
    end
})

MiscTab:AddToggle({
    Name = "Full Brightness",
    CurrentValue = false,
    Flag = "FullBright",
    Callback = function(Value)
        if Value then
            applyFullBrightness()
        else
            removeFullBrightness()
        end
    end,
})

MiscTab:AddToggle({
    Name = "Super Full Brightness",
    CurrentValue = false,
    Flag = "SuperFullBright",
    Callback = function(Value)
        if Value then
            applySuperFullBrightness()
        else
            removeFullBrightness()
        end
    end,
})

MiscTab:AddToggle({
    Name = "No Fog",
    CurrentValue = false,
    Flag = "NoFog",
    Callback = function(Value)
        if Value then
            applyNoFog()
        else
            removeNoFog()
        end
    end,
})

MiscTab:AddToggle({
    Name = "Vibrant Colors",
    CurrentValue = false,
    Flag = "Vibrant",
    Callback = function(Value)
        if Value then
            applyVibrant()
        else
            removeVibrant()
        end
    end,
})

MiscTab:AddToggle({
    Name = "FPS Boost",
    CurrentValue = false,
    Flag = "FPSBoost",
    Callback = function(Value)
        if Value then
            for _, v in pairs(game:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.Material = Enum.Material.SmoothPlastic
                    v.Reflectance = 0
                elseif v:IsA("Decal") then
                    v.Transparency = 1
                end
            end
            settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        end
    end,
})

-- Auto-revive loop
RunService.Heartbeat:Connect(function()
    if autoReviveEnabled then
        if tick() - lastCheckTime >= checkInterval then
            lastCheckTime = tick()
            local player = LocalPlayer
            local character = player.Character
            if character and character:GetAttribute("Downed") then
                ReplicatedStorage.Events.Player.ChangePlayerMode:FireServer(true)
            end
        end
    end
end)

-- Ensure the GUI is visible (bearlib creates it automatically)
print("Evade script loaded with bearlib UI")
