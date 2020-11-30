object frmAverageResult: TfrmAverageResult
  Left = 0
  Top = 0
  Caption = 'Averaging Result'
  ClientHeight = 432
  ClientWidth = 1025
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object cgdAVGrid: TXColorGrid
    Left = 0
    Top = 0
    Width = 1025
    Height = 391
    Align = alClient
    DefaultColWidth = 80
    DefaultRowHeight = 18
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goColSizing]
    TabOrder = 0
    CellFormat = xSingleLine
    SelectColor = clWindow
    CellSelectable = False
    ExplicitLeft = 8
    ExplicitWidth = 827
  end
  object Panel1: TPanel
    Left = 0
    Top = 391
    Width = 1025
    Height = 41
    Align = alBottom
    TabOrder = 1
    ExplicitLeft = 376
    ExplicitTop = 288
    ExplicitWidth = 185
    DesignSize = (
      1025
      41)
    object btnAvSave: TButton
      Left = 780
      Top = 6
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Save'
      TabOrder = 0
      OnClick = btnAvSaveClick
      ExplicitLeft = 672
    end
    object btnClose: TButton
      Left = 900
      Top = 6
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Close'
      TabOrder = 1
      OnClick = btnCloseClick
      ExplicitLeft = 792
    end
  end
  object SaveDialog1: TSaveDialog
    Left = 504
    Top = 224
  end
end
