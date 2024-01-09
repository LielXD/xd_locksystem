Welcome to my release this version of the locksystem is much better from the previous one,
by performance, gameplay and features.

This script is completely **Free**.

![xd_locksystem_v2|690x388](https://forum.cfx.re/uploads/default/original/4X/a/3/9/a39e0f0184e72884af6034dc72f4ea6c52e9e151.png)

This resource will upgrade your roleplay server with more features for players to use with vehicles, to make the roleplay experience better.
*********************************************************************
**Features**
* Locking/Unlocking vehicles with animation and car key prop.
* Lockpick locked vehicles with a cool minigame.
* Hotwire vehicles to start the engine without keys.
* Rob keys from npc driving around you.
* Ability to give your keys to otherplayer.
* Everything Synced with the server.
* Many customizable configs to match your server prefrences.
*********************************************************************
**Developers**<br>

**Exports**<br>

To set owned vehicle keys you can use the exports below.

```lua
exports['xd_locksystem']:SetVehicleKey(plate, remove)
```
* **plate** - the vehicle license plate.

* **remove** - if true then it will remove the key from any player.

```lua
exports['xd_locksystem']:GetVehicleData(plate)
```
* **plate** - the vehicle plate you want to check key for.
<br>

  *this will return 2 values:*

* **keys** - with these values

  * false - no one have keys to the vehicle.

  * true - someone have keys to the vehicle.

  * 'self' - current player have keys to vehicle.

* **lockpick** - with these values

  * false - vehicle have not lockpicked.

  * true - vehicle lockpicked.

  * 'NPC' - used in the script to prevent from players to lockpick npc vehicles driving around.

**Example**<br>
client script:
```lua
RegisterCommand('engine', function()
	local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
	if vehicle ~= 0 then
		local plate = GetVehicleNumberPlateText(vehicle)
		local VehicleData = exports['xd_locksystem']:GetVehicleData(plate)

		-- make sure here to check if the current player have keys ↓
		if VehicleData.keys == 'self' then
			local engineState = GetIsVehicleEngineRunning(vehicle)
			SetVehicleEngineOn(vehicle, not engineState, false, true)
		end
	end
end)
```
*********************************************************************

**Give key to other player**

You can use the command:
```lua
/givekey [player_id]
```
**if there is no id specified then closest player will get the key.**

*********************************************************************
**Help!**
Please! if you need any help or found any bugs please open an issue at the resource github repository.
*********************************************************************
**Video**<br>
[Click Here](https://youtu.be/f0fnLGQ1yYs) for Video!
*********************************************************************
**Download**<br>
[Click Here](https://github.com/LielXD/xd_locksystem) to Download!
make sure you download from the releases section.
*********************************************************************
**My Scripts**<br>

* [xd_locksystem v1](https://forum.cfx.re/t/release-esx-xd-locksystem-vehicle-key-system/4849251)
* [xd_doorlock](https://forum.cfx.re/t/release-esx-xd-doorlock-door-lock-system/4859153)
* [xd_locksystem v2](https://forum.cfx.re/t/release-standalone-xd-locksystem-v2-vehicle-key-system/5200025)
