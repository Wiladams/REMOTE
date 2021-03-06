package.path = "../?.lua;"..package.path;

local ffi = require("ffi")
local random = math.random

local NetInteractor = require("tflremote.sharer")


local colors = require("colors")
local keycodes = require("tflremote.jskeycodes")
local bgi = require("bgi")
local maths = require("tflremote.maths")


local width = 640;
local height = 480;


local DIRUP = 1;
local DIRDOWN = 2;
local DIRLEFT = 3;
local DIRRIGHT = 4;



local HIT =1
local NOTYET =0
local RED =1
local BLUE =2
local YES =1
local NO =0
local GAMEOVER =-1


local Stage = {	left = 70, top = 90, right = 560, bottom = 430}
function Stage.contains(self, x,y)
	return not (x <= self.left or x >= self.right or y <= self.top or y >= self.bottom)
end

function Stage.draw(self)
	setcolor(1);
	rectangle(self.left, self.top, self.right, self.bottom);
end

local MidBox = {
	lines = {
		{x1 = 270, y1 = 230, x2 = 330, y2 = 230},
		{x1 = 270, y1 = 300, x2 = 330, y2 = 300},
		{x1 = 260, y1 = 240, x2 = 260, y2 = 290},
		{x1 = 340, y1 = 240, x2 = 340, y2 = 290}
	}
}

function MidBox.draw(self)
	setcolor(1);
	for _, aline in ipairs(self.lines) do
		line(aline.x1, aline.y1, aline.x2, aline.y2)
	end
end

function MidBox.hit(self, ptx, pty)
	for _, aline in ipairs(self.lines) do
		local distance = maths.pointLineDistance(
			aline.x1, aline.y1, 
			aline.x2, aline.y2, 
			ptx, pty)

		if distance == 0 then return true end
	end

	return false;
end


--[[
	The Arena represents the entirety of the gamespace.
	The Arena contains the stage, as well as the various players.
	It will ultimately receive the commands from the outside world,
	and move the players along.
--]]
local Arena = {}

function Arena.draw(self)
	setcolor(1);

	Stage:draw();

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
	
	MidBox:draw();
end




local Player = {}
local Player_mt = {
	__index = Player
}


-- Definition of a single player in the game
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

function Player.draw(self)
	--print("Player.draw(): ", self.color)

	for i=0, self.length-1 do
		self.x[i] =self.x[i] + (2*self.dirx[i]);
		self.y[i] =self.y[i] + (2*self.diry[i]);
        putpixel(self.x[i],self.y[i],self.color);
	end
	putpixel(self.x[self.length-1],self.y[self.length-1],0);
	putpixel(self.x[0],self.y[0],self.color);
end

function Player.advance(self)
	for i=self.length-1, 1, -1 do
		self.dirx[i] = self.dirx[i-1];
		self.diry[i] = self.diry[i-1];
	end
end

function Player.hasHitWall(self)
	return not Stage:contains(self.x[0], self.y[0])
end

function Player.reset(self, x, y)
	for i=0, self.length-1 do
		putpixel(self.x[i], self.y[i],15);
	end

	for i=0, self.length-1 do
		if (self.state ~= GAMEOVER) then
			self.x[i] = x;
			self.y[i] = y;
			self.dirx[i] = 0;
			self.diry[i] = 0;
		end
		self.length = 10;
	end
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

function Player.move(self, direction)
	if (self.state == GAMEOVER) then
		return 
	end

	if direction == DIRUP then
		if (self.diry[0] == 1) then
			return
		end
	
		self.diry[0] = -1;
		self.dirx[0] = 0;
	elseif direction == DIRDOWN then
		if (self.diry[0] == -1) then
			return
		end

		self.diry[0] = 1;
		self.dirx[0] = 0;
	elseif direction == DIRLEFT then

		if (dirx1[0] == 1) then
			return 
		end
		self.dirx[0] = -1;
		self.diry[0] = 0;
	elseif direction == DIRRIGHT then
		if (self.dirx[0] == -1) then
			return 
		end
		self.dirx[0] = 1;
		self.diry[0] = 0;
	end
end


local sounds = false;

local lx1,ly1,lx2,ly2 = 0,0,0,0;
local target = HIT;
local c = 300;
local clr = 0;
local red_score = 0;
local blue_score = 0;
local length1=10;
local length2=10;
local play1=0;
local play2=0;

local player1 = Player:new(1, 12);
local player2 = Player:new(2, 1);


local keyfuncs = {}
function keyfuncs.uparrow()
	player1:move(DIRUP);
end

function keyfuncs.downarrow()
	player1:move(DIRDOWN);
end

function keyfuncs.rightarrow()
	player1:move(DIRRIGHT)
end

function keyfuncs.leftarrow()
	player1:move(DIRLEFT)
end

function keyfuncs.w()
	player2:move(DIRUP);
end

function keyfuncs.s()
	player2:move(DIRDOWN)
end

