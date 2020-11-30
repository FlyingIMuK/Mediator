program Mediator;

uses
  Forms,
  fMediator in 'fMediator.pas' {frmMediator},
  fMsgWin in '..\fMsgWin.pas' {frmMessageWindow},
  mGlobProc_B in '..\mGlobProc_B.pas',
  fAvTable in 'fAvTable.pas' {frmAverageResult};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmMediator, frmMediator);
  Application.CreateForm(TfrmMessageWindow, frmMessageWindow);
  Application.CreateForm(TfrmAverageResult, frmAverageResult);
  Application.Run;
end.
