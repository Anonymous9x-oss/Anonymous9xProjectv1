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
        Monochrome = {
            ["Color Hub 1"] = ColorSequence.new({
                ColorSequenceKeypoint.new(0.00, Color3.fromRGB(25, 25, 25)),
                ColorSequenceKeypoint.new(0.50, Color3.fromRGB(35, 35, 35)),
                ColorSequenceKeypoint.new(1.00, Color3.fromRGB(25, 25, 25))
            }),
            ["Color Hub 2"] = Color3.fromRGB(20, 20, 20),
            ["Color Stroke"] = Color3.fromRGB(80, 80, 80),
            ["Color Theme"] = Color3.fromRGB(220, 220, 220),
            ["Color Text"] = Color3.fromRGB(255, 255, 255),
            ["Color Dark Text"] = Color3.fromRGB(170, 170, 170),
            ["Color Discord Text"] = Color3.fromRGB(255, 255, 255),
            ["Color Discord Stats"] = Color3.fromRGB(200, 200, 200),
            ["Color Discord Border"] = Color3.fromRGB(80, 80, 80),
            ["Color Profile Border"] = Color3.fromRGB(80, 80, 80),
            ["Color Card Border"] = Color3.fromRGB(80, 80, 80),
            ["Color Toggle On"] = Color3.fromRGB(220, 220, 220),
            ["Color Toggle Off"] = Color3.fromRGB(50, 50, 50),
            ["Color Toggle Knob On"] = Color3.fromRGB(30, 30, 30),
            ["Color Toggle Knob Off"] = Color3.fromRGB(200, 200, 200),
            ["Color Toggle Border"] = Color3.fromRGB(100, 100, 100),
            ["Border Thickness"] = 1.5,
            ["UI Border Color"] = Color3.fromRGB(100, 100, 100),
        }
    },
    Info = {
        Version = "1.2.0"
    },
    Save = {
        UISize = {550, 380},
        TabSize = 160,
        Theme = "Monochrome"
    },
    Settings = {},
    Connection = {},
    Instances = {},
    Elements = {},
    Options = {},
    Flags = {},
    Tabs = {},
    Icons = (function()
        return {}
    end)(),
    AllElements = {},
    ThunderActive = false
}

local ViewportSize = workspace.CurrentCamera.ViewportSize
local UIScale = ViewportSize.Y / 450

local Settings = bearlib.Settings
local Flags = bearlib.Flags

local SetProps, SetChildren, InsertTheme, Create do
    InsertTheme = function(Instance, Type)
        table.insert(bearlib.Instances, {
            Instance = Instance,
            Type = Type
        })
        return Instance
    end

    SetChildren = function(Instance, Children)
        if Children then
            table.foreach(Children, function(_,Child)
                Child.Parent = Instance
            end)
        end
        return Instance
    end

    SetProps = function(Instance, Props)
        if Props then
            table.foreach(Props, function(prop, value)
                Instance[prop] = value
            end)
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
                if rawget(decode, "Theme") and VerifyTheme(decode["Theme"]) then bearlib.Save["Theme"] = decode["Theme"] end
            end
        end
    end

    pcall(Save, "bear library v8.1.json")
end

local Funcs = {} do
    function Funcs:InsertCallback(tab, func)
        if type(func) == "function" then
            table.insert(tab, func)
        end
        return func
    end

    function Funcs:FireCallback(tab, ...)
        for _,v in ipairs(tab) do
            if type(v) == "function" then
                task.spawn(v, ...)
            end
        end
    end

    function Funcs:ToggleVisible(Obj, Bool)
        Obj.Visible = Bool ~= nil and Bool or Obj.Visible
    end

    function Funcs:GetConnectionFunctions(ConnectedFuncs, func)
        local Connected = { Function = func, Connected = true }

        function Connected:Disconnect()
            if self.Connected then
                table.remove(ConnectedFuncs, table.find(ConnectedFuncs, self.Function))
                self.Connected = false
            end
        end

        function Connected:Fire(...)
            if self.Connected then
                task.spawn(self.Function, ...)
            end
        end

        return Connected
    end

    function Funcs:GetCallback(Configs, index)
        local func = Configs[index] or Configs.Callback or function()end

        if type(func) == "table" then
            return ({function(Value) func[1][func[2]] = Value end})
        end
        return {func}
    end
end

local Connections, Connection = {}, bearlib.Connection do
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
        for _,Func in pairs(Connection) do
            task.spawn(Func, ...)
        end
    end

    NewConnectionList({"FlagsChanged", "ThemeChanged", "FileSaved", "ThemeChanging", "OptionAdded"})
end

local GetFlag, SetFlag, CheckFlag do
    CheckFlag = function(Name)
        return type(Name) == "string" and Flags[Name] ~= nil
    end

    GetFlag = function(Name)
        return type(Name) == "string" and Flags[Name]
    end

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

            local Success, Encoded = pcall(function()
                return HttpService:JSONEncode(Flags)
            end)

            if Success then
                local Success = pcall(writefile, ScriptFile, Encoded)
                if Success then
                    Connection:FireConnection("FileSaved", "Script-Flags", ScriptFile, Encoded)
                end
            end
        end
    end)
end

local ScreenGui = Create("ScreenGui", CoreGui, {
    Name = "Anonymous9x Library",
}, {
    Create("UIScale", {
        Scale = UIScale,
        Name = "Scale"
    })
})

local ScreenFind = CoreGui:FindFirstChild(ScreenGui.Name)
if ScreenFind and ScreenFind ~= ScreenGui then
    ScreenFind:Destroy()
end

local function GetStr(val)
    if type(val) == "function" then
        return val()
    end
    return val
end

local function ConnectSave(Instance, func)
    Instance.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
            while UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do task.wait()
            end
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
    local TweenInfo = TweenInfo.new(Time, Enum.EasingStyle.Quint)

    local Tween = TweenService:Create(Instance, TweenInfo, {[Prop] = NewVal})
    Tween:Play()
    if TweenWait then
        Tween.Completed:Wait()
    end
    return Tween
end

local function MakeDrag(Instance)
    task.spawn(function()
        SetProps(Instance, {
            Active = true,
            AutoButtonColor = false
        })

        local DragStart, StartPos, InputOn

        local function Update(Input)
            local delta = Input.Position - DragStart
            local Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + delta.X / UIScale, StartPos.Y.Scale, StartPos.Y.Offset + delta.Y / UIScale)
            CreateTween({Instance, "Position", Position, 0.35})
        end

        Instance.MouseButton1Down:Connect(function()
            InputOn = true
        end)

        Instance.InputBegan:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                StartPos = Instance.Position
                DragStart = Input.Position

                while UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do RunService.Heartbeat:Wait()
                    if InputOn then
                        Update(Input)
                    end
                end
                InputOn = false
            end
        end)
    end)
    return Instance
end

local function VerifyTheme(Theme)
    for name,_ in pairs(bearlib.Themes) do
        if name == Theme then
            return true
        end
    end
end

local function SaveJson(FileName, save)
    if writefile then
        local json = HttpService:JSONEncode(save)
        writefile(FileName, json)
    end
end

local Theme = bearlib.Themes[bearlib.Save.Theme]

local function AddEle(Name, Func)
    bearlib.Elements[Name] = Func
end

local function Make(Ele, Instance, props, ...)
    local Element = bearlib.Elements[Ele](Instance, props, ...)
    return Element
end

AddEle("Corner", function(parent, CornerRadius)
    local New = SetProps(Create("UICorner", parent, {
        CornerRadius = CornerRadius or UDim.new(0, 7)
    }))
    return New
end)

AddEle("Stroke", function(parent, props, ...)
    local args = {...}
    local New = InsertTheme(SetProps(Create("UIStroke", parent, {
        Color = args[1] or Theme["Color Stroke"],
        Thickness = args[2] or 1,
        ApplyStrokeMode = "Border"
    }), props), "Stroke")
    return New
end)

AddEle("Button", function(parent, props, ...)
    local args = {...}
    local New = InsertTheme(SetProps(Create("TextButton", parent, {
        Text = "",
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Theme["Color Hub 2"],
        AutoButtonColor = false
    }), props), "Frame")

    New.MouseEnter:Connect(function()
        New.BackgroundTransparency = 0.4
    end)
    New.MouseLeave:Connect(function()
        New.BackgroundTransparency = 0
    end)
    if args[1] then
        New.Activated:Connect(args[1])
    end
    return New
end)

