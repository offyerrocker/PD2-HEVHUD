local HEVHUDCarry = blt_class(HEVHUDCore:require("classes/HEVHUDBase"))
local AnimateLibrary = HEVHUDCore:require("classes/AnimateLibrary")

function HEVHUDCarry:init(panel,settings,config,...)
	HEVHUDCarry.super.init(self,panel,settings,config,...)
	
	local vars = self._config.Carry
	self._panel = panel:panel({
		name = "carry",
		w = vars.CARRY_W,
		h = vars.CARRY_H,
		x = vars.CARRY_HOR_OFFSET + panel:w() - vars.CARRY_W,
		y = vars.CARRY_VER_OFFSET + panel:h() - vars.CARRY_H,
		valign = "bottom",
		halign = "right"
	})
	
	--self._save_data.bag_label = nil -- string
	self:setup(settings,config)
	self:recreate_hud()
end

function HEVHUDCarry:setup(settings,config,...)
	HEVHUDCarry.super.setup(self,settings,config,...)
	local vars = config.Carry
	
	self._BAG_ANIM_ALPHA_ENABLED = vars.BAG_ANIM_ALPHA_ENABLED
	
	self._BAG_AUTO_W_ENABLED = vars.BAG_AUTO_W_ENABLED
	self._BAG_AUTO_W_HOR_MARGIN = vars.BAG_AUTO_W_HOR_MARGIN + vars.BAG_LABEL_HOR_OFFSET
	
	-- bag value representation?
end

-- create permanent hud elements (not ephemeral ones)
function HEVHUDCarry:recreate_hud()
	local vars = self._config.Carry
	self._panel:clear()
	
	local bag = self._panel:panel({
		name = "bag",
		w = vars.BAG_W,
		h = vars.BAG_H,
		valign = "grow",
		halign = "grow",
--		alpha = self._BAG_ANIM_ALPHA_ENABLED and 0 or 1,
		visible = false
	})
	self._bag = bag
	self._bag_bgbox = self.CreateBGBox(bag,nil,self._BGBOX_PANEL_CONFIG,self._BGBOX_TILE_CONFIG)
	
	local texture,texture_rect = tweak_data.hud_icons:get_icon_data("pd2_loot")
	local bag_icon = bag:bitmap({
		name = "bag_icon",
		texture = texture,
		texture_rect = texture_rect,
		w = vars.BAG_ICON_W,
		h = vars.BAG_ICON_H,
		x = vars.BAG_ICON_OFFSET_HOR,
		y = vars.BAG_ICON_OFFSET_VER,
		color = self._COLOR_YELLOW,
		layer = 3,
		valign = "top",
		halign = "left"
	})
	
	local bag_label = bag:text({
		name = "bag_label",
		text = "", --self._save_data.bag_label or "",
		font = vars.BAG_LABEL_FONT_NAME,
		font_size = vars.BAG_LABEL_FONT_SIZE,
		x = vars.BAG_LABEL_HOR_OFFSET,
		y = vars.BAG_LABEL_VER_OFFSET,
		color = self._COLOR_YELLOW,
		layer = 3,
		valign = "grow",
		halign = "grow"
	})
end


--function HEVHUDCarry:clbk_on_settings_changed(settings,...)
--	HEVHUDCarry.super.clbk_on_settings_changed(self,settings,...)
--end

function HEVHUDCarry:clbk_on_config_changed(config,...)
	HEVHUDCarry.super.clbk_on_config_changed(self,config,...)
	
	local vars = config.Carry
	if alive(self._panel) then
		self._panel:configure({
			w = vars.CARRY_W,
			h = vars.CARRY_H,
			x = vars.CARRY_HOR_OFFSET + self._parent:w() - vars.CARRY_W,
			y = vars.CARRY_VER_OFFSET + self._parent:h() - vars.CARRY_H
		})
	end
end

function HEVHUDCarry:show_carry_bag(carry_id,value)
	local vars = self._config.Carry
	
	
	local carry_data = tweak_data.carry[carry_id]
	local type_text = managers.localization:text(carry_data.name_id)
	
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
		
		label:set_text("")
	end
	
	bag:show()
	
	local cb = function(o)
		o:child("bag_label"):animate(AnimateLibrary.animate_text_gradual,nil,vars.CARRY_TEXT_ANIM_DURATION,type_text)
	end
	bag:set_x(self._panel:w())
	bag:animate(AnimateLibrary.animate_move_lerp,not self._BAG_ANIM_ALPHA_ENABLED and cb,vars.CARRY_INTRO_ANIM_DURATION,self._panel:w() - bag:w()) -- appear from left
	
	if self._BAG_ANIM_ALPHA_ENABLED then
		bag:animate(AnimateLibrary.animate_alpha_lerp,cb,vars.CARRY_INTRO_ANIM_DURATION,nil,1)
	end
end

function HEVHUDCarry:hide_carry_bag()
	local vars = self._config.Carry
	local CARRY_OUTRO_ANIM_DURATION = vars.CARRY_OUTRO_ANIM_DURATION
	
	local bag = self._bag
	bag:stop()
	local cb = function(o)
		o:child("bag_label"):set_text("")
		o:hide()
		o:set_alpha(1)
		o:set_w(vars.BAG_W)
		--o:set_right(self._panel:w())
	end
	
	bag:animate(AnimateLibrary.animate_move_lerp,cb,CARRY_OUTRO_ANIM_DURATION,self._panel:w()) -- move right offscreen
	
	if self._BAG_ANIM_ALPHA_ENABLED then
		bag:animate(AnimateLibrary.animate_alpha_lerp,nil,CARRY_OUTRO_ANIM_DURATION,nil,0)
	end
--	bag:animate(AnimateLibrary.animate_grow_w_right,cb,self._CARRY_OUTRO_ANIM_DURATION,nil,1)
end



return HEVHUDCarry