**Welcome Everybody for my first Release!**<br>
This script is completely **Free**.

So I've seen a lot of requests in onyxLocksystem for fixed  and better version so I decided to create one!

Of course I asked first for permission from HighHowdy (Creator of onyxLocksystem) to use the script idea and some of his code!<br>
<br>**So Big Credit to @HighHowdy**
*********************************************************************
**Features**
* Locking/Unlocking vehicles with keys
* Hotwiring vehicles with multiple stages
* Searching the vehicles to find a spare keys
* Steal keys from locals by holding them up
* Give keys to other player
* Everything Synced with the server
* A lot of Settings in Config file!
*********************************************************************
**Dependency**
* [es_extended](https://github.com/esx-framework/esx-legacy)
* Any Notify System - make sure to change to your notify in client if you have custom notify
* same as above for progress bars
*********************************************************************
**Exports**<br>
give player keys
```
exports['xd_locksystem']:givePlayerKeys(plate)
```
take player keys
```
exports['xd_locksystem']:takePlayerKeys(plate)
```
*********************************************************************
**Developers - Check Player Keys**
if you want to add check for keys to one of your script, you can use this in your client files
* **plate** - the vehicle plate you want to check key for.
* **hasKeys** - return true if player has the keys for vehicle else false.
```
ESX.TriggerServerCallback('xd_locksystem:getKeys', function(hasKeys)
	if hasKeys then
		print('Player has the key for the vehicle!')
	end
end, plate)
```
*********************************************************************
**Lockpick**
While in hotwire you can have big chance to fail, but with lockpick you will succeed everytime you using it in vehicle, but you have a chance written in the config for the lockpick to break and not succeed!
*********************************************************************
**Help!**
For any help type in the comments your issue or open issue in github where the download link is
recommended to open issue in github :slight_smile: 
*********************************************************************
**Video**<br>
[Click Here](https://streamable.com/hq1ykl) for Video!
*********************************************************************
**Download**<br>
[Click Here](https://github.com/LielXD/xd_locksystem) to Download!
*********************************************************************
***XD_LOCKSYSTEM v1.1.0***<br>
**Fixed**
* Player camera only moved left or right without bottom and up when hotwire/search
* Fixed exports when taking or giving vehicle keys it takes few sec to update now its updating automatically

**Added**
* New Settings for Config file
* Support for esx_notify
* Support for esx_progressbar
* Support for Custom Notify/Custom ProgressBars
* Custom Translate Options in Config
