program Android_Media_Player;

uses
  System.StartUpCopy,
  FMX.Forms,
  UMain in 'UMain.pas' {FrmMain},
  FMX.TextLayout.GPU in 'Arabic Patch\FMX.TextLayout.GPU.pas',
  PersianTool in 'Arabic Patch\PersianTool.pas',
  duck in 'duck.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFrmMain, FrmMain);
  Application.Run;

end.
