HEVHUD = HEVHUD or {}
HEVHUD._path = HEVHUD._path or ModPath
HEVHUD._localization_path = HEVHUD._localization_path or (HEVHUD._path .. "localization/")
HEVHUD._assets_path = HEVHUD._assets_path or (HEVHUD._path .. "assets/")
HEVHUD._sounds_path = HEVHUD._sounds_path or (HEVHUD._assets_path .. "snd/")
HEVHUD._AUDIO_FILE_FORMAT = ".ogg"
HEVHUD._audio_sources = HEVHUD._audio_sources or {}
HEVHUD._audio_buffers = HEVHUD._audio_buffers or {}
HEVHUD._audio_queue = HEVHUD._audio_queue or {}
HEVHUD._suit_number_vox = HEVHUD._suit_number_vox or {
	["0"] = "_comma"
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
	["40"] = "forty",
	["50"] = "fifty",
	["60"] = "sixty",
	["70"] = "seventy",
	["80"] = "eighty",
	["90"] = "ninety",
	["100"] = "onehundred",
	["pm"] = "pm",
	["am"] = "am"
}
HEVHUD._fonts = {
	hl2_icons = HEVHUD._assets_path .. "fonts/hl2",
	hl2_text = HEVHUD._assets_path .. "fonts/myriad_pro"
}
HEVHUD._animate_targets = {}
HEVHUD._panel = HEVHUD._panel or nil --for name reference 

HEVHUD._cache = {} --slight misnomer but basically intended as an unorganized bucket-style structure for random things set during in-game/in-heist

HEVHUD._SETUP_COMPLETE = false


HEVHUD.default_settings = {
	HEALTH_THRESHOLD_DOOMED = 0.01,
	HEALTH_THRESHOLD_CRITICAL = 0.3,
	HEALTH_THRESHOLD_MINOR = 0.5
}
HEVHUD.settings = HEVHUD.settings or {}
for k,v in pairs(HEVHUD.default_settings) do 
	if HEVHUD.settings[k] == nil then 
		HEVHUD.settings[k] = v
	end
end


HEVHUD.color_data = {
	hl2_yellow = Color("FFD040"),
	hl2_orange = Color("FFA000")
}

function HEVHUD:log(...)
	if Console then 
		Console:Log(...)
	else
		log(...)
	end
end

Hooks:Add("BaseNetworkSessionOnLoadComplete","HEVHUD_OnLoadComplete",callback(HEVHUD,HEVHUD,"Setup"))

function HEVHUD:CreateHUD()
	if Util:IsInHeist() then 
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
			text = "Q",
			vertical = "center",
			align = "center",
			y = -crosshair_font_size * 0.9,
			font = self._fonts.hl2_icons,
			font_size = crosshair_font_size
		})
		local crosshair_left = crosshairs:text({
			name = "crosshair_left",
			text = "[",
			vertical = "center",
			align = "center",
			x = -16,
			y = -crosshair_font_size,
			font = self._fonts.hl2_icons,
			font_size = crosshair_font_size
		})
		local crosshair_right = crosshairs:text({
			name = "crosshair_right",
			text = "]",
			vertical = "center",
			align = "center",
			x = 16,
			y = -crosshair_font_size,
			font = self._fonts.hl2_icons,
			font_size = crosshair_font_size
		})
		
		
	--HEALTH/SUIT
		local vitals = self._panel:panel({
			name = "vitals"
		})

		local box_scale = 1
		local box_w = 128 * box_scale
		local box_h = 48 * box_scale
		
		local text_name_size = 16 * box_scale
		local text_label_size = 32 * box_scale
		
		local box_ver_offset = -32
		local text_ver_offset = -8
		local health = hl2:panel({
			name = "health",
			w = box_w,
			h = box_h,
			x = 48 + 24,
			y = -128 + box_ver_offset + hl2:h() - box_h
		})
		
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
			font = self._fonts.hl2_text,
			font_size = text_name_size,
			color = self.color_data.hl2_yellow,
			alpha = 2/3,
			layer = 2
		})
		local health_label = health:text({
			name = "health_label",
			text = "96",
			align = "right",
			x = -text_label_size,
			y = text_ver_offset + health:h() - text_label_size,
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
			y = -128 + box_ver_offset + hl2:h() - box_h
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
			font = self._fonts.hl2_text,
			font_size = text_name_size,
			color = self.color_data.hl2_yellow,
			alpha = 2/3,
			layer = 2
		})
		local suit_label = suit:text({
			name = "suit_label",
			text = "100",
			align = "right",
			x = -text_label_size,
			y = text_ver_offset + suit:h() - text_label_size,
			font = self._fonts.hl2_icons,
			font_size = text_label_size,
			color = self.color_data.hl2_yellow,
			alpha = 2/3,
			layer = 2
		})

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
			
	end
