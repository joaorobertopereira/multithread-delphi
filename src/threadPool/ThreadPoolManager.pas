unit ThreadPoolManager;

interface

uses
  System.SysUtils, System.Classes, System.Threading, System.SyncObjs,
  System.Generics.Collections, Winapi.Windows, HandlerException, Logger;

type
  TThreadPoolManager = class
  private
    FTaskQueue: TQueue<ITask>;
    FMaxThreads: Integer;
    FActiveThreads: Integer;
    FLock: TObject;
    FThreadFinishedEvent: TEvent;
    FExceptionHandler: THandlerException;
    FLogger: TLogger;
    procedure ThreadFinished;
    procedure LogTaskStart(const ThreadName: string);
    procedure LogTaskEnd(const ThreadName: string);
  public
    constructor Create(MaxThreads: Integer);
    destructor Destroy; override;
    procedure QueueTask(TaskProc: TProc; const ThreadName: string);
    procedure WaitForAll;
    function IsQueueFull: Boolean;
    function GetActiveThreadCount: Integer;
  end;

implementation

procedure SetThreadName(const ThreadName: string);
const
  MS_VC_EXCEPTION = $406D1388;
type
  TThreadNameInfo = record
    dwType: LongWord;     // Must be 0x1000
    szName: PAnsiChar;    // Pointer to name (in user addr space)
    dwThreadID: LongWord; // Thread ID (-1 for caller thread)
    dwFlags: LongWord;    // Reserved for future use, must be zero
  end;
var
  ThreadNameInfo: TThreadNameInfo;
  Logger: TLogger;
begin
  Logger := TLogger.Create;
  try
    ThreadNameInfo.dwType := $1000;
    ThreadNameInfo.szName := PAnsiChar(AnsiString(ThreadName));
    ThreadNameInfo.dwThreadID := $FFFFFFFF;
    ThreadNameInfo.dwFlags := 0;
    try
      RaiseException(MS_VC_EXCEPTION, 0,
        SizeOf(ThreadNameInfo) div SizeOf(LongWord), @ThreadNameInfo);
    except
      on E: Exception do
      begin
        Logger.Log(Format('Falha ao Setar o nome da Thread "%s": %s',
          [ThreadName, E.Message]), Error);
      end;
    end;
  finally
    Logger.Free;
  end;
end;

constructor TThreadPoolManager.Create(MaxThreads: Integer);
begin
  FMaxThreads := MaxThreads;
  FTaskQueue := TQueue<ITask>.Create;
  FLock := TObject.Create;
  FThreadFinishedEvent := TEvent.Create(nil, True, False, '');
  FActiveThreads := 0;
  FExceptionHandler := THandlerException.Create;
  FLogger := TLogger.Create;
  TThreadPool.Default.SetMaxWorkerThreads(FMaxThreads);
end;

destructor TThreadPoolManager.Destroy;
begin
  WaitForAll;
  FTaskQueue.Free;
  FLock.Free;
  FThreadFinishedEvent.Free;
  FExceptionHandler.Free;
  FLogger.Free;
  inherited Destroy;
end;

procedure TThreadPoolManager.QueueTask(TaskProc: TProc;
  const ThreadName: string);
var
  Task: ITask;
begin
  TMonitor.Enter(FLock);
  try
    Inc(FActiveThreads);
  finally
    TMonitor.Exit(FLock);
  end;

  Task := TTask.Run(
    procedure
    begin
      try
        SetThreadName(ThreadName);
        LogTaskStart(ThreadName);
        try
          TaskProc();
        except
          on E: Exception do
          begin
            FExceptionHandler.HandleException(E, 'QueueTask', ThreadName);
            raise;
          end;
        end;
      finally
        LogTaskEnd(ThreadName);
        ThreadFinished;
      end;
    end
  );
  FTaskQueue.Enqueue(Task);
end;

procedure TThreadPoolManager.ThreadFinished;
begin
  TMonitor.Enter(FLock);
  try
    Dec(FActiveThreads);
    if FActiveThreads = 0 then
      FThreadFinishedEvent.SetEvent;
  finally
    TMonitor.Exit(FLock);
  end;
end;

procedure TThreadPoolManager.WaitForAll;
begin
  FThreadFinishedEvent.WaitFor(INFINITE);
end;

function TThreadPoolManager.IsQueueFull: Boolean;
begin
  TMonitor.Enter(FLock);
  try
    Result := FActiveThreads >= FMaxThreads;
  finally
    TMonitor.Exit(FLock);
  end;
end;

function TThreadPoolManager.GetActiveThreadCount: Integer;
begin
  TMonitor.Enter(FLock);
  try
    Result := FActiveThreads;
  finally
    TMonitor.Exit(FLock);
  end;
end;

procedure TThreadPoolManager.LogTaskStart(const ThreadName: string);
begin
  FLogger.Log(Format('A Task %s Iniciou', [ThreadName]), Debug);
end;

procedure TThreadPoolManager.LogTaskEnd(const ThreadName: string);
begin
  FLogger.Log(Format('A Task %s Finalizou', [ThreadName]), Debug);
end;

end.
