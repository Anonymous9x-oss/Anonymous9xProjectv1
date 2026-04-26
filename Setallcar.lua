--[[
	WARNING: Heads up! This script has not been verified by ScriptBlox. Use at your own risk!
]]
print("Starting Universal Vehicle Script...")
local success, VenyxLibrary = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/Documantation12/Universal-Vehicle-Script/main/Library.lua"))()
end)
if not success then
    warn("Failed to load Venyx library. Please check the URL, your network, or Xeno compatibility.")
    warn("Error details: " .. tostring(VenyxLibrary))
    print("Tip: Test HttpGet manually in Xeno console: loadstring(game:HttpGet('https://raw.githubusercontent.com/Documantation12/Universal-Vehicle-Script/main/Library.lua'))()")
    return
end
print("Venyx Library loaded successfully!")
local Venyx = VenyxLibrary.new("Universal Vehicle Script", 8356815386)
print("Venyx UI created!")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

-- Consistent Black and White Theme
local Theme = {
    Background = Color3.fromRGB(0, 0, 0),    -- Pure black background
    Glow = Color3.fromRGB(255, 255, 255),    -- White glow for contrast
    Accent = Color3.fromRGB(30,30,30),     -- Dark gray accent
    LightContrast = Color3.fromRGB(25,25,25), -- Light gray for readability
    DarkContrast = Color3.fromRGB(20, 20, 20),    -- Darker gray for depth
    TextColor = Color3.fromRGB(255, 255, 255)     -- White text for visibility
}

-- Apply theme to Venyx UI
for index, value in pairs(Theme) do
    pcall(Venyx.setTheme, Venyx, index, value)
end
print("Theme applied!")

local function GetVehicleFromDescendant(Descendant)
    local vehicle = Descendant:FindFirstAncestor(LocalPlayer.Name .. "'s Car") or
        (Descendant:FindFirstAncestor("Body") and Descendant:FindFirstAncestor("Body").Parent) or
        (Descendant:FindFirstAncestor("Misc") and Descendant:FindFirstAncestor("Misc").Parent) or
        Descendant:FindFirstAncestorWhichIsA("Model")
    if vehicle then print("Vehicle detected: " .. vehicle.Name) end
    return vehicle
end

