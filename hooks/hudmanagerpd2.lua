Hooks:PostHook(HUDManager,"_setup_player_info_hud_pd2","hevhud_hudmanager_create_hud",function(self)
	local hm = managers.hud:script(PlayerBase.PLAYER_INFO_HUD_PD2)
	local parent_panel = hm and hm.panel
	if alive(parent_panel) then 
		HEVHUD:CreateHUD(parent_panel)
--		HEVHUD:CreateHUD(parent_panel,HEVHUD:CheckFontResourcesReady(false,callback(HEVHUD,HEVHUD,"OnDelayedLoad")))
	end
end)


--[[
Hooks:PostHook(HUDManager,"add_teammate_panel","hevhud_hudmanager_addteammate",function(self, character_name, player_name, ai, peer_id)
	HEVHUD:AddTeammatePanel(character_name,player_name,ai,peer_id)
end)


--]]


Hooks:PostHook(HUDManager,"set_disabled","hevhud_hudmanager_hidehud",function(self)
	HEVHUD._panel:hide()
end)

Hooks:PostHook(HUDManager,"set_enabled","hevhud_hudmanager_showhud",function(self)
	HEVHUD._panel:show()
end)

Hooks:PostHook(HUDManager,"set_player_health","hevhud_hudmanager_set_player_health",function(self,data)
	HEVHUD._hud_vitals:set_health(data.current,data.total,data.revives)
end)

Hooks:PostHook(HUDManager,"set_player_armor","hevhud_hudmanager_set_player_armor",function(self,data)
	HEVHUD._hud_vitals:set_armor(data.current,data.total)
end)

Hooks:PostHook(HUDManager,"set_stamina_value","hevhud_hudmanager_set_stamina_current",function(self,value)
	HEVHUD._hud_vitals:set_stamina_current(value)
end)

Hooks:PostHook(HUDManager,"set_max_stamina","hevhud_hudmanager_set_stamina_max",function(self,value)
	HEVHUD._hud_vitals:set_stamina_max(value)
end)

Hooks:PostHook(HUDManager,"set_ammo_amount","hevhud_hudmanager_set_ammo_amount",function(self, index, magazine_max, magazine_current, reserves_current, reserves_max)
	HEVHUD:SetAmmoAmount(index,magazine_max,magazine_current,reserves_current,reserves_max)
end)

Hooks:OverrideFunction(HUDManager,"temp_show_carry_bag",function(self, carry_id, value)
	HEVHUD:ShowCarry(carry_id,value)
end)

Hooks:OverrideFunction(HUDManager,"temp_hide_carry_bag",function(self)
	HEVHUD:HideCarry()
end)

Hooks:PostHook(HUDManager,"set_teammate_condition","hevhud_hudmanager_set_teammate_condition",function(self,i,icon_data,text)
	HEVHUD:SetTeammateCondition(i,icon_data,text)
end)

Hooks:PostHook(HUDManager,"set_teammate_ammo_amount","hevhud_hudmanager_set_teammate_ammo",function(self, id, selection_index, max_clip, current_clip, current_left, max)
	HEVHUD:SetTeammateAmmo(id, selection_index, max_clip, current_clip, current_left, max)
end)

Hooks:PostHook(HUDManager,"set_teammate_name","hevhud_hudmanager_set_teammate_name",function(self,i,name)
	HEVHUD:SetTeammateName(i,name)
end)

Hooks:PostHook(HUDManager,"set_cable_tie","hevhud_hudmanager_set_teammate_ties_data",function(self,i,data)
	HEVHUD:SetTeammateCabletiesData(i,data)
end)
Hooks:PostHook(HUDManager,"set_cable_ties_amount","hevhud_hudmanager_set_teammate_ties_amount",function(self,i,amount)
	HEVHUD:SetTeammateCabletiesAmount(i,amount)
end)