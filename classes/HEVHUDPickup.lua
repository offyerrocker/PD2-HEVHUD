local HEVHUDPickup = blt_class(HEVHUDCore:require("classes/HEVHUDBase"))
local AnimateLibrary = HEVHUDCore:require("classes/AnimateLibrary")

function HEVHUDPickup:init(panel,settings,config,...)
	HEVHUDPickup.super.init(self,panel,settings,config,...)
	self._panel = panel:panel({
		name = "pickup",
		valign = "grow",
		halign = "grow",
		w = panel:w(),
		h = panel:h(),
		layer = 1,
		alpha = 1
	})
	
	--hud_ammo_pickup_enabled
	--hud_missioneq_enabled
	
	
	-- non-sequential; hold pickup panels
	self._anim_slots = {}
	self._anim_waiting = {}
	
	-- stores recent amounts by weapon slot, so that they can be combined
	self._pickup_aggregate_cache = {}
	
	self:setup(settings,config)
	self:recreate_hud()
end

function HEVHUDPickup:setup(settings,config,...)
	HEVHUDPickup.super.setup(self,settings,config,...)
	self._MAX_POPUP_SLOTS = config.Pickup.PICKUP_POPUP_SLOTS_MAX
end

function HEVHUDPickup:recreate_hud()
--	self._panel:clear()
end


function HEVHUDPickup:add_special_equipment(data)
	self:_add_special_equipment(data.id,data.amount,data.icon)
end

function HEVHUDPickup:set_special_equipment_amount(equipment_id,amount)
	self:_add_special_equipment(equipment_id,amount,nil)
end

function HEVHUDPickup:_add_special_equipment(id,amount,icon_id)
	if not id then return end
	
	local vars = self._config.Pickup
	local panel_name = "pickup_equipment_" .. tostring(id)
	local pickup = self._panel:child(panel_name)
	
	if self._settings.hud_ammo_pickup_aggregate_ammopickups then
		local t = TimerManager:main():time()
		local aggregate_cache = self._pickup_aggregate_cache[id]
		if aggregate_cache and aggregate_cache.t > t then -- if within refresh threshold
			aggregate_cache.t = t + vars.AMMO_AGGREGATE_TIMER_THRESHOLD
			local old_amount = aggregate_cache.amount 
			amount = amount + old_amount
			aggregate_cache.amount = amount
		else
			self._pickup_aggregate_cache[id] = {
				t = t + vars.AMMO_AGGREGATE_TIMER_THRESHOLD,
				amount = amount
			}
		end
		
		if alive(pickup) then
			for i,panel in pairs(self._anim_slots) do 
				if panel == pickup then
					pickup:child("amount_label"):set_text(tostring(amount))
					self:animate_pickup(pickup,i)
					break
				end
			end
			return
		end
	end
	
	
	if not amount or tostring(amount) == "1" then
		amount = ""
	end
	if alive(pickup) then 
		pickup:child("label"):set_text(amount)
	else
		local eq_td = tweak_data.equipments.specials[id]
		
		pickup = self._panel:panel({
			name = panel_name,
			w = vars.PICKUP_W,
			h = vars.PICKUP_H,
			x = 0,
			y = 0,
			valign = "grow",
			halign = "grow",
			layer = 2,
			visible = false
		})
		
		local amount_label = pickup:text({
			name = "amount_label",
			text = tostring(amount),
			align = vars.AMMO_AMOUNT_LABEL_ALIGN,
			vertical = vars.AMMO_AMOUNT_LABEL_VERTICAL,
			x = vars.AMMO_AMOUNT_LABEL_HOR_OFFSET,
			y = vars.AMMO_AMOUNT_LABEL_VER_OFFSET,
			valign = "grow",
			halign = "grow",
			font = vars.AMMO_AMOUNT_LABEL_FONT_NAME,
			font_size = vars.AMMO_AMOUNT_LABEL_FONT_SIZE,
			color = self._COLOR_YELLOW,
			blend_mode = vars.AMMO_AMOUNT_BLEND_MODE,
			layer = 2
		})
		
		local name_label = pickup:text({
			name = "name_label",
			text = managers.localization:text(eq_td.text_id),
			align = "left",
			vertical = vars.AMMO_AMOUNT_LABEL_VERTICAL,
			x = vars.WEAPON_ICON_X + pickup:w() - vars.WEAPON_ICON_W,
			y = vars.WEAPON_ICON_Y,
			valign = "grow",
			halign = "grow",
			font = vars.MISSION_EQ_LABEL_FONT_NAME,
			font_size = vars.AMMO_AMOUNT_LABEL_FONT_SIZE,
			color = self._COLOR_YELLOW,
			blend_mode = vars.AMMO_AMOUNT_BLEND_MODE,
			layer = 2
		})
		
		local texture,rect = tweak_data.hud_icons:get_icon_data(icon_id or eq_td.icon)
		local icon = pickup:bitmap({
			name = "icon",
			texture = texture,
			texture_rect = rect,
			x = vars.AMMO_ICON_X,
			y = vars.AMMO_ICON_Y,
			w = vars.MISSION_EQ_ICON_W,
			h = vars.MISSION_EQ_ICON_H,
			color = self._COLOR_YELLOW,
			valign = "grow",
			halign = "grow",
			layer = 3
		})
		
		--icon:animate(AnimateLibrary.animate_color_lerp,nil,vars.ANIM_MISSION_EQ_HIGHLIGHT_DURATION,self._COLOR_ORANGE,self._COLOR_YELLOW)
		
		
		self:register_popup(pickup)
	end
