util.AddNetworkString("maks_questnpc_futur") -- TODO: Only 1 networked string
util.AddNetworkString("maks_questshowmewhatyougot")
util.AddNetworkString("maks_questfinished")
util.AddNetworkString("maks_quest_object")

if !sql.TableExists("maksquest_completed") or !sql.TableExists("maksquest_inprogress") then
	if !sql.TableExists("maksquest_completed") then
		sql.Query("CREATE TABLE maksquest_completed( steamID VARCHAR(30), collecID INTEGER, questID INTEGER, hasRecomp INT(1) )")
	end
	if !sql.TableExists("maksquest_inprogress") then -- steamID, collection ID, quest ID, and info to complete quest e.g. kill number, health, name...
		sql.Query("CREATE TABLE maksquest_inprogress( steamID VARCHAR(30), collecID INTEGER, questID INTEGER, info TEXT )")
	end
end

local function killmonster(name, number, ply, collectionID, questID)
	local weirdName = collectionID..questID.."killmonster"..name..number..ply:SteamID()
	hook.Add("OnNPCKilled", weirdName, function(npc, attacker) -- Hook with collecID,questID,killmonster,name,num,steamid e.g. 13killmonsternpc_headcrab50STEAM_0:0:06546
		if npc:GetClass() == name and attacker == ply then
			-- If no progress stored
			if type(sql.QueryRow("SELECT * FROM maksquest_inprogress WHERE steamID='"..attacker:SteamID().."' AND collecID="..collectionID.." AND questID="..questID)) == "nil" then
				sql.Query("INSERT INTO maksquest_inprogress(steamID, collecID, questID, info) VALUES('"..attacker:SteamID().."', "..collectionID..", "..questID..", '1')")
			else
				local numberKilled = tonumber(sql.Query("SELECT * FROM maksquest_inprogress WHERE steamID='"..attacker:SteamID().."' AND collecID="..collectionID.." AND questID="..questID)[1]['info'])
				numberKilled = numberKilled + 1
				if numberKilled >= number then
					sql.Query("DELETE FROM maksquest_inprogress WHERE steamID='"..attacker:SteamID().."' AND collecID="..collectionID.." AND questID="..questID)
					sql.Query("INSERT INTO maksquest_completed(steamID, collecID, questID, hasRecomp) VALUES('"..attacker:SteamID().."', "..collectionID..", "..questID..", 0)")
					net.Start("maks_questfinished")
						net.WriteBool(true)
						net.WriteInt(collectionID, 32)
						net.WriteInt(questID, 32)
					net.Send(attacker)
					net.Start("maks_questfinished")
						net.WriteBool(false)
						net.WriteInt(collectionID, 32)
						net.WriteInt(questID, 32)
						net.WriteString(""..numberKilled)
					net.Send(attacker)
					hook.Remove("OnNPCKilled",weirdName)
					return
				end
				net.Start("maks_questfinished")
					net.WriteBool(false)
					net.WriteInt(collectionID, 32)
					net.WriteInt(questID, 32)
					net.WriteString(""..numberKilled)
				net.Send(attacker)
				sql.Query("UPDATE maksquest_inprogress WHERE steamID='"..attacker:SteamID().."' AND collecID="..collectionID.." AND questID="..questID.." SET info='"..numberKilled.."'")
			end
		end
	end)
	hook.Add("PlayerDisconnected", weirdName, function(satan)
		if satan == ply then
			hook.Remove("OnNPCKilled", weirdName)
			hook.Remove("PlayerDisconnected", weirdName)
		end
	end)
end

