local HUD_TEAMMATE_ENABLED = HEVHUDCore.session_settings.hud_teammate_enabled
local HUD_HINT_ENABLED = HEVHUDCore.session_settings.hud_hint_enabled
local HUD_PLAYER_ENABLED = HEVHUDCore.session_settings.hud_player_enabled
local HUD_PRESENTER_ENABLED = HEVHUDCore.session_settings.hud_presenter_enabled
local HUD_HITDIRECTION_ENABLED = HEVHUDCore.session_settings.hud_hitdirection_enabled
local HUD_OBJECTIVE_ENABLED = HEVHUDCore.session_settings.hud_objective_enabled
local HUD_WAITING_ENABLED = HEVHUDCore.session_settings.hud_waiting_enabled

Hooks:PostHook(HUDManager,"_setup_player_info_hud_pd2","hevhud_hudmanager_create_hud",function(self)
	local hm = managers.hud:script(PlayerBase.PLAYER_INFO_HUD_PD2)

	local parent_panel = hm and hm.panel
	if alive(parent_panel) then 
		HEVHUD:CreateHUD(parent_panel)
--		HEVHUD:CreateHUD(parent_panel,HEVHUD:CheckFontResourcesReady(false,callback(HEVHUD,HEVHUD,"OnDelayedLoad")))
	end
end)

--Hooks:PostHook(HUDManager,"controller_mod_changed","hevhud_hudmanager_controllermodchanged",function(self)
--	if self:alive("guis/mask_off_hud") then
--		self:script("guis/mask_off_hud").panel:hide()
--	end
--end)

-- GENERAL
Hooks:PostHook(HUDManager,"set_disabled","hevhud_hudmanager_hidehud",function(self)
	HEVHUD._panel:hide()
end)
Hooks:PostHook(HUDManager,"set_enabled","hevhud_hudmanager_showhud",function(self)
	HEVHUD._panel:show()
end)


-- Create player and/or teammates panel
if HUD_TEAMMATE_ENABLED then
	-- override
	Hooks:PostHook(HUDManager,"_create_teammates_panel","hevhud_hudmanager_create_teammates",function(self,hud)
		if HUD_PLAYER_ENABLED then
			HEVHUD:CreateHUDPlayer(self,hud)
		end
		HEVHUD:CreateHUDTeammates(self,hud)
	end)
	--[[
	Hooks:OverrideFunction(HUDManager,"_create_teammates_panel",function(self,hud)
		HEVHUD:CreateHUDTeammates(self,hud)
	end)
	--]]
elseif HUD_PLAYER_ENABLED then
	Hooks:PostHook(HUDManager,"_create_teammates_panel","hevhud_hudmanager_create_teammates",function(self,hud)
		HEVHUD:CreateHUDPlayer(self,hud)
	end)
end


