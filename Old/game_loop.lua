tileCells=generate_cells(60,0,{{{0,0,0,0,0}},{{1,0,0,0,0}}})
tileSet[1]=TileObject:new(4,4,tileCells,{},5)

--Game Loop

function TIC()
	check_input()
	update_state()
	draw_screen()
end

function OVR()
	vbank(1)
	cls(0)
	for i=1,#overSet do
		if overSet[i].visible==true then draw_game_object(overSet[i]) end
	end
	if reticle.active==true then draw_reticle() end
	draw_message()
	draw_hud()
end

function check_input()
	check_input_move()
	check_input_mouse()
end

function check_input_move()
	local up,down,left,right=false
	up=btn(0) or key(23)
	down=btn(1) or key(19)
	left=btn(2) or key(1)
	right=btn(3) or key(4)
	if up==true and left==true then avatar:set_motion(ROT_NW)
	elseif up==true and right==true then avatar:set_motion(ROT_NE)
	elseif down==true and left==true then avatar:set_motion(ROT_SW)
	elseif down==true and right==true then avatar:set_motion(ROT_SE)
	elseif up==true then avatar:set_motion(ROT_N)
	elseif down==true then avatar:set_motion(ROT_S)
	elseif left==true then avatar:set_motion(ROT_W)
	elseif right==true then avatar:set_motion(ROT_E)
	else avatar:set_motion() end
end

function check_input_mouse()
	local m=mouseData
	local mP=mousePrev
	m.x,m.y,m.l,m.m,m.r,m.scrollX,m.scrollY=mouse()
	local FIRE_RADIUS=12
	local dist=distance(playerTank:center().x,playerTank:center().y,cam.x+m.x,cam.y+m.y)
	local inBounds=m.x>0 and m.y>0 and m.x<SC_HUD and m.y<SC_H
	local inRange=dist<=AMMO_TYPE[ammoIndex][AM_RANGE]
	local overlaps=dist<FIRE_RADIUS
	mouseData.inRange=inBounds and inRange and not overlaps
	if avatar==playerTank then
		if m.l==true and mP.l==false then
			if mouseData.inRange==true and ammo[ammoIndex]>0 then
				avatar.chamber={cam.x+m.x,cam.y+m.y,AMMO_TYPE[ammoIndex]}
				if ammoIndex~=1 then ammo[ammoIndex]=ammo[ammoIndex]-1 end
				if ammo[ammoIndex]<=0 then cycle_ammo(true) end
			elseif message.t<=30 then set_message("Out of range.",35) end
		elseif m.scrollY>0 then cycle_ammo(true)
		elseif m.scrollY<0 then cycle_ammo()
		elseif key(48) and scripted~=SCPT_DISMOUNT then
			scripted=SCRP_DISMOUNT 
			playerTank.dismounting=true			
		end
	end
	mousePrev={l=m.l,m=m.m,r=m.r}
end

