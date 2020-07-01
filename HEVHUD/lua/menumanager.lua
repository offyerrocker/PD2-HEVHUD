--[[
todo:

fix weapon count problem (two separate panels)
sprint meter + sprint hud animation
adjust aux alignment





--HL2 font characters:
	--health: *
	--energy: +
	--crosshair (): O
	--crosshair dots: Q 
	--crosshair ( fill: [
	--crouch: \
	--crosshair ) fill: ]
	--crosshair ( empty: {
	--crosshair ) empty:}
	--flashlight on: copyright
	--flashlight off: (r)
	


--]]

HEVHUD = HEVHUD or {}
HEVHUD._path = HEVHUD._path or ModPath
HEVHUD._localization_path = HEVHUD._localization_path or (HEVHUD._path .. "localization/")
HEVHUD._assets_path = HEVHUD._assets_path or (HEVHUD._path .. "assets/")
HEVHUD._sounds_path = HEVHUD._sounds_path or (HEVHUD._assets_path .. "snd/fvox/")
HEVHUD._AUDIO_FILE_FORMAT = ".ogg"
HEVHUD._audio_sources = HEVHUD._audio_sources or {}
HEVHUD._audio_buffers = HEVHUD._audio_buffers or {}
HEVHUD._audio_queue = HEVHUD._audio_queue or {}
HEVHUD._suit_number_vox = HEVHUD._suit_number_vox or {
	["0"] = "_comma",
	["1"] = "one",
	["2"] = "two",
	["3"] = "three",
	["4"] = "four",
	["5"] = "five",
	["6"] = "six",
	["7"] = "seven",
	["8"] = "eight",
	["9"] = "nine",
	["10"] = "ten",
	["11"] = "eleven",
	["12"] = "twelve",
	["13"] = "thirteen",
	["14"] = "fourteen",
	["15"] = "fifteen",
	["16"] = "sixteen",
	["17"] = "seventeen",
	["18"] = "eighteen",
	["19"] = "nineteen",
	["20"] = "twenty",
	["30"] = "thirty",
	["40"] = "fourty",
	["50"] = "fifty",
	["60"] = "sixty",
	["70"] = "seventy",
	["80"] = "eighty",
	["90"] = "ninety",
	["100"] = "onehundred",
	["PM"] = "pm",
	["AM"] = "am"
}
HEVHUD._fonts = {
	hl2_icons = "fonts/halflife2",
	hl2_text = "fonts/trebuchet",
	hl2_vitals = "fonts/tahoma_bold",
	not_hl2 = "fonts/myriad" --yeah turns out myriad is not the ui font used in half-life 
}
HEVHUD._animate_targets = {}
HEVHUD._panel = HEVHUD._panel or nil --for name reference 

HEVHUD._font_icons = {
	physgun_fill = "!",
	pound = "#",
	revolver_fill = "$",
	pistol = "%",
	smg = "&",
	supers2 = "'",
	shotgun_fill = "(",
	crossbow_fill = ")",
	energy_box = "*",
	health_box = "+",
	comma = ",",
	hyphen = "-",
	period = ".",
	slash = "/",
	zero = "0",
	one = "1",
	two = "2",
	three = "3",
	four = "4",
	five = "5",
	six = "6",
	seven = "7",
	eight = "8",
	nine = "9",
	pulse_fill = ":",
	rpg_fill = ";",
	arrow_left = "<",
	arrow_up = "=",
	arrow_right = ">",
	arrow_down = "?",
	hl2_icon = "@",
	lambda = "A",
	demo_d = "B",
	follower = "C",
	follower_run = "D",
	hl_e = "E",
	hl_f = "F",
	demo_e = "G",
	hl_h = "H",
	hl_i = "I",
	demo_m = "J",
	demo_o = "K",
	hl_l = "L",
	medic = "M",
	medic_run = "N",
	cross_pair_thin = "O",
	pause = "P",
	cross_dots = "Q",
	play = "R",
	ffwd = "S",
	stop = "T",
	rev = "U",
	valve = "V",
	frev = "W",
	next_chapter = "X",
	prev_chapter = "Y",
	rec = "Z",
	cross_left_fill = "[",
	crouch = "\\",
	cross_right_fill = "]",
	crowbar_fill = "^",
	grenade_fill = "_",
	toilet = "`",
	smg_empty = "a",
	shotgun_empty = "b",
	crowbar_empty = "c",
	pistol_empty = "d",
	revolver_empty = "e",
	oicw_empty = "f",
	crossbow_empty = "g",
	tau_empty = "h",
	rpg_empty = "i",
	bait_empty = "j",
	grenade_empty = "k",
	pulse_empty = "l",
	physgun_empty = "m",
	baton_empty = "n",
	slam_empty = "o",
	pistol_ammo = "p",
	revolver_ammo = "q",
	smg_ammo = "r",
	shotgun_ammo = "s",
	grenadelauncher_ammo = "t",
	pulse_ammo = "u",
	grenade_ammo = "v", --very similar to grenade_fill but horizontally flat
	crossbow_rebar = "w", --at least, i think it's rebar.
	rpg_ammo = "x",
	gauss_ammo = "y", --placeholder for cut content, evidently
	darkenergy_ammo = "z", 
	cross_left_empty = "{",
	crossbow_bolt = "|", --not sure why there's two versions?
	cross_right_empty = "}",
	bait_fill = "~",
	flashlight_on = "©", --copyright symbol (circled c)
	flashlight_off = "®" -- registered trademark symbol (circled r)
	
}

