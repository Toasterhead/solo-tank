--Global Functions

function add_to(theTable,item) theTable[#theTable+1]=item end

function remove_at(theTable,i)
	local tbl=theTable
	local a=tbl[i]
	if a.Under then
		local under=a.Under
		if under==-1 then under=BLANK end
		for j=1,#a.Cells[1] do mset(a.X+a.Cells[1][j].x,a.Y+a.Cells[1][j].y,under) end
	end
	for j=i,#tbl-1 do tbl[j]=tbl[j+1] end
	tbl[#tbl]=nil
end

function distance(x,y,a,b) return math.sqrt((a-x)^2+(b-y)^2) end

function coterminal(theta)
 	if theta<0 then while theta+ROTATION<ROTATION do theta=theta+ROTATION end
 	else while theta-ROTATION>=0 do theta=theta-ROTATION end end
 	return theta
end

function intersect_bound(tile,actor)
	if tile:has_col_reg() and tile:absolute_col_reg(1):intersects(actor:absolute_col_reg(CR_BOUND)) then return true end
	return false
end

function absolute_mouse() return cam.x+mouseData.x,cam.y+mouseData.y end

function set_red_effect(t) tRed.t=t tRed.init=t end

function set_message(text,t) message.t=t or 180 message.text=text end

function set_message(text,t) message.t=t or 180 message.text=text end

function play_sound(sound,isPrimary,modulation,shiftVolume)
	local s=sound
	local ts=tSoundA
	local m=modulation or 0
	local sv=shiftVolume or 0
	if isPrimary==false and ts.t>0 then ts=tSoundB end
	if ts.t<=0 or (ts.t>0 and s.priority>=ts.priority) then
		ts.t=s.duration
		ts.priority=s.priority
		sfx(s.id,s.pitch+m,s.duration,ts.channel,s.volume+sv)
	end
end

function cycle_ammo(forward)
	local MAX=PLAYER_AMMO_TYPES
	local empty=true
	for i=2,MAX do
		if ammo[i]>0 then empty=false break end
	end
	if empty==false then
		if forward and forward==true then
			ammoIndex=(ammoIndex)%MAX+1
			while ammo[ammoIndex]==MAX_ROUNDS or ammo[ammoIndex]<=0 do ammoIndex=(ammoIndex)%MAX+1 end
		else
			ammoIndex=ammoIndex-1
			if ammoIndex<=1 then ammoIndex=MAX end
			while ammo[ammoIndex]==MAX_ROUNDS or ammo[ammoIndex]<=0 do
				ammoIndex=ammoIndex-1
				if ammoIndex<=1 then ammoIndex=MAX end
			end
		end
	else ammoIndex=1 end
end

function adjust_ammo(amount,i) ammo[i]=ammo[i]+amount end

function adjust_lives(increase)
	if increase and increase==true then lives=lives+1
	else lives=lives-1 end
end

function in_set(value,a)
	for i=1,#a do
		if value==a[i] then return true end
	end
	return false
end

function load_tile_set()
	local W=240
	local H=136
	local tS={}
	local cr={CollisionRegion:new(0,0,8,8)}
	for i=0,W-1 do
		for j=0,H-1 do
			local id=mget(i,j)
			local gc=generate_cells(id,0,{{{0,0,0,0,0}}})
			if id>0 and id<=PCK_RADAR then
				tS[#tS+1]=PickUp:new(i,j,gc,cr)
				tS[#tS]:init(id)
			elseif id==22 or id==38 then
				tS[#tS+1]=Door:new(i,j,basic_tiles_from(id,{3,2,1,0}),cr)
			elseif id==28 or id==30 then
				tS[#tS+1]=Terrain:new(i,j,gc,cr)
				tS[#tS]:init(TRN_WALL)
			elseif in_set(id,{58,60,62}) then
				tS[#tS+1]=TileObject:new(i,j,basic_tiles_from(id,{0,1}),cr)
			elseif in_set(id,{59,61,63}) then
				tS[#tS+1]=TileObject:new(i,j,basic_tiles_from(id,{0,-1}),cr)
			elseif id>=96 and id<=103 then
				tS[#tS+1]=TileObject:new(i,j,basic_tiles_from(id,{0,16}),cr,60)
			elseif id==104 or id==105 then
				tS[#tS+1]=Terrain:new(i,j,gc,cr)
				tS[#tS]:init(TRN_MUD)
			elseif id>=120 and id<=127 then
				tS[#tS+1]=Terrain:new(i,j,gc,cr)
				tS[#tS]:init(TRN_MUD_EDGE)
			elseif id==128 then
				tS[#tS+1]=Terrain:new(i,j,genCells,{CollisionRegion:new(0,0,32,16)},5)
				tS[#tS]:init(BLD_GENERATOR,100)
			elseif id==134 then
				tS[#tS+1]=Terrain:new(i,j,twrCells,{CollisionRegion:new(0,0,16,16)},5)
				tS[#tS]:init(BLD_COM_TOWER,75)
			end
		end
	end
	return tS
end