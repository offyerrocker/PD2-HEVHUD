local HEVHUDBase = blt_class() -- base class for HEVHUD HUD classes
local AnimateLibrary = HEVHUDCore:require("classes/AnimateLibrary")

function HEVHUDBase:init(parent,settings,config)
	self._parent = parent
	self._settings = settings
	self._config = config
	
	local key = tostring(self)
	Hooks:Add("hevhud_on_settings_changed","hevhud_on_settings_changed_" .. key,callback(self,self,"clbk_on_settings_changed"))
	Hooks:Add("hevhud_on_config_changed","hevhud_on_config_changed_" .. key,callback(self,self,"clbk_on_config_changed"))
	
	--self._save_data = {} -- save any data passed to the hud, so that it can be remade if the user changes settings and triggers a hud refresh
	self:setup(settings,config)
end

-- should be overloaded by child classes
function HEVHUDBase:recreate_hud()
end

-- setup should be called whenever settings or config are changed,
-- or on first time setup (before panel creation).
function HEVHUDBase:setup(settings,config)
	self._COLOR_YELLOW = HEVHUD.colordecimal_to_color(settings.color_hl2_yellow)
	self._COLOR_ORANGE = HEVHUD.colordecimal_to_color(settings.color_hl2_orange)
	self._COLOR_RED = HEVHUD.colordecimal_to_color(settings.color_hl2_red)
	self._COLOR_GREY = HEVHUD.colordecimal_to_color(settings.color_hl2_grey)
	
	self._BG_BOX_ALPHA = config.General.BG_BOX_ALPHA
	self._BG_BOX_COLOR = HEVHUD.colordecimal_to_color(config.General.BG_BOX_COLOR)
	self._BGBOX_PANEL_CONFIG = {alpha=self._BG_BOX_ALPHA,valign="grow",halign="grow"}
	self._BGBOX_TILE_CONFIG = {color=self._BG_BOX_COLOR}
end

function HEVHUDBase.format_amount_str(amounts,implicit_one)
	local amount_1,amount_2
	local has_any
	if type(amounts) == "table" then
		amount_1 = amounts[1]
		amount_2 = amounts[2]
	else
		amount_1 = amounts
		amount_2 = nil
	end
	
	has_any = (amount_2 and amount_2 > 0) or (amount_1 and amount_1 > 0)
	if amount_2 then
		-- assume that secondary amount should never be alone
		local str_1 = string.format("%i",amount_1 or 0)
		local str_2 = string.format("%i",amount_2)
		return str_1 .. HEVHUD._font_icons.slash .. str_2,has_any
	else
		local str_1
		if amount_1 and (not implicit_one or amount_1 ~= 1) then
			str_1 = string.format("%i",amount_1)
		else
			str_1 = ""
		end
		return str_1,has_any
	end
end


function HEVHUDBase:pre_destroy()
	if alive(self._panel) then
		self._panel:parent():remove(self._panel)
	end
	self._panel = nil
	self._parent = nil
end

function HEVHUDBase:clbk_on_settings_changed(settings)
	self._settings = settings
	self:setup(settings,self._config)
end

function HEVHUDBase:clbk_on_config_changed(config)
	self._config = config
	self:setup(self._settings,config)
end

