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