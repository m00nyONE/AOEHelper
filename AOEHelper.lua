local startLoadTime = GetGameTimeMilliseconds()

AOEHelper = AOEHelper or {}



function AOEHelper.filterName(unfiltered)
    local i, _ = string.find(unfiltered, "%^")
    if i == nil then
        return unfiltered
    end
    return string.sub(unfiltered, 1, i-1)
end

-- donate to me if you want to
function AOEHelper.donate()
    -- show message window
	SCENE_MANAGER:Show('mailSend')
    -- wait 200 ms async
	zo_callLater(
		function()
            -- fill out messagebox
			ZO_MailSendToField:SetText("@m00nyONE")
			ZO_MailSendSubjectField:SetText("Donation for AOEHelper")
			QueueMoneyAttachment(1)
			ZO_MailSendBodyField:TakeFocus()
		end,
	200)
end

-- returns the current game colors
function AOEHelper.GetGameColors()
    return {
        enemyColor = GetSetting(SETTING_TYPE_COMBAT, COMBAT_SETTING_MONSTER_TELLS_ENEMY_COLOR):sub(3,8),
        enemyBrightness = GetSetting(SETTING_TYPE_COMBAT, COMBAT_SETTING_MONSTER_TELLS_ENEMY_BRIGHTNESS),
        friendlyColor = GetSetting(SETTING_TYPE_COMBAT, COMBAT_SETTING_MONSTER_TELLS_FRIENDLY_COLOR):sub(3,8),
        friendlyBrightness = GetSetting(SETTING_TYPE_COMBAT, COMBAT_SETTING_MONSTER_TELLS_FRIENDLY_BRIGHTNESS),
    }
end

-- apply the colors to the game settings
function AOEHelper.SetGameColors(colors)
    --[[
        color = {
            enemyColor: string | nil
            enemyBrightness: number | nil
            friendlyColor: string | nil
            friendlyBrightness: number | nil
        }
    ]]--
    if type(colors) ~= "table" then d("argument is not a table") return end
    if colors.enemyColor ~= nil then
        SetSetting(SETTING_TYPE_COMBAT, COMBAT_SETTING_MONSTER_TELLS_ENEMY_COLOR, colors.enemyColor)
    end
    if colors.enemyBrightness ~= nil then
        SetSetting(SETTING_TYPE_COMBAT, COMBAT_SETTING_MONSTER_TELLS_ENEMY_BRIGHTNESS, colors.enemyBrightness)
    end
    if colors.friendlyColor ~= nil then
        SetSetting(SETTING_TYPE_COMBAT, COMBAT_SETTING_MONSTER_TELLS_FRIENDLY_COLOR, colors.friendlyColor)
    end
    if colors.friendlyBrightness ~= nil then
        SetSetting(SETTING_TYPE_COMBAT, COMBAT_SETTING_MONSTER_TELLS_FRIENDLY_BRIGHTNESS, colors.friendlyBrightness)
    end
end

-- save colors for a zone to saved variables
function AOEHelper.SetZoneColors(zoneID, colors)
    --[[
        zoneID: number
        color = {
            enemyColor: string | nil
            enemyBrightness: number | nil
            friendlyColor: string | nil
            friendlyBrightness: number | nil
        }
    ]]--
    if type(colors) ~= "table" then d("argument is not a table") return end

    if AOEHelper.savedVariables.savedZones[zoneID] == nil then
        AOEHelper.savedVariables.savedZones[zoneID] = {}
    end

    if colors.enemyColor ~= nil then
        AOEHelper.savedVariables.savedZones[zoneID].enemyColor = colors.enemyColor
    end
    if colors.enemyBrightness ~= nil then
        AOEHelper.savedVariables.savedZones[zoneID].enemyBrightness = colors.enemyBrightness
    end
    if colors.friendlyColor ~= nil then
        AOEHelper.savedVariables.savedZones[zoneID].friendlyColor = colors.friendlyColor
    end
    if colors.friendlyBrightness ~= nil then
        AOEHelper.savedVariables.savedZones[zoneID].friendlyBrightness = colors.friendlyBrightness
    end
