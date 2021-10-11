{*********************************************************************************************
 **                          Delphi ROCKS! - An Asteroids Clone
 *********************************************************************************************
 **	     			Programmed By:	John Ayres                                  **
 **      			Date:	        October 19, 1996                            **
 **     		        Splash Screen:	David Bowden                                **
 *********************************************************************************************
 **  There are a number of people in the Delphi community pushing the idea that Delphi is   **
 **  a great platform for making games.  I wholeheartedly agree with this idea.  I've       **
 **  programmed in C for a number of years, but I've found that not only can Delphi do      **
 **  everything that C can, but it can things done in less time.  What used to take months  **
 **  to do in C, I can do in 2 weeks with Delphi.  Games are no exception.  DirectX is      **
 **  becoming the defacto standard in game development, and Delphi has full access to this  **
 **  API.  Although this program does not use DirectX, it demonstrates that you can make    **
 **  a game with a large number of sprites moving about the screen using only high level    **
 **  Object Pascal and Windows API functions and still get a good frame rate.  I hope that  **
 **  sometime in the near future some entrepreneurial company will take the plunge and use  **
 **  Delphi as the development platform for a best selling game.  Delphi could kick more    **
 **  titles out in a year than a comparable team using C, it's just a matter of time        **
 **  before somebody realizes that fact.                                                    **
 **                                                                                         **
 **  Take this game and improve it.  I want to see Delphi become the game programming       **
 **  platform of choice for Windows games.  If enthusiastic Delphi programmers keep showing **
 **  the C world that Delphi is a great games development platform, changes could happen.   **
 *********************************************************************************************
 **  Thanks to all of those programmers who generously provide free examples to      	    **
 **  those of us still learning.  In carrying on such a tradition, this program is hereby   **
 **  designated as freeware, in the hopes that I will contribute to someone's knowledge     **
 **  base, and see Delphi being used in a much broader arena.                               **
 *********************************************************************************************
 **                                  --- Shameless Plug ---                                 **
 **                                                                                         **
 **  Check out the Delphi Developers of Dallas users group.  We're one of the largest in    **
 **  the world, and we get bigger every month.  Visit our web site at:                      **
 **	                                     www.3-D.org                                  		 **
 **                                                                                         **
 **  Tell me what you think about this game or Delphi as a games development platform.  I   **
 **  can be reached at:                                                                     **
 **                                102447.10@Compuserve.Com                                 **
 **                                                                                         **
 **  And coming soon, look for 'DirectX Games Programming With Delphi' in the computer      **
 **  section of your local bookstores.                                                      **
 *********************************************************************************************
 **  Addendum                                                                               **
 **  In the first release of this program, some users experienced a problem with the        **
 **  ProcessUserInput function if they modified the code.  The values from the              **
 **  GetAsyncKeyState API functions (a SHORT) was being compared to 0, and if the value     **
 **  was greater, the appropriate action was performed.  On some machines, the return value **
 **  was a negative number, and thus this comparision failed.  These values are now being   **
 **  compared to the hex number $8000, which seems to fix the problem.  I haven't quite     **
 **  tracked down why the original code works on some machines, but not others.             **
 **                                                                                         **
 **  Some readers have asked if this program was tested under Delphi 1.  It was written     **
 **  specifically for Delphi 2, and has not been compiled under Delphi 1.  However,         **
 **  someone pointed out to me that the only thing that needs to be changed for it to work  **
 **  in the 16 bit world is where the value of the IntersectRect API function is being      **
 **  checked.  Under Windows 95, this returns a boolean value, but under Windows 3.1,       **
 **  it returns an integer value.  I have not tested this yet, but this should help anyone  **
 **  who wants to port this application to Delphi 1.                                        **
 *********************************************************************************************}
 unit DRockU;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, Menus, ExtCtrls, TrigU, StdCtrls,  MMSystem,dateutils;

