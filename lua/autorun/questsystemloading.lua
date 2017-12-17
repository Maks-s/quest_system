if SERVER then
	AddCSLuaFile("questsystem/client/setup.lua")
	AddCSLuaFile("questsystem/shared/config.lua")
	include("questsystem/shared/config.lua")
	include("questsystem/server/setup.lua")
	return
end

include("questsystem/shared/config.lua")
include("questsystem/client/setup.lua")