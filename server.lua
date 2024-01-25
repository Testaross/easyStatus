
local debugMode = true -- Set to false to disable debugging

-- Debug function
local function debugPrint(...)
    if debugMode then
        local args = {...}
        for _, arg in ipairs(args) do
            print(json.encode(arg, {indent = true})) -- Adjust indent as needed
        end
    end
end

local players = {}
local playerLoaded = false

local PlayerState = {}
PlayerState.__index = PlayerState

function PlayerState.new(playerId)
    if players[playerId] then
        return players[playerId]
    end

    local self = setmetatable({}, PlayerState)
    self.id = playerId
    self.state = {
        food = 100,
        water = 100
    }
    players[playerId] = self 
    debugPrint({action = "New PlayerState Created", playerId = playerId, state = self.state})
    return self
end

function PlayerState:updateFoodWater()
    self.state.food = math.max(0, math.min(100, self.state.food - Config.FoodDecreaseAmount))
    self.state.water = math.max(0, math.min(100, self.state.water - Config.WaterDecreaseAmount))
    debugPrint({
        action = "Update Food & Water", 
        playerId = self.id, 
        oldState = oldState, 
        newState = self.state
    })
    if self.state.food == 0 or self.state.water == 0 then
        TriggerClientEvent('HealthTick', self.id)
        debugPrint({action = "Trigger HealthTick Event", playerId = self.id})
    end
end

function PlayerState:modifyNeeds(foodDelta, waterDelta)
    self.state.food = math.max(0, math.min(100, self.state.food + foodDelta))
    self.state.water = math.max(0, math.min(100, self.state.water + waterDelta))
    debugPrint({
        action = "Modify Needs", 
        playerId = self.id, 
        foodDelta = foodDelta, 
        waterDelta = waterDelta, 
        oldState = oldState, 
        newState = self.state
    })
end


local function handleResourceStart(resourceName)
    debugPrint({action = "Handling Resource Start", resourceName = resourceName})

    if GetResourceState('ND_Core') == 'started' then
        debugPrint({message = "ND_Core bridge loaded, thanks for downloading"})
        playerLoaded = true
        AddEventHandler("ND:characterLoaded", function(character)
            debugPrint({message = "ND_Core character loaded", playerLoaded = playerLoaded})
        end)
    elseif GetResourceState('es_extended') == 'started' then
        debugPrint({message = "es_extended bridge loaded, thanks for downloading"})
        playerLoaded = true
        AddEventHandler('esx:playerLoaded', function()
            debugPrint({message = "esx player loaded", playerLoaded = playerLoaded})
        end)
    elseif resourceName == "ox_core" then
        debugPrint({message = "ox_core detected"})
        playerLoaded = true
        AddEventHandler('ox:playerLoaded', function(source, userid, charid) 
            debugPrint({message = "ox_core player loaded", playerLoaded = playerLoaded})
        end)
    elseif resourceName == "qb-core" then
        debugPrint({message = "qb-core detected, no action taken"})
    else
        debugPrint({message = 'Custom core detected, add player loaded event'})
        --add player loaded event
    end
end

AddEventHandler("onResourceStart", function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then return end
    Wait(1000)
    handleResourceStart(resourceName)
end)

RegisterServerEvent('statusLoad')
AddEventHandler('statusLoad', function()
    local player = PlayerState.new(source)
    player:updateFoodWater()
    debugPrint({action = "Status Load Event", playerId = source})
end)

function updateAllPlayersFoodWater()
    if not playerLoaded then return end
    local allPlayers = GetPlayers()
    for _, playerId in ipairs(allPlayers) do
        local player = PlayerState.new(tonumber(playerId))
        player:updateFoodWater()
    end
end


RegisterServerEvent('ModifyNeeds')
AddEventHandler('ModifyNeeds', function(foodDelta, waterDelta)
    local player = PlayerState.new(source)
    player:modifyNeeds(foodDelta, waterDelta)
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        updateAllPlayersFoodWater()
    end
end)
