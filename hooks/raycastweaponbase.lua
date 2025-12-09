local main_ammo_amount = 0
local underbarrel_ammo_amount = {}


-- this is a stupid ass way to detect underbarrel ammo but the vanilla pd2 func doesn't return ammo data for underbarrels

local function pre_check_ammo(self,...)
	main_ammo_amount = self:get_ammo_total()
	for i,gadget in pairs(self:get_all_override_weapon_gadgets()) do 
		if gadget and gadget.ammo_base then
			underbarrel_ammo_amount[i] = gadget:ammo_base():get_ammo_total()
		end
	end
end

local function post_check_ammo(self,...)
	local picked_up,_ = Hooks:GetReturn() -- in add_ammo_from_bag the return value is the amount of ammo taken from the ammo bag
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

Hooks:PreHook(RaycastWeaponBase,"add_ammo","hevhud_raycastweaponbase_addammo_pre",pre_check_ammo)
Hooks:PostHook(RaycastWeaponBase,"add_ammo","hevhud_raycastweaponbase_addammo_post",post_check_ammo)

Hooks:PreHook(RaycastWeaponBase,"add_ammo_from_bag","hevhud_raycastweaponbase_addammofrombag_pre",pre_check_ammo)
Hooks:PostHook(RaycastWeaponBase,"add_ammo_from_bag","hevhud_raycastweaponbase_addammofrombag_post",post_check_ammo)

--add_ammo_ratio() also exists but isn't used