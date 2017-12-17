include("shared.lua")

surface.CreateFont("npc_namemaks",{
	size = 50
})

function ENT:Draw()
	self:DrawModel()
	local ang = self:GetAngles()
	local pos = self:GetPos()
	ang:RotateAroundAxis(self:GetAngles():Right(),-90)
	ang:RotateAroundAxis(self:GetAngles():Forward(),90)
	cam.Start3D2D(self:GetPos(),ang, 0.1)
		draw.SimpleText(self:GetFirstName() or "ERROR","npc_namemaks",0,-800,Color(255,255,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
	cam.End3D2D()
	ang:RotateAroundAxis(self:GetAngles():Up(),180)
	cam.Start3D2D(self:GetPos(),ang, 0.1)
		draw.SimpleText(self:GetFirstName() or "ERROR","npc_namemaks",0,-800,Color(255,255,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
	cam.End3D2D()        
end