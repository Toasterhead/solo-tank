--Actor Class

Actor={}
Actor.__index=Actor
setmetatable(Actor,Mover)

Actor.Vitality=MAX_VITALITY Actor.Shield=1

function Actor:adjust_vitality(amount)
	self.Vitality=self.Vitality+amount
	if self.Vitality>MAX_VITALITY then
		self.Vitality=MAX_VITALITY
	elseif self.Vitality<0 then
		self.Vitality=0
		self.flagRemoval=true
	end
end

function Actor:behave() end

function Actor:update()
	self:behave()
	self:move()
	self:animate()
	if self.peripheral then actor.peripheral:update() end
end