-- XD_Locksystem | Creator: LielXD --

function hasToggledLock()
    lockDisable = true
    Wait(2000)
    lockDisable = false
end

function playLockAnim()
    ESX.Streaming.RequestAnimDict('anim@mp_player_intmenu@key_fob@', function()
		if not IsPedInAnyVehicle(GetPlayerPed(-1), true) then
			TaskPlayAnim(PlayerPedId(), 'anim@mp_player_intmenu@key_fob@', 'fob_click_fp', 8.0, 8.0, -1, 48, 1, false, false, false)
		end
	end)
end

function getNearestVeh(radius)
	local pos = GetEntityCoords(GetPlayerPed(-1))
	local entityWorld = GetOffsetFromEntityInWorldCoords(GetPlayerPed(-1), 0.0, radius, 0.0)

	local rayHandle = CastRayPointToPoint(pos.x, pos.y, pos.z, entityWorld.x, entityWorld.y, entityWorld.z, 10, GetPlayerPed(-1), 0)
	local _, _, _, _, vehicleHandle = GetRaycastResult(rayHandle)
	
	local vehicleIsIn = GetVehiclePedIsIn(GetPlayerPed(-1), false)

	if vehicleIsIn ~= 0 then
		return vehicleIsIn
	else
		return vehicleHandle
	end
end

function DrawText3D(coords, text)
    SetTextScale(0.4, 0.4)
	SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(coords, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0+0.0125, 0.017 + factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end