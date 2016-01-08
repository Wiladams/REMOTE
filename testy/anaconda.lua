#include <stdio.h>
#include <bios.h>
#include <graphics.h>
#include <stdlib.h>
#define UP 18432
#define DOWN 20480
#define RIGHT 19712
#define LEFT 19200
#define ENTER 7181
#define W 4471
#define S 8051
#define A 7777
#define D 8292
#define HIT 1
#define NOTYET 0
#define RED 1
#define BLUE 2
#define YES 1
#define NO 0
#define GAMEOVER -1

int x1[175],y1[175],dirx1[175],diry1[175],i;
int x2[175],y2[175],dirx2[175],diry2[175],sounds = NO;
int lx1,ly1,lx2,ly2,target = HIT,c = 300,clr = 0;
int red_score = 0,blue_score = 0,length1=10,length2=10;
int chance1 = 5,chance2 = 5,play1=0,play2=0;

main()
{
	int gd = DETECT,gm,key;
	char r;
	initgraph(&gd,&gd,"c:\\tc");
	printf("\nSound Y/N  :");
	r = getch();
	if(r == 'y'|| r == 'Y')
		sounds = YES;
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
	for (i=0;i<10;i++)
	{
		x1[i] = 400;
		y1[i] = 240;
		dirx1[i] = diry1[i] = 0;
		x2[i] = 200;
		y2[i] = 240;
		dirx2[i] = diry2[i] = 0;
	}

	reset_game(0);
	while(1)
	{
/*		if (sounds == YES)
			sound(43);*/
		check();
		if (target == HIT)
		{
			disp_score();
			setcolor(15);
			line(lx1,ly1,lx2,ly2);
			newtarget();
		}
		if (kbhit())
		{
			key = bioskey(0);
			switch(key)
			{
				case UP:
					if (play1 == GAMEOVER)
						break;
					if (diry1[0] == 1)
						break;
					diry1[0] = -1;
					dirx1[0] = 0;
					break;
				case DOWN:
					if (play1 == GAMEOVER)
						break;
					if (diry1[0] == -1)
						break;
					diry1[0] = 1;
					dirx1[0] = 0;
					break;
				case RIGHT:
					if (play1 == GAMEOVER)
						break;
					if (dirx1[0] == -1)
						break;
					dirx1[0] = 1;
					diry1[0] = 0;
					break;
				case LEFT:
					if (play1 == GAMEOVER)
						break;
					if (dirx1[0] == 1)
						break;
					dirx1[0] = -1;
					diry1[0] = 0;
					break;
				case W:
					if (play2 == GAMEOVER)
						break;
					if (diry2[0] == 1)
						break;
					diry2[0] = -1;
					dirx2[0] = 0;
					break;
				case S:
					if (play2 == GAMEOVER)
						break;
					if (diry2[0] == -1)
						break;
					diry2[0] = 1;
					dirx2[0] = 0;
					break;
				case D:
					if (play2 == GAMEOVER)
						break;
					if (dirx2[0] == -1)
						break;
					dirx2[0] = 1;
					diry2[0] = 0;
					break;
				case A:
					if (play2 == GAMEOVER)
						break;
					if (dirx2[0] == 1)
						break;
					dirx2[0] = -1;
					diry2[0] = 0;
					break;
				case ENTER:
					nosound();
					closegraph();
					exit(0);

			}
		}
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
	}
	closegraph();

}

newtarget()
{
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
}

