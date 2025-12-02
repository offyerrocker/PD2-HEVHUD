local HEVHUD = {}

HEVHUD._font_icons = {
	physgun_fill = "!",
	pound = "#",
	revolver_fill = "$",
	pistol_fill = "%",
	smg_fill = "&",
	supers2 = "'", --superscript 2 from half life 2 title
	shotgun_fill = "(",
	crossbow_fill = ")",
	energy_box = "*",
	health_box = "+",
	comma = ",",
	hyphen = "-",
	period = ".",
	slash = "/",
	zero = "0",
	one = "1",
	two = "2",
	three = "3",
	four = "4",
	five = "5",
	six = "6",
	seven = "7",
	eight = "8",
	nine = "9",
	pulse_fill = ":",
	rpg_fill = ";",
	arrow_left = "<",
	arrow_up = "=",
	arrow_right = ">",
	arrow_down = "?",
	halflife2_icon = "@",
	lambda = "A",
	demo_d = "B",
	follower = "C",
	follower_run = "D",
	hl_e = "E",
	hl_f = "F",
	demo_e = "G",
	hl_h = "H",
	hl_i = "I",
	demo_m = "J",
	demo_o = "K",
	hl_l = "L",
	medic = "M",
	medic_run = "N",
	cross_pair_thin = "O",
	pause = "P",
	cross_dots = "Q",
	play = "R",
	ffwd = "S",
	stop = "T",
	rev = "U",
	valve = "V",
	frev = "W",
	next_chapter = "X",
	prev_chapter = "Y",
	rec = "Z",
	cross_left_fill = "[",
	crouch = "\\",
	cross_right_fill = "]",
	crowbar_fill = "^",
	grenade_fill = "_",
	toilet = "`",
	smg_empty = "a",
	shotgun_empty = "b",
	crowbar_empty = "c",
	pistol_empty = "d",
	revolver_empty = "e",
	oicw_empty = "f",
	crossbow_empty = "g",
	tau_empty = "h",
	rpg_empty = "i",
	bait_empty = "j",
	grenade_empty = "k",
	pulse_empty = "l",
	physgun_empty = "m",
	baton_empty = "n",
	slam_empty = "o",
	pistol_ammo = "p",
	revolver_ammo = "q",
	smg_ammo = "r",
	shotgun_ammo = "s",
	grenadelauncher_ammo = "t",
	pulse_ammo = "u",
	grenade_ammo = "v", --very similar to grenade_fill but horizontally flat
	crossbow_rebar = "w", --at least, i think it's rebar.
	rpg_ammo = "x",
	gauss_ammo = "y", --placeholder for cut content, evidently
	darkenergy_ammo = "z", 
	cross_left_empty = "{",
	crossbow_bolt = "|", --not sure why there's two versions?
	cross_right_empty = "}",
	bait_fill = "~",
	flashlight_on = "©", --copyright symbol (circled c)
	flashlight_off = "®" -- registered trademark symbol (circled r)
}

HEVHUD.FIRE_MODE_IDS = {
	single = Idstring("single"),
	auto = Idstring("auto"),
	burst = Idstring("burst"),
	volley = Idstring("volley")
}

HEVHUD.HEVHUD_ICONS = {
	revives = {0,0,32,32},
	teammate_vitals_fill = {32,0,32,32},
	teammate_vitals_line = {64,0,32,32},
	EMPTY4 = {96,0,32,32},
	firemode_single = {0,32,32,32},
	firemode_burst = {32,32,32,32},
	firemode_auto = {64,32,32,32},
	firemode_volley = {96,32,32,32},
	teammate_ammo = {0,64,32,32},
	triangle_line = {32,64,32,32},
	EMPTY11 = {64,64,32,32},
	EMPTY12 = {96,64,32,32},
	EMPTY13 = {0,96,32,32},
	EMPTY14 = {32,96,32,32},
	EMPTY15 = {64,96,32,32},
	EMPTY16 = {96,96,32,32}
}

