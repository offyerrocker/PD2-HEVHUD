Hooks:PostHook(HUDManager,"_setup_player_info_hud_pd2","hevhud_hudmanager_create_hud",function(self)
	local hm = managers.hud:script(PlayerBase.PLAYER_INFO_HUD_PD2)
	local parent_panel = hm and hm.panel
	if alive(parent_panel) then 
		HEVHUD:CreateHUD(parent_panel)
--		HEVHUD:CreateHUD(parent_panel,HEVHUD:CheckFontResourcesReady(false,callback(HEVHUD,HEVHUD,"OnDelayedLoad")))
	end
end)



-- GENERAL
Hooks:PostHook(HUDManager,"set_disabled","hevhud_hudmanager_hidehud",function(self)
	HEVHUD._panel:hide()
end)
Hooks:PostHook(HUDManager,"set_enabled","hevhud_hudmanager_showhud",function(self)
	HEVHUD._panel:show()
end)

-- HINT
Hooks:OverrideFunction(HUDManager,"show_hint",function(self,params)
--	if params.event then
--		self._sound_source:post_event(params.event)
--	end
	HEVHUD._hud_hint:add_hint(params)
end)

Hooks:OverrideFunction(HUDManager,"stop_hint",function(self)
	HEVHUD._hud_hint:stop_hint()
end)

-- TEAMMATES
Hooks:PostHook(HUDManager,"set_teammate_name","hevhud_hudmanager_set_teammate_name",function(self,i,name)
	HEVHUD:SetTeammateName(i,name)
end)


Hooks:OverrideFunction(HUDManager,"start_teammate_timer",function(self,i,t)
	HEVHUD:SetTeammateTimer(i,t)
end)
Hooks:OverrideFunction(HUDManager,"pause_teammate_timer",function(self,i,is_paused)
	HEVHUD:PauseTeammateTimer(i,is_paused)
end)
Hooks:OverrideFunction(HUDManager,"stop_teammate_timer",function(self,i)
	HEVHUD:StopTeammateTimer(i)
end)
Hooks:OverrideFunction(HUDManager,"is_teammate_timer_running",function(self,i)
	HEVHUD:IsTeammateTimerRunning(i)
end)


-- VITALS
Hooks:PostHook(HUDManager,"set_player_health","hevhud_hudmanager_set_player_health",function(self,data)
	HEVHUD._hud_vitals:set_health(data.current,data.total,data.revives)
	
	Hooks:Call("HEVHUD_Crosshair_Listener",{
		source = "health",
		current = data.current,
		total = data.total,
		revives = data.revives
	})
	
end)
Hooks:PostHook(HUDManager,"set_player_armor","hevhud_hudmanager_set_player_armor",function(self,data)
	HEVHUD._hud_vitals:set_armor(data.current,data.total)
	
	Hooks:Call("HEVHUD_Crosshair_Listener",{
		source = "armor",
		current = data.current,
		total = data.total
	})
end)
Hooks:PostHook(HUDManager,"set_stamina_value","hevhud_hudmanager_set_stamina_current",function(self,value)
	HEVHUD._hud_vitals:set_stamina_current(value)
end)
Hooks:PostHook(HUDManager,"set_max_stamina","hevhud_hudmanager_set_stamina_max",function(self,value)
	HEVHUD._hud_vitals:set_stamina_max(value)
end)
Hooks:PostHook(HUDManager,"set_teammate_condition","hevhud_hudmanager_set_teammate_condition",function(self,i,icon_data,text)
	HEVHUD:SetTeammateCondition(i,icon_data,text)
end)
Hooks:PostHook(HUDManager,"set_teammate_health","hevhud_hudmanager_set_teammate_health",function(self,i,data)
	HEVHUD:SetTeammateHealth(i,data)
end)
Hooks:PostHook(HUDManager,"set_teammate_armor","hevhud_hudmanager_set_teammate_armor",function(self,i,data)
	HEVHUD:SetTeammateArmor(i,data)
end)


Hooks:PostHook(HUDManager,"set_stored_health","hevhud_hudmanager_set_player_stored_health",function(self,stored_health_ratio)
	HEVHUD._hud_vitals:set_stored_health(stored_health_ratio)
end)

Hooks:PostHook(HUDManager,"set_stored_health_max","hevhud_hudmanager_set_player_max_stored_health",function(self,stored_health_ratio)
	HEVHUD._hud_vitals:set_max_stored_health(stored_health_ratio)
end)

Hooks:PostHook(HUDManager,"set_teammate_delayed_damage","hevhud_hudmanager_set_player_max_stored_health",function(self,i,delayed_damage)
	if i == HUDManager.PLAYER_PANEL then
		HEVHUD._hud_vitals:set_delayed_damage(delayed_damage)
	end
end)


