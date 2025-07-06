-- open source
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Load UI Library (same as towerwallhop.lua)
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/x2zu/OPEN-SOURCE-UI-ROBLOX/refs/heads/main/X2ZU%20UI%20ROBLOX%20OPEN%20SOURCE/DummyUi-leak-by-x2zu/fetching-main/Tools/Framework.luau"))()

-- Create Main Window
local Window = Library:Window({
    Title = "Souls Hub | Ink Game Helper",
    Desc = "by rintoshiii",
    Icon = "hand-holding-heart",
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

-- Main Tab
local MainTab = Window:Tab({Title = "Main", Icon = "home"}) do
    MainTab:Section({Title = "Player Helper"})

    local polygon = {
        Vector2.new(-52, -515),
        Vector2.new(115, -515),
        Vector2.new(115, 84),
        Vector2.new(-216, 84)
    }

    local function isPointInPolygon(point, poly)
        local inside = false
        local j = #poly
        for i = 1, #poly do
            local xi, zi = poly[i].X, poly[i].Y
            local xj, zj = poly[j].X, poly[j].Y
            if ((zi > point.Y) ~= (zj > point.Y)) and
                (point.X < (xj - xi) * (point.Y - zi) / (zj - zi + 1e-9) + xi) then
                inside = not inside
            end
            j = i
        end
        return inside
    end

    local function tpTo(cf)
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.CFrame = cf
        end
    end

    local function fireProximityPrompt(prompt)
        if fireproximityprompt then
            fireproximityprompt(prompt)
        end
    end

    local function helpPlayer()
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                local liveChar = workspace:FindFirstChild("Live") and workspace.Live:FindFirstChild(player.Name)
                local hrp = liveChar and liveChar:FindFirstChild("HumanoidRootPart")

                if hrp then
                    local posXZ = Vector2.new(hrp.Position.X, hrp.Position.Z)
                    if isPointInPolygon(posXZ, polygon) then
                        local prompt = hrp:FindFirstChild("CarryPrompt")

                        if prompt and prompt:IsA("ProximityPrompt") and prompt.Enabled then
                            Window:Notify({
                                Title = "Helping Player",
                                Desc = "Helping: " .. player.Name,
                                Time = 2
                            })
                            tpTo(hrp.CFrame + Vector3.new(0, 2, 0))
                            task.wait(0.4)
                            fireProximityPrompt(prompt)
                            task.wait(0.7)
                            tpTo(CFrame.new(-46, 1024, 110))
                            Window:Notify({
                                Title = "Help Complete",
                                Desc = "Done: " .. player.Name,
                                Time = 2
                            })
                            task.wait(0.6)
                            return true
                        end
                    end
                end
            end
        end
        Window:Notify({
            Title = "No Players",
            Desc = "No one to help",
            Time = 2
        })
        return false
    end

    MainTab:Button({
        Title = "Help Player",
        Desc = "Help a player in need",
        Callback = function()
            helpPlayer()
        end
    })

    local autoHelpLoop
    MainTab:Toggle({
        Title = "Auto Help",
        Desc = "Automatically help players in need",
        Value = false,
        Callback = function(state)
            if state then
                autoHelpLoop = RunService.Heartbeat:Connect(function()
                    helpPlayer()
                    task.wait(5) -- Delay to prevent spamming
                end)
            else
                if autoHelpLoop then
                    autoHelpLoop:Disconnect()
                    autoHelpLoop = nil
                end
            end
        end
    })
end

-- Info Tab
local InfoTab = Window:Tab({Title = "Info", Icon = "info-circle"}) do
    InfoTab:Section({Title = "Info"})
    InfoTab:Label({Title = "Ink Game Helper" .. LocalPlayer.Name, Desc = "Thanks for using ink game helper"})

    InfoTab:Section({Title = "Creator"})
    InfoTab:Label({Title = "Made by rintoshiii", Desc = "Souls Hub"})

    InfoTab:Section({Title = "Links (Socials)"})
    InfoTab:Button({
        Title = "Copy Creator Discord",
        Callback = function()
            setclipboard("@rintoshiii")
        end
    })
end

-- Final Notification
Window:Notify({
    Title = "Ink Game Helper Loaded",
    Desc = "Script loaded successfully!",
    Time = 4
})