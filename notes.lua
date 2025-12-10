--[[
TODO:
	
	BUGS
		firemode reappearing (as client)
		
		need better assets for underbarrel weapons in ammo pickup hud
		possible issue: bgbox flashing may interfere with equip/unequip alpha anim?
		
	
	FINAL STRETCH!
		- Cable Ties
		- Hostages
		- Teammate interaction
		- Teammate ability/swansong
		
		- Readability pass
	
	
	
	
	Assets
		Find a font that works for teammate names (support wide variety of characters)
		Find a font that works for small readouts eg. teammate ammo counters/equipment counter- something bold, prob.
		Better zipties icon
	scanline effect
		either generic blob oval, or special special font (not recommended- prone to clipping)
	Ammo Pickup in HUD
	General
		pager counter in stealth?
	Vitals
		Maniac
		Leech
		
		Swan Song
		
		Neater revives counter (needs design too)
	Weapons
	Teammates
		- maybe another text entry for interacting or bag carry name?
		- interaction
		- ability/swansong timer
		- colors need to be tweaked; white should probably be normal, instead of orange, otherwise it blends too much
		- detect ai carry state
	Equipment
		player deployable icon needs to be organized; icon and secondary amount are not centered
			tripmine dual amount is hard to read
		Cable Ties
	Special crosshair (customizable target)
		needs menu options
	HL2 style loadout
	Hints/Popups
		vertical margin
		reduce h
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
		hit display lasts too long- maybe custom solution that tracks the attacker unit?
		maybe need a minimum display instead of just hiding it so it doesn't "reappear" as a new hit when you look away and back
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

BeardLib:AddUpdater("hevhud_test",function(t,dt)
	if HEVHUD and HEVHUD._hud_presenter then
		Console:SetTracker(tostring(HEVHUD._hud_presenter._presenting) .. string.format("%0.2f",t),1)
	end
end)




function HEVHUDBase.CreateScanlinesBox(parent,params)
	if not alive(parent) then 
		--self:log("HEVHUD:CreateScanlines(" .. tostring(panel) .. "," .. tostring(count) .. "): bad panel")
		return
	end
	params = params or {}
	
	local panel = parent:panel({
		name = "scanlines",
		valign = "grow",
		halign = "grow",
		w = parent:w(),
		h = parent:h(),
		alpha = 0.5,
		layer = -1
	})
	if params.panel_config then
		panel:configure(params.panel_config)
	end
	
	local count = params.count or panel:h()
	local intensity = params.intensity or 0.5
	local intensity_deviance = params.intensity_deviance or 0.2
	local margin = params.margin or 0.15
	
	local visible = true
	if params.visible ~= nil then 
		visible = params.visible
	end
	local a_table = {}
	
	local color = HEVHUD.colordecimal_to_color(HEVHUDCore.settings.color_hl2_orange)
	for i=1,count do 
		local a_range = 0.5 + ((i % 2) / 2)
		local alpha = intensity + (math.random(intensity_deviance * 2 * 100) / 100) - intensity_deviance
		a_table[i] = alpha
		local gradient = panel:gradient({
			name = "scanline_" .. tostring(i),
			x = params.x or 0,
			y = params.y or ((i / count) * panel:h()),
			w = params.w or (panel:w()),
			h = params.h or (count / panel:h()),
			layer = params.layer or -1,
			alpha = alpha * math.sin(180 * i / count), --(((2 * i) / count) - (i / count)),
			blend_mode = params.blend_mode or "add",
			gradient_points = params.gradient_points or {
				0,
				color:with_alpha(0),
				margin,
				color:with_alpha(a_range),
				1 - margin,
				color:with_alpha(a_range),
				1,
				color:with_alpha(0)
			},
			visible = visible
		})
	end
	--[[
	local objectives_bg = panel:bitmap({
		name = "objectives_bg",
		layer = (params.layer or -1) + 1,
		texture = "guis/textures/pd2/hud_tabs",
		texture_rect = {84,0,44,32},
		w = panel:w(),
		h = panel:h(),
		alpha = 0.33 --0.75
	})
	--]]
	return panel,a_table
end

function AnimateLibrary.animate_scanlines(o,cb,duration,speed,alpha_table)
	if not alpha_table then return end
	local t = 0
	duration = duration or 3
	speed = speed or 10
	while t < duration do 
		local elapsed = t * speed
		for i = 1,#alpha_table do 
			local scanline = o:child("scanline_" .. tostring(i))
			
			if alive(scanline) then 
				local j = math.floor((i + elapsed) % #alpha_table) + 1
				if not alpha_table[j] then
					return true
				end
				scanline:set_alpha(math.sin(180 * (j / #alpha_table) * alpha_table[j]))
				scanline:set_y((j / #alpha_table) * o:h())
			end
		end
		t = t + coroutine.yield()
	end
	if cb then
		cb(o)
	end
end


	local scanlines,tbl = self.CreateScanlinesBox(crosshairs)
	self._alpha_table = tbl
	self._scanlines = scanlines
end

function HEVHUDCrosshair:set_right_crosshair(value)	
	self._scanlines:animate(AnimateLibrary.animate_scanlines,nil,3,1,self._alpha_table)
	













--]]