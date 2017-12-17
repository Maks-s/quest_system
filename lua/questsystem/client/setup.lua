-- Initializing general things

local currentQuest = {}
local completedQuest = {}
for i=1, MAKS_QUEST.Config.maxQuest do
	currentQuest[i] = {}
end
for i=1, table.Count(MAKS_QUEST.Quests) do
	completedQuest[i] = {}
end

net.Receive("maks_questshowmewhatyougot",function()
	local typeOfSend = net.ReadBool()
	local questServer = net.ReadTable()
	if !typeOfSend then -- in progress
		for key, value in pairs(questServer) do
			currentQuest[key] = MAKS_QUEST.Quests[tonumber(value['collecID'])][tonumber(value['questID'])]
			currentQuest[key].finished = 0
			currentQuest[key].questID = tonumber(value['questID'])
			currentQuest[key].collecID = tonumber(value['collecID'])
			if value['info'] then
				currentQuest[key].info = tonumber(value['info'])
			end
		end
	else -- completed
		for key, value in pairs(questServer) do
			if tonumber(value['hasRecomp']) == 1 then
				completedQuest[tonumber(value['collecID'])] = {}
				completedQuest[tonumber(value['collecID'])][tonumber(value['questID'])] = true
			else
				currentQuest[key] = MAKS_QUEST.Quests[tonumber(value['collecID'])][tonumber(value['questID'])]
				currentQuest[key].finished = 1
				currentQuest[key].questID = tonumber(value['questID'])
				currentQuest[key].collecID = tonumber(value['collecID'])
				if type(MAKS_QUEST.Quests[tonumber(value['collecID'])][tonumber(value['questID'])].quest.number) == "number" then
					currentQuest[key].info = MAKS_QUEST.Quests[tonumber(value['collecID'])][tonumber(value['questID'])].quest.number
				end
			end
		end
	end
end)

-- Define how is NPC

local function showRaceMenu(ent) -- name / model / id setup
	local window = vgui.Create("DFrame")
	window:SetSize(400, 150)
	window:Center()
	window:SetTitle("Choose your NPC")
	local teName = vgui.Create("DTextEntry",window)
	teName:SetSize(100,20)
	teName:SetPos(0,30)
	teName:SetDrawLanguageID(false)
	teName:SetText("Name")
	teName:CenterHorizontal()
	local nwIdentif = vgui.Create("DNumberWang",window) 
	nwIdentif:SetSize(40,20)
	nwIdentif:SetPos(0,60)
	nwIdentif:SetDrawLanguageID(false)
	nwIdentif:SetDecimals(0)
	nwIdentif:SetText("ID")
	nwIdentif:CenterHorizontal()
	local teModel = vgui.Create("DTextEntry",window)
	teModel:SetSize(300,20)
	teModel:SetPos(0,90)
	teModel:SetDrawLanguageID(false)
	teModel:SetText("Model")
	teModel:CenterHorizontal()
	local bOK = vgui.Create("DButton",window)
	bOK:SetText("OK")
	function bOK:Paint(w,h)
		if !bOK:IsDown() then
			draw.RoundedBox(5,0,0,w,h,Color(255,0,0))
		else
			draw.RoundedBox(5,0,0,w,h,Color(150,0,0))
		end
	end 
	bOK:SetColor(Color(255,255,255))
	bOK:SetPos(0, 120)
	bOK:CenterHorizontal()
	teName.OnEnter = function()
		nwIdentif:RequestFocus()
		nwIdentif:SelectAllText()
	end
	nwIdentif.OnEnter = function()
		teModel:RequestFocus()
		teModel:SelectAllText()
	end
	bOK.DoClick = function()
		net.Start("maks_questnpc_futur")
		net.WriteEntity(ent)
		net.WriteString(teName:GetValue())
		net.WriteString(teModel:GetValue())
		net.WriteInt(math.Round(nwIdentif:GetValue()), 32)
		net.SendToServer()
		window:Close()
	end
	window:MakePopup()
	teName:RequestFocus()
	teName:SelectAllText()
end

--[[-------------------------------------------------------------------------
QUEST CHOOSING + ENDING NPC MENU
---------------------------------------------------------------------------]]

