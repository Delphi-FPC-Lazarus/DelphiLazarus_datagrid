object frmTest: TfrmTest
  Left = 0
  Top = 0
  Caption = 'frmTest'
  ClientHeight = 509
  ClientWidth = 589
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
    Width = 542
    Height = 274
    ColCount = 1
    DefaultColWidth = 150
    FixedCols = 0
    RowCount = 1
    FixedRows = 0
    TabOrder = 1
    OnDblClick = DrawGridDynDblClick
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
    Top = 421
    Width = 75
    Height = 25
    Caption = 'btnladen'
    TabOrder = 2
    OnClick = btnladenClick
  end
  object btnschreiben: TButton
    Left = 27
    Top = 359
    Width = 75
    Height = 25
    Caption = 'btnschreiben'
    TabOrder = 3
    OnClick = btnschreibenClick
  end
  object btntesten: TButton
    Left = 27
    Top = 390
    Width = 75
    Height = 25
    Caption = 'btntesten'
    TabOrder = 4
    OnClick = btntestenClick
  end
  object btnSpeed: TButton
    Left = 239
    Top = 359
    Width = 75
    Height = 25
    Caption = 'btnSpeed'
    TabOrder = 5
    OnClick = btnSpeedClick
  end
  object cbStresstest: TCheckBox
    Left = 448
    Top = 359
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
    Top = 359
    Width = 75
    Height = 25
    Caption = 'DrawgridReset'
    TabOrder = 10
    OnClick = btnDrawgridResetClick
  end
  object cbStresstestwrite: TCheckBox
    Left = 472
    Top = 394
    Width = 97
    Height = 17
    Caption = '(schreiben)'
    TabOrder = 11
    OnClick = cbStresstestwriteClick
  end
  object cbStresstestread: TCheckBox
    Left = 472
    Top = 379
    Width = 97
    Height = 17
    Caption = '(lesen)'
    TabOrder = 12
    OnClick = cbStresstestreadClick
  end
  object cbStresstestshuffle: TCheckBox
    Left = 472
    Top = 409
    Width = 97
    Height = 17
    Caption = '(shuffle)'
    TabOrder = 13
    OnClick = cbStresstestshuffleClick
  end
  object brnrepaint: TButton
    Left = 108
    Top = 48
    Width = 75
    Height = 25
    Caption = 'brnrepaint'
    TabOrder = 14
    OnClick = brnrepaintClick
  end
end