AddEle("Gradient", function(parent, props, ...)
    local args = {...}
    local New = InsertTheme(SetProps(Create("UIGradient", parent, {
        Color = Theme["Color Hub 1"]
    }), props), "Gradient")
    return New
end)

local function ButtonFrame(Instance, Title, Description, HolderSize)
    local TitleL = InsertTheme(Create("TextLabel", {
        Font = Enum.Font.GothamMedium,
        TextColor3 = Theme["Color Text"],
        Size = UDim2.new(1, -20),
        AutomaticSize = "Y",
        Position = UDim2.new(0, 0, 0.5),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundTransparency = 1,
        TextTruncate = "AtEnd",
        TextSize = 10,
        TextXAlignment = "Left",
        Text = "",
        RichText = true,
        ZIndex = 5
    }), "Text")

    local DescL = InsertTheme(Create("TextLabel", {
        Font = Enum.Font.Gotham,
        TextColor3 = Theme["Color Dark Text"],
        Size = UDim2.new(1, -20),
        AutomaticSize = "Y",
        Position = UDim2.new(0, 12, 0, 15),
        BackgroundTransparency = 1,
        TextWrapped = true,
        TextSize = 8,
        TextXAlignment = "Left",
        Text = "",
        RichText = true,
        ZIndex = 5
    }), "DarkText")

    local Frame = Make("Button", Instance, {
        Size = UDim2.new(1, 0, 0, 25),
        AutomaticSize = "Y",
        Name = "Option"
    }) Make("Corner", Frame, UDim.new(0, 6))

    local LabelHolder = Create("Frame", Frame, {
        AutomaticSize = "Y",
        BackgroundTransparency = 1,
        Size = HolderSize,
        Position = UDim2.new(0, 10, 0),
        AnchorPoint = Vector2.new(0, 0),
        ZIndex = 4
    }, {
        Create("UIListLayout", {
            SortOrder = "LayoutOrder",
            VerticalAlignment = "Center",
            Padding = UDim.new(0, 2)
        }),
        Create("UIPadding", {
            PaddingBottom = UDim.new(0, 5),
            PaddingTop = UDim.new(0, 5)
        }),
        TitleL,
        DescL,
    })

    local Label = {}
    function Label:SetTitle(NewTitle)
        if type(NewTitle) == "string" and NewTitle:gsub(" ", ""):len() > 0 then
            TitleL.Text = NewTitle
        end
    end
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

local function GetColor(Instance)
    if Instance:IsA("Frame") then
        return "BackgroundColor3"
    elseif Instance:IsA("ImageLabel") then
        return "ImageColor3"
    elseif Instance:IsA("TextLabel") then
        return "TextColor3"
    elseif Instance:IsA("ScrollingFrame") then
        return "ScrollBarImageColor3"
    elseif Instance:IsA("UIStroke") then
        return "Color"
    end
    return ""
end

function bearlib:GetIcon(index)
    if type(index) ~= "string" or index:find("rbxassetid://") or #index == 0 then
        return index
    end

    local firstMatch = nil
    index = string.lower(index):gsub("lucide", ""):gsub("-", "")

    if self.Icons[index] then
      return self.Icons[index]
    end

    for Name, Icon in self.Icons do
        if Name == index then
            return Icon
        elseif not firstMatch and Name:find(index, 1, true) then
            firstMatch = Icon
        end
    end

    return firstMatch or index
end

function bearlib:SetTheme(NewTheme)
    if not VerifyTheme(NewTheme) then return end

    bearlib.Save.Theme = NewTheme
    SaveJson("bear library v8.1.json", bearlib.Save)

    local OldTheme = Theme
    Theme = bearlib.Themes[NewTheme]

    if MainFrame then
        if NewTheme == "Monochrome" then
            MainFrame.BackgroundTransparency = 0.03
        end
    end

    Connection:FireConnection("ThemeChanged", NewTheme)

    for _, Val in pairs(bearlib.Instances) do
        if not Val.Instance or not Val.Instance.Parent then continue end

        if Val.Type == "Gradient" then
            Val.Instance.Color = Theme["Color Hub 1"]

        elseif Val.Type == "Frame" then
            Val.Instance.BackgroundColor3 = Theme["Color Hub 2"]

        elseif Val.Type == "Stroke" then
            local parent = Val.Instance.Parent
            local strokeColor = Theme["Color Stroke"]

            if parent then
                if parent:FindFirstAncestor("DiscordInviteContainer") or 
                   parent.Name:find("DiscordCard") or
                   parent:FindFirstAncestor("DiscordCard") then
                    strokeColor = Theme["Color Discord Border"]
                elseif parent:FindFirstAncestor("Profile") then
                    strokeColor = Theme["Color Profile Border"]
                elseif parent.Name == "Hub" or (parent:IsA("ImageButton") and parent.Name == "Hub") then
                    strokeColor = Theme["UI Border Color"]
                end
            end

            Val.Instance.Color = strokeColor
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

    if SearchButton then
        SearchButton.ImageColor3 = Theme["Color Text"]
    end
    if MinimizeButton then
        MinimizeButton.ImageColor3 = Theme["Color Text"]
    end

    if MinimizedContainer and MinimizedIcon and MinimizedTitle then
        MinimizedIcon.ImageColor3 = Theme["Color Text"]
        MinimizedTitle.TextColor3 = Theme["Color Text"]
    end

    for _, TabData in pairs(bearlib.Tabs) do
        if TabData and TabData.func and TabData.func.Cont then
            local container = TabData.func.Cont
            local tabButton = container and container.Parent
            if tabButton and tabButton:IsA("TextButton") then
                local textLabel = tabButton:FindFirstChildOfClass("TextLabel")
                if textLabel then
                    textLabel.TextColor3 = Theme["Color Text"]
                end

                local imageLabel = tabButton:FindFirstChildOfClass("ImageLabel")
                if imageLabel then
                    imageLabel.ImageColor3 = Theme["Color Text"]
                end

                local selectedFrame = tabButton:FindFirstChildOfClass("Frame")
                if selectedFrame and selectedFrame.Name ~= "Selected" then
                    for _, child in pairs(tabButton:GetChildren()) do
                        if child:IsA("Frame") and child.BackgroundColor3 == OldTheme["Color Theme"] then
                            child.BackgroundColor3 = Theme["Color Theme"]
                        end
                    end
                end
            end
        end
    end

    task.wait()
    if MainFrame then
        MainFrame.BackgroundTransparency = MainFrame.BackgroundTransparency
    end

    print("Tema diubah menjadi:", NewTheme)
end

function bearlib:SetScale(NewScale)
    NewScale = ViewportSize.Y / math.clamp(NewScale, 300, 2000)
    UIScale, ScreenGui.Scale.Scale = NewScale, NewScale
end

local MainFrame = nil
local SearchButton = nil
local MinimizeButton = nil
local ToggleButton = nil
local ToggleGui = nil
local MinimizedContainer = nil
local MinimizedIcon = nil
local MinimizedTitle = nil

