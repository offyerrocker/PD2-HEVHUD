local HEVHUDCrosshair = blt_class(HEVHUDCore:require("classes/HEVHUDBase"))
local AnimateLibrary = HEVHUDCore:require("classes/AnimateLibrary")


function HEVHUDCrosshair:init(panel,settings,config,...)
	HEVHUDCrosshair.super.init(self,panel,settings,config,...)
	local vars = config.Crosshair
	self._panel = panel:panel({
		name = "crosshairs",
		valign = "center",
		halign = "center",
		w = panel:w(),
		h = panel:h(),
		layer = 1,
		alpha = 1,
		visible = settings.hud_crosshair_enabled
	})
	self._panel:set_center(panel:w()/2,panel:h()/2)
	
	self:setup(settings,config)
	self:recreate_hud()
	self:set_left_crosshair(1)
	self:set_right_crosshair(1)
end

function HEVHUDCrosshair:setup(settings,config,...)
	HEVHUDCrosshair.super.setup(self,settings,config,...)
	local vars = config.Crosshair
	self._CROSSHAIR_INDICATOR_SIZE = vars.CROSSHAIR_INDICATOR_SIZE
	
	self._VALUE_THRESHOLD_LOW = vars.VALUE_THRESHOLD_LOW
	self._VALUE_THRESHOLD_CRITICAL = vars.VALUE_THRESHOLD_CRITICAL
	
	self._ANIM_TIMEOUT_WAIT_DURATION = config.General.ANIM_TIMEOUT_WAIT_DURATION
	self._ANIM_TIMEOUT_FADE_DURATION = config.General.ANIM_TIMEOUT_FADE_DURATION
	
	self._CROSSHAIR_ALPHA_MIN = vars.CROSSHAIR_ALPHA_MIN
	self._CROSSHAIR_ALPHA_MAX = vars.CROSSHAIR_ALPHA_MAX
	
	self._CROSSHAIR_IMAGE_SIZE = vars.CROSSHAIR_IMAGE_SIZE
end

function HEVHUDCrosshair:recreate_hud()
	local vars = self._config.Crosshair
	
	local crosshair_size = self._CROSSHAIR_INDICATOR_SIZE
	local crosshair_distance = 32
	
	local crosshairs = self._panel
	local crosshair_dots = crosshairs:bitmap({
		name = "crosshair_dots",
		w = crosshair_size,
		h = crosshair_size,
		texture = "guis/textures/hl2_crosshair_fivedot",
		valign = "grow",
		halign = "grow",
		color = Color.white,
		layer = 3
	})
	crosshair_dots:set_center(crosshairs:w()/2,crosshairs:h()/2)
	
	local crosshair_empty_left = crosshairs:bitmap({
		name = "crosshair_empty_left",
		texture = "guis/textures/hl2_crosshair_empty_left",
		w = crosshair_size,
		h = crosshair_size,
		x = -crosshair_distance + (crosshairs:w() - crosshair_size) / 2,
		y = (crosshairs:h() - crosshair_size) / 2,
		color = self._COLOR_YELLOW,
		layer = 2
	})
	local crosshair_empty_right = crosshairs:bitmap({
		name = "crosshair_empty_right",
		texture = "guis/textures/hl2_crosshair_empty_right",
		w = crosshair_size,
		h = crosshair_size,
		x = crosshair_distance + (crosshairs:w() - crosshair_size) / 2,
		y = (crosshairs:h() - crosshair_size) / 2,
		valign = "grow",
		halign = "grow",
		color = self._COLOR_YELLOW,
		layer = 2
	})
	local crosshair_fill_left = crosshairs:bitmap({
		name = "crosshair_fill_left",
		texture = "guis/textures/hl2_crosshair_fill_left",
		w = crosshair_size,
		h = crosshair_size,
		x = -crosshair_distance + (crosshairs:w() - crosshair_size) / 2,
		y = (crosshairs:h() - crosshair_size) / 2,
		valign = "grow",
		halign = "grow",
		color = self._COLOR_YELLOW,
		layer = 3
	})
	local crosshair_fill_right = crosshairs:bitmap({
		name = "crosshair_fill_right",
		texture = "guis/textures/hl2_crosshair_fill_right",
		w = crosshair_size,
		h = crosshair_size,
		x = crosshair_distance + (crosshairs:w() - crosshair_size) / 2,
		y = (crosshairs:h() - crosshair_size) / 2,
		valign = "grow",
		halign = "grow",
		color = self._COLOR_YELLOW,
		layer = 3
	})
end

function HEVHUDCrosshair:set_right_crosshair(value)	
	local crosshair_master = self._panel
	local crosshair = crosshair_master:child("crosshair_fill_right")
	local crosshair_outline = crosshair_master:child("crosshair_empty_right")
	local IMAGE_SIZE = self._CROSSHAIR_IMAGE_SIZE
	local INDICATOR_SIZE = self._CROSSHAIR_INDICATOR_SIZE
	
	crosshair:set_texture_rect(0,IMAGE_SIZE * (1 - value),IMAGE_SIZE,IMAGE_SIZE * value)
	crosshair:set_h(INDICATOR_SIZE * (value))
	crosshair:set_y(((crosshair_master:h() - INDICATOR_SIZE) / 2) + ((1 - value) * INDICATOR_SIZE))
	
	local blend_mode = value < self._VALUE_THRESHOLD_CRITICAL and "add" or "normal"
	crosshair:set_blend_mode(blend_mode)
	crosshair_outline:set_blend_mode(blend_mode)
	local color = HEVHUD:GetRangedColor(value)
	if color then 
		crosshair:set_color(color)
		crosshair_outline:set_color(color)
	end
	self.animate_inactive_fadeout(crosshair_master,self._ANIM_TIMEOUT_WAIT_DURATION,self._ANIM_TIMEOUT_FADE_DURATION,self._CROSSHAIR_ALPHA_MIN,self._CROSSHAIR_ALPHA_MAX)
end

function HEVHUDCrosshair:set_left_crosshair(value)
	local crosshair_master = self._panel
	local crosshair = crosshair_master:child("crosshair_fill_left")
	local crosshair_outline = crosshair_master:child("crosshair_empty_left")
	local IMAGE_SIZE = self._CROSSHAIR_IMAGE_SIZE
	local INDICATOR_SIZE = self._CROSSHAIR_INDICATOR_SIZE
	
	crosshair:set_texture_rect(0,IMAGE_SIZE * (1 - value),IMAGE_SIZE,IMAGE_SIZE * value)
	crosshair:set_h(INDICATOR_SIZE * (value))
	crosshair:set_y(((crosshair_master:h() - INDICATOR_SIZE) / 2) + ((1 - value) * INDICATOR_SIZE))
	
	local blend_mode = value < self._VALUE_THRESHOLD_CRITICAL and "add" or "normal"
	crosshair:set_blend_mode(blend_mode)
	crosshair_outline:set_blend_mode(blend_mode)
	local color = HEVHUD:GetRangedColor(value)
	if color then 
		crosshair:set_color(color)
		crosshair_outline:set_color(color)
	end
	self.animate_inactive_fadeout(crosshair_master,self._ANIM_TIMEOUT_WAIT_DURATION,self._ANIM_TIMEOUT_FADE_DURATION,self._CROSSHAIR_ALPHA_MIN,self._CROSSHAIR_ALPHA_MAX)
end


return HEVHUDCrosshair