end


function HEVHUDPickup:animate_pickup(panel,i)
	local vars = self._config.Pickup
	panel:stop()
	panel:set_alpha(1)
	panel:set_right(vars.PICKUPS_X + self._panel:w())
	panel:set_y(vars.PICKUPS_Y + self._panel:h() - i * panel:h()) -- todo: shouldn't use panel:h() 
	panel:show()
	panel:animate(AnimateLibrary.animate_wait,vars.ANIM_PICKUP_HOLD_DURATION,AnimateLibrary.animate_alpha_lerp,function(o)
		self._anim_slots[i] = nil
		self:check_pickup_anim_slots()
		o:parent():remove(o)
	end,vars.ANIM_PICKUP_FADE_DURATION,nil,0)
end


function HEVHUDPickup:register_popup(panel,skip_wait)
	local found_slot = nil
	for i=1,self._MAX_POPUP_SLOTS do 
		if not (self._anim_slots[i] and alive(self._anim_slots[i])) then
			found_slot = i
			break
		end
	end
	if found_slot then
		self:_register_popup(panel,found_slot)
		return true
	elseif not skip_wait then
		table.insert(self._anim_waiting,#self._anim_waiting+1,panel)
	end
	return false
end

function HEVHUDPickup:_register_popup(panel,found_slot)
	self._anim_slots[found_slot] = panel
	self:animate_pickup(panel,found_slot)
end

function HEVHUDPickup:check_pickup_anim_slots()
	if #self._anim_waiting > 0 then
		if self:register_popup(self._anim_waiting[1],true) then
			table.remove(self._anim_waiting,1)
		end
	end
end

-- weapon slot is not the same as anim slot
function HEVHUDPickup:add_ammo_pickup(weapon_slot,amount,ammo_text,weapon_texture,weapon_rect)
	local vars = self._config.Pickup
	
	local ICONS_FONT_NAME = self._config.General.ICONS_FONT_NAME
	
	
	local panel_name = "pickup_ammo_" .. tostring(weapon_slot)
	local pickup = self._panel:child(panel_name)
	if self._settings.hud_ammo_pickup_aggregate_ammopickups then
		local t = TimerManager:main():time()
		local aggregate_cache = self._pickup_aggregate_cache[weapon_slot]
		if aggregate_cache and aggregate_cache.t > t then -- if within refresh threshold
			aggregate_cache.t = t + vars.AMMO_AGGREGATE_TIMER_THRESHOLD
			local old_amount = aggregate_cache.amount 
			amount = amount + old_amount
			aggregate_cache.amount = amount
		else
			self._pickup_aggregate_cache[weapon_slot] = {
				t = t + vars.AMMO_AGGREGATE_TIMER_THRESHOLD,
				amount = amount
			}
		end
		
		if alive(pickup) then
			for i,panel in pairs(self._anim_slots) do 
				if panel == pickup then
					local amount_label = pickup:child("amount_label")
					amount_label:set_text(tostring(amount))
					--local tx,ty,tw,th = amount_label:text_rect()
					--pickup:child("weapon_icon"):set_right(tx + vars.WEAPON_ICON_X)
					
					self:animate_pickup(pickup,i)
					break
				end
			end
			return
		end
	end
	
	pickup = self._panel:panel({
		name = panel_name,
		w = vars.PICKUP_W,
		h = vars.PICKUP_H,
		x = 0,
		y = 0,
		alpha = 1,
		visible = false,
		layer = 2
	})
	--[[
	self._BG_BOX_COLOR = HEVHUD.colordecimal_to_color(self._config.General.BG_BOX_COLOR)
	local BG_BOX_ALPHA = self._config.General.BG_BOX_ALPHA
	self._BG_BOX_ALPHA = BG_BOX_ALPHA
	local bgbox_panel_config = {alpha=BG_BOX_ALPHA,valign="grow",halign="grow"}
	local bgbox_item_config = {color=self._BG_BOX_COLOR}
	local bgbox = self.CreateBGBox(pickup,nil,nil,bgbox_panel_config,bgbox_item_config)
	--]]
	
	local amount_label = pickup:text({
		name = "amount_label",
		text = tostring(amount),
		align = vars.AMMO_AMOUNT_LABEL_ALIGN,
		vertical = vars.AMMO_AMOUNT_LABEL_VERTICAL,
		x = vars.AMMO_AMOUNT_LABEL_HOR_OFFSET,
		y = vars.AMMO_AMOUNT_LABEL_VER_OFFSET,
		valign = "grow",
		halign = "grow",
		font = vars.AMMO_AMOUNT_LABEL_FONT_NAME,
		font_size = vars.AMMO_AMOUNT_LABEL_FONT_SIZE,
		color = self._COLOR_YELLOW,
		blend_mode = vars.AMMO_AMOUNT_BLEND_MODE,
		layer = 2
	})
	
	local weapon_icon = pickup:bitmap({
		name = "weapon_icon",
		texture = weapon_texture,
		rect = weapon_rect,
		x = vars.WEAPON_ICON_X + pickup:w() - vars.WEAPON_ICON_W,
		y = vars.WEAPON_ICON_Y,
		w = vars.WEAPON_ICON_W,
		h = vars.WEAPON_ICON_H,
		color = self._COLOR_YELLOW,
		blend_mode = vars.WEAPON_ICON_BLEND_MODE,
		layer = 3
	})
	--local tx,ty,tw,th = amount_label:text_rect()
	--weapon_icon:set_right(tx + vars.WEAPON_ICON_X)
	
	local ammo_icon = pickup:text({
		name = "ammo_icon",
		text = ammo_text,
		x = vars.AMMO_ICON_X,
		y = vars.AMMO_ICON_Y,
		vertical = "center",
		align = "left",
		valign = "grow",
		halign = "grow",
		font = ICONS_FONT_NAME,
		font_size = vars.AMMO_ICON_FONT_SIZE,
		color = self._COLOR_YELLOW,
		blend_mode = vars.AMMO_ICON_BLEND_MODE,
		layer = 2
	})
	--ammo_icon:set_x(weapon_icon:left() + 0)
	
	
	self:register_popup(pickup)
end


return HEVHUDPickup