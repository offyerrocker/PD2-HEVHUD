Hooks:PostHook(HUDTeammate,"init","hevhud_init_playerpanel",function(self, i, teammates_panel, is_player, width)
	local show_teammates_vanilla = not HEVHUDCore.settings.hud_teammate_enabled
	if not show_teammates_vanilla or self._main_player then
		if alive(self._panel) then 
			self._panel:set_alpha(0)
			self._player_panel:child("weapons_panel"):hide()
		end
	end
end)