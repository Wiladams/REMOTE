package.path = "../?.lua;"..package.path;

local ffi = require("ffi")
local NetInteractor = require("tflremote.sharer")


local colors = require("colors")
local keycodes = require("tflremote.jskeycodes")
local bgi = require("bgi")
local random = math.random


local width = 640;
local height = 480;



local UP =18432
local DOWN =20480
local RIGHT =19712
local LEFT =19200
local ENTER =7181
local W =4471
local S =8051
local A =7777
local D =8292

local HIT =1
local NOTYET =0
local RED =1
local BLUE =2
local YES =1
local NO =0
local GAMEOVER =-1

local Player = {}
local Player_mt = {
	__index = Player
}

function Player.init(self, id, color)
	local obj = {
		id = id;
		color = color;
		x = ffi.new("int[175]");
		y = ffi.new("int[175]");
		dirx = ffi.new("int[175]");
		diry = ffi.new("int[175]");

		length = 1;
		chance = 5;
		score=0;
	}
	setmetatable(obj, Player_mt);

	return obj;
end

function Player.new(self, id, color)
	return self:init(id, color);
end

function Player.gameOver(self)
	for i=0, self.length-1 do
		self.x[i] = 0;
		self.y[i] = 0;
		self.dirx[i] = 0;
		self.diry[i] = 0;
	end
	self.state = GAMEOVER;
end

function Player.lengthChange(self)
	if (self.length+3) < 175 then
	
		for i=self.length, self.length+3-1 do
		
			self.x[i] = self.x[self.length-1];
			self.y[i] = self.y[self.length-1];
			self.dirx[i] = 0;
			self.diry[i] = 0;
		end
		self.length = self.length + 3;
	end
end

--[[
int x1[175];
int y1[175];
int dirx1[175];
int diry1[175];

int x2[175];
int y2[175]
int dirx2[175],
int diry2[175],
--]]

local sounds = false;

local lx1,ly1,lx2,ly2;
local target = HIT;
local c = 300;
local clr = 0;
local red_score = 0;
local blue_score = 0;
local length1=10;
local length2=10;
local chance1 = 5;
local chance2 = 5;
local play1=0;
local play2=0;

local player1 = Player:new(1, colors.red);
local player2 = Player:new(2, colors.blue);


local keyfuncs = {}
function keyfuncs.uparrow()
--[[
	if (play1 == GAMEOVER)
		break;
	if (diry1[0] == 1)
		break;
	
	diry1[0] = -1;
	dirx1[0] = 0;
--]]
end

function keyfuncs.downarrow()
--[[
	if (player1.score == GAMEOVER) then
						break;
	end

					if (diry1[0] == -1)
						break;
					diry1[0] = 1;
					dirx1[0] = 0;
					break;
--]]
end

function keyfuncs.rightarrow()
--[[
					if (play1 == GAMEOVER)
						break;
					if (dirx1[0] == -1)
						break;
					dirx1[0] = 1;
					diry1[0] = 0;
					break;
--]]
end

function keyfuncs.leftarrow()
--[[
					if (play1 == GAMEOVER)
						break;
					if (dirx1[0] == 1)
						break;
					dirx1[0] = -1;
					diry1[0] = 0;
					break;
--]]
end

function keyfuncs.w()
--[[
					if (play2 == GAMEOVER)
						break;
					if (diry2[0] == 1)
						break;
					diry2[0] = -1;
					dirx2[0] = 0;
					break;
--]]
end

function keyfuncs.s()
--[[
					if (play2 == GAMEOVER)
						break;
					if (diry2[0] == -1)
						break;
					diry2[0] = 1;
					dirx2[0] = 0;
					break;
--]]
end

function keyfuncs.d()
--[[
					if (play2 == GAMEOVER)
						break;
					if (dirx2[0] == -1)
						break;
					dirx2[0] = 1;
					diry2[0] = 0;
					break;
--]]
end

function keyfuncs.a()
--[[
					if (play2 == GAMEOVER)
						break;
					if (dirx2[0] == 1)
						break;
					dirx2[0] = -1;
					diry2[0] = 0;
					break;
--]]
end

function keyfuncs.enter()
	--nosound();
	closegraph();
	--exit(0);
end

function keyDown(activity)
	local key = activity.keyCode;
	local keyname = keycodes[activity.keyCode];

	if keyfuncs[keyname] then
		keyfuncs[keyname]()
	end
end


