
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

--Hooks:PostHook(HUDManager,"clear_player_special_equipments","",function(self)

--end)

--[[
function HUDManager:hide_player_gear(panel_id)
	if self._teammate_panels[panel_id] and self._teammate_panels[panel_id]:panel() and self._teammate_panels[panel_id]:panel():child("player") then
		local player_panel = self._teammate_panels[panel_id]:panel():child("player")
		local teammate_panel = self._teammate_panels[panel_id]

		player_panel:child("weapons_panel"):set_visible(false)
		teammate_panel._deployable_equipment_panel:set_visible(false)
		teammate_panel._cable_ties_panel:set_visible(false)
		teammate_panel._grenades_panel:set_visible(false)
	end
end

function HUDManager:show_player_gear(panel_id)
	if self._teammate_panels[panel_id] and self._teammate_panels[panel_id]:panel() and self._teammate_panels[panel_id]:panel():child("player") then
		local player_panel = self._teammate_panels[panel_id]:panel():child("player")
		local teammate_panel = self._teammate_panels[panel_id]

		player_panel:child("weapons_panel"):set_visible(true)
		teammate_panel._deployable_equipment_panel:set_visible(true)
		teammate_panel._cable_ties_panel:set_visible(true)
		teammate_panel._grenades_panel:set_visible(true)
	end
end

function HUDManager:hide_local_player_gear()
end

function HUDManager:show_local_player_gear()
end
--]]



