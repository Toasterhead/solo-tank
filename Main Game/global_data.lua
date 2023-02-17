--Global Data

mouseData={x=0,y=0,l=false,m=false,r=false,scrollX=0,scrollY=0}
mousePrev={l=false,m=false,r=false}
cam={x=0,y=0,z=0,mode=0}
reticle={radii={3,5,7},color=7,colorDeny=12,active=true,inRange=false}
tRed={t=0,init=180}
tVital={t=0,subject=nil}
tSoundA={t=0,priority=0,channel=2}
tSoundB={t=0,priority=0,channel=3}
message={t=0,text="",active=true}

X=1
Y=2
Z=3

WHITE=7

BLANK=79

SC_W=240
SC_H=136
SC_HUD=200

MAP_W=8*SC_W
MAP_H=8*SC_H

CAM_CENTER=0
CAM_LOCK_H=1
CAM_LOCK_V=2

MRG_DRAW=24
MRG_UPDATE=SC_W//2

SCRP_DISMOUNT=0
SCRP_DEAD_A=1
SCRP_DEAD_B=2
SCRP_DOCK=3

TRN_WALL=0
TRN_WATER=1
TRN_MUD=2
TRN_MUD_EDGE=3
BLD_FACTORY=4
BLD_COM_TOWER=5
BLD_GENERATOR=6
BLD_GATE=7

CR_HIT=1
CR_BOUND=2

PCK_SHELLS=1
PCK_LONG_RANGE=2
PCK_ROCKET=3
PCK_HOMING_MISSILE=4
PCK_MEGA_MISSILE=5
PCK_REPAIR=6
PCK_FULL_REPAIR=7
PCK_SHIELD=8
PCK_EXTRA_LIFE=9
PCK_KEY=10
PCK_RADAR=11

AM_IMG=1
AM_PROJECTILE=2
AM_IMPACT=3
AM_RANGE=4
AM_SPEED=5
AM_DAMAGE=6
AM_EXPLODES=7
AM_HOMES=8
AM_TXT_1=9
AM_TXT_2=10

AMMO_TYPE=
{
	{0,1,1,60,4,15,false,false,"Backup","Shells"},
	{1,2,1,75,5,25,false,false,"Stand.","Shells"},
	{2,2,1,125,6,20,false,false,"Long","Range"},
	{3,3,2,100,3,120,true,false,"Stand.","Rocket"},
	{4,3,2,100,3,100,true,true,"Homing","Missile"},
	{5,3,2,85,2,150,true,false,"Mega","Missile"}
}
PLAYER_AMMO_TYPES=6

ROT_N=0.75
ROT_NE=0.875
ROT_E=0
ROT_SE=0.125
ROT_S=0.25
ROT_SW=0.375
ROT_W=0.5
ROT_NW=0.625

DIR_N=0
DIR_NE=1
DIR_E=2
DIR_SE=3
DIR_S=4
DIR_SW=5
DIR_W=6
DIR_NW=7

ROTATION=2*math.pi

NUM_LAYERS=5
LAYER_CUTOFF=3
SCREEN_MARGIN=32

MAX_VITALITY=100
MAX_ROUNDS=256
MAX_OTHER=16

scripted=-1
tileSet={}
gameSet={}
overSet={}
avatar=nil
lives=5
ammoIndex=2
ammo={MAX_ROUNDS,10,5,3,2,4}
intactComTower=true
intactFactory=true
intactGenerator=true
intactGate=true
keycard=false
radarOn=false
soundOn=true
musicOn=true
paused=false
t=0