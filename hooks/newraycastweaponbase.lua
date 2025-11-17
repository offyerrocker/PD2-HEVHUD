Hooks:PostHook(NewRaycastWeaponBase,"set_gadget_on","hevhud_check_flashlight",function(self, gadget_on, ignore_enable, gadgets, current_state)
	if self._setup and self._setup.user_unit == managers.player:local_player() then
		HEVHUD:CheckWeaponGadgets(self)
	end
end)


Hooks:PostHook(NewRaycastWeaponBase,"toggle_firemode","hevhud_check_firemode",function(self, skip_post_event)
	if self._setup and self._setup.user_unit == managers.player:local_player() then
		HEVHUD:CheckWeaponFiremode(self)
	end
end)