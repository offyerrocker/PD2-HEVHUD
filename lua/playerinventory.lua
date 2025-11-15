Hooks:PostHook(PlayerInventory,"init","hevhud_playerinventory_init",function(self)
	self:add_listener("hevhud_on_weapon_switch",{"equip"},callback(HEVHUD,HEVHUD,"SetSelectedWeapon"))
end)