HEVHUD._cache = {
	underbarrel = {
		[1] = nil,
		[2] = nil
	}
} --slight misnomer but basically intended as an unorganized bucket-style structure for random things set during in-game/in-heist


--HEVHUD._sounds_path = (HEVHUD._assets_path .. "snd/fvox/")
HEVHUD._SETUP_COMPLETE = false


HEVHUD.default_settings = {
	HEALTH_THRESHOLD_DOOMED = 0.01,
	HEALTH_THRESHOLD_CRITICAL = 0.3,
	HEALTH_THRESHOLD_MINOR = 0.5,
	AMMO_THRESHOLD_LOW = 1/3,
	WEAPON_INACTIVE_ALPHA = 2/3,
	WEAPON_ACTIVE_ALPHA = 1
}
HEVHUD.settings = HEVHUD.settings or {}
for k,v in pairs(HEVHUD.default_settings) do 
	if HEVHUD.settings[k] == nil then 
		HEVHUD.settings[k] = v
	end
end


HEVHUD.color_data = {
	hl2_yellow = Color("FFD040"),
	hl2_yellow_bright = Color("F0D210"),
	hl2_red_bright = Color("FF0000"),
	hl2_red = Color("BB0200"),
	hl2_orange = Color("FFA000")
}

function HEVHUD:log(...)
	if Console then 
		Console:Log(...)
	else
		log(...)
	end
end

