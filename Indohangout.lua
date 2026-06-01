local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local LP = Players.LocalPlayer
local Cam = workspace.CurrentCamera
local PLACE_ID = 9788848685
local inCorrectMap = game.PlaceId == PLACE_ID
local char, hum, hrp
local function linkChar(c)
	char = c
	hum = c:WaitForChild("Humanoid", 10)
	hrp = c:WaitForChild("HumanoidRootPart", 10)
end
if LP.Character then linkChar(LP.Character) end
LP.CharacterAdded:Connect(linkChar)
local CatalogOnApplyOutfit
if inCorrectMap then
	pcall(function()
		local BB = ReplicatedStorage:WaitForChild("BloxbizRemotes", 6)
		if BB then CatalogOnApplyOutfit = BB:WaitForChild("CatalogOnApplyOutfit", 6) end
	end)
end
local selectedPlayer = nil
local isSpectating = false
local lastCamSubject = nil
local isFollowing = false
local followConn = nil
local isNoclip = false
local noclipConn = nil
local isAntiAfk = false
local speedVal = 16
local isESP = false
local espConn = nil
local espDrawings = {}
pcall(function() game.CoreGui:FindFirstChild("_A9xIH"):Destroy() end)
pcall(function() LP.PlayerGui:FindFirstChild("_A9xIH"):Destroy() end)
local gui = Instance.new("ScreenGui")
gui.Name = "_A9xIH"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.IgnoreGuiInset = true
pcall(function() gui.Parent = game.CoreGui end)
if not gui.Parent then gui.Parent = LP.PlayerGui end
local T = {
	bg = Color3.fromRGB(7, 7, 9),
	hdr = Color3.fromRGB(5, 5, 7),
	card = Color3.fromRGB(15, 15, 19),
	cardH = Color3.fromRGB(21, 21, 27),
	sep = Color3.fromRGB(26, 26, 34),
	border = Color3.fromRGB(40, 40, 56),
	white = Color3.new(1, 1, 1),
	pri = Color3.fromRGB(218, 218, 226),
	sec = Color3.fromRGB(110, 110, 130),
	dim = Color3.fromRGB(60, 60, 80),
	purple = Color3.fromRGB(170, 110, 255),
	purpleD = Color3.fromRGB(120, 70, 210),
	safe = Color3.fromRGB(80, 185, 90),
	danger = Color3.fromRGB(210, 55, 55),
}
local W = 240
local HDR = 32
local H = 360
local notifQueue = {}
local notifActive = false
local function showNotif(title, body, duration)
	table.insert(notifQueue, {title=title, body=body, dur=duration or 3.5})
	if notifActive then return end
	notifActive = true
	task.spawn(function()
		while #notifQueue > 0 do
			local n = table.remove(notifQueue, 1)
			local nf = Instance.new("Frame")
			nf.Size = UDim2.fromOffset(220, 54)
			nf.Position = UDim2.new(1, 10, 1, -70)
			nf.BackgroundColor3 = T.bg
			nf.BackgroundTransparency = 0
			nf.BorderSizePixel = 0
			nf.ZIndex = 800
			nf.Parent = gui
			Instance.new("UICorner", nf).CornerRadius = UDim.new(0, 7)
			local nfS = Instance.new("UIStroke", nf)
			nfS.Color = T.purple
			nfS.Thickness = 1.2
			local nt = Instance.new("TextLabel")
			nt.Size = UDim2.new(1,-12,0,18)
			nt.Position = UDim2.fromOffset(8, 5)
			nt.BackgroundTransparency = 1
			nt.Text = n.title
			nt.Font = Enum.Font.GothamBold
			nt.TextSize = 10
			nt.TextColor3 = T.white
			nt.TextXAlignment = Enum.TextXAlignment.Left
			nt.ZIndex = 801
			nt.Parent = nf
			local nb = Instance.new("TextLabel")
			nb.Size = UDim2.new(1,-12,0,22)
			nb.Position = UDim2.fromOffset(8, 24)
			nb.BackgroundTransparency = 1
			nb.Text = n.body
			nb.Font = Enum.Font.Gotham
			nb.TextSize = 8
			nb.TextColor3 = T.sec
			nb.TextXAlignment = Enum.TextXAlignment.Left
			nb.TextWrapped = true
			nb.ZIndex = 801
			nb.Parent = nf
			TweenService:Create(nf, TweenInfo.new(0.20, Enum.EasingStyle.Quad), {Position = UDim2.new(1,-228,1,-70)}):Play()
			task.wait(n.dur)
			TweenService:Create(nf, TweenInfo.new(0.18, Enum.EasingStyle.Quad), {Position = UDim2.new(1,10,1,-70)}):Play()
			task.wait(0.20)
			pcall(function() nf:Destroy() end)
			task.wait(0.08)
		end
		notifActive = false
	end)
