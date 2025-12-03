local HEVHUDObjectives = blt_class(HEVHUDCore:require("classes/HEVHUDBase")) -- for jokers
local AnimateLibrary = HEVHUDCore:require("classes/AnimateLibrary")


function HEVHUDObjectives:init(panel,settings,config,...)
	HEVHUDObjectives.super.init(self,panel,settings,config,...)
	self._panel = panel:panel({
		name = "objectives",
		valign = "grow",
		halign = "grow",
		w = panel:w(),
		h = panel:h(),
		layer = 1,
		alpha = 1
	})
	self._active_objective_id = nil
	self:setup()
end

function HEVHUDObjectives:setup()
--	self._panel:clear()
	local vars = self._config.Objectives
	
	self._objective_text_color = Color("ababab")
	self._objective_flash_color = Color("ffa000")
	self._TEXT_COLOR_FULL = HEVHUD.colordecimal_to_color(self._settings.color_hl2_yellow)
	self._TEXT_COLOR_HALF = HEVHUD.colordecimal_to_color(self._settings.color_hl2_orange)
	self._TEXT_COLOR_NONE = HEVHUD.colordecimal_to_color(self._settings.color_hl2_red)
	
	self._objective = self._panel:panel({
		name = "objective",
		x = vars.OBJECTIVES_X,
		y = vars.OBJECTIVES_Y,
		w = 1, --vars.OBJECTIVES_W,
		h = vars.OBJECTIVES_H,
		alpha = 1,
		layer = 3,
		visible = false
	})
	
	self._BG_BOX_COLOR = HEVHUD.colordecimal_to_color(self._config.General.BG_BOX_COLOR)
	
	self.CreateBGBox(self._objective,nil,nil,{alpha=self._config.General.BG_BOX_ALPHA,valign="grow",halign="grow",layer=1},{color=self._BG_BOX_COLOR})
	
	self._objective:text({
		name = "text",
		text = "",
		x = vars.OBJECTIVE_LABEL_X,
		y = vars.OBJECTIVE_LABEL_Y,
--		w = self._objective:w(),
--		h = self._objective:h(),
		font = vars.OBJECTIVE_LABEL_FONT_NAME,
		font_size = vars.OBJECTIVE_LABEL_FONT_SIZE,
		align = vars.OBJECTIVE_LABEL_ALIGN,
		vertical = vars.OBJECTIVE_LABEL_VERTICAL,
		color = self._objective_text_color,
		valign = "grow",
		halign = "grow",
--		wrap = true, -- word wrap does not seem to work with custom fonts; it reports a negative line height, causing 
		layer = 4
	})
	self._objective:text({
		name = "amount",
		text = "",
		x = vars.OBJECTIVE_AMOUNT_LABEL_X,
		y = vars.OBJECTIVE_AMOUNT_LABEL_Y,
--		w = self._objective:w(),
--		h = self._objective:h(),
		font = vars.OBJECTIVE_AMOUNT_LABEL_FONT_NAME,
		font_size = vars.OBJECTIVE_AMOUNT_LABEL_FONT_SIZE,
		align = vars.OBJECTIVE_AMOUNT_LABEL_ALIGN,
		vertical = vars.OBJECTIVE_AMOUNT_LABEL_VERTICAL,
		color = self._objective_text_color,
		valign = "grow",
		halign = "grow",
		layer = 4
	})
	
	
	
	local mission_equipment = self._panel:panel({
		name = "mission_equipment",
		x = vars.MISSION_EQUIPMENT_X,
		y = vars.MISSION_EQUIPMENT_Y,
		w = vars.MISSION_EQUIPMENT_W,
		h = vars.MISSION_EQUIPMENT_H,
		layer = 4
	})
--	mission_equipment:rect({color=Color.red,alpha=0.1})
	
	self._mission_equipment = mission_equipment
end


function HEVHUDObjectives:add_special_equipment(data)
	self:_add_special_equipment(data.id,data.amount,data.icon)
end

