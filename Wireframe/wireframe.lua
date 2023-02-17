-- title:   Wireframe Test
-- author:  Lenny Young
-- desc:    Establishes a very basic engine for displaying perspective-adjusted 3D wireframe models.
-- site:    website link
-- license: MIT License (change this to your license of choice)
-- version: 0.1
-- script:  lua

ORIGIN_X=240/2
ORIGIN_Y=136/2
RATE=0.998
REVOLUTION=360
COLOR=5

nodes={}
t=0

--Node Class

Node={}
Node.__index=Node
function Node:new(x,y,z,connections) return setmetatable({X=x or 0,Y=y or 0,Z=z or 0,Connections=connections or {}},self) end

Node.Render={x=0,y=0,z=0}

function Node:reset_render() self.Render={x=self.X,y=self.Y,z=self.Z} end

function Node:rotate(theta) 
	self.Render=
	{
		x=( self.Render.x*math.cos(theta))+(self.Render.z*math.sin(theta)),
		y=  self.Render.y,
		z=(-self.Render.z*math.sin(theta))+(self.Render.z*math.cos(theta))
	}
end

function Node:perspective() self.Render={x=self.Render.x*math.pow(RATE,self.Render.z),y=self.Render.y*math.pow(RATE,self.Render.z),z=self.Render.z} end

--Game Loop

function update_model()
	for i=1,#nodes do
		nodes[i]:reset_render()
		nodes[i]:rotate((t/REVOLUTION)*(2*math.pi))
		nodes[i]:perspective()
	end
end

function draw_model()
	for i=1,#nodes do
		for j=1,#nodes[i].Connections do
			line(nodes[i].Render.x+ORIGIN_X,nodes[i].Render.y+ORIGIN_Y,nodes[i].Connections[j].Render.x+ORIGIN_X,nodes[i].Connections[j].Render.y+ORIGIN_Y,COLOR)
		end
	end
end

function BOOT()
	nodes[1]=Node:new(-30,-30,-30,{})
	nodes[2]=Node:new(-30,30,-30,{nodes[1]})
	nodes[3]=Node:new(30,30,-30,{nodes[2]})
	nodes[4]=Node:new(30,-30,-30,{nodes[3]})
	nodes[5]=Node:new(-30,-30,-30,{nodes[4]})
	nodes[6]=Node:new(-30,30,30,{nodes[2]})
	nodes[7]=Node:new(30,30,30,{nodes[3],nodes[6]})
	nodes[8]=Node:new(30,-30,30,{nodes[4],nodes[7]})
	nodes[9]=Node:new(-30,-30,30,{nodes[5],nodes[6],nodes[8]})

end

function TIC()
	update_model()
	cls(0)
	draw_model()
	t=t+1
end