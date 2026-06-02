});
        if Library then
            pcall(function(...)
                v5 = Library;
                v5.Unload(v5);
                return; 
            end);
        end;
        W = "https://raw.githubusercontent.com/vinxonez/ViKai-HUB/main/";
        v2 = game;
        r24 = loadstring(v2.HttpGet(v2, W .. "Library.lua"))();
        v6 = game;
        loadstring(v6.HttpGet(v6, W .. "ThemeManager.lua"))();
        r = game;
        loadstring(r.HttpGet(r, W .. "SaveManager.lua"))();
        v6 = r24;
        r = v6.CreateWindow(v6, {
            ["Title"] = "Anonymous9x",
            ["Footer"] = "VIP Fish it",
            ["Icon"] = 97269958324726,
            ["NotifySide"] = "Right",
            ["Size"] = UDim2.fromOffset(540, 350),
            ["ShowCustomCursor"] = false
        });
        v6 = {
            ["Info"] = r.AddTab(r, "Info", "info"),
            ["Main"] = r.AddTab(r, "Main", "house"),
            ["Teleport"] = r.AddTab(r, "Teleport", "map-pinned"),
            ["Shop"] = r.AddTab(r, "Shop", "shopping-cart"),
            ["Quest"] = r.AddTab(r, "Quest", "book"),
            ["Web"] = r.AddTab(r, "Webhooks", "webhook"),
            ["Misc"] = r.AddTab(r, "Misc", "settings")
        };
        I = game;
        v8 = game;
        J = game;
        X = game;
        E = game;
        Y = game;
        K = game;
        F = game;
        gW = game;
        CW = game;
        r25 = {
            ["Players"] = I.GetService(I, "Players"),
            ["RS"] = v8.GetService(v8, "ReplicatedStorage"),
            ["UIS"] = J.GetService(J, "UserInputService"),
            ["VU"] = X.GetService(X, "VirtualUser"),
            ["Run"] = E.GetService(E, "RunService"),
            ["Tween"] = Y.GetService(Y, "TweenService"),
            ["HttpService"] = K.GetService(K, "HttpService"),
            ["TS"] = F.GetService(F, "TeleportService"),
            ["NC"] = gW.GetService(gW, "NetworkClient"),
            ["Vim"] = CW.GetService(CW, "VirtualInputManager")
        };
        r26 = {
            ["Net"] = r25.RS.Packages._Index["sleitnick_net@0.2.0"].net,
            ["Replion"] = require(r25.RS.Packages.Replion),
            ["FishingController"] = require(r25.RS.Controllers.FishingController),
            ["AutoFishingController"] = require(r25.RS.Controllers.AutoFishingController),
            ["TradingController"] = require(r25.RS.Controllers.ItemTradingController),
            ["ItemUtility"] = require(r25.RS.Shared.ItemUtility),
            ["VendorUtility"] = require(r25.RS.Shared.VendorUtility),
            ["PlayerStatsUtility"] = require(r25.RS.Shared.PlayerStatsUtility),
            ["Effects"] = require(r25.RS.Shared.Effects)
        };
        v8 = u[m];
        r27 = r25.Players.LocalPlayer;
        A = r27.Character;
        i = A;
        if A then
            v5 = v5;
            r28 = A;
            i = r28;
            r29 = i.WaitForChild(i, "HumanoidRootPart");
            A = r28;
            A.FindFirstChildOfClass(A, "Humanoid");
            A = r27;
            r30 = A.WaitForChild(A, "PlayerGui");
            c = workspace.CurrentCamera;
            X = r30;
            r31 = X.WaitForChild(X, "Merchant");
            L = workspace;
            L.WaitForChild(L, "!!! MENU RINGS");
            L = workspace;
            L.WaitForChild(L, "CosmeticFolder");
            L = r25.RS.Modules.Animations;
            L = r25.RS.Packages._Index["sleitnick_net@0.2.0"];
            b = L.WaitForChild(L, "net");
            L = r27;
            K = L.WaitForChild(L, "leaderstats");
            L = r26.Net["RE/RollEnchant"];
            r32 = K.WaitForChild(K, "Caught");
            nW = r27;
            G = nW.WaitForChild(nW, "PlayerGui");
            r33 = G.FindFirstChild(G, "Small Notification");
            CW = r26.Replion.Client;
            NW = r25.RS;
            OW = r25.RS.Packages._Index;
            r34 = {
                ["Data"] = CW.WaitReplion(CW, "Data"),
                ["Items"] = NW.WaitForChild(NW, "Items"),
                ["PlayerStat"] = require(OW.FindFirstChild(OW, "ytrev_replion@2.0.0-rc.3").replion)
            };
            r35 = {
                ["ChargeFishingRod"] = b.WaitForChild(b, "RF/ChargeFishingRod"),
                ["RequestFishingMinigameStarted"] = b.WaitForChild(b, "RF/RequestFishingMinigameStarted"),
                ["SellAllItems"] = b.WaitForChild(b, "RF/SellAllItems"),
                ["PurchaseWeather"] = b.WaitForChild(b, "RF/PurchaseWeatherEvent"),
                ["PurchaseBait"] = b.WaitForChild(b, "RF/PurchaseBait"),
                ["PurchaseRod"] = b.WaitForChild(b, "RF/PurchaseFishingRod"),
                ["UpdateFishingRadar"] = b.WaitForChild(b, "RF/UpdateFishingRadar"),
                ["CancelFishing"] = b.WaitForChild(b, "RF/CancelFishingInputs")
            };
            r36 = {
                ["FishingCompleted"] = b.WaitForChild(b, "RE/FishingCompleted"),
                ["ReplicateCutscene"] = b.WaitForChild(b, "RE/ReplicateCutscene"),
                ["StopCutscene"] = b.WaitForChild(b, "RE/StopCutscene"),
                ["EquipTool"] = b.WaitForChild(b, "RE/EquipToolFromHotbar"),
                ["UnequipTool"] = b.WaitForChild(b, "RE/UnequipToolFromHotbar"),
                ["FavoriteItem"] = b.WaitForChild(b, "RE/FavoriteItem"),
                ["FavoriteStateChanged"] = b.WaitForChild(b, "RE/FavoriteStateChanged"),
                ["ActivateEnchanting"] = b.WaitForChild(b, "RE/ActivateEnchantingAltar"),
                ["EquipItem"] = b.WaitForChild(b, "RE/EquipItem"),
                ["SpawnTotem"] = b.WaitForChild(b, "RE/SpawnTotem"),
                ["FishCaughtEvent"] = b.WaitForChild(b, "RE/FishCaught"),
                ["PlaceCafeEvent"] = b.WaitForChild(b, "RE/PlaceCavernTotemItem"),
                ["ReplicateTextEffect"] = b.WaitForChild(b, "RE/ReplicateTextEffect"),
                ["ActivateSCEnchanting"] = b.WaitForChild(b, "RE/ActivateSecondEnchantingAltar")
            };
            r37 = {
                ["autoEquipRod"] = false
            };
            L.WaitForChild(L, "ReelIntermission");
            SW = workspace;
            SW.GetServerTimeNow(SW);
            getgenv().AutoSell = false;
            getgenv().AutoFarmTP = false;
            getgenv().SelectedWeathers = {};
            getgenv().AutoBuyWeather = false;
            jW = {
                pcall(function(...)
                    W = game;
                    return require(W.GetService(W, "ReplicatedStorage").Controllers.CutsceneController); 
                end)
            };
            WW = jW[2];
            mW = pcall(function(...)
                W = game;
                return require(W.GetService(W, "ReplicatedStorage").Controllers.CutsceneController); 
            end);
            vW = mW;
            if mW then
                vW = jW[2];
            end;
            v5 = v5;
            if vW then
                vW = jW[2];
                r38 = vW;
                r39 = r38.Play;
                r40 = r38.Stop;
            end;
            local function WW(...)
                if r38 and (r39 and r40) then
                    r38.Play = r39;
                    r38.Stop = r40;
                end;
                return; 
            end;
            (function(...)
                if r38 then
                    v5 = r38.ReplicateCutscene;
                    if v5 then
                        v5 = r38.ReplicateCutscene.OnClientEvent;
                        v5.Connect(v5, function(...)
                            return; 
                        end);
                    end;
                    v5 = r38.StopCutscene;
                    if v5 then
                        v5 = r38.StopCutscene.OnClientEvent;
                        v5.Connect(v5, function(...)
                            return; 
                        end);
                    end;
                    r38.Play = function(...)
                        return; 
                    end;
                    r38.Stop = function(...)
                        return; 
                    end;
                end;
                return; 
            end)();
            wm[5] = 4656877095032;
            wm[7] = 3789191579364;
            VW = r27.CharacterAdded;
            VW.Connect(VW, function(arg1_2, ...)
                v1 = arg1_2;
                r28 = v1;
                r29 = v1.WaitForChild(v1, "HumanoidRootPart");
                return; 
            end);
            task.spawn(function(...)
                v5 = task.wait;
                while v5(600) do
                    v5 = r25.VU;
                    v5.CaptureController(v5);
                    v5 = r25.VU;
                    v5.ClickButton2(v5, Vector2.new()); 
                end;
                return; 
            end);
            VW = v6.Info;
            wW = VW.AddLeftGroupbox(VW, "Information");
            wW.AddLabel(wW, "This script are still under development\nany bugs or suggestion join to our discord", true);
            wW.AddButton(wW, {
                ["Text"] = "Join Discord",
                ["Func"] = function(...)
                    setclipboard("https://discord.gg/88UhpkGs");
                    v5 = r24;
                    v5.Notify(v5, {
                        ["Title"] = "Discord",
                        ["Description"] = "Link copied!",
                        ["Time"] = 3
                    });
                    return; 
                end
            });
            wW.AddButton(wW, {
                ["Text"] = "Destroy GUI",
                ["Func"] = function(...)
                    v5 = r24;
                    v5.Unload(v5);
                    return; 
                end
            });
            VW = v6.Main;
            DW = VW.AddLeftGroupbox(VW, "Fishing Features", "shrimp");
            r41 = {
                ["IsActive"] = false,
                ["MinigameActive"] = false
            };
            getgenv().LegitFishingDelay = .1;
            local function r43(...)
                v5 = r26.FishingController;
                v5.RequestFishingMinigameClick(v5);
                task.wait(getgenv().LegitFishingDelay);
                return; 
            end;
            r44 = r26.AutoFishingController.AutoFishingStateChanged;
            local function yW(arg1_3, ...)
                v1 = arg1_3;
                r44(true);
                return; 
            end;
            r26.AutoFishingController.AutoFishingStateChanged = yW;
            local function r45(...)
                v1 = r34.Data;
                if not v1.GetExpect(v1, "AutoFishing") then
                    Z = require(r26.Net);
                    r46 = Z.RemoteFunction(Z, "UpdateAutoFishingState");
                    pcall(function(...)
                        v5 = r46;
                        return v5.InvokeServer(v5, true); 
                    end);
                end;
                return; 
            end;
            r47 = r26.FishingController.FishingRodStarted;
            r48 = r26.FishingController.FishingStopped;
            wm[6] = "\xd78\xd5T\t\x03$]\xb0\xef\xf1\x16-\xdf\xad55-";
            r26.FishingController.FishingRodStarted = function(arg1_4, arg2_4, arg3_4, ...)
                r47(arg1_4, arg2_4, arg3_4);
                if r41.IsActive and not r41.MinigameActive then
                    r41.MinigameActive = true;
                    if r42 then
                        task.cancel(r42);
                    end;
                    r42 = task.spawn(function(...)
                        v1 = r41.IsActive;
                        v3 = r41.MinigameActive;
                        while not v1 do
                            if v3 then
                                u[R[6]]();
                            end;
                            return; 
                        end;
                        v3 = r41.MinigameActive; 
                    end);
                end;
                return; 
            end;
            r26.FishingController.FishingStopped = function(arg1_5, arg2_5, ...)
                r48(arg1_5, arg2_5);
                if r41.MinigameActive then
                    r41.MinigameActive = false;
                    task.wait(1);
                    r45();
                end;
                return; 
            end;
            local function r49(arg1_6, ...)
                v1 = arg1_6;
                r41.IsActive = v1;
                if v1 then
                    r45();
                else
                    if r42 then
                        task.cancel(r42);
                    end;
                    r41.MinigameActive = false;
                    return;
                end; 
            end;
            DW.AddToggle(DW, "LegitFishing", {
                ["Text"] = "Legit Fishing",
                ["Default"] = false,
                ["Callback"] = function(arg1_7, ...)
                    v1 = arg1_7;
                    getgenv().LegitFishing = v1;
                    r49(v1);
                    v5 = r36.EquipTool;
                    v5.FireServer(v5, 1);
                    v5 = r30;
                    v3 = v5.WaitForChild(v5, "Fishing");
                    m = v3.WaitForChild(v3, "Main");
                    v5 = r30;
                    v3 = v5.WaitForChild(v5, "Charge");
                    W = v3.WaitForChild(v3, "Main");
                    if v1 then
                        m.Visible = false;
                        W.Visible = false;
                    else
                        m.Visible = true;
                        W.Visible = true;
                    end;
                    return; 
                end
            });
            wm[1] = 23477713463988;
            DW.AddInput(DW, "LegitFishingDelayInput", {
                ["Text"] = "Click Delay (s)",
                ["Numeric"] = true,
                ["Default"] = .1,
                ["Callback"] = function(arg1_8, ...)
                    m = tonumber(arg1_8);
                    if m then
                        v3 = m >= 0;
                    end;
                    if m then
                        W = v5(v1);
                        getgenv().LegitFishingDelay = W;
                    end;
                    return; 
                end
            });
            wm[12] = "\x0ee\x00\xdb\n\xa7H5g\xf6kj\xeb\x04x\xa3\xabK\x81\xbc";
            r50 = false;
            r51 = false;
            r52 = false;
            r53 = 1.5;
            r54 = 1.05;
            local function r56(...)
                if r51 then
                    return;
                end;
                r51 = true;
                task.spawn(function(...)
                    v5 = r50;
                    while v5 do
                        pcall(updateDelayBasedOnRodV2);
                        pcall(function(...)
                            v5 = r35.CancelFishing;
                            v5.InvokeServer(v5);
                            v5 = r35.ChargeFishingRod;
                            v5.InvokeServer(v5, tick());
                            task.wait(.2);
                            v5 = r35.RequestFishingMinigameStarted;
                            v5.InvokeServer(v5, -1, 1);
                            return; 
                        end);
                        v5 = task.wait;
                        v5(r53 or 0.5);
                        m = v5; 
                    end;
                    r51 = false;
                    return; 
                end);
                return; 
            end;
            local function r57(...)
                if r52 then
                    return;
                end;
                r52 = true;
                v3 = r36.ReplicateTextEffect.OnClientEvent;
                r55 = v3.Connect(v3, function(...)
                    v5 = r50;
                    v1 = {
                        S(1, H(C))
                    };
                    if v5 then
                        v5 = task.wait;
                        W = v5;
                        v5(r54 or .1);
                        pcall(function(...)
                            v5 = r36.FishingCompleted;
                            v5.FireServer(v5);
                            fishCount = (fishCount or 0) + 1;
                            return; 
                        end);
                    end;
                    return; 
                end);
                task.spawn(function(...)
                    while r50 do
                        task.wait(0.5); 
                    end;
                    if r55 then
                        v5 = r55;
                        v5.Disconnect(v5);
                    end;
                    r52 = false;
                    return; 
                end);
                return; 
            end;
            DW.AddToggle(DW, "InstantFishing", {
                ["Text"] = "Instant Fishing",
                ["Default"] = false,
                ["Callback"] = function(arg1_9, ...)
                    v1 = arg1_9;
                    r50 = v1;
                    if v1 then
                        r56();
                        r57();
                        v3 = r24;
                        v3.Notify(v3, {
                            ["Title"] = "Instant Fishing",
                            ["Description"] = "Enabled (Event-Based)",
                            ["Time"] = 3
                        });
                    else
                        if r55 then
                            v3 = r55;
                            v3.Disconnect(v3);
                        end;
                        r51 = false;
                        r52 = false;
                        Z = r24;
                        Z.Notify(Z, {
                            ["Title"] = "Instant Fishing",
                            ["Description"] = "Disabled",
                            ["Time"] = 3
                        });
                        return;
                    end; 
                end
            });
            wm[16] = "a\x7f\xefc\x04x\xd0\xd8\xfa(\xf2s\x08\t\xb8\xcb\xc58>m\xc8\xba`";
            DW.AddToggle(DW, "Auto Equip Rod", {
                ["Text"] = "Auto Equip Rod",
                ["Default"] = false,
                ["Callback"] = function(arg1_10, ...)
                    m = arg1_10;
                    r37.autoEquipRod = m;
                    local function r58(...)
                        v5 = r34.Data;
                        r59 = v5.Get(v5, "EquippedId");
                        if not r59 then
                            return false;
                        end;
                        v5 = r26.PlayerStatsUtility;
                        m = v5.GetItemFromInventory(v5, r34.Data, function(arg1_11, ...)
                            return arg1_11.UUID == r59; 
                        end);
                        if not m then
                            return false;
                        end;
                        v5 = r26.ItemUtility;
                        W = v5.GetItemData(v5, m.Id);
                        if W then
                            v3 = W.Data.Type == "Fishing Rods";
                        end;
                        return W; 
                    end;
                    local function r60(...)
                        if not r58() then
                            pcall(function(...)
                                v5 = r15.EquipTool;
                                v5.FireServer(v5, 1);
                                return; 
                            end);
                        end;
                        return; 
                    end;
                    task.spawn(function(...)
                        while r37.autoEquipRod do
                            r60();
                            task.wait(1); 
                        end;
                        return; 
                    end);
                    return; 
                end
            });
            r61 = false;
            local function r62(...)
                if r61 then
                    return;
                end;
                r61 = true;
                task.spawn(function(...)
                    while r61 do
                        task.wait(1);
                        W = r32.Value;
                        v5 = W > r32.Value;
                        if v5 then
                            v5 = v3[Z[v4]];
                            v1 = W;
                            m = 0;
                        else
                            m = 0 + 1;
                        end;
                        if 0 >= 10 then
                            pcall(function(...)
                                v5 = r35.CancelFishing;
                                v5.InvokeServer(v5);
                                return; 
                            end);
                            task.wait(.1);
                            pcall(function(...)
                                v5 = r35.CancelFishing;
                                v5.InvokeServer(v5);
                                return; 
                            end);
                            m = 0;
                        end; 
                    end;
                    return; 
                end);
                return; 
            end;
            local function r63(...)
                r61 = false;
                return; 
            end;
            wm[2] = "\xa8\x1d\x07\x8dD\xaa~\x195\xf6j\xe4p\xdb\xfd\x0b\xb7\xea\xe5\x15";
            wm[14] = "3\xea`\xcd\xe4\xb9\x96R7F(\xab\xa7|\x12\xfe;3FIa\x8e3\x02\x19";
            DW.AddToggle(DW, "CaughtMonitor", {
                ["Text"] = "Stuck Detector",
                ["Default"] = false,
                ["Callback"] = function(arg1_12, ...)
                    if arg1_12 then
                        r62();
                        v5 = r24;
                        v5.Notify(v5, {
                            ["Title"] = "Caught Monitor",
                            ["Description"] = "Enabled",
                            ["Time"] = 3
                        });
                    else
                        r63();
                        v5 = r24;
                        v5.Notify(v5, {
                            ["Title"] = "Caught Monitor",
                            ["Description"] = "Disabled",
                            ["Time"] = 3
                        });
                    end;
                    return; 
                end
            });
            DW.AddInput(DW, "DelayCast", {
                ["Text"] = "Delay Cast",
                ["Default"] = tostring(r53),
                ["Placeholder"] = "1.5",
                ["Finished"] = false,
                ["ClearTextOnFocus"] = false,
                ["Callback"] = function(arg1_13, ...)
                    v5 = tonumber;
                    m = v5(arg1_13);
                    if m then
                        v5 = v3;
                        r53 = v5;
                    end;
                    return; 
                end
            });
            wm[11] = 21832134305718;
            DW.AddInput(DW, "DelayComplete", {
                ["Text"] = "Delay Complete",
                ["Default"] = tostring(r54),
                ["Placeholder"] = "1.05",
                ["Finished"] = false,
                ["ClearTextOnFocus"] = false,
                ["Callback"] = function(arg1_14, ...)
                    v5 = tonumber;
                    m = v5(arg1_14);
                    if m then
                        v5 = v3;
                        r54 = v5;
                    end;
                    return; 
                end
            });
            DW.AddDivider(DW);
            DW.AddLabel(DW, "Cancel Fishing");
            wm[8] = "\xc1`Ii\x0e\n[\xa88Y\x8f\xe7\xc4\x05\xed\xe8wX\x87h\x96";
            DW.AddButton(DW, "Cancel Fishing", {
                ["Text"] = "Cancel Fishing",
                ["Func"] = function(...)
                    task.spawn(function(...)
                        AutoFishingRunning = false;
                        pcall(function(...)
                            v5 = r35.CancelFishing;
                            v5.InvokeServer(v5);
                            return; 
                        end);
                        v3 = r24;
                        v3.Notify(v3, {
                            ["Title"] = "Auto Fishing",
                            ["Description"] = "Cancelled",
                            ["Time"] = 3
                        });
                        return; 
                    end);
                    return; 
                end
            });
            wm[15] = 5785258281605;
            wm[17] = 22504964958447;
            qW = v6.Main;
            JW = qW.AddLeftGroupbox(qW, "Enchant Features", "zap");
            JW.AddLabel(JW, "Enchant Guide :");
            wm[13] = 2542597833887;
            JW.AddLabel(JW, "Place enchant\nstone in hotbar slot 5");
            JW.AddLabel(JW, "Auto Enchant");
            wm[3] = 28372047967131;
            r64 = Vector3.new(3231, -1303, 1402);
            local function r65(...)
                v1 = workspace;
                v1 = v1.FindFirstChild(v1, "Characters") and v1.FindFirstChild(v1, r27.Name);
                if not u[i] then
                    return;
                end;
                m = r27;
                W = m.PlayerGui and (m.PlayerGui.Backpack and m.PlayerGui.Backpack.Display);
                if W then
                    Z = W.GetChildren(W)[10];
                end;
                if nil then
                    i = r15;
                    v3 = nil.FindFirstChild(nil, "Inner") and (i.FindFirstChild(i, "Tags") and i.FindFirstChild(i, "ItemName"));
                end;
                if not Z or not 15749436972197.find(15749436972197, "enchant") then
                    return;
                end;
                u[i].CFrame = CFrame.new(r64 + Vector3.new(0, 5, 0));
                task.wait(1.2);
                pcall(function(...)
                    v5 = r36.EquipTool;
                    v5.FireServer(v5, 5);
                    task.wait(0.5);
                    v5 = r36.ActivateEnchanting;
                    v5.FireServer(v5);
                    return; 
                end);
                task.wait(7);
                u[i].CFrame = CFrame.new(u[i].Position + Vector3.new(0, 3, 0));
                v3 = r24;
                v3.Notify(v3, {
                    ["Title"] = "Auto Enchant",
                    ["Description"] = "Attempt completed",
                    ["Time"] = 4
                });
                return; 
            end;
            JW.AddButton(JW, "AutoEnchantBtn", {
                ["Text"] = "Enchant",
                ["Func"] = function(...)
                    task.spawn(r65);
                    return; 
                end
            });
            pW = v6.Main;
            XW = pW.AddRightGroupbox(pW, "Sell Features", "store");
            XW.AddLabel(XW, "Sell Mode");
            wm[4] = "\x00\xca\x1c\xed\xa8\x16\xf1\nit\x98(\x17\xdf\xbc";
            XW.AddToggle(XW, "AutoSell", {
                ["Text"] = "Auto Sell",
                ["Default"] = false,
                ["Callback"] = function(arg1_15, ...)
                    getgenv().AutoSell = arg1_15;
                    return; 
                end
            });
            r66 = "By Caught";
            r67 = 5;
            r68 = 5;
            XW.AddDropdown(XW, "SellType", {
                ["Values"] = {
                    "By Caught",
                    "By Delay"
                },
                ["Default"] = r66,
                ["Text"] = "Sell Type",
                ["Callback"] = function(arg1_16, ...)
                    r66 = arg1_16;
                    return; 
                end
            });
            XW.AddInput(XW, "SellThreshold", {
                ["Text"] = "Sell Threshold / Delay",
                ["Default"] = tostring(r67),
                ["Placeholder"] = "5",
                ["Callback"] = function(arg1_17, ...)
                    m = tonumber(arg1_17);
                    if m then
                        v3 = r66;
                        v5 = v3 == "By Caught";
                        if v5 then
                            v5 = v3;
                            r67 = v5;
                        else
                            v3 = m;
                            r68 = v3;
                        end;
                    end;
                    return; 
                end
            });
            XW.AddButton(XW, "ManualSell", {
                ["Text"] = "Manual Sell",
                ["Func"] = function(...)
                    pcall(function(...)
                        local R = {
                            R[1],
                            R[2],
                            R[3],
                            R[4]
                        };
                        v5 = u[R[1]].SellAllItems;
                        v5.InvokeServer(v5);
                        v5 = u[R[4]];
                        v5.Notify(v5, {
                            ["Title"] = "Sell",
                            ["Description"] = "Manual sell executed",
                            ["Time"] = 3
                        });
                        return; 
                    end);
                    return; 
                end
            });
            task.spawn(function(...)
                v1 = r32.Value;
                tick();
                while task.wait(0.5) do
                    if not getgenv().AutoSell then
                    end;
                    if r66 == "By Caught" then
                        W = r32.Value;
                        v5 = W - r32.Value >= r67;
                        if v5 then
                            pcall(function(...)
                                v5 = r35.SellAllItems;
                                v5.InvokeServer(v5);
                                return; 
                            end);
                            v5 = r32[r15[v4]];
                            v1 = W;
                        end;
                    else
                        v5 = v3 == W;
                        if r66 == "By Delay" and tick() - tick() >= r68 then
                            pcall(function(...)
                                v5 = r35.SellAllItems;
                                v5.InvokeServer(v5);
                                return; 
                            end);
                            tick();
                        end;
                    end; 
                end;
                return; 
            end);
            EW = v6.Shop;
            YW = v6.Teleport;
            bW = v6.Misc;
            PW = v6.Event;
            wm[9] = 25062516403606;
            KW = v6.Web;
            FW = v6.Quest;
            GW = EW.AddLeftGroupbox(EW, "Rod Features", "shopping-cart");
            wm[10] = "\\LQ\xba\x05\x0b\xcf7\x0f(\xcc}\xb8YG8\xf4\xca\xf82\xe8\xd9i";
            Sm = "Luck Rod (350)";
            wm[1] = r16(wm[2], wm[3]);
            wm[1] = r15;
            wm[2] = r16;
            wm[3] = wm[2](wm[4], wm[5]);
            wm[3] = r15;
            wm[1] = 78;
            wm[4] = r16;
            wm[5] = wm[4](wm[6], wm[7]);
            wm[2] = wm[3][wm[5]];
            wm[3] = 4;
            wm[5] = r15;
            wm[6] = r16;
            wm[7] = wm[6](wm[8], wm[9]);
            wm[4] = wm[5][wm[7]];
            wm[7] = r15;
            wm[5] = 80;
            wm[8] = r16;
            wm[9] = wm[8](wm[10], wm[11]);
            wm[6] = wm[7][wm[9]];
            wm[9] = r15;
            wm[7] = 6;
            wm[10] = r16;
            wm[11] = wm[10](wm[12], wm[13]);
            wm[8] = wm[9][wm[11]];
            wm[11] = r15;
            wm[12] = r16;
            wm[13] = wm[12](wm[14], wm[15]);
            wm[9] = 7;
            wm[10] = wm[11][wm[13]];
            wm[11] = 255;
            wm[13] = r15;
            wm[14] = r16;
            wm[15] = wm[14](wm[16], wm[17]);
            wm[12] = wm[13][wm[15]];
            wm[13] = 258;
            r69 = {
                ["Angler Rod (8,000,000)"] = 168,
                ["Ares Rod (3,000,000)"] = 126,
                ["Astral Rod (100,000)"] = 5,
                [Sm] = 79,
                ["Carbon Rod (900)"] = 76,
                [r15[r16("\xf4z\xf7]6\xfc3\xca%\xbf\xa8\xb9\xc9Z\xaa\x83\x7f", wm[1])]] = 85,
                [r15[wm[1]]] = 77,
                [wm[1][wm[3]]] = wm[1],
                [wm[2]] = wm[3],
                [wm[4]] = wm[5],
                [wm[6]] = wm[7],
                [wm[8]] = wm[9],
                [wm[10]] = wm[11],
                [wm[12]] = wm[13]
            };
            nm = {};
            Nm = r69;
            Cm = Sm[2];
            Hm = Sm[1];
            for Rm, Nm in pairs(Nm) do
                table.insert(nm, Rm); 
            end;
            r70 = nm[1];
            wm[1] = 26441494655000;
            wm[10] = "=\xa7\x88bOk\x85H\x82\xc4\x89\x024\xbd\xb4W\xd8\xb6xu\xcf\x85\xdf";
            wm[4] = "*\x1e@\xab+\x02\xc7\x99\xd7\xe7t\x90\xeb\x91\x8d\x8eN\xfe\xc0\xab\xb3\xf0Qmf\xe6";
            GW.AddDropdown(GW, "SelectRod", {
                ["Values"] = nm,
                ["Default"] = r70,
                ["Text"] = "Select Rod",
                [r15[r16("3\xf7h\xad\xd1zM]", wm[1])]] = function(arg1_18, ...)
                    r70 = arg1_18;
                    return; 
                end
            });
            wm[5] = 33285289622667;
            wm[1] = 26651159163002;
            GW.AddButton(GW, "BuyRodBtn", {
                ["Text"] = "Buy Selected Rod",
                ["Func"] = function(...)
                    if r70 and r69[r70] then
                        pcall(function(...)
                            v5 = r35.PurchaseRod;
                            v5.InvokeServer(v5, r69[r70]);
                            return; 
                        end);
                        v5 = r24;
                        y = "Requested purchase: %s";
                        v5.Notify(v5, {
                            ["Title"] = "Shop",
                            ["Description"] = y.format(y, r70),
                            ["Time"] = 3
                        });
                    else
                        v5 = r24;
                        v5.Notify(v5, {
                            ["Title"] = "Shop",
                            ["Description"] = "PurchaseRod remote not found",
                            ["Time"] = 4
                        });
                    end;
                    return; 
                end
            });
            r71 = false;
            wm[2] = "\xf5\xc8\xc80d\x13\x05c\xd6]\xd20\xdf4_\xdc\x81\x84T\x06C";
            wm[8] = "a\xe3u2\x97\x8f\x9d\x93\x97\xfe;\xcb\xff\x92\xdc\x7f\x90E\xbcG\xac\xa2|";
            r31.Enabled = r71;
            wm[11] = 12832374347607;
            wm[7] = 22857164433811;
            GW.AddButton(GW, "ToggleMerchantGUI", {
                ["Text"] = "Merchant GUI",
                ["Func"] = function(...)
                    v5 = not r71;
                    r71 = v5;
                    r31.Enabled = r71;
                    v3 = r24;
                    v5 = v5;
                    v5 = v5;
                    v3.Notify(v3, {
                        ["Title"] = "Merchant",
                        ["Description"] = r71 and "Merchant GUI opened" or "Merchant GUI closed",
                        ["Time"] = 2
                    });
                    return; 
                end
            });
            wm[3] = 31031356651634;
            Om = r15[r16("za\xd6\x88\x9c\x08\xc1\xaa\xe4\xf7\x8cy\t\x04\xcd&\x12\x05\x00\x00", wm[1])];
            wm[1] = r16(wm[2], wm[3]);
            wm[1] = r15;
            wm[2] = r16;
            wm[3] = wm[2](wm[4], wm[5]);
            wm[6] = "\xc7,_X[\xa0z\xae\xcf'\xfe_\x85\x1c`:<\xb3\x9f\xc3T\x9eXH";
            wm[1] = 8;
            wm[3] = r15;
            wm[4] = r16;
            wm[5] = wm[4](wm[6], wm[7]);
            wm[2] = wm[3][wm[5]];
            wm[5] = r15;
            wm[6] = r16;
            wm[9] = 7760674082333;
            wm[3] = 15;
            wm[7] = wm[6](wm[8], wm[9]);
            wm[4] = wm[5][wm[7]];
            wm[7] = r15;
            wm[8] = r16;
            wm[5] = 16;
            wm[9] = wm[8](wm[10], wm[11]);
            wm[6] = wm[7][wm[9]];
            wm[7] = 20;
            r72 = {
                ["Topwater Bait (100)"] = 10,
                ["Luck Bait (1,000)"] = 2,
                ["Midnight Bait (3,000)"] = 3,
                [Om] = 17,
                [r15[wm[1]]] = 6,
                [wm[1][wm[3]]] = wm[1],
                [wm[2]] = wm[3],
                [wm[4]] = wm[5],
                [wm[6]] = wm[7]
            };
            gm = {};
            vm = r72;
            um = Om[3];
            for um, vm in Om[1], pairs(vm) do
                wm[2] = "w\xc3\x88TT\xb8";
                wm[3] = 34017553825248;
                wm[1] = r16(wm[2], wm[3]);
                table[r15[wm[1]]](gm, um); 
            end;
            wm[3] = "\xfd\x8a&\xbd";
            r73 = gm[1];
            wm[8] = "\x05\xa5\x01";
            wm[5] = 1632044778231;
            Nm = EW.AddRightGroupbox(EW, "Bait Features", "fish");
            wm[4] = 10541872665388;
            wm[1] = 13483684370566;
            wm[14] = "\xf3,P";
            wm[1] = "\x0b\xd6\x93q$\r\xb2";
            wm[6] = 21233030981279;
            wm[2] = 30614120413103;
            wm[27] = 26433488990229;
            wm[10] = "4\xe09";
            wm[1] = r16;
            wm[24] = "\xe4\x1cO";
            wm[2] = wm[1](wm[3], wm[4]);
            wm[1] = r15;
            wm[12] = "z\xda\xce";
            wm[4] = "\x03\xa7\x08\xc1\xf6\xfd\x9cc\xe33\x8f";
            wm[2] = r16;
            wm[3] = wm[2](wm[4], wm[5]);
            wm[36] = " \x92\x96";
            wm[2] = r15;
            wm[5] = "8\xa6;\x12\xfc\xfc\xf8\x99";
            wm[3] = r16;
            wm[4] = wm[3](wm[5], wm[6]);
            wm[1] = wm[2][wm[4]];
            wm[2] = function(arg1_19, ...)
                r73 = arg1_19;
                return; 
            end;
            wm[20] = "\x03pA";
            wm[2] = 5039617394986;
            Nm.AddDropdown(Nm, "SelectBait", {
                [r15[r16("v\xe4\xcc\xdfv\xff", wm[1])]] = gm,
                [r15[r16(wm[1], wm[2])]] = r73,
                [r15[wm[2]]] = wm[1][wm[3]],
                [wm[1]] = wm[2]
            });
            wm[6] = "\x8b.]";
            wm[3] = 16916184948421;
            wm[1] = 13258118649885;
            wm[1] = "\x9c\xf3\xac\xeb\xc9Q\xceF\x06\xb3\x0bj\xb6\xe8d*\x81";
            wm[41] = 4882628413665;
            wm[7] = 8121594859205;
            wm[2] = "/\xe3\r\x1b";
            wm[1] = r16(wm[2], wm[3]);
            wm[16] = "U\xc9\xee";
            wm[17] = 11434983527628;
            Nm.AddButton(Nm, "BuyBaitBtn", {
                [r15[r16("L\x8d\xd8\x8d", wm[1])]] = r15[r16(wm[1], wm[2])],
                [r15[wm[1]]] = function(...)
                    if r73 and r72[r73] then
                        pcall(function(...)
                            v5 = r35.PurchaseBait;
                            v5.InvokeServer(v5, r72[r73]);
                            return; 
                        end);
                        v5 = r24;
                        y = "Requested bait purchase: %s";
                        v5.Notify(v5, {
                            ["Title"] = "Shop",
                            ["Description"] = y.format(y, r73),
                            ["Time"] = 3
                        });
                    else
                        v5 = r24;
                        v5.Notify(v5, {
                            ["Title"] = "Shop",
                            ["Description"] = "PurchaseBait remote not found",
                            ["Time"] = 4
                        });
                    end;
                    return; 
                end
            });
            wm[5] = 22831453907335;
            wm[3] = 18891933983325;
            wm[34] = "0\x96S";
            am = YW.AddLeftGroupbox(YW, "Teleport Features", "map-pinned");
            wm[13] = 5493114784253;
            wm[2] = "9\x93\xdd";
            wm[28] = "4L\x03";
            wm[11] = 31729192204727;
            wm[22] = "\xe0I\xa8";
            wm[4] = "\x88\x97\xb1";
            wm[23] = 16370870803911;
            wm[1] = r16(wm[2], wm[3]);
            wm[9] = 25232793349605;
            wm[2] = 9288413139173;
            wm[1] = "\x92\xc6!\x8b\x18Th\xfd\x9c\xa0Y";
            wm[1] = r15;
            wm[2] = r16;
            wm[35] = 1809791435594;
            wm[26] = "7\x1e\xa0";
            wm[3] = wm[2](wm[4], wm[5]);
            wm[1] = 3;
            wm[15] = 6711200533557;
            wm[2] = 2410;
            wm[3] = "\xdc\xf9\xcf \"\xbf\x0f\xf8\xba\x899C\x04\x85";
            wm[1] = r16;
            wm[4] = 31724308347316;
            wm[2] = wm[1](wm[3], wm[4]);
            wm[29] = 6090129591059;
            wm[2] = "CFrame";
            wm[1] = Env[wm[2]];
            wm[3] = r15;
            wm[38] = "\x82 m";
            wm[4] = r16;
            wm[5] = wm[4](wm[6], wm[7]);
            wm[4] = 5055;
            wm[2] = wm[3][wm[5]];
            wm[5] = "%Q\xb9.\xc7\x88'bQ\xfa\xa1\x13\xca\xd7";
            wm[3] = 8;
            wm[6] = 18245507834160;
            wm[2] = 1008;
            wm[1] = wm[1][wm[2]](wm[2], wm[3], wm[4]);
            wm[2] = r15;
            wm[3] = r16;
            wm[4] = wm[3](wm[5], wm[6]);
            wm[4] = "CFrame";
            wm[3] = Env[wm[4]];
            wm[5] = r15;
            wm[6] = r16;
            wm[7] = wm[6](wm[8], wm[9]);
            wm[4] = wm[5][wm[7]];
            wm[2] = wm[3][wm[4]];
            wm[4] = 1994;
            wm[7] = "e5a\xf6=\xda\xb6b\xa7\\\xba\xad\xd5\xc1dE";
            wm[6] = 1365;
            wm[5] = 8;
            wm[3] = wm[2](wm[4], wm[5], wm[6]);
            wm[8] = 30135614224080;
            wm[4] = r15;
            wm[5] = r16;
            wm[6] = wm[5](wm[7], wm[8]);
            wm[2] = wm[4][wm[6]];
            wm[6] = "CFrame";
            wm[5] = Env[wm[6]];
            wm[7] = r15;
            wm[21] = 25659538173612;
            wm[8] = r16;
            wm[9] = wm[8](wm[10], wm[11]);
            wm[6] = wm[7][wm[9]];
            wm[7] = 17;
            wm[25] = 31452923443510;
            wm[8] = 2835;
            wm[4] = wm[5][wm[6]];
            wm[6] = 34;
            wm[10] = 20662541657493;
            wm[5] = wm[4](wm[6], wm[7], wm[8]);
            wm[9] = "\x86<\xb3\x14\xdb\xaf";
            wm[6] = r15;
            wm[7] = r16;
            wm[8] = wm[7](wm[9], wm[10]);
            wm[4] = wm[6][wm[8]];
            wm[8] = "CFrame";
            wm[7] = Env[wm[8]];
            wm[9] = r15;
            wm[10] = r16;
            wm[11] = wm[10](wm[12], wm[13]);
            wm[8] = wm[9][wm[11]];
            wm[11] = "\xb1~A\xa2\x12\x0e\xc8\x88\xe0\x81D~r\"";
            wm[19] = 33809889983871;
            wm[12] = 33361236982959;
            wm[6] = wm[7][wm[8]];
            wm[10] = 802;
            wm[8] = -688;
            wm[9] = 3;
            wm[7] = wm[6](wm[8], wm[9], wm[10]);
            wm[8] = r15;
            wm[40] = "yGS";
            wm[9] = r16;
            wm[10] = wm[9](wm[11], wm[12]);
            wm[45] = 26157966585748;
            wm[6] = wm[8][wm[10]];
            wm[10] = "CFrame";
            wm[33] = 25543691972214;
            wm[9] = Env[wm[10]];
            wm[11] = r15;
            wm[12] = r16;
            wm[13] = wm[12](wm[14], wm[15]);
            wm[10] = wm[11][wm[13]];
            wm[13] = "\x14\x05#\t\xf8H\xe5owo\x12\xb0\xf3/";
            wm[12] = 93;
            wm[8] = wm[9][wm[10]];
            wm[10] = -579;
            wm[11] = 41;
            wm[9] = wm[8](wm[10], wm[11], wm[12]);
            wm[10] = r15;
            wm[14] = 16893705035450;
            wm[11] = r16;
            wm[12] = wm[11](wm[13], wm[14]);
            wm[8] = wm[10][wm[12]];
            wm[12] = "CFrame";
            wm[11] = Env[wm[12]];
            wm[13] = r15;
            wm[14] = r16;
            wm[15] = wm[14](wm[16], wm[17]);
            wm[12] = wm[13][wm[15]];
            wm[10] = wm[11][wm[12]];
            wm[16] = 11750817944927;
            wm[15] = "A\xf6r\xeeh\xdf\xeb\xd0\xdc\x1a\x92\xb4\x7f";
            wm[13] = 53;
            wm[30] = "\x9b\x97\x93";
            wm[43] = 27286638326178;
            wm[14] = 3673;
            wm[42] = "\x86fi";
            wm[18] = "\xc5\xd3\xcb";
            wm[12] = -2151;
            wm[11] = wm[10](wm[12], wm[13], wm[14]);
            wm[12] = r15;
            wm[13] = r16;
            wm[14] = wm[13](wm[15], wm[16]);
            wm[10] = wm[12][wm[14]];
            wm[14] = "CFrame";
            wm[13] = Env[wm[14]];
            wm[15] = r15;
            wm[16] = r16;
            wm[17] = wm[16](wm[18], wm[19]);
            wm[14] = wm[15][wm[17]];
            wm[12] = wm[13][wm[14]];
            wm[15] = -276;
            wm[14] = -3601;
            wm[16] = -1641;
            wm[17] = "\x0bI\xea\xad\xd8\xb4\x01\x83\xb0p]\ni\xf2\x14";
            wm[18] = 4923995523316;
            wm[13] = wm[12](wm[14], wm[15], wm[16]);
            wm[14] = r15;
            wm[15] = r16;
            wm[16] = wm[15](wm[17], wm[18]);
            wm[12] = wm[14][wm[16]];
            wm[16] = "CFrame";
            wm[15] = Env[wm[16]];
            wm[17] = r15;
            wm[18] = r16;
            wm[19] = wm[18](wm[20], wm[21]);
            wm[16] = wm[17][wm[19]];
            wm[17] = -135;
            wm[19] = "Jq\xe8\x04\xb3\xcd\xb5\x7f\xe5\xe6$#\x16>\xa8\xcd\xec\xc1\xbb\xf9";
            wm[14] = wm[15][wm[16]];
            wm[18] = -953;
            wm[16] = -3783;
            wm[20] = 7705059724803;
            wm[15] = wm[14](wm[16], wm[17], wm[18]);
            wm[16] = r15;
            wm[17] = r16;
            wm[18] = wm[17](wm[19], wm[20]);
            wm[14] = wm[16][wm[18]];
            wm[44] = "G\xd19";
            wm[18] = "CFrame";
            wm[17] = Env[wm[18]];
            wm[19] = r15;
            wm[20] = r16;
            wm[21] = wm[20](wm[22], wm[23]);
            wm[20] = -591;
            wm[18] = wm[19][wm[21]];
            wm[22] = 19038247396001;
            wm[16] = wm[17][wm[18]];
            wm[19] = 128;
            wm[18] = 1479;
            wm[21] = "?\xfaT(\x80\xfb\x8a\x99\x80\xd6n\xd7\x0e\x89\xb2gv\x10";
            wm[17] = wm[16](wm[18], wm[19], wm[20]);
            wm[18] = r15;
            wm[19] = r16;
            wm[20] = wm[19](wm[21], wm[22]);
            wm[16] = wm[18][wm[20]];
            wm[20] = "CFrame";
            wm[31] = 1143805182484;
            wm[19] = Env[wm[20]];
            wm[21] = r15;
            wm[22] = r16;
            wm[23] = wm[22](wm[24], wm[25]);
            wm[20] = wm[21][wm[23]];
            wm[24] = 11125667943484;
            wm[21] = -91;
            wm[23] = "\x84?\xb0\xff\xaeGN`\x16JE\xb4\x9e\xee";
            wm[22] = -700;
            wm[18] = wm[19][wm[20]];
            wm[20] = 2113;
            wm[19] = wm[18](wm[20], wm[21], wm[22]);
            wm[20] = r15;
            wm[21] = r16;
            wm[22] = wm[21](wm[23], wm[24]);
            wm[18] = wm[20][wm[22]];
            wm[22] = "CFrame";
            wm[21] = Env[wm[22]];
            wm[23] = r15;
            wm[24] = r16;
            wm[25] = wm[24](wm[26], wm[27]);
            wm[22] = wm[23][wm[25]];
            wm[23] = 5;
            wm[20] = wm[21][wm[22]];
            wm[25] = "\x82\"\xec<\x89g\x01\xfc\r\xa7\x99\xb9f";
            wm[22] = 1343;
            wm[24] = -355;
            wm[26] = 15537160805443;
            wm[21] = wm[20](wm[22], wm[23], wm[24]);
            wm[22] = r15;
            wm[23] = r16;
            wm[24] = wm[23](wm[25], wm[26]);
            wm[20] = wm[22][wm[24]];
            wm[24] = "CFrame";
            wm[23] = Env[wm[24]];
            wm[25] = r15;
            wm[26] = r16;
            wm[27] = wm[26](wm[28], wm[29]);
            wm[24] = wm[25][wm[27]];
            wm[22] = wm[23][wm[24]];
            wm[28] = 10472912147212;
            wm[25] = -22;
            wm[26] = -629;
            wm[24] = 1476;
            wm[23] = wm[22](wm[24], wm[25], wm[26]);
            wm[24] = r15;
            wm[25] = r16;
            wm[27] = "NKj#\xe3D\xa8\xc5";
            wm[26] = wm[25](wm[27], wm[28]);
            wm[32] = "a\x8b\xf2";
            wm[22] = wm[24][wm[26]];
            wm[26] = "CFrame";
            wm[25] = Env[wm[26]];
            wm[27] = r15;
            wm[28] = r16;
            wm[29] = wm[28](wm[30], wm[31]);
            wm[26] = wm[27][wm[29]];
            wm[30] = 27705750401637;
            wm[28] = -851;
            wm[29] = "\x00\x97\x9d\x87)ZQ\xca";
            wm[27] = 7;
            wm[24] = wm[25][wm[26]];
            wm[26] = 1487;
            wm[25] = wm[24](wm[26], wm[27], wm[28]);
            wm[26] = r15;
            wm[27] = r16;
            wm[28] = wm[27](wm[29], wm[30]);
            wm[24] = wm[26][wm[28]];
            wm[28] = "CFrame";
            wm[27] = Env[wm[28]];
            wm[39] = 31436281608494;
            wm[29] = r15;
            wm[30] = r16;
            wm[31] = wm[30](wm[32], wm[33]);
            wm[28] = wm[29][wm[31]];
            wm[31] = "?U\xe4\xeb9\xe3\xd4&";
            wm[30] = -288;
            wm[26] = wm[27][wm[28]];
            wm[29] = 7;
            wm[28] = 1834;
            wm[27] = wm[26](wm[28], wm[29], wm[30]);
            wm[28] = r15;
            wm[32] = 20035739165809;
            wm[37] = 16575675407910;
            wm[29] = r16;
            wm[30] = wm[29](wm[31], wm[32]);
            wm[26] = wm[28][wm[30]];
            wm[30] = "CFrame";
            wm[29] = Env[wm[30]];
            wm[31] = r15;
            wm[32] = r16;
            wm[33] = wm[32](wm[34], wm[35]);
            wm[34] = 13190773774334;
            wm[30] = wm[31][wm[33]];
            wm[32] = -359;
            wm[33] = "\xd6\x84\xddM\xf9\x90g\xc3";
            wm[28] = wm[29][wm[30]];
            wm[30] = 883;
            wm[31] = 7;
            wm[29] = wm[28](wm[30], wm[31], wm[32]);
            wm[30] = r15;
            wm[31] = r16;
            wm[32] = wm[31](wm[33], wm[34]);
            wm[28] = wm[30][wm[32]];
            wm[32] = "CFrame";
            wm[31] = Env[wm[32]];
            wm[33] = r15;
            wm[34] = r16;
            wm[35] = wm[34](wm[36], wm[37]);
            wm[34] = 84;
            wm[36] = 9931386294800;
            wm[32] = wm[33][wm[35]];
            wm[30] = wm[31][wm[32]];
            wm[32] = 1418;
            wm[33] = 30;
            wm[31] = wm[30](wm[32], wm[33], wm[34]);
            wm[35] = "\x02\x0c\x1fg\xa9A\xc4\xd6\x11$@\xc7";
            wm[32] = r15;
            wm[33] = r16;
            wm[34] = wm[33](wm[35], wm[36]);
            wm[30] = wm[32][wm[34]];
            wm[34] = "CFrame";
            wm[33] = Env[wm[34]];
            wm[35] = r15;
            wm[36] = r16;
            wm[37] = wm[36](wm[38], wm[39]);
            wm[34] = wm[35][wm[37]];
            wm[32] = wm[33][wm[34]];
            wm[35] = -586;
            wm[37] = "\x80\x9fE\x87\x91\x95\xa0\x16y\xeba\x11Q\xd3";
            wm[34] = 6084;
            wm[36] = 4635;
            wm[38] = 6624096652300;
            wm[33] = wm[32](wm[34], wm[35], wm[36]);
            wm[34] = r15;
            wm[35] = r16;
            wm[36] = wm[35](wm[37], wm[38]);
            wm[32] = wm[34][wm[36]];
            wm[36] = "CFrame";
            wm[35] = Env[wm[36]];
            wm[37] = r15;
            wm[38] = r16;
            wm[39] = wm[38](wm[40], wm[41]);
            wm[36] = wm[37][wm[39]];
            wm[38] = 2842;
            wm[37] = 10;
            wm[34] = wm[35][wm[36]];
            wm[36] = 1234;
            wm[35] = wm[34](wm[36], wm[37], wm[38]);
            wm[40] = 27981101708005;
            wm[39] = "S\xe7\xd2\x0e\x1b\xeb\xc8\xfaK";
            wm[36] = r15;
            wm[37] = r16;
            wm[38] = wm[37](wm[39], wm[40]);
            wm[34] = wm[36][wm[38]];
            wm[38] = "CFrame";
            wm[37] = Env[wm[38]];
            wm[39] = r15;
            wm[40] = r16;
            wm[41] = wm[40](wm[42], wm[43]);
            wm[38] = wm[39][wm[41]];
            wm[36] = wm[37][wm[38]];
            wm[39] = -549;
            wm[42] = 10375743197919;
            wm[38] = -8651;
            wm[40] = 163;
            wm[37] = wm[36](wm[38], wm[39], wm[40]);
            wm[38] = r15;
            wm[39] = r16;
            wm[41] = "c9\x81\x06\xe6\x0f\x01\xc9b\xa4l";
            wm[40] = wm[39](wm[41], wm[42]);
            wm[36] = wm[38][wm[40]];
            wm[40] = "CFrame";
            wm[39] = Env[wm[40]];
            wm[41] = r15;
            wm[42] = r16;
            wm[43] = wm[42](wm[44], wm[45]);
            wm[40] = wm[41][wm[43]];
            wm[42] = 159;
            wm[38] = wm[39][wm[40]];
            wm[40] = -9175;
            wm[41] = -582;
            wm[39] = wm[38](wm[40], wm[41], wm[42]);
            r74 = {
                ["Enchant Altar"] = CFrame[r15[wm[1]]](3258, -1301, 1390),
                [r15[r16(wm[1], wm[2])]] = CFrame[wm[1][wm[3]]](-3273, wm[1], wm[2]),
                [r15[wm[2]]] = wm[1],
                [wm[2][wm[4]]] = wm[3],
                [wm[2]] = wm[5],
                [wm[4]] = wm[7],
                [wm[6]] = wm[9],
                [wm[8]] = wm[11],
                [wm[10]] = wm[13],
                [wm[12]] = wm[15],
                [wm[14]] = wm[17],
                [wm[16]] = wm[19],
                [wm[18]] = wm[21],
                [wm[20]] = wm[23],
                [wm[22]] = wm[25],
                [wm[24]] = wm[27],
                [wm[26]] = wm[29],
                [wm[28]] = wm[31],
                [wm[30]] = wm[33],
                [wm[32]] = wm[35],
                [wm[34]] = wm[37],
                [wm[36]] = wm[39]
            };
            um = {};
            wm[1] = {
                pairs(r74)
            };
            Wm = wm[1][2];
            mm = wm[1][1];
            Zm, Vm = mm(Wm, Zm);
            while wm[1][3] do
                wm[3] = "table";
                wm[8] = 33997838859735;
                wm[2] = Env[wm[3]];
                wm[4] = r15;
                wm[7] = "\xfb\xc8\x1fo}\xf3";
                wm[5] = r16;
                wm[6] = wm[5](wm[7], wm[8]);
                wm[3] = wm[4][wm[6]];
                wm[1] = wm[2][wm[3]];
                wm[2] = wm[1](um, Zm); 
            end;
            wm[2] = "\x0fip\xa2\xd1\xbc\xf31\x0fy\xd3\x97";
            r75 = um[1];
            wm[5] = 2408578008161;
            wm[4] = "\xf2\x89\x06\"\xb1P";
            wm[6] = 10564284699447;
            wm[8] = 25894966128410;
            wm[3] = 27269448249754;
            wm[12] = 17340873613194;
            wm[7] = "ijd\x7f";
            wm[1] = r16(wm[2], wm[3]);
            wm[1] = r15;
            wm[9] = 7332573531478;
            wm[2] = r16;
            wm[3] = wm[2](wm[4], wm[5]);
            wm[2] = r15;
            wm[3] = r16;
            wm[24] = "Y\xe5R\xff\xb6\x13";
            wm[5] = "\x00FNL\x16\x85\x08";
            wm[4] = wm[3](wm[5], wm[6]);
            wm[1] = wm[2][wm[4]];
            wm[2] = r75;
            wm[4] = r15;
            wm[5] = r16;
            wm[6] = wm[5](wm[7], wm[8]);
            wm[10] = 1039450767844;
            wm[3] = wm[4][wm[6]];
            wm[5] = r15;
            wm[8] = "\xc8\x85{j\x92\x18\x88\x1d\xf0\xde;\x81\xf7";
            wm[6] = r16;
            wm[7] = wm[6](wm[8], wm[9]);
            wm[4] = wm[5][wm[7]];
            wm[11] = 10332043219659;
            wm[6] = r15;
            wm[7] = r16;
            wm[9] = "\x83\xbf\x0c/\x91jI\t";
            wm[8] = wm[7](wm[9], wm[10]);
            wm[5] = wm[6][wm[8]];
            wm[6] = function(arg1_20, ...)
                r75 = arg1_20;
                return; 
            end;
            wm[2] = "\x95\xd9\xee\x12p|\xaaO\x89d\xe3\x8e\x18\x06";
            am.AddDropdown(am, r15[wm[1]], {
                [wm[1][wm[3]]] = um,
                [wm[1]] = wm[2],
                [wm[3]] = wm[4],
                [wm[5]] = wm[6]
            });
            wm[5] = 23703444335389;
            wm[4] = "#\xf0z\xd6";
            wm[3] = 33600025869598;
            wm[7] = 29868577207892;
            wm[13] = 10691120354162;
            wm[1] = r16(wm[2], wm[3]);
            wm[1] = r15;
            wm[2] = r16;
            wm[3] = wm[2](wm[4], wm[5]);
            wm[5] = "\x8dvX\xcd\xf0z\x88f";
            wm[8] = 25255797468656;
            wm[9] = "'\xab0\xe2";
            wm[2] = r15;
            wm[3] = r16;
            wm[6] = 20077698180229;
            wm[4] = wm[3](wm[5], wm[6]);
            wm[26] = 28883835204746;
            wm[1] = wm[2][wm[4]];
            wm[3] = r15;
            wm[21] = 33752933104997;
            wm[4] = r16;
            wm[6] = "\x9b\x81\x97\xfd";
            wm[5] = wm[4](wm[6], wm[7]);
            wm[2] = wm[3][wm[5]];
            wm[3] = function(...)
                if r29 and r74[r75] then
                    r29.CFrame = r74[r75] + Vector3.new(0, 5, 0);
                    v5 = r24;
                    v5.Notify(v5, {
                        ["Title"] = "Teleport",
                        ["Description"] = "Teleported to " .. r75,
                        ["Time"] = 3
                    });
                end;
                return; 
            end;
            wm[23] = 16273065074073;
            wm[10] = 5372054456773;
            wm[4] = 31400910272798;
            wm[2] = 12159047095837;
            am.AddButton(am, r15[wm[1]], {
                [wm[1][wm[3]]] = wm[1],
                [wm[2]] = wm[3]
            });
            wm[1] = "x\xfd0\x15\x12b\x93Z\x9d\xc9/\xdf2\xd5v\xdd[\xed\x90B\xed";
            wm[3] = ">\x81\x9d\x9fu\xdd\xc5\xa0\x9b\xdf~%\xbd\xc2\x95\x1f\x0f\xe9\xcd\xdd\xdd";
            r76 = r15[r16(wm[1], wm[2])];
            am.AddDivider(am);
            wm[16] = "\x1a\xadW]";
            wm[14] = "l=\x90l\xdeR\x12";
            wm[1] = r16;
            wm[2] = wm[1](wm[3], wm[4]);
            wm[7] = "\xbd\x1d\xab\x9c\xa0\xd3\x9d";
            am.AddLabel(am, r15[wm[2]]);
            local function r77(arg1_21, ...)
                if writefile then
                    m = arg1_21.Position;
                    writefile(r76, string.format("%.3f,%.3f,%.3f", m.X, m.Y, m.Z));
                end;
                return; 
            end;
            wm[2] = 122;
            wm[1] = function(...)
                if delfile and isfile then
                    delfile(r76);
                end;
                return; 
            end;
            r78 = wm[1];
            wm[1] = (function(...)
                v1 = isfile;
                if v1 then
                    v3 = isfile(r76);
                end;
                if v1 then
                    y = {
                        string.match(readfile(r76), "(-?%d+%.?%d*),(-?%d+%.?%d*),(-?%d+%.?%d*)")
                    };
                    m = y[2];
                    Z = string.match(readfile(r76), "(-?%d+%.?%d*),(-?%d+%.?%d*),(-?%d+%.?%d*)");
                    if Z then
                        if m then
                            y = y[3];
                        end;
                        v5 = string.match;
                        v3 = m;
                    end;
                    if Z then
                        return CFrame.new(tonumber(Z), tonumber(m), tonumber(y[3]));
                    end;
                end;
                return nil; 
            end)();
            u[wm[2]] = wm[1];
            wm[4] = r15;
            wm[5] = r16;
            wm[6] = wm[5](wm[7], wm[8]);
            wm[3] = wm[4][wm[6]];
            wm[6] = r15;
            wm[7] = r16;
            wm[8] = wm[7](wm[9], wm[10]);
            wm[5] = wm[6][wm[8]];
            wm[7] = r15;
            wm[8] = r16;
            wm[10] = "\xa3\x92\xa3/\xb5\x1aBi\xd2\xe7\x0b\x02\xe4&C~6\xfb\xef:0";
            wm[9] = wm[8](wm[10], wm[11]);
            wm[1] = "AddButton";
            wm[11] = "HN\x7f\x95";
            wm[1] = am[wm[1]];
            wm[6] = wm[7][wm[9]];
            wm[8] = r15;
            wm[9] = r16;
            wm[10] = wm[9](wm[11], wm[12]);
            wm[7] = wm[8][wm[10]];
            wm[8] = function(...)
                v1 = r27.Character;
                r29 = v1 and v1.FindFirstChild(v1, "HumanoidRootPart");
                if r29 then
                    u[wm[2]] = r29.CFrame;
                    r77(u[wm[2]]);
                    v1 = r24;
                    v1.Notify(v1, {
                        ["Title"] = "ViKai HUB",
                        ["Description"] = "Position saved!",
                        ["Time"] = 3
                    });
                end;
                return; 
            end;
            wm[9] = "C<\xa9m";
            wm[4] = {
                [wm[5]] = wm[6],
                [wm[7]] = wm[8]
            };
            wm[1] = wm[1](am, wm[3], wm[4]);
            wm[7] = "R8\x85_\x18\x15\xf9k!\xdf\xdeXx";
            wm[4] = r15;
            wm[5] = r16;
            wm[8] = 3277018416629;
            wm[6] = wm[5](wm[7], wm[8]);
            wm[1] = "AddButton";
            wm[3] = wm[4][wm[6]];
            wm[6] = r15;
            wm[10] = 18155919859974;
            wm[7] = r16;
            wm[8] = wm[7](wm[9], wm[10]);
            wm[5] = wm[6][wm[8]];
            wm[11] = 11372692427951;
            wm[10] = "t\xe4\xf5X\x93\xcah\n\x16(\xe4\xdc\x1f\xb8G\xcd\xbf\x0b\x9a\xe2\xe80\xf9";
            wm[7] = r15;
            wm[8] = r16;
            wm[12] = 9011888214116;
            wm[17] = 7659266182638;
            wm[9] = wm[8](wm[10], wm[11]);
            wm[19] = 8414545629006;
            wm[11] = "\xf7\x95\xf1&";
            wm[6] = wm[7][wm[9]];
            wm[8] = r15;
            wm[9] = r16;
            wm[10] = wm[9](wm[11], wm[12]);
            wm[7] = wm[8][wm[10]];
            wm[8] = function(...)
                v1 = r27.Character;
                r29 = v1 and v1.FindFirstChild(v1, "HumanoidRootPart");
                if r29 and u[wm[2]] then
                    r29.CFrame = u[wm[2]] + Vector3.new(0, 5, 0);
                    v5 = r24;
                    v5.Notify(v5, {
                        ["Title"] = "ViKai HUB",
                        ["Description"] = "Teleported to saved position!",
                        ["Time"] = 3
                    });
                else
                    v5 = r24;
                    v5.Notify(v5, {
                        ["Title"] = "ViKai HUB",
                        ["Description"] = "No saved position found!",
                        ["Time"] = 3
                    });
                end;
                return; 
            end;
            wm[4] = {
                [wm[5]] = wm[6],
                [wm[7]] = wm[8]
            };
            wm[7] = "\x9d\x8ee$i4\xc91\xeaVc\xb8\xa2";
            wm[8] = 13283643545641;
            wm[1] = am[wm[1]];
            wm[10] = 2644800996559;
            wm[1] = wm[1](am, wm[3], wm[4]);
            wm[4] = r15;
            wm[18] = 32974201666554;
            wm[5] = r16;
            wm[6] = wm[5](wm[7], wm[8]);
            wm[3] = wm[4][wm[6]];
            wm[6] = r15;
            wm[1] = "AddButton";
            wm[7] = r16;
            wm[25] = 34414899576473;
            wm[9] = "#\x1c\xf3\xce";
            wm[8] = wm[7](wm[9], wm[10]);
            wm[5] = wm[6][wm[8]];
            wm[10] = "\xf4\xc5\xfc\x14\x12\x89\xb2\xb3\x15\xa0\x0cA\x8e\\\x8f\xd2\xce\x91--";
            wm[7] = r15;
            wm[8] = r16;
            wm[11] = 4439582820371;
            wm[9] = wm[8](wm[10], wm[11]);
            wm[11] = "H#\xc98";
            wm[12] = 21064276010576;
            wm[6] = wm[7][wm[9]];
            wm[8] = r15;
            wm[1] = am[wm[1]];
            wm[9] = r16;
            wm[10] = wm[9](wm[11], wm[12]);
            wm[7] = wm[8][wm[10]];
            wm[8] = function(...)
                r78();
                u[wm[2]] = nil;
                v3 = r24;
                v3.Notify(v3, {
                    ["Title"] = "ViKai HUB",
                    ["Description"] = "Saved position has been reset!",
                    ["Time"] = 3
                });
                return; 
            end;
            wm[4] = {
                [wm[5]] = wm[6],
                [wm[7]] = wm[8]
            };
            wm[1] = wm[1](am, wm[3], wm[4]);
            wm[4] = "task";
            wm[3] = Env[wm[4]];
            wm[8] = "\xfbq\xef4\x17";
            wm[9] = 4625388128361;
            wm[5] = r15;
            wm[6] = r16;
            wm[7] = wm[6](wm[8], wm[9]);
            wm[10] = "5\x86\x930\xff\xc4\x90bG\x9bR\xc6";
            wm[4] = wm[5][wm[7]];
            wm[1] = wm[3][wm[4]];
            wm[15] = 30315274188580;
            wm[8] = 31516606921044;
            wm[7] = "}\xbdo\xe6\x07^\x1f\x0c\xd0\xff8-T\x91\xc70\x13\xc39r\xee\xe1\xa1.";
            wm[4] = function(...)
                v1 = r27.Character;
                v3 = v1;
                if v1 then
