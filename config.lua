-- XD_Locksystem | Creator: LielXD --

Config = {}

Config.checkKeyInterval = 5000				-- Interval to check Keys when player in car | current 6s

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
