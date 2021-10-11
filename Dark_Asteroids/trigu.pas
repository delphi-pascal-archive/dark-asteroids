{********************************************************************************************
 **                                 TestTrig.Pas Unit                                      **
 **  ------------------------------------------------------------------------------------  **
 **	 This unit generates a sine and cosine lookup table.  This is an optimization         **
 **	 technique which greatly speeds up Trig functions, since they use so much Sines,      **
 **   Cosines, etc.  Using this technique, a program generates all of the possible values  **
 **   before hand, and then looks them up in a table when they are needed.  This avoids    **
 **   using the very slow built in Trig functions.                                         **
 ********************************************************************************************}

unit Trigu;

interface

type
    TSineArray = array[0..359] of Real;
    TCosineArray = array[0..359] of Real;

var
   SineArray: ^TSineArray;
   CosineArray: ^TCosineArray;

procedure InitSineArray;
procedure InitCosineArray;
procedure DestroySineArray;
procedure DestroyCosineArray;

implementation

procedure InitSineArray;
var
   Count: Integer;
begin
  {allocate memory for the sine array}
  GetMem(SineArray, SizeOf(TSineArray));

  {generate sines for 360 degrees.  remember, we must convert to radians for the sin function}
  for Count:=0 to 359 do
      SineArray^[Count]:=Sin((Count)*(pi / 180));
end;

procedure InitCosineArray;
var
   Count: Integer;
begin
  {allocate memory for the sine array}
  GetMem(CosineArray, SizeOf(TCosineArray));

  {generate cosines for 360 degrees.  remember, we must convert to radians for the cos function}
  for Count:=0 to 359 do
      CosineArray^[Count]:=Cos((Count)*(pi / 180));
end;

procedure DestroySineArray;
begin
  {deallocate the memory}
  FreeMem(SineArray, SizeOf(TSineArray));
end;

procedure DestroyCosineArray;
begin
  {deallocate the memory}
  FreeMem(CosineArray, SizeOf(TCosineArray));
end;

end.
