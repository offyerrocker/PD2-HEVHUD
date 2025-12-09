local HEVHUDWaiting = blt_class(HEVHUDCore:require("classes/HEVHUDBase"))
local AnimateLibrary = HEVHUDCore:require("classes/AnimateLibrary")


function HEVHUDWaiting:init(panel,settings,config,...)
	HEVHUDWaiting.super.init(self,panel,settings,config,...)
	local vars = config.Waiting
	self._panel = panel:panel({
		name = "waiting",
		valign = "center",
		halign = "center",
		w = panel:w(),
		h = panel:h(),
		layer = 5,
		alpha = 1,
		visible = false
	})
	
	self._current_peer = nil
	
	self._all_buttons = {
		self:create_button("hud_waiting_accept", "drop_in_accept", "spawn", "text_button_accept"),
		self:create_button("hud_waiting_return", "drop_in_return", "return_back", "text_button_return"),
		self:create_button("hud_waiting_kick", "drop_in_kick", "kick", "text_button_kick")
	}
	
	self:setup(settings,config)
	self:recreate_hud()
end

function HEVHUDWaiting:setup(settings,config,...)
	HEVHUDWaiting.super.setup(self,settings,config,...)
end

function HEVHUDWaiting:recreate_hud()
	local vars = self._config.Waiting
	
	self._buttons_panel = self._panel:panel({
		name = "buttons_panel",
		x = vars.BUTTONS_PANEL_X,
		y = vars.BUTTONS_PANEL_Y,
		w = vars.BUTTONS_PANEL_W,
		h = vars.BUTTONS_PANEL_H,
		layer = 3
	})
	
	local text_header = self._buttons_panel:text({
		name = "text_header",
		text_id = "hud_waiting_no_binding_text",
		valign = "grow",
		halign = "grow",
		align = "left",
		vertical = "top",
		x = vars.LABEL_BUTTON_HEADER_X,
		y = vars.LABEL_BUTTON_HEADER_Y,
		font = vars.LABEL_BUTTON_HEADER_FONT_NAME,
		font_size = vars.LABEL_BUTTON_HEADER_FONT_SIZE,
		color = self._COLOR_YELLOW,
		layer = 3
	})
	local text_button_accept = self._buttons_panel:text({
		name = "text_button_accept",
		text = "ACCEPT",
		valign = "grow",
		halign = "grow",
		align = "left",
		vertical = "top",
		x = vars.LABEL_BUTTON_ACCEPT_X,
		y = vars.LABEL_BUTTON_ACCEPT_Y,
		font = vars.LABEL_BUTTON_FONT_NAME,
		font_size = vars.LABEL_BUTTON_FONT_SIZE,
		color = Color.white,
		layer = 3
	})
	local text_button_return = self._buttons_panel:text({
		name = "text_button_return",
		text = "RETURN",
		valign = "grow",
		halign = "grow",
		align = "left",
		vertical = "top",
		x = vars.LABEL_BUTTON_RETURN_X,
		y = vars.LABEL_BUTTON_RETURN_Y,
		font = vars.LABEL_BUTTON_FONT_NAME,
		font_size = vars.LABEL_BUTTON_FONT_SIZE,
		color = Color.white,
		layer = 3
	})
	local text_button_kick = self._buttons_panel:text({
		name = "text_button_kick",
		text = "KICK",
		valign = "grow",
		halign = "grow",
		align = "left",
		vertical = "top",
		x = vars.LABEL_BUTTON_KICK_X,
		y = vars.LABEL_BUTTON_KICK_Y,
		font = vars.LABEL_BUTTON_FONT_NAME,
		font_size = vars.LABEL_BUTTON_FONT_SIZE,
		color = Color.white,
		layer = 3
	})
	self._buttons_bgbox = self.CreateBGBox(self._buttons_panel,nil,self._BGBOX_PANEL_CONFIG,self._BGBOX_TILE_CONFIG)
	
	
	local card_panel = self._panel:panel({
		name = "card_panel",
		w = vars.CARD_PANEL_W,
		h = vars.CARD_PANEL_H,
		x = vars.CARD_PANEL_X,
		y = vars.CARD_PANEL_Y,
		layer = 5
	})
	self._card_panel = card_panel
	
	card_panel:bitmap({
		name = "card_image",
		texture = "guis/textures/hevhud_waiting_legend",
		texture_rect = {
			0,0,
			200,128
		},
		w = 200,
		h = 128,
		x = 0,
		y = 0,
		layer = 1
	})
	
	local portrait_image = card_panel:bitmap({
		name = "portrait_image",
		texture = tweak_data.blackmarket:get_character_icon("dallas"),
		texture_rect = nil,
		color = Color.white,
--		blend_mode = "add",
		x = 12,
		y = 43,
		w = 56,
		h = 56,
		layer = 3
	})
	
	local portrait_frame = card_panel:bitmap({
		name = "portrait_frame",
		texture = "guis/textures/hevhud_waiting_legend",
		texture_rect = {200,43,56,56},
		x = 12,
		y = 43,
		w = 56,
		h = 56,
		layer = 4
	})
	
	local player_name = card_panel:text({
		name = "player_name",
		text = "chinz",
		valign = "grow",
		halign = "grow",
		align = "right",
		vertical = "top",
		x = vars.LABEL_NAME_X,
		y = vars.LABEL_NAME_Y,
		font = vars.LABEL_FONT_NAME,
		font_size = vars.LABEL_FONT_SIZE,
		color = Color.black,
		layer = 3
	})
	
	local player_level = card_panel:text({
		name = "player_level",
		text = "XXV-100",
		valign = "grow",
		halign = "grow",
		align = "right",
		vertical = "top",
		x = vars.LABEL_LEVEL_X,
		y = vars.LABEL_LEVEL_Y,
		font = vars.LABEL_FONT_NAME,
		font_size = vars.LABEL_FONT_SIZE,
		color = Color.black,
		layer = 3
	})
	
	local player_detrisk = card_panel:text({
		name = "player_detrisk",
		text = "75",
		valign = "grow",
		halign = "grow",
		align = "right",
		vertical = "top",
		x = vars.LABEL_DETRISK_X,
		y = vars.LABEL_DETRISK_Y,
		font = vars.LABEL_FONT_NAME,
		font_size = vars.LABEL_FONT_SIZE,
		color = Color.black,
		layer = 3
	})
	
	
	local texture,rect = HEVHUD:GetIconData("triangle_line")
	
	local box_eq_1 = card_panel:panel({
		name = "box_eq_1",
		w = vars.ICON_W,
		h = vars.ICON_H,
		x = vars.ICON_DEPLOYABLE_1_X,
		y = vars.ICON_DEPLOYABLE_1_Y,
		layer = 2
	})
	box_eq_1:rect({
		name = "bg",
		w = vars.ICON_W,
		h = vars.ICON_H,
		valign = "grow",
		halign = "grow",
		color = Color.black,
		alpha = vars.EQBOX_RECT_ALPHA,
		layer = 1
	})
	box_eq_1:bitmap({
		name = "icon",
		texture = texture,
		texture_rect = rect,
		w = vars.ICON_W,
		h = vars.ICON_H,
		color = Color.white,
		layer = 2
	})
	box_eq_1:text({
		name = "text",
		text = "1",
		valign = "grow",
		halign = "grow",
		align = "right",
		vertical = "top",
		x = vars.EQBOX_LABEL_X,
		y = vars.EQBOX_LABEL_Y,
		font = vars.LABEL_FONT_NAME,
		font_size = vars.LABEL_FONT_SIZE,
		color = Color.black,
		layer = 3
	})
	
	
	local box_eq_2 = card_panel:panel({
		name = "box_eq_2",
		w = vars.ICON_W,
		h = vars.ICON_H,
		x = vars.ICON_DEPLOYABLE_2_X,
		y = vars.ICON_DEPLOYABLE_2_Y,
		layer = 2
	})
	box_eq_2:rect({
		name = "bg",
		w = vars.ICON_W,
		h = vars.ICON_H,
		color = Color.black,
		alpha = vars.EQBOX_RECT_ALPHA,
		layer = 1
	})
	box_eq_2:bitmap({
		name = "icon",
		texture = texture,
		texture_rect = rect,
		w = vars.ICON_W,
		h = vars.ICON_H,
		color = Color.white,
		layer = 2
	})
	box_eq_2:text({
		name = "text",
		text = "1",
		valign = "grow",
		halign = "grow",
		align = "right",
		vertical = "top",
		x = vars.EQBOX_LABEL_X,
		y = vars.EQBOX_LABEL_Y,
		font = vars.LABEL_FONT_NAME,
		font_size = vars.LABEL_FONT_SIZE,
		color = Color.black,
		layer = 3
	})
	
	local box_eq_3 = card_panel:panel({
		name = "box_eq_3",
		w = vars.ICON_W,
		h = vars.ICON_H,
		x = vars.ICON_THROWABLE_X,
		y = vars.ICON_THROWABLE_Y,
		layer = 2
	})
	box_eq_3:rect({
		name = "bg",
		w = vars.ICON_W,
		h = vars.ICON_H,
		color = Color.black,
		alpha = vars.EQBOX_RECT_ALPHA,
		layer = 1
	})
	box_eq_3:bitmap({
		name = "icon",
		texture = texture,
		texture_rect = rect,
		w = vars.ICON_W,
		h = vars.ICON_H,
		color = Color.white,
		layer = 2
	})
	box_eq_3:text({
		name = "text",
		text = "1",
		valign = "grow",
		halign = "grow",
		align = "right",
		vertical = "top",
		x = vars.EQBOX_LABEL_X,
		y = vars.EQBOX_LABEL_Y,
		font = vars.LABEL_FONT_NAME,
		font_size = vars.LABEL_FONT_SIZE,
		color = Color.black,
		layer = 3
	})
	
	local box_eq_4 = card_panel:panel({
		name = "box_eq_4",
		w = vars.ICON_W,
		h = vars.ICON_H,
		x = vars.ICON_SPECIALIZATION_X,
		y = vars.ICON_SPECIALIZATION_Y,
		layer = 2
	})
	box_eq_4:rect({
		name = "bg",
		w = vars.ICON_W,
		h = vars.ICON_H,
		color = Color.black,
		alpha = vars.EQBOX_RECT_ALPHA,
		layer = 1
	})
	box_eq_4:bitmap({
		name = "icon",
		texture = texture,
		texture_rect = rect,
		w = vars.ICON_W,
		h = vars.ICON_H,
		color = Color.white,
		layer = 2
	})
	box_eq_4:text({
		name = "text",
		text = "1",
		valign = "grow",
		halign = "grow",
		align = "right",
		vertical = "top",
		x = vars.EQBOX_LABEL_X,
		y = vars.EQBOX_LABEL_Y,
		font = vars.LABEL_FONT_NAME,
		font_size = vars.LABEL_FONT_SIZE,
		color = Color.black,
		layer = 3
	})
end

function HEVHUDWaiting:animate_flash_bgbox()
	local vars = self._config.Waiting
	for _,child in pairs(self._buttons_bgbox:children()) do 
		child:stop()
		child:animate(AnimateLibrary.animate_color_oscillate,vars.ANIM_BGBOX_FLASH_SPEED,self._COLOR_YELLOW,self._BG_BOX_COLOR)
	end
	self._buttons_bgbox:stop()
	self._buttons_bgbox:animate(AnimateLibrary.animate_alpha_oscillate,vars.ANIM_BGBOX_FLASH_SPEED,vars.ANIM_BGBOX_FLASH_ALPHA,self._BG_BOX_ALPHA)
end

function HEVHUDWaiting:stop_animate_flash_bgbox()
	for _,child in pairs(self._buttons_bgbox:children()) do 
		child:stop()
		child:set_color(self._BG_BOX_COLOR)
	end
	self._buttons_bgbox:stop()
	self._buttons_bgbox:set_alpha(self._BG_BOX_ALPHA)
end

function HEVHUDWaiting:create_button(text, binding, func_name, gui_name)
	return {
		text = text,
		binding = binding,
		callback = callback(self, self, func_name),
		gui_name = gui_name
	}
end

function HEVHUDWaiting:update_buttons()
	local vars = self._config.Waiting
	local max_w = vars.BUTTONS_PANEL_W
	
	local text_header = self._buttons_panel:child("text_header")
	local _tx,_ty,_tw,_th = text_header:text_rect()
	max_w = math.max(max_w,text_header:x() + _tw)
	
--	text_header:animate(AnimateLibrary.animate_color_oscillate(
	
	self:animate_flash_bgbox()
	
	for k, btn in pairs(self._all_buttons) do
		local button_text = managers.localization:btn_macro(btn.binding, true, true)
		local child = btn.gui_name and self._buttons_panel:child(btn.gui_name)
		
		if child then
			child:set_text(
				managers.localization:text(btn.text, {
					MY_BTN = button_text
				})
			)
			local tx,ty,tw,th = child:text_rect()
			max_w = math.max(max_w,child:x() + tw)
		end
	end
	self._buttons_panel:set_w(max_w + vars.BUTTONS_PANEL_HOR_MARGIN)

--	if str == "" then
--		str = managers.localization:text("hud_waiting_no_binding_text")
--	end
	
	self._panel:set_visible(true)
end

function HEVHUDWaiting:on_input(button)
	if not self._current_peer or self._block_input_until and Application:time() < self._block_input_until then
		return
	end

	for _, btn in pairs(self._all_buttons) do
		if btn.binding == button and btn.callback then
			btn.callback()

			return
		end
	end
end

function HEVHUDWaiting:show_on(teammate_hud,peer)
	local panel = teammate_hud._panel
	
	local my_peer = managers.network:session():peer(self._peer_id)
	peer = peer or my_peer
	
	local card_panel = self._card_panel
	local peer_name = peer:name()
	local level_str, color_ranges = managers.experience:gui_string(peer:level(), peer:rank(), 0)
	card_panel:child("player_name"):set_text(peer_name)
	local player_level = card_panel:child("player_level")
	player_level:set_text(level_str)
	for _, color_range in ipairs(color_ranges or {}) do
		player_level:set_range_color(color_range.start, color_range.stop, color_range.color)
	end
	
	local current, reached = managers.blackmarket:get_suspicion_offset_of_peer(peer, tweak_data.player.SUSPICION_OFFSET_LERP or 0.75)
	
	local player_detrisk = card_panel:child("player_detrisk")
	player_detrisk:set_text(string.format("%i",math.round(current * 100)))

	if reached then
		player_detrisk:set_color(Color(255, 255, 42, 0) / 255)
	else
		player_detrisk:set_color(Color.black)
	end
	
	local outfit = peer:profile().outfit or managers.blackmarket:unpack_outfit_from_string(peer:profile().outfit_string) or {}

	local has_deployable = outfit.deployable and outfit.deployable ~= "nil"
	local has_secondary_deployable = outfit.secondary_deployable and outfit.secondary_deployable ~= "nil"
	
	local box_eq_1 = card_panel:child("box_eq_1")
	box_eq_1:set_visible(has_secondary_deployable)
	if has_secondary_deployable then
		self.set_icon_data(box_eq_1:child("icon"),tweak_data.equipments[outfit.secondary_deployable].icon)
		box_eq_1:child("text"):set_text(outfit.secondary_deployable_amount)
	end
	
	local box_eq_2 = card_panel:child("box_eq_2")
	box_eq_2:set_visible(has_deployable)
	if has_deployable then
		self.set_icon_data(box_eq_2:child("icon"),tweak_data.equipments[outfit.deployable].icon)
		box_eq_2:child("text"):set_text(outfit.deployable_amount)
	end
	
	local box_eq_3 = card_panel:child("box_eq_3")
	box_eq_3:set_visible(outfit.grenade and true or false)
	if outfit.grenade then
		self.set_icon_data(box_eq_3:child("icon"),tweak_data.blackmarket.projectiles[outfit.grenade].icon)
		box_eq_3:child("text"):set_text(managers.player:get_max_grenades(peer:grenade_id()))
	end
	
	local box_eq_4 = card_panel:child("box_eq_4")
	self.set_icon_data(box_eq_4:child("icon"),tweak_data.skilltree:get_specialization_icon_data(tonumber(outfit.skills.specializations[1])))
	box_eq_4:child("text"):set_text(outfit.skills.specializations[2])
	
	card_panel:child("portrait_image"):set_image(tweak_data.blackmarket:get_character_icon(outfit.character))
	
--	self._panel:set_world_leftbottom(panel:world_left(), panel:world_top() + 20)

	self._current_peer = peer or managers.network:session():local_peer()

	self:update_buttons()

	self._block_input_until = Application:time() + 0.5
end

function HEVHUDWaiting.set_icon_data(bitmap,icon_id,rect)
	if rect then
		bitmap:set_image(icon_id, unpack(rect))

		return
	end

	local text, rect = tweak_data.hud_icons:get_icon_data(icon_id or "fallback")

	bitmap:set_image(text, unpack(rect))
end

function HEVHUDWaiting:peer()
	return self._current_peer
end

function HEVHUDWaiting:is_set()
	return not not self._current_peer
end

function HEVHUDWaiting:turn_off()
	self._current_peer = nil
	self:stop_animate_flash_bgbox()
	self._panel:set_visible(false)
end

function HEVHUDWaiting:spawn()
	if self._current_peer then
		managers.wait:spawn_waiting(self._current_peer:id())
	end
end

function HEVHUDWaiting:return_back()
	if self._current_peer then
		managers.wait:kick_to_briefing(self._current_peer:id())
	end
end

function HEVHUDWaiting:kick()
	if self._current_peer then
		managers.vote:message_host_kick(self._current_peer)
	end
end



return HEVHUDWaiting