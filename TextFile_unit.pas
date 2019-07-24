{
  Ersatzklasse für Streamreader/Streamwriter
  zum Schreiben/Lesen von UTF8 Textdateien

  Streamreader hat beim Laden einen riesen Nachteil:
  Wenn die Datei irgendwo beschädigt ist, also ein nicht utf8 decodebares Zeichen beinhaltet ist die ganze datei überhaupt nicht mehr lesbar.
  Beim Assignfile mit Codepage und realn ist die Datei lesbar, das nicht lesbare Zeichen wir durch das dafür reservierte Unicode Zeichen ersetzt.

  Reservierte Unicodezeichen
  ( https://en.wikipedia.org/wiki/Specials_%28Unicode_block%29 )
  werden  eingelesen und verarbeitet wie normale Unicodezeichen,
  U+FFFD ist aber als Ersatzeichen für unlesbare Zeichen vorgesehen und löst im Streamreader einen Fehler aus was an sich nicht falsch ist,
  aber ich kann diesen Fehler nicht behandeln und das Laden fortsetzen.

  Je nach dem was man in der Datei erfasst, ist das Mist weil z.B. das Dateisystem dieses Zeichen in Datei und Verzeichnisnamen erlaubt.
  Das kann auch bei Encodingfehlern / fehlerhaft eingebundene Netzlaufwerke passieren.

  Achtung:
  unter Delphi schreibt TextFile ANSI wenn kein Encoding angegeben wurde
  unter FPC schreibt TextFile generell UTF8 (ohne BOM), ein Encoding kann nicht angegeben werden

  xx/xxxx XE10
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

unit TextFile_unit;

interface

uses
{$IFNDEF FPC}System.UITypes, {$ENDIF}
{$IFNDEF UNIX}Windows, {$ENDIF}
{$IFDEF FPC}LCLIntf, LCLType, LMessages, {$ENDIF}
  Classes, SysUtils, graphics, dialogs;

type
  TTextFileBase = class(TObject)
  protected
{$IFNDEF FPC}
    function getEncodingCodePage: Integer;
    function getEncodingBOM: char;
{$ENDIF}
  end;

type
  TTextFileReader = class(TTextFileBase)
  private
    frtext: TextFile;
    fopen: Boolean;
  public
    function ReadLine: String;
    function EndOfFile: Boolean;

    constructor Create(filename: string);
    destructor Destroy; override;
  end;

type
  TTextFileWriter = class(TTextFileBase)
  private
    fwtext: TextFile;
    fopen: Boolean;
  public
    constructor Create(filename: string; appendfile: Boolean);
    destructor Destroy; override;

    procedure WriteLine(s: string);
  end;

resourcestring
  rsfilecoodingerror =
    'Datei %s hat eine falsche Zeichenkodierung und kann daher nicht geladen werden!';

implementation

uses unicode_def_unit;

// ----------------------------------------------------------------------
// BASE

{$IFNDEF FPC}

function TTextFileBase.getEncodingCodePage: Integer;
begin
  // Alle Schreib-/Lese Funktionen verwenden diese Codepage
  Result := CodePage_UTF8;
end;

function TTextFileBase.getEncodingBOM: char;
begin
  // Alle Schreib-/Lese Funktionen verwenden diese BOM
  Result := #$FEFF; // EFBBBF in der Datei
end;
{$ENDIF}
// ----------------------------------------------------------------------
// Reader

constructor TTextFileReader.Create(filename: string);
{$IFNDEF FPC}
var
  ctmp: char;
{$ENDIF}
begin
  inherited Create;

  fopen := false;
  AssignFile(frtext, filename{$IFNDEF FPC}, getEncodingCodePage{$ENDIF});
  Reset(frtext);
  fopen := true;
{$IFNDEF FPC}
  Read(frtext, ctmp);
  // 3 Byte URF8-Bom ist ein UTF8 Zeichen ( EF BB BF  1110xxxx 10xxxxxx 10xxxxxx )
  if ctmp <> getEncodingBOM then
  begin
    raise Exception.Create(format(rsfilecoodingerror, [filename]));
  end;
{$ENDIF}
end;

function TTextFileReader.ReadLine: String;
begin
  Readln(frtext, Result);
end;

function TTextFileReader.EndOfFile: Boolean;
begin
  Result := Eof(frtext);
end;

destructor TTextFileReader.Destroy;
begin
  if fopen then
    CloseFile(frtext);
  fopen := false;

  inherited Destroy;
end;

// ----------------------------------------------------------------------
// Writer

constructor TTextFileWriter.Create(filename: string; appendfile: Boolean);
begin
  inherited Create;

  fopen := false;
  AssignFile(fwtext, filename{$IFNDEF FPC}, getEncodingCodePage{$ENDIF});
  if appendfile then
  begin
    Append(fwtext)
  end
  else
  begin
    Rewrite(fwtext);
{$IFNDEF FPC}
    write(fwtext, getEncodingBOM);
{$ENDIF}
  end;
  fopen := true;
end;

destructor TTextFileWriter.Destroy;
begin
  if fopen then
    CloseFile(fwtext);
  fopen := false;

  inherited Destroy;
end;

procedure TTextFileWriter.WriteLine(s: string);
begin
  writeln(fwtext, s);
end;

// ----------------------------------------------------------------------

end.
