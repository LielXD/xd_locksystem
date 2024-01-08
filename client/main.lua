local inAction = false
local canRob = false
local currentVehicle = nil

CreateThread(function()
    SetPlayerFlags()
end)

CreateThread(function()
    while true do
        Wait(500)

        if currentVehicle and #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(currentVehicle)) > 2 then
            Config.ShowInstruction(false)
            currentVehicle = nil
        end

        local aim, entity = GetEntityPlayerIsFreeAimingAt(PlayerId())
        if GetIsTaskActive(PlayerPedId(), 160) and not inAction then
            inAction = true

            local vehicleEntering = GetVehiclePedIsTryingToEnter(PlayerPedId())
            local plate = GetVehicleNumberPlateText(vehicleEntering)
            local VehicleData = GetVehicleData(plate)
            local vehicleClass = GetVehicleClass(vehicleEntering)

            SetPlayerFlags()
            SetVehicleRadioLoud(vehicleEntering, Config.LoudRadio)
            
            -- 8: Motorcycles | 13: Cycles
            local NpcChance = false
            local lockpickKey = GetControlInstructionalButton(0, `xd_locksystem:lockpick`, true)
            if not VehicleData.keys and not VehicleData.lockpick and vehicleClass ~= 8 and vehicleClass ~= 13 then
                local NpcDriver = GetPedInVehicleSeat(vehicleEntering, -1)
                
                if NpcDriver == 0 then
                    SetVehicleNeedsToBeHotwired(vehicleEntering, false)
                    for i=0, 5 do
                        if IsVehicleDoorDamaged(vehicleEntering, i) or GetVehicleDoorAngleRatio(vehicleEntering, i) > 0.1 then
                            SetVehicleIndividualDoorsLocked(vehicleEntering, i, 1)
                        else
                            SetVehicleIndividualDoorsLocked(vehicleEntering, i, 2)
                        end
                    end

                    currentVehicle = vehicleEntering

                    Config.ShowInstruction(Config.Translate['lockpick_helpbox'], currentVehicle, lockpickKey)
                elseif not IsPedAPlayer(NpcDriver) then
                    NpcChance = true

                    local chance = math.random(1, Config.NpcOpenChance)
                    if chance ~= 1 then
                        NpcChance = false
                        
                        SetVehicleNeedsToBeHotwired(vehicleEntering, false)
                        for i=0, 5 do
                            if IsVehicleDoorDamaged(vehicleEntering, i) or GetVehicleDoorAngleRatio(vehicleEntering, i) > 0.1 then
                                SetVehicleIndividualDoorsLocked(vehicleEntering, i, 1)
                            else
                                SetVehicleIndividualDoorsLocked(vehicleEntering, i, 2)
                            end
                        end

                        TriggerServerEvent('xd_locksystem:setVehicleLockpicked', GetVehicleNumberPlateText(vehicleEntering), 'NPC')
                    end
                end
            end
            
            while GetIsTaskActive(PlayerPedId(), 160) do
                Wait(100)

                if GetIsTaskActive(PlayerPedId(), 165) and not Config.Player.shuffle then
                    ClearPedTasks(PlayerPedId())
                    SetPedIntoVehicle(PlayerPedId(), vehicleEntering, 0)
                    SetVehicleDoorShut(vehicleEntering, 0, false)
                end
            end
            
            local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
            if NpcChance or GetIsVehicleEngineRunning(vehicle) and not VehicleData.lockpick then
                SetVehicleKey(GetVehicleNumberPlateText(vehicle))
                Config.ShowInstruction(false)
            elseif vehicle ~= 0 and not VehicleData.keys and not VehicleData.lockpick or vehicle ~= 0 and VehicleData.lockpick == 'NPC' then
                Config.ShowInstruction(Config.Translate['hotwire_helpbox'], vehicle, lockpickKey)
            end

            inAction = false
        elseif not inAction and aim and IsPedArmed(PlayerPedId(), 4) and not IsPedAPlayer(entity) and IsPedInAnyVehicle(entity, false) and not IsPedInAnyVehicle(PlayerPedId(), true) and #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(entity)) < Config.Distance.Rob then
            inAction = true
            
            local dict, anim = 'random@mugging3', 'handsup_standing_base'
            RequestAnimDict(dict)
            TaskSetBlockingOfNonTemporaryEvents(entity, true)
            Wait(1)
            
            local vehicle = GetVehiclePedIsIn(entity, true)
            TriggerServerEvent('xd_locksystem:setVehicleLockpicked', GetVehicleNumberPlateText(vehicle), 'NPC')
            TaskLeaveAnyVehicle(entity, 1, 256)
            Wait(1)
            while GetIsTaskActive(entity, 152) do Wait(10) end

            TaskWanderInArea(entity, 0, 0, 0, 20, 100, 100)
            Wait(1)

            TaskPlayAnim(entity, dict, anim, 8.0, 8.0, -1, 49, 1, false, false, false)
            currentVehicle = vehicle

            local robKey = GetControlInstructionalButton(0, `xd_locksystem:rob`, true)
            Config.ShowInstruction(Config.Translate['rob_helpbox'], currentVehicle, robKey)
            
            canRob = {vehicle, entity}
            while canRob do
                Wait(500)

                local aim2, entity2 = GetEntityPlayerIsFreeAimingAt(PlayerId())

                if #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(entity)) >= Config.Distance.Rob or aim2 and entity ~= entity2 or IsPedInAnyVehicle(PlayerPedId(), true) then
                    ClearPedTasks(entity)
                    TaskReactAndFleePed(entity, PlayerPedId())
                    canRob = false
                    inAction = false
                    break
                end

                if GetEntityHealth(entity) < 1 then
                    SetVehicleKey(GetVehicleNumberPlateText(vehicle))
                    canRob = false
                    inAction = false
                    break
                end
            end
        end
    end
end)

