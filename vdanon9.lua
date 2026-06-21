--[[
╔══════════════════════════════════════════════════════════════════╗
║   Anonymous9x Vd                                                 ║
║   not a great script                                             ║
║   By Anonymous9x                                                 ║
╠══════════════════════════════════════════════════════════════════╣
║   ARCHITECTURE — 1 FILE (No Key System)                         ║
║   Full GUI + every feature's logic, built on Luna Interface      ║
║   Suite. No external key list required.                          ║
║                                                                  ║
║   >>> PASTE YOUR DISCORD INVITE CODE BELOW (DISCORD_CODE) <<<    ║
║                                                                  ║
║   Every feature's underlying LOGIC is carried over unmodified    ║
║   from the source you provided. Only the UI-construction layer   ║
║   (Tab/Section/Toggle/Slider/etc calls) was rewritten for Luna.  ║
║   One real bug from the source was fixed: `safeNotify` was       ║
║   called by the No-Skillcheck system before it was ever defined  ║
║   (a local declared later in the file) — it is now defined right ║
║   after Luna loads, before anything can call it.                 ║
╚══════════════════════════════════════════════════════════════════╝
]]

-- ════════════════════════════════════════════════════════════════
-- EDIT THIS LINE
-- ════════════════════════════════════════════════════════════════
local DISCORD_CODE  = "https://discord.gg/ptvyFfK3pU"   -- no "discord.gg/" prefix

-- ════════════════════════════════════════════════════════════════
-- LOAD LUNA INTERFACE SUITE
-- ════════════════════════════════════════════════════════════════
local Luna = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/Nebula-Softworks/Luna-Interface-Suite/refs/heads/master/source.lua",
    true
))()

