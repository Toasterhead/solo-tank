--Game Object Class

GameObject={}
GameObject.__index=GameObject
function GameObject:new(x,y,z,cells,collisionRegions,cellsPerRow,delay,centerOffset,impact)
	return setmetatable(
		{
			X=x,
			Y=y,
			Z=z,
			Cells=cells or {},
			CollisionRegions=collisionRegions or {},
			CellsPerRow=cellsPerRow or #cells,
			Delay=delay or 5,
			DelayT=0,
			CenterOffset=centerOffset or {8,8},
			TheImpact=impact or nil,
			cellX=0,
			cellY=0,
			visible=true,
			flagRemoval=false
		},self)
end

function GameObject:reposition(x,y) self.X=x self.Y=y end

function GameObject:center()
	local c=self.CenterOffset
	return {x=self.X+c[X],y=self.Y+c[Y]}
end

function has_col_reg() return #self.CollisionRegions>0 end

function GameObject:absolute_col_reg(i,radial)
	local cr=self.CollisionRegions[i]
	if radial and radial==true then return CollisionRegion:new(self:center().x,self:center().y,cr.W/2) end
	return CollisionRegion:new(self.X+cr.X,self.Y+cr.Y,cr.W,cr.H)
end

function GameObject:animate()
	self.DelayT=self.DelayT+1
	if self.DelayT>=self.Delay then
		self.DelayT=0
		self.cellX=self.cellX+1
		if self.cellX>=self.CellsPerRow then
			self.cellX=0
			self.cellY=self.cellY+1 
			if self.cellY>=math.floor(#self.Cells/self.CellsPerRow) then self.cellY=0 end
		end
	end
end

function GameObject:update()
	self:animate()
	if self.peripheral then self.peripheral:update() end
end