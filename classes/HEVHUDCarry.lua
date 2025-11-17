local HEVHUDCarry = blt_class(HEVHUDCore:require("classes/HEVHUDBase"))
local AnimateLibrary = HEVHUDCore:require("classes/AnimateLibrary")

function HEVHUDCarry:init(panel,settings,config)
	HEVHUDCarry.super.init(self,panel,settings,config,...)
	
	local vars = self._config.Carry
	self._panel = panel:panel({
		name = "carry",
		w = vars.CARRY_W,
		h = vars.CARRY_H,
		x = vars.CARRY_X,
		y = vars.CARRY_Y,
		valign = "bottom",
		halign = "right"
	})
	self._panel:rect({
		name = "debug",
		color = Color.red,
		alpha = 0.1
	})
	--individual panels per bag are generated separately
	--	on bag picked up, since centered text does not seem to re-center correctly when a panel's size changes
	
	-- anim threads here
	
	
	self:setup()
end

function HEVHUDCarry:setup()
	local vars = self._config.Carry
	self._panel:configure({
		w = vars.CARRY_W,
		h = vars.CARRY_H,
		x = vars.CARRY_X,
		y = vars.CARRY_Y
	})
	
	self._CARRY_INTRO_ANIM_DURATION = vars.CARRY_INTRO_ANIM_DURATION
	self._CARRY_OUTRO_ANIM_DURATION = vars.CARRY_OUTRO_ANIM_DURATION
	
	self._carry_x1 = 0
	self._carry_y1 = 0
	
	-- outro positions
	self._carry_x2 = 0
	self._carry_y2 = 0
end

function HEVHUDCarry:show_carry_bag(carry_id,value)
	self:_hide_carry_bag()
	
	local vars = self._config.Carry
	
	local bag = self._panel:panel({
		name = "bag",
		w = vars.BAG_W,
		h = vars.BAG_H
	})
	-- icon
	-- label (carry name)
	-- value representation? dollar/regional currency signs?
	-- weight representation? probably color
	
	local cb_done
	--self._anim_whatever = bag:animate(AnimateLibrary.animate_move_lerp,cb_done,self._CARRY_OUTRO_ANIM_DURATION,nil,-bag:h())
end

function HEVHUDCarry:hide_carry_bag()
	
	local cb = function() self._panel:clear() end
	
end

function HEVHUDCarry:_hide_carry_bag()
	self._panel:clear()
	--self.anim_thread_whatever = nil
end



return HEVHUDCarry