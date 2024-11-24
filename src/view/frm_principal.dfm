object F_Principal: TF_Principal
  Left = 0
  Top = 0
  Caption = 'Principal'
  ClientHeight = 600
  ClientWidth = 800
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object btn_genericTask: TButton
    Left = 8
    Top = 105
    Width = 145
    Height = 65
    Caption = 'Generic Task'
    TabOrder = 0
    OnClick = btn_genericTaskClick
  end
  object Memo1: TMemo
    Left = 0
    Top = 176
    Width = 800
    Height = 104
    Align = alBottom
    ScrollBars = ssVertical
    TabOrder = 1
    ExplicitTop = 170
  end
  object Memo: TMemo
    Left = 0
    Top = 280
    Width = 800
    Height = 320
    Align = alBottom
    ScrollBars = ssVertical
    TabOrder = 2
  end
end
