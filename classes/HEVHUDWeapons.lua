local HEVHUDWeapons = blt_class(HEVHUDCore:require("classes/HEVHUDBase"))
local AnimateLibrary = HEVHUDCore:require("classes/AnimateLibrary")

HEVHUDWeapons.FIREMODE_ICONS = {
	single = "firemode_single",
	burst = "firemode_burst",
	auto = "firemode_auto",
	volley = "firemode_volley"
}

function HEVHUDWeapons:init(panel,settings,config,...)
	HEVHUDWeapons.super.init(self,panel,settings,config,...)
	
	local vars = self._config.Weapons
	local weapons = panel:panel({
		name = "weapons",
		layer = 1,
		w = vars.WEAPONS_W,
		h = vars.WEAPONS_H
	})
	self._panel = weapons
	
	self._underbarrel_visible = nil
	self._underbarrel_on = nil
	self._anim_main_weapon_swap_thread = nil -- plays when switching between two weapons that do and don't have an underbarrel
	self._anim_underbarrel_ammo_swap_thread = nil
	
	self._anim_main_ammo_equip_thread = nil -- plays when equipping/unequipping the underbarrel on your current weapon
	self._anim_underbarrel_ammo_equip_thread = nil -- plays when equipping/unequipping the underbarrel on your current weapon
	self:setup()
	self:set_underbarrel_on(false)
	self:set_underbarrel_visible(false)
end