-- VEHICLE PAGE
local vehiclePage = Venyx:addPage("Vehicle", 8356815386)
print("Vehicle page added!")
local usageSection = vehiclePage:addSection("Usage")
local velocityEnabled = true
usageSection:addToggle("Keybinds Active", velocityEnabled, function(v) velocityEnabled = v; print("Keybinds Active: " .. tostring(v)) end)
local flightSection = vehiclePage:addSection("Flight")
local flightEnabled = false
local flightSpeed = 1
flightSection:addToggle("Enabled", false, function(v) flightEnabled = v; print("Flight Enabled: " .. tostring(v)) end)
flightSection:addSlider("Speed", 100, 0, 800, function(v) flightSpeed = v / 100; print("Flight Speed: " .. flightSpeed) end)
local defaultCharacterParent 
RunService.Stepped:Connect(function()
    local Character = LocalPlayer.Character
    if flightEnabled == true then
        if Character and typeof(Character) == "Instance" then
            local Humanoid = Character:FindFirstChildWhichIsA("Humanoid")
            if Humanoid and typeof(Humanoid) == "Instance" then
                local SeatPart = Humanoid.SeatPart
                if SeatPart and typeof(SeatPart) == "Instance" and SeatPart:IsA("VehicleSeat") then
                    local Vehicle = GetVehicleFromDescendant(SeatPart)
                    if Vehicle and Vehicle:IsA("Model") then
                        Character.Parent = Vehicle
                        if not Vehicle.PrimaryPart then
                            if SeatPart.Parent == Vehicle then
                                Vehicle.PrimaryPart = SeatPart
                            else
                                Vehicle.PrimaryPart = Vehicle:FindFirstChildWhichIsA("BasePart")
                            end
                        end
                        local PrimaryPartCFrame = Vehicle:GetPrimaryPartCFrame()
                        Vehicle:SetPrimaryPartCFrame(CFrame.new(PrimaryPartCFrame.Position, PrimaryPartCFrame.Position + Workspace.CurrentCamera.CFrame.LookVector) * (UserInputService:GetFocusedTextBox() and CFrame.new(0, 0, 0) or CFrame.new((UserInputService:IsKeyDown(Enum.KeyCode.D) and flightSpeed) or (UserInputService:IsKeyDown(Enum.KeyCode.A) and -flightSpeed) or 0, (UserInputService:IsKeyDown(Enum.KeyCode.E) and flightSpeed / 2) or (UserInputService:IsKeyDown(Enum.KeyCode.Q) and -flightSpeed / 2) or 0, (UserInputService:IsKeyDown(Enum.KeyCode.S) and flightSpeed) or (UserInputService:IsKeyDown(Enum.KeyCode.W) and -flightSpeed) or 0)))
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
print("Acceleration section added!")
local velocityMult = 0.025
speedSection:addSlider("Multiplier (Thousandths)", 25, 0, 50, function(v) velocityMult = v / 1000; print("Velocity Multiplier: " .. velocityMult) end)
local velocityEnabledKeyCode = Enum.KeyCode.W
speedSection:addKeybind("Velocity Enabled", velocityEnabledKeyCode, function()
    if not velocityEnabled then return end
    print("Velocity keybind pressed!")
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
end, function(v) velocityEnabledKeyCode = v.KeyCode; print("Velocity Keybind Changed: " .. tostring(v.KeyCode)) end)

-- DECELERATION
local decelerateSelection = vehiclePage:addSection("Deceleration")
print("Deceleration section added!")
local qbEnabledKeyCode = Enum.KeyCode.S
local velocityMult2 = 150e-3
decelerateSelection:addSlider("Brake Force (Thousandths)", velocityMult2*1e3, 0, 300, function(v) velocityMult2 = v / 1000; print("Brake Force: " .. velocityMult2) end)
decelerateSelection:addKeybind("Quick Brake Enabled", qbEnabledKeyCode, function()
    if not velocityEnabled then return end
    print("Brake keybind pressed!")
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
end, function(v) qbEnabledKeyCode = v.KeyCode; print("Brake Keybind Changed: " .. tostring(v.KeyCode)) end)
decelerateSelection:addKeybind("Stop the Vehicle", Enum.KeyCode.P, function(v)
    if not velocityEnabled then return end
    print("Stop vehicle pressed!")
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

-- HEADLIGHTS SECTION
local headlightSection = vehiclePage:addSection("Headlights")
print("Headlights section added!")
local headlightSettings = { Brightness = 1, Radius = 20, Enabled = true}
local function UpdateHeadlights(brightness, radius, enabled)
    local Character = LocalPlayer.Character
    if Character then
        local Humanoid = Character:FindFirstChildWhichIsA("Humanoid")
        if Humanoid then
            local SeatPart = Humanoid.SeatPart
            if SeatPart and SeatPart:IsA("VehicleSeat") then
                local Vehicle = GetVehicleFromDescendant(SeatPart)
                if Vehicle then
                    print("Updating headlights for vehicle: " .. Vehicle.Name)
                    local lightCount = 0
                    for _, light in pairs(Vehicle:GetDescendants()) do
                        if light:IsA("PointLight") or light:IsA("SpotLight") then
                            lightCount = lightCount + 1
                            pcall(function()
                                local originalParent = light.Parent
                                light.Brightness = enabled and brightness or 0
                                light.Range = radius
                                light.Enabled = enabled
                                light.Parent = nil
                                task.wait()
                                light.Parent = originalParent
                            end)
                        end
                    end
                    if lightCount == 0 and enabled then
                        for _, part in pairs(Vehicle:GetDescendants()) do
                            if part:IsA("BasePart") and (part.Name:lower():find("headlight") or part.Name:lower():find("light")) then
                                local existingLight = part:FindFirstChildOfClass("PointLight") or part:FindFirstChildOfClass("SpotLight")
                                if not existingLight then
                                    local newLight = Instance.new("SpotLight")
                                    newLight.Name = "TempHeadlight"
                                    newLight.Brightness = enabled and brightness or 0
                                    newLight.Range = radius
                                    newLight.Angle = 60
                                    newLight.Face = Enum.NormalId.Front
                                    newLight.Enabled = enabled
                                    newLight.Parent = part
                                    lightCount = lightCount + 1
                                end
                            end
                        end
                    end
                    if lightCount == 0 and enabled then
                        warn("No PointLight or SpotLight found in vehicle. Created temporary headlights.")
                        game:GetService("StarterGui"):SetCore("SendNotification", {
                            Title = "Headlight Warning",
                            Text = "No headlights found. Created temporary ones (may be local only).",
                            Duration = 3
                        })
                    else
                        game:GetService("StarterGui"):SetCore("SendNotification", {
                            Title = "Headlight Update",
                            Text = enabled and ("Headlights set to Brightness: " .. brightness .. ", Range: " .. radius) or "Headlights turned off!",
                            Duration = 2
                        })
                        print("Found " .. lightCount .. " lights. Applied Brightness: " .. (enabled and brightness or 0) .. ", Range: " .. radius .. ", Enabled: " .. tostring(enabled))
                    end
                else
                    warn("No valid vehicle found for headlight adjustments.")
                end
            end
        end
    end
end
headlightSection:addToggle("Headlights On", true, function(v)
    headlightSettings.Enabled = v
    UpdateHeadlights(headlightSettings.Brightness, headlightSettings.Radius, headlightSettings.Enabled)
end)
headlightSection:addSlider("Set Brightness", 100, 0, 1000, function(v)
    headlightSettings.Brightness = v / 100
    UpdateHeadlights(headlightSettings.Brightness, headlightSettings.Radius, headlightSettings.Enabled)
end)
headlightSection:addSlider("Set Radius", 2000, 0, 10000, function(v)
    headlightSettings.Radius = v / 100
    UpdateHeadlights(headlightSettings.Brightness, headlightSettings.Radius, headlightSettings.Enabled)
end)

-- REMOVE BRAKE SECTION
local removeBrakeSection = vehiclePage:addSection("Remove Brake")
print("Remove Brake section added!")
local removeBrakeEnabled = false
local removeBrakeSpeed = 50
removeBrakeSection:addToggle("Remove Brake Enabled", false, function(v)
    removeBrakeEnabled = v
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Remove Brake",
        Text = v and "Brake override enabled! Vehicle won't stop." or "Brake override disabled!",
        Duration = 2
    })
    print("Remove Brake Enabled: " .. tostring(v))
end)
removeBrakeSection:addSlider("Override Speed", 5000, 0, 10000, function(v)
    removeBrakeSpeed = v / 100
    print("Remove Brake Speed: " .. removeBrakeSpeed)
end)
RunService.Stepped:Connect(function()
    if removeBrakeEnabled and velocityEnabled then
        local Character = LocalPlayer.Character
        if Character then
            local Humanoid = Character:FindFirstChildWhichIsA("Humanoid")
            if Humanoid then
                local SeatPart = Humanoid.SeatPart
                if SeatPart and SeatPart:IsA("VehicleSeat") then
                    local Vehicle = GetVehicleFromDescendant(SeatPart)
                    if Vehicle and Vehicle.PrimaryPart then
                        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                            local currentCFrame = Vehicle:GetPrimaryPartCFrame()
                            local forwardVector = currentCFrame.LookVector
                            local currentVelocity = SeatPart.AssemblyLinearVelocity
                            SeatPart.AssemblyLinearVelocity = Vector3.new(
                                forwardVector.X * removeBrakeSpeed,
                                currentVelocity.Y,
                                forwardVector.Z * removeBrakeSpeed
                            )
                            print("Brake overridden, applying speed: " .. removeBrakeSpeed)
                        end
                    end
                end
            end
        end
    end
end)

