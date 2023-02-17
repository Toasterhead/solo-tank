--Tripwire Class

Tripwire={}
Tripwire.__index=Tripwire
setmetatable(Tripwire,Terrain)

function Tripwire:deactivate()
	self.flagRemoval=true
	--
end