local function killboss(name, health, pos, ply, collectionID, questID)
	local weirdName = questID..collectionID..name..health..ply:SteamID() -- 19npc_headcrab500STEAM_0:0:54552855
	local monster = ents.Create(name)
	monster:SetHealth(health)
	monster:SetEnemy(ply)
	monster:SetPos(pos)
	hook.Add("OnNPCKilled",weirdName,function(npc, attacker)
		if npc == monster then
			sql.Query("DELETE FROM maksquest_inprogress WHERE steamID='"..attacker:SteamID().."' AND collecID="..collectionID.." AND questID="..questID)
			sql.Query("INSERT INTO maksquest_completed(steamID, collecID, questID, hasRecomp) VALUES('"..attacker:SteamID().."', "..collectionID..", "..questID..", 0)")
			net.Start("maks_questfinished")
				net.WriteBool(true)
				net.WriteInt(collectionID, 32)
				net.WriteInt(questID, 32)
			net.Send(attacker)
			hook.Remove("OnNPCKilled",weirdName)
			hook.Remove("PlayerDisconnected",weirdName)
			hook.Remove("ScaleNPCDamage",weirdName)
		end
	end)
	hook.Add("ScaleNPCDamage",weirdName,function(npc, _, dmginfo) -- no one except player can damage the boss
		if dmginfo:GetAttacker() ~= ply and npc == monster then
			dmginfo:ScaleDamage(0)
		end
	end)
	hook.Add("PlayerDisconnected",weirdName,function(satan)
		if satan == ply then
			hook.Remove("OnNPCKilled",weirdName)
			hook.Remove("ScaleNPCDamage",weirdName)
			hook.Remove("PlayerDisconnected",weirdName)
		end
	end)
end

local function killplayer(checker, ply, collectionID, questID)
	local weirdName = collectionID..questID..ply:SteamID().."killplayer"
	hook.Add("PlayerDeath", weirdName, function(victim, inflictor, attacker)
		if attacker == ply then
			-- If no progress stored
			if type(sql.QueryRow("SELECT * FROM maksquest_inprogress WHERE steamID='"..attacker:SteamID().."' AND collecID="..collectionID.." AND questID="..questID)) == "nil" then
				sql.Query("INSERT INTO maksquest_inprogress(steamID, collecID, questID, info) VALUES('"..attacker:SteamID().."', "..collectionID..", "..questID..", '')")
			else
				if checker(victim, inflictor, attacker) or false then
					sql.Query("DELETE FROM maksquest_inprogress WHERE steamID='"..attacker:SteamID().."' AND collecID="..collectionID.." AND questID="..questID)
					sql.Query("INSERT INTO maksquest_completed(steamID, collecID, questID, hasRecomp) VALUES('"..attacker:SteamID().."', "..collectionID..", "..questID..", 0)")
					net.Start("maks_questfinished")
						net.WriteBool(true)
						net.WriteInt(collectionID, 32)
						net.WriteInt(questID, 32)
					net.Send(attacker)
					hook.Remove("PlayerDeath",weirdName)
				end
			end
		end
	end)
	hook.Add("PlayerDisconnected", weirdName, function(satan)
		if satan == ply then
			hook.Remove("PlayerDeath", weirdName)
			hook.Remove("PlayerDisconnected", weirdName)
		end
	end)
end

hook.Add("PlayerInitialSpawn","youforgotyourQuestBro",function(ply)
	local sqlQuery = sql.Query("SELECT * FROM maksquest_inprogress WHERE steamID='"..ply:SteamID().."'")
	for _, value in pairs(sqlQuery or {}) do
		local collectionID = tonumber(value['collecID'])
		local questID = tonumber(value['questID'])
		local Quest = MAKS_QUEST.Quests[collectionID][questID]
		if Quest.quest.questType == "killmonster" then
			killmonster(Quest.quest.name, Quest.quest.number, ply, collectionID, questID)
		elseif Quest.quest.questType == "killboss" then
			killboss(Quest.quest.name, Quest.quest.health, Quest.quest.pos, ply, collectionID, questID)
		elseif Quest.quest.questType == "killplayer" then
			killplayer(Quest.quest.checker, ply, collectionID, questID)
		else
			error("Quest "..questID.." in collec "..collectionID.." has an invalid questType")
		end
	end
	if type(sqlQuery) == "table" then
		net.Start("maks_questshowmewhatyougot")
		net.WriteBool(false)
		net.WriteTable(sqlQuery)
		net.Send(ply)
	end
end)

