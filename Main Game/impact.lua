--Impact Class

Impact={}
Impact.__index=Impact
setmetatable(Impact,GameObject)

function Impact:animate()
	self.DelayT=self.DelayT+1
	if self.DelayT>=self.Delay then
		self.DelayT=0
		self.cellX=self.cellX+1
		if self.cellX>=self.CellsPerRow then self.flagRemoval=true end
	end
end

function Impact:update() self:animate() end