-- WEAPONS
Hooks:PostHook(HUDManager,"set_ammo_amount","hevhud_hudmanager_set_ammo_amount",function(self, index, magazine_max, magazine_current, reserves_current, reserves_max)
	HEVHUD:SetAmmoAmount(index,magazine_max,magazine_current,reserves_current,reserves_max)
end)
Hooks:PostHook(HUDManager,"set_teammate_ammo_amount","hevhud_hudmanager_set_teammate_ammo",function(self, id, selection_index, max_clip, current_clip, current_left, max)
	HEVHUD:SetTeammateAmmo(id, selection_index, max_clip, current_clip, current_left, max)
end)
Hooks:PostHook(HUDManager,"recreate_weapon_firemode","hevhud_hudmanager_recreatefiremode",function(self,i)
	self._teammate_panels[i]._panel:hide()
end)

-- CABLE TIES
Hooks:PostHook(HUDManager,"set_cable_tie","hevhud_hudmanager_set_teammate_ties_data",function(self,i,data)
	HEVHUD:SetTeammateCabletiesData(i,data)
end)
Hooks:PostHook(HUDManager,"set_cable_ties_amount","hevhud_hudmanager_set_teammate_ties_amount",function(self,i,amount)
	HEVHUD:SetTeammateCabletiesAmount(i,amount)
end)


-- GRENADES
Hooks:PostHook(HUDManager,"set_player_grenade_cooldown","hevhud_hudmanager_set_grenade_cooldown",function(self,data)
	HEVHUD._hud_weapons:set_grenades_cooldown(data)
end)

Hooks:PostHook(HUDManager,"set_player_ability_radial","hevhud_hudmanager_player_set_ability_radial",function(self,data)
	HEVHUD._hud_ability:set_ability_timer(data.current,data.total)
end)
Hooks:PostHook(HUDManager,"activate_teammate_ability_radial","hevhud_hudmanager_teammate_activate_ability_radial",function(self,i,time_left,time_total)
	-- throwable ability (kingpin, pecm, etc)
	if i == HUDManager.PLAYER_PANEL then
		HEVHUD._hud_ability:set_ability_timer(time_left,time_total)
	end
end)

Hooks:PostHook(HUDManager,"set_teammate_grenade_cooldown","hevhud_hudmanager_teammate_set_grenade_cooldown",function(self,i,data)
	HEVHUD:SetTeammateGrenadeCooldown(i,data)
end)
Hooks:PostHook(HUDManager,"set_teammate_grenades","hevhud_hudmanager_teammate_set_grenades_data",function(self,i,data)
	-- set ability icon
	HEVHUD:SetTeammateGrenadeData(i,data)
	if i == HUDManager.PLAYER_PANEL then
		HEVHUD._hud_weapons:set_grenades_data(data)
	end
end)
Hooks:PostHook(HUDManager,"set_teammate_grenades_amount","hevhud_hudmanager_teammate_set_grenades_amount",function(self,i,data)
	HEVHUD:SetTeammateGrenadeAmount(i,data)
	if i == HUDManager.PLAYER_PANEL then
		HEVHUD._hud_weapons:set_grenades_amount(data)
	end
end)


-- SPECIAL EQUIPMENT (aka MISSION EQUIPMENT)
Hooks:PostHook(HUDManager,"add_special_equipment","hevhud_hudmanager_set_special_equipment",function(self,data)
	HEVHUD._hud_objectives:add_special_equipment(data)
	if HEVHUDCore.config.Pickup.MISSION_EQ_ENABLED then
		HEVHUD._hud_hint:add_special_equipment(data)
	end
end)
Hooks:PostHook(HUDManager,"set_special_equipment_amount","hevhud_hudmanager_set_special_equipment_amount",function(self,equipment_id,amount)
	HEVHUD._hud_objectives:set_special_equipment_amount(equipment_id,amount)
	if HEVHUDCore.config.Pickup.MISSION_EQ_ENABLED then
		HEVHUD._hud_hint:set_special_equipment_amount(equipment_id,amount)
	end
end)
Hooks:PostHook(HUDManager,"remove_special_equipment","hevhud_hudmanager_remove_special_equipment",function(self,equipment_id)
	HEVHUD._hud_objectives:remove_special_equipment(equipment_id)
end)

Hooks:PostHook(HUDManager,"add_teammate_special_equipment","hevhud_hudmanager_teammate_set_special_equipment",function(self,i,data)
	HEVHUD:AddTeammateSpecialEquipment(i,data)
end)
Hooks:PostHook(HUDManager,"remove_teammate_special_equipment","hevhud_hudmanager_teammate_remove_special_equipment",function(self,i,equipment)
	HEVHUD:RemoveTeammateSpecialEquipment(i,equipment)
end)
Hooks:PostHook(HUDManager,"set_teammate_special_equipment_amount","hevhud_hudmanager_teammate_set_special_equipment_amount",function(self,i,equipment_id,amount)
	HEVHUD:SetTeammateSpecialEquipmentAmount(i,equipment_id,amount)
end)

