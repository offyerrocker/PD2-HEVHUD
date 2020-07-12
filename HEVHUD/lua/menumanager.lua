--[[
todo:

----equipment menu:
-deployables (primary + secondary)
-throwables/abilities
-zipties
-mission equipment


-objectives

-teammates
-assault



bag value?
move hud into hudmanager hud 

globals for hud subpanels
init audio sources outside of update; call again on player respawn, and check for closed source

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
HEVHUD._DATA = {
	CROSSHAIR_IMAGE_SIZE = 96,
	NUM_POWER_TICKS = 10
}
HEVHUD._hints = {} --queue style structure

HEVHUD._waits = 0

HEVHUD._objectives_data = {} --stores all data by string id of objective
HEVHUD._objectives_lookup = {} --stores ordered references to objective data (for hud display reasons)

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

HEVHUD.color_data = {
	hl2_yellow = Color("FFD040"),
	hl2_yellow_bright = Color("F0D210"),
	hl2_red = Color("bb2d12"),
	hl2_red_bright = Color("BB0200"), --80000?
	hl2_orange = Color("FFA000")
}

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

HEVHUD._cache = { --slight misnomer but basically intended as an unorganized bucket-style structure for random things set during in-game/in-heist
	underbarrel = {
		[1] = nil,
		[2] = nil
	},
	objectives = {},
	stamina_update_t = 0
}

HEVHUD._SETUP_COMPLETE = false

HEVHUD.default_settings = {
	HEALTH_THRESHOLD_DOOMED = 0.01,
	HEALTH_THRESHOLD_CRITICAL = 0.3,
	HEALTH_THRESHOLD_MINOR = 0.5,
	ARMOR_THRESHOLD_CRITICAL = 0.3,
	ARMOR_THRESHOLD_MINOR = 0.5,
	AMMO_THRESHOLD_LOW = 1/3,
	WEAPON_INACTIVE_ALPHA = 2/3,
	WEAPON_ACTIVE_ALPHA = 1,
	CROSSHAIR_INDICATOR_SIZE = 48,
	crosshair_indicator_left_tracker = 1,
	crosshair_indicator_right_tracker = 3,
	STAMINA_UPDATE_INTERVAL = 0.025,
	STAMINA_UPDATE_RATE_DECAY = 0.8, --lower is faster decay
	STAMINA_UPDATE_RATE_BUILD = 1.3, --higher is faster build
	STAMINA_THRESHOLD_LOW = 0.3,
	STAMINA_INACTIVE_ALPHA = 0.2,
	STAMINA_ACTIVE_ALPHA = 1,
	HINT_FOCUS_X = 100,
	HINT_FOCUS_Y = 100,
	HINT_FOCUS_ADJUST_DURATION = 0.25, --seconds for a hint to reach focus location
	HINT_QUEUE_MARGIN_Y = 16,
	HINT_FONT_SIZE = 16,
	MAX_HINTS_VISIBLE = 5,
	OBJECTIVES_X = 100,
	OBJECTIVES_Y = 100,
	OBJECTIVES_W = 500,
	OBJECTIVES_H = 500,
	OBJECTIVE_W = 400,
	OBJECTIVE_H = 100
}


Hooks:Register("HEVHUD_Crosshair_Listener")
Hooks:Add("HEVHUD_Crosshair_Listener","HEVHUD_OnCrosshairListenerEvent",function(source,params)
--[[
	crosshair indicator trackers:
	1: health
	2: armor
	3: magazine (current)
	4: magazine (primary)
	5: magazine (secondary)
	6: reserve (current)
	7: reserve (primary)
	8: reserve (secondary)
	9: perk-deck-specific (stored health, absorption, etc)
	10: detection
--]]
	local source_types = {
		[1] = "health",
		[2] = "armor",
		[3] = "weapon",
		[4] = "weapon",
		[5] = "weapon",
		[6] = "weapon",
		[7] = "weapon",
		[8] = "weapon",
		[9] = "perk",
		[10] = "detection" --maybe? or separate toggle overriding during stealth?
	}
	
	local function check_listener(setting)		
		if source_types[setting] == source then 
			if setting == 1 then 
				if source == "health" then 
					return true
				end
			elseif setting == 2 then 
				if source == "armor" then 
					return true
				end
			elseif source == "weapon" then 
				if setting == 3 then 
					if params.is_equipped and params.variant == "magazine" then 
						return true
					end
				elseif setting == 4 then 
					if params.slot_name == "primary" and params.variant == "magazine" then 
						return true
					end
				elseif setting == 5 then 
					if params.slot_name == "secondary" and params.variant == "magazine" then 
						return true
					end
				elseif setting == 6 then 
					if params.is_equipped and params.variant == "reserve" then 
						return true
					end
				elseif setting == 7 then 
					if params.slot_name == "primary" and params.variant == "reserve" then 
						return true
					end
				elseif setting == 8 then 
					if params.slot_name == "secondary" and params.variant == "reserve" then 
						return true
					end
				end
			elseif setting == 9 then
				if source == "perk" then 
					local equipped_perk_deck --blackmarket equipped specialization blah blah blah
				end
			end
		end
	end
	
	if check_listener(HEVHUD.settings.crosshair_indicator_left_tracker) then 
		HEVHUD:SetLeftCrosshair(params.value,params.color)
	end
	if check_listener(HEVHUD.settings.crosshair_indicator_right_tracker) then 
		HEVHUD:SetRightCrosshair(params.value,params.color)
	end
end)

HEVHUD.settings = HEVHUD.settings or {}
for k,v in pairs(HEVHUD.default_settings) do 
	if HEVHUD.settings[k] == nil then 
		HEVHUD.settings[k] = v
	end
end

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
		
	--HINTS
		local hints = self._panel:panel({
			name = "hints"
		}) 
		--populated dynamically/separately
		
		local carry = self._panel:panel({
			name = "carry"
		})
		--individual panels per bag are generated separately
		--on bag picked up, since centered text does not seem to re-center correctly when a panel's size changes

	--OBJECTIVES
		local objective_font_size = 16
		local objectives = self._panel:panel({
			name = "objectives",
			x = self.settings.OBJECTIVES_X,
			y = self.settings.OBJECTIVES_Y,
			w = self.settings.OBJECTIVES_W,
			h = self.settings.OBJECTIVES_H
		})
		local objectives_bg = objectives:bitmap({
			name = "objectives_bg",
			layer = 1,
			texture = "guis/textures/pd2/hud_tabs",
			texture_rect = {84,0,44,32},
			w = objectives:w(),
			h = objectives:h(),
			alpha = 0.33 --0.75
		})
--		self:CreateScanlines(objectives)
		--[[
		local objective_title = objectives:text({
			name = "objective_title",
			text = self._font_icons.cross_dots,
			vertical = "center",
			align = "center",
			y = 0,
			font = self._fonts.hl2_text,
			font_size = objective_font_size,
			color = self.color_data.hl2_yellow,
			layer = 3
		})
		
		
		--]]
		
		
	--todo	
	--SQUAD
		local squad = self._panel:panel({
			name = "squad"
		})
		
		
		
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
			font_size = crosshair_font_size,
			color = self.color_data.hl2_yellow,
			layer = 3
		})
		
		local crosshair_size = self.settings.CROSSHAIR_INDICATOR_SIZE
		local crosshair_distance = 32
		local crosshair_empty_left = crosshairs:bitmap({
			name = "crosshair_empty_left",
			texture = "textures/hl2_crosshair_empty_left",
			w = crosshair_size,
			h = crosshair_size,
			x = -crosshair_distance + (crosshairs:w() - crosshair_size) / 2,
			y = (crosshairs:h() - crosshair_size) / 2,
			color = self.color_data.hl2_yellow,
			layer = 2
		})
		local crosshair_empty_right = crosshairs:bitmap({
			name = "crosshair_empty_right",
			texture = "textures/hl2_crosshair_empty_right",
			w = crosshair_size,
			h = crosshair_size,
			x = crosshair_distance + (crosshairs:w() - crosshair_size) / 2,
			y = (crosshairs:h() - crosshair_size) / 2,
			color = self.color_data.hl2_yellow,
			layer = 2
		})
		local crosshair_fill_left = crosshairs:bitmap({
			name = "crosshair_fill_left",
			texture = "textures/hl2_crosshair_fill_left",
			w = crosshair_size,
			h = crosshair_size,
			x = -crosshair_distance + (crosshairs:w() - crosshair_size) / 2,
			y = (crosshairs:h() - crosshair_size) / 2,
			color = self.color_data.hl2_yellow,
			layer = 3
		})
		local crosshair_fill_right = crosshairs:bitmap({
			name = "crosshair_fill_right",
			texture = "textures/hl2_crosshair_fill_right",
			w = crosshair_size,
			h = crosshair_size,
			x = crosshair_distance + (crosshairs:w() - crosshair_size) / 2,
			y = (crosshairs:h() - crosshair_size) / 2,
			color = self.color_data.hl2_yellow,
			layer = 3
		})
		
		
		local hostages_margin = 12
		local hostages_w = 72
		local hostages_h = 36
		local hostage_icon_size = 32
	--HOSTAGES
		local hostages = self._panel:panel({
			name = "hostages",
			w = hostages_w,
			h = hostages_h,
			x = self._panel:w() - (hostages_w + hostages_margin),
			y = hostages_margin
		})
		local hostages_icon = hostages:bitmap({
			name = "hostages_icon",
			texture = "guis/textures/pd2/hud_icon_hostage",
			x = (hostages_h - hostage_icon_size) / 2,
			y = (hostages_h - hostage_icon_size) / 2, --hostages_h is not a typo
			w = hostage_icon_size,
			h = hostage_icon_size,
			color = self.color_data.hl2_yellow,
			layer = 2
		})
		local hostages_count = hostages:text({
			name = "hostages_count",
			text = "0",
			vertical = "center",
--			align = "center",
			x = (hostages_w - 8) / 2,
			font = self._fonts.hl2_icons,
			font_size = crosshair_font_size,
			color = self.color_data.hl2_yellow,
			layer = 3
		})
		local hostages_bg = hostages:bitmap({
			name = "hostages_bg",
			layer = 1,
			texture = "guis/textures/pd2/hud_tabs",
			texture_rect = {84,0,44,32},
			w = hostages_w,
			h = hostages_h,
			alpha = 0.75
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
				
		local NUM_POWER_TICKS = self._DATA.NUM_POWER_TICKS
		local TICK_HEIGHT = 4
		local TICK_WIDTH = 7
		local TICK_MARGIN = 4

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
			color = self.color_data.hl2_yellow,
			alpha = 2/3,
			layer = 2
		})
		local TICK_OFFSET_X = (power:w() - ((NUM_POWER_TICKS - 1) * (TICK_MARGIN + (TICK_WIDTH * box_scale)))) / 2

		for i=1,NUM_POWER_TICKS do
			power:rect({
				name = "power_tick_" .. tostring(i),
				color = self.color_data.hl2_yellow_bright,
				x = 10 + ((i - 1) * (TICK_MARGIN + TICK_WIDTH)),
				y = -4 + power:h() - (TICK_HEIGHT + TICK_MARGIN),
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

function HEVHUD:SetRevives(id,revives)
	
end

function HEVHUD:ShowHint(params)
	if type(params) ~= "table" then return end
	local text = params.text
	
	local new_hint = self._panel:child("hints"):panel({
		name = params.id or params.text,
		visible = true,
		alpha = 0,
		x = self.settings.HINT_FOCUS_X,
		y = 400, --temp
		w = 500, --temp
		h = 500 --temp
	})
	
	--centered text does not re-center properly after resizing its parent i guess,
	--so create a text object specifically for measurement, resize the panel accordingly,
	--create another text object, and then remove the measurement text 
	local sample_sizer = new_hint:text({
		name = "sample_sizer",
		text = params.text,
		font = params.font or self._fonts.hl2_text,
		font_size = self.settings.HINT_FONT_SIZE,
		color = self.color_data.hl2_yellow,
		visible = false
	})
	
	local HINT_MARGIN = 12
	local tx,ty,tw,th = sample_sizer:text_rect()
	new_hint:set_size(tw + HINT_MARGIN,th + HINT_MARGIN)
	new_hint:set_y(self.settings.HINT_FOCUS_Y + (2 * new_hint:h()))
	
	new_hint:remove(sample_sizer)
	
	local hint_text = new_hint:text({
		name = "text",
		text = params.text,
		vertical = "center",
		align = "center",
		font = params.font or self._fonts.hl2_text,
		font_size = self.settings.HINT_FONT_SIZE,
		color = self.color_data.hl2_yellow,
		layer = 3,
		visible = true
	})
	local hint_bg = new_hint:bitmap({
		name = "bg",
		layer = 1,
		texture = "guis/textures/pd2/hud_tabs",
		texture_rect = {84,0,44,32},
		w = new_hint:w(),
		h = new_hint:h(),
		alpha = 2/3
	})
	params.panel = new_hint
	params.time = (tonumber(params.time) or 3) + self.settings.HINT_FOCUS_ADJUST_DURATION
	params.start_y = new_hint:y()
--	params.start_t = Application:time()
	table.insert(self._hints,params)
	--add to hints table
end

function HEVHUD:UpdateHints(t,dt)
	local panel = self._panel:child("hints")
	local queue_bottom_y = 0
	local HINT_QUEUE_MARGIN_Y = self.settings.HINT_QUEUE_MARGIN_Y
	local MAX_HINTS_VISIBLE = self.settings.MAX_HINTS_VISIBLE
	for i,hint_data in ipairs(self._hints) do 
		local hint_panel = hint_data.panel
		if i <= MAX_HINTS_VISIBLE then 
		
			hint_data.start_t = hint_data.start_t or t
			if i == 1 then 
				if not hint_data.is_first then 
					hint_data.is_first = true
					hint_data.time =  math.max(1,hint_data.time - (t - hint_data.start_t))
					hint_data.start_t = t
					
				end
				local elapsed = t - hint_data.start_t
				local elapsed_ratio = math.clamp(math.pow(elapsed / self.settings.HINT_FOCUS_ADJUST_DURATION,2),0,1)
				hint_panel:set_alpha(math.max(elapsed_ratio,hint_panel:alpha()))
			
				local d_y = self.settings.HINT_FOCUS_Y - hint_data.start_y
				hint_panel:set_y(hint_data.start_y + (d_y * (elapsed_ratio)))
				
				if elapsed > hint_data.time then 
					table.remove(self._hints,i)
					self:animate(hint_panel,"animate_fadeout",function(o) panel:remove(o) end,1/3,hint_panel:alpha(),hint_panel:x() - 200)
				end
			else
			
				local elapsed = t - hint_data.start_t
				local elapsed_ratio = math.clamp(math.pow(elapsed / self.settings.HINT_FOCUS_ADJUST_DURATION,2),0,1)
				hint_panel:set_alpha(elapsed_ratio)
				
				hint_panel:set_y(queue_bottom_y)
				hint_data.start_y = queue_bottom_y
			end
			queue_bottom_y = hint_panel:bottom() + HINT_QUEUE_MARGIN_Y
		end
	end
end

function HEVHUD:ShowCarry(carry_id,value)
	local td = tweak_data.carry[tostring(carry_id)]
	local bag_name = td and managers.localization:text(td.name_id)
	local font_size = 16
	local font = self._fonts.hl2_text
	local text_margin = 12
	
	local icon_size = 16 --max values to constrain by
	

	
	local sample_sizer = self._panel:text({
		name = "sample_sizer",
		text = bag_name,
		font = font,
		font_size = font_size,
		visible = false
	})
	--todo value
	local tx,ty,tw,th = sample_sizer:text_rect()
	self._panel:remove(sample_sizer)
	
	local bag_w = tw + text_margin
	local bag_h = th + text_margin
	local bag_start_x = self._panel:child("primary"):child("ammo"):x() --self._panel:w() - (bag_w + 100)
	local bag_start_y = self._panel:h() - (bag_h + 25)
	local bag_end_y = bag_start_y - 64
	local new_bag_panel = self._panel:child("carry"):panel({
		name = "held_bag",
		x = bag_start_x,
		y = bag_start_y,
		w = bag_w + (icon_size * 2),
		h = bag_h,
		alpha = 0
	})
	
		
	local bag_texture,bag_rect = tweak_data.hud_icons:get_icon_data("bag_icon")
	local bag_icon = new_bag_panel:bitmap({
		name = "bag_icon",
		texture = bag_texture,
		texture_rect = bag_rect,
		layer = 2
--		w = icon_w,
--		h = icon_h,
--		x = (icon_w + text_margin) / 2,
--		y = (icon_h + text_margin) / 2
	})	
	
	local size_ratio = icon_size / math.max(bag_icon:w(),bag_icon:h())
	bag_icon:set_size(size_ratio * bag_icon:w(),size_ratio * bag_icon:h())	
	bag_icon:set_position(text_margin / 2,(bag_h - bag_icon:h()) / 2)
	
	local bag_name = new_bag_panel:text({
		name = "bag_name",
		text = bag_name,
		vertical = "center",
		align = "center",
		x = icon_size,
		font = font,
		font_size = font_size,
		color = self.color_data.hl2_yellow,
		layer = 3
	})

	
	local bag_bg = new_bag_panel:bitmap({
		name = "bag_bg",
		layer = 1,
		texture = "guis/textures/pd2/hud_tabs",
		texture_rect = {84,0,44,32},
		w = new_bag_panel:w(),
		h = new_bag_panel:h(),
		alpha = 0.75
	})
	self._held_bag = new_bag_panel
	
	self:animate(new_bag_panel,"animate_fadein",nil,0.5,1,nil,nil,bag_start_y,bag_end_y)
	
end

function HEVHUD:HideCarry()
	local carry_panel = self._panel:child("carry")
	if self._held_bag and alive(self._held_bag) then 
		self:animate(self._held_bag,"animate_fadeout",function(o) 
			carry_panel:remove(o)
		end,0.5,self._held_bag:alpha(),nil,-100)
--		self._panel:child("carry"):remove(self._panel:child("held_bag"))
		self._held_bag = nil
	end
end

--[[
--todo lines for health/armor damage from various sources
--todo flag so that the line doesn't play every single time you're injured at x health
function HEVHUD:SetHealth(current,total)
	local ratio = current / total
	if ratio < self.HUD_VALUES.HEALTH_THRESHOLD_DOOMED then
		self:PlaySound("suit","near_death")
	elseif ratio < self.HUD_VALUES.HEALTH_THRESHOLD_CRITICAL then 
		self:PlaySound("suit","health_critical")
	elseif ratio < self.HUD_VALUES.HEALTH_THRESHOLD_MINOR then 
--		self:PlaySound("suit","health_critical")
	end
end
--]]

function HEVHUD:SetHealth(data)
	HEVHUD:SetRevives(nil,data.revives)

	local health_ratio = 0
	local text = ""
	if data.total ~= 0 then 
		health_ratio = data.current / data.total
		if HEVHUD:ShouldShowHealthValue() then 
			text = string.format("%i",data.current * 10)
		else
			text = string.format("%i",health_ratio * 10)
		end
	end
	local color
	if health_ratio <= self.settings.HEALTH_THRESHOLD_CRITICAL then 
		color = self.color_data.hl2_red
	elseif health_ratio <= self.settings.HEALTH_THRESHOLD_MINOR then 
		color = self.color_data.hl2_orange
	else 
		color = self.color_data.hl2_yellow
	end	
	
	Hooks:Call("HEVHUD_Crosshair_Listener","health",{
		value = health_ratio,
		color = color
	})
	self._panel:child("health"):child("health_label"):set_text(text)
	self._panel:child("health"):child("health_label"):set_color(color)
end

function HEVHUD:SetArmor(data)

	local color
	local text = ""
	local armor_ratio = 0
	if data.total ~= 0 then 
		armor_ratio = data.current / data.total
		if HEVHUD:ShouldShowArmorValue() then 
			text = string.format("%i",data.current * 10)
		else
			text = string.format("%i",armor_ratio * 10)
		end
	end
	if armor_ratio <= self.settings.ARMOR_THRESHOLD_CRITICAL then 
		color = self.color_data.hl2_red
	elseif armor_ratio <= self.settings.ARMOR_THRESHOLD_MINOR then 
		color = self.color_data.hl2_orange
	else 
		color = self.color_data.hl2_yellow
	end	
	
	Hooks:Call("HEVHUD_Crosshair_Listener","armor",{
		value = armor_ratio,
		color = color
	})
	self._panel:child("suit"):child("suit_label"):set_text(text)
	self._panel:child("suit"):child("suit_label"):set_color(color)
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
	

	
	self:SetWeaponPanelState(slot_name,true)
	
	
	
	local ammo_ratio = 1
	if max_reserve > 0 then
		ammo_ratio = current_reserve / max_reserve
	end
	local color
	if ammo_ratio <= 0 then 
		color = self.color_data.hl2_red
	elseif ammo_ratio <= self.settings.AMMO_THRESHOLD_LOW then 
		color = self.color_data.hl2_orange
	else 
		color = self.color_data.hl2_yellow
	end
	
	Hooks:Call("HEVHUD_Crosshair_Listener","weapon",{
		variant = "reserve",
		slot_name = slot_name,
		is_equipped = slot == player:inventory():equipped_selection(),
		value = ammo_ratio,
		color = color
	})
	if alive(weapon_panel) then 
		weapon_panel:child("ammo"):child("reserve"):set_color(color)
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
	
	
	local color
	local ammo_ratio = 1
	if mag_max > 0 then
		ammo_ratio = mag_current / mag_max
	end
	if ammo_ratio <= 0 then 
		color = self.color_data.hl2_red
	elseif ammo_ratio <= self.settings.AMMO_THRESHOLD_LOW then 
		color = self.color_data.hl2_orange
	else 
		color = self.color_data.hl2_yellow
	end	
	
	Hooks:Call("HEVHUD_Crosshair_Listener","weapon",{
		variant = "magazine",
		slot_name = slot_name,
		is_equipped = slot == player:inventory():equipped_selection(),
		value = ammo_ratio,
		color = color
	})
	self:SetWeaponPanelState(slot_name,true)
	
	if alive(weapon_panel) then 
		weapon_panel:child("ammo"):child("magazine"):set_color(color)
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

function HEVHUD:SetRightCrosshair(value,color)
	local crosshair_master = self._panel:child("crosshairs")
	local crosshair = crosshair_master:child("crosshair_fill_right")
	local crosshair_outline = crosshair_master:child("crosshair_empty_right")
	local IMAGE_SIZE = self._DATA.CROSSHAIR_IMAGE_SIZE
	local INDICATOR_SIZE = self.settings.CROSSHAIR_INDICATOR_SIZE
	if value then 
		crosshair:set_texture_rect(0,IMAGE_SIZE * (1 - value),IMAGE_SIZE,IMAGE_SIZE * (value))
		crosshair:set_h(self.settings.CROSSHAIR_INDICATOR_SIZE * (value))
		crosshair:set_y(((crosshair_master:h() - INDICATOR_SIZE) / 2) + ((1 - value) * INDICATOR_SIZE))
	end
	if color then 
		crosshair:set_color(color)
		crosshair_outline:set_color(color)
	end
end

function HEVHUD:SetLeftCrosshair(value,color)
	local crosshair_master = self._panel:child("crosshairs")
	local crosshair = crosshair_master:child("crosshair_fill_left")
	local crosshair_outline = crosshair_master:child("crosshair_empty_left")
	local IMAGE_SIZE = self._DATA.CROSSHAIR_IMAGE_SIZE
	local INDICATOR_SIZE = self.settings.CROSSHAIR_INDICATOR_SIZE
	if value then 
		crosshair:set_texture_rect(0,IMAGE_SIZE * (1 - value),IMAGE_SIZE,IMAGE_SIZE * (value))
		crosshair:set_h(INDICATOR_SIZE * (value))
		crosshair:set_y(((crosshair_master:h() - INDICATOR_SIZE) / 2) + ((1 - value) * INDICATOR_SIZE))
	end
	if color then 
		crosshair:set_color(color)
		crosshair_outline:set_color(color)
	end
end

function HEVHUD:SetHostageCount(num)
	self._panel:child("hostages"):child("hostages_count"):set_text(math.clamp(num,0,99))
end

function HEVHUD:ShowHostages(skip_anim)
	self._panel:child("hostages"):child("hostages_count"):show()
end

function HEVHUD:HideHostages(skip_anim)
	self._panel:child("hostages"):child("hostages_count"):hide()
end

function HEVHUD:AddObjective(data)
	if not data then
		self:log("HEVHUD:AddObjective(): What kind of idiot tries to add an objective with no data?")
		return
	end
	if not data.id then 
		self:log("HEVHUD:AddObjective(): You know, back in my day, our objectives had INTEGRITY. We always added ids to our objectives. That's what's wrong with this country." )
		return
	end	
	
	local objective = self._objectives_data[data.id]	
	
	if data.mode == "activate" then 
		if not objective then --add new objective data to stored table
			self._objectives_data[data.id] = data
			objective = self._objectives_data[data.id]

			--create text
			local panel = self._panel:child("objectives"):panel({
				name = data.id,
				w = self.settings.OBJECTIVE_W,
				h = self.settings.OBJECTIVE_H
			})
			objective.objective_panel = panel
			objective.objective_text = panel:text({
				name = "title",
				text = data.text,
				align = "left",
				font = self._fonts.hl2_text,
				font_size = 16,
				color = self.color_data.hl2_yellow,
				layer = 3,
				visible = true
			})
			objective.objective_amount_text = panel:text({
				name = "amount",
				text = "",
				align = "right",
				font = self._fonts.hl2_text,
				font_size = 16,
				color = self.color_data.hl2_yellow,
				layer = 4,
				visible = true
			})
			
			HEVHUD:ShowPopup(data.id,data.text)
		end
	elseif data.mode == "update_amount" then 
		objective.amount = data.amount or objective.amount
		objective.current_amount = data.current_amount or objective.current_amount
		if objective.amount then 
			if objective.current_amount then 
				local s = managers.localization:text("hevhud_objective_amount_progress")
				s = string.gsub(s,"$1",objective.current_amount)
				s = string.gsub(s,"$2",objective.amount)
				objective.objective_amount_text:set_text(s)
			else
				objective.objective_amount_text:set_text(tostring(objective.amount))
			end
		elseif data.current_amount then 
			objective.objective_amount_text:set_text(tostring(data.current_amount))
		end
		objective.objective_text:set_text(data.text)
	elseif data.mode == "complete" then 
		self._panel:child("objectives"):remove(objective.objective_panel)
--		objective.objective_panel:remove(objective.objective_text)
--		objective.objective_panel:remove(objective.objective_amount_text)
	elseif data.mode == "remind" then 
		
	else
		self:log("HEVHUD:AddObjective(" .. tostring(data) .. ") Error: unknown data mode " .. tostring(data.mode),{color=Color.red})
	end
	
	--[[
	
		item = self._panel:child("objectives"):panel({
			name = data.id
		})
		local item_bg = item:bitmap({
			name = "item_bg",
			layer = 1,
			texture = "guis/textures/pd2/hud_tabs",
			texture_rect = {84,0,44,32},
			w = item:w(),
			h = item:h(),
			alpha = 0.75
		})
	--]]
--[[
	if data.mode == "remind" then 
		local c = self._cache.objectives[data.id] or {text = ""}
		data.current_amount = data.current_amount or c.current_amount
		data.amount = data.amount or c.amount
		data.text = data.text or c.text
	elseif data.text then 
		self._cache.objectives[data.id] = data
	end
	
	
	local added = false
	
	--search queued objectives for this objective, and replace it if it exists (and isn't already animating)
	for i,queued in ipairs(self._objectives_queue) do 
		if queued.id == data.id and not queued.is_animating then 
			table.remove(self._objectives_queue,i)
			table.insert(self._objectives_queue,data)
			added = true
			break
		end
	end
	if not added then 		
		table.insert(self._objectives_queue,data)
	end
	if self._objectives_queue[1] and not self._objectives_queue[1].is_animating then
		self:PerformObjectiveFromQueue()
	end
	--]]
end


function HEVHUD.animate_scanlines(o,t,dt,start_t,alpha_table)
	if not alpha_table then return true end
	local speed = 10
	for i = 1,#alpha_table do 
		local elapsed = (t - start_t) * speed
		local scanline = o:child("scanline_" .. tostring(i))
		
		if alive(scanline) then 
			local j = math.floor((i + elapsed) % #alpha_table) + 1
			if not alpha_table[j] then 
				Log(j)
				Log(#alpha_table,{color=Color.green})
				logall(alpha_table)
				return true
			end
			scanline:set_alpha(math.sin(180 * (j / #alpha_table) * alpha_table[j]))
			scanline:set_y((j / #alpha_table) * o:h())
		end
	end


--[[
	if not count then return true end
	
	alpha = alpha or 1
	alpha_deviation = alpha_deviation or 1
	speed = speed or 2
	local max_h = o:h()
	local margin = 0.15
	local color = HEVHUD.color_data.hl2_orange
	for i = 1,count do 
		local a_range = alpha + (math.random(alpha_deviation * 2 * 100) / 100) - alpha_deviation
		local j = ((t - start_t) % count) --count functions as period here too
--			local a_range = 0.5 + ((j % 2) / 2)
			scanline:set_y((scanline:y() + (speed * dt)) % max_h)
--			scanline:set_alpha( (((i + j) % count) / count) )

	end
	--]]
end


function HEVHUD:ShowPopup(id,text)
	local hints_panel = self._panel:child("hints")
	local popup = hints_panel:panel({
		name = id .. "_popup",
		alpha = 0
	})
	local sizer = popup:text({
		name = "sizer",
		text = text,
		font = self._fonts.hl2_text,
		font_size = 16,
		visible = false
	})
	local tx,ty,tw,th = sizer:text_rect()
	popup:remove(sizer)
	local margin = 4
	popup:set_size(tw + margin,th + margin)
	
	self:CreateScanlines(popup)
	local function remove_panel(o)
		o:parent():remove(o)
	end
	
	local function wait()
		self:animate_wait(2,
			function ()
				self:animate(popup,"animate_fadeout",remove_panel,1,popup:alpha(),nil,-popup:h())
			end
		)
	end
	--(popup,"animate_fade",function(o) self:animate(o,"animate_fadeout",remove_panel,2,o:alpha()) end,3)
--	HEVHUD:animate(popup,"animate_scanlines",nil,data)
	self:animate(popup,"animate_fadein",wait,1,1,nil,nil) --,popup:y() + popup:h(),popup:h())
	
	local popup_text = popup:text({
		name = "popup_text",
		text = text,
		align = "center",
		vertical = "center",
		font = self._fonts.hl2_text,
		font_size = 16,
		color = self.color_data.hl2_yellow,
		layer = 3,
		visible = true
	})
	popup:set_center(hints_panel:center())
end

--animates the appearance of the topmost objective in the queue
function HEVHUD:PerformObjectiveFromQueue()
	--[[
	local data = self._objectives_queue[1]
	local mode = data.mode --can be activate, remind, or complete
	if mode == "activate" then 
		self:SetObjectiveTitle(utf8.to_upper(managers.localization:text("noblehud_hud_objective_activate")))
	elseif mode == "remind" then 
		self:SetObjectiveTitle(utf8.to_upper(managers.localization:text("noblehud_hud_objective_reminder")))
	elseif mode == "update_amount" then
		self:SetObjectiveTitle(utf8.to_upper(managers.localization:text("noblehud_hud_objective_update")))
	elseif mode == "complete" then
		self:SetObjectiveTitle(utf8.to_upper(managers.localization:text("noblehud_hud_objective_complete")))
	elseif mode == "wave" then
		self:SetObjectiveTitle(utf8.to_upper(managers.localization:text("noblehud_hud_objective_wave")))
	else
		self:log("If I was locked in a room with a gun, two bullets, and yourself, I would add a mode parameter to my PerformObjectiveFromQueue() calls. Also, I'd shoot the door lock.",{color=Color.red})
		table.remove(self._objectives_queue,1)
	end
	self:AnimateShowObjective(data)
--]]	
end

function HEVHUD:CreateScanlines(panel,params)
	if not alive(panel) then 
		self:log("HEVHUD:CreateScanlines(" .. tostring(panel) .. "," .. tostring(count) .. "): bad panel")
		return
	end
	params = params or {}
	local count = params.count or panel:h()
	local intensity = params.intensity or 0.5
	local intensity_deviance = params.intensity_deviance or 0.2
	local margin = params.margin or 0.15
	
	local visible = true
	if params.visible ~= nil then 
		visible = params.visible
	end
	local a_table = {}

		
	local color = self.color_data.hl2_orange
	for i=1,count do 
		local a_range = 0.5 + ((i % 2) / 2)
		local alpha = intensity + (math.random(intensity_deviance * 2 * 100) / 100) - intensity_deviance
		a_table[i] = alpha
		local gradient = panel:gradient({
			name = "scanline_" .. tostring(i),
			x = params.x or 0,
			y = params.y or ((i / count) * panel:h()),
			w = params.w or (panel:w()),
			h = params.h or (count / panel:h()),
			layer = params.layer or -1,
			alpha = alpha * math.sin(180 * i / count), --(((2 * i) / count) - (i / count)),
			blend_mode = params.blend_mode or "add",
			gradient_points = params.gradient_points or {
				0,
				color:with_alpha(0),
				margin,
				color:with_alpha(a_range),
				1 - margin,
				color:with_alpha(a_range),
				1,
				color:with_alpha(0)
			},
			visible = visible
		})
	end
	
	local objectives_bg = panel:bitmap({
		name = "objectives_bg",
		layer = (params.layer or -1) + 1,
		texture = "guis/textures/pd2/hud_tabs",
		texture_rect = {84,0,44,32},
		w = panel:w(),
		h = panel:h(),
		alpha = 0.33 --0.75
	})
	return a_table
end

--	self:animate(panel,"animate_scanlines",nil,count,10,0.5,0.3)
--	local panel = HEVHUD._panel:child("objectives"); HEVHUD:animate(panel,"animate_scanlines",nil,panel:h(),10,0.5,0.01)
--technically this uses the parent as the animate target


function HEVHUD.OLD_animate_scanlines(o,t,dt,start_t,count,speed,alpha,alpha_deviation)
	if not count then return true end
	alpha = alpha or 1
	alpha_deviation = alpha_deviation or 1
	speed = speed or 2
	local max_h = o:h()
	local margin = 0.15
	local color = HEVHUD.color_data.hl2_orange
	for i = 1,count do 
		local a_range = alpha + (math.random(alpha_deviation * 2 * 100) / 100) - alpha_deviation
		local j = ((t - start_t) % count) --count functions as period here too
		local scanline = o:child("scanline_" .. tostring(i))
		if alive(scanline) then 
--			local a_range = 0.5 + ((j % 2) / 2)
			scanline:set_y((scanline:y() + (speed * dt)) % max_h)
			scanline:set_alpha(math.sin(180 * (scanline:y() / max_h)) * a_range)
--			scanline:set_alpha( (((i + j) % count) / count) )

		end
	end
end

function HEVHUD.animate_flicker_alpha(o,t,dt,start_t,duration)
	if duration == 0 then 
	elseif (t - start_t) <= 0 then 
	
	end
end

function HEVHUD:SetObjectiveTitle(text)
--[[
	if alive(self._objectives_panel) then 
		self._objectives_panel:child("objectives_title"):set_text(label)
		self._objectives_panel:child("objectives_title_shadow"):set_text(label)
	end
	--]]
end

function HEVHUD:AnimateShowObjective(data)
--[[
	if not self._queued_objectives[1] then
		self:log("NobleHUD:AnimateShowObjective() ERROR: Tried to animate nonexistent objective queue",{color=Color.red})
		return
	end
	self._queued_objectives[1].is_animating = true
	local objectives_panel = NobleHUD._objectives_panel
	local objectives_label = objectives_panel:child("objectives_label")
	local objectives_label_shadow = objectives_panel:child("objectives_label_shadow")
	local objectives_title = objectives_panel:child("objectives_title")
	local objectives_title_shadow = objectives_panel:child("objectives_title_shadow")
	local _,_,label_w,label_h = objectives_label:text_rect()
	
	local _,_,title_w,title_h = objectives_title:text_rect()

	local blink_label = NobleHUD._objectives_panel:child("blink_label")
	local blink_title = NobleHUD._objectives_panel:child("blink_title")

	local kern = -2
	local title_font_size = tweak_data.hud.active_objective_title_font_size
	local label_font_size = title_font_size * 1.15
	local in_duration = 0.2
	local mid_x = objectives_panel:w() / 2
	local blinkout_time = 0.25
	local blinkout_alpha = 0.9
	local blinkout_stretch_w_mul = 1.25
	local display_hold_time = 3
	
--prep
	blink_label:set_size(label_w,label_h)
--	blink_label:set_alpha(1)
	blink_title:set_size(title_w,title_h)
	blink_title:set_alpha(1)
	objectives_title:set_font_size(0)
	objectives_title:set_kern(kern)
	objectives_title:set_alpha(1)
	objectives_title_shadow:set_font_size(0)
	objectives_title_shadow:set_kern(kern)
	objectives_title_shadow:set_alpha(1)
	objectives_label:set_font_size(0)
	objectives_label:set_kern(kern)
	objectives_label:set_alpha(1)
	objectives_label:set_color(data.color or self.color_data.hud_objective_label_text)
	objectives_label_shadow:set_font_size(0)
	objectives_label_shadow:set_kern(kern)
	objectives_label_shadow:set_alpha(1)
	self:animate_stop(blink_label)
	self:animate_stop(blink_title)
	self:animate_stop(objectives_title)
	self:animate_stop(objectives_title_shadow)
	self:animate_stop(objectives_label)
	self:animate_stop(objectives_label_shadow)
	
	if (data.mode ~= "remind") or (data.id and data.id == managers.hud._hud_objectives._active_objective_id) then
		local label_text = utf8.to_upper(data.text)
		if data.amount and data.current_amount then
			label_text = label_text .. string.gsub(" [$CURRENT/$TOTAL]","$CURRENT",data.current_amount)
			label_text = string.gsub(label_text,"$TOTAL",data.amount)
		elseif data.amount or data.current_amount then 
		--i don't know under what circumstances this would trigger, probably just weirdly scripted custom heissts
			label_text = label_text .. " [" .. tostring(data.amount or data.current_amount) .. "]"
		end
		objectives_label:set_text(label_text)
		objectives_label_shadow:set_text(label_text)
	end
	
	
--build display cb sequence backwards

--forward order:

--animate white flash
	-- done_cb fadein title, fadein label
--fadein title
	--done cb: delayed cb to fadeout title after display duration
--fadein label
	--done cb: delayed cb to fadeout label after display duration
--return done
	
--basically, title and label are animated concurrently (after the initial flash)
--each with their own cb tree,
--but title is the one that calls the overall animate done callback for this objective 

--
	local function done () 
	--remove this objective from queue, 
	--	and display next queued objective, if one exists
		table.remove(self._queued_objectives,1)
		if self._queued_objectives[1] then 
			self:PerformObjectiveFromQueue()
		end
	end
	
	
	
	local function fadeout_title()
		self:AddDelayedCallback(function()
			self:animate(objectives_title,"animate_fadeout",function(o) o:set_font_size(title_font_size) done() end,0.5)
			self:animate(objectives_title_shadow,"animate_fadeout",function(o) o:set_font_size(title_font_size) end,0.5)		
		end,nil,display_hold_time,"objective_title_hide")
	end
	local function fadeout_label()
		self:AddDelayedCallback(function()
			self:animate(objectives_label,"animate_fadeout",nil,0.5)
			self:animate(objectives_label_shadow,"animate_fadeout",nil,0.5)
		end,nil,display_hold_time,"objective_label_hide")
	end
	
	local function animate_objective_label_in()		
		self:animate(objectives_label,"animate_objective_flash",fadeout_label,in_duration,label_font_size,kern)
		self:animate(objectives_label_shadow,"animate_objective_flash",nil,in_duration,label_font_size,kern)
	end
	local function animate_blink_blinkout()
		blink_label:set_alpha(1)
		self:animate(blink_label,"animate_objective_blinkout",animate_objective_label_in,blinkout_time,label_w,label_w * blinkout_stretch_w_mul,blinkout_alpha,mid_x)
	end
	
	local function animate_objective_title_in()
		self:animate(objectives_title,"animate_objective_flash",fadeout_title,in_duration,title_font_size,kern)
		self:animate(objectives_title_shadow,"animate_objective_flash",nil,in_duration,title_font_size,kern)
		animate_blink_blinkout()
	end

	self:animate(blink_title,"animate_objective_blinkout",animate_objective_title_in,blinkout_time,title_w,title_w * blinkout_stretch_w_mul,blinkout_alpha,mid_x)
--]]
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
	
	
	--init HEV suit sound source; TODO make this init and check for closed source
	local player = managers.player:local_player()
	if player then 
		self._audio_sources.suit = self._audio_sources.suit or XAudio.UnitSource:new(XAudio.PLAYER)
	else
		return
	end
	for source_name,audio_queue in pairs(self._audio_queue) do 
		local audio_source = self._audio_sources[source_name] and self._audio_sources[source_name]
		if audio_source and audio_source:get_state() ~= 1 then 
			local snd_data = table.remove(audio_queue,1)
			if snd_data and type(snd_data) == "table" then
				audio_source:set_buffer(snd_data.buffer)
				audio_source:set_looping(snd_data.should_loop)
				audio_source:play()
			end
		end
	end
	
	if player and self._cache.stamina_update_t > self.settings.STAMINA_UPDATE_INTERVAL then 
		self._cache.stamina_update_t = self._cache.stamina_update_t - self.settings.STAMINA_UPDATE_INTERVAL
		
		local stamina_ratio = player:movement():stamina() / player:movement():_max_stamina()
		for i = self._DATA.NUM_POWER_TICKS,1,-1 do 
			local tick = self._panel:child("power"):child("power_tick_" .. tostring(i))
			local a = tick:alpha()
			if stamina_ratio >= (i/self._DATA.NUM_POWER_TICKS) then 
				if a < self.settings.STAMINA_ACTIVE_ALPHA then 
					tick:set_alpha(math.min(a * self.settings.STAMINA_UPDATE_RATE_BUILD,self.settings.STAMINA_ACTIVE_ALPHA))
				end
			else
				if a > self.settings.STAMINA_INACTIVE_ALPHA then 
					tick:set_alpha(math.max(a * self.settings.STAMINA_UPDATE_RATE_DECAY,self.settings.STAMINA_INACTIVE_ALPHA))
				end
			end
			--chose to use custom STAMINA_THRESHOLD_LOW value instead of tweak_data.player.movement_state.stamina.MIN_STAMINA_THRESHOLD
			--since at this low level (4 out of ~100 base), there are no stamina ticks visually remaining 
			if stamina_ratio < self.settings.STAMINA_THRESHOLD_LOW then
				tick:set_color(self.color_data.hl2_red)
			else
				tick:set_color(self.color_data.hl2_yellow)			
			end
		end
		if stamina_ratio < self.settings.STAMINA_THRESHOLD_LOW then 
			self._panel:child("power"):child("power_name"):set_color(self.color_data.hl2_red)
		else
			self._panel:child("power"):child("power_name"):set_color(self.color_data.hl2_yellow)	
		end
	end
	self._cache.stamina_update_t = self._cache.stamina_update_t + dt
	
	self:UpdateHints(t,dt)
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

function HEVHUD:animate_wait(timer,callback,...)
	self._waits = self._waits + 1
	self:animate(self._waits,self._animate_wait,callback,timer,...)
end

function HEVHUD._animate_wait(o,t,dt,start_t,duration)
	if (t - start_t) >= duration then 
		return true
	end
end

function HEVHUD.animate_fadeout(o,t,dt,start_t,duration,from_alpha,exit_x,exit_y)
	duration = duration or 1
	from_alpha = from_alpha or 1
	local ratio = math.pow((t - start_t) / duration,2)
	
	if ratio >= 1 then 
		o:set_alpha(0)
		return true
	end
	o:set_alpha(from_alpha * (1 - ratio))
	if exit_y then 
		o:set_y(o:y() + (exit_y * dt / duration))
	end
	if exit_x then 
		o:set_x(o:x() + (exit_x * dt / duration))
	end
end

function HEVHUD.animate_fadein(o,t,dt,start_t,duration,end_alpha,start_x,end_x,start_y,end_y)
	duration = duration or 1
	end_alpha = end_alpha or 1
	local ratio = math.pow((t - start_t) / duration,2)
	
	if ratio >= 1 then 
		o:set_alpha(end_alpha)
		if end_x then 
			o:set_x(end_x)
		end 
		if end_y then 
			o:set_y(end_y)
		end
		return true
	end
	o:set_alpha(ratio * end_alpha)
	if start_x and end_x then 
		o:set_x(start_x + ((end_x - start_x) * ratio))
	end
	if start_y and end_y then 
		o:set_y(start_y + ((end_y - start_y) * ratio))
	end
end

function HEVHUD.animate_text_color_ripple(o,t,dt,start_t,duration,start_color,end_color,start_alpha,end_alpha)
	duration = duration or 1
	local progress = (t - start_t) / duration
	
	Console:SetTrackerValue("trackera",tostring(progress))
	Console:SetTrackerValue("trackerb",tostring(t - start_t)) --elapsed
	if progress >= 1 then
		if end_alpha then 
			o:set_alpha(end_alpha)
		end
		if end_color then 
			o:set_color(end_color)
		end
		return true
	end
	local length = string.len(o:text())
	for i=1,length do 
		local char_ratio = i/length
		local char_duration = duration * char_ratio
--		local char_start_t = start_t + (duration * char_ratio)
--		local char_progress = math.clamp(t - char_start_t,0,1)
--		local char_progress = math.clamp((t- start_t) / (duration * (i - 1) / length),0,1)
		local char_start_t = start_t + (duration * char_ratio)
--		local char_progress = math.clamp((t - (start_t + (char_duration - duration))) / char_duration,0,1)
		local char_progress = math.clamp((t - char_start_t + duration) / (char_duration),0,1) --working

		if start_color and end_color then 
			local color = HEVHUD.interp_colors(start_color,end_color,char_progress)
			o:set_range_color(i-1,i,color)
		end
	end
	if start_alpha and end_alpha then 
		local d_a = end_alpha - start_alpha
		o:set_alpha(start_alpha + (d_a * progress))
	end
	
end

function HEVHUD.interp_colors(one,two,percent) --interpolates colors based on a percentage
--percent is [0,1]
	percent = math.clamp(percent,0,1)
	
--color 1
	local r1 = one.red
	local g1 = one.green
	local b1 = one.blue
	local a1 = one.alpha
	
--color 2
	local r2 = two.red
	local g2 = two.green
	local b2 = two.blue
	local a2 = two.alpha

--delta
	local r3 = r2 - r1
	local g3 = g2 - g1
	local b3 = b2 - b1
	local a3 = a2 - a1
	
	return Color(r1 + (r3 * percent),g1 + (g3 * percent), b1 + (b3 * percent)):with_alpha(a1 + (a3 * percent))
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


Hooks:Add("LocalizationManagerPostInit", "hevhud_addlocalization", function( loc )
	loc:add_localized_strings({
		hevhud_objective_amount_progress = "$1 / $2",
	})

--[[
	local path = HEVHUD._localization_path
	
	for _, filename in pairs(file.GetFiles(path)) do
		local str = filename:match('^(.*).txt$')
		if str and Idstring(str) and Idstring(str):key() == SystemInfo:language():key() then
			loc:load_localization_file(path .. filename)
			return
		end
	end
	loc:load_localization_file(path .. "english.txt")
	--]]
end)