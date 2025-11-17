local HEVHUDTeammates = blt_class(HEVHUDCore:require("classes/HEVHUDBase")) -- manager for all teammates
local AnimateLibrary = HEVHUDCore:require("classes/AnimateLibrary")

local TeammatePanel = blt_class() -- individual teammate


function HEVHUDTeammates:init(panel,settings,config,...)
	HEVHUDTeammates.super.init(self,panel,settings,config,...)
	
	self._panel = panel:panel({
		name = "teammate"
	})
	
	self._teammates = {}
	
	self:setup()
end

function HEVHUDTeammates:setup()
	-- set vars
	
	local num_teammates = 3 -- not including main player
	
	for i=1,num_teammates do 
		self:create_teammate(i)
	end
	
	
	
	
end


function HEVHUDTeammates:arrange_teammates()
	for _,child in pairs(self._teammates) do
		-- todo sort by peer num or join order?
		-- arrange child
	end
end

function HEVHUDTeammates:hide_teammate(i)
	if self._teammates[i] then
		self._teammates[i]:hide()
	end
end

function HEVHUDTeammates:show_teammate(i)
	if self._teammates[i] then
		self._teammates[i]:show()
	end
end

function HEVHUDTeammates:remove_teammate(i)
	if self._teammates[i] then 
		self._teammates[i]:pre_destroy()
		self._teammates[i] = nil
	end
end

function HEVHUDTeammates:create_teammate(i)
	self:remove_teammate(i)
	self._teammates[i] = TeammatePanel:new(i,self._panel,self._config,self._settings)
end


function TeammatePanel:init(i,parent_panel,config,settings)
	
	
	self._parent_panel = parent_panel
	local vars = config.Teammates
	
	self._TEXT_COLOR_FULL = HEVHUD.colordecimal_to_color(settings.color_hl2_yellow)
	self._peer_id = nil
	self._peer_color = self._TEXT_COLOR_FULL
	
	
	local panel = parent_panel:panel({
		name = tostring(i),
		w = vars.TEAMMATE_W,
		h = vars.TEAMMATE_H,
		layer = 1
	})
	self._panel = panel
	
	local name = panel:text({
		name = "name",
		text = "futurecar",
		font = vars.TEAMMATE_NAMEPLATE_FONT_NAME,
		font_size = vars.TEAMMATE_NAMEPLATE_FONT_SIZE,
		x = vars.TEAMMATE_NAMEPLATE_X,
		y = vars.TEAMMATE_NAMEPLATE_Y,
		valign = "grow",
		halign = "grow",
		color = self._TEXT_COLOR_FULL
		layer = 3
	})
	
	local vitals_icon = panel:bitmap({
		name = "vitals_icon",
		texture = "",
		texture_rect = nil,
		w = vars.TEAMMATE_VITALS_ICON_W,
		h = vars.TEAMMATE_VITALS_ICON_H,
		x = vars.TEAMMATE_VITALS_ICON_X,
		y = vars.TEAMMATE_VITALS_ICON_Y,
		color = self._TEXT_COLOR_FULL,
		layer = 2
	})
	
	local ammo_icon = panel:bitmap({
		name = "ammo_icon",
		texture = "",
		texture_rect = nil,
		w = vars.TEAMMATE_AMMO_ICON_W,
		h = vars.TEAMMATE_AMMO_ICON_H,
		x = vars.TEAMMATE_AMMO_ICON_X,
		y = vars.TEAMMATE_AMMO_ICON_Y,
		color = self._TEXT_COLOR_FULL,
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

function TeammatePanel:show()
	self._panel:show()
end

function TeammatePanel:hide()
	self._panel:hide()
end

function TeammatePanel:set_name(name)
	self._panel:child("name"):set_text(name)
end

function TeammatePanel:set_health(data)
	self:_set_revives(data.revives)
end
function TeammatePanel:set_armor(data)
end
function TeammatePanel:_set_revives(revives)
end

function TeammatePanel:set_peer_id(peer_id)
	self._peer_id = peer_id
	self:set_peer_color(tweak_data.chat_colors[peer_id])
end

function TeammatePanel:set_peer_color(color)
	if color then
		self._peer_color = color
		self._panel:child("name"):set_color(color)
	end
end



function TeammatePanel:pre_destroy()
	if alive(self._panel) then
		self._parent_panel:remove(self._panel)
	end
	self._parent_panel = nil
	self._panel = nil
end


return HEVHUDTeammates