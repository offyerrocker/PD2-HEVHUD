Hooks:PostHook(GroupAIStateBase,"_set_converted_police","hevhud_on_converted",function(self, u_key, unit, owner_unit)
	if alive(owner_unit) and owner_unit == managers.player:local_player() then
		HEVHUD:AddMinion(u_key,unit)
	end
end)

Hooks:PostHook(GroupAIStateBase,"remove_minion","hevhud_on_convert_removed",function(self, minion_key, player_key)
	HEVHUD:RemoveMinion(minion_key)
end)