local function CanDoQuest(quest, collecID, questID)
	if completedQuest[collecID][questID] then
		return false
	end
	for i=1, MAKS_QUEST.Config.maxQuest do -- Replace by text 'You have too many quest'
		if type(currentQuest[i].quest) == "nil" then
			break
		end
		if i == MAKS_QUEST.Config.maxQuest then
			return false
		end
	end
	for i=1, MAKS_QUEST.Config.maxQuest do
		if currentQuest[i].collecID == collecID and currentQuest[i].questID == questID then
			return false
		end
	end
	local level = quest.levelNeeded
	if level then -- level check
		local levelply = LocalPlayer():getDarkRPVar('level')
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
		if !quest.customCheck(LocalPlayer()) then
			return false
		end
	end
	return true
end

local function patchTextCode(text, ent)
	text = string.Replace(text, "#name", ent:GetFirstName())
	text = string.Replace(text, "#ply", LocalPlayer():Nick())
	return text
end

local function showQuestMenu(ent)
	local collectionId = ent:GetIdentif()
	local window = vgui.Create("DFrame")
	window:SetSize(900,650)
	window:ShowCloseButton(false)
	window:SetTitle("")
	function window:Paint(w,h)
		draw.RoundedBox(5,0,0,w,h,MAKS_QUEST.Config.qColorWindow)
	end
	window:Center()
	window:MakePopup()
	local upperText = vgui.Create("DLabel",window)
	upperText:SetText(" "..patchTextCode(MAKS_QUEST.Config.qUpBarText, ent))
	upperText:AlignLeft()
	upperText:SetFont("Trebuchet18")
	upperText:SetWidth(window:GetWide())
	function upperText:Paint(w,h)
		draw.RoundedBoxEx(5,0,0,w,h,MAKS_QUEST.Config.qUpBarColor,true,true)
	end
	local closeButton = vgui.Create("DButton",window)
	closeButton:SetText("✖")
	closeButton:SetFont("Trebuchet24")
	closeButton:SetSize(20,20)
	closeButton:AlignRight(2)
	closeButton:AlignTop()
	closeButton:SetColor(Color(255,0,0))
	function closeButton:Paint(w,h)	end -- Only X, no button visible
	closeButton.DoClick = function()
		window:Close()
	end
	-- Quest panel
	local questPanel = vgui.Create("DPanel",window)
	questPanel:Dock(FILL)
	function questPanel:Paint(w,h)	end
	local questDialog = vgui.Create("DTextEntry",questPanel)
	questDialog:SetDrawLanguageID(false)
	questDialog:Dock(FILL)
	questDialog:DockMargin(0,0,0,100)
	questDialog:SetEditable(false)
	questDialog:SetMultiline(true)
	questDialog:SetFont("Trebuchet18")
	function questDialog:Paint(w,h)	
		self:DrawTextEntryText(Color(255,255,255),Color(255,255,255),Color(255,255,255))
	end
	local acceptButton = vgui.Create("DButton",window)	
	acceptButton:SetSize(window:GetWide()/2-20,100)
	acceptButton:SetText(MAKS_QUEST.Config.acceptText)
	acceptButton:SetFont("Trebuchet24")
	acceptButton:AlignBottom(5)
	acceptButton:AlignLeft(5)
	acceptButton:SetColor(Color(255,255,255))
	function acceptButton:Paint(w,h)
		if !self:IsHovered() and !self:IsDown() then -- Normal
			draw.RoundedBox(5,0,0,w,h,Color(56,142,60))
		elseif self:IsDown() then -- Click
			draw.RoundedBox(5,0,0,w,h,Color(0,200,0))
		else -- Hover
			draw.RoundedBox(5,0,0,w,h,Color(46,125,50))
		end
	end
	local rejectButton = vgui.Create("DButton",window)	
	rejectButton:SetSize(window:GetWide()/2-20,100)
	rejectButton:SetText(MAKS_QUEST.Config.rejectText)
	rejectButton:AlignBottom(5)
	rejectButton:AlignRight(5)
	rejectButton:SetFont("Trebuchet24")
	rejectButton:SetColor(Color(255,255,255))
	function rejectButton:Paint(w,h)
		if !self:IsHovered() and !self:IsDown() then -- Normal
			draw.RoundedBox(5,0,0,w,h,Color(200,40,40))
		elseif self:IsDown() then -- Click
			draw.RoundedBox(5,0,0,w,h,Color(255,0,0))
		else -- Hover
			draw.RoundedBox(5,0,0,w,h,Color(150,20,20))
		end
	end
	questPanel:SetVisible(false)
	acceptButton:SetVisible(false)
	rejectButton:SetVisible(false)

	local mainScrollPanel = vgui.Create("DScrollPanel",window)
	mainScrollPanel:Dock(FILL)
	rejectButton.DoClick = function() -- If not here, mainScrollPanel isn't defined so error
		questPanel:SetVisible(false)
		acceptButton:SetVisible(false)
		rejectButton:SetVisible(false)
		mainScrollPanel:SetVisible(true)
	end
	local countingStar = 0
	for id, questAvailable in pairs(MAKS_QUEST.Quests[collectionId] or {}) do
		if !CanDoQuest(questAvailable, collectionId, id) then continue end
		local questButton = mainScrollPanel:Add("DButton")
		questButton:SetText(questAvailable.title or "Quest")
		questButton:SetSize(0,50)
		questButton:SetFont("Trebuchet24")
		questButton:SetColor(MAKS_QUEST.Config.qtButtonColor)
		questButton:Dock(TOP)
		questButton:DockMargin(10,0,10,20)
		function questButton:Paint(w,h)
			if !self:IsHovered() and !self:IsDown() then -- Normal
				draw.RoundedBox(5,0,0,w,h,MAKS_QUEST.Config.qButtonColor)
			elseif self:IsDown() then -- Click
				draw.RoundedBox(5,0,0,w,h,MAKS_QUEST.Config.qButtonColorC)
			else -- Hover
				draw.RoundedBox(5,0,0,w,h,MAKS_QUEST.Config.qButtonColorH)
			end
		end
		questButton.DoClick = function()
			questDialog:SetText(patchTextCode(questAvailable.firstDialog, ent))
			acceptButton.DoClick = function() 
				window:Close()
				net.Start("maks_questshowmewhatyougot")
				net.WriteString(collectionId..";"..id)
				net.SendToServer()
				for i=1, MAKS_QUEST.Config.maxQuest do
					if type(currentQuest[i].quest) == "nil" then
						currentQuest[i] = questAvailable
						currentQuest[i].finished = false
						currentQuest[i].collecID = collectionId
						currentQuest[i].questID = id
						break
					end
				end
			end -- Update quest to accept
			questPanel:SetVisible(true)
			acceptButton:SetVisible(true)
			rejectButton:SetVisible(true)
			mainScrollPanel:SetVisible(false)
		end
		countingStar = countingStar + 1
	end
	if !(countingStar > 0) then
		local noQuestLabel = vgui.Create("DLabel",window)
		noQuestLabel:SetText(MAKS_QUEST.Config.qNoQuestText)
		noQuestLabel:SetFont("Trebuchet24")
		noQuestLabel:SetMultiline(true)
		noQuestLabel:SizeToContents()
		noQuestLabel:CenterHorizontal()
		noQuestLabel:CenterVertical()
	end
	for i=1, MAKS_QUEST.Config.maxQuest do
		if currentQuest[i].collecID == collectionId and currentQuest[i].finished == 1 then
			if noQuestLabel then
				noQuestLabel:SetVisible(false)
			end
			mainScrollPanel:SetVisible(false)
			acceptButton:SetWide(window:GetWide()-20)
			acceptButton:CenterHorizontal()
			acceptButton:SetText(MAKS_QUEST.Config.qFinishQuestText)
			questDialog:SetText(currentQuest[i].endDialog)
			questPanel:SetVisible(true)
			acceptButton:SetVisible(true)
			acceptButton.DoClick = function()
				completedQuest[completedQuest[i].collecID][completedQuest[i].questID] = true
				if noQuestLabel then
					noQuestLabel:SetVisible(true)
				end
				mainScrollPanel:SetVisible(true)
				questPanel:SetVisible(false)
				acceptButton:SetVisible(false)
				acceptButton:SetSize(window:GetWide()/2-20,100)
				acceptButton:SetText(MAKS_QUEST.Config.acceptText)
				acceptButton:AlignBottom(5)
				acceptButton:AlignLeft(5)
				net.Start("maks_questfinished")
				net.WriteInt(currentQuest[i].collecID, 32)
				net.WriteInt(currentQuest[i].questID, 32)
				net.SendToServer()
				table.Empty(completedQuest[i])
			end
			break
		end
	end
