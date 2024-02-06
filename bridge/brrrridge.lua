 local playerState = LocalPlayer.state

--esx

RegisterNetEvent('esx_status:add')
AddEventHandler('esx_status:add', function(name, val)
    local amount = val / 1000
    if name == 'food' or 'hunger' then
        statusUpdate( amount, 0)
    elseif name == 'water' or 'thirst' then
        statusUpdate( 0, amount)
    else
        lib.notify({ title = 'error', 
            description = "Status Undefined", 
            type = 'error', 
            duration = 5000, 
        })
    end      
end)

RegisterNetEvent('esx_status:remove')
AddEventHandler('esx_status:remove', function(name, val)
    local amount = val / 1000
    if name == 'food' or 'hunger' then
        statusUpdate( amount , 0)
    elseif name == 'water' or 'thirst' then
        statusUpdate( 0, amount)
    else
        lib.notify({ title = 'error', 
            description = "Status Undefined", 
            type = 'error', 
            duration = 5000, 
        })
    end
end)

AddEventHandler('esx_status:getStatus', function(name, cb)
    local food = playerState.needs.hunger
    local water = playerState.need.water
    if name == 'food' or 'hunger' then
        cb(food)
		return 
    elseif name == 'water' or 'thirst' then
        cb(water)
		return 
    else
		--''do wahtever''
    end
end)


RegisterCommand('check1', function()
    TriggerEvent('esx_status:getStatus', 'hunger', function(status)
        if status then 
            print(status) 
        end
    end)
end, false)

-- AddStateBagChangeHandler('needs', GetPlayerServerId(PlayerPedId()), function(bagName, key, value)

--     -- Print the updated thirst value
--     print("Updated Thirst: " .. value.thirst)
--     print("Updated hugner: " .. value.hunger)
--     -- Send a message to update item.thirst

--     SendNUIMessage({
--         type = "updateInfo",
--         thirst = value.thirst,
--         hunger = value.hunger
--     })
-- end)
