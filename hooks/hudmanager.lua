Hooks:OverrideFunction(HUDManager,"_drop_in_input_callback",function(self,binding_str)
	HEVHUD._hud_waiting:on_input(binding_str)
end)