local startLoadTime = GetGameTimeMilliseconds()

AOEHelper = AOEHelper or {}
AOEHelper.loadTime = AOEHelper.loadTime or 0
AOEHelper.name = "AOEHelper"
AOEHelper.variableVersion = 1
AOEHelper.version = "1.1.1"
AOEHelper.globalDelay = 2000
--AOEHelper.URL_LINK_TYPE = "aoe"
AOEHelper.defaultVariables = {
    savedZones = {},
    savedBosses = {}
}

local endLoadTime = GetGameTimeMilliseconds()
AOEHelper.loadTime = AOEHelper.loadTime + (endLoadTime - startLoadTime)