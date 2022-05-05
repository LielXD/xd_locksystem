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
		TriggerEvent('xd_notify:send', 'No vehicle nearby', 3000, 'bottom', true, 'error')
		return
	end

	ESX.TriggerServerCallback('xd_locksystem:getKeys', function(keys)
		if keys then
			if tonumber(args[1]) and GetPlayerPed(target) == GetPlayerPed(-1) then
				TriggerEvent('xd_notify:send', 'You can\'t give yourself keys', 3000, 'bottom', true, 'error')
				return
			elseif target == -1 then
				TriggerEvent('xd_notify:send', 'No players found', 3000, 'bottom', true, 'error')
				return
			end
			if distance < Config.key.PlayerRadius then
				takePlayerKeys(plate)
				TriggerServerEvent('xd_locksystem:giveKeyCommand', GetPlayerServerId(target), plate)
				TriggerEvent('xd_notify:send', 'You gave your keys of plate\n~h~' .. plate, 5000, 'bottom', true, 'warning')
			end
		else
			TriggerEvent('xd_notify:send', 'You don\'t have keys', 3000, 'bottom', true, 'error')
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
							exports['xd_progress']:drawBar(6000, 'Searching Vehicle')
							Wait(6300)
							TriggerEvent('xd_notify:send', 'Found keys\nfor plate ~h~' .. plate, 3000, 'bottom', true, 'info')
							TriggerServerEvent('xd_locksystem:setVehicleSearched', plate)
							TriggerServerEvent('xd_locksystem:givePlayerKey', plate)
							isSearch = false
						else
							isSearch = true
							exports['xd_progress']:drawBar(6000, 'Searching Vehicle')
							Wait(6300)
							TriggerEvent('xd_notify:send', 'Failed to found keys', 3000, 'bottom', true, 'error')
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
			EnableControlAction('INPUTGROUP_LOOK', true)
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
						TriggerEvent('xd_notify:send', 'the driver decided to runaway', 3000, 'bottom', true, 'warning')
                    else
                        local plate = GetVehicleNumberPlateText(prevCar)
						exports['xd_progress']:drawBar(3600, 'taking the keys')
                        Wait(3600)
                        givePlayerKeys(plate)
						TriggerServerEvent('xd_locksystem:check', plate)
						TriggerEvent('xd_notify:send', 'you took the keys for plate ~h~' .. plate, 3000, 'bottom', true, 'info')
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
	TriggerEvent('xd_notify:send', 'You got vehicle keys for plate\n~h~' .. plate, 5000, 'bottom', true, 'info')
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

	local text = {
		'Preparing Hotwire',
		'Cutting Cables',
		'Hotwire Attempt',
		'Trying turning on Engine'
	}
	for i=1, #text, 1 do
		exports['xd_progress']:drawBar(Config.noKeys.HotwireWait, text[i])
		Wait(Config.noKeys.HotwireWait + 500)
		if i == 2 and lockpick == 'break' then
			TriggerEvent('xd_notify:send', 'The lockpick broke!', 3000, 'bottom', true, 'error')
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
		TriggerEvent('xd_notify:send', 'Hotwire succeed', 3000, 'bottom', true, 'success')
		Wait(100)
		SetVehicleLights(vehicle, 0)
		SetVehicleEngineOn(vehicle, true, true, false)
	else
		isHotwire = false
		StopAnimTask(ped, 'veh@std@ds@base', 'hotwire', 1.0)
		TriggerServerEvent('xd_locksystem:check', plate)
		TriggerEvent('xd_notify:send', 'Hotwire failed', 3000, 'bottom', true, 'error')
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
				TriggerEvent('xd_notify:send', 'Vehicle Locked', 3000, 'bottom', true, 'info')
				playLockAnim()
			elseif lockStatus == 4 then
				SetVehicleDoorsLocked(vehicle, 1)
				SetVehicleDoorsLockedForAllPlayers(vehicle, false)
				TriggerEvent('xd_notify:send', 'Vehicle Unlocked', 3000, 'bottom', true, 'info')
				playLockAnim()
			else
				SetVehicleDoorsLocked(vehicle, 4)
				SetVehicleDoorsLockedForAllPlayers(vehicle, true)
				TriggerEvent('xd_notify:send', 'Vehicle Locked', 3000, 'bottom', true, 'info')
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