-- ════════════════════════════════════════════════════════════════
-- ANONYMOUS9x BRANDED NOTIFICATION WRAPPER
-- Defined immediately so every later system can safely call it.
-- (Fixes the source's ordering bug — see header note above.)
-- ════════════════════════════════════════════════════════════════
local LOGO_ASSET_ID = "97269958324726"

local function safeNotify(title, content, duration)
    -- `duration` kept for call-site compatibility with the ported logic;
    -- Luna's own example computes display time automatically and has no
    -- documented Duration field, so it is not passed through.
    Luna:Notification({
        Title       = title,
        Content     = content,
        Icon        = LOGO_ASSET_ID,
        ImageSource = "Roblox",   -- best-effort guess, see header note
    })
end

-- ════════════════════════════════════════════════════════════════
-- SERVICES
-- ════════════════════════════════════════════════════════════════
local RunService        = game:GetService("RunService")
local Players            = game:GetService("Players")
local UserInputService   = game:GetService("UserInputService")
local VirtualUser         = game:GetService("VirtualUser")
local Lighting            = game:GetService("Lighting")
local ReplicatedStorage   = game:GetService("ReplicatedStorage")
local Workspace           = game:GetService("Workspace")
local HttpService         = game:GetService("HttpService")
local TweenService        = game:GetService("TweenService")
local LocalPlayer         = Players.LocalPlayer

-- ════════════════════════════════════════════════════════════════
-- FPS UNLOCK
-- ════════════════════════════════════════════════════════════════
if setfpscap then
    setfpscap(1000000)
    print("FPS Unlocked!")
end

-- ════════════════════════════════════════════════════════════════
-- CROSSHAIR SYSTEM  (unchanged logic — pure Frame/GUI, no UI-lib dependency)
-- ════════════════════════════════════════════════════════════════
local Crosshair = {
    Enabled = false,
    CurrentType = "Dot",
    Color = Color3.fromRGB(255, 255, 255),
    Size = 20,
    Transparency = 0.8,
    Thickness = 2,
    Gap = 3,
    Outline = false,
    OutlineColor = Color3.fromRGB(0, 0, 0),
    Animation = false,
    Gui = nil,
    CurrentFrame = nil
}

local CrosshairTypes = {
    ["Dot"] = function(frame, size, color, transparency, thickness, gap, outline, outlineColor)
        local dot = Instance.new("Frame")
        dot.Name = "Dot"
        dot.AnchorPoint = Vector2.new(0.5, 0.5)
        dot.BackgroundColor3 = color
        dot.BackgroundTransparency = transparency
        dot.Size = UDim2.new(0, math.max(3, size/4), 0, math.max(3, size/4))
        dot.Position = UDim2.new(0.5, 0, 0.5, 0)
        dot.BorderSizePixel = 0
        dot.ZIndex = 10
        dot.Parent = frame

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(1, 0)
        corner.Parent = dot

        if outline then
            local stroke = Instance.new("UIStroke")
            stroke.Color = outlineColor
            stroke.Thickness = 1
            stroke.Transparency = transparency
            stroke.Parent = dot
        end
    end,

    ["Circle"] = function(frame, size, color, transparency, thickness, gap, outline, outlineColor)
        local circle = Instance.new("Frame")
        circle.Name = "Circle"
        circle.AnchorPoint = Vector2.new(0.5, 0.5)
        circle.BackgroundColor3 = color
        circle.BackgroundTransparency = 1
        circle.Size = UDim2.new(0, size, 0, size)
        circle.Position = UDim2.new(0.5, 0, 0.5, 0)
        circle.BorderSizePixel = 0
        circle.ZIndex = 10
        circle.Parent = frame

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(1, 0)
        corner.Parent = circle

        local stroke = Instance.new("UIStroke")
        stroke.Color = color
        stroke.Thickness = thickness
        stroke.Transparency = transparency
        stroke.Parent = circle

        if outline then
            local outlineStroke = Instance.new("UIStroke")
            outlineStroke.Color = outlineColor
            outlineStroke.Thickness = thickness + 2
            outlineStroke.Transparency = transparency * 0.7
            outlineStroke.Parent = circle
        end
    end,

    ["Cross"] = function(frame, size, color, transparency, thickness, gap, outline, outlineColor)
        local horizontal = Instance.new("Frame")
        horizontal.Name = "Horizontal"
        horizontal.AnchorPoint = Vector2.new(0.5, 0.5)
        horizontal.BackgroundColor3 = color
        horizontal.BackgroundTransparency = transparency
        horizontal.Size = UDim2.new(0, size, 0, thickness)
        horizontal.Position = UDim2.new(0.5, 0, 0.5, 0)
        horizontal.BorderSizePixel = 0
        horizontal.ZIndex = 10
        horizontal.Parent = frame

        local vertical = Instance.new("Frame")
        vertical.Name = "Vertical"
        vertical.AnchorPoint = Vector2.new(0.5, 0.5)
        vertical.BackgroundColor3 = color
        vertical.BackgroundTransparency = transparency
        vertical.Size = UDim2.new(0, thickness, 0, size)
        vertical.Position = UDim2.new(0.5, 0, 0.5, 0)
        vertical.BorderSizePixel = 0
        vertical.ZIndex = 10
        vertical.Parent = frame

        if outline then
            for _, line in pairs({horizontal, vertical}) do
                local stroke = Instance.new("UIStroke")
                stroke.Color = outlineColor
                stroke.Thickness = 1
                stroke.Transparency = transparency * 0.7
                stroke.Parent = line
            end
        end
    end,

    ["Cross-Dot"] = function(frame, size, color, transparency, thickness, gap, outline, outlineColor)
        local horizontal = Instance.new("Frame")
        horizontal.Name = "Horizontal"
        horizontal.AnchorPoint = Vector2.new(0.5, 0.5)
        horizontal.BackgroundColor3 = color
        horizontal.BackgroundTransparency = transparency
        horizontal.Size = UDim2.new(0, size, 0, thickness)
        horizontal.Position = UDim2.new(0.5, 0, 0.5, 0)
        horizontal.BorderSizePixel = 0
        horizontal.ZIndex = 10
        horizontal.Parent = frame

        local vertical = Instance.new("Frame")
        vertical.Name = "Vertical"
        vertical.AnchorPoint = Vector2.new(0.5, 0.5)
        vertical.BackgroundColor3 = color
        vertical.BackgroundTransparency = transparency
        vertical.Size = UDim2.new(0, thickness, 0, size)
        vertical.Position = UDim2.new(0.5, 0, 0.5, 0)
        vertical.BorderSizePixel = 0
        vertical.ZIndex = 10
        vertical.Parent = frame

        local dot = Instance.new("Frame")
        dot.Name = "Dot"
        dot.AnchorPoint = Vector2.new(0.5, 0.5)
        dot.BackgroundColor3 = color
        dot.BackgroundTransparency = transparency
        dot.Size = UDim2.new(0, math.max(3, size/6), 0, math.max(3, size/6))
        dot.Position = UDim2.new(0.5, 0, 0.5, 0)
        dot.BorderSizePixel = 0
        dot.ZIndex = 11
        dot.Parent = frame

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(1, 0)
        corner.Parent = dot

        if outline then
            for _, element in pairs({horizontal, vertical, dot}) do
                local stroke = Instance.new("UIStroke")
                stroke.Color = outlineColor
                stroke.Thickness = 1
                stroke.Transparency = transparency * 0.7
                stroke.Parent = element
            end
        end
    end,

    ["Square"] = function(frame, size, color, transparency, thickness, gap, outline, outlineColor)
        local square = Instance.new("Frame")
        square.Name = "Square"
        square.AnchorPoint = Vector2.new(0.5, 0.5)
        square.BackgroundColor3 = color
        square.BackgroundTransparency = transparency
        square.Size = UDim2.new(0, size/2, 0, size/2)
        square.Position = UDim2.new(0.5, 0, 0.5, 0)
        square.BorderSizePixel = 0
        square.ZIndex = 10
        square.Parent = frame

        if outline then
            local stroke = Instance.new("UIStroke")
            stroke.Color = outlineColor
            stroke.Thickness = 2
            stroke.Transparency = transparency * 0.7
            stroke.Parent = square
        end
    end,

    ["Square-Outline"] = function(frame, size, color, transparency, thickness, gap, outline, outlineColor)
        local square = Instance.new("Frame")
        square.Name = "SquareOutline"
        square.AnchorPoint = Vector2.new(0.5, 0.5)
        square.BackgroundColor3 = color
        square.BackgroundTransparency = 1
        square.Size = UDim2.new(0, size/2, 0, size/2)
        square.Position = UDim2.new(0.5, 0, 0.5, 0)
        square.BorderSizePixel = 0
        square.ZIndex = 10
        square.Parent = frame

        local stroke = Instance.new("UIStroke")
        stroke.Color = color
        stroke.Thickness = thickness
        stroke.Transparency = transparency
        stroke.Parent = square
    end,

    ["Diamond"] = function(frame, size, color, transparency, thickness, gap, outline, outlineColor)
        local diamond = Instance.new("Frame")
        diamond.Name = "Diamond"
        diamond.AnchorPoint = Vector2.new(0.5, 0.5)
        diamond.BackgroundColor3 = color
        diamond.BackgroundTransparency = transparency
        diamond.Size = UDim2.new(0, size/2, 0, size/2)
        diamond.Position = UDim2.new(0.5, 0, 0.5, 0)
        diamond.BorderSizePixel = 0
        diamond.ZIndex = 10
        diamond.Parent = frame
        diamond.Rotation = 45

        if outline then
            local stroke = Instance.new("UIStroke")
            stroke.Color = outlineColor
            stroke.Thickness = 1
            stroke.Transparency = transparency * 0.7
            stroke.Parent = diamond
        end
    end,

    ["Diamond-Outline"] = function(frame, size, color, transparency, thickness, gap, outline, outlineColor)
        local diamond = Instance.new("Frame")
        diamond.Name = "DiamondOutline"
        diamond.AnchorPoint = Vector2.new(0.5, 0.5)
        diamond.BackgroundColor3 = color
        diamond.BackgroundTransparency = 1
        diamond.Size = UDim2.new(0, size/2, 0, size/2)
        diamond.Position = UDim2.new(0.5, 0, 0.5, 0)
        diamond.BorderSizePixel = 0
        diamond.ZIndex = 10
        diamond.Parent = frame
        diamond.Rotation = 45

        local stroke = Instance.new("UIStroke")
        stroke.Color = color
        stroke.Thickness = thickness
        stroke.Transparency = transparency
        stroke.Parent = diamond
    end,

    ["Triangle"] = function(frame, size, color, transparency, thickness, gap, outline, outlineColor)
        local triangleContainer = Instance.new("Frame")
        triangleContainer.Name = "TriangleContainer"
        triangleContainer.AnchorPoint = Vector2.new(0.5, 0.5)
        triangleContainer.BackgroundTransparency = 1
        triangleContainer.Size = UDim2.new(0, size, 0, size)
        triangleContainer.Position = UDim2.new(0.5, 0, 0.5, 0)
        triangleContainer.ZIndex = 10
        triangleContainer.Parent = frame

        local triangle = Instance.new("Frame")
        triangle.Name = "Triangle"
        triangle.AnchorPoint = Vector2.new(0.5, 0.5)
        triangle.BackgroundColor3 = color
        triangle.BackgroundTransparency = transparency
        triangle.Size = UDim2.new(0, size/2, 0, size/2)
        triangle.Position = UDim2.new(0.5, 0, 0.5, -size/8)
        triangle.BorderSizePixel = 0
        triangle.ZIndex = 10
        triangle.Parent = triangleContainer
        triangle.Rotation = 180

        if outline then
            local stroke = Instance.new("UIStroke")
            stroke.Color = outlineColor
            stroke.Thickness = 1
            stroke.Transparency = transparency * 0.7
            stroke.Parent = triangle
        end
    end,

    ["Triangle-Down"] = function(frame, size, color, transparency, thickness, gap, outline, outlineColor)
        local triangleContainer = Instance.new("Frame")
        triangleContainer.Name = "TriangleContainer"
        triangleContainer.AnchorPoint = Vector2.new(0.5, 0.5)
        triangleContainer.BackgroundTransparency = 1
        triangleContainer.Size = UDim2.new(0, size, 0, size)
        triangleContainer.Position = UDim2.new(0.5, 0, 0.5, 0)
        triangleContainer.ZIndex = 10
        triangleContainer.Parent = frame

        local triangle = Instance.new("Frame")
        triangle.Name = "Triangle"
        triangle.AnchorPoint = Vector2.new(0.5, 0.5)
        triangle.BackgroundColor3 = color
        triangle.BackgroundTransparency = transparency
        triangle.Size = UDim2.new(0, size/2, 0, size/2)
        triangle.Position = UDim2.new(0.5, 0, 0.5, size/8)
        triangle.BorderSizePixel = 0
        triangle.ZIndex = 10
        triangle.Parent = triangleContainer

        if outline then
            local stroke = Instance.new("UIStroke")
            stroke.Color = outlineColor
            stroke.Thickness = 1
            stroke.Transparency = transparency * 0.7
            stroke.Parent = triangle
        end
    end,

    ["Advanced"] = function(frame, size, color, transparency, thickness, gap, outline, outlineColor)
        local gapSize = gap

        local horizontalLeft = Instance.new("Frame")
        horizontalLeft.Name = "HorizontalLeft"
        horizontalLeft.AnchorPoint = Vector2.new(1, 0.5)
        horizontalLeft.BackgroundColor3 = color
        horizontalLeft.BackgroundTransparency = transparency
        horizontalLeft.Size = UDim2.new(0, size/3, 0, thickness)
        horizontalLeft.Position = UDim2.new(0.5, -gapSize, 0.5, 0)
        horizontalLeft.BorderSizePixel = 0
        horizontalLeft.ZIndex = 10
        horizontalLeft.Parent = frame

        local horizontalRight = Instance.new("Frame")
        horizontalRight.Name = "HorizontalRight"
        horizontalRight.AnchorPoint = Vector2.new(0, 0.5)
        horizontalRight.BackgroundColor3 = color
        horizontalRight.BackgroundTransparency = transparency
        horizontalRight.Size = UDim2.new(0, size/3, 0, thickness)
        horizontalRight.Position = UDim2.new(0.5, gapSize, 0.5, 0)
        horizontalRight.BorderSizePixel = 0
        horizontalRight.ZIndex = 10
        horizontalRight.Parent = frame

        local verticalTop = Instance.new("Frame")
        verticalTop.Name = "VerticalTop"
        verticalTop.AnchorPoint = Vector2.new(0.5, 1)
        verticalTop.BackgroundColor3 = color
        verticalTop.BackgroundTransparency = transparency
        verticalTop.Size = UDim2.new(0, thickness, 0, size/3)
        verticalTop.Position = UDim2.new(0.5, 0, 0.5, -gapSize)
        verticalTop.BorderSizePixel = 0
        verticalTop.ZIndex = 10
        verticalTop.Parent = frame

        local verticalBottom = Instance.new("Frame")
        verticalBottom.Name = "VerticalBottom"
        verticalBottom.AnchorPoint = Vector2.new(0.5, 0)
        verticalBottom.BackgroundColor3 = color
        verticalBottom.BackgroundTransparency = transparency
        verticalBottom.Size = UDim2.new(0, thickness, 0, size/3)
        verticalBottom.Position = UDim2.new(0.5, 0, 0.5, gapSize)
        verticalBottom.BorderSizePixel = 0
        verticalBottom.ZIndex = 10
        verticalBottom.Parent = frame

        if outline then
            for _, element in pairs({horizontalLeft, horizontalRight, verticalTop, verticalBottom}) do
                local stroke = Instance.new("UIStroke")
                stroke.Color = outlineColor
                stroke.Thickness = 1
                stroke.Transparency = transparency * 0.7
                stroke.Parent = element
            end
        end
    end,

    ["Sniper"] = function(frame, size, color, transparency, thickness, gap, outline, outlineColor)
        local outerCircle = Instance.new("Frame")
        outerCircle.Name = "OuterCircle"
        outerCircle.AnchorPoint = Vector2.new(0.5, 0.5)
        outerCircle.BackgroundColor3 = color
        outerCircle.BackgroundTransparency = 1
        outerCircle.Size = UDim2.new(0, size, 0, size)
        outerCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
        outerCircle.BorderSizePixel = 0
        outerCircle.ZIndex = 10
        outerCircle.Parent = frame

        local outerCorner = Instance.new("UICorner")
        outerCorner.CornerRadius = UDim.new(1, 0)
        outerCorner.Parent = outerCircle

        local outerStroke = Instance.new("UIStroke")
        outerStroke.Color = color
        outerStroke.Thickness = 1
        outerStroke.Transparency = transparency
        outerStroke.Parent = outerCircle

        local dot = Instance.new("Frame")
        dot.Name = "Dot"
        dot.AnchorPoint = Vector2.new(0.5, 0.5)
        dot.BackgroundColor3 = color
        dot.BackgroundTransparency = transparency
        dot.Size = UDim2.new(0, 2, 0, 2)
        dot.Position = UDim2.new(0.5, 0, 0.5, 0)
        dot.BorderSizePixel = 0
        dot.ZIndex = 11
        dot.Parent = frame

        local dotCorner = Instance.new("UICorner")
        dotCorner.CornerRadius = UDim.new(1, 0)
        dotCorner.Parent = dot

        local angles = {0, 45, 90, 135, 180, 225, 270, 315}
        for i, angle in ipairs(angles) do
            local notch = Instance.new("Frame")
            notch.Name = "Notch" .. i
            notch.AnchorPoint = Vector2.new(0.5, 0.5)
            notch.BackgroundColor3 = color
            notch.BackgroundTransparency = transparency
            notch.Size = UDim2.new(0, thickness, 0, size/8)
            notch.Position = UDim2.new(0.5, 0, 0.5, 0)
            notch.BorderSizePixel = 0
            notch.ZIndex = 10
            notch.Rotation = angle
            notch.Parent = frame
        end
    end,

    ["Circle-Dot"] = function(frame, size, color, transparency, thickness, gap, outline, outlineColor)
        local circle = Instance.new("Frame")
        circle.Name = "Circle"
        circle.AnchorPoint = Vector2.new(0.5, 0.5)
        circle.BackgroundColor3 = color
        circle.BackgroundTransparency = 1
        circle.Size = UDim2.new(0, size, 0, size)
        circle.Position = UDim2.new(0.5, 0, 0.5, 0)
        circle.BorderSizePixel = 0
        circle.ZIndex = 10
        circle.Parent = frame

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(1, 0)
        corner.Parent = circle

        local stroke = Instance.new("UIStroke")
        stroke.Color = color
        stroke.Thickness = thickness
        stroke.Transparency = transparency
        stroke.Parent = circle

        local dot = Instance.new("Frame")
        dot.Name = "Dot"
        dot.AnchorPoint = Vector2.new(0.5, 0.5)
        dot.BackgroundColor3 = color
        dot.BackgroundTransparency = transparency
        dot.Size = UDim2.new(0, math.max(3, size/6), 0, math.max(3, size/6))
        dot.Position = UDim2.new(0.5, 0, 0.5, 0)
        dot.BorderSizePixel = 0
        dot.ZIndex = 11
        dot.Parent = frame

        local dotCorner = Instance.new("UICorner")
        dotCorner.CornerRadius = UDim.new(1, 0)
        dotCorner.Parent = dot

        if outline then
            local outlineStroke = Instance.new("UIStroke")
            outlineStroke.Color = outlineColor
            outlineStroke.Thickness = thickness + 2
            outlineStroke.Transparency = transparency * 0.7
            outlineStroke.Parent = circle
        end
    end,

    ["Cross-Circle"] = function(frame, size, color, transparency, thickness, gap, outline, outlineColor)
        local circle = Instance.new("Frame")
        circle.Name = "Circle"
        circle.AnchorPoint = Vector2.new(0.5, 0.5)
        circle.BackgroundColor3 = color
        circle.BackgroundTransparency = 1
        circle.Size = UDim2.new(0, size, 0, size)
        circle.Position = UDim2.new(0.5, 0, 0.5, 0)
        circle.BorderSizePixel = 0
        circle.ZIndex = 10
        circle.Parent = frame

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(1, 0)
        corner.Parent = circle

        local stroke = Instance.new("UIStroke")
        stroke.Color = color
        stroke.Thickness = thickness
        stroke.Transparency = transparency
        stroke.Parent = circle

        local horizontal = Instance.new("Frame")
        horizontal.Name = "Horizontal"
        horizontal.AnchorPoint = Vector2.new(0.5, 0.5)
        horizontal.BackgroundColor3 = color
        horizontal.BackgroundTransparency = transparency
        horizontal.Size = UDim2.new(0, size/1.5, 0, thickness)
        horizontal.Position = UDim2.new(0.5, 0, 0.5, 0)
        horizontal.BorderSizePixel = 0
        horizontal.ZIndex = 11
        horizontal.Parent = frame

        local vertical = Instance.new("Frame")
        vertical.Name = "Vertical"
        vertical.AnchorPoint = Vector2.new(0.5, 0.5)
        vertical.BackgroundColor3 = color
        vertical.BackgroundTransparency = transparency
        vertical.Size = UDim2.new(0, thickness, 0, size/1.5)
        vertical.Position = UDim2.new(0.5, 0, 0.5, 0)
        vertical.BorderSizePixel = 0
        vertical.ZIndex = 11
        vertical.Parent = frame
    end,

    ["Square-Cross"] = function(frame, size, color, transparency, thickness, gap, outline, outlineColor)
        local square = Instance.new("Frame")
        square.Name = "Square"
        square.AnchorPoint = Vector2.new(0.5, 0.5)
        square.BackgroundColor3 = color
        square.BackgroundTransparency = 1
        square.Size = UDim2.new(0, size/1.5, 0, size/1.5)
        square.Position = UDim2.new(0.5, 0, 0.5, 0)
        square.BorderSizePixel = 0
        square.ZIndex = 10
        square.Parent = frame

        local squareStroke = Instance.new("UIStroke")
        squareStroke.Color = color
        squareStroke.Thickness = thickness
        squareStroke.Transparency = transparency
        squareStroke.Parent = square

        local horizontal = Instance.new("Frame")
        horizontal.Name = "Horizontal"
        horizontal.AnchorPoint = Vector2.new(0.5, 0.5)
        horizontal.BackgroundColor3 = color
        horizontal.BackgroundTransparency = transparency
        horizontal.Size = UDim2.new(0, size/2, 0, thickness)
        horizontal.Position = UDim2.new(0.5, 0, 0.5, 0)
        horizontal.BorderSizePixel = 0
        horizontal.ZIndex = 11
        horizontal.Parent = frame

        local vertical = Instance.new("Frame")
        vertical.Name = "Vertical"
        vertical.AnchorPoint = Vector2.new(0.5, 0.5)
        vertical.BackgroundColor3 = color
        vertical.BackgroundTransparency = transparency
        vertical.Size = UDim2.new(0, thickness, 0, size/2)
        vertical.Position = UDim2.new(0.5, 0, 0.5, 0)
        vertical.BorderSizePixel = 0
        vertical.ZIndex = 11
        vertical.Parent = frame
    end,

    ["Heart"] = function(frame, size, color, transparency, thickness, gap, outline, outlineColor)
        local heartContainer = Instance.new("Frame")
        heartContainer.Name = "HeartContainer"
        heartContainer.AnchorPoint = Vector2.new(0.5, 0.5)
        heartContainer.BackgroundTransparency = 1
        heartContainer.Size = UDim2.new(0, size, 0, size)
        heartContainer.Position = UDim2.new(0.5, 0, 0.5, 0)
        heartContainer.ZIndex = 10
        heartContainer.Parent = frame

        local leftCircle = Instance.new("Frame")
        leftCircle.Name = "LeftCircle"
        leftCircle.AnchorPoint = Vector2.new(0.5, 0.5)
        leftCircle.BackgroundColor3 = color
        leftCircle.BackgroundTransparency = transparency
        leftCircle.Size = UDim2.new(0, size/3, 0, size/3)
        leftCircle.Position = UDim2.new(0.3, 0, 0.4, 0)
        leftCircle.BorderSizePixel = 0
        leftCircle.ZIndex = 10
        leftCircle.Parent = heartContainer

        local leftCorner = Instance.new("UICorner")
        leftCorner.CornerRadius = UDim.new(1, 0)
        leftCorner.Parent = leftCircle

        local rightCircle = Instance.new("Frame")
        rightCircle.Name = "RightCircle"
        rightCircle.AnchorPoint = Vector2.new(0.5, 0.5)
        rightCircle.BackgroundColor3 = color
        rightCircle.BackgroundTransparency = transparency
        rightCircle.Size = UDim2.new(0, size/3, 0, size/3)
        rightCircle.Position = UDim2.new(0.7, 0, 0.4, 0)
        rightCircle.BorderSizePixel = 0
        rightCircle.ZIndex = 10
        rightCircle.Parent = heartContainer

        local rightCorner = Instance.new("UICorner")
        rightCorner.CornerRadius = UDim.new(1, 0)
        rightCorner.Parent = rightCircle

        local triangle = Instance.new("Frame")
        triangle.Name = "Triangle"
        triangle.AnchorPoint = Vector2.new(0.5, 0.5)
        triangle.BackgroundColor3 = color
        triangle.BackgroundTransparency = transparency
        triangle.Size = UDim2.new(0, size/2.5, 0, size/3)
        triangle.Position = UDim2.new(0.5, 0, 0.7, 0)
        triangle.BorderSizePixel = 0
        triangle.ZIndex = 10
        triangle.Parent = heartContainer
        triangle.Rotation = 45
    end,

    ["Star"] = function(frame, size, color, transparency, thickness, gap, outline, outlineColor)
        local starContainer = Instance.new("Frame")
        starContainer.Name = "StarContainer"
        starContainer.AnchorPoint = Vector2.new(0.5, 0.5)
        starContainer.BackgroundTransparency = 1
        starContainer.Size = UDim2.new(0, size, 0, size)
        starContainer.Position = UDim2.new(0.5, 0, 0.5, 0)
        starContainer.ZIndex = 10
        starContainer.Parent = frame

        local angles = {0, 45, 90, 135, 180, 225, 270, 315}
        for i, angle in ipairs(angles) do
            local point = Instance.new("Frame")
            point.Name = "Point" .. i
            point.AnchorPoint = Vector2.new(0.5, 0.5)
            point.BackgroundColor3 = color
            point.BackgroundTransparency = transparency
            point.Size = UDim2.new(0, thickness, 0, size/3)
            point.Position = UDim2.new(0.5, 0, 0.5, 0)
            point.BorderSizePixel = 0
            point.ZIndex = 10
            point.Rotation = angle
            point.Parent = starContainer
        end
    end,

    ["Target"] = function(frame, size, color, transparency, thickness, gap, outline, outlineColor)
        local circles = {size, size * 0.7, size * 0.4}
        for i, circleSize in ipairs(circles) do
            local circle = Instance.new("Frame")
            circle.Name = "TargetCircle" .. i
            circle.AnchorPoint = Vector2.new(0.5, 0.5)
            circle.BackgroundColor3 = color
            circle.BackgroundTransparency = 1
            circle.Size = UDim2.new(0, circleSize, 0, circleSize)
            circle.Position = UDim2.new(0.5, 0, 0.5, 0)
            circle.BorderSizePixel = 0
            circle.ZIndex = 10
            circle.Parent = frame

            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(1, 0)
            corner.Parent = circle

            local stroke = Instance.new("UIStroke")
            stroke.Color = color
            stroke.Thickness = 1
            stroke.Transparency = transparency
            stroke.Parent = circle
        end

        local dot = Instance.new("Frame")
        dot.Name = "Dot"
        dot.AnchorPoint = Vector2.new(0.5, 0.5)
        dot.BackgroundColor3 = color
        dot.BackgroundTransparency = transparency
        dot.Size = UDim2.new(0, 4, 0, 4)
        dot.Position = UDim2.new(0.5, 0, 0.5, 0)
        dot.BorderSizePixel = 0
        dot.ZIndex = 11
        dot.Parent = frame

        local dotCorner = Instance.new("UICorner")
        dotCorner.CornerRadius = UDim.new(1, 0)
        dotCorner.Parent = dot
    end,

    ["Reticle"] = function(frame, size, color, transparency, thickness, gap, outline, outlineColor)
        local gapSize = gap * 2

        local circle = Instance.new("Frame")
        circle.Name = "Circle"
        circle.AnchorPoint = Vector2.new(0.5, 0.5)
        circle.BackgroundColor3 = color
        circle.BackgroundTransparency = 1
        circle.Size = UDim2.new(0, size, 0, size)
        circle.Position = UDim2.new(0.5, 0, 0.5, 0)
        circle.BorderSizePixel = 0
        circle.ZIndex = 10
        circle.Parent = frame

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(1, 0)
        corner.Parent = circle

        local stroke = Instance.new("UIStroke")
        stroke.Color = color
        stroke.Thickness = 1
        stroke.Transparency = transparency
        stroke.Parent = circle

        local positions = {
            {x = 0.5, y = 0.5, xOffset = -gapSize, yOffset = -gapSize},
            {x = 0.5, y = 0.5, xOffset = gapSize, yOffset = -gapSize},
            {x = 0.5, y = 0.5, xOffset = -gapSize, yOffset = gapSize},
            {x = 0.5, y = 0.5, xOffset = gapSize, yOffset = gapSize}
        }

        for i, pos in ipairs(positions) do
            local notch = Instance.new("Frame")
            notch.Name = "Notch" .. i
            notch.AnchorPoint = Vector2.new(0.5, 0.5)
            notch.BackgroundColor3 = color
            notch.BackgroundTransparency = transparency
            notch.Size = UDim2.new(0, thickness * 2, 0, thickness * 2)
            notch.Position = UDim2.new(pos.x, pos.xOffset, pos.y, pos.yOffset)
            notch.BorderSizePixel = 0
            notch.ZIndex = 11
            notch.Parent = frame
        end
    end
}

local function CreateCrosshairGUI()
    if Crosshair.Gui then
        Crosshair.Gui:Destroy()
    end

    local gui = Instance.new("ScreenGui")
    gui.Name = "CrosshairGUI"
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.DisplayOrder = 999
    gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.BackgroundTransparency = 1
    mainFrame.Size = UDim2.new(1, 0, 1, 0)
    mainFrame.Position = UDim2.new(0, 0, 0, 0)
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = false
    mainFrame.Parent = gui

    local crosshairFrame = Instance.new("Frame")
    crosshairFrame.Name = "CrosshairContainer"
    crosshairFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    crosshairFrame.BackgroundTransparency = 1
    crosshairFrame.Size = UDim2.new(0, 150, 0, 150)
    crosshairFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    crosshairFrame.BorderSizePixel = 0
    crosshairFrame.ClipsDescendants = false
    crosshairFrame.Parent = mainFrame

    Crosshair.Gui = gui
    Crosshair.CurrentFrame = crosshairFrame

    return crosshairFrame
end

local function ApplyCrosshairAnimation(crosshairFrame)
    local pulseConnection
    pulseConnection = RunService.Heartbeat:Connect(function(delta)
        if not Crosshair.Animation or not Crosshair.Enabled then
            pulseConnection:Disconnect()
            return
        end

        local scale = 1 + math.sin(tick() * 5) * 0.1
        crosshairFrame.Size = UDim2.new(scale, 0, scale, 0)
    end)
end

local function UpdateCrosshair()
    if not Crosshair.Enabled then
        if Crosshair.Gui then
            Crosshair.Gui.Enabled = false
        end
        return
    end

    if not Crosshair.Gui then
        CreateCrosshairGUI()
    end

    Crosshair.Gui.Enabled = true

    for _, child in pairs(Crosshair.CurrentFrame:GetChildren()) do
        child:Destroy()
    end

    local crosshairFrame = Instance.new("Frame")
    crosshairFrame.Name = "Crosshair"
    crosshairFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    crosshairFrame.BackgroundTransparency = 1
    crosshairFrame.Size = UDim2.new(1, 0, 1, 0)
    crosshairFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    crosshairFrame.BorderSizePixel = 0
    crosshairFrame.Parent = Crosshair.CurrentFrame

    if CrosshairTypes[Crosshair.CurrentType] then
        CrosshairTypes[Crosshair.CurrentType](
            crosshairFrame,
            Crosshair.Size,
            Crosshair.Color,
            Crosshair.Transparency,
            Crosshair.Thickness,
            Crosshair.Gap,
            Crosshair.Outline,
            Crosshair.OutlineColor
        )
    else
        CrosshairTypes["Dot"](
            crosshairFrame,
            Crosshair.Size,
            Crosshair.Color,
            Crosshair.Transparency,
            Crosshair.Thickness,
            Crosshair.Gap,
            Crosshair.Outline,
            Crosshair.OutlineColor
        )
    end

    if Crosshair.Animation then
        ApplyCrosshairAnimation(crosshairFrame)
    end
end

local function SetupResponsiveBehavior()
    if Crosshair.Gui then
        Crosshair.Gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
            UpdateCrosshair()
        end)
    end
