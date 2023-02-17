--Camera Functions

function move_camera(subject)
	local HALF_W=(SC_W-(SC_W-SC_HUD))/2
	local HALF_H=SC_H/2
	local mapX=(cam.x+HALF_W)//SC_W
	local mapY=(cam.y+HALF_H)//SC_H
	local targetX=mapX*SC_W
	local targetY=mapY*SC_H
	local hCL=hCamLocks
	local vCL=vCamLocks
	local m=subject.Travel:magnitude()
	cam.mode=CAM_CENTER
	for i=1,#hCL do
		if mapX==hCL[i][X] and mapY==hCL[i][Y] then
			cam.mode=CAM_LOCK_H
			break
		end
	end
	if cam.mode~=CAM_LOCK_H then
		for i=1,#vCL do
			if mapX==vCL[i][X] and mapY==vCL[i][Y] and cam.x+HALF_W<targetX+SC_HUD then
				cam.mode=CAM_LOCK_V
				break
			end
		end
	end
	if cam.mode==CAM_LOCK_H then
		if cam.y>targetY then cam.y=cam.y-m end
		if cam.y<targetY then cam.y=cam.y+m end
		snap_cam_v(targetY,m)
		check_cam_h(HALF_W,m,subject)
	elseif cam.mode==CAM_LOCK_V then
		if cam.x>targetX then cam.x=cam.x-m end
		if cam.x<targetX then cam.x=cam.x+m end
		snap_cam_h(targetX,m)
		check_cam_v(HALF_H,m,subject)
	else
		check_cam_h(HALF_W,m,subject)
		check_cam_v(HALF_H,m,subject)
	end
	if cam.x<0 then cam.x=0 
	elseif cam.x>MAP_W-SC_W then cam.x=MAP_W-SC_W end
	if cam.y<0 then cam.y=0 
	elseif cam.y>MAP_H-SC_H then cam.y=MAP_H-SC_H end
end

function check_cam_h(hW,m,sbj)
	if cam.x+hW>sbj:center().x then cam.x=cam.x-m end
	if cam.x+hW<sbj:center().x then cam.x=cam.x+m end
	snap_cam_h(sbj:center().x-hW,sbj.TopSpeed)
end

function check_cam_v(hH,m,sbj)
	if cam.y+hH>sbj:center().y then cam.y=cam.y-m end
	if cam.y+hH<sbj:center().y then cam.y=cam.y+m end
	snap_cam_v(sbj:center().y-hH,sbj.TopSpeed)
end

function snap_cam_h(target,threshold)
	if cam.x<=target+threshold and cam.x>=target-threshold then cam.x=target end
end

function snap_cam_v(target,threshold)
	if cam.y<=target+threshold and cam.y>=target-threshold then cam.y=target end
end

function in_range(item,margin,isTile)
	if isTile and isTile==true then return 8*item.X>=cam.x-margin and 8*item.X<cam.x+SC_HUD+margin and 8*item.Y>=cam.y-margin and 8*item.Y<cam.y+SC_H+margin end
	return item.X>=cam.x-margin and item.X<cam.x+SC_HUD+margin and item.Y>=cam.y-margin and item.Y<cam.y+SC_H+margin
end