function HEVHUD:CreateHUD()
	if true or Utils:IsInHeist() then 
		self._ws = managers.gui_data:create_fullscreen_workspace()
		local hl2 = self._ws:panel()
		self._panel = hl2
		
		local scale = 1
		
	--CROSSHAIR
		local crosshair_font_size = 32 --TODO get from setting
		local crosshairs = self._panel:panel({
			name = "crosshairs"
		})
		local crosshair_dots = crosshairs:text({
			name = "crosshair_dots",
			text = self._font_icons.cross_dots,
			vertical = "center",
			align = "center",
			y = 0,
			font = self._fonts.hl2_icons,
			font_size = crosshair_font_size
		})
		local crosshair_left = crosshairs:text({
			name = "crosshair_left",
			text = self._font_icons.cross_left_empty,
			vertical = "center",
			align = "center",
			x = -16,
			y = -crosshair_font_size * 0.1,
			font = self._fonts.hl2_icons,
			font_size = crosshair_font_size
		})
		local crosshair_right = crosshairs:text({
			name = "crosshair_right",
			text = self._font_icons.cross_right_empty,
			vertical = "center",
			align = "center",
			x = 16,
			y = -crosshair_font_size * 0.1,
			font = self._fonts.hl2_icons,
			font_size = crosshair_font_size
		})
		
	--todo
	--SQUAD
		local squad = self._panel:panel({
			name = "squad"
		})
		
	--HEALTH/SUIT/AUX
		local vitals = self._panel:panel({
			name = "vitals"
		})

		local box_scale = 1
		local box_w = 128 * box_scale
		local box_h = 48 * box_scale
		
		local text_name_size = 12 * box_scale
		local text_label_size = 32 * box_scale
		local text_hor_margin = 24 * box_scale
		
		local box_ver_offset = -32
		local text_ver_offset = -12
		local label_ver_offset = -8 --for the values themselves
		
		local health = hl2:panel({
			name = "health",
			w = box_w,
			h = box_h,
			x = 24,
			y = box_ver_offset + hl2:h() - box_h
		})
				
		local NUM_POWER_TICKS = 10
		local TICK_HEIGHT = 3
		local TICK_WIDTH = 6
		local TICK_MARGIN = 2

		local power_h = 32
		local power = hl2:panel({
			name = "power",
			w = box_w,
			h = power_h * box_scale,
			x = 24,
			y = health:y() - ((power_h * box_scale) + 8)
		})
		local power_bg = power:bitmap({
			name = "power_bg",
			layer = 1,
			texture = "guis/textures/pd2/hud_tabs",
			texture_rect = {84,0,44,32},
			w = power:w(),
			h = power:h(),
			alpha = 0.75
		})
		local power_name = power:text({
			name = "power_name",
			text = "AUX POWER",
			x = 8 + TICK_MARGIN,
			blend_mode = "add",
			y = -16 + power:h() - text_name_size,
			font = self._fonts.hl2_vitals,
			font_size = text_name_size,
			color = self.color_data.hl2_yellow_bright,
			alpha = 1,
			layer = 2
		})
		local TICK_OFFSET_X = (power:w() - ((NUM_POWER_TICKS - 1) * (TICK_MARGIN + (TICK_WIDTH * box_scale)))) / 2

		for i=1,NUM_POWER_TICKS do
			power:rect({
				name = "power_tick_" .. tostring(i),
				color = self.color_data.hl2_yellow_bright,
				x = 10 + ((i - 1) * (TICK_MARGIN + TICK_WIDTH)),
				y = -8 + power:h() - (TICK_HEIGHT + TICK_MARGIN),
				w = TICK_WIDTH,
				h = TICK_HEIGHT,
				alpha = 2/3,
				layer = 2
			})
		end
		--TODO "SPRINT" text animation
		
		local health_bg = health:bitmap({
			name = "health_bg",
			layer = 1,
			texture = "guis/textures/pd2/hud_tabs",
			texture_rect = {84,0,44,32},
			w = health:w(),
			h = health:h(),
			alpha = 0.75
		})
		local health_name = health:text({
			name = "health_name",
			text = "HEALTH",
			x = 8,
			y = text_ver_offset + health:h() - text_name_size,
			font = self._fonts.hl2_vitals,
			font_size = text_name_size,
			color = self.color_data.hl2_yellow,
			alpha = 2/3,
			layer = 2
		})
		local health_label = health:text({
			name = "health_label",
			text = "",
			align = "right",
			x = -text_hor_margin,
			y = label_ver_offset + health:h() - text_label_size,
			font = self._fonts.hl2_icons,
			font_size = text_label_size,
			color = self.color_data.hl2_yellow,
			alpha = 2/3,
			layer = 2
		})
		
		local suit = hl2:panel({
			name = "suit",
			w = box_w,
			h = box_h,
			x = 24 + health:right(),
			y = box_ver_offset + hl2:h() - box_h
		})
		
		local suit_bg = suit:bitmap({
			name = "suit_bg",
			layer = 1,
			texture = "guis/textures/pd2/hud_tabs",
			texture_rect = {84,0,44,32},
			w = suit:w(),
			h = suit:h(),
			alpha = 0.75
		})
		local suit_name = suit:text({
			name = "suit_name",
			text = "SUIT",
			x = 8,
			y = text_ver_offset + suit:h() - text_name_size,
			font = self._fonts.hl2_vitals,
			font_size = text_name_size,
			color = self.color_data.hl2_yellow,
			alpha = 2/3,
			layer = 2
		})
		local suit_label = suit:text({
			name = "suit_label",
			text = "",
			align = "right",
			x = -text_hor_margin,
			y = label_ver_offset + suit:h() - text_label_size,
			font = self._fonts.hl2_icons,
			font_size = text_label_size,
			color = self.color_data.hl2_yellow,
			alpha = 2/3,
			layer = 2
		})
		
				
		
		
		
		local function populate_weapon_panel(weapon_panel)
			
			local ammo_icon_size = 32 * box_scale
			local underbarrel_icon_size = 32 * box_scale
			local underbarrel_w = 64 * box_scale
			local underbarrel_h = box_h

			local underbarrel = weapon_panel:panel({
				name = "underbarrel",
				x = weapon_panel:w() - underbarrel_w + box_ver_offset,
				y = weapon_panel:h() - underbarrel_h + box_ver_offset,
				w = underbarrel_w,
				h = underbarrel_h
			})
			
			local underbarrel_bg = underbarrel:bitmap({
				name = "underbarrel_bg",
				layer = 1,
				texture = "guis/textures/pd2/hud_tabs",
				texture_rect = {84,0,44,32},
				w = underbarrel:w(),
				h = underbarrel:h(),
				alpha = 0.75
			})
			local underbarrel_icon = underbarrel:text({
				name = "underbarrel_icon",
				text = "",
				x = 8,
				y = 0,
				font = self._fonts.hl2_icons,
				font_size = underbarrel_icon_size,
				color = self.color_data.hl2_yellow,
				alpha = 2/3,
				layer = 2
			})
			local underbarrel_name = underbarrel:text({
				name = "underbarrel_name",
				text = "ALT",
				align = "left",
				x = 8,
				y = text_ver_offset + underbarrel:h() - text_name_size,
				font = self._fonts.hl2_vitals,
				font_size = text_name_size,
				color = self.color_data.hl2_yellow,
				alpha = 2/3,
				layer = 2
			})
			local underbarrel_label = underbarrel:text({
				name = "underbarrel_label",
				text = "", --number of rounds
				align = "right",
				x = -8,
				y = (underbarrel:h() - text_label_size)/2,
				font = self._fonts.hl2_icons,
				font_size = text_label_size,
				color = self.color_data.hl2_yellow,
				alpha = 2/3,
				layer = 2
			})
			
			
			
			
			
			local ammo_w = 200 * box_scale
			local ammo_h = box_h
			local reserve_font_size = 24 * box_scale
			local magazine_font_size = 32 * box_scale
			
			local ammo = weapon_panel:panel({
				name = "ammo",
				x = underbarrel:x() - (ammo_w + 16),
				y = underbarrel:y(),
				w = ammo_w,
				h = ammo_h
			})
			local ammo_bg = ammo:bitmap({
				name = "ammo_bg",
				layer = 1,
				texture = "guis/textures/pd2/hud_tabs",
				texture_rect = {84,0,44,32},
				w = ammo:w(),
				h = ammo:h(),
				alpha = 0.75
			})
			local ammo_name = ammo:text({
				name = "ammo_name",
				text = "AMMO",
				align = "left",
				x = text_name_size,
				y = ammo:h() - text_name_size + text_ver_offset,
				font = self._fonts.hl2_vitals,
				font_size = text_name_size,
				color = self.color_data.hl2_yellow,
				alpha = 2/3,
				layer = 2
			})
			local ammo_name_x,ammo_name_y,ammo_name_w,ammo_name_h = ammo_name:text_rect()
			local ammo_icon = ammo:text({
				name = "ammo_icon",
				text = "",
	--			x = 8,
				y = 0,
				x = ammo_name:x() + ((ammo_name_w - ammo_icon_size) / 1),
	--			y = ammo_name_y + ammo_name_h,
				font = self._fonts.hl2_icons,
				font_size = ammo_icon_size,
				color = self.color_data.hl2_yellow,
				alpha = 2/3,
				layer = 2
			})
			local magazine = ammo:text({
				name = "magazine",
				text = "18",
				align = "center",
				y = label_ver_offset + ammo:h() - magazine_font_size,
				font = self._fonts.hl2_icons,
				font_size = magazine_font_size,
				color = self.color_data.hl2_yellow,
				alpha = 2/3,
				layer = 2
			})
			
			local reserve = ammo:text({
				name = "reserve",
				text = "60",
				align = "right",
				x = -reserve_font_size,
				y = label_ver_offset + ammo:h() - reserve_font_size,
				font = self._fonts.hl2_icons,
				font_size = reserve_font_size,
				color = self.color_data.hl2_yellow,
				alpha = 2/3,
				layer = 2
			})
		
		end
		local primary = self._panel:panel({
			name = "primary",
			visible = false
		})
		--
		populate_weapon_panel(primary)
		local secondary = self._panel:panel({
			name = "secondary"
		})
		populate_weapon_panel(secondary)
	end
