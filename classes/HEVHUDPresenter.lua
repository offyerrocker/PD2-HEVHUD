local HEVHUDPresenter = blt_class(HEVHUDCore:require("classes/HEVHUDBase"))
local AnimateLibrary = HEVHUDCore:require("classes/AnimateLibrary")

function HEVHUDPresenter:init(panel,settings,config,...)
	HEVHUDPresenter.super.init(self,panel,settings,config,...)
	self._panel = panel:panel({
		name = "pickup",
		valign = "grow",
		halign = "grow",
		w = panel:w(),
		h = panel:h(),
		layer = 1,
		alpha = 1
	})

	self._present_queue = {}
	self._presenting = nil
	
	
	self:setup()
end

function HEVHUDPresenter:setup()
--	self._panel:clear()
	local vars = self._config.Presenter
	self._TEXT_COLOR_FULL = HEVHUD.colordecimal_to_color(self._settings.color_hl2_yellow)
	self._TEXT_COLOR_HALF = HEVHUD.colordecimal_to_color(self._settings.color_hl2_orange)
	self._TEXT_COLOR_NONE = HEVHUD.colordecimal_to_color(self._settings.color_hl2_red)
	
	self._objective_text_color = Color("ababab")
	self._objective_flash_color = Color("ffa000")
	
	
	self._present_box = self._panel:panel({
		name = "present_box",
		valign = "grow",
		halign = "grow",
		alpha = 1,
		layer = 1,
		visible = true
	})
	
	self._title = self._present_box:text({
		name = "title",
		text = "",
		align = vars.PRESENTER_TITLE_ALIGN,
		vertical = vars.PRESENTER_TITLE_VERTICAL,
		x = vars.PRESENTER_TITLE_X,
		y = vars.PRESENTER_TITLE_Y,
		valign = "grow",
		halign = "grow",
		font = vars.PRESENTER_TITLE_FONT_NAME,
		font_size = vars.PRESENTER_TITLE_FONT_SIZE,
		color = self._objective_text_color,
		blend_mode = vars.PRESENTER_TITLE_BLEND_MODE,
		layer = 2
	})
	
	self._desc = self._present_box:text({
		name = "desc",
		text = "",
		align = vars.PRESENTER_DESC_ALIGN,
		vertical = vars.PRESENTER_DESC_VERTICAL,
		x = vars.PRESENTER_DESC_X,
		y = vars.PRESENTER_DESC_Y,
		valign = "grow",
		halign = "grow",
		font = vars.PRESENTER_DESC_FONT_NAME,
		font_size = vars.PRESENTER_DESC_FONT_SIZE,
		color = self._objective_text_color,
		blend_mode = vars.PRESENTER_DESC_BLEND_MODE,
		layer = 2
	})
	
end

function HEVHUDPresenter:present(params)
--	logall(params)
--	foo = params
	if self._presenting then
		table.insert(self._present_queue, params)

		return
	end

	if params.present_mid_text then
		self:_present_information(params)
	end
end

function HEVHUDPresenter:_present_information(params)
--	self._present_box:stop()
--	local alpha_duration = 0.5
--	self._present_box:animate(AnimateLibrary.animate_alpha_lerp,callback(self,self,"animate_show_text",params),alpha_duration,nil,1)
	self:animate_show_text(params)
	
	--present_panel:animate(callback(self, self, "_animate_present_information"), callback_params)

--	self._present_box:show()
	self._presenting = true
end

function HEVHUDPresenter:animate_show_text(params)
	if params.event then
		managers.hud._sound_source:post_event(params.event)
	end
	
	
	
	local duration = params.time or 4
	
	local col_1 = self._objective_text_color
	local col_2 = self._objective_flash_color
	
	
	self._desc:stop()
	self._desc:set_text("")
	self._desc:set_alpha(1)
	self._desc:clear_range_color(0,utf8.len(params.text))
	
	
	local vars = self._config.Objectives
	
	local function cb_animate_fadeout(o,cb)
		local alpha_duration = vars.ANIM_OBJECTIVE_FADEOUT_DURATION
		o:animate(AnimateLibrary.animate_alpha_lerp,cb,alpha_duration,nil,0)
	end
	
	local title = params.title
	self._title:stop()
	self._title:set_alpha(1)
	self._title:set_text("")
	if title then 
		self._title:clear_range_color(0,utf8.len(title))
		-- show title -> show desc -> hold visible -> fadeout each -> queue next
		
		-- show title
		self._title:animate(AnimateLibrary.animate_text_mission,
			function(_title)
				-- too many nested callbacks!
				-- ... surely it's fine, right?
				
				-- show desc
				self._desc:animate(AnimateLibrary.animate_text_mission,
					function(_desc)
						-- hold
						_desc:animate(AnimateLibrary.animate_wait,params.time,
							function()
								-- fadeout both
								cb_animate_fadeout(_title)
								cb_animate_fadeout(_desc,
									function()
										-- queue next
										self:_present_done()
									end
								)
							end
						)
					end,
					utf8.to_upper(params.text or ""),nil,col_1,col_2,nil
				)
				
			end,utf8.to_upper(title),nil,col_1,col_2,nil
		)
	else
		local duration = params.time
		self._title:clear_range_color(0,1)
		
		-- only animate desc, don't wait for title
		self._desc:animate(AnimateLibrary.animate_wait,params.time,
			function(_desc)
				-- fadeout both
				cb_animate_fadeout(_desc,
					function()
						-- queue next
						self:_present_done()
					end
				)
			end
		)
	end
end

-- check next item in the queue
function HEVHUDPresenter:_present_done()
	if #self._present_queue > 0 then
		if not self._presenting then
			local queued = table.remove(self._present_queue, 1)
			self:_present_information(queued)
			return
		end
	end
--	self._present_box:hide()
	self._presenting = false
end


return HEVHUDPresenter