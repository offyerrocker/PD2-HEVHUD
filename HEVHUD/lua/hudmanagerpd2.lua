Hooks:PostHook(HUDManager,"_setup_player_info_hud_pd2","hevhud_hudmanager_create_hud",function(self)
	local hm = managers.hud:script(PlayerBase.PLAYER_INFO_HUD_PD2)
	local parent_panel = hm and hm.panel
	if alive(parent_panel) then 
		HEVHUD:CreateHUD(parent_panel)
	end
	HEVHUD:Setup()
end)

Hooks:PostHook(HUDManager,"set_disabled","hevhud_hudmanager_hidehud",function(self)
	HEVHUD._panel:hide()
end)

Hooks:PostHook(HUDManager,"set_enabled","hevhud_hudmanager_showhud",function(self)
	HEVHUD._panel:show()
end)


Hooks:PostHook(HUDManager,"add_special_equipment","hevhud_hudmanager_add_special_equipment",function(self,...)
	HEVHUD:AddSpecialEquipment(...)
end)
Hooks:PostHook(HUDManager,"remove_special_equipment","hevhud_hudmanager_remove_special_equipment",function(self,...)
	HEVHUD:RemoveSpecialEquipment(...)
end)
Hooks:PostHook(HUDManager,"set_special_equipment_amount","hevhud_hudmanager_set_special_equipment_amount",function(self,...)
	HEVHUD:SetSpecialEquipmentAmount(...)
end)


Hooks:PostHook(HUDManager,"_create_heist_timer","hevhud_hudmanager_create_heist_timer",function(self,...)
	if self._hud_heist_timer then 
		local timer = self._hud_heist_timer._timer_text
		if alive(timer) then 
			timer:set_font(Idstring(HEVHUD._fonts.hl2_text))
			timer:set_font_size(HEVHUD.settings.HEIST_TIMER_FONT_SIZE)
			timer:set_color(HEVHUD.color_data.hl2_yellow)
		end
	end
end)

Hooks:PostHook(HUDManager,"clear_player_special_equipments","hevhud_hudmanager_clear_special_equipments",function(self)
	HEVHUD:ClearSpecialEquipment()
end)