end

function HEVHUD:SetUnderbarrelPanelState(slot_name,is_active,ammo_ratio)
	local weapon_panel = self._panel:child(tostring(slot_name))
	if alive(weapon_panel) then 
		local underbarrel_panel = weapon_panel:child("underbarrel")
		local alpha
		if is_active then 
			alpha = self.settings.WEAPON_ACTIVE_ALPHA
		else
			alpha = self.settings.WEAPON_INACTIVE_ALPHA
		end
		underbarrel_panel:child("underbarrel_label"):set_alpha(alpha)
		underbarrel_panel:child("underbarrel_name"):set_alpha(alpha)
		underbarrel_panel:child("underbarrel_icon"):set_alpha(alpha)
		if ammo_ratio then 
			if ammo_ratio <= 0 then 
				--todo set underbarrel icon opacity blink
				underbarrel_panel:child("underbarrel_label"):set_color(self.color_data.hl2_red)
			elseif ammo_ratio < self.settings.AMMO_THRESHOLD_LOW then 
				underbarrel_panel:child("underbarrel_label"):set_color(self.color_data.hl2_orange)
			else 
				underbarrel_panel:child("underbarrel_label"):set_color(self.color_data.hl2_yellow)
			end
		end
	end
end

function HEVHUD:SetReserveAmmoColorByRatio(slot_name,ammo_ratio)
	local weapon_panel = self._panel:child(tostring(slot_name))
	if alive(weapon_panel) then 
		local ammo_panel = weapon_panel:child("ammo")
		if ammo_ratio <= 0 then 
			ammo_panel:child("reserve"):set_color(self.color_data.hl2_red)
		elseif ammo_ratio <= self.settings.AMMO_THRESHOLD_LOW then 
			ammo_panel:child("reserve"):set_color(self.color_data.hl2_orange)
		else 
			ammo_panel:child("reserve"):set_color(self.color_data.hl2_yellow)
		end
	end