function keyfuncs.d()
	player2:move(DIRRIGHT)
end

function keyfuncs.a()
	player2:move(DIRLEFT)
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

local function reset_game(player)

	local cr = 0;
	local xxx = 15;
	local yyy = 180;


	--out_sound();
	setlinestyle(0,0,NORM_WIDTH);

	if (player == player1) then
	
		player1.chance = player1.chance - 1;
		reset_screen();
		if player1.chance<0 then
			end_game(player1);
		end
	end

	if (player == player2) then
	
		player2.chance2 = player2.chance - 1;
		reset_screen();
		if (player2.chance<0) then
			end_game(player2);
		end
	end


	setlinestyle(0,0,NORM_WIDTH);
	for i=0, 9 do
		if i<player2.chance then
			cr = 9;
		else 
			cr = 1;
		end

		setcolor(cr);
		line(xxx,yyy,xxx+45,yyy);
		yyy = yyy  + 20;
	end

	yyy = 180;
	xxx = 580;
	
	for i=0, 9 do
	
		if i < player1.chance then 
			cr = 12;
		else 
			cr = 1;
		end

		setcolor(cr);
		line(xxx,yyy,xxx+45,yyy);
		yyy = yyy+20;
	end

	setlinestyle(0,0,THICK_WIDTH);
end

local function check()
	-- First check to see if they've hit
	-- any of the perimeter walls
	if player1:hasHitWall() then
		reset_game(player1);
		return ;
	end

	if player2:hasHitWall() then
		reset_game(player2);
		return ;
	end


	-- lines of the mid_box
	if MidBox:hit(player1.x[0], player1.y[0]) then
		reset_game(player1);
		return
	end

	if MidBox:hit(player2.x[0], player2.y[0]) then
		reset_game(player2);
		return 
	end


--[=[
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
--]=]

	-- target checking
	-- in order to lengthen your snake, you 
	-- must hit the target, which is moving around
	-- the stage
	local no = -1;
	while no < 2 do
--[[	
		for (i=ly1+no;i<=ly2+no;i++)
		{
			-- player 1 hit target
			if (x1[0]>lx1-1 and x1[0]<lx2+1  and y1[0] == i)
			{
    			target = HIT;
				--hit_sound();
				red_score+=5;
				player1:lengthChange();

				return;
			}

			-- player 2 hit target
			if (x2[0]>lx1-1 and x2[0]<lx2+1  and y2[0] == i)
			{
				target = HIT;
				hit_sound();
				blue_score+=5;
				player2:lengthChange();
				return;
			}
		}
--]]		
		no = no + 1;
	end

end

local function disp_score()
	gotoxy(3,9);
	printf("%d ",player2.score);
	gotoxy(72,9);
	printf("%d ",player1.score);
end

local function newtarget()
	lx1 =0;
	ly2 = 0;
	if clr == 6 then
		clr = 1;
	else
		clr = clr + 1;
	end
	
	while(lx1 < 73 or ly1 < 93) do
		lx1 = random(530);
		ly1 = random(400);
	end

	lx2 = lx1+10;
	ly2 = ly1;
	setcolor(clr);
	setlinestyle(0,0,THICK_WIDTH);
	line(lx1,ly1,lx2,ly2);
	target = NOTYET;
end


function loop()
	--print("loop")
	check();

	if (target == HIT) then
		disp_score();
		setcolor(15);
		line(lx1,ly1,lx2,ly2);
		newtarget();
	end


	player1:draw();
	player1:advance();

	player2:draw();
	player2:advance();


--[[
		for (i=0;i<length1;i++)
		{
			x1[i]+=(2*dirx1[i]);
			y1[i]+=(2*diry1[i]);
                        putpixel(x1[i],y1[i],12);
		}
		putpixel(x1[length1-1],y1[length1-1],0);
		putpixel(x1[0],y1[0],1);
		
		for (i=length1-1;i>0;i--)
		{
			dirx1[i] = dirx1[i-1];
			diry1[i] = diry1[i-1];
		}


		for (i=0;i<length2;i++)
		{
			x2[i]+=(2*dirx2[i]);
			y2[i]+=(2*diry2[i]);
			putpixel(x2[i],y2[i],1);
		}
		putpixel(x2[length2-1],y2[length2-1],0);
		putpixel(x2[0],y2[0],12);


		for (i=length2-1;i>0;i--)
		{
			dirx2[i] = dirx2[i-1];
			diry2[i] = diry2[i-1];
		}
--]]	
end

local function main()
	local graphPort = size(width, height)
	graphPort:clearToWhite();

	initgraph(graphPort,nil,"c:\\tc");

	Arena:draw();

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
end


local function reset_screen()
	player1:reset(400, 240);
	player2:reset(200, 240);


	Arena:draw_mid_box();
	setcolor(15);
        setlinestyle(0,0,THICK_WIDTH);
	line(lx1,ly1,lx2,ly2);
	newtarget();
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