function SetVehicleKey(plate, remove)
    if not plate then return end
    TriggerServerEvent('xd_locksystem:setVehicleKey', plate, remove)
end
exports('SetVehicleKey', SetVehicleKey)

local vehicleData = nil
RegisterNetEvent('xd_locksystem:getVehicleData', function(cb)
    vehicleData = cb
end)

function GetVehicleData(plate)
    if not plate then return false end

    vehicleData = nil
    TriggerServerEvent('xd_locksystem:getVehicleData', plate)
    while vehicleData == nil do Wait(4) end
    
    return json.decode(vehicleData)
end
exports('GetVehicleData', GetVehicleData)

function SetPlayerFlags()
    local ped = PlayerPedId()

    SetPedConfigFlag(ped, 328, true) -- lower priority of warp seats
    SetPedConfigFlag(ped, 448, true) -- disable breaking window animation
    SetPedConfigFlag(ped, 426, false) -- disable auto lockpick animation
    SetPedConfigFlag(ped, 252, Config.Player.kick) -- kick out player from vehicle
    SetPedConfigFlag(ped, 184, not Config.Player.shuffle) -- prevent autodriver seat
    SetPedConfigFlag(ped, 366, not Config.Player.shuffle) -- allow driver seat
    SetPedConfigFlag(ped, 360, not Config.Player.shuffle) -- turrent seat
    SetPedConfigFlag(ped, 241, not Config.Player.autoEngine) -- auto stop
    SetPedConfigFlag(ped, 429, not Config.Player.autoEngine) -- auto start
end

