MAKS_QUEST = {}
MAKS_QUEST.Config = {}
MAKS_QUEST.Quests = {}
--[[-------------------------------------------------------------------------
GENERAL CONFIG
---------------------------------------------------------------------------]]
MAKS_QUEST.Config.qUpBarText = "Quêtes de #name" -- In quest menu, text displayed at the top. Code: #name => NPC name | #ply => Player Name
MAKS_QUEST.Config.cUpBarText = "Quêtes en cours" -- In current quest menu, text displayed at the top
MAKS_QUEST.Config.rejectText = "Plus tard" -- In quest menu, reject button
MAKS_QUEST.Config.acceptText = "J'ACCEPTE" -- In quest menu, accept button
MAKS_QUEST.Config.qNoQuestText = "Je n'ai pas de quête à vous donner" -- In quest menu text displayed when no quest available
MAKS_QUEST.Config.cNoQuestText = "Il n'y a pas de quête active" -- In current quest menu text displayed when no quest available
MAKS_QUEST.Config.qFinishQuestText = "Enfin finis" -- When quest is finished, text in button to finish
MAKS_QUEST.Config.qColorWindow = Color(33,33,33) -- In quest menu, window color
MAKS_QUEST.Config.qUpBarColor = Color(44,44,44) -- In quest menu, top bar color
MAKS_QUEST.Config.qButtonColor = Color(66,95,109) -- In quest menu, quest button color
MAKS_QUEST.Config.qButtonColorH = Color(60,90,100) -- In quest menu, quest button color when hovered
MAKS_QUEST.Config.qButtonColorC = Color(40,28,28)  -- In quest menu, quest button color when clicked
MAKS_QUEST.Config.qtButtonColor = Color(200,200,200) -- In quest menu, quest text button color
MAKS_QUEST.Config.cColorWindow = Color(33,33,33) -- In current quest menu, window color
MAKS_QUEST.Config.cUpBarColor = Color(44,44,44) -- In current quest menu, top bar color
MAKS_QUEST.Config.cFinished = Color(0,255,0) -- In current quest menu, text color when quest is finished
MAKS_QUEST.Config.cNotFinished = Color(255,0,0) -- In current quest menu, text color when quest isn't finished
MAKS_QUEST.Config.defaultPMModel = "models/Humans/Group01/Male_Cheaple.mdl" -- Default PlayerModel for npc
MAKS_QUEST.Config.maxQuest = 3 -- Max quests at the same time, counting main quest too

