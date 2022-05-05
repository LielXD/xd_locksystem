-- XD_Locksystem | Creator: LielXD --

local vehicles = {}
local searchedVehicles = {}

RegisterServerEvent('xd_locksystem:check')
AddEventHandler('xd_locksystem:check', function(plate)
	local xPlayer = ESX.GetPlayerFromId(source)
	local hasKey, hasSearched = false, false
	
	for k, v in pairs(vehicles) do
		if k == xPlayer.getIdentifier() then
			for i=1, #v, 1 do
				if string.lower(v[i]) == string.lower(plate) then
					hasKey = true
					break
				end
			end
		end
	end
	
	for k, v in pairs(searchedVehicles) do
		if string.lower(v) == string.lower(plate) then
			hasSearched = true
			break
		end
	end
	
	TriggerClientEvent('xd_locksystem:check', source, hasKey, hasSearched)
end)

RegisterServerEvent('xd_locksystem:givePlayerKey')
AddEventHandler('xd_locksystem:givePlayerKey', function(plate)
	local xPlayer = ESX.GetPlayerFromId(source)
	local identifier = xPlayer.getIdentifier()
	
	if not vehicles[identifier] then
		vehicles[identifier] = {plate}
	else
		for k, v in pairs(vehicles[identifier]) do
			if v == plate then
				return
			end
		end
		
		table.insert(vehicles[identifier], plate)
	end
end)

RegisterServerEvent('xd_locksystem:takePlayerKey')
AddEventHandler('xd_locksystem:takePlayerKey', function(plate)
	local xPlayer = ESX.GetPlayerFromId(source)
	local identifier = xPlayer.getIdentifier()
	
	if not vehicles[identifier] then
		return
	else
		for k, v in pairs(vehicles[identifier]) do
			if v == plate then
				table.remove(vehicles[identifier], k)
			end
		end
	end
end)

RegisterServerEvent('xd_locksystem:setVehicleSearched')
AddEventHandler('xd_locksystem:setVehicleSearched', function(plate)
	for k, v in pairs(searchedVehicles) do
		if v == plate then
			return
		end
	end
	
	table.insert(searchedVehicles, plate)
end)

ESX.RegisterUsableItem('lockpick', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)
	local ped = GetPlayerPed(source)
	local vehicle = GetVehiclePedIsIn(ped, false)
	local shouldBreak = false
	
	if vehicle == 0 then
		TriggerClientEvent('xd_notify:send', source, 'אתה חייב להיות ברכב בכדי להתשמש בזה', 3000, 'bottom', true, 'error')
		return
	end
	
	if GetPedInVehicleSeat(vehicle, -1) ~= ped then
		TriggerClientEvent('xd_notify:send', source, 'אתה חייב להיות הנהג בכדי לעשות פעולה זאת', 3000, 'bottom', true, 'error')
		return
	end
	
	for k, v in pairs(Config.BlackList) do
		if GetHashKey(v) == GetEntityModel(vehicle) then
			return
		end
	end
	
	local chance = math.random(1, Config.noKeys.LockpickBreakChance)
	
	if chance == 1 then
		shouldBreak = true
	end
	
	TriggerClientEvent('xd_locksystem:lockpick', source, shouldBreak)
	
	if chance == 1 then
		Wait(Config.noKeys.HotwireWait * 2)
		xPlayer.removeInventoryItem('lockpick', 1)
	end
end)

ESX.RegisterServerCallback('xd_locksystem:getKeys', function(source, cb, plate)
	local xPlayer = ESX.GetPlayerFromId(source)
	local hasKey, hasSearched = false, false
	
	for k, v in pairs(vehicles) do
		if k == xPlayer.getIdentifier() then
			for i=1, #v, 1 do
				if plate ~= nil then
					if string.lower(v[i]) == string.lower(plate) then
						hasKey = true
						break
					end
				end
			end
		end
	end
	
	for k, v in pairs(searchedVehicles) do
		if string.lower(v) == string.lower(plate) then
			hasSearched = true
			break
		end
	end
	
	cb(hasKey, hasSearched)
end)

RegisterServerEvent('xd_locksystem:giveKeyCommand')
AddEventHandler('xd_locksystem:giveKeyCommand', function(target, plate)
	TriggerClientEvent('xd_locksystem:giveKeyCommand', target, plate)
end)