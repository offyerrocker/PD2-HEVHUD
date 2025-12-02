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
	
	self._TEXT_COLOR_FULL = HEVHUD.colordecimal_to_color(self._settings.color_hl2_yellow)
	self._TEXT_COLOR_HALF = HEVHUD.colordecimal_to_color(self._settings.color_hl2_orange)
	self._TEXT_COLOR_NONE = HEVHUD.colordecimal_to_color(self._settings.color_hl2_red)
	
	self._objective = self._panel:panel({
		name = "objective",
		x = vars.OBJECTIVES_X,
		y = vars.OBJECTIVES_Y,
		w = vars.OBJECTIVES_W,
		h = vars.OBJECTIVES_H,
		alpha = 1,
		layer = 3,
		visible = false
	})
	
	local BG_BOX_ALPHA = self._config.General.BG_BOX_ALPHA
	self._BG_BOX_COLOR = HEVHUD.colordecimal_to_color(self._config.General.BG_BOX_COLOR)
	
	self.CreateBGBox(self._objective,nil,nil,{alpha=BG_BOX_ALPHA,valign="grow",halign="grow",layer=1},{color=self._BG_BOX_COLOR})
	
	self._objective:text({
		name = "text",
		text = "",
		x = vars.OBJECTIVE_LABEL_X,
		y = vars.OBJECTIVE_LABEL_Y,
		font = vars.OBJECTIVE_LABEL_FONT_NAME,
		font_size = vars.OBJECTIVE_LABEL_FONT_SIZE,
		align = vars.OBJECTIVE_LABEL_ALIGN,
		vertical = vars.OBJECTIVE_LABEL_VERTICAL,
		color = self._TEXT_COLOR_FULL,
		valign = "grow",
		halign = "grow",
		wrap = true,
		layer = 4
	})
	self._objective:text({
		name = "amount",
		text = "",
		x = vars.OBJECTIVE_AMOUNT_LABEL_X,
		y = vars.OBJECTIVE_AMOUNT_LABEL_Y,
		font = vars.OBJECTIVE_AMOUNT_LABEL_FONT_NAME,
		font_size = vars.OBJECTIVE_AMOUNT_LABEL_FONT_SIZE,
		align = vars.OBJECTIVE_AMOUNT_LABEL_ALIGN,
		vertical = vars.OBJECTIVE_AMOUNT_LABEL_VERTICAL,
		color = self._TEXT_COLOR_FULL,
		valign = "grow",
		halign = "grow",
		layer = 4
	})
end

function HEVHUDObjectives:activate_objective(data)
	self._objective:show()
	self._active_objective_id = data.id
	self._objective:child("text"):set_text(data.text)
	self._objective:child("amount"):hide()
	
	if data.amount then
		self:update_amount_objective(data)
	else
		-- animate hide amount
	end
end

function HEVHUDObjectives:remind_objective(id)
	
end

function HEVHUDObjectives:complete_objective(data)
	if data.id == self._active_objective_id then
		self._objective:hide()
	end
end

function HEVHUDObjectives:update_amount_objective(data)
	local text = self._objective:child("amount")
	text:show()
	text:set_text(string.format("%i/%i",data.current_amount or 0,data.amount))
end



return HEVHUDObjectives