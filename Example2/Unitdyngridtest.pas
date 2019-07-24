unit Unitdyngridtest;

interface

uses
  System.UITypes,
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Grids, Vcl.StdCtrls,
  Vcl.Samples.Spin;

type
  TfrmTest = class(TForm)
    DrawGridDyn: TDrawGrid;
    btndynfuellen: TButton;
    btnladen: TButton;
    btnschreiben: TButton;
    btntesten: TButton;
    btnSpeed: TButton;
    cbStresstest: TCheckBox;
    spedit: TSpinEdit;
    btndynadd: TButton;
    btnclear: TButton;
    btnDrawgridReset: TButton;
    cbStresstestwrite: TCheckBox;
    cbStresstestread: TCheckBox;
    cbStresstestshuffle: TCheckBox;
    brnrepaint: TButton;
    procedure FormCreate(Sender: TObject);
    procedure btndynfuellenClick(Sender: TObject);
    procedure btnschreibenClick(Sender: TObject);
    procedure btntestenClick(Sender: TObject);
    procedure btnladenClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnSpeedClick(Sender: TObject);
    procedure cbStresstestClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure btndynaddClick(Sender: TObject);
    procedure btnclearClick(Sender: TObject);
    procedure cbStresstestwriteClick(Sender: TObject);
    procedure cbStresstestreadClick(Sender: TObject);
    procedure btnDrawgridResetClick(Sender: TObject);
    procedure cbStresstestshuffleClick(Sender: TObject);
    procedure brnrepaintClick(Sender: TObject);
    procedure DrawGridDynDblClick(Sender: TObject);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

type
  TStresstest = class(TThread)
  private
    faktiv:Boolean;
    fdowrite:Boolean;
    fdoread:Boolean;
    fdoshuffle:Boolean;
    fname:string;
  protected
    procedure Execute; override;
  public
    property aktiv:boolean read faktiv write faktiv;

    property doread:boolean read fdoread write fdoread;
    property dowrite:boolean read fdowrite write fdowrite;
    property doshuffle:boolean read fdoshuffle write fdoshuffle;

    property anzname:string read fname write fname;
  end;

var
  frmTest: TfrmTest;

implementation

{$R *.dfm}

// Notiz: FASTMM scheint im Fulldebugmode einen extrem negativen Einfluss auf Performance und Speicherfreigabe zu haben (zu prüfen)
//        ohne fullldebugmode ist alles ok

uses //synobj_unit,
     dyngrid_unit, unicode_def_unit;

var dyngrid:TdynGrid;
    Stresstest1:TStresstest;
    Stresstest2:TStresstest;
    Stresstest3:TStresstest;
    Stresstest4:TStresstest;

// ----------------------------------------------------------

procedure TStresstest.Execute;
var r:Integer;
    s:String;
    su:UTF8String;

    i,r1,r2:Integer;
    sa:array[0..9] of String;
begin
 FreeOnTerminate:= false;
 faktiv:= false;
 fdoread:= false;
 fdowrite:= false;
 fdoshuffle:= false;
 r:= 0;
 while not Terminated do
 begin
  if (faktiv) and (assigned(dyngrid)) then
  begin
   if Assigned(dyngrid) then
   begin

    if fdoread or fdowrite then
    begin
      if fdoread then
      begin
        //s:= dyngrid.cells[0,r];
        su:= dyngrid.cellsRaw[0,r];
      end;
      if fdowrite then
      begin
       s:= fname+formatdatetime('hh:nn:ss:zzz', time);
       dyngrid.cells[0,r]:= s;
      end;
      inc(r);
      if r > dyngrid.rowcount-1 then r:= 0;
    end;

    if fdoshuffle then
    begin
      r1:= random(dyngrid.rowcount);
      r2:= random(dyngrid.rowcount);
      // r1 -> sa
      for i:= 1 to dyngrid.colcount do
       sa[i-1]:= dyngrid.cells[i-1,r1];
      // r2 -> r1
      for i:= 1 to dyngrid.colcount do
       dyngrid.cells[i-1,r1]:= dyngrid.cells[i-1,r2];
      // sa -> r2
      for i:= 1 to dyngrid.colcount do
       dyngrid.cells[i-1,r2]:= sa[i-1];
    end;

   end;
  end
  else
  begin
   sleep(10);
  end;
 end;
end;

// ----------------------------------------------------------


procedure TfrmTest.FormClose(Sender: TObject; var Action: TCloseAction);
begin
 FreeAndNil(Stresstest1);
 FreeAndNil(Stresstest2);
 FreeAndNil(Stresstest3);
 FreeAndNil(Stresstest4);

 FreeAndNil(dyngrid);
end;

procedure TfrmTest.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
 stresstest1.aktiv:= false;
 stresstest1.Terminate;
 stresstest2.aktiv:= false;
 stresstest2.Terminate;
 stresstest3.aktiv:= false;
 stresstest3.Terminate;
 stresstest4.aktiv:= false;
 stresstest4.Terminate;
end;

procedure TfrmTest.FormCreate(Sender: TObject);

 procedure dyngrid_init;
 begin
  dyngrid:= TdynGrid.Create('Test1', @DrawGriddyn);
  dyngrid.colcount:= 3;
  dyngrid.clearlikestringgrid;
  // dyngrid.drawgridautorepaint:= true; // optionales autorepaint
 end;

begin
 randomize;
 dyngrid_init;
 Stresstest1:= TStresstest.Create;
 Stresstest1.anzname:= 'st1_';
 Stresstest2:= TStresstest.Create;
 Stresstest2.anzname:= 'st2_';
 Stresstest3:= TStresstest.Create;
 Stresstest3.anzname:= 'st3_';
 Stresstest4:= TStresstest.Create;
 Stresstest4.anzname:= 'st4_';
