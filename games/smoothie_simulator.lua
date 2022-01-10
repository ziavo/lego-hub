local start_time = os.clock()

local client = game.Players.LocalPlayer
local playerGui = client.PlayerGui

local runService = game:GetService("RunService")
local httpService = game:GetService("HttpService")
local replicatedStorage = game:GetService("ReplicatedStorage")

local events_folder = replicatedStorage.Events
local gameplay_folder = events_folder.Gameplay

local plots_folder = workspace.Plots
local debris_folder = workspace.Debris
local fruits_folder = debris_folder.Fruit
local player_base
---------------------------------------------------------------
-- Unloads Old Shit
if shared._unload then
    pcall(shared._unload)
end

function shared._unload()
    if shared.impulse then
        shared.impulse = nil
    end
    if shared._ids then
        for i,v in pairs(shared._ids) do
            pcall(runService.UnbindFromRenderStep, runService, v)
        end
    end
    for i,v in pairs(game.CoreGui:GetChildren()) do
        if v.Name == "ScreenGui" then v:Destroy() end
    end
end
---------------------------------------------------------------
local function return_base(target)
    for i,v in pairs(plots_folder:GetChildren()) do
        if v.Info.Owner.Value == client then return v end
    end
end

local function add_to_blender()
    for i,v in pairs(player_base.Blenders:GetChildren()) do
        gameplay_folder.AddFruitToBlender:FireServer()
    end
end
local function auto_grab()
    for i,v in pairs(fruits_folder:GetChildren()) do
        if v.Plot.Value == player_base then
            gameplay_folder.GrabFruit:FireServer(v)
        end
    end
end

shared._ids = {}
local function bind_render(name, callback)
    if shared._ids then
        if shared._ids[name] and not shared.impulse.features[name] then
            pcall(runService.UnbindFromRenderStep, runService, shared._ids[name])
            shared._ids[name] = nil
            return
        end

        if not shared.impulse.features[name] then return end
        shared._ids[name] = httpService:GenerateGUID(false)
        runService:BindToRenderStep(shared._ids[name], 1, callback)
    end
end
---------------------------------------------------------------
-- UI Lib
local library = loadstring(game:HttpGet('https://lindseyhost.com/UI/LinoriaLib.lua'))()

local fonts = {}
for font, _ in next, Drawing.Fonts do
    table.insert(fonts, font)
end;
local windows = {
    main = library:CreateWindow("Impulse | v0.01"),
}
local tabs = {
    features = windows.main:AddTab("Features"),
    killswitch = windows.main:AddTab("Kill Switch"),
}
local sections = {
    auto = tabs.features:AddLeftGroupbox("Auto"),
}
local feature_names = {
    ["auto_grab"] = "Auto Grab Fruits"
}

shared.impulse = {
    ["features"] = {
        ["auto_grab"] = false
    }
}
---------------------------------------------------------------
player_base = return_base(client)
task.spawn(function() -- auto selection
    sections.auto:AddToggle("AutoGrab", {Text = "Auto Grab Fruits", Default = false}):OnChanged(function()
        shared.impulse.features.auto_grab = Toggles.AutoGrab.Value
    
        bind_render("auto_grab", auto_grab)
    end)
end)

library:Notify(math.floor((os.clock() - start_time) * 1000) .. "ms to initialize!")
library:Notify("press right ctrl to open/close!")