end

local function ToggleCrosshair(state)
    Crosshair.Enabled = state
    UpdateCrosshair()
    if state then
        SetupResponsiveBehavior()
    end
end

local function ChangeCrosshairType(t)
    Crosshair.CurrentType = t
    UpdateCrosshair()
end

local function ChangeCrosshairColor(color)
    Crosshair.Color = color
    UpdateCrosshair()
end

local function ChangeCrosshairSize(size)
    Crosshair.Size = size
    UpdateCrosshair()
end

local function ChangeCrosshairTransparency(transparency)
    Crosshair.Transparency = transparency
    UpdateCrosshair()
end

local function ChangeCrosshairThickness(thickness)
    Crosshair.Thickness = math.max(1, thickness)
    UpdateCrosshair()
end

local function ChangeCrosshairGap(gap)
    Crosshair.Gap = gap
    UpdateCrosshair()
end

local function ToggleOutline(state)
    Crosshair.Outline = state
    UpdateCrosshair()
end

local function ChangeOutlineColor(color)
    Crosshair.OutlineColor = color
    UpdateCrosshair()
end

local function ToggleAnimation(state)
    Crosshair.Animation = state
    UpdateCrosshair()
end

-- ════════════════════════════════════════════════════════════════
-- VARIABLES
-- ════════════════════════════════════════════════════════════════
local LP = LocalPlayer
local Camera = Workspace.CurrentCamera

local originalLighting = {
    Brightness = Lighting.Brightness,
    FogEnd = Lighting.FogEnd,
    FogStart = Lighting.FogStart,
    GlobalShadows = Lighting.GlobalShadows,
    ClockTime = Lighting.ClockTime,
    Ambient = Lighting.Ambient,
    OutdoorAmbient = Lighting.OutdoorAmbient,
    ColorShift_Bottom = Lighting.ColorShift_Bottom,
    ColorShift_Top = Lighting.ColorShift_Top
}

local featureStates = {
    WalkSpeed = false,
    WalkSpeedValue = 16,
    Noclip = false,
    AntiAFK = false,
    AutoStun = false,
    GodMode = false,

    ESPFillTransparency = 0.7,
    ESPOutlineTransparency = 0,
    ESPTextSize = 14,

    SurvivorESP = false,
    KillerESP = false,
    Nametags = false,
    DistanceESP = false,
    SurvivorColor = Color3.fromRGB(0, 255, 0),
    KillerColor = Color3.fromRGB(255, 0, 0),

    GeneratorESP = false,
    HookESP = false,
    GateESP = false,
    WindowESP = false,
    PalletESP = false,

    GeneratorColor = Color3.fromRGB(0, 170, 255),
    HookColor = Color3.fromRGB(255, 0, 0),
    GateColor = Color3.fromRGB(255, 225, 0),
    WindowColor = Color3.fromRGB(255, 255, 255),
    PalletColor = Color3.fromRGB(255, 140, 0),

    FullBright = false,
    TimeOfDay = Lighting.ClockTime,
    NoFog = false,
    NoShadows = false,

    HitboxKiller = false,
    HitboxAll = false,
    HitboxSize = 12,
    HitboxTransparency = 1,

    AbilityNotify = true,
    AutoReveal = false,

    FOVEnabled = false,
    FOVValue = 95,

    SurvivorItemsESP = false,
    SurvivorItemsColor = Color3.fromRGB(0, 170, 255),

    BypassGate = false,
    AutoLever = false,
    KillAll = false,
    AutoAttack = false,
    NoFlashlight = false,

    NoSkillcheck = false,

    FlingPlayer = false,
    FlingTarget = nil,
    FlingKiller = false,
    FlingActive = false
}

local character, humanoid, rootPart

local speedHumanoid = nil
local speedConnChanged, speedConnAncestry = nil, nil
local speedBound = false
local noclipEnabled, noclipConn = false, nil
local antiStunEnabled = false
local antiAFKConn = nil
local worldLoopThread = nil
local playerConns = {}
local distanceUpdateThread = nil
local remoteHooks = setmetatable({},{__mode="k"})

local godModeEnabled = false
local godModeConnection = nil
local characterAddedConnection = nil
local godModeCharacter
local godModeHumanoid

local worldReg = {
    Generator = {}, Hook = {}, Gate = {},
    Window = {}, Palletwrong = {}
}
local mapAdd, mapRem = {}, {}
local palletState = setmetatable({}, {__mode="k"})
local windowState = setmetatable({}, {__mode="k"})

local playerHitboxes = {}
local hitboxEnabledKiller = false
local hitboxEnabledAll = false
local headSize = 12
local hitboxTransparency = 1

local teleportPlayerList = {}
local selectedPlayerForTeleport = nil

local nfActive=false
local nfStore={lighting={},inst=setmetatable({},{__mode="k"}),conns={},tick=nil}
local nfNameTokens={"smoke","mist","fog","haze","smog","steam","cloud","lake"}
local nfStrictNames={["Smoke"]=true,["LakeMist"]=true,["Chromatic Water Fog"]=true,["Cursed Energy Smoke"]=true,["Firm Smoke"]=true,["Foggy Wind"]=true}
local nfQueue, nfQueued, nfProcessed = {}, setmetatable({}, {__mode="k"}), setmetatable({}, {__mode="k"})

local fbActive = false
local fbConn = nil

local todActive = false
local desiredClockTime = Lighting.ClockTime

local displayNames = {
    ["Motion Tracker"] = "Motion Tracker",
    ["Gate"] = "Gate",
    ["Flashlight"] = "Flashlight",
    ["Bandage"] = "Bandage",
    ["Parrying Dagger"] = "Parrying Dagger",
    ["Adrenaline Shot"] = "Adrenaline Shot",
    ["Shadow Clone"] = "Shadow Clone",
}

local autoLeverRunning = false
local killAllRunning = false
local autoAttackRunning = false
local noFlashlightRunning = false

local lastInputTime = tick()
local INPUT_COOLDOWN = 2
local noSkillcheckEnabled = false
local originalNamecall = nil
local hookedMetatable = false

local flingConnection = nil
local flingTargets = {}
local flingCheckboxes = {}
local originalFallenPartsDestroyHeight = Workspace.FallenPartsDestroyHeight
local originalPosition = nil
local returnToOriginalPositionRunning = false

-- ════════════════════════════════════════════════════════════════
-- NO SKILLCHECK SYSTEM  (logic unchanged; now safely calls safeNotify)
-- ════════════════════════════════════════════════════════════════
local function setupNoSkillcheck()
    if noSkillcheckEnabled then return end

    noSkillcheckEnabled = true

    local mt = getrawmetatable(game)
    if not mt then
        safeNotify("No Skillcheck", "Failed to get metatable", 3)
        return
    end

    originalNamecall = mt.__namecall

    local function onInput(action, state, input)
        if state == Enum.UserInputState.Begin then
            lastInputTime = tick()
        end
    end

    UserInputService.InputBegan:Connect(onInput)
    UserInputService.InputChanged:Connect(onInput)

    Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
        if Workspace.CurrentCamera then
            Workspace.CurrentCamera:GetPropertyChangedSignal("CFrame"):Connect(function()
                lastInputTime = tick()
            end)
        end
    end)

    setreadonly(mt, false)
    mt.__namecall = newcclosure(function(self, ...)
        local args = {...}
        local method = getnamecallmethod()

        if noSkillcheckEnabled and method == "FireServer" then
            local selfName = tostring(self):lower()
            if selfName:find("skill") or selfName:find("check") then
                local sinceLastInput = tick() - lastInputTime
                local shouldActivate = sinceLastInput > INPUT_COOLDOWN

                if shouldActivate then
                    args[1] = "Great"
                    safeNotify("No Skillcheck", "Auto skillcheck activated!", 1)
                end
            end
        end

        return originalNamecall(self, unpack(args))
    end)
    setreadonly(mt, true)

    hookedMetatable = true
    safeNotify("No Skillcheck", "Auto skillcheck activated. Will auto-hit after 2 seconds of no input.", 4)
end

local function disableNoSkillcheck()
    if not noSkillcheckEnabled then return end

    noSkillcheckEnabled = false

    if hookedMetatable then
        local mt = getrawmetatable(game)
        if mt and originalNamecall then
            setreadonly(mt, false)
            mt.__namecall = originalNamecall
            setreadonly(mt, true)
        end
        hookedMetatable = false
    end

    safeNotify("No Skillcheck", "Auto skillcheck disabled.", 3)
end

-- ════════════════════════════════════════════════════════════════
-- FLING SYSTEM  (logic unchanged; WindUI:Notify → safeNotify)
-- ════════════════════════════════════════════════════════════════
local function getRole(p)
    local tn = p.Team and p.Team.Name and p.Team.Name:lower() or ""
    if tn:find("killer") then return "Killer" end
    if tn:find("survivor") then return "Survivor" end
    return "Survivor"
end

local function saveOriginalPosition()
    local Character = LP.Character
    if Character and Character:FindFirstChild("HumanoidRootPart") then
        originalPosition = Character.HumanoidRootPart.CFrame
    end
end

local function returnToOriginalPosition()
    if returnToOriginalPositionRunning then
        return
    end

    returnToOriginalPositionRunning = true

    local Character = LP.Character
    if not Character then
        returnToOriginalPositionRunning = false
        return
    end

    local RootPart = Character:FindFirstChild("HumanoidRootPart")
    local Humanoid = Character:FindFirstChildOfClass("Humanoid")

    if not RootPart or not Humanoid then
        returnToOriginalPositionRunning = false
        return
    end

    for _, v in pairs(RootPart:GetChildren()) do
        if v:IsA("BodyVelocity") then
            v:Destroy()
        end
    end

    RootPart.Velocity = Vector3.new(0, 0, 0)
    RootPart.RotVelocity = Vector3.new(0, 0, 0)

    for _, v in pairs(RootPart:GetChildren()) do
        if v:IsA("BodyAngularVelocity") then
            v:Destroy()
        end
    end

    Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)

    Workspace.CurrentCamera.CameraSubject = Humanoid

    if originalPosition then
        Character:SetPrimaryPartCFrame(originalPosition)
        RootPart.CFrame = originalPosition
    end

    task.wait(0.5)

    Workspace.FallenPartsDestroyHeight = originalFallenPartsDestroyHeight

    Humanoid.PlatformStand = false
    Humanoid.Sit = false

    for _, child in pairs(Character:GetChildren()) do
        if child:IsA("BodyForce") or child:IsA("BodyThrust") or child:IsA("BodyPosition") then
            child:Destroy()
        end
    end

    Humanoid:ChangeState(Enum.HumanoidStateType.Running)

    returnToOriginalPositionRunning = false