function HEVHUDWeapons:setup()
	local vars = self._config.Weapons
	self._panel:set_size(vars.WEAPONS_W,vars.WEAPONS_H)
	self._panel:set_position(vars.WEAPONS_HOR_OFFSET + self._parent:w()-self._panel:w(),vars.WEAPONS_VER_OFFSET + self._parent:h() - self._panel:h())
	self._panel:set_valign(vars.WEAPONS_VALIGN)
	self._panel:set_halign(vars.WEAPONS_HALIGN)
	
	self._AMMO_PANEL_INACTIVE_ALPHA = vars.AMMO_PANEL_INACTIVE_ALPHA
	self._AMMO_PANEL_ACTIVE_ALPHA = vars.AMMO_PANEL_ACTIVE_ALPHA
	self._AMMO_SWAP_ANIM_DURATION = vars.AMMO_SWAP_ANIM_DURATION
	self._EQUIP_UNDERBARREL_ANIM_DURATION = vars.EQUIP_UNDERBARREL_ANIM_DURATION	
	self._MAIN_AMMO_HOR_OFFSET = vars.MAIN_AMMO_HOR_OFFSET
	self._TEXT_COLOR_FULL = HEVHUD.colordecimal_to_color(self._settings.color_hl2_yellow)
	self._TEXT_COLOR_HALF = HEVHUD.colordecimal_to_color(self._settings.color_hl2_orange)
	self._TEXT_COLOR_NONE = HEVHUD.colordecimal_to_color(self._settings.color_hl2_red)
	
	self._ANIM_BGBOX_FLASH_DURATION = vars.ANIM_BGBOX_FLASH_DURATION
	self._ANIM_BGBOX_ALPHA = vars.ANIM_BGBOX_ALPHA
	
	self._BG_BOX_COLOR = HEVHUD.colordecimal_to_color(self._config.General.BG_BOX_COLOR)
	local BG_BOX_ALPHA = self._config.General.BG_BOX_ALPHA
	self._BG_BOX_ALPHA = BG_BOX_ALPHA
	local ICONS_FONT_NAME = self._config.General.ICONS_FONT_NAME
	local bgbox_panel_config = {alpha=BG_BOX_ALPHA,valign="grow",halign="grow"}
	local bgbox_item_config = {color=self._BG_BOX_COLOR}
	
	local main_weapon = self._panel:panel({
		name = "main_weapon",
		w = vars.MAIN_WEAPON_W,
		h = vars.MAIN_WEAPON_H,
		x = self._panel:w() - vars.MAIN_WEAPON_W,
		y = self._panel:h() - vars.MAIN_WEAPON_H,
		layer = 1
	})
	self._main_weapon = main_weapon
	
	local grenades = main_weapon:panel({
		name = "grenades",
		w = vars.GRENADES_W,
		h = vars.GRENADES_H,
--		x = main_weapon:w() - vars.GRENADES_W,
		y = main_weapon:h() - vars.GRENADES_H,
		valign = "bottom",
		halign = "left",
		layer = 2
	})
	self._grenades = grenades
	
	self._grenades_ammo_bgbox = self.CreateBGBox(grenades,nil,nil,bgbox_panel_config,bgbox_item_config)
	
	grenades:bitmap({
		name = "icon",
		w = vars.GRENADES_ICON_W,
		h = vars.GRENADES_ICON_H,
		x = vars.GRENADES_ICON_X,
		y = vars.GRENADES_ICON_Y,
		valign = "grow",
		halign = "grow",
		texture = "fonts/halflife2", 
		texture_rect = {133,155,30,18},
		color = self._TEXT_COLOR_FULL,
		layer = 2
	})
	grenades:text({
		name = "amount",
		text = "99",
		align = vars.GRENADES_LABEL_ALIGN,
		vertical = vars.GRENADES_LABEL_VERTICAL,
		x = vars.GRENADES_LABEL_HOR_OFFSET,
		y = vars.GRENADES_LABEL_VER_OFFSET,
		valign = "grow",
		halign = "grow",
		font = vars.GRENADES_LABEL_FONT_NAME,
		font_size = vars.GRENADES_LABEL_FONT_SIZE,
		color = self._TEXT_COLOR_FULL,
		layer = 2
	})
		
	local main_ammo = main_weapon:panel({
		name = "main_ammo",
		w = vars.MAIN_AMMO_W,
		h = vars.MAIN_AMMO_H,
		x = main_weapon:w() - vars.MAIN_AMMO_W,
		y = main_weapon:h() - vars.MAIN_AMMO_H,
		valign = "bottom",
		halign = "right",
		layer = 1
	})
	self._main_ammo = main_ammo
	
	-- deal with placement later
	self._main_ammo_bgbox = self.CreateBGBox(main_ammo,nil,nil,bgbox_panel_config,bgbox_item_config)
	local ammo_name = main_ammo:text({
		name = "ammo_name",
		text = managers.localization:text("hevhud_hud_ammo"),
		align = "left",
		vertical = "bottom",
		x = vars.WEAPONS_NAME_HOR_OFFSET,
		y = vars.WEAPONS_NAME_VER_OFFSET,
		font = vars.AMMO_FONT_NAME,
		font_size = vars.NAME_FONT_SIZE,
		color = self._TEXT_COLOR_FULL,
		layer = 2
	})
	local ammo_icon = main_ammo:text({
		name = "ammo_icon",
		text = HEVHUD._font_icons.pistol_ammo,
		x = vars.ICON_HOR_OFFSET,
		y = vars.ICON_VER_OFFSET,
		font = ICONS_FONT_NAME,
		font_size = vars.ICONS_FONT_SIZE,
		color = self._TEXT_COLOR_FULL,
		layer = 2
	})
	local magazine = main_ammo:text({
		name = "magazine",
		text = "0",
		align = "left",
		vertical = "bottom",
		x = vars.MAGAZINE_HOR_OFFSET,
		y = vars.MAGAZINE_VER_OFFSET, -- + main_ammo:h() - vars.MAGAZINE_FONT_SIZE,
		font = ICONS_FONT_NAME,
		font_size = vars.MAGAZINE_FONT_SIZE,
		color = self._TEXT_COLOR_FULL,
		layer = 2
	})
	
	local reserve = main_ammo:text({
		name = "reserve",
		text = "0",
		align = "left",
		vertical = "bottom",
		x = vars.RESERVE_HOR_OFFSET,
		y = vars.RESERVE_VER_OFFSET, -- + main_ammo:h() - vars.RESERVE_FONT_SIZE,
		font = ICONS_FONT_NAME,
		font_size = vars.RESERVE_FONT_SIZE,
		color = self._TEXT_COLOR_FULL,
		layer = 2
	})
	
	local firemode_icon = main_ammo:bitmap({
		name = "firemode_icon",
		texture = "guis/textures/hevhud_icons",
		texture_rect = {0,32,32,32}, -- single
		w = vars.FIREMODE_ICON_W,
		h = vars.FIREMODE_ICON_H,
		x = vars.FIREMODE_ICON_HOR_OFFSET,
		y = vars.FIREMODE_ICON_VER_OFFSET,
		color = self._TEXT_COLOR_FULL,
		valign = "bottom",
		halign = "right",
		visible = true,
		layer = 3
	})
	
	local underbarrel_ammo = self._panel:panel({
		name = "underbarrel_ammo",
		w = vars.UNDERBARREL_AMMO_W,
		h = vars.UNDERBARREL_AMMO_H,
		x = self._panel:w() - vars.UNDERBARREL_AMMO_W,
		y = self._panel:h() - vars.UNDERBARREL_AMMO_H,
		alpha = 0,
		layer = 1
	})
	self._underbarrel_ammo = underbarrel_ammo
	self._underbarrel_ammo_bgbox = self.CreateBGBox(underbarrel_ammo,nil,nil,bgbox_panel_config,bgbox_item_config)

	local underbarrel_icon = underbarrel_ammo:text({
		name = "underbarrel_icon",
		text = HEVHUD._font_icons.grenadelauncher_ammo,
		x = vars.ICON_HOR_OFFSET,
		y = vars.ICON_VER_OFFSET,
		font = ICONS_FONT_NAME,
		font_size = vars.ICONS_FONT_SIZE,
		color = self._TEXT_COLOR_FULL,
		layer = 2
	})
	local underbarrel_name = underbarrel_ammo:text({
		name = "underbarrel_name",
		text = managers.localization:text("hevhud_hud_alt"),
		align = "left",
		vertical = "bottom",
		x = vars.WEAPONS_NAME_HOR_OFFSET,
		y = vars.WEAPONS_NAME_VER_OFFSET,
		font = vars.AMMO_FONT_NAME,
		font_size = vars.NAME_FONT_SIZE,
		color = self._TEXT_COLOR_FULL,
		layer = 2
	})
	local underbarrel_label = underbarrel_ammo:text({
		name = "underbarrel_label",
		text = "0",
		align = "left",
		x = vars.UNDERBARREL_LABEL_HOR_OFFSET,
		y = vars.UNDERBARREL_LABEL_VER_OFFSET + main_ammo:h() - vars.UNDERBARREL_LABEL_FONT_SIZE,
		font = ICONS_FONT_NAME,
		font_size = vars.UNDERBARREL_LABEL_FONT_SIZE,
		color = self._TEXT_COLOR_FULL,
		layer = 2
	})
