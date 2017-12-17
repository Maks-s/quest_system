ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Quest Object"
ENT.Spawnable = true
ENT.AdminOnly = true
ENT.Category = "Quest"
ENT.Instructions = "Take me with E"
ENT.Author = "Maks"
ENT.Purpose = "Do quest"

function ENT:SetupDataTables()
	self:NetworkVar("Int",0,"Identif")
	self:NetworkVar("String",0,"ModelNames")
	if SERVER then
		self:SetIdentif(-1)
	end
end