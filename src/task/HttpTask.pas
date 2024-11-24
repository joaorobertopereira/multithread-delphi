unit HttpTask;

interface

uses
  System.SysUtils, IdHTTP, IdSSLOpenSSL, Classes, ThreadPoolManager;

type
  THttpTask = class(TThreadPoolManager)
  private
    FIdHTTP: TIdHTTP;
    FSSLHandler: TIdSSLIOHandlerSocketOpenSSL;
    procedure InitializeHTTP;
  public
    constructor Create(MaxThreads: Integer);
    destructor Destroy; override;
    procedure ExecuteHttpTask(const Method: string; const URL: string; const Data: string = '');
  end;

implementation

constructor THttpTask.Create(MaxThreads: Integer);
begin
  inherited Create(MaxThreads);
  InitializeHTTP;
end;

destructor THttpTask.Destroy;
begin
  FIdHTTP.Free;
  FSSLHandler.Free;
  inherited Destroy;
end;

procedure THttpTask.InitializeHTTP;
begin
  FIdHTTP := TIdHTTP.Create(nil);
  FSSLHandler := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
  FIdHTTP.IOHandler := FSSLHandler;
  FIdHTTP.Request.ContentType := 'application/json';
end;

procedure THttpTask.ExecuteHttpTask(const Method: string; const URL: string; const Data: string = '');
begin
  QueueTask(
    procedure
    var
      Response: string;
      StringStream: TStringStream;
    begin
      try
        if Method = 'GET' then
          Response := FIdHTTP.Get(URL)
        else if Method = 'POST' then
        begin
          StringStream := TStringStream.Create(Data, TEncoding.UTF8);
          try
            Response := FIdHTTP.Post(URL, StringStream);
          finally
            StringStream.Free;
          end;
        end
        else if Method = 'PUT' then
        begin
          StringStream := TStringStream.Create(Data, TEncoding.UTF8);
          try
            Response := FIdHTTP.Put(URL, StringStream);
          finally
            StringStream.Free;
          end;
        end
        else if Method = 'DELETE' then
          Response := FIdHTTP.Delete(URL);

        TThread.Queue(nil,
          procedure
          begin
            // Update UI with the response
          end);
      except
        on E: Exception do
        begin
          TThread.Queue(nil,
            procedure
            begin
              // Update UI with the error message
            end);
          raise;
        end;
      end;
    end,
    'HttpTaskThread'
  );
end;

end.