-- TEAMMATES
if HUD_TEAMMATE_ENABLED then
	Hooks:OverrideFunction(HUDManager,"set_teammate_name",function(self,i,name)
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

	Hooks:OverrideFunction(HUDManager,"set_teammate_condition",function(self,i,icon_data,text)
		HEVHUD:SetTeammateCondition(i,icon_data,text)
	end)
	Hooks:OverrideFunction(HUDManager,"set_teammate_health",function(self,i,data)
		HEVHUD:SetTeammateHealth(i,data)
	end)
	Hooks:OverrideFunction(HUDManager,"set_teammate_armor",function(self,i,data)
		HEVHUD:SetTeammateArmor(i,data)
	end)
	
	Hooks:OverrideFunction(HUDManager,"set_teammate_delayed_damage",function(self,i,delayed_damage)
		if not HUD_PLAYER_ENABLED and i == HUDManager.PLAYER_PANEL then
			HEVHUD._hud_vitals:set_delayed_damage(delayed_damage)
		end
	end)
	Hooks:OverrideFunction(HUDManager,"recreate_weapon_firemode",function(self,i) end)

	Hooks:OverrideFunction(HUDManager,"set_teammate_ammo_amount",function(self, id, selection_index, max_clip, current_clip, current_left, max)
		HEVHUD:SetTeammateAmmo(id, selection_index, max_clip, current_clip, current_left, max)
	end)
	
	-- CABLE TIES
	Hooks:OverrideFunction(HUDManager,"set_cable_tie",function(self,i,data)
		HEVHUD:SetTeammateCabletiesData(i,data)
	end)
	Hooks:OverrideFunction(HUDManager,"set_cable_ties_amount",function(self,i,amount)
		HEVHUD:SetTeammateCabletiesAmount(i,amount)
	end)
	
	
	Hooks:OverrideFunction(HUDManager,"set_teammate_grenade_cooldown",function(self,i,data)
		HEVHUD:SetTeammateGrenadeCooldown(i,data)
	end)

	Hooks:OverrideFunction(HUDManager,"add_teammate_special_equipment",function(self,i,data)
		if not i then
			HEVHUDCore:Log("[HUDManager:add_teammate_special_equipment] - Didn't get a number")
			return
		end
		HEVHUD:AddTeammateSpecialEquipment(i,data)
	end)
	Hooks:OverrideFunction(HUDManager,"remove_teammate_special_equipment",function(self,i,equipment)
		HEVHUD:RemoveTeammateSpecialEquipment(i,equipment)
	end)
	Hooks:OverrideFunction(HUDManager,"set_teammate_special_equipment_amount",function(self,i,equipment_id,amount)
		HEVHUD:SetTeammateSpecialEquipmentAmount(i,equipment_id,amount)
	end)
	
	-- DEPLOYABLE
	Hooks:OverrideFunction(HUDManager,"set_deployable_equipment_from_string",function(self, i, data)
		if not HUD_PLAYER_ENABLED or i ~= HUDManager.PLAYER_PANEL then
			HEVHUD:SetTeammateDeployableFromString(i,data)
		end
	end)
	Hooks:OverrideFunction(HUDManager,"set_teammate_deployable_equipment_amount",function(self, i, index, data)
		if not HUD_PLAYER_ENABLED or i ~= HUDManager.PLAYER_PANEL then
			HEVHUD:SetTeammateDeployableAmount(i,index,data)
		end
	-- Table data = { amount = Int, index = Int }
	end)
	Hooks:OverrideFunction(HUDManager,"set_teammate_deployable_equipment_amount_from_string",function(self, i, index, data)
		if not HUD_PLAYER_ENABLED or i ~= HUDManager.PLAYER_PANEL then
			HEVHUD:SetTeammateDeployableAmountFromString(i,index,data)
		end
	-- Table data = { amount_str = string, Table amount = { Int, Int }
	end)
	
	Hooks:OverrideFunction(HUDManager,"set_deployable_equipment",function(self, i, data)
		if not HUD_PLAYER_ENABLED or i ~= HUDManager.PLAYER_PANEL then
			HEVHUD:SetTeammateDeployableData(i,data)
		end
	end)


	-- CARRY
	Hooks:OverrideFunction(HUDManager,"set_teammate_carry_info",function(self,i,carry_id,value)
		HEVHUD:SetTeammateCarry(i,carry_id,value)
	end)
	Hooks:OverrideFunction(HUDManager,"remove_teammate_carry_info",function(self,i)
		HEVHUD:RemoveTeammateCarry(i)
	end)

end

-- WAITING LEGEND
if HUD_WAITING_ENABLED then
	Hooks:OverrideFunction(HUDManager,"_create_waiting_legend",function(self, hud)
		HEVHUD:CreateHUDWaiting(self,hud)
	end)
	
	Hooks:OverrideFunction(HUDManager,"add_waiting",function(self, peer_id, override_index)
		if not Network:is_server() then
			return
		end

		local peer = managers.network:session():peer(peer_id)

		if override_index then
			self._waiting_index[peer_id] = override_index
		end

		local index = self:get_waiting_index(peer_id)
		local panel = HEVHUD._teammate_panels[index]

		if panel and peer then
			--panel:set_waiting(true, peer)

			if not HEVHUD._hud_waiting:is_set() then 
				HEVHUD._hud_waiting:show_on(panel, peer)
			end
		end
	end)

	Hooks:OverrideFunction(HUDManager,"remove_waiting",function(self, peer_id)
		if not Network:is_server() then
			return
		end
		local index = self:get_waiting_index(peer_id)
		self._waiting_index[peer_id] = nil
	--	local _ = self._teammate_panels[index] and self._teammate_panels[index]:set_waiting(false)

		if HEVHUD._hud_waiting:peer() and peer_id == HEVHUD._hud_waiting:peer():id() then
			HEVHUD._hud_waiting:turn_off()

			for id, index in pairs(self._waiting_index) do
				local panel = HEVHUD._teammate_panels[index]
				local peer = managers.network:session():peer(id)

				if panel then
					HEVHUD._hud_waiting:show_on(panel, peer)

					break
				end
			end
		end
	end)
end

-- GRENADES (PLAYER/TEAMMATE SHARED)
if HUD_TEAMMATE_ENABLED and HUD_PLAYER_ENABLED then
	-- used for both player and teammate
	Hooks:OverrideFunction(HUDManager,"set_teammate_grenades_amount",function(self,i,data)
		HEVHUD:SetTeammateGrenadeAmount(i,data)
		if HUD_PLAYER_ENABLED and i == HUDManager.PLAYER_PANEL then
			HEVHUD._hud_weapons:set_grenades_amount(data)
		end
	end)
	Hooks:OverrideFunction(HUDManager,"set_teammate_grenades",function(self,i,data)
		-- set ability icon
		HEVHUD:SetTeammateGrenadeData(i,data)
		if HUD_PLAYER_ENABLED and i == HUDManager.PLAYER_PANEL then
			HEVHUD._hud_weapons:set_grenades_data(data)
		end
	end)

	-- only used for player atm
	Hooks:OverrideFunction(HUDManager,"activate_teammate_ability_radial",function(self,i,time_left,time_total)
		-- throwable ability (kingpin, pecm, etc)
		if HUD_PLAYER_ENABLED and i == HUDManager.PLAYER_PANEL then
			HEVHUD._hud_ability:set_ability_timer(time_left,time_total)
		end
	end)
elseif HUD_PLAYER_ENABLED then
	-- these have no player-only counterpart
	
	Hooks:PostHook(HUDManager,"set_teammate_grenades_amount","hevhud_set_teammate_grenades_amount",function(self,i,data)
		if i == HUDManager.PLAYER_PANEL then
			HEVHUD._hud_weapons:set_grenades_amount(data)
		end
	end)
	Hooks:PostHook(HUDManager,"set_teammate_grenades","hevhud_set_teammate_grenades_data",function(self,i,data)
		-- set ability icon
		if i == HUDManager.PLAYER_PANEL then
			HEVHUD._hud_weapons:set_grenades_data(data)
		end
	end)

	-- only used for player atm
	Hooks:PostHook(HUDManager,"activate_teammate_ability_radial","hevhud_activate_teammate_ability_radial",function(self,i,time_left,time_total)
		-- throwable ability (kingpin, pecm, etc)
		if i == HUDManager.PLAYER_PANEL then
			HEVHUD._hud_ability:set_ability_timer(time_left,time_total)
		end
	end)
end

-- PLAYER VITALS
if HUD_PLAYER_ENABLED then
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

	Hooks:PostHook(HUDManager,"set_stored_health","hevhud_hudmanager_set_player_stored_health",function(self,stored_health_ratio)
		HEVHUD._hud_vitals:set_stored_health(stored_health_ratio)
	end)

	Hooks:PostHook(HUDManager,"set_stored_health_max","hevhud_hudmanager_set_player_max_stored_health",function(self,stored_health_ratio)
		HEVHUD._hud_vitals:set_max_stored_health(stored_health_ratio)
	end)


	-- WEAPONS

	Hooks:PostHook(HUDManager,"set_ammo_amount","hevhud_hudmanager_set_ammo_amount",function(self, index, magazine_max, magazine_current, reserves_current, reserves_max)
		HEVHUD:SetAmmoAmount(index,magazine_max,magazine_current,reserves_current,reserves_max)
	end)



	-- GRENADES
	Hooks:PostHook(HUDManager,"set_player_grenade_cooldown","hevhud_hudmanager_set_grenade_cooldown",function(self,data)
		HEVHUD._hud_weapons:set_grenades_cooldown(data)
	end)
	Hooks:PostHook(HUDManager,"set_player_ability_radial","hevhud_hudmanager_player_set_ability_radial",function(self,data)
		HEVHUD._hud_ability:set_ability_timer(data.current,data.total)
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


	-- CARRY
	Hooks:OverrideFunction(HUDManager,"temp_show_carry_bag",function(self, carry_id, value)
		HEVHUD:ShowCarry(carry_id,value)
	end)
	Hooks:OverrideFunction(HUDManager,"temp_hide_carry_bag",function(self)
		HEVHUD:HideCarry()
	end)
end


-- PRESENTER
if HUD_PRESENTER_ENABLED then
	-- hevhudpresenter is a mimic class
	Hooks:OverrideFunction(HUDManager,"_create_present_panel",function(self,hud)
		self._hud_presenter = HEVHUD:CreateHUDPresenter(self,hud)
	end)
end

-- HIT DIRECTION
if HUD_HITDIRECTION_ENABLED then
	Hooks:PostHook(HUDManager,"_create_hit_direction","hevhud_hudmanager_create_hitdirection",function(self,hud)
		HEVHUD:CreateHUDHitDirection(self,hud)
	end)
	
	Hooks:PostHook(HUDManager,"on_hit_direction","hevhud_hudmanager_onhitdirection",function(self, dir, unit_type_hit, fixed_angle, ...)
		HEVHUD:OnHitDirection(dir, unit_type_hit, fixed_angle, ...)
	end)
end


-- OBJECTIVES
if HUD_OBJECTIVE_ENABLED then
	-- hevhudobjectives is a mimic class
	Hooks:OverrideFunction(HUDManager,"_create_objectives",function(self,hud)
		self._hud_objectives = HEVHUD:CreateHUDObjectives(self,hud)
	end)
end


-- SPECIAL EQUIPMENT (aka MISSION EQUIPMENT)
if HUD_TEAMMATE_ENABLED then
	Hooks:OverrideFunction(HUDManager,"add_special_equipment",function(self,data)
		HEVHUD:AddSpecialEquipment(data)
	end)
	Hooks:OverrideFunction(HUDManager,"set_special_equipment_amount",function(self,equipment_id,amount)
		HEVHUD:SetSpecialEquipmentAmount(equipment_id,amount)
	end)
	Hooks:OverrideFunction(HUDManager,"remove_special_equipment",function(self,equipment_id)
		HEVHUD:RemoveSpecialEquipment(equipment_id,amount)
	end)
else
	Hooks:PostHook(HUDManager,"add_special_equipment","hevhud_hudmanager_set_special_equipment",function(self,data)
		HEVHUD:AddSpecialEquipment(data)
	end)
	Hooks:PostHook(HUDManager,"set_special_equipment_amount","hevhud_hudmanager_set_special_equipment_amount",function(self,equipment_id,amount)
		HEVHUD:SetSpecialEquipmentAmount(equipment_id,amount)
	end)
	Hooks:PostHook(HUDManager,"remove_special_equipment","hevhud_hudmanager_remove_special_equipment",function(self,equipment_id)
		HEVHUD:RemoveSpecialEquipment(equipment_id)
	end)
end

-- HINT
if HUD_HINT_ENABLED then
	Hooks:PostHook(HUDManager,"_create_hint","hevhud_hudmanager_createhint",function(self)
		HEVHUD:CreateHUDHint(self,hud)
	end)
	
	Hooks:OverrideFunction(HUDManager,"show_hint",function(self,params)
		if params.event then
			self._sound_source:post_event(params.event)
		end
		HEVHUD:ShowHint(params)
	end)

	Hooks:OverrideFunction(HUDManager,"stop_hint",function(self)
		HEVHUD:StopHint()
	end)
end




-- ASSAULT BANNER
--[[
if HUD_ASSAULT_ENABLED then
	Hooks:OverrideFunction(HUDManager,"_create_assault_corner",function(self,hud)
		self._hud_assaultcorner = HEVHUD:CreateHUDAssault(self,hud)
	end)
end
--]]

-- CHAT
--[[
if HUD_ASSAULT_ENABLED then
	Hooks:OverrideFunction(HUDManager,"_create_hud_chat",function(self,hud)
		self._hud_chat_ingame = HEVHUD:CreateHUDChat(self,hud)
	end)
	
	Hooks:OverrideFunction(HUDManager,"_create_hud_chat_access",function(self,hud)
		self._hud_chat_access = HEVHUD:CreateHUDChat(self,hud)
	end)
end
--]]