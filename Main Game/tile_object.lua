--Tile Object Class

TileObject={}
TileObject.__index=TileObject
function TileObject:new(x,y,cells,collisionRegions,delay,under)
	return setmetatable(
		{
			X=x,
			Y=y,
			Cells=cells or {},
			CollisionRegions=collisionRegions or {},
			Delay=delay or 10,
			Under=under or -1,
			cellX=0,
			visible=true,
			flagRemoval=false
		},self)
end

function TileObject:center()
	local CR=self.CollisionRegions
	local colReg=nil
	if CR and #CR>0 then colReg=self:absolute_col_reg(1) end
	if colReg then return {x=colReg.X+(0.5*colReg.W),y=colReg.Y+(0.5*colReg.H)} end
	return {x=8*self.X+4,y=8*self.Y+4}
end

function has_col_reg() return #self.CollisionRegions>0 end

function TileObject:absolute_col_reg(i,radial)
	local cr=self.CollisionRegions[i]
	if radial and radial==true then return CollisionRegion:new(self:center().x,self:center().y,cr.W/2) end
	return CollisionRegion:new((8*self.X)+cr.X,(8*self.Y)+cr.Y,cr.W,cr.H)
end

function TileObject:remove_tile()
	local BLANK=10
	local under=self.Under
	if under==-1 then under=BLANK end
	for i=1,#self.Cells[1] do mset(self.X+self.Cells[1][i].x,self.Y+self.Cells[1][i].y,under) end
	self.flagRemoval=true
end

function TileObject:animate()
	local tRange=self.Delay*#self.Cells
	self.cellX=math.floor(((t%tRange)/tRange)*#self.Cells)
end

function TileObject:update() self:animate() end