Config = {}

Config.Framework = false    -- you can use these frameworks: 'esx', 'qbcore', false for standalone anything else will be as standalone.

Config.LoudRadio = true     -- Will set vehicles radio loud so players can hear them outside the vehicle too.

Config.NpcOpenChance = 5    -- The chance of a npc vehicle being open. default: 1/5 chance.

Config.minigame = 10        -- The minigame timer.

Config.Player = {
    kick = true,            -- Enable kick out other players from vehicle by holding F.
    shuffle = false,        -- Enable auto shuffle vehicle seats.
    autoEngine = false,     -- Enable auto turn on/off engine when player exit vehicle.
}

Config.Distance = {
    Rob = 8,                -- Distance to aim at npc to start rob.
    Lock = 15,              -- Distance to lock/unlock vehicle.
    Givekey = 5             -- Distance range player needs to be to be able to get keys.
}

Config.Hotwire = {
    chance = 3,             -- The success chance of the hotwire. default: 1/3 chance.
    time = 5,               -- The time each hotwire will take in seconds.
    police = 5,             -- The chance the police will get alert. default: 1/5 chance, false for no alert.

    -- The function that will run once the police get alert, place here your police alert script.
    policeFunc = function(vehicle)
        SetVehicleAlarm(vehicle, true)
		StartVehicleAlarm(vehicle)

        print('police alert')
    end
}

if not IsDuplicityVersion() then


-- Add here your custom Notify system of leave it to use in game notify.
Config.ShowNotify = function(msg, msgType)
    AddTextEntry('xd_locksystem', msg)
    BeginTextCommandDisplayHelp('xd_locksystem')
    EndTextCommandDisplayHelp(0, false, true, 3000)
end

--[[
    if you have any different instruction script you can set it here,
    if not you can use the in game help text box.
]]--
Config.ShowInstruction = function(msg, ent, instructionKey)
    -- change here to your client function/export.

    -- remove the instruction.
    if not msg then
        ClearAllHelpMessages()
        return
    end

    -- show the instruction.
    CreateThread(function()
        AddTextEntry('xd_locksystem', msg)
        BeginTextCommandDisplayHelp('xd_locksystem')
        EndTextCommandDisplayHelp(1, true, true, -1)

        SetFloatingHelpTextStyle(0, 0, 158, 150, 0, 0)
        SetFloatingHelpTextToEntity(0, ent)
    end)
end


end

Config.Translate = {
    -- lock system
    ['lock_no_keys'] = 'You don\'t have keys to that vehicle',
    ['locked'] = 'Vehicle locked',
    ['unlocked'] = 'Vehicle unlocked',

    -- rob
    ['rob_helpbox'] = 'Press   ~INPUT_C7DC9306~to rob the keys',
    ['rob'] = 'You robbed the keys',

    -- lockpick
    ['lockpick_helpbox'] = 'Press   ~INPUT_DF83D996~to try breaking into the vehicle',
    ['lockpick_win'] = 'You lockpicked the vehicle',
    ['lockpick_lost'] = 'You could\'nt lockpick the vehicle',

    -- hotwire
    ['hotwire_helpbox'] = 'Press   ~INPUT_DF83D996~to try hotwire the vehicle',
    ['hotwire_helpbox_stop'] = 'Press   ~INPUT_DF83D996~to stop the hotwire',
    ['hotwire_stop'] = 'You\'ve stopped the hotwire',
    ['hotwire_fail'] = 'You could\'nt hotwire the vehicle',
    ['hotwire'] = 'You\'ve hotwired the vehicle',

    -- minigame
    ['minigame_ready'] = 'Get Ready',
    ['minigame_start'] = 'Game started',
    ['minigame_success'] = 'You succeed',
    ['minigame_failed'] = 'You failed',

    -- commands
    ['givekey_no_self'] = 'You can\'t give yourself the keys',
    ['givekey_no_player'] = 'Player not found',
    ['givekey_no_vehicle'] = 'No vehicle found',
    ['givekey_no_keys'] = 'You don\'t have keys to the vehicle',
    ['givekey'] = 'You gave your vehicle keys with plate: %s'
}