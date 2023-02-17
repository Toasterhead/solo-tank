--Terrain Class

Terrain={}
Terrain.__index=Terrain
setmetatable(Terrain,TileObject)

Terrain.Vitality=nil Terrain.Type=TRN_WALL

function Terrain:init(trnType,strength)
	self.Type=trnType
	self.Vitality=strength
end

function Terrain:adjust_vitality(amount)
	if self.Vitality then
		self.Vitality=self.Vitality+amount
		if self.Vitality<=0 then self.flagRemoval=true end
	end
end