--[[
    Rob
]]--
RegisterCommand('xd_locksystem:rob', function()
    if IsNuiFocused() or IsPauseMenuActive() or not canRob then return end
    Config.ShowInstruction(false)

    if DoesEntityExist(canRob[2]) then
        ClearPedTasks(canRob[2])

        local dict, anim = 'mp_common', 'givetake2_b'
        RequestAnimDict(dict)
        while not HasAnimDictLoaded(dict) do Wait(100) end

        local forward, right, up, pos = GetEntityMatrix(PlayerPedId())
        TaskGoStraightToCoord(canRob[2], pos+forward, 2.0, -1, GetEntityHeading(PlayerPedId())-180, 2)
        Wait(10)

        while GetScriptTaskStatus(PlayerPedId(), 0x7D8F4411) ~= 7 do
            TaskStandStill(PlayerPedId(), 500)
            Wait(500)
        end

        TaskPlayAnim(canRob[2], dict, anim, 1.0,1.0, 2000, 48, 0.0, 0,0,0)
        Wait(10)
        
        SetPedCurrentWeaponVisible(PlayerPedId(), false, false, false, false)
        TaskPlayAnim(PlayerPedId(), dict, anim, 8.0,8.0, 2000, 48, 0.0, 0,0,0)

        while IsEntityPlayingAnim(canRob[2], dict, anim, 3) do Wait(500) end
        SetPedCurrentWeaponVisible(PlayerPedId(), true, false, false, false)

        ClearPedTasks(canRob[2])
        TaskReactAndFleePed(canRob[2], PlayerPedId())
    end

    SetVehicleKey(GetVehicleNumberPlateText(canRob[1]))
    TriggerServerEvent('xd_locksystem:setVehicleLockpicked', GetVehicleNumberPlateText(canRob[1]), true)
    Config.ShowNotify(Config.Translate['rob'], 'info')

    canRob = false
    inAction = false
end, true)
RegisterKeyMapping('xd_locksystem:rob', '.3 Rob vehicle keys', 'keyboard', 'E')

--[[
    Key Lock Toggle
]]--
local locking = false
RegisterCommand('xd_locksystem:lock', function()
    if IsNuiFocused() or IsPauseMenuActive() or locking then return end
    locking = true

    local vehicle = false
    if IsPedInAnyVehicle(PlayerPedId(), true) then
        local veh = GetVehiclePedIsIn(PlayerPedId(), false)
        if GetPedInVehicleSeat(veh, -1) == PlayerPedId() then
            vehicle = veh
        end
    else
        local coords = GetEntityCoords(PlayerPedId())
        local offset = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, Config.Distance.Lock * 1.0, 0.0)
        local shape = StartShapeTestCapsule(coords, offset, 10, PlayerPedId(), 0)
        local retval, hit, endCoords, surfaceNormal, veh = GetShapeTestResult(shape)

        if veh ~= 0 then
            vehicle = veh
        end
    end

    if not vehicle or vehicle == 0 then
        locking = false
        return
    end

    local VehicleData = GetVehicleData(GetVehicleNumberPlateText(vehicle))
    if VehicleData.keys ~= 'self' then
        Config.ShowNotify(Config.Translate['lock_no_keys'], 'error')
        locking = false
        return
    end

    if not DecorExistOn(vehicle, 'xd_locksystem') then
        DecorRegister('xd_locksystem', 2)
        DecorSetBool(vehicle, 'xd_locksystem', false)
    end

    local dict, anim, carKeyProp, carKeyObject = 'anim@mp_player_intmenu@key_fob@', 'fob_click_fp', 'lr_prop_carkey_fob', false
    if not IsPedInAnyVehicle(PlayerPedId(), true) then
        RequestAnimDict(dict)
        RequestModel(carKeyProp)

        while not HasAnimDictLoaded(dict) or not HasModelLoaded(carKeyProp) do Wait(100) end

        SetPedCurrentWeaponVisible(PlayerPedId(), false, false, false, false)

        local boneIndex = GetPedBoneIndex(PlayerPedId(), 0xDEAD)
        local boneCoords = GetWorldPositionOfEntityBone(PlayerPedId(), boneIndex)
        carKeyObject = CreateObject('lr_prop_carkey_fob', boneCoords, true, true, false)
        AttachEntityToEntity(carKeyObject, PlayerPedId(), boneIndex, 0.13,0.04,-0.02, 0.0,90.0,100.0, true, true, false, false, 2, true)

        TaskPlayAnim(PlayerPedId(), dict, anim, 8.0, 8.0, -1, 48, 1, false, false, false)
        Wait(500)

        TriggerServerEvent('xd_locksystem:indicator', NetworkGetNetworkIdFromEntity(vehicle))
        TriggerServerEvent('xd_locksystem:PlaySound.server', 'vehicle_beep', VehToNet(vehicle))
    end

    if not DecorGetBool(vehicle, 'xd_locksystem') then
        SetVehicleNeedsToBeHotwired(vehicle, false)

        SetVehicleDoorsLocked(vehicle, 4)
        SetVehicleDoorsLockedForAllPlayers(vehicle, true)

        for i=0, 5 do
            PlayVehicleDoorCloseSound(vehicle, i)
        end
        Config.ShowNotify(Config.Translate['locked'], 'info')
        
        DecorSetBool(vehicle, 'xd_locksystem', true)
    else
        SetVehicleNeedsToBeHotwired(vehicle, false)

        SetVehicleDoorsLocked(vehicle, 1)
        SetVehicleDoorsLockedForAllPlayers(vehicle, false)

        for i=0, 5 do
            PlayVehicleDoorOpenSound(vehicle, i)
        end
        Config.ShowNotify(Config.Translate['unlocked'], 'info')
        
        DecorSetBool(vehicle, 'xd_locksystem', false)
    end

    while IsEntityPlayingAnim(PlayerPedId(), dict, anim, 3) do
        Wait(100)
        DisableControlAction(0, 23, true)

        if GetEntityAnimCurrentTime(PlayerPedId(), dict, anim) >= 0.7 then
            break
        end
    end

    if carKeyObject then
        DeleteObject(carKeyObject)
        carKeyObject = false
    end

    SetPedCurrentWeaponVisible(PlayerPedId(), true, false, false, false)
    Wait(1000)
    locking = false