{global constants}
const
  MISSLEFRAMELIFE = 17;			{number of frames the missle will stay alive}
  MISSLEFRAMELIFEX = 35;			{number of frames the missle will stay alive}
  NUMMISSLES = 20;					{total number of missles allowed in the game}
  NUMMISSLESX = 2;					{total number of missles allowed in the game}
  NUMPARTICLES = 29;
  MISSLEVELDELTA = 10;			   {a constant to determine the missles velocity in relation to the ship}
  MISSLEVELDELTAX = 7;			   {a constant to determine the missles velocity in
  NUMPARTICLES = 29;				{Number of particles in a particle system}
  EXHAUSTLIFESPAN = 10;			{Number of frames that ship exhaust is on the screen}
  EXHAUSTVELDELTA = 2;			   {A constant for adjusting the exhaust velocity in
                                 relation to the player ship velocity}
  NUMASTEROIDS = 20;				{the total number of asteroids allowed}
  MAXASTEROIDRAD = 40;			   {the maximum asteroid radius}

  NUMEXLPDS = 10;					{maximum number of explosions on the screen at once}
  EXPLDLIFE = 10;					{The number of frames that an explosion remains on screen}
  EXPLDVELDELTA = 4;				{velocitiy adjustment for explosion particles}

  SHIELDLIFESPAN = 40;			   {the number of frames that the players shields hold out}

{This array holds color s...}
type
  TFadeColors = array[0..4] of TColor;

{for the fade effect used on bullets and exhaust particles}
const
  FadeColors: TFadeColors = (clMaroon, clRed,clOlive,clYellow, clWhite);

{These states are used for controlling the game in the main loop}
type
  TGameStates = (Playing, Intermission, Demo,gameover);

type
  {this is a real number based point, for use in polygon vertex tracking}
  TRPoint = record
  	X, Y: Real;
  end;

  TAsteroidForm = class(TForm)
    MainMenu1: TMainMenu;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    File1: TMenuItem;
    NewGame1: TMenuItem;
    N1: TMenuItem;
    Exit1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure NewGame1Click(Sender: TObject);
    procedure About1Click(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure N3Click(Sender: TObject);
  private
    { Private declarations }
    FDoLoop: Boolean;                     {Controls the processing of the main loop}
    FOffscreenBuffer: TBitmap;				  {Double Buffer for flicker-free animation}
  public
    { Public declarations }
    procedure MainLoop;						  {Our game control loop function}

    {this procedure is called when the player fires a new bullet}
    procedure StartMissle(InitialX, InitialY: Real; Facing: Integer; StartXVel, StartYVel: Real);

procedure StartMissleX(InitialX, InitialY: Real; Facing: Integer; StartXVel, StartYVel: Real);
    {moves and draws all the missles}
    procedure MoveMissles;

    {Start some particles for the ship exhaust effect}
    procedure StartShipExhaustBurst;

    {draws and moves the particles in the ship exhaust effect}
    procedure DrawShipExhaust;

    {this procedure will start an asteroid with a relative diameter}
    procedure StartAsteroid(InitialX,InitialY: Integer; Facing: Integer; Radius: Integer);

    {this procedure moves and draws all the asteroids, and performs the collision checking}
    procedure MoveAsteroids;

    {Start an explosion particle system}
    procedure StartExplosion(InitialX,InitialY: Integer);

    {Draw the explosion particle systems}
    procedure DrawExplosions;

    {this procedure starts the player in the middle of the screen, with shields on}
    procedure StartPlayer(NewPlayer: Boolean);

    {this procedure simply throws us into the main loop when the program is idling}
    procedure Idling(Sender: TObject; var Done: Boolean);

    {this is used to clear out all of the arrays so we can start new games}
    procedure ClearAll;

    {this procedure will essentially end the game and put us in Intermission mode}
    procedure EndGame;

    {this procedure interprets all keyboard input for the game}
    procedure ProcessUserInput;
  end;

  {the base moving graphic object all others will be decended from. all sprites in this game
   will be vector based}
  TSprite = class
     XPos, YPos: Real; 			   						{world coordinates relative to the center of the sprite}
     XVel, YVel: Real;                              {world velocities}
     Living: Boolean;                               {if it's alive, it'll be moved}
     Color: TColor;												{the color the sprite will be drawn in}
     Angle: Integer;											{direction the sprite is facing}
     procedure MoveSprite;                          {moves the sprite based on velocity}
     procedure Accelerate;                          {increases velocity}
  end;

  {This is used for missles and particle systems}
  TParticle = class(TSprite)
     Lifespan: Integer;										{the current life span, expressed in terms of number of frames}
     MaxLife: Integer;                              {the particles maximum lifespan, used in determining
                                                     what color to draw it in}
     ColDelta: Integer;										{bounding box for missle types}
     procedure Draw;                                {draws the particle and decreases its life}
  end;

  {this is the base class for the player ship and asteroids}
  TPolygonSprite = class(TSprite)
    ColDelta: Integer;                              {used to determine a bounding box from the center}
    ThePolygon: array[0..19] of TRPoint;            {the points for drawing the shape, relative to the center of the shape}
    NumVertices: integer;									   {the number of vertices used in ThePolygon}
    procedure Draw;                                 {this draws and rotates the polygon}
    procedure Rotate(Degrees: integer);             {modifies the direction that the sprite is facing}
  end;

  {This is the class for the players ship.  It simply adds an indicator for the shields}
  TPlayerShip = class(TPolygonSprite)
     ShieldLife: Integer;									   {holds the current count of the shields lifespan}
  end;

  {Asteroids have a few more properties other objects don't}
  TAsteroid = class(TPolygonSprite)
  	RotationRate: Integer;								   {the angle it rotates through each frame}
  end;

  TParticleSystem = array[0..NUMPARTICLES] of TParticle;  {used for explosions and ship exhaust}

  TExplosion = record
     Living: boolean;                               {If it's alive, it'll be drawn}
     Particles: TParticleSystem;                    {The particle system for the explosion}
  end;

var
  AsteroidForm: TAsteroidForm;
  PlayerShip: TPlayerShip;                          {the player ship variable}
  Asteroids: array[0..NUMASTEROIDS] of TAsteroid;   {this tracks all of the asteroids}
  Missles: array[0..NUMMISSLES] of TParticle;			{this tracks all of the missles}
  MisslesX: array[0..NUMMISSLES] of TParticle;			{this tracks all of the missles}
  Explosions: array[0..NUMEXLPDS] of TExplosion;	   {this tracks all of the explosions}
  ShipExhaust: TParticleSystem;                 	   {exhause effect from the players ship}
  Score: Longint;												{The players score}
  NumShipsLeft: Integer;										{The number of lives the player has left}
  CurLevel: Integer;	 										{the current level in the game}
  AnyAsteroidsMoved: Boolean;								{this will determine if all asteroids are dead so we can start a new level}
  GameState: TGameStates;                           {tracks what state the game is currently in}
  PacingCounter : LongInt;

implementation

{$R *.DFM}

type
  RGBSet = record
    R, G, B: byte;
  end;

var rearmtime:tdatetime=-1;
var rearmtimex:tdatetime=-1;
var rearmshtime:tdatetime=-1;
var miscount:integer=0;
var miscountx:integer=0;
function MakeRGB(R: RGBSet): TColor;
begin
  Result := 0;
  Result := Result + (R.R and 255);
  Result := Result shl 8 + (R.G and 255);
  Result := Result shl 16 + (R.B and 255);
end;


{----- TSprite Routines -----}

{moves sprites according to velocity}
procedure TSprite.MoveSprite;
begin
  {add the X and Y velocities to the sprites current position}
  XPos:=XPos+XVel;
	YPos:=YPos+YVel;

  {check for screen sides}
  if XPos>632 then XPos:=0;
  if XPos<0 then XPos:=632;
  if YPos>409 then YPos:=0;
  if YPos<0 then YPos:=409;
end;

{accelerates the sprite, constraining to a maximum velocity}
procedure TSprite.Accelerate;
begin
  {adjust the X velocity}
  XVel:=XVel+CosineArray^[Angle];
  {check for maximum limits}
  if XVel>10 then XVel:=10
  else
  if XVel<-10 then XVel:=-10;

  {adjust the Y velocity}
  YVel:=YVel+SineArray^[Angle];
  {check for maximum limits}
  if YVel>10 then YVel:=10
  else
  if YVel<-10 then YVel:=-10;
end;

{----- TParticle Routines -----}

{moves and draws a particle}
procedure TParticle.Draw;
var
  ParticleColor: TColor;     {a placeholder for the particle color}
  ColorIndex: Real;          {used in determining what color the particle is drawn in}
begin
  {move this particle}
  MoveSprite;

  {Decrease the LifeSpan, as another animation frame has gone by}
  Inc(LifeSpan,-1);

  {if the lifespan has run out, kill this particle}
  if LifeSpan=0 then
  begin
     Living:=False;
     Exit;
  end;

  {if the particle is still alive, then draw it}

  {determine where the color will fall in the color array}
  ColorIndex:=MaxLife/5;	{we have 5 colors}

  {and the particle color is...}
  ParticleColor:=FadeColors[Trunc(LifeSpan/ColorIndex)];

  {draw this particle to our offscreen buffer}
  AsteroidForm.FOffscreenBuffer.Canvas.Pixels[Round(XPos),Round(YPos)]:=ParticleColor;
end;

{----- TPolygonSprite Routines -----}

{modify the sprites current facing}
procedure TPolygonSprite.Rotate(Degrees: Integer);
begin
  {modify the angle}
  Angle:=Angle+Degrees;

  {check for boundries}
  if Angle>359 then Angle:=Angle-359;
  if Angle<0 then Angle:=360+Angle;
end;

{this procedure rotates the points in the polygon to the current facing and draws it
 to the offscreen buffer}
procedure TPolygonSprite.Draw;
var
	TempPoly: Array[0..19] of TPoint;   {a Polyline compatible polygon point array}
  Count: Integer;                     {general loop control variable}
begin
	{Rotate the polygon by the angle using point rotation equations from trigonometry,
   and translate it's position}
  for Count:=0 to NumVertices-1 do
  begin
  	TempPoly[Count].X:=Round((ThePolygon[Count].X*CosineArray^[Angle]-ThePolygon[Count].Y*SineArray^[Angle])+XPos);
  	TempPoly[Count].Y:=Round((ThePolygon[Count].X*SineArray^[Angle]+ThePolygon[Count].Y*CosineArray^[Angle])+YPos);
  end;

  {adjust the pen and the brush of the offscreen buffers canvas}
  AsteroidForm.FOffscreenBuffer.Canvas.Pen.Color:=Color;
  AsteroidForm.FOffscreenBuffer.Canvas.Brush.Style:=bsClear;
  AsteroidForm.FOffscreenBuffer.Canvas.Brush.Color:=Color;

  {draw the polygon using a Windows API function}
  Polygon(AsteroidForm.FOffscreenBuffer.Canvas.Handle,TempPoly,NumVertices);
end;

{----- TAsteroidForm Routines -----}

{This is the main control loop for the entire program.  This controls the action
 from a high level standpoint, and is itself controlled by a state variable that
 determines what should be happening. We want to do this inside of a regular loop
 as opposed to putting this on a timer event.  This is becuase even with an interval
 of 1, the timer is too slow, and a loop will give us the best performance.}
procedure TAsteroidForm.MainLoop;
var
	LevelPauseCounter: TDateTime;		     {for timing how long the level intermission has lasted}
  Count: Integer;								{general loop control}
begin
	while FDoLoop do     {continue this loop until the user shuts down the program}
  case GameState of
     Playing:          {we are actively playing the game}
        begin
           {if the player does not have any ships left, end the game and go into demo mode}
 if NumShipsLeft<0 then
begin
gamestate:=gameover;
//EndGame;
exit;
end;

           {if the player has killed all of the asteroids, go to intermission and increase the level}
           if not AnyAsteroidsMoved then
              GameState:=Intermission;

	         {Erase the previous frame in the offscreen buffer, so we can begin a new one}
		      With FOffscreenBuffer.Canvas do
		      begin
		    	   Brush.Color:=clBlack;
		    	   Brush.Style:=bsSolid;
		    	   Fillrect(Cliprect);
		      end;

           {if the player is still alive, get user input and move the players ship}
           if PlayerShip.Living then
           begin
              ProcessUserInput;
              PlayerShip.MoveSprite;
           end
           else
        	   {we died, start us over}
        	   StartPlayer(TRUE);

           {draw the players ship to the offscreen buffer}
           PlayerShip.Draw;

           {if shields are on, draw them round the players ship}
		      if PlayerShip.ShieldLife>0 then
		    	with FOffscreenBuffer.Canvas do
			      begin
            case PlayerShip.ShieldLife of
            1..10: Pen.Color:=clGreen;
            11..20: Pen.Color:=clLime;
            21..40: Pen.Color:=clWhite;
            end;
		            Brush.Style:=bsClear;
                 {shields are represented by a simple circle}
		            Ellipse(Round(PlayerShip.XPos-PlayerShip.ColDelta-5),Round(PlayerShip.YPos-PlayerShip.ColDelta-5),
		        				  Round(PlayerShip.XPos+PlayerShip.ColDelta+5),Round(PlayerShip.YPos+PlayerShip.ColDelta+5));
                 {decrease the shield life span}
                 Inc(PlayerShip.ShieldLife, -1);
		  	      end;

		      {draw ship exhaust effect}
		      DrawShipExhaust;

		      {Move all active missles}
		      MoveMissles;

		      {Move all Asteroids and check for collisions}
		      MoveAsteroids;

	         {draw any explosions that have just occured}
		      DrawExplosions;

		  	   {Copy the next frame to the screen}
		      AsteroidForm.Canvas.Draw(0,0,FOffscreenBuffer);

	         {Display Score Changes}
	         Panel2.Caption:='Очки: '+IntToStr(Score);

                 {This pause counter is here for the benefit of faster machines.
                  Without it, Delphi Rocks will run too fast to be playable on
                  Pentium 90+ machines.  Try experimenting with the delay time
                  to increase the frame rate if you have a slower machine}
                  PacingCounter := GetTickCount;
                  repeat
                    {Let Windows process any pending messages}
                    Application.ProcessMessages;
                  until (GetTickCount-PacingCounter) > 50;
  		end;
     Intermission:		{this does a slight pause in between levels}
        begin
           {kill any moving sprites}
           ClearAll;

           {increase the level}
           Inc(CurLevel);

	    		{Erase the former frame, so we can begin a new one}
      		With FOffscreenBuffer.Canvas do
		  		begin
		  			Brush.Color:=clBlack;
      			Brush.Style:=bsSolid;
		  			Fillrect(Cliprect);
		  		end;

      		{Draw the level on the offscreen buffer}
      		with FOffscreenBuffer.Canvas do
      		begin
      			SetTextAlign(Handle, TA_CENTER);
      			Font.Name:='Arial';
      		   Font.Size:=30;
      		   Font.Color:=clRed;
             Font.Style:=[fsBold];
      		   Brush.Style:=bsClear;

      		  {display the text centered in the offscreen buffer}
      		  TextOut(FOffscreenBuffer.Width div 2, (FOffscreenBuffer.Height div 2)-(TextHeight('ABC')div 2),
                     'УРОВЕНЬ:'+IntToStr(CurLevel));
      		   Font.Color:=clBlue;
      		  TextOut((FOffscreenBuffer.Width div 2)-1, ((FOffscreenBuffer.Height div 2)-(TextHeight('ABC')div 2))-1,
                     'УРОВЕНЬ:'+IntToStr(CurLevel));

      		end;

	  			{Copy the next frame to the screen}
	    		AsteroidForm.Canvas.Draw(0,0,FOffscreenBuffer);

           {process any ending Windows messages}
	    		Application.ProcessMessages;

           {show this intermission for approximately 4 seconds}
           LevelPauseCounter:=Time;
           repeat
              Application.ProcessMessages;
           until (Time-LevelPauseCounter) > 0.00004;

           {intermission is over, we are actively playing the game again}
           GameState:=Playing;

           {start the player in the middle of the screen, with shields on}
           StartPlayer(FALSE);

  			{display the game values}
  			Panel2.Caption:='Очки: '+IntToStr(Score);
  			if NumShipsLeft>-1 then 		{we don't want to display a negative amount of ships}
        Panel3.Caption:='Попытки: '+IntToStr(NumShipsLeft);
  			Panel4.Caption:='Уровень: '+IntToStr(CurLevel);

           {Now, generate some new asteroids, based on the level we are at}
           for Count:=0 to Random(5)+CurLevel do
           begin
           case random(30) of
            15:
        	   StartAsteroid(Random(631),Random(408),Random(359),Random(45)+20);
            4:
       	   StartAsteroid(Random(631),Random(408),Random(359),Random(30)+20);
            10..12:
            StartAsteroid(Random(631),Random(408),Random(359),Random(20));
        	   else StartAsteroid(Random(631),Random(408),Random(359),Random(10)+20);
            end;
          end;
           {this must be set so we enter the main playing loop}
           AnyAsteroidsMoved:=True;
        end;
        ///////////////
             gameover:		{this does a slight pause in between levels}
        begin
           {kill any moving sprites}
           ClearAll;

           {increase the level}
           Inc(CurLevel);

	    		{Erase the former frame, so we can begin a new one}
      		With FOffscreenBuffer.Canvas do
		  		begin
		  			Brush.Color:=clBlack;
      			Brush.Style:=bsSolid;
		  			Fillrect(Cliprect);
		  		end;

      		{Draw the level on the offscreen buffer}
      		with FOffscreenBuffer.Canvas do
      		begin
      			SetTextAlign(Handle, TA_CENTER);
      			Font.Name:='Arial';
      		   Font.Size:=30;
      		   Font.Color:=clRed;
             Font.Style:=[fsBold];
      		   Brush.Style:=bsClear;

      		  {display the text centered in the offscreen buffer}
      		  TextOut(FOffscreenBuffer.Width div 2, (FOffscreenBuffer.Height div 2)-(TextHeight('ABC')div 2),
                     'ИГРА ЗАВЕРШЕНА');
      		   Font.Color:=clBlue;
      		  TextOut((FOffscreenBuffer.Width div 2)-1, ((FOffscreenBuffer.Height div 2)-(TextHeight('ABC')div 2))-1,
                     'ИГРА ЗАВЕРШЕНА');
      		   Font.Color:=clRed;
      		  TextOut(FOffscreenBuffer.Width div 2, (FOffscreenBuffer.Height div 2)+(TextHeight('ABC')div 2),
                     'ИТОГ: '+inttostr(score));
      		   Font.Color:=clBlue;
      		  TextOut((FOffscreenBuffer.Width div 2)-1, ((FOffscreenBuffer.Height div 2)+(TextHeight('ABC')div 2))-1,
                     'ИТОГ: '+inttostr(score));
      		end;

	  			{Copy the next frame to the screen}
	    		AsteroidForm.Canvas.Draw(0,0,FOffscreenBuffer);

           {process any ending Windows messages}
	    		Application.ProcessMessages;

           {show this intermission for approximately 4 seconds}
           LevelPauseCounter:=Time;
           repeat
              Application.ProcessMessages;
           until (Time-LevelPauseCounter) > 0.00004;

           {intermission is over, we are actively playing the game again}
           endgame;
        end;

        //////////////
     Demo:       {we are not playing the game, so lets show some general animation}
        begin
           {Erase the previous frame, so we can begin a new one}
	         With FOffscreenBuffer.Canvas do
	         begin
	    	      Brush.Color:=clBlack;
	    	      Brush.Style:=bsSolid;
	    	      Fillrect(Cliprect);
	         end;


           MoveAsteroids;
           with FOffscreenBuffer.Canvas do
           begin
      	      SetTextAlign(Handle, TA_CENTER);
      	      Font.Name:='Arial';
              Font.Size:=30;
              Font.Color:=clRed;
              Font.Style:=[fsBold];
              Brush.Style:=bsClear;
              TextOut((FOffscreenBuffer.Width div 2), (FOffscreenBuffer.Height div 4),'DARK ASTEROIDS');
              TextOut((FOffscreenBuffer.Width div 2), (FOffscreenBuffer.Height div 2)-(TextHeight('ABC')div 2)+46,'BY DARKSOFTWARE');
              Font.Color:=clBlue;
              TextOut((FOffscreenBuffer.Width div 2)-1, (FOffscreenBuffer.Height div 4)-1,'DARK ASTEROIDS');
              TextOut((FOffscreenBuffer.Width div 2)-1, (FOffscreenBuffer.Height div 2)-(TextHeight('ABC')div 2)+45,'BY DARKSOFTWARE');
           end;

	  	      {Copy the next frame to the screen}
	         AsteroidForm.Canvas.Draw(0,0,FOffscreenBuffer);

           {process any pending Windows messages}
	         Application.ProcessMessages;
        end;
  end;
end;

{We use this routine instead of the OnKey events of the form so that we can determine if
 more than one key is being held down.  This allows us to rotate, accelerate, and fire
 all at the same time}
procedure TAsteroidForm.ProcessUserInput;
var
   temp: short;
begin
  {counterclockwise rotation}
  if (GetAsyncKeyState(VK_LEFT) AND $8000)=$8000 then
     PlayerShip.Rotate(-15);

  {clockwise rotation}
  if (GetAsyncKeyState(VK_RIGHT) AND $8000)=$8000 then
     PlayerShip.Rotate(15);

  {fire a missle}
if (GetAsyncKeyState(VK_SPACE) AND $8000)=$8000 then
  begin
  if miscount<17 then
  begin
 AsteroidForm.StartMissle(PlayerShip.XPos,PlayerShip.YPos,PlayerShip.Angle,PlayerShip.XVel,PlayerShip.YVel);
inc(miscount,1);
rearmtime:=now;
end else begin
if dateutils.SecondsBetween(now,rearmtime)>2 then begin
miscount:=1;
AsteroidForm.StartMissle(PlayerShip.XPos,PlayerShip.YPos,PlayerShip.Angle,PlayerShip.XVel,PlayerShip.YVel);
rearmtime:=now;
end;
end;
end;

if (GetAsyncKeyState(VK_SHIFT) AND $8000)=$8000 then
  begin
  if miscountx<2 then
  begin
 AsteroidForm.StartMisslex(PlayerShip.XPos,PlayerShip.YPos,PlayerShip.Angle,PlayerShip.XVel,PlayerShip.YVel);
inc(miscountx,1);
rearmtimex:=now;
end else begin
if dateutils.SecondsBetween(now,rearmtimex)>3 then begin
miscountx:=1;
AsteroidForm.StartMisslex(PlayerShip.XPos,PlayerShip.YPos,PlayerShip.Angle,PlayerShip.XVel,PlayerShip.YVel);
rearmtimex:=now;
end;
end;
end;


  {Acceleration}
  if (GetAsyncKeyState(VK_UP) AND $8000)=$8000 then
  begin
     StartShipExhaustBurst;
     PlayerShip.Accelerate;
  end;

if (GetAsyncKeyState(VK_RETURN) AND $8000)=$8000 then
begin
if PlayerShip.ShieldLife<=0 then
if dateutils.SecondsBetween(now,rearmshtime)>15 then begin
PlayerShip.ShieldLife:=SHIELDLIFESPAN;
rearmshtime:=now;
end;
end;
end;
{this sets up all of the game elements}
procedure TAsteroidForm.FormCreate(Sender: TObject);
var
  Count, Count2: Integer;                  {loop control variables}
begin
	FOffscreenBuffer:=TBitmap.Create;			{make the double buffer and initialize it}
  with FOffscreenBuffer do
  begin
  	Width:=632;
  	Height:=409;
     {fill it with black}
  	FOffscreenBuffer.Canvas.Brush.Color:=clBlack;
     FOffscreenBuffer.Canvas.FillRect(Canvas.ClipRect);
  end;

  {initialize random number generation}
  Randomize;
  {initialize the trigonometry lookup tables}
  InitSineArray;
  InitCosineArray;

  {set the control variable for the main loop}
  FDoLoop:=True;

  {initialize all global objects}

  {create an instance of the players ship}
  PlayerShip:= TPlayerShip.Create;

  {create all of the asteroid objects}
  for Count:=0 to NUMASTEROIDS do
  	Asteroids[Count]:= TAsteroid.Create;

  {create all of the missle objects}
  for Count:=0 to NUMMISSLES do
		Missles[Count]:= TParticle.Create;
 for Count:=0 to NUMMISSLESX do
		Misslesx[Count]:= TParticle.Create;

  {create all of the particles for explosions}
  for Count:=0 to NUMEXLPDS do
  	for Count2:=0 to NUMPARTICLES do
  		Explosions[Count].Particles[Count2]:= TParticle.Create;

  {create particles for the ship exhaust effect}
  for Count:=0 to NUMPARTICLES do
    ShipExhaust[Count]:= TParticle.Create;

{Define what the players ship looks like}
with PlayerShip do
begin
	Color:=clYellow;

	NumVertices:=5;            {only five points for this polygon}
  ColDelta:=5;					{set the bounding box for collisions}

  ThePolygon[0].x:=6;
  ThePolygon[0].y:=0;

  ThePolygon[1].x:=-6;
  ThePolygon[1].y:=7;

  ThePolygon[2].x:=-4;
  ThePolygon[2].y:=0;

  ThePolygon[3].x:=-6;
  ThePolygon[3].y:=-7;

  ThePolygon[4].x:=6;
  ThePolygon[4].y:=0;
end;

{set the OnIdle event so the main loop will start automatically}
Application.OnIdle:=Idling;

{we should start out in Intermission mode, so zero out everything}
EndGame;
end;

{clean up everything}
procedure TAsteroidForm.FormDestroy(Sender: TObject);
var
	Count, Count2: Integer;          {general loop control variables}
begin
	FOffscreenBuffer.Free;				{destroy the offscreen buffer}

  {Deallocate the trig lookup tables}
  DestroySineArray;
  DestroyCosineArray;

  {deinitialize all global objects}

  {kill the player ship}
  PlayerShip.Free;

  {kill all the asteroid objects}
  for Count:=0 to NUMASTEROIDS do
  	Asteroids[Count].Free;

  {kill all the missle objects}
  for Count:=0 to NUMMISSLES do
		Missles[Count].Free;
  for Count:=0 to NUMMISSLESX do
		Misslesx[Count].Free;

  {kill all particles for explosions}
  for Count:=0 to NUMEXLPDS do
  	for Count2:=0 to NUMPARTICLES do
  		Explosions[Count].Particles[Count2].Free;

  {kill all ship exhaust particles}
  for Count:=0 to NUMPARTICLES do
    ShipExhaust[Count].Free;
end;

procedure TAsteroidForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  {run the Exit menu click procedure, as it causes the main loop to stop}
  Exit1Click(Self);
end;

{Start a new asteroid in the asteroids array}
procedure TAsteroidForm.StartAsteroid(InitialX,InitialY: Integer; Facing: Integer;Radius: Integer);
var
	Count1, Count2: Integer;            {loop control variables}
  AngleStep: Integer;                 {the angle to increment by as we create points around the asteroid}
  CurAngle: Integer;                  {the current angle}
  Noise1, Noise2: integer;            {variables for random variations in the radius}
  begin
  {search the asteroid array...}
	for Count1:=0 to NUMASTEROIDS do
     {...and if we find a slot that is open, create a new asteroid}
 		if not Asteroids[Count1].Living then
   	with Asteroids[Count1] do
    	begin
    		Living:=True;
      	Angle:=Facing;    {this determines what direction it will move in}
        Color:=random(255*255*255);//!!!asteroid color
        {make sure that the specified radius is not too large...}
        if Radius>MAXASTEROIDRAD then Radius:=MAXASTEROIDRAD;
        {...or too small}
        if Radius<5 then Radius:=5;

        {relative bounding rectangle}
      	ColDelta:=Radius;

        {Determine a random velocity. large asteroids will move slower than smaller ones}
      	XVel:=CosineArray^[Angle]*(random(3)+(MAXASTEROIDRAD div Radius));
      	YVel:=SineArray^[Angle]*(random(3)+(MAXASTEROIDRAD div Radius));

        {Determine a random rotation rate}
        RotationRate:=random(20)-10;

      	{place the asteroid}
      	XPos:=InitialX;
      	YPos:=InitialY;

      	{Now, let's create the asteroid polygon with 6-19 vertices}
        NumVertices:=Random(13)+5;

        {this is how many degress we can rotate through for each vertex}
        AngleStep:=359 div NumVertices;

        {we start at an angle of 0}
        CurAngle:=0;

        {create some vertices in a rough circle with varying magnitudes from the origin}
        for Count2:=0 to NumVertices-1 do
        begin
           {step around the perimeter of the asteroid}
           CurAngle:=CurAngle+AngleStep;

           {generate a random number for a 'fractalized' asteroid look}
           Noise1:=Random(10)-5;
           Noise2:=Random(10)-5;

           {generate the X and Y point relative to the center of the asteroid}
           ThePolygon[Count2].X:=CosineArray^[CurAngle]*Radius+Noise1;
           ThePolygon[Count2].Y:=SineArray^[CurAngle]*Radius+Noise2;
        end;

        {close the polygon}
        ThePolygon[Count2].X:=ThePolygon[0].X;
        ThePolygon[Count2].Y:=ThePolygon[0].Y;

        {we added another point to the polygon, so increase its vertex count}
        inc(NumVertices);

        {we only want to create one asteroid, so break out of the loop}
    		break;
			end;
end;

{this function is responsible for both moving all of the asteroids and checking for
 collisions with asteroids, missles, and the playership}
procedure TAsteroidForm.MoveAsteroids;
var
	Count, Count2, Count3: Integer;  {loop control variables}
  IntersectRect: TRect;				{this is the coordinates of the intersection rectangle}
begin
	{start checking for any living asteroids}
  AnyAsteroidsMoved:=False;

  {loop throught the entire asteroid array}
	for Count:=0 to NUMASTEROIDS do
  begin
     {if this asteroid is alive, move it and check for collisions}
     if Asteroids[Count].Living then
     begin

    	{there is at least one asteroid still left alive, so we won't go into intermission}
     AnyAsteroidsMoved:=True;

     {move this asteroid}
     Asteroids[Count].MoveSprite;

     {Modify its rotation}
     Asteroids[Count].Rotate(Asteroids[Count].RotationRate);

     {draw the asteroid}
     Asteroids[Count].Draw;

     {This is the general collision detection code.  We must see if we have collided
      with either a missle or the players ship.  We will start by checking our
      bounding rectangle against the players bounding rectangle.  If there is a collision,
      we kill the player, kill this asteroid, start two explosions, and create some
      more asteroids, only a little smaller}
     if (WinProcs.IntersectRect(IntersectRect,
     									Rect(Round(Asteroids[Count].XPos-Asteroids[Count].ColDelta),
                          		Round(Asteroids[Count].YPos-Asteroids[Count].ColDelta),
                            		Round(Asteroids[Count].XPos+Asteroids[Count].ColDelta),
                                Round(Asteroids[Count].YPos+Asteroids[Count].ColDelta)),
      									Rect(Round(PlayerShip.XPos-PlayerShip.ColDelta),
                                Round(PlayerShip.YPos-PlayerShip.ColDelta),
                                Round(PlayerShip.XPos+PlayerShip.ColDelta),
                                Round(PlayerShip.YPos+PlayerShip.ColDelta))))
      		and (PlayerShip.ShieldLife<=0) then
     begin				{if there has been a collision...}
        {start an explosion for the player and the asteroid}
        StartExplosion(Round(PlayerShip.XPos), Round(PlayerShip.YPos));
        StartExplosion(Round(Asteroids[Count].XPos), Round(Asteroids[Count].YPos));

        {kill this asteroid}
        Asteroids[Count].Living:=False;

        {kill the player}
        PlayerShip.Living:=False;

        {increase the players score. this should give us a higher score for smaller asteroids}
        Score:=Score+(MAXASTEROIDRAD-Asteroids[Count].ColDelta);

        {generate a few asteroids...}
        for Count3:=0 to Random(3) do
           {...but only if the current asteroid is not too small}
        	if Asteroids[Count].ColDelta>10 then
              {make these asteroids a little smaller than the one that just died}
         		StartAsteroid(Round(Asteroids[Count].XPos),Round(Asteroids[Count].YPos),
         						  Random(359),Asteroids[Count].ColDelta-5);
     end;

     {now, test against all of the bullets}
		for Count2:=0 to NUMMISSLES do
        {if this bullet is alive, check for a collision}
        if Missles[Count2].Living=True then
      	   if WinProcs.IntersectRect(IntersectRect,
                                     Rect(Round(Asteroids[Count].XPos-Asteroids[Count].ColDelta),
          	                 			  Round(Asteroids[Count].YPos-Asteroids[Count].ColDelta),
            	               		  Round(Asteroids[Count].XPos+Asteroids[Count].ColDelta),
              	                    Round(Asteroids[Count].YPos+Asteroids[Count].ColDelta)),
      										  Rect(Round(Missles[Count2].XPos-Missles[Count2].ColDelta),
                  	              	  Round(Missles[Count2].YPos-Missles[Count2].ColDelta),
                    	              Round(Missles[Count2].XPos+Missles[Count2].ColDelta),
                      	              Round(Missles[Count2].YPos+Missles[Count2].ColDelta))) then
      		begin						{we shot an asteroid}
              {start an explosion for this asteroid}
		         StartExplosion(Round(Missles[Count2].XPos), Round(Missles[Count2].YPos));

              {kill this asteroid}
    		      Asteroids[Count].Living:=False;

              {kill this bullet}
              Missles[Count2].Living:=False;

              {increase the players score. this should give us a higher score for smaller asteroids}
              Score:=Score+(MAXASTEROIDRAD-Asteroids[Count].ColDelta);

              {generate a few asteroids...}
              for Count3:=0 to Random(3) do
                 {...but only if the current asteroid is not too small}
        	      if Asteroids[Count].ColDelta>10 then
                    {make these asteroids a little smaller than the one that just died}
         		      StartAsteroid(Round(Asteroids[Count].XPos),Round(Asteroids[Count].YPos),
         			      			  Random(359),Asteroids[Count].ColDelta-5);
           end;
           ///////////////////////
		for Count2:=0 to NUMMISSLESX do
        {if this bullet is alive, check for a collision}
        if Misslesx[Count2].Living=True then
      	   if WinProcs.IntersectRect(IntersectRect,
                                     Rect(Round(Asteroids[Count].XPos-Asteroids[Count].ColDelta),
          	                 			  Round(Asteroids[Count].YPos-Asteroids[Count].ColDelta),
            	               		  Round(Asteroids[Count].XPos+Asteroids[Count].ColDelta),
              	                    Round(Asteroids[Count].YPos+Asteroids[Count].ColDelta)),
      										  Rect(Round(Misslesx[Count2].XPos-Misslesx[Count2].ColDelta),
                  	              	  Round(Misslesx[Count2].YPos-Misslesx[Count2].ColDelta),
                    	              Round(Misslesx[Count2].XPos+Misslesx[Count2].ColDelta),
                      	              Round(Misslesx[Count2].YPos+Misslesx[Count2].ColDelta))) then
      		begin						{we shot an asteroid}
              {start an explosion for this asteroid}
		         StartExplosion(Round(Misslesx[Count2].XPos), Round(Misslesx[Count2].YPos));

              {kill this asteroid}
    		      Asteroids[Count].Living:=False;

              {kill this bullet}
              Misslesx[Count2].Living:=False;

              {increase the players score. this should give us a higher score for smaller asteroids}
              Score:=Score+(MAXASTEROIDRAD-Asteroids[Count].ColDelta);

              {generate a few asteroids...}
              for Count3:=0 to Random(3) do
                 {...but only if the current asteroid is not too small}
        	      if Asteroids[Count].ColDelta>25 then
                    {make these asteroids a little smaller than the one that just died}
         		      StartAsteroid(Round(Asteroids[Count].XPos),Round(Asteroids[Count].YPos),
         			      			  Random(359),Asteroids[Count].ColDelta-5);
           end;

           //////////////////////
    end;
  end;
end;

{start a new player, in the middle of the game field, with shields on}
procedure TAsteroidForm.StartPlayer(NewPlayer: Boolean);
begin
	with PlayerShip do
  begin
     Living:=True;
     ShieldLife:=SHIELDLIFESPAN;
     rearmshtime:=now;
     XPos:=316;
     YPos:=204;
     XVel:=0;
     YVel:=0;
     Angle:=0;
  end;

  {subtract one from the overall ships left, if this is a new player}
  if NewPlayer then
     Dec(NumShipsLeft);

  {display the game values}
  Panel2.Caption:='Очки: '+IntToStr(Score);
  if NumShipsLeft>-1 then 		{we don't want to display a negative amount of ships}
  	Panel3.Caption:='Попытки: '+IntToStr(NumShipsLeft);
  Panel4.Caption:='Уровень: '+IntToStr(CurLevel);
end;

{This starts some particles in the ship exhaust particle system}
procedure TAsteroidForm.StartShipExhaustBurst;
var
	Count1, Count2: Integer;         {loop control variables}
  Angle: Integer;                  {determines the direction of a particle}
begin
	{Start a random number of particles}
  for Count1:=0 to random(4)+5 do
  	for Count2:=0 to NUMPARTICLES do
        {if this slot in the ship exhaust particle array is open, use it}
    	   if not ShipExhaust[Count2].Living then
        with ShipExhaust[Count2] do
        begin
           {mark this particle as living}
           Living:=true;

           {the particle direction will be opposite that of the player plus a small random amount}
           Angle:=PlayerShip.Angle+180+(random(30)-15);

           {make sure our direction is valid}
  			if Angle>359 then Angle:=Angle-359;
  			if Angle<0 then Angle:=360+Angle;

           {determine lifespan, plus a random amount}
           LifeSpan:=EXHAUSTLIFESPAN+(random(10)+1);
           MaxLife:=LifeSpan;

        	{This will insure that the exhaust is always slower than the player's ship}
        	XVel:=(CosineArray^[Angle]*EXHAUSTVELDELTA);
        	YVel:=(SineArray^[Angle]*EXHAUSTVELDELTA);

        	{Start the exhaust a little bit behind the ship}
        	XPos:=PlayerShip.XPos+(CosineArray^[Angle]*4);
        	YPos:=PlayerShip.YPos+(SineArray^[Angle]*4);

           {we only wanted to start one particle in the inner loop, so break out of it}
           break;
        end;
end;

{animate and draw the ship exhaust effect}
procedure TAsteroidForm.DrawShipExhaust;
var
	Count: Integer;            {loop control variable}
begin
  {for every particle in the ship exhaust particle system...}
	for Count:=0 to NUMPARTICLES do
     {...if it lives, move and draw it}
     if ShipExhaust[Count].Living then
        ShipExhaust[Count].Draw;
end;

{This procedure starts a bullet for the player, if one is available}
procedure TAsteroidForm.StartMissle(InitialX, InitialY: Real; Facing: Integer; StartXVel, StartYVel: Real);
var
  Count: Integer;					{general loop counter}
begin
  {loop through the Missles array}
  for Count:=0 to NUMMISSLES do
     {if this slot is open, use it}
		if not Missles[Count].Living then
    	with Missles[Count] do
     begin
        {mark this missle as living}
        Living:=True;

        {small bounding rectangle}
        ColDelta:=2;

        {LifeSpan measures how long they will live, in terms of number
         of frames that will pass before they fade away. This will give them a specific
         range instead of the entire board.}
        LifeSpan:= MISSLEFRAMELIFE;
        MaxLife:=MISSLEFRAMELIFE;

        {This will insure that the bullet is always faster than the player's ship}
        XVel:=StartXVel+(CosineArray^[Facing]*MISSLEVELDELTA);
        YVel:=StartYVel+(SineArray^[Facing]*MISSLEVELDELTA);

        {Start the bullet a little bit ahead of the ship}
        XPos:=InitialX+CosineArray^[Facing]*2;
        YPos:=InitialY+SineArray^[Facing]*2;

        {we only wanted to start one bullet, so break out of the loop}
    		break;
      end;
end;

procedure TAsteroidForm.StartMissleX(InitialX, InitialY: Real; Facing: Integer; StartXVel, StartYVel: Real);
var
  Count: Integer;					{general loop counter}
begin
  {loop through the Missles array}
  for Count:=0 to NUMMISSLESX do
     {if this slot is open, use it}
		if not Misslesx[Count].Living then
    	with Misslesx[Count] do
     begin
        {mark this missle as living}
        Living:=True;

        {small bounding rectangle}
        ColDelta:=2;

        {LifeSpan measures how long they will live, in terms of number
         of frames that will pass before they fade away. This will give them a specific
         range instead of the entire board.}
        LifeSpan:= MISSLEFRAMELIFEX;
        MaxLife:=MISSLEFRAMELIFEX;

        {This will insure that the bullet is always faster than the player's ship}
        XVel:=StartXVel+(CosineArray^[Facing]*MISSLEVELDELTAX);
        YVel:=StartYVel+(SineArray^[Facing]*MISSLEVELDELTAX);
        {Start the bullet a little bit ahead of the ship}
        XPos:=InitialX+CosineArray^[Facing]*2;
        YPos:=InitialY+SineArray^[Facing]*2;

        {we only wanted to start one bullet, so break out of the loop}
    		break;
      end;
end;



procedure TAsteroidForm.MoveMissles;
var
	Count: Integer;      {general loop control variable}
begin
  {search the entire missle array...}
	for Count:=0 to NUMMISSLES do
     {...and if this one is alive, move and draw it}
     if Missles[Count].Living then
        Missles[Count].Draw;
	for Count:=0 to NUMMISSLESX do
     {...and if this one is alive, move and draw it}
     if Misslesx[Count].Living then
        Misslesx[Count].Draw;

 end;

{this procedure parses through the explosion list. if a free explosion slot is found,
 it generates all the particles for that explosion}
procedure TAsteroidForm.StartExplosion(InitialX,InitialY: Integer);
var
	Count1, Count2: Integer;            {loop control variables}
  CurAngle, AngleStep: Integer;       {used in starting particles in a circular fashion}
begin
	{see if an explosion slot is available}
	for Count1:=0 to NUMEXLPDS do
     {if this slot is available, use it}
     if not Explosions[Count1].Living then
     begin
        {mark this slot as alive}
        Explosions[Count1].Living:=True;

        {prepare to generate the particles radiating from the center outwards
         in a 360 degree circle}
        CurAngle:=0;
        AngleStep:=360 div NUMPARTICLES;

 			{now, step through each particle, setting it up accordingly}
        for Count2:=0 to NUMPARTICLES do
        begin
      	   {flag the particle as alive}
				Explosions[Count1].Particles[Count2].Living:=True;

      	   {determine lifespan, plus a random amount}
           Explosions[Count1].Particles[Count2].LifeSpan:=EXPLDLIFE+(random(10)+1);
           Explosions[Count1].Particles[Count2].MaxLife:=Explosions[Count1].Particles[Count2].LifeSpan;

           {determine the velocity, plus a little extra}
           Explosions[Count1].Particles[Count2].XVel:=CosineArray^[CurAngle]*EXPLDVELDELTA*(Random(2)+1);
				Explosions[Count1].Particles[Count2].YVel:=SineArray^[CurAngle]*EXPLDVELDELTA*(Random(2)+1);

           {place the explosions center point}
           Explosions[Count1].Particles[Count2].XPos:=InitialX;
           Explosions[Count1].Particles[Count2].YPos:=InitialY;

           {increase our position around the circle}
           CurAngle:=CurAngle+AngleStep;
        end;

        {we only wanted one explosion, so break out of the loop}
    	   Break;
     end;
end;

procedure TAsteroidForm.DrawExplosions;
var
	Count1, Count2: Integer;         {loop control variables}
  DeadParticles: Integer;          {used in determining if an explosion is no longer living}
begin
	{check to see if we need to play this explosion}
	for Count1:=0 to NUMEXLPDS do
  	if Explosions[Count1].Living then
     begin
        {this tallies all of the dead particles in the explosion. if they are all
         dead, then this explosion slot can be freed.}
        DeadParticles:=0;

        {parse all the particles and draw them}
        for Count2:=0 to NUMPARTICLES do
        begin
     	   if Explosions[Count1].Particles[Count2].Living then
              Explosions[Count1].Particles[Count2].Draw;
           {if this particle is no longer alive, increase the dead particle count}
           if Explosions[Count1].Particles[Count2].Living=False then Inc(DeadParticles)
        end;

        {check to see if all the particles in this explosion are dead, and if so, free the slot}
        if DeadParticles>=NUMPARTICLES then
           Explosions[Count1].Living:=False;
     end;
end;

procedure TAsteroidForm.NewGame1Click(Sender: TObject);
begin
	{Make sure any random asteroids are all dead}
  ClearAll;

  {initialize the global variables for score, lives, and level}
  NumShipsLeft:=3;
  Score:=0;
  CurLevel:=0;

  {Start a new player ship}
  StartPlayer(TRUE);

  {we are now actively playing the game}
  GameState:=Playing;

  {go back into the main loop}
	MainLoop;
end;

{Show the about screen}
procedure TAsteroidForm.About1Click(Sender: TObject);
begin
end;

{kick us into the main loop when the app becomes idle}
procedure TAsteroidForm.Idling(Sender: TObject; var Done: Boolean);
begin
	MainLoop;
  Done:=true;
end;

{this will zero out all of the arrays, which will be useful when we want to start another
 game or another level}
procedure TAsteroidForm.ClearAll;
var
	Count: Integer;      {loop control variable}
begin
	{clear all asteroids}
	for Count:=0 to NUMASTEROIDS do
  	Asteroids[Count].Living:=False;

  {clear all missles}
  for Count:=0 to NUMMISSLES do
  	Missles[Count].Living:=False;
  for Count:=0 to NUMMISSLESx do
  	Misslesx[Count].Living:=False;

  {clear all explosions}
  for Count:=0 to NUMEXLPDS do
  	Explosions[Count].Living:=False;

  {clear the ship exhaust particles}
  for Count:=0 to NUMPARTICLES do
  	ShipExhaust[Count].Living:=False;

end;

{this is a general procedure that will end the current game, generate some random asteroids,
 and put us into Intermission mode}
procedure TAsteroidForm.EndGame;
var
	Count: Integer;         {loop control variable}
begin
  {zero out the global variables for score, lives, and level}
  NumShipsLeft:=-1;
  Score:=0;
  CurLevel:=0;

  {display these values}
  Panel2.Caption:='Очки: '+IntToStr(Score);
  Panel3.Caption:='Попытки: 0';
  Panel4.Caption:='Уровень: '+IntToStr(CurLevel);

  {make sure everything is dead}
  ClearAll;

  {Generate some random asteroids}
  for Count:=0 to 10 do
  	StartAsteroid(Random(FOffscreenBuffer.Width),Random(FOffscreenBuffer.Height),
    					  Random(359),Random(MAXASTEROIDRAD));

  {and put us into demo mode}
  GameState:=Demo;
end;

{stop the program.}
procedure TAsteroidForm.Exit1Click(Sender: TObject);
begin
  {kill the idle event so it doesn't throw us back into the game loop}
  Application.OnIdle:=nil;

  {turn the main loop off}
  FDoLoop:=False;

  {terminate the program}
  Application.Terminate;
end;

procedure TAsteroidForm.N3Click(Sender: TObject);
begin
FDoLoop:=False;
ShowMessage('DarkAsteroids (DelphiROCKS!)'+#13+'Автор изначального кода: John Ayres'+#13+'Ремейк и доработка: Alex Dark'+#13+'Российская Федерация, г.Кольчугино'#13+'Посвящается любимой М.В.Ш.');
FDoLoop:=True;
end;

end.