end;

procedure TfrmTest.btndynfuellenClick(Sender: TObject);
var start,stop:TDatetime;
     m, i:integer;
begin
 dyngrid.setdrawgrid(nil); // Grafik ist immer langsam
 m:= spedit.Value;
 dyngrid.rowcount:= m;

 start:= date+time;
 for i:= 1 to m do
 begin
   dyngrid.cells[0, i-1]:= 'Test'+inttostr(i);
   if i = 1 then dyngrid.cells[0, i-1]:= dyngrid.cells[0, i-1] + ' Das ist die erste Zeile!';
   if i = m then dyngrid.cells[0, i-1]:= dyngrid.cells[0, i-1] + ' Das ist die letzte Zeile!';
 end;
 stop:= date+time;
 showmessage(format('%f',[(stop-start)*24*60*60]));

 dyngrid.setdrawgrid(@DrawGridDyn);
 DrawGridDyn.Refresh;
end;

procedure TfrmTest.brnrepaintClick(Sender: TObject);
begin
 DrawGridDyn.Repaint;
end;

procedure TfrmTest.btnclearClick(Sender: TObject);
begin
 dyngrid.clearlikestringgrid;
end;

procedure TfrmTest.btnDrawgridResetClick(Sender: TObject);
begin
 dyngrid.setdrawgrid(nil);
end;

procedure TfrmTest.btndynaddClick(Sender: TObject);
var start,stop:TDatetime;
     m, i:integer;
begin
 dyngrid.setdrawgrid(nil); // Grafik ist immer langsam
 m:= spedit.Value;

 start:= date+time;
 for i:= 1 to m do
 begin
   if length(dyngrid.cells[0, dyngrid.rowcount-1]) > 1 then
    dyngrid.rowcount:= dyngrid.rowcount+1;
   dyngrid.cells[0, dyngrid.rowcount-1]:= 'Test'+inttostr(i);
   if i = 1 then dyngrid.cells[0, dyngrid.rowcount-1]:= dyngrid.cells[0, i-1] + ' Das ist die erste Zeile!';
   if i = m then dyngrid.cells[0, dyngrid.rowcount-1]:= dyngrid.cells[0, i-1] + ' Das ist die letzte Zeile!';
 end;
 stop:= date+time;
 showmessage(format('%f',[(stop-start)*24*60*60]));

 dyngrid.setdrawgrid(@DrawGridDyn);
 DrawGridDyn.Refresh;
end;

procedure TfrmTest.btnladenClick(Sender: TObject);
var datei:string;
    i:integer;
begin
 dyngrid.setdrawgrid(nil); // Grafik ist immer langsam

 datei:= IncludeTrailingPathDelimiter(extractfilepath(application.ExeName))+'Test.txt';
 if dyngrid.loadfromfile(datei, '#Bestand') then
  showmessage('ok ' + dyngrid.cells[0,0])
 else
  showmessage('Fehler');

 dyngrid.setdrawgrid(@DrawGridDyn);
 DrawGridDyn.Refresh;
end;

procedure TfrmTest.btnschreibenClick(Sender: TObject);
var datei:string;
begin
 datei:= IncludeTrailingPathDelimiter(extractfilepath(application.ExeName))+'Test.txt';

 if dyngrid.savetofile(datei, '#Bestand') then
  showmessage('ok')
 else
  showmessage('Fehler');
end;

procedure TfrmTest.btnSpeedClick(Sender: TObject);
var start,stop:TDatetime;
    i:integer;
begin
 start:= date+time;
 for i:= 1 to 1000000 do
 begin
   dyngrid.cells[0,0]:= '0123456789';
 end;
 stop:= date+time;
 showmessage(format('%f',[(stop-start)*24*60*60]));
end;

procedure TfrmTest.btntestenClick(Sender: TObject);
begin
 //
end;

procedure TfrmTest.cbStresstestClick(Sender: TObject);
begin
 Stresstest1.aktiv:= cbStresstest.Checked;
 //Stresstest2.aktiv:= cbStresstest.Checked;
 //Stresstest3.aktiv:= cbStresstest.Checked;
 //Stresstest4.aktiv:= cbStresstest.Checked;
end;

procedure TfrmTest.cbStresstestreadClick(Sender: TObject);
begin
 Stresstest1.doread:= cbStresstestread.Checked;
 Stresstest2.doread:= cbStresstestread.Checked;
 Stresstest3.doread:= cbStresstestread.Checked;
 Stresstest4.doread:= cbStresstestread.Checked;
end;

procedure TfrmTest.cbStresstestwriteClick(Sender: TObject);
begin
 Stresstest1.dowrite:= cbStresstestwrite.Checked;
 Stresstest2.dowrite:= cbStresstestwrite.Checked;
 Stresstest3.dowrite:= cbStresstestwrite.Checked;
 Stresstest4.dowrite:= cbStresstestwrite.Checked;
end;

procedure TfrmTest.DrawGridDynDblClick(Sender: TObject);
begin
 showmessage(dyngrid.cells[dyngrid.col, dyngrid.row]);
end;

procedure TfrmTest.cbStresstestshuffleClick(Sender: TObject);
begin
 Stresstest1.doshuffle:= cbStresstestshuffle.Checked;
 Stresstest2.doshuffle:= cbStresstestshuffle.Checked;
 Stresstest3.doshuffle:= cbStresstestshuffle.Checked;
 Stresstest4.doshuffle:= cbStresstestshuffle.Checked;
end;

end.
