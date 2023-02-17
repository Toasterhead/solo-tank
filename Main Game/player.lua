--Player Definition

playerBarrelCells=generate_cells(
	272,
	2,
	{
		{{0,0,0,0,0}},{{1,0,0,0,0}},{{2,0,0,0,0}},{{1,0,0,2,1}},
		{{0,0,0,0,1}},{{1,0,0,0,1}},{{2,0,0,0,1}},{{1,0,0,2,0}},
		{{0,0,0,0,2}},{{1,0,0,0,2}},{{2,0,0,0,2}},{{1,0,0,1,1}},
		{{0,0,0,0,3}},{{1,0,0,0,3}},{{2,0,0,0,3}},{{1,0,0,1,0}}
	},
	0)
playerPersonCells=generate_cells(
	292,
	1,
	{
		{{1,0,0,0,0},{17,0,8,0,0}},{{3,0,0,0,0},{19,0,8,0,0}},{{1,0,0,0,0},{17,0,8,0,0}},{{3,0,0,1,0},{19,0,8,1,0}},
		{{4,0,0,0,0},{20,0,8,0,0}},{{5,0,0,0,0},{21,0,8,0,0}},{{4,0,0,0,0},{20,0,8,0,0}},{{6,0,0,0,0},{22,0,8,0,0}},
		{{0,0,0,0,0},{16,0,8,0,0}},{{2,0,0,0,0},{18,0,8,0,0}},{{0,0,0,0,0},{16,0,8,0,0}},{{2,0,0,1,0},{18,0,8,1,0}},
		{{4,0,0,1,0},{20,0,8,1,0}},{{5,0,0,1,0},{21,0,8,1,0}},{{4,0,0,1,0},{20,0,8,1,0}},{{6,0,0,1,0},{22,0,8,1,0}},
		{{1,0,0,0,0},{7,0,8,0,0}},{{4,0,0,0,0},{9,0,8,0,0}},{{0,0,0,0,0},{8,0,8,0,0}},{{4,0,0,1,0},{9,0,8,1,0}}
	},
	0)
ptcDiagonal=generate_cells(
	288,
	1,
	{
		{{0,0,0,0,0},{2,8,0,0,0},{2,0,8,3,0},{0,8,8,0,2},{16,0,-8,1,1},{18,8,-8,0,0},{16,-8,0,0,0},{18,16,0,1,3},{18,-8,8,1,1},{16,16,8,3,0},{18,0,16,3,0},{16,8,16,2,1}},
		{{1,0,0,0,0},{2,8,0,0,0},{2,0,8,3,0},{1,8,8,2,1},{17,0,-8,0,0},{18,8,-8,0,0},{16,-8,0,1,1},{18,16,0,1,3},{18,-8,8,1,1},{17,16,8,3,0},{18,0,16,0,2},{16,8,16,3,0}},
		{{1,0,0,1,1},{2,8,0,0,0},{2,0,8,3,0},{1,8,8,0,2},{16,0,-8,0,0},{18,8,-8,0,0},{17,-8,0,0,0},{18,16,0,1,3},{18,-8,8,1,1},{16,16,8,2,1},{18,0,16,0,2},{17,8,16,3,0}},		
		{{2,0,0,1,0},{0,8,0,0,1},{0,0,8,0,3},{2,8,8,2,0},{18,0,-8,1,0},{16,8,-8,0,1},{18,-8,0,0,3},{16,16,0,1,0},{16,-8,8,2,0},{18,16,8,0,1},{16,0,16,3,1},{18,8,16,2,0}},
		{{2,0,0,1,0},{1,8,0,0,1},{1,0,8,1,2},{2,8,8,2,0},{18,0,-8,1,0},{16,8,-8,1,0},{18,-8,0,0,3},{17,16,0,1,0},{16,-8,8,0,3},{18,16,8,0,1},{17,0,16,2,0},{18,8,16,2,0}},
		{{2,0,0,1,0},{1,8,0,1,0},{1,0,8,0,3},{2,8,8,2,0},{18,0,-8,1,0},{17,8,-8,1,0},{18,-8,0,0,3},{16,16,0,0,1},{17,-8,8,2,0},{18,16,8,0,1},{16,0,16,2,0},{18,8,16,2,0}},	
		{{0,0,0,0,0},{2,8,0,0,0},{2,0,8,3,0},{0,8,8,0,2},{16,0,-8,1,1},{18,8,-8,0,0},{16,-8,0,0,0},{18,16,0,1,3},{18,-8,8,1,1},{16,16,8,3,0},{18,0,16,3,0},{16,8,16,2,1}},
		{{1,0,0,1,1},{2,8,0,0,0},{2,0,8,3,0},{1,8,8,0,2},{16,0,-8,0,0},{18,8,-8,0,0},{17,-8,0,0,0},{18,16,0,1,3},{18,-8,8,1,1},{16,16,8,2,1},{18,0,16,3,0},{17,8,16,3,0}},
		{{1,0,0,0,0},{2,8,0,0,0},{2,0,8,3,0},{1,8,8,2,1},{17,0,-8,0,0},{18,8,-8,0,0},{16,-8,0,1,1},{18,16,0,1,3},{18,-8,8,1,1},{17,16,8,3,0},{18,0,16,3,0},{16,8,16,0,2}},
		{{2,0,0,1,0},{0,8,0,0,1},{0,0,8,0,3},{2,8,8,2,0},{18,0,-8,1,0},{16,8,-8,0,1},{18,-8,0,0,3},{16,16,0,1,0},{16,-8,8,2,0},{18,16,8,0,1},{16,0,16,3,1},{18,8,16,2,0}},
		{{2,0,0,1,0},{1,8,0,1,0},{1,0,8,0,3},{2,8,8,2,0},{18,0,-8,1,0},{17,8,-8,1,0},{18,-8,0,0,3},{16,16,0,0,1},{17,-8,8,2,0},{18,16,8,0,1},{16,0,16,2,0},{18,8,16,2,0}},
		{{2,0,0,1,0},{1,8,0,0,1},{1,0,8,1,2},{2,8,8,2,0},{18,0,-8,1,0},{16,8,-8,1,0},{18,-8,0,0,3},{17,16,0,1,0},{16,-8,8,0,3},{18,16,8,0,1},{17,0,16,2,0},{18,8,16,2,0}}
	},
	0)
