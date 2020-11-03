program Mediator;

uses
  Forms,
  fMediator in 'fMediator.pas' {frmMediator},
  fMsgWin in '..\fMsgWin.pas' {frmMessageWindow},
  mGlobProc_B in '..\mGlobProc_B.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmMediator, frmMediator);
  Application.CreateForm(TfrmMessageWindow, frmMessageWindow);
  Application.Run;
end.
