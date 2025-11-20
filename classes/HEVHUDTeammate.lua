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
	self._TEXT_COLOR_HALF = HEVHUD.colordecimal_to_color(self._settings.color_hl2_orange)
	self._TEXT_COLOR_NONE = HEVHUD.colordecimal_to_color(self._settings.color_hl2_red)
	
	self._peer_id = nil
	self._peer_color = self._TEXT_COLOR_FULL
	self._ai = nil
	local panel = self._panel
	local BG_BOX_ALPHA = self._config.General.BG_BOX_ALPHA
	self._BG_BOX_COLOR = HEVHUD.colordecimal_to_color(self._config.General.BG_BOX_COLOR)
	self._bgbox = self.CreateBGBox(panel,nil,nil,{alpha=BG_BOX_ALPHA,valign="grow",halign="grow"},{color=self._BG_BOX_COLOR})

	self._TEAMMATE_VITALS_HEALTH_LOW_THRESHOLD = vars.TEAMMATE_VITALS_HEALTH_LOW_THRESHOLD
	self._TEAMMATE_VITALS_HEALTH_EMPTY_THRESHOLD = vars.TEAMMATE_VITALS_HEALTH_EMPTY_THRESHOLD
	self._TEAMMATE_VITALS_REVIVES_LOW_THRESHOLD = vars.TEAMMATE_VITALS_REVIVES_LOW_THRESHOLD
	self._TEAMMATE_VITALS_REVIVES_EMPTY_THRESHOLD = vars.TEAMMATE_VITALS_REVIVES_EMPTY_THRESHOLD
	self._MISSION_EQ_ICON_W = vars.MISSION_EQ_ICON_W
	self._MISSION_EQ_ICON_H = vars.MISSION_EQ_ICON_H
	self._MISSION_EQ_ICON_HOR_MARGIN = vars.MISSION_EQ_ICON_HOR_MARGIN
	self._MISSION_EQ_AMOUNT_VERTICAL = vars.MISSION_EQ_AMOUNT_VERTICAL
	self._MISSION_EQ_AMOUNT_ALIGN = vars.MISSION_EQ_AMOUNT_ALIGN
	self._ANIM_SORT_MISSION_EQ_ICON_DURATION = vars.ANIM_SORT_MISSION_EQ_ICON_DURATION
	self._TEAMMATE_MISSION_EQ_LABEL_FONT_SIZE = vars. TEAMMATE_MISSION_EQ_LABEL_FONT_SIZE
	self._TEAMMATE_MISSION_EQ_LABEL_FONT_NAME = vars.TEAMMATE_MISSION_EQ_LABEL_FONT_NAME
	
	
	local status = panel:panel({
		name = "status",
		w = vars.STATUS_ICON_W,
		h = vars.STATUS_ICON_H,
		x = vars.STATUS_ICON_X,
		y = vars.STATUS_ICON_Y,
		layer = 3
	})
	local state_icon_texture,state_icon_rect = HEVHUD:GetIconData("triangle")
	status:bitmap({
		name = "status_icon",
		texture = state_icon_texture,
		texture_rect = state_icon_rect,
		w = status:w(),
		h = status:h(),
		halign = "grow",
		valign = "grow",
		layer = 3
	})
	
	local ammo = status:panel({
		name = "ammo",
		w = status:w(),
		h = status:h(),
		halign = "grow",
		valign = "grow",
		layer = 3
	})
	local ammo_icon_texture,ammo_icon_rect = HEVHUD:GetIconData("teammate_ammo")
	ammo_icon = ammo:bitmap({
		name = "ammo_icon",
		texture = ammo_icon_texture,
		texture_rect = ammo_icon_rect,
		w = ammo:w(),
		h = ammo:h(),
		halign = "grow",
		valign = "grow",
		color = self._TEXT_COLOR_FULL,
		layer = 3
	})
	local triangle_icon_texture,triangle_icon_rect = HEVHUD:GetIconData("triangle_line")
	ammo:bitmap({
		name = "triangle_icon",
		texture = triangle_icon_texture,
		texture_rect = triangle_icon_rect,
		w = ammo:w(),
		h = ammo:h(),
		halign = "grow",
		valign = "grow",
		color = self._TEXT_COLOR_NONE,
		blend_mode = "add",
		layer = 2
	})
	
	local vitals = panel:panel({
		name = "vitals",
		w = vars.VITALS_ICON_W,
		h = vars.VITALS_ICON_H,
		x = vars.VITALS_ICON_X,
		y = vars.VITALS_ICON_Y,
		layer = 3
	})
	
	local vitals_icon_fill_texture,vitals_icon_fill_rect = HEVHUD:GetIconData("teammate_vitals_fill")
	local vitals_icon_line_texture,vitals_icon_line_rect = HEVHUD:GetIconData("teammate_vitals_line")
	vitals:bitmap({
		name = "vitals_icon_fill",
		texture = vitals_icon_fill_texture,
		texture_rect = vitals_icon_fill_rect,
		w = vitals:w(),
		h = vitals:h(),
		color = self._TEXT_COLOR_FULL,
		valign = "grow",
		halign = "grow",
		layer = 2
	})
	vitals:bitmap({
		name = "vitals_icon_line",
		texture = vitals_icon_line_texture,
		texture_rect = vitals_icon_line_rect,
		w = vitals:w(),
		h = vitals:h(),
		color = self._TEXT_COLOR_FULL,
		valign = "grow",
		halign = "grow",
		layer = 2
	})
	
	panel:text({
		name = "name",
		text = "futurecar",
		font = vars.NAMEPLATE_FONT_NAME,
		font_size = vars.NAMEPLATE_FONT_SIZE,
		x = vars.NAMEPLATE_X,
		y = vars.NAMEPLATE_Y,
		valign = "grow",
		halign = "grow",
		color = self._TEXT_COLOR_FULL,
		layer = 3
	})
	
	local deployable = panel:panel({
		name = "deployable",
		w = vars.DEPLOYABLE_ICON_W,
		h = vars.DEPLOYABLE_ICON_H,
		x = vars.DEPLOYABLE_ICON_X,
		y = vars.DEPLOYABLE_ICON_Y,
		layer = 3
	})
	deployable:texture({
		name = "icon",
		w = deployable:w(),
		w = deployable:h(),
		valign = "grow",
		halign = "grow",
		layer = 3
	})
	deployable:text({
		name = "amount",
		x = vars.DEPLOYABLE_LABEL_X,
		y = vars.DEPLOYABLE_LABEL_Y,
		font = vars.DEPLOYABLE_LABEL_FONT_NAME,
		font_size = vars.DEPLOYABLE_LABEL_FONT_SIZE,
		text = "14",
		align = vars.DEPLOYABLE_LABEL_ALIGN,
		vertical = vars.DEPLOYABLE_LABEL_VERTICAL,
	})
	
	
	local grenades_icon_texture,grenades_icon_rect = tweak_data.hud_icons:get_icon_data("frag_grenade")
	local grenades = panel:panel({
		name = "grenades",
		x = vars.GRENADES_ICON_X,
		y = vars.GRENADES_ICON_Y,
		w = vars.GRENADES_ICON_W,
		h = vars.GRENADES_ICON_H,
		color = self._TEXT_COLOR_FULL,
		valign = "grow",
		halign = "grow",
		layer = 2
	})
	grenades:bitmap({
		name = "icon",
		texture = grenades_icon_texture,
		texture_rect = grenades_icon_rect,
		w = grenades:w(),
		h = grenades:h(),
		color = self._TEXT_COLOR_FULL,
		valign = "grow",
		halign = "grow",
		layer = 2
	})
	grenades:text({
		name = "amount",
		x = vars.GRENADES_LABEL_X,
		y = vars.GRENADES_LABEL_Y,
		font = vars.GRENADES_LABEL_FONT_NAME,
		font_size = vars.GRENADES_LABEL_FONT_SIZE,
		text = "14",
		align = vars.GRENADES_LABEL_ALIGN,
		vertical = vars.GRENADES_LABEL_VERTICAL,
	})
	
	
	local zipties_icon_texture,zipties_icon_rect = tweak_data.hud_icons:get_icon_data("equipment_cable_ties")
	local zipties = panel:panel({
		name = "zipties",
		x = vars.ZIPTIES_ICON_X,
		y = vars.ZIPTIES_ICON_Y,
		w = vars.ZIPTIES_ICON_W,
		h = vars.ZIPTIES_ICON_H,
		color = self._TEXT_COLOR_FULL,
		valign = "grow",
		halign = "grow",
		layer = 2
	})
	zipties:bitmap({
		name = "icon",
		texture = zipties_icon_texture,
		texture_rect = zipties_icon_rect,
		w = zipties:w(),
		h = zipties:h(),
		color = self._TEXT_COLOR_FULL,
		valign = "grow",
		halign = "grow",
		layer = 2
	})
	zipties:text({
		name = "amount",
		x = vars.ZIPTIES_LABEL_X,
		y = vars.ZIPTIES_LABEL_Y,
		font = vars.ZIPTIES_LABEL_FONT_NAME,
		font_size = vars.ZIPTIES_LABEL_FONT_SIZE,
		text = "14",
		align = vars.ZIPTIES_LABEL_ALIGN,
		vertical = vars.ZIPTIES_LABEL_VERTICAL,
	})
	
	
	local carry_icon_texture,carry_icon_rect = tweak_data.hud_icons:get_icon_data("pd2_loot")
	local carry = panel:panel({
		name = "carry",
		x = vars.CARRY_ICON_X,
		y = vars.CARRY_ICON_Y,
		w = vars.CARRY_ICON_W,
		h = vars.CARRY_ICON_H,
		color = self._TEXT_COLOR_FULL,
		valign = "grow",
		halign = "grow",
		layer = 2
	})
	carry:bitmap({
		name = "icon",
		texture = carry_icon_texture,
		texture_rect = carry_icon_rect,
		w = carry:w(),
		h = carry:h(),
		color = self._TEXT_COLOR_FULL,
		valign = "grow",
		halign = "grow",
		layer = 2
	})
	
	
	--[[
	all vars standardized to eqbox

-- slight layering of equipment icons?
-- or scrolling bar?
	
	
[X][v]NAMEHERE
[1][G][Z]
[B][M]
	
	--]]
	
	
	local mission_equipment_bar = panel:panel({
		name = "mission_equipment_bar",
		w = vars.MISSION_EQ_W,
		h = vars.MISSION_EQ_H,
		x = vars.MISSION_EQ_X,
		y = vars.MISSION_EQ_Y,
		color = self._TEXT_COLOR_FULL,
		layer = 2
	})
	self._mission_equipment = mission_equipment_bar
	
	
	-- vitals icon (w/ visual shield/health/revives indicator)
	-- weapons ammo visual indicator (conditional)
	-- grenades, ties
	-- deployables
	-- mission equipment
	