end

local function SkidFling(TargetPlayer)
    local Character = LP.Character
    local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
    local RootPart = Humanoid and Humanoid.RootPart
    local TCharacter = TargetPlayer.Character
    if not TCharacter then return end

    local THumanoid
    local TRootPart
    local THead
    local Accessory
    local Handle
    if TCharacter:FindFirstChildOfClass("Humanoid") then
        THumanoid = TCharacter:FindFirstChildOfClass("Humanoid")
    end
    if THumanoid and THumanoid.RootPart then
        TRootPart = THumanoid.RootPart
    end
    if TCharacter:FindFirstChild("Head") then
        THead = TCharacter.Head
    end
    if TCharacter:FindFirstChildOfClass("Accessory") then
        Accessory = TCharacter:FindFirstChildOfClass("Accessory")
    end
    if Accessory and Accessory:FindFirstChild("Handle") then
        Handle = Accessory.Handle
    end
    if Character and Humanoid and RootPart then
        if not originalPosition then
            saveOriginalPosition()
        end

        if THumanoid and THumanoid.Sit then
            safeNotify("Fling Error", TargetPlayer.Name .. " is sitting", 2)
            return
        end

        if THead then
            Workspace.CurrentCamera.CameraSubject = THead
        elseif Handle then
            Workspace.CurrentCamera.CameraSubject = Handle
        elseif THumanoid and TRootPart then
            Workspace.CurrentCamera.CameraSubject = THumanoid
        end

        if not TCharacter:FindFirstChildWhichIsA("BasePart") then
            return
        end

        local FPos = function(BasePart, Pos, Ang)
            RootPart.CFrame = CFrame.new(BasePart.Position) * Pos * Ang
            Character:SetPrimaryPartCFrame(CFrame.new(BasePart.Position) * Pos * Ang)
            RootPart.Velocity = Vector3.new(9e7, 9e7 * 10, 9e7)
            RootPart.RotVelocity = Vector3.new(9e8, 9e8, 9e8)
        end

        local SFBasePart = function(BasePart)
            local TimeToWait = 2
            local Time = tick()
            local Angle = 0
            repeat
                if RootPart and THumanoid then
                    if BasePart.Velocity.Magnitude < 50 then
                        Angle = Angle + 100
                        FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle),0 ,0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle),0 ,0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection, CFrame.Angles(math.rad(Angle),0 ,0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection, CFrame.Angles(math.rad(Angle), 0, 0))
                        task.wait()
                    else
                        FPos(BasePart, CFrame.new(0, 1.5, THumanoid.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, -THumanoid.WalkSpeed), CFrame.Angles(0, 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, 1.5, THumanoid.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))
                        task.wait()

                        FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(90), 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(90), 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0))
                        task.wait()
                    end
                end
            until Time + TimeToWait < tick() or not featureStates.FlingActive
        end

        Workspace.FallenPartsDestroyHeight = math.huge

        local BV = Instance.new("BodyVelocity")
        BV.Parent = RootPart
        BV.Velocity = Vector3.new(0, 0, 0)
        BV.MaxForce = Vector3.new(9e9, 9e9, 9e9)

        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)

        if TRootPart then
            SFBasePart(TRootPart)
        elseif THead then
            SFBasePart(THead)
        elseif Handle then
            SFBasePart(Handle)
        else
            safeNotify("Fling Error", TargetPlayer.Name .. " has no valid parts", 2)
            return
        end

        BV:Destroy()
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
        Workspace.CurrentCamera.CameraSubject = Humanoid

        returnToOriginalPosition()
    else
        safeNotify("Fling Error", "Your character is not ready", 2)
    end
end

local function startFlingLoop()
    if flingConnection then
        flingConnection:Disconnect()
        flingConnection = nil
    end

    featureStates.FlingActive = true

    flingConnection = RunService.Heartbeat:Connect(function()
        if not featureStates.FlingActive then
            flingConnection:Disconnect()
            returnToOriginalPosition()
            return
        end

        if featureStates.FlingKiller then
            local role = getRole(LP)
            if role == "Killer" then
                safeNotify("Fling Killer", "You are the killer, fling killer disabled.", 3)
                featureStates.FlingKiller = false
                featureStates.FlingActive = false
                flingConnection:Disconnect()
                returnToOriginalPosition()
                return
            end

            local killer = nil
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LP and getRole(player) == "Killer" then
                    killer = player
                    break
                end
            end

            if killer then
                SkidFling(killer)
            end
        elseif featureStates.FlingPlayer and featureStates.FlingTarget then
            SkidFling(featureStates.FlingTarget)
        end
    end)
end

local function stopFling()
    featureStates.FlingActive = false
    featureStates.FlingPlayer = false
    featureStates.FlingKiller = false

    if flingConnection then
        flingConnection:Disconnect()
        flingConnection = nil
    end

    returnToOriginalPosition()

    safeNotify("Fling", "Fling stopped. Returned to original position.", 3)
end

-- ════════════════════════════════════════════════════════════════
-- GOD MODE SYSTEM  (logic unchanged)
-- ════════════════════════════════════════════════════════════════
local function refreshGodModeCharacter()
    godModeCharacter = LP.Character or LP.CharacterAdded:Wait()
    godModeHumanoid = godModeCharacter:FindFirstChildOfClass("Humanoid")

    if not godModeHumanoid then
        godModeCharacter.ChildAdded:Connect(function(child)
            if child:IsA("Humanoid") then
                godModeHumanoid = child
            end
        end)
        godModeHumanoid = godModeCharacter:WaitForChild("Humanoid")
    end
end

local function enableGodMode()
    godModeEnabled = true
    refreshGodModeCharacter()

    characterAddedConnection = LP.CharacterAdded:Connect(function()
        refreshGodModeCharacter()
    end)

    godModeConnection = RunService.Heartbeat:Connect(function()
        if godModeHumanoid then
            godModeHumanoid.Health = godModeHumanoid.MaxHealth

            if godModeHumanoid.MaxHealth < 100 then
                godModeHumanoid.MaxHealth = 100
            end

            godModeHumanoid.BreakJointsOnDeath = false

            if godModeHumanoid.Health <= 1 then
                godModeHumanoid.Health = godModeHumanoid.MaxHealth
            end
        end
    end)

    task.spawn(function()
        while godModeEnabled do
            task.wait(0.25)
            if godModeHumanoid and godModeHumanoid.Health <= 1 then
                godModeHumanoid.Health = godModeHumanoid.MaxHealth
            end
        end
    end)
end

local function disableGodMode()
    godModeEnabled = false
    if godModeConnection then
        godModeConnection:Disconnect()
        godModeConnection = nil
    end
    if characterAddedConnection then
        characterAddedConnection:Disconnect()
        characterAddedConnection = nil
    end
end

-- ════════════════════════════════════════════════════════════════
-- ESP UTILITY FUNCTIONS  (logic unchanged; duplicate safeNotify removed)
-- ════════════════════════════════════════════════════════════════
local function alive(i)
    if not i then return false end
    local ok = pcall(function() return i.Parent end)
    return ok and i.Parent ~= nil
end

local function validPart(p) return p and alive(p) and p:IsA("BasePart") end
local function clamp(n,lo,hi) if n<lo then return lo elseif n>hi then return hi else return n end end
local function now() return os.clock() end
local function dist(a,b) return (a-b).Magnitude end

local function firstBasePart(inst)
    if not alive(inst) then return nil end
    if inst:IsA("BasePart") then return inst end
    if inst:IsA("Model") then
        if inst.PrimaryPart and inst.PrimaryPart:IsA("BasePart") and alive(inst.PrimaryPart) then return inst.PrimaryPart end
        local p = inst:FindFirstChildWhichIsA("BasePart", true)
        if validPart(p) then return p end
    end
    if inst:IsA("Tool") then
        local h = inst:FindFirstChild("Handle") or inst:FindFirstChildWhichIsA("BasePart")
        if validPart(h) then return h end
    end
    return nil
end

local function makeBillboard(text, color3, size)
    local g = Instance.new("BillboardGui")
    g.Name = "VD_Tag"
    g.AlwaysOnTop = true
    g.Size = UDim2.new(0, 200, 0, 20)
    g.StudsOffset = Vector3.new(0, 2.5, 0)
    g.MaxDistance = 0
    g.Adornee = nil

    local l = Instance.new("TextLabel")
    l.Name = "Label"
    l.BackgroundTransparency = 1
    l.Size = UDim2.new(1, 0, 1, 0)
    l.Font = Enum.Font.GothamBold
    l.Text = text
    l.TextSize = featureStates.ESPTextSize
    l.TextColor3 = color3 or Color3.new(1,1,1)
    l.TextStrokeTransparency = 0.3
    l.TextStrokeColor3 = Color3.new(0,0,0)
    l.BorderSizePixel = 0
    l.Parent = g

    return g
end

local function makeColoredBillboard(playerName, itemText, playerColor, itemColor, distanceText)
    local g = Instance.new("BillboardGui")
    g.Name = "VD_Tag"
    g.AlwaysOnTop = true
    g.Size = UDim2.new(0, 200, 0, 20)
    g.StudsOffset = Vector3.new(0, 2.5, 0)
    g.MaxDistance = 0
    g.Adornee = nil

    local l = Instance.new("TextLabel")
    l.Name = "Label"
    l.BackgroundTransparency = 1
    l.Size = UDim2.new(1, 0, 1, 0)
    l.Font = Enum.Font.GothamBold
    l.TextSize = featureStates.ESPTextSize
    l.TextStrokeTransparency = 0.3
    l.TextStrokeColor3 = Color3.new(0,0,0)
    l.BorderSizePixel = 0

    local fullText = ""
    if playerName and playerName ~= "" then
        fullText = playerName
    end

    if itemText and itemText ~= "" then
        if fullText ~= "" then
            fullText = fullText .. " "
        end
        fullText = fullText .. itemText
    end

    if distanceText and distanceText ~= "" then
        fullText = fullText .. " " .. distanceText
    end

    l.Text = fullText

    if itemText and itemText ~= "" then
        l.TextColor3 = itemColor
    else
        l.TextColor3 = playerColor
    end

    l.Parent = g

    return g
end

local function clearChild(o, n)
    if o and alive(o) then
        local c = o:FindFirstChild(n)
        if c then pcall(function() c:Destroy() end) end
    end
end

local function ensureHighlight(model, fill, isPlayer)
    if not (model and model:IsA("Model") and alive(model)) then return end
    local hl = model:FindFirstChild("VD_HL")
    if not hl then
        local ok, obj = pcall(function()
            local h = Instance.new("Highlight")
            h.Name = "VD_HL"
            h.Adornee = model
            h.FillTransparency = 0.9
            h.OutlineTransparency = 0.2
            h.Parent = model
            return h
        end)
        if ok then hl = obj else return end
    end
    hl.FillColor = fill
    hl.OutlineColor = fill
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop

    if isPlayer then
        hl.FillTransparency = 0.9
        hl.OutlineTransparency = 0.1
    else
        hl.FillTransparency = 0.95
        hl.OutlineTransparency = 0.3
    end
end

local function clearHighlight(model)
    if model and model:FindFirstChild("VD_HL") then
        pcall(function() model.VD_HL:Destroy() end)
    end
end

local function getRoleCached(p) return getRole(p) end

local function getSurvivorItem(player)
    if not player.Character then return nil end
    for _, obj in pairs(player.Character:GetDescendants()) do
        if obj:IsA("Tool") or obj:IsA("Accessory") or obj:IsA("Model") then
            if displayNames[obj.Name] then
                return "("..displayNames[obj.Name]..")"
            end
        end
    end
    return nil
end

