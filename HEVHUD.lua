local HEVHUD = {}


function HEVHUD.color_to_colorstring(color) -- from colorpicker; serialize a Color userdata as a hexadecimal string
	return string.format("%02x%02x%02x", math.min(math.max(color.r * 255,0),0xff),math.min(math.max(color.g * 255,0),0xff),math.min(math.max(color.b * 255,0),0xff))
end

--function HEVHUD.colordecimal_to_string(n) end -- todo

function HEVHUD.colordecimal_to_colorstring(n)
	return string.format("%06x",n)
end

function HEVHUD.colordecimal_to_color(n)
	return Color(string.format("%06x",n))
end

function HEVHUD:CreateHUD(parent_hud)
	self._ws = managers.hud._workspace --managers.gui_data:create_fullscreen_workspace()
	if not parent_hud then 
		return
	end
	if alive(self._panel) then
		self._panel:parent():remove(self._panel)
		self._panel = nil
	end
	
	local hl2 = parent_hud:panel({--self._ws:panel():panel({
		name = "hevhud"
	})
	self._panel = hl2
	
	local settings = HEVHUDCore.settings
	local config = HEVHUDCore.config
	
	self._hud_vitals = HEVHUDCore:require("classes/HEVHUDVitals"):new(hl2,settings,config)
	--self._hud_carry = HEVHUDCore:require("classes/HEVHUDCarry"):new(hl2,settings,config)
	--self._hud_hint = HEVHUDCore:require("classes/HEVHUDHint"):new(hl2,settings,config)
	--self._hud_objectives = HEVHUDCore:require("classes/HEVHUDObjectives"):new(hl2,settings,config)
	
	
	
	
end

function HEVHUD:UpdateGame(t,dt)
	-- game update
	local player = managers.player:local_player()
	if player then
		self._hud_vitals:set_sprint_on(player:movement():current_state():running())
	end
end
Hooks:Add("GameSetupUpdate","hevhud_updategame",callback(HEVHUD,HEVHUD,"UpdateGame"))

function HEVHUD:CheckWeaponGadgets(weap_base)
	if not weap_base._assembly_complete then
		return nil
	end
	
	local gadgets = managers.weapon_factory:get_parts_from_weapon_by_type_or_perk("gadget", weap_base._factory_id, weap_base._blueprint)
	if gadgets then
		for i, id in ipairs(gadgets) do
			local gadget = weap_base._parts[id]
			local gadget_base = gadget and gadget.unit:base()
			if gadget_base then
				local gadget_type = gadget_base.GADGET_TYPE
				if gadget_type == WeaponFlashLight.GADGET_TYPE then -- "flashlight"
					if gadget_base:is_on() then
						-- if any flashlights are on in the current weapon, show flashlight indicator in hud
						return self:SetFlashlightState(true)
					end
				end
			end
		end
	end
	return self:SetFlashlightState(false)
end

function HEVHUD:SetFlashlightState(state)
	self._hud_vitals:set_flashlight_on(state)
	return state
end

--[[
function HEVHUD:UpdatePaused(t,dt)
	-- paused update
end
Hooks:Add("GameSetupUpdate","hevhud_updatepaused",callback(HEVHUD,HEVHUD,"UpdatePaused"))
--]]

return HEVHUD