-- redundant since the newraycastweaponbase hook catches gadget states
--Hooks:PostHook(PlayerStandard,"_toggle_gadget","hevhud_playerstandard_toggle_gadget",function(self,weap_base)
--	HEVHUD:CheckWeaponGadgets(weap_base)
--end)

Hooks:PostHook(PlayerStandard,"_check_action_deploy_underbarrel","hevhud_playerstandard_toggle_underbarrel",function(self,t,input)
	if Hooks:GetReturn() then
		local weap_base = alive(self._equipped_unit) and self._equipped_unit:base()
		if weap_base then
			HEVHUD:CheckWeaponUnderbarrelActive(weap_base)
			HEVHUD:CheckWeaponHasUnderbarrel(weap_base)
			HEVHUD:CheckUnderbarrelAmmo(weap_base)
		end
	end
end)
--[[
Hooks:PostHook(PlayerStandard,"inventory_clbk_listener","hevhud_playerstandard_inventoryclbklistener",function(self,unit,event)
	if event == "equip" then
		for id, weapon in pairs(self._ext_inventory:available_selections()) do
			for _,underbarrel_base in pairs(weapon.unit:base():get_all_override_weapon_gadgets()) do 
				--managers.hud:set_own_ammo_amount(id + 2,underbarrel_base:ammo_info())
				local ammo = underbarrel_base._ammo
				managers.hud:set_own_ammo_amount(id + 2,ammo._ammo_max_per_clip or ammo._ammo_max_per_clip2,ammo._ammo_remaining_in_clip or ammo._ammo_remaining_in_clip2,ammo._ammo_total,ammo._ammo_max or ammo._ammo_max2)

				break
			end
		end
	end
end)
--]]