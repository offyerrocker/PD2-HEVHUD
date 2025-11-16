local HEVHUDVitals = blt_class(HEVHUDCore:require("classes/HEVHUDBase"))
local AnimateLibrary = HEVHUDCore:require("classes/AnimateLibrary")

function HEVHUDVitals:init(panel,settings,config,...)
	HEVHUDVitals.super.init(self,panel,settings,config,...)
	
	local vars = self._config.Vitals
	local vitals = panel:panel({
		name = "vitals",
		layer = 1,
		w = vars.VITALS_W,
		h = vars.VITALS_H,
		valign = vars.VITALS_VALIGN,
		halign = vars.VITALS_HALIGN
	})
	self._panel = vitals
	
	self._lowhealth_pulse_on = false
	self._sprint_on = false
	self._flashlight_on = false
	self._anim_power_tick_threads = {}
	
	self:setup()
end


function HEVHUDVitals:setup()

	local vars = self._config.Vitals
	self._LABEL_ALPHA_LOW = self._config.General.LABEL_ALPHA_LOW
	self._LABEL_ALPHA_HIGH = self._config.General.LABEL_ALPHA_HIGH
	self._POWER_TICK_ANIM_DURATION = vars.POWER_TICK_ANIM_DURATION
	self._POWER_RATIO_LOW_THRESHOLD = vars.POWER_RATIO_LOW_THRESHOLD
	self._TEXT_COLOR_FULL = HEVHUD.colordecimal_to_color(self._settings.color_hl2_yellow)
	self._TEXT_COLOR_HALF = HEVHUD.colordecimal_to_color(self._settings.color_hl2_orange)
	self._TEXT_COLOR_NONE = HEVHUD.colordecimal_to_color(self._settings.color_hl2_red)
	self._HEALTH_RATIO_LOW_THRESHOLD = vars.HEALTH_RATIO_LOW_THRESHOLD
	self._HEALTH_LOW_ANIM_SPEED = vars.HEALTH_LOW_ANIM_SPEED
	
	self._NUM_POWER_TICKS = vars.NUM_POWER_TICKS
	self._num_power_ticks_current = self._NUM_POWER_TICKS

	local scale = 1
	
	local BG_BOX_ALPHA = self._config.General.BG_BOX_ALPHA
	self._BG_BOX_COLOR = HEVHUD.colordecimal_to_color(self._config.General.BG_BOX_COLOR)
	local ICONS_FONT_NAME = self._config.General.ICONS_FONT_NAME
	local LABEL_ALPHA_LOW = self._LABEL_ALPHA_LOW
	local LABEL_ALPHA_HIGH = self._LABEL_ALPHA_HIGH
	
	
	local DEFAULT_COLOR = self._TEXT_COLOR_FULL
	
	local VITALS_FONT_NAME = vars.VITALS_FONT_NAME
	
	self._panel:clear() -- remove all children
	self._panel:configure({
		w = vars.VITALS_W,
		h = vars.VITALS_H,
		x = vars.VITALS_HOR_OFFSET,
		valign = vars.VITALS_VALIGN,
		halign = vars.VITALS_HALIGN
	})
	self._panel:set_bottom(self._panel:parent():h() + vars.VITALS_VER_OFFSET)

--HEALTH	
	local health = self._panel:panel({
		name = "health",
		layer = 3,
		w = vars.HEALTH_W,
		h = vars.HEALTH_H,
		x = vars.HEALTH_HOR_OFFSET,
		y = vars.HEALTH_VER_OFFSET + self._panel:h() - vars.HEALTH_H
	})
	self._health = health
	self._health_bgbox = self.CreateBGBox(health,nil,nil,{alpha=BG_BOX_ALPHA},{color=self._BG_BOX_COLOR}) -- blend_mode mul would be best but it doesn't seem to want to work
	
	local health_name = health:text({
		name = "health_name",
		text = managers.localization:text("hevhud_hud_health"),
		x = vars.TEXT_NAME_HOR_MARGIN,
		y = vars.VITALS_NAME_VER_OFFSET + health:h() - vars.TEXT_NAME_SIZE,
		font = vars.VITALS_FONT_NAME,
		font_size = vars.TEXT_NAME_SIZE,
		color = DEFAULT_COLOR,
		alpha = vars.TEXT_NAME_ALPHA,
		layer = 2
	})
	local health_label = health:text({
		name = "health_label",
		text = "690",
		align = "left",
		x = vars.LABEL_HOR_OFFSET,
		y = vars.LABEL_VER_OFFSET + health:h() - vars.TEXT_LABEL_SIZE, -- bottom() doesn't work as well since custom fonts don't seem to have correct font height detection
		--blend_mode = "add",
		font = ICONS_FONT_NAME,
		font_size = vars.TEXT_LABEL_SIZE,
		color = DEFAULT_COLOR,
		alpha = LABEL_ALPHA_HIGH,
		layer = 2
	})
	
