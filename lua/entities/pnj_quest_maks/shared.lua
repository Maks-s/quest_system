ENT.Base = "base_ai"
ENT.Type = "ai"
ENT.PrintName = "Quest NPC"
ENT.Author = "Maks"
ENT.Category = "Quest"
ENT.Purpose = "Questing"
ENT.Spawnable = true
ENT.AdminOnly = true

function ENT:SetupDataTables()
	self:NetworkVar("String", 0, "FirstName")
	self:NetworkVar("String", 1, "ModelNames")
	self:NetworkVar("Int", 0, "Identif")
	if SERVER then
		self:SetFirstName("Click me")
		self:SetModelNames(MAKS_QUEST.Config.defaultPMModel)
		self:SetIdentif(-1)
	end
end