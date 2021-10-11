program darkasteroids;

uses
  Forms,
  SysUtils,
  Controls,
  DRockU in 'DRockU.pas' {AsteroidForm},
  Trigu in 'Trigu.pas';

{$R *.RES}

begin
  Screen.Cursor := crDefault;
  Application.Title := 'DarkAsteroids.E X E';
  Application.CreateForm(TAsteroidForm, AsteroidForm);
  Application.Run;
end.