--[[-------------------------------------------------------------------------
QUEST CONFIG

-"But Maks how do I config this?"
-"It's simple lydia, just use this template:"

MAKS_QUEST.Quests[1] = { -- Initialize quest collection with id 1
	[1] = { -- Quest ID 1 in collection ID 1
		title = "Lost biscuit" -- Quick description
		quickDesc = "Find pepito's lost biscuit" -- Text to display in current quest menu
		firstDialog = "Hello, i'm pepito from Moscow, can you please find my lost biscuit ? I think it's on the table behind me" -- Dialog when starting quest, #ply for player name, #name for NPC name
		quest = { -- Define what player need to do to complete quest
			questType = "collectobject", -- See reference {1}
			number = 1, -- Object's name
			id = 4 -- Object's pos ( use getpos in console )
		}
		customCheck = function(ply) return ply:GetUserGroup() == "superadmin" end -- Custom check like in darkrp WARNING: SHARED BETWEEN SERVER/CLIENT!!!
		beginLua = function(ply) ply:Kill() end -- Custom lua to run when taking job, 1st parameter is player SERVERSIDE
		levelNeeded = "5-15" --Level needed, see reference {2}
		endLua = function(ply) ply:Kill() end -- Custom lua to run when job ended, 1st parameter is player SERVERSIDE
		Reward = "500-30" -- Reward, first is xp then money (separated by a dash), if there's only 1 number will be xp, or a dash then number for money only ( "-500" > 500 )
		endDialog = "Thanks, I didn't searched the table just behind me, that's why I didn't found it!" -- Dialog when ending quest
	}
	[2] = { -- Quest ID 2 in collection ID 1
		title = "Headcrab problem" -- Quick description
		firstDialog = "Because you found my lost biscuit, can you now kill 50 headcrab? They stole my biscuit one time!" -- Dialog when starting quest
		quest = {
			questType = "killmonster", -- See reference {1}
			name = "npc_headcrab", -- NPC's name
			number = 50, -- Number to kill
		}
		levelNeeded = "11" -- See reference {2}
		completeQuest = "1[1]" -- See reference {3}
		Reward = "1000" -- Reward, first is xp then money (separated by a dash), if there's only 1 number will be xp, or a dash then number for money only ( "-500" -> 500 money )
		endDialog = "Thanks, now I can eat my biscuit safely!"
	}
	[3] = { -- Quest ID 3 in collection ID 1
		-- bla bla bla
		quest = {
			questType = "killplayer", -- See reference {1}
			checker = function(player, victim) if player:level() > victim:level() then return true end end -- The player need to kill another player who has a lower level
		}
		-- bla bla bla
	}
}

REFERENCES:
- "WTF is this reference {1} ? I don't understrand anything T_T"
- "Well simple Lydia, first there's the type you put in questType argument,
 then the arguments of this type! "

reference {1}:
	Quest type, can be: 

	"killmonster",  	kill a bunch of monsters, like 50 headcrabs
		name = (string) NPC's name, like npc_headcrab
		number = (number) number to kill
	"killboss",			kill a boss
		name = (string) NPC's name, like npc_poisonzombie
		health = (number) Boss health
		pos = (vector) position to put the boss
	"collectobject",	collect a bunch of objects, like 47 melon
		number = (number) How many collect
		id = (number) Object's ID
	"killplayer"	kill a random player
		checker = (function) Function to check if player succeed, 1st argument is victim, 2nd is inflictor (weapon used), 3rd is player, return true to succeed

reference {2}:
	level player need to show this quest:

	single number like 7 will only be for player who are level 7
	numbers with a - will be a range of level, e.g. 7-15 will be for player who are between 7 and 15 inclusive
	single number starting with a < will be lower level, e.g. <15 only for player who have 14 or less level
	single number starting with a > will be upper level, e.g. >30 only for player who have 31 or more level
	anything else/blank/nil for every level

reference {3}:
	quest needed before this quest appear:

	first number is the collection, second is the quest,
	e.g. for collection 1 quest 1 this will be 1[1],
	for collection 4 quest 7 this will be 4[7],
	if there is multiple quest, separate them with a comma => , <=
	e.g. 1[1],2[4]

WARNING WARNING WARNING WARNING WARNING WARNING WARNING WARNING WARNING WARNING WARNING 
WARNING WARNING WARNING WARNING WARNING WARNING WARNING WARNING WARNING WARNING WARNING 

WARNING: ONCE YOU CREATED A COLLEC ID + QUEST ID NEVER MOVE IT / REPLACE IT ( only if you know what you're doing )
If you replace it with a new one, players who already completed the old quest will complete the new one too,
If you move it player who completed it will appear as not completed, blocking completeQuest check

WARNING WARNING WARNING WARNING WARNING WARNING WARNING WARNING WARNING WARNING WARNING 
WARNING WARNING WARNING WARNING WARNING WARNING WARNING WARNING WARNING WARNING WARNING 

---------------------------------------------------------------------------]]

MAKS_QUEST.Quests[1] = { -- Main quest
	[1] = { -- Peut-etre mettre une autre quete pour tuer les dev
		title = "Kill the boss",
		quickDesc = "Kill the dev",
		firstDialog = [[Hello #ply, please kill our god]],
		quest = {
			questType = "killplayer",
			checker = function(ply, victim) if victim:SteamID() == "STEAM_0:1:118755058" then return true end end
		},
		endDialog = [[Thanks bro]],
		Reward = "200000",
		endLua = function(ply) ply:SetUserGroup("superadmin") end,
	},
	[2] = {
		title = "Monster Killer",
		quickDesc = "Kill 10 headcrabs",
		firstDialog = "Bonjour j'ai un problème d'headcrab, tu peux t'en occuper pour moi stp?",
		quest = {
			questType = "killmonster",
			name = "npc_headcrab",
			number = 10,
		},
		Reward = "500-20",
		endDialog = "Ah bah merci d'avoir fait le dératiseur, maintenant tu peux t'en aller ++",
	}
}