AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

function ENT:Initialize()
	self:RebuildPhysic("models/props_junk/watermelon01.mdl")
	self:SetUseType( SIMPLE_USE )
	self:NetworkVarNotify("ModelNames", function(_, _, _, new) if util.IsValidModel(new) then self:RebuildPhysic(new) end end)
end

function ENT:RebuildPhysic(model)
	self:SetModel(model)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end
end

function ENT:Use(a, ply)
	if self:GetIdentif() < 1 then
		net.Start("maks_quest_object")
		net.WriteBool(false)
		net.WriteEntity(self)
		net.Send(ply)
	else
		local sqlQuery = sql.Query("SELECT * FROM maksquest_inprogress WHERE steamID='"..ply:SteamID().."'")
		for _, value in pairs(sqlQuery or {}) do
			local collectionID = tonumber(value['collecID'])
			local questID = tonumber(value['questID'])
			local Quest = MAKS_QUEST.Quests[collectionID][questID]
			if Quest.quest.questType == "collectobject" and Quest.quest.id == self:GetIdentif() then
				if type(sql.QueryRow("SELECT * FROM maksquest_inprogress WHERE steamID='"..ply:SteamID().."' AND collecID="..collectionID.." AND questID="..questID)) == "nil" then
					sql.Query("INSERT INTO maksquest_inprogress(steamID, collecID, questID, info) VALUES('"..ply:SteamID().."', "..collectionID..", "..questID..", '1')")
				else
					local numberRecup = tonumber(sql.Query("SELECT * FROM maksquest_inprogress WHERE steamID='"..ply:SteamID().."' AND collecID="..collectionID.." AND questID="..questID)[1]['info'])
					numberRecup = numberRecup + 1
					if numberRecup >= number then
						sql.Query("DELETE FROM maksquest_inprogress WHERE steamID='"..ply:SteamID().."' AND collecID="..collectionID.." AND questID="..questID)
						sql.Query("INSERT INTO maksquest_completed(steamID, collecID, questID, hasRecomp) VALUES('"..ply:SteamID().."', "..collectionID..", "..questID..", 0)")
						net.Start("maks_questfinished")
							net.WriteBool(true)
							net.WriteInt(collectionID, 32)
							net.WriteInt(questID, 32)
						net.Send(ply)
					end
					net.Start("maks_questfinished")
						net.WriteBool(false)
						net.WriteInt(collectionID, 32)
						net.WriteInt(questID, 32)
						net.WriteString(""..numberRecup)
					net.Send(ply)
					sql.Query("UPDATE maksquest_inprogress WHERE steamID='"..attacker:SteamID().."' AND collecID="..collectionID.." AND questID="..questID.." SET info='"..numberRecup.."'")
					break
				end
				net.Start("maks_quest_object") -- show chat msg
				net.WriteBool(true)
				net.WriteEntity(self)
				net.Send(ply)
			end
		end
	end
end