end, true)
RegisterKeyMapping('xd_locksystem:lock', '.1 Lock vehicle', 'keyboard', 'L')

RegisterNetEvent('xd_locksystem:indicator.blink', function(vehicle)
    local vehicle = NetworkGetEntityFromNetworkId(vehicle)
    local engineOn = GetIsVehicleEngineRunning(vehicle)

    if not engineOn then
        SetVehicleLights(vehicle, 1)
        SetVehicleEngineOn(vehicle, true, true, true)
    end

    SetVehicleIndicatorLights(vehicle, 0, true)
    SetVehicleIndicatorLights(vehicle, 1, true)
    Wait(1500)
    SetVehicleIndicatorLights(vehicle, 0, false)
    SetVehicleIndicatorLights(vehicle, 1, false)

    if not engineOn then
        SetVehicleLights(vehicle, 0)
        SetVehicleEngineOn(vehicle, false, true, true)
    end
end)

--[[
    Lockpick Vehicle
]]--
local lockpickAction = false
function LockpickVehicle(vehicle)
    if not vehicle or vehicle == 0 or not DoesEntityExist(vehicle) or not IsEntityAVehicle(vehicle)
    or IsPedInAnyVehicle(PlayerPedId(), true) or GetVehicleDoorLockStatus(vehicle) < 2 then return end
    
    local plate = GetVehicleNumberPlateText(vehicle)
    local VehicleData = GetVehicleData(plate)
    if VehicleData.keys or VehicleData.lockpick then return end

    inAction = 'lockpick'
    lockpickAction = false

    local forward, right, up, pos = GetEntityMatrix(vehicle)
    local boneCoords = GetWorldPositionOfEntityBone(vehicle, GetEntityBoneIndexByName(vehicle, 'seat_dside_f')) - right - forward * 0.5
    TaskGoToCoordAnyMeans(PlayerPedId(), boneCoords, 3.0, 0, 0, 786603, 0)
    Wait(10)
    while GetIsTaskActive(PlayerPedId(), 224) do Wait(100) end

    TaskGoStraightToCoord(PlayerPedId(), boneCoords, 2.0, -1, GetEntityHeading(vehicle) - 90, 3)
    Wait(10)
    while GetScriptTaskStatus(PlayerPedId(), 0x7D8F4411) ~= 7 do Wait(100) end

    local dict, anim = 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@', 'machinic_loop_mechandplayer'
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Wait(10)
    end

    SetPedCurrentWeaponVisible(PlayerPedId(), false, false, false, false)
    TaskPlayAnim(PlayerPedId(), dict, anim, 8.0, 8.0, -1, 48, 1, false, false, false)
    Wait(1)
    
    local lockpickKey = GetControlInstructionalButton(0, `xd_locksystem:lockpick`, true)
    SetNuiFocus(true, true)
    SendNUIMessage({
        lockpick = Config.minigame or 10,
        translate = Config.Translate,
        exitButton = lockpickKey:gsub('t_', ''):gsub('b_', '')
    })

    while not lockpickAction do
        Wait(1000)
    end

    SetNuiFocus(false, false)
    ClearPedTasks(PlayerPedId())
    SetPedCurrentWeaponVisible(PlayerPedId(), true, false, false, false)
    if lockpickAction == 'win' then
        SetVehicleDoorsLocked(vehicle, 1)
        SetVehicleDoorsLockedForAllPlayers(vehicle, false)
        SetVehicleNeedsToBeHotwired(vehicle, false)
        TriggerServerEvent('xd_locksystem:setVehicleLockpicked', plate)

        Config.ShowNotify(Config.Translate['lockpick_win'], 'success')
        TaskEnterVehicle(PlayerPedId(), vehicle, -1, -1, 2.0, 1, 0)
        while GetIsTaskActive(PlayerPedId(), 160) do Wait(100) end

        if not GetIsVehicleEngineRunning(vehicle) then
            Config.ShowInstruction(Config.Translate['hotwire_helpbox'], vehicle, lockpickKey)
        end
    elseif lockpickAction == 'lose' then
        Config.ShowNotify(Config.Translate['lockpick_lost'], 'error')
    end

    inAction = false
    lockpickAction = false
