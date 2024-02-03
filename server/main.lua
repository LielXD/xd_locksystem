local VehicleKeys = {}
local VehicleLockpicked = {}

RegisterServerEvent('xd_locksystem:setVehicleKey', function(plate, remove)
    if not plate or not source then return end
    
    if remove then
        VehicleKeys[plate] = nil
        return
    end

    SetVehicleKey(plate, source)
end)

RegisterServerEvent('xd_locksystem:getVehicleData', function(plate)
    if not plate or not tonumber(source) then return end
    
    local callback = GetVehicleData(plate, source)
    TriggerClientEvent('xd_locksystem:getVehicleData', source, json.encode(callback))
end)

RegisterServerEvent('xd_locksystem:PlaySound.server', function(name, entity)
    TriggerClientEvent('xd_locksystem:PlaySound', -1, name, entity)
end)

function SetVehicleKey(plate, playerId)
    if not plate then return end

    if not tonumber(playerId) then
        VehicleKeys[plate] = nil
    end

    local identifier = false
    if not Config.Framework or Config.Framework == true then
        identifier = GetPlayerIdentifier(playerId, 0)
    elseif string.lower(Config.Framework) == 'xd' then
        local player = XD.getPlayer(playerId)
        identifier = player.getIdentifier()
    elseif string.lower(Config.Framework) == 'esx' then
        local xPlayer = ESX.GetPlayerFromId(playerId)
        identifier = xPlayer.getIdentifier()
    elseif string.lower(Config.Framework) == 'qbcore' then
        identifier = QBCore.Functions.GetIdentifier(playerId)
    end

    VehicleKeys[plate] = identifier
end

function GetVehicleData(plate, playerId)
    if not plate or not tonumber(playerId) then return end

    local identifier = false
    if not Config.Framework or Config.Framework == true then
        identifier = GetPlayerIdentifier(playerId, 0)
    elseif string.lower(Config.Framework) == 'xd' then
        local player = XD.getPlayer(playerId)
        identifier = player.getIdentifier()
    elseif string.lower(Config.Framework) == 'esx' then
        local xPlayer = ESX.GetPlayerFromId(playerId)
        identifier = xPlayer.getIdentifier()
    elseif string.lower(Config.Framework) == 'qbcore' then
        identifier = QBCore.Functions.GetIdentifier(playerId)
    end
    
    local callback = {}
    callback.keys = false

    if VehicleKeys[plate] then
        callback.keys = true

        if VehicleKeys[plate] == identifier then
            callback.keys = 'self'
        end
    end

    callback.lockpick = false
    if VehicleLockpicked[plate] then
        callback.lockpick = VehicleLockpicked[plate]
    end

    return callback
end

--[[
    Lockpick
]]--
RegisterServerEvent('xd_locksystem:setVehicleLockpicked', function(plate, remove)
    if remove == true then
        VehicleLockpicked[plate] = nil
        return
    elseif remove == 'NPC' then
        VehicleLockpicked[plate] = 'NPC'
        return
    end

    VehicleLockpicked[plate] = true
end)

--[[
    Indicator
]]--
RegisterServerEvent('xd_locksystem:indicator', function(vehicleNetId)
    TriggerClientEvent('xd_locksystem:indicator.blink', -1, vehicleNetId)
end)

--[[
    Commands
]]--
-- shuffle
RegisterCommand('shuffle', function(source)
    TriggerClientEvent('xd_locksystem:shuffle', source)
end)

-- givekey
RegisterCommand('givekey', function(source, args)
    local targetId = false

    if not args[1] then
        local players = GetPlayers()
        local closestPlayer, distLast = false, false
        
        for _, playerId in ipairs(players) do
            if tonumber(playerId) ~= tonumber(source) then
                local playerPed = GetPlayerPed(playerId)
                local dist = #(GetEntityCoords(GetPlayerPed(source)) - GetEntityCoords(playerPed))
                
                if dist < Config.Distance.Givekey then
                    if not closestPlayer or distLast > dist then
                        closestPlayer = playerId
                        distLast = dist
                    end
                end
            end
        end
        
        targetId = closestPlayer
    else
        if not tonumber(args[1]) then return end
        
        local playerId = tonumber(args[1])
        if playerId == source then
            TriggerClientEvent('xd_locksystem:givekey.notify', source, Config.Translate['givekey_no_self'], 'error')
            return
        end

        if not GetPlayerPed(playerId) or GetPlayerPed(playerId) == 0 then
            TriggerClientEvent('xd_locksystem:givekey.notify', source, Config.Translate['givekey_no_player'], 'error')
            return
        end

        targetId = playerId
    end

    if not targetId then
        TriggerClientEvent('xd_locksystem:givekey.notify', source, Config.Translate['givekey_no_player'], 'error')
        return
    end
    
    TriggerClientEvent('xd_locksystem:givekey', source, targetId)
end)

RegisterServerEvent('xd_locksystem:givekey', function(plate, target)
    SetVehicleKey(plate, tonumber(target))
end)