end

function HEVHUDWeapons:set_underbarrel_on(state)
	if self._underbarrel_on ~= state then
		if self._anim_main_ammo_equip_thread then
			self._main_ammo:stop(self._anim_main_ammo_equip_thread)
			self._anim_main_ammo_equip_thread = nil
		end
		if self._anim_underbarrel_ammo_equip_thread then
			self._underbarrel_ammo:stop(self._anim_underbarrel_ammo_equip_thread)
			self._anim_underbarrel_ammo_equip_thread = nil
		end
		
		self._anim_main_ammo_equip_thread = self._main_ammo:animate(AnimateLibrary.animate_alpha_lerp,nil,self._EQUIP_UNDERBARREL_ANIM_DURATION,self._underbarrel_ammo:alpha(),state and self._AMMO_PANEL_INACTIVE_ALPHA or self._AMMO_PANEL_ACTIVE_ALPHA)
		
		self._anim_underbarrel_ammo_equip_thread = self._underbarrel_ammo:animate(AnimateLibrary.animate_alpha_lerp,nil,self._EQUIP_UNDERBARREL_ANIM_DURATION,self._underbarrel_ammo:alpha(),state and self._AMMO_PANEL_ACTIVE_ALPHA or self._AMMO_PANEL_INACTIVE_ALPHA)
		self._underbarrel_on = state
		
	end
	if state then
		self:animate_flash_bgbox_underbarrel()
	else
		self:animate_flash_bgbox_main()
	end
	return state
