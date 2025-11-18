-- Mod core file, for functions not directly related to HUD-
-- eg. player settings, IO, localization

if HEVHUDCore and HEVHUDCore.setup_load_done then
	-- This mod is loaded redundantly by BeardLib and SBLT,
	-- because I'm trying to move away from BeardLib as a mandatory dependency
	return
end

HEVHUDCore.default_settings = {
	color_hl2_yellow = 0xFFD040,
	color_hl2_yellow_bright = 0xF0D210,
	color_hl2_red = 0xbb2d12,
	color_hl2_red_bright = 0xBB0200, --80000?
	color_hl2_orange = 0xFFA000,
	sounds_enabled = true,
	language_name = "english.json",	 	-- The name of the localization file being used
	_language_index = 1, 			-- Internally used to display the current language option; do not change
	hud_teammate_enabled = true
}
HEVHUDCore.MOD_PATH = HEVHUDCore.GetPath and HEVHUDCore:GetPath() or ModPath
HEVHUDCore.settings = table.deep_map_copy(HEVHUDCore.default_settings)
HEVHUDCore.config = { -- Loaded from hevhud_vars.ini
	--Player = {},
	Teammate = {},
	General = {},
	Vitals = {},
	Weapons = {},
	Carry = {},
	Hint = {},
	Crosshair = {},
	Chat = {},
	Assault = {},
	TabScreen = {}
}
HEVHUDCore._sort_config = { -- order to sort ini file during write
	"General",
	"Vitals",
	"Carry",
	"Hint",
	"Crosshair",
	"Chat",
	"Assault",
	"TabScreen"
}

HEVHUDCore.languages = {}
-- This will hold data for each of the available languages that HEVHUDCore has been translated to (including english)
HEVHUDCore.ASSETS_PATH = HEVHUDCore.MOD_PATH .. "assets/" 	-- Path to the mod assets (textures, fonts, etc)
HEVHUDCore.USER_SETTINGS_PATH = SavePath .. "hevhud_settings.json" 	-- Path to the user-defined settings
HEVHUDCore.USER_CONFIG_PATH = SavePath .. "hevhud_vars.ini"			-- Path to the advanced config file
HEVHUDCore.DEFAULT_USER_CONFIG_PATH = HEVHUDCore.MOD_PATH .. "hevhud_vars.ini"	-- Path to the defaults for the advanced config file
HEVHUDCore.LOCALIZATION_DIRECTORY_PATH = HEVHUDCore.MOD_PATH .. "l10n/" 		-- Path to the folder containing localization files

HEVHUDCore.menu_data = {
	populated_languages_menu = false,
	menu_ids = {
		main = "menu_hevhud_main",
		general = "menu_hevhud_general"
	}
}

-- settings = user preferences available to be changed in the menu user interface; saved as json
-- config = variables and "advanced" tweaks that do not have controls in the user interface; saved as ini

HEVHUDCore._libraries = {}
function HEVHUDCore:require(path) -- local only; relative path to HEVHUD folder
	if self._libraries[path] then
		return self._libraries[path]
	end
	
	local result,err = blt.vm.dofile(self.MOD_PATH .. path .. ".lua")
	if not result and err then
		Application:error(err)
		return
	end
	
	self._libraries[path] = result
	return result
end

function HEVHUDCore:Log(a,...)
	if _G.Log then
		return _G.Log("[HEVHUDCore]" .. tostring(a))
	end
end

function HEVHUDCore:Print(...)
	if _G.Print then
		return _G.Print(...)
	end
end

function HEVHUDCore:LoadConfig(path)
	if file.FileExists(path) then
		local LIP = self:require("classes/LIP")
		local config = LIP.load(path)
		if config then
			for cat,data in pairs(config) do 
				if self.config[cat] and type(data) == "table" then
					for k,v in pairs(data) do
						self.config[cat][k] = v
					end
				else
					--self.config[k] = v
				end
			end
		else
			self:Log("Invalid config file!",path)
		end
	else
		self:Log("No config file",path)
	end
	Hooks:Call("hevhud_on_settings_changed",self.config)