end
task.delay(0.6, function()
	if inCorrectMap then
		showNotif("Execute successfully", "Indo Hangout | By @Anonymous9x", 4)
	else
		showNotif("Wrong game!", "This script is for Indo Hangout only. By @Anonymous9x", 6)
	end
end)
if not inCorrectMap then return end
local vp = Cam.ViewportSize
if vp.X < 10 then task.wait(0.1); vp = Cam.ViewportSize end
local win = Instance.new("Frame")
win.Name = "Win"
win.Size = UDim2.fromOffset(W, H)
win.Position = UDim2.fromScale(0.5, 0.5)
win.AnchorPoint = Vector2.new(0.5, 0.5)
win.BackgroundColor3 = T.bg
win.BackgroundTransparency = 0
win.BorderSizePixel = 0
win.ClipsDescendants = true
win.ZIndex = 10
win.Parent = gui
Instance.new("UICorner", win).CornerRadius = UDim.new(0, 8)
local winS = Instance.new("UIStroke", win)
winS.Thickness = 1.3
winS.Color = T.border
task.spawn(function()
	local t = 0
	while win.Parent do
		t = t + task.wait(0.04)
		local s = (math.sin(t * 2.4) + 1) / 2
		winS.Color = Color3.new(0.86 + s * 0.14, 0.76 + s * 0.05, 0.88 + s * 0.52)
		winS.Thickness = 1.2 + s * 0.6
		if math.random(1, 90) == 1 then winS.Color = T.purple task.wait(0.04) end
	end
end)
local shimmerF = Instance.new("Frame")
shimmerF.Size = UDim2.fromOffset(W*3, H)
shimmerF.Position = UDim2.fromOffset(-W, 0)
shimmerF.BackgroundColor3 = Color3.new(1,1,1)
shimmerF.BackgroundTransparency = 1
shimmerF.BorderSizePixel = 0
shimmerF.ZIndex = 9
shimmerF.Parent = win
local shimmerGrad = Instance.new("UIGradient")
shimmerGrad.Rotation = 35
shimmerGrad.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.new(1,1,1)),
	ColorSequenceKeypoint.new(0.4, Color3.new(1,1,1)),
	ColorSequenceKeypoint.new(0.5, Color3.fromRGB(180,140,255)),
	ColorSequenceKeypoint.new(0.6, Color3.new(1,1,1)),
	ColorSequenceKeypoint.new(1, Color3.new(1,1,1)),
})
shimmerGrad.Transparency = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 1),
	NumberSequenceKeypoint.new(0.4, 1),
	NumberSequenceKeypoint.new(0.5, 0.92),
	NumberSequenceKeypoint.new(0.6, 1),
	NumberSequenceKeypoint.new(1, 1),
})
shimmerGrad.Parent = shimmerF
task.spawn(function()
	while win.Parent do
		TweenService:Create(shimmerF, TweenInfo.new(3.2, Enum.EasingStyle.Linear), {Position = UDim2.fromOffset(W, 0)}):Play()
		task.wait(3.3)
		shimmerF.Position = UDim2.fromOffset(-W, 0)
		task.wait(0.1)
	end
end)
local hdr = Instance.new("Frame")
hdr.Size = UDim2.new(1,0,0,HDR)
hdr.BackgroundColor3 = T.hdr
hdr.BackgroundTransparency = 0
hdr.BorderSizePixel = 0
hdr.ZIndex = 12
hdr.Parent = win
Instance.new("UICorner", hdr).CornerRadius = UDim.new(0, 8)
local hPatch = Instance.new("Frame")
hPatch.Size = UDim2.new(1,0,0,8)
hPatch.Position = UDim2.new(0,0,1,-8)
hPatch.BackgroundColor3 = T.hdr
hPatch.BorderSizePixel = 0
hPatch.ZIndex = 11
hPatch.Parent = hdr
local hSep = Instance.new("Frame")
hSep.Size = UDim2.new(1,0,0,1)
hSep.Position = UDim2.new(0,0,1,-1)
hSep.BackgroundColor3 = T.sep
hSep.BorderSizePixel = 0
hSep.ZIndex = 13
hSep.Parent = hdr
local hTitle = Instance.new("TextLabel")
hTitle.Size = UDim2.new(1,-52,1,0)
hTitle.Position = UDim2.fromOffset(9,0)
hTitle.BackgroundTransparency = 1
hTitle.Text = "Ano9x Indo Hangout"
hTitle.Font = Enum.Font.GothamBold
hTitle.TextSize = 10
hTitle.TextColor3 = T.pri
hTitle.TextXAlignment = Enum.TextXAlignment.Left
hTitle.TextTruncate = Enum.TextTruncate.AtEnd
hTitle.ZIndex = 13
hTitle.Parent = hdr
local function makeCtrl(xOff, sym)
	local b = Instance.new("ImageButton")
	b.Size = UDim2.fromOffset(20,18)
	b.Position = UDim2.new(1,xOff,0.5,-9)
	b.BackgroundColor3 = T.card
	b.BackgroundTransparency = 0
	b.BorderSizePixel = 0
	b.Image = ""
	b.AutoButtonColor = false
	b.ZIndex = 14
	b.Parent = hdr
	Instance.new("UICorner",b).CornerRadius = UDim.new(0,4)
	local l = Instance.new("TextLabel")
	l.Size = UDim2.fromScale(1,1)
	l.BackgroundTransparency = 1
	l.Text = sym
	l.Font = Enum.Font.GothamBold
	l.TextSize = 12
	l.TextColor3 = T.sec
	l.ZIndex = 15
	l.Parent = b
	b.MouseEnter:Connect(function()
		TweenService:Create(b,TweenInfo.new(0.10),{BackgroundColor3=T.cardH}):Play()
		l.TextColor3 = T.white
	end)
	b.MouseLeave:Connect(function()
		TweenService:Create(b,TweenInfo.new(0.10),{BackgroundColor3=T.card}):Play()
		l.TextColor3 = T.sec
	end)
	return b, l