end

net.Receive("maks_questnpc_futur",function()
	if net.ReadBool() and LocalPlayer():IsAdmin() then
		showRaceMenu(net.ReadEntity()) -- skyrim reference :p
	else
		showQuestMenu(net.ReadEntity())
	end
end)

--[[-------------------------------------------------------------------------
SHOW CURRENT QUEST MENU
---------------------------------------------------------------------------]]

local function showCurrentQuest()
	local window = vgui.Create("DFrame")
	window:SetSize(350,250)
	window:ShowCloseButton(false)
	window:SetTitle("")
	window:SetMouseInputEnabled(true)
	window:SetKeyBoardInputEnabled(false)
	function window:Paint(w,h)
		draw.RoundedBox(5,0,0,w,h,MAKS_QUEST.Config.cColorWindow)
	end
	window:SetPos(10, 10)
	local upperText = vgui.Create("DLabel",window)
	upperText:SetText(" "..MAKS_QUEST.Config.cUpBarText)
	upperText:AlignLeft()
	upperText:SetFont("Trebuchet18")
	upperText:SetWidth(window:GetWide())
	function upperText:Paint(w,h)
		draw.RoundedBoxEx(5,0,0,w,h,MAKS_QUEST.Config.cUpBarColor,true,true)
	end
	local closeButton = vgui.Create("DButton",window)
	closeButton:SetText("✖")
	closeButton:SetFont("Trebuchet24")
	closeButton:SetSize(20,20)
	closeButton:AlignRight(2)
	closeButton:AlignTop()
	closeButton:SetColor(Color(255,0,0))
	function closeButton:Paint(w,h)	end -- Only X, no button visible
	closeButton.DoClick = function()
		if timer.Exists("refreshQuestData") then
			timer.Remove("refreshQuestData")
		end
		window:Close()
	end
	local mainScrollPanel = vgui.Create("DScrollPanel",window)
	mainScrollPanel:Dock(FILL)
	local countingStar = 0
	for id, questAvailable in pairs(currentQuest or {}) do
		if !questAvailable.quest then continue end
		local questText = mainScrollPanel:Add("DLabel")
		if questAvailable.quest.number then
			local oldQuest = questAvailable.info or 0
			questText:SetText( (questAvailable.quickDesc or "Error bro, report to admin").."("..(questAvailable.info or "0").."/"..questAvailable.quest.number..")" )
			timer.Create("refreshQuestData",5,0,function()
				if currentQuest[id].finished == 1 then
					questText:SetColor(MAKS_QUEST.Config.cFinished)
				else
					questText:SetColor(MAKS_QUEST.Config.cNotFinished)
				end
				if oldQuest != currentQuest[id].info then
					oldQuest = currentQuest[id].info
					questText:SetText( (questAvailable.quickDesc or "Error bro, report to admin").."("..(questAvailable.info or "0").."/"..questAvailable.quest.number..")" )
				end
			end)
		else
			questText:SetText(questAvailable.quickDesc or "Error bro, report to admin")
			timer.Create("refreshQuestData",5,0,function()
				if currentQuest[id].finished then
					questText:SetColor(MAKS_QUEST.Config.cFinished)
				else
					questText:SetColor(MAKS_QUEST.Config.cNotFinished)
				end
			end)
		end
		questText:SetFont("Trebuchet20")
		if questAvailable.finished == 1 then
			questText:SetColor(MAKS_QUEST.Config.cFinished)
		else
			questText:SetColor(MAKS_QUEST.Config.cNotFinished)
		end
		questText:Dock(TOP)
		questText:DockMargin(10,0,10,20)
		countingStar = countingStar + 1
	end
	if !(countingStar > 0) then
		local noQuestLabel = vgui.Create("DLabel",window)
		noQuestLabel:SetText(MAKS_QUEST.Config.cNoQuestText)
		noQuestLabel:SetFont("Trebuchet24")
		noQuestLabel:SetMultiline(true)
		noQuestLabel:SizeToContents()
		noQuestLabel:CenterHorizontal()
		noQuestLabel:CenterVertical()
	end
