local HEVHUDTeammate = blt_class(HEVHUDCore:require("classes/HEVHUDBase")) -- manager for all teammates
local AnimateLibrary = HEVHUDCore:require("classes/AnimateLibrary")


function HEVHUDTeammate:init(panel,settings,config,i,...)
	HEVHUDTeammate.super.init(self,panel,settings,config,i,...)
	local vars = config.Teammate
	self._panel = panel:panel({
		name = string.format("teammate_%i",i),
		w = vars.TEAMMATE_W,
		h = vars.TEAMMATE_H,
		layer = 1,
		visible = true
	})
--	self._panel:rect({color=Color.red,alpha=0.1,name="debug"})
	self._id = i
	
	self:setup(settings,config)
	self:recreate_hud()
	
	--[[
	do -- test eq
		local keys = {}
		for k,v in pairs(tweak_data.equipments) do 
			table.insert(keys,k)
		end
		
		for i=1,8,1 do 
			local id = table.remove(keys,math.random(1,#keys))
			if tweak_data.equipments[id] and tweak_data.equipments[id].icon then
				local amount = tostring(math.random(1,20))
				self:_add_special_equipment(id,amount,nil,true)
			end
		end
		
		self:sort_special_equipment()
		
	end
	--]]
	
	-- game values
	self._peer_id = nil
	self._ai = nil
	
	self._ammo_state_primary = false
	self._ammo_state_secondary = false
	self._condition_state = false
	self._status_panel_state = false
	self._deployable_state = false
	self._secondary_deployable_state = false
	self._grenade_state = false
	self._ability_state = false
	self._zipties_state = false
	self._equipment_state = false
	self._bag_state = false
end

function HEVHUDTeammate:setup(settings,config)
	local vars = config.Teammate
	self._VITALS_THRESHOLD_HEALTH_CRITICAL = 	vars.VITALS_THRESHOLD_HEALTH_CRITICAL
	self._VITALS_THRESHOLD_HEALTH_LOW = 		vars.VITALS_THRESHOLD_HEALTH_LOW
	self._VITALS_THRESHOLD_REVIVES_CRITICAL = 	vars.VITALS_THRESHOLD_REVIVES_CRITICAL
	self._VITALS_THRESHOLD_REVIVES_LOW = 		vars.VITALS_THRESHOLD_REVIVES_LOW
	
	self._AMMO_LOW_THRESHOLD = vars.AMMO_LOW_THRESHOLD
	
	self._MISSION_EQ_ICON_W = vars.MISSION_EQ_ICON_W
	self._MISSION_EQ_ICON_H = vars.MISSION_EQ_ICON_H
	self._MISSION_EQ_ICON_HOR_MARGIN = vars.MISSION_EQ_ICON_HOR_MARGIN
	self._MISSION_EQ_ICON_VER_MARGIN = vars.MISSION_EQ_ICON_VER_MARGIN
	self._MISSION_EQ_AMOUNT_ALIGN = vars.MISSION_EQ_AMOUNT_ALIGN
	self._MISSION_EQ_AMOUNT_VERTICAL = vars.MISSION_EQ_AMOUNT_VERTICAL
	self._MISSION_EQ_LABEL_FONT_NAME = vars.MISSION_EQ_LABEL_FONT_NAME
	self._MISSION_EQ_LABEL_FONT_SIZE = vars.MISSION_EQ_LABEL_FONT_SIZE
	
	self._ANIM_MISSION_EQ_HIGHLIGHT_DURATION = vars.ANIM_MISSION_EQ_HIGHLIGHT_DURATION
	self._ANIM_SORT_MISSION_EQ_ICON_DURATION = vars.ANIM_SORT_MISSION_EQ_ICON_DURATION
	
	self._ANIM_STATUS_PANEL_FADE_DURATION = vars.ANIM_STATUS_PANEL_FADE_DURATION
	
	self._MISSION_EQ_X = vars.MISSION_EQ_X
	self._ANIM_CARRY_START_DURATION = vars.ANIM_CARRY_FADEIN_DURATION
	self._CARRY_RIGHT = vars.CARRY_ICON_W
	self._CARRY_W = vars.CARRY_ICON_W
	
end

function HEVHUDTeammate:recreate_hud()
	self._panel:clear()
	
	-- vars for layout
	local vars = self._config.Teammate
	local panel = self._panel
	panel:set_size(vars.TEAMMATE_W,vars.TEAMMATE_H)
	self._bgbox = self.CreateBGBox(panel,nil,nil,self._BGBOX_PANEL_CONFIG,self._BGBOX_TILE_CONFIG)
	
	-- shows custody/downed/tasered/low ammo
	local status = panel:panel({
		name = "status",
		w = vars.STATUS_ICON_W,
		h = vars.STATUS_ICON_H,
		x = vars.STATUS_ICON_X,
		y = vars.STATUS_ICON_Y,
		visible = false,
		layer = 3
	})
	local state_icon_texture,state_icon_rect = HEVHUD:GetIconData("triangle_line")
	status:bitmap({
		name = "status_icon",
		texture = state_icon_texture,
		texture_rect = state_icon_rect,
		w = status:w(),
		h = status:h(),
		halign = "left",
		valign = "grow",
		visible = false,
		layer = 3
	})
	self._status_panel = status
	
	local ammo = status:panel({
		name = "ammo",
		w = status:w(),
		h = status:h(),
		halign = "grow",
		valign = "grow",
		layer = 3,
		visible = false
	})
	local ammo_icon_texture,ammo_icon_rect = HEVHUD:GetIconData("teammate_ammo")
	ammo:bitmap({
		name = "ammo_icon",
		texture = ammo_icon_texture,
		texture_rect = ammo_icon_rect,
		w = ammo:w(),
		h = ammo:h(),
		halign = "left",
		valign = "grow",
		color = self._COLOR_YELLOW,
		layer = 3
	})
	local triangle_icon_texture,triangle_icon_rect = HEVHUD:GetIconData("triangle_line")
	ammo:bitmap({
		name = "triangle_icon",
		texture = triangle_icon_texture,
		texture_rect = triangle_icon_rect,
		w = ammo:w(),
		h = ammo:h(),
		halign = "left",
		valign = "grow",
		color = self._COLOR_RED,
		blend_mode = "add",
		layer = 2
	})
	self._ammo_panel = ammo
	
	local nameplate = panel:panel({
		name = "nameplate",
		x = vars.STATUS_ICON_X, -- vars.NAMEPLATE_X, -- starting position is left
		y = vars.NAMEPLATE_Y,
		w = vars.NAMEPLATE_W,
		h = vars.NAMEPLATE_H,
		valign = "top",
		halign = "left",
		layer = 2
	})
	self._nameplate = nameplate
	
	nameplate:text({
		name = "name",
		text = "WWWWWWWWWWWWQWWW",
		font = vars.NAME_LABEL_FONT_NAME,
		font_size = vars.NAME_LABEL_FONT_SIZE,
		x = vars.NAME_LABEL_X,
		y = vars.NAME_LABEL_Y,
		valign = "grow",
		halign = "grow",
		color = self._COLOR_YELLOW,
		layer = 3
	})
	
	local vitals = nameplate:panel({
		name = "vitals",
		w = vars.VITALS_ICON_W,
		h = vars.VITALS_ICON_H,
		x = vars.VITALS_ICON_X,
		y = vars.VITALS_ICON_Y,
		valign = "grow",
		halign = "grow",
		layer = 3
	})
	self._vitals = vitals
	
	local vitals_icon_fill_texture,vitals_icon_fill_rect = HEVHUD:GetIconData("teammate_vitals_fill")
	local vitals_icon_line_texture,vitals_icon_line_rect = HEVHUD:GetIconData("teammate_vitals_line")
	vitals:bitmap({
		name = "vitals_icon_fill",
		texture = vitals_icon_fill_texture,
		texture_rect = vitals_icon_fill_rect,
		w = vitals:w(),
		h = vitals:h(),
		color = self._COLOR_YELLOW,
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
		color = self._COLOR_YELLOW,
		valign = "grow",
		halign = "grow",
		layer = 3
	})
	
	-- deployable, zipties, grenades
	local loadout = panel:panel({
		name = "loadout",
		x = vars.LOADOUT_X,
		y = vars.LOADOUT_Y,
		w = panel:w() - vars.LOADOUT_X,
		h = panel:h() - vars.LOADOUT_Y,
		valign = "top",
		halign = "left",
		layer = 1
	})
	
	local deployable_texture,deployable_rect = tweak_data.hud_icons:get_icon_data("equipment_ammo_bag")
	local deployable_1 = loadout:panel({
		name = "deployable_1",
		w = vars.DEPLOYABLE_ICON_W,
		h = vars.DEPLOYABLE_ICON_H,
		x = vars.DEPLOYABLE_ICON_X,
		y = vars.DEPLOYABLE_ICON_Y,
		visible = false,
		layer = 3
	})
	deployable_1:bitmap({
		name = "icon",
		w = deployable_1:w(),
		h = deployable_1:h(),
		texture = deployable_texture, -- set later
		texture_rect = deployable_rect,
		color = self._COLOR_YELLOW,
		valign = "grow",
		halign = "grow",
		layer = 2
	})
	deployable_1:text({
		name = "amount_1",
		x = vars.DEPLOYABLE_LABEL_1_X,
		y = vars.DEPLOYABLE_LABEL_1_Y,
		font = vars.DEPLOYABLE_LABEL_FONT_NAME,
		font_size = vars.DEPLOYABLE_LABEL_FONT_SIZE,
		text = "",
		align = vars.DEPLOYABLE_LABEL_1_ALIGN,
		vertical = vars.DEPLOYABLE_LABEL_1_VERTICAL,
		layer = 3
	})
	deployable_1:text({
		name = "amount_2",
		x = vars.DEPLOYABLE_LABEL_2_X,
		y = vars.DEPLOYABLE_LABEL_2_Y,
		font = vars.DEPLOYABLE_LABEL_FONT_NAME,
		font_size = vars.DEPLOYABLE_LABEL_FONT_SIZE,
		text = "",
		align = vars.DEPLOYABLE_LABEL_2_ALIGN,
		vertical = vars.DEPLOYABLE_LABEL_2_VERTICAL,
		layer = 3
	})
	self._deployable = deployable_1
	
	local deployable_2 = loadout:panel({
		name = "deployable_2",
		w = vars.DEPLOYABLE_ICON_W,
		h = vars.DEPLOYABLE_ICON_H,
		x = deployable_1:right(),
		y = vars.DEPLOYABLE_ICON_Y,
		visible = false,
		layer = 3
	})
	deployable_2:bitmap({
		name = "icon",
		w = deployable_2:w(),
		h = deployable_2:h(),
		texture = deployable_texture, -- set later
		texture_rect = deployable_rect,
		color = self._COLOR_YELLOW,
		valign = "grow",
		halign = "grow",
		layer = 2
	})
	deployable_2:text({
		name = "amount_1",
		x = vars.DEPLOYABLE_LABEL_1_X,
		y = vars.DEPLOYABLE_LABEL_1_Y,
		font = vars.DEPLOYABLE_LABEL_FONT_NAME,
		font_size = vars.DEPLOYABLE_LABEL_FONT_SIZE,
		text = "",
		align = vars.DEPLOYABLE_LABEL_1_ALIGN,
		vertical = vars.DEPLOYABLE_LABEL_1_VERTICAL,
		layer = 3
	})
	deployable_2:text({
		name = "amount_2",
		x = vars.DEPLOYABLE_LABEL_2_X,
		y = vars.DEPLOYABLE_LABEL_2_Y,
		font = vars.DEPLOYABLE_LABEL_FONT_NAME,
		font_size = vars.DEPLOYABLE_LABEL_FONT_SIZE,
		text = "",
		align = vars.DEPLOYABLE_LABEL_2_ALIGN,
		vertical = vars.DEPLOYABLE_LABEL_2_VERTICAL,
		layer = 3
	})
	self._secondary_deployable = deployable_2
	
	local grenades_icon_texture,grenades_icon_rect = tweak_data.hud_icons:get_icon_data("frag_grenade")
	local grenades = loadout:panel({
		name = "grenades",
		x = vars.GRENADES_ICON_X,
		y = vars.GRENADES_ICON_Y,
		w = vars.GRENADES_ICON_W,
		h = vars.GRENADES_ICON_H,
		color = self._COLOR_YELLOW,
		valign = "grow",
		halign = "grow",
		visible = false,
		layer = 2
	})
	grenades:bitmap({
		name = "icon",
		texture = grenades_icon_texture,
		texture_rect = grenades_icon_rect,
		w = grenades:w(),
		h = grenades:h(),
		color = self._COLOR_YELLOW,
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
		text = "",
		align = vars.GRENADES_LABEL_ALIGN,
		vertical = vars.GRENADES_LABEL_VERTICAL,
		layer = 3
	})
	self._grenades = grenades
	
	local zipties_icon_texture,zipties_icon_rect = tweak_data.hud_icons:get_icon_data("equipment_cable_ties")
	local zipties = loadout:panel({
		name = "zipties",
		x = vars.ZIPTIES_ICON_X,
		y = vars.ZIPTIES_ICON_Y,
		w = vars.ZIPTIES_ICON_W,
		h = vars.ZIPTIES_ICON_H,
		color = self._COLOR_YELLOW,
		valign = nil,
		halign = nil,
		alpha = vars.ZIPTIES_EMPTY_ALPHA,
		visible = false,
		layer = 2
	})
	zipties:bitmap({
		name = "icon",
		texture = zipties_icon_texture,
		texture_rect = zipties_icon_rect,
		w = zipties:w(),
		h = zipties:h(),
		color = self._COLOR_YELLOW,
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
		text = "",
		align = vars.ZIPTIES_LABEL_ALIGN,
		vertical = vars.ZIPTIES_LABEL_VERTICAL,
		layer = 3
	})
	self._zipties = zipties
	
	local carry_icon_texture,carry_icon_rect = tweak_data.hud_icons:get_icon_data("pd2_loot")
	local carry = panel:panel({
		name = "carry",
		x = vars.CARRY_ICON_X,
		y = vars.CARRY_ICON_Y,
		w = vars.CARRY_ICON_W,
		h = vars.CARRY_ICON_H,
		color = self._COLOR_YELLOW,
		valign = "top",
		halign = "left",
		visible = false,
		alpha = 0,
		layer = 2
	})
	carry:bitmap({
		name = "icon",
		texture = carry_icon_texture,
		texture_rect = carry_icon_rect,
		w = carry:w(),
		h = carry:h(),
		color = self._COLOR_YELLOW,
		valign = "top",
		halign = "left",
		layer = 2
	})
	self._carry = carry
	
	local mission_equipment_bar = panel:panel({
		name = "mission_equipment_bar",
		w = vars.MISSION_EQ_W,
		h = vars.MISSION_EQ_H,
		x = vars.MISSION_EQ_X,
		y = vars.MISSION_EQ_Y,
		color = self._COLOR_YELLOW,
		valign = "top",
		halign = "left",
		layer = 2
	})
	--[[
	mission_equipment_bar:rect({
		name = "debug",
		color = Color.red,
		alpha = 0.1
	})
	--]]
	self._mission_equipment = mission_equipment_bar
	
	
	-- vitals icon (w/ visual shield/health/revives indicator)
	-- weapons ammo visual indicator (conditional)
	-- grenades, ties
	-- deployables
	-- mission equipment
	self:check_panel_state()
end

function HEVHUDTeammate:add_special_equipment(data)
	self:_add_special_equipment(data.id,data.amount,data.icon)
end

function HEVHUDTeammate:_add_special_equipment(id,amount,icon_id,skip_sort)	
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
		equipment = self._mission_equipment:panel({
			name = id,
			w = self._MISSION_EQ_ICON_W,
			h = self._MISSION_EQ_ICON_H,
			x = -self._MISSION_EQ_ICON_W,
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
			w = self._MISSION_EQ_ICON_W,
			h = self._MISSION_EQ_ICON_H,
			valign = "grow",
			halign = "grow",
			layer = 3
		})
		
		local label = equipment:text({
			name = "label",
			font = self._MISSION_EQ_LABEL_FONT_NAME,
			font_size = self._MISSION_EQ_LABEL_FONT_SIZE,
			text = amount,
			align = self._MISSION_EQ_AMOUNT_ALIGN,
			vertical = self._MISSION_EQ_AMOUNT_VERTICAL,
			valign = "grow",
			halign = "grow",
			layer = 4
		})
		icon:animate(AnimateLibrary.animate_color_lerp,nil,self._ANIM_MISSION_EQ_HIGHLIGHT_DURATION,self._COLOR_ORANGE,self._COLOR_YELLOW)
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

function HEVHUDTeammate:sort_special_equipment(instant)
	-- todo sort options?
	-- todo ensure reliable sort
	--local num_eq = #self._mission_equipment:children()

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
	
	self._equipment_state = #self._mission_equipment:children() > 0
	self:check_panel_state()
end


function HEVHUDTeammate:set_grenades_data(data)
	local texture,rect = tweak_data.hud_icons:get_icon_data(data.icon,{0,0,32,32})
	self._grenades:child("icon"):set_image(texture,unpack(rect))
	self:set_grenades_amount(data)
	--self:check_panel_state()
end

function HEVHUDTeammate:set_grenades_amount(data)
	self._grenades:child("amount"):set_text(string.format("%i",data.amount))
	self._grenade_state = data.amount > 0
	if self._grenade_state then
		self._grenades:show()
	end
	self:check_panel_state()
end

function HEVHUDTeammate:set_grenades_cooldown(data)
	self._ability_state = true
	if self._ability_state then
		self._grenades:show()
	end

	self:check_panel_state()
end

function HEVHUDTeammate:set_ability_icon(data) -- should be funneled into status
	self._ability_state = true
	
	if self._ability_state then
		self._grenades:show()
	end
end

function HEVHUDTeammate:set_zipties_data(data)
	local texture,rect = tweak_data.hud_icons:get_icon_data(data.icon)
	self._zipties:child("icon"):set_image(texture,unpack(rect))
	self:set_zipties_amount(data.amount)
end

function HEVHUDTeammate:set_zipties_amount(amount)
	if amount <= 0 then
		self._zipties:set_alpha(self._config.Teammate.ZIPTIES_EMPTY_ALPHA)
		self._zipties:child("amount"):set_text("")
		self._zipties_state = false
		self._zipties:hide()
	else
		self._zipties:set_alpha(1)
		self._zipties:child("amount"):set_text(string.format("%i",amount))
		self._zipties_state = true
		self._zipties:show()
	end
	
	self:check_panel_state()
end

function HEVHUDTeammate:set_deployable(data) -- only used for teammates
	local texture,rect = tweak_data.hud_icons:get_icon_data(data.icon)
	local deployable = self._deployable
	
	if data.icon then
		deployable:child("icon"):set_image(texture,unpack(rect))
		deployable:child("amount_1"):set_text(string.format("%i",data.amount))
	end
	
	self._deployable_state = data.amount > 0
	deployable:set_visible(self._deployable_state)
	
	self:check_panel_state()
end

function HEVHUDTeammate:set_deployable_second_amount(data) -- only used for teammates
	local deployable = self._deployable
	
	local has_any
	if data.amount[1] then
		has_any = has_any or (data.amount[1] > 0)
		deployable:child("amount_1"):set_text(string.format("%i",data.amount[1]))
	end
	if data.amount[2] then
		has_any = has_any or (data.amount[2] > 0)
		deployable:child("amount_2"):set_text(string.format("%i",data.amount[2]))
	end
	if data.icon then
		local texture,rect = tweak_data.hud_icons:get_icon_data(data.icon)
		deployable:child("icon"):set_image(texture,unpack(rect))
	end
	
	
	self._deployable_state = has_any
	deployable:set_visible(self._deployable_state)
	self:check_panel_state()
end

function HEVHUDTeammate:set_deployable_by_index(index,data) -- only used for player
	local deployable
	if index == 2 then
		deployable = self._secondary_deployable
	else
		deployable = self._deployable
	end
	if data.icon then
		local texture,rect = tweak_data.hud_icons:get_icon_data(data.icon)
		deployable:child("icon"):set_image(texture,unpack(rect))
	end
	deployable:child("amount_1"):set_text(string.format("%i",data.amount))
	
	if index == 2 then
		self._secondary_deployable_state = data.amount > 0
		deployable:set_visible(self._secondary_deployable_state)
	else
		self._deployable_state = data.amount > 0
		deployable:set_visible(self._deployable_state)
	end
	self:check_panel_state()
end
function HEVHUDTeammate:set_deployable_second_amount_by_index(index,data) -- only used for player
	local deployable
	if index == 2 then
		deployable = self._secondary_deployable
	else
		deployable = self._deployable
	end
	
	local has_any
	if data.amount[1] then
		has_any = has_any or (data.amount[1] > 0)
		deployable:child("amount_1"):set_text(string.format("%i",data.amount[1]))
	end
	if data.amount[2] then
		has_any = has_any or (data.amount[2] > 0)
		deployable:child("amount_2"):set_text(string.format("%i",data.amount[2]))
	end
	if data.icon then
		local texture,rect = tweak_data.hud_icons:get_icon_data(data.icon)
		deployable:child("icon"):set_image(texture,unpack(rect))
	end
	
	if index == 2 then
		self._secondary_deployable_state = has_any
		deployable:set_visible(self._secondary_deployable_state)
	else
		self._deployable_state = has_any
		deployable:set_visible(self._deployable_state)
	end
	self:check_panel_state()
end

function HEVHUDTeammate:set_name(name)
	self._nameplate:child("name"):set_text(name)
end

function HEVHUDTeammate:show()
	self._panel:show()
end

function HEVHUDTeammate:hide()
	self._panel:hide()
end

function HEVHUDTeammate:set_health(data)
	local ratio = data.current/data.total
	
	local vitals_icon_fill = self._vitals:child("vitals_icon_fill")
	
	-- todo option for smooth lerp color
	if ratio <= 0 then
		vitals_icon_fill:set_color(Color.black)
	elseif ratio <= self._VITALS_THRESHOLD_HEALTH_CRITICAL then
		vitals_icon_fill:set_color(self._COLOR_RED)
	elseif ratio <= self._VITALS_THRESHOLD_HEALTH_LOW then
		vitals_icon_fill:set_color(self._COLOR_ORANGE)
	else
		vitals_icon_fill:set_color(self._COLOR_YELLOW)
	end
	
	local vitals_icon_fill_texture,vitals_icon_fill_rect = HEVHUD:GetIconData("teammate_vitals_fill")
	local rect = {
		vitals_icon_fill_rect[1],vitals_icon_fill_rect[2],
		vitals_icon_fill_rect[3],vitals_icon_fill_rect[4] * ratio
	}
	vitals_icon_fill:set_image(vitals_icon_fill_texture,unpack(vitals_icon_fill_rect))
	vitals_icon_fill:set_bottom(self._vitals:h())
	
	self:_set_revives(data.revives)
end

function HEVHUDTeammate:set_armor(data)
end

function HEVHUDTeammate:_set_revives(revives)
	local vitals_icon_line = self._vitals:child("vitals_icon_line")
	
	if revives <= 0 then
		vitals_icon_line:set_color(Color.black)
	elseif revives <= self._VITALS_THRESHOLD_REVIVES_CRITICAL then
		vitals_icon_line:set_color(self._COLOR_RED)
	elseif revives <= self._VITALS_THRESHOLD_REVIVES_LOW then
		vitals_icon_line:set_color(self._COLOR_ORANGE)
	else
		vitals_icon_line:set_color(self._COLOR_YELLOW)
	end
end

function HEVHUDTeammate:set_ammo(selection_index, max_clip, current_clip, current_left, max)
	if selection_index == 2 then
		self._ammo_state_primary = current_left / max < self._AMMO_LOW_THRESHOLD
	else
		self._ammo_state_secondary = current_left / max < self._AMMO_LOW_THRESHOLD
	end

	self:chk_condition_panel()
end

function HEVHUDTeammate:set_ai(state)
	self._ai = state
	
	self._vitals:set_visible(not state)
	self._mission_equipment:set_visible(not state)
	self._deployable:set_visible(not state)
	self._grenades:set_visible(not state)
	self._zipties:set_visible(not state)
	-- carry can stay
end

function HEVHUDTeammate:set_carry(data,value)
	self._mission_equipment:stop()
	self._mission_equipment:animate(AnimateLibrary.animate_move_lerp,nil,self._ANIM_CARRY_START_DURATION,self._CARRY_RIGHT+self._MISSION_EQ_X)
	self._carry:show()
	self._carry:stop()
	self._carry:set_alpha(1)
	self._carry:animate(AnimateLibrary.animate_grow_w_left,nil,self._ANIM_CARRY_START_DURATION,1,self._CARRY_W)
	
	self._bag_state = true
	self:check_panel_state()
end

function HEVHUDTeammate:stop_carry()
	self._mission_equipment:stop()
	self._mission_equipment:animate(AnimateLibrary.animate_move_lerp,nil,self._ANIM_CARRY_START_DURATION,self._MISSION_EQ_X)
	self._carry:stop()
	self._carry:animate(AnimateLibrary.animate_grow_w_left,nil,self._ANIM_CARRY_START_DURATION,nil,1)
	self._carry:animate(AnimateLibrary.animate_alpha_lerp,nil,self._ANIM_CARRY_START_DURATION,nil,0)
	
	self._bag_state = false
	self:check_panel_state()
end

function HEVHUDTeammate:chk_condition_panel()
	local ammo_visible = self._ammo_state_primary or self._ammo_state_secondary
	local state = ammo_visible or self._condition_state
	
	self._ammo_panel:set_visible(ammo_visible and not self._condition_state)
	
	if self._status_panel_state ~= state then
		self._status_panel_state = state
		if not state then
			-- shrink status panel, then hide
			self._status_panel:stop()
			self._status_panel:animate(AnimateLibrary.animate_grow_w_left,function(o) o:hide() end,self._ANIM_STATUS_PANEL_FADE_DURATION,nil,1)
			
			self._nameplate:stop()
			self._nameplate:animate(AnimateLibrary.animate_move_lerp,nil,self._ANIM_STATUS_PANEL_FADE_DURATION,self._config.Teammate.NAMEPLATE_X)
		else
			-- show and grow status panel
			self._status_panel:stop()
			self._status_panel:show()
			self._status_panel:animate(AnimateLibrary.animate_grow_w_left,nil,self._ANIM_STATUS_PANEL_FADE_DURATION,1,self._config.Teammate.STATUS_ICON_W)
		
			self._nameplate:stop()
			self._nameplate:animate(AnimateLibrary.animate_move_lerp,nil,self._ANIM_STATUS_PANEL_FADE_DURATION,self._config.Teammate.STATUS_ICON_W)
		end
	end
end

function HEVHUDTeammate:set_condition(icon_id,text)
	--Print(icon_id,">",text,"<")
	local status_icon = self._status_panel:child("status_icon")
	if icon_id == "mugshot_normal" then
		status_icon:hide()
		if self._condition_state then
			self._condition_state = false
			self:chk_condition_panel()
		end
	else
		status_icon:show()
		if not self._condition_state then
			self._condition_state = true
			self:chk_condition_panel()
		end
		--HEVHUDCore:Print("condition icon",icon_id)
		
		local texture,rect
		texture,rect = HEVHUD:GetIconData(icon_id)
		if not texture then
			texture,rect = tweak_data.hud_icons:get_icon_data(icon_id)
		end
		
		--[[
	mugshot_health_background 
	mugshot_health_armor
	mugshot_health_health 
	mugshot_talk 
	mugshot_in_custody 
	mugshot_downed
	mugshot_cuffed
	mugshot_electrified
		--]]
		
		status_icon:set_image(texture,unpack(rect))
	end
end

function HEVHUDTeammate:set_peer_id(peer_id)
	self._peer_id = peer_id
	self:set_peer_color(tweak_data.chat_colors[peer_id])
end

function HEVHUDTeammate:set_peer_color(color)
	if color then
		self._nameplate:set_color(color)
	end
end

function HEVHUDTeammate:check_panel_state()
	local h = self._nameplate:bottom() -- first row h
	
--	self._deployable:set_visible(self._deployable_state)
--	self._grenades:set_visible(self._grenade_state or self._ability_state)
--	self._zipties:set_visible(self._zipties_state)
--	self._mission_equipment:set_visible(self._equipment_state)
--	self._carry:set_visible(self._bag_state)
	if self._deployable_state or self._secondary_deployable_state or self._grenade_state or self._ability_state or self._zipties_state then 
		h = self._deployable:bottom()
		
		local x = self._loadout_x_1
		if self._deployable_state then
			self._deployable:set_x(x)
			x = self._deployable:right()
		end
		if self._secondary_deployable_state then
			self._secondary_deployable:set_x(x)
			x = self._secondary_deployable:right()
		end
		
		if self._grenade_state or self._ability_state then
			self._grenades:set_x(x)
			x = self._grenades:right()
		end
		if self._zipties_state then
			self._zipties:set_x(x)
			x = self._zipties:right()
		end
	end
	-- todo this needs to adjust row 2 down if row 1 is nonexistent
	
	if self._bag_state or self._equipment_state then
		h = self._carry:bottom()
		
		local x = self._loadout_x_2
		if self._bag_state then
			self._carry:set_x(x)
			x = self._carry:right()
		end
		if self._equipment_state then
			self._mission_equipment:set_x(x)
			x = self._mission_equipment:right()
		end
	end
	
	self._panel:set_h(h)
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