end
local minBtn, minL = makeCtrl(-44, "-")
local closeBtn, _ = makeCtrl(-22, "x")
local floatF = Instance.new("Frame")
floatF.Name = "FloatIcon"
floatF.Size = UDim2.fromOffset(46,46)
floatF.BackgroundColor3 = T.hdr
floatF.BackgroundTransparency = 0
floatF.BorderSizePixel = 0
floatF.Visible = false
floatF.ZIndex = 500
floatF.Parent = gui
Instance.new("UICorner",floatF).CornerRadius = UDim.new(0,10)
local fiS = Instance.new("UIStroke",floatF)
fiS.Color = T.purple
fiS.Thickness = 1.4
task.spawn(function()
	local t = 0
	while gui.Parent do
		t = t + task.wait(0.05)
		local s = (math.sin(t*3)+1)/2
		fiS.Color = Color3.new(0.8+s*0.2, 0.5+s*0.1, 1)
		fiS.Thickness = 1.2+s*0.6
	end
end)
local fiImg = Instance.new("ImageLabel")
fiImg.Size = UDim2.fromOffset(40,40)
fiImg.Position = UDim2.fromOffset(3,3)
fiImg.BackgroundTransparency = 1
fiImg.Image = "rbxassetid://97269958324726"
fiImg.ScaleType = Enum.ScaleType.Crop
fiImg.ZIndex = 501
fiImg.Parent = floatF
Instance.new("UICorner",fiImg).CornerRadius = UDim.new(0,8)
local function anchorFloat()
	local vp2 = Cam.ViewportSize
	if vp2.X < 10 then vp2 = Vector2.new(800,600) end
	floatF.Position = UDim2.fromOffset(vp2.X-56, math.floor(vp2.Y/2)-23)
end
anchorFloat()
local fiBtn = Instance.new("ImageButton")
fiBtn.Size = UDim2.fromScale(1,1)
fiBtn.BackgroundTransparency = 1
fiBtn.Image = ""
fiBtn.AutoButtonColor = false
fiBtn.ZIndex = 502
fiBtn.Parent = floatF
fiBtn.MouseButton1Click:Connect(function()
	floatF.Visible = false
	win.Visible = true
	minL.Text = "-"
end)
fiBtn.MouseEnter:Connect(function()
	TweenService:Create(floatF,TweenInfo.new(0.12),{BackgroundColor3=T.card}):Play()
end)
fiBtn.MouseLeave:Connect(function()
	TweenService:Create(floatF,TweenInfo.new(0.12),{BackgroundColor3=T.hdr}):Play()
end)
minBtn.MouseButton1Click:Connect(function()
	win.Visible = false
	anchorFloat()
	floatF.Visible = true
	minL.Text = "+"
end)
closeBtn.MouseButton1Click:Connect(function()
	isFollowing = false
	isNoclip = false
	isAntiAfk = false
	isSpectating = false
	isESP = false
	if followConn then followConn:Disconnect() followConn = nil end
	if noclipConn then noclipConn:Disconnect() noclipConn = nil end
	if espConn then espConn:Disconnect() espConn = nil end
	for _, drawings in pairs(espDrawings) do
		for _, d in pairs(drawings) do
			pcall(function() d:Remove() end)
		end
	end
	espDrawings = {}
	if lastCamSubject then pcall(function() Cam.CameraSubject = lastCamSubject end) end
	pcall(function() gui:Destroy() end)
end)
local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1,0,1,-HDR)
scroll.Position = UDim2.fromOffset(0,HDR)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 3
scroll.ScrollBarImageColor3 = T.purple
scroll.ScrollingDirection = Enum.ScrollingDirection.Y
scroll.CanvasSize = UDim2.fromOffset(0,0)
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.ZIndex = 11
scroll.Parent = win
local sLL = Instance.new("UIListLayout")
sLL.SortOrder = Enum.SortOrder.LayoutOrder
sLL.Padding = UDim.new(0,4)
sLL.Parent = scroll
local sPad = Instance.new("UIPadding")
sPad.PaddingLeft = UDim.new(0,7)
sPad.PaddingRight = UDim.new(0,7)
sPad.PaddingTop = UDim.new(0,7)
sPad.PaddingBottom = UDim.new(0,10)
sPad.Parent = scroll
local _order = 0
local function ord()
	_order = _order + 1
	return _order
end
local function mkSec(title)
	local f = Instance.new("Frame")
	f.Size = UDim2.new(1,0,0,18)
	f.BackgroundTransparency = 1
	f.BorderSizePixel = 0
	f.LayoutOrder = ord()
	f.ZIndex = 12
	f.Parent = scroll
	local l = Instance.new("TextLabel")
	l.Size = UDim2.fromScale(1,1)
	l.BackgroundTransparency = 1
	l.Text = title:upper()
	l.Font = Enum.Font.GothamBold
	l.TextSize = 7
	l.TextColor3 = T.purple
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.ZIndex = 13
	l.Parent = f
	local ln = Instance.new("Frame")
	ln.Size = UDim2.new(1,0,0,1)
	ln.Position = UDim2.new(0,0,1,-1)
	ln.BackgroundColor3 = T.sep
	ln.BorderSizePixel = 0
	ln.ZIndex = 13
	ln.Parent = f
	return f