end

hook.Add("OnPlayerChat","MaksQuestMenuShowCurrent",function(ply, text)
	if string.lower(string.Replace(text," ","")) == "!quest" then
		if ply == LocalPlayer() then
			showCurrentQuest()
		end
		return true
	end
end)

-- Updating quest / Finishing quest

local function updateQuestInfo(collectionID, questingID, info)
	for i=1, MAKS_QUEST.Config.maxQuest do
		if currentQuest[i].collecID == collectionID and currentQuest[i].questID == questingID then
			if currentQuest[i].quest.questType == "killmonster" then
				currentQuest[i].info = tonumber(info)
			elseif currentQuest[i].quest.questType == "collectobject" then
				currentQuest[i].info = tonumber(info)
			end
			break
		end
	end
end

net.Receive("maks_questfinished",function()
	if net.ReadBool() then -- When really finishing
		local collectionId = net.ReadInt(32)
		local questID = net.ReadInt(32)
		for i=1, MAKS_QUEST.Config.maxQuest do
			if currentQuest[i].collecID == collectionId and currentQuest[i].questID == questID then
				currentQuest[i].finished = 1
				break
			end
		end
	else -- When updating quest
		updateQuestInfo(net.ReadInt(32),net.ReadInt(32),net.ReadString())
	end
end)

