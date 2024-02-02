
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
    end
end

function PlayerState:modifyNeeds(foodDelta, waterDelta)
    self.state.food = math.max(0, math.min(100, self.state.food + foodDelta))
    self.state.water = math.max(0, math.min(100, self.state.water + waterDelta))
end


function HandleResourceStart()
    if  GetResourceState('ND_Core') == 'started' then
        print("ND_Core bridge loaded, thanks for downloading")
        AddEventHandler("ND:characterLoaded", function(character)
            playerLoaded = true
        end)
    elseif GetResourceState('es_extended') == 'started'then
        RegisterNetEvent('esx:playerLoaded')
        AddEventHandler('esx:playerLoaded', function()
            playerLoaded = true
        end)
        print("ESX bridge loaded, thanks for downloading")
    elseif resourceName == "ox_core" then
        AddEventHandler('ox:playerLoaded', function(source, userid, charid) 
            playerLoaded = true
        end)
        print("ox_core bridge loaded, thanks for downloading")
    elseif resourceName == "qb-core" then
        return
    else
        print('add custom core')
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
        Wait(Config.TickRate * 60000)
        updateAllPlayersFoodWater()
    end
end)