-- SPRING SECTION
local springSection = vehiclePage:addSection("Springs")
print("Springs section added!")
springSection:addToggle("Visible", false, function(v)
    local Character = LocalPlayer.Character
    if Character then
        local Humanoid = Character:FindFirstChildWhichIsA("Humanoid")
        if Humanoid then
            local SeatPart = Humanoid.SeatPart
            if SeatPart and SeatPart:IsA("VehicleSeat") then
                local Vehicle = GetVehicleFromDescendant(SeatPart)
                local count = 0
                for _, SpringConstraint in pairs(Vehicle:GetDescendants()) do
                    if SpringConstraint:IsA("SpringConstraint") then
                        SpringConstraint.Visible = v
                        count = count + 1
                    end
                end
                print("Springs visibility set to " .. tostring(v) .. " for " .. count .. " constraints")
            end
        end
    end
end)

-- FREEZE CAR
local freezeSection = vehiclePage:addSection("Freeze Car")
print("Freeze section added!")
local freezeEnabled = false
local freezeKeyCode = Enum.KeyCode.F
local function SetFreeze(state)
    local Character = LocalPlayer.Character
    if Character then
        local Humanoid = Character:FindFirstChildWhichIsA("Humanoid")
        if Humanoid then
            local SeatPart = Humanoid.SeatPart
            if SeatPart and SeatPart:IsA("VehicleSeat") then
                local Vehicle = GetVehicleFromDescendant(SeatPart)
                if Vehicle then
                    local partCount = 0
                    for _, part in pairs(Vehicle:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.Anchored = state
                            if state then
                                part.AssemblyLinearVelocity = Vector3.new(0,0,0)
                                part.AssemblyAngularVelocity = Vector3.new(0,0,0)
                            end
                            partCount = partCount + 1
                        end
                    end
                    game:GetService("StarterGui"):SetCore("SendNotification", {
                        Title = "Freeze Vehicle",
                        Text = state and "Vehicle frozen!" or "Vehicle unfrozen!",
                        Duration = 2
                    })
                    print("Freeze set to " .. tostring(state) .. " for " .. partCount .. " parts")
                end
            end
        end
    end
end
freezeSection:addToggle("Freeze Vehicle", false, function(v)
    freezeEnabled = v
    SetFreeze(v)
end)
freezeSection:addKeybind("Toggle Freeze", freezeKeyCode, function()
    if not velocityEnabled then return end
    freezeEnabled = not freezeEnabled
    SetFreeze(freezeEnabled)
    print("Freeze toggled via keybind!")
end, function(v) freezeKeyCode = v.KeyCode; print("Freeze Keybind Changed: " .. tostring(v.KeyCode)) end)

-- NOCLIP SECTION
local noclipSection = vehiclePage:addSection("Noclip")
print("Noclip section added!")
local noclipEnabled = false
local noclipKeyCode = Enum.KeyCode.N
local vectorForce = nil
local groundHeightNoclip = nil
local function SetNoclip(state)
    local Character = LocalPlayer.Character
    if Character then
        local Humanoid = Character:FindFirstChildWhichIsA("Humanoid")
        if Humanoid then
            local SeatPart = Humanoid.SeatPart
            if SeatPart and SeatPart:IsA("VehicleSeat") then
                local Vehicle = GetVehicleFromDescendant(SeatPart)
                if Vehicle and Vehicle.PrimaryPart then
                    local rayOrigin = Vehicle.PrimaryPart.Position
                    local rayDirection = Vector3.new(0, -1000, 0)
                    local raycastParams = RaycastParams.new()
                    raycastParams.FilterDescendantsInstances = {Vehicle, Character}
                    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
                    local rayResult = Workspace:Raycast(rayOrigin, rayDirection, raycastParams)
                    groundHeightNoclip = rayResult and rayResult.Position.Y or 0
                    print("Noclip " .. (state and "enabled" or "disabled") .. ", Ground height detected: " .. groundHeightNoclip)
                    if state then
                        if not vectorForce then
                            vectorForce = Instance.new("VectorForce")
                            vectorForce.ApplyAtCenterOfMass = true
                            vectorForce.Force = Vector3.new(0, Workspace.Gravity * Vehicle.PrimaryPart:GetMass(), 0)
                            vectorForce.Parent = Vehicle.PrimaryPart
                            print("VectorForce added for noclip!")
                        end
                    else
                        if vectorForce then
                            vectorForce:Destroy()
                            vectorForce = nil
                            print("VectorForce removed for noclip!")
                        end
                        groundHeightNoclip = nil
                    end
                    local partCount = 0
                    local springCount = 0
                    for _, obj in pairs(Vehicle:GetDescendants()) do
                        if obj:IsA("BasePart") then
                            obj.CanCollide = not state
                            partCount = partCount + 1
                        elseif obj:IsA("SpringConstraint") then
                            obj.Enabled = not state
                            springCount = springCount + 1
                        end
                    end
                    print("Noclip applied: " .. partCount .. " parts, " .. springCount .. " springs")
                    game:GetService("StarterGui"):SetCore("SendNotification", {
                        Title = "Vehicle Noclip",
                        Text = state and "Noclip enabled! Drive through walls." or "Noclip disabled!",
                        Duration = 2
                    })
                else
                    warn("Failed to enable noclip: No valid Vehicle or PrimaryPart found.")
                end
            end
        end
    end
end
noclipSection:addToggle("Noclip Enabled", false, function(v)
    noclipEnabled = v
    SetNoclip(v)
end)
noclipSection:addKeybind("Toggle Noclip", noclipKeyCode, function()
    if not velocityEnabled then return end
    noclipEnabled = not noclipEnabled
    SetNoclip(noclipEnabled)
    print("Noclip toggled via keybind!")
end, function(v) noclipKeyCode = v.KeyCode; print("Noclip Keybind Changed: " .. tostring(v.KeyCode)) end)
RunService.Stepped:Connect(function()
    if noclipEnabled then
        local Character = LocalPlayer.Character
        if Character then
            local Humanoid = Character:FindFirstChildWhichIsA("Humanoid")
            if Humanoid then
                local SeatPart = Humanoid.SeatPart
                if SeatPart and SeatPart:IsA("VehicleSeat") then
                    local Vehicle = GetVehicleFromDescendant(SeatPart)
                    if Vehicle and Vehicle.PrimaryPart then
                        local pos = Vehicle.PrimaryPart.Position
                        if groundHeightNoclip then
                            local targetHeight = groundHeightNoclip + 5
                            if pos.Y < targetHeight then
                                local newPos = Vector3.new(pos.X, targetHeight, pos.Z)
                                Vehicle:SetPrimaryPartCFrame(CFrame.new(newPos, newPos + Vehicle.PrimaryPart.CFrame.LookVector))
                                print("Corrected vehicle height to: " .. targetHeight)
                            end
                        end
                        if pos.Y < 0 then
                            local safePos = Vector3.new(pos.X, groundHeightNoclip and (groundHeightNoclip + 5) or 50, pos.Z)
                            Vehicle:SetPrimaryPartCFrame(CFrame.new(safePos, safePos + Vehicle.PrimaryPart.CFrame.LookVector))
                            game:GetService("StarterGui"):SetCore("SendNotification", {
                                Title = "Anti-Void",
                                Text = "Vehicle teleported to prevent falling into void!",
                                Duration = 2
                            })
                            print("Anti-void triggered, repositioned to Y: " .. (groundHeightNoclip and (groundHeightNoclip + 5) or 50))
                        end
                    end
                end
            end
        end
    end
end)

-- SUSPENSION PAGE
local suspensionPage = Venyx:addPage("Suspension", 6031068433)
print("Suspension page added!")
local suspensionSection = suspensionPage:addSection("Spring Settings")
local suspensionSettings = {Stiffness = -4000, Damping = 200, HeightAdjustEnabled = true}
suspensionSection:addToggle("Adjust Tire Height", true, function(v)
    suspensionSettings.HeightAdjustEnabled = v
    print("Height Adjust Enabled: " .. tostring(v))
end)
local function UpdateSuspension(stiffness, damping)
    local Character = LocalPlayer.Character
    if Character then
        local Humanoid = Character:FindFirstChildWhichIsA("Humanoid")
        if Humanoid then
            local SeatPart = Humanoid.SeatPart
            if SeatPart and SeatPart:IsA("VehicleSeat") then
                local Vehicle = GetVehicleFromDescendant(SeatPart)
                if Vehicle then
                    local springCount = 0
                    for _, spring in pairs(Vehicle:GetDescendants()) do
                        if spring:IsA("SpringConstraint") then
                            springCount = springCount + 1
                            pcall(function()
                                spring.Stiffness = stiffness
                                if suspensionSettings.HeightAdjustEnabled and not noclipEnabled then
                                    local baseHeight = 2.5
                                    local heightAdjustment = (stiffness / 1000)
                                    local newFreeLength = baseHeight - heightAdjustment
                                    spring.FreeLength = math.clamp(newFreeLength, -5, 5)
                                end
                            end)
                            pcall(function()
                                spring.Damping = damping
                            end)
                        end
                    end
                    if springCount == 0 then
                        warn("No SpringConstraints found in vehicle. Tire height adjustment may not work.")
                    else
                        print("Found " .. springCount .. " SpringConstraints. Applied stiffness: " .. stiffness .. ", FreeLength: " .. (suspensionSettings.HeightAdjustEnabled and not noclipEnabled and (math.clamp(2.5 - (stiffness / 1000), -5, 5)) or "default"))
                    end
                end
            end
        end
    end
end
suspensionSection:addSlider("Stiffness / Height", suspensionSettings.Stiffness, -5000, 5000, function(v)
    suspensionSettings.Stiffness = v
    UpdateSuspension(suspensionSettings.Stiffness, suspensionSettings.Damping)
end)
suspensionSection:addSlider("Damping", suspensionSettings.Damping, 0, 2000, function(v)
    suspensionSettings.Damping = v
    UpdateSuspension(suspensionSettings.Stiffness, suspensionSettings.Damping)
end)

-- TIRE PAGE
local tirePage = Venyx:addPage("Tire", 6031068433)
print("Tire page added!")
local turnSection = tirePage:addSection("Turn Controls")
local turnSpeed = 0.5
turnSection:addSlider("Turn Speed", 50, 0, 200, function(v) turnSpeed = v / 100; print("Turn Speed: " .. turnSpeed) end)
local function ApplyTurn(direction)
    local Character = LocalPlayer.Character
    if Character then
        local Humanoid = Character:FindFirstChildWhichIsA("Humanoid")
        if Humanoid then
            local SeatPart = Humanoid.SeatPart
            if SeatPart and SeatPart:IsA("VehicleSeat") then
                local Vehicle = GetVehicleFromDescendant(SeatPart)
                if Vehicle and Vehicle.PrimaryPart then
                    local currentCFrame = Vehicle:GetPrimaryPartCFrame()
                    local rotation = CFrame.Angles(0, math.rad(direction * turnSpeed), 0)
                    Vehicle:SetPrimaryPartCFrame(currentCFrame * rotation)
                end
            end
        end
    end
end
local turnLeftKeyCode = Enum.KeyCode.A
turnSection:addKeybind("Turn Left", turnLeftKeyCode, function()
    if not velocityEnabled then return end
    print("Turn Left keybind pressed!")
    while UserInputService:IsKeyDown(turnLeftKeyCode) do
        task.wait(0)
        ApplyTurn(1)
        if not velocityEnabled then break end
    end
end, function(v) turnLeftKeyCode = v.KeyCode; print("Turn Left Keybind Changed: " .. tostring(v.KeyCode)) end)
local turnRightKeyCode = Enum.KeyCode.D
turnSection:addKeybind("Turn Right", turnRightKeyCode, function()
    if not velocityEnabled then return end
    print("Turn Right keybind pressed!")
    while UserInputService:IsKeyDown(turnRightKeyCode) do
        task.wait(0)
        ApplyTurn(-1)
        if not velocityEnabled then break end
    end
end, function(v) turnRightKeyCode = v.KeyCode; print("Turn Right Keybind Changed: " .. tostring(v.KeyCode)) end)

-- INFO PAGE
repeat task.wait(0) until game:IsLoaded() and game.PlaceId > 0
print("Game loaded! PlaceId: " .. game.PlaceId)
if game.PlaceId == 3351674303 then
    local drivingEmpirePage = Venyx:addPage("Wayfort", 8357222903)
    local dealershipSection = drivingEmpirePage:addSection("Vehicle Dealership")
    local dealershipList = {}
    for index, value in pairs(Workspace:WaitForChild("Game"):WaitForChild("Dealerships"):WaitForChild("Dealerships"):GetChildren()) do
        table.insert(dealershipList, value.Name)
    end
    dealershipSection:addDropdown("Dealership", dealershipList, function(v)
        game:GetService("ReplicatedStorage").Remotes.Location:FireServer("Enter", v)
        print("Entered dealership: " .. v)
    end)
elseif game.PlaceId == 891852901 then
    local greenvillePage = Venyx:addPage("Greenville", 8360925727)
elseif game.PlaceId == 54865335 then
    local ultimateDrivingPage = Venyx:addPage("Westover", 8360954483)
elseif game.PlaceId == 5232896677 then
    local pacificoPage = Venyx:addPage("Pacifico", 3028235557)
elseif game.PlaceId == 6161235818 then
    local twistedPage = Venyx:addPage("Twisted", 1234567890)
    local twistedSection = twistedPage:addSection("Twisted Storm Chasing")
    twistedSection:addButton("Toggle Headlights (H Key)", function()
        local Character = LocalPlayer.Character
        if Character then
            local Humanoid = Character:FindFirstChildWhichIsA("Humanoid")
            if Humanoid then
                local SeatPart = Humanoid.SeatPart
                if SeatPart and SeatPart:IsA("VehicleSeat") then
                    local Vehicle = GetVehicleFromDescendant(SeatPart)
                    if Vehicle then
                        print("Toggling Twisted headlights!")
                        local remotes = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes")
                        if remotes then
                            local lightRemote = remotes:FindFirstChild("ToggleLights") or remotes:FindFirstChild("VehicleLights")
                            if lightRemote and lightRemote:IsA("RemoteEvent") then
                                lightRemote:FireServer()
                                print("Fired remote for headlights!")
                            end
                        end
                        local lightCount = 0
                        for _, light in pairs(Vehicle:GetDescendants()) do
                            if light:IsA("SpotLight") or light:IsA("PointLight") then
                                light.Enabled = not light.Enabled
                                lightCount = lightCount + 1
                            end
                        end
                        print("Toggled " .. lightCount .. " local lights!")
                        game:GetService("StarterGui"):SetCore("SendNotification", {
                            Title = "Twisted Headlights",
                            Text = "Headlights toggled!",
                            Duration = 2
                        })
                    end
                end
            end
        end
    end)
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode.H then
            print("H key pressed for Twisted headlights!")
            local Character = LocalPlayer.Character
            if Character then
                local Humanoid = Character:FindFirstChildWhichIsA("Humanoid")
                if Humanoid then
                    local SeatPart = Humanoid.SeatPart
                    if SeatPart and SeatPart:IsA("VehicleSeat") then
                        local Vehicle = GetVehicleFromDescendant(SeatPart)
                        if Vehicle then
                            local remotes = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes")
                            if remotes then
                                local lightRemote = remotes:FindFirstChild("ToggleLights") or remotes:FindFirstChild("VehicleLights")
                                if lightRemote and lightRemote:IsA("RemoteEvent") then
                                    lightRemote:FireServer()
                                end
                            end
                            for _, light in pairs(Vehicle:GetDescendants()) do
                                if light:IsA("SpotLight") or light:IsA("PointLight") then
                                    light.Enabled = not light.Enabled
                                end
                            end
                        end
                    end
                end
            end
        end
    end)
end
local infoPage = Venyx:addPage("Information", 8356778308)
print("Info page added!")
local discordSection = infoPage:addSection("Discord")
discordSection:addButton("Copy Discord Link", function()
    setclipboard("https://www.discord.com/invite/ENHYznSPmM")
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Discord",
        Text = "Discord link copied to clipboard!",
        Duration = 3
    })
    print("Discord link copied!")
end)
print("Universal Vehicle Script fully loaded! Open UI with RightBracket (])")
local function CloseGUI() Venyx:toggle() end
UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    if not gameProcessedEvent and input.KeyCode == Enum.KeyCode.RightBracket then
        CloseGUI()
        print("UI toggled!")
    end
end)
