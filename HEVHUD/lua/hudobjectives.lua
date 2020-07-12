
Hooks:PostHook(HUDObjectives,"init","hevhud_objectiveinit",function(self,hud)
	local objectives_panel = self._hud_panel:child("objectives_panel")
	objectives_panel:hide()
end)



--overridden
function HUDObjectives:activate_objective(data)
	self._active_objective_id = data.id
	data.mode = "activate"
	HEVHUD:AddObjective(data)
	
end	

--overridden
function HUDObjectives:remind_objective(id)
	HEVHUD:AddObjective({id = id,mode = "remind"})
	
end

--overridden
function HUDObjectives:complete_objective(data)
	data.mode = "complete"
	HEVHUD:AddObjective(data)

end

function HUDObjectives:update_amount_objective(data)
	data.mode = "update_amount"
	HEVHUD:AddObjective(data)
end

