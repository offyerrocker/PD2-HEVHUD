local STATE_COMPATIBILITY = true
if STATE_COMPATIBILITY then
	Hooks:PostHook(IngameMaskOffState,"at_enter","hevhud_maskoff_show_maskprompt",function(self)
		HEVHUD._hud_hint:show_mask_prompt()
		managers.hud:hide(self._MASK_OFF_HUD)
	end)
else
	Hooks:OverrideFunction(IngameMaskOffState,"at_enter",function(self)
	
		local players = managers.player:players()

		for k, player in ipairs(players) do
			local vp = player:camera():viewport()

			if vp then
				vp:set_active(true)
			else
				Application:error("No viewport for player " .. tostring(k))
			end
		end
		
		-- prevent maskoff hud from being created at all
		--if not managers.hud:exists(self._MASK_OFF_HUD) then
		--	managers.hud:load_hud(self._MASK_OFF_HUD, false, false, true, {})
		--end
		--
		--if not _G.IS_VR then
		--	managers.hud:show(self._MASK_OFF_HUD)
		--end

		managers.hud:show(PlayerBase.PLAYER_INFO_HUD)
		managers.hud:show(PlayerBase.PLAYER_INFO_HUD_FULLSCREEN)

		local player = managers.player:player_unit()

		if player then
			player:base():set_enabled(true)
		end
	
		HEVHUD._hud_hint:show_mask_prompt()
	end)
end

Hooks:PostHook(IngameMaskOffState,"at_exit","hevhud_maskoff_hide_maskprompt",function(self)
	HEVHUD._hud_hint:hide_mask_prompt()
	
	--managers.hud:hide(self._MASK_OFF_HUD)
end)

