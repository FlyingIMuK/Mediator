unit fAvTable;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Grids,
  ColorGrid;

type
  TfrmAverageResult = class(TForm)
    cgdAVGrid: TXColorGrid;
    Panel1: TPanel;
    btnAvSave: TButton;
    btnClose: TButton;
    SaveDialog1: TSaveDialog;
    procedure btnCloseClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnAvSaveClick(Sender: TObject);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  frmAverageResult: TfrmAverageResult;

implementation

{$R *.dfm}

uses mGlobProc_B, fMediator;

procedure TfrmAverageResult.btnAvSaveClick(Sender: TObject);
var
  sDir, sFN, sExt: string;
begin
  SaveDialog1.InitialDir := sGlobDataDir;
  AnalyseFileName(frmMediator.feInput.FileName, sDir, sFN, sExt);
  SaveDialog1.FileName := sDir + '\' + sFN + '_1.' + sExt;
  if SaveDialog1.Execute then
    if FileExists(SaveDialog1.FileName) then
      if MessageDlg('File exists! Overwrite?', mtConfirmation, [mbYes, mbNo], 0)
        = mrNo then
        exit;
   cgdAVGrid.bWriteToCSV(SaveDialog1.FileName, true);

end;

procedure TfrmAverageResult.btnCloseClick(Sender: TObject);
begin
self.Close;
end;

procedure TfrmAverageResult.FormShow(Sender: TObject);
begin
 cgdAVGrid.ColWidths[0] := 140;

end;

end.