end

function HEVHUDWeapons:set_underbarrel_visible(state)
	if self._underbarrel_visible ~= state then
		if self._anim_main_weapon_swap_thread then
			self._main_weapon:stop(self._anim_main_weapon_swap_thread)
			self._anim_main_weapon_swap_thread = nil
		end
		if self._anim_underbarrel_ammo_swap_thread then
			self._underbarrel_ammo:stop(self._anim_underbarrel_ammo_swap_thread)
			self._anim_underbarrel_ammo_swap_thread = nil
		end
		if not state then
			self._anim_main_weapon_swap_thread = self._main_weapon:animate(AnimateLibrary.animate_move_lerp,nil,self._AMMO_SWAP_ANIM_DURATION,self._underbarrel_ammo:right()-self._main_weapon:w())
			self._anim_underbarrel_ammo_swap_thread = self._underbarrel_ammo:animate(AnimateLibrary.animate_alpha_lerp,nil,self._AMMO_SWAP_ANIM_DURATION,self._underbarrel_ammo:alpha(),0)
		else
			self._anim_main_weapon_swap_thread = self._main_weapon:animate(AnimateLibrary.animate_move_lerp,nil,self._AMMO_SWAP_ANIM_DURATION,self._underbarrel_ammo:left()-(self._main_weapon:w() + self._MAIN_AMMO_HOR_OFFSET))
			self._anim_underbarrel_ammo_swap_thread = self._underbarrel_ammo:animate(AnimateLibrary.animate_alpha_lerp,nil,self._AMMO_SWAP_ANIM_DURATION,self._underbarrel_ammo:alpha(),self._underbarrel_on and self._AMMO_PANEL_ACTIVE_ALPHA or self._AMMO_PANEL_INACTIVE_ALPHA)
		end
		self._underbarrel_visible = state
	end
	return state
end

function HEVHUDWeapons:set_main_ammo(magazine_max,magazine_current,reserves_current,reserves_max)
	if managers.user:get_setting("alt_hud_ammo") then
		reserves_current = math.max(0, reserves_current - magazine_max - (magazine_current - magazine_max))
	end
	
	local color
	if magazine_current == 0 then
		color = self._TEXT_COLOR_NONE
	else
		color = self._TEXT_COLOR_FULL
	end
	self._main_ammo:child("reserve"):set_color(color)
	self._main_ammo:child("magazine"):set_color(color)
	self._main_ammo:child("ammo_icon"):set_color(color)
	self._main_ammo:child("ammo_name"):set_color(color)
	
	self:_set_main_weapon_reserve(reserves_current,reserves_max)
	self:_set_main_weapon_magazine(magazine_current,magazine_max)
end

function HEVHUDWeapons:_set_main_weapon_reserve(current,total)
	self._main_ammo:child("reserve"):set_text(string.format("%i",math.max(current,0)))
	-- todo set color here
end

function HEVHUDWeapons:_set_main_weapon_magazine(current,total)
	self._main_ammo:child("magazine"):set_text(string.format("%i",math.max(current,0)))
	-- todo set color here
end

function HEVHUDWeapons:set_main_weapon_firemode(firemode,can_toggle)
	local texture,texture_rect = HEVHUD:GetIconData(self.FIREMODE_ICONS[firemode])
	if texture then
		self._main_ammo:child("firemode_icon"):set_image(texture,unpack(texture_rect))
	end
end

function HEVHUDWeapons:set_grenades_data(data)
	if data.icon then
		local texture,rect = tweak_data.hud_icons:get_icon_data(data.icon,{0,0,32,32})
		self._grenades:child("icon"):set_image(texture,unpack(rect))
	end
	self:set_grenades_amount(data)