function HEVHUDObjectives:_add_special_equipment(id,amount,icon_id,skip_sort)	
	if not alive(self._mission_equipment) then
		error("Panel not alive!")
	end
	if not id then return end
	id = tostring(id)
	local equipment = self._mission_equipment:child(id)
	if not amount or tostring(amount) == "1" then
		amount = ""
	end
	if alive(equipment) then 
		equipment:child("label"):set_text(amount)
	else
		local vars = self._config.Objectives
		equipment = self._mission_equipment:panel({
			name = id,
			w = vars.MISSION_EQ_ICON_W,
			h = vars.MISSION_EQ_ICON_H,
--			x = -vars.MISSION_EQ_ICON_W,
			y = 0,
			valign = "grow",
			halign = "grow",
			layer = 2
		})
		
		if not icon_id then
			local eq_td = tweak_data.equipments[id]
			icon_id = eq_td.icon
		end
		
		local texture,rect = tweak_data.hud_icons:get_icon_data(icon_id)
		local icon = equipment:bitmap({
			name = "icon",
			texture = texture,
			texture_rect = rect,
			w = vars.MISSION_EQ_ICON_W,
			h = vars.MISSION_EQ_ICON_H,
			valign = "grow",
			halign = "grow",
			layer = 3
		})
		
		local label = equipment:text({
			name = "label",
			font = vars.MISSION_EQ_LABEL_FONT_NAME,
			font_size = vars.MISSION_EQ_LABEL_FONT_SIZE,
			text = amount,
			align = vars.MISSION_EQ_LABEL_ALIGN,
			vertical = vars.MISSION_EQ_LABEL_VERTICAL,
			valign = "grow",
			halign = "grow",
			layer = 4
		})
		icon:animate(AnimateLibrary.animate_color_lerp,nil,vars.ANIM_MISSION_EQ_HIGHLIGHT_DURATION,self._TEXT_COLOR_HALF,self._TEXT_COLOR_FULL)
		if not skip_sort then
			self:sort_special_equipment()
		end
	end
end


function HEVHUDObjectives:set_special_equipment_amount(equipment_id,amount)
	self:_add_special_equipment(equipment_id,amount,nil)
end

function HEVHUDObjectives:remove_special_equipment(equipment_id,skip_sort)
	local equipment = self._mission_equipment:child(equipment_id)
	if alive(equipment) then 
		self._mission_equipment:remove(equipment)
		if not skip_sort then
			self:sort_special_equipment()
		end
	end
end

function HEVHUDObjectives:sort_special_equipment(instant)
	local vars = self._config.Objectives
	local x = 0
	for i,child in ipairs(self._mission_equipment:children()) do 
		child:stop() -- todo stop only motion thread
		if instant then
			child:set_x(x)
		else
			child:animate(AnimateLibrary.animate_move_lerp,nil,vars.ANIM_SORT_MISSION_EQ_ICON_DURATION,x)
		end
		x = x + vars.MISSION_EQ_ICON_W + vars.MISSION_EQ_ICON_HOR_MARGIN
	end
end

function HEVHUDObjectives:activate_objective(data)
--	Print("activate")
--	logall(data)
	
	local cb_done
	
	if not self._objective:visible() then
		cb_done = callback(self,self,"_activate_objective",data)
	end
	
	self._active_objective_id = data.id

	local vars = self._config.Objectives
	local objective_w = vars.OBJECTIVES_W
	if data.text then
		local objective_text = self._objective:child("text")
		objective_text:set_text(data.text)
		local tx,ty,tw,th = objective_text:text_rect()
		objective_w = vars.OBJECTIVE_LABEL_X + tw + vars.OBJECTIVE_LABEL_HOR_MARGIN
	end
	
	self._objective:show()
	self._objective:stop()
	self._objective:animate(AnimateLibrary.animate_grow_w_left,cb_done,vars.ANIM_OBJECTIVE_PANEL_DURATION,nil,objective_w)
	
	if cb_done then
		return
	else
		self:_activate_objective(data)
	end
	
end

function HEVHUDObjectives:_activate_objective(data)
	local objective_text = self._objective:child("text")
	objective_text:stop()
	objective_text:animate(AnimateLibrary.animate_text_mission,nil,data.text,nil,self._objective_text_color,self._objective_flash_color,nil)
	
	if data.amount then
		self:update_amount_objective(data)
	else
		self._objective:child("amount"):hide()
		-- animate hide amount
	end
end

function HEVHUDObjectives:remind_objective(id)
--	Print("remind",id)
	
	-- flash the objective bgbox twice
	
end

function HEVHUDObjectives:complete_objective(data)
	if data.id == self._active_objective_id then
--		Print("complete")
--		logall(data)
	end
end

function HEVHUDObjectives:update_amount_objective(data)
--	Print("Update amount")
--	logall(data)
	local vars = self._config.Objectives
	local objective_amount = self._objective:child("amount")
	objective_amount:show()
	objective_amount:stop()
	objective_amount:animate(AnimateLibrary.animate_wait,vars.ANIM_OBJECTIVE_AMOUNT_ACTIVATE_DELAY,AnimateLibrary.animate_text_mission,nil,string.format("%i/%i",data.current_amount or 0,data.amount),vars.ANIM_OBJECTIVE_AMOUNT_UPDATE_DURATION,self._objective_text_color,self._objective_flash_color,nil)
end



return HEVHUDObjectives