--[[-------------------------------------------------------------------------
Now setup objects for quests
---------------------------------------------------------------------------]]

local function showObjectMenu(ent) -- model / id setup
	local window = vgui.Create("DFrame")
	window:SetSize(400, 150)
	window:Center()
	window:SetTitle("Choose your OBJECT")
	local nwIdentif = vgui.Create("DNumberWang",window) 
	nwIdentif:SetSize(40,20)
	nwIdentif:SetPos(0,60)
	nwIdentif:SetDrawLanguageID(false)
	nwIdentif:SetDecimals(0)
	nwIdentif:SetText("ID")
	nwIdentif:CenterHorizontal()
	local teModel = vgui.Create("DTextEntry",window)
	teModel:SetSize(300,20)
	teModel:SetPos(0,90)
	teModel:SetDrawLanguageID(false)
	teModel:SetText("Model")
	teModel:CenterHorizontal()
	local bOK = vgui.Create("DButton",window)
	bOK:SetText("OK")
	function bOK:Paint(w,h)
		if !bOK:IsDown() then
			draw.RoundedBox(5,0,0,w,h,Color(255,0,0))
		else
			draw.RoundedBox(5,0,0,w,h,Color(150,0,0))
		end
	end 
	bOK:SetColor(Color(255,255,255))
	bOK:SetPos(0, 120)
	bOK:CenterHorizontal()
	nwIdentif.OnEnter = function()
		teModel:RequestFocus()
		teModel:SelectAllText()
	end
	bOK.DoClick = function()
		net.Start("maks_quest_object")
		net.WriteEntity(ent)
		net.WriteString(teModel:GetValue())
		net.WriteInt(math.Round(nwIdentif:GetValue()), 32)
		net.SendToServer()
		window:Close()
	end
	window:MakePopup()
	nwIdentif:RequestFocus()
	nwIdentif:SelectAllText()
end

net.Receive("maks_quest_object",function()
	if !net.ReadBool() then
		if !LocalPlayer():IsAdmin() then return end -- useless check
		showObjectMenu(net.ReadEntity())
	else
		chat.AddText(Color(255,25,0), "[QUEST] Vous avez pris cette object")
	end
end)