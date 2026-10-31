InteractionAnimationsConfig = InteractionAnimationsConfig or {}
InteractionAnimationsConfig._data_path = SavePath .. "intanims_data.txt"
InteractionAnimationsConfig._data = InteractionAnimationsConfig._data or {
    anims_enabled = {}
}

function InteractionAnimationsConfig:Save()
    local file = io.open(self._data_path, "w+")
    if file then
        file:write(json.encode(self._data))
        file:close()
    end
end

function InteractionAnimationsConfig:SaveDefaults()
    for _, v in pairs(tweak_data.interaction.animations or {}) do
        self._data.anims_enabled[v.animation_state_machine_name] = true
    end
    self:Save()
end

function InteractionAnimationsConfig:Load()
	local file = io.open(self._data_path, "r" )
	if file then
		self._data = json.decode( file:read("*all") )
		file:close()
    else
        self:SaveDefaults()
    end
end

Hooks:Add("LocalizationManagerPostInit", "LocalizationManagerPostInit_intanims", function(localization_manager)
    localization_manager:add_localized_strings({
      ["intanims_name"] = "Interaction Animations",
      ["intanims_desc"] = "",
    })
end)

Hooks:Add("MenuManagerSetupCustomMenus", "MenuManagerSetupCustomMenus_intanims", function(menu_manager, nodes)
    MenuHelper:NewMenu("intanims_menu")
end)

Hooks:Add("MenuManagerInitialize", "MenuManagerInitialize_intanims", function(menu_manager)
    MenuCallbackHandler.callback_intanims_save = function(self, item)
        InteractionAnimationsConfig:Save()
    end

    for _, v in pairs(tweak_data.interaction.animations or {}) do
        MenuCallbackHandler["callback_disable_anim_".. v.animation_state_machine_name] = function(self, item)
            InteractionAnimationsConfig._data.anims_enabled[v.animation_state_machine_name] = item:value() == "on"
        end
    end

    InteractionAnimationsConfig:Load()
end)

Hooks:Add("MenuManagerPopulateCustomMenus", "MenuManagerPopulateCustomMenus_intanims", function( menu_manager, nodes )
    local processed_anims = {}

    for _, v in pairs(tweak_data.interaction.animations or {}) do
        local name = v.animation_state_machine_name
        if not processed_anims[name] then
            MenuHelper:AddToggle({
                id = tostring(v.animation_state_machine_name),
                menu_id = "intanims_menu",
                localized = false,
                title = v.animation_state_machine_name,
                desc = "Whether the animation with ID ".. tostring(name) .. " should be enabled",
                value = InteractionAnimationsConfig._data.anims_enabled[name],
                callback = "callback_disable_anim_".. name
            })

            processed_anims[name] = true
        end
    end
end)

Hooks:Add("MenuManagerBuildCustomMenus", "MenuManagerBuildCustomMenus_intanims", function(menu_manager, nodes)  
    nodes["intanims_menu"] = MenuHelper:BuildMenu("intanims_menu", {back_callback = "callback_intanims_save"})    
    MenuHelper:AddMenuItem(nodes.blt_options, "intanims_menu", "intanims_name", "intanims_desc")
end)