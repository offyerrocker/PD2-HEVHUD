Hooks:PostHook(HUDTemp,"init","hevhud_bagpanel_init",function(self,hud)
	self._hud_panel:child("temp_panel"):hide()
end)


function HUDTemp:show_carry_bag(...)
	HEVHUD:ShowCarry(...)
end

function HUDTemp:hide_carry_bag(...)
	HEVHUD:HideCarry(...)
end
--[[
function HUDTemp:set_stamina_value(value)
	HEVHUD:SetStamina(value)
end
--]]