end
local pickerCard
local pickerScroll
local selectedName = "None"
local function buildPlayerPicker()
	if pickerScroll then
		for _, c in ipairs(pickerScroll:GetChildren()) do
			if c:IsA("ImageButton") then c:Destroy() end
		end
	end
	local names = {}
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= LP then table.insert(names, p.Name) end
	end
	if #names == 0 then table.insert(names, "No players") end
	for i, nm in ipairs(names) do
		local pb = Instance.new("ImageButton")
		pb.Size = UDim2.new(1,0,0,20)
		pb.BackgroundColor3 = nm == selectedName and T.cardH or T.card
		pb.BackgroundTransparency = 0
		pb.BorderSizePixel = 0
		pb.Image = ""
		pb.AutoButtonColor = false
		pb.LayoutOrder = i
		pb.ZIndex = 15
		pb.Parent = pickerScroll
		Instance.new("UICorner",pb).CornerRadius = UDim.new(0,4)
		local pl = Instance.new("TextLabel")
		pl.Size = UDim2.fromScale(1,1)
		pl.BackgroundTransparency = 1
		pl.Text = nm
		pl.Font = Enum.Font.GothamSemibold
		pl.TextSize = 9
		pl.TextColor3 = nm == selectedName and T.white or T.pri
		pl.TextXAlignment = Enum.TextXAlignment.Left
		pl.ZIndex = 16
		pl.Parent = pb
		local pp = Instance.new("UIPadding")
		pp.PaddingLeft = UDim.new(0,6)
		pp.Parent = pl
		pb.MouseButton1Click:Connect(function()
			selectedName = nm
			selectedPlayer = nm == "No players" and nil or Players:FindFirstChild(nm)
			for _, c in ipairs(pickerScroll:GetChildren()) do
				if c:IsA("ImageButton") then
					local isThis = (c:FindFirstChildOfClass("TextLabel") or {}).Text == nm
					c.BackgroundColor3 = isThis and T.cardH or T.card
					local cl = c:FindFirstChildOfClass("TextLabel")
					if cl then cl.TextColor3 = isThis and T.white or T.pri end
				end
			end
		end)
	end
end
mkSec("Select Target")
pickerCard = Instance.new("Frame")
pickerCard.Size = UDim2.new(1,0,0,96)
pickerCard.BackgroundColor3 = T.card
pickerCard.BackgroundTransparency = 0
pickerCard.BorderSizePixel = 0
pickerCard.LayoutOrder = ord()
pickerCard.ZIndex = 12
pickerCard.Parent = scroll
Instance.new("UICorner",pickerCard).CornerRadius = UDim.new(0,6)
local pcS = Instance.new("UIStroke",pickerCard)
pcS.Color = T.border
pcS.Thickness = 0.8
local selLbl = Instance.new("TextLabel")
selLbl.Size = UDim2.new(1,-8,0,16)
selLbl.Position = UDim2.fromOffset(6,4)
selLbl.BackgroundTransparency = 1
selLbl.Text = "Target : None"
selLbl.Font = Enum.Font.GothamBold
selLbl.TextSize = 9
selLbl.TextColor3 = T.sec
selLbl.TextXAlignment = Enum.TextXAlignment.Left
selLbl.ZIndex = 13
selLbl.Parent = pickerCard
pickerScroll = Instance.new("ScrollingFrame")
pickerScroll.Size = UDim2.new(1,-4,0,54)
pickerScroll.Position = UDim2.fromOffset(2,22)
pickerScroll.BackgroundColor3 = T.bg
pickerScroll.BackgroundTransparency = 0
pickerScroll.BorderSizePixel = 0
pickerScroll.ScrollBarThickness = 2
pickerScroll.ScrollBarImageColor3 = T.purple
pickerScroll.ScrollingDirection = Enum.ScrollingDirection.Y
pickerScroll.CanvasSize = UDim2.fromOffset(0,0)
pickerScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
pickerScroll.ZIndex = 13
pickerScroll.Parent = pickerCard
Instance.new("UICorner",pickerScroll).CornerRadius = UDim.new(0,5)
local psLL = Instance.new("UIListLayout")
psLL.SortOrder = Enum.SortOrder.LayoutOrder
psLL.Padding = UDim.new(0,2)
psLL.Parent = pickerScroll
local psPad = Instance.new("UIPadding")
psPad.PaddingTop = UDim.new(0,2)
psPad.PaddingBottom = UDim.new(0,2)
psPad.PaddingLeft = UDim.new(0,2)
psPad.PaddingRight = UDim.new(0,2)
psPad.Parent = pickerScroll
local refBtn = Instance.new("ImageButton")
refBtn.Size = UDim2.new(1,-4,0,16)
refBtn.Position = UDim2.fromOffset(2,78)
refBtn.BackgroundColor3 = T.card
refBtn.BackgroundTransparency = 0
refBtn.BorderSizePixel = 0
refBtn.Image = ""
refBtn.AutoButtonColor = false
refBtn.ZIndex = 13
refBtn.Parent = pickerCard
Instance.new("UICorner",refBtn).CornerRadius = UDim.new(0,4)
local rfS = Instance.new("UIStroke",refBtn)
rfS.Color = T.border
rfS.Thickness = 0.8
local rfL = Instance.new("TextLabel")
rfL.Size = UDim2.fromScale(1,1)
rfL.BackgroundTransparency = 1
rfL.Text = "Refresh Player List"
rfL.Font = Enum.Font.GothamBold
rfL.TextSize = 8
rfL.TextColor3 = T.sec
rfL.ZIndex = 14
rfL.Parent = refBtn
refBtn.MouseButton1Click:Connect(function()
	buildPlayerPicker()
	rfL.TextColor3 = T.white
	task.delay(0.5, function() pcall(function() rfL.TextColor3 = T.sec end) end)
end)
refBtn.MouseEnter:Connect(function()
	TweenService:Create(refBtn,TweenInfo.new(0.10),{BackgroundColor3=T.cardH}):Play()
end)
refBtn.MouseLeave:Connect(function()
	TweenService:Create(refBtn,TweenInfo.new(0.10),{BackgroundColor3=T.card}):Play()
end)
task.spawn(function()
	while gui.Parent do
		task.wait(0.3)
		pcall(function()
			selLbl.Text = "Target : " .. selectedName
			selLbl.TextColor3 = selectedName == "None" and T.sec or T.pri
		end)
	end
end)
buildPlayerPicker()
Players.PlayerAdded:Connect(function() task.wait(0.5) buildPlayerPicker() end)
Players.PlayerRemoving:Connect(function() task.wait(0.3) buildPlayerPicker() end)
local function getTargetHRP()
	if not selectedPlayer then return nil end
	local c = selectedPlayer.Character
	return c and c:FindFirstChild("HumanoidRootPart")
