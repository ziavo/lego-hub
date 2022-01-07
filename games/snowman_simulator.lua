--[[
    dont mind the retarded way i coded this ui :P
--]]

local start_time = os.clock()

local client = game.Players.LocalPlayer
local playerGui = client.PlayerGui

local runService = game:GetService("RunService")
local httpService = game:GetService("HttpService")
local replicatedStorage = game:GetService("ReplicatedStorage")

local info_folder = client.info
local signals_folder = replicatedStorage.Signals

local candycanes_folder = workspace.gameCandyCanes
local sellspots_folder = workspace.sellSpots
local bases_folder = workspace.snowmanBases
local gifts_folder = workspace.giftSpawns
local player_base
---------------------------------------------------------------
local function return_base(target)
    for i,v in pairs(bases_folder:GetChildren()) do
        if v.player.Value == target then
            return v
        end
    end
    return nil
end
local function return_snow_amount()
    local amount = string.split(playerGui.Main.hudItems.snowballs.textFrame.TextLabel.Text, "/")
    local current_amount = string.gsub(amount[1], ",", "")
    local max_amount = string.gsub(amount[2], ",", "")

    return current_amount, max_amount
end

local function fireproximityprompt(Obj, Amount, Skip)
    if Obj.ClassName == "ProximityPrompt" then 
        Amount = Amount or 1
        local PromptTime = Obj.HoldDuration
        if Skip then 
            Obj.HoldDuration = 0
        end
        for i = 1, Amount do 
            Obj:InputHoldBegin()
            if not Skip then 
                wait(Obj.HoldDuration)
            end
            Obj:InputHoldEnd()
        end

        Obj.HoldDuration = PromptTime
    else 
        error("userdata<ProximityPrompt> expected")
    end
end
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
local settings = {
    ["gift_in_use"] = false,
}
local function auto_roll()
    if not info_folder.snowmanBall.Value then
        signals_folder.snowballController:FireServer("startRoll")
    end
    if info_folder.snowmanBallSize.Value <= 20 then
        signals_folder.collectSnow:FireServer()
    else
        if info_folder.snowmanBall.Value then
            signals_folder.snowballControllerFunc:InvokeServer("stopRoll")
        end
    end
end
local function auto_snowman()
    local amount, max_amount = return_snow_amount()
    if amount == nil then return end

    if tonumber(amount) >= tonumber(max_amount)/2 then
        if not player_base.addingToSnowman.Value then
            signals_folder.addToSnowman:FireServer("addToSnowman")
        end
    end
end
local function auto_rebirth()
    if player_base then
        if player_base.rebirthControl:FindFirstChild("BUTTON"):FindFirstChild("outerButton").Color == Color3.fromRGB(75, 151, 75) then
            --if not player_base.rebirthActive.Value then
                signals_folder.snowmanEvent:FireServer("acceptRebirth", player_base, true)
            --end
        end
    end
end
local function auto_gift()
    if settings.gift_in_use then return end

    settings.gift_in_use = true
    local gift = gifts_folder:GetChildren()[1]
    if gift then
        client.Character:MoveTo(gift.hitbox.Position)
        task.wait(.2)
        fireproximityprompt(gift.hitbox.proxGui.ProximityPrompt, 1)
        repeat wait() until gift.hitbox:FindFirstChild("presentExplode1") or gift.hitbox:FindFirstChild("presentExplode2")
    end
    settings.gift_in_use = false
end
local function auto_cane()
    if not client.Character then return end
    for i,v in pairs(candycanes_folder:GetChildren()) do
        client.character:MoveTo(v.cane.Position)
        --repeat wait() until v.cane.collect.Enabled == true
        --client.Character.PrimaryPart.Position = v.cane.Position
        task.wait(.15)
    end
end

shared._ids = {}
local function bind_render(name, callback)
    if shared._ids then
        if shared._ids[name] and not shared.impulse[name] then
            pcall(runService.UnbindFromRenderStep, runService, shared._ids[name])
            shared._ids[name] = nil
            return
        end

        if not shared.impulse[name] then return end
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
    main = library:CreateWindow("Impulse | v0.03"),
}
local tabs = {
    features = windows.main:AddTab("Features"),
    killswitch = windows.main:AddTab("Kill Switch"),
}
local sections = {
    auto = tabs.features:AddLeftGroupbox("Auto"),
    scripts = tabs.features:AddRightGroupbox("Scripts"),
}
shared.impulse = {
    ["features"] = {
        ["auto_cane"] = false,
        ["auto_gift"] = false,
        ["auto_roll"] = false,
        ["auto_sell"] = false,
        ["auto_rebirth"] = false,
    }
}
---------------------------------------------------------------
player_base = return_base(client)
task.spawn(function() -- auto section
    sections.auto:AddToggle("AutoRoll", {Text = "Auto Roll", Default = false,}):OnChanged(function()
        shared.impulse.auto_roll = Toggles.AutoRoll.Value

        bind_render("auto_roll", auto_roll)
    end)
    sections.auto:AddToggle("AutoSell", {Text = "Auto Sell", Default = false,}):OnChanged(function()
        shared.impulse.auto_sell = Toggles.AutoSell.Value

        bind_render("auto_sell", auto_snowman)
    end)
    sections.auto:AddToggle("AutoRebirth", {Text = "Auto Rebirth", Default = false,}):OnChanged(function()
        shared.impulse.auto_rebirth = Toggles.AutoRebirth.Value

        bind_render("auto_rebirth", auto_rebirth)
    end)
    sections.auto:AddToggle("AutoGift", {Text = "Auto Gift Open", Default = false,}):OnChanged(function()
        shared.impulse.auto_gift = Toggles.AutoGift.Value

        bind_render("auto_gift", auto_gift)
    end)

    sections.scripts:AddButton("Sell All CandyCanes", function()
        signals_folder.candycaneSell:FireServer("sellCandycanes", 1, sellspots_folder.redB.Nutcracker)
        signals_folder.candycaneSell:FireServer("sellCandycanes", 2, sellspots_folder.greenB.Nutcracker)
        signals_folder.candycaneSell:FireServer("sellCandycanes", 3, sellspots_folder.goldB.Nutcracker)
    end)
end)

library:Notify(math.floor((os.clock() - start_time) * 1000) .. "ms to initialize!")
library:Notify("press right ctrl to open/close!")