local function loop()
--[[
	while(true) do
	
		check();
		
		if (target == HIT) then
			disp_score();
			setcolor(15);
			line(lx1,ly1,lx2,ly2);
			newtarget();
		end

		-- kbhit


		for (i=0;i<length1;i++)
		{
			x1[i]+=(2*dirx1[i]);
			y1[i]+=(2*diry1[i]);
                        putpixel(x1[i],y1[i],12);
		}
		
		for (i=0;i<length2;i++)
		{
			x2[i]+=(2*dirx2[i]);
			y2[i]+=(2*diry2[i]);
			putpixel(x2[i],y2[i],1);
		}

		putpixel(x1[length1-1],y1[length1-1],0);
		putpixel(x2[length2-1],y2[length2-1],0);

		putpixel(x1[0],y1[0],1);
		putpixel(x2[0],y2[0],12);
		for (i=length1-1;i>0;i--)
		{
			dirx1[i] = dirx1[i-1];
			diry1[i] = diry1[i-1];
		}
		for (i=length2-1;i>0;i--)
		{
			dirx2[i] = dirx2[i-1];
			diry2[i] = diry2[i-1];
		}
		delay(15);
		nosound();
	end
--]]
end

local function main()
	local graphPort = size(width, height)

	--int gd = DETECT,gm,key;
	--char r;
	initgraph(graphPort,nil,"c:\\tc");


	setcolor(1);
	
	rectangle(70,90,560,430);
	setbkcolor(15);
	rectangle(5,110,70,150);
	settextstyle(5,0,0);
		outtextxy(19,115,"Score");
	
	rectangle(560,110,625,150);
	
	setcolor(12);
		outtextxy(570,115,"Score");
	
	setfillstyle(SOLID_FILL,1);
	floodfill(10,10,1);
	setcolor(12);
	settextstyle(1,0,4);
		outtextxy(180,30,"A n a c o n d A");
	draw_mid_box();
	for i=0, 9 do
	
		player1.x[i] = 400;
		player1.y[i] = 240;
		player1.dirx[i] = 0;
		player1.diry[i] = 0;


		player2.x[i] = 200;
		player2.y[i] = 240;
		player2.dirx[i] = 0;
		player2.diry[i] = 0;
	end

	reset_game();

	--closegraph();
end


local function newtarget()
--[[
	lx1 =0;
	ly2 = 0;
	clr = (clr == 6)?1:clr+1;
	while(lx1 < 73 || ly1 < 93)
	{
		lx1 = random(530);
		ly1 = random(400);
	}
	lx2 = lx1+10;
	ly2 = ly1;
	setcolor(clr);
	setlinestyle(0,0,THICK_WIDTH);
	line(lx1,ly1,lx2,ly2);
	target = NOTYET;
--]]
end

local function check()
--[=[
	int no = -1;
	-- left wall checking
	if (y1[0]>89 and y1[0]<431  and x1[0]<=71)
	{
		reset_game(RED);
		return;
	}
	if (y2[0]>89 and y2[0]<431  and x2[0]<=71)
	{
		reset_game(BLUE);
		return;
	}

	-- right wall checking
	if (y1[0]>89 and y1[0]<431  and x1[0]>=560)
	{
			reset_game(RED);
		return;
	}
	if (y2[0]>89 and y2[0]<431  and x2[0]>=560)
	{
		reset_game(BLUE);
		return;
	}

	--top wall checking 
	if (x1[0]>69 and x1[0]<560  and y1[0]<=90)
	{
		reset_game(RED);
		return;
	}
	if (x2[0]>69 and x2[0]<560  and y2[0]<=90)
	{
		reset_game(BLUE);
		return;
	}

	--bottom wall checking
	if (x1[0]>69 and x1[0]<560  and y1[0]>=430)
	{
		reset_game(RED);
		return;
	}
	if (x2[0]>69 and x2[0]<560  and y2[0]>=430)
	{
		reset_game(BLUE);
		return;
	}

	-- top line checking
	if (x1[0]>269 and x1[0]<331 and (y1[0] == 230))
	{
		reset_game(RED);
		return;
	}

	if (x2[0]>269 and x2[0]<331 and y2[0] == 230)
	{
		reset_game(BLUE);
		return;
	}

	-- bottom line checking
	if (x1[0]>269 and x1[0]<331 and (y1[0] == 300))
	{
		reset_game(RED);
		return;
	}

	if (x2[0]>269 and x2[0]<331 and y2[0] == 300)
	{
		reset_game(BLUE);
		return;
	}

	-- left line checking
	if (y1[0]>240 and y1[0]<290 and (x1[0] == 260))
	{
		reset_game(RED);
		return;
	}

	if (y2[0]>240 and y2[0]<290 and x2[0] == 260)
	{
		reset_game(BLUE);
		return;
	}

	-- right line checking
	if (y1[0]>240 and y1[0]<290 and (x1[0] == 340))
	{
		reset_game(RED);
		return;
	}

	if (y2[0]>240 and y2[0]<290 and x2[0] == 340)
	{
		reset_game(BLUE);
		return;
	}

	-- RED hits BLUE
	for (i=0;i<length2;i++)
	{
		if (x1[0] == x2[i] and y1[0] == y2[i])
		{
			reset_game(RED);
			return;
		}
	}

	-- BLUE hits RED 
	for (i=0;i<length1;i++)
	{
		if (x2[0] == x1[i] and y2[0] == y1[i])
		{
			reset_game(BLUE);
			return;
		}
	}

	--[[ RED hits RED
	if (x1[0] != x1[1])
		for (i=1;i<length1;i++)
		{
			if (x1[0] == x1[i] and (y1[0] == y1[i] || y1[0] == y1[i]+1))
			{
				reset_game(RED);
				return;
			}
		}
	 BLUE hits BLUE
	if (x2[0] != x2[1])
		for (i=1;i<length2;i++)
		{
			if (x2[0] == x2[i]  and y2[0] == y2[i])
			{
				reset_game(BLUE);
				return;
			}
		}       --]]

	-- target checking
	while(no<2)
	{
	for (i=ly1+no;i<=ly2+no;i++)
		{
			if (x1[0]>lx1-1 and x1[0]<lx2+1  and y1[0] == i)
			{
    				target = HIT;
				hit_sound();
				red_score+=5;
				player1:lengthChange();

				return;
			}

			if (x2[0]>lx1-1 and x2[0]<lx2+1  and y2[0] == i)
			{
				target = HIT;
				hit_sound();
				blue_score+=5;
				player2:lengthChange();
				return;
			}
		}
	no = no + 1;
	}
--]=]
end

