-- title:   Solo Tank (Tentative)
-- author:  Lenny Young
-- desc:    N/A
-- site:    N/A
-- license: MIT License
-- version: 0.1
-- script:  lua

--Global Data

cam={["x"]=0,["y"]=0,["z"]=0,["mode"]=0}
reticle={["radii"]={3,5,7},["color"]=7,["outOfRange"]=12}
redTimer={["t"]=180,["initial"]=180}

X=1
Y=2
Z=3

GM_MENU=0
GM_ACTION=1
GM_PAUSE=2
GM_GAME_OVER=3

SC_W=240
SC_H=136
SC_HUD=200

CAM_CENTER=0
CAM_LOCK_HORIZONTAL=1
CAM_LOCK_VERTICAL=2

SHL_INDEX_RANGE=1
SHL_INDEX_SPEED=2
SHL_INDEX_DAMAGE=3
SHL_INDEX_EXPLODES=4

SHELL_BACKUP={50,5,15,false}
SHELL_STANDARD={60,5,25,false}
SHELL_LONG={150,6,25,false}
SHELL_HEAVY={75,2,50,true}
SHELL_HOMING={100,4,35,true}

DIR_N=0.75
DIR_NE=0.875
DIR_E=0
DIR_SE=0.125
DIR_S=0.25
DIR_SW=0.375
DIR_W=0.5
DIR_NW=0.675
ROTATION=6.28

NUM_LAYERS=5
LAYER_CUTOFF=3
SCREEN_MARGIN=32

gameMode=GM_MENU
gameObjects={}
avatar=nil

--Vector Class

Vector={}
Vector.__index=Vector
function Vector:new(x,y)
	return setmetatable({x=x or 0,y=y or 0},self)
end

function Vector:magnitude()
	return math.sqrt(self.x^2+self.y^2)
end

function Vector:add(other)
	return Vector:new(self.x+other.x,self.y+other.y)
end

function Vector:scale(scalar)
	return Vector:new(scalar*self.x,scalar*self.y)
end

--Collision Detection

CollisionRegion={}
CollisionRegion.__index=CollisionRegion
function CollisionRegion:new(x,y,w,h)
	return setmetatable({x=x or 0,y=y or 0,w=w or 8,h=h or 8},self)
end

function CollisionRegion:intersects(other)
	if other.w and other.h then
		return false--
	elseif other.w and not other.h then
		return math.sqrt((other.x-self.x)^2+(other.y-self.y)^2)<self.w
	else return other.x>=self.x and other.x<self.x+self.w and other.y>=self.y and other.y<self.y+self.h end
end

--Information Structures

ImageInfo={}
ImageInfo.__index=ImageInfo
function ImageInfo:new(id,x,y,z,colorKey,scale,flip,rotate,w,h)
	return setmetatable({id=id,x=x or 0,y=y or 0,z=z or 0,colorkey=colorKey or -1,scale=scale or 1,flip=flip or 0,rotate=rotate or 0,w=w or 1,h=h or 1},self)
end

--Game Object Class

GameObject={}
GameObject.__index=GameObject
function GameObject:new(x,y,cells,collisionRegions,cellsPerRow,delay)
	return setmetatable(
		{
			X=x,
			Y=y,
			Cells=cells or {},
			CollisionRegions=collisionRegions or {},
			CellsPerRow=cellsPerRow or #cells,
			Delay=delay or 5,
			DelayT=0,
			cellX=0,
			cellY=0,
			visible=true,
			flagRemoval=false
		},
		self)
end

function GameObject:reposition(x,y)
	self.X=x
	self.Y=y
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

--Derived Game Object Classes

Impact={} --Needs testing.
Impact.__index=Impact
setmetatable(Impact,GameObject)

Impact.potent=true Impact.duration=6

function Impact:update()
	self.duration=self.duration-1
	self.potent=false
	if self.duration<=0 then self.flagRemoval=true end
	self:animate()
	if self.peripheral then player.peripheral:update() end
end

Mover={}
Mover.__index=Mover
setmetatable(Mover,GameObject)

Mover.Velocity=Vector:new() Mover.Travel=Vector:new() Mover.TopSpeed=1 Mover.DeltaSpeed=0.1

function Mover:move()
	--self.Velocity:add(self.Travel) --Fails. Investigate later.
	self.X=self.X+self.Velocity.x
	self.Y=self.Y+self.Velocity.y
end

