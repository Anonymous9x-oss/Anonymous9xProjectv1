--[[
	WARNING: Heads up! This script has not been verified by ScriptBlox. Use at your own risk!
]]
						local PrimaryPartCFrame = Vehicle:GetPrimaryPartCFrame()
						Vehicle:SetPrimaryPartCFrame(CFrame.new(PrimaryPartCFrame.Position, PrimaryPartCFrame.Position + workspace.CurrentCamera.CFrame.LookVector) * (UserInputService:GetFocusedTextBox() and CFrame.new(0, 0, 0) or CFrame.new((UserInputService:IsKeyDown(Enum.KeyCode.D) and flightSpeed) or (UserInputService:IsKeyDown(Enum.KeyCode.A) and -flightSpeed) or 0, (UserInputService:IsKeyDown(Enum.KeyCode.E) and flightSpeed / 2) or (UserInputService:IsKeyDown(Enum.KeyCode.Q) and -flightSpeed / 2) or 0, (UserInputService:IsKeyDown(Enum.KeyCode.S) and flightSpeed) or (UserInputService:IsKeyDown(Enum.KeyCode.W) and -flightSpeed) or 0)))
						SeatPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
						SeatPart.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
					end
				end
			end
		end
	else
		if Character and typeof(Character) == "Instance" then
			Character.Parent = defaultCharacterParent or Character.Parent
			defaultCharacterParent = Character.Parent
		end
	end
end)

-- SPEED SECTION
local speedSection = vehiclePage:addSection("Acceleration")
local velocityMult = 0.025;
speedSection:addSlider("Multiplier (Thousandths)", 25, 0, 50, function(v) velocityMult = v / 1000; end)
local velocityEnabledKeyCode = Enum.KeyCode.W;
speedSection:addKeybind("Velocity Enabled", velocityEnabledKeyCode, function()
	if not velocityEnabled then return end
	while UserInputService:IsKeyDown(velocityEnabledKeyCode) do
		task.wait(0)
		local Character = LocalPlayer.Character
		if Character then
			local Humanoid = Character:FindFirstChildWhichIsA("Humanoid")
			if Humanoid then
				local SeatPart = Humanoid.SeatPart
				if SeatPart and SeatPart:IsA("VehicleSeat") then
					SeatPart.AssemblyLinearVelocity *= Vector3.new(1 + velocityMult, 1, 1 + velocityMult)
				end
			end
		end
		if not velocityEnabled then break end
	end
end, function(v) velocityEnabledKeyCode = v.KeyCode end)

-- DECELERATION
local decelerateSelection = vehiclePage:addSection("Deceleration")
local qbEnabledKeyCode = Enum.KeyCode.S
local velocityMult2 = 150e-3
decelerateSelection:addSlider("Brake Force (Thousandths)", velocityMult2*1e3, 0, 300, function(v) velocityMult2 = v / 1000; end)
decelerateSelection:addKeybind("Quick Brake Enabled", qbEnabledKeyCode, function()
	if not velocityEnabled then return end
	while UserInputService:IsKeyDown(qbEnabledKeyCode) do
		task.wait(0)
		local Character = LocalPlayer.Character
		if Character then
			local Humanoid = Character:FindFirstChildWhichIsA("Humanoid")
			if Humanoid then
				local SeatPart = Humanoid.SeatPart
				if SeatPart and SeatPart:IsA("VehicleSeat") then
					SeatPart.AssemblyLinearVelocity *= Vector3.new(1 - velocityMult2, 1, 1 - velocityMult2)
				end
			end
		end
		if not velocityEnabled then break end
	end
end, function(v) qbEnabledKeyCode = v.KeyCode end)
decelerateSelection:addKeybind("Stop the Vehicle", Enum.KeyCode.P, function(v)
	if not velocityEnabled then return end
	local Character = LocalPlayer.Character
	if Character then
		local Humanoid = Character:FindFirstChildWhichIsA("Humanoid")
		if Humanoid then
			local SeatPart = Humanoid.SeatPart
			if SeatPart and SeatPart:IsA("VehicleSeat") then
				SeatPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
				SeatPart.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
			end
		end
	end
end)

-- SPRING SECTION
local springSection = vehiclePage:addSection("Springs")
springSection:addToggle("Visible", false, function(v)
	local Character = LocalPlayer.Character
	if Character then
		local Humanoid = Character:FindFirstChildWhichIsA("Humanoid")
		if Humanoid then
			local SeatPart = Humanoid.SeatPart
			if SeatPart and SeatPart:IsA("VehicleSeat") then
				local Vehicle = GetVehicleFromDescendant(SeatPart)
				for _, SpringConstraint in pairs(Vehicle:GetDescendants()) do
					if SpringConstraint:IsA("SpringConstraint") then
						SpringConstraint.Visible = v
					end
				end
			end
		end
	end
end)

