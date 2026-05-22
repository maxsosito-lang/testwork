local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local DataManager = require(ReplicatedStorage:WaitForChild("DataManager"))

local function OnPlayerAdded(player)
    local success = DataManager.Load(player)
    
    if not success then
        player:Kick("Critical data failure. Please reconnect.")
        return
    end
    
    local data = DataManager.Profiles[player.UserId]
    
    local leaderstats = Instance.new("Folder")
    leaderstats.Name = "leaderstats"
    leaderstats.Parent = player
    
    local gold = Instance.new("IntValue")
    gold.Name = "Gold"
    gold.Value = data.Gold
    gold.Parent = leaderstats
    
    local level = Instance.new("IntValue")
    level.Name = "Level"
    level.Value = data.Level
    level.Parent = leaderstats

    gold.Changed:Connect(function(newValue)
        data.Gold = newValue
    end)
    
    level.Changed:Connect(function(newValue)
        data.Level = newValue
    end)
end

local function OnPlayerRemoving(player)
    DataManager.Save(player)
end

Players.PlayerAdded:Connect(OnPlayerAdded)
Players.PlayerRemoving:Connect(OnPlayerRemoving)

game:BindToClose(function()
    for _, player in ipairs(Players:GetPlayers()) do
        task.spawn(function()
            DataManager.Save(player)
        end)
    end
    
    if not RunService:IsStudio() then
        local start = os.clock()
        while #Players:GetPlayers() > 0 and os.clock() - start < 20 do
            task.wait(1)
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(300)
        for _, player in ipairs(Players:GetPlayers()) do
            DataManager.Save(player)
        end
    end
end)