function Mover:set_movement(theta)
	local deltaS=self.DeltaSpeed
	if theta then
		self.Travel=self.Travel.add(math.cos(theta)*deltaS,math.sin(theta)*deltaS)
		local magnitude=self.Travel.magnitude()
		if magnitude>self.TopSpeed then self.Travel.scale(self.TopSpeed/magnitude) end
	else
		local magnitude=self.Travel.magnitude()
		if magnitude<deltaS then self.Travel=Vector:new()
		else
			local invertedNormal=self.Travel.scale(-deltaS/magnitude)
			self.Travel.add(invertedNormal)
		end
	end
end

function Mover:direction()
	local SLICE=(1/16)*ROTATION
	local theta=math.atan(self.Travel.Y/self.Travel.X)+(ROTATION/2)
	if theta>=ROTATION-SLICE and theta<E+SLICE then return E
	elseif theta>=SE-SLICE and theta<SE+SLICE then return SE
	elseif theta>=S-SLICE and theta<S+SLICE then return S
	elseif theta>=SW-SLICE and theta<SW+SLICE then return SW
	elseif theta>=W-SLICE and theta<W+SLICE then return W
	elseif theta>=NW-SLICE and theta<NW+SLICE then return NW
	elseif theta>=N-SLICE and theta<N+SLICE then return N
	elseif theta>=NE-SLICE and theta<NE+SLICE then return NE end
end

function Mover:neutralize(axis)
	local values={0,0}
	if axis==X then values={self.Velocity.x,0}
	elseif axis==Y then values={0,self.Velocity.y} end
	self.Velocity=Vector:new(values[X],values[Y])
end

function Mover:update()
	self:move()
	self:animate()
	if self.peripheral then self.peripheral:update() end
end

Projectile={} --Needs testing.
Projectile.__index=Projectile
setmetatable(Projectile,Mover)

Projectile.Characteristics=SHELL_BACKUP Projectile.FromPlayer=false Projectile.Target={["X"]=0,["Y"]=0} Projectile.Terminate=false

function Projectile:determine_termination()
	if self.X<cam.x-SCREEN_MARGIN or self.X>=cam.x+SC_HUD+SCREEN_MARGIN or self.Y<cam.y-SCREEN_MARGIN or self.Y>=cam.y+SC_HUD+SCREEN_MARGIN then
		flagRemoval=true
	elseif self.Characteristics[RANGE]<=0 then
		self.Terminate=true
	elseif Vector:new(self.X-self.Target.X,self.Y-self.Target.Y).magnitude<=self.Characteristics[SPEED] then
		self.Terminate=true
	end
end

function Projectile:update()
	self:move()
	self:determine_termination()
	self:animate()
	if self.peripheral then player.peripheral:update() end
end

Actor={}
Actor.__index=Actor
setmetatable(Actor,Mover)

Actor.vitality=100 Actor.shield=1

function Actor:behave() end

function Actor:update()
	self:behave()
	self:move()
	self:animate()
	if self.peripheral then player.peripheral:update() end
end

--Animation Cell Manipulation

function rotated_from(cell,quarters) --Incomplete. Not used.
	rotated={}
	local rw=cell[1].x
	local rh=cell[1].y
	for i=2,#cell do
		if cell[i].x>rw then rw=cell[i].x end
		if cell[i].y<rh then rh=cell[i].y end
	end
	local midX=rw/2
	local midY=rh/2
	for i=1,#cell do
		quarters=(cell[i].rotate+quarters)%4
		local imgX,imgY=0
		local x=cell[i].x-midX
		local y=cell[i].y-midY
		if x>=0 and y>=0 then
			if quarters==1 then x=-y y=x
			elseif quarters==2 then x=-x y=-y
			elseif quarters==3 then x=y y=-x
			end
		elseif x<0 and y>=0 then
			if quarters==1 then x=y y=x
			elseif quarters==2 then x=-x y=-y
			elseif quarters==3 then x=-y y=-x
			end
		end
		rotated[i]=ImageInfo:new(cell[i].id,midX+x,midY+y,cell[i].z,cell[i].colorKey,cell[i].scale,cell[i].flip,quarters,cell[i].w,cell[i].h)
	end
	return rotated
end