end

RegisterNUICallback('lockpick', function(data, cb)
    if data.win then
        lockpickAction = 'win'
    else
        lockpickAction = 'lose'
    end

    cb('ok')
end)

RegisterNUICallback('close', function(data, cb)
    lockpickAction = 'lose'

    cb('ok')
end)

RegisterNUICallback('PlaySound', function(data, cb)
    TriggerServerEvent('xd_locksystem:PlaySound.server', 'lockpick', PedToNet(PlayerPedId()))
    
    cb('ok')
end)

local isHotwire = false
RegisterCommand('xd_locksystem:lockpick', function()
    if IsNuiFocused() or IsPauseMenuActive() then return end

    if isHotwire then
        isHotwire = false
        return
    end

    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    if vehicle == 0 then
        Config.ShowInstruction(false)

        local coords = GetEntityCoords(PlayerPedId())
        local offset = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, Config.Distance.Lock * 1.0, 0.0)
        local shape = StartShapeTestCapsule(coords, offset, 10, PlayerPedId(), 0)
        local retval, hit, endCoords, surfaceNormal, closeVehicle = GetShapeTestResult(shape)
    
        LockpickVehicle(closeVehicle)
        return
    end

    local VehicleData = GetVehicleData(GetVehicleNumberPlateText(vehicle))
    if VehicleData.keys or GetIsVehicleEngineRunning(vehicle) then return end

    local dict, anim = 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@', 'machinic_loop_mechandplayer'
    local boneIndex = GetEntityBoneIndexByName(vehicle, 'seat_dside_f')
    local coords = GetWorldPositionOfEntityBone(vehicle, boneIndex)
    local rotation = GetEntityBoneRotation(vehicle, boneIndex)

    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do Wait(10) end
    TaskPlayAnim(PlayerPedId(), dict, anim, 1.0,1.0, -1, 16, 0.0, 1,1,1)
    
    local cam = CreateCamWithParams('DEFAULT_SCRIPTED_CAMERA', coords+vector3(0,0,0.5), rotation, GetGameplayCamFov(), true, false)
    while not DoesCamExist(cam) do Wait(10) end

    AttachCamToVehicleBone(cam, vehicle, boneIndex, true, -20.0,0.0,30.0, 0.6,-0.6,0.6, true)
    RenderScriptCams(true, true, 1000)
    isHotwire = true

    local lockpickKey = GetControlInstructionalButton(0, `xd_locksystem:lockpick`, true)
    Config.ShowInstruction(Config.Translate['hotwire_helpbox_stop'], vehicle, lockpickKey)

    if Config.Hotwire.police then
        local policeChance = math.random(1, Config.Hotwire.police)
        if policeChance == 1 and Config.Hotwire.policeFunc then
            Config.Hotwire.policeFunc(vehicle)
        end
    end

    local hotwire = 0
    while DoesCamExist(cam) do
        Wait(1000)
        hotwire = hotwire + 1
        if not isHotwire or hotwire >= Config.Hotwire.time then break end
    end

    StopAnimTask(PlayerPedId(), dict, anim, 1.0)
    RenderScriptCams(false, true, 1000)
    DestroyCam(cam)

    if hotwire >= Config.Hotwire.time and isHotwire then
        local chance = math.random(1, Config.Hotwire.chance)
        if chance == 1 then
            SetVehicleEngineOn(vehicle, true, false, true)
            Config.ShowInstruction(false)
            Config.ShowNotify(Config.Translate['hotwire'], 'success')

            SetVehicleDoorsLocked(vehicle, 1)
            SetVehicleDoorsLockedForAllPlayers(vehicle, false)
            DecorSetBool(vehicle, 'xd_locksystem', false)

            TriggerServerEvent('xd_locksystem:setVehicleLockpicked', GetVehicleNumberPlateText(vehicle))
        else
            Config.ShowNotify(Config.Translate['hotwire_fail'], 'warning')
            Config.ShowInstruction(Config.Translate['hotwire_helpbox'], vehicle, lockpickKey)
        end
    else
        Config.ShowNotify(Config.Translate['hotwire_stop'], 'default')
        Config.ShowInstruction(Config.Translate['hotwire_helpbox'], vehicle, lockpickKey)
    end

    isHotwire = false
