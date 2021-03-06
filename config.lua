-- XD_Locksystem | Creator: LielXD --

Config = {}

Config.checkKeyInterval = 5000				-- Interval to check Keys when player in car | current 5s

Config.BlackList = {						-- Vehicles Script will not work on them
	-- Bikes
	'bmx',
	'cruiser',
	'fixter',
	'scorcher',
	'tribike',
	'tribike2',
	'tribike3'
}

Config.noKeys = {
	-- Hotwire
	HotwireKey = 74,						-- Hotwire key | Currently H
	HotwireChance = 5,						-- Hotwire success chance | Current 1 to 5
	HotwireAlarm = true,					-- Police alert | Current true, if true change the alarm in code to whatever script you have!
	HotwireAlarmChance = 3,					-- The chance to alert the police, only if above is true | Currently 1 to 3
	HotwireWait = 6000,						-- Amount of time to wait every progressbar | Currently 6s
	Hotwire_Stages = {						-- Add here as much stages as you want for the Hotwire | Current 4 stages
		'Preparing Hotwire',
		'Cutting Cables',
		'Hotwire Attempt',
		'Trying turning on Engine'
	},
	
	-- Search
	SearchKey = 47,							-- Search key | Currently G
	FoundKeyChance = 8,						-- Search key chance | Currently 1 to 8
	
	-- Lockpick
	LockpickBreakChance = 6,				-- The chance for lockpick to break | Currently 1 to 6
	
	-- Texts
	Text = 'Press ~p~[H]~w~ to ~p~Hotwire~w~   Press ~g~[G]~w~ to ~g~Search',	-- Text
	TextSearched = 'Press ~p~[H]~w~ to ~p~Hotwire~w~'							-- Text when vehicle already searched
}

Config.rob = {
	Key = 38,								-- The key to rob NPC keys | Currently E
	RunawayChance = 10,						-- The chance NPC will run with keys | Currently 1 to 10
	Text = 'Press ~p~[E]~w~ to ~p~rob~w~ the keys'
}

Config.key = {
	-- Lock / Unlock
	LockKey = 47,							-- Lock/Unlock key | Currently G
	
	-- GiveKey Command
	PlayerRadius = 8						-- The radius of player to givekey | Currently 8 Meters
}
-- You can find all controls Here ↓
-- https://docs.fivem.net/docs/game-references/controls/

Config.ESX_ProgressBar = true				-- If you want to use ESX progressbars | current true
Config.Custom_ProgressBar = function(Text, Time)
	
	--[[
		if ESX_ProgressBar is set to false then add here your custom progressbar
		for example
		exports['xd_progress']:drawBar(Time, Text)
	]]--
	
end

Config.ESX_Notify = true					-- If you want to use ESX notify | current true
Config.Custom_Notify = function(Text, Time, Type)

	--[[
		if ESX_Notify is set to false then add here your custom notify
		for example
		TriggerEvent('xd_notify:send', Text, Time, 'bottom', true, Type)
	]]--
	
end

Config.Translate = {
	['search'] = 'Searching Vehicle',
	['rob_key'] = 'taking the keys',
	['no_vehicles'] = 'No vehicle nearby',
	['give_yourself'] = 'You can\'t give yourself keys',
	['no_players'] = 'No players found',
	['give_key'] = 'You gave your keys of plate %s',
	['no_key'] = 'You don\'t have keys',
	['found_key'] = 'Found keys for plate %s',
	['notfound_key'] = 'Failed to found keys',
	['npc_run'] = 'the driver decided to runaway',
	['npc_key'] = 'you took the keys for plate %s',
	['give_key_target'] = 'You got vehicle keys for plate %s',
	['lockpick'] = 'The lockpick broke!',
	['hotwire_success'] = 'Hotwire succeed',
	['hotwire_failed'] = 'Hotwire failed',
	['locked'] = 'Vehicle Locked',
	['unlocked'] = 'Vehicle Unlocked',
	['not_in_vehicle'] = 'You have to be in vehicle to use this',
	['not_driver'] = 'You have to be the driver to hotwire the vehicle'
}
