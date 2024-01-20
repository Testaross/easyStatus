local players = {}
local playerLoaded = false


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
        print("ox_core bridge loaded, thanks for downloading")
    elseif resourceName == "ox_core" then
        AddEventHandler('ox:playerLoaded', function(source, userid, charid) 
            playerLoaded = true
        end)
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
    HandleResourceStart()
end)


RegisterServerEvent('statusLoad')
AddEventHandler("statusLoad", function()
    Player(source).state.food = 100
    Player(source).state.water = 100
end)

function updateFoodWater()
    local players = GetPlayers()
    if playerLoaded == nil then return end
    for i=1, #players do
        local playerId = players[i]
        local plyState = Player(playerId).state
        local food = plyState.food
        local water = plyState.water
        plyState.food = math.max(0, math.min(100, food - Config.FoodDecreaseAmount))
        plyState.water = math.max(0, math.min(100, water - Config.WaterDecreaseAmount))
        if Player(playerId).state.food == 0 or Player(playerId).state.water == 0 then
            TriggerClientEvent('HealthTick', playerId)
        end
    end
end

RegisterServerEvent('ModifyNeeds')
AddEventHandler("ModifyNeeds", function( foodDelta, waterDelta)
    local food = Player(source).state.food
    local water = Player(source).state.water
    local plyState = Player(source).state
    plyState.food = math.max(0, math.min(100, food + foodDelta ))
    plyState.water = math.max(0, math.min(100, water + waterDelta ))
 
end)



local function foodWaterLoop()
    while true do
        Wait(Config.TickRate * 60000)
        updateFoodWater()
    end
end

foodWaterLoop()




