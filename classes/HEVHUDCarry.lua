local HEVHUDCarry = blt_class(HEVHUDCore:require("classes/HEVHUDBase"))
local AnimateLibrary = HEVHUDCore:require("classes/AnimateLibrary")

function HEVHUDCarry:init(panel,settings,config,...)
	HEVHUDCarry.super.init(self,panel,settings,config,...)
	
	local vars = self._config.Carry
	self._panel = panel:panel({
		name = "carry",
		w = vars.CARRY_W,
		h = vars.CARRY_H,
		valign = "bottom",
		halign = "right"
	})
	
	self:setup()
end

function HEVHUDCarry:setup()
	local vars = self._config.Carry
	self._panel:configure({
		w = vars.CARRY_W,
		h = vars.CARRY_H,
		x = vars.CARRY_HOR_OFFSET + self._parent:w() - vars.CARRY_W,
		y = vars.CARRY_VER_OFFSET + self._parent:h() - vars.CARRY_H
	})
	
	self._CARRY_TEXT_ANIM_DURATION = vars.CARRY_TEXT_ANIM_DURATION
	self._CARRY_INTRO_ANIM_DURATION = vars.CARRY_INTRO_ANIM_DURATION
	self._CARRY_OUTRO_ANIM_DURATION = vars.CARRY_OUTRO_ANIM_DURATION
	self._TEXT_COLOR_FULL = HEVHUD.colordecimal_to_color(self._settings.color_hl2_yellow)
	self._BAG_AUTO_W_ENABLED = vars.BAG_AUTO_W_ENABLED
	self._BAG_AUTO_W_HOR_MARGIN = vars.BAG_AUTO_W_HOR_MARGIN + vars.BAG_LABEL_HOR_OFFSET
	self._BAG_ANIM_ALPHA_ENABLED = vars.BAG_ANIM_ALPHA_ENABLED
	local BG_BOX_ALPHA = self._config.General.BG_BOX_ALPHA
	self._BG_BOX_COLOR = HEVHUD.colordecimal_to_color(self._config.General.BG_BOX_COLOR)
	
	self._BAG_W = vars.BAG_W
	
	local vars = self._config.Carry
	
	local bag = self._panel:panel({
		name = "bag",
		w = vars.BAG_W,
		h = vars.BAG_H,
		valign = "grow",
		halign = "grow",
		alpha = 0
	})
	self._bag = bag
	
	self._bag_bgbox = self.CreateBGBox(bag,nil,nil,{alpha=BG_BOX_ALPHA,valign="grow",halign="grow"},{color=self._BG_BOX_COLOR})
	
	local texture,texture_rect = tweak_data.hud_icons:get_icon_data("pd2_loot")
	local bag_icon = bag:bitmap({
		name = "bag_icon",
		texture = texture,
		texture_rect = texture_rect,
		w = vars.BAG_ICON_W,
		h = vars.BAG_ICON_H,
		x = vars.BAG_ICON_OFFSET_HOR,
		y = vars.BAG_ICON_OFFSET_VER,
		color = self._TEXT_COLOR_FULL,
		layer = 3,
		valign = "top",
		halign = "left"
	})
	
	local bag_label = bag:text({
		name = "bag_label",
		text = "trauma",
		font = vars.BAG_LABEL_FONT_NAME,
		font_size = vars.BAG_LABEL_FONT_SIZE,
		x = vars.BAG_LABEL_HOR_OFFSET,
		y = vars.BAG_LABEL_VER_OFFSET,
		color = self._TEXT_COLOR_FULL,
		layer = 3,
		valign = "grow",
		halign = "grow"
	})
	-- value representation? dollar/regional currency signs?
	
	--self._anim_bag_move_thread = nil
	--bag:animate(AnimateLibrary.animate_move_lerp,cb_done,self._CARRY_OUTRO_ANIM_DURATION,nil,-bag:h())
	
end

function HEVHUDCarry:show_carry_bag(carry_id,value)
	local carry_data = tweak_data.carry[carry_id]
	local type_text = carry_data.name_id and managers.localization:text(carry_data.name_id)
	
	local bag = self._bag
	bag:stop()
	
	local label = bag:child("bag_label")
	
	if self._BAG_AUTO_W_ENABLED then
		-- get the final size of text object
		label:set_text(type_text)
		local x,y,w,h = label:text_rect()
		--Print(x,y,w,h)

		local w2 = w + self._BAG_AUTO_W_HOR_MARGIN
		if w2 > 32 then -- min size for the bgbox
			bag:set_w(w2)
		end
--		local w2 = w + self._BAG_AUTO_W_HOR_MARGIN
--		if w2 > self._BAG_W then
--			bag:set_w(w2)
--		end
		
		label:set_text("")
	end
	
	bag:show()
	
	local cb = function(o)
		o:child("bag_label"):animate(AnimateLibrary.animate_text_gradual,nil,self._CARRY_TEXT_ANIM_DURATION,type_text)
	end
	bag:set_x(self._panel:w())
	bag:animate(AnimateLibrary.animate_move_lerp,nil,self._CARRY_INTRO_ANIM_DURATION,self._panel:w() - bag:w()) -- appear from left
	
	if self._BAG_ANIM_ALPHA_ENABLED then
		bag:animate(AnimateLibrary.animate_alpha_lerp,cb,self._CARRY_INTRO_ANIM_DURATION,nil,1)
	end
--	bag:animate(AnimateLibrary.animate_grow_w_right,cb,self._CARRY_INTRO_ANIM_DURATION,nil,self._BAG_W)
end

function HEVHUDCarry:hide_carry_bag()
	local bag = self._bag
	bag:stop()
	local cb = function(o)
		o:child("bag_label"):set_text("")
		o:hide()
		o:set_alpha(1)
		o:set_w(self._BAG_W)
		--o:set_right(self._panel:w())
	end
	
	bag:animate(AnimateLibrary.animate_move_lerp,cb,self._CARRY_OUTRO_ANIM_DURATION,self._panel:w()) -- move right offscreen
	
	if self._BAG_ANIM_ALPHA_ENABLED then
		bag:animate(AnimateLibrary.animate_alpha_lerp,cb,self._CARRY_OUTRO_ANIM_DURATION,nil,0)
	end
--	bag:animate(AnimateLibrary.animate_grow_w_right,cb,self._CARRY_OUTRO_ANIM_DURATION,nil,1)
end



return HEVHUDCarry