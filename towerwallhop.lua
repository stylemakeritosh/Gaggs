--== Initialization ==--
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

-- Wait for LocalPlayer
local player
repeat
    player = Players.LocalPlayer
    if not player then
        task.wait(0.1)
    end
until player

-- Load UI Library
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/x2zu/OPEN-SOURCE-UI-ROBLOX/refs/heads/main/X2ZU%20UI%20ROBLOX%20OPEN%20SOURCE/DummyUi-leak-by-x2zu/fetching-main/Tools/Framework.luau"))()
getgenv().TeleportMode = "Teleport"

--== Functions ==--
function TeleportTo(position)
    local character = player.Character
    if not character or not character.Parent then return end

    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return end

    if getgenv().TeleportMode == "Teleport" then
        root.CFrame = CFrame.new(position)
    elseif getgenv().TeleportMode == "Tween" then
        local speed = getgenv().TweenSpeed or 100
        local tweenTime = 5 / (speed / 20)
        local tween = TweenService:Create(root, TweenInfo.new(tweenTime, Enum.EasingStyle.Linear), {CFrame = CFrame.new(position)})
        tween:Play()
    end
end

-- Create Main Window
local Window = Library:Window({
    Title = "Souls Hub | Tower Only Wall Hop",
    Desc = "by Rintoshiii",
    Icon = "door-open",
    Theme = "Dark",
    Config = {
        Keybind = Enum.KeyCode.LeftControl,
        Size = UDim2.new(0, 530, 0, 400)
    },
    CloseUIButton = {
        Enabled = true,
        Text = "Close UI"
    }
})

-- Info Tab
local InfoTab = Window:Tab({Title = "Info", Icon = "info-circle"}) do
    InfoTab:Section({Title = "Info"})
    InfoTab:Label({Title = "Wall Hop Tower Only" .. player.Name .. "Souls Hub", Desc = "Thanks for using Souls Hub :D"})

    InfoTab:Section({Title = "Creator"})
    InfoTab:Label({Title = "Made by Rin", Desc = "My Discord: rintoshiii"})
    InfoTab:Label({Title = "Souls Hub", Desc = "Made by Rin and Souls"})
    InfoTab:Label({Title = "https://discord.gg/QG5PHd7mVD", Desc = "Join for more"})

    InfoTab:Section({Title = "Links (Socials)"})
    InfoTab:Button({
        Title = "Discord (Co-Owner) (Rintoshiii)",
        Callback = function()
            setclipboard("@rintoshiii")
        end
    })
    InfoTab:Button({
        Title = "Souls (Owner) (soulshub_)",
        Callback = function()
            setclipboard("@soulshub_")
        end
    })

    InfoTab:Section({Title = "Discord Link"})
    InfoTab:Button({
        Title = "Click to Join Discord",
        Callback = function()
            setclipboard("https://discord.gg/QG5PHd7mVD")
        end
    })
    InfoTab:Button({
        Title = "More Scripts Soon, So Join :)",
        Callback = function()
            setclipboard("oke")
        end
    })
end

