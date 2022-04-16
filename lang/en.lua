local strings = {
    AOEHELPER_MENU_DESCRIPTION = "AOEColor allows you to customize enemy and ally AOE colors specific for each zone. YOu can customize every Trial and Dungeon.",
	AOEHELPER_LOADED_COLORS = "loaded custom colors for <<1>>",
	AOEHELPER_MENU_CURRENT_HEADER_DESCRIPTION = "current colors",

	AOEHELPER_MENU_GENERAL_ENEMY_COLOR = "enemy color",
	AOEHELPER_MENU_GENERAL_ENEMY_BRIGHTNESS = "enemy brightness",
	AOEHELPER_MENU_GENERAL_ALLY_COLOR = "friendly color",
	AOEHELPER_MENU_GENERAL_ALLY_BRIGHTNESS = "friendly brightness",
}

for stringId, stringValue in pairs(strings) do
	ZO_CreateStringId(stringId, stringValue)
	SafeAddVersion(stringId, 1)
end