end
local function mkBtn(title, sub, cb)
	local h = sub and 40 or 30
	local b = Instance.new("ImageButton")
	b.Size = UDim2.new(1,0,0,h)
	b.BackgroundColor3 = T.card
	b.BackgroundTransparency = 0
	b.BorderSizePixel = 0
	b.Image = ""
	b.AutoButtonColor = false
	b.LayoutOrder = ord()
	b.ZIndex = 12
	b.Parent = scroll
	Instance.new("UICorner",b).CornerRadius = UDim.new(0,6)
	local bS = Instance.new("UIStroke",b)
	bS.Color = T.border
	bS.Thickness = 0.8
	local tl = Instance.new("TextLabel")
	tl.Size = UDim2.new(1,-10,0,14)
	tl.Position = UDim2.fromOffset(8, sub and 5 or 8)
	tl.BackgroundTransparency = 1
	tl.Text = title
	tl.Font = Enum.Font.GothamBold
	tl.TextSize = 10
	tl.TextColor3 = T.pri
	tl.TextXAlignment = Enum.TextXAlignment.Left
	tl.ZIndex = 13
	tl.Parent = b
	if sub then
		local sl = Instance.new("TextLabel")
		sl.Size = UDim2.new(1,-10,0,11)
		sl.Position = UDim2.fromOffset(8,20)
		sl.BackgroundTransparency = 1
		sl.Text = sub
		sl.Font = Enum.Font.Gotham
		sl.TextSize = 7
		sl.TextColor3 = T.sec
		sl.TextXAlignment = Enum.TextXAlignment.Left
		sl.ZIndex = 13
		sl.Parent = b
	end
	b.MouseButton1Click:Connect(function()
		TweenService:Create(b,TweenInfo.new(0.08),{BackgroundColor3=T.cardH}):Play()
		task.delay(0.15,function() TweenService:Create(b,TweenInfo.new(0.10),{BackgroundColor3=T.card}):Play() end)
		if cb then cb() end
	end)
	b.MouseEnter:Connect(function() TweenService:Create(b,TweenInfo.new(0.10),{BackgroundColor3=T.cardH}):Play() end)
	b.MouseLeave:Connect(function() TweenService:Create(b,TweenInfo.new(0.10),{BackgroundColor3=T.card}):Play() end)
	return b, tl
end
local function mkToggleBtn(title, sub, onCb, offCb)
	local h = sub and 40 or 30
	local b = Instance.new("ImageButton")
	b.Size = UDim2.new(1,0,0,h)
	b.BackgroundColor3 = T.card
	b.BackgroundTransparency = 0
	b.BorderSizePixel = 0
	b.Image = ""
	b.AutoButtonColor = false
	b.LayoutOrder = ord()
	b.ZIndex = 12
	b.Parent = scroll
	Instance.new("UICorner",b).CornerRadius = UDim.new(0,6)
	local bS = Instance.new("UIStroke",b)
	bS.Color = T.border
	bS.Thickness = 0.8
	local tl = Instance.new("TextLabel")
	tl.Name = "TL"
	tl.Size = UDim2.new(1,-36,0,14)
	tl.Position = UDim2.fromOffset(8, sub and 5 or 8)
	tl.BackgroundTransparency = 1
	tl.Text = title
	tl.Font = Enum.Font.GothamBold
	tl.TextSize = 10
	tl.TextColor3 = T.pri
	tl.TextXAlignment = Enum.TextXAlignment.Left
	tl.ZIndex = 13
	tl.Parent = b
	if sub then
		local sl = Instance.new("TextLabel")
		sl.Size = UDim2.new(1,-36,0,11)
		sl.Position = UDim2.fromOffset(8,20)
		sl.BackgroundTransparency = 1
		sl.Text = sub
		sl.Font = Enum.Font.Gotham
		sl.TextSize = 7
		sl.TextColor3 = T.sec
		sl.TextXAlignment = Enum.TextXAlignment.Left
		sl.ZIndex = 13
		sl.Parent = b
	end
	local TW, TH2 = 24, 13
	local trk = Instance.new("Frame")
	trk.Size = UDim2.fromOffset(TW, TH2)
	trk.Position = UDim2.new(1,-(TW+6),0.5,-(TH2/2))
	trk.BackgroundColor3 = T.border
	trk.BorderSizePixel = 0
	trk.ZIndex = 13
	trk.Parent = b
	Instance.new("UICorner",trk).CornerRadius = UDim.new(1,0)
	local KS = TH2 - 4
	local knob = Instance.new("Frame")
	knob.Size = UDim2.fromOffset(KS, KS)
	knob.Position = UDim2.fromOffset(2,2)
	knob.BackgroundColor3 = T.white
	knob.BorderSizePixel = 0
	knob.ZIndex = 14
	knob.Parent = trk
	Instance.new("UICorner",knob).CornerRadius = UDim.new(1,0)
	local state = false
	b.MouseButton1Click:Connect(function()
		state = not state
		local onColor = T.purple
		TweenService:Create(trk,TweenInfo.new(0.12),{BackgroundColor3 = state and onColor or T.border}):Play()
		TweenService:Create(knob,TweenInfo.new(0.12),{Position = state and UDim2.fromOffset(TW-KS-2,2) or UDim2.fromOffset(2,2)}):Play()
		TweenService:Create(b,TweenInfo.new(0.08),{BackgroundColor3=T.cardH}):Play()
		task.delay(0.15,function() TweenService:Create(b,TweenInfo.new(0.10),{BackgroundColor3=T.card}):Play() end)
		if state then
			if onCb then onCb() end
		else
			if offCb then offCb() end
		end
	end)
	b.MouseEnter:Connect(function() TweenService:Create(b,TweenInfo.new(0.10),{BackgroundColor3=T.cardH}):Play() end)
	b.MouseLeave:Connect(function() TweenService:Create(b,TweenInfo.new(0.10),{BackgroundColor3=T.card}):Play() end)
	return b