end

function HEVHUDTeammate:add_special_equipment(id,amount,skip_sort)
	
	local equipment = self._mission_equipment:child(id)
	if not amount or tostring(amount) == "1" then
		amount = ""
	end
	if alive(equipment) then 
		equipment:child("amount"):set_text(amount)
	else
		--local num_eq = #self._mission_equipment:children()
		equipment = self._mission_equipment:panel({
			name = id,
			w = self._MISSION_EQ_ICON_W,
			h = self._MISSION_EQ_ICON_H,
			x = -self._MISSION_EQ_ICON_W,
			y = 0,
			layer = 2
		})
		
		local eq_td = tweak_data.equipments[id]
		local texture,rect = tweak_data.hud_icons:get_icon_data(eq_td.icon)
		local icon = equipment:bitmap({
			name = "icon",
			texture = texture,
			texture_rect = rect,
			w = self._MISSION_EQ_ICON_W,
			h = self._MISSION_EQ_ICON_H,
			layer = 3
		})
		
		local amount = equipment:text({
			name = "amount",
			font = self._TEAMMATE_MISSION_EQ_LABEL_FONT_NAME,
			font_size = self._TEAMMATE_MISSION_EQ_LABEL_FONT_SIZE,
			text = amount,
			align = self._MISSION_EQ_AMOUNT_ALIGN,
			vertical = self._MISSION_EQ_AMOUNT_VERTICAL,
			layer = 4
		})
		if not skip_sort then
			self:sort_special_equipment()
		end
	end
