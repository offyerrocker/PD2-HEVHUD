local HEVHUDHitDirection = blt_class(HEVHUDCore:require("classes/HEVHUDBase"))
local AnimateLibrary = HEVHUDCore:require("classes/AnimateLibrary")


function HEVHUDHitDirection:init(panel,settings,config,...)
	HEVHUDHitDirection.super.init(self,panel,settings,config,...)
	local vars = config.HitDirection
	self._panel = panel:panel({
		name = "hitdirection",
		valign = "center",
		halign = "center",
		w = panel:w(),
		h = panel:h(),
		layer = 1,
		alpha = 1,
		visible = settings.hud_hitdirection_enabled
	})
	self._panel:set_center(panel:w()/2,panel:h()/2)
	
	self:setup(settings,config)
	self:recreate_hud()
end

function HEVHUDHitDirection:recreate_hud()
	self:clear_hits()
end

function HEVHUDHitDirection:clear_hits()
	self._panel:clear()
end


function HEVHUDHitDirection:on_hit_direction(origin,damage_type,fixed_angle)
	local vars = self._config.HitDirection
	local texture_rect = nil
	
	local color
	if damage_type == HUDHitDirection.DAMAGE_TYPES.ARMOUR then
		color = Color(0,1,1)
	elseif damage_type == HUDHitDirection.DAMAGE_TYPES.VEHICLE then
		color = Color(1,1,1)
	else
		color = Color(1,0,0)
	end
	local hold_duration,fadeout_duration = vars.ANIM_HOLD_DURATION,vars.ANIM_FADEOUT_DURATION
	
	local hit = self._panel:bitmap({
		name = tostring(origin),
		texture = "guis/textures/hevhud_hitdirection",
		texture_rect = texture_rect,
		blend_mode = vars.HIT_BAR_BLEND_MODE,
		color = color,
		alpha = vars.HIT_BAR_ALPHA,
		layer = 3
	})
	
	local indicate_angle_distance = false
	
	local function done_cb(o)
		o:parent():remove(o)
	end
	
	hit:animate(self.animate_hit,done_cb,
		origin,
		fixed_angle,
		hold_duration,
		fadeout_duration,
		indicate_angle_distance
	)
end

function HEVHUDHitDirection.animate_hit(o,done_cb,origin,fixed_angle,hold_duration,fadeout_duration,do_animate_w)
	local t = 0
	local angle = 0
	local from_alpha = o:alpha()
	local to_alpha = 0
	local d_alpha = to_alpha - from_alpha
	local total_duration = hold_duration + fadeout_duration
	local bezier_values = {0,0,1,1}
	local player,camera_ext
	local target_vec = Vector3()
	local mvector3_set = mvector3.set
	local mvector3_sub = mvector3.subtract
	
	local base_w = o:w()
	
	local c_y = o:parent():h()/2
	local left_rect = {32,0,-32,256}
	local right_align_x = o:parent():w() - 100
	local left_align_x = 100
	
	local hor_state = false -- if true, on right side of screen; if false, requires flip
	
	local outofscreen_angle = 45
	local max_angle = 180 - outofscreen_angle
	
	while t < total_duration do 
		player = managers.player:player_unit()
		if player then
			camera_ext = player:camera()
			if camera_ext then
				mvector3_set(target_vec,camera_ext:position())
				mvector3_sub(target_vec,origin)
				angle = target_vec:to_polar_with_reference(camera_ext:forward(), math.UP).spin
				
				angle = ((angle) % 360) - 180
				
--				Console:SetTracker(string.format("angle %i",angle),1)
				
				if fixed_angle ~= nil then
					angle = fixed_angle
				end
				
				local abs_angle = math.abs(angle)
				
				if abs_angle > outofscreen_angle then -- todo fov setting
					o:show()
					if do_animate_w then
						o:set_w(base_w * (abs_angle - outofscreen_angle) / max_angle)
					end
					if angle < 0 then
						-- from left
						if hor_state then
							-- set to right-side orientation
							o:set_image("guis/textures/hevhud_hitdirection")
							hor_state = false
						end
						o:set_left(right_align_x)
					else
						if not hor_state then
							hor_state = true
							-- set to left-side orientation
							o:set_image("guis/textures/hevhud_hitdirection",unpack(left_rect))
						end
						o:set_right(left_align_x)
					end
					o:set_center_y(c_y)
				else
					o:hide()
				end
			end
		end
		t = t + coroutine.yield()
		
		if t > hold_duration then
			local lerp = (t - hold_duration) / fadeout_duration
			if lerp >= 1 then
				break
			end
			o:set_alpha(from_alpha + d_alpha * math.bezier({0,0,1,1},lerp))
		end
	end
	
	o:set_alpha(to_alpha)
	
	if done_cb then
		done_cb(o)
	end
	
end

return HEVHUDHitDirection