function symmetrical_cells_from(imgInfo,rotated,animation,animationStyle)
	rotated=rotated or false
	animation=animation or {imgInfo.id}
	animationStyle=animationStyle or 0
	local IMAGES_PER_CELL=4
	local cells={}
	local cellsCounter=1
	local x=imgInfo.x
	local y=imgInfo.y
	local w=imgInfo.w*imgInfo.scale*8
	local h=imgInfo.h*imgInfo.scale*8
	local flips={{0,1,2,3},{1,0,3,2},{3,2,1,0},{2,3,0,1}}
	local xSet={x,x+w,x,x+w}
	local ySet={y,y,y+h,y+h}
	local nQuarters=4
	local messageCounter=0--
	if rotated==false then nQuarters=1 end
	local animationDirections={{1,1,1,1},{1,1,1,1},{1,1,1,1},{1,1,1,1}}
	if animationStyle==1 then
		animationDirections={{1,1,-1,-1},{-1,1,-1,1},{-1,-1,1,1},{1,-1,1,-1}}
	end
	for i=1,nQuarters do
		for j=1,#animation do
			local images={}
			for k=1,IMAGES_PER_CELL do
				local id
				if animationDirections[i][k]>0 then 
					id=animation[j]
				else id=animation[#animation-(j-1)] end
				images[k]=ImageInfo:new(id,xSet[k],ySet[k],imgInfo.z,imgInfo.colorKey,imgInfo.scale,flips[i][k],i-1,imgInfo.w,imgInfo.h)
			end
			cells[cellsCounter]=images
			cellsCounter=cellsCounter+1
		end
	end
	return cells
end

function rotated_set_from(imgInfo,asCells)
	asCells=asCells or true
	local N_QUARTERS=4
	local images={}
	for i=0,N_QUARTERS-1 do
		local imgInfo=ImageInfo:new(imgInfo.id,imgInfo.x,imgInfo.y,imgInfo.z,imgInfo.colorKey,imgInfo.scale,imgInfo.flip,(imgInfo.rotate+i)%4,imgInfo.w,imgInfo.h)		
		if asCells==true then
			images[i+1]={imgInfo}
		else images[i+1]=imgInfo end
	end
	return images
end

function generate_cells(baseId,z,args,colorKey,scale,w,h) --In progress.
	local RELATIVE_ID=1
	local X=2
	local Y=3
	local FLIP=4
	local ROTATE=5
	local COLOR_KEY=6
	local colorKey=colorKey or 0
	local scale=scale or 1
	local w=w or 1
	local h=h or 1
	local cells={}
	local cellsCounter=1
	for i=1,#args do
		local images={}
		for j=1,#args[i] do
			args[i][j][COLOR_KEY]=args[i][j][COLOR_KEY] or colorKey
			images[j]=ImageInfo:new(baseId+args[i][j][RELATIVE_ID],args[i][j][X],args[i][j][Y],z,args[i][j][COLOR_KEY],scale,args[i][j][FLIP],args[i][j][ROTATE],w,h)
		end
		cells[cellsCounter]=images
		cellsCounter=cellsCounter+1
	end
	return cells
end

function format_copied_from(cell,idArr)
	copied={}
	for i=1,#idArr do
		copied[i]=ImageInfo:new(idArr[i],cell[i].x,cell[i].y,cell[i].z,cell[i].colorKey,cell[i].scale,cell[i].flip,cell[i].rotate,cell[i].w,cell[i].h)
	end
	return copied
end

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
		{{1,0,0,0,0},{7,0,8,0,0}},{{4,0,0,0,0},{9,0,8,0,0}},{{0,0,0,0,0},{8,0,8,0,0}},{{4,0,0,1,0},{9,0,8,1,0}},
		{{1,0,0,0,0},{17,0,8,0,0}},{{3,0,0,0,0},{19,0,8,0,0}},{{1,0,0,0,0},{17,0,8,0,0}},{{3,0,0,1,0},{19,0,8,1,0}},
		{{4,0,0,0,0},{20,0,8,0,0}},{{5,0,0,0,0},{21,0,8,0,0}},{{4,0,0,0,0},{20,0,8,0,0}},{{6,0,0,0,0},{22,0,8,0,0}},
		{{0,0,0,0,0},{16,0,8,0,0}},{{2,0,0,0,0},{18,0,8,0,0}},{{0,0,0,0,0},{16,0,8,0,0}},{{2,0,0,1,0},{18,0,8,1,0}},
		{{4,0,0,1,0},{20,0,8,1,0}},{{5,0,0,1,0},{21,0,8,1,0}},{{4,0,0,1,0},{20,0,8,1,0}},{{6,0,0,1,0},{22,0,8,1,0}}
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
playerTankCells=
{
	ptcOrthogonal[1],ptcOrthogonal[2],ptcOrthogonal[3],ptcOrthogonal[4],
	ptcDiagonal[1],ptcDiagonal[2],ptcDiagonal[3],ptcDiagonal[3],
	ptcOrthogonal[5],ptcOrthogonal[6],ptcOrthogonal[7],ptcOrthogonal[8],
	ptcDiagonal[4],ptcDiagonal[5],ptcDiagonal[6],ptcDiagonal[6],
	ptcOrthogonal[9],ptcOrthogonal[10],ptcOrthogonal[11],ptcOrthogonal[12],
	ptcDiagonal[7],ptcDiagonal[8],ptcDiagonal[9],ptcDiagonal[9],
	ptcOrthogonal[13],ptcOrthogonal[14],ptcOrthogonal[15],ptcOrthogonal[16],
	ptcDiagonal[10],ptcDiagonal[11],ptcDiagonal[12],ptcDiagonal[12]
}
playerBarrel=GameObject:new(0,0,playerBarrelCells,{},16,5)
playerPerson=Mover:new(30,30,playerPersonCells,{},4,30)
playerTank=Mover:new(80,15,playerTankCells,{},1,5)
playerTank.peripheral=playerBarrel

function playerTank:animate()
	local diagonalCellsPerRow=3
	local diagonalDelay=math.floor(self.Delay*1.33+0.5)
	if self.velocity.x~=0 or self.velocity.y~=0 then
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
end

avatar=playerTank
playerTank.Velocity.y=1

--Game Loop

function TIC()
	check_input()
	update_state()
	draw_screen()
end

function BDR()
	vbank(1)
	cls(0)
	draw_reticle()
	draw_hud()
end

function check_input()
	if btn(0) or key(23)then cam.y=cam.y-1 end
	if btn(1) or key(19)then cam.y=cam.y+1 end
	if btn(2) or key(1) then cam.x=cam.x-1 end
	if btn(3) or key(4) then cam.x=cam.x+1 end
end

function update_state()
	playerTank:update()
	playerPerson:update()
end

function draw_screen()
	vbank(0)
	cls(0)
	clip(0,0,SC_HUD,SC_H)
	cls(4)
	draw_map()
	draw_game_object(playerTank)
	draw_game_object(playerPerson)
	if redTimer.t~=-1 then
		redTimer.t=redTimer.t-1
		if redTimer.t<=0 then redTimer.t=-1 end
		draw_red_effect(redTimer.t/redTimer.initial)
	end
	print(playerTank.Velocity.y,84,84,7)
	print(playerTank.X,84,92,7)
end

function draw_map()
	map(cam.x//8,cam.y//8,(SC_HUD//8)+1,(SC_H//8)+1,-(cam.x%8),-(cam.y%8))
end

function draw_game_object(gObj)
	local prior=gObj.cellY*gObj.CellsPerRow
	local cell=gObj.Cells[prior+gObj.cellX+1]
	for j=1,#cell do
		spr(cell[j].id,(gObj.X+cell[j].x)-cam.x,(gObj.Y+cell[j].y)-cam.y,cell[j].colorKey,cell[j].scale,cell[j].flip,cell[j].rotate,cell[j].w,cell[j].h)
	end
	if gObj.peripheral then draw_game_object(gObj.peripheral) end
end

function draw_reticle()
	local PLAYER_RADIUS=12
	local mX,mY=mouse()
	local mapPosX=mX+cam.x
	local mapPosY=mY+cam.y
	local color=reticle.color
	--Note: Replace '50' with ammunition type's range and '8' with hit-box's center later.
	local distance=Vector:new(mapPosX-(playerTank.X+8),mapPosY-(playerTank.Y+8)):magnitude()
	if distance>50 or distance<PLAYER_RADIUS then color=reticle.outOfRange end
	line(mX,mY-reticle.radii[1],mX,mY-reticle.radii[3],color)
	line(mX+reticle.radii[1],mY,mX+reticle.radii[3],mY,color)
	line(mX,mY+reticle.radii[1],mX,mY+reticle.radii[3],color)
	line(mX-reticle.radii[1],mY,mX-reticle.radii[3],mY,color)
	circb(mX,mY,reticle.radii[2],color)
end

function draw_red_effect(level)
	local BASE_RED=11
	for i=0,SC_HUD-1 do
		for j=0,SC_H-1 do
			local c=pix(i,j)
			if level>=0.0 and (c==1 or c==4 or c==14 or c==8) then pix(i,j,BASE_RED+0)
			elseif level>=0.33 and (c==2 or c==5 or c==15 or c==9) then pix(i,j,BASE_RED+1)
			elseif level>=0.67 and (c==3 or c==6 or c==7 or c==10) then pix(i,j,BASE_RED+2) end
		end
	end
end

function draw_hud()
	clip(SC_HUD,0,SC_W,SC_H)
	print("HUD test.",SC_HUD,32,7)--
end

function compare_z(a,b) return a.z<b.z end --Might not be used.