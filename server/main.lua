local VehicleKeys = {}
local VehicleLockpicked = {}

RegisterServerEvent('xd_locksystem:setVehicleKey', function(plate, remove)
    if not plate then return end
    local playerId = source
    
    if remove then
        VehicleKeys[plate] = nil
        return
    end

    if not playerId then return end

    local identifier = false
    if not Config.Framework then
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
end)

RegisterServerEvent('xd_locksystem:getVehicleData', function(plate)
    local playerId = source
    if not playerId then return end

    local identifier = false
    if not Config.Framework then
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
    
    TriggerClientEvent('xd_locksystem:getVehicleData', playerId, json.encode(callback))
end)

RegisterServerEvent('xd_locksystem:PlaySound.server', function(name, entity)
    TriggerClientEvent('xd_locksystem:PlaySound', -1, name, entity)
end)

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
RegisterCommand('shuffle', function(source)
    TriggerClientEvent('xd_locksystem:shuffle', source)
end)