end)
RegisterKeyMapping('xd_locksystem:lockpick', '.2 Lockpick vehicle', 'keyboard', 'E')

RegisterNetEvent('xd_locksystem:PlaySound', function(name, entityNet)
    while not RequestScriptAudioBank('locksystem', false) do Wait(10) end

    local soundId = GetSoundId()
    PlaySoundFromEntity(soundId, name, NetToEnt(entityNet), 'xd_locksystem_soundset', true, true)
    ReleaseSoundId(soundId)
end)

AddEventHandler('onResourceStop', function(res)
    if res ~= GetCurrentResourceName() then return end

    ClearAllHelpMessages()
end)

--[[
    Commands
]]--
-- shuffle
RegisterNetEvent('xd_locksystem:shuffle', function()
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    if vehicle == 0 then return end
    
    local maxSeats = GetVehicleModelNumberOfSeats(GetEntityModel(vehicle))
    local currentSeat = false
    for i=-1, maxSeats do
        if GetPedInVehicleSeat(vehicle, i) == PlayerPedId() then
            currentSeat = i
            break
        end
    end
    
    if not currentSeat then return end
    
    local nextSeat = false
    if currentSeat % 2 ~= 0 then
        nextSeat = currentSeat+1
    else
        nextSeat = currentSeat-1
    end
    
    if IsVehicleSeatFree(vehicle, nextSeat) then
        TaskShuffleToNextVehicleSeat(PlayerPedId(), vehicle)
    end
end)

-- givekey
RegisterNetEvent('xd_locksystem:givekey.notify', function(msg, msgType)
    if not msg then return end
    if not msgType then msgType = 'default' end
    
    Config.ShowNotify(msg, msgType)
end)

RegisterNetEvent('xd_locksystem:givekey', function(targetId)
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    if vehicle == 0 then
        local coords = GetEntityCoords(PlayerPedId())
        local offset = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, Config.Distance.Lock * 1.0, 0.0)
        local shape = StartShapeTestCapsule(coords, offset, 10, PlayerPedId(), 0)
        local retval, hit, endCoords, surfaceNormal, veh = GetShapeTestResult(shape)

        vehicle = veh
    end

    if not vehicle or vehicle == 0 then
        Config.ShowNotify(Config.Translate['givekey_no_vehicle'], 'error')
        return
    end

    local plate = GetVehicleNumberPlateText(vehicle)
    local VehicleData = GetVehicleData(plate)
    if VehicleData.keys ~= 'self' then
        Config.ShowNotify(Config.Translate['givekey_no_keys'], 'error')
        return
    end

    TriggerServerEvent('xd_locksystem:givekey', plate, targetId)
    Config.ShowNotify(Config.Translate['givekey']:format(plate), 'warning')
end)