--ARMOR
	local suit = self._panel:panel({
		name = "suit",
		layer = 3,
		w = vars.SUIT_W,
		h = vars.SUIT_H,
		x = health:right() + vars.SUIT_HOR_OFFSET,
		y = vars.SUIT_VER_OFFSET + self._panel:h() - vars.SUIT_H
	})
	self._suit = suit
	self._suit_bgbox = self.CreateBGBox(suit,nil,nil,{alpha=BG_BOX_ALPHA},{color=self._BG_BOX_COLOR})
	
	local suit_name = suit:text({
		name = "suit_name",
		text = managers.localization:text("hevhud_hud_suit"),
		x = vars.TEXT_NAME_HOR_MARGIN,
		y = vars.VITALS_NAME_VER_OFFSET + suit:h() - vars.TEXT_NAME_SIZE,
		font = vars.VITALS_FONT_NAME,
		font_size = vars.TEXT_NAME_SIZE,
		color = DEFAULT_COLOR,
		alpha = vars.TEXT_NAME_ALPHA,
		layer = 2
	})
	
	local suit_label = suit:text({
		name = "suit_label",
		text = "420",
		align = "left",
		x = vars.LABEL_HOR_OFFSET,
		y = vars.LABEL_VER_OFFSET + health:h() - vars.TEXT_LABEL_SIZE, -- bottom() doesn't work as well since custom fonts don't seem to have correct font height detection
		--blend_mode = "add",
		font = ICONS_FONT_NAME,
		font_size = vars.TEXT_LABEL_SIZE,
		color = DEFAULT_COLOR,
		alpha = LABEL_ALPHA_HIGH,
		layer = 2
	})
	
--POWER (sprint/flashlight)
	local power = self._panel:panel({
		name = "power",
		layer = 4,
		w = vars.POWER_W,
		h = vars.POWER_H,
		x = vars.POWER_HOR_OFFSET,
		y = health:y() - (vars.POWER_H + vars.POWER_VER_OFFSET)
	})
	self._power = power
	self._power_bgbox = self.CreateBGBox(power,nil,nil,{alpha=BG_BOX_ALPHA},{color=self._BG_BOX_COLOR})
	
	local power_name = power:text({
		name = "power_name",
		text = managers.localization:text("hevhud_hud_aux_power"),
		x = vars.TEXT_NAME_HOR_MARGIN,
		y = vars.POWER_NAME_VER_OFFSET,
		font = VITALS_FONT_NAME,
		font_size = vars.TEXT_NAME_SIZE,
		vertical = "top",
		align = "left",
		color = DEFAULT_COLOR,
		alpha = vars.TEXT_NAME_ALPHA,
		layer = 2
	})
	
	local TICK_WIDTH = vars.TICK_WIDTH 
	local TICK_HEIGHT = vars.TICK_HEIGHT
	local TICK_MARGIN = vars.TICK_MARGIN
	local TICK_HOR_OFFSET = vars.TICK_HOR_OFFSET
	local TICK_VER_OFFSET = vars.TICK_VER_OFFSET
	for i=1,vars.NUM_POWER_TICKS do
		power:rect({
			name = tostring(i),
			color = DEFAULT_COLOR,
			x = TICK_HOR_OFFSET + ((i - 1) * (TICK_MARGIN + TICK_WIDTH)),
			y = TICK_VER_OFFSET + power:h() - (TICK_HEIGHT + TICK_MARGIN),
			w = TICK_WIDTH,
			h = TICK_HEIGHT,
			valign = "top",
			halign = "left",
			alpha = LABEL_ALPHA_HIGH,
			layer = 2
		})
	end
	
	local flashlight_name = power:text({
		name = "flashlight_name",
		text = managers.localization:text("hevhud_hud_flashlight"),
		x = vars.TEXT_NAME_HOR_MARGIN,
		y = nil, -- dynamically positioned
		font = VITALS_FONT_NAME,
		font_size = vars.TEXT_NAME_SIZE,
		vertical = "top",
		align = "left",
		color = DEFAULT_COLOR,
		alpha = vars.TEXT_NAME_ALPHA,
--		visible = false,
		layer = 2
	})
	
	local sprint_name = power:text({
		name = "sprint_name",
		text = managers.localization:text("hevhud_hud_sprint"),
		x = vars.TEXT_NAME_HOR_MARGIN,
		y = nil, -- dynamically positioned
		font = VITALS_FONT_NAME,
		font_size = vars.TEXT_NAME_SIZE,
		vertical = "top",
		align = "left",
		color = DEFAULT_COLOR,
		alpha = vars.TEXT_NAME_ALPHA,
--		visible = false,
		layer = 2
	})
	
	
end

