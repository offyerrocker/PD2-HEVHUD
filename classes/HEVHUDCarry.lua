local HEVHUDCarry = blt_class(HEVHUDCore:require("classes/HEVHUDBase"))
local AnimateLibrary = HEVHUDCore:require("classes/AnimateLibrary")

function HEVHUDCarry:init(panel,settings,config)
	HEVHUDCarry.super.init(self,panel,settings,config,...)
	
	local vars = self._config.Carry
	self._panel = panel:panel({
		name = "carry",
		w = vars.CARRY_W,
		h = vars.CARRY_H,
		x = vars.CARRY_X,
		y = vars.CARRY_Y,
		valign = "bottom",
		halign = "right"
	})
	self._panel:rect({
		name = "debug",
		color = Color.red,
		alpha = 0.1
	})
	
	self:setup()
end

function HEVHUDCarry:setup()
	local vars = self._config.Carry
	self._panel:configure({
		w = vars.CARRY_W,
		h = vars.CARRY_H,
		x = vars.CARRY_X,
		y = vars.CARRY_Y
	})
	
	self._CARRY_TEXT_ANIM_DURATION = vars.CARRY_TEXT_ANIM_DURATION
	self._CARRY_INTRO_ANIM_DURATION = vars.CARRY_INTRO_ANIM_DURATION
	self._CARRY_OUTRO_ANIM_DURATION = vars.CARRY_OUTRO_ANIM_DURATION
	self._TEXT_COLOR_FULL = HEVHUD.colordecimal_to_color(self._settings.color_hl2_yellow)
	local BG_BOX_ALPHA = self._config.General.BG_BOX_ALPHA
	self._BG_BOX_COLOR = HEVHUD.colordecimal_to_color(self._config.General.BG_BOX_COLOR)
	
	local vars = self._config.Carry
	
	local bag = self._panel:panel({
		name = "bag",
		w = vars.BAG_W,
		h = vars.BAG_H
	})
	self._bag = bag
	
	self._bag_bgbox = self.CreateBGBox(bag,nil,nil,{alpha=BG_BOX_ALPHA,valign="grow",halign="grow"},{color=self._BG_BOX_COLOR})
	
	local texture,texture_rect = tweak_data.hud_icons:get_icon_data("wp_bag")
	local bag_icon = bag:bitmap({
		name = "bag_icon",
		texture = texture,
		texture_rect = texture_rect,
		w = vars.BAG_ICON_W,
		h = vars.BAG_ICON_H,
		x = vars.BAG_ICON_OFFSET_HOR,
		y = vars.BAG_ICON_OFFSET_VER,
		color = self._TEXT_COLOR_FULL,
		layer = 3
	})
	
	local bag_label = bag:text({
		name = "bag_label",
		text = "trauma",
		font = vars.BAG_LABEL_FONT_NAME,
		font_size = vars.BAG_LABEL_FONT_SIZE,
		x = vars.BAG_LABEL_HOR_OFFSET,
		y = vars.BAG_LABEL_VER_OFFSET,
		color = self._TEXT_COLOR_FULL,
		layer = 3
	})
	-- value representation? dollar/regional currency signs?
	
	--self._anim_bag_move_thread = nil
	--bag:animate(AnimateLibrary.animate_move_lerp,cb_done,self._CARRY_OUTRO_ANIM_DURATION,nil,-bag:h())
	
end

function HEVHUDCarry:show_carry_bag(carry_id,value)
	local bag = self._bag
	bag:stop()
	
	local carry_data = tweak_data.carry[carry_id]
	local type_text = carry_data.name_id and managers.localization:text(carry_data.name_id)
	
	bag:child("bag_label"):animate(AnimateLibrary.animate_text_gradual,nil,self._CARRY_TEXT_ANIM_DURATION,type_text) -- animate this text?
	bag:set_x(-bag:w())
	bag:animate(AnimateLibrary.animate_move_lerp,nil,self._CARRY_INTRO_ANIM_DURATION,self._panel:w())
	bag:animate(AnimateLibrary.animate_alpha_lerp,nil,self._CARRY_INTRO_ANIM_DURATION,nil,1)
end

function HEVHUDCarry:hide_carry_bag()
	local bag = self._bag
	bag:stop()
	local cb = function(o)
		o:child("bag_label"):set_text("")
		o:hide()
		o:set_alpha(1)
	end
	bag:animate(AnimateLibrary.animate_move_lerp,cb,self._CARRY_OUTRO_ANIM_DURATION,bag:w()) -- move right offscreen
	bag:animate(AnimateLibrary.animate_alpha_lerp,nil,self._CARRY_OUTRO_ANIM_DURATION,nil,0)
end



return HEVHUDCarry