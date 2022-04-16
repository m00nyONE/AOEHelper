local strings = {
    AOEHELPER_MENU_DESCRIPTION = "AOEColor ermöglich das Speichern einzelner Farben für Gegner- und Verbündeten AOEs pro Zone. Dies gilt für Prüfungen und Dungeons",
	AOEHELPER_LOADED_COLORS = "Farben für <<1>> erfolgreich geladen",
	AOEHELPER_MENU_CURRENT_HEADER_DESCRIPTION = "Aktuelle Farben",

	AOEHELPER_MENU_GENERAL_ENEMY_COLOR = "Farbe von Feinden",
	AOEHELPER_MENU_GENERAL_ENEMY_BRIGHTNESS = "Helligkeit von Feinden",
	AOEHELPER_MENU_GENERAL_ALLY_COLOR = "Farbe von Verbündeten",
	AOEHELPER_MENU_GENERAL_ALLY_BRIGHTNESS = "Helligkeit von Verbündeten",
}

for stringId, stringValue in pairs(strings) do
	ZO_CreateStringId(stringId, stringValue)
	SafeAddVersion(stringId, 1)
end