end

function HEVHUD:SetMagazineAmmoColorByRatio(slot_name,ammo_ratio)
	local weapon_panel = self._panel:child(tostring(slot_name))
	if alive(weapon_panel) then 
		local ammo_panel = weapon_panel:child("ammo")
		if ammo_ratio <= 0 then 
			ammo_panel:child("magazine"):set_color(self.color_data.hl2_red)
		elseif ammo_ratio <= self.settings.AMMO_THRESHOLD_LOW then 
			ammo_panel:child("magazine"):set_color(self.color_data.hl2_orange)
		else 
			ammo_panel:child("magazine"):set_color(self.color_data.hl2_yellow)
		end
	end
end

function HEVHUD:SetWeaponPanelState(slot_name,is_active)
	local weapon_panel = self._panel:child(tostring(slot_name))
	if alive(weapon_panel) then 
		local ammo_panel = weapon_panel:child("ammo")
		local alpha
		if is_active then 
			alpha = self.settings.WEAPON_ACTIVE_ALPHA
		else
			alpha = self.settings.WEAPON_INACTIVE_ALPHA
		end
		ammo_panel:child("ammo_name"):set_alpha(alpha)
		ammo_panel:child("ammo_icon"):set_alpha(alpha)
		ammo_panel:child("magazine"):set_alpha(alpha)
		ammo_panel:child("reserve"):set_alpha(alpha)
	end
end

function HEVHUD:ShouldShowHealthValue()
	--determines if HUD should show the actual health value, or a percentage of total
	return true
end

function HEVHUD:ShouldShowArmorValue()
	--determines if HUD should show the actual armor value, or a percentage of total
	return true
end

function HEVHUD:SetHealthString(text)
	self._panel:child("health"):child("health_label"):set_text(text)
end

function HEVHUD:SetSuitString(text)
	self._panel:child("suit"):child("suit_label"):set_text(text)
end

function HEVHUD:GetHLGunAmmoIcon(categories,weapon_id,fallback)
	fallback = fallback or "pistol_ammo"
	if type(categories) ~= "table" then 
		return fallback
	end
	local overrides = {
		rpg7 = "rpg_ammo", --rocket launchers in pd2 don't have a separate category; they're all classed as grenade_launcher
		ray = "rpg_ammo" --commando rocket launcher
	}
	if weapon_id and overrides[weapon_id] then 
		return overrides[weapon_id]
	end
	local is_revolver
	for _,cat in pairs(categories) do 
		if cat == "revolver" then 
			is_revolver = true
		end
		if cat == "crossbow" then 
			return "crossbow_rebar"
		elseif cat == "bow" then 
			return "crossbow_bolt"
		elseif cat == "grenade_launcher" then 
			return "grenadelauncher_ammo"
		elseif cat == "shotgun" then 
			return "shotgun_ammo"
		elseif cat == "smg" then 
			return "smg_ammo"
		elseif cat == "lmg" then 
			return "pulse_ammo"
		elseif cat == "minigun" then
			return "pulse_ammo"
		elseif cat == "snp" then 
			return "pulse_ammo"
		elseif cat == "assault_rifle" then 
			return "smg_ammo"
		elseif cat == "pistol" then 
			if is_revolver then 
				return "revolver_ammo" 
			end
			return "pistol_ammo"
		elseif cat == "saw" then 
			return "darkenergy_ammo"
		elseif cat == "flamethrower" then
			return "darkenergy_ammo"
		end
	end
	return fallback
end

function HEVHUD:GetUnderbarrelInSlot(slot,underbarrel_slot)
	
	--there is currently no precedent for multiple underbarrel gadgets on a single weapon... yet
	underbarrel_slot = tonumber(underbarrel_slot) or 1
	
	slot = tonumber(slot)
	local player = managers.player:local_player()
	if not (slot and player) then return end
	local equipped_in_slot = player:inventory():unit_by_selection(slot)
	if not equipped_in_slot then return end	
	local weapon_id = equipped_in_slot:get_name_id()
	if self._cache.underbarrel[slot] == nil then 
		local underbarrel_weapons = equipped_in_slot:base():get_all_override_weapon_gadgets()
		if #underbarrel_weapons > 0 then 
			self._cache.underbarrel[slot] = underbarrel_weapons
			local categories = underbarrel_weapons[underbarrel_slot]._tweak_data.categories