function bearlib:MakeWindow(Configs)
    local WTitle = Configs[1] or Configs.Name or Configs.Title or "Anonymous9x Library"
    local WMiniText = Configs[2] or Configs.SubTitle or "by : Anonymous9x"

    Settings.ScriptFile = Configs[3] or Configs.SaveFolder or false

    local function LoadFile()
        local File = Settings.ScriptFile
        if type(File) ~= "string" then return end
        if not readfile or not isfile then return end
        local s, r = pcall(isfile, File)

        if s and r then
            local s, _Flags = pcall(readfile, File)

            if s and type(_Flags) == "string" then
                local s,r = pcall(function() return HttpService:JSONDecode(_Flags) end)
                Flags = s and r or {}
            end
        end
    end;LoadFile()

    local UISizeX, UISizeY = unpack(bearlib.Save.UISize)

    local bgTransparency = 0.03

    MainFrame = InsertTheme(Create("ImageButton", ScreenGui, {
        Size = UDim2.fromOffset(UISizeX, UISizeY),
        Position = UDim2.new(0.5, -UISizeX/2, 0.5, -UISizeY/2),
        BackgroundTransparency = bgTransparency,
        Name = "Hub"
    }), "Main")
    Make("Gradient", MainFrame, {
        Rotation = 45
    }) MakeDrag(MainFrame)

    local MainCorner = Make("Corner", MainFrame, UDim.new(0, 7))

    local UIBorder = Instance.new("UIStroke")
    UIBorder.Name = "UIBorder"
    UIBorder.Color = Theme["UI Border Color"] or Color3.fromRGB(100, 100, 100)
    UIBorder.Thickness = 1.5
    UIBorder.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    UIBorder.LineJoinMode = Enum.LineJoinMode.Round
    UIBorder.Parent = MainFrame

    InsertTheme(UIBorder, "UIBorder")

    local Components = Create("Folder", MainFrame, {
        Name = "Components"
    })

    local DropdownHolder = Create("Folder", ScreenGui, {
        Name = "Dropdown"
    })

    local TopBar = Create("Frame", Components, {
        Size = UDim2.new(1, 0, 0, 28),
        BackgroundTransparency = 1,
        Name = "Top Bar"
    })

    local Title = InsertTheme(Create("TextLabel", TopBar, {
        Position = UDim2.new(0, 15, 0.5),
        AnchorPoint = Vector2.new(0, 0.5),
        AutomaticSize = "XY",
        Text = WTitle,
        TextXAlignment = "Left",
        TextSize = 12,
        TextColor3 = Theme["Color Text"],
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamMedium,
        Name = "Title"
    }, {
        InsertTheme(Create("TextLabel", {
            Size = UDim2.fromScale(0, 1),
            AutomaticSize = "X",
            AnchorPoint = Vector2.new(0, 1),
            Position = UDim2.new(1, 5, 0.9),
            Text = WMiniText,
            TextColor3 = Theme["Color Dark Text"],
            BackgroundTransparency = 1,
            TextXAlignment = "Left",
            TextYAlignment = "Bottom",
            TextSize = 8,
            Font = Enum.Font.Gotham,
            Name = "SubTitle"
        }), "DarkText")
    }), "Text")

    MinimizedContainer = Create("Frame", TopBar, {
        Size = UDim2.new(0, 0, 0, 28),
        Position = UDim2.new(0, 15, 0.5),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundTransparency = 1,
        Visible = false,
        Name = "MinimizedContainer"
    })

    MinimizedIcon = Create("ImageLabel", MinimizedContainer, {
        Size = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new(0, 0, 0.5),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundTransparency = 1,
        Image = "rbxassetid://97269958324726",
        ImageColor3 = Theme["Color Text"],
        Name = "MinimizedIcon"
    })

    MinimizedTitle = InsertTheme(Create("TextLabel", MinimizedContainer, {
        Size = UDim2.new(0, 0, 0, 20),
        Position = UDim2.new(0, 25, 0.5),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamMedium,
        Text = WTitle,
        TextColor3 = Theme["Color Text"],
        TextSize = 12,
        TextXAlignment = "Left",
        AutomaticSize = "X",
        Name = "MinimizedTitle"
    }), "Text")

    local MainScroll = InsertTheme(Create("ScrollingFrame", Components, {
        Size = UDim2.new(0, bearlib.Save.TabSize, 1, -TopBar.Size.Y.Offset),
        ScrollBarImageColor3 = Theme["Color Theme"],
        Position = UDim2.new(0, 0, 1, 0),
        AnchorPoint = Vector2.new(0, 1),
        ScrollBarThickness = 1.5,
        BackgroundTransparency = 1,
        ScrollBarImageTransparency = 0.2,
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = "Y",
        ScrollingDirection = "Y",
        BorderSizePixel = 0,
        Name = "Tab Scroll"
    }, {
        Create("UIPadding", {
            PaddingLeft = UDim.new(0, 10),
            PaddingRight = UDim.new(0, 10),
            PaddingTop = UDim.new(0, 10),
            PaddingBottom = UDim.new(0, 10)
        }), Create("UIListLayout", {
            Padding = UDim.new(0, 5)
        })
    }), "ScrollBar")

    local Containers = Create("Frame", Components, {
        Size = UDim2.new(1, -MainScroll.Size.X.Offset, 1, -TopBar.Size.Y.Offset),
        AnchorPoint = Vector2.new(1, 1),
        Position = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Name = "Containers"
    })

    local SearchContainer = InsertTheme(Create("ScrollingFrame", Components, {
        Size = UDim2.new(1, -MainScroll.Size.X.Offset, 1, -TopBar.Size.Y.Offset),
        AnchorPoint = Vector2.new(1, 1),
        Position = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Visible = false,
        ScrollBarThickness = 1.5,
        ScrollBarImageTransparency = 0.2,
        ScrollBarImageColor3 = Theme["Color Theme"],
        AutomaticCanvasSize = "Y",
        ScrollingDirection = "Y",
        BorderSizePixel = 0,
        Name = "SearchContainer"
    }, {
        Create("UIPadding", {
            PaddingLeft = UDim.new(0, 10),
            PaddingRight = UDim.new(0, 10),
            PaddingTop = UDim.new(0, 10),
            PaddingBottom = UDim.new(0, 10)
        }),
        Create("UIListLayout", {
            SortOrder = "LayoutOrder",
            Padding = UDim.new(0, 5)
        })
    }), "ScrollBar")

    local ControlSize1, ControlSize2 = MakeDrag(Create("ImageButton", MainFrame, {
        Size = UDim2.new(0, 35, 0, 35),
        Position = MainFrame.Size,
        Active = true,
        AnchorPoint = Vector2.new(0.8, 0.8),
        BackgroundTransparency = 1,
        Name = "Control Hub Size"
    })), MakeDrag(Create("ImageButton", MainFrame, {
        Size = UDim2.new(0, 20, 1, -30),
        Position = UDim2.new(0, MainScroll.Size.X.Offset, 1, 0),
        AnchorPoint = Vector2.new(0.5, 1),
        Active = true,
        BackgroundTransparency = 1,
        Name = "Control Tab Size"
    }))

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

    ConnectSave(ControlSize1, function()
        if not Minimized then
            bearlib.Save.UISize = {MainFrame.Size.X.Offset, MainFrame.Size.Y.Offset}
            SaveJson("bear library v8.1.json", bearlib.Save)
        end
    end)

    ConnectSave(ControlSize2, function()
        bearlib.Save.TabSize = MainScroll.Size.X.Offset
        SaveJson("bear library v8.1.json", bearlib.Save)
    end)

    local ButtonsFolder = Create("Folder", TopBar, {
        Name = "Buttons"
    })

    local CloseButton = Create("ImageButton", {
        Size = UDim2.new(0, 14, 0, 14),
        Position = UDim2.new(1, -10, 0.5),
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundTransparency = 1,
        Image = "rbxassetid://10747384394",
        AutoButtonColor = false,
        Name = "Close"
    })

    MinimizeButton = Create("ImageButton", {
        Size = UDim2.new(0, 14, 0, 14),
        Position = UDim2.new(1, -35, 0.5),
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundTransparency = 1,
        Image = "rbxassetid://97269958324726",
        ImageColor3 = Theme["Color Text"],
        AutoButtonColor = false,
        Name = "Minimize"
    })

    SearchButton = Create("ImageButton", {
        Size = UDim2.new(0, 14, 0, 14),
        Position = UDim2.new(1, -60, 0.5),
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundTransparency = 1,
        Image = "rbxassetid://10734943674",
        ImageColor3 = Theme["Color Text"],
        Name = "Search"
    })

    SetChildren(ButtonsFolder, {
        CloseButton,
        MinimizeButton,
        SearchButton
    })

    local SearchInputFrame = InsertTheme(Create("Frame", TopBar, {
        Size = UDim2.new(0, 0, 0, 22),
        Position = UDim2.new(1, -85, 0.5),
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundColor3 = Theme["Color Hub 2"],
        ClipsDescendants = true
    }), "Frame")
    Make("Corner", SearchInputFrame, UDim.new(0, 4))
    Make("Stroke", SearchInputFrame)

    local SearchInput = InsertTheme(Create("TextBox", SearchInputFrame, {
        Size = UDim2.new(1, -5, 1, 0),
        Position = UDim2.new(0, 5, 0, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        PlaceholderText = "Cari...",
        TextColor3 = Theme["Color Text"],
        TextSize = 10,
        TextXAlignment = "Left",
        Text = ""
    }), "Text")

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
            local MatchName = string.find(Name, Query)

            if MatchName then
                if ElementData.Instance then
                    ElementData.Instance.Parent = SearchContainer
                    ElementData.Instance.Visible = true
                end
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

    SearchInput:GetPropertyChangedSignal("Text"):Connect(function()
        if SearchActive then
            UpdateSearch(SearchInput.Text)
        end
    end)

    local Minimized, SaveSize, WaitClick
    local Window, FirstTab = {}, false

    local function UpdateMinimizeState()
        if Minimized then
            Title.Visible = false
            if Title.SubTitle then
                Title.SubTitle.Visible = false
            end

            MinimizedContainer.Size = UDim2.new(0, 25 + MinimizedTitle.TextBounds.X + 5, 0, 28)
            MinimizedContainer.Visible = true

            MinimizedIcon.ImageColor3 = Theme["Color Text"]
            MinimizedTitle.TextColor3 = Theme["Color Text"]
        else
            MinimizedContainer.Visible = false
            Title.Visible = true
            if Title.SubTitle then
                Title.SubTitle.Visible = true
            end
        end
    end

    MinimizedTitle:GetPropertyChangedSignal("TextBounds"):Connect(function()
        if Minimized and MinimizedContainer.Visible then
            MinimizedContainer.Size = UDim2.new(0, 25 + MinimizedTitle.TextBounds.X + 5, 0, 28)
        end
    end)

    function Window:CloseBtn()
        local Dialog = Window:Dialog({
            Title = "Window",
            Text = "Tutup window?",
            Options = {
                {"Tutup", function()
                    ScreenGui:Destroy()
                    if ToggleGui then
                        ToggleGui:Destroy()
                    end
                end},
                {"Batal"}
            }
        })
    end

    function Window:MinimizeBtn()
        if WaitClick then return end
        WaitClick = true

        if Minimized then
            MinimizeButton.Image = "rbxassetid://97269958324726"
            CreateTween({MainFrame, "Size", SaveSize, 0.25, true})
            ControlSize1.Visible = true
            ControlSize2.Visible = true
            Minimized = false
        else
            MinimizeButton.Image = "rbxassetid://10734924532"
            SaveSize = MainFrame.Size
            ControlSize1.Visible = false
            ControlSize2.Visible = false
            CreateTween({MainFrame, "Size", UDim2.fromOffset(MainFrame.Size.X.Offset, 28), 0.25, true})
            Minimized = true
        end

        UpdateMinimizeState()
        WaitClick = false
    end

    function Window:Minimize()
        MainFrame.Visible = not MainFrame.Visible
    end

    function Window:AddMinimizeButton(Configs)
        local Button = MakeDrag(Create("ImageButton", ScreenGui, {
            Size = UDim2.fromOffset(35, 35),
            Position = UDim2.fromScale(0.15, 0.15),
            BackgroundTransparency = 1,
            BackgroundColor3 = Theme["Color Hub 2"],
            AutoButtonColor = false
        }))

        local Stroke, Corner
        if Configs.Corner then
            Corner = Make("Corner", Button)
            SetProps(Corner, Configs.Corner)
        end
        if Configs.Stroke then
            Stroke = Make("Stroke", Button)
            SetProps(Stroke, Configs.Corner)
        end

        SetProps(Button, Configs.Button)
        Button.Activated:Connect(Window.Minimize)

        return {
            Stroke = Stroke,
            Corner = Corner,
            Button = Button
        }
    end

    function Window:Set(Val1, Val2)
        if type(Val1) == "string" and type(Val2) == "string" then
            Title.Text = Val1
            Title.SubTitle.Text = Val2
            MinimizedTitle.Text = Val1
        elseif type(Val1) == "string" then
            Title.Text = Val1
            MinimizedTitle.Text = Val1
        end
    end

    function Window:Dialog(Configs)
        if MainFrame:FindFirstChild("Dialog") then return end
        if Minimized then
            Window:MinimizeBtn()
        end

        local DTitle = Configs[1] or Configs.Title or "Dialog"
        local DText = Configs[2] or Configs.Text or "Ini adalah dialog"
        local DOptions = Configs[3] or Configs.Options or {}

        local Frame = Create("Frame", {
            Active = true,
            Size = UDim2.fromOffset(250 * 1.08, 150 * 1.08),
            Position = UDim2.fromScale(0.5, 0.5),
            AnchorPoint = Vector2.new(0.5, 0.5),
            ZIndex = 200
        }, {
            InsertTheme(Create("TextLabel", {
                Font = Enum.Font.GothamBold,
                Size = UDim2.new(1, 0, 0, 20),
                Text = DTitle,
                TextXAlignment = "Left",
                TextColor3 = Theme["Color Text"],
                TextSize = 15,
                Position = UDim2.fromOffset(15, 5),
                BackgroundTransparency = 1,
                ZIndex = 201
            }), "Text"),
            InsertTheme(Create("TextLabel", {
                Font = Enum.Font.GothamMedium,
                Size = UDim2.new(1, -25),
                AutomaticSize = "Y",
                Text = DText,
                TextXAlignment = "Left",
                TextColor3 = Theme["Color Dark Text"],
                TextSize = 12,
                Position = UDim2.fromOffset(15, 25),
                BackgroundTransparency = 1,
                TextWrapped = true,
                ZIndex = 201
            }), "DarkText")
        }) 
        Make("Gradient", Frame, {Rotation = 270}) 
        Make("Corner", Frame)

        local ButtonsHolder = Create("Frame", Frame, {
            Size = UDim2.fromScale(1, 0.35),
            Position = UDim2.fromScale(0, 1),
            AnchorPoint = Vector2.new(0, 1),
            BackgroundColor3 = Theme["Color Hub 2"],
            BackgroundTransparency = 1,
            ZIndex = 201
        }, {
            Create("UIListLayout", {
                Padding = UDim.new(0, 10),
                VerticalAlignment = "Center",
                FillDirection = "Horizontal",
                HorizontalAlignment = "Center"
            })
        })

        local Screen = InsertTheme(Create("Frame", MainFrame, {
            BackgroundTransparency = 0.6,
            Active = true,
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundColor3 = Theme["Color Stroke"],
            Name = "Dialog",
            ZIndex = 150
        }), "Stroke")

        MainCorner:Clone().Parent = Screen
        Frame.Parent = Screen

        for _, child in pairs(Frame:GetDescendants()) do
            if child:IsA("TextLabel") or child:IsA("TextButton") or child:IsA("Frame") then
                child.ZIndex = math.max(child.ZIndex or 1, 200)
            end
        end

        CreateTween({Frame, "Size", UDim2.fromOffset(250, 150), 0.2})
        CreateTween({Frame, "Transparency", 0, 0.15})
        CreateTween({Screen, "Transparency", 0.3, 0.15})

        local ButtonCount, Dialog = 1, {}
        function Dialog:Button(Configs)
            local Name = Configs[1] or Configs.Name or Configs.Title or ""
            local Callback = Configs[2] or Configs.Callback or function()end

            ButtonCount = ButtonCount + 1
            local Button = Make("Button", ButtonsHolder)
            Make("Corner", Button)
            SetProps(Button, {
                Text = Name,
                Font = Enum.Font.GothamBold,
                TextColor3 = Theme["Color Text"],
                TextSize = 12,
                ZIndex = 202
            })

            for _,Btn in pairs(ButtonsHolder:GetChildren()) do
                if Btn:IsA("TextButton") then
                    Btn.Size = UDim2.new(1 / ButtonCount, -(((ButtonCount - 1) * 20) / ButtonCount), 0, 32)
                    Btn.ZIndex = 202
                end
            end
            Button.Activated:Connect(Dialog.Close)
            Button.Activated:Connect(Callback)
        end
        function Dialog:Close()
            CreateTween({Frame, "Size", UDim2.fromOffset(250 * 1.08, 150 * 1.08), 0.2})
            CreateTween({Screen, "Transparency", 1, 0.15})
            CreateTween({Frame, "Transparency", 1, 0.15, true})
            Screen:Destroy()
        end
        table.foreach(DOptions, function(_,Button)
            Dialog:Button(Button)
        end)
        return Dialog
    end

    function Window:SelectTab(TabSelect)
        if type(TabSelect) == "number" then
            bearlib.Tabs[TabSelect].func:Enable()
        else
            for _,Tab in pairs(bearlib.Tabs) do
                if Tab.Cont == TabSelect.Cont then
                    Tab.func:Enable()
                end
            end
        end
    end

    local ContainerList = {}
    function Window:MakeTab(paste, Configs)
        if type(paste) == "table" then Configs = paste end
        local TName = Configs[1] or Configs.Title or "Tab!"
        local TIcon = Configs[2] or Configs.Icon or ""

        TIcon = bearlib:GetIcon(TIcon)
        if not TIcon:find("rbxassetid://") or TIcon:gsub("rbxassetid://", ""):len() < 6 then
            TIcon = false
        end

        local TabSelect = Make("Button", MainScroll, {
            Size = UDim2.new(1, 0, 0, 24)
        }) Make("Corner", TabSelect)

        local LabelTitle = InsertTheme(Create("TextLabel", TabSelect, {
            Size = UDim2.new(1, TIcon and -25 or -15, 1),
            Position = UDim2.fromOffset(TIcon and 25 or 15),
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamMedium,
            Text = TName,
            TextColor3 = Theme["Color Text"],
            TextSize = 10,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTransparency = (FirstTab and 0.3) or 0,
            TextTruncate = "AtEnd",
            ZIndex = 5
        }), "Text")

        local LabelIcon = InsertTheme(Create("ImageLabel", TabSelect, {
            Position = UDim2.new(0, 8, 0.5),
            Size = UDim2.new(0, 13, 0, 13),
            AnchorPoint = Vector2.new(0, 0.5),
            Image = TIcon or "",
            BackgroundTransparency = 1,
            ImageTransparency = (FirstTab and 0.3) or 0,
            ImageColor3 = Theme["Color Text"],
            ZIndex = 5
        }), "Text")

        local Selected = InsertTheme(Create("Frame", TabSelect, {
            Size = FirstTab and UDim2.new(0, 4, 0, 4) or UDim2.new(0, 4, 0, 13),
            Position = UDim2.new(0, 1, 0.5),
            AnchorPoint = Vector2.new(0, 0.5),
            BackgroundColor3 = Theme["Color Theme"],
            BackgroundTransparency = FirstTab and 1 or 0,
            ZIndex = 4
        }), "Theme") Make("Corner", Selected, UDim.new(0.5, 0))

        local Container = InsertTheme(Create("ScrollingFrame", {
            Size = UDim2.new(1, 0, 1, 0),
            Position = UDim2.new(0, 0, 1),
            AnchorPoint = Vector2.new(0, 1),
            ScrollBarThickness = 1.5,
            BackgroundTransparency = 1,
            ScrollBarImageTransparency = 0.2,
            ScrollBarImageColor3 = Theme["Color Theme"],
            AutomaticCanvasSize = "Y",
            ScrollingDirection = "Y",
            BorderSizePixel = 0,
            CanvasSize = UDim2.new(),
            Name = ("Container %i [ %s ]"):format(#ContainerList + 1, TName),
            ZIndex = 1
        }, {
            Create("UIPadding", {
                PaddingLeft = UDim.new(0, 10),
                PaddingRight = UDim.new(0, 10),
                PaddingTop = UDim.new(0, 10),
                PaddingBottom = UDim.new(0, 10)
            }), Create("UIListLayout", {
                Padding = UDim.new(0, 5),
                SortOrder = "LayoutOrder"
            })
        }), "ScrollBar")

        table.insert(ContainerList, Container)

        if not FirstTab then Container.Parent = Containers end

        local function Tabs()
            if Container.Parent then return end
            for _,Frame in pairs(ContainerList) do
                if Frame:IsA("ScrollingFrame") and Frame ~= Container then
                    Frame.Parent = nil
                end
            end
            Container.Parent = Containers
            Container.Size = UDim2.new(1, 0, 1, 150)
            table.foreach(bearlib.Tabs, function(_,Tab)
                if Tab.Cont ~= Container then
                    Tab.func:Disable()
                end
            end)
            CreateTween({Container, "Size", UDim2.new(1, 0, 1, 0), 0.3})
            CreateTween({LabelTitle, "TextTransparency", 0, 0.35})
            CreateTween({LabelIcon, "ImageTransparency", 0, 0.35})
            CreateTween({Selected, "Size", UDim2.new(0, 4, 0, 13), 0.35})
            CreateTween({Selected, "BackgroundTransparency", 0, 0.35})
        end
        TabSelect.Activated:Connect(Tabs)

        FirstTab = true
        local Tab = {}
        table.insert(bearlib.Tabs, {TabInfo = {Name = TName, Icon = TIcon}, func = Tab, Cont = Container})
        Tab.Cont = Container

        local ElementCount = 0
        local function GetOrder()
            ElementCount = ElementCount + 1
            return ElementCount
        end

        function Tab:Disable()
            Container.Parent = nil
            CreateTween({LabelTitle, "TextTransparency", 0.3, 0.35})
            CreateTween({LabelIcon, "ImageTransparency", 0.3, 0.35})
            CreateTween({Selected, "Size", UDim2.new(0, 4, 0, 4), 0.35})
            CreateTween({Selected, "BackgroundTransparency", 1, 0.35})
        end
        function Tab:Enable()
            Tabs()
        end
        function Tab:Visible(Bool)
            Funcs:ToggleVisible(TabSelect, Bool)
        end
        function Tab:Destroy() TabSelect:Destroy() Container:Destroy() end

        local CurrentSectionName = nil

        function Tab:AddSection(Configs)
            local SectionName = type(Configs) == "string" and Configs or Configs[1] or Configs.Name or Configs.Title or Configs.Section
            CurrentSectionName = SectionName

            local SectionFrame = Create("Frame", Container, {
                Size = UDim2.new(1, 0, 0, 30),
                BackgroundTransparency = 1,
                Name = "Option",
                LayoutOrder = GetOrder(),
                ZIndex = 2
            })

            local SectionLabel = InsertTheme(Create("TextLabel", SectionFrame, {
                Font = Enum.Font.GothamBold,
                Text = SectionName,
                TextColor3 = Theme["Color Text"],
                Size = UDim2.new(1, -25, 0, 18),
                Position = UDim2.new(0, 5, 0, 0),
                BackgroundTransparency = 1,
                TextTruncate = "AtEnd",
                TextSize = 14,
                TextXAlignment = "Left",
                ZIndex = 3
            }), "Text")

            local UnderlineFrame = Create("Frame", SectionFrame, {
                Size = UDim2.new(1, -10, 0, 1.5),
                Position = UDim2.new(0, 5, 1, -5),
                BackgroundColor3 = Theme["UI Border Color"],
                BackgroundTransparency = 0,
                BorderSizePixel = 0,
                ZIndex = 2
            })

            table.insert(bearlib.Instances, {
                Instance = UnderlineFrame,
                Type = "UIBorder"
            })

            local UnderlineGradient = Instance.new("UIGradient")
            UnderlineGradient.Rotation = 90
            UnderlineGradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0.00, Theme["UI Border Color"]),
                ColorSequenceKeypoint.new(0.50, Theme["Color Theme"]),
                ColorSequenceKeypoint.new(1.00, Theme["UI Border Color"])
            })
            UnderlineGradient.Parent = UnderlineFrame

            table.insert(bearlib.Instances, {
                Instance = UnderlineGradient,
                Type = "Gradient"
            })

            table.insert(bearlib.AllElements, {
                Name = SectionName,
                Instance = SectionFrame,
                OriginalParent = Container,
                SectionName = SectionName,
                Underline = UnderlineFrame,
                UnderlineGradient = UnderlineGradient
            })

            local Section = {}
            table.insert(bearlib.Options, {type = "Section", Name = SectionName, func = Section})

            function Section:Visible(Bool)
                if Bool == nil then 
                    SectionFrame.Visible = not SectionFrame.Visible 
                    return 
                end
                SectionFrame.Visible = Bool
            end

            function Section:Destroy()
                SectionFrame:Destroy()
            end

            function Section:Set(New)
                if New then
                    SectionLabel.Text = GetStr(New)
                end
            end

            return Section
        end

        function Tab:AddParagraph(Configs)
            local PName = Configs[1] or Configs.Title or "Paragraf"
            local PDesc = Configs[2] or Configs.Text or ""

            local Frame, LabelFunc = ButtonFrame(Container, PName, PDesc, UDim2.new(1, -20))
            Frame.LayoutOrder = GetOrder()

            table.insert(bearlib.AllElements, {
                Name = PName,
                Instance = Frame,
                OriginalParent = Container,
                SectionName = CurrentSectionName
            })

            local Paragraph = {}
            function Paragraph:Visible(...) Funcs:ToggleVisible(Frame, ...) end
            function Paragraph:Destroy() Frame:Destroy() end
            function Paragraph:SetTitle(Val)
                LabelFunc:SetTitle(GetStr(Val))
            end
            function Paragraph:SetDesc(Val)
                LabelFunc:SetDesc(GetStr(Val))
            end
            function Paragraph:Set(Val1, Val2)
                if Val1 and Val2 then
                    LabelFunc:SetTitle(GetStr(Val1))
                    LabelFunc:SetDesc(GetStr(Val2))
                elseif Val1 then
                    LabelFunc:SetDesc(GetStr(Val1))
                end
            end
            return Paragraph
        end

        function Tab:AddButton(Configs)
            local BName = Configs[1] or Configs.Name or Configs.Title or "Tombol!"
            local BDescription = Configs.Desc or Configs.Description or ""
            local Callback = Funcs:GetCallback(Configs, 2)

            local FButton, LabelFunc = ButtonFrame(Container, BName, BDescription, UDim2.new(1, -20))
            FButton.LayoutOrder = GetOrder()

            local ButtonIcon = Create("ImageLabel", FButton, {
                Size = UDim2.new(0, 14, 0, 14),
                Position = UDim2.new(1, -10, 0.5),
                AnchorPoint = Vector2.new(1, 0.5),
                BackgroundTransparency = 1,
                Image = "rbxassetid://10709791437",
                ZIndex = 5
            })

            FButton.Activated:Connect(function()
                Funcs:FireCallback(Callback)
            end)

            table.insert(bearlib.AllElements, {
                Name = BName,
                Instance = FButton,
                OriginalParent = Container,
                SectionName = CurrentSectionName
            })

            local Button = {}
            function Button:Visible(...) Funcs:ToggleVisible(FButton, ...) end
            function Button:Destroy() FButton:Destroy() end
            function Button:Callback(...) Funcs:InsertCallback(Callback, ...)() end
            function Button:Set(Val1, Val2)
                if type(Val1) == "string" and type(Val2) == "string" then
                    LabelFunc:SetTitle(Val1)
                    LabelFunc:SetDesc(Val2)
                elseif type(Val1) == "string" then
                    LabelFunc:SetTitle(Val1)
                elseif type(Val1) == "function" then
                    Callback = Val1
                end
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

            local ToggleHolder = InsertTheme(Create("Frame", Button, {
                Size = UDim2.new(0, 35, 0, 18),
                Position = UDim2.new(1, -10, 0.5),
                AnchorPoint = Vector2.new(1, 0.5),
                BackgroundColor3 = Theme["Color Toggle Off"],
                ZIndex = 4
            }), "Stroke")
            Make("Corner", ToggleHolder, UDim.new(0.5, 0))

            local Slider = Create("Frame", ToggleHolder, {
                BackgroundTransparency = 1,
                Size = UDim2.new(0.8, 0, 0.8, 0),
                Position = UDim2.new(0.5, 0, 0.5, 0),
                AnchorPoint = Vector2.new(0.5, 0.5),
                ZIndex = 4
            })

            local Toggle = InsertTheme(Create("Frame", Slider, {
                Size = UDim2.new(0, 12, 0, 12),
                Position = UDim2.new(0, 0, 0.5),
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundColor3 = Theme["Color Toggle Knob Off"],
                ZIndex = 5
            }), "Theme")
            Make("Corner", Toggle, UDim.new(0.5, 0))

            local WaitClick
            local function SetToggle(Val)
                if WaitClick then return end

                WaitClick, Default = true, Val
                SetFlag(Flag, Default)
                Funcs:FireCallback(Callback, Default)
                if Default then
                    CreateTween({Toggle, "Position", UDim2.new(1, 0, 0.5), 0.25})
                    CreateTween({Toggle, "BackgroundColor3", Theme["Color Toggle Knob On"], 0.25})
                    CreateTween({Toggle, "AnchorPoint", Vector2.new(1, 0.5), 0.25})
                    CreateTween({ToggleHolder, "BackgroundColor3", Theme["Color Toggle On"], 0.25})
                else
                    CreateTween({Toggle, "Position", UDim2.new(0, 0, 0.5), 0.25})
                    CreateTween({Toggle, "BackgroundColor3", Theme["Color Toggle Knob Off"], 0.25})
                    CreateTween({Toggle, "AnchorPoint", Vector2.new(0, 0.5), 0.25})
                    CreateTween({ToggleHolder, "BackgroundColor3", Theme["Color Toggle Off"], 0.25})
                end
                WaitClick = false
            end
            task.spawn(SetToggle, Default)

            Button.Activated:Connect(function()
                SetToggle(not Default)
            end)

            table.insert(bearlib.AllElements, {
                Name = TName,
                Instance = Button,
                OriginalParent = Container,
                SectionName = CurrentSectionName
            })

            local Toggle = {}
            function Toggle:Visible(...) Funcs:ToggleVisible(Button, ...) end
            function Toggle:Destroy() Button:Destroy() end
            function Toggle:Callback(...) Funcs:InsertCallback(Callback, ...)() end
            function Toggle:Set(Val1, Val2)
                if type(Val1) == "string" and type(Val2) == "string" then
                    LabelFunc:SetTitle(Val1)
                    LabelFunc:SetDesc(Val2)
                elseif type(Val1) == "string" then
                    LabelFunc:SetTitle(Val1)
                elseif type(Val1) == "boolean" then
                    if WaitClick and Val2 then
                        repeat task.wait() until not WaitClick
                    end
                    task.spawn(SetToggle, Val1)
                elseif type(Val1) == "function" then
                    Callback = Val1
                end
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

            local SelectedFrame = InsertTheme(Create("Frame", Button, {
                Size = UDim2.new(0, 150, 0, 18),
                Position = UDim2.new(1, -10, 0.5),
                AnchorPoint = Vector2.new(1, 0.5),
                BackgroundColor3 = Theme["Color Stroke"],
                ZIndex = 4
            }), "Stroke") Make("Corner", SelectedFrame, UDim.new(0, 4))

            local ActiveLabel = InsertTheme(Create("TextLabel", SelectedFrame, {
                Size = UDim2.new(0.85, 0, 0.85, 0),
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.new(0.5, 0, 0.5, 0),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBold,
                TextScaled = true,
                TextColor3 = Theme["Color Text"],
                Text = "...",
                ZIndex = 5
            }), "Text")

            local Arrow = Create("ImageLabel", SelectedFrame, {
                Size = UDim2.new(0, 15, 0, 15),
                Position = UDim2.new(0, -5, 0.5),
                AnchorPoint = Vector2.new(1, 0.5),
                Image = "rbxassetid://10709791523",
                BackgroundTransparency = 1,
                ZIndex = 5
            })

            local NoClickFrame = Create("TextButton", DropdownHolder, {
                Name = "AntiClick",
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Visible = false,
                Text = ""
            })

            local DropFrame = Create("Frame", NoClickFrame, {
                Size = UDim2.new(SelectedFrame.Size.X, 0, 0),
                BackgroundTransparency = 0.1,
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                AnchorPoint = Vector2.new(0, 1),
                Name = "DropdownFrame",
                ClipsDescendants = true,
                Active = true,
                ZIndex = 5
            }) Make("Corner", DropFrame) Make("Stroke", DropFrame) Make("Gradient", DropFrame, {Rotation = 60})

            local ScrollFrame = InsertTheme(Create("ScrollingFrame", DropFrame, {
                ScrollBarImageColor3 = Theme["Color Theme"],
                Size = UDim2.new(1, 0, 1, 0),
                ScrollBarThickness = 1.5,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                CanvasSize = UDim2.new(),
                ScrollingDirection = "Y",
                AutomaticCanvasSize = "Y",
                Active = true,
                ZIndex = 6
            }, {
                Create("UIPadding", {
                    PaddingLeft = UDim.new(0, 8),
                    PaddingRight = UDim.new(0, 8),
                    PaddingTop = UDim.new(0, 5),
                    PaddingBottom = UDim.new(0, 5)
                }), Create("UIListLayout", {
                    Padding = UDim.new(0, 4)
                })
            }), "ScrollBar")

            local ScrollSize, WaitClick = 5
            local function Disable()
                WaitClick = true
                CreateTween({Arrow, "Rotation", 0, 0.2})
                CreateTween({DropFrame, "Size", UDim2.new(0, 152, 0, 0), 0.2, true})
                CreateTween({Arrow, "ImageColor3", Color3.fromRGB(255, 255, 255), 0.2})
                Arrow.Image = "rbxassetid://10709791523"
                NoClickFrame.Visible = false
                WaitClick = false
            end

            local function GetFrameSize()
                return UDim2.fromOffset(152, ScrollSize)
            end

            local function CalculateSize()
                local Count = 0
                for _,Frame in pairs(ScrollFrame:GetChildren()) do
                    if Frame:IsA("Frame") or Frame.Name == "Option" then
                        Count = Count + 1
                    end
                end
                ScrollSize = (math.clamp(Count, 0, 10) * 25) + 10
                if NoClickFrame.Visible then
                    NoClickFrame.Visible = true
                    CreateTween({DropFrame, "Size", GetFrameSize(), 0.2, true})
                end
            end

            local function Minimize()
                if WaitClick then return end
                WaitClick = true
                if NoClickFrame.Visible then
                    Arrow.Image = "rbxassetid://10709791523"
                    CreateTween({Arrow, "ImageColor3", Color3.fromRGB(255, 255, 255), 0.2})
                    CreateTween({DropFrame, "Size", UDim2.new(0, 152, 0, 0), 0.2, true})
                    NoClickFrame.Visible = false
                else
                    NoClickFrame.Visible = true
                    Arrow.Image = "rbxassetid://10709790948"
                    CreateTween({Arrow, "ImageColor3", Theme["Color Theme"], 0.2})
                    CreateTween({DropFrame, "Size", GetFrameSize(), 0.2, true})
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

            local AddNewOptions, GetOptions, AddOption, RemoveOption, Selected do
                local Default = type(OpDefault) ~= "table" and {OpDefault} or OpDefault
                local MultiSelect = DMultiSelect
                local Options = {}
                Selected = MultiSelect and {} or CheckFlag(Flag) and GetFlag(Flag) or Default[1]

                if MultiSelect then
                    for index, Value in pairs(CheckFlag(Flag) and GetFlag(Flag) or Default) do
                        if type(index) == "string" and (DOptions[index] or table.find(DOptions, index)) then
                            Selected[index] = Value
                        elseif DOptions[Value] then
                            Selected[Value] = true
                        end
                    end
                end

                local function CallbackSelected()
                    SetFlag(Flag, MultiSelect and Selected or tostring(Selected))
                    Funcs:FireCallback(Callback, Selected)
                end

                local function UpdateLabel()
                    if MultiSelect then
                        local list = {}
                        for index, Value in pairs(Selected) do
                            if Value then
                                table.insert(list, index)
                            end
                        end
                        ActiveLabel.Text = #list > 0 and table.concat(list, ", ") or "..."
                    else
                        ActiveLabel.Text = tostring(Selected or "...")
                    end
                end

                local function UpdateSelected()
                    if MultiSelect then
                        for _,v in pairs(Options) do
                            local nodes, Stats = v.nodes, v.Stats
                            CreateTween({nodes[2], "BackgroundTransparency", Stats and 0 or 0.8, 0.35})
                            CreateTween({nodes[2], "Size", Stats and UDim2.fromOffset(4, 12) or UDim2.fromOffset(4, 4), 0.35})
                            CreateTween({nodes[3], "TextTransparency", Stats and 0 or 0.4, 0.35})
                        end
                    else
                        for _,v in pairs(Options) do
                            local Slt = v.Value == Selected
                            local nodes = v.nodes
                            CreateTween({nodes[2], "BackgroundTransparency", Slt and 0 or 1, 0.35})
                            CreateTween({nodes[2], "Size", Slt and UDim2.fromOffset(4, 14) or UDim2.fromOffset(4, 4), 0.35})
                            CreateTween({nodes[3], "TextTransparency", Slt and 0 or 0.4, 0.35})
                        end
                    end
                    UpdateLabel()
                end

                local function Select(Option)
                    if MultiSelect then
                        Option.Stats = not Option.Stats
                        Option.LastCB = tick()

                        Selected[Option.Name] = Option.Stats
                        CallbackSelected()
                    else
                        Option.LastCB = tick()

                        Selected = Option.Value
                        CallbackSelected()
                    end
                    UpdateSelected()
                end

                AddOption = function(index, Value)
                    local Name = tostring(type(index) == "string" and index or Value)
                    local OptionValue = type(index) == "table" and Value or index

                    if Options[Name] then return end
                    Options[Name] = {
                        index = index,
                        Value = OptionValue,
                        Name = Name,
                        nodes = {}
                    }

                    local Holder = Create("Frame", ScrollFrame, {
                        Size = UDim2.new(1, -8, 0, 18),
                        Name = "Option",
                        BackgroundTransparency = 1,
                        ZIndex = 7
                    })

                    local Point = InsertTheme(Create("Frame", Holder, {
                        Size = UDim2.fromOffset(4, 4),
                        Position = UDim2.new(0, 2, 0.5),
                        AnchorPoint = Vector2.new(0, 0.5),
                        BackgroundColor3 = Theme["Color Theme"],
                        ZIndex = 8
                    }), "Theme")
                    Make("Corner", Point, UDim.new(0.5, 0))

                    local Text = InsertTheme(Create("TextLabel", Holder, {
                        Size = UDim2.new(1, -16, 1, 0),
                        Position = UDim2.new(0, 12, 0.5),
                        AnchorPoint = Vector2.new(0, 0.5),
                        BackgroundTransparency = 1,
                        Text = Name,
                        TextXAlignment = "Left",
                        Font = Enum.Font.Gotham,
                        TextColor3 = Theme["Color Text"],
                        TextSize = 10,
                        ZIndex = 8
                    }), "Text")

                    local Stroke = InsertTheme(Create("UIStroke", Holder, {
                        Color = Theme["Color Stroke"],
                        Thickness = 0.5,
                        ApplyStrokeMode = "Border"
                    }), "Stroke")
                    Stroke.Enabled = false

                    local Option = {
                        Name = Name,
                        Value = OptionValue,
                        nodes = {Holder, Point, Text, Stroke},
                        Stats = type(Selected) == "table" and Selected[Name] or Value == Selected
                    }

                    if Option.Stats then
                        CreateTween({Point, "BackgroundTransparency", 0, 0})
                        CreateTween({Point, "Size", MultiSelect and UDim2.fromOffset(4, 12) or UDim2.fromOffset(4, 14), 0})
                        CreateTween({Text, "TextTransparency", 0, 0})
                        if MultiSelect then
                            Stroke.Enabled = true
                        end
                    else
                        CreateTween({Point, "BackgroundTransparency", 1, 0})
                        CreateTween({Point, "Size", UDim2.fromOffset(4, 4), 0})
                        CreateTween({Text, "TextTransparency", 0.4, 0})
                    end

                    if MultiSelect then
                        Holder.MouseEnter:Connect(function()
                            Stroke.Enabled = true
                        end)
                        Holder.MouseLeave:Connect(function()
                            if not Option.Stats then
                                Stroke.Enabled = false
                            end
                        end)
                    end

                    Holder.MouseButton1Click:Connect(function()
                        if (tick() - (Option.LastCB or 0)) > 0.15 then
                            Select(Option)
                        end
                    end)

                    Options[Name] = Option
                    return Holder
                end

                function GetOptions()
                    return Options
                end

                function RemoveOption(name)
                    if Options[name] then
                        Options[name].nodes[1]:Destroy()
                        Options[name] = nil
                    end
                end

                function AddNewOptions(newOptions)
                    for i,v in pairs(newOptions) do
                        AddOption(i,v)
                    end
                    CalculateSize()
                    UpdateSelected()
                end

                AddNewOptions(DOptions)
                SelectedFrame.MouseButton1Click:Connect(Minimize)
                UserInputService.InputBegan:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 and NoClickFrame.Visible then
                        if not DropFrame:IsHovered() and not SelectedFrame:IsHovered() then
                            Disable()
                        end
                    end
                end)
                SelectedFrame:GetPropertyChangedSignal("AbsolutePosition"):Connect(CalculatePos)
            end

            table.insert(bearlib.AllElements, {
                Name = DName,
                Instance = Button,
                OriginalParent = Container,
                SectionName = CurrentSectionName
            })

            local Dropdown = {}
            function Dropdown:Refresh(Options)
                Options = type(Options) == "table" and Options or {}
                local list = {}
                for _,Option in pairs(Options) do
                    AddOption(Option, Option)
                end
                for _,Option in pairs(GetOptions()) do
                    if not table.find(Options, Option.Name) then
                        RemoveOption(Option.Name)
                    end
                end
                if MultiSelect then
                    Selected = {}
                end
                UpdateSelected()
                CalculateSize()
                task.spawn(CallbackSelected)
            end

            function Dropdown:Set(Val)
                if type(Val) == "string" or type(Val) == "number" then
                    local Option = GetOptions()[tostring(Val)]
                    if Option then
                        Select(Option)
                        UpdateLabel()
                    end
                elseif type(Val) == "table" then
                    for i,v in pairs(GetOptions()) do
                        if table.find(Val, v.Value) or table.find(Val, v.Name) then
                            Select(v)
                        end
                    end
                    UpdateLabel()
                end
            end

            function Dropdown:Add(Val1, Val2)
                AddOption(Val1, Val2)
                CalculateSize()
                UpdateSelected()
                CallbackSelected()
            end

            function Dropdown:Clear()
                for _,Option in pairs(GetOptions()) do
                    RemoveOption(Option.Name)
                end
                if MultiSelect then
                    Selected = {}
                else
                    Selected = ""
                end
                UpdateLabel()
                CallbackSelected()
                CalculateSize()
            end

            function Dropdown:Visible(...) Funcs:ToggleVisible(Button, ...) end
            function Dropdown:Destroy() Button:Destroy() NoClickFrame:Destroy() end
            function Dropdown:Callback(...) Funcs:InsertCallback(Callback, ...)() end
            return Dropdown
        end

        function Tab:AddTextBox(Configs)
            local TName = Configs[1] or Configs.Name or Configs.Title or "TextBox"
            local TDesc = Configs.Desc or Configs.Description or ""
            local Placeholder = Configs.Placeholder or Configs.PlaceHolder or ""
            local Flag = Configs[3] or Configs.Flag or false
            local Callback = Funcs:GetCallback(Configs, 2)
            local Default = CheckFlag(Flag) and GetFlag(Flag) or Configs.Default or ""

            local Button, LabelFunc = ButtonFrame(Container, TName, TDesc, UDim2.new(1, -180))
            Button.LayoutOrder = GetOrder()

            local BoxHolder = InsertTheme(Create("Frame", Button, {
                Size = UDim2.new(0, 150, 0, 18),
                Position = UDim2.new(1, -10, 0.5),
                AnchorPoint = Vector2.new(1, 0.5),
                BackgroundColor3 = Theme["Color Stroke"],
                ZIndex = 4
            }), "Stroke")
            Make("Corner", BoxHolder, UDim.new(0, 4))

            local Box = InsertTheme(Create("TextBox", BoxHolder, {
                Size = UDim2.new(0.9, 0, 0.9, 0),
                Position = UDim2.new(0.5, 0, 0.5, 0),
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBold,
                TextScaled = true,
                TextColor3 = Theme["Color Text"],
                Text = Default,
                PlaceholderText = Placeholder,
                ZIndex = 5
            }), "Text")

            local WaitClick
            local function SetTextbox(Val)
                if WaitClick then return end
                WaitClick = true
                SetFlag(Flag, Val)
                Funcs:FireCallback(Callback, Val)
                WaitClick = false
            end

            Box.FocusLost:Connect(function(enterPressed)
                if enterPressed then
                    SetTextbox(Box.Text)
                end
            end)

            table.insert(bearlib.AllElements, {
                Name = TName,
                Instance = Button,
                OriginalParent = Container,
                SectionName = CurrentSectionName
            })

            local TextBox = {}
            function TextBox:Visible(...) Funcs:ToggleVisible(Button, ...) end
            function TextBox:Destroy() Button:Destroy() end
            function TextBox:Set(Val1, Val2)
                if type(Val1) == "string" and type(Val2) == "string" then
                    LabelFunc:SetTitle(Val1)
                    LabelFunc:SetDesc(Val2)
                elseif type(Val1) == "string" then
                    LabelFunc:SetTitle(Val1)
                elseif type(Val1) == "function" then
                    Callback = Val1
                end
            end
            function TextBox:SetValue(Val)
                Box.Text = tostring(Val)
                SetFlag(Flag, Box.Text)
                Funcs:FireCallback(Callback, Box.Text)
            end
            return TextBox
        end

        function Tab:AddSlider(Configs)
            local SName = Configs[1] or Configs.Name or Configs.Title or "Slider"
            local SDesc = Configs.Desc or Configs.Description or ""
            local Min = Configs.Min or 0
            local Max = Configs.Max or 10
            local Default = Configs.Default or Min
            local Increment = Configs.Increment or 1
            local Flag = Configs[5] or Configs.Flag or false
            local Callback = Funcs:GetCallback(Configs, 2)

            local Button, LabelFunc = ButtonFrame(Container, SName, SDesc, UDim2.new(1, -180))
            Button.LayoutOrder = GetOrder()

            local SliderFrame = InsertTheme(Create("Frame", Button, {
                Size = UDim2.new(0, 150, 0, 18),
                Position = UDim2.new(1, -10, 0.5),
                AnchorPoint = Vector2.new(1, 0.5),
                BackgroundColor3 = Theme["Color Hub 2"],
                ZIndex = 4
            }), "Frame")
            Make("Corner", SliderFrame, UDim.new(0, 4))
            Make("Stroke", SliderFrame)

            local SliderBar = Create("Frame", SliderFrame, {
                Size = UDim2.new(0, 0, 1, 0),
                BackgroundColor3 = Theme["Color Theme"],
                ZIndex = 5
            })
            Make("Corner", SliderBar, UDim.new(0, 4))

            local ValueLabel = InsertTheme(Create("TextLabel", SliderFrame, {
                Size = UDim2.new(0.8, 0, 0.8, 0),
                Position = UDim2.new(0.5, 0, 0.5, 0),
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBold,
                TextScaled = true,
                Text = tostring(Default),
                TextColor3 = Theme["Color Text"],
                ZIndex = 6
            }), "Text")

            local function SetValue(Value)
                Value = math.clamp(Value, Min, Max)
                local Percent = (Value - Min) / (Max - Min)
                SliderBar.Size = UDim2.new(Percent, 0, 1, 0)
                ValueLabel.Text = tostring(Value)
                SetFlag(Flag, Value)
                Funcs:FireCallback(Callback, Value)
            end

            SetValue(Default)

            local Dragging = false
            SliderFrame.InputBegan:Connect(function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                    Dragging = true
                    local Percent = (Input.Position.X - SliderFrame.AbsolutePosition.X) / SliderFrame.AbsoluteSize.X
                    local Value = Min + ((Max - Min) * math.clamp(Percent, 0, 1))
                    local RoundedValue = math.round(Value / Increment) * Increment
                    SetValue(RoundedValue)
                end
            end)

            UserInputService.InputEnded:Connect(function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                    Dragging = false
                end
            end)

            UserInputService.InputChanged:Connect(function(Input)
                if Dragging and Input.UserInputType == Enum.UserInputType.MouseMovement then
                    local Percent = (Input.Position.X - SliderFrame.AbsolutePosition.X) / SliderFrame.AbsoluteSize.X
                    local Value = Min + ((Max - Min) * math.clamp(Percent, 0, 1))
                    local RoundedValue = math.round(Value / Increment) * Increment
                    SetValue(RoundedValue)
                end
            end)

            table.insert(bearlib.AllElements, {
                Name = SName,
                Instance = Button,
                OriginalParent = Container,
                SectionName = CurrentSectionName
            })

            local Slider = {}
            function Slider:Visible(...) Funcs:ToggleVisible(Button, ...) end
            function Slider:Destroy() Button:Destroy() end
            function Slider:Set(Val1, Val2)
                if type(Val1) == "string" and type(Val2) == "string" then
                    LabelFunc:SetTitle(Val1)
                    LabelFunc:SetDesc(Val2)
                elseif type(Val1) == "string" then
                    LabelFunc:SetTitle(Val1)
                elseif type(Val1) == "function" then
                    Callback = Val1
                end
            end
            function Slider:SetValue(Value)
                SetValue(Value)
            end
            return Slider
        end

        return Tab
    end

    Window.Close = Window.CloseBtn
    CloseButton.Activated:Connect(Window.Close)
    MinimizeButton.Activated:Connect(Window.MinimizeBtn)

    return Window
end

return bearlib
