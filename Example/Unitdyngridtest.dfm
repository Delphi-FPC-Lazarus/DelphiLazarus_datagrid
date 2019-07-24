object frmTest: TfrmTest
  Left = 0
  Top = 0
  Caption = 'frmTest'
  ClientHeight = 551
  ClientWidth = 876
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object DrawGridDyn: TDrawGrid
    Left = 27
    Top = 79
    Width = 830
    Height = 250
    ColCount = 1
    DefaultColWidth = 350
    FixedCols = 0
    RowCount = 1
    FixedRows = 0
    TabOrder = 1
    ColWidths = (
      350)
    RowHeights = (
      24)
  end
  object btndynfuellen: TButton
    Left = 27
    Top = 17
    Width = 75
    Height = 25
    Caption = 'btndynfuellen'
    TabOrder = 0
    OnClick = btndynfuellenClick
  end
  object btnladen: TButton
    Left = 27
    Top = 428
    Width = 75
    Height = 25
    Caption = 'btnladen'
    TabOrder = 2
    OnClick = btnladenClick
  end
  object btnschreiben: TButton
    Left = 27
    Top = 335
    Width = 75
    Height = 25
    Caption = 'btnschreiben'
    TabOrder = 3
    OnClick = btnschreibenClick
  end
  object btntesten: TButton
    Left = 27
    Top = 397
    Width = 75
    Height = 25
    Caption = 'btntesten'
    TabOrder = 4
    OnClick = btntestenClick
  end
  object btnSpeed: TButton
    Left = 257
    Top = 440
    Width = 75
    Height = 25
    Caption = 'btnSpeed'
    TabOrder = 5
    OnClick = btnSpeedClick
  end
  object cbStresstest: TCheckBox
    Left = 224
    Top = 339
    Width = 74
    Height = 17
    Caption = 'Stresstest'
    TabOrder = 6
    OnClick = cbStresstestClick
  end
  object spedit: TSpinEdit
    Left = 189
    Top = 20
    Width = 109
    Height = 22
    MaxValue = 1000000
    MinValue = 1
    TabOrder = 7
    Value = 1000
  end
  object btndynadd: TButton
    Left = 108
    Top = 17
    Width = 75
    Height = 25
    Caption = 'btndynadd'
    TabOrder = 8
    OnClick = btndynaddClick
  end
  object btnclear: TButton
    Left = 27
    Top = 48
    Width = 75
    Height = 25
    Caption = 'btnclear'
    TabOrder = 9
    OnClick = btnclearClick
  end
  object btnDrawgridReset: TButton
    Left = 135
    Top = 335
    Width = 75
    Height = 25
    Caption = 'DrawgridReset'
    TabOrder = 10
    OnClick = btnDrawgridResetClick
  end
  object cbStresstestwrite: TCheckBox
    Left = 248
    Top = 370
    Width = 97
    Height = 17
    Caption = '(schreiben)'
    TabOrder = 11
    OnClick = cbStresstestwriteClick
  end
  object cbStresstestread: TCheckBox
    Left = 248
    Top = 355
    Width = 97
    Height = 17
    Caption = '(lesen)'
    TabOrder = 12
    OnClick = cbStresstestreadClick
  end
  object Button1: TButton
    Left = 27
    Top = 459
    Width = 75
    Height = 25
    Caption = 'btnsuchen'
    TabOrder = 13
    OnClick = Button1Click
  end
end
