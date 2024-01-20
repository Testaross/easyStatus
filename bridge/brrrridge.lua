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
    if name == 'food' or 'hunger' then
        local amount = playerState.food
		return amount
    elseif name == 'water' or 'thirst' then
        local amount = playerState.water
		return amount
    else
		--''do wahtever''
    end
end)




RegisterCommand('check1', function()
    local food = TriggerEvent('esx_status:getStatus', food)
    TriggerEvent('esx_status:getStatus', 'hunger', function(status)
        if status then 
            print(status) 
        end
    end)
end, false)