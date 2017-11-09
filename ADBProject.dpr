program ADBProject;

uses
  System.StartUpCopy,
  FMX.Forms,
  unTestProject in 'unTestProject.pas' {Form1},
  ArrayAssoc in 'ArrayAssoc.pas',
  ADBConnection in 'ADBConnection.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;

end.