-- Main Tab
local MainTab = Window:Tab({Title = "Main", Icon = "home"}) do
    MainTab:Section({Title = "Sword (Auto and Manual)"})

    MainTab:Button({
        Title = "Get Sword",
        Callback = function()
            local character = player.Character
            if character then
                local leftArm = character:FindFirstChild("Left Arm")
                local torso = character:FindFirstChild("Torso")
                if leftArm and torso then
                    local leftShoulder = character:FindFirstChild("Left Shoulder")
                    if leftShoulder then leftShoulder:Destroy() end

                    leftArm.Anchored = false
                    leftArm.Position = Vector3.new(-261.83, 1430.00, 619.79)
                    wait(0.20)
                    leftArm.Position = torso.Position + Vector3.new(-1.5, 0, 0)
                    local newShoulder = Instance.new("Motor6D")
                    newShoulder.Name = "Left Shoulder"
                    newShoulder.Part0 = torso
                    newShoulder.Part1 = leftArm
                    newShoulder.C0 = CFrame.new(-1.5, 0.5, 0) * CFrame.Angles(0, math.rad(-90), 0)
                    newShoulder.C1 = CFrame.new(0, 0.5, 0) * CFrame.Angles(0, math.rad(-90), 0)
                    newShoulder.Parent = torso
                end
            end
        end
    })

    local autoSwordLoop
    MainTab:Toggle({
        Title = "Auto Get Sword",
        Desc = "Automatically get the sword",
        Value = false,
        Callback = function(Value)
            local character = player.Character
            if Value then
                if character then
                    local leftArm = character:FindFirstChild("Left Arm")
                    local torso = character:FindFirstChild("Torso")
                    if leftArm and torso then
                        local leftShoulder = character:FindFirstChild("Left Shoulder")
                        if leftShoulder then leftShoulder:Destroy() end

                        autoSwordLoop = RunService.Heartbeat:Connect(function()
                            leftArm.Anchored = false
                            leftArm.Position = Vector3.new(-261.83, 1430.00, 619.79)
                            wait(0.01)
                        end)
                    end
                end
            else
                if autoSwordLoop then
                    autoSwordLoop:Disconnect()
                    autoSwordLoop = nil

                    if character then
                        local leftArm = character:FindFirstChild("Left Arm")
                        local torso = character:FindFirstChild("Torso")
                        if leftArm and torso then
                            leftArm.Position = torso.Position + Vector3.new(-1.5, 0, 0)
                            local newShoulder = Instance.new("Motor6D")
                            newShoulder.Name = "Left Shoulder"
                            newShoulder.Part0 = torso
                            newShoulder.Part1 = leftArm
                            newShoulder.C0 = CFrame.new(-1.5, 0.5, 0) * CFrame.Angles(0, math.rad(-90), 0)
                            newShoulder.C1 = CFrame.new(0, 0.5, 0) * CFrame.Angles(0, math.rad(-90), 0)
                            newShoulder.Parent = torso
                        end
                    end
                end
            end
        end
    })

    MainTab:Section({Title = "Player"})
    local killAllLoop
    local originalPositions = {}
    MainTab:Toggle({
        Title = "Spam Kill All (Beta)",
        Desc = "Kill all players (equip sword and keep clicking)",
        Value = false,
        Callback = function(state)
            if state then
                originalPositions = {}
                killAllLoop = RunService.Heartbeat:Connect(function()
                    local localChar = player.Character
                    if not localChar then return end
                    local localHRP = localChar:FindFirstChild("HumanoidRootPart")
                    if not localHRP then return end
                    local localHumanoid = localChar:FindFirstChild("Humanoid")
                    if localHumanoid and localHumanoid.Health <= 0 then return end

                    for _, otherPlayer in ipairs(Players:GetPlayers()) do
                        if otherPlayer ~= player and otherPlayer.Character then
                            local otherHRP = otherPlayer.Character:FindFirstChild("HumanoidRootPart")
                            local otherHumanoid = otherPlayer.Character:FindFirstChild("Humanoid")
                            if otherHRP and otherHumanoid and otherHumanoid.Health > 0 then
                                if not originalPositions[otherPlayer] then
                                    originalPositions[otherPlayer] = otherHRP.CFrame
                                end
                                otherHRP.Anchored = false
                                otherHRP.Size = Vector3.new(10, 10, 10)
                                local position = (localHRP.CFrame * CFrame.new(0, 0, -4)).Position
                                otherHRP.CFrame = CFrame.new(position) * localHRP.CFrame.Rotation
                            end
                        end
                    end
                end)
            else
                if killAllLoop then
                    killAllLoop:Disconnect()
                    killAllLoop = nil
                end
                for otherPlayer, originalCFrame in pairs(originalPositions) do
                    if otherPlayer.Character then
                        local otherHRP = otherPlayer.Character:FindFirstChild("HumanoidRootPart")
                        if otherHRP then
                            otherHRP.Size = Vector3.new(2, 2, 1)
                            otherHRP.CFrame = originalCFrame
                        end
                    end
                end
                originalPositions = {}
            end
        end
    })
end

