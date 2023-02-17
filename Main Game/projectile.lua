--Projectile Class

Projectile={}
Projectile.__index=Projectile
setmetatable(Projectile,Mover)

Projectile.Target={x=0,y=0}
Projectile.Start={x=0,y=0}
Projectile.Damage=0
Projectile.Range=0
Projectile.Explodes=false
Projectile.Homes=false
Projectile.Source=nil
Projectile.Terminate=false
Projectile.ByDir=false

function Projectile:init(tX,tY,projCh,source,byDir)
	local speed=projCh[AM_SPEED]
	local srcCtr=source:center()
	self.X=srcCtr.x
	self.Y=srcCtr.y
	if source.fire_pos then
		local fp=source:fire_pos()
		self.X=fp[X]
		self.Y=fp[Y]
	end
	self.Start.x=self.X
	self.Start.y=self.Y
	self.Damage=projCh[AM_DAMAGE]
	self.Explodes=projCh[AM_EXPLODES]
	self.Homes=projCh[AM_HOMES]
	self.Target.x=tX
	self.Target.y=tY
	self.Source=source
	self.TopSpeed=speed
	self.DeltaSpeed=speed
	self.Travel=Vector:new(tX-srcCtr.x,tY-srcCtr.y):normalize():scale(speed)
	self.Range=distance(self.Target.x,self.Target.y,self.Start.x,self.Start.y)
	self.ByDir=byDir or false
end


function Projectile:animate()
	if self.ByDir then
		self.cellX=self:direction()
	else
		self.DelayT=self.DelayT+1
		if self.DelayT>=self.Delay then
			self.DelayT=0
			self.cellX=self.cellX+1
			if self.cellX>=self.CellsPerRow then self.cellX=0 end
		end
	end
end

function Projectile:determine_termination()
	local MARGIN=16
	local x=self.X
	local y=self.Y
	self.Duration=self.Duration-1
	if distance(x,y,self.Start.x,self.Start.y)>self.Range then
		self.Terminate=true
	elseif x<cam.x-MARGIN or x>=cam.x+SC_HUD+MARGIN or y<cam.y-MARGIN or y>=cam.y+SC_H+MARGIN then
		self.flagRemoval=true
	end
end

function Projectile:update()
	self:move()
	self:determine_termination()
	self:animate()
end