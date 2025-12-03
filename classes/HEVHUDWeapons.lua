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
	
	self._ANIM_GRENADE_CHARGE_USE_FILL_UPWARD = vars.ANIM_GRENADE_CHARGE_USE_FILL_UPWARD
	self._ANIM_GRENADE_EMPTY_DURATION = vars.ANIM_GRENADE_EMPTY_DURATION
	
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
	
	
	local grenades = main_weapon:panel({
		name = "grenades",
		w = vars.GRENADES_W,
		h = vars.GRENADES_H,
--		x = main_weapon:left() - (vars.MAIN_AMMO_W + vars.GRENADES_W + vars.GRENADES_HOR_MARGIN),
		y = main_weapon:h() - vars.GRENADES_H,
		valign = "bottom",
		halign = "left",
		alpha = 0, -- start hidden, show if the player has any grenades ever
		layer = 2
	})
	grenades:set_right(main_ammo:left() + vars.GRENADES_HOR_MARGIN)
	
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
		text = "",
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
	local grenades_charge = grenades:panel({
		name = "grenades_charge",
		w = vars.GRENADES_CHARGE_W,
		h = vars.GRENADES_CHARGE_H,
		x = vars.GRENADES_CHARGE_X,
		y = (grenades:h() - vars.GRENADES_CHARGE_H) + vars.GRENADES_CHARGE_Y,
		valign = "bottom",
		halign = "grow",
		alpha = 0,
		layer = 3
	})
	self._grenades_charge = grenades_charge
	grenades_charge:rect({
		name = "charge_bar",
		w = grenades_charge:w(),
		h = grenades_charge:h(),
		valign = "grow",
		halign = "scale",
		color = Color.white,
		layer = 2
	})
	grenades_charge:rect({
		name = "charge_bg",
		w = grenades_charge:w(),
		h = grenades_charge:h(),
		valign = "grow",
		halign = "scale",
		color = Color.black,
		alpha = vars.GRENADES_CHARGE_BG_ALPHA,
		layer = 1
	})
	
	
		
	local deployables = main_weapon:panel({
		name = "deployables",
--		x = vars.DEPLOYABLES_X,
		y = vars.DEPLOYABLES_Y,
		w = vars.DEPLOYABLES_W,
		h = vars.DEPLOYABLES_H,
		valign = "bottom",
		halign = "right",
		alpha = 1,
		layer = 2,
		visible = true
	})
	deployables:set_right(grenades:left() + vars.DEPLOYABLES_X)
	
	self._deployables = deployables
	
	local deployable_1 = deployables:panel({
		name = "1",
		x = deployables:w() - vars.DEPLOYABLE_W,
		y = nil,
		w = vars.DEPLOYABLE_W,
		h = vars.DEPLOYABLE_H,
		valign = "bottom",
		halign = "right",
		alpha = 1,
		layer = 1,
		visible = false
	})
	self.CreateBGBox(deployable_1,nil,nil,bgbox_panel_config,bgbox_item_config)
	
	deployable_1:bitmap({
		name = "icon",
		texture = "guis/textures/hevhud_icons", -- placeholder image
		texture_rect = {32,64,32,32},
		x = vars.DEPLOYABLE_ICON_X,
		y = vars.DEPLOYABLE_ICON_Y,
		w = vars.DEPLOYABLE_ICON_W,
		h = vars.DEPLOYABLE_ICON_H,
		color = self._TEXT_COLOR_FULL,
		layer = 2
	})
	
	deployable_1:text({
		name = "amount",
		text = "",
		x = vars.DEPLOYABLE_LABEL_X,
		y = vars.DEPLOYABLE_LABEL_Y,
		align = vars.DEPLOYABLE_LABEL_ALIGN,
		vertical = vars.DEPLOYABLE_LABEL_VERTICAL,
		font = vars.DEPLOYABLE_LABEL_FONT_NAME,
		font_size = vars.DEPLOYABLE_LABEL_FONT_SIZE,
		color = self._TEXT_COLOR_FULL,
		alpha = 1,
		layer = 3
	})
	
	local deployable_2 = deployables:panel({
		name = "2",
	--	x = deployable_1:x() - (vars.DEPLOYABLE_W + vars.DEPLOYABLE_W + vars.DEPLOYABLE_HOR_MARGIN),
		y = 0,
		w = vars.DEPLOYABLE_W,
		h = vars.DEPLOYABLE_H,
		valign = "bottom",
		halign = "right",
		alpha = 0.5,
		layer = 1,
		visible = false
	})
	deployable_2:set_right(deployable_1:left() + vars.DEPLOYABLE_HOR_MARGIN)
	self.CreateBGBox(deployable_2,nil,nil,bgbox_panel_config,bgbox_item_config)
	deployable_2:bitmap({
		name = "icon",
		texture = "guis/textures/hevhud_icons", -- placeholder image
		texture_rect = {32,64,32,32},
		x = vars.DEPLOYABLE_ICON_X,
		y = vars.DEPLOYABLE_ICON_Y,
		w = vars.DEPLOYABLE_ICON_W,
		h = vars.DEPLOYABLE_ICON_H,
		color = self._TEXT_COLOR_FULL,
		layer = 2
	})
	deployable_2:text({
		name = "amount",
		text = "",
		x = vars.DEPLOYABLE_LABEL_X,
		y = vars.DEPLOYABLE_LABEL_Y,
		align = vars.DEPLOYABLE_LABEL_ALIGN,
		vertical = vars.DEPLOYABLE_LABEL_VERTICAL,
		font = vars.DEPLOYABLE_LABEL_FONT_NAME,
		font_size = vars.DEPLOYABLE_LABEL_FONT_SIZE,
		color = self._TEXT_COLOR_FULL,
		alpha = 1,
		layer = 3
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
	local ANIM_GRENADE_EMPTY_DURATION = self._ANIM_GRENADE_EMPTY_DURATION
	if data.amount <= 0 then
		self._grenades:stop()
		self._grenades:animate(AnimateLibrary.animate_alpha_lerp,nil,ANIM_GRENADE_EMPTY_DURATION,nil,0.5)
	else
		self._grenades:stop()
		self._grenades:animate(AnimateLibrary.animate_alpha_lerp,nil,ANIM_GRENADE_EMPTY_DURATION,nil,1)
		self:animate_flash_bgbox_grenades()
	end
end

function HEVHUDWeapons:set_grenades_cooldown(data)
	self._grenades_charge:set_alpha(1)
	local charge_bar = self._grenades_charge:child("charge_bar")
	charge_bar:stop()
	charge_bar:animate(function(o,cb,duration,end_t,from_w,to_w,upward_fill) -- modification of AnimateLibrary.animate_grow_w_left, but adapted to specifically use the same timer used for grenade cooldowns
		local left = o:left()
		from_w = from_w or o:w()
		local dw = to_w - from_w
		local t = -math.huge
		local bezier_points 
		if upward_fill then
			bezier_points = {1,1,0,0}
		else
			bezier_points = {0,0,1,1}
		end
		--Print("duration",duration,"end_t",end_t)
		while t < end_t do 
			t = managers.game_play_central:get_heist_timer() -- alt. different timers Application:time() or TimerManager:game():time()
			o:set_w(from_w + dw * math.bezier(bezier_points,(end_t - t)/duration))
			o:set_left(right)
			coroutine.yield()
		end
		o:set_w(to_w)
		o:set_left(left)
		if cb then 
			cb(o)
		end
		--Print("end t",TimerManager:game():time(),"projcted",end_t)
	end,function(o) o:parent():set_alpha(0) end,data.duration,data.end_time,1,self._grenades_charge:w(),self._ANIM_GRENADE_CHARGE_USE_FILL_UPWARD)
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

function HEVHUDWeapons:set_equipment(slot,data)
	if data.amount then
		-- format string
		local amount_string = ""
		for i = 1, #data.amount do
			local amount = tostring(Application:digest_value(data.amount[i], false))
			if i == 1 then 
				amount_string = amount
			else
				amount_string = amount_string .. " | " .. amount
			end
		end
		self:_set_deployable_label(slot,amount_string)
	end
	
	-- get icon
	local equipment_id = data.equipment
	if equipment_id then
		local guis_catalog = "guis/"
		local bundle_folder = tweak_data.blackmarket.deployables[equipment_id] and tweak_data.blackmarket.deployables[equipment_id].texture_bundle_folder

		if bundle_folder then
			guis_catalog = guis_catalog .. "dlcs/" .. tostring(bundle_folder) .. "/"
		end

		local texture_path = guis_catalog .. "textures/pd2/blackmarket/icons/deployables/" .. tostring(equipment_id)
		local texture_rect = nil
		self:_set_deployable_icon(slot,texture_path,texture_rect)
		self:_show_deployable(slot)
	end
		
	-- get name
	-- local equipment_name = managers.localization:text(tweak_data.upgrades.definitions[equipment_id].name_id)
end

function HEVHUDWeapons:_set_deployable_label(slot,str)
	local panel = self._deployables:child(tostring(slot))
	if alive(panel) then
		panel:child("amount"):set_text(str)
	end
end
function HEVHUDWeapons:_set_deployable_icon(slot,texture,rect)
	local panel = self._deployables:child(tostring(slot))
	if alive(panel) then
		if rect then
			panel:child("icon"):set_image(texture,unpack(rect))
		else
			panel:child("icon"):set_image(texture)
		end
	end
end

function HEVHUDWeapons:_show_deployable(slot)
	local panel = self._deployables:child(tostring(slot))
	if alive(panel) then
		panel:show()
	end
end

function HEVHUDWeapons:set_selected_equipment_slot(slot)
	local slot_name = tostring(slot)
	for _,deployable_panel in pairs(self._deployables:children()) do 
		if deployable_panel:name() == slot_name then
			-- if equipped,
			
			-- flash bgbox
			local bgbox = deployable_panel:child("bgbox")
			for _,child in pairs(bgbox:children()) do 
				child:stop()
				child:animate(AnimateLibrary.animate_color_lerp,nil,self._ANIM_BGBOX_FLASH_DURATION,self._TEXT_COLOR_FULL,self._BG_BOX_COLOR)
			end
			bgbox:stop()
			bgbox:animate(AnimateLibrary.animate_alpha_lerp,nil,self._ANIM_BGBOX_FLASH_DURATION,self._ANIM_BGBOX_ALPHA,self._BG_BOX_ALPHA)
			
			-- set full visibility
			--deployable_panel:stop()
			--deployable_panel:animate(AnimateLibrary.animate_alpha_lerp,nil,self._config.Weapons.ANIM_SWAP_DEPLOYABLE_DURATION,nil,self._config.General.LABEL_ALPHA_HIGH)
			deployable_panel:set_alpha(self._config.General.LABEL_ALPHA_HIGH)
		else
			-- set half visibility
			deployable_panel:set_alpha(self._config.General.LABEL_ALPHA_LOW)
			--deployable_panel:stop()
			--deployable_panel:animate(AnimateLibrary.animate_alpha_lerp,nil,self._config.Weapons.ANIM_SWAP_DEPLOYABLE_DURATION,nil,self._config.General.LABEL_ALPHA_LOW)
			
--			for _,child in pairs(deployable_panel:child("bgbox")) do 
--				child:stop()
--				child:set_color(Color.black) -- or whatever
--				child:set_alpha(0.5) -- etc etc
--			end
		end
	end
end

function HEVHUDWeapons:animate_flash_bgbox_deployable(slot)
	
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

function HEVHUDWeapons:animate_flash_bgbox_grenades()
	for _,child in pairs(self._grenades_ammo_bgbox:children()) do 
		child:stop()
		child:animate(AnimateLibrary.animate_color_lerp,nil,self._ANIM_BGBOX_FLASH_DURATION,self._TEXT_COLOR_FULL,self._BG_BOX_COLOR)
	end
	self._grenades_ammo_bgbox:stop()
	self._grenades_ammo_bgbox:animate(AnimateLibrary.animate_alpha_lerp,nil,self._ANIM_BGBOX_FLASH_DURATION,self._ANIM_BGBOX_ALPHA,self._BG_BOX_ALPHA)
end







return HEVHUDWeapons