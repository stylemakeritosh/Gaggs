local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer

-- Loading screen
local blur = Instance.new("BlurEffect", Lighting)
blur.Size = 0
TweenService:Create(blur, TweenInfo.new(0.5), {Size = 24}):Play()

local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
screenGui.Name = "SoulsLoader"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true

local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(1, 0, 1, 0)
frame.BackgroundTransparency = 1

local bg = Instance.new("Frame", frame)
bg.Size = UDim2.new(1, 0, 1, 0)
bg.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
bg.BackgroundTransparency = 1
bg.ZIndex = 0
TweenService:Create(bg, TweenInfo.new(0.5), {BackgroundTransparency = 0.3}):Play()

local word = "SOULS"
local letters = {}

local function tweenOutAndDestroy()
    for _, label in ipairs(letters) do
        TweenService:Create(label, TweenInfo.new(0.3), {TextTransparency = 1, TextSize = 20}):Play()
    end
    TweenService:Create(bg, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
    TweenService:Create(blur, TweenInfo.new(0.5), {Size = 0}):Play()
    wait(0.6)
    screenGui:Destroy()
    blur:Destroy()
end

for i = 1, #word do
    local char = word:sub(i, i)
    local label = Instance.new("TextLabel")
    label.Text = char
    label.Font = Enum.Font.GothamBlack
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextStrokeTransparency = 1
    label.TextTransparency = 1
    label.TextScaled = false
    label.TextSize = 30
    label.Size = UDim2.new(0, 60, 0, 60)
    label.AnchorPoint = Vector2.new(0.5, 0.5)
    label.Position = UDim2.new(0.5, (i - (#word / 2 + 0.5)) * 65, 0.5, 0)
    label.BackgroundTransparency = 1
    label.Parent = frame

    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(100, 170, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(50, 100, 160))
    })
    gradient.Rotation = 90
    gradient.Parent = label

    local tweenIn = TweenService:Create(label, TweenInfo.new(0.3), {TextTransparency = 0, TextSize = 60})
    tweenIn:Play()

    table.insert(letters, label)
    wait(0.25)
end

wait(2)
tweenOutAndDestroy()

-- Wait for game to fully load
repeat task.wait() until game.Players.LocalPlayer and game.Players.LocalPlayer.Character
if not game:IsLoaded() then game.Loaded:Wait() end

-- Load the new UI library
local StellarLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/stylemakeritosh/Gaggs/refs/heads/main/uimain.txt"))()

-- Loading animation with StellarLibrary
if StellarLibrary:LoadAnimation() then
    StellarLibrary:StartLoad()
end
if StellarLibrary:LoadAnimation() then
    StellarLibrary:Loaded()
end

-- Create main window with Souls Hub title
local Window = StellarLibrary:Window({
    Title = "Souls Hub",
    SubTitle = "https://discord.gg/QG5PHd7mVD",
    Size = UDim2.new(0, 520, 0, 400),
    TabWidth = 160
})

-- Create tabs with appropriate icons
local About = Window:Tab("About", "rbxassetid://128891143813807") -- Info icon
local Farm = Window:Tab("Farm", "rbxassetid://10723407389")     -- Star icon
local Dungeon = Window:Tab("Dungeon", "rbxassetid://10723415335") -- Swords icon
local Pets = Window:Tab("Pets", "rbxassetid://10709782497")      -- Egg icon
local Settings = Window:Tab("Settings", "rbxassetid://10734950309") -- Gear icon

-- About Tab
About:Seperator("Welcome")
About:Label("Thank you for using the script! Join the discord if you have problems and suggestions with the script")
About:Seperator("Important")
About:Label("If you found this script requiring a key, it's not the official version. Join our Discord to get the keyless version!")
About:Button("Copy Discord Link", function()
    setclipboard("https://discord.gg/QG5PHd7mVD")
    StellarLibrary:Notify("Successfully copied to the clipboard!", 3)
end)

-- Variables
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoidRootPart = newCharacter:WaitForChild("HumanoidRootPart")
end)

-- Farm variables
local selectedWorld = nil
local selectedEnemy = nil
local currentTarget = nil
local autoFarm = false
local teleported = false
local enemyDropdown = nil
local teleportDelay = 3
local lastTeleportTime = 0
local awaitingArise = false
local postDeathDelay = 1
local deathTime = 0

local RARITY_PRIORITY = {
    Common = 1, Rare = 2, Epic = 3, Legendary = 4,
    Mythical = 5, Mythical2 = 6, Secret = 7, Secret2 = 8
}
local RARITY_VALUES = { "Common", "Rare", "Epic", "Legendary", "Mythical", "Mythical2", "Secret", "Secret2" }
local selectedRarity = "Common"

-- Helper functions
local function getEnemiesFolder(worldName)
    local success, folder = pcall(function()
        return Workspace:WaitForChild("Worlds"):WaitForChild(worldName):WaitForChild("Enemies")
    end)
    if success then return folder end
    return nil
end

local function getEnemyNamesFromWorld(worldName)
    local folder = getEnemiesFolder(worldName)
    if not folder then return {} end
    local unique, added = {}, {}
    for _, enemy in ipairs(folder:GetChildren()) do
        if not added[enemy.Name] then
            table.insert(unique, enemy.Name)
            added[enemy.Name] = true
        end
    end
    return unique
end

local function updateEnemyDropdown(worldName)
    local enemyList = getEnemyNamesFromWorld(worldName)
    enemyDropdown:Clear()
    for _, enemy in ipairs(enemyList) do
        enemyDropdown:Add(enemy)
    end
end

local function isEnemyAlive(enemy)
    return enemy and enemy.Parent and enemy:FindFirstChild("HumanoidRootPart") and enemy:GetAttribute("Health") and enemy:GetAttribute("Health") > 0
end

local function getAllEnemies(folder)
    local result = {}
    if not folder then return result end
    for _, enemy in ipairs(folder:GetChildren()) do
        local meta = enemy:FindFirstChild("Metadata")
        local root = enemy:FindFirstChild("HumanoidRootPart")
        if meta and root and enemy:GetAttribute("Health") and enemy:GetAttribute("Health") > 0 then
            local rarity = meta:FindFirstChild("Rarity") and meta.Rarity:GetAttribute("Value") or "Common"
            local shiny = meta:FindFirstChild("Shiny") and meta.Shiny:GetAttribute("Value") or false
            table.insert(result, {
                Model = enemy,
                Root = root,
                Distance = (humanoidRootPart.Position - root.Position).Magnitude,
                Rarity = rarity,
                RarityLevel = RARITY_PRIORITY[rarity] or 0,
                Shiny = shiny
            })
        end
    end
    return result
end

local function findBestEnemy(enemies)
    local minRarityLevel = RARITY_PRIORITY[selectedRarity] or 1
    local filtered = {}
    for _, e in ipairs(enemies) do
        if e.RarityLevel >= minRarityLevel then
            table.insert(filtered, e)
        end
    end
    table.sort(filtered, function(a, b)
        if a.RarityLevel ~= b.RarityLevel then
            return a.RarityLevel > b.RarityLevel
        elseif a.Shiny ~= b.Shiny then
            return a.Shiny
        else
            return a.Distance < b.Distance
        end
    end)
    return filtered[1]
end

-- Main farm loop
RunService.Heartbeat:Connect(function()
    if autoFarm and selectedWorld then
        local enemiesFolder = getEnemiesFolder(selectedWorld)
        if not enemiesFolder then return end

        if currentTarget and not isEnemyAlive(currentTarget) then
            if not awaitingArise then
                awaitingArise = true
                deathTime = tick()
            elseif tick() - deathTime >= postDeathDelay then
                teleported = false
                currentTarget = nil
                awaitingArise = false
            end
            return
        end

        if not teleported and tick() - lastTeleportTime >= teleportDelay then
            local allEnemies = getAllEnemies(enemiesFolder)
            local target = nil

            if selectedEnemy and selectedEnemy ~= "" then
                for _, e in ipairs(allEnemies) do
                    if e.Model.Name == selectedEnemy then
                        target = e
                        break
                    end
                end
            else
                target = findBestEnemy(allEnemies)
            end

            if target and humanoidRootPart then
                currentTarget = target.Model
                humanoidRootPart.CFrame = target.Root.CFrame * CFrame.new(0, 5, 0)
                teleported = true
                lastTeleportTime = tick()

                pcall(function()
                    local petsFolder = Workspace:FindFirstChild("Pets")
                    if petsFolder then
                        local pet = petsFolder:FindFirstChild("3ZEGAOG-8")
                        if pet then
                            ReplicatedStorage:WaitForChild("Remote"):WaitForChild("Pets"):WaitForChild("SetTarget"):FireServer(pet)
                        end
                    end
                end)
            end
        elseif currentTarget and isEnemyAlive(currentTarget) and humanoidRootPart then
            local distance = (humanoidRootPart.Position - currentTarget.HumanoidRootPart.Position).Magnitude
            if distance > 10 then
                humanoidRootPart.CFrame = currentTarget.HumanoidRootPart.CFrame * CFrame.new(0, 5, 0)
            end

            if currentTarget:GetAttribute("UniqueID") then
                pcall(function()
                    local args = { tostring(currentTarget:GetAttribute("UniqueID")) }
                    ReplicatedStorage:WaitForChild("Remote"):WaitForChild("Orbs"):WaitForChild("AriseOpportunity"):FireServer(unpack(args))
                end)
            end
        end
    end
end)

-- Farm Tab UI
Farm:Seperator("World Selection")
Farm:Dropdown("Select World", {"Solo", "OnePiece", "DemonSlayer", "DBZ"}, nil, function(world)
    selectedWorld = world
    teleported = false
    currentTarget = nil
    updateEnemyDropdown(world)
end)

enemyDropdown = Farm:Dropdown("Select Enemy", {}, nil, function(selected)
    selectedEnemy = selected
    teleported = false
    currentTarget = nil
end)

Farm:Dropdown("Minimum Rarity", RARITY_VALUES, "Common", function(selected)
    selectedRarity = selected
end)

Farm:Seperator("Farm Controls")
Farm:Toggle("Auto Farm", false, "Teleport and attack", function(state)
    autoFarm = state
    teleported = false
    currentTarget = nil
    StellarLibrary:Notify(state and "Auto Farm Enabled" or "Auto Farm Disabled", 2)
end)

Farm:Slider("Teleport Delay", 0.5, 5, 3, function(value)
    teleportDelay = value
end)

Farm:Seperator("Auto Settings")
Farm:Toggle("Auto Attack", false, "Bypass auto attack", function(state)
    pcall(function()
        ReplicatedStorage:WaitForChild("Bindable"):WaitForChild("ValueObjects"):WaitForChild("AutoAttack").Value = state
    end)
    StellarLibrary:Notify(state and "Auto Attack Enabled" or "Auto Attack Disabled", 2)
end)

Farm:Toggle("Auto Arise", true, "Bypass auto arise", function(state)
    pcall(function()
        ReplicatedStorage:WaitForChild("Bindable"):WaitForChild("ValueObjects"):WaitForChild("AutoArise").Value = state
    end)
    StellarLibrary:Notify(state and "Auto Arise Enabled" or "Auto Arise Disabled", 2)
end)

Farm:Toggle("Auto Ability", false, "Bypass auto ability", function(state)
    pcall(function()
        ReplicatedStorage:WaitForChild("Bindable"):WaitForChild("ValueObjects"):WaitForChild("AutoAbility").Value = state
    end)
    StellarLibrary:Notify(state and "Auto Ability Enabled" or "Auto Ability Disabled", 2)
end)

-- Auto dash system
local autoDash = false
local dashLoopRunning = false

pcall(function()
    local Bindable = ReplicatedStorage:WaitForChild("Bindable"):WaitForChild("Player")
    local AttemptDash = Bindable:WaitForChild("AttemptDash")
    local DashRecharging = Bindable:WaitForChild("DashRecharging")
    local SetDashes = Bindable:WaitForChild("SetDashes")
    local UpdateMaxDashes = Bindable:WaitForChild("UpdateMaxDashes")
    
    DashRecharging.Event:Connect(function()
        SetDashes:Fire(999)
    end)
    UpdateMaxDashes:Fire(999)

    Farm:Toggle("Auto Dash", false, nil, function(state)
        autoDash = state
        if autoDash and not dashLoopRunning then
            dashLoopRunning = true
            spawn(function()
                while autoDash do
                    AttemptDash:Fire()
                    task.wait(0.1)
                end
                dashLoopRunning = false
            end)
        end
    end)
end)

-- Pet Hatch Tab
Pets:Seperator("Gacha")
Pets:Label("Gem Requirement: You need at least 7,500 gems to hatch a pet from this banner.")

local autoHatch = false
local bannerName = "PremiumBanner1"

local function hatchOnce()
    pcall(function()
        local args = { bannerName }
        ReplicatedStorage:WaitForChild("Remote"):WaitForChild("Banners"):WaitForChild("PullSingle"):FireServer(unpack(args))
    end)
end

Pets:Button("Hatch 1x", function()
    hatchOnce()
    StellarLibrary:Notify("Attempted to hatch 1x", 2)
end)

Pets:Toggle("Auto Hatch", false, "Keep hatching until turned off", function(state)
    autoHatch = state
    StellarLibrary:Notify(state and "Auto Hatch Enabled" or "Auto Hatch Disabled", 2)
end)

task.spawn(function()
    while true do
        task.wait(2)
        if autoHatch then
            hatchOnce()
        end
    end
end)

Pets:Toggle("Skip Summon Animation", true, "Skip cutscene when hatching", function(state)
    pcall(function()
        local animFlag = ReplicatedStorage:FindFirstChild("Bindable")
            and ReplicatedStorage.Bindable:FindFirstChild("ValueObjects")
            and ReplicatedStorage.Bindable.ValueObjects:FindFirstChild("DoingSummonAnimation")
        if animFlag then
            animFlag.Value = not state
        end
        
        local orbBindable = ReplicatedStorage:FindFirstChild("Bindable")
            and ReplicatedStorage.Bindable:FindFirstChild("Orbs")
        if orbBindable then
            local runCutscene = orbBindable:FindFirstChild("RunOpeningCutscene")
            if runCutscene and runCutscene:IsA("BindableEvent") then
                if state then
                    local dummy = Instance.new("BindableEvent")
                    dummy.Name = "RunOpeningCutscene"
                    dummy.Parent = orbBindable
                    runCutscene:Destroy()
                end
            end
        end
    end)
    StellarLibrary:Notify(state and "Cutscene skipped" or "Cutscene enabled", 2)
end)

-- Pet upgrade system
Pets:Seperator("Upgrade")
Pets:Label("You need upgrade materials or resources to level up your pet slot.")

local autoUpgrade = false
local selectedSlot = 1
local failedCount = 0

Pets:Dropdown("Select Pet Slot", {"1", "2", "3", "4", "5"}, "1", function(value)
    selectedSlot = tonumber(value)
    StellarLibrary:Notify("Auto upgrade will use pet slot: " .. value, 2)
end)

Pets:Toggle("Auto Upgrade", false, "Upgrade selected pet slot", function(state)
    autoUpgrade = state
    failedCount = 0
    StellarLibrary:Notify(state and "Auto upgrade is now active" or "Auto upgrade has been disabled", 2)
end)

task.spawn(function()
    while true do
        task.wait(1)
        if autoUpgrade and selectedSlot then
            local success = pcall(function()
                local args = { selectedSlot }
                ReplicatedStorage:WaitForChild("Remote"):WaitForChild("Pets"):WaitForChild("LevelUpPetSlot"):FireServer(unpack(args))
            end)

            if not success then
                failedCount = failedCount + 1
            else
                failedCount = 0
            end

            if failedCount >= 3 then
                autoUpgrade = false
                StellarLibrary:Notify("Auto upgrade stopped. Possibly not enough resources.", 4)
            end
        end
    end
end)

-- Dungeon Tab
local rankList = {"F", "E", "D", "C", "B", "A", "S"}
local selectedRank = "F"
local autoStartEnabled = false
local autoFarmDungeon = false

local function getDungeonEnemies()
    local folder = Workspace.Worlds:FindFirstChild("Raids")
    local enemies = folder and folder:FindFirstChild("Enemies")
    if not enemies then return {} end

    local result = {}
    for _, enemy in ipairs(enemies:GetChildren()) do
        local meta = enemy:FindFirstChild("Metadata")
        local root = enemy:FindFirstChild("HumanoidRootPart")
        local health = enemy:GetAttribute("Health")
        if meta and root and health and health > 0 then
            local isBoss = meta:FindFirstChild("Boss") and meta.Boss:GetAttribute("Value") or false
            table.insert(result, {
                Model = enemy,
                Root = root,
                IsBoss = isBoss,
                Distance = (humanoidRootPart.Position - root.Position).Magnitude
            })
        end
    end
    return result
end

local function splitEnemies(enemies)
    local regular, boss = {}, nil
    for _, e in ipairs(enemies) do
        if e.IsBoss then boss = e else table.insert(regular, e) end
    end
    table.sort(regular, function(a, b) return a.Distance < b.Distance end)
    return regular, boss
end

local function moveAndAttack(target)
    if not target or not humanoidRootPart then return end
    humanoidRootPart.CFrame = target.Root.CFrame * CFrame.new(0, 0, -5)
    task.wait(0.15)
    pcall(function()
        ReplicatedStorage:WaitForChild("Bindable"):WaitForChild("Enemies"):WaitForChild("LocalDealDamageRaw"):Fire(target.Model)
    end)
end

local function waitUntilDead(enemyModel)
    while enemyModel and enemyModel.Parent and enemyModel:GetAttribute("Health") and enemyModel:GetAttribute("Health") > 0 do
        task.wait(0.1)
    end
end

Dungeon:Seperator("Dungeon Settings")
Dungeon:Dropdown("Select Dungeon Rank", rankList, "F", function(value)
    selectedRank = value
end)

Dungeon:Toggle("Auto Create & Start", false, nil, function(state)
    autoStartEnabled = state
    if autoStartEnabled then
        spawn(function()
            while autoStartEnabled do
                pcall(function()
                    local RemoteRaidLobby = ReplicatedStorage:WaitForChild("Remote"):WaitForChild("Raid"):WaitForChild("Lobby")
                    local CreateLobby = RemoteRaidLobby:WaitForChild("CreateLobby")
                    local StartRaid = RemoteRaidLobby:WaitForChild("StartRaid")
                    local args = {"RaidPortal"}
                    CreateLobby:FireServer(unpack(args))
                    StartRaid:FireServer()
                end)
                task.wait(5)
            end
        end)
    end
end)

Dungeon:Toggle("Auto Farm Dungeon", false, nil, function(state)
    autoFarmDungeon = state
end)

task.spawn(function()
    while true do
        task.wait(0.2)
        if autoFarmDungeon then
            local enemies = getDungeonEnemies()
            local regular, boss = splitEnemies(enemies)

            for _, enemy in ipairs(regular) do
                if not autoFarmDungeon then break end
                moveAndAttack(enemy)
                waitUntilDead(enemy.Model)
            end

            if boss and autoFarmDungeon then
                moveAndAttack(boss)
                waitUntilDead(boss.Model)
            end
        end
    end
end)

-- Infinity Castle section
Dungeon:Seperator("Infinity Castle")
local selectedTower = nil
local autoFarmCastle = false
local towerAliases = {
    ["Castle"] = "Tower",
    ["Fire Tower"] = "Tower_Fire",
    ["Water Tower"] = "Tower_Water",
    ["Earth Tower"] = "Tower_Earth",
    ["Ice Tower"] = "Tower_Ice",
    ["Light Tower"] = "Tower_Light",
    ["Dark Tower"] = "Tower_Dark"
}
local towerDisplayNames = {}
for label, _ in pairs(towerAliases) do
    table.insert(towerDisplayNames, label)
end

Dungeon:Dropdown("Select Tower", towerDisplayNames, "Castle", function(value)
    selectedTower = towerAliases[value]
    StellarLibrary:Notify("Auto raid will start: " .. selectedTower, 2)
end)

Dungeon:Button("Start Selected Tower", function()
    if selectedTower then
        pcall(function()
            ReplicatedStorage:WaitForChild("Remote"):WaitForChild("Raid"):WaitForChild("StartRaidForPlayer"):FireServer(selectedTower)
        end)
        StellarLibrary:Notify("Starting raid: " .. selectedTower, 2)
    else
        StellarLibrary:Notify("Please select a tower first!", 2)
    end
end)

Dungeon:Toggle("AutoFarm Infinity Castle", false, nil, function(state)
    autoFarmCastle = state
    StellarLibrary:Notify(state and "AutoFarm Started" or "AutoFarm Stopped", 2)
end)

task.spawn(function()
    while true do
        task.wait(0.2)
        if autoFarmCastle then
            local enemies = getDungeonEnemies()
            local regular, boss = splitEnemies(enemies)

            for _, enemy in ipairs(regular) do
                if not autoFarmCastle then break end
                moveAndAttack(enemy)
                waitUntilDead(enemy.Model)
            end
            
            if boss and autoFarmCastle then
                moveAndAttack(boss)
                waitUntilDead(boss.Model)
            end
        end
    end
end)

-- Settings Tab (using built-in library settings, add custom if needed)
Settings:Seperator("Script Settings")
Settings:Label("Configure additional settings via the library's settings menu.")

-- Final notifications
StellarLibrary:Notify("Souls Hub", "The script has been loaded.", 3)
task.wait(3)
StellarLibrary:Notify("Souls Hub", "Join the discord for more updates and keyless scripts", 8)