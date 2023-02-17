--Collision Detection

CollisionRegion={}
CollisionRegion.__index=CollisionRegion
function CollisionRegion:new(x,y,w,h)
	return setmetatable({X=x or 0,Y=y or 0,W=w,H=h},self)
end

function CollisionRegion:intersects(other)
	if self.W and self.H and other.W and other.H then
		return self.X<(other.X+other.W) and (self.X+self.W)>other.X and self.Y<(other.Y+other.H) and (self.Y+self.H)>other.Y
	elseif self.W and self.H and not other.W and not other.H then
		return other.X>=self.X and other.X<self.X+self.W and other.Y>=self.Y and other.Y<self.Y+self.H
	elseif self.W and not self.H then
		local operand=self.W
		if other.W then operand=operand+other.W end
		operand=operand+other.W
		return math.sqrt((other.X-self.X)^2+(other.Y-self.Y)^2)<operand
	end
	return false
end