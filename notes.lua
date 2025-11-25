--[[
TODO:
	Assets
		Find a font that works for teammate names (support wide variety of characters)
	
	General
		OnSettings/Config Changed hooks
	Vitals
		Neater revives counter (needs design too)
		Workaround for no mul on bitmap	(check alpha channel in asset?)
			- Yep it's the alpha channel, that has to be explicit
	Weapons
		Neater firemode readout
		Weapon icons?
		Melee
	Teammates
		- colors need to be tweaked; white should probably be normal, instead of orange, otherwise it blends too much
	Equipment
		?????????
		Special equipment
		Throwable
		Deployables
			Primary/secondary
		Cable Ties
	Special crosshair (customizable target)
		1: health
		2: armor
		3: magazine (current)
		4: magazine (primary)
		5: magazine (secondary)
		6: reserve (current)
		7: reserve (primary)
		8: reserve (secondary)
		9: perk-deck-specific (stored health, absorption, etc)
		10: detection
	HL2 style loadout
	Ammo Pickup in HUD
	Hints/Popups
		ez
	Objectives
		???
	Assault Banner
		????
	Hostages
		????
	Lootscreen
		???
	Custom drag+drop?
	




[X][v]NAMEHERE
[1][2][G][Z]
[B][M]

----

[b] =  bag
[x]=status (custody/downed/swansong/throwable/low ammo)
[v] = vitals
[1] = deployable 1
[2] = deployable 2
[g] = grenade
[z] = zipties
[m] = missionequipment

* name must be character limited
	* or width limited?
- which element to use peercolor?
	



--]]


--[[ SNIPPETS
foobar = HEVHUDCore:require("classes/LIP").load(HEVHUDCore.USER_CONFIG_PATH)

--]]