--			local categories = {"pistol","revolver"}
			local underbarrel_category = self:GetHLGunAmmoIcon(categories,underbarrel_weapons[underbarrel_slot].name_id)
			if underbarrel_category then 
				self:SetUnderbarrelIcon((slot == 1 and "secondary") or (slot == 2 and "primary"),self._font_icons[underbarrel_category])
			end
			--todo get underbarrel tweakdata categories and set underbarrel icon
		else
			--set flag not to check for underbarrels anymore
			self._cache.underbarrel[slot] = false
		end
	end
	if type(self._cache.underbarrel[slot]) == "table" then 
		return self._cache.underbarrel[slot][underbarrel_slot]
	end
end

function HEVHUD:ShouldUseRealAmmo()
	return true
end

function HEVHUD:SetWeaponReserve(slot_name,current_reserve,max_reserve)
	local weapon_panel = self._panel:child(tostring(slot_name))

	local slot = 0
	if slot_name == "primary" then 
		slot = 2
	elseif slot_name == "secondary" then 
		slot = 1
	end
	
	local player = managers.player:local_player()
	local underbarrel = self:GetUnderbarrelInSlot(slot)
	if underbarrel and player then 
		if slot == player:inventory():equipped_selection() then			
			self:SetUnderbarrel(slot_name,underbarrel._ammo:get_ammo_total())
			local weapon_category = self:GetHLGunAmmoIcon(player:inventory():equipped_unit():base():categories())
			
			--set underbarrel count if current weapon has an underbarrel
			if not underbarrel._on and weapon_category then 
				self:SetWeaponIcon(slot_name,self._font_icons[weapon_category])
			end
		end
		if underbarrel._on then 
			--if underbarrel is active then don't overwrite the normal reserve ammo counter with underbarrel values
			return
		end
	elseif not underbarrel then 
		self:SetUnderbarrel(slot_name,false)
		local weapon_category = self:GetHLGunAmmoIcon(player:inventory():equipped_unit():base():categories())
		if weapon_category then 
			self:SetWeaponIcon(slot_name,self._font_icons[weapon_category])
		end
		--hide underbarrel panel if none exists
	end
	
	local ammo_ratio = 1
	if max_reserve > 0 then
		ammo_ratio = current_reserve / max_reserve
	end
	self:SetReserveAmmoColorByRatio(slot_name,ammo_ratio)
	self:SetWeaponPanelState(slot_name,true)
	
	if alive(weapon_panel) then 
		weapon_panel:child("ammo"):child("reserve"):set_text(current_reserve)
	end
end

function HEVHUD:SetWeaponMagazine(slot_name,mag_current,mag_max)
	local weapon_panel = self._panel:child(tostring(slot_name))
	
	local slot = 0
	if slot_name == "primary" then 
		slot = 2
	elseif slot_name == "secondary" then 
		slot = 1
	end
	
	local player = managers.player:local_player()
	local underbarrel = self:GetUnderbarrelInSlot(slot)
	if underbarrel and player then 
		--set underbarrel count if current weapon has an underbarrel
		
--		if slot == player:inventory():equipped_selection() then
--		end
		local ammo_max = underbarrel._ammo:get_ammo_max_per_clip()
		local underbarrel_ammo_ratio = 1
		
		if ammo_max > 0 then 
			underbarrel_ammo_ratio = underbarrel._ammo:get_ammo_remaining_in_clip() / ammo_max
		end

		self:SetUnderbarrelPanelState(slot_name,underbarrel._on,underbarrel_ammo_ratio)
		if underbarrel._on then 
			self:SetWeaponPanelState(slot_name,false)
			--if underbarrel is active then don't overwrite the normal magazine ammo counter with underbarrel values
			return
		else
			self:SetUnderbarrelPanelState(slot_name,false)
		end
	elseif not underbarrel then 
		--hide underbarrel panel if none exists
		self:SetUnderbarrel(slot_name,false)
	end
	
	local ammo_ratio = 1
	if mag_max > 0 then
		ammo_ratio = mag_current / mag_max
	end
	self:SetMagazineAmmoColorByRatio(slot_name,ammo_ratio)
	self:SetWeaponPanelState(slot_name,true)
	
	if alive(weapon_panel) then 
		weapon_panel:child("ammo"):child("magazine"):set_text(mag_current)
	end
	
