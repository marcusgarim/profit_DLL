program DLLClientP;

uses
  Vcl.Forms,
  frmClientU in 'frmClientU.pas' {frmClient},
  functionWrapperU in 'Wrapper\functionWrapperU.pas',
  callbackWrapperU in 'Wrapper\callbackWrapperU.pas',
  callbackTypeU in 'Types\callbackTypeU.pas',
  enums in 'Types\enums.pas',
  structs in 'Types\structs.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.Title:= 'DataFeed Client';
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmClient, frmClient);
  Application.Run;
end.