local function setNoclip(state)
    if state and not noclipConn then
        noclipEnabled = true
        noclipConn = RunService.Stepped:Connect(function()
            local char = LP.Character
            if char then
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    elseif not state and noclipConn then
        noclipEnabled = false
        noclipConn:Disconnect()
        noclipConn = nil

        local char = LP.Character
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end
end

local function updateDistanceDisplay()
    if not featureStates.DistanceESP then return end

    for _,pl in ipairs(Players:GetPlayers()) do
        if pl ~= LP and pl.Character and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
            local targetRoot = pl.Character:FindFirstChild("HumanoidRootPart")
            local head = pl.Character:FindFirstChild("Head")

            if targetRoot and head then
                local root = LP.Character.HumanoidRootPart
                local distance = math.floor((root.Position - targetRoot.Position).Magnitude)

                local tag = head:FindFirstChild("VD_Tag")
                if tag then
                    local label = tag:FindFirstChild("Label")
                    if label then
                        local currentText = label.Text
                        local originalText = currentText:gsub(" %[%d+m%]", "")
                        label.Text = originalText .. " [" .. distance .. "m]"
                    end
                end
            end
        end
    end
end

local function startDistanceUpdate()
    if distanceUpdateThread then return end

    distanceUpdateThread = task.spawn(function()
        while featureStates.DistanceESP do
            updateDistanceDisplay()
            task.wait(0.2)
        end
        distanceUpdateThread = nil
    end)
end

local function stopDistanceUpdate()
    if distanceUpdateThread then
        distanceUpdateThread = nil
    end

    for _,pl in ipairs(Players:GetPlayers()) do
        if pl ~= LP and pl.Character then
            local head = pl.Character:FindFirstChild("Head")
            if head then
                local tag = head:FindFirstChild("VD_Tag")
                if tag then
                    local label = tag:FindFirstChild("Label")
                    if label then
                        local currentText = label.Text
                        local originalText = currentText:gsub(" %[%d+m%]", "")
                        label.Text = originalText
                    end
                end
            end
        end
    end
end

local function applyPlayerESP(p)
    if p == LP then return end
    local c = p.Character
    if not (c and alive(c)) then return end
    local role = getRole(p)

    clearHighlight(c)
    local head = c:FindFirstChild("Head")
    if head then
        local t = head:FindFirstChild("VD_Tag")
        if t then pcall(function() t:Destroy() end) end
    end

    local distanceText = ""
    if featureStates.DistanceESP and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
        local root = LP.Character.HumanoidRootPart
        local targetRoot = c:FindFirstChild("HumanoidRootPart")
        if targetRoot then
            local distance = math.floor((root.Position - targetRoot.Position).Magnitude)
            distanceText = "[" .. distance .. "m]"
        end
    end

    if role == "Survivor" and featureStates.SurvivorESP then
        ensureHighlight(c, featureStates.SurvivorColor, true)

        if (featureStates.Nametags or featureStates.DistanceESP or featureStates.SurvivorItemsESP) and head and validPart(head) then
            local playerName = ""
            if featureStates.Nametags then
                playerName = p.Name
            end

            local itemText = ""
            if featureStates.SurvivorItemsESP then
                local item = getSurvivorItem(p)
                if item then
                    itemText = item
                end
            end

            local tag = makeColoredBillboard(playerName, itemText, featureStates.SurvivorColor, featureStates.SurvivorItemsColor, distanceText)
            tag.Name = "VD_Tag"
            tag.Adornee = head
            tag.Parent = head
        end
    elseif role == "Killer" and featureStates.KillerESP then
        ensureHighlight(c, featureStates.KillerColor, true)

        if (featureStates.Nametags or featureStates.DistanceESP) and head and validPart(head) then
            local displayText = ""
            if featureStates.Nametags then
                displayText = "Killer"
            end
            displayText = displayText .. " " .. distanceText

            local tag = makeBillboard(displayText, featureStates.KillerColor)
            tag.Name = "VD_Tag"
            tag.Adornee = head
            tag.Parent = head
        end
    end
end

local function watchPlayer(p)
    if playerConns[p] then for _,cn in ipairs(playerConns[p]) do cn:Disconnect() end end
    playerConns[p] = {}
    table.insert(playerConns[p], p.CharacterAdded:Connect(function()
        task.delay(0.15, function() applyPlayerESP(p) end)
    end))
    table.insert(playerConns[p], p:GetPropertyChangedSignal("Team"):Connect(function() applyPlayerESP(p) end))
    if p.Character then applyPlayerESP(p) end
end

local function unwatchPlayer(p)
    if p.Character then
        clearHighlight(p.Character)
        local head = p.Character:FindFirstChild("Head")
        if head and head:FindFirstChild("VD_Tag") then pcall(function() head.VD_Tag:Destroy() end) end
    end
    if playerConns[p] then for _,cn in ipairs(playerConns[p]) do cn:Disconnect() end end
    playerConns[p] = nil
end

local function pickRep(model, cat)
    if not (model and alive(model)) then return nil end
    if cat == "Generator" then
        local hb = model:FindFirstChild("HitBox", true)
        if validPart(hb) then return hb end
    elseif cat == "Palletwrong" then
        local a = model:FindFirstChild("HumanoidRootPart", true); if validPart(a) then return a end
        local b = model:FindFirstChild("PrimaryPartPallet", true); if validPart(b) then return b end
        local c = model:FindFirstChild("Primary1", true); if validPart(c) then return c end
        local d = model:FindFirstChild("Primary2", true); if validPart(d) then return d end
    end
    return firstBasePart(model)
end

local function genLabelData(model)
    local pct = tonumber(model:GetAttribute("RepairProgress")) or 0
    if pct>=0 and pct<=1.001 then pct = pct*100 end
    pct = clamp(pct,0,100)
    local repairers = tonumber(model:GetAttribute("PlayersRepairingCount")) or 0
    local paused = (model:GetAttribute("ProgressPaused")==true)
    local kickcount = tonumber(model:GetAttribute("kickcount")) or 0
    local abyss50 = (model:GetAttribute("Abyss50Triggered")==true)
    -- Note: emoji symbols from the original source replaced with plain text tags
    local parts = {"Gen "..tostring(math.floor(pct+0.5)).."%" }
    if repairers>0 then parts[#parts+1]="("..repairers.."p)" end
    if paused then parts[#parts+1]="[Paused]" end
    if abyss50 then parts[#parts+1]="[Alert]" end
    if kickcount and kickcount>0 then parts[#parts+1]="K:"..kickcount end
    local text = table.concat(parts," ")
    local hue = clamp((pct/100)*0.33,0,0.33)
    local labelColor = Color3.fromHSV(hue,1,1)
    return text, labelColor
end

local function hasAnyBasePart(m)
    if not (m and alive(m)) then return false end
    local bp = m:FindFirstChildWhichIsA("BasePart", true)
    return bp ~= nil
end

local function isPalletGone(m)
    if not alive(m) then return true end
    if not m:IsDescendantOf(Workspace) then return true end
    if palletState[m]=="DEST" then return true end
    local ok, val = pcall(function() return m:GetAttribute("Destroyed") end)
    if ok and val == true then return true end
    if not hasAnyBasePart(m) then return true end
    return false
end

local function ensureWorldEntry(cat, model)
    if not alive(model) or worldReg[cat][model] then return end
    if cat=="Palletwrong" and isPalletGone(model) then return end
    local rep = pickRep(model, cat)
    if not validPart(rep) then return end
    worldReg[cat][model] = {part = rep}
end

local function removeWorldEntry(cat, model)
    local e = worldReg[cat][model]
    if not e then return end
    clearChild(e.part, "VD_Text_"..cat)
    worldReg[cat][model] = nil
end

local function registerFromDescendant(obj)
    if not alive(obj) then return end
    local validCats = {
        Generator = true, Hook = true, Gate = true,
        Window = true, Palletwrong = true
    }
    if obj:IsA("Model") then
        if validCats[obj.Name] then
            ensureWorldEntry(obj.Name, obj)
            return
        end
    end
    if obj:IsA("BasePart") and obj.Parent and obj.Parent:IsA("Model") then
        if validCats[obj.Parent.Name] then
            ensureWorldEntry(obj.Parent.Name, obj.Parent)
        end
    end
end

local function unregisterFromDescendant(obj)
    if not obj then return end
    local validCats = {
        Generator = true, Hook = true, Gate = true,
        Window = true, Palletwrong = true
    }
    if obj:IsA("Model") then
        if validCats[obj.Name] then
            removeWorldEntry(obj.Name, obj)
            return
        end
    end
    if obj:IsA("BasePart") and obj.Parent and obj.Parent:IsA("Model") then
        if validCats[obj.Parent.Name] then
            local e = worldReg[obj.Parent.Name][obj.Parent]
            if e and e.part == obj then removeWorldEntry(obj.Parent.Name, obj.Parent) end
        end
    end
end

local function attachRoot(root)
    if not root or mapAdd[root] then return end
    mapAdd[root] = root.DescendantAdded:Connect(registerFromDescendant)
    mapRem[root] = root.DescendantRemoving:Connect(unregisterFromDescendant)
    for _,d in ipairs(root:GetDescendants()) do registerFromDescendant(d) end
end

local function refreshRoots()
    for _,cn in pairs(mapAdd) do if cn then cn:Disconnect() end end
    for _,cn in pairs(mapRem) do if cn then cn:Disconnect() end end
    mapAdd, mapRem = {}, {}
    local r1 = Workspace:FindFirstChild("Map")
    local r2 = Workspace:FindFirstChild("Map1")
    if r1 then attachRoot(r1) end
    if r2 then attachRoot(r2) end
end

local function labelForPallet(model)
    local st=palletState[model] or "UP"
    if st=="DOWN" then return "Pallet (down)" end
    if st=="DEST" then return "Pallet (destroyed)" end
    if st=="SLIDE" then return "Pallet (slide)" end
    return "Pallet"
end

local function labelForWindow(model)
    local st=windowState[model] or "READY"
    return st=="BUSY" and "Window (busy)" or "Window"
end

local function anyWorldEnabled()
    return featureStates.GeneratorESP or featureStates.HookESP or featureStates.GateESP or
           featureStates.WindowESP or featureStates.PalletESP
end

local function startWorldLoop()
    if worldLoopThread then return end
    worldLoopThread = task.spawn(function()
        while anyWorldEnabled() do
            for cat,models in pairs(worldReg) do
                local enabled = false
                local col = featureStates.GeneratorColor
                if cat == "Generator" then enabled = featureStates.GeneratorESP; col = featureStates.GeneratorColor
                elseif cat == "Hook" then enabled = featureStates.HookESP; col = featureStates.HookColor
                elseif cat == "Gate" then enabled = featureStates.GateESP; col = featureStates.GateColor
                elseif cat == "Window" then enabled = featureStates.WindowESP; col = featureStates.WindowColor
                elseif cat == "Palletwrong" then enabled = featureStates.PalletESP; col = featureStates.PalletColor
                end

                if enabled then
                    local textName = "VD_Text_"..cat
                    local n = 0
                    for model,entry in pairs(models) do
                        if (cat=="Palletwrong" and isPalletGone(model)) then
                            removeWorldEntry(cat, model)
                        else
                            local part = entry.part
                            if model and alive(model) then
                                if not validPart(part) or (model:IsA("Model") and not part:IsDescendantOf(model)) then
                                    entry.part = pickRep(model, cat); part = entry.part
                                end
                                if validPart(part) then
                                    ensureHighlight(model, col, false)
                                    local bb = part:FindFirstChild(textName)
                                    if not bb then
                                        local displayName = cat
                                        if cat == "Palletwrong" then displayName = "Pallet" end

                                        local newbb = makeBillboard(displayName, col)
                                        newbb.Name = textName
                                        newbb.Adornee = part
                                        newbb.Parent = part
                                        bb = newbb
                                    end
                                    local lbl = bb:FindFirstChild("Label")
                                    if lbl then
                                        lbl.TextSize = featureStates.ESPTextSize

                                        if cat=="Generator" then
                                            local txt,lblCol=genLabelData(model)
                                            lbl.Text=txt
                                            lbl.TextColor3=lblCol
                                        elseif cat=="Palletwrong" then
                                            lbl.Text=labelForPallet(model)
                                            lbl.TextColor3=col
                                        elseif cat=="Window" then
                                            lbl.Text=labelForWindow(model)
                                            lbl.TextColor3=col
                                        else
                                            lbl.Text=cat
                                            lbl.TextColor3=col
                                        end
                                    end
                                end
                            else
                                removeWorldEntry(cat, model)
                            end
                        end
                        n = n + 1
                        if n % 60 == 0 then task.wait() end
                    end
                else
                    for model,entry in pairs(models) do
                        if model and alive(model) then
                            clearHighlight(model)
                        end
                    end
                end
            end
            task.wait(0.25)
        end
        worldLoopThread=nil
    end)
end

local function setWalkSpeed(h, v)
    if h and h.Parent then
        pcall(function() h.WalkSpeed = v end)
    end
end

local function bindSpeedLoop()
    if speedBound then return end
    speedBound = true
    RunService:BindToRenderStep("VD_SpeedEnforcer", 300, function()
        if not speedHumanoid or not speedHumanoid.Parent then return end
        if featureStates.WalkSpeed and speedHumanoid.WalkSpeed ~= featureStates.WalkSpeedValue then
            setWalkSpeed(speedHumanoid, featureStates.WalkSpeedValue)
        end
    end)
end

local function unbindSpeedLoop()
    if speedBound then
        speedBound = false
        pcall(function() RunService:UnbindFromRenderStep("VD_SpeedEnforcer") end)
    end
end

local function hookHumanoid(h)
    if speedConnChanged then speedConnChanged:Disconnect() speedConnChanged=nil end
    if speedConnAncestry then speedConnAncestry:Disconnect() speedConnAncestry=nil end

    speedHumanoid = h

    if featureStates.WalkSpeed then
        setWalkSpeed(h, featureStates.WalkSpeedValue)
        bindSpeedLoop()
    else
        pcall(function() if h and h.Parent then h.WalkSpeed = 16 end end)
    end

    speedConnChanged = h:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
        if h.Parent and featureStates.WalkSpeed and h.WalkSpeed ~= featureStates.WalkSpeedValue then
            setWalkSpeed(h, featureStates.WalkSpeedValue)
        end
    end)

    speedConnAncestry = h.AncestryChanged:Connect(function(_, parent)
        if not parent then
            unbindSpeedLoop()
            speedHumanoid = nil
        end
    end)
end

local function onCharacterAdded(char)
    local h = char:WaitForChild("Humanoid", 10) or char:FindFirstChildOfClass("Humanoid")
    if h then hookHumanoid(h) end
    char.ChildAdded:Connect(function(ch) if ch:IsA("Humanoid") then hookHumanoid(ch) end end)
end

local function startAntiAFK()
    antiAFKConn = LP.Idled:Connect(function()
        VirtualUser:Button2Down(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
    end)
end

local function stopAntiAFK()
    if antiAFKConn then
        antiAFKConn:Disconnect()
        antiAFKConn = nil
    end
end

local function updateFullBright()
    if featureStates.FullBright then
        if not fbConn then
            fbConn = RunService.RenderStepped:Connect(function()
                Lighting.GlobalShadows = false
                Lighting.FogEnd = 100000
                Lighting.Brightness = 2
                Lighting.Ambient = Color3.fromRGB(255, 255, 255)
                Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
            end)
        end
    else
        if fbConn then
            fbConn:Disconnect()
            fbConn = nil
            Lighting.GlobalShadows = originalLighting.GlobalShadows
            Lighting.FogEnd = originalLighting.FogEnd
            Lighting.Brightness = originalLighting.Brightness
            Lighting.Ambient = originalLighting.Ambient
            Lighting.OutdoorAmbient = originalLighting.OutdoorAmbient
        end
    end
end

local function bindTimeLock()
    if featureStates.TimeOfDay then
        if not todActive then
            todActive = true
            RunService:BindToRenderStep("VD_TimeLock", 200, function()
                Lighting.ClockTime = featureStates.TimeOfDay
            end)
        end
    else
        if todActive then
            todActive = false
            RunService:UnbindFromRenderStep("VD_TimeLock")
            Lighting.ClockTime = originalLighting.ClockTime
        end
    end
end

local function nfEnable()
    if nfActive then return end
    nfActive = true

    nfStore.lighting.FogEnd = Lighting.FogEnd
    nfStore.lighting.FogStart = Lighting.FogStart

    Lighting.FogEnd = 9e9
    Lighting.FogStart = 9e9

    local function processInstance(inst)
        if nfQueued[inst] then return end
        nfQueued[inst] = true

        if inst:IsA("ParticleEmitter") then
            local name = inst.Name:lower()
            for _, token in ipairs(nfNameTokens) do
                if name:find(token) then
                    nfStore.inst[inst] = inst.Enabled
                    inst.Enabled = false
                    return
                end
            end
        elseif inst:IsA("Smoke") or inst:IsA("Fire") or nfStrictNames[inst.Name] then
            nfStore.inst[inst] = inst.Enabled
            inst.Enabled = false
        end
    end

    nfStore.conns.descendantAdded = Workspace.DescendantAdded:Connect(function(inst)
        processInstance(inst)
    end)

    for _, inst in ipairs(Workspace:GetDescendants()) do
        processInstance(inst)
    end
end

local function nfDisable()
    if not nfActive then return end
    nfActive = false

    if nfStore.lighting.FogEnd then
        Lighting.FogEnd = nfStore.lighting.FogEnd
    end
    if nfStore.lighting.FogStart then
        Lighting.FogStart = nfStore.lighting.FogStart
    end

    for inst, enabled in pairs(nfStore.inst) do
        if inst and inst.Parent then
            pcall(function() inst.Enabled = enabled end)
        end
    end

    if nfStore.conns.descendantAdded then
        nfStore.conns.descendantAdded:Disconnect()
    end

    nfStore = {lighting={},inst=setmetatable({},{__mode="k"}),conns={}}
    nfQueued = setmetatable({},{__mode="k"})
end

local function updateNoShadows()
    if featureStates.NoShadows then
        Lighting.GlobalShadows = false
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("Part") or obj:IsA("MeshPart") or obj:IsA("UnionOperation") then
                if obj.Material == Enum.Material.Plastic or obj.Material == Enum.Material.Wood or obj.Material == Enum.Material.Slate then
                    obj.Material = Enum.Material.SmoothPlastic
                end
            end
        end
    else
        Lighting.GlobalShadows = originalLighting.GlobalShadows
    end
end

local function applyFOV()
    if featureStates.FOVEnabled and Camera and Camera.FieldOfView ~= featureStates.FOVValue then
        Camera.FieldOfView = featureStates.FOVValue
    end
end

local function updateHitboxSystem()
    local roleLP = getRole(LP)
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LP and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = player.Character.HumanoidRootPart
            local apply = (hitboxEnabledAll or (hitboxEnabledKiller and roleLP == "Killer"))

            if apply then
                if not playerHitboxes[player] then
                    playerHitboxes[player] = hrp
                end
                hrp.Size = Vector3.new(headSize, headSize, headSize)
                hrp.Transparency = hitboxTransparency
                hrp.BrickColor = BrickColor.new("Really black")
                hrp.Material = Enum.Material.Neon
                hrp.CanCollide = false
            else
                if playerHitboxes[player] then
                    hrp.Size = Vector3.new(2,2,1)
                    hrp.Transparency = 0
                    hrp.BrickColor = BrickColor.new("Medium stone grey")
                    hrp.Material = Enum.Material.Plastic
                    hrp.CanCollide = true
                    playerHitboxes[player] = nil
                end
            end
        end
    end
end

local function tpCFrame(cf)
    local char=LP.Character
    if not (char and char.Parent) then return end
    local hrp = char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
    local was=featureStates.Noclip
    setNoclip(true)
    hrp.CFrame = cf
    task.delay(0.7,function() if not was then setNoclip(false) end end)
end

local function teleportToRandomSurvivor()
    local hrp=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart"); if not hrp then return end

    local survivors = {}
    for _,pl in ipairs(Players:GetPlayers()) do
        if pl ~= LP and getRole(pl) == "Survivor" then
            table.insert(survivors, pl)
        end
    end

    if #survivors > 0 then
        local randomSurvivor = survivors[math.random(1, #survivors)]
        local ch = randomSurvivor.Character
        local h = ch and ch:FindFirstChild("HumanoidRootPart")

        if h then
            local cf = h.CFrame * CFrame.new(0,0,-3)
            cf = cf + Vector3.new(0,3,0)
            tpCFrame(cf)
            safeNotify("Teleport", "Teleported to: "..randomSurvivor.Name, 4)
        else
            safeNotify("Teleport", "Survivor character not found", 3)
        end
    else
        safeNotify("Teleport", "No survivors found", 3)
    end
end

local function teleportToRandomObject(category)
    local hrp=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart"); if not hrp then return end
    local objects = {}

    for model,entry in pairs(worldReg[category] or {}) do
        if model and alive(model) and entry.part and validPart(entry.part) then
            table.insert(objects, entry.part)
        end
    end

    if #objects > 0 then
        local randomObj = objects[math.random(1, #objects)]
        local cf = randomObj.CFrame + Vector3.new(0, 3, 0)
        tpCFrame(cf)

        local objName = category
        if category == "Palletwrong" then objName = "Pallet" end

        safeNotify("Teleport", "Teleported to random " .. objName, 4)
    else
        safeNotify("Teleport", "No " .. category .. " found", 4)
    end
end

local function teleportToNearestObject(category)
    local hrp=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart"); if not hrp then return end
    local best,bp,bd=nil,nil,1e9

    for model,entry in pairs(worldReg[category] or {}) do
        if model and alive(model) and entry.part and validPart(entry.part) then
            local d=dist(entry.part.Position,hrp.Position)
            if d<bd then bd=d best=model bp=entry.part end
        end
    end

    if best and bp then
        local cf = bp.CFrame + Vector3.new(0, 3, 0)
        tpCFrame(cf)

        local objName = category
        if category == "Palletwrong" then objName = "Pallet" end

        safeNotify("Teleport", "Teleported to nearest " .. objName, 4)
    else
        safeNotify("Teleport", "No " .. category .. " found", 4)
    end
end

-- ════════════════════════════════════════════════════════════════
-- NEW FEATURES (script 2 origin)  (logic unchanged)
-- ════════════════════════════════════════════════════════════════
local function setBypassGate(state)
    featureStates.BypassGate = state

    local function gatherGates()
        local gates = {}
        local function getMapFolders()
            local folders = {}
            local mainMap = Workspace:FindFirstChild("Map")
            if mainMap then
                table.insert(folders, mainMap)
                if mainMap:FindFirstChild("Rooftop") then
                    table.insert(folders, mainMap.Rooftop)
                end
            end
            return folders
        end

        for _, folder in pairs(getMapFolders()) do
            for _, gate in pairs(folder:GetChildren()) do
                if gate.Name == "Gate" then
                    table.insert(gates, gate)
                end
            end
        end
        return gates
    end

    local gates = gatherGates()
    for _, gate in pairs(gates) do
        local leftGate = gate:FindFirstChild("LeftGate")
        local rightGate = gate:FindFirstChild("RightGate")
        local leftEnd = gate:FindFirstChild("LeftGate-end")
        local rightEnd = gate:FindFirstChild("RightGate-end")
        local box = gate:FindFirstChild("Box")

        if state then
            if leftGate then
                leftGate.Transparency = 1
                leftGate.CanCollide = false
            end
            if rightGate then
                rightGate.Transparency = 1
                rightGate.CanCollide = false
            end
            if leftEnd then
                leftEnd.Transparency = 0
                leftEnd.CanCollide = true
            end
            if rightEnd then
                rightEnd.Transparency = 0
                rightEnd.CanCollide = true
            end
            if box then
                box.CanCollide = false
            end
        else
            if leftGate then
                leftGate.Transparency = 0
                leftGate.CanCollide = true
            end
            if rightGate then
                rightGate.Transparency = 0
                rightGate.CanCollide = true
            end
            if leftEnd then
                leftEnd.Transparency = 1
                leftEnd.CanCollide = true
            end
            if rightEnd then
                rightEnd.Transparency = 1
                rightEnd.CanCollide = true
            end
            if box then
                box.CanCollide = true
            end
        end
    end
end

local function startAutoLever()
    autoLeverRunning = true

    task.spawn(function()
        local remote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Exit"):WaitForChild("LeverEvent")

        while autoLeverRunning and featureStates.AutoLever do
            local char = LP.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if root then
                for model, entry in pairs(worldReg.Gate) do
                    if model and alive(model) then
                        local exitLever = model:FindFirstChild("ExitLever")
                        if exitLever then
                            local main = exitLever:FindFirstChild("Main")
                            if main then
                                local d = (root.Position - main.Position).Magnitude
                                if d <= 10 then
                                    remote:FireServer(main, true)
                                end
                            end
                        end
                    end
                end
            end
            task.wait(2)
        end
    end)
end

local function stopAutoLever()
    autoLeverRunning = false
end

local function startKillAll()
    killAllRunning = true

    task.spawn(function()
        local remote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Attacks"):WaitForChild("BasicAttack")
        local startCFrame = nil

        while killAllRunning and featureStates.KillAll do
            local char = LP.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if root then
                if not startCFrame then
                    startCFrame = root.CFrame
                end

                local targets = {}
                for _, plr in ipairs(Players:GetPlayers()) do
                    if plr ~= LP and plr.Character then
                        local targetRoot = plr.Character:FindFirstChild("HumanoidRootPart")
                        local hum = plr.Character:FindFirstChildOfClass("Humanoid")
                        if targetRoot and hum then
                            table.insert(targets, {player = plr, root = targetRoot, humanoid = hum})
                        end
                    end
                end

                if #targets > 0 then
                    for _, entry in ipairs(targets) do
                        if not killAllRunning then break end
                        local targetRoot = entry.root
                        if targetRoot and targetRoot.Parent then
                            root.CFrame = targetRoot.CFrame * CFrame.new(0, 0, 2)
                            pcall(function()
                                remote:FireServer()
                            end)
                            task.wait(0.15)
                        end
                    end

                    local allLowHealth = true
                    for _, entry in ipairs(targets) do
                        if entry.humanoid.Health > 20 then
                            allLowHealth = false
                            break
                        end
                    end

                    if allLowHealth and startCFrame then
                        root.CFrame = startCFrame
                        task.wait(1)
                    else
                        task.wait(0.2)
                    end
                else
                    task.wait(0.5)
                end
            else
                task.wait(0.2)
            end
        end
    end)
end

local function stopKillAll()
    killAllRunning = false
end

local function startAutoAttack()
    autoAttackRunning = true

    task.spawn(function()
        local remote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Attacks"):WaitForChild("BasicAttack")

        while autoAttackRunning and featureStates.AutoAttack do
            local char = LP.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if root then
                local closestTarget = nil
                local closestDist = 10

                for _, plr in ipairs(Players:GetPlayers()) do
                    if plr ~= LP and plr.Character then
                        local targetRoot = plr.Character:FindFirstChild("HumanoidRootPart")
                        if targetRoot then
                            local d = (root.Position - targetRoot.Position).Magnitude
                            if d <= closestDist then
                                closestDist = d
                                closestTarget = plr.Character
                            end
                        end
                    end
                end

                if closestTarget then
                    remote:FireServer()
                end
            end
            task.wait(0.1)
        end
    end)
end

local function stopAutoAttack()
    autoAttackRunning = false
end

local function startNoFlashlight()
    noFlashlightRunning = true

    task.spawn(function()
        while noFlashlightRunning and featureStates.NoFlashlight do
            local playerGui = LP:FindFirstChild("PlayerGui")
            if playerGui then
                for _, descendant in pairs(playerGui:GetDescendants()) do
                    if descendant:IsA("GuiObject") and descendant.Name == "Blind" then
                        descendant:Destroy()
                    end
                end
            end
            task.wait(0.5)
        end
    end)
end

local function stopNoFlashlight()
    noFlashlightRunning = false
end

local function fixCamera()
    local char = LP.Character or LP.CharacterAdded:Wait()
    local hum = char:FindFirstChildOfClass("Humanoid")

    if hum then
        Camera.CameraType = Enum.CameraType.Custom
        Camera.CameraSubject = hum

        LP.CameraMinZoomDistance = 0.5
        LP.CameraMaxZoomDistance = 400
        LP.CameraMode = Enum.CameraMode.Classic

        local head = char:FindFirstChild("Head")
        if head then
            head.Anchored = false
        end

        safeNotify("Camera", "Camera fixed to 3rd person", 3)
    end
end

-- ════════════════════════════════════════════════════════════════
-- WINDOW  (Luna) — Key System DISABLED
-- ════════════════════════════════════════════════════════════════
local Window = Luna:CreateWindow({
    Name = "Anonymous9x Vd",
    Subtitle = "not a great script",
    LogoID = LOGO_ASSET_ID,
    LoadingEnabled = true,
    LoadingTitle = "Anonymous9x Vd",
    LoadingSubtitle = "by Anonymous9x",

    ConfigSettings = {
        RootFolder = nil,
        ConfigFolder = "Anonymous9x Vd",
    },

    -- KeySystem = true,   <-- REMOVED
    -- KeySettings = { ... } <-- REMOVED

    -- Theme = "Dark", -- speculative: not confirmed in the example you gave me.
    -- Size = UDim2.new(0, 0, 0, 0), -- speculative: no Size field shown in the example.
})

Window:CreateHomeTab({
    SupportedExecutors = {
        "Synapse X",
        "Krnl",
        "ProtoSmasher",
        "Fluxus",
        "Script-Ware",
        "EasyExploits",
        "Electron",
        "JJSploit",
        "Calamari",
        "SirHurt",
        "Sentinel",
        "WEAREDEVS",
        "Comet",
        "Cellery",
        "Wave",
        "CODex",
        "Delta"
    },
    DiscordInvite = DISCORD_CODE,
    Icon = 1
})

local PlayerTab    = Window:CreateTab({Name="Player",    Icon="person",              ImageSource="Material", ShowTitle=true})
local SurvivorTab  = Window:CreateTab({Name="Survivor",  Icon="health_and_safety",   ImageSource="Material", ShowTitle=true})
local KillerTab    = Window:CreateTab({Name="Killer",    Icon="dangerous",           ImageSource="Material", ShowTitle=true})
local ESPTab       = Window:CreateTab({Name="ESP",       Icon="visibility",          ImageSource="Material", ShowTitle=true})
local WorldTab     = Window:CreateTab({Name="World",     Icon="public",              ImageSource="Material", ShowTitle=true})
local VisualTab    = Window:CreateTab({Name="Visual",    Icon="wb_sunny",            ImageSource="Material", ShowTitle=true})
local TeleportTab  = Window:CreateTab({Name="Teleport",  Icon="navigation",          ImageSource="Material", ShowTitle=true})
local CrosshairTab = Window:CreateTab({Name="Crosshair", Icon="center_focus_strong", ImageSource="Material", ShowTitle=true})
local MiscTab      = Window:CreateTab({Name="Misc",      Icon="settings",            ImageSource="Material", ShowTitle=true})
local ThemeTab     = Window:CreateTab({Name="Theme",     Icon="palette",             ImageSource="Material", ShowTitle=true})
local ConfigTab    = Window:CreateTab({Name="Config",    Icon="save",                ImageSource="Material", ShowTitle=true})

ThemeTab:BuildThemeSection()
ConfigTab:BuildConfigSection()

-- ════════════════════════════════════════════════════════════════
-- PLAYER TAB
-- ════════════════════════════════════════════════════════════════
PlayerTab:CreateSection("Movement")
PlayerTab:CreateDivider()

PlayerTab:CreateToggle({
    Name = "Walk Speed",
    Description = "Enable a custom walk speed value.",
    CurrentValue = false,
    Callback = function(state)
        featureStates.WalkSpeed = state
        if state then
            if speedHumanoid and speedHumanoid.Parent then
                setWalkSpeed(speedHumanoid, featureStates.WalkSpeedValue)
            end
            bindSpeedLoop()
        else
            unbindSpeedLoop()
            if speedHumanoid and speedHumanoid.Parent then
                setWalkSpeed(speedHumanoid, 16)
            end
        end
    end
}, "WalkSpeedToggle")

PlayerTab:CreateSlider({
    Name = "Walk Speed Value",
    Range = {0, 200},
    Increment = 1,
    CurrentValue = featureStates.WalkSpeedValue,
    Callback = function(value)
        featureStates.WalkSpeedValue = value
        if featureStates.WalkSpeed and speedHumanoid and speedHumanoid.Parent then
            setWalkSpeed(speedHumanoid, featureStates.WalkSpeedValue)
            bindSpeedLoop()
        end
    end
}, "WalkSpeedValueSlider")

PlayerTab:CreateToggle({
    Name = "Noclip",
    Description = "Walk through walls and other parts.",
    CurrentValue = false,
    Callback = function(state)
        featureStates.Noclip = state
        setNoclip(state)
    end
}, "NoclipToggle")

PlayerTab:CreateToggle({
    Name = "God Mode",
    Description = "Keeps your health full and blocks ragdoll on death.",
    CurrentValue = false,
    Callback = function(state)
        featureStates.GodMode = state
        if state then
            enableGodMode()
            safeNotify("God Mode", "God Mode activated. You are now invincible.", 3)
        else
            disableGodMode()
            safeNotify("God Mode", "God Mode deactivated.", 3)
        end
    end
}, "GodModeToggle")

PlayerTab:CreateSection("Utilities")
PlayerTab:CreateDivider()

PlayerTab:CreateToggle({
    Name = "Anti AFK",
    Description = "Prevents being kicked for being idle.",
    CurrentValue = false,
    Callback = function(state)
        featureStates.AntiAFK = state
        if state then
            startAntiAFK()
        else
            stopAntiAFK()
        end
    end
}, "AntiAFKToggle")

-- ════════════════════════════════════════════════════════════════
-- SURVIVOR TAB
-- ════════════════════════════════════════════════════════════════
SurvivorTab:CreateSection("Survivor Main")
SurvivorTab:CreateDivider()

SurvivorTab:CreateToggle({
    Name = "Auto Lever",
    Description = "Automatically pulls exit levers when you are near one.",
    CurrentValue = false,
    Callback = function(state)
        featureStates.AutoLever = state
        if state then
            startAutoLever()
        else
            stopAutoLever()
        end
    end
}, "AutoLeverToggle")

SurvivorTab:CreateToggle({
    Name = "No Skillcheck",
    Description = "Auto-hits generator and healing skillchecks for you.",
    CurrentValue = false,
    Callback = function(state)
        featureStates.NoSkillcheck = state
        if state then
            setupNoSkillcheck()
        else
            disableNoSkillcheck()
        end
    end
}, "NoSkillcheckToggle")

-- ════════════════════════════════════════════════════════════════
-- KILLER TAB
-- ════════════════════════════════════════════════════════════════
KillerTab:CreateSection("Killer Main")
KillerTab:CreateDivider()

KillerTab:CreateToggle({
    Name = "Kill All",
    Description = "Chases and attacks every survivor automatically. High risk of detection.",
    CurrentValue = false,
    Callback = function(state)
        featureStates.KillAll = state
        if state then
            startKillAll()
        else
            stopKillAll()
        end
    end
}, "KillAllToggle")

KillerTab:CreateToggle({
    Name = "Auto Attack",
    Description = "Automatically attacks the closest survivor in range.",
    CurrentValue = false,
    Callback = function(state)
        featureStates.AutoAttack = state
        if state then
            startAutoAttack()
        else
            stopAutoAttack()
        end
    end
}, "AutoAttackToggle")

KillerTab:CreateToggle({
    Name = "No Flashlight",
    Description = "Removes the flashlight blind/screen-cover effect.",
    CurrentValue = false,
    Callback = function(state)
        featureStates.NoFlashlight = state
        if state then
            startNoFlashlight()
        else
            stopNoFlashlight()
        end
    end
}, "NoFlashlightToggle")

KillerTab:CreateSection("Killer Utility")
KillerTab:CreateDivider()

KillerTab:CreateButton({
    Name = "Fix Camera",
    Description = "Resets your camera back to normal third-person view.",
    Callback = function()
        fixCamera()
    end
})

-- ════════════════════════════════════════════════════════════════
-- ESP TAB
-- ════════════════════════════════════════════════════════════════
ESPTab:CreateSection("ESP Settings")
ESPTab:CreateDivider()

ESPTab:CreateSlider({
    Name = "ESP Fill Transparency",
    Range = {0, 100},
    Increment = 5,
    CurrentValue = featureStates.ESPFillTransparency * 100,
    Callback = function(value)
        featureStates.ESPFillTransparency = value / 100
        for _,pl in ipairs(Players:GetPlayers()) do
            if pl ~= LP then applyPlayerESP(pl) end
        end
    end
}, "ESPFillSlider")

ESPTab:CreateSlider({
    Name = "ESP Outline Transparency",
    Range = {0, 100},
    Increment = 5,
    CurrentValue = featureStates.ESPOutlineTransparency * 100,
    Callback = function(value)
        featureStates.ESPOutlineTransparency = value / 100
        for _,pl in ipairs(Players:GetPlayers()) do
            if pl ~= LP then applyPlayerESP(pl) end
        end
    end
}, "ESPOutlineSlider")

ESPTab:CreateSlider({
    Name = "ESP Text Size",
    Range = {8, 20},
    Increment = 1,
    CurrentValue = featureStates.ESPTextSize,
    Callback = function(value)
        featureStates.ESPTextSize = value
        for _,pl in ipairs(Players:GetPlayers()) do
            if pl ~= LP then applyPlayerESP(pl) end
        end
    end
}, "ESPTextSizeSlider")

ESPTab:CreateSection("Player ESP")
ESPTab:CreateDivider()

ESPTab:CreateToggle({
    Name = "Survivor ESP",
    Description = "Highlights every survivor through walls.",
    CurrentValue = false,
    Callback = function(state)
        featureStates.SurvivorESP = state
        for _,pl in ipairs(Players:GetPlayers()) do
            if pl ~= LP and getRole(pl) == "Survivor" then applyPlayerESP(pl) end
        end
    end
}, "SurvivorESPToggle")

ESPTab:CreateToggle({
    Name = "Killer ESP",
    Description = "Highlights the killer through walls.",
    CurrentValue = false,
    Callback = function(state)
        featureStates.KillerESP = state
        for _,pl in ipairs(Players:GetPlayers()) do
            if pl ~= LP and getRole(pl) == "Killer" then applyPlayerESP(pl) end
        end
    end
}, "KillerESPToggle")

ESPTab:CreateToggle({
    Name = "Nametags",
    Description = "Shows player names above their ESP highlight.",
    CurrentValue = false,
    Callback = function(state)
        featureStates.Nametags = state
        for _,pl in ipairs(Players:GetPlayers()) do
            if pl ~= LP then applyPlayerESP(pl) end
        end
    end
}, "NametagsToggle")

ESPTab:CreateToggle({
    Name = "Distance ESP",
    Description = "Shows live distance in studs to every player.",
    CurrentValue = false,
    Callback = function(state)
        featureStates.DistanceESP = state
        if state then
            startDistanceUpdate()
        else
            stopDistanceUpdate()
        end
        for _,pl in ipairs(Players:GetPlayers()) do
            if pl ~= LP then applyPlayerESP(pl) end
        end
    end
}, "DistanceESPToggle")

ESPTab:CreateToggle({
    Name = "Survivor Items ESP",
    Description = "Shows items survivors are currently carrying.",
    CurrentValue = false,
    Callback = function(state)
        featureStates.SurvivorItemsESP = state
        for _,pl in ipairs(Players:GetPlayers()) do
            if pl ~= LP and getRole(pl) == "Survivor" then applyPlayerESP(pl) end
        end
    end
}, "SurvivorItemsESPToggle")

ESPTab:CreateColorPicker({
    Name = "Survivor Color",
    Color = featureStates.SurvivorColor,
    Flag = "SurvivorColorPicker",
    Callback = function(color)
        featureStates.SurvivorColor = color
        for _,pl in ipairs(Players:GetPlayers()) do
            if pl ~= LP and getRole(pl) == "Survivor" and featureStates.SurvivorESP then applyPlayerESP(pl) end
        end
    end
}, "SurvivorColorPicker")

ESPTab:CreateColorPicker({
    Name = "Killer Color",
    Color = featureStates.KillerColor,
    Flag = "KillerColorPicker",
    Callback = function(color)
        featureStates.KillerColor = color
        for _,pl in ipairs(Players:GetPlayers()) do
            if pl ~= LP and getRole(pl) == "Killer" and featureStates.KillerESP then applyPlayerESP(pl) end
        end
    end
}, "KillerColorPicker")

ESPTab:CreateColorPicker({
    Name = "Survivor Items Color",
    Color = featureStates.SurvivorItemsColor,
    Flag = "SurvivorItemsColorPicker",
    Callback = function(color)
        featureStates.SurvivorItemsColor = color
        for _,pl in ipairs(Players:GetPlayers()) do
            if pl ~= LP and getRole(pl) == "Survivor" and featureStates.SurvivorESP and featureStates.SurvivorItemsESP then
                applyPlayerESP(pl)
            end
        end
    end
}, "SurvivorItemsColorPicker")

-- ════════════════════════════════════════════════════════════════
-- WORLD TAB
-- ════════════════════════════════════════════════════════════════
WorldTab:CreateSection("World ESP Toggles")
WorldTab:CreateDivider()

WorldTab:CreateToggle({
    Name = "Generators",
    Description = "Shows generator locations with live repair progress.",
    CurrentValue = false,
    Callback = function(state)
        featureStates.GeneratorESP = state
        if state then
            if not worldLoopThread then startWorldLoop() end
        else
            for model,entry in pairs(worldReg.Generator) do
                if model and alive(model) then
                    clearHighlight(model)
                    if entry and entry.part then clearChild(entry.part,"VD_Text_Generator") end
                end
            end
        end
    end
}, "GeneratorESPToggle")

WorldTab:CreateToggle({
    Name = "Hooks",
    Description = "Shows hook locations on the map.",
    CurrentValue = false,
    Callback = function(state)
        featureStates.HookESP = state
        if state then
            if not worldLoopThread then startWorldLoop() end
        else
            for model,entry in pairs(worldReg.Hook) do
                if model and alive(model) then
                    clearHighlight(model)
                    if entry and entry.part then clearChild(entry.part,"VD_Text_Hook") end
                end
            end
        end
    end
}, "HookESPToggle")

WorldTab:CreateToggle({
    Name = "Gates",
    Description = "Shows exit gate locations.",
    CurrentValue = false,
    Callback = function(state)
        featureStates.GateESP = state
        if state then
            if not worldLoopThread then startWorldLoop() end
        else
            for model,entry in pairs(worldReg.Gate) do
                if model and alive(model) then
                    clearHighlight(model)
                    if entry and entry.part then clearChild(entry.part,"VD_Text_Gate") end
                end
            end
        end
    end
}, "GateESPToggle")

WorldTab:CreateToggle({
    Name = "Windows",
    Description = "Shows vault window locations.",
    CurrentValue = false,
    Callback = function(state)
        featureStates.WindowESP = state
        if state then
            if not worldLoopThread then startWorldLoop() end
        else
            for model,entry in pairs(worldReg.Window) do
                if model and alive(model) then
                    clearHighlight(model)
                    if entry and entry.part then clearChild(entry.part,"VD_Text_Window") end
                end
            end
        end
    end
}, "WindowESPToggle")

WorldTab:CreateToggle({
    Name = "Pallets",
    Description = "Shows pallet locations and their current state.",
    CurrentValue = false,
    Callback = function(state)
        featureStates.PalletESP = state
        if state then
            if not worldLoopThread then startWorldLoop() end
        else
            for model,entry in pairs(worldReg.Palletwrong) do
                if model and alive(model) then
                    clearHighlight(model)
                    if entry and entry.part then clearChild(entry.part,"VD_Text_Palletwrong") end
                end
            end
        end
    end
}, "PalletESPToggle")

WorldTab:CreateSection("World ESP Colors")
WorldTab:CreateDivider()

WorldTab:CreateColorPicker({
    Name = "Generator Color",
    Color = featureStates.GeneratorColor,
    Flag = "GeneratorColorPicker",
    Callback = function(color) featureStates.GeneratorColor = color end
}, "GeneratorColorPicker")

WorldTab:CreateColorPicker({
    Name = "Hook Color",
    Color = featureStates.HookColor,
    Flag = "HookColorPicker",
    Callback = function(color) featureStates.HookColor = color end
}, "HookColorPicker")

WorldTab:CreateColorPicker({
    Name = "Gate Color",
    Color = featureStates.GateColor,
    Flag = "GateColorPicker",
    Callback = function(color) featureStates.GateColor = color end
}, "GateColorPicker")

WorldTab:CreateColorPicker({
    Name = "Window Color",
    Color = featureStates.WindowColor,
    Flag = "WindowColorPicker",
    Callback = function(color) featureStates.WindowColor = color end
}, "WindowColorPicker")

WorldTab:CreateColorPicker({
    Name = "Pallet Color",
    Color = featureStates.PalletColor,
    Flag = "PalletColorPicker",
    Callback = function(color) featureStates.PalletColor = color end
}, "PalletColorPicker")

WorldTab:CreateSection("World Cheats")
WorldTab:CreateDivider()

WorldTab:CreateToggle({
    Name = "Bypass Gate",
    Description = "Walk straight through exit gates without opening them.",
    CurrentValue = false,
    Callback = function(state)
        featureStates.BypassGate = state
        setBypassGate(state)
    end
}, "BypassGateToggle")

-- ════════════════════════════════════════════════════════════════
-- VISUAL TAB
-- ════════════════════════════════════════════════════════════════
VisualTab:CreateSection("Lighting")
VisualTab:CreateDivider()

VisualTab:CreateToggle({
    Name = "Fullbright",
    Description = "Maxes out brightness and removes shadows.",
    CurrentValue = false,
    Callback = function(state)
        featureStates.FullBright = state
        updateFullBright()
    end
}, "FullbrightToggle")

VisualTab:CreateSlider({
    Name = "Time Of Day",
    Range = {0, 24},
    Increment = 1,
    CurrentValue = featureStates.TimeOfDay,
    Callback = function(value)
        featureStates.TimeOfDay = value
        desiredClockTime = value
        Lighting.ClockTime = value
        bindTimeLock()
    end
}, "TimeOfDaySlider")

VisualTab:CreateToggle({
    Name = "No Fog",
    Description = "Removes fog and smoke/mist particle effects from the map.",
    CurrentValue = false,
    Callback = function(state)
        featureStates.NoFog = state
        if state then nfEnable() else nfDisable() end
    end
}, "NoFogToggle")

VisualTab:CreateToggle({
    Name = "No Shadows",
    Description = "Disables global shadows for clearer visibility.",
    CurrentValue = false,
    Callback = function(state)
        featureStates.NoShadows = state
        updateNoShadows()
    end
}, "NoShadowsToggle")

VisualTab:CreateSection("FOV")
VisualTab:CreateDivider()

VisualTab:CreateToggle({
    Name = "Custom FOV",
    Description = "Overrides your camera field of view.",
    CurrentValue = false,
    Callback = function(state)
        featureStates.FOVEnabled = state
        if state then
            applyFOV()
        else
            if Camera then Camera.FieldOfView = 70 end
        end
    end
}, "CustomFOVToggle")

VisualTab:CreateSlider({
    Name = "FOV Value",
    Range = {70, 120},
    Increment = 1,
    CurrentValue = featureStates.FOVValue,
    Callback = function(value)
        featureStates.FOVValue = value
        if featureStates.FOVEnabled then applyFOV() end
    end
}, "FOVValueSlider")

-- ════════════════════════════════════════════════════════════════
-- TELEPORT TAB
-- ════════════════════════════════════════════════════════════════
TeleportTab:CreateSection("Player Teleport")
TeleportTab:CreateDivider()

TeleportTab:CreateButton({
    Name = "Teleport to Random Survivor",
    Description = "Instantly teleports you next to a random survivor.",
    Callback = function()
        teleportToRandomSurvivor()
    end
})

TeleportTab:CreateButton({
    Name = "Teleport to Killer",
    Description = "Instantly teleports you next to the killer.",
    Callback = function()
        local function findKiller()
            for _,pl in ipairs(Players:GetPlayers()) do
                if pl ~= LP and getRole(pl) == "Killer" then return pl end
            end
            return nil
        end

        local killer = findKiller()
        if killer and killer.Character then
            local hrp = killer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local cf = hrp.CFrame * CFrame.new(0,0,-3) + Vector3.new(0,3,0)
                tpCFrame(cf)
                safeNotify("Teleport", "Teleported to Killer: "..killer.Name, 4)
            else
                safeNotify("Teleport", "Killer character not found", 4)
            end
        else
            safeNotify("Teleport", "No killer found", 4)
        end
    end
})

TeleportTab:CreateSection("World Teleport")
TeleportTab:CreateDivider()

local selectedWorldCategory = "Generator"

TeleportTab:CreateDropdown({
    Name = "Select Object Type",
    Description = "Choose which kind of world object to teleport to.",
    Options = {"Generator", "Hook", "Gate", "Window", "Pallet"},
    CurrentOption = {"Generator"},
    MultipleOptions = false,
    SpecialType = nil,
    Callback = function(Options)
        local picked = (type(Options) == "table") and Options[1] or Options
        selectedWorldCategory = picked
    end
}, "WorldCategoryDropdown")

TeleportTab:CreateButton({
    Name = "Teleport to Random Object",
    Description = "Teleports to a random object of the selected type.",
    Callback = function()
        local category = selectedWorldCategory
        if category == "Pallet" then category = "Palletwrong" end
        teleportToRandomObject(category)
    end
})

TeleportTab:CreateButton({
    Name = "Teleport to Nearest Object",
    Description = "Teleports to the nearest object of the selected type.",
    Callback = function()
        local category = selectedWorldCategory
        if category == "Pallet" then category = "Palletwrong" end
        teleportToNearestObject(category)
    end
})

TeleportTab:CreateSection("Escape")
TeleportTab:CreateDivider()

TeleportTab:CreateButton({
    Name = "Instant-Escape",
    Description = "Teleports you behind the nearest exit gate lever.",
    Callback = function()
        local function findExitLevers()
            local list={}
            local map=Workspace:FindFirstChild("Map")
            if not map then return list end
            for _,d in ipairs(map:GetDescendants()) do
                if d.Name=="ExitLever" then
                    local p=firstBasePart(d)
                    if validPart(p) then table.insert(list,p) end
                end
            end
            return list
        end

        local function teleportRightOfLever(leverPart)
            local right = leverPart.CFrame.RightVector * 50
            local targetPos = leverPart.Position + right
            tpCFrame(CFrame.new(targetPos))
        end

        local levers = findExitLevers()
        if #levers==0 then
            safeNotify("Instant-Escape", "No ExitLever found.", 5)
            return
        end
        local hrp=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        local pick = levers[1]
        if hrp then
            local bd=1e9
            for _,p in ipairs(levers) do local d=(p.Position-hrp.Position).Magnitude if d<bd then bd=d pick=p end end
        end
        teleportRightOfLever(pick)
        safeNotify("Instant-Escape", "Teleported behind gate.", 4)
    end
})

-- ════════════════════════════════════════════════════════════════
-- CROSSHAIR TAB
-- ════════════════════════════════════════════════════════════════
CrosshairTab:CreateSection("Main Settings")
CrosshairTab:CreateDivider()

CrosshairTab:CreateToggle({
    Name = "Enable Crosshair",
    Description = "Turns the on-screen crosshair on or off.",
    CurrentValue = false,
    Callback = function(state)
        ToggleCrosshair(state)
    end
}, "EnableCrosshairToggle")

CrosshairTab:CreateDropdown({
    Name = "Crosshair Type",
    Description = "Choose from 19 crosshair designs.",
    Options = {
        "Dot", "Circle", "Cross", "Cross-Dot",
        "Square", "Square-Outline", "Diamond", "Diamond-Outline",
        "Triangle", "Triangle-Down", "Advanced", "Sniper",
        "Circle-Dot", "Cross-Circle", "Square-Cross", "Heart",
        "Star", "Target", "Reticle"
    },
    CurrentOption = {Crosshair.CurrentType},
    MultipleOptions = false,
    SpecialType = nil,
    Callback = function(Options)
        local v = (type(Options) == "table") and Options[1] or Options
        ChangeCrosshairType(v)
    end
}, "CrosshairTypeDropdown")

CrosshairTab:CreateSection("Appearance")
CrosshairTab:CreateDivider()

CrosshairTab:CreateColorPicker({
    Name = "Crosshair Color",
    Color = Crosshair.Color,
    Flag = "CrosshairColorPicker",
    Callback = function(color) ChangeCrosshairColor(color) end
}, "CrosshairColorPicker")

CrosshairTab:CreateSlider({
    Name = "Crosshair Size",
    Range = {10, 150},
    Increment = 1,
    CurrentValue = Crosshair.Size,
    Callback = function(value) ChangeCrosshairSize(value) end
}, "CrosshairSizeSlider")

CrosshairTab:CreateSlider({
    Name = "Crosshair Transparency",
    Range = {0, 100},
    Increment = 5,
    CurrentValue = Crosshair.Transparency * 100,
    Callback = function(value) ChangeCrosshairTransparency(value / 100) end
}, "CrosshairTransparencySlider")

CrosshairTab:CreateSection("Advanced Settings")
CrosshairTab:CreateDivider()

CrosshairTab:CreateSlider({
    Name = "Line Thickness",
    Range = {1, 10},
    Increment = 1,
    CurrentValue = Crosshair.Thickness,
    Callback = function(value) ChangeCrosshairThickness(value) end
}, "CrosshairThicknessSlider")

CrosshairTab:CreateSlider({
    Name = "Center Gap",
    Range = {0, 30},
    Increment = 1,
    CurrentValue = Crosshair.Gap,
    Callback = function(value) ChangeCrosshairGap(value) end
}, "CrosshairGapSlider")

CrosshairTab:CreateToggle({
    Name = "Outline Effect",
    Description = "Adds an outline to crosshair elements.",
    CurrentValue = false,
    Callback = function(state) ToggleOutline(state) end
}, "CrosshairOutlineToggle")

CrosshairTab:CreateColorPicker({
    Name = "Outline Color",
    Color = Crosshair.OutlineColor,
    Flag = "CrosshairOutlineColorPicker",
    Callback = function(color) ChangeOutlineColor(color) end
}, "CrosshairOutlineColorPicker")

CrosshairTab:CreateToggle({
    Name = "Pulse Animation",
    Description = "Adds a subtle pulsing animation to the crosshair.",
    CurrentValue = false,
    Callback = function(state) ToggleAnimation(state) end
}, "CrosshairPulseToggle")

CrosshairTab:CreateSection("Preview & Control")
CrosshairTab:CreateDivider()

CrosshairTab:CreateButton({
    Name = "Refresh Crosshair",
    Description = "Forces the crosshair display to refresh.",
    Callback = function()
        UpdateCrosshair()
        SetupResponsiveBehavior()
    end
})

CrosshairTab:CreateButton({
    Name = "Reset to Default",
    Description = "Resets every crosshair setting back to default (off).",
    Callback = function()
        Crosshair.Enabled = false
        Crosshair.CurrentType = "Dot"
        Crosshair.Color = Color3.fromRGB(255, 255, 255)
        Crosshair.Size = 20
        Crosshair.Transparency = 0.8
        Crosshair.Thickness = 2
        Crosshair.Gap = 3
        Crosshair.Outline = false
        Crosshair.OutlineColor = Color3.fromRGB(0, 0, 0)
        Crosshair.Animation = false
        UpdateCrosshair()
        SetupResponsiveBehavior()
        safeNotify("Crosshair Reset", "All crosshair settings reset to default.", 3)
    end
})

-- ════════════════════════════════════════════════════════════════
-- MISC TAB
-- ════════════════════════════════════════════════════════════════
MiscTab:CreateSection("Notifications")
MiscTab:CreateDivider()

MiscTab:CreateToggle({
    Name = "Killer Ability Notify",
    Description = "Notifies you when the killer uses their ability.",
    CurrentValue = true,
    Callback = function(state)
        featureStates.AbilityNotify = state
    end
}, "AbilityNotifyToggle")

MiscTab:CreateSection("Fling Player")
MiscTab:CreateDivider()

-- NOTE: Luna's documented example does not show a method to refresh a
-- Dropdown's options after creation. The dropdown below lists players who
-- were online when the menu loaded. For full reliability, use the exact-name
-- input box underneath — it works for anyone online right now.
local initialFlingNames = {}
for _, p in ipairs(Players:GetPlayers()) do
    if p ~= LP then table.insert(initialFlingNames, p.Name) end
end
if #initialFlingNames == 0 then initialFlingNames = {"No players online"} end

MiscTab:CreateDropdown({
    Name = "Select Player to Fling",
    Description = "Pick a player who was online when this menu loaded.",
    Options = initialFlingNames,
    CurrentOption = {initialFlingNames[1]},
    MultipleOptions = false,
    SpecialType = nil,
    Callback = function(Options)
        local picked = (type(Options) == "table") and Options[1] or Options
        local found = Players:FindFirstChild(picked)
        featureStates.FlingTarget = found
    end
}, "FlingPlayerDropdown")

MiscTab:CreateInput({
    Name = "Fling Target (exact name)",
    Description = "Type an exact player name if they are not in the dropdown above (the dropdown only lists players who were online when the menu loaded).",
    PlaceholderText = "ExamplePlayerName",
    CurrentValue = "",
    Numeric = false,
    MaxCharacters = nil,
    Enter = true,
    Callback = function(Text)
        if Text and Text ~= "" then
            local found = Players:FindFirstChild(Text)
            if found then
                featureStates.FlingTarget = found
                safeNotify("Fling Target Set", "Target locked to: " .. found.Name, 3)
            else
                safeNotify("Fling Target Not Found", "No player named " .. Text .. " is currently online.", 3)
            end
        end
    end
}, "FlingTargetInput")

MiscTab:CreateToggle({
    Name = "Fling Selected Player",
    Description = "Repeatedly flings whichever player is currently selected above.",
    CurrentValue = false,
    Callback = function(state)
        featureStates.FlingPlayer = state
        if state then
            if featureStates.FlingTarget then
                startFlingLoop()
                safeNotify("Fling", "Flinging " .. featureStates.FlingTarget.Name, 3)
            else
                safeNotify("Fling", "Please select a player first.", 3)
                featureStates.FlingPlayer = false
            end
        else
            stopFling()
        end
    end
}, "FlingPlayerToggle")

MiscTab:CreateToggle({
    Name = "Auto Fling Killer",
    Description = "Automatically flings the killer. Disabled if you are the killer yourself.",
    CurrentValue = false,
    Callback = function(state)
        featureStates.FlingKiller = state
        if state then
            if getRole(LP) == "Killer" then
                safeNotify("Fling Killer", "You are the killer, cannot use this feature.", 3)
                featureStates.FlingKiller = false
                return
            end
            startFlingLoop()
            safeNotify("Fling Killer", "Auto fling killer activated.", 3)
        else
            stopFling()
        end
    end
}, "AutoFlingKillerToggle")

MiscTab:CreateButton({
    Name = "Stop All Fling",
    Description = "Stops all flinging and returns you to your original position.",
    Callback = function()
        stopFling()
        safeNotify("Fling", "All flinging stopped. Returned to original position.", 3)
    end
})

MiscTab:CreateSection("Hitbox")
MiscTab:CreateDivider()

MiscTab:CreateToggle({
    Name = "Hitbox (Killer Only)",
    Description = "Expands the killer's hitbox, making them easier to hit.",
    CurrentValue = false,
    Callback = function(state)
        hitboxEnabledKiller = state
        featureStates.HitboxKiller = state
    end
}, "HitboxKillerToggle")

MiscTab:CreateToggle({
    Name = "Hitbox (All Players)",
    Description = "Expands every player's hitbox.",
    CurrentValue = false,
    Callback = function(state)
        hitboxEnabledAll = state
        featureStates.HitboxAll = state
    end
}, "HitboxAllToggle")

MiscTab:CreateSlider({
    Name = "Hitbox Size",
    Range = {4, 30},
    Increment = 1,
    CurrentValue = featureStates.HitboxSize,
    Callback = function(value)
        headSize = value
        featureStates.HitboxSize = value
    end
}, "HitboxSizeSlider")

MiscTab:CreateSlider({
    Name = "Hitbox Transparency",
    Range = {0, 100},
    Increment = 5,
    CurrentValue = featureStates.HitboxTransparency * 100,
    Callback = function(value)
        hitboxTransparency = value / 100
        featureStates.HitboxTransparency = value / 100
    end
}, "HitboxTransparencySlider")

-- ════════════════════════════════════════════════════════════════
-- INITIALIZE SYSTEMS
-- ════════════════════════════════════════════════════════════════
if LocalPlayer.Character then
    onCharacterAdded(LocalPlayer.Character)
end

LocalPlayer.CharacterAdded:Connect(onCharacterAdded)

for _,p in ipairs(Players:GetPlayers()) do if p~=LP then watchPlayer(p) end end
Players.PlayerAdded:Connect(watchPlayer)
Players.PlayerRemoving:Connect(unwatchPlayer)

refreshRoots()
Workspace.ChildAdded:Connect(function(ch)
    if ch.Name=="Map" or ch.Name=="Map1" then
        attachRoot(ch)
    end
end)

bindTimeLock()
updateFullBright()
updateNoShadows()

if anyWorldEnabled() then
    startWorldLoop()
end

Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    task.wait(0.1)
    Camera = Workspace.CurrentCamera
    if featureStates.FOVEnabled then
        applyFOV()
    end
end)

task.spawn(function()
    task.wait(2)
    CreateCrosshairGUI()
    UpdateCrosshair()
    SetupResponsiveBehavior()
end)

RunService.RenderStepped:Connect(function()
    if featureStates.FOVEnabled then
        applyFOV()
    end

    updateHitboxSystem()

    if featureStates.FullBright then
        updateFullBright()
    end
    if featureStates.NoShadows then
        updateNoShadows()
    end
    if featureStates.TimeOfDay then
        bindTimeLock()
    end
end)

Players.PlayerRemoving:Connect(function(player)
    if playerHitboxes[player] then
        playerHitboxes[player]:Destroy()
        playerHitboxes[player] = nil
    end
end)

Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    task.wait(0.5)
    if Crosshair.Gui then
        UpdateCrosshair()
    end
end)

LocalPlayer:GetPropertyChangedSignal("PlayerGui"):Connect(function()
    task.wait(1)
    if Crosshair.Gui and Crosshair.Gui.Parent == nil then
        CreateCrosshairGUI()
        UpdateCrosshair()
        SetupResponsiveBehavior()
    end
end)

game:GetService("ScriptContext").DescendantRemoving:Connect(function(descendant)
    if descendant == script then
        disableNoSkillcheck()
        stopFling()
    end
end)

-- ════════════════════════════════════════════════════════════════
-- FINAL INITIALIZATION
-- ════════════════════════════════════════════════════════════════
task.spawn(function()
    task.wait(3)
    safeNotify(
        "Anonymous9x Vd",
        "Loaded successfully. Open any tab to start using a feature.",
        6
    )
end)