local function reset_game(player)
--[[
	int cr,xxx = 15,yyy = 180;
	--out_sound();
	setlinestyle(0,0,NORM_WIDTH);
	
	if (player == RED) then
	{
		chance1 = chance1 - 1;
		reset_screen();
		if (chance1<0)
			end_game(RED);
	}
	if (player == BLUE)
	{
		chance2--;
		reset_screen();
		if (chance2<0)
			end_game(BLUE);
	}
	setlinestyle(0,0,NORM_WIDTH);
	for (i=0;i<10;i++)
	{
		if (i<chance2) cr = 9;
		else cr = 1;
		setcolor(cr);
		line(xxx,yyy,xxx+45,yyy);
		yyy+=20;
	}
	yyy = 180;
	xxx = 580;
	for (i=0;i<10;i++)
	{
		if (i<chance1) cr = 12;
		else cr = 1;
		setcolor(cr);
		line(xxx,yyy,xxx+45,yyy);
		yyy+=20;
	}
--]]
	setlinestyle(0,0,THICK_WIDTH);
end


local function disp_score()
		gotoxy(3,9);
		printf("%d ",blue_score);
		gotoxy(72,9);
		printf("%d ",red_score);
end

local function draw_mid_box()
	setcolor(1);
	line(270,230,330,230);
	line(270,300,330,300);
	line(260,240,260,290);
	line(340,240,340,290);
end


local function reset_screen()
--[[
	for(i=0;i<length1;i++)
		putpixel(x1[i],y1[i],15);
	for(i=0;i<length2;i++)
		putpixel(x2[i],y2[i],15);

	for (i=0;i<length1;i++)
	{
		if (play1 != GAMEOVER)
		{	x1[i] = 400;
			y1[i] = 240;
			dirx1[i] = diry1[i] = 0;
		}
		length1 = 10;
	}

	for (i=0;i<length2;i++)
	{
		if (play2 != GAMEOVER)
		{	x2[i] = 200;
			y2[i] = 240;
			dirx2[i] = diry2[i] = 0;
		}
		length2 = 10;
	}
--]]
	draw_mid_box();
	setcolor(15);
        setlinestyle(0,0,THICK_WIDTH);
	--line(lx1,ly1,lx2,ly2);
	--newtarget();
end


local function end_game(player)
	if (player == player1) then
		player1:gameOver();
	end

	if (player == player2) then
		player2:gameOver();
	end

	if (player1.state == GAMEOVER and play2.state == GAMEOVER) then	
		settextstyle(5,0,35);
		outtextxy(265,260,"GAME OVER");
		--getch();
		--exit(0);
	end
end





main()
run()
