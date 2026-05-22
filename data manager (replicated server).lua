local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")

local DATA_STORE_NAME = "Production_Data"
local DATABASE = DataStoreService:GetDataStore(DATA_STORE_NAME)

local DataManager = {}
DataManager.Profiles = {}

local TEMPLATE = {
    Level = 1,
    Experience = 0,
    Gold = 250,
    Inventory = {"Starter_Kit"},
    Stats = {
        Strength = 1,
        Agility = 1
    }
}

local function Reconcile(target, template)
    for key, value in pairs(template) do
        if type(value) == "table" then
            if type(target[key]) ~= "table" then
                target[key] = {}
            end
            Reconcile(target[key], value)
        elseif target[key] == nil then
            target[key] = value
        end
    end
end

function DataManager.Load(player)
    local userId = player.UserId
    local key = "UID_" .. userId
    
    local success, result = pcall(function()
        return DATABASE:GetAsync(key)
    end)

    if success then
        local data = result or {}
        Reconcile(data, TEMPLATE)
        DataManager.Profiles[userId] = data
        return true
    end
    
    return false
end

function DataManager.Save(player)
    local userId = player.UserId
    local data = DataManager.Profiles[userId]
    
    if not data then return end
    
    local key = "UID_" .. userId
    local success, err = pcall(function()
        DATABASE:UpdateAsync(key, function(oldData)
            return data
        end)
    end)
    
    DataManager.Profiles[userId] = nil
end

return DataManager