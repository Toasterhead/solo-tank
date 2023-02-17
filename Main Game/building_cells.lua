--Ballistic Cells

ballisticImg=ImageInfo:new(0,-4,-4,0,0)
rcktOrth=rotated_set_from(ImageInfo:new(284,-4,-4,0,0))
rcktDiag=rotated_set_from(ImageInfo:new(285,-4,-4,0,0))
explCells={}
for i=1,8 do
	local a=(i-1)%4
	if i>4 then a=a+16 end
	explCells[i]={{a,-8,-8,0,0},{a,0,-8,1,0},{a,-8,0,2,0},{a,0,0,3,0}}
end

PRJ_CELLS=
{
	format_copied_from(ballisticImg,{{1},{2}},260),
	format_copied_from(ballisticImg,{{1},{2}},276),
	{rcktOrth[1],rcktDiag[1],rcktOrth[2],rcktDiag[2],rcktOrth[3],rcktDiag[3],rcktOrth[4],rcktDiag[4]}
}
IM_CELLS=
{
	format_copied_from(ballisticImg,{{0},{1},{20},{21},{22},{23}},260),
	generate_cells(315,2,explCells,0)
}
ROCKET_CUTOFF=3

--Building Cells

twrCells={}
for i=1,6 do
	local a={0,2,4,6,4,2}
	twrCells[i]={{a[i],0,0,0,0},{a[i]+1,1,0,0},{16,0,1,0,0},{17,1,1,0,0}}
end
twrCells=generate_cells(134,0,twrCells,0)

genCells={}
for i=1,6 do
	local a={4,20,5,21,5,20}
	genCells[i]={{0,0,0,0,0},{1,1,0,0,0},{a[i],2,0,0,0},{3-math.floor((i-1)/3),3,0,0,0},{16,0,1,0,0},{17,1,1,0,0},{18,2,1,0,0},{19,3,1,0,0}}
end
genCells=generate_cells(128,0,genCells,0)