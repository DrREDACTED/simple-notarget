NoTarget = NoTarget or {}


-- Turn on/off this addon, it essentiually won't run. 
CreateConVar("NoTargetEnabled", 1, FCVAR_ARCHIVE, "Enable or disable NoTarget", 0, 1)

-- Turn on/off the allowed use only feature.
CreateConVar("NoTargetWhitelist", 0, FCVAR_ARCHIVE, "Enable or disable NoTargetWhitelist", 0, 1)

-- Add the usergroup to the list, quite simple.
NoTarget.Whitelist = {
--  ["user"] = true,
	["moderator"] = true,
	["admin"] = true,
	["superadmin"] = true,
}