check()
{
	int no = -1;
	/*left wall checking */
	if (y1[0]>89 && y1[0]<431  && x1[0]<=71)
	{
		reset_game(RED);
		return;
	}
	if (y2[0]>89 && y2[0]<431  && x2[0]<=71)
	{
		reset_game(BLUE);
		return;
	}
	/*right wall checking */
	if (y1[0]>89 && y1[0]<431  && x1[0]>=560)
	{
			reset_game(RED);
		return;
	}
	if (y2[0]>89 && y2[0]<431  && x2[0]>=560)
	{
		reset_game(BLUE);
		return;
	}

	/*top wall checking */
	if (x1[0]>69 && x1[0]<560  && y1[0]<=90)
	{
		reset_game(RED);
		return;
	}
	if (x2[0]>69 && x2[0]<560  && y2[0]<=90)
	{
		reset_game(BLUE);
		return;
	}

	/*bottom wall checking */
	if (x1[0]>69 && x1[0]<560  && y1[0]>=430)
	{
		reset_game(RED);
		return;
	}
	if (x2[0]>69 && x2[0]<560  && y2[0]>=430)
	{
		reset_game(BLUE);
		return;
	}

	/* top line checking */
	if (x1[0]>269 && x1[0]<331 && (y1[0] == 230))
	{
		reset_game(RED);
		return;
	}

	if (x2[0]>269 && x2[0]<331 && y2[0] == 230)
	{
		reset_game(BLUE);
		return;
	}
	/* bottom line checking */
	if (x1[0]>269 && x1[0]<331 && (y1[0] == 300))
	{
		reset_game(RED);
		return;
	}

	if (x2[0]>269 && x2[0]<331 && y2[0] == 300)
	{
		reset_game(BLUE);
		return;
	}
	/* left line checking */
	if (y1[0]>240 && y1[0]<290 && (x1[0] == 260))
	{
		reset_game(RED);
		return;
	}

	if (y2[0]>240 && y2[0]<290 && x2[0] == 260)
	{
		reset_game(BLUE);
		return;
	}

	/* right line checking */
	if (y1[0]>240 && y1[0]<290 && (x1[0] == 340))
	{
		reset_game(RED);
		return;
	}

	if (y2[0]>240 && y2[0]<290 && x2[0] == 340)
	{
		reset_game(BLUE);
		return;
	}
	/* RED hits BLUE */
	for (i=0;i<length2;i++)
	{
		if (x1[0] == x2[i] && y1[0] == y2[i])
		{
			reset_game(RED);
			return;
		}
	}
	/* BLUE hits RED */
	for (i=0;i<length1;i++)
	{
		if (x2[0] == x1[i] && y2[0] == y1[i])
		{
			reset_game(BLUE);
			return;
		}
	}

	/* RED hits RED
	if (x1[0] != x1[1])
		for (i=1;i<length1;i++)
		{
			if (x1[0] == x1[i] && (y1[0] == y1[i] || y1[0] == y1[i]+1))
			{
				reset_game(RED);
				return;
			}
		}
	 BLUE hits BLUE
	if (x2[0] != x2[1])
		for (i=1;i<length2;i++)
		{
			if (x2[0] == x2[i]  && y2[0] == y2[i])
			{
				reset_game(BLUE);
				return;
			}
		}       */

	/* target checking */
	while(no<2)
	{
	for (i=ly1+no;i<=ly2+no;i++)
		{
			if (x1[0]>lx1-1 && x1[0]<lx2+1  && y1[0] == i)
			{
    				target = HIT;
				hit_sound();
				red_score+=5;
				length_change(1);
				return;
			}

			if (x2[0]>lx1-1 && x2[0]<lx2+1  && y2[0] == i)
			{
				target = HIT;
				hit_sound();
				blue_score+=5;
				length_change(2);
				return;
			}
		}
	no++;
	}
}

reset_game(int player)
{
	int cr,xxx = 15,yyy = 180;
	out_sound();
	setlinestyle(0,0,NORM_WIDTH);
	if (player == RED)
	{
		chance1--;
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
	setlinestyle(0,0,THICK_WIDTH);
}


disp_score()
{
		gotoxy(3,9);
		printf("%d ",blue_score);
		gotoxy(72,9);
		printf("%d ",red_score);
}

draw_mid_box()
{
	setcolor(1);
	line(270,230,330,230);
	line(270,300,330,300);
	line(260,240,260,290);
	line(340,240,340,290);
}

out_sound()
{
	int s;
	if (sounds == YES)
	for(s = 5000;s>100;s-=50)
	{
		sound(s);
		delay(2);
		nosound();
		delay(3);
	}
}

hit_sound()
{
	if (sounds == YES)
	{
		sound(950);
		delay(30);
		sound(1950);
		delay(30);
		sound(2950);
		delay(30);
		sound(3950);
		delay(30);
		sound(4950);
		delay(30);
		sound(5950);
		nosound();
	}
}
reset_screen()
{
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
	draw_mid_box();
	setcolor(15);
        setlinestyle(0,0,THICK_WIDTH);
	line(lx1,ly1,lx2,ly2);
	newtarget();
}
end_game(int player)
{

	if (player == 1)
	{
		for (i=0;i<length1;i++)
		{
			x1[i] = 1;
			y1[i] = 1;
			dirx1[i] = diry1[i] = 0;
		}
		play1 = GAMEOVER;
	}
	if (player == 2)
	{
		for (i=0;i<length2;i++)
		{
			x2[i] = 0;
			y2[i] = 0;
			dirx2[i] = diry2[i] = 0;
		}
		play2 = GAMEOVER;
	}
	if (play1 == GAMEOVER && play2 == GAMEOVER)
	{
		settextstyle(5,0,35);
		outtextxy(265,260,"GAME OVER");
		getch();
		exit(0);
	}
}
length_change(int player)
{
	if (player == 1 && (length2+3)<175)
	{
		for (i=length1;i<length1+3;i++)
		{
			x1[i] = x1[length1-1];
			y1[i] = y1[length1-1];
			dirx1[i] = 0;
			diry1[i] = 0;
		}
		length1+=3;
	}
	if (player == 2 && (length2+3)<175)
	{
		for (i=length2;i<length2+3;i++)
		{
			x2[i] = x2[length2-1];
			y2[i] = y2[length2-1];
			dirx2[i] = 0;
			diry2[i] = 0;
		}
		length2+=3;
	}
}