end

-- remove a zone from the saved variables
function AOEHelper.DeleteZoneColors(zoneID)
    if AOEHelper.savedVariables.savedZones[zoneID] == nil then return end
    AOEHelper.savedVariables.savedZones[zoneID] = nil
end

-- get the Colors from a saved zone - if it does not exist it returns nil
function AOEHelper.GetZoneColors(zoneID)
    --[[
        zoneID: number
    ]]--
    if AOEHelper.savedVariables.savedZones[zoneID] == nil then return nil end

    local defaultColors = AOEHelper.savedVariables.defaultColors
    local zoneColors = AOEHelper.savedVariables.savedZones[zoneID]

    if zoneColors.enemyColor == nil then zoneColors.enemyColor = defaultColors.enemyColorend end
    if zoneColors.enemyBrightness == nil then zoneColors.enemyBrightness = defaultColors.enemyBrightness end
    if zoneColors.friendlyColor == nil then zoneColors.friendlyColor = defaultColors.friendlyColor end
    if zoneColors.friendlyBrightness == nil then zoneColors.friendlyBrightness = defaultColors.friendlyBrightness end

    return zoneColors
end

local function onPlayerActivated()
    local zoneID = GetZoneId(GetUnitZoneIndex("player"))

    --if not IsUnitInDungeon("player") then
    --    AOEHelper.SetGameColors(AOEHelper.savedVariables.defaultColors)
    --    return
    --end

    if AOEHelper.GetZoneColors(zoneID) == nil then
        AOEHelper.SetGameColors(AOEHelper.savedVariables.defaultColors)
        return
    end


    AOEHelper.SetGameColors(AOEHelper.GetZoneColors(zoneID))
    d(zo_strformat(GetString(AOEHELPER_LOADED_COLORS), AOEHelper.filterName(GetUnitZone("player"))))
end

function AOEHelper.OnAddOnLoaded(_, addonName)
    if addonName == AOEHelper.name then
        local startLoadTime2 = GetGameTimeMilliseconds()
        


        EVENT_MANAGER:UnregisterForEvent(AOEHelper.name, EVENT_ADD_ON_LOADED)

        -- load saved variables ( global )
        AOEHelper.savedVariables = AOEHelper.savedVariables or {}
        AOEHelper.savedVariables = ZO_SavedVars:NewAccountWide("AOEHelperVars", AOEHelper.variableVersion, nil, AOEHelper.defaultVariables, GetWorldName())

        -- check if its the first run
        if AOEHelper.savedVariables.defaultColors == nil then
            AOEHelper.savedVariables.defaultColors = AOEHelper.GetGameColors()
        end

        -- check if AccountSettings by Jodynn is installed & work around the auto settings
        if AccountSettings ~= nil then
            AOEHelper.globalDelay = 6000
        end

        -- create the LibAddonMenu entry
        AOEHelper.createAddonMenu()

        -- use EVENT_PLAYER_ACTIVATED to check the zones because EVENT_ZONE_CHANGED is just an unreliable piece of shit
        EVENT_MANAGER:RegisterForEvent(AOEHelper.name .. "ZoneChange", EVENT_PLAYER_ACTIVATED, function() zo_callLater(onPlayerActivated, AOEHelper.globalDelay) end)

        local endLoadTime2 = GetGameTimeMilliseconds()
        AOEHelper.loadTime = AOEHelper.loadTime + (endLoadTime2 - startLoadTime2)
    end
end

EVENT_MANAGER:RegisterForEvent(AOEHelper.name, EVENT_ADD_ON_LOADED, AOEHelper.OnAddOnLoaded)

local endLoadTime = GetGameTimeMilliseconds()
AOEHelper.loadTime = AOEHelper.loadTime + (endLoadTime - startLoadTime)