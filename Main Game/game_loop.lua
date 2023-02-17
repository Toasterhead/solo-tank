--Game Loop

function BOOT()
	avatar=playerTank
	gameSet[1]=playerTank
	gameSet[2]=playerPerson
	tileSet=load_tile_set()
	--music(0)
end

function TIC()
	if paused==false then
		check_input()
		update_state()
		draw_screen()
	end
end

function OVR()
	vbank(1)
	cls(0)
	if paused==true then
		process_pause()
	else
		draw_overlay()
		draw_hud()
	end
end

function check_input()
	check_input_move()
	check_input_mouse()
	check_input_pause()
end

function check_input_pause()
	if key(16) then
		paused=true
		music()
		play_sound(sfxPause,true)
	end
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
			play_sound(sfxDismount,true)
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
	for i=#tS,1,-1 do
		if not in_range(tS[i],MRG_UPDATE,true) then goto continueTS end
		local tSI=tS[i].__index
		tS[i]:update()
		if tSI==PickUp and not mounted then
			if intersect_bound(tS[i],avatar) then
				if tS[i].Id==PCK_SHELLS then
					adjust_ammo(20,PCK_SHELLS+1)
					set_message("Standard shells obtained.")
				elseif tS[i].Id==PCK_LONG_RANGE then
					adjust_ammo(20,PCK_LONG_RANGE+1)
					set_message("Long-range shells obtained.")
				elseif tS[i].Id==PCK_ROCKET then
					adjust_ammo(5,PCK_ROCKET+1)
					set_message("Rockets obtained.")
				elseif tS[i].Id==PCK_MEGA_MISSILE then
					adjust_ammo(5,PCK_MEGA_MISSILE+1)
					set_message("Mega missiles found. Sweet.")
				elseif tS[i].Id==PCK_HOMING_MISSILE then
					adjust_ammo(5,PCK_HOMING_MISSILE+1)
					set_message("Homing missiles found!")
				elseif tS[i].Id==PCK_REPAIR then
					playerTank:adjust_vitality(tS[i].Value)
					set_message("Tank partially repaired.")
				elseif tS[i].Id==PCK_FULL_REPAIR then
					playerTank:adjust_vitality(tS[i].Value)
					set_message("Tank fully repaired.")
				elseif tS[i].Id==PCK_SHIELD then
					playerTank:increase_shield()
					set_message("Shield increased.")
				elseif tS[i].Id==PCK_EXTRA_LIFE then
					adjust_lives(true)
					set_message("Found an extra life!")
				elseif tS[i].Id==PCK_KEY then
					keycard=true
					set_message("Key-card acquired.")
				elseif tS[i].Id==PCK_RADAR then
					radarOn=true
					set_message("Radar acquired!")
				end
				play_sound(sfxPickUp,true)
				tS[i].flagRemoval=true
			end
		elseif tSI==Terrain or tSI==Door then
			if mounted==true then
				if tS[i].Type==TRN_MUD_EDGE then
					if intersect_bound(tS[i],avatar) then
						avatar.inMud=true
						if avatar.Travel:magnitude()>0 then play_sound(sfxSplash,false,math.random(-5,5)) end
					end
				end
			else
				if tSI==Door then tS[i].check_access(avatar) end
			end
		end
		if tS[i].flagRemoval==true then remove_at(tS,i) end
		::continueTS::
	end
	for i=#gS,1,-1 do
		if not in_range(gS[i],MRG_UPDATE) then goto continueGS end
		local gSI=gS[i].__index
		gS[i]:update()
		if gS[i].chamber then
			local c=gS[i].chamber
			local impactDelay=4
			local modulate=0
			local isRocket=c[#c][AM_PROJECTILE]>=ROCKET_CUTOFF
			if isRocket then
				impactDelay=6
				modulate=-5
			end
			local theImpact=Impact:new(0,0,0,IM_CELLS[c[#c][AM_IMPACT]],{},#IM_CELLS[c[#c][AM_IMPACT]],impactDelay)
			local proj=Projectile:new(0,0,0,PRJ_CELLS[c[#c][AM_PROJECTILE]],{},#PRJ_CELLS[c[#c][AM_PROJECTILE]],1,{0,0},theImpact)
			proj:init(c[X],c[Y],c[#c],gS[i],isRocket)
			add_to(gS,proj)
			play_sound(sfxFire,true,modulate)
			gS[i].chamber=nil
		end
		if gS[i].flagRemoval==true then remove_at(gS,i)
		elseif gS[i].Terminate and gS[i].Terminate==true then
			if gS[i].TheImpact then
				local hit=process_hits(gS[i])
				local impact=gS[i].TheImpact
				add_to(gS,impact)
				add_to(oS,impact)
				gS[i].TheImpact:reposition(gS[i]:center().x,gS[i]:center().y)
				if gS[i].Explodes==true then
					local mod=0
					if math.random(0,1)==0 then mod=3 end
					play_sound(sfxExplosion,true,mod)
				end
			end
			remove_at(gS,i)
		elseif gSI==Projectile or gSI==Impact then
			if gSI==Projectile then
				--Check for collision with player.
			end
			add_to(oS,gS[i])
		end
		::continueGS::
	end
	if not mounted and avatar:absolute_col_reg(2):intersects(playerTank:absolute_col_reg(1)) then
		avatar.visible=false
		avatar=playerTank
	end
	move_camera(playerTank)
	tSoundA.t=tSoundA.t-1
	tSoundB.t=tSoundB.t-1
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
	if tRed.t>0 then
		tRed.t=tRed.t-1
		draw_red_effect(tRed.t/tRed.init)
	end
end

function draw_map()
	for i=1,#tileSet do draw_tile(tileSet[i]) end
	map(cam.x//8,cam.y//8,(SC_HUD//8)+1,(SC_H//8)+1,-(cam.x%8),-(cam.y%8))
end

function draw_game_object(gObj)
	if gObj.Splash then draw_splash(gObj) end
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

function draw_splash(gObj)
	local spl=gObj.Splash
	local ctr=gObj:center()
	spr(spl.id,(ctr.x+spl.x)-cam.x,(ctr.y+spl.y)-cam.y,0,1,spl.flip)
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

function draw_overlay()
	for i=1,#overSet do
		if overSet[i].visible==true then draw_game_object(overSet[i]) end
	end
	overSet={}
	if message.active==true then draw_vitality() end
	if reticle.active==true then draw_reticle() end
	if message.active==true then draw_message() end
end

function draw_vitality()
	if tVital.t>0 and tVital.subject then
		local sbj=tVital.subject
		if sbj.Vitality<=0 then
			tVital.t=0
		else
			local GREEN=6
			local x=sbj.X
			local y=sbj.Y
			if sbj.__index==Terrain then x=8*x y=8*y end
			tVital.t=tVital.t-1
			line(x-cam.x,y-4-cam.y,x+((sbj.Vitality/MAX_VITALITY)*(2*(sbj:center().x-x)))-cam.x,y-4-cam.y,GREEN)
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
	local rounds=ammo[ammoIndex]
	if rounds==MAX_ROUNDS then rounds="---" end
	clip(SC_HUD,0,HUD_W,SC_H)
	cls(0)
	rectb(SC_HUD,0,HUD_W,SC_H,14)
	spr(252,SC_HUD+8,0)
	print(lives,SC_HUD+24,2,WHITE)
	spr(253,SC_HUD+8,16)
	print(playerTank.Shield,SC_HUD+24,18,WHITE)
	spr(254,SC_HUD,32)
	rectb(SC_HUD+8,32,32,8,WHITE)
	rect(SC_HUD+10,34,(playerTank.Vitality/MAX_VITALITY)*28,4,WHITE)
	spr(AMMO_TYPE[ammoIndex][AM_IMG],SC_HUD+8,48)
	print(rounds,SC_HUD+24,48,WHITE)
	print(AMMO_TYPE[ammoIndex][AM_TXT_1],SC_HUD+1,64,WHITE)
	print(AMMO_TYPE[ammoIndex][AM_TXT_2],SC_HUD+1,72,WHITE)
	if radarOn==true then
		local RADAR_W=HUD_W-5
		local RADAR_H=(SC_H/SC_W)*RADAR_W
		rectb(SC_HUD+2,SC_H-RADAR_H-1,RADAR_W,RADAR_H,5)
		for i=SC_H-RADAR_H+1,SC_H-3,2 do pix(SC_HUD+2+(RADAR_W/2),i,4) end
		for i=SC_HUD+4,SC_HUD+RADAR_W,2 do pix(i,SC_H-(RADAR_H/2)-2,4) end
		draw_radar_items(tileSet,RADAR_W,RADAR_H,true)
		draw_radar_items(gameSet,RADAR_W,RADAR_H)
	end
end

function draw_radar_items(s,rW,rH,areTiles)
	for i=1,#s do
		if ((s[i].Vitality and areTiles==false) or s[i].__index==PickUp) and s[i]~=playerTank and s[i]~=playerPerson and in_range(s[i],MRG_UPDATE,areTiles) then
			local color=6
			if s[i].Vitality then color=12 end
			local edgeLeft=cam.x-MRG_UPDATE
			local edgeTop=cam.y-MRG_UPDATE
			local spanH=(cam.x+SC_HUD+MRG_UPDATE)-edgeLeft
			local spanV=(cam.y+SC_H+MRG_UPDATE)-edgeTop
			local a=1
			if areTiles then a=8 end
			local ctr={x=s[i].X,y=s[i].Y}
			if s[i].center then ctr=s[i]:center() end
			if areTiles and areTiles==true then a=8 end
			local radarPosX=((ctr.x-edgeLeft)/spanH)*rW
			local radarPosY=((ctr.y-edgeTop)/spanV)*rH
			pix(SC_HUD+radarPosX+2,SC_H-rH+radarPosY-1,color)
		end
	end
end

function process_pause()
	if key(15) then
		paused=false
		music(0)
	elseif key(17) then exit() end
	cls(0)
	local c=WHITE
	print("P A U S E D",76,34,c)
	print("Esc",60,50,c)
	print("Q",60,58,c)
	print(": Return to Game",100,50,c)
	print(": Quit",100,58,c)
end

function process_hits(proj)
	local gS=gameSet
	local tS=tileSet
	local ctr=proj:center()
	local detected=false
	local r=4
	if proj.Explodes==true then r=10 end
	for i=1,#gS do
		if gS[i].Vitality and in_range(gS[i],MRG_UPDATE)==true then
			if gS[i]==avatar and proj.Explodes==false then r=2 end
			colReg=CollisionRegion:new(ctr.x,ctr.y,r)
			if gS[i]:absolute_col_reg(CR_HIT,true):intersects(colReg) then
				impose_damage(gS[i],proj)
				detected=true
			end
		end
	end
	for i=1,#tS do
		if tS[i].Vitality and in_range(tS[i],MRG_UPDATE,true)==true then
			colReg=CollisionRegion:new(ctr.x,ctr.y,r)
			if tS[i]:absolute_col_reg(CR_HIT,true):intersects(colReg) then
				impose_damage(tS[i],proj)
				detected=true
			end
		end
	end
	return detected
end

function impose_damage(sbj,proj)
	local sCtr=sbj:center()
	local pCtr=proj:center()
	local shield=1
	if sbj.Shield then shield=sbj.Shield end
	local damage=proj.Damage-((shield-1)*(proj.Damage/MAX_OTHER))
	if proj.Explodes==true then
		damage=math.pow(0.95,distance(sCtr.x,sCtr.y,pCtr.x,pCtr.y))*damage
		if sbj.push then sbj.push=Vector:new(sCtr.x-pCtr.x,sCtr.x-pCtr.y):normalize():scale(0.1*damage) end
	else
		if sbj.push then sbj.push=proj.Travel:normalize():scale(-0.1*damage) end
	end
	sbj:adjust_vitality(-damage)
	if sbj==avatar then
		if avatar==playerTank then
			tRed.t=2*damage
			tRed.init=tRed.t
			play_sound(sfxStruck,true,0,-5+((damage/MAX_VITALITY)*5))
		else
			--
		end
	else
		tVital.t=120
		tVital.subject=sbj
		play_sound(sfxHit,true,-math.floor((sbj.Vitality/MAX_VITALITY)*7))
	end		
end

function compare_z(a,b) return a.z<b.z end --Might not be used.