end

-- ==================== AVATAR SECTION ====================
mkSec("Avatar")
mkBtn("Copy Avatar", "Clone target player outfit FE", function()
	if not inCorrectMap then showNotif("Wrong Game", "Only works in Indo Hangout.", 3) return end
	if not selectedPlayer then showNotif("No Target", "Select a player first.", 3) return end
	if not CatalogOnApplyOutfit then showNotif("Remote Missing", "CatalogOnApplyOutfit not found.", 3) return end
	local targetHum = selectedPlayer.Character and selectedPlayer.Character:FindFirstChildOfClass("Humanoid")
	if not targetHum then showNotif("Error", "Target has no character.", 3) return end
	local ok, desc = pcall(function() return targetHum:GetAppliedDescription() end)
	if not ok or not desc then showNotif("Error", "Could not get avatar description.", 3) return end
	local accessories = {}
	pcall(function()
		for _, acc in ipairs(desc:GetAccessories(true)) do
			table.insert(accessories, {
				AccessoryType = acc.AccessoryType,
				AssetId = acc.AssetId,
				Order = acc.Order,
				Puffiness = acc.Puffiness,
			})
		end
	end)
	local outfitData = {{
		Accessories = accessories,
		BodyTypeScale = desc.BodyTypeScale,
		HeadScale = desc.HeadScale,
		ProportionScale = desc.ProportionScale,
		WidthScale = desc.WidthScale,
		HeightScale = desc.HeightScale,
		DepthScale = desc.DepthScale,
		Face = desc.Face,
		GraphicTShirt = desc.GraphicTShirt,
		Head = desc.Head,
		HeadColor = desc.HeadColor,
		Pants = desc.Pants,
		Shirt = desc.Shirt,
		Torso = desc.Torso,
		TorsoColor = desc.TorsoColor,
		LeftArm = desc.LeftArm,
		LeftArmColor = desc.LeftArmColor,
		LeftLeg = desc.LeftLeg,
		LeftLegColor = desc.LeftLegColor,
		RightArm = desc.RightArm,
		RightArmColor = desc.RightArmColor,
		RightLeg = desc.RightLeg,
		RightLegColor = desc.RightLegColor,
		ClimbAnimation = desc.ClimbAnimation,
		FallAnimation = desc.FallAnimation,
		IdleAnimation = desc.IdleAnimation,
		JumpAnimation = desc.JumpAnimation,
		RunAnimation = desc.RunAnimation,
		SwimAnimation = desc.SwimAnimation,
		WalkAnimation = desc.WalkAnimation,
	}}
	local fired, err = pcall(function() CatalogOnApplyOutfit:FireServer(unpack(outfitData)) end)
	if fired then
		showNotif("Avatar Copied", "Outfit from " .. selectedPlayer.Name .. " applied.", 4)
	else
		showNotif("Error", tostring(err):sub(1,60), 4)
	end
end)
mkBtn("Reset Avatar", "Restore your original outfit", function()
	if not inCorrectMap then showNotif("Wrong Game", "Only works in Indo Hangout.", 3) return end
	if not CatalogOnApplyOutfit then showNotif("Remote Missing", "CatalogOnApplyOutfit not found.", 3) return end
	local ok, desc = pcall(function() return Players:GetHumanoidDescriptionFromUserId(LP.UserId) end)
	if not ok or not desc then showNotif("Error", "Could not load default description.", 3) return end
	local outfitData = {{
		Accessories = {},
		BodyTypeScale = desc.BodyTypeScale,
		HeadScale = desc.HeadScale,
		ProportionScale = desc.ProportionScale,
		WidthScale = desc.WidthScale,
		HeightScale = desc.HeightScale,
		DepthScale = desc.DepthScale,
		Face = desc.Face,
		GraphicTShirt = desc.GraphicTShirt,
		Head = desc.Head,
		HeadColor = desc.HeadColor,
		Pants = desc.Pants,
		Shirt = desc.Shirt,
		Torso = desc.Torso,
		TorsoColor = desc.TorsoColor,
		LeftArm = desc.LeftArm,
		LeftArmColor = desc.LeftArmColor,
		LeftLeg = desc.LeftLeg,
		LeftLegColor = desc.LeftLegColor,
		RightArm = desc.RightArm,
		RightArmColor = desc.RightArmColor,
		RightLeg = desc.RightLeg,
		RightLegColor = desc.RightLegColor,
		ClimbAnimation = desc.ClimbAnimation,
		FallAnimation = desc.FallAnimation,
		IdleAnimation = desc.IdleAnimation,
		JumpAnimation = desc.JumpAnimation,
		RunAnimation = desc.RunAnimation,
		SwimAnimation = desc.SwimAnimation,
		WalkAnimation = desc.WalkAnimation,
	}}
	pcall(function() CatalogOnApplyOutfit:FireServer(unpack(outfitData)) end)
	showNotif("Avatar Reset", "Restored your original look.", 3)
end)