end

function HEVHUDTeammate:remove_special_equipment(id,skip_sort)
	local equipment = self._mission_equipment:child(id)
	if alive(equipment) then 
		self._mission_equipment:remove(equipment)
		if not skip_sort then
			self:sort_special_equipment()
		end
	end
end

--
function HEVHUDTeammate:sort_special_equipment(instant)
	-- todo sort options?
	-- todo ensure reliable sort
	local x = 0
	for i,child in ipairs(self._mission_equipment:children()) do 
		child:stop() -- todo stop only motion thread
		if instant then
			child:set_x(x)
		else
			child:animate(AnimateLibrary.animate_move_lerp,nil,self._ANIM_SORT_MISSION_EQ_ICON_DURATION,x)
		end
		x = x + self._MISSION_EQ_ICON_W + self._MISSION_EQ_ICON_HOR_MARGIN
	end
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
	local ratio = data.current/data.total
	
	local vitals_icon_fill = self._panel:child("vitals_icon_fill")
	
	-- todo option for smooth lerp color
	if ratio <= self._TEAMMATE_VITALS_HEALTH_EMPTY_THRESHOLD then
		vitals_icon_fill:set_color(self._TEXT_COLOR_NONE)
	elseif ratio <= self._TEAMMATE_VITALS_HEALTH_LOW_THRESHOLD then
		vitals_icon_fill:set_color(self._TEXT_COLOR_HALF)
	else
		vitals_icon_fill:set_color(self._TEXT_COLOR_FULL)
	end
	
	self:_set_vitals_fill(ratio)
	
	self:_set_revives(data.revives)
end

function HEVHUDTeammate:_set_vitals_fill(ratio)
	--[[
		local vitals_icon_fill_texture,vitals_icon_fill_rect = HEVHUD:GetIconData("teammate_vitals_fill")
		local rect = {
			vitals_icon_fill_rect[1],vitals_icon_fill_rect[2],
			vitals_icon_fill_rect[3],vitals_icon_fill_rect[4] * 
		}
		vitals_icon_fill:set_image(vitals_icon_fill_texture,unpack(vitals_icon_fill_rect))
		vitals_icon_fill:set_bottom(VITALS_ICON_Y+VITALS_ICON_H)
	--]]
end

function HEVHUDTeammate:set_armor(data)
end

function HEVHUDTeammate:_set_revives(revives)
	local vitals_icon_line = self._panel:child("vitals_icon_line")
	
	if revives <= self._TEAMMATE_VITALS_REVIVES_EMPTY_THRESHOLD then
		vitals_icon_line:set_color(self._TEXT_COLOR_NONE)
	elseif revives <= self._TEAMMATE_VITALS_REVIVES_LOW_THRESHOLD then
		vitals_icon_line:set_color(self._TEXT_COLOR_HALF)
	else
		vitals_icon_line:set_color(self._TEXT_COLOR_FULL)
	end
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
