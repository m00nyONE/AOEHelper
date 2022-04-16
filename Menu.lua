local startLoadTime = GetGameTimeMilliseconds()

AOEHelper = AOEHelper or {}
AOEHelper.loadTime = AOEHelper.loadTime or 0
local LAM2 = LibAddonMenu2

-- create a custom menu by using LibCustomMenu
function AOEHelper.createAddonMenu()
    local panelData = {
        type = "panel",
        name = "AOEHelper",
        displayName = "AOEHelper",
        author = "|cFFC0CBm00ny|r",
        version = AOEHelper.version,
        website = "https://github.com/m00nyONE/AOEHelper",
        feedback = "",
        donation = AOEHelper.donate,
        slashCommand = "/aoesettings",
        registerForRefresh = true,
        registerForDefaults = false,
    }

    local optionsTable = {
        [1] = {
            type = "description",
            text = "|cff6600" .. GetString(AOEHELPER_MENU_DESCRIPTION) .. "|r",
            width = "full",
        },
        [2] = {
            type = "header",
            name = GetString(AOEHELPER_MENU_CURRENT_HEADER_DESCRIPTION),
            width = "full",
        },
        [3] = {
            type = "colorpicker",
            name = GetString(AOEHELPER_MENU_GENERAL_ENEMY_COLOR),
            tooltip = "The color of the AoEs that come from enemys",
			getFunc = function()
				local c = AOEHelper.GetGameColors().enemyColor
				return tonumber("0x" .. c:sub(1, 2)) / 255, tonumber("0x" .. c:sub(3, 4)) / 255, tonumber("0x" .. c:sub(5, 6)) / 255
			end,
			setFunc = function(red,green,blue,a)
                local colors = {}
				colors.enemyColor = string.format("%02x%02x%02x", red*255, green*255, blue*255)
                AOEHelper.SetGameColors(colors)
			end,
            width = "half"
		},
        [4] = {
            type = "slider",
            name = GetString(AOEHELPER_MENU_GENERAL_ENEMY_BRIGHTNESS),
            tooltip = "the brightness of the AoEs that come from enemys",
            getFunc = function() return GetSetting(SETTING_TYPE_COMBAT, COMBAT_SETTING_MONSTER_TELLS_ENEMY_BRIGHTNESS) end,
            setFunc = function(value) SetSetting(SETTING_TYPE_COMBAT, COMBAT_SETTING_MONSTER_TELLS_ENEMY_BRIGHTNESS, value) end,
            clampInput = false,
            width = "half",
            decimals = 0,
            step = 1,
            default = 50,
            min = 1,
            max = 100,
        },
        [5] = {
            type = "colorpicker",
            name = GetString(AOEHELPER_MENU_GENERAL_ALLY_COLOR),
            tooltip = "The color of the AoEs that come from friendlies",
			getFunc = function()
				local c = AOEHelper.GetGameColors().friendlyColor
				return tonumber("0x" .. c:sub(1, 2)) / 255, tonumber("0x" .. c:sub(3, 4)) / 255, tonumber("0x" .. c:sub(5, 6)) / 255
			end,
			setFunc = function(red,green,blue,a)
                local colors = {}
				colors.friendlyColor = string.format("%02x%02x%02x", red*255, green*255, blue*255)
                AOEHelper.SetGameColors(colors)
			end,
            width = "half"
		},
        [6] = {
            type = "slider",
            name = GetString(AOEHELPER_MENU_GENERAL_ALLY_BRIGHTNESS),
            tooltip = "the brightness of the AoEs that come from friendlies",
            getFunc = function() return GetSetting(SETTING_TYPE_COMBAT, COMBAT_SETTING_MONSTER_TELLS_FRIENDLY_BRIGHTNESS) end,
            setFunc = function(value) SetSetting(SETTING_TYPE_COMBAT, COMBAT_SETTING_MONSTER_TELLS_FRIENDLY_BRIGHTNESS, value) end,
            width = "half",
            decimals = 0,
            step = 1,
            default = 50,
            min = 1,
            max = 100,
        },
        [7] = {
            type = "divider"
        },
        [8] = {
            type = "button",
            name = "set for current Zone",
            tooltip = "set color for the current Zone you are in",
            func = function()
                local zoneID = GetZoneId(GetUnitZoneIndex("player"))
                AOEHelper.SetZoneColors(zoneID, AOEHelper.GetGameColors())
            end,
            width = "half",
            disabled = function() return not IsUnitInDungeon("player") end,
        },
        [9] = {
            type = "button",
            name = "reset",
            tooltip = "set color for current Zone",
            func = function()
                AOEHelper.SetGameColors(AOEHelper.savedVariables.defaultColors)
            end,
            width = "half",
        },

        [10] = {
            type = "submenu",
            name = function() return "current zone colors (" .. AOEHelper.filterName(GetUnitZone("player")) .. ")"  end,
            tooltip = "Colors for this Zone",
            disabled = function() if AOEHelper.savedVariables.savedZones[GetZoneId(GetUnitZoneIndex("player"))] == nil then return true end return false end,
            controls = {
                [1] = {
                    type = "colorpicker",
                    name = GetString(AOEHELPER_MENU_GENERAL_ENEMY_COLOR),
                    tooltip = "The color of the AoEs that come from enemys",
                    getFunc = function()
                        if AOEHelper.savedVariables.savedZones[GetZoneId(GetUnitZoneIndex("player"))] ~= nil then
                            local c = AOEHelper.savedVariables.savedZones[GetZoneId(GetUnitZoneIndex("player"))].enemyColor
                            return tonumber("0x" .. c:sub(1, 2)) / 255, tonumber("0x" .. c:sub(3, 4)) / 255, tonumber("0x" .. c:sub(5, 6)) / 255
                        end
                        return 0,0,0
                    end,
                    setFunc = function(red,green,blue,a)
                        local newColor = string.format("%02x%02x%02x", red*255, green*255, blue*255)
                        AOEHelper.savedVariables.savedZones[GetZoneId(GetUnitZoneIndex("player"))].enemyColor = newColor
                        SetSetting(SETTING_TYPE_COMBAT, COMBAT_SETTING_MONSTER_TELLS_ENEMY_COLOR, newColor)
                    end,
                    width = "half"
                },
                [2] = {
                    type = "slider",
                    name = GetString(AOEHELPER_MENU_GENERAL_ENEMY_BRIGHTNESS),
                    tooltip = "the brightness of the AoEs that come from enemys",
                    getFunc = function() 
                        if AOEHelper.savedVariables.savedZones[GetZoneId(GetUnitZoneIndex("player"))] ~= nil then
                            return AOEHelper.savedVariables.savedZones[GetZoneId(GetUnitZoneIndex("player"))].enemyBrightness
                        end
                        return 0
                    end,
                    setFunc = function(value)
                        AOEHelper.savedVariables.savedZones[GetZoneId(GetUnitZoneIndex("player"))].enemyBrightness = value
                        SetSetting(SETTING_TYPE_COMBAT, COMBAT_SETTING_MONSTER_TELLS_ENEMY_BRIGHTNESS, value)
                    end,
                    width = "half",
                    decimals = 0,
                    step = 1,
                    default = 50,
                    min = 1,
                    max = 100,
                },
                [3] = {
                    type = "colorpicker",
                    name = GetString(AOEHELPER_MENU_GENERAL_ALLY_COLOR),
                    tooltip = "The color of the AoEs that come from friendlies",
                    getFunc = function()
                        if AOEHelper.savedVariables.savedZones[GetZoneId(GetUnitZoneIndex("player"))] ~= nil then
                            local c = AOEHelper.savedVariables.savedZones[GetZoneId(GetUnitZoneIndex("player"))].friendlyColor
                        return tonumber("0x" .. c:sub(1, 2)) / 255, tonumber("0x" .. c:sub(3, 4)) / 255, tonumber("0x" .. c:sub(5, 6)) / 255
                        end
                        return 0,0,0
                    end,
                    setFunc = function(red,green,blue,a)
                        d("R: " .. red .. " G: " .. green .. " B: " .. blue .. " A: " .. a)
                        local newColor = string.format("%02x%02x%02x", red*255, green*255, blue*255)
                        AOEHelper.savedVariables.savedZones[GetZoneId(GetUnitZoneIndex("player"))].friendlyColor = newColor
                        SetSetting(SETTING_TYPE_COMBAT, COMBAT_SETTING_MONSTER_TELLS_FRIENDLY_COLOR, newColor)
                    end,
                    width = "half"
                },
                [4] = {
                    type = "slider",
                    name = GetString(AOEHELPER_MENU_GENERAL_ALLY_BRIGHTNESS),
                    tooltip = "the brightness of the AoEs that come from friendlies",
                    getFunc = function()
                        if AOEHelper.savedVariables.savedZones[GetZoneId(GetUnitZoneIndex("player"))] ~= nil then
                            return AOEHelper.savedVariables.savedZones[GetZoneId(GetUnitZoneIndex("player"))].friendlyBrightness
                        end
                        return 0
                    end,
                    setFunc = function(value) 
                        AOEHelper.savedVariables.savedZones[GetZoneId(GetUnitZoneIndex("player"))].friendlyBrightness = value
                        SetSetting(SETTING_TYPE_COMBAT, COMBAT_SETTING_MONSTER_TELLS_FRIENDLY_BRIGHTNESS, value)
                    end,
                    width = "half",
                    decimals = 0,
                    step = 1,
                    default = 50,
                    min = 1,
                    max = 100,
                },
                [5] = {
                    type = "button",
                    name = "load",
                    tooltip = "load the currently saved settings from this zone",
                    func = function()
                        local zoneID = GetZoneId(GetUnitZoneIndex("player"))
                        AOEHelper.SetGameColors(AOEHelper.GetZoneColors(zoneID))
                    end,
                    disabled = function()
                        local zoneID = GetZoneId(GetUnitZoneIndex("player"))
                        if AOEHelper.GetZoneColors(zoneID) == nil then return true end

                        local function compare(t1, t2)
                            for key, value in pairs(t1) do
                                if t2[key] ~= value then 
                                    return false
                                end
                            end
                            return true
                        end
                        if compare(AOEHelper.GetZoneColors(zoneID), AOEHelper.GetGameColors()) then return true end

                        --if AOEHelper.GetZoneColors(zoneID) == AOEHelper.GetGameColors() then return true end
                        return false
                    end,
                    width = "half",
                },
                [6] = {
                    type = "button",
                    name = "delete settings",
                    tooltip = "delete saved settings for this zone",
                    warning = "this deletes your saved settings for this zone and they will fallback to deafault",
                    func = function()
                        local zoneID = GetZoneId(GetUnitZoneIndex("player"))
                        AOEHelper.DeleteZoneColors(zoneID)
                    end,
                    width = "half",
                }
            }
        },
        [11] = {
            type = "submenu",
            name = "Default Colors",
            tooltip = "Default Colors",
            controls = {
                [1] = {
                    type = "colorpicker",
                    name = GetString(AOEHELPER_MENU_GENERAL_ENEMY_COLOR),
                    tooltip = "The color of the AoEs that come from enemys",
                    getFunc = function()
                        local c = AOEHelper.savedVariables.defaultColors.enemyColor
                        return tonumber("0x" .. c:sub(1, 2)) / 255, tonumber("0x" .. c:sub(3, 4)) / 255, tonumber("0x" .. c:sub(5, 6)) / 255
                    end,
                    setFunc = function(red,green,blue,a)
                        local newColor = string.format("%02x%02x%02x", red*255, green*255, blue*255)
                        AOEHelper.savedVariables.defaultColors.enemyColor = newColor
                    end,
                    width = "half"
                },
                [2] = {
                    type = "slider",
                    name = GetString(AOEHELPER_MENU_GENERAL_ENEMY_BRIGHTNESS),
                    tooltip = "the brightness of the AoEs that come from enemys",
                    getFunc = function() return AOEHelper.savedVariables.defaultColors.enemyBrightness end,
                    setFunc = function(value) AOEHelper.savedVariables.defaultColors.enemyBrightness = value end,
                    width = "half",
                    decimals = 0,
                    step = 1,
                    default = 50,
                    min = 1,
                    max = 100,
                },
                [3] = {
                    type = "colorpicker",
                    name = GetString(AOEHELPER_MENU_GENERAL_ALLY_COLOR),
                    tooltip = "The color of the AoEs that come from friendlies",
                    getFunc = function()
                        local c = AOEHelper.savedVariables.defaultColors.friendlyColor
                        return tonumber("0x" .. c:sub(1, 2)) / 255, tonumber("0x" .. c:sub(3, 4)) / 255, tonumber("0x" .. c:sub(5, 6)) / 255
                    end,
                    setFunc = function(red,green,blue,a)
                        local newColor = string.format("%02x%02x%02x", red*255, green*255, blue*255)
                        AOEHelper.savedVariables.defaultColors.friendlyColor = newColor
                    end,
                    width = "half"
                },
                [4] = {
                    type = "slider",
                    name = GetString(AOEHELPER_MENU_GENERAL_ALLY_BRIGHTNESS),
                    tooltip = "the brightness of the AoEs that come from friendlies",
                    getFunc = function() return AOEHelper.savedVariables.defaultColors.friendlyBrightness end,
                    setFunc = function(value) AOEHelper.savedVariables.defaultColors.friendlyBrightness = value end,
                    width = "half",
                    decimals = 0,
                    step = 1,
                    default = 50,
                    min = 1,
                    max = 100,
                },
                [5] = {
                    type = "description",
                    name = " ",
                    width = "half"
                },
                [6] = {
                    type = "button",
                    name = "save current",
                    tooltip = "set color for the current Zone you are in",
                    warning = "this overwrites you default colors with the current loaded ones globally",
                    func = function()
                        AOEHelper.savedVariables.defaultColors = AOEHelper.GetGameColors()
                    end,
                    width = "half",
                },
            }
        },
    }

    optionsTable[#optionsTable + 1] = {
        type = "submenu",
        name = "debug",
        controls = {
            [1] = {
                type = "description",
                text = function() return "Took " .. AOEHelper.loadTime .. "ms to load " .. AOEHelper.name end,
            }
        }
    }

    LAM2:RegisterAddonPanel("AOEHelperMenu", panelData)
    LAM2:RegisterOptionControls("AOEHelperMenu", optionsTable)
end

local endLoadTime = GetGameTimeMilliseconds()
AOEHelper.loadTime = AOEHelper.loadTime + (endLoadTime - startLoadTime)