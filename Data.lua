local startLoadTime = GetGameTimeMilliseconds()

AOEHelper = AOEHelper or {}
AOEHelper.loadTime = AOEHelper.loadTime or 0
AOEHelper.name = "AOEHelper"
AOEHelper.variableVersion = 1
AOEHelper.version = "0.1.0"
AOEHelper.globalDelay = 1000
AOEHelper.URL_LINK_TYPE = "aoe"
AOEHelper.defaultVariables = {
    savedZones = {}
}

local endLoadTime = GetGameTimeMilliseconds()
AOEHelper.loadTime = AOEHelper.loadTime + (endLoadTime - startLoadTime)