-- ==================== MOVEMENT SECTION ====================
mkSec("Movement")
mkBtn("Teleport to Target", "Instantly move to selected player", function()
	if not selectedPlayer then showNotif("No Target","Select a player first.",3) return end
	local th = getTargetHRP()
	if not th or not hrp then showNotif("Error","Target or your character missing.",3) return end
	pcall(function() hrp.CFrame = th.CFrame + Vector3.new(2,0,0) end)
	showNotif("Teleported", "Moved to " .. selectedPlayer.Name, 3)
end)
mkToggleBtn("Follow Player", "Continuously follow target", function()
	isFollowing = true
	followConn = RunService.Heartbeat:Connect(function()
		if not isFollowing then return end
		local th = getTargetHRP()
		if th and hrp then pcall(function() hrp.CFrame = CFrame.new(th.Position + Vector3.new(2,0,0)) end) end
	end)
	showNotif("Follow ON", "Following " .. (selectedName or "target"), 3)
end, function()
	isFollowing = false
	if followConn then followConn:Disconnect() followConn = nil end
	showNotif("Follow OFF", "Stopped following.", 2)
end)
mkToggleBtn("Spectate Player", "View from target's camera", function()
	if not selectedPlayer then showNotif("No Target","Select a player first.",3) return end
	local tChar = selectedPlayer.Character
	local tHum = tChar and tChar:FindFirstChildOfClass("Humanoid")
	if not tHum then showNotif("Error","Target has no character.",3) return end
	lastCamSubject = Cam.CameraSubject
	isSpectating = true
	Cam.CameraSubject = tHum
	showNotif("Spectate ON", "Watching " .. selectedPlayer.Name, 3)
end, function()
	isSpectating = false
	if lastCamSubject then pcall(function() Cam.CameraSubject = lastCamSubject end) lastCamSubject = nil end
	showNotif("Spectate OFF", "Camera restored.", 2)
end)

