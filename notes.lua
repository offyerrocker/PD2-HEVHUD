--[[
TODO:
	
	BUGS
		hudpresenter is getting clogged again
		need better assets for underbarrel weapons in ammo pickup hud
		possible issue: bgbox flashing may interfere with equip/unequip alpha anim?
		hit display lasts too long- maybe custom solution that tracks the attacker unit?
		
	
	
	Assets
		Find a font that works for teammate names (support wide variety of characters)
		Find a font that works for small readouts eg. teammate ammo counters/equipment counter- something bold, prob.
		Better zipties icon
		
	scanline effect
		either generic blob oval, or special special font (not recommended- prone to clipping)
	Ammo Pickup in HUD
		show ACTUAL amount added, rather than max added
		show grenade pickups from fully loaded aced
	General
	Vitals
		Neater revives counter (needs design too)
	Weapons
	Teammates
		- down/custody timer
		- interaction
		- throwable cooldown
		- ability timer
		- bag (needs distinction from normal mission equipment)
		- colors need to be tweaked; white should probably be normal, instead of orange, otherwise it blends too much
	Equipment
		player deployable icon needs to be organized; icon and secondary amount are not centered
		Active Ability timer
		Cable Ties
	Special crosshair (customizable target)
		needs menu options
	HL2 style loadout
	Hints/Popups
		ez
	Assault Banner
		????
	Hostages
		cable ties next to hostages i guess
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