function HEVHUD.GetWeaponBlackmarketIcon(weapon_id)
	local wtd = weapon_id and tweak_data.weapon[weapon_id]
	if not wtd then
		-- error
		return
	end
	
	local guis_catalog = "guis/"
	local bundle_folder = wtd.texture_bundle_folder
	if bundle_folder then
		guis_catalog = guis_catalog .. "dlcs/" .. tostring(bundle_folder) .. "/"
	end
	guis_catalog = guis_catalog .. string.format("textures/pd2/blackmarket/icons/weapons/%s",weapon_id)
	
	return guis_catalog,nil
end

function HEVHUD:GetIconData(icon_id)
	local rect = self.HEVHUD_ICONS[icon_id]
	if rect then
		return "guis/textures/hevhud_icons",rect
	end
end

--- returns string ammo_char,string empty_weapon_char,string full_weapon_char

function HEVHUD.GetHL2WeaponIcons(weapon_id,categories)
	local overrides = {
		rpg7 = {"rpg_ammo","rpg_full","rpg_empty"}, --rocket launchers in pd2 don't have a separate category; they're all classed as grenade_launcher
		ray = {"rpg_ammo","rpg_full","rpg_empty"} --commando rocket launcher
	}
	if not weapon_id then
		return
	end
	if overrides[weapon_id] then 
		return unpack(overrides[weapon_id])
	end
	
	if not categories then
		categories = tweak_data.weapon[weapon_id] and tweak_data.weapon[weapon_id].categories or {}
	end
	
	local is_revolver
	local is_pistol 
	for _,cat in pairs(categories) do
		if cat == "revolver" then 
			is_revolver = true
		end
		if cat == "crossbow" then 
			return "crossbow_rebar","crossbow_fill","crossbow_empty"
		elseif cat == "bow" then 
			return "crossbow_bolt","crossbow_fill","crossbow_empty"
		elseif cat == "grenade_launcher" then 
			return "grenadelauncher_ammo","grenade_fill","grenade_empty"
		elseif cat == "shotgun" then 
			return "shotgun_ammo","shotgun_fill","shotgun_empty"
		elseif cat == "smg" then 
			return "smg_ammo","smg_fill","smg_empty"
		elseif cat == "lmg" then 
			return "pulse_ammo","pulse_fill","pulse_empty"
		elseif cat == "minigun" then
			return "pulse_ammo","pulse_fill","pulse_empty"
		elseif cat == "snp" then 
			return "pulse_ammo","pulse_fill","pulse_empty"
		elseif cat == "assault_rifle" then 
			return "smg_ammo","smg_fill","smg_empty"
		elseif cat == "pistol" then 
			is_pistol = true
		elseif cat == "saw" then 
			return "darkenergy_ammo","pulse_fill","pulse_empty"
		elseif cat == "flamethrower" then
			return "darkenergy_ammo","pulse_fill","pulse_empty"
		end
	end
	if is_pistol then 
		if is_revolver then 
			return "revolver_ammo","revolver_fill","revolver_empty"
		else
			return "pistol_ammo","pistol_fill","pistol_empty"
		end
	end
end

function HEVHUD.color_to_colorstring(color) -- from colorpicker; serialize a Color userdata as a hexadecimal string
	return string.format("%02x%02x%02x", math.min(math.max(color.r * 255,0),0xff),math.min(math.max(color.g * 255,0),0xff),math.min(math.max(color.b * 255,0),0xff))
end

--function HEVHUD.colordecimal_to_string(n) end -- todo

function HEVHUD.colordecimal_to_colorstring(n)
	return string.format("%06x",n)
end

function HEVHUD.colordecimal_to_color(n)
	return Color(string.format("%06x",n))
end