function HEVHUDVitals:set_low_health(state)
	if self._lowhealth_pulse_on ~= state then
		self._lowhealth_pulse_on = state
		for _,child in pairs(self._health_bgbox:children()) do 
			child:stop()
			if state then
				child:animate(AnimateLibrary.animate_color_oscillate,self._HEALTH_LOW_ANIM_SPEED,self._BG_BOX_COLOR,self._TEXT_COLOR_NONE)
			else
				child:set_color(self._BG_BOX_COLOR)
			end
		end
		
		if state then
			self._health:child("health_name"):set_color(self._TEXT_COLOR_NONE)
			self._health:child("health_label"):set_color(Color.red)
			self._health:child("health_label"):set_blend_mode("add")
		else
			self._health:child("health_name"):set_color(self._TEXT_COLOR_FULL)
			self._health:child("health_label"):set_color(self._TEXT_COLOR_FULL)
			self._health:child("health_label"):set_blend_mode("normal")
		end
		
	end
end

function HEVHUDVitals:set_sprint_on(state)
	if self._sprint_on ~= state then
		self._sprint_on = state
		self:upd_power_size()
	end
end

function HEVHUDVitals:set_flashlight_on(state)
	if self._flashlight_on ~= state then
		self._flashlight_on = state
		self:upd_power_size()
	end
end

--[[
function HEVHUDVitals:callback_anim_stop(i,thread_name,stop_thread)
	local data = self._anim_power_tick_threads[i]
	if alive(self._power) and data then
		local tick = self._power:child(tostring(i))
		if alive(tick) then
			if data[thread_name] then
				if stop_thread then
					tick:stop(data[thread_name])
				end
				data[thread_name] = nil
			end
		end
	end
end
--]]

function HEVHUDVitals:set_sprint_amount(current,total)
	local ratio = current/total
	local ticks_current = math.ceil(self._NUM_POWER_TICKS*ratio)
	local POWER_RATIO_LOW_THRESHOLD = self._POWER_RATIO_LOW_THRESHOLD
	if ticks_current ~= self._num_power_ticks_current then
		--local descending = ticks_current < self._num_power_ticks_current
		local to_color
		
		local low_stamina = false
		local TICK_EMPTY_ALPHA = self._TICK_EMPTY_ALPHA
		local TICK_FULL_ALPHA = self._TICK_FULL_ALPHA
		local TEXT_COLOR_NONE = self._TEXT_COLOR_NONE
		local TEXT_COLOR_FULL = self._TEXT_COLOR_FULL
		
		if ratio < POWER_RATIO_LOW_THRESHOLD then
			low_stamina = true
		else
			low_stamina = false
		end
		
		for i=1,self._NUM_POWER_TICKS,1 do
			local tick = self._power:child(tostring(i))
			
			local anim_data = self._anim_power_tick_threads[i]
			if not anim_data then
				anim_data = {}
				self._anim_power_tick_threads[i] = anim_data
			end
			
			if i >= ticks_current then -- set this tick to empty
				if anim_data.alpha_state ~= false then
					anim_data.alpha_state = true
					if anim_data.alpha_thread then
						tick:stop(anim_data.alpha_thread)
						anim_data.alpha_thread = nil
					end
					
					anim_data.alpha_thread = tick:animate(AnimateLibrary.animate_alpha_lerp,function() anim_data.alpha_thread = nil end,self._POWER_TICK_ANIM_DURATION,tick:alpha(),TICK_EMPTY_ALPHA)
				end
			else -- set this tick to full
				if anim_data.alpha_state ~= true then
					anim_data.alpha_state = false
					if anim_data.alpha_thread then
						tick:stop(anim_data.alpha_thread)
						anim_data.alpha_thread = nil
					end
					
					anim_data.alpha_thread = tick:animate(AnimateLibrary.animate_alpha_lerp,function() anim_data.alpha_thread = nil end,self._POWER_TICK_ANIM_DURATION,tick:alpha(),TICK_FULL_ALPHA)
				end
			end
			
			if anim_data.color_state ~= low_stamina then
				anim_data.color_state = low_stamina
				
				if anim_data.color_thread then
					tick:stop(anim_data.color_thread)
					anim_data.color_thread = nil
				end
				anim_data.color_thread = tick:animate(AnimateLibrary.animate_color_lerp,function() anim_data.color_thread = nil end,self._POWER_TICK_ANIM_DURATION,tick:color(),low_stamina and TEXT_COLOR_NONE or TEXT_COLOR_FULL)
			end
		end
		self._num_power_ticks_current = ticks_current
	end
end

function HEVHUD:upd_power_size()
	local h = 0
	if self._sprint_on then
		h = h + 0
	end
	if self._flashlight_on then
		h = h + 0
	end
	
end

function HEVHUDVitals:set_health(current,total,revives)
	self._health:child("health_label"):set_text(string.format("%i",current*tweak_data.gui.stats_present_multiplier))
	
	-- todo disable with berserker
	self:set_low_health(current/total <= self._HEALTH_RATIO_LOW_THRESHOLD)
end

function HEVHUDVitals:set_armor(current,total)
	self._suit:child("suit_label"):set_text(string.format("%i",math.round(current*tweak_data.gui.stats_present_multiplier)))
end

return HEVHUDVitals