local HEVHUDBase = blt_class() -- base class for HEVHUD HUD classes

function HEVHUDBase:init(parent,settings,config)
	self._parent = parent
	self._settings = settings
	self._config = config
	
	local key = tostring(self)
	Hooks:Add("hevhud_on_settings_changed","hevhud_on_settings_changed_" .. key,callback(self,self,"clbk_on_settings_changed"))
	Hooks:Add("hevhud_on_config_changed","hevhud_on_config_changed_" .. key,callback(self,self,"clbk_on_config_changed"))
end

function HEVHUDBase:pre_destroy()
	if alive(self._panel) then
		self._panel:parent():remove(self._panel)
	end
	self._panel = nil
	self._parent = nil
end

function HEVHUDBase:clbk_on_settings_changed(settings)

end

function HEVHUDBase:clbk_on_config_changed(config)

end

function HEVHUDBase.CreateBGBox(parent,w,h,panel_config,child_config)
	local panel
	w = w or parent:w()
	h = h or parent:h()
	panel = parent:panel({
		name = "bgbox",
		w = w,
		h = h,
		alpha = 0.5,
		layer = -1
	})
	if panel_config then
		panel:configure(panel_config)
	end
	
	local hor_size = w - 32
	local ver_size = h - 32
	local bitmap_w = 16
	local bitmap_h = 16
	
	local color = Color.black
	local texture = "guis/textures/hevhud_bgbox_atlas"
	local corner_topleft = panel:bitmap({
		name = "corner_topleft",
		x = 0,
		y = 0,
		w = bitmap_w,
		h = bitmap_h,
		valign = "top",
		halign = "left",
		color = color,
		texture = texture,
		texture_rect = {
			0,0,
			bitmap_w,bitmap_h
		}
	})
	local corner_bottomleft = panel:bitmap({
		name = "corner_topleft",
		x = 0,
		y = h - bitmap_h,
		w = bitmap_w,
		h = bitmap_h,
		valign = "bottom",
		halign = "left",
		color = color,
		texture = texture,
		texture_rect = {
			0,bitmap_h,
			bitmap_w,-bitmap_h
		}
	})
	local corner_topright = panel:bitmap({
		name = "corner_topright",
		x = w - bitmap_w,
		y = 0,
		w = bitmap_w,
		h = bitmap_h,
		valign = "top",
		halign = "right",
		color = color,
		texture = texture,
		texture_rect = {
			bitmap_w,0,
			-bitmap_w,bitmap_h
		}
	})
	local corner_bottomright = panel:bitmap({
		name = "corner_bottomright",
		x = w - bitmap_w,
		y = h - bitmap_h,
		w = bitmap_w,
		h = bitmap_h,
		valign = "bottom",
		halign = "right",
		color = color,
		texture = texture,
		texture_rect = {
			bitmap_w,bitmap_h,
			-bitmap_w,-bitmap_h
		}
	})
	local edge_left = panel:bitmap({
		name = "edge_left",
		x = 0,
		y = bitmap_h,
		w = bitmap_w,
		h = ver_size,
		valign = "grow",
		halign = "left",
		color = color,
		texture = texture,
		texture_rect = {
			0,bitmap_h,
			bitmap_w,bitmap_h
		}
	})
	local edge_right = panel:bitmap({
		name = "edge_right",
		x = w - bitmap_w,
		y = bitmap_h,
		w = bitmap_w,
		h = ver_size,
		valign = "grow",
		halign = "right",
		texture = texture,
		color = color,
		texture_rect = {
			bitmap_w,bitmap_h,
			-bitmap_w,bitmap_h
		}
	})
	local edge_top = panel:bitmap({
		name = "edge_top",
		x = bitmap_w,
		y = 0,
		w = hor_size,
		h = bitmap_h,
		valign = "top",
		halign = "grow",
		color = color,
		texture = texture,
		texture_rect = {
			bitmap_w,0,
			bitmap_w,bitmap_h
		}
	})
	local edge_bottom = panel:bitmap({
		name = "edge_bottom",
		x = bitmap_w,
		y = h - bitmap_h,
		w = hor_size,
		h = bitmap_h,
		valign = "bottom",
		halign = "grow",
		color = color,
		texture = texture,
		texture_rect = {
			bitmap_w,bitmap_h,
			bitmap_w,-bitmap_h
		}
	})
	
	local center = panel:bitmap({
		name = "center",
		x = bitmap_w,
		y = bitmap_h,
		w = hor_size,
		h = ver_size,
		valign = "grow",
		halign = "grow",
		color = color,
		texture = texture,
		texture_rect = {
			bitmap_w,bitmap_h,
			bitmap_w,-bitmap_h
		}
	})
	
	if child_config then
		corner_topleft:configure(child_config)
		corner_bottomleft:configure(child_config)
		corner_topright:configure(child_config)
		corner_bottomright:configure(child_config)
		edge_left:configure(child_config)
		edge_right:configure(child_config)
		edge_top:configure(child_config)
		edge_bottom:configure(child_config)
		center:configure(child_config)
	end
	
	return panel
end


return HEVHUDBase