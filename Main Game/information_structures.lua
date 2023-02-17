--Information Structures

ImageInfo={}
ImageInfo.__index=ImageInfo
function ImageInfo:new(id,x,y,z,colorKey,scale,flip,rotate,w,h)
	return setmetatable({id=id,x=x or 0,y=y or 0,z=z or 0,colorKey=colorKey or -1,scale=scale or 1,flip=flip or 0,rotate=rotate or 0,w=w or 1,h=h or 1},self)
end

SoundInfo={}
SoundInfo.__index=SoundInfo
function SoundInfo:new(id,priority,pitch,duration,volume)
	return setmetatable({id=id,priority=priority,pitch=pitch,duration=duration,volume=volume or 15},self)
end