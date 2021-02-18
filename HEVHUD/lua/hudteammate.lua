Hooks:PostHook(HUDTeammate,"init","hevhud_init_playerpanel",function(self, i, teammates_panel, is_player, width)
	if i == HUDManager.PLAYER_PANEL then
		if alive(self._panel) then 
			self._panel:set_alpha(0)
		end
	end
end)

Hooks:PostHook(HUDTeammate,"set_health","hevhud_set_health",function(self,data)
	HEVHUD:SetHealth(data)
end)

Hooks:PostHook(HUDTeammate,"_create_primary_weapon_firemode","hevhud_disable_primary_firemode_panel",function(self)
	if self._id == HUDManager.PLAYER_PANEL then 
		local primary_weapon_panel = self._player_panel:child("weapons_panel"):child("primary_weapon_panel")
		primary_weapon_panel:child("weapon_selection"):hide()
	end
end)
Hooks:PostHook(HUDTeammate,"_create_secondary_weapon_firemode","hevhud_disable_secondary_firemode_panel",function(self)
	if self._id == HUDManager.PLAYER_PANEL then 
		local secondary_weapon_panel = self._player_panel:child("weapons_panel"):child("secondary_weapon_panel")
		secondary_weapon_panel:child("weapon_selection"):hide()
	end
end)

Hooks:PostHook(HUDTeammate,"set_armor","hevhud_set_armor",function(self,data)
	HEVHUD:SetArmor(data)
end)

Hooks:PostHook(HUDTeammate,"set_ammo_amount_by_type","hevhud_set_ammo",function(self,slot_name, max_clip, current_clip, current_reserve, max_reserve, weapon_panel)
--	HEVHUD:SetWeaponReserve(slot_name,math.max(current_left - current_clip,0))
	
	if HEVHUD:ShouldUseRealAmmo() then 
		HEVHUD:SetWeaponReserve(slot_name,math.max(current_reserve - current_clip,0),max_reserve)
	else
		HEVHUD:SetWeaponReserve(slot_name,current_reserve,max_reserve)
	end
	HEVHUD:SetWeaponMagazine(slot_name,current_clip,max_clip)
end)