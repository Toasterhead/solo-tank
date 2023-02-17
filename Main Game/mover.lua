--Mover Class

Mover={}
Mover.__index=Mover
setmetatable(Mover,GameObject)

Mover.Velocity=Vector:new() Mover.Travel=Vector:new() Mover.push=Vector:new() Mover.Inertia=0.4 Mover.TopSpeed=0.5 Mover.DeltaSpeed=0.1 Mover.inMud=false Mover.Splash=nil
function Mover:init(inert,tS,dS) self.Inertia=inert self.TopSpeed=tS self.DeltaSpeed=dS end

function Mover:move()
	self.Velocity=self.Velocity:add(self.Travel)
	self.Velocity=self.Velocity:add(self.push)	
	self:set_splash()
	if self.inMud==true then
		self.Velocity=self.Velocity:scale(0.25)
		self.inMud=false
	end
	self.X=self.X+self.Velocity.x
	self.Y=self.Y+self.Velocity.y
  	self.Velocity=Vector:new()
	self:apply_friction()
end

function Mover:apply_friction()
	local m=self.push:magnitude()
	if m~=0 then
		self.push=self.push:scale((m-self.Inertia)/m)
		if self.push:magnitude()<=self.Inertia then self.push=Vector:new() end
	end
end

function Mover:set_motion(rotations)
	local dS=self.DeltaSpeed
	if rotations then
		local theta=rotations*ROTATION
		self.Travel=self.Travel:add(Vector:new(math.cos(theta)*dS,math.sin(theta)*dS))
		local m=self.Travel:magnitude()
		if m>self.TopSpeed then self.Travel=self.Travel:scale(self.TopSpeed/m) end
	else
		local m=self.Travel:magnitude()
		if m<dS then self.Travel=Vector:new()
		else self.Travel=self.Travel:add(self.Travel:scale(-dS/m)) end
	end
end

function Mover:direction()
	local SLICE=(1/16)
	theta=self.Travel:angle()
	local rot=theta/ROTATION
	if (rot>=1-SLICE and rot<1) or (rot>=ROT_E and rot<ROT_E+SLICE) then return DIR_E
	elseif rot>=ROT_SE-SLICE and rot<ROT_SE+SLICE then return DIR_SE
	elseif rot>=ROT_S-SLICE and rot<ROT_S+SLICE then return DIR_S
	elseif rot>=ROT_SW-SLICE and rot<ROT_SW+SLICE then return DIR_SW
	elseif rot>=ROT_W-SLICE and rot<ROT_W+SLICE then return DIR_W
	elseif rot>=ROT_NW-SLICE and rot<ROT_NW+SLICE then return DIR_NW
	elseif rot>=ROT_N-SLICE and rot<ROT_N+SLICE then return DIR_N
	elseif rot>=ROT_NE-SLICE and rot<ROT_NE+SLICE then return DIR_NE
	else return DIR_E end
end

function Mover:neutralize(axis)
	local values={0,0}
	if axis==X then values={self.Velocity.x,0}
	elseif axis==Y then values={0,self.Velocity.y} end
	self.Travel=Vector:new(values[X],values[Y])
	self.Velocity=Vector:new(values[X],values[Y])
end

function Mover:set_splash()
	if self.inMud==true and t%3==0 and self.Velocity:magnitude()>0 then
		local IMG_ID=319
		local dir=self:direction()
		local id,x,y,f,r=0
		id=0 x=0 y=0 f=0
		if t%6==0 then
			if dir==DIR_E then x=-10 y=-7
			elseif dir==DIR_SE then id=16 x=-12 y=-3
			elseif dir==DIR_S then x=-7 y=-10 f=1 r=1
			elseif dir==DIR_SW then id=16 x=12 y=-3 f=2 r=2
			elseif dir==DIR_W then x=10 y=-7 f=1
			elseif dir==DIR_NW then id=16 x=12 y=3 r=2
			elseif dir==DIR_N then x=-7 y=10 r=3
			elseif dir==DIR_NE then id=16 x=-12 y=3 f=1 r=2 end
		else
			if dir==DIR_E then x=-10 y=7 f=2
			elseif dir==DIR_SE then id=16 x=-3 y=-12 f=1 r=1
			elseif dir==DIR_S then x=7 y=-10 r=1
			elseif dir==DIR_SW then id=16 x=3 y=-12 r=1
			elseif dir==DIR_W then x=10 y=7 f=3
			elseif dir==DIR_NW then id=16 x=3 y=12 f=1 r=3
			elseif dir==DIR_N then x=7 y=10 f=1 r=3
			elseif dir==DIR_NE then id=16 x=-3 y=12 r=3 end
		end
		self.Splash=ImageInfo:new(IMG_ID+id,x-4,y-4,0,0,1,f,r)
	else self.Splash=nil end
end

function Mover:update()
	self:move()
	self:animate()
	if self.peripheral then self.peripheral:update() end
end