ptcOrthogonal=symmetrical_cells_from(
	ImageInfo:new(256,0,0,1,0,1,0,0,1,1),
	true,
	{256,257,258,259},
	1)
ptcDismounted=generate_cells(
	275,
	1,
	{{{0,0,0,0,0},{0,8,0,1,0},{16,0,8,0,0},{16,8,8,1,0}}},
	12)
playerTankCells=
{
	ptcOrthogonal[1],ptcOrthogonal[2],ptcOrthogonal[3],ptcOrthogonal[4],
	ptcDiagonal[1],ptcDiagonal[2],ptcDiagonal[3],ptcDiagonal[3],
	ptcOrthogonal[5],ptcOrthogonal[6],ptcOrthogonal[7],ptcOrthogonal[8],
	ptcDiagonal[4],ptcDiagonal[5],ptcDiagonal[6],ptcDiagonal[6],
	ptcOrthogonal[9],ptcOrthogonal[10],ptcOrthogonal[11],ptcOrthogonal[12],
	ptcDiagonal[7],ptcDiagonal[8],ptcDiagonal[9],ptcDiagonal[9],
	ptcOrthogonal[13],ptcOrthogonal[14],ptcOrthogonal[15],ptcOrthogonal[16],
	ptcDiagonal[10],ptcDiagonal[11],ptcDiagonal[12],ptcDiagonal[12],
	ptcDismounted[1],ptcDismounted[1],ptcDismounted[1],ptcDismounted[1]
}
local ColReg=CollisionRegion
playerBarrel=GameObject:new(0,0,0,playerBarrelCells,{},16,5)
playerPerson=Actor:new(30,30,0,playerPersonCells,{ColReg:new(1,2,6,8),ColReg:new(0,0,8,16)},4,10,{4,8})
playerTank=Actor:new(80,15,0,playerTankCells,{ColReg:new(2,2,12,12),ColReg:new(0,0,16,16)},4,5,{8,8})
playerTank.peripheral=playerBarrel playerTank.dismounting=false playerTank.chamber=nil
playerBarrel.parent=playerTank
playerPerson:init(0,0.35,0.35)