-- DEPLOYABLES
Hooks:PostHook(HUDManager,"add_item","hevhud_hudmanager_player_set_deployable",function(self, data)
	HEVHUD:CheckPlayerDeployables(data)
end)
Hooks:PostHook(HUDManager,"add_item_from_string","hevhud_hudmanager_player_from_string_set_deployable",function(self, data)
	HEVHUD:CheckPlayerDeployables(data)
end)
Hooks:PostHook(HUDManager,"set_item_amount","hevhud_hudmanager_player_set_deployable_amount",function(self, index, amount)
	HEVHUD:CheckPlayerDeployables(data)
end)
Hooks:PostHook(HUDManager,"set_item_amount_from_string","hevhud_hudmanager_player_from_string_set_deployable_amount",function(self, index, amount_str, amount)
	HEVHUD:CheckPlayerDeployables(data)
end)

Hooks:PostHook(HUDManager,"set_deployable_equipment_from_string","hevhud_hudmanager_player_from_string_set_deployable",function(self, i, data)
	if i ~= HUDManager.PLAYER_PANEL then
		HEVHUD:SetTeammateDeployableFromString(i,data)
	end
end)
Hooks:PostHook(HUDManager,"set_deployable_equipment","hevhud_hudmanager_teammate_set_deployable",function(self, i, data)
	if i ~= HUDManager.PLAYER_PANEL then
		HEVHUD:SetTeammateDeployableData(i,data)
	end
end)

Hooks:PostHook(HUDManager,"set_teammate_deployable_equipment_amount","hevhud_hudmanager_teammate_set_deployable_amount",function(self, i, index, data)
	-- not used
	if i ~= HUDManager.PLAYER_PANEL then
		HEVHUD:SetTeammateDeployableAmount(i,index,data)
	end
-- Table data = { amount = Int, index = Int }
end)
Hooks:PostHook(HUDManager,"set_teammate_deployable_equipment_amount_from_string","hevhud_hudmanager_teammate_from_string_set_deployable_amount",function(self, i, index, data)
	-- not used
	if i ~= HUDManager.PLAYER_PANEL then
		HEVHUD:SetTeammateDeployableAmountFromString(i,index,data)
	end
-- Table data = { amount_str = string, Table amount = { Int, Int }
end)

-- CARRY
Hooks:OverrideFunction(HUDManager,"temp_show_carry_bag",function(self, carry_id, value)
	HEVHUD:ShowCarry(carry_id,value)
end)
Hooks:OverrideFunction(HUDManager,"temp_hide_carry_bag",function(self)
	HEVHUD:HideCarry()
end)

Hooks:PostHook(HUDManager,"set_teammate_carry_info","hevhud_hudmanager_teammate_set_carry",function(self,i,carry_id,value)
	HEVHUD:SetTeammateCarry(i,carry_id,value)
end)
Hooks:PostHook(HUDManager,"remove_teammate_carry_info","hevhud_hudmanager_teammate_remove_carry",function(self,i)
	HEVHUD:RemoveTeammateCarry(i)
end)

-- PRESENTER
Hooks:OverrideFunction(HUDManager,"present",function(self,params)
	HEVHUD._hud_presenter:present(params)
end)

-- HIT DIRECTION
Hooks:PostHook(HUDManager,"on_hit_direction","hevhud_hudmanager_onhitdirection",function(self, dir, unit_type_hit, fixed_angle)
	HEVHUD._hud_hitdirection:on_hit_direction(dir, unit_type_hit, fixed_angle)
end)

--[[
Hooks:PostHook(HUDManager,"add_teammate_panel","hevhud_hudmanager_addteammate",function(self, character_name, player_name, ai, peer_id)
	HEVHUD:AddTeammatePanel(character_name,player_name,ai,peer_id)
end)
--]]

-- OBJECTIVES
Hooks:OverrideFunction(HUDManager,"activate_objective",function(self,data)
	HEVHUD._hud_objectives:activate_objective(data)
end)
Hooks:OverrideFunction(HUDManager,"update_amount_objective",function(self,data)
	HEVHUD._hud_objectives:update_amount_objective(data)
end)
Hooks:OverrideFunction(HUDManager,"remind_objective",function(self,id)
	HEVHUD._hud_objectives:remind_objective(id)
end)
Hooks:OverrideFunction(HUDManager,"complete_objective",function(self,data)
	HEVHUD._hud_objectives:complete_objective(data)
end)