end

function HEVHUDWeapons:set_grenades_amount(data)
	self._grenades:child("amount"):set_text(string.format("%i",data.amount))
end

function HEVHUDWeapons:set_grenades_cooldown(data)
	
end

-- can_toggle is not used
function HEVHUDWeapons:set_underbarrel_weapon_firemode(firemode,can_toggle)
end

function HEVHUDWeapons:set_underbarrel_ammo(magazine_max,magazine_current,reserves_current,reserves_max)
	-- don't use alt ammo for underbarrels since it only shows the total reserves
	self:_set_underbarrel_weapon_magazine(magazine_current,magazine_max)
	self:_set_underbarrel_weapon_reserve(reserves_current,reserves_max)
	
	-- if totally empty, color everything red
	-- if only mag is empty, color mag red, and color everything else normally (yellow)
	
	local color
	if magazine_current == 0 then
		self._underbarrel_ammo:child("underbarrel_label"):set_color(self._TEXT_COLOR_NONE)
		if reserves_current == 0 then
			color = self._TEXT_COLOR_NONE
		else
			color = self._TEXT_COLOR_FULL
		end
	else
		color = self._TEXT_COLOR_FULL
		self._underbarrel_ammo:child("underbarrel_label"):set_color(color)
	end
	self._underbarrel_ammo:child("underbarrel_icon"):set_color(color)
	self._underbarrel_ammo:child("underbarrel_name"):set_color(color)
	
	self._underbarrel_ammo:child("underbarrel_label"):set_text(string.format("%i",math.max(reserves_current,0)))
end

-- these aren't used since the underbarrel only has one number readout
function HEVHUDWeapons:_set_underbarrel_weapon_magazine(current,total)
end
function HEVHUDWeapons:_set_underbarrel_weapon_reserve(current,total)
end

function HEVHUDWeapons:set_underbarrel_ammo_icon(icon_name)
	self._underbarrel_ammo:child("underbarrel_icon"):set_text(icon_name)
end

function HEVHUDWeapons:set_main_ammo_icon(icon_name)
	self._main_ammo:child("ammo_icon"):set_text(icon_name)
end

function HEVHUDWeapons:animate_flash_bgbox_main()
	for _,child in pairs(self._main_ammo_bgbox:children()) do 
		child:stop()
		child:animate(AnimateLibrary.animate_color_lerp,nil,self._ANIM_BGBOX_FLASH_DURATION,self._TEXT_COLOR_FULL,self._BG_BOX_COLOR)
	end
	self._main_ammo_bgbox:stop()
	self._main_ammo_bgbox:animate(AnimateLibrary.animate_alpha_lerp,nil,self._ANIM_BGBOX_FLASH_DURATION,self._ANIM_BGBOX_ALPHA,self._BG_BOX_ALPHA)
end

function HEVHUDWeapons:animate_flash_bgbox_underbarrel()
	for _,child in pairs(self._underbarrel_ammo_bgbox:children()) do 
		child:stop()
		child:animate(AnimateLibrary.animate_color_lerp,nil,self._ANIM_BGBOX_FLASH_DURATION,self._TEXT_COLOR_FULL,self._BG_BOX_COLOR)
	end
	self._underbarrel_ammo_bgbox:stop()
	self._underbarrel_ammo_bgbox:animate(AnimateLibrary.animate_alpha_lerp,nil,self._ANIM_BGBOX_FLASH_DURATION,self._ANIM_BGBOX_ALPHA,self._BG_BOX_ALPHA)
end

-- todo
function HEVHUDWeapons:animate_flash_bgbox_grenades()
--	for _,child in pairs(self._underbarrel_ammo_bgbox:children()) do 
--		child:stop()
--	end
--	self._underbarrel_ammo_bgbox:animate(AnimateLibrary.animate_color_lerp,nil,self._ANIM_BGBOX_FLASH_DURATION,self._TEXT_COLOR_FULL,self._BG_BOX_COLOR)
end







return HEVHUDWeapons