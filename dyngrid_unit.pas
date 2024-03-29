﻿{$T+}
{
  =============================================
  Kompakte Stringgrid-kompatible Klasse
  für nicht visuelle und visuelle Datenhaltung
  mit Speicher und Ladefunktion für die Griddaten
  in beliebig vielen Instanzen.
  =============================================
  (c) P.Lorenz

  Diese Version arbeitet vollständig im Speicher,
  und ist nur für den Stringgrid-Modus gedacht!

  Hauptfeatures:
  ==============
  - beschränkt sich auf elementare Funktionen
  - höhere Zugriffsgeschwindigkeit
  - gibt Speicher vollständig wieder frei ohne aufgelöst werden zu müssen
  - Speicheraddressierung nicht übermäßig, auch bei ständiger Rowcountänderung
  - automatische Apassung der Speicheradressierungsblockgröße um Datenmengen >2M Recs besser zu verarbeiten
  - Stringgrid änliches Verhalten / Zugriffsmöglichkeit
  - Visualisierungsmöglichkeit ohne zusätzlichen Speicherbedarf
  - echte und visualisierte Spaltenanzahl können sich unterscheiden
  - interne Speicherung als platzsparendes utf8
  - Speichern/laden optional ANSI oder Unicode

  Beschreibung:
  =============
  Colcount sollte nur beim Start gesetzt werden
  und nicht ständig geändert werden da dies nicht
  mit dem gesonderten Handling gesichert ist wie rowcount.

  Das größte Problem das ständiges Ändern von Rowcount
  viel Zeit und Speicher benötigt (liegt an der Addressierung)
  Dieses Problem Dyngrid in dem es Speicher im Vorraus reserviert,
  also die Speicherreservierung nur Blockweise ändere.

  Das DynGrid kann zusätzlich die beinhalteten Daten in einem Drawgrid ausgeben,
  dies kann über die entsprechende Funktion passieren in dem ein Pointer auf ein Drawgrid übergeben wird.
  Wird als Pointer nil übergeben, wird nicht visualisiert.
  In dem Falle können alle Eigenschaften und alle Ereignisse des Drawgrid bis auf onDrawCell frei zugewiesen werden.
  (onDrawCell wird von dieser Komponente bedient und direkt mit Daten aus dem internen Speicher befüllt, Performance relevant)
  Die wichtigsten Eigenschaften vom Drawgrid können direkt über diese Komponente zugegriffen werden, alle anderen vom Drawgrid direkt.

  Intern werden die Daten in UTF8String gehalten um Speicher zu sparen
  Das Speichern kann optional in ANSI oder auch Unicode geschehen,
  beim Laden wird das über die BOM automatisch erkannt.

  Initialisierung:
  grid:= Tdyngrid.create('Gridname', nil);
  grid.colcount:= 5;
  grid.clearlikestringgrid;

  10/2013 XE2 kompatibel
  02/2016 XE10 x64 Test
  xx/xxxx FPC Ubuntu

  --------------------------------------------------------------------
  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at https://mozilla.org/MPL/2.0/.

  THE SOFTWARE IS PROVIDED "AS IS" AND WITHOUT WARRANTY

  Author: Peter Lorenz
  Is that code useful for you? Donate!
  Paypal webmaster@peter-ebe.de
  --------------------------------------------------------------------

}

{$I ..\share_settings.inc}
unit dyngrid_unit;

interface

uses
{$IFNDEF FPC}System.UITypes, {$ENDIF}
{$IFNDEF UNIX}Windows, {$ENDIF}
{$IFDEF FPC}LCLIntf, LCLType, LMessages, {$ENDIF}
  TextFile_unit,
  Classes, SyncObjs, SysUtils,
  grids, graphics, dialogs;

// ----------------------------------------------------------------------------

const
  dyngrid_trenner: char = {$IFDEF FPC}#161{$ELSE}'¡'{$ENDIF};
  dyngrid_subtrenner: char = {$IFDEF FPC}#191{$ELSE}'¿'{$ENDIF};

  dyngrid_colinf_maxsubcol = 49;
  dyngrid_colinf_maxcol = 9;
  dyngrid_defaultsubcolwidth = 45;
  dyngrid_subcolgap = 5;

  lf: char = #10;
  cr: char = #13;

type
  TDyngridDatatype = UTF8String;

type
  PDrawgrid = ^TDrawgrid;

type
  rowdata = array of TDyngridDatatype;