-- ==================== EXTRAS SECTION ====================
mkSec("Extras")
mkToggleBtn("Noclip", "Walk through parts and walls", function()
	isNoclip = true
	noclipConn = RunService.Stepped:Connect(function()
		if not isNoclip or not char then return end
		for _, p in ipairs(char:GetDescendants()) do
			if p:IsA("BasePart") then p.CanCollide = false end
		end
	end)
	showNotif("Noclip ON", "You can now walk through walls.", 3)
end, function()
	isNoclip = false
	if noclipConn then noclipConn:Disconnect() noclipConn = nil end
	if char then
		for _, p in ipairs(char:GetDescendants()) do
			if p:IsA("BasePart") then pcall(function() p.CanCollide = true end) end
		end
	end
	showNotif("Noclip OFF", "Collision restored.", 2)
end)
mkBtn("Speed x3", "Set walkspeed to 3x default", function()
	if not hum then showNotif("Error","Humanoid not found.",3) return end
	speedVal = 48
	pcall(function() hum.WalkSpeed = speedVal end)
	showNotif("Speed x3", "WalkSpeed set to 48.", 3)
end)
mkBtn("Speed Reset", "Restore default walkspeed (16)", function()
	if not hum then showNotif("Error","Humanoid not found.",3) return end
	speedVal = 16
	pcall(function() hum.WalkSpeed = 16 end)
	showNotif("Speed Reset", "WalkSpeed back to 16.", 2)
end)
mkToggleBtn("Anti-AFK", "Prevent idle kick loop", function()
	isAntiAfk = true
	LP.Idled:Connect(function()
		if not isAntiAfk then return end
		pcall(function()
			VirtualUser:Button2Down(Vector2.new(0,0))
			task.wait(0.1)
			VirtualUser:Button2Up(Vector2.new(0,0))
		end)
	end)
	showNotif("Anti-AFK ON", "Idle kick protection active.", 3)
end, function()
	isAntiAfk = false
	showNotif("Anti-AFK OFF", "Idle protection disabled.", 2)
end)
mkToggleBtn("ESP", "Show all players ESP", function()
	isESP = true
	local function removePlayerESP(player)
		if espDrawings[player] then
			for _, d in pairs(espDrawings[player]) do
				pcall(function() d:Remove() end)
			end
			espDrawings[player] = nil
		end
	end
	local function createPlayerESP(player)
		if espDrawings[player] then return end
		local box = {}
		box.topLine = Drawing.new("Line")
		box.topLine.Visible = false
		box.topLine.Color = Color3.fromRGB(170, 110, 255)
		box.topLine.Thickness = 1.5
		box.bottomLine = Drawing.new("Line")
		box.bottomLine.Visible = false
		box.bottomLine.Color = Color3.fromRGB(170, 110, 255)
		box.bottomLine.Thickness = 1.5
		box.leftLine = Drawing.new("Line")
		box.leftLine.Visible = false
		box.leftLine.Color = Color3.fromRGB(170, 110, 255)
		box.leftLine.Thickness = 1.5
		box.rightLine = Drawing.new("Line")
		box.rightLine.Visible = false
		box.rightLine.Color = Color3.fromRGB(170, 110, 255)
		box.rightLine.Thickness = 1.5
		box.nameText = Drawing.new("Text")
		box.nameText.Visible = false
		box.nameText.Color = Color3.new(1,1,1)
		box.nameText.Size = 14
		box.nameText.Center = true
		box.nameText.Outline = true
		box.nameText.OutlineColor = Color3.new(0,0,0)
		box.distText = Drawing.new("Text")
		box.distText.Visible = false
		box.distText.Color = Color3.fromRGB(170, 110, 255)
		box.distText.Size = 13
		box.distText.Center = true
		box.distText.Outline = true
		box.distText.OutlineColor = Color3.new(0,0,0)
		espDrawings[player] = box
	end
	local function updateESP()
		for _, player in ipairs(Players:GetPlayers()) do
			if player == LP then
				if espDrawings[player] then removePlayerESP(player) end
				continue
			end
			local character = player.Character
			if not character then
				removePlayerESP(player)
				continue
			end
			local head = character:FindFirstChild("Head")
			local root = character:FindFirstChild("HumanoidRootPart")
			if not head or not root then
				removePlayerESP(player)
				continue
			end
			if not espDrawings[player] then
				createPlayerESP(player)
			end
			local box = espDrawings[player]
			local headPos = head.Position + Vector3.new(0, 0.5, 0)
			local footPos = root.Position - Vector3.new(0, 3, 0)
			local headScreen, headOnScreen = Cam:WorldToViewportPoint(headPos)
			local footScreen, footOnScreen = Cam:WorldToViewportPoint(footPos)
			if not headOnScreen and not footOnScreen then
				for _, d in pairs(box) do d.Visible = false end
				continue
			end
			local leftOffset = head.Position + Vector3.new(-1.5, 0, 0)
			local rightOffset = head.Position + Vector3.new(1.5, 0, 0)
			local leftScreen = Cam:WorldToViewportPoint(leftOffset)
			local rightScreen = Cam:WorldToViewportPoint(rightOffset)
			local topY = headScreen.Y
			local bottomY = footScreen.Y
			local leftX = math.min(leftScreen.X, rightScreen.X)
			local rightX = math.max(leftScreen.X, rightScreen.X)
			if bottomY < topY then
				local tmp = topY
				topY = bottomY
				bottomY = tmp
			end
			box.topLine.From = Vector2.new(leftX, topY)
			box.topLine.To = Vector2.new(rightX, topY)
			box.bottomLine.From = Vector2.new(leftX, bottomY)
			box.bottomLine.To = Vector2.new(rightX, bottomY)
			box.leftLine.From = Vector2.new(leftX, topY)
			box.leftLine.To = Vector2.new(leftX, bottomY)
			box.rightLine.From = Vector2.new(rightX, topY)
			box.rightLine.To = Vector2.new(rightX, bottomY)
			local dist = math.floor((root.Position - (hrp and hrp.Position or Vector3.zero)).Magnitude)
			box.nameText.Text = player.Name
			box.nameText.Position = Vector2.new((leftX+rightX)/2, topY - 16)
			box.distText.Text = dist .. "m"
			box.distText.Position = Vector2.new((leftX+rightX)/2, bottomY + 2)
			for _, d in pairs(box) do d.Visible = true end
		end
		for player, _ in pairs(espDrawings) do
			if not Players:FindFirstChild(player.Name) then
				removePlayerESP(player)
			end
		end
	end
	espConn = RunService.Heartbeat:Connect(updateESP)
	showNotif("ESP ON", "Showing all players ESP.", 3)
end, function()
	isESP = false
	if espConn then espConn:Disconnect() espConn = nil end
	for player, drawings in pairs(espDrawings) do
		for _, d in pairs(drawings) do
			pcall(function() d:Remove() end)
		end
		espDrawings[player] = nil
	end
	showNotif("ESP OFF", "Player ESP hidden.", 2)
end)

-- ==================== FISHING SECTION ====================
mkSec("Fishing")

local sellRemote
pcall(function()
	local Events = ReplicatedStorage:FindFirstChild("Events")
	if Events then
		local RemoteFunction = Events:FindFirstChild("RemoteFunction")
		if RemoteFunction then
			sellRemote = RemoteFunction:FindFirstChild("SellFish") or RemoteFunction:FindFirstChild("SellItemRemoteFunction")
		end
	end
	if not sellRemote then
		local Remote = ReplicatedStorage:FindFirstChild("Remote")
		if Remote then
			sellRemote = Remote:FindFirstChild("SellItemRemoteFunction") or Remote:FindFirstChild("SellFish")
		end
	end
end)

if sellRemote then
	mkBtn("Sell All Fish", "Sell all fish in your inventory", function()
		pcall(function()
			sellRemote:InvokeServer("SellFish", "Sell All")
		end)
		showNotif("Sell All", "All fish sold!", 3)
	end)
else
	task.spawn(function()
		showNotif("Fishing Error", "Sell remote not available.", 3)
	end)
end

RunService.Heartbeat:Connect(function()
	if speedVal ~= 16 and hum then pcall(function() if hum.WalkSpeed ~= speedVal then hum.WalkSpeed = speedVal end end) end
end)