function update_state()
	local mounted=avatar==playerTank
	playerPerson.visible=not mounted
	playerBarrel.visible=mounted
	reticle.active=mounted
	if scripted==SCRP_DISMOUNT then
		playerTank:neutralize()
		if playerTank.dismounting==false then
			scripted=-1
			local a=playerTank:dismount_position()
			if a then				
				avatar=playerPerson
				avatar:reposition(a.x,a.y)
			else set_message("Can't dismount here.") end
		end
	end
	local tS=tileSet
	local gS=gameSet
	local oS=overSet
	if avatar.chamber then
		local a=avatar.chamber
		local impactDelay=4
		local isRocket=a[#a][AM_PROJECTILE]>=ROCKET_CUTOFF
		if isRocket then impactDelay=6 end
		local theImpact=Impact:new(0,0,0,IM_CELLS[a[#a][AM_IMPACT]],{},#IM_CELLS[a[#a][AM_IMPACT]],impactDelay)
		local proj=Projectile:new(0,0,0,PRJ_CELLS[a[#a][AM_PROJECTILE]],{},#PRJ_CELLS[a[#a][AM_PROJECTILE]],1,{0,0},theImpact)
		proj:init(a[X],a[Y],a[#a],playerTank,isRocket)
		add_to(oS,proj)
		avatar.chamber=nil
	end
	for i=#tS,1,-1 do
		tS[i]:update()
		--
	end
	for i=#gS,1,-1 do
		gS[i]:update()
		if gS[i].flagRemoval==true then remove_at(gS,i)
		elseif gS[i].Terminate and gS[i].Terminate==true then remove_at(gS,i) end
	end
	for i=#oS,1,-1 do
		oS[i]:update()
		if oS[i].flagRemoval==true then remove_at(oS,i) 
		elseif oS[i].Terminate and oS[i].Terminate==true then
			if oS[i].TheImpact then
				local ctr=oS[i]:center()
				add_to(oS,oS[i].TheImpact)
				oS[i].TheImpact:reposition(ctr.x,ctr.y)
			end
			remove_at(oS,i)
		end
	end
	move_camera(playerTank)
	t=t+1
end

function draw_screen()
	vbank(0)
	cls(0)
	clip(0,0,SC_HUD,SC_H)
	cls(4)
	draw_map()
	for i=1,#gameSet do 
		if gameSet[i].visible==true and in_range(gameSet[i],MRG_DRAW) then draw_game_object(gameSet[i]) end
	end
	if tRed.t~=-1 then
		tRed.t=tRed.t-1
		if tRed.t<=0 then tRed.t=-1 end
		draw_red_effect(tRed.t/tRed.init)
	end
end

function draw_map()
	for i=1,#tileSet do draw_tile(tileSet[i]) end
	map(cam.x//8,cam.y//8,(SC_HUD//8)+1,(SC_H//8)+1,-(cam.x%8),-(cam.y%8))
end

function draw_game_object(gObj)
	local prior=gObj.cellY*gObj.CellsPerRow
	local cell=gObj.Cells[prior+gObj.cellX+1]
	for j=1,#cell do
		spr(cell[j].id,(gObj.X+cell[j].x)-cam.x,(gObj.Y+cell[j].y)-cam.y,cell[j].colorKey,cell[j].scale,cell[j].flip,cell[j].rotate,cell[j].w,cell[j].h)
	end
	if gObj.peripheral and gObj.peripheral.visible==true then draw_game_object(gObj.peripheral) end
end

function draw_tile(tile)
	local cell=tile.Cells[tile.cellX+1]
	for j=1,#cell do mset(tile.X+cell[j].x,tile.Y+cell[j].y,cell[j].id) end
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

function draw_reticle()
	local mX,mY=mouse()
	local color=reticle.color
	if mouseData.inRange==false then color=reticle.colorDeny end
	line(mX,mY-reticle.radii[1],mX,mY-reticle.radii[3],color)
	line(mX+reticle.radii[1],mY,mX+reticle.radii[3],mY,color)
	line(mX,mY+reticle.radii[1],mX,mY+reticle.radii[3],color)
	line(mX-reticle.radii[1],mY,mX-reticle.radii[3],mY,color)
	circb(mX,mY,reticle.radii[2],color)
end

function draw_message()
	local msg=message
	if msg.t>0 then
		msg.t=msg.t-1
		print(msg.text,8,SC_H-8,WHITE)
	end
end

function draw_hud()
	local HUD_W=SC_W-SC_HUD
	local RADAR_W=HUD_W-5
	local RADAR_H=(SC_H/SC_W)*RADAR_W
	local rounds=ammo[ammoIndex]
	local margin=MRG_UPDATE
	if rounds==MAX_ROUNDS then rounds="---" end
	clip(SC_HUD,0,HUD_W,SC_H)
	cls(0)
	rectb(SC_HUD,0,HUD_W,SC_H,14)
	spr(93,SC_HUD+8,0)
	print(lives,SC_HUD+24,2,WHITE)
	spr(94,SC_HUD+8,16)
	print(playerTank.Shield,SC_HUD+24,18,WHITE)
	spr(95,SC_HUD,32)
	rectb(SC_HUD+8,32,32,8,WHITE)
	rect(SC_HUD+10,34,(playerTank.Vitality/MAX_VITALITY)*28,4,WHITE)
	spr(AMMO_TYPE[ammoIndex][AM_IMG],SC_HUD+8,48)
	print(rounds,SC_HUD+24,48,WHITE)
	print(AMMO_TYPE[ammoIndex][AM_TXT_1],SC_HUD+1,64,WHITE)
	print(AMMO_TYPE[ammoIndex][AM_TXT_2],SC_HUD+1,72,WHITE)
	if radarOn==true then
		rectb(SC_HUD+2,SC_H-RADAR_H-1,RADAR_W,RADAR_H,5)
		for i=SC_H-RADAR_H+1,SC_H-3,2 do pix(SC_HUD+2+(RADAR_W/2),i,4) end
		for i=SC_HUD+4,SC_HUD+RADAR_W,2 do pix(i,SC_H-(RADAR_H/2)-2,4) end
		for i=1,#gameSet do
			local gObj=gameSet[i]
			if gObj.move and gObj~=playerTank and gObj~=playerPerson and in_range(gObj,margin) then
				local edgeLeft=cam.x-margin
				local edgeTop=cam.y-margin
				local spanH=(cam.x+SC_HUD+margin)-edgeLeft
				local spanV=(cam.y+SC_H+margin)-edgeTop
				local radarPosX=((gObj:center().x-edgeLeft)/spanH)*RADAR_W
				local radarPosY=((gObj:center().y-edgeTop)/spanV)*RADAR_H
				pix(SC_HUD+radarPosX+2,SC_H-RADAR_H+radarPosY-1,6)
			end
		end
	end
end

function compare_z(a,b) return a.z<b.z end --Might not be used.