-- FREEZE CAR
local freezeSection = vehiclePage:addSection("Freeze Car")
local freezeEnabled = false
local function SetFreeze(state)
    local Character = LocalPlayer.Character
    if Character then
        local Humanoid = Character:FindFirstChildWhichIsA("Humanoid")
        if Humanoid then
            local SeatPart = Humanoid.SeatPart
            if SeatPart and SeatPart:IsA("VehicleSeat") then
                local Vehicle = GetVehicleFromDescendant(SeatPart)
                if Vehicle then
                    for _, part in pairs(Vehicle:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.Anchored = state
                            if state then
                                part.AssemblyLinearVelocity = Vector3.new(0,0,0)
                                part.AssemblyAngularVelocity = Vector3.new(0,0,0)
                            end
                        end
                    end
                end
            end
        end
    end
end
freezeSection:addToggle("Freeze Vehicle", false, function(v)
    freezeEnabled = v
    SetFreeze(v)
end)

-- SUSPENSION PAGE
local suspensionPage = Venyx:addPage("Suspension", 6031068433)
local suspensionSection = suspensionPage:addSection("Spring Settings")

local suspensionSettings = {Stiffness = 2000, Damping = 200}
local function UpdateSuspension(stiffness, damping)
    local Character = LocalPlayer.Character
    if Character then
        local Humanoid = Character:FindFirstChildWhichIsA("Humanoid")
        if Humanoid then
            local SeatPart = Humanoid.SeatPart
            if SeatPart and SeatPart:IsA("VehicleSeat") then
                local Vehicle = GetVehicleFromDescendant(SeatPart)
                if Vehicle then
                    for _, spring in pairs(Vehicle:GetDescendants()) do
                        if spring:IsA("SpringConstraint") then
                            pcall(function() 
                                spring.Stiffness = stiffness
                                spring.FreeLength = math.clamp(stiffness/1000, -5, 10)
                            end)
                            pcall(function()
                                spring.Damping = damping
                            end)
                        end
                    end
                end
            end
        end
    end
end

suspensionSection:addSlider("Stiffness / Height", suspensionSettings.Stiffness, -20000, 20000, function(v)
    suspensionSettings.Stiffness = v
    UpdateSuspension(suspensionSettings.Stiffness, suspensionSettings.Damping)
end)

suspensionSection:addSlider("Damping", suspensionSettings.Damping, 0, 2000, function(v)
    suspensionSettings.Damping = v
    UpdateSuspension(suspensionSettings.Stiffness, suspensionSettings.Damping)
end)

-- INFO PAGE
repeat task.wait(0) until game:IsLoaded() and game.PlaceId > 0
if game.PlaceId == 3351674303 then
	local drivingEmpirePage = Venyx:addPage("Wayfort", 8357222903)
	local dealershipSection = drivingEmpirePage:addSection("Vehicle Dealership")
	local dealershipList = {}
	for index, value in pairs(workspace:WaitForChild("Game"):WaitForChild("Dealerships"):WaitForChild("Dealerships"):GetChildren()) do
		table.insert(dealershipList, value.Name)
	end
	dealershipSection:addDropdown("Dealership", dealershipList, function(v)
		game:GetService("ReplicatedStorage").Remotes.Location:FireServer("Enter", v)
	end)
elseif game.PlaceId == 891852901 then
	local greenvillePage = Venyx:addPage("Greenville", 8360925727)
elseif game.PlaceId == 54865335 then
	local ultimateDrivingPage = Venyx:addPage("Westover", 8360954483)
elseif game.PlaceId == 5232896677 then
	local pacificoPage = Venyx:addPage("Pacifico", 3028235557)
end

local infoPage = Venyx:addPage("Information", 8356778308)
local discordSection = infoPage:addSection("Discord")
discordSection:addButton(syn and "Join the Discord server" or "Copy Discord Link", function()
	if syn then
		syn.request({
			Url = "http://127.0.0.1:6463/rpc?v=1",
			Method = "POST",
			Headers = {["Content-Type"] = "application/json",["Origin"] = "https://discord.com"},
			Body = game:GetService("HttpService"):JSONEncode({
				cmd = "INVITE_BROWSER",
				args = {code = "ENHYznSPmM"},
				nonce = game:GetService("HttpService"):GenerateGUID(false)
			}),
		})
		return
	end
	setclipboard("https://discord.gg/aQpS2gQS")
end)

-- TOGGLE GUI
local function CloseGUI() Venyx:toggle() end
UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    if not gameProcessedEvent and input.KeyCode == Enum.KeyCode.RightBracket then
        CloseGUI()
    end
end)
