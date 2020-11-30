object frmMediator: TfrmMediator
  Left = 563
  Top = 290
  Caption = 'Mediator das Mittelungstool f'#252'r Zeitreihen'
  ClientHeight = 649
  ClientWidth = 975
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  DesignSize = (
    975
    649)
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 72
    Width = 130
    Height = 13
    Caption = 'by Holger Schilke Mai 2019'
  end
  object Label2: TLabel
    Left = 649
    Top = 102
    Width = 65
    Height = 13
    Caption = 'Average (min)'
  end
  object Label3: TLabel
    Left = 10
    Top = 15
    Width = 16
    Height = 13
    Caption = 'File'
  end
  object Label4: TLabel
    Left = 8
    Top = 44
    Width = 42
    Height = 13
    Caption = 'Directory'
  end
  object BitBtn1: TBitBtn
    Left = 872
    Top = 63
    Width = 95
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Close'
    Kind = bkClose
    NumGlyphs = 2
    TabOrder = 0
    ExplicitLeft = 832
  end
  object cgdWerte: TXColorGrid
    Left = 8
    Top = 144
    Width = 968
    Height = 480
    Anchors = [akLeft, akTop, akRight, akBottom]
    ColCount = 2
    DefaultColWidth = 80
    DefaultRowHeight = 18
    RowCount = 2
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goColSizing, goColMoving, goAlwaysShowEditor]
    PopupMenu = PopupMenu1
    TabOrder = 1
    CellFormat = xSingleLine
    SelectColor = clWindow
    CellSelectable = False
    ExplicitWidth = 928
  end
  object bbnSave: TBitBtn
    Left = 872
    Top = 32
    Width = 89
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Save'
    Glyph.Data = {
      76010000424D7601000000000000760000002800000020000000100000000100
      04000000000000010000130B0000130B00001000000000000000000000000000
      800000800000008080008000000080008000808000007F7F7F00BFBFBF000000
      FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333333330070
      7700333333337777777733333333008088003333333377F73377333333330088
      88003333333377FFFF7733333333000000003FFFFFFF77777777000000000000
      000077777777777777770FFFFFFF0FFFFFF07F3333337F3333370FFFFFFF0FFF
      FFF07F3FF3FF7FFFFFF70F00F0080CCC9CC07F773773777777770FFFFFFFF039
      99337F3FFFF3F7F777F30F0000F0F09999937F7777373777777F0FFFFFFFF999
      99997F3FF3FFF77777770F00F000003999337F773777773777F30FFFF0FF0339
      99337F3FF7F3733777F30F08F0F0337999337F7737F73F7777330FFFF0039999
      93337FFFF7737777733300000033333333337777773333333333}
    NumGlyphs = 2
    TabOrder = 3
    OnClick = bbnSaveClick
  end
  object sb1: TStatusBar
    Left = 0
    Top = 630
    Width = 975
    Height = 19
    Panels = <
      item
        Width = 50
      end>
    ExplicitWidth = 935
  end
  object btnLoad: TButton
    Left = 612
    Top = 9
    Width = 75
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Load'
    TabOrder = 4
    OnClick = btnLoadClick
  end
  object cmbInterval: TComboBox
    Left = 693
    Top = 10
    Width = 65
    Height = 21
    Style = csDropDownList
    Anchors = [akTop, akRight]
    ItemIndex = 1
    TabOrder = 5
    Text = '1 min'
    Items.Strings = (
      '10 s'
      '1 min'
      '5 min'
      '10 min')
  end
  object deSource: TJvDirectoryEdit
    Left = 56
    Top = 38
    Width = 623
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 6
    Text = 'deSource'
    ExplicitWidth = 583
  end
  object feInput: TJvFilenameEdit
    Left = 55
    Top = 12
    Width = 546
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 7
    Text = 'feInput'
  end
  object cmbFiletype: TComboBox
    Left = 270
    Top = 65
    Width = 145
    Height = 21
    Style = csDropDownList
    TabOrder = 8
    OnChange = cmbFiletypeChange
    Items.Strings = (
      'Herrenhausen'
      'Dach'
      'Ruthe'
      'Ruthe Mast'
      'Dosimeter'
      'SolarHighFreq')
  end
  object btnFillGaps: TButton
    Left = 708
    Top = 37
    Width = 75
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Fill Gaps'
    TabOrder = 9
    OnClick = btnFillGapsClick
    ExplicitLeft = 680
  end
  object btnLoadFillGapSave: TButton
    Left = 710
    Top = 63
    Width = 156
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Load FillGap Save'
    TabOrder = 10
    OnClick = btnLoadFillGapSaveClick
    ExplicitLeft = 670
  end
  object cmbAvInterval: TComboBox
    Left = 733
    Top = 94
    Width = 65
    Height = 21
    Style = csDropDownList
    ItemIndex = 5
    TabOrder = 11
    Text = '1 h'
    Items.Strings = (
      '10 s'
      '1 min'
      '5 min'
      '10 min'
      '30 min'
      '1 h')
  end
  object btnAverage: TButton
    Left = 832
    Top = 94
    Width = 75
    Height = 25
    Caption = 'Average'
    TabOrder = 12
    OnClick = btnAverageClick
  end
  object PopupMenu1: TPopupMenu
    Left = 352
    Top = 192
    object menDelLine: TMenuItem
      Caption = 'Zeile l'#246'schen'
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object menSetToZero: TMenuItem
      Caption = 'Markiertes auf "0" setzen'
    end
    object menSetToValue: TMenuItem
      Caption = 'Markiertes Auf beliebigen Wert setzen'
    end
    object menVoidTemp: TMenuItem
      Caption = 'Ung'#252'ltige Temperatur => "-100.00"'
    end
    object menVoidHum: TMenuItem
      Caption = 'Ung'#252'ltige Feuchte => "NoFloat"'
    end
    object menVoidRad: TMenuItem
      Caption = 'Ung'#252'ltige Strahlung => "-100.0"'
    end
    object menSynthDiffRad: TMenuItem
      Caption = 'Synthetsiere Diffuse Strahlung'
    end
    object menMEZ2UTC: TMenuItem
      Caption = 'Winterzeit -> UTC'
    end
    object N11: TMenuItem
      Caption = '-'
    end
    object menPrecCorr: TMenuItem
      Caption = 'Niederschlagskorrektur + 0.01mm'
    end
    object menRadiationCorr: TMenuItem
      Caption = 'Strahlungskorrektur mit Offset'
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object menDespikeTemp: TMenuItem
      Caption = 'Despike Temperatur'
    end
    object menDespikeHum: TMenuItem
      Caption = 'Despike Feuchte'
    end
    object menDespikePress: TMenuItem
      Caption = 'Despike Druck'
    end
    object menDeZeroSpalte: TMenuItem
      Caption = 'DeZero Spalte'
    end
  end
  object SaveDialog1: TSaveDialog
    Left = 32
    Top = 160
  end
end
