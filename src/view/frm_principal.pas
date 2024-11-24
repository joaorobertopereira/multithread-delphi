unit frm_principal;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, ThreadPoolManager;

type
  TF_Principal = class(TForm)
    btn_genericTask: TButton;
    Memo1: TMemo;
    Memo: TMemo;
    procedure btn_genericTaskClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  F_Principal: TF_Principal;
  ThreadPoolManager: TThreadPoolManager;

implementation

{$R *.dfm}

procedure TF_Principal.btn_genericTaskClick(Sender: TObject);
begin
  if ThreadPoolManager.IsQueueFull then
  begin
    Memo1.Lines.Add('A fila de threads está cheia. Aguarde...');
  end
  else
  begin
    ThreadPoolManager.QueueTask(
      procedure
      var
        I: Integer;
      begin
        for I := 1 to 50 do
        begin
          TThread.Sleep(1000);
          TThread.Synchronize(nil,
            procedure
            begin
              Memo.Lines.Add(FormatDateTime('dd-mm-yyyy hh:mm:ss', Now) + ' - Task Executando ' + IntToStr(I));
            end);
        end;
      end,
      'CustomThreadName' // Nome da thread
    );
  end;
end;

procedure TF_Principal.FormCreate(Sender: TObject);
begin
  ThreadPoolManager := TThreadPoolManager.Create(10); // Inicializa o pool de threads
end;

end.
