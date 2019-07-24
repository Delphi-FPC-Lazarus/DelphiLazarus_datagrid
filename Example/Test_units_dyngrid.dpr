program Test_units_dyngrid;

//FastMM4 in '..\..\_Share\extern\FastMM\FastMM4.pas',
//FastMM4Messages in '..\..\_Share\extern\FastMM\FastMM4Messages.pas',

uses
  Vcl.Forms,
  Unitdyngridtest in 'Unitdyngridtest.pas' {frmTest},
  dyngrid_unit in '..\dyngrid_unit.pas',
  TextFile_unit in '..\TextFile_unit.pas',
  unicode_def_unit in '..\unicode_def_unit.pas';

{$R *.res}

begin
  {$IFDEF DEBUG}
  ReportMemoryLeaksOnShutdown:= true;
  {$ENDIF}
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmTest, frmTest);
  Application.Run;
end.
