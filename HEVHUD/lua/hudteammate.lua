Hooks:PostHook(HUDTeammate,"set_health","hevhud_set_health",function(self,data)
	local text = ""
	if data.total ~= 0 then 
		if HEVHUD:ShouldShowHealthValue() then 
			text = string.format("%i",data.current * 10)
		else
			text = string.format("%i",(data.current / data.total) * 10)
		end
	end
	HEVHUD:SetHealthString(text)
end)

Hooks:PostHook(HUDTeammate,"set_armor","hevhud_set_armor",function(self,data)
	local text = ""
	if data.total ~= 0 then 
		if HEVHUD:ShouldShowArmorValue() then 
			text = string.format("%i",data.current * 10)
		else
			text = string.format("%i",(data.current / data.total) * 10)
		end
	end
	HEVHUD:SetSuitString(text)
end)

Hooks:PostHook(HUDTeammate,"set_ammo_amount_by_type","hevhud_set_ammo",function(self,slot_name, max_clip, current_clip, current_reserve, max_reserve, weapon_panel)
--	HEVHUD:SetWeaponReserve(slot_name,math.max(current_left - current_clip,0))
	
	if HEVHUD:ShouldUseRealAmmo() then 
		HEVHUD:SetWeaponReserve(slot_name,math.max(current_reserve - current_clip,0),max_reserve)
	else
		HEVHUD:SetWeaponReserve(slot_name,current_reserve,max_reserve)
	end
	HEVHUD:SetWeaponMagazine(slot_name,current_clip,max_clip)
--[[
	local weapon_panel = weapon_panel or self._player_panel:child("weapons_panel"):child(type .. "_weapon_panel")

	weapon_panel:set_visible(true)

	local low_ammo = current_left <= math.round(max_clip / 2)
	local low_ammo_clip = current_clip <= math.round(max_clip / 4)
	local out_of_ammo_clip = current_clip <= 0
	local out_of_ammo = current_left <= 0
	local color_total = out_of_ammo and Color(1, 0.9, 0.3, 0.3)
	color_total = color_total or low_ammo and Color(1, 0.9, 0.9, 0.3)
	color_total = color_total or Color.white
	local color_clip = out_of_ammo_clip and Color(1, 0.9, 0.3, 0.3)
	color_clip = color_clip or low_ammo_clip and Color(1, 0.9, 0.9, 0.3)
	color_clip = color_clip or Color.white
	local ammo_clip = weapon_panel:child("ammo_clip")
	local zero = current_clip < 10 and "00" or current_clip < 100 and "0" or ""

	ammo_clip:set_text(zero .. tostring(current_clip))
	ammo_clip:set_color(color_clip)
	ammo_clip:set_range_color(0, string.len(zero), color_clip:with_alpha(0.5))
	ammo_clip:set_font_size(string.len(current_clip) < 4 and 32 or 24)

	local ammo_total = weapon_panel:child("ammo_total")
	local zero = current_left < 10 and "00" or current_left < 100 and "0" or ""

	ammo_total:set_text(zero .. tostring(current_left))
	ammo_total:set_color(color_total)
	ammo_total:set_range_color(0, string.len(zero), color_total:with_alpha(0.5))
	ammo_total:set_font_size(string.len(current_left) < 4 and 24 or 20)
	--]]
end)