end

function HEVHUD:SetUnderbarrel(slot_name,text)
	--hides underbarrel panel if text is false;
	--shows underbarrel panel and sets underbarrel text if text is non-nil value
	local weapon_panel = self._panel:child(tostring(slot_name))
	if alive(weapon_panel) then 
		if text then 
			weapon_panel:child("underbarrel"):child("underbarrel_label"):set_text(tostring(text))
		end
		weapon_panel:child("underbarrel"):set_visible(text and true)
	end
end

function HEVHUD:SetUnderbarrelIcon(slot_name,icon_name)
	local weapon_panel = self._panel:child(tostring(slot_name))
	if icon_name and alive(weapon_panel) then 
		weapon_panel:child("underbarrel"):child("underbarrel_icon"):set_text(icon_name)
	end
end

--[[
function HEVHUD:SetUnderbarrelVisible(weapon_slot,state)
	local weapon_panel = self._panel:child(tostring(weapon_slot))
	if alive(weapon_panel) then 
		weapon_panel:child("underbarrel")set_visible(state)
	end
end
--]]

function HEVHUD:SetWeaponIcon(slot_name,icon_name)
	local weapon_panel = self._panel:child(tostring(slot_name))
	if alive(weapon_panel) then 
		weapon_panel:child("ammo"):child("ammo_icon"):set_text(icon_name)
	end
end

function HEVHUD:SetSelectedWeapon(selection)
	local player = managers.player:local_player()
	if player then 
		selection = (selection and tonumber(selection)) or player:inventory():equipped_selection()

		if selection == 1 then
			self._panel:child("primary"):hide()
			self._panel:child("secondary"):show()
			
		elseif selection == 2 then 
			self._panel:child("primary"):show()
			self._panel:child("secondary"):hide()
		end
	end
end

function HEVHUD:Setup()
	if not self._SETUP_COMPLETE then 
