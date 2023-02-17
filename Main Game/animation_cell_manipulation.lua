--Animation Cell Manipulation

function rotated_from(cell,quarters) --Incomplete. Not used.
	rotated={}
	local rw=cell[1].x
	local rh=cell[1].y
	for i=2,#cell do
		if cell[i].x>rw then rw=cell[i].x end
		if cell[i].y<rh then rh=cell[i].y end
	end
	local midX=rw/2
	local midY=rh/2
	for i=1,#cell do
		quarters=(cell[i].rotate+quarters)%4
		local imgX,imgY=0
		local x=cell[i].x-midX
		local y=cell[i].y-midY
		if x>=0 and y>=0 then
			if quarters==1 then x=-y y=x
			elseif quarters==2 then x=-x y=-y
			elseif quarters==3 then x=y y=-x
			end
		elseif x<0 and y>=0 then
			if quarters==1 then x=y y=x
			elseif quarters==2 then x=-x y=-y
			elseif quarters==3 then x=-y y=-x
			end
		end
		rotated[i]=ImageInfo:new(cell[i].id,midX+x,midY+y,cell[i].z,cell[i].colorKey,cell[i].scale,cell[i].flip,quarters,cell[i].w,cell[i].h)
	end
	return rotated
end

function symmetrical_cells_from(imgInfo,rotated,animation,animationStyle)
	rotated=rotated or false
	animation=animation or {imgInfo.id}
	animationStyle=animationStyle or 0
	local IMAGES_PER_CELL=4
	local cells={}
	local cellsCounter=1
	local x=imgInfo.x
	local y=imgInfo.y
	local w=imgInfo.w*imgInfo.scale*8
	local h=imgInfo.h*imgInfo.scale*8
	local flips={{0,1,2,3},{1,0,3,2},{3,2,1,0},{2,3,0,1}}
	local xSet={x,x+w,x,x+w}
	local ySet={y,y,y+h,y+h}
	local nQuarters=4
	local messageCounter=0--
	if rotated==false then nQuarters=1 end
	local animationDirections={{1,1,1,1},{1,1,1,1},{1,1,1,1},{1,1,1,1}}
	if animationStyle==1 then
		animationDirections={{1,1,-1,-1},{-1,1,-1,1},{-1,-1,1,1},{1,-1,1,-1}}
	end
	for i=1,nQuarters do
		for j=1,#animation do
			local images={}
			for k=1,IMAGES_PER_CELL do
				local id
				if animationDirections[i][k]>0 then 
					id=animation[j]
				else id=animation[#animation-(j-1)] end
				images[k]=ImageInfo:new(id,xSet[k],ySet[k],imgInfo.z,imgInfo.colorKey,imgInfo.scale,flips[i][k],i-1,imgInfo.w,imgInfo.h)
			end
			cells[cellsCounter]=images
			cellsCounter=cellsCounter+1
		end
	end
	return cells
end

function rotated_set_from(imgInfo,asCells)
	asCells=asCells or true
	local N_QUARTERS=4
	local images={}
	for i=0,N_QUARTERS-1 do
		local imgInfo=ImageInfo:new(imgInfo.id,imgInfo.x,imgInfo.y,imgInfo.z,imgInfo.colorKey,imgInfo.scale,imgInfo.flip,(imgInfo.rotate+i)%4,imgInfo.w,imgInfo.h)		
		if asCells==true then
			images[i+1]={imgInfo}
		else images[i+1]=imgInfo end
	end
	return images
end

function generate_cells(baseId,z,args,colorKey,scale,w,h)
	local RELATIVE_ID=1
	local X=2
	local Y=3
	local FLIP=4
	local ROTATE=5
	local COLOR_KEY=6
	local colorKey=colorKey or -1
	local scale=scale or 1
	local w=w or 1
	local h=h or 1
	local cells={}
	local cellsCounter=1
	for i=1,#args do
		local images={}
		for j=1,#args[i] do
			args[i][j][COLOR_KEY]=args[i][j][COLOR_KEY] or colorKey
			images[j]=ImageInfo:new(baseId+args[i][j][RELATIVE_ID],args[i][j][X],args[i][j][Y],z,args[i][j][COLOR_KEY],scale,args[i][j][FLIP],args[i][j][ROTATE],w,h)
		end
		cells[cellsCounter]=images
		cellsCounter=cellsCounter+1
	end
	return cells
end

function format_copied_from(img,idArr,absoluteId)
	local cells={}
	local id=absoluteId or 0
	for i=1,#idArr do
		for j=1,#idArr[i] do
			local images={}
			images[j]=ImageInfo:new(id+idArr[i][j],img.x,img.y,img.z,img.colorKey,img.scale,img.flip,img.rotate,img.w,img.h)
			cells[i]=images
		end
	end
	return cells
end

function basic_tiles_from(id,idArr)
	local img=ImageInfo:new(0)
	local idNew={}
	for i=1,#idArr do idNew[i]={id+idArr[i]} end
	return format_copied_from(img,idNew)
end