function HEVHUDBase.CreateBGBox(parent,bgbox_config,panel_config,child_config)
	local w = (bgbox_config and bgbox_config.w) or parent:w()
	local h = (bgbox_config and bgbox_config.h) or parent:h()
	local panel = parent:panel({
		name = "bgbox",
		w = w,
		h = h,
		alpha = 0.5,
		layer = -1
	})
	if panel_config then
		panel:configure(panel_config)
	end
	
	--local tile_w_scale = bgbox_config and (bgbox_config.w_scale or bgbox_config.scale) or 1
	--local tile_h_scale = bgbox_config and (bgbox_config.h_scale or bgbox_config.scale) or 1
	
	-- individual tile sizes in texture file
	local RAW_BITMAP_W = 16
	local RAW_BITMAP_H = 16
	
	local tile_w = bgbox_config and (bgbox_config.w or bgbox_config.tile_size) or RAW_BITMAP_W -- or (tile_w_scale * RAW_BITMAP_W)
	local tile_h = bgbox_config and (bgbox_config.h or bgbox_config.tile_size) or RAW_BITMAP_H -- or (tile_h_scale * RAW_BITMAP_H)
	
	local hor_size = w - (tile_w + tile_w)
	local ver_size = h - (tile_h + tile_h)
	
	local color = Color.black
	local texture = "guis/textures/hevhud_bgbox_atlas"
	local corner_topleft = panel:bitmap({
		name = "corner_topleft",
		x = 0,
		y = 0,
		w = tile_w,
		h = tile_h,
		valign = "top",
		halign = "left",
		color = color,
		texture = texture,
		texture_rect = {
			0,0,
			RAW_BITMAP_W,RAW_BITMAP_H
		}
	})
	local corner_bottomleft = panel:bitmap({
		name = "corner_bottomleft",
		x = 0,
		y = h - tile_h,
		w = tile_w,
		h = tile_h,
		valign = "bottom",
		halign = "left",
		color = color,
		texture = texture,
		texture_rect = {
			0,RAW_BITMAP_H,
			RAW_BITMAP_W,-RAW_BITMAP_H
		}
	})
	local corner_topright = panel:bitmap({
		name = "corner_topright",
		x = w - tile_w,
		y = 0,
		w = tile_w,
		h = tile_h,
		valign = "top",
		halign = "right",
		color = color,
		texture = texture,
		texture_rect = {
			RAW_BITMAP_W,0,
			-RAW_BITMAP_W,RAW_BITMAP_H
		}
	})
	local corner_bottomright = panel:bitmap({
		name = "corner_bottomright",
		x = w - tile_w,
		y = h - tile_h,
		w = tile_w,
		h = tile_h,
		valign = "bottom",
		halign = "right",
		color = color,
		texture = texture,
		texture_rect = {
			RAW_BITMAP_W,RAW_BITMAP_H,
			-RAW_BITMAP_W,-RAW_BITMAP_H
		}
	})
	local edge_left = panel:bitmap({
		name = "edge_left",
		x = 0,
		y = tile_h,
		w = tile_w,
		h = ver_size,
		valign = "grow",
		halign = "left",
		color = color,
		texture = texture,
		texture_rect = {
			0,RAW_BITMAP_H,
			RAW_BITMAP_W,RAW_BITMAP_H
		}
	})
	local edge_right = panel:bitmap({
		name = "edge_right",
		x = w - tile_w,
		y = tile_h,
		w = tile_w,
		h = ver_size,
		valign = "grow",
		halign = "right",
		texture = texture,
		color = color,
		texture_rect = {
			RAW_BITMAP_W,RAW_BITMAP_H,
			-RAW_BITMAP_W,RAW_BITMAP_H
		}
	})
	local edge_top = panel:bitmap({
		name = "edge_top",
		x = tile_w,
		y = 0,
		w = hor_size,
		h = tile_h,
		valign = "top",
		halign = "grow",
		color = color,
		texture = texture,
		texture_rect = {
			RAW_BITMAP_W,0,
			RAW_BITMAP_W,RAW_BITMAP_H
		}
	})
	local edge_bottom = panel:bitmap({
		name = "edge_bottom",
		x = tile_w,
		y = h - tile_h,
		w = hor_size,
		h = tile_h,
		valign = "bottom",
		halign = "grow",
		color = color,
		texture = texture,
		texture_rect = {
			RAW_BITMAP_W,RAW_BITMAP_H,
			RAW_BITMAP_W,-RAW_BITMAP_H
		}
	})
	
	local center = panel:bitmap({
		name = "center",
		x = tile_w,
		y = tile_h,
		w = hor_size,
		h = ver_size,
		valign = "grow",
		halign = "grow",
		color = color,
		texture = texture,
		texture_rect = {
			RAW_BITMAP_W,RAW_BITMAP_H,
			RAW_BITMAP_W,-RAW_BITMAP_H
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

function HEVHUDBase.animate_inactive_fadeout(o,anim_timeout_duration,anim_alpha_duration,alpha_min,alpha_max)
	o:set_alpha(alpha_max)
	o:stop()
	return o:animate(AnimateLibrary.animate_wait,anim_timeout_duration,AnimateLibrary.animate_alpha_lerp,nil,anim_alpha_duration,nil,alpha_min)
end

return HEVHUDBase