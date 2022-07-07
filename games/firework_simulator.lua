local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()
local Windows = {
    Main = OrionLib:MakeWindow({
        Name = "Firework Sim",
        HidePremium = false,
        SaveConfig = false,
        ConfigFolder = nil,
    })
}
local Tabs = {
    scriptsTab =  Windows.Main:MakeTab({
        Name = "Scripts",
        Icon = "rbxassetid://7733770982",
        PremiumOnly = false,
    }),
    shopsTab = Windows.Main:MakeTab({
        Name = "Shops",
        Icon = "rbxassetid://7734056813",
        PremiumOnly = false,
    }),
}

local runService = game:GetService("RunService")

local client = game.Players.LocalPlayer

-- Orion Lib
do
    -- scriptsTab
    do
        Tabs.scriptsTab:AddSlider({
            Name = "Apply Money",
            Min = 1,
            Max = 1000000000000000000,
            Default = 1000000000000000000,
            Color = Color3.fromRGB(255, 255, 255),
            Increment = 1000,
            ValueName = "Money",
            Callback = function(v) workspace.AddMoneyD:FireServer(v) end
        })
        Tabs.scriptsTab:AddSlider({
            Name = "Spawn Amount [Wood Rock]",
            Min = 1,
            Max = 1000,
            Default = 300,
            Color = Color3.fromRGB(255, 255, 255),
            Increment = 5,
            ValueName = "Spawn Amount",
            Callback = function(v) OrionLib.Flags["spawnAmount"] = v end
        })
        Tabs.scriptsTab:AddButton({
            Name = "Spawn [Wood Rock][AUTODROPS]",
            Callback = function()
                for i = 1, OrionLib.Flags["spawnAmount"] do
                    client.PlayerGui.Islands.Money.RemoteEvent:FireServer(12)
                    task.wait(.02)
                end
                task.wait()
                client.Backpack.Lighter.Parent = client.Character
                for i,v in pairs(client.Backpack:GetChildren()) do
                    if v:IsA("Tool") then
                        v.Parent = client.Character
                        task.wait(.2)
                        v.Mouse:FireServer("Create")
                    end
                end
            end,
        })
        Tabs.scriptsTab:AddButton({
            Name = "Drop All",
            Callback = function()
                task.wait()
                client.Backpack.Lighter.Parent = client.Character
                for i,v in pairs(client.Backpack:GetChildren()) do
                    if v:IsA("Tool") then
                        v.Parent = client.Character
                        task.wait(.2)
                        v.Mouse:FireServer("Create")
                    end
                end
            end,
        })
    end

    -- shopsTab
    do
        Tabs.shopsTab:AddDropdown({
            Name = "Open Shop",
            -- Default = "ShopVolcano",
            Options = {"ShopVolcano", "ShopWinter", "ShopForest", "ShopMonkey", "ShopBeach", "StrangeMan"},
            Callback = function(Value)
                client.PlayerGui[Value].Enabled = true
            end    
        })
    end
    OrionLib:Init()
    -- table.foreach(OrionLib, print)
end
