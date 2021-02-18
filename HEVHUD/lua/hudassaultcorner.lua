Hooks:PostHook(HUDAssaultCorner,"init","hevhud_disable_hostages panel",function(self,hud, full_hud, tweak_hud)
	self._hud_panel:child("hostages_panel"):hide()
end)

function HUDAssaultCorner:set_control_info(data)
	HEVHUD:SetHostageCount(data.nr_hostages)
end

function HUDAssaultCorner:_show_hostages()
	if not self._point_of_no_return then
		HEVHUD:ShowHostages()
	end
end

function HUDAssaultCorner:_hide_hostages()
	HEVHUD:HideHostages()
end

function HUDAssaultCorner:_set_hostage_offseted(is_offseted)
	local hostage_panel = HEVHUD._panel:child("hostages") --self._hud_panel:child("hostages_panel")
	self._remove_hostage_offset = nil

	hostage_panel:stop()
	hostage_panel:animate(callback(self, self, "_offset_hostage", is_offseted))

	local wave_panel = self._hud_panel:child("wave_panel")

	if wave_panel then
		wave_panel:stop()
		wave_panel:animate(callback(self, self, "_offset_hostage", is_offseted))
	end
end