type
  coldata = array of rowdata;

  colsubcols = array [0 .. dyngrid_colinf_maxsubcol] of integer;

  colinf = record
    cols: array [0 .. dyngrid_colinf_maxcol] of colsubcols;
  end;

type
  TdynGrid = class(TObject)
  private
    fcs_FileIO: SyncObjs.TCriticalSection;
    fcs_Graphic: SyncObjs.TCriticalSection;
    fcs_Base: SyncObjs.TCriticalSection;

    { Bezeichnung }
    fdebugname: string;

    { Datenarray }
    fdaten: coldata;

    fdatamemblockcurrent: integer;
    fmrc: integer; { memory rowcount (speicherreservierung) }
    ferc: integer; { extern rowcount (rückgabe) }

    fccinvis: integer; { anzahl der nicht visualisierten Spalten }

    { Visualisierung }
    fhlrow: integer;

    fdrawgrid: PDrawgrid;
    fdrawgrid_autorepaint: boolean;
    fdrawgrid_columnsubmode: boolean;
    fdrawgrid_columnsubseparator: string;
    fdrawgrid_columnsubinf: colinf;

    procedure drawgrid_OnDrawCell(Sender: TObject; ACol, ARow: integer;
      Rect: TRect; State: TGridDrawState);
    procedure drawgrid_setup;
    procedure drawgrid_repaint(aktrow: integer);

    procedure adjustdatamemblocksize(datacount: integer);

    { interne Zugriffsfunktionen für Property's }
    function getinvisiblecols: integer;
    procedure setinvisiblecols(wert: integer);

    function getcolcount: integer;
    procedure setcolcount(wert: integer);

    function getrowcount: integer;
    procedure setrowcount(wert: integer);

    function getcellRaw(c, r: integer): TDyngridDatatype;

    function getcell(c, r: integer): string;
    procedure setcell(c, r: integer; const strdaten: string);

    procedure setdrawgridautorepaint(wert: boolean);
    function getdrawgridautorepaint: boolean;

    procedure setdrawgridcolumnsubmode(wert: boolean);
    function getdrawgridcolumnsubmode: boolean;

    procedure setdrawgridcolumnsubseparator(wert: string);
    function getdrawgridcolumnsubseparator: string;

    function getdrawgridcolumnsubinf: colinf;
    procedure setdrawgridcolumnsubinf(wert: colinf);

    function getrow: integer;
    procedure setrow(wert: integer);

    function getcol: integer;
    procedure setcol(wert: integer);

    function gethighlightrow: integer;
    procedure sethighlightrow(wert: integer);

    function util_zeichenfilter(strdaten: string): string;
  public
    { Public-Deklarationen }

    { --- folgendes ist nur für Debug-Zwecke --- }
    function getmrc: integer;

    { --- folgendes ist für den normalen Betrieb --- }
    constructor Create(const setdebugname: string; setdrawgrid: PDrawgrid);
    destructor Destroy; override;

    procedure setdrawgrid(setdrawgrid: PDrawgrid);

    procedure clearall;
    procedure clearlikestringgrid;

    function indexofCIS(ssearchkey: string; col: integer): integer;

    property invisiblecols: integer read getinvisiblecols
      write setinvisiblecols;
    property colcount: integer read getcolcount write setcolcount;
    property rowcount: integer read getrowcount write setrowcount;

    property highlightrow: integer read gethighlightrow write sethighlightrow;

    property cells[col, row: integer]: string read getcell write setcell;
    property cellsRaw[col, row: integer]: TDyngridDatatype read getcellRaw;

    property drawgridautorepaint: boolean read getdrawgridautorepaint
      write setdrawgridautorepaint;
    property drawgrid_columnsubmode: boolean read getdrawgridcolumnsubmode
      write setdrawgridcolumnsubmode;
    property drawgrid_columnsubseparator: string
      read getdrawgridcolumnsubseparator write setdrawgridcolumnsubseparator;
    property drawgrid_columnsubinf: colinf read getdrawgridcolumnsubinf
      write setdrawgridcolumnsubinf;

    property row: integer read getrow write setrow;
    property col: integer read getcol write setcol;

    { --- folgendes ist für das laden und Speichern der Daten --- }
    function checkfileidentifier(const datei: string;
      identifier: string): boolean;
    // autodetect BOM
    function loadfromfile(const datei: string;
      optionalidentifier: string): boolean;
    // autodetect BOM
    function savetofile(const datei: string;
      optionalidentifier: string): boolean;
    // DynGrid Encoding mit BOM

    { --- folgendes ist als sonderfunktion freigegeben --- }
  end;

type
  PdynGrid = ^TdynGrid;

  // ----------------------------------------------------------------------------

resourcestring
  rssource = 'Quelle:';
  rsmissingidentifier =
    'int Fehler: checkfileidentifier: identifier muss übergeben werden!';
  rsfilenotfound = 'Datei %s existiert nicht!';
  rsfilenotmatch = 'Datei ist keine %s Datei!';
  rsminzero = 'Wert unterschreitet 0!';
  rsnorowdata = 'Keine Rows vorhanden da Colcount 0!';
  rsrangeerror = 'Außerhalb Bereich';

implementation

// ----------------------------------------------------------------------------

const
  datamemblockdefault = 10000; // Vorgabewert (besser zu groß als zu klein)

  // ----------------------------------------------------------------------------
  // constructor/destructor -----------------------------------------------------

constructor TdynGrid.Create(const setdebugname: string; setdrawgrid: PDrawgrid);
begin
  inherited Create; { constructor von TObject aufrufen }
  fdatamemblockcurrent := datamemblockdefault;

  fcs_FileIO := SyncObjs.TCriticalSection.Create;
  fcs_Graphic := SyncObjs.TCriticalSection.Create;
  fcs_Base := SyncObjs.TCriticalSection.Create;

  fdebugname := setdebugname; { Namen merken }

  clearall; { clear }

  fdrawgrid := setdrawgrid; { Gridpointer merken }
  fdrawgrid_autorepaint := false;
  fdrawgrid_columnsubmode := false;
  fdrawgrid_columnsubseparator := ',';

  if Assigned(fdrawgrid) then { ggf. Grid Drawcell zuweisen }
  begin
    fdrawgrid.OnDrawcell := drawgrid_OnDrawCell;

    { ggf. Ausgabegrid mit ändern }
    drawgrid_setup; // eigene Threadsicherung
  end;
end;

destructor TdynGrid.Destroy;
begin
  FreeAndNil(fcs_FileIO);
  FreeAndNil(fcs_Graphic);
  FreeAndNil(fcs_Base);

  inherited Destroy; { destuctor von TObject aufrufen }
end;

// ----------------------------------------------------------------------------
// load/save ------------------------------------------------------------------

function TdynGrid.checkfileidentifier(const datei: string;
  identifier: string): boolean;
var
  frtext: TTextFileReader;
  zeile: string;
begin
  { Datei testen (identifier) }
  Result := false;

  identifier := uppercase(trim(identifier));
  if length(identifier) = 0 then
  begin
    MessageDlg(rsmissingidentifier, mtwarning, [mbok], 0);
    exit
  end;

  if not fileexists(datei) then
  begin
    MessageDlg(format(rsfilenotfound, [datei]), mtwarning, [mbok], 0);
    exit;
  end;

  frtext := nil;
  try
    frtext := TTextFileReader.Create(datei);
    zeile := frtext.ReadLine;
    FreeAndNil(frtext);

    if uppercase(trim(identifier)) = uppercase(trim(zeile)) then
      Result := true
    else
      MessageDlg(format(rsfilenotmatch, [datei]), mtwarning, [mbok], 0);

  except
    on e: exception do
    begin
      try
        FreeAndNil(frtext);
      except
        on e: exception do
        begin { nix } end;
      end;
      MessageDlg('TdynGrid: checkfileidentifier(): ' + e.message + #10#13 +
        rssource + fdebugname, mtwarning, [mbok], 0);
    end;
  end;
end;

function TdynGrid.loadfromfile(const datei: string;
  optionalidentifier: string): boolean;

  function int_loadfromfile(var error: string): boolean;
  var
    frtext: TTextFileReader;
    i, c, dr: integer;
    zeile, tmpstr: string;
    ctmp: char;
    bEndOfFile: boolean;
  begin
    Result := false;
    error := '';

    frtext := nil;
    try
      frtext := TTextFileReader.Create(datei);

      if length(optionalidentifier) > 0 then
      begin
        zeile := frtext.ReadLine;

        if uppercase(trim(optionalidentifier)) <> uppercase(trim(zeile)) then
        begin
          FreeAndNil(frtext);
          MessageDlg(format(rsfilenotmatch, [datei]), mtwarning, [mbok], 0);
          exit;
        end;
      end;

      // Löschen, wichtig!
      clearlikestringgrid;

      // Einlesen
      dr := -1; { da incrementiert, so wird bei 0 begonnen }
      repeat
        ;
        zeile := frtext.ReadLine;

        if length(zeile) > 0 then
        begin
          inc(dr); { nächste Ziele }
          if dr > rowcount - 1 then
            rowcount := dr + 1;

          { einlesen }
          if zeile[length(zeile)] <> dyngrid_trenner then
            zeile := zeile + dyngrid_trenner;
          c := 0;
          tmpstr := '';
          for i := 1 to length(zeile) do
            if zeile[i] = dyngrid_trenner then
            begin
              if c <= colcount - 1 then
              begin
                cells[c, dr] := tmpstr;
                inc(c);
                tmpstr := '';
              end;
            end
            else
              tmpstr := tmpstr + zeile[i];
        end;

        bEndOfFile := frtext.EndOfFile;

      until bEndOfFile;

      FreeAndNil(frtext);

      Result := true;
    except
      on e: exception do
      begin
        error := 'TdynGrid: loadfromfile(): ' + e.message + #10#13 + rssource +
          fdebugname;
        try
          FreeAndNil(frtext);
        except
          on e: exception do
          begin { nix } end;
        end;
      end;
    end;

  end;

var
  error: string;
begin
  Result := false;
  try
    fcs_FileIO.Enter;

    { grid aus Datei laden }
    optionalidentifier := uppercase(trim(optionalidentifier));

    if not fileexists(datei) then
    begin
      MessageDlg(format(rsfilenotfound, [datei]), mtwarning, [mbok], 0);
      exit;
    end;

    // hier kein adjustdatamemblocksize() da sowieso unbekannt wie viele Daten kommen
    // adjustdatamemblocksize() wird automatisch von setrowcount() gemacht

    if int_loadfromfile(error) then
    begin
      Result := true;
    end
    else
    begin
      MessageDlg(error, mtwarning, [mbok], 0);
    end;

  finally
    fcs_FileIO.Leave;
  end;

end;

function TdynGrid.savetofile(const datei: string;
  optionalidentifier: string): boolean;
var
  fwtext: TTextFileWriter;
  r, c: integer;
  zeile: string;

  tmpstr: string;
  i: integer;
begin
  Result := false;
  try
    fcs_FileIO.Enter;

    { grid in Datei sichern }
    optionalidentifier := uppercase(trim(optionalidentifier));
    try
      fwtext := TTextFileWriter.Create(datei, false);

      if length(optionalidentifier) > 0 then
        fwtext.WriteLine(optionalidentifier);

      for r := 1 to rowcount do
      begin
        zeile := '';
        for c := 1 to colcount do
        begin
          tmpstr := cells[c - 1, r - 1];

          // Steuerzeichen filtern, beim Speichern muss es spätestens sein
          tmpstr := util_zeichenfilter(tmpstr);

          for i := 1 to length(tmpstr) do
            if tmpstr[i] = dyngrid_trenner then
              tmpstr[i] := ' ';
          zeile := zeile + tmpstr + dyngrid_trenner;
        end;
        fwtext.WriteLine(zeile);
      end;

      FreeAndNil(fwtext);

      Result := true;
    except
      on e: exception do
      begin
        try
          FreeAndNil(fwtext);
        except
          on e: exception do
          begin { nix } end;
        end;
        MessageDlg('TdynGrid: savetofile(): ' + e.message + #10#13 + rssource +
          fdebugname, mtwarning, [mbok], 0);
      end;
    end;
  finally
    fcs_FileIO.Leave;
  end;
end;

// ----------------------------------------------------------------------------
// clear ----------------------------------------------------------------------

procedure TdynGrid.clearall;
begin
  try
    fcs_Base.Enter;

    // speicherreservierung erst einmal zurück auf vorgabe
    fdatamemblockcurrent := datamemblockdefault;

    { alle Cols (damit auch alle Rows) löschen }
    setlength(fdaten, 0);
    fmrc := 0;
    ferc := 0;
    // ccinvis und colcount nicht
    fhlrow := -1;
  finally
    fcs_Base.Leave;
  end;
end;

procedure TdynGrid.clearlikestringgrid;
var
  cc: integer;
begin
  { alle Rows löschen (Cols bleiben erhalten mit Rowcount 0) }

  cc := colcount; { merken }

  clearall; { Speicher freigeben - eigene Threadsicherung }

  setcolcount(cc); { Spaltenanzahl wiederherstellen - eigene Threadsicherung }
  setrowcount(1); { Zeilenanzahl auf 1 setzen - eigene Threadsicherung }
end;

// ----------------------------------------------------------------------------
// suchfunktion ---------------------------------------------------------------

function TdynGrid.indexofCIS(ssearchkey: string; col: integer): integer;
var
  r: integer;
  lsearch: integer;
begin
  Result := -1;
  if rowcount < 1 then
    exit;
  ssearchkey := lowercase(ssearchkey); { einmal vorab }
  lsearch := length(ssearchkey); { einmal vorab }

  { Findefunktion für Eintrage
    Diese Funktion ist um einiges schneller als Funktionen von außen
    da der direkte Zuriff auf das Datenarray schneller ist
    als der Zugriff über die Propperty .cells[]
  }

  { Wichtig, kein lowercase über die ganzen daten!
    Die Daten dürfen nicht verändert werden!

    Wegen der Performance
    - vorbereiten soweit möglich
    - ersteinmal length() checken, dann lowercase() vergleichen
  }
  for r := 1 to rowcount do
    if length(String(fdaten[col][r - 1])) = lsearch
    then { lsucheintrag vorab vorbereitet }
      if lowercase(String(fdaten[col][r - 1])) = ssearchkey
      then { lsucheintrag vorab vorbereitet }
      begin
        Result := r - 1;
        exit;
      end;

  { nicht gefunden }
end;

// ----------------------------------------------------------------------------
// drawgrid -------------------------------------------------------------------

procedure TdynGrid.drawgrid_OnDrawCell(Sender: TObject; ACol, ARow: integer;
  Rect: TRect; State: TGridDrawState);
var
  inhalt: string;
  x, xinc, y: integer;
  iSrc, iSubfield: integer;
  arinhalt: array [0 .. dyngrid_colinf_maxsubcol] of string;
  subRect: TRect;
begin
  { Visualisierung: Ausgabe
    Hier muss alles generisch bzw. über properties gesteuert abgehandelt werden

    Alternative wäre ein externes draw event zu schmeißen das von der Anwendung bedient wird,
    in dem Falle müssten aber zwingend neben col, row, drarect auch die Daten mitgegeben werden um die Performance zu erhalten!
  }
  if Sender = nil then
    exit;

  // try
  // KEINE Critical Section da OnDrawCell von ProgrammThread aufgerufen wird

  if (high(fdaten) >= (ACol - fccinvis)) and (ACol >= 0) and
    (ACol <= Pred(colcount) - fccinvis) then
  begin
    if (high(fdaten[ACol]) >= ARow) and (ARow >= 0) and (ARow <= Pred(rowcount))
    then
    begin
      inhalt := String(fdaten[ACol][ARow]);
      if length(inhalt) > 0 then
      begin
        // direkt aus den Daten, performancerelevant
        if (fdrawgrid_columnsubmode = false) or
          (StrPos(pchar(inhalt), pchar(dyngrid_subtrenner)) = nil) then
        begin
          { Einfache Ausgabe }
          x := Rect.left + 2;
          y := Rect.Top + round((Rect.bottom - Rect.Top) / 2 - TDrawgrid(Sender)
            .Canvas.TextHeight(inhalt) / 2);
          if ARow = fhlrow then
          begin
            { diesen Eintrag hervorheben in dem die Eigenschaft fsbold getoggelt wird
              ACHTUNG: .canvas.font weicht von .font ab (z.B. bei aktuellen Eintrag)
            }
            if fsbold in TDrawgrid(Sender).Canvas.font.Style then
              TDrawgrid(Sender).Canvas.font.Style := []
            else
              TDrawgrid(Sender).Canvas.font.Style := TDrawgrid(Sender)
                .Canvas.font.Style + [fsbold]
          end;
          { ausgeben }
          inhalt := StringReplace(inhalt, dyngrid_subtrenner,
            fdrawgrid_columnsubseparator, [rfReplaceAll]);
          TDrawgrid(Sender).Canvas.TextOut(x, y, inhalt);
        end
        else
        begin
          { SubSpalten Ausgabe }
          for iSubfield := Low(arinhalt) to High(arinhalt) do
          begin
            arinhalt[iSubfield] := '';
          end;
          iSubfield := low(arinhalt);
          for iSrc := 1 to length(inhalt) do
          begin
            if (inhalt[iSrc] = dyngrid_subtrenner) then
              inc(iSubfield)
            else
              arinhalt[iSubfield] := arinhalt[iSubfield] + inhalt[iSrc];
            if iSubfield > high(arinhalt) then
              break;
          end;

          x := Rect.left + 2;
          y := Rect.Top + round((Rect.bottom - Rect.Top) / 2 - TDrawgrid(Sender)
            .Canvas.TextHeight(inhalt) / 2);

          for iSubfield := Low(arinhalt) to High(arinhalt) do
          begin
            if (ACol >= low(fdrawgrid_columnsubinf.cols)) and
              (ACol <= high(fdrawgrid_columnsubinf.cols)) and
              (iSubfield >= low(fdrawgrid_columnsubinf.cols[ACol])) and
              (iSubfield <= high(fdrawgrid_columnsubinf.cols[ACol])) then
              xinc := fdrawgrid_columnsubinf.cols[ACol, iSubfield]
            else
              xinc := dyngrid_defaultsubcolwidth;

            if length(arinhalt[iSubfield]) > 0 then
            begin
              // Rect.Left:= x;
              // TDrawgrid(Sender).Canvas.FillRect(Rect);
              // TDrawgrid(Sender).Canvas.TextOut(x+dyngrid_subcolgap, y, arinhalt[iSubfield]);
              subRect := Rect;
              subRect.left := x;
              subRect.Right := x + xinc;
              TDrawgrid(Sender).Canvas.TextRect(subRect, x + dyngrid_subcolgap,
                y, arinhalt[iSubfield]);
            end;
            inc(x, xinc + dyngrid_subcolgap);
          end;
        end;

      end; // Inhalt vorhanden
    end; // Zeile gültig
  end; // Spalte gültig

  // finally
  //
  // end

end;

procedure TdynGrid.drawgrid_setup;
begin
  { Visualisierung: Colcount/Rowcount setzen wenn geändert }
  if not Assigned(fdrawgrid) then
    exit;

  if (fdrawgrid.rowcount <> rowcount) or
    (fdrawgrid.colcount <> colcount - fccinvis) then
  begin
    try
      fcs_Graphic.Enter;

      fdrawgrid.rowcount := rowcount;
      fdrawgrid.colcount := colcount - fccinvis;
      { Spaltenanzahl - nicht zu visualisierende Spalten }
    finally
      fcs_Graphic.Leave;
    end;
  end;
end;

procedure TdynGrid.drawgrid_repaint(aktrow: integer);
begin
  { Visualisierung: neu zeichnen }
  if not Assigned(fdrawgrid) then
    exit;
  if fdrawgrid_autorepaint = false then
    exit;

  try
    fcs_Graphic.Enter;

    { Repaint nur wenn übergebene (geänderte) Zelle im sichtbaren Bereich liegt }
    if ((aktrow >= fdrawgrid.TopRow) and (aktrow <= fdrawgrid.TopRow +
      fdrawgrid.VisibleRowCount)) or (aktrow < 0) then
      fdrawgrid.Invalidate; // .repaint;
  finally
    fcs_Graphic.Leave;
  end;
end;

// ----------------------------------------------------------------------------
// getter/setter --------------------------------------------------------------

function TdynGrid.getinvisiblecols: integer;
begin
  { invisible Cols lesen }
  Result := fccinvis;
end;

procedure TdynGrid.setinvisiblecols(wert: integer);
begin
  { invisible Cols setzen }
  fccinvis := wert;

  { ggf. Ausgabegrid mit ändern }
  drawgrid_setup; // eigene Threadsicherung
end;

function TdynGrid.getcolcount: integer;
begin
  { Colcount lesen }
  Result := high(fdaten) + 1;
end;

procedure TdynGrid.setcolcount(wert: integer);
var
  i: integer;
  c, csub: integer;
begin
  { Colcount setzen (Rowcount für neue Spalten anpassen) }
  if wert < 0 then
  begin
    MessageDlg('TdynGrid: setcolcount(): ' + rsminzero + #10#13 + rssource +
      fdebugname, mtwarning, [mbok], 0);
    exit;
  end;
  if wert = colcount then
    exit;

  try
    fcs_Base.Enter;

    setlength(fdaten, wert);
    { wenn cols vorhanden (könnte ja 0 gesetzt worden sein) }
    if high(fdaten) > -1 then
    begin
      for i := low(fdaten) to high(fdaten) do
        setlength(fdaten[i], fmrc);
    end;

  finally
    fcs_Base.Leave;
  end;

  { ggf. Ausgabegrid mit ändern }
  drawgrid_setup; // eigene Threadsicherung
end;

function TdynGrid.getrowcount: integer;
begin
  { Rowcount lesen }
  if high(fdaten) < 0 then
    Result := 0
  else
    Result := ferc;
end;

function TdynGrid.getmrc: integer;
begin
  { int. reservierten Speicher lesen }
  Result := fmrc;
end;

procedure TdynGrid.adjustdatamemblocksize(datacount: integer);
var
  datamemblocknew: integer;
begin
  // ggf. datenblockreservierung dyn. anpassen je Datenmenge bereits gespeichert und zu laden
  // sonst steigt der benötigte Speicher durch die ständige Anpassung des dyn. Arrays unnötig stark an
  datamemblocknew := datamemblockdefault;
  if datacount > datamemblockdefault * 5 then
    datamemblocknew := datamemblockdefault * 5;
  if datacount > datamemblockdefault * 10 then
    datamemblocknew := datamemblockdefault * 10;
  if datacount > datamemblockdefault * 50 then
    datamemblocknew := datamemblockdefault * 50;
  if datacount > datamemblockdefault * 100 then
    datamemblocknew := datamemblockdefault * 100;
  if datamemblocknew > 1000000 then
    datamemblocknew := 1000000;
  // max blockgröße für speichererweiterung (ist natürlich nicht max speichergröße)

  // wichtig: hier nur erhöhen, zurückgesetzt wird sie nur beim clear
  if datamemblocknew > fdatamemblockcurrent then
    fdatamemblockcurrent := datamemblocknew;
end;

procedure TdynGrid.setrowcount(wert: integer);
var
  i: integer;
  mrcneu: integer;
begin
  { Rowcount setzen (für alle Spalten) }
  if wert < 0 then
  begin
    MessageDlg('TdynGrid: setrowcount(): ' + rsminzero + #10#13 + rssource +
      fdebugname, mtwarning, [mbok], 0);
    exit;
  end;
  if wert = ferc then
    exit;

  { Wert merken (Rowcount nach außen) }
  ferc := wert;

  { hier aufgrund dem gesetztem rowcount die Blockgröße einstellen,
    d.h. die blockgröße steigt mit Anzahl der Daten }
  adjustdatamemblocksize(wert);

  { MRC (=int. reservierter Speicher) ermitteln }
  mrcneu := 0;
  while mrcneu < wert do
    mrcneu := mrcneu + fdatamemblockcurrent;

  if fmrc <> mrcneu then // nur wenn sich die speicherzuordnung geändert hat
  begin
    try
      fcs_Base.Enter;

      { Ändern der Speicherreservierung }
      fmrc := mrcneu;
      if high(fdaten) > -1 then { wenn cols vorhanden }
      begin
        for i := low(fdaten) to high(fdaten) do
          setlength(fdaten[i], fmrc);
      end
      else
      begin
        MessageDlg('TdynGrid: setrowcount(): ' + rsnorowdata + #10#13 + rssource
          + fdebugname, mtwarning, [mbok], 0);
        exit;
      end;
    finally
      fcs_Base.Leave;
    end;
  end;

  { ggf. Ausgabegrid mit ändern }
  drawgrid_setup; // eigene Threadsicherung
end;

function TdynGrid.getcellRaw(c, r: integer): TDyngridDatatype;
begin
  { Datenzelle lesen }
  Result := '';
  if (c < low(fdaten)) or (c > high(fdaten)) then
  begin
    MessageDlg('TdynGrid: getcell: c (' + inttostr(c) + ') ' + rsrangeerror +
      #10#13 + rssource + fdebugname, mtwarning, [mbok], 0);
    exit;
  end;
  if (r < low(fdaten[c])) or (r > ferc - 1) then
  begin
    MessageDlg('TdynGrid: getcell: r (' + inttostr(r) + ') ' + rsrangeerror +
      #10#13 + rssource + fdebugname, mtwarning, [mbok], 0);
    exit;
  end;
  Result := fdaten[c][r];
end;

function TdynGrid.getcell(c, r: integer): string;
begin
  { Datenzelle lesen }
  Result := '';
  if (c < low(fdaten)) or (c > high(fdaten)) then
  begin
    MessageDlg('TdynGrid: getcell: c (' + inttostr(c) + ') ' + rsrangeerror +
      #10#13 + rssource + fdebugname, mtwarning, [mbok], 0);
    exit;
  end;
  if (r < low(fdaten[c])) or (r > ferc - 1) then
  begin
    MessageDlg('TdynGrid: getcell: r (' + inttostr(r) + ') ' + rsrangeerror +
      #10#13 + rssource + fdebugname, mtwarning, [mbok], 0);
    exit;
  end;
  Result := String(fdaten[c][r]);
end;

procedure TdynGrid.setcell(c, r: integer; const strdaten: string);
begin
  { Datenzelle schreiben }
  if (c < low(fdaten)) or (c > high(fdaten)) then
  begin
    MessageDlg('TdynGrid: setcell: c (' + inttostr(c) + ') ' + rsrangeerror +
      #10#13 + rssource + fdebugname, mtwarning, [mbok], 0);
    exit;
  end;
  if (r < low(fdaten[c])) or (r > ferc - 1) then
  begin
    MessageDlg('TdynGrid: setcell: r (' + inttostr(r) + ') ' + rsrangeerror +
      #10#13 + rssource + fdebugname, mtwarning, [mbok], 0);
    exit;
  end;

  try
    fcs_Base.Enter;

    // Steuerzeichen hier nicht filtern, da Steuerzeichen im "verwendbaren" Zeichnbeereich
    // strdaten:= util_zeichenfilter(strdaten);

    { einfügen ins grid }
    fdaten[c][r] := TDyngridDatatype(strdaten);

  finally
    fcs_Base.Leave;
  end;

  { ggf. neu zeichnen (nur wenn Ändrung im sichtbaren Breich liegt) }
  drawgrid_repaint(r);
end;

function TdynGrid.util_zeichenfilter(strdaten: string): string;
var
  i: integer;
begin
  Result := strdaten;

  { Steuerzeichen filtern und daten einfügen }
  for i := 1 to length(strdaten) do
  begin
    if (strdaten[i] = dyngrid_trenner) or (strdaten[i] = lf) or
      (strdaten[i] = cr) then
      strdaten[i] := ' ';
  end;

  Result := strdaten;
end;

function TdynGrid.gethighlightrow: integer;
begin
  Result := fhlrow;
end;

procedure TdynGrid.sethighlightrow(wert: integer);
begin
  fhlrow := wert;

  { ggf. neu zeichnen (nur wenn Ändrung im sichtbaren Breich liegt) }
  drawgrid_repaint(wert);
end;

function TdynGrid.getdrawgridautorepaint: boolean;
begin
  Result := fdrawgrid_autorepaint;
end;

procedure TdynGrid.setdrawgridautorepaint(wert: boolean);
begin
  fdrawgrid_autorepaint := wert;
end;

function TdynGrid.getdrawgridcolumnsubmode: boolean;
begin
  Result := fdrawgrid_columnsubmode;
end;

procedure TdynGrid.setdrawgridcolumnsubmode(wert: boolean);
begin
  fdrawgrid_columnsubmode := wert;
end;

function TdynGrid.getdrawgridcolumnsubseparator: string;
begin
  Result := fdrawgrid_columnsubseparator;
end;

procedure TdynGrid.setdrawgridcolumnsubseparator(wert: string);
begin
  fdrawgrid_columnsubseparator := wert;
end;

function TdynGrid.getdrawgridcolumnsubinf: colinf;
begin
  Result := fdrawgrid_columnsubinf;
end;

procedure TdynGrid.setdrawgridcolumnsubinf(wert: colinf);
begin
  fdrawgrid_columnsubinf := wert;
end;

procedure TdynGrid.setdrawgrid(setdrawgrid: PDrawgrid);
begin
  if Assigned(fdrawgrid) then
    fdrawgrid.OnDrawcell := nil;

  fdrawgrid := setdrawgrid; { Gridpointer merken }
  if Assigned(fdrawgrid) then { ggf. Grid Drawcell zuweisen }
  begin
    fdrawgrid.OnDrawcell := drawgrid_OnDrawCell;

    { ggf. Ausgabegrid mit ändern }
    drawgrid_setup; // eigene Threadsicherung
  end;
end;

function TdynGrid.getrow: integer;
begin
  { Visualisierung: row holen }
  Result := -1;
  if not Assigned(fdrawgrid) then
    exit;
  Result := fdrawgrid.row;
end;

procedure TdynGrid.setrow(wert: integer);
begin
  { Visualisierung: row setzen }
  if not Assigned(fdrawgrid) then
    exit;
  fdrawgrid.row := wert;
end;

function TdynGrid.getcol: integer;
begin
  { Visualisierung: col holen }
  Result := -1;
  if not Assigned(fdrawgrid) then
    exit;
  Result := fdrawgrid.col;
end;

procedure TdynGrid.setcol(wert: integer);
begin
  { Visualisierung: col setzen }
  if not Assigned(fdrawgrid) then
    exit;
  fdrawgrid.col := wert;
end;

// ----------------------------------------------------------------------------

end.
