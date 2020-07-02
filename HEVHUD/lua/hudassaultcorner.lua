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
