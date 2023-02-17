--Door Class

Door={}
Door.__index=Door
setmetatable(Door,Terrain)

Door.OPEN_TIME=40 Door.OpenT=nil

function Door:check_access(avt)
	local THRESHOLD=24
	local colReg=self:absolute_col_reg(1)
	if not self.OpenT and keycard==true and distance(avt.X,avt.Y,colReg.X,colReg.Y)<=THRESHOLD then
		self.OpenT=Door.OPEN_TIME
		play_sound(sfxOpen,true)
	end
end

function Door:animate()
	if not self.OpenT then
		self.cellX=#self.Cells-1
	else self.cellX=math.floor((self.OpenT/Door.OPEN_TIME)*(#self.Cells-1)) end
end

function Door:update()
	if self.OpenT then
		self.OpenT=self.OpenT-1
		if self.OpenT<=0 then self.flagRemoval=true end
	end
	self:animate()
end