end

function HEVHUDCore:SaveConfig() -- this is not used anywhere (and honestly it shouldn't be) but it does work!
	local LIP = self:require("classes/LIP")
	LIP.save(self.USER_CONFIG_PATH,self.config,self._sort_config)
end

function HEVHUDCore:LoadSettings()
	local file = io.open(self.USER_SETTINGS_PATH, "r")
	if file then
		for k, v in pairs(json.decode(file:read("*all"))) do
			self.settings[k] = v
		end
	end
	
	Hooks:Call("hevhud_on_config_changed",self.settings)
end

function HEVHUDCore:SaveSettings()
	local file = io.open(self.USER_SETTINGS_PATH,"w+")
	if file then
		file:write(json.encode(self.settings))
		file:close()
	end
end

	--Registers assets into the game's db so that they can be loaded later 
function HEVHUDCore:CheckFontResourcesAdded(skip_load)
	local font_ids = Idstring("font")
	local texture_ids = Idstring("texture")
	
	local fonts = {
		hl2_icons = "fonts/halflife2", 
		hl2_text = "fonts/trebuchet",
		hl2_vitals = "fonts/tahoma_bold"
	}
	
	for font_id,font_path in pairs(fonts) do 
		if DB:has(font_ids, font_path) then 
			self:Log("Font " .. font_id .. " at path " .. font_path .. " is verified.")
		else
			--assume that if the .font is not loaded, then the .texture is not either (both are needed anyway)
			self:Log("Font " .. font_id .. " at path " .. font_path .. " is not created!")
			if not skip_load then 
				local full_asset_path = self.ASSETS_PATH .. font_path
				BLT.AssetManager:CreateEntry(Idstring(font_path),font_ids,full_asset_path .. ".font")
				BLT.AssetManager:CreateEntry(Idstring(font_path),texture_ids,full_asset_path .. ".texture")
			end
		end
	end
end

--Loads assets into memory so that they can be used in-game
function HEVHUDCore:CheckFontResourcesReady(skip_load,done_loading_cb)
	self:Log("Checking font assets...")
	local font_ids = Idstring("font")
	local texture_ids = Idstring("texture")
	
	local dyn_pkg = DynamicResourceManager.DYN_RESOURCES_PACKAGE

	if done_loading_cb and done_loading_cb ~= false then 
	
		done_loading_cb = function(done,resource_type_ids,resource_ids)
			if done then 
				self:Log("Completed manual asset loading for " .. tostring(resource_ids))
			end
		end
		
	end
	
	local fonts = {
		hl2_icons = "fonts/halflife2", 
		hl2_text = "fonts/trebuchet",
		hl2_vitals = "fonts/tahoma_bold"
	}
	
	local font_resources_ready = true
	for font_id,font_path in pairs(fonts) do 
		if not managers.dyn_resource:is_resource_ready(font_ids,Idstring(font_path),dyn_pkg) then 
			if not skip_load then 
				--register_loading(font_path)

				self:Log("Creating DB entry for " .. tostring(font_ids) .. ", " .. tostring(font_path) .. ", " .. tostring(self.ASSETS_PATH .. font_path .. ".font"))
				
				managers.dyn_resource:load(font_ids, Idstring(font_path), dyn_pkg, done_loading_cb)
				managers.dyn_resource:load(texture_ids, Idstring(font_path), dyn_pkg, done_loading_cb)
				
			end
			self:Log("Font " .. tostring(font_id) .. " is not ready!" .. (skip_load and " Skipped loading for " or " Started manual load for ") .. font_path)
			font_resources_ready = false
		else
			self:Log("Font asset " .. font_id .. " at path " .. font_path .. " is ready.")
		end
	end
	return font_resources_ready
end


function HEVHUDCore:LoadLanguage(localizationmanager,user_language)
	localizationmanager = localizationmanager or managers.localization
	if localizationmanager then 
		user_language = user_language or self:GetCurrentLanguageName()
		local language_data = user_language and self.languages[user_language]
		if language_data then
			if language_data.file_path then
				localizationmanager:load_localization_file(language_data.file_path,true)
				self.settings._language_index = language_data.index
			else
				self:Log("ERROR! No file path for language: " .. tostring(user_language))
			end
		else
			self:Log("ERROR! Bad language data for language: " .. tostring(user_language))
		end
	else
		self:Log("ERROR! LocalizationManager not initialized!")
	end
end

-- get the filename (including extension) of the current language file
function HEVHUDCore:GetCurrentLanguageName()
	return self.settings.language_name
end

-- Index the localization folder to get a list of all available languages
function HEVHUDCore:LoadLanguageFiles()
	-- For each localization file in the localization folder...
	for i,filename in ipairs(SystemFS:list(self.LOCALIZATION_DIRECTORY_PATH)) do 
		local localization_file_path = self.LOCALIZATION_DIRECTORY_PATH .. filename
		local file = io.open(localization_file_path, "r")
		-- ...open the file...
		if file then
		
			-- ...read the contents and get the name of the language from the contents (not from the filename!)...
			local localized_strings = json.decode(file:read("*all"))
			local lang_name = localized_strings and (type(localized_strings) == "table") and localized_strings.menu_hevhud_language_name
			-- ...and "register" the file so that the mod knows that it is a selectable language
			if lang_name then 
				self.languages[filename] = {
					index = i,
					localized_language_name = lang_name,
					file_path = localization_file_path
				}
			end
		
		end
		-- If this file is the currently selected language,
		-- Then set the _language_index so that the multiple choice setting reflects that this is the currently selected language
		if filename == self:GetCurrentLanguageName() then 
			self.settings._language_index = i
			-- Language order is not guaranteed- particularly if a new language is added which interferes with the alphabetical order-
			-- which is why the filename is saved and not the index number of the language,
			-- and the index number is "generated" on load instead of being written here in settings
		end
	end
end

-- Initially, load the default language (english)
Hooks:Add("LocalizationManagerPostInit", "hevhud_LocalizationManagerPostInit",
	function(self)
		-- Load default localization
		HEVHUDCore:LoadLanguage(self)
	end
)

Hooks:Add("MenuManagerSetupCustomMenus", "hevhud_MenuManagerSetupCustomMenus", function(menu_manager, nodes)
	for _,menu_id in pairs(HEVHUDCore.menu_data.menu_ids) do 
		MenuHelper:NewMenu(menu_id)
	end
end)

Hooks:Add("MenuManagerPopulateCustomMenus", "hevhud_MenuManagerPopulateCustomMenus", function(menu_manager, nodes)
	-- general options
	MenuHelper:AddMultipleChoice({
		id = "hevhud_language_name",
		title = "menu_hevhud_language_name_title",
		desc = "menu_hevhud_language_name_desc",
		callback = "callback_hevhud_language_name",
		items = {},	-- populated later
		value = HEVHUDCore.settings._language_index,
		menu_id = HEVHUDCore.menu_data.menu_ids.general,
		priority = 1
	})
	
	MenuHelper:AddToggle({
		id = "hevhud_general_sounds_enabled",
		title = "menu_hevhud_sounds_enabled_title",
		desc = "menu_hevhud_sounds_enabled_desc",
		callback = "callback_hevhud_sounds_enabled",
		value = HEVHUDCore.settings.sounds_enabled,
		menu_id = HEVHUDCore.menu_data.menu_ids.general,
		priority = 2
	})
end)

Hooks:Add("MenuManagerBuildCustomMenus", "hevhud_MenuManagerBuildCustomMenus", function( menu_manager, nodes )
	--create main menu
	local main_menu_id = HEVHUDCore.menu_data.menu_ids.main
	local menu_main = MenuHelper:BuildMenu(
		main_menu_id,{
			area_bg = "none",
			back_callback = nil, --"callback_id",
			focus_changed_callback = nil --"callback_id"
		}
	)
	nodes[main_menu_id] = menu_main
	MenuHelper:AddMenuItem(nodes.blt_options,main_menu_id,"menu_hevhud_main_title","menu_hevhud_main_desc")
	
	-- create general submenu
	local general_menu_id = HEVHUDCore.menu_data.menu_ids.general
	nodes[general_menu_id] = MenuHelper:BuildMenu(
		general_menu_id,{
			area_bg = "none",
			back_callback = nil,
			focus_changed_callback = "callback_hevhud_menu_general_focus"
		}
	)
	MenuHelper:AddMenuItem(menu_main,general_menu_id,"menu_hevhud_general_title","menu_hevhud_general_desc")
	
end)

Hooks:Add("MenuManagerInitialize", "hevhud_initmenu", function(menu_manager)
	-- anything that changes settings should then call:
	-- Hooks:Add("hevhud_on_config_changed",self.settings)
	
	
	MenuCallbackHandler.callback_hevhud_menu_general_focus = function(self,focus)
		if focus then
			if HEVHUDCore.menu_data.populated_languages_menu then
				return
			end
			
			local menu_item = MenuHelper:GetMenu(HEVHUDCore.menu_data.menu_ids.general) or {_items = {}}
			for _,item in pairs(menu_item._items) do 
				if item._parameters and item._parameters.name == "hevhud_language_name" then 
					for lang_name,lang_data in pairs(HEVHUDCore.languages) do 
						item:add_option(
							CoreMenuItemOption.ItemOption:new(
								{
									_meta = "option",
									text_id = lang_data.localized_language_name,
									value = lang_data.index,
									localize = false
								}
							)
						)
					end
					item:set_value(HEVHUDCore.settings._language_index)
					break
				end
			end
			HEVHUDCore.menu_data.populated_languages_menu = true
		end
	end
	
	MenuCallbackHandler.callback_hevhud_language_name = function(self,item)
		local index = item:value()
		HEVHUDCore.settings._language_index = index
		for filename,data in pairs(self._languages) do 
			if data.index == index then
				HEVHUDCore:LoadLanguage(nil,filename)
				HEVHUDCore.settings.language_name = filename
				HEVHUDCore:SaveSettings()
				return
			end
		end
		
		HEVHUDCore:Log("Error loading localization! Invalid selection index: " .. tostring(index))
	end
	
	MenuCallbackHandler.callback_hevhud_sounds_enabled = function(self,item)
		HEVHUDCore.settings.sounds_enabled = item:value() == "on"
	end
	
	HEVHUDCore:LoadSettings()
	HEVHUDCore:LoadConfig(HEVHUDCore.USER_CONFIG_PATH)
	--[[
	--creates colorpicker menu for AdvancedCrosshair mod; this menu is reused for all color-related callbacks in this mod,
	--so it's also necessary to also update the callback whenever calling the menu
	if _G.ColorPicker then 
		AdvancedCrosshair._colorpicker = AdvancedCrosshair._colorpicker or ColorPicker:new("advancedcrosshairs",{},callback(AdvancedCrosshair,AdvancedCrosshair,"set_colorpicker_menu"))
	end
	--]]
	--MenuHelper:LoadFromJsonFile(AdvancedCrosshair.path .. "menu/menu_compat.json", AdvancedCrosshair, AdvancedCrosshair.settings)
	
	HEVHUDCore:CheckFontResourcesReady()
end)






HEVHUDCore:LoadConfig(HEVHUDCore.DEFAULT_USER_CONFIG_PATH)
HEVHUDCore:LoadLanguageFiles()
_G.HEVHUD = HEVHUDCore:require("HEVHUD")
HEVHUDCore:CheckFontResourcesAdded()
HEVHUDCore.setup_load_done = true