function HEVHUD:CreateHUD(parent_hud)
	self._ws = managers.hud._workspace --managers.gui_data:create_fullscreen_workspace()
	if not parent_hud then 
		return
	end
	if alive(self._panel) then
		self._panel:parent():remove(self._panel)
		self._panel = nil
	end
	
	local hl2 = parent_hud:panel({--self._ws:panel():panel({
		name = "hevhud"
	})
	self._panel = hl2
	
	local settings = HEVHUDCore.settings
	local config = HEVHUDCore.config
	
	self._hud_vitals = HEVHUDCore:require("classes/HEVHUDVitals"):new(hl2,settings,config)
	self._hud_weapons = HEVHUDCore:require("classes/HEVHUDWeapons"):new(hl2,settings,config)
	self._hud_carry = HEVHUDCore:require("classes/HEVHUDCarry"):new(hl2,settings,config)
	self._hud_followers = HEVHUDCore:require("classes/HEVHUDFollowers"):new(hl2,settings,config)
	self._hud_crosshair = HEVHUDCore:require("classes/HEVHUDCrosshair"):new(hl2,settings,config)
	self._hud_hitdirection = HEVHUDCore:require("classes/HEVHUDHitDirection"):new(hl2,settings,config)
	self._hud_pickup = HEVHUDCore:require("classes/HEVHUDPickup"):new(hl2,settings,config) -- special equipment and ammo pickups
	self._teammate_panels = {}
	
	self:CreateTeammatesPanel(hl2) -- create separate panel to hold each individual teammate panel
	
	--self._hud_hint = HEVHUDCore:require("classes/HEVHUDHint"):new(hl2,settings,config)
	--self._hud_objectives = HEVHUDCore:require("classes/HEVHUDObjectives"):new(hl2,settings,config)
	
	local HEVHUDTeammate = HEVHUDCore:require("classes/HEVHUDTeammate")
	local y = config.Teammate.TEAMMATE_Y
	for i=1,4 do 
		local teammate = HEVHUDTeammate:new(hl2,settings,config,i)
		self._teammate_panels[i] = teammate 
		teammate._panel:set_y(y + config.Teammate.TEAMMATE_VER_MARGIN)
		y = teammate._panel:bottom()
	end
end

function HEVHUD:CreateTeammatesPanel(parent)
	if alive(self._teammates_panel) then
		self._teammates_panel:parent():remove(self._teammates_panel)
		self._teammates_panel = nil
	end
	self._teammates_panel = parent:panel({
		name = "teammates",
		valign = "grow",
		halign = "grow",
		layer = 1
	})
end
--[[
function HEVHUD:AddTeammatePanel(character_name,player_name,ai,peer_id)
	local HUDTeammateClass = HEVHUDCore:require("classes/HEVHUDTeammate")
	
end

function HEVHUD:RemoveTeammatePanel(character_name,player_name,ai,peer_id)
end
--]]

function HEVHUD:UpdateGame(t,dt)
	-- game update
	local player = managers.player:local_player()
	if player then
		self._hud_vitals:set_sprint_on(player:movement():current_state():running())
	end
end
Hooks:Add("GameSetupUpdate","hevhud_updategame",callback(HEVHUD,HEVHUD,"UpdateGame"))

function HEVHUD:OnSwitchWeapon(weap_base) -- called when swapping weapons or when swapping underbarrel
	self:CheckWeaponUnderbarrelActive(weap_base)
	self:CheckWeaponHasUnderbarrel(weap_base)
	self:CheckUnderbarrelAmmo(weap_base)
end

function HEVHUD:CheckWeaponFiremode(weap_base)
	local firemode = self:GetFiremodeName(weap_base._fire_mode)
	if firemode then
		self._hud_weapons:set_main_weapon_firemode(firemode,not weap_base._locked_fire_mode and weap_base:can_toggle_firemode())
	end
end

function HEVHUD:CheckWeaponGadgets(weap_base)
	if not weap_base._assembly_complete then
		return nil
	end
	
	local gadgets = managers.weapon_factory:get_parts_from_weapon_by_type_or_perk("gadget", weap_base._factory_id, weap_base._blueprint)
	if gadgets then
		for i, id in ipairs(gadgets) do
			local gadget = weap_base._parts[id]
			local gadget_base = gadget and gadget.unit:base()
			if gadget_base then
				local gadget_type = gadget_base.GADGET_TYPE
				if gadget_type == WeaponFlashLight.GADGET_TYPE then -- "flashlight"
					if gadget_base:is_on() then
						-- if any flashlights are on in the current weapon, show flashlight indicator in hud
						return self:SetFlashlightState(true)
					end
				end
			end
		end
	end
	return self:SetFlashlightState(false)
end

function HEVHUD:SetFlashlightState(state)
	self._hud_vitals:set_flashlight_on(state)
	return state
end

--function HEVHUD:CheckAmmoIcons(weap_base) end

function HEVHUD:GetFiremodeName(ids)
	for name,v in pairs(self.FIRE_MODE_IDS) do 
		if v == ids then
			return name
		end
	end
end

-- also checks underbarrel firemode
function HEVHUD:CheckUnderbarrelAmmo(weap_base)
	for _,underbarrel_base in pairs(weap_base:get_all_override_weapon_gadgets()) do 
		local magazine_max,magazine_current,reserves_current,reserves_max = RaycastWeaponBase.ammo_info(underbarrel_base)
		
		self._hud_weapons:set_underbarrel_ammo(magazine_max,magazine_current,reserves_current,reserves_max)
		
		local underbarrel_icon = self.GetHL2WeaponIcons(underbarrel_base.name_id)
		if underbarrel_icon then
			self._hud_weapons:set_underbarrel_ammo_icon(self._font_icons[underbarrel_icon])
		end
		
--		local firemode = weap_base:gadget_function_override("fire_mode") -- only works if the underbarrel is active
		local firemode = self:GetFiremodeName(underbarrel_base._fire_mode)
		if firemode then 
			self._hud_weapons:set_underbarrel_weapon_firemode(firemode,false) -- i actually don't know if underbarrels are allowed to toggle firemodes, or what that check looks like
		end
		
		-- only perform this check for the "first" of the underbarrels;
		-- assume there is only one underbarrel per weapon
		-- (i hope.)
		break
	end
end

function HEVHUD:CheckWeaponUnderbarrelActive(weap_base)
	local underbarrel_base = weap_base and weap_base:gadget_overrides_weapon_functions()
	if underbarrel_base then
		return self._hud_weapons:set_underbarrel_on(true)
	end
	return self._hud_weapons:set_underbarrel_on(false)
end

-- check whether there is an underbarrel on this weapon at all, regardless of active state
function HEVHUD:CheckWeaponHasUnderbarrel(weap_base)
	for _,underbarrel_base in pairs(weap_base:get_all_override_weapon_gadgets()) do
		return self._hud_weapons:set_underbarrel_visible(true)
	end
	return self._hud_weapons:set_underbarrel_visible(false)
end

function HEVHUD:SetAmmoAmount(index,magazine_max,magazine_current,reserves_current,reserves_max)
	-- since HEVHUD has a separate counter for the underbarrel which is non-exclusive with the ordinary ammo counter,
	-- HEVHUD just gets the ammo info for whatever the equipped (main, not underbarrel) weapon is
	-- and updates the underbarrel info separately
	
	local turret_unit = managers.player:get_local_player_turret()
	local weapon_unit
	local inv_ext = managers.player:local_player():inventory()
	if alive(turret_unit) then
		weapon_unit = turret_unit
	else
		local _weapon_unit = inv_ext:equipped_unit()
		if alive(_weapon_unit) then
			weapon_unit = _weapon_unit
		end
	end
	
	local is_equipped = inv_ext:equipped_selection() == index
	
	if weapon_unit then
		local weap_base = weapon_unit:base()
		self:CheckUnderbarrelAmmo(weap_base) -- update underbarrel ammo info
		local underbarrel = weap_base:gadget_overrides_weapon_functions()
		if underbarrel then
			-- specifically use the individual getters; ammo_info() will return the underbarrel ammo data
			-- (so, get the base weapon ammo here)
			
			-- can use the below for explicit underbarrel ammo if i decide not to trust the ammo info passed to this function
--			local umagazine_max,umagazine_current,ureserves_current,ureserves_max = RaycastWeaponBase.ammo_info(underbarrel)
			Hooks:Call("HEVHUD_Crosshair_Listener",{
				source = "weapon",
				slot = index + 2,
				is_equipped = true,
				magazine_current = magazine_current,
				magazine_max = magazine_max,
				reserves_current = reserves_current,
				reserves_max = reserves_max
			})
			is_equipped = false -- don't tell the crosshair ammo that the base weapon is equipped if the underbarrel is active
			
			-- todo set crosshair ammo of non-equipped underbarrels?
			
			magazine_max,magazine_current,reserves_current,reserves_max = weap_base:get_ammo_max_per_clip(),weap_base:get_ammo_remaining_in_clip(),weap_base:get_ammo_total(),weap_base:get_ammo_max()
		elseif not is_equipped then
			return
		else
			self:CheckWeaponFiremode(weap_base)
			local categories = weap_base.categories and weap_base:categories()
			local weapon_id = weap_base.get_name_id and weap_base:get_name_id()
			local icon = self.GetHL2WeaponIcons(weapon_id,categories,nil)
			if icon then
				self._hud_weapons:set_main_ammo_icon(self._font_icons[icon])
			end
		end
	end
	
	-- update the base weapon ammo
	Hooks:Call("HEVHUD_Crosshair_Listener",{
		source = "weapon",
		slot = index,
		is_equipped = is_equipped,
		magazine_current = magazine_current,
		magazine_max = magazine_max,
		reserves_current = reserves_current,
		reserves_max = reserves_max
	})
	
	
	
	self._hud_weapons:set_main_ammo(magazine_max,magazine_current,reserves_current,reserves_max)
end

function HEVHUD:ShowCarry(carry_id,value,...)
	self._hud_carry:show_carry_bag(carry_id,value,...)
end

function HEVHUD:HideCarry(...)
	self._hud_carry:hide_carry_bag(...)
end

function HEVHUD:SetTeammateName(id,name)
	self._teammate_panels[id]:set_name(name)
end

function HEVHUD:SetTeammateCondition(id,icon_id,text)
	self._teammate_panels[id]:set_condition(icon_id,text)
end

function HEVHUD:SetTeammateAmmo(id, selection_index, max_clip, current_clip, current_left, max)
	self._teammate_panels[id]:set_ammo(selection_index, max_clip, current_clip, current_left, max)
end

function HEVHUD:SetTeammateCabletiesData(id,data)
	self._teammate_panels[id]:set_zipties_data(data)
end

function HEVHUD:SetTeammateCabletiesAmount(id,amount)
	self._teammate_panels[id]:set_zipties_amount(amount)
end

function HEVHUD:SetTeammateGrenadeData(id,data)
	self._teammate_panels[id]:set_grenades_data(data)
end
function HEVHUD:SetTeammateGrenadeAmount(id,data)
	self._teammate_panels[id]:set_grenades_amount(data)
end
function HEVHUD:SetTeammateGrenadeCooldown(id,data)
	self._teammate_panels[id]:set_grenades_cooldown(data)
end

function HEVHUD:AddTeammateSpecialEquipment(id,data)
	self._teammate_panels[id]:add_special_equipment(data)
end
function HEVHUD:RemoveTeammateSpecialEquipment(id,equipment_id)
	self._teammate_panels[id]:remove_special_equipment(equipment_id)
end
function HEVHUD:SetTeammateSpecialEquipmentAmount(id,equipment_id,amount)
	self._teammate_panels[id]:_add_special_equipment(equipment_id,amount)
end
function HEVHUD:SetTeammateCarry(id,carry_id,value)
	self._teammate_panels[id]:set_carry(carry_id,value)
end
function HEVHUD:RemoveTeammateCarry(id)
	self._teammate_panels[id]:stop_carry()
end

function HEVHUD:CheckPlayerDeployables(equipment)
	-- ignore data entirely basically;
	-- because pd2 hud is set up to only show one deployable at a time regardless of how many you have (Jack of All Trades),
	-- the hud "lies" and says that the equipped deployable is always slot 1.
	-- so, i just use the function as an event that cues HEVHUD to check the deployables by itself.
	
	for slot,data in pairs(managers.player._equipment.selections) do 
		self._hud_weapons:set_equipment(slot,data)
	end
	self._hud_weapons:set_selected_equipment_slot(managers.player._equipment.selected_index)
	
end

function HEVHUD:SetTeammateDeployableData(id,data)
	self._teammate_panels[id]:add_special_equipment(data)
end

function HEVHUD:SetTeammateDeployableFromString(id,data)
	self._teammate_panels[id]:add_special_equipment(data)
end
function HEVHUD:AddMinion(ukey,unit)
	self._hud_followers:add_follower(ukey)
	if alive(unit) then
		-- add damage listeners
		local dmg_ext = unit:character_damage()
		if dmg_ext then
			dmg_ext:add_listener(
				"hevhud_on_minion_damaged",
				{
					-- kinda guessing that all of these damage types will be appropriately called tbh
					"bullet",
					"melee",
					"poison",
					"fire",
					"explosion",
					"mission",
					"graze",
					"simple",
					"dmg_rcv",
					"hurt"
				},
				function(hit_unit,dmg_info)
					self._hud_followers:set_follower_hp(ukey,hit_unit:character_damage():health_ratio())
				end
			)
		end
	end
end
	
function HEVHUD:RemoveMinion(ukey)
	self._hud_followers:remove_follower(ukey,nil,nil)
end

function HEVHUD:ShowAmmoPickup(slot,weapon_id,amount,override_ammo_char,override_weapon_icon,override_weapon_rect)

	local ammo_text = override_ammo_char or HEVHUD._font_icons[self.GetHL2WeaponIcons(weapon_id) or ""]
	
	local weapon_texture,weapon_rect
	if override_weapon_icon then
		weapon_texture,weapon_rect = override_weapon_icon,override_weapon_rect
	else
		weapon_texture,weapon_rect = self.GetWeaponBlackmarketIcon(weapon_id)
	end
	
	self._hud_pickup:add_ammo_pickup(slot,amount,ammo_text,weapon_texture,weapon_rect)
end

--[[
function HEVHUD:UpdatePaused(t,dt)
	-- paused update
end
Hooks:Add("GameSetupUpdate","hevhud_updatepaused",callback(HEVHUD,HEVHUD,"UpdatePaused"))
--]]

function HEVHUD.check_crosshair_listener(setting,params)
--[[
	crosshair indicator trackers:
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
--]]
	local source_types = {
		[1] = "health",
		[2] = "armor",
		[3] = "weapon",
		[4] = "weapon",
		[5] = "weapon",
		[6] = "weapon",
		[7] = "weapon",
		[8] = "weapon",
		[9] = "perk"
	}
	local source = params.source
	if source_types[setting] == source then 
		if setting == 1 then
			return params.current/params.total
		elseif setting == 2 then
			return params.current/params.total
		elseif source == "weapon" then 
			if setting == 3 then 
				if params.is_equipped then 
					return params.magazine_current/params.magazine_max
				end
			elseif setting == 4 then 
				if params.slot == 2 then 
					return params.magazine_current/params.magazine_max
				end
			elseif setting == 5 then 
				if params.slot == 1 then 
					return params.magazine_current/params.magazine_max
				end
			elseif setting == 6 then 
				if params.is_equipped then 
					return params.reserves_current/params.reserves_max
				end
			elseif setting == 7 then 
				if params.slot == 2 then 
					return params.reserves_current/params.reserves_max
				end
			elseif setting == 8 then 
				if params.slot == 1 then 
					return params.reserves_current/params.reserves_max
				end
			end
		elseif setting == 9 then
			local equipped_perk_deck --blackmarket equipped specialization blah blah blah
			--these need to be done on a case-by-case basis 
		end
	end
	return nil
end

function HEVHUD:GetRangedColor(n)
	if n < 0.33 then
		return self.colordecimal_to_color(HEVHUDCore.settings.color_hl2_red)
	elseif n < 0.66 then
		return self.colordecimal_to_color(HEVHUDCore.settings.color_hl2_orange)
	else
		return self.colordecimal_to_color(HEVHUDCore.settings.color_hl2_yellow)
	end
end

Hooks:Register("HEVHUD_Crosshair_Listener")
Hooks:Add("HEVHUD_Crosshair_Listener","HEVHUD_OnCrosshairListenerEvent",function(params)
	local value = HEVHUD.check_crosshair_listener(HEVHUDCore.settings.crosshair_indicator_left_tracker,params)
	if value then
		HEVHUD._hud_crosshair:set_left_crosshair(value)
	end
	
	value = HEVHUD.check_crosshair_listener(HEVHUDCore.settings.crosshair_indicator_right_tracker,params)
	if value then
		HEVHUD._hud_crosshair:set_right_crosshair(value)
	end
end)

return HEVHUD