unit TaskManager;

interface

uses
  System.SysUtils, HttpTask, DatabaseTask, ThreadPoolManager;

type
  TTaskManager = class
  private
    class var FInstance: TTaskManager;
    FHttpTask: THttpTask;
    FDatabaseTask: TDatabaseTask;
    FGenericTask: TThreadPoolManager;
    constructor CreateInstance;
    function GetMaxThreads(const EnvVar: string; Default: Integer): Integer;
  public
    constructor Create; reintroduce;
    destructor Destroy; override;
    class function GetInstance: TTaskManager;
    class function HttpTask: THttpTask;
    class function DatabaseTask: TDatabaseTask;
    class function GenericTask: TThreadPoolManager;
  end;

implementation

constructor TTaskManager.CreateInstance;
var
  MaxHttpThreads, MaxDbThreads, MaxGenericThreads: Integer;
begin
  inherited Create;
  MaxHttpThreads := GetMaxThreads('MAX_HTTP_THREADS', 4);
  MaxDbThreads := GetMaxThreads('MAX_DB_THREADS', 4);
  MaxGenericThreads := GetMaxThreads('MAX_GENERIC_THREADS', 4);

  FHttpTask := THttpTask.Create(MaxHttpThreads); // Inicializa o pool de threads com MaxHttpThreads
  FDatabaseTask := TDatabaseTask.Create(MaxDbThreads); // Inicializa o pool de threads com MaxDbThreads
  FGenericTask := TThreadPoolManager.Create(MaxGenericThreads); // Inicializa o pool de threads genérico com MaxGenericThreads
end;

constructor TTaskManager.Create;
begin
  raise Exception.Create('Use GetInstance instead of Create.');
end;

destructor TTaskManager.Destroy;
begin
  FHttpTask.Free;
  FDatabaseTask.Free;
  FGenericTask.Free;
  inherited Destroy;
end;

class function TTaskManager.GetInstance: TTaskManager;
begin
  if not Assigned(FInstance) then
  begin
    FInstance := TTaskManager.CreateInstance;
  end;
  Result := FInstance;
end;

function TTaskManager.GetMaxThreads(const EnvVar: string; Default: Integer): Integer;
var
  MaxThreadsStr: string;
begin
  MaxThreadsStr := GetEnvironmentVariable(EnvVar);
  if MaxThreadsStr = '' then
    Result := Default // Default value if the environment variable is not set
  else
    Result := StrToIntDef(MaxThreadsStr, Default); // Convert to integer, default to Default if conversion fails
end;

class function TTaskManager.HttpTask: THttpTask;
begin
  Result := GetInstance.FHttpTask;
end;

class function TTaskManager.DatabaseTask: TDatabaseTask;
begin
  Result := GetInstance.FDatabaseTask;
end;

class function TTaskManager.GenericTask: TThreadPoolManager;
begin
  Result := GetInstance.FGenericTask;
end;

end.
