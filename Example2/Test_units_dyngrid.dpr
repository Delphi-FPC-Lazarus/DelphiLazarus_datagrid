program Test_units_dyngrid;

uses
  Vcl.Forms,
  dyngrid_unit in '..\dyngrid_unit.pas',
  unicode_def_unit in '..\unicode_def_unit.pas',
  TextFile_unit in '..\TextFile_unit.pas',
  Unitdyngridtest in 'Unitdyngridtest.pas' {frmTest};

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
