--[[
function PlayerInventory:add_listener(key, events, clbk)
	events = events or self._all_event_types

	self._listener_holder:add(key, events, clbk)
end
--]]

Hooks:PostHook(PlayerInventory,"init","hevhud_playerinventory_init",function(self)
	self:add_listener("hevhud_on_weapon_switch",{"equip"},callback(HEVHUD,HEVHUD,"SetSelectedWeapon"))
end)
