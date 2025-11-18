local HEVHUDTeammate = blt_class(HEVHUDCore:require("classes/HEVHUDBase")) -- manager for all teammates
local AnimateLibrary = HEVHUDCore:require("classes/AnimateLibrary")


function HEVHUDTeammate:init(panel,settings,config,i,...)
	HEVHUDTeammate.super.init(self,panel,settings,config,i,...)
	local vars = config.Teammate
	self._panel = panel:panel({
		name = string.format("teammate_%i",i),
		w = vars.TEAMMATE_W,
		h = vars.TEAMMATE_H,
		layer = 1
	})
--	self._panel:rect({color=Color.red,alpha=0.1,name="debug"})
	self._id = i
	
	self:setup()
end

function HEVHUDTeammate:setup()
	-- set vars
	local vars = self._config.Teammate
	self._panel:set_size(vars.TEAMMATE_W,vars.TEAMMATE_H)
	self._TEXT_COLOR_FULL = HEVHUD.colordecimal_to_color(self._settings.color_hl2_yellow)
	self._TEXT_COLOR_NONE = HEVHUD.colordecimal_to_color(self._settings.color_hl2_red)
	
	self._peer_id = nil
	self._peer_color = self._TEXT_COLOR_FULL
	self._ai = nil
	local panel = self._panel
	local BG_BOX_ALPHA = self._config.General.BG_BOX_ALPHA
	self._BG_BOX_COLOR = HEVHUD.colordecimal_to_color(self._config.General.BG_BOX_COLOR)
	self._bgbox = self.CreateBGBox(panel,nil,nil,{alpha=BG_BOX_ALPHA,valign="grow",halign="grow"},{color=self._BG_BOX_COLOR})
	
	
	local name = panel:text({
		name = "name",
		text = "futurecar",
		font = vars.TEAMMATE_NAMEPLATE_FONT_NAME,
		font_size = vars.TEAMMATE_NAMEPLATE_FONT_SIZE,
		x = vars.TEAMMATE_NAMEPLATE_X,
		y = vars.TEAMMATE_NAMEPLATE_Y,
		valign = "grow",
		halign = "grow",
		color = self._TEXT_COLOR_FULL,
		layer = 3
	})
	
	local vitals_icon_fill_texture,vitals_icon_fill_rect = HEVHUD:GetIconData("teammate_vitals_fill")
	local vitals_icon_line_texture,vitals_icon_line_rect = HEVHUD:GetIconData("teammate_vitals_line")
	
	local vitals_icon_fill = panel:bitmap({
		name = "vitals_icon_fill",
		texture = vitals_icon_fill_texture,
		texture_rect = vitals_icon_fill_rect,
		w = vars.TEAMMATE_VITALS_ICON_W,
		h = vars.TEAMMATE_VITALS_ICON_H,
		x = vars.TEAMMATE_VITALS_ICON_X,
		y = vars.TEAMMATE_VITALS_ICON_Y,
		color = self._TEXT_COLOR_FULL,
		valign = "grow",
		halign = "grow",
		layer = 2
	})
	local vitals_icon_line = panel:bitmap({
		name = "vitals_icon_line",
		texture = vitals_icon_line_texture,
		texture_rect = vitals_icon_line_rect,
		w = vars.TEAMMATE_VITALS_ICON_W,
		h = vars.TEAMMATE_VITALS_ICON_H,
		x = vars.TEAMMATE_VITALS_ICON_X,
		y = vars.TEAMMATE_VITALS_ICON_Y,
		color = self._TEXT_COLOR_FULL,
		valign = "grow",
		halign = "grow",
		layer = 2
	})
	
	local triangle_icon_texture,triangle_icon_rect = HEVHUD:GetIconData("triangle_line")
	local ammo_icon_texture,ammo_icon_rect = HEVHUD:GetIconData("teammate_ammo")
	local ammo_icon = panel:bitmap({
		name = "ammo_icon",
		texture = ammo_icon_texture,
		texture_rect = ammo_icon_rect,
		w = vars.TEAMMATE_AMMO_ICON_W,
		h = vars.TEAMMATE_AMMO_ICON_H,
		x = vars.TEAMMATE_AMMO_ICON_X,
		y = vars.TEAMMATE_AMMO_ICON_Y,
		color = self._TEXT_COLOR_FULL,
		layer = 3
	})
	
	local triangle_icon = panel:bitmap({
		name = "triangle_icon",
		texture = triangle_icon_texture,
		texture_rect = triangle_icon_rect,
		w = vars.TEAMMATE_AMMO_ICON_W,
		h = vars.TEAMMATE_AMMO_ICON_H,
		x = vars.TEAMMATE_AMMO_ICON_X,
		y = vars.TEAMMATE_AMMO_ICON_Y,
		color = self._TEXT_COLOR_FULL,
		blend_mode = "add",
		layer = 2
	})
	
	
	local mission_equipment_bar = panel:panel({
		name = "mission_equipment_bar",
		w = TEAMMATE_MISSION_EQ_W,
		h = TEAMMATE_MISSION_EQ_H,
		x = TEAMMATE_MISSION_EQ_X,
		y = TEAMMATE_MISSION_EQ_Y,
		color = self._TEXT_COLOR_FULL,
		layer = 2
	})
	
	
	
	-- vitals icon (w/ visual shield/health/revives indicator)
	-- weapons ammo visual indicator (conditional)
	-- grenades, ties
	-- deployables
	-- mission equipment
	
	
	
	
	
	
	
	
	
end

function HEVHUDTeammate:set_name(name)
	self._panel:child("name"):set_text(name)
end

function HEVHUDTeammate:show()
	self._panel:show()
end

function HEVHUDTeammate:hide()
	self._panel:hide()
end

function HEVHUDTeammate:set_health(data)
	self:_set_revives(data.revives)
end

function HEVHUDTeammate:set_armor(data)
end

function HEVHUDTeammate:_set_revives(revives)
end

function HEVHUDTeammate:set_ai(state)
	self._ai = state
end

function HEVHUDTeammate:set_peer_id(peer_id)
	self._peer_id = peer_id
	self:set_peer_color(tweak_data.chat_colors[peer_id])
end

function HEVHUDTeammate:set_peer_color(color)
	if color then
		self._peer_color = color
		self._panel:child("name"):set_color(color)
	end
end

return HEVHUDTeammate





--[[
function HEVHUDTeammate:arrange_teammates()
	for _,child in pairs(self._teammates) do
		-- todo sort by peer num or join order?
		-- arrange child
	end
end
function HEVHUDTeammate:hide_teammate(i)
	if self._teammates[i] then
		self._teammates[i]:hide()
	end
end

function HEVHUDTeammate:show_teammate(i)
	if self._teammates[i] then
		self._teammates[i]:show()
	end
end

function HEVHUDTeammate:remove_teammate(i)
	if self._teammates[i] then 
		self._teammates[i]:pre_destroy()
		self._teammates[i] = nil
	end
end

function HEVHUDTeammate:create_teammate(i)
	self:remove_teammate(i)
	self._teammates[i] = HEVHUDTeammate:new(i,self._panel,self._config,self._settings)
end
--]]
