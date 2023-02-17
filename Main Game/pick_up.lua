--Pick-up Class

PickUp={}
PickUp.__index=PickUp
setmetatable(PickUp,TileObject)

PickUp.Id=0 PickUp.Value=0

function PickUp:init(id)
	self.Id=id
	if id==PCK_REPAIR then self.Value=15
	elseif id==PCK_FULL_REPAIR then self.Value=MAX_VITALITY
	elseif id==PCK_SHIELD or id==PCK_EXTRA_LIFE then self.Value=1
	elseif id<PLAYER_AMMO_TYPES then self.Value=20 end
end