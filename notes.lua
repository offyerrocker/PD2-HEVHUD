--[[
TODO:
	
	Assets
		Find a font that works for teammate names (support wide variety of characters)
		Find a font that works for small readouts eg. teammate ammo counters/equipment counter- something bold, prob.
		Better zipties icon
		
	Mission text
		ASSIGNMENT TERMINATED SUBJECT FREEMAN etc etc
	scanline effect
		either generic blob oval, or special special font (not recommended- prone to clipping)
	Ammo Pickup in HUD
		also show health 'pickups' on right side
		heck, show special equipment pickups too
	General
		OnSettings/Config Changed hooks
	Vitals
		Neater revives counter (needs design too)
	Weapons
		Neater firemode readout
		Weapon icons?
		Melee
		possible issue: bgbox flashing may interfere with equip/unequip alpha anim?
	Teammates
		- interaction
		- deployable
		- throwable; cooldown?
		- bag (needs resizing)
		- colors need to be tweaked; white should probably be normal, instead of orange, otherwise it blends too much
	Equipment
		?????????
		Special equipment
		Active Ability timer
		Deployables
			Primary/secondary
		Cable Ties
	Special crosshair (customizable target)
		needs menu options
	HL2 style loadout
	Hints/Popups
		ez
	Objectives
		???
	Assault Banner
		????
	Hostages
		????
		maybe in the Jokers panel? also show the following civ in "SQUAD FOLLOWING" hud 
	Lootscreen
		???
	Custom drag+drop?
	HUDHitDamage
		* simple radial red line to show hit direction?
			tf2 style



	
	looks like i have to (re)invent a lot of language for HEVHUD,
	because hl2 is a much more mechanically simple game than pd2 (not lesser, but having less complexity),
	and doesn't have equivalents for the type of information in pd2's hud
	(progress bars, status/modals and state transitions);
	furthermore, pd2 just has a lot *more* information than hl2
	
	
	


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