-- Teleport Tab
local TeleportTab = Window:Tab({Title = "Teleport", Icon = "map-marker"}) do
    TeleportTab:Section({Title = "Teleport"})

    TeleportTab:Dropdown({
        Title = "Location",
        Desc = "Select the location to teleport to",
        List = {"end", "sword", "spawn"},
        Value = "no location",
        Callback = function(Value)
            if Value == "end" then
                TeleportTo(Vector3.new(-78.22, 1664.81, 902.50))
            elseif Value == "sword" then
                TeleportTo(Vector3.new(-261.83, 1430.00, 619.79))
            elseif Value == "spawn" then
                TeleportTo(Vector3.new(-22, 1431, 520))
            end
        end
    })

    TeleportTab:Dropdown({
        Title = "Stages",
        Desc = "Select the stage to teleport to",
        List = {"stage 1", "stage 2"},
        Value = "no stage",
        Callback = function(Value)
            if Value == "stage 1" then
                TeleportTo(Vector3.new(-22, 1435, 531))
            elseif Value == "stage 2" then
                TeleportTo(Vector3.new(-22, 1440, 543))
            end
        end
    })
end

-- ESP Tab
local EspTab = Window:Tab({Title = "ESP", Icon = "eye"}) do
    local espAtivo = false
    local playerHighlightColor = Color3.new(1, 0, 0)
    local playerRainbowLoopRunning = false
    local lastPlayerColor = "Red"
    local rainbowColors = {
        Color3.fromRGB(255, 0, 0), Color3.fromRGB(0, 0, 255), Color3.fromRGB(255, 255, 0), Color3.fromRGB(0, 128, 0),
        Color3.fromRGB(128, 0, 128), Color3.fromRGB(255, 165, 0), Color3.fromRGB(255, 192, 203), Color3.fromRGB(0, 0, 0),
        Color3.fromRGB(255, 255, 255), Color3.fromRGB(128, 128, 128), Color3.fromRGB(165, 42, 42), Color3.fromRGB(0, 255, 255),
        Color3.fromRGB(255, 0, 255), Color3.fromRGB(64, 224, 208), Color3.fromRGB(50, 205, 50), Color3.fromRGB(75, 0, 130),
        Color3.fromRGB(238, 130, 238), Color3.fromRGB(255, 215, 0), Color3.fromRGB(192, 192, 192), Color3.fromRGB(245, 245, 220),
        Color3.fromRGB(255, 127, 127), Color3.fromRGB(0, 128, 128), Color3.fromRGB(128, 0, 0), Color3.fromRGB(128, 128, 0),
        Color3.fromRGB(0, 0, 128), Color3.fromRGB(220, 20, 60), Color3.fromRGB(152, 255, 152), Color3.fromRGB(230, 230, 250),
        Color3.fromRGB(250, 128, 114), Color3.fromRGB(255, 0, 128)
    }

    local function updatePlayerHighlightColor(colorName)
        lastPlayerColor = colorName
        playerRainbowLoopRunning = false
        if colorName == "Rainbow" then
            playerRainbowLoopRunning = true
            coroutine.wrap(function()
                local colorIndex = 1
                while espAtivo and playerRainbowLoopRunning do
                    playerHighlightColor = rainbowColors[colorIndex]
                    for _, otherPlayer in pairs(Players:GetPlayers()) do
                        if otherPlayer ~= player and otherPlayer.Character and otherPlayer.Character:FindFirstChild("Highlight") then
                            otherPlayer.Character.Highlight.OutlineColor = playerHighlightColor
                            otherPlayer.Character.Highlight.FillColor = playerHighlightColor
                        end
                    end
                    colorIndex = (colorIndex % #rainbowColors) + 1
                    task.wait(0.5)
                end
            end)()
        else
            if colorName == "Red" then playerHighlightColor = Color3.new(1, 0, 0)
            elseif colorName == "Blue" then playerHighlightColor = Color3.new(0, 0, 1)
            elseif colorName == "Yellow" then playerHighlightColor = Color3.new(1, 1, 0) end
            for _, otherPlayer in pairs(Players:GetPlayers()) do
                if otherPlayer ~= player and otherPlayer.Character and otherPlayer.Character:FindFirstChild("Highlight") then
                    otherPlayer.Character.Highlight.OutlineColor = playerHighlightColor
                    otherPlayer.Character.Highlight.FillColor = playerHighlightColor
                end
            end
        end
    end

    local function ativarESPPlayer()
        espAtivo = true
        updatePlayerHighlightColor(lastPlayerColor)
        coroutine.wrap(function()
            while espAtivo do
                for _, otherPlayer in pairs(Players:GetPlayers()) do
                    if otherPlayer ~= player and otherPlayer.Character and otherPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        local root = otherPlayer.Character.HumanoidRootPart
                        local playerRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                        if playerRoot then
                            local distance = (playerRoot.Position - root.Position).Magnitude
                            if distance <= 100000 then
                                if not otherPlayer.Character:FindFirstChild("Highlight") then
                                    local highlight = Instance.new("Highlight")
                                    highlight.Adornee = otherPlayer.Character
                                    highlight.OutlineColor = playerHighlightColor
                                    highlight.FillColor = playerHighlightColor
                                    highlight.OutlineTransparency = 0
                                    highlight.FillTransparency = 0.5
                                    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                                    highlight.Parent = otherPlayer.Character
                                end
                            else
                                if otherPlayer.Character:FindFirstChild("Highlight") then
                                    otherPlayer.Character.Highlight:Destroy()
                                end
                            end
                        end
                    end
                end
                task.wait(0.04)
            end
        end)()
    end

    local function desativarESPPlayer()
        espAtivo = false
        playerRainbowLoopRunning = false
        for _, otherPlayer in pairs(Players:GetPlayers()) do
            if otherPlayer ~= player and otherPlayer.Character and otherPlayer.Character:FindFirstChild("Highlight") then
                otherPlayer.Character.Highlight:Destroy()
            end
        end
    end

    local espadaESPAtivo = false
    local espadaHighlight = nil
    local espadaHighlightColor = Color3.new(1, 0, 0)
    local swordRainbowLoopRunning = false
    local lastSwordColor = "Red"

    local function updateHighlightColor(colorName)
        lastSwordColor = colorName
        swordRainbowLoopRunning = false
        if colorName == "Rainbow" then
            swordRainbowLoopRunning = true
            coroutine.wrap(function()
                local colorIndex = 1
                while espadaESPAtivo and swordRainbowLoopRunning do
                    espadaHighlightColor = rainbowColors[colorIndex]
                    if espadaHighlight and espadaHighlight.Adornee then
                        espadaHighlight.OutlineColor = espadaHighlightColor
                        espadaHighlight.FillColor = espadaHighlightColor
                    end
                    colorIndex = (colorIndex % #rainbowColors) + 1
                    task.wait(0.5)
                end
            end)()
        else
            if colorName == "Red" then espadaHighlightColor = Color3.new(1, 0, 0)
            elseif colorName == "Blue" then espadaHighlightColor = Color3.new(0, 0, 1)
            elseif colorName == "Yellow" then espadaHighlightColor = Color3.new(1, 1, 0) end
            if espadaHighlight and espadaHighlight.Adornee then
                espadaHighlight.OutlineColor = espadaHighlightColor
                espadaHighlight.FillColor = espadaHighlightColor
            end
        end
    end

    local function ativarESPEspada()
        espadaESPAtivo = true
        updateHighlightColor(lastSwordColor)
        coroutine.wrap(function()
            while espadaESPAtivo do
                local espada = game.Workspace:FindFirstChild("ClassicSword")
                local playerRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                if espada and playerRoot then
                    local espadaPos = espada:IsA("BasePart") and espada.Position or espada:GetPivot().Position
                    local distance = (playerRoot.Position - espadaPos).Magnitude
                    if distance <= 100000 and not espada:FindFirstChild("Highlight") then
                        espadaHighlight = Instance.new("Highlight")
                        espadaHighlight.Adornee = espada
                        espadaHighlight.OutlineColor = espadaHighlightColor
                        espadaHighlight.FillColor = espadaHighlightColor
                        espadaHighlight.OutlineTransparency = 0
                        espadaHighlight.FillTransparency = 0.8
                        espadaHighlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        espadaHighlight.Parent = espada
                    elseif (distance > 100000 or not espada) and espadaHighlight then
                        espadaHighlight:Destroy()
                        espadaHighlight = nil
                    end
                elseif not espada and espadaHighlight then
                    espadaHighlight:Destroy()
                    espadaHighlight = nil
                end
                task.wait(0.04)
            end
        end)()
    end

    local function desativarESPEspada()
        espadaESPAtivo = false
        swordRainbowLoopRunning = false
        if espadaHighlight then
            espadaHighlight:Destroy()
            espadaHighlight = nil
        end
    end

    EspTab:Section({Title = "Normal (ESP)"})
    EspTab:Toggle({
        Title = "Player",
        Desc = "See players on the map",
        Value = false,
        Callback = function(state)
            if state then ativarESPPlayer() else desativarESPPlayer() end
        end
    })
    EspTab:Dropdown({
        Title = "Color (Player)",
        Desc = "Select the outline color",
        List = {"Red", "Blue", "Yellow", "Rainbow"},
        Value = "Red",
        Callback = function(Value)
            updatePlayerHighlightColor(Value)
        end
    })

    EspTab:Section({Title = "Sword (ESP)"})
    EspTab:Toggle({
        Title = "Sword",
        Desc = "See the sword",
        Value = false,
        Callback = function(state)
            if state then ativarESPEspada() else desativarESPEspada() end
        end
    })
    EspTab:Dropdown({
        Title = "Color (Sword)",
        Desc = "Select the outline color",
        List = {"Red", "Blue", "Yellow", "Rainbow"},
        Value = "Red",
        Callback = function(Value)
            updateHighlightColor(Value)
        end
    })
end

-- Script Tab
local ScriptTab = Window:Tab({Title = "Script", Icon = "code"}) do
    ScriptTab:Section({Title = "FE Admin"})
    ScriptTab:Button({
        Title = "Universal (Infinite Yield) - (FE)",
        Callback = function()
            loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()
        end
    })
    ScriptTab:Button({
        Title = "Universal (Nameless Admin) - (FE)",
        Callback = function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/ltseverydayyou/Nameless-Admin/main/Source.lua"))()
        end
    })
    ScriptTab:Button({
        Title = "Universal (Fly V3) - (FE)",
        Callback = function()
            loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-Gui-Fly-v3-37111"))()
        end
    })

    ScriptTab:Section({Title = "FE Hug"})
    ScriptTab:Button({
        Title = "Universal (Hug) - (FE)",
        Callback = function()
            loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-FE-HUG-R6-23876"))()
        end
    })
end

-- Settings Tab
local SettingsTab = Window:Tab({Title = "Settings", Icon = "cog"}) do
    SettingsTab:Section({Title = "Settings"})
    SettingsTab:Dropdown({
        Title = "Teleport Mode",
        Desc = "Choose the teleport mode",
        List = {"Teleport", "Tween"},
        Value = "Teleport",
        Callback = function(Value)
            getgenv().TeleportMode = Value
        end
    })
    SettingsTab:Slider({
        Title = "Tween Speed",
        Min = 1,
        Max = 350,
        Rounding = 0,
        Value = 100,
        Callback = function(Value)
            getgenv().TweenSpeed = Value
        end
    })

    SettingsTab:Section({Title = "Anti"})
    local AntiVoidEnabled = false
    SettingsTab:Toggle({
        Title = "Anti-Void",
        Value = true,
        Callback = function(Value)
            AntiVoidEnabled = Value
        end
    })

    -- Anti-Void Logic
    RunService.Heartbeat:Connect(function()
        if not AntiVoidEnabled then return end
        local character = player.Character
        if not character then return end
        local root = character:FindFirstChild("HumanoidRootPart")
        if not root then return end
        if root.Position.Y < 20 then
            local bodyVelocity = root:FindFirstChild("AntiVoidVelocity") or Instance.new("BodyVelocity")
            bodyVelocity.Name = "AntiVoidVelocity"
            bodyVelocity.Velocity = Vector3.new(0, 820, 0)
            bodyVelocity.MaxForce = Vector3.new(0, math.huge, 0)
            bodyVelocity.P = 5000
            bodyVelocity.Parent = root
        else
            local antiVoidVelocity = root:FindFirstChild("AntiVoidVelocity")
            if antiVoidVelocity then
                antiVoidVelocity:Destroy()
            end
        end
    end)
end

-- Final Notification
Window:Notify({
    Title = "Souls Hub Loaded",
    Desc = "Script loaded successfully!",
    Time = 4
})
