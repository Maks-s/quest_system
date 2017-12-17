AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

function ENT:Initialize()
	timer.Simple(0.1, function() -- Model not saving with perma props if not this
		if !IsValid(self) then return end
		self:SetModel( (util.IsValidModel(self:GetModelNames()) and self:GetModelNames() or MAKS_QUEST.Config.defaultPMModel ) ) -- If not valid display default pm
		self:SetHullType(HULL_HUMAN)
		self:SetHullSizeNormal()
		self:SetNPCState(NPC_STATE_IDLE)
		self:SetSolid(SOLID_BBOX)
		self:CapabilitiesAdd(CAP_ANIMATEDFACE)
		self:SetUseType(SIMPLE_USE)
	end)
end

function ENT:OnTakeDamage()
	return false
end

function ENT:AcceptInput(Name, _, ply)
	if Name == "Use" and ply:IsPlayer() and IsValid(ply) then
		local init = (self:GetIdentif() <= 0 and true or false) -- If id is -1 init = true else = false
		net.Start("maks_questnpc_futur")
		net.WriteBool(init)
		net.WriteEntity(self)
		net.Send(ply)
	end
end