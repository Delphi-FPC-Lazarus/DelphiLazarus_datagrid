{
  Codepages

  Die aktuelle Codepage kann über getacp abgefragt werden

  ACHTUNG:
  TEncoding.GetEncoding() erzeugt immer eine neue Instanz von TEncoding, d.h. die muss auch wieder ordentlich aufgelöst werden
  TEncoding.Unicode .ASCII usw. gibt intern verwaltete Instanzen (Klassenvariablen) zurück, die dürfen "von außen" nicht aufgelöst werden

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
unit unicode_def_unit;

Interface

uses
{$IFNDEF UNIX}Windows, {$ENDIF}
{$IFDEF FPC}LCLIntf, LCLType, LMessages, {$ENDIF}
  Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

const
  CodePage_UTF16 = 1200;
  CodePage_UTF16BE = 1201;
  CodePage_UTF8 = 65001;

  CodePage_ANSI = 1252; // =Default

Implementation

end.
