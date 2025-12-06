--local SHOW_UNDERBARREL_AFTER_MAIN_AMMO = false
local DETECT_UNDERBARREL_AMMO = true

local main_ammo_amount = 0
local underbarrel_ammo_amount = {}
if DETECT_UNDERBARREL_AMMO then
	-- this is a stupid ass way to detect underbarrel ammo but the vanilla pd2 func doesn't return ammo data for underbarrels 
	Hooks:PreHook(RaycastWeaponBase,"add_ammo","hevhud_raycastweaponbase_addammo_pre",function(self, ratio, add_amount_override)
		main_ammo_amount = self:get_ammo_total()
		for i,gadget in pairs(self:get_all_override_weapon_gadgets()) do 
			if gadget and gadget.ammo_base then
				underbarrel_ammo_amount[i] = gadget:ammo_base():get_ammo_total()
			end
		end
	end)
end

Hooks:PostHook(RaycastWeaponBase,"add_ammo","hevhud_raycastweaponbase_addammo_post",function(self, ratio, add_amount_override)
	local picked_up,_ = Hooks:GetReturn()
	if picked_up then
	
		-- main weapon pickup
		if main_ammo_amount then
			local main_ammo = self:get_ammo_total() - main_ammo_amount
			
			if main_ammo > 0 then
				local weapon_id = self._name_id
				local wtd = tweak_data.weapon[weapon_id] or tweak_data.weapon.amcar
				HEVHUD:ShowAmmoPickup(wtd.use_data.selection_index,weapon_id,main_ammo,nil,nil,nil)
			end
			main_ammo_amount = nil
		end
		
		-- underbarrel pickup
		if DETECT_UNDERBARREL_AMMO then
			for i,gadget in pairs(self:get_all_override_weapon_gadgets()) do 
				if gadget and gadget.ammo_base then
					if underbarrel_ammo_amount[i] then
						local underbarrel_ammo = gadget:ammo_base():get_ammo_total() - underbarrel_ammo_amount[i]
						underbarrel_ammo_amount[i] = nil
						if underbarrel_ammo >= 1 then
							local weapon_id = gadget.name_id
							local wtd = tweak_data.weapon[weapon_id]
							if wtd then
								local override_weapon_icon,override_weapon_rect = "guis/textures/pd2/blackmarket/icons/weapons/outline/contraband_m203",nil
								HEVHUD:ShowAmmoPickup(wtd.use_data.selection_index,weapon_id,underbarrel_ammo,nil,override_weapon_icon,override_weapon_rect)
							end
						end
					end
				end
			end
		end
	end
end)