function playerTank:increase_shield(arg)
	if arg and arg==-1 then self.Shield=1 else self.Shield=self.Shield+1 end
	if self.Shield>=MAX_OTHER then self.Shield=MAX_OTHER-1 end
end

function playerTank:dismount_position(gs)
	local a=self.center()
	return {x=a.x-4,y=a.y+12}
end

function playerTank:fire_pos()
	local RADIUS=12
	local ctr=self:center()
	local theta=2*math.pi*self:direction()
	return {math.cos(theta)*RADIUS+self.X,math.sin(theta)*RADIUS+self.Y}
end

function playerTank:fire_pos()
	local RADIUS=8
	local mX,mY=absolute_mouse()
	local ctr=self:center()
	local displacement=Vector:new(mX-ctr.x,mY-ctr.y):normalize():scale(RADIUS)
	return {ctr.x+displacement.x,ctr.y+displacement.y}
end

function playerTank:animate()
	if self.dismounting==true then
		if self.cellX==0 and self.cellY==0 then
			local DISMOUNTED_CELL=8
			self.dismounting=false
			self.cellX=0 self.cellY=DISMOUNTED_CELL
		else
			self.DelayT=self.DelayT+1
			if self.DelayT>=self.Delay then
				self.DelayT=0
				if self.cellY==0 then self.cellX=(self.cellX+1)%self.CellsPerRow
				else self.cellY=(self.cellY+1)%(DIR_NW+1) end
			end
		end
	else
		local delay=self.Delay/(self.Travel:magnitude()/self.TopSpeed)
		local cellsPerRow=self.CellsPerRow
		if self.Travel.x~=0 or self.Travel.y~=0 then
			self.cellY=self:direction()
			if self.cellY%2==1 then
				delay=math.floor(delay*1.33+0.5)
				cellsPerRow=cellsPerRow-1 
			end
			self.DelayT=self.DelayT+1
			if self.DelayT>=delay then
				self.DelayT=0
				self.cellX=self.cellX+1
				if self.cellX>=cellsPerRow then self.cellX=0 end
			end
		end
	end
end

function playerPerson:animate()
	local STATIONARY=4
	local dir=self:direction()
	if self.Travel.x~=0 or self.Travel.y~=0 then
		if dir%2==0 then self.cellY=dir//2 end
		self.DelayT=self.DelayT+1
		if self.DelayT>=self.Delay then
			self.DelayT=0
			self.cellX=self.cellX+1
			if self.cellX>=self.CellsPerRow then self.cellX=0 end
		end
	elseif self.cellY~=STATIONARY then
		self.cellX=self.cellY
		self.cellY=STATIONARY
	end
end

function playerBarrel:animate()
	local mX,mY=absolute_mouse()
	local dX=mX-(self.parent.X+8)
	local dY=mY-(self.parent.Y+8)
	local theta=math.atan(dY/dX)
	local adjustment=0.5+(1/16)
	if dX<0 then theta=math.pi+theta end
	theta=coterminal(theta+(adjustment*math.pi))
	local rot=theta/ROTATION
	self.cellX=math.floor(rot*self.CellsPerRow)
	local cellX=self.cellX
	local pX=self.parent.X
	local pY=self.parent.Y
	local a={self.X,self.Y}
	if cellX==0 then a={pX+4,pY-2}
	elseif cellX==1 then a={pX+7,pY-2}
	elseif cellX==2 then a={pX+9,pY-1}
	elseif cellX==3 then a={pX+10,pY+1}
	elseif cellX==4 then a={pX+10,pY+4}
	elseif cellX==5 then a={pX+10,pY+7}
	elseif cellX==6 then a={pX+9,pY+9}
	elseif cellX==7 then a={pX+7,pY+10}
	elseif cellX==8 then a={pX+4,pY+10}
	elseif cellX==9 then a={pX+1,pY+10}
	elseif cellX==10 then a={pX-1,pY+9}
	elseif cellX==11 then a={pX-2,pY+7}
	elseif cellX==12 then a={pX-2,pY+4}
	elseif cellX==13 then a={pX-2,pY+1}
	elseif cellX==14 then a={pX-1,pY-1}
	elseif cellX==15 then a={pX+1,pY-2}
	end
	self.X=a[1]
	self.Y=a[2]
end