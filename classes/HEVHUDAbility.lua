local HEVHUDAbility = blt_class(HEVHUDCore:require("classes/HEVHUDBase"))
local AnimateLibrary = HEVHUDCore:require("classes/AnimateLibrary")


function HEVHUDAbility:init(panel,settings,config,...)
	HEVHUDAbility.super.init(self,panel,settings,config,...)
	local vars = config.Ability
	self._panel = panel:panel({
		name = "ability",
		valign = "center",
		halign = "center",
		w = panel:w(),
		h = panel:h(),
		layer = 1,
		alpha = 1,
		visible = true
	})
	self._panel:set_center(panel:w()/2,panel:h()/2)
	
	self:setup(settings,config)
	self:recreate_hud()
	
	self._num_ticks_current = 0
	self._anim_tick_threads = {}
end

function HEVHUDAbility:setup(settings,config,...)
	HEVHUDAbility.super.setup(self,settings,config,...)
	local vars = config.Ability
	self._NUM_TICKS = vars.ABILITY_BOX_TICKS
	self._num_ticks_current = self._NUM_TICKS
	self._LOW_THRESHOLD = vars.LOW_THRESHOLD
end

function HEVHUDAbility:recreate_hud()
	local vars = self._config.Ability
	
	local TICK_MARGIN = vars.TICK_MARGIN -- space between ticks
	local TICK_WIDTH = vars.TICK_WIDTH 
	local TICK_HEIGHT = vars.TICK_HEIGHT
	local TICK_VER_OFFSET = vars.TICK_VER_OFFSET 
	
	local ability_box_w = self._NUM_TICKS * (TICK_WIDTH + TICK_MARGIN) + vars.TICK_HOR_OFFSET + vars.TICK_HOR_OFFSET
	local ability_box_h = TICK_HEIGHT + TICK_VER_OFFSET + TICK_VER_OFFSET
	
	
	local ability_box = self._panel:panel({
		name = "ability_box",
		valign = "center",
		halign = "center",
		w = ability_box_w,
		h = ability_box_h,
		x = vars.ABILITY_BOX_X + (self._panel:w() - ability_box_w)/2,
		y = vars.ABILITY_BOX_Y + (self._panel:h() - ability_box_h)/2,
		layer = 2,
		visible = false
	})
	self._ability_box = ability_box
	
	self._bgbox = self.CreateBGBox(ability_box,{tile_size=6},self._BGBOX_PANEL_CONFIG,self._BGBOX_TILE_CONFIG)
	
	local tick_offset_x = (ability_box_w - (TICK_WIDTH + (self._NUM_TICKS - 1) * (TICK_WIDTH + TICK_MARGIN)))/2
	
	local tick_y = (ability_box:h() - TICK_HEIGHT)/2
	local tick_x = tick_offset_x
	
	for i=1,self._NUM_TICKS,1 do 
		tick_x = tick_offset_x + ((i - 1) * (TICK_MARGIN + TICK_WIDTH))
		
		--local tick_x = (ability_box:w() + -TICK_HOR_OFFSET + -TICK_HOR_OFFSET)
		local tick = ability_box:rect({
			name = tostring(i),
			w = TICK_WIDTH,
			h = TICK_HEIGHT,
			x = tick_x,
			y = nil,
			valign = "center",
			halign = "center",
			color = self._COLOR_YELLOW,
			layer = 3
		})
		--tick:set_center_x(tick_x)
		tick:set_y(tick_y)
		
		-- bg
		local bg = ability_box:rect({
			name = "bg_" .. tostring(i),
			w = TICK_WIDTH,
			h = TICK_HEIGHT,
			x = tick_x,
			y = nil,
			valign = "center",
			halign = "center",
			color = Color.black,
			alpha = 0.5,
			layer = 2
		})
--		bg:set_center_x(tick_x)
		bg:set_y(tick_y)
	end
	
	
end

function HEVHUDAbility:reset_ability_timer(is_empty)
	local color,alpha,blend_mode
	local TICK_EMPTY_ALPHA = 0
	local TICK_FULL_ALPHA = 1
	if is_empty then
		color = self._COLOR_RED
		alpha = TICK_EMPTY_ALPHA
		blend_mode = "add"
	else
		color = self._COLOR_YELLOW
		alpha = TICK_FULL_ALPHA
		blend_mode = "normal"
	end
	for i,anim_data in pairs(self._anim_tick_threads) do
		local tick = self._ability_box:child(tostring(i))
		anim_data.alpha_state = not is_empty
		anim_data.color_state = not is_empty
		if alive(tick) then
			tick:set_blend_mode(blend_mode)
			tick:stop()
			
			anim_data.alpha_thread = nil
			tick:set_alpha(alpha)
			
			anim_data.color_thread = nil
			tick:stop(anim_data.color_thread)
			
			tick:set_color(color)
		end
	end	
	
	self._num_ticks_current = self._NUM_TICKS
	
	self._ability_box:set_alpha(1)
end

function HEVHUDAbility:set_ability_timer(time_left,time_total)
	time_total = time_total or time_left
	self._ability_box:show()
	
	local duration = 0.5
	
	local function cb_done()
		self._ability_box:animate(AnimateLibrary.animate_alpha_lerp,function(o)
			o:hide()
			self:reset_ability_timer()
		end,duration,nil,0)
	end
	
	self._ability_box:stop()
	self._ability_box:animate(function(o,cb)
		local LOW_THRESHOLD = self._LOW_THRESHOLD
		local TICK_EMPTY_ALPHA = 0
		local TICK_FULL_ALPHA = 1
		local TEXT_COLOR_NONE = self._COLOR_RED
		local TEXT_COLOR_FULL = self._COLOR_YELLOW
		
		repeat 
			local ratio = time_left/time_total
			
			local ticks_current = math.floor(self._NUM_TICKS*ratio)
			if ticks_current ~= self._num_ticks_current then
				--self:upd_power_visible()
				--local descending = ticks_current < self._num_power_ticks_current
				local is_low = ratio < LOW_THRESHOLD
				
				for i=1,self._NUM_TICKS,1 do
					local tick = o:child(tostring(i))
					
					local anim_data = self._anim_tick_threads[i]
					if not anim_data then
						anim_data = {}
						self._anim_tick_threads[i] = anim_data
					end
					
					if i > ticks_current then -- set this tick to empty
						if anim_data.alpha_state ~= false then
							anim_data.alpha_state = false
							tick:set_blend_mode("add")
							if anim_data.alpha_thread then
								tick:stop(anim_data.alpha_thread)
								anim_data.alpha_thread = nil
							end
							
							anim_data.alpha_thread = tick:animate(AnimateLibrary.animate_alpha_lerp,function() anim_data.alpha_thread = nil end,duration,tick:alpha(),TICK_EMPTY_ALPHA)
						end
					else -- set this tick to full
						if anim_data.alpha_state ~= true then
							anim_data.alpha_state = true
							tick:set_blend_mode("normal")
							if anim_data.alpha_thread then
								tick:stop(anim_data.alpha_thread)
								anim_data.alpha_thread = nil
							end
							
							anim_data.alpha_thread = tick:animate(AnimateLibrary.animate_alpha_lerp,function() anim_data.alpha_thread = nil; end,duration,tick:alpha(),TICK_FULL_ALPHA)
						end
					end
					
					if anim_data.color_state ~= is_low then
						anim_data.color_state = is_low
						if anim_data.color_thread then
							tick:stop(anim_data.color_thread)
							anim_data.color_thread = nil
						end
						anim_data.color_thread = tick:animate(AnimateLibrary.animate_color_lerp,function() anim_data.color_thread = nil end,duration,tick:color(),is_low and TEXT_COLOR_NONE or TEXT_COLOR_FULL)
					end
				end
				self._num_ticks_current = ticks_current
			end
			time_left = time_left - coroutine.yield()
		until time_left <= 0
		
		if cb then
			cb(o)
		end
	end,cb_done)
end

return HEVHUDAbility