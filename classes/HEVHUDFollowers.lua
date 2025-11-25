local HEVHUDFollowers = blt_class(HEVHUDCore:require("classes/HEVHUDBase")) -- for jokers
local AnimateLibrary = HEVHUDCore:require("classes/AnimateLibrary")


function HEVHUDFollowers:init(panel,settings,config,...)
	HEVHUDFollowers.super.init(self,panel,settings,config,...)
	local vars = config.Followers
	self._panel = panel:panel({
		name = "followers",
		valign = "bottom",
		halign = "right",
		layer = 1,
		alpha = 0
	})
	self:setup()
end

function HEVHUDFollowers:setup()
	local vars = self._config.Followers
	
	self._panel:clear()
	self._panel:configure({
		x = vars.FOLLOWERS_X + self._panel:w() - vars.FOLLOWERS_W,
		y = vars.FOLLOWERS_Y + self._panel:h() - vars.FOLLOWERS_H,
		w = vars.FOLLOWERS_W,
		h = vars.FOLLOWERS_H
	})
	
	local BG_BOX_ALPHA = self._config.General.BG_BOX_ALPHA
	self._BG_BOX_COLOR = HEVHUD.colordecimal_to_color(self._config.General.BG_BOX_COLOR)
	
	self._bgbox = self.CreateBGBox(self._panel,nil,nil,{alpha=BG_BOX_ALPHA,valign="grow",halign="grow",layer=1},{color=self._BG_BOX_COLOR})
	
	self._TEXT_COLOR_FULL = HEVHUD.colordecimal_to_color(self._settings.color_hl2_yellow)
	self._TEXT_COLOR_HALF = HEVHUD.colordecimal_to_color(self._settings.color_hl2_orange)
	self._TEXT_COLOR_NONE = HEVHUD.colordecimal_to_color(self._settings.color_hl2_red)
	
	self._ANIM_SORT_FOLLOWERS_DURATION = vars.ANIM_SORT_FOLLOWERS_DURATION
	self._ANIM_FADE_FOLLOWERS_DURATION = vars.ANIM_FADE_FOLLOWERS_DURATION
	
	self._ICON_W = vars.ICON_W
	self._ICON_TEXT_HOR_OFFSET = vars.ICON_TEXT_HOR_OFFSET
	
	
	self._panel:text({
		name = "name",
		text = managers.localization:text("hevhud_hud_followers"),
		valign = "grow",
		halign = "grow",
		align = "left",
		vertical = "bottom",
		x = vars.PANEL_NAME_X,
		y = vars.PANEL_NAME_Y,
		font = vars.PANEL_FONT_NAME,
		font_size = vars.PANEL_FONT_SIZE,
		color = self._TEXT_COLOR_FULL,
		layer = 3
	})
	
	self._followers = self._panel:panel({
		name = "followers",
		x = 0,
		y = 0,
		w = self._panel:w(),
		h = self._panel:h(),
		valign = "grow",
		halign = "grow",
		layer = 2
	})
end

function HEVHUDFollowers:add_follower(ukey,skip_sort)
	local vars = self._config.Followers
	
	-- todo add listener
	ukey = tostring(ukey)
	if alive(self._followers:child(ukey)) then
		return
	end
	
	local follower = self._followers:panel({
		name = ukey,
		w = vars.ICON_W,
		h = vars.ICON_H,
		x = -vars.ICON_W,
		y = 0,
		valign = "grow",
		halign = "right",
		layer = 1,
		visible = nil
	})
	
	local icon_text = follower:text({
		name = "icon_text",
		text = HEVHUD._font_icons.follower,
		align = "center",
		vertical = "top",
		x = vars.ICON_TEXT_HOR_OFFSET,
		y = vars.ICON_TEXT_VER_OFFSET,
		font = vars.ICONS_FONT_NAME,
		font_size = vars.ICONS_FONT_SIZE,
		valign = "bottom",
		halign = "grow",
		color = self._TEXT_COLOR_FULL,
		layer = 2
	})
	if not skip_sort then
		self:sort_followers(self._panel:alpha() <= 0.001)
	end
end

function HEVHUDFollowers:set_follower_hp(ukey,hp_ratio)
	ukey = tostring(ukey)
	local follower = self._followers:child(ukey)
	if alive(follower) then
		local col1 = self._TEXT_COLOR_NONE
		local col2 = self._TEXT_COLOR_FULL
		local dcol = col2 - col1
		local color = col1 + dcol * hp_ratio
		follower:child("icon_text"):set_color(color)
	end
end

function HEVHUDFollowers:remove_follower(ukey,skip_sort)
	-- todo remove listener
	ukey = tostring(ukey)
	local follower = self._followers:child(ukey)
	if alive(follower) then
		self._followers:remove(follower)
	end
	
	if not skip_sort then
		self:sort_followers()
	end
end

function HEVHUDFollowers:sort_followers(instant)
	local x = 0
	local has_any = false
	for i,child in ipairs(self._followers:children()) do 
		has_any = true
		
		child:stop()
		if instant then
			child:set_x(x)
		else
			child:animate(AnimateLibrary.animate_move_lerp,nil,self._ANIM_SORT_FOLLOWERS_DURATION,x)
		end
		x = x + self._ICON_W + self._ICON_TEXT_HOR_OFFSET
	end
	
	-- show followers panel only if at least 1 follower present
	if has_any ~= self._visible_state then
		self._visible_state = has_any
		local cb = function()
			self._anim_thread_panel_alpha = nil
		end
		if self._anim_thread_panel_alpha then
			self._panel:stop(self._anim_thread_panel_alpha)
			self._anim_thread_panel_alpha = nil
		end
		
		-- show panel
		self._panel:animate(AnimateLibrary.animate_alpha_lerp,cb,self._ANIM_FADE_FOLLOWERS_DURATION,nil,has_any and 1 or 0)
	end
	--self._followers:set_w(self._config.Followers.FOLLOWERS_W + x)
end


return HEVHUDFollowers