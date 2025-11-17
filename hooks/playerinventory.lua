Hooks:PostHook(PlayerInventory,"equip_selection","hevhud_playerinventory_on_switch_weapon",function(self,selection_index, instant)
	if self._unit == managers.player:local_player() then
		local equipped_unit = self:equipped_unit()
		local weap_base = alive(equipped_unit) and equipped_unit:base()
		if weap_base then
			HEVHUD:CheckWeaponUnderbarrelActive(weap_base)
			HEVHUD:CheckWeaponHasUnderbarrel(weap_base)
			HEVHUD:CheckUnderbarrelAmmo(weap_base)
		end
	end
end)