--		self._SETUP_COMPLETE = true
		--init blt xaudio (doesn't matter if another mod has already set it up)
		if blt.xaudio then
			blt.xaudio.setup()
		end
		
		self._audio_queue.suit = {}
		self:CreateHUD()
		BeardLib:AddUpdater("HEVHUD_update",callback(self,self,"Update"))
	end
end

function HEVHUD:SayTime()
	self:PlaySound("suit","time_is_now")
	local TWELVE_HOUR = true
	--i don't plan to include an option to disable twelve-hour format because... see below comments
	local c_h
	if TWELVE_HOUR then 
		c_h = os.date("%I")
	else
		c_h = os.date("%H")
	end
	local c_m = os.date("%M")
	
	local h_1 = string.sub(c_h,1,1) or ""
	local h_2 = string.sub(c_h,2,2) or ""
	if c_h == "00" then
		--times with hour 00 (midnight, when not using twelve-hour will say "12" because the HEV suit has no voice line for "zero" or "oh" )
		self:PlaySound("suit",self._suit_number_vox["12"])
	elseif (h_2 == "0") or (h_1 == "1") then 
		self:PlaySound("suit",self._suit_number_vox[c_h] or self._suit_number_vox[h_2])
	else
		self:PlaySound("suit",self._suit_number_vox[h_1 .. "0"])
		self:PlaySound("suit",self._suit_number_vox[h_2])
	end
	local m_1 = string.sub(c_m,1,1) or ""
	local m_2 = string.sub(c_m,2,2) or ""
	
	if m_1 ~= "0" then --times with minutes 00-09 are just not said, again because the HEV suit can't say "zero"		
		if tonumber(c_m) < 20 then 
			self:PlaySound("suit",self._suit_number_vox[tostring(c_m)])
		else
			self:PlaySound("suit",self._suit_number_vox[m_1 .. "0"])
			self:PlaySound("suit",self._suit_number_vox[m_2])
		end
	end
	if TWELVE_HOUR then 
		self:PlaySound("suit",self._suit_number_vox[os.date("%p")])
	end
end

function HEVHUD:PlaySound(source_name,sound_name,should_loop)
	if not sound_name then 
		return
	end
	sound_name = tostring(sound_name)
	local audio_source = self._audio_sources[tostring(source_name)]
	
	local snd = self._audio_buffers[sound_name]
	if type(snd) == "table" and snd.disabled then 
		self:log("PlaySound(): sound [" .. sound_name .. "] not found",{color = Color.red})
	elseif not snd then
		local buffer = XAudio.Buffer:new(self._sounds_path .. sound_name .. self._AUDIO_FILE_FORMAT)
		--[[
		if not buffer then 
			self._audio_buffers[sound_name] = {
				disabled = true
			}
		end
		--]]
		
		self._audio_buffers[sound_name] = {
			name = sound_name,
			looping = should_loop,
			buffer = buffer
		}
	end
	if snd and audio_source then
		if should_loop ~= nil then
--			self._audio_queue[source_name][#self._audio_queue[source_name] + 1] = {self._audio_buffers[sound_name].buffer, should_loop = should_loop}
			table.insert(self._audio_queue[source_name],{name = sound_name,buffer = self._audio_buffers[sound_name].buffer, should_loop = should_loop})
		else
--			self._audio_queue[source_name][#self._audio_queue[source_name] + 1] = self._audio_buffers[sound_name]
			table.insert(self._audio_queue[source_name],self._audio_buffers[sound_name])
		end
	end
end

function HEVHUD:Update(t,dt)
	--Audio sources
	
	
	--init HEV suit sound source
	if managers.player:local_player() then 
		self._audio_sources.suit = self._audio_sources.suit or XAudio.UnitSource:new(XAudio.PLAYER)
	else
		return
	end
	for source_name,audio_queue in pairs(self._audio_queue) do 
--		Console:SetTrackerValue("trackera",source_name .. Application:time())
		local audio_source = self._audio_sources[source_name] and self._audio_sources[source_name]
--		self:log("State is " .. audio_source:get_state())
		if audio_source and audio_source:get_state() ~= 1 then 
--			Console:SetTrackerValue("trackerb","" .. math.random())
			local snd_data = table.remove(audio_queue,1)
			if snd_data and type(snd_data) == "table" then
--				Log("Playing snd data ")
--				logall(snd_data)
				audio_source:set_buffer(snd_data.buffer)
				audio_source:set_looping(snd_data.should_loop)
				audio_source:play()
			end
		end
	end
	
	self:UpdateAnimate(t,dt)
end

function HEVHUD:animate(target,func,done_cb,...)
	if target then 
		if type(func) == "function" then 
		elseif type(self[tostring(func)]) == "function" then
			func = self[tostring(func)]
		else
			self:log("ERROR: Unknown/unsupported animate function type: " .. tostring(func) .. " (" .. type(func) .. ")",{color=Color.red})
			return
		end
		if (type(target) == "number") or alive(target) then
			self._animate_targets[tostring(target)] = {
				func = func,
				target = target,
				start_t = Application:time(),
				done_cb = done_cb,
				params = {
					...
				}
			}
		end
	end
end

function HEVHUD:animate_stop(name,do_cb)
	local item = self._animate_targets[tostring(name)]
	if item and do_cb and (type(item.done_cb) == "function") then 
		return item.done_cb(item.target,unpack(item.params))
	end
end

function HEVHUD:UpdateAnimate(t,dt)
	for id,data in pairs(self._animate_targets) do 
		if data and data.target and ((type(data.target) == "number") or alive(data.target)) then 
			local result = data.func(data.target,t,dt,data.start_t,unpack(data.params or {}))
			if result then 
				if type(data.done_cb) == "function" then 
					local done_cb = data.done_cb
					local target = data.target
					local params = data.params
					self._animate_targets[id] = nil
					done_cb(target,unpack(params))
--					data.done_cb(data.target,unpack(data.params))
				else
					self._animate_targets[id] = nil
				end
			end
		else
			self._animate_targets[id] = nil
		end
	end
end


Hooks:Add("BaseNetworkSessionOnLoadComplete","HEVHUD_OnLoadComplete",callback(HEVHUD,HEVHUD,"Setup"))





--todo flag so that the line doesn't play every single time you're injured at x health
function HEVHUD:SetHealth(current,total)
	self:SetHealthString(current,total)
	local ratio = current / total
	if ratio < self.HUD_VALUES.HEALTH_THRESHOLD_DOOMED then
		self:PlaySound("suit","near_death")
	elseif ratio < self.HUD_VALUES.HEALTH_THRESHOLD_CRITICAL then 
		self:PlaySound("suit","health_critical")
	elseif ratio < self.HUD_VALUES.HEALTH_THRESHOLD_MINOR then 
--		self:PlaySound("suit","health_critical")
	end
end

function HEVHUD:SetArmor(current,total)
	self:SetSuitString(current,total)
end
Hooks:Add("DISABLED___LocalizationManagerPostInit", "hevhud_addlocalization", function( loc )
	local path = HEVHUD._localization_path
	
	for _, filename in pairs(file.GetFiles(path)) do
		local str = filename:match('^(.*).txt$')
		if str and Idstring(str) and Idstring(str):key() == SystemInfo:language():key() then
			loc:load_localization_file(path .. filename)
			return
		end
	end
	loc:load_localization_file(path .. "english.txt")
end)