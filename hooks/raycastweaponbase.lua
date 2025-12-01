--local SHOW_UNDERBARREL_AFTER_MAIN_AMMO = false
local DETECT_UNDERBARREL_AMMO = true


local underbarrel_ammo_amount = 0
if DETECT_UNDERBARREL_AMMO then
	-- this is a stupid ass way to detect underbarrel ammo but the vanilla pd2 func doesn't return ammo data for underbarrels 
	Hooks:PreHook(RaycastWeaponBase,"add_ammo","hevhud_raycastweaponbase_addammo_pre",function(self, ratio, add_amount_override)
		underbarrel_ammo_amount = 0
		for i,gadget in pairs(self:get_all_override_weapon_gadgets()) do 
			if gadget and gadget.ammo_base then
				underbarrel_ammo_amount = gadget:ammo_base():get_ammo_total()
				break
			end
		end
	end)
end

Hooks:PostHook(RaycastWeaponBase,"add_ammo","hevhud_raycastweaponbase_addammo_post",function(self, ratio, add_amount_override)
	local picked_up,add_amount = Hooks:GetReturn()
	
	if picked_up then
		local slot = self:selection_index()
		
		if DETECT_UNDERBARREL_AMMO then
			for i,gadget in pairs(self:get_all_override_weapon_gadgets()) do 
				if gadget and gadget.ammo_base then
					local underbarrel_add_amount = gadget:ammo_base():get_ammo_total() - underbarrel_ammo_amount
					if underbarrel_add_amount >= 1 then
						-- it looks like vanilla pd2 adds the underbarrel ammo added to main ammo added when reporting ammo picked up,
						-- but this doesn't work- reports a negative value
						--add_amount = add_amount - underbarrel_add_amount 
						local override_weapon_icon,override_weapon_rect = "guis/textures/pd2/blackmarket/icons/weapons/outline/contraband_m203",nil
						HEVHUD:ShowAmmoPickup(slot + 2,gadget.name_id,underbarrel_add_amount,nil,override_weapon_icon,override_weapon_rect)
					end
					break
				end
			end
		end
		
		if add_amount >= 1 then -- todo show decimal setting
			local weapon_id = self:get_name_id()
			HEVHUD:ShowAmmoPickup(slot,weapon_id,add_amount,HEVHUD._font_icons[HEVHUD.GetHL2WeaponIcons(weapon_id) or ""],nil,nil,nil)
		end
		
		
		--[[
		local underbarrel_ammo = {}
		local override_weapon_icon,override_weapon_rect = "guis/textures/pd2/blackmarket/icons/weapons/outline/contraband_m203",nil
		for i,gadget in pairs(self:get_all_override_weapon_gadgets()) do 
		
			if gadget and gadget.ammo_base then
				local ammo_base = gadget:ammo_base()
				underbarrel_ammo[i] = {
					gadget = gadget,
					ammo_base = ammo_base,
					amount = ammo_base:get_ammo_total()
				}
					
				local underbarrel_add_amount = ammo_base:get_ammo_total() - data.amount
				if underbarrel_add_amount > 0 then
					add_amount = add_amount - underbarrel_add_amount
					data.add_amount = add_amount
					
					if not SHOW_UNDERBARREL_AFTER_MAIN_AMMO then
						HEVHUD:ShowAmmoPickup(slot + 2,gadget.name_id,add_amount,nil,override_weapon_icon,override_weapon_rect)
					end
				end
			end
		end
		
		local weapon_id = self:get_name_id()
		HEVHUD:ShowAmmoPickup(slot,weapon_id,add_amount,HEVHUD._font_icons[HEVHUD.GetHL2WeaponIcons(weapon_id) or ""],nil,nil,nil)
		if SHOW_UNDERBARREL_AFTER_MAIN_AMMO then
			-- it's technically slightly less efficient to do this,
			-- but also potentially annoying if players wish to see their main weapon pickup first
			local override_weapon_icon,override_weapon_rect = "guis/textures/pd2/blackmarket/icons/weapons/outline/contraband_m203",nil
			for i,data in pairs(underbarrel_ammo) do 
				HEVHUD:ShowAmmoPickup(slot + 2,gadget.name_id,data.add_amount,nil,override_weapon_icon,override_weapon_rect)
			end
		end
	--]]
	end
end)