net.Receive("maks_questnpc_futur",function(_, ply)
	if !ply:IsAdmin() then return end
	local ent = net.ReadEntity()
	ent:SetFirstName(net.ReadString())
	local model = net.ReadString()
	ent:SetModel(model)
	ent:SetModelName(model)
	ent:SetModelNames(model)
	ent:SetIdentif(net.ReadInt(32))
end)

local function CanDoQuest(quest, ply)
	local level = quest.levelNeeded
	if level then -- level check
		local levelply = ply:getDarkRPVar('level')
		if tonumber(level) and levelply != tonumber(level) then -- single number
			return false
		end
		local levelexplo = string.Explode("-",level,false)
		if #levelexplo == 2 then
			if tonumber(levelexplo[1]) > levelply or tonumber(levelexplo[2]) < levelply then -- If player is out of range
				return false
			end
		end
		if string.StartWith(level,"<") and tonumber(string.sub(level,2)) < levelply then -- If player has more level
			return false
		end
		if string.StartWith(level,">") and tonumber(string.sub(level,2)) > levelply then -- If player has more level
			return false
		end
	end
	if type(quest.customCheck) == "func" then
		if !quest.customCheck(ply) then
			return false
		end
	end
	return true
end

net.Receive("maks_questshowmewhatyougot",function(_, ply)
	local rawstring = net.ReadString()
	local collectionID = tonumber(string.Explode(";",rawstring,false)[1])
	local questID = tonumber(string.Explode(";",rawstring,false)[2])
	local Quest = MAKS_QUEST.Quests[collectionID][questID]
	if !collectionID or !questID or !Quest then return end -- if not valid, quit
	CanDoQuest(Quest, ply)
	print("ServerLog: [QUEST] "..ply:Nick().." started quest with collectionID "..collecID.." and questID "..questID)
	if type(Quest.beginLua) == "func" then -- exec begin lua
		Quest.beginLua(ply)
	end
	if Quest.quest.questType == "killmonster" then
		killmonster(Quest.quest.name, Quest.quest.number, ply, collectionID, questID)
	elseif Quest.quest.questType == "killboss" then
		killboss(Quest.quest.name, Quest.quest.health, Quest.quest.pos, ply, collectionID, questID)
	elseif Quest.quest.questType == "killplayer" then
		killplayer(Quest.quest.checker, ply, collectionID, questID)
	else
		error("Quest "..questID.." in collec "..collectionID.." has an invalid questType")
	end
end)

net.Receive("maks_questfinished",function(_, ply)
	local collecID = net.ReadInt(32)
	local questID = net.ReadInt(32)
	if type(sql.Query("SELECT * FROM maksquest_completed WHERE steamID='"..ply:SteamID().."' AND collecID="..collecID.." AND questID="..questID.." AND hasRecomp=0")) == "table" then
		sql.Query("UPDATE maksquest_completed SET hasRecomp=1 WHERE steamID='"..ply:SteamID().."' AND collecID="..collecID.." AND questID="..questID)
		print("ServerLog: [QUEST] "..ply:Nick().." finished quest with collectionID "..collecID.." and questID "..questID)
		if type(MAKS_QUEST.Quests[collecID][questID].endLua) == "func" then
			MAKS_QUEST.Quests[collecID][questID].endLua(ply)
		end
		if type(MAKS_QUEST.Quests[collecID][questID].Reward) == "string" then
			local reward = string.Split(MAKS_QUEST.Quests[collecID][questID].Reward, "-")
			ply:addXP(reward[1] or 0)
			ply:addMoney(reward[2] or 0)
		end
	else
		MsgC(Color(255,0,0),"[QUEST] WARNING! "..ply:Nick().."("..ply:SteamID()..") SAID HE FINISHED A QUEST BUT HE DIDN'T! BE AWARE!")
	end
end)

net.Receive("maks_quest_object",function(_, ply)
	if !ply:IsAdmin() then return end
	local ent = net.ReadEntity()
	ent:SetModelNames(net.ReadString())
	ent:SetIdentif(net.ReadInt(32))
end)