-- XD_Locksystem | Creator: LielXD --

--[[
	HasKeys
]]--

local hasKeys, hasSearched = false, false
local isHotwire, isSearch = false, false
local isRobbing, canRob = false, false
local prevPed, prevCar = false, false

-- Check Interval
Citizen.CreateThread(function()
	while true do
		Wait(4)
		
		local ped = GetPlayerPed(-1)
		local vehicle = GetVehiclePedIsIn(ped, false)
		
		if IsPedInAnyVehicle(ped, false) then
			TriggerServerEvent('xd_locksystem:check', GetVehicleNumberPlateText(vehicle))
			Wait(Config.checkKeyInterval)
		end
	end
end)

RegisterNetEvent('xd_locksystem:check')
AddEventHandler('xd_locksystem:check', function(keys, searched)
	hasKeys = keys
	hasSearched = searched
end)

--[[
	Givekey Command
]]--

RegisterCommand('givekey', function(source, args)
	local vehicle = getNearestVeh(2.0)
	local plate = GetVehicleNumberPlateText(vehicle)
	local pedCoords = GetEntityCoords(GetPlayerPed(-1))
	local target, distance = ESX.Game.GetClosestPlayer()

	if tonumber(args[1]) then
		target = GetPlayerFromServerId(tonumber(args[1]))
		distance = #(pedCoords - GetEntityCoords(GetPlayerPed(target)))
	end
	
	if vehicle == 0 then
		if Config.ESX_Notify then
			exports['esx_notify']:Notify('error', 3000, Config.Translate['no_vehicles'])
		else
			Config.Custom_Notify(Config.Translate['no_vehicles'], 3000, 'error')
		end
		return
	end

	ESX.TriggerServerCallback('xd_locksystem:getKeys', function(keys)
		if keys then
			if tonumber(args[1]) and GetPlayerPed(target) == GetPlayerPed(-1) then
				if Config.ESX_Notify then
					exports['esx_notify']:Notify('error', 3000, Config.Translate['give_yourself'])
				else
					Config.Custom_Notify(Config.Translate['give_yourself'], 3000, 'error')
				end
				return
			elseif target == -1 then
				if Config.ESX_Notify then
					exports['esx_notify']:Notify('error', 3000, Config.Translate['no_players'])
				else
					Config.Custom_Notify(Config.Translate['no_players'], 3000, 'error')
				end
				return
			end
			if distance < Config.key.PlayerRadius then
				takePlayerKeys(plate)
				TriggerServerEvent('xd_locksystem:giveKeyCommand', GetPlayerServerId(target), plate)
				if Config.ESX_Notify then
					exports['esx_notify']:Notify('info', 5000, Config.Translate['give_key']:format(plate))
				else
					Config.Custom_Notify(Config.Translate['give_key']:format(plate), 5000, 'info')
				end
			end
		else
			if Config.ESX_Notify then
				exports['esx_notify']:Notify('error', 3000, Config.Translate['no_key'])
			else
				Config.Custom_Notify(Config.Translate['no_key'], 3000, 'error')
			end
		end
	end, plate)
end)

--[[
	Loops
]]--

-- Hotwire and Search
Citizen.CreateThread(function()
	while true do
		Wait(4)
		
		local ped = GetPlayerPed(-1)
		local vehicle = GetVehiclePedIsIn(ped, false)
		local driver = GetPedInVehicleSeat(vehicle, -1)
		local plate = GetVehicleNumberPlateText(vehicle)
		local disable = false
		
		if IsPedInAnyVehicle(ped, false) and driver == ped then
			for k, v in pairs(Config.BlackList) do
				if GetHashKey(v) == GetEntityModel(vehicle) then
					disable = true
				end
			end
			if not hasKeys and disable == false then
				SetVehicleNeedsToBeHotwired(vehicle, false)
				
				if not isHotwire and not isSearch then
					SetVehicleEngineOn(vehicle, false, true, true)
					if hasSearched then
						DrawText3D(GetEntityCoords(vehicle), Config.noKeys.TextSearched)
					else
						DrawText3D(GetEntityCoords(vehicle), Config.noKeys.Text)
					end
					
					if IsControlJustPressed(1, Config.noKeys.SearchKey) and not hasSearched then
						local chance = math.random(1, Config.noKeys.FoundKeyChance)
						
						if chance == 1 then
							isSearch = true
							if Config.ESX_ProgressBar then
								exports['esx_progressbar']:Progressbar(Config.Translate['search'], 6000,{FreezePlayer = false, animation = false})
							else
								Config.Custom_ProgressBar(Config.Translate['search'], 6000)
							end
							if Config.ESX_Notify then
								exports['esx_notify']:Notify('success', 5000, Config.Translate['found_key']:format(plate))
							else
								Config.Custom_Notify(Config.Translate['found_key']:format(plate), 5000, 'success')
							end
							TriggerServerEvent('xd_locksystem:setVehicleSearched', plate)
							TriggerServerEvent('xd_locksystem:givePlayerKey', plate)
							isSearch = false
						else
							isSearch = true
							if Config.ESX_ProgressBar then
								exports['esx_progressbar']:Progressbar(Config.Translate['search'], 6000,{FreezePlayer = false, animation = false})
							else
								Config.Custom_ProgressBar(Config.Translate['search'], 6000)
							end
							if Config.ESX_Notify then
								exports['esx_notify']:Notify('error', 3000, Config.Translate['notfound_key'])
							else
								Config.Custom_Notify(Config.Translate['notfound_key'], 3000, 'error')
							end
							TriggerServerEvent('xd_locksystem:setVehicleSearched', plate)
							isSearch = false
						end
						TriggerServerEvent('xd_locksystem:check', plate)
					end
					
					if IsControlJustPressed(1, Config.noKeys.HotwireKey) then
						hotwire(false)
					end
				end
			end
		end
	end
end)

Citizen.CreateThread(function()
	while true do
		Wait(4)
		
		if isHotwire or isSearch then
			DisableAllControlActions(0)
			-- Enable looking
			EnableControlAction(0, 1, true)
			EnableControlAction(0, 2, true)
		end
	end
end)

-- Rob
Citizen.CreateThread(function()
    while true do
        Wait(4)
		
        local foundEnt, aimingEnt = GetEntityPlayerIsFreeAimingAt(PlayerId())
        local entPos = GetEntityCoords(aimingEnt)
        local pos = GetEntityCoords(GetPlayerPed(-1))
        local dist = GetDistanceBetweenCoords(pos.x, pos.y, pos.z, entPos.x, entPos.y, entPos.z, true)
		local disable = false

        if foundEnt and prevPed ~= aimingEnt and IsPedInAnyVehicle(aimingEnt, false) and IsPedArmed(GetPlayerPed(-1), 7) and dist < 20.0 and not IsPedInAnyVehicle(GetPlayerPed(-1)) then
            for k, v in pairs(Config.BlackList) do
				if GetHashKey(v) == GetEntityModel(vehicle) then
					disable = true
				end
			end
			if not IsPedAPlayer(aimingEnt) and disable == false then
                prevPed = aimingEnt
                Wait(math.random(300, 700))
                ESX.Streaming.RequestAnimDict('random@mugging3', function()
					local chance = math.random(1, 10)

					if chance > 4 then
						prevCar = GetVehiclePedIsIn(aimingEnt, false)
						TaskLeaveVehicle(aimingEnt, prevCar)
						SetVehicleEngineOn(prevCar, false, false, false)
						while IsPedInAnyVehicle(aimingEnt, false) do
							Wait(4)
						end
						SetBlockingOfNonTemporaryEvents(aimingEnt, true)
						ClearPedTasksImmediately(aimingEnt)
						TaskPlayAnim(aimingEnt, 'random@mugging3', 'handsup_standing_base', 8.0, -8.0, 0.01, 49, 0, 0, 0, 0)
						ResetPedLastVehicle(aimingEnt)
						TaskWanderInArea(aimingEnt, 0, 0, 0, 20, 100, 100)
						canRob = true
						beginRobTimer(aimingEnt)
					end
				end)
            end
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Wait(4)
		
        if canRob and not IsEntityDead(prevPed) and IsPlayerFreeAiming(PlayerId()) then
            local ped = GetPlayerPed(-1)
            local pos = GetEntityCoords(ped)
            local entPos = GetEntityCoords(prevPed)
			
            if GetDistanceBetweenCoords(pos.x, pos.y, pos.z, entPos.x, entPos.y, entPos.z, false) < 3.5 then
                DrawText3D(entPos, Config.rob.Text)
                
				if IsControlJustPressed(1, Config.rob.Key) then
                    local chance = math.random(1, Config.rob.RunawayChance)
                    if chance == 1 then
                        Wait(400)
						if Config.ESX_Notify then
							exports['esx_notify']:Notify('error', 3000, Config.Translate['npc_run'])
						else
							Config.Custom_Notify(Config.Translate['npc_run'], 3000, 'error')
						end
                    else
                        local plate = GetVehicleNumberPlateText(prevCar)
						if Config.ESX_ProgressBar then
							exports['esx_progressbar']:Progressbar(Config.Translate['rob_key'], 3600,{FreezePlayer = false, animation = false})
						else
							Config.Custom_ProgressBar(Config.Translate['rob_key'], 3600)
						end
                        givePlayerKeys(plate)
						TriggerServerEvent('xd_locksystem:check', plate)
						if Config.ESX_Notify then
							exports['esx_notify']:Notify('success', 5000, Config.Translate['npc_key']:format(plate))
						else
							Config.Custom_Notify(Config.Translate['npc_key']:format(plate), 5000, 'success')
						end
                    end
                    SetBlockingOfNonTemporaryEvents(prevPed, false)
					StopAnimTask(prevPed, 'random@mugging3', 'handsup_standing_base', 1.0)
                    canRob = false
                end
            end
        end
    end
end)

-- Lock / Unlock
Citizen.CreateThread(function()
	while true do
        Wait(4)
		
		local ped = GetPlayerPed(-1)
        local pos = GetEntityCoords(ped)

        if IsControlJustPressed(1, Config.key.LockKey) then
            if IsPedInAnyVehicle(ped, false)  then
                local vehicle = GetVehiclePedIsIn(ped, false)
                toggleLock(vehicle)
				Wait(2000)
            else
				local vehicle = getNearestVeh(8.0)
                if DoesEntityExist(vehicle) then
                    toggleLock(vehicle)
					Wait(2000)
                end
            end
        end
    end
end)

--[[
	NetEvents
]]--

RegisterNetEvent('xd_locksystem:lockpick')
AddEventHandler('xd_locksystem:lockpick', function(shouldBreak)
	if hasKeys then
		return
	end
	if shouldBreak then
		hotwire('break')
	else
		hotwire(true)
	end
end)

RegisterNetEvent('xd_locksystem:giveKeyCommand')
AddEventHandler('xd_locksystem:giveKeyCommand', function(plate)
	givePlayerKeys(plate)
	if Config.ESX_Notify then
		exports['esx_notify']:Notify('success', 5000, Config.Translate['give_key_target']:format(plate))
	else
		Config.Custom_Notify(Config.Translate['give_key_target']:format(plate), 5000, 'success')
	end
end)

RegisterNetEvent('xd_locksystem:sendNotify')
AddEventHandler('xd_locksystem:sendNotify', function(text, time, type)
	if Config.ESX_Notify then
		exports['esx_notify']:Notify(type, time, text)
	else
		Config.Custom_Notify(text, time, type)
	end
end)

--[[
	Functions
]]--

function givePlayerKeys(plate)
	TriggerServerEvent('xd_locksystem:givePlayerKey', plate)
end

function takePlayerKeys(plate)
	TriggerServerEvent('xd_locksystem:takePlayerKey', plate)
end

function hotwire(lockpick)
	local ped = GetPlayerPed(-1)
	local vehicle = GetVehiclePedIsIn(ped, false)
	local plate = GetVehicleNumberPlateText(vehicle)
	
	isHotwire = true

	SetVehicleEngineOn(vehicle, false, true, true)
	SetVehicleLights(vehicle, 1)
	
	if Config.noKeys.HotwireAlarm then
		local chance = math.random(1, Config.noKeys.HotwireAlarmChance)

		if chance == 1 then
			SetVehicleAlarm(vehicle, true)
			StartVehicleAlarm(vehicle)
			-- In Future Send Notification to Police Officers
			print('police alert')
		end
	end

	ESX.Streaming.RequestAnimDict('veh@std@ds@base', function()
		TaskPlayAnim(PlayerPedId(), 'veh@std@ds@base', 'hotwire', 1.0, 1.0, -1, 1, 0.3, true, true, true)
	end)

	for i=1, #Config.noKeys.Hotwire_Stages, 1 do
		if Config.ESX_ProgressBar then
			exports['esx_progressbar']:Progressbar(Config.noKeys.Hotwire_Stages[i], Config.noKeys.HotwireWait,{FreezePlayer = false, animation = false})
		else
			Config.Custom_ProgressBar(Config.noKeys.Hotwire_Stages[i], Config.noKeys.HotwireWait)
		end
		Wait(100)
		if i == 2 and lockpick == 'break' then
			if Config.ESX_Notify then
				exports['esx_notify']:Notify('error', 3000, Config.Translate['lockpick'])
			else
				Config.Custom_Notify(Config.Translate['lockpick'], 3000, 'error')
			end
			StopAnimTask(ped, 'veh@std@ds@base', 'hotwire', 1.0)
			isHotwire = false
			return
		end
	end

	local chance = math.random(1, Config.noKeys.HotwireChance)
	if lockpick ~= false then
		chance = 1
	end
	if chance == 1 then
		isHotwire = false
		givePlayerKeys(plate)
		StopAnimTask(ped, 'veh@std@ds@base', 'hotwire', 1.0)
		TriggerServerEvent('xd_locksystem:check', plate)
		if Config.ESX_Notify then
			exports['esx_notify']:Notify('success', 5000, Config.Translate['hotwire_success'])
		else
			Config.Custom_Notify(Config.Translate['hotwire_success'], 5000, 'success')
		end
		Wait(100)
		SetVehicleLights(vehicle, 0)
		SetVehicleEngineOn(vehicle, true, true, false)
	else
		isHotwire = false
		StopAnimTask(ped, 'veh@std@ds@base', 'hotwire', 1.0)
		TriggerServerEvent('xd_locksystem:check', plate)
		if Config.ESX_Notify then
			exports['esx_notify']:Notify('error', 3000, Config.Translate['hotwire_failed'])
		else
			Config.Custom_Notify(Config.Translate['hotwire_failed'], 3000, 'error')
		end
	end
end

function beginRobTimer(entity)
	local timer = 18

	while canRob do
		timer = timer - 1
		if timer == 0 then
			canRob = false
			SetBlockingOfNonTemporaryEvents(entity, false)
			StopAnimTask(prevPed, 'random@mugging3', 'handsup_standing_base', 1.0)
		end
		Wait(1000)
	end
end

function toggleLock(vehicle)
    local plate = GetVehicleNumberPlateText(vehicle)
    local lockStatus = GetVehicleDoorLockStatus(vehicle)
	
	ESX.TriggerServerCallback('xd_locksystem:getKeys', function(keys)
		if keys then
			if lockStatus == 1 then
				SetVehicleDoorsLocked(vehicle, 4)
				SetVehicleDoorsLockedForAllPlayers(vehicle, true)
				if Config.ESX_Notify then
					exports['esx_notify']:Notify('info', 3000, Config.Translate['locked'])
				else
					Config.Custom_Notify(Config.Translate['locked'], 3000, 'info')
				end
				playLockAnim()
			elseif lockStatus == 4 then
				SetVehicleDoorsLocked(vehicle, 1)
				SetVehicleDoorsLockedForAllPlayers(vehicle, false)
				if Config.ESX_Notify then
					exports['esx_notify']:Notify('info', 3000, Config.Translate['unlocked'])
				else
					Config.Custom_Notify(Config.Translate['unlocked'], 3000, 'info')
				end
				playLockAnim()
			else
				SetVehicleDoorsLocked(vehicle, 4)
				SetVehicleDoorsLockedForAllPlayers(vehicle, true)
				if Config.ESX_Notify then
					exports['esx_notify']:Notify('info', 3000, Config.Translate['locked'])
				else
					Config.Custom_Notify(Config.Translate['locked'], 3000, 'info')
				end
				playLockAnim()
			end
			if not IsPedInAnyVehicle(GetPlayerPed(-1), true) then
				Wait(500)
				local flickers = 0
				while flickers < 2 do
					SetVehicleLights(vehicle, 2)
					Wait(170)
					SetVehicleLights(vehicle, 0)
					flickers = flickers + 1
					Wait(170)
				end
			end
		end
	end, plate)
end

--[[
	Chat Suggestions
]]--

Citizen.CreateThread(function()
	TriggerEvent('chat:addSuggestion', '/givekey',  'give keys to closest player', {
		{name = 'playerId', help = 'player id | can leave blank for closest player'}
	})
end)

AddEventHandler('onResourceStop', function(resource)
	if resource == GetCurrentResourceName() then
		TriggerEvent('chat:removeSuggestion', '/givekey')
	end
end)