end


function HEVHUD:ShouldShowVitalsValues() 
	return true
end
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


function HEVHUD:SetHealthString(current,total)
	if self:ShouldShowVitalsValues() then
		self._panel:child("health"):child("health_label"):set_text(string.format("%d",current * 10))
	else
		self._panel:child("health"):child("health_label"):set_text(string.format("%d",current/total))
	end
end

function HEVHUD:SetSuitString(current,total)
	if self:ShouldShowVitalsValues() then 
		self._panel:child("suit"):child("suit_label"):set_text(string.format("%d",current * 10))
	else
		self._panel:child("suit"):child("suit_label"):set_text(string.format("%d",current/total))
	end
end

function HEVHUD:Setup()
	if not self._SETUP_COMPLETE then 
		self._SETUP_COMPLETE = true
		--init blt xaudio (doesn't matter if another mod has already set it up)
		if blt.xaudio then
			blt.xaudio.setup()
		end
		
		--init HEV suit sound source
		self._audio_sources.suit = XAudio.UnitSource:new(XAudio.PLAYER)
		
		self:CreateHUD()
	end
end

function HEVHUD:SayTime()
	self:PlaySound("suit","time_is_now")
	local TWELVE_HOUR = true
	local c_h
	if TWELVE_HOUR then 
		c_h = os.date("%H")
	else
		c_h = os.date("%I")
	end
	local c_m = os.date("%m")
	local c_t = os.date("%p")
	
	local h_1 = string.sub(c_h,1,1) or ""
	local h_2 = string.sub(c_h,2,2) or ""
	if c_h == "00" then
		--times with hour 00 (midnight, when not using twelve-hour will say "12" because the HEV suit has no voice line for "zero" or "oh" )
		self:PlaySound("suit",self._hev_number_vox["12"])
	elseif (h_2 == "0") or (h_1 == "1") then 
		self:PlaySound("suit",self._hev_number_vox[c_h] or self._hev_number_vox[h_2])
	else
		self:PlaySound("suit",self._hev_number_vox[h_1 .. "0")
		self:PlaySound("suit",self._hev_number_vox[h_2])
	end
	local m_1 = string.sub(c_m,1,1) or ""
	local m_2 = string.sub(c_m,2,2) or ""
	
	if m_1 ~= "0" then --times with minutes 00-09 are just not said, again because the HEV suit can't say "zero"
		self:PlaySound("suit",self._hev_number_vox[m_1 .. "0")
		self:PlaySound("suit",self._hev_number_vox[m_2])
	end
	if TWELVE_HOUR then 
		self:PlaySound("suit",self._hev_number_vox[os.date("%p")])
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
		local buffer = XAudio.Source:new(XAudio.Buffer:new(self._sounds_path .. sound_name .. self._AUDIO_FILE_FORMAT))
		if buffer then 
			self._audio_buffers[sound_name] = {
				disabled = true
			}
		end
		self._audio_buffers[sound_name] = {
			name = sound_name,
			looping = should_loop,
			buffer = buffer
		}
	end
	if snd and audio_source then
		if should_loop ~= nil then
			table.insert(self._audio_queue[source_name],{name = sound_name,buffer = self._audio_buffers[sound_name].buffer, should_loop = should_loop})
		else
			table.insert(self._audio_queue[source_name],self._audio_buffers[sound_name])
		end
	end
end

function HEVHUD:Update(t,dt)

	--Audio sources
	for source_name,audio_queue in pairs(self._audio_queue) do 
		local audio_source = self._audio_sources[source_name]
		if audio_source and audio_source:get_state() ~= 1 then 
			local snd_data = table.remove(audio_queue,1)
			if snd_data and type(snd_data) == "table" then
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

Hooks:Add("LocalizationManagerPostInit", "hevhud_addlocalization", function( loc )
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