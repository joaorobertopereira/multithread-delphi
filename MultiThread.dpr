program MultiThread;

uses
  Vcl.Forms,
  HandlerException in 'src\handler\HandlerException.pas',
  DatabaseTask in 'src\task\DatabaseTask.pas',
  HttpTask in 'src\task\HttpTask.pas',
  TaskManager in 'src\task\TaskManager.pas',
  frm_principal in 'src\view\frm_principal.pas' {F_Principal},
  ThreadPoolManager in 'src\threadPool\ThreadPoolManager.pas',
  Logger in 'src\log\Logger.pas';

{$R *